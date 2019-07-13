#INCLUDE "PROTHEUS.CH"
#INCLUDE "Fileio.ch"
#INCLUDE "ap5mail.ch"
            
//--------------------------------------------------------------
/*/{Protheus.doc} AFATR05
Description  
//Envia e-mail para solicitantes
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Jose Antonio                                              
@since 30/04/2013                                                   
/*/                                                                 

*************************************
User Function AFATR05(pCotacao,pCodFor,pLoja,pMail,pFilial)
*************************************
*
	fProcessa(pCotacao,pCodFor,pLoja,pMail,pFilial)

Return(.T.)  


*************************************
Static Function fProcessa(pCotacao,pCodFor,pLoja,pMail,pFilial)
*************************************
* Gera o E-mail..
*

Local cNumCot  	:= SC8->C8_NUM
Local cFilCot     := SC8->C8_FILIAL
Local cQuery   := ""
Local cAlias   := "TRB"

cQuery := "SELECT DISTINCT(C8_FORNECE),C8_LOJA , C8_NUM, C8_FILIAL"
cQuery += " FROM "
cQuery += RetSqlName("SC8") + " SC8 "
cQuery += " WHERE D_E_L_E_T_ <> '*'
cQuery += " AND C8_FILIAL = '" + pFilial + "'"
cQuery += " AND C8_NUM = '" + pCotacao + "'"
cQuery += " AND C8_FORNECE = '" + pCodFor + "'"
cQuery += " AND C8_LOJA = '" + pLoja + "'"
cQuery += " ORDER BY C8_FORNECE"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.) 

dbSelectArea("TRB")
dbgoTop()

While !Eof("TRB") 
    
	EnviarMail(TRB->C8_NUM,TRB->C8_FORNECE,TRB->C8_LOJA,pMail,TRB->C8_FILIAL)
	
	dbSelectArea("TRB")
	dbSkip()

EndDo    

dbSelectArea("TRB")
dbCloseArea("TRB")

Return
    

Static Function EnviarMail(cNumCot,cFornece,cLoja,pMail,cFilCot)
********************************************************
**** Rotina de Envio de E-Mail
****************
Local cBody := ""              
Local lCabCot := .T.  
//POP.FLAPA.COM.BR
//SMTP.FLAPA.COM.BR    
//ti@flapa.com.br
//top45102                                              
Local cMailServer := Alltrim(GetNewPar("MV_ZZSMTP","smtp.flapa.com.br:587"))
Local cMailCtaAut := ""//Alltrim(GetNewPar("MV_ZZMAIL","ti@flapa.com.br"))
Local cFrom       := Alltrim(GetNewPar("MV_ZZFROM","Workflow Cotacao"))
Local cPws        := ""//Alltrim(GetNewPar("MV_ZZPWS","top45102"))

Local cTo         := ""
Local cSubJect    := "Solicitação de Cotação " + cNumCot
Local lEnviado    := .F.  
Local lSmtpAuth   := .T.
Local lOk         := .F. 
Local cNomeComp   := ""                                                        
Local cFileHtml   := ""
Local cNomeForn   := ""
Local cCaminho    := "c:\cotacoes"

If Empty(cMailServer)
   cMailServer := Alltrim(GetNewPar("MV_RELSERV","smtp.flapa.com.br:587"))
Endif

//Pega o e-mail e senha do comprador para usar e enviar o e-mail
dbSelectArea("SY1")
dbSetOrder(3)
if dbSeek(xFilial("SY1")+RetCodUsr())
	cMailCtaAut := Alltrim(SY1->Y1_EMAIL)
	cPws        := Alltrim(SY1->Y1_ZSENHA)
	cNomeComp   := Alltrim(SY1->Y1_NOME)
	cTelComp    := Alltrim(SY1->Y1_TEL)
endif

if Empty(cMailCtaAut) .Or. Empty(cPws)
	ApMsgInfo("E-mail e senha do comprador não cadastrados !!!")
	return
endif
        
CONNECT SMTP SERVER cMailServer ACCOUNT cMailCtaAut PASSWORD cPws RESULT lOk
	
If lSmtpAuth
	if lOk
		lAutOk := MailAuth(cMailCtaAut,cPws)
	EndIf 
Endif
	
If ! lOk .Or. ! lAutOk
	MsgStop("Nao foi possivel conectar no servidor smtp. MailServer:["+cMailServer+"] MailCtaAut: ["+cMailCtaAut+"]")
	Return
EndIF	                                           

