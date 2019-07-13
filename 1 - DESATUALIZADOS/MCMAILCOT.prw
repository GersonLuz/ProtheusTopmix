#Include "RwMake.ch" 
#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "ap5mail.ch"
//--------------------------------------------------------------
/*/{Protheus.doc} MCMAILCOT
Enviar email para os fornecedores vinculados a cotação de compra.

@param  
@author Rodrigo Carvalho
@since  15/12/2015
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
            
User Function MCMAILCOT( cAlias, nRegSC8 , nOpcX )

Local nTotReg := 0
Local aLstFor := {}
Local lOk     := .f.

DbSelectArea("SC8")
SC8->(DbGoto(nRegSC8))

cFilCt  := SC8->C8_FILIAL
cNumCot := SC8->C8_NUM

MsAguarde( { |lEnd| FCarrDados(cFilCt,cNumCot,@nTotReg)},"Aguarde","Enviando e-mail... Aguarde... ",.T.)

dbSelectArea("TRB")
If nTotReg == 0
   dbCloseArea("TRB")
   MsgBox("Não foram encontrados registros com esses parametros!","Envio de e-mail Fornecedores", "ALERT")
   Return .T.
Endif   

aLstFor := McEditMail(3,"TRB",cNumCot,@lOk) // editar os e-mails do cadastro do fornecedor.
                               
dbSelectArea("TRB")
dbCloseArea("TRB")

If lOk
   For nXy := 1 To Len(aLstFor) 
	    EnviarMail(aLstFor[nXy][01],aLstFor[nXy][02],aLstFor[nXy][03],aLstFor[nXy][04],aLstFor[nXy][05],aLstFor[nXy][06])
   Next
Endif

DbSelectArea("SC8")
SC8->(DbGoto(nRegSC8))

Return(.T.)  




//--------------------------------------------------------------
/*/{Protheus.doc} FCarrDados
Enviar email para os fornecedores vinculados a cotação de compra.

@param  
@author Rodrigo Carvalho
@since  15/12/2015
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
Static Function FCarrDados(cFilCt,cNumCot,nTotReg)

Local   cQuery  := ""
Local   cAlias  := "TRB" 
Default nTotReg := 0

cQuery := "SELECT DISTINCT C8_FILIAL,C8_NUM,C8_FORNECE,C8_LOJA,A2_NOME, (CASE WHEN C8_ZEMAIL = ' ' THEN A2_EMAIL ELSE C8_ZEMAIL END) A2_EMAIL"
cQuery += " FROM "
cQuery += RetSqlName("SC8") + " SC8 "
cQuery += " INNER JOIN "+RetSqlName("SA2")+" A2 ON A2_COD = C8_FORNECE AND A2_LOJA = C8_LOJA AND A2.D_E_L_E_T_ <> '*'"
cQuery += " WHERE SC8.D_E_L_E_T_ <> '*'"
cQuery += "   AND C8_FILIAL  = '" + cFilCt  + "'"
cQuery += "   AND C8_NUM     = '" + cNumCot + "'" /* AND C8_FILENT IN ('"+Space(Len(cFilCt))+"','"+cFilCt+"')*/
cQuery += " ORDER BY 1,2,3,4"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.) 

dbSelectArea("TRB")
DbgoTop()
TRB->(dbEval({ || nTotReg++ }))
DbgoTop()

Return
    




