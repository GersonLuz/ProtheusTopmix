#Include "PROTHEUS.CH"
#INCLUDE "ap5mail.ch"
//--------------------------------------------------------------
/*/{Protheus.doc} AFATP11
Description  
//sinalizar processo finalizado                                                   
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Jose Antonio (AMM)                                              
@since 24/01/2013                                                   
/*/                                                             
//--------------------------------------------------------------  
//Sinalizar Processo Finalizado
******************************
User Function AFATP11()       
******************************

Local aAliasOLD := GetArea()    
Local cUsrOcor  := UsrRetName(RetCodUsr())
Local cCodOcor  := RetCodUsr() 
Local cFilSC7   := aWBrowse4[nRegSC8,12]
Local cNUM      := aWBrowse4[nRegSC8,03] 
Local cAliasQry := GetNextAlias()   

Local aCab      := {}
Local aItens    := {}
Local cNumSC1   := ""
Local aItem     := {}      

Local aAliasOLD := GetArea()
Local cCodProcesso, cCodStatus, cHtmlModelo, cMailID
Local cUsuarioProtheus, cTexto, cAssunto
Local oProcess          
       
Private cPedido  := ""
Private cCotacao := ""    

Private aListBox1 := {}
Private oListBox1     
Private oOk 	   := LoadBitmap( GetResources(), "LBOK"       )
Private oNo 	   := LoadBitmap( GetResources(), "LBNO"       )  

if Empty(aWBrowse4[nRegSC8,02]) .Or. Empty(aWBrowse4[nRegSC8,10])
	ApMsgInfo("Não existe ordem de compras a ser finalizada !!!")
	return
endif