dbSelectArea("SC8")
dbSetOrder(1)
If dbSeek(cFilCot+cNumCot+cFornece+cLoja)
                
	
	cNomeForn := Alltrim(Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_NOME"))	
	dbSelectArea("SC8")
	
	While !Eof("SC8") .And. SC8->C8_FILIAL == cFilCot .And. SC8->C8_NUM == cNumCot .And.;
					  SC8->C8_FORNECE == cFornece .And. SC8->C8_LOJA == cLoja
		
		If lCabCot
		
			cBody := '<html>'

			cBody += '<font size="2" face="Arial">Prezado fornecedor ' + cNomeForn +','+'</font><br><br>'
			
			cBody += '<font size="2" face="Arial">Solicitamos a cotação dos itens abaixo discriminados:  </font><br><br>'

			//cBody += '<b><font size="3" face="Arial">Numero da Cotação: ' + cNumCot + ' </font></b><br><br>'

			cBody += '<table font size="2" face="Arial" border=1>'
			//cBody += '<tr><td>' + 'Item' + '</td><td>'+'Especificação'+'</td><td>'+ 'UM'+'</td><td>'+'Quantidade'+'</td><td>'+'Valor Unitário R$'+'</td><td>'+'Valor Total R$'+'</td></tr>'
			cBody += '<tr><td>' + 'Item' + '</td><td>' +'Cod.Original' + '</td><td>'+ 'Especificação'+'</td><td>'+ 'Fabricante' + '</td><td>' + 'UM'+'</td><td>'+'Quantidade'+'</td><td>'+'Valor Unitário R$'+'</td><td>'+'Valor Total R$'+'</td></tr>'
			lCabCot := .F.
		EndIf

		cDescAdic := ""
		dbSelectArea("SB1")
		dbSetOrder(1)
      If ! Empty(SC8->C8_ZPRDSUB)
         If SB1->(MsSeek(xFilial("SB1")+SC8->C8_ZPRDSUB))
    	      cDescAdic += " (" + Alltrim(SB1->B1_FABRIC) +"/" + Alltrim(SB1->B1_ZREF2) + ")" 
         Endif
		Endif
		
		MsSeek(xFilial("SB1")+SC8->C8_PRODUTO)			  

		cBody += '<tr><td>' + Alltrim(SC8->C8_ITEM) + '</td><td>' + Alltrim(SB1->B1_ZREF1) + '</td><td>' + Alltrim(SC8->C8_ZDESCRI) + '</td><td>' + Alltrim(SB1->B1_FABRIC)+cDescAdic+ '</td><td>'+ SC8->C8_UM + '</td><td>'+ Transform(SC8->C8_QUANT,"@E 9,999,999.99") + '</td><td></td><td></td></tr>'
  	            
		dbSelectArea("SC8")
		dbSkip()		
	EndDo	

	cBody += '</table><br>'                                     
	

	cBody += '<font size="2" face="Arial">A resposta a esta cotação deverá atender fielmente às especificações acima. </font><br><br>'	
	cBody += '<font size="2" face="Arial">Tipo de frete: CIF _____ FOB _____. </font><br><br>'		
	cBody += '<font size="2" face="Arial">Prazo de entrega: ____________________ </font><br><br>'	
	cBody += '<font size="2" face="Arial">Condições de pagamento: ____________________ </font><br><br>'			
	cBody += '<font size="2" face="Arial">Agradecemos desde já. </font><br><br>'	
	//cBody += '<font size="2" face="Arial">Equipe de suprimentos FLAPA | TOPMIX </font><br>'	
	cBody += '<font size="2" face="Arial">'+cNomeComp+'</font><br>'	
	//cBody += '<font size="2" face="Arial">(31) 2103-1314 </font><br><br>'		
	cBody += '<font size="2" face="Arial">'+cTelComp+'</font><br><br>'
	
	
	cBody += '</body></html>'

EndIf
	
//APMsgAlert(cBody)		
cTo	:=	pMail 
	
If lSmtpAuth .And. lOk .And. lAutOk

	SEND MAIL FROM cMailCtaAut TO cTo SUBJECT cSubJect BODY cBody RESULT lEnviado 
		
	If !lEnviado
		GET MAIL ERROR cError
		MsgInfo(cError,"Erro no envio da cotação " + cNumCot + " para o fornecedor " + cFornece + "/" + cLoja + ".")		
	endif
Else
	lEnviado := .F.
EndIf                                                                         

cFileHtml := "Cotacao-" + cNumCot + "-"+ Alltrim(Left(cNomeForn,20)) +".Html" 
nMakeDir := MAKEDIR( cCaminho )
MemoWrite(cCaminho + "\" + cFileHtml ,cBody)

If File(cCaminho + "\" + cFileHtml)
	MsgInfo("Foi gerado um arquivo em c:\cotacoes\ contendo: " + cFileHtml,"Atenção Comprador!")
EndIf

If lOk
	DISCONNECT SMTP SERVER
EndIf 
	
Return







//--------------------------------------------------------------
/*/{Protheus.doc} FDescPrd
//Retorna a descrição completa do produto
                                                                
@param  codigo produto
@return Descricao
@author Rodrigo Carvalho
@since  02/02/2016                                                   
/*/                                                                 
//--------------------------------------------------------------

Static Function FDescPrd(cCodProd)

Local cDescri := ""

dbSelectArea("SB1")                 
DbSetOrder(1)
dbSeek(xFilial("SB1") + cCodProd )

cDescri := Alltrim(SB1->B1_DESC)
	 
If ! Empty(SC8->C8_ZPRDSUB)

	If SB1->(MsSeek(xFilial("SB1")+SC8->C8_ZPRDSUB))
    	cDescri += " (" + Alltrim(SB1->B1_FABRIC) +"/" + Alltrim(SB1->B1_ZREF2) + ")" 
   Endif

ElseIf ! Empty(SB1->B1_FABRIC) .Or. ! Empty(SB1->B1_ZREF1)   

  	cDescri += " (" + Alltrim(SB1->B1_FABRIC) +"/" + Alltrim(SB1->B1_ZREF1) + ")" 

EndIf   

cDescri +=" " + Alltrim(SC8->C8_ZOBSADI)
	 
Return(cDescri)