//--------------------------------------------------------------
/*/{Protheus.doc} EnviarMail

@param  
@author Rodrigo Carvalho
@since  15/12/2015
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
Static Function EnviarMail(cFilCot,cNumCot,cFornece,cLoja,cNomeForn,cMailDest)
                         
Local cSubJect    := "Solicitação de Cotação " + cNumCot
Local cDestino    := "C:\cotacoes\"
Local cMailComp   := ""
Local lCabCot     := .T.             
Local cCodUsr     := RetCodUsr()
Local cHtml       := ""
Local cTexto      := ""
Local lEnviaMsg   := .F.

//cMailDest   := "rodrigo.carvalho@maiscs.com.br"

dbSelectArea("SY1")
dbSetOrder(3)
If ! dbSeek( xFilial("SY1") + cCodUsr )
	MsgInfo("O Comprador não possui as informações de envio de e-mail","Atenção Comprador!")
	Return .F.
Endif

If Empty(SY1->Y1_EMAIL) 
	MsgInfo("O Comprador não possui as informações de envio de e-mail","Atenção Comprador!")
	Return .F.
Endif

cUsuMail   := lower(Alltrim(SY1->Y1_EMAIL))
cCtaEmail  := lower(Alltrim(SY1->Y1_EMAIL))	
cPswEmail  := Alltrim(SY1->Y1_ZSENHA)
cNomeComp  := Alltrim(SY1->Y1_NOME)
cTelComp   := Alltrim(SY1->Y1_TEL)

dbSelectArea("SC8")
dbSetOrder(1) //C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD
DbSeek(cFilCot + cNumCot + cFornece + cLoja , .T. )

If ! SC8->(Eof())

	dbSelectArea("SC8")
	Do While ! Eof("SC8") .And. SC8->(C8_FILIAL + C8_NUM + C8_FORNECE + C8_LOJA) == (cFilCot + cNumCot + cFornece + cLoja )
		
      If lCabCot
         cHtml := '<html>'
         cHtml += '   <font size="2" face="Arial">Prezado fornecedor</font>'
         cHtml += '   <font face="Arial"><b>'+cNomeForn+'</b></font>'
         cHtml += '   <font size="2" face="Arial">,</font><br><br>'
         cHtml += '   <font size="2" face="Arial">Solicitamos a cotação dos itens abaixo discriminados:</font><br><br>'
         cHtml += '   <table font size="2" face="Arial" border=1>'
         cHtml += '<tr>'           
         cHtml += '	<td bgcolor="#C0C0C0"><font size="2"><b>Item</b></font></td>'                         
         cHtml += '	<td bgcolor="#C0C0C0"><font size="2"><b>Cod.Original</b></font></td>'
         cHtml += '	<td bgcolor="#C0C0C0"><font size="2"><b>Descrição</b></font></td>'
         cHtml += '	<td bgcolor="#C0C0C0" width="88"><font size="2"><b>Fabricante/Observação</b></font></td>'
         cHtml += '	<td bgcolor="#C0C0C0"><font size="2"><b>UM</b></font></td>'
         cHtml += '	<td bgcolor="#C0C0C0"><font size="2"><b>Quantidade</b></font></td>'
         cHtml += '	<td bgcolor="#C0C0C0"><font size="2"><b>Vl.Unitário</b></font></td>'
         cHtml += '	<td bgcolor="#C0C0C0"><font size="2"><b>Total</b></font></td>'
         cHtml += '</tr>'
         lCabCot := .F.
      EndIf

		cDescAdic := Alltrim(SC8->C8_ZOBSADI)
		dbSelectArea("SB1")
		dbSetOrder(1)    

      If ! Empty(SC8->C8_ZPRDSUB)
         If SB1->(MsSeek(xFilial("SB1")+SC8->C8_ZPRDSUB))
    	      cDescAdic += IIf(Empty(SB1->B1_ZREF2),""," (" + Alltrim(SB1->B1_ZREF2) + ")" )
         Endif
		Endif
      
      MsSeek(xFilial("SB1")+SC8->C8_PRODUTO)

		cHtml += '<tr><td>' + Alltrim(CAPITALACE(SC8->C8_ITEM))             +'</td><td>'+;
		                      Alltrim(CAPITALACE(SB1->B1_ZREF1))            +'</td><td>'+;
		                      Alltrim(CAPITALACE(SC8->C8_ZDESCRI))          +'</td><td>'+;
		                      Alltrim(CAPITALACE(SB1->B1_FABRIC))+IIF(Empty(CAPITALACE(cDescAdic)),"","/")+CAPITALACE(cDescAdic) +'</td><td>'+;
		                      SC8->C8_UM                        +'</td><td>'+;
		            Transform(SC8->C8_QUANT,"@E 9,999,999.99")  +'</td><td></td><td></td></tr>'
  	            
		dbSelectArea("SC8")
		SC8->(dbSkip())
	
	EndDo	

	cHtml += '</table><br>'
	cHtml += '<font size="2" face="Arial">A resposta a esta cotação deverá atender fielmente às especificações acima. </font><br><br>'
	cHtml += '<font size="2" face="Arial">Tipo de frete: CIF _____ FOB _____. </font><br><br>'
	cHtml += '<font size="2" face="Arial">Prazo de entrega: ____________________ </font><br><br>'
	cHtml += '<font size="2" face="Arial">Condições de pagamento: ____________________ </font><br><br>'			
	cHtml += '<font size="2" face="Arial">Agradecemos desde já. </font><br><br>'
	cHtml += '<font size="2" face="Arial">'+cNomeComp+'</font><br>'
	cHtml += '<font size="2" face="Arial">'+cTelComp+'</font><br><br>'
	cHtml += '</body><b><font face=Arial size=6><img src=http://topmix.com.br/wp-content/uploads/2016/02/logotipo-topmix.png width="146" height="76"></font></b></html>'

   cFileHtml := "Cotacao-" + Alltrim(cNumCot) + "-"+ Alltrim(cNomeForn) +".Html" 
   cFileHtml := StrTran(cFileHtml," ","_") 

   nMakeDir := MAKEDIR( cDestino )

   MemoWrite(cDestino + "\" + cFileHtml ,cHtml)

   lEnviaMsg := U_MCSendMail(cSubJect,{},cTexto,cHtml,{},cMailDest,cUsuMail,cCtaEmail,cPswEmail,,)

   If File(cDestino + "\" + cFileHtml)
	   MsgInfo("Foi gerado o arquivo na pasta: "+cDestino+CRLF+" Contendo: " + cFileHtml,"Atenção Comprador!")
   EndIf
   
   If lEnviaMsg

      dbSelectArea("SC8")
      dbSetOrder(1) //C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD
      DbSeek(cFilCot + cNumCot + cFornece + cLoja , .T. )
      Do While ! Eof("SC8") .And. SC8->(C8_FILIAL + C8_NUM + C8_FORNECE + C8_LOJA) == (cFilCot + cNumCot + cFornece + cLoja )
         RecLock("SC8",.F.)
         Replace SC8->C8_ZEMAIL With cMailDest + IIf(Empty(SC8->C8_ZEMAIL),"",";"+Alltrim(SC8->C8_ZEMAIL))
         SC8->(MsUnlock())
         DbSelectArea("SC8")
         SC8->(dbSkip())
      EndDo
   
   Endif

Else
   ApMsgAlert("Cotação "+cFilCot+"/"+cNumCot+" não encontrada para o fornecedor: "+cFornece+"/"+cLoja)
   Return .F.
EndIf

Return(lEnviaMsg)




//-------------------------------------------------------------------
/*/{Protheus.doc} McEditMail