If MsgYesNo( "Confirma a liberação do pedido " + cNUM + " ?" )  

  	BeginSql Alias cAliasQry 
  		SELECT C7_FILIAL,C7_NUM,C7_NUMSC,C7_NUMCOT,A2_NOME,C7_LOJA,C7_PRODUTO,B1_DESC,C7_QUANT,SC7.R_E_C_N_O_ AS RECSC7,C1_FILIAL,C7_ITEMSC, C7_ITEM
		FROM %table:SC7% SC7                                                 
		INNER JOIN %table:SA2% SA2 ON SC7.C7_FORNECE = SA2.A2_COD AND SC7.C7_LOJA   = SA2.A2_LOJA AND SA2.%notDel%   
		INNER JOIN %table:SB1% SB1 ON SC7.C7_PRODUTO = SB1.B1_COD AND SB1.%notDel%
		INNER JOIN %table:SC1% SC1 ON SC7.C7_FILIAL = SC1.C1_ZFILFAT AND SC7.C7_NUMSC = SC1.C1_NUM AND SC7.C7_ITEMSC = SC1.C1_ITEM AND SC1.%notDel%   
		WHERE SC7.%notDel% 	AND   
  		SC7.C7_CONAPRO IN (%Exp:'B'%) AND
  		SC7.C7_USER    = %Exp:cCodUser% AND
  		SC7.C7_FILIAL  = %Exp:cFilSC7% AND 
  		SC7.C7_NUM     = %Exp:cNUM%
      	ORDER BY C7_NUM,A2_NOME,C7_PRODUTO                		
  	EndSql         
  	
	(cAliasQry)->( DbGoTop() )
	While !(cAliasQry)->(Eof()) 

	 	dbSelectArea("SC7")
	  	dbSetOrder(1)
	  	if dbSeek((cAliasQry)->(C7_FILIAL)+(cAliasQry)->(C7_NUM)+(cAliasQry)->(C7_ITEM),.T.)
	 		dbSelectArea("SC7") 
			If RecLock("SC7", .F.) 
			  	SC7->C7_CONAPRO:='L'
				cPedido :=SC7->C7_NUM
				cCotacao:=SC7->C7_NUMCOT    
				MsUnLock()
			Endif	  
			
		  	dbSelectArea("SC1")
		  	dbSetOrder(1)                                                                  
		  	if dbSeek((cAliasQry)->C1_FILIAL+(cAliasQry)->C7_NUMSC+(cAliasQry)->C7_ITEMSC,.T.) //     
				If SC1->C1_ZSTATUS <> "6"
					If RecLock("SC1", .F.) 
				        SC1->C1_ZSTATUS:= "6" 
						MsUnLock() 
					Endif
				Endif	  
			endif   

		  	dbSelectArea("SC8")
		  	dbSetOrder(1)
	  		IF dbSeek(xFilial("SC8")+SC7->C7_NUMCOT+SC7->C7_FORNECE+SC7->C7_LOJA,.T.)    
  				While !Eof() .And. SC8->C8_FILIAL   == xFilial("SC8")  .And. ;
  	  					   		   SC8->C8_NUM      == SC7->C7_NUMCOT  .And. ;
  	  					   		   SC8->C8_FORNECE  == SC7->C7_FORNECE .And. ;
  	  				   			   SC8->C8_LOJA     == SC7->C7_LOJA 
	  	  			IF Alltrim(SC8->C8_PRODUTO) == Alltrim(SC7->C7_PRODUTO)   		                          
						   If RecLock("SC8", .F.) 
						 		SC8->C8_ZSTATUS := "6"   
								MsUnLock()
						   Endif		
					Endif
					dbSkip()
				Enddo		  
			EndIf   
	
			dbSelectArea("SZ2") 
			cNumCot := GetSxENum("SZ2","Z2_NUMERO") 
			ConfirmSX8()
			If RecLock("SZ2", .T.) 
			    SZ2->Z2_FILIAL   := SC7->C7_FILIAL
			    SZ2->Z2_NUMERO   := cNumCot
			    SZ2->Z2_CODIGO   := "999" 
			   	SZ2->Z2_NUMSC    := SC7->C7_NUMSC
			   	SZ2->Z2_PRODUTO  := SC7->C7_PRODUTO
			   	SZ2->Z2_ITEMSC   := SC7->C7_ITEMSC
			   	SZ2->Z2_NUMCOT   := SC7->C7_NUMCOT
			   	SZ2->Z2_CODUSR   := cCodOcor
			   	SZ2->Z2_NOMEUSR  := cUsrOcor
			  	SZ2->Z2_MOTIVO   := "PEDIDO LIBERADO"   
			   	SZ2->Z2_DATA     := DATE()
			   	SZ2->Z2_HORA     := TIME()
			   	SZ2->Z2_EMAIL1   := ""
			   	SZ2->Z2_EMAIL2   := ""
			   	SZ2->Z2_EMAIL3   := ""
			   	SZ2->Z2_EMAIL4   := ""
			   	SZ2->Z2_EMAIL5   := ""
				MsUnLock()  
			Endif	    
	
			aEmpresa:=u_fSIGAMAT()// Funcao para buscar as empresas
			For xE:=1 to Len(aEmpresa)   
				cEmpAux   := aEmpresa[xE,1]  
				FGraSC1(cEmpAux,SC7->C7_NUMCOT,SC7->C7_PRODUTO,(cAliasQry)->C1_FILIAL,SC7->C7_NUMSC,SC7->C7_ITEMSC) // Grava na empresa 01
			Next
	  	
	  	endif	                                    
	
	  	(cAliasQry)->( dbSkip() )
	
	enddo
	
	(cAliasQry)->(dbCloseArea())  
	
	//Pergunta se o Frete e CIF ou FOB
	//Se for FOB gera uma SC
	If MsgYesNo("O frete do pedido " + cNUM + " será FOB ?")  
	
		DEFINE MSDIALOG oDlgFre TITLE "Solicitação de Compras - Frete" FROM C(178),C(181) TO C(460),C(705) PIXEL
		
		// Cria as Groups do Sistema
		@ C(002),C(002) TO C(126),C(262) LABEL "  Empresas / Filiais  " PIXEL OF oDlgFre
		
		// Cria Componentes Padroes do Sistema
		@ C(128),C(183) Button "&Confirmar" Size C(037),C(012) Action MsAguarde( {||fConfFr() },"ATENÇÃO","Gerando solicitações de frete... Aguarde...",.F.) PIXEL OF oDlgFre
		@ C(128),C(223) Button "&Fechar" Size C(037),C(012) Action oDlgFre:End() PIXEL OF oDlgFre
		
		// Cria ExecBlocks dos Componentes Padroes do Sistema
		
		// Chamadas das ListBox do Sistema
		fListBox1()
		
		ACTIVATE MSDIALOG oDlgFre CENTERED 
	
	endif	
		  		