@protected
@author    Rodrigo Carvalho
@since     12/04/2016
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function McEditMail(nOpx,cAlias,cNumCot,lOk)
                                
Local aArea       := GetArea()
Local oDlgAlter
Local aObjects    := {}
Local aPosObj     := {}
Local lContinua   := .T.

Local aSize       := MsAdvSize(.T.,.F.,300) //(lEnchoiceBar,lTelaPadrao,ntamanho_linhas)
Local aInfo       := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local oFont       := TFont():New( "Arial",,16,,.T.,,,,.F.,.F. )

Local bWhen		   := {|| Nil}
Local nMaxPrds    := SuperGetMv("MC_MXPRALT",,99) // numero maximo de registros
Local cIniCpos    := "" // incremento automatico.

Private aHeaderCT := {}
Private aColsCt   := {} 

Private oGdSG
Private aEditCpos := {}
Private N         := 1

Define FONT oBold   NAME "Arial" Size 0, -12 BOLD

aHeaderCt := FHeader(cAlias)

aAdd(aEditCpos,"A2_EMAIL" )

Inclui  := .F.
Altera  := .T.
lDeleta := .T.  

FBuscaDados(cAlias)

AADD(aObjects,{100,100,.T.,.T.})  // {TamX,TamY,DimX,DimY,lDimensaoXeY}