Endif  


RestArea(aAliasOLD)             

Return()  
/*
Gravar no SC1 status  6
*/
Static Function FGraSC1(pEmp,pCotacao,pProduto,pFilSC,pNumSC,pItSC)
Local aAliasOLD := GetArea()
	Begin Transaction    
		//_cSql := "UPDATE SC1" + pEmp + "0 SET C1_ZSTATUS = '6' WHERE C1_ZSTATUS = '3' AND C1_COTACAO = '" + pCotacao + "' AND C1_PRODUTO = '" + Alltrim(pProduto) + "'"
		_cSql := "UPDATE SC1" + pEmp + "0 SET C1_ZSTATUS = '6' WHERE C1_FILIAL = '" + Alltrim(pFilSC) + "' AND C1_NUM = '" + Alltrim(pNumSC) + "' AND C1_ITEM = '" + Alltrim(pItSC) + "'"
    	_Retorno := TCSQLExec(_cSql)   
 	End Transaction	
	If _Retorno < 0 
		_GetErroTop := TCSQLError()							
		MsgStop("Error ocorreram na execucao da Query no banco de dados. Veja detalhes no log Afatp03.TXT","Erro","Alert")
	Endif
RestArea(aAliasOLD)
Return()	 


Static Function EnviarMail(cNumero,cPedido,cCotacao)
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
Local cMailCtaAut := Alltrim(GetNewPar("MV_ZZMAIL","ti@flapa.com.br"))
Local cFrom       := Alltrim(GetNewPar("MV_ZZFROM","Workflow Cotacao"))
Local cPws        := Alltrim(GetNewPar("MV_ZZPWS","top45102"))
Local cTo         := Alltrim(GetNewPar("MV_ZEMAILFR","compras@flapa.com.br"))
Local cSubJect    := "Solicitação de Compra Numero: " +cNumero
Local lEnviado    := .F.  
Local lSmtpAuth   := .T.
Local lOk         := .F.  
        
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailCtaAut PASSWORD cPws RESULT lOk
	
	If lSmtpAuth
		if lOk
			lAutOk := MailAuth(cMailCtaAut,cPws)
		EndIf 
	Endif
	
	If !lOk .Or. !lAutOk
		MsgStop("Nao foi possivel conectar no servidor smtp ...")
		Return
	EndIF	
	cBody := '<html>'
	cBody += '<head>'
	cBody += '<title> A Solicitação de Compra, referente a frete foi incluída. </title>'
	cBody += '</head>'  
	cBody += '<b><font size="3" face="Arial">A Solicitação de Compras referente a frete foi incluída. </font></b><br><br>'
	cBody += '<b><font size="3" face="Arial">Numero da Solicitação: ' + cNumero + ' </font></b><br><br>'
	cBody += '<b><font size="3" face="Arial">     Numero do Pedido: ' + cPedido + ' </font></b><br><br>'
	cBody += '<b><font size="3" face="Arial">    Numero da Cotação: ' + cCotacao + ' </font></b><br><br>'
	cBody += '<b><font size="3" face="Arial">      Data da Emissão: ' + DTOC(DATE())+' </font></b><br><br>'
	cBody += '<b><font size="3" face="Arial">      Hora da Emissão: ' + time()+' </font></b><br><br>'
	cBody += '<b><font size="3" face="Arial">      Nome do Usuario: ' + SubStr(cUsuario,7,15)+' </font></b><br><br>'
	lCabCot := .F.
	
	cBody += '</table><br>'
	
	cBody += '</body></html>'

	If lSmtpAuth .And. lOk .And. lAutOk

		SEND MAIL FROM cMailCtaAut TO cTo SUBJECT cSubJect BODY cBody RESULT lEnviado 
		
		If !lEnviado
			GET MAIL ERROR cError
			MsgInfo(cError,"Erro no envio da solicitação " + cNumero + " não foi enviada.")		
		endif
	Else
		lEnviado := .F.
	
	EndIf 

	If lOk
		DISCONNECT SMTP SERVER
	EndIf 
	
Return 

******************************************
Static Function fListBox1()
******************************************
*
*
                                
	// Carrege aqui sua array da Listbox
	Aadd(aListBox1,{.F.,"","",""})

	@ C(008),C(005) ListBox oListBox1 Fields ;
		HEADER "","Empresa","Filial","Nome";
		Size C(254),C(117) Of oDlgFre Pixel;
		ColSizes 30,40,50;
	On DBLCLICK ( aListBox1[oListBox1:nAt,1] := !(aListBox1[oListBox1:nAt,1]), oListBox1:Refresh() )
	oListBox1:SetArray(aListBox1)        
	
	// Cria ExecBlocks das ListBoxes
	oListBox1:bLine 		:= {|| {;
	If(aListBox1[oListBox1:nAT,1],oOk,oNo),;
		aListBox1[oListBox1:nAT,02],;
		aListBox1[oListBox1:nAT,03],;
		aListBox1[oListBox1:nAT,04]}}
	
	fLista()

Return Nil 

******************************************
Static Function fLista()
******************************************
*
*  

Local cAliasQry := GetNextAlias()  
Local lUmaVez   := .T.

aListBox1 := {}
Aadd(aListBox1,{.F.,"","",""})

BeginSql Alias cAliasQry    
	SELECT M0_CODIGO, M0_CODFIL, M0_FILIAL
	FROM SIGAMAT                                                 
	WHERE %notDel%
	ORDER BY M0_CODIGO, M0_CODFIL 	            
EndSql    
  	
(cAliasQry)->( DbGoTop() )
 	
While !(cAliasQry)->(EOF())  
	
	if lUmaVez
		aListBox1[1,1] := .F.
		aListBox1[1,2] := (cAliasQry)->M0_CODIGO
		aListBox1[1,3] := (cAliasQry)->M0_CODFIL
		aListBox1[1,4] := (cAliasQry)->M0_FILIAL
		lUmaVez := .F.
	else
		aadd(aListBox1,{.F.,(cAliasQry)->M0_CODIGO,(cAliasQry)->M0_CODFIL,(cAliasQry)->M0_FILIAL})
	endif
	(cAliasQry)->( dbSkip() )  

enddo    

(cAliasQry)->(dbCloseArea()) 

oListBox1:SetArray( aListBox1 )

oListBox1:bLine := {|| { If(aListBox1[oListBox1:nAT,1],oOk,oNo),;
						 aListBox1[oListBox1:nAT,02],;
						 aListBox1[oListBox1:nAT,03],;
						 aListBox1[oListBox1:nAT,04]}}

oListBox1:Refresh()

return 

******************************************
Static Function C(nTam)                   
******************************************
*
*                                      
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam) 

******************************************
Static Function fConfFr()                  
******************************************
*
*

Local cNumero   := ""
Local cFilAux   := cFilAnt
Local cProduto  := Alltrim(GetNewPar("MV_ZPROFRE","53010009"))
Local cZZCodUsr := ""
Local cQuery    := ""

cZZCodUsr := RetCodUsr()  