aPosObj:=MsObjSize(aInfo,aObjects)

oDlgAlter:=MSDialog():New(aSize[7],0,aSize[6],aSize[5],OemToAnsi(cCadastro),,,,,,,,,.t.)
oDlgAlter:lEscClose:=.F.
oDlgAlter:lMaximized:=.T.

TGroup():New(aPosObj[1,1],aPosObj[1,2],025,aPosObj[1,4]-5,OemToAnsi(""),oDlgAlter,,,.T.)

@ aPosObj[1,1]+05,aPosObj[1,2]+05  SAY "Cotação: "+cNumCot Size 070,10 Pixel OF oDlgAlter FONT oBold 

oGdSG :=	MsNewGetDados():New(aPosObj[1][1]+30,aPosObj[1][2]+5,aPosObj[1,3],aPosObj[1,4]-5,nOpx,"U_FValida(N)","U_FValida(N)",,aEditCpos,,,,,,oDlgAlter,aHeaderCt,aColsCt)

oDlgAlter:Activate(,,,.t.,,EnchoiceBar(oDlgAlter,{|| lOk:=.T., Iif(oGdSG:TudoOk(),oDlgAlter:End(),lOk:=.f.)}, {||oDlgAlter:End()},,{}))

RestArea(aArea)

Return( aClone(oGdSG:ACOLS) )   



//-------------------------------------------------------------------
/*/{Protheus.doc} FHeader
Carrega os campos da tabela

@protected
@author    Rodrigo Carvalho
@since     12/04/2016
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FHeader(cAlias)

Local aStruDB := (cAlias)->(dbStruct())
Local nXy
Local aHeaderTmp := {} 

DbSelectArea(cAlias)

dbSelectArea("SX3")
SX3->(dbSetOrder(2)) 

For nXy := 1 To Len(aStruDB)
    If SX3->(dbSeek(aStruDB[nXy][1]))                                                                      
      // If X3USO(SX3->X3_USADO)
	      AADD(aHeaderTmp,{ALLTRIM(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
     //  EndIf
    Endif
Next

Return(aClone(aHeaderTmp))
                         






//-------------------------------------------------------------------
/*/{Protheus.doc} FBuscaDados()

@protected
@author    Rodrigo Carvalho
@since     12/04/2016
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------

Static Function FBuscaDados(cAlias)

Local cChave

DbSelectArea(cAlias)
DbGoTop()

n := 1
AADD(aColsCt,Array(Len(aHeaderCt)+1))   
aColsCt[Len(aColsCt)][Len(aHeaderCt)+1] := .F.   

Do While !(cAlias)->(Eof())
   If ! Empty(aColsCt[1][1])
     AADD(aColsCt,Array(Len(aHeaderCt)+1))   
   Endif
   For nXy := 1 To FCount() 
       nPosHeader := Ascan(aHeaderCt,{|x| Alltrim(x[2])== FieldName(nXy) })
       If  nPosHeader > 0
          aColsCt[Len(aColsCt)][nPosHeader] := (cAlias)->(&(FieldName(nXy)))
       Endif
   Next
   aColsCt[Len(aColsCt)][Len(aHeaderCt)+1] := .F.   
   (cAlias)->(dbSkip())
Enddo

Return .t.





//-------------------------------------------------------------------
/*/{Protheus.doc} FValida

@protected
@author    Rodrigo Carvalho
@since     12/04/2016
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FValida(nLinha)

Local lRetorno := .T.

If GdDeleted(nLinha)
   lRetorno := .T.
Else
   If nLinha > 0
  
   Endif
Endif

Return(lRetorno)