For k := 1 To Len(aListBox1)

	if aListBox1[k,1]                       
	
		if Alltrim(aListBox1[k,2]) == "02"
	
			cFilAnt  := Alltrim(aListBox1[k,3])
			cNumero  := GetSx8Num("SC1")
			ConfirmSX8()
			
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+cProduto)			
	
			if RecLock("SC1",.T.)
				Replace SC1->C1_FILIAL  With xFilial("SC1")
				Replace SC1->C1_NUM     With cNumero
				Replace SC1->C1_ITEM    With "0001"
				Replace SC1->C1_PRODUTO With cProduto
				Replace SC1->C1_DESCRI  With SB1->B1_DESC
				Replace SC1->C1_UM      With SB1->B1_UM
				Replace SC1->C1_LOCAL   With SB1->B1_LOCPAD
				Replace SC1->C1_QUANT   With 1
				Replace SC1->C1_DATPRF  With dDataBase
				Replace SC1->C1_EMISSAO With dDataBase
				Replace SC1->C1_SOLICIT With SubStr(cUsuario,7,15)
				Replace SC1->C1_USER    With cZZCodUsr
				Replace SC1->C1_FILENT  With Alltrim(aListBox1[k,3])
				Replace SC1->C1_QTDORIG With 1
				Replace SC1->C1_ZFILFAT With Alltrim(aListBox1[k,3])
				Replace SC1->C1_ZCLASSI With "1"
				Replace SC1->C1_ZSTATUS With "1"
				Replace SC1->C1_ZEMP    With "02"
				Replace SC1->C1_APROV   With "L"
				MsUnLock()
			endif  
			
			ApMsgInfo("Solicitação de compras " + cNumero + " gerada com sucesso !!!")   
			
		elseif Alltrim(aListBox1[k,2]) == "01" 
		
			cQuery := "SELECT MAX(C1_NUM) AS NUMSC1"
			cQuery += " FROM SC1010 SC1 "
			cQuery += " WHERE C1_FILIAL = '" + Alltrim(aListBox1[k,3]) + "'"
			
			cQuery := ChangeQuery(cQuery)
			
			//memowrite("c:\cquery.sql",cquery)   	
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBMAX",.T.,.T.) 
			
			dbSelectArea("TRBMAX")
			dbGoTop()
			
			if !Eof("TRBMAX")
				cNumero := StrZero(Val(TRBMAX->NUMSC1)+1,6)
			else           	
				cNumero := "000001"
			endif

			dbSelectArea("TRBMAX")
			dbCloseArea("TRBMAX")			
		
	 		cQuery:="INSERT INTO SC1"+aListBox1[k,2]+"0"     
			cQuery+=" (C1_FILIAL,C1_NUM,C1_ITEM,C1_PRODUTO,C1_DESCRI,C1_UM,"
			cQuery+=" C1_LOCAL,C1_QUANT,C1_DATPRF,C1_EMISSAO,C1_SOLICIT,C1_USER,C1_FILENT,C1_QTDORIG,"
			cQuery+=" C1_ZFILFAT,C1_ZCLASSI,C1_ZSTATUS,C1_ZEMP,R_E_C_N_O_,C1_APROV)"
			cQuery+=" values ( "    

			cQuery+=+"'"+Alltrim(aListBox1[k,3])+"','"+cNumero+"','"+"0001"+"','"+cProduto+"','"+Alltrim(SB1->B1_DESC)+"','"+SB1->B1_UM+"','"+SB1->B1_LOCPAD+"','"
			cQuery+=Alltrim(Str(1))+"','"+dTos(dDataBase)+"','"+dTos(dDataBase)+"','"+Alltrim(SubStr(cUsuario,7,15))+"','"+cZZCodUsr+"','"+Alltrim(aListBox1[k,3])+"','"
			cQuery+=Alltrim(Str(1))+"','"+Alltrim(aListBox1[k,3])+"','1','1','02',"
			cQuery+="(SELECT isNull(max(R_E_C_N_O_),0) + 1,'L' " 
			cQuery+=" FROM SC1"+aListBox1[k,2]+"0"+"))"

			TCREFRESH("SC1"+aListBox1[k,2]+"0")

//			memowrite("C:cquerySC1.sql",cQuery)

			nRet := TCSQLExec(cQuery) 
			
			ApMsgInfo("Solicitação de compras " + cNumero + " gerada com sucesso !!!")			
					
		endif       
		
		//Envia e-mail para o solicitante  
		//EnviarMail(cNumero,cPedido,cCotacao)		
	
	endif

Next

cFilAnt := cFilAux

oDlgFre:End()

return                                                                 