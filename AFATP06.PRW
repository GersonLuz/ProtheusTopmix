#Include "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} AFATP06
Description Registra ocorrencias para o processo                                                    
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Jose Antonio (AMM)                                             
@since 17/12/2012    paWBrowAux3[oWBrowse2:nAt,2]                                               
/*/                                                             
//--------------------------------------------------------------
User Function AFATP06(paWBrowAux3)                        
Local oBitmap1
Local oBitmap2
Local oFont1 := TFont():New("Calibri",,022,,.T.,,,,,.F.,.F.)
Local oFont2 := TFont():New("Calibri",,020,,.T.,,,,,.F.,.F.)
Local oFont3 := TFont():New("Calibri",,018,,.T.,,,,,.F.,.F.)
Local oFont4 := TFont():New("Calibri",,018,,.F.,,,,,.F.,.F.)
Local oCodOcor
Local cCodOcor := Criavar("Z3_CODIGO")
Local oGet2
Local cGet2 := Space(30)
Local oMotivo
Local cMotivo := Criavar("Z2_MOTIVO")
Local oMail
Local cMail := Criavar("Z2_EMAIL1")
Local oGroup1
Local oGroup2
Local oGroup3
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSButton0
Local oSButton1
Local oSButton2
Private cZCota  := iif(Alltrim(FunName())=="AFATP00",SC1->C1_COTACAO,paWBrowAux3[oWBrowse2:nAt,2])
Static oDlg       

//IF len(paWBrowAux3)==0
//	MsgAlert("Não exite registro","Atenção")  
//	Return
//Endif

  DEFINE MSDIALOG oDlg TITLE "Registro de Ocorrencias" FROM 000, 000  TO 440, 600 COLORS 0, 16777215 PIXEL

    @ 002, 050 SAY oSay1 PROMPT "REGISTRO DE OCORRENCIAS" SIZE 122, 011 OF oDlg FONT oFont1 COLORS 32768, 16777215 PIXEL
    @ 000, 165 BITMAP oBitmap1 SIZE 041, 015 OF oDlg FILENAME "\Imagens\Flapa_Totvs.png" NOBORDER PIXEL
    @ 000, 207 BITMAP oBitmap2 SIZE 041, 015 OF oDlg FILENAME "\Imagens\TopMix_Totvs.png" NOBORDER PIXEL
    @ 016, 002 GROUP oGroup1 TO 203, 298 OF oDlg COLOR 0, 16777215 PIXEL
    @ 021, 005 SAY oSay2 PROMPT "Informe Dados da Ocorrência" SIZE 111, 009 OF oDlg FONT oFont2 COLORS 128, 16777215 PIXEL
    @ 030, 005 GROUP oGroup2 TO 084, 295 OF oDlg COLOR 0, 16777215 PIXEL
    @ 040, 007 SAY oSay3 PROMPT "Código" SIZE 025, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
    @ 040, 067 SAY oSay4 PROMPT "Descrição" SIZE 031, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
    @ 055, 007 SAY oSay5 PROMPT "Motivo" SIZE 025, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
    @ 070, 007 SAY oSay6 PROMPT "E-Mail Adicional" SIZE 050, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
    @ 037, 029 MSGET oCodOcor VAR cCodOcor SIZE 029, 011 OF oDlg COLORS 0, 16777215 FONT oFont4   F3 "SZ3" PIXEL VALID !Empty(cCodOcor) .And. ExistCpo("SZ3",cCodOcor) 
    @ 037, 097 MSGET oGet2 VAR cGet2 SIZE 144, 011 OF oDlg COLORS 0, 16777215 FONT oFont4 PIXEL WHEN .F.
    @ 052, 029 MSGET oMotivo VAR cMotivo SIZE 212, 011 OF oDlg COLORS 0, 16777215 FONT oFont4 PIXEL
    @ 067, 055 MSGET oMail VAR cMail SIZE 185, 011 OF oDlg COLORS 0, 16777215 FONT oFont4 PIXEL
    @ 089, 005 SAY oSay7 PROMPT "Selecione as Cotações da Ocorrência" SIZE 148, 008 OF oDlg FONT oFont2 COLORS 128, 16777215 PIXEL
    @ 098, 005 GROUP oGroup3 TO 197, 295 OF oDlg COLOR 0, 16777215 PIXEL
    oWBrowAux3:=fWBrowse1(paWBrowAux3)    
    DEFINE SBUTTON oSButton1 FROM 205, 190 TYPE 01 ACTION (fConfirma(oWBrowAux3,cCodOcor,cMotivo,cMail),oDlg:End()) OF oDlg ENABLE
    DEFINE SBUTTON oSButton2 FROM 205, 219 TYPE 02  ACTION oDlg:End() OF oDlg ENABLE

  ACTIVATE MSDIALOG oDlg CENTERED

Return  
/*
Confirma gravaçao
*/

Static Function fConfirma(poWBrowAux3,pCodOcor,pMotivo,pMail,pop)

MsAguarde( {|lEnd|FGravaSC8(poWBrowAux3,pCodOcor,pMotivo,pMail)},"Aguarde","Gravando Registros...",.T.)

oDlg:End()
Return 

//------------------------------------------------ 
Static Function fWBrowse1(poWBrowse)
//------------------------------------------------   
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")
Local oWBrowse1
Local aWBrowse1 := {}
Local aAUx		:= {}    

    // Insert items here 
 	IF Alltrim(FunName())=="AFATP00"       
	     cNumCot:=SC1->C1_COTACAO
	     aAUx:=fSelecao2()   
	Else   
	    aAUx:=fSelecao1()    
	Endif
	  
    If Len(aAUx)=0 
		Aadd(aWBrowse1,{.F.,"","","","",""})
    ElSe
		aWBrowse1:=Aclone(aAUx)
    Endif 

  //  Aadd(aWBrowse1,{.F.,"Filial","Numero da Cotação","Numero da Solicitacao","Data Inclusão","Solicitante"})
 
    @ 102, 007 LISTBOX oWBrowse1 Fields HEADER "","Empresa","Filial","Numero Cotação","Numero Solicitação","Solicitante" SIZE 285, 091 OF oDlg PIXEL ColSizes 50,50
    oWBrowse1:SetArray(aWBrowse1)
    oWBrowse1:bLine := {|| {;
      If(aWBrowse1[oWBrowse1:nAT,1],oOk,oNo),;
      aWBrowse1[oWBrowse1:nAt,2],;
      aWBrowse1[oWBrowse1:nAt,3],;
      aWBrowse1[oWBrowse1:nAt,4],;
      aWBrowse1[oWBrowse1:nAt,5],;
      aWBrowse1[oWBrowse1:nAt,6];
    }}
    // DoubleClick event
    oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],;
      oWBrowse1:DrawSelect()}

Return(oWBrowse1)    
//------------------------------------------------ 
Static Function fSelecao1()
//------------------------------------------------ 

Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()                                                                                
Local cCodUser  := RetCodUsr() 
Local aWBrowse1 := {}    
Local aWBrowAux := {} 
Local cSql      :=""  
Local cEmpresa  :=""      
Local aEmpresa  :=u_fSIGAMAT()
Local nRegSM0   :=0 
Local cEmpAux   :=""
Local cFromSC1  := "%"+"SC1"+cEmpAux+"%"

 
 	BeginSql Alias cAliasQry  
   		SELECT DISTINCT C8_NUM 
 		FROM %table:SC8% SC8                                                 
		WHERE SC8.%notDel% 	AND    
		//SC8.C8_ZUSER = %Exp:cCodUser% AND      
		SC8.C8_NUM = %Exp:cZCota% //AND SC8.C8_ZSTATUS IN (%Exp:'3'%) 
		GROUP BY C8_NUM
  	EndSql   
	(cAliasQry)->( DbGoTop() )
 	While !(cAliasQry)->(EOF())  
 	       Aadd(aWBrowse1,{(cAliasQry)->C8_NUM	})
	       (cAliasQry)->(dbskip())  
	EndDo
	(cAliasQry)->(dbCloseArea()) 
	
For xE:=1 to Len(aEmpresa)   // Inicio de empresa
 	
 	cEmpAux  := aEmpresa[xE,1]+"0"
	cFromSC1 := "%"+"SC1"+cEmpAux+"%"
   
    For xC:=1 to Len(aWBrowse1)   // Inicio da cotacao
        
   		cCotacao:=aWBrowse1[xC,1]

		cAliasQry := GetNextAlias()  

		BeginSql Alias cAliasQry
	 		SELECT DISTINCT C1_ZEMP,C1_FILIAL,C1_NUM,C1_COTACAO,C1_SOLICIT,C1_DESCRI,C1_USER,C1_PRODUTO, C1_ITEM
			FROM %Exp:cFromSC1% SC1  
			WHERE SC1.%notDel% 	AND    
  			SC1.C1_COTACAO = %Exp:cCotacao% 
	      	ORDER BY C1_ZEMP,C1_FILIAL,C1_NUM,C1_ITEM,C1_COTACAO,C1_SOLICIT,C1_DESCRI,C1_USER,C1_PRODUTO   
	  	EndSql   
	 	(cAliasQry)->( DbGoTop() )
	 	While !(cAliasQry)->(EOF())  
	       Aadd(aWBrowAux,{.F.,;          				  // Marca    	1    
   	        	(cAliasQry)->C1_ZEMP,;  			      // Empresa   	2
	        	(cAliasQry)->C1_FILIAL,;  				  // Filial   	3
	        	(cAliasQry)->C1_COTACAO,; 				  // Cotacao  	4
	        	(cAliasQry)->C1_NUM+"/"+(cAliasQry)->C1_ITEM,;// Numero SC  	5  
	        	(cAliasQry)->C1_SOLICIT,;  				  // Nome do solicitante 	6
	        	(cAliasQry)->C1_PRODUTO,;  				  // Codigo do Produto    7
	        	(cAliasQry)->C1_DESCRI,;  				  // Descricao do Produto 8
	        	(cAliasQry)->C1_USER;  	     			  // Codigo do usuario 	9
	        	 })
	        (cAliasQry)->(dbskip())  
		EndDo
 		(cAliasQry)->(dbCloseArea())
	Next  // Fim cotacao e solicitacao
	
Next  // Fim de emprea

RestArea(aAliasOLD)
Return(aWBrowAux)  

//------------------------------------------------ 
Static Function fSelecao2()
//------------------------------------------------ 

Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()                                                                                
Local cCodUser  := RetCodUsr() 
Local aWBrowse1 := {}    
Local aWBrowAux := {} 
Local cSql      :=""  
Local cEmpresa  :=""      
Local aEmpresa  :=u_fSIGAMAT()
Local nRegSM0   :=0 
Local cEmpAux   :=""
Local cFromSC1  := "%"+"SC1"+cEmpAux+"%"

 	BeginSql Alias cAliasQry  
   		SELECT DISTINCT C8_NUM 
 		FROM %table:SC8% SC8                                                 
		WHERE SC8.%notDel% 	AND    
		SC8.C8_NUM = %Exp:cNumCot% 
		GROUP BY C8_NUM
  	EndSql   
	(cAliasQry)->( DbGoTop() )
 	While !(cAliasQry)->(EOF())  
 	       Aadd(aWBrowse1,{(cAliasQry)->C8_NUM	})
	       (cAliasQry)->(dbskip())  
	EndDo
	(cAliasQry)->(dbCloseArea()) 
	
For xE:=1 to Len(aEmpresa)   // Inicio de empresa
 	
 	cEmpAux  := aEmpresa[xE,1]+"0"
	cFromSC1 := "%"+"SC1"+cEmpAux+"%"
   
    For xC:=1 to Len(aWBrowse1)   // Inicio da cotacao
        
   		cCotacao:=aWBrowse1[xC,1]

		cAliasQry := GetNextAlias()  

		BeginSql Alias cAliasQry
	 		SELECT DISTINCT C1_ZEMP,C1_FILIAL,C1_NUM,C1_COTACAO,C1_SOLICIT,C1_DESCRI,C1_USER,C1_PRODUTO, C1_ITEM
			FROM %Exp:cFromSC1% SC1  
			WHERE SC1.%notDel% 	AND    
  			SC1.C1_COTACAO = %Exp:cCotacao% 
	      	ORDER BY C1_ZEMP,C1_FILIAL,C1_NUM,C1_ITEM,C1_COTACAO,C1_SOLICIT,C1_DESCRI,C1_USER,C1_PRODUTO   
	  	EndSql   
	 	(cAliasQry)->( DbGoTop() )
	 	While !(cAliasQry)->(EOF())  
	       Aadd(aWBrowAux,{.F.,;          				// Marca    	1    
   	        	(cAliasQry)->C1_ZEMP,;  			    // Empresa   	2
	        	(cAliasQry)->C1_FILIAL,;  				// Filial   	3
	        	(cAliasQry)->C1_COTACAO,; 				// Cotacao  	4
	        	(cAliasQry)->C1_NUM+"/"+(cAliasQry)->C1_ITEM,;     				// Numero SC  	5  
	        	(cAliasQry)->C1_SOLICIT,;  				// Nome do solicitante 	6
	        	(cAliasQry)->C1_PRODUTO,;  				// Codigo do Produto    7
	        	(cAliasQry)->C1_DESCRI,;  				// Descricao do Produto 8
	        	(cAliasQry)->C1_USER;  	     			// Codigo do usuario 	9
	        	 })
	        (cAliasQry)->(dbskip())  
		EndDo
 		(cAliasQry)->(dbCloseArea())
	Next  // Fim cotacao e solicitacao
	
Next  // Fim de emprea

RestArea(aAliasOLD)
Return(aWBrowAux)  

//------------------------------------------------ 
//* Grava na tabela SZ4 Ocorrencias de contacao   
//------------------------------------------------ 
Static Function FGravaSC8(poWBrowAux3,pCodOcor,pMotivo,pMail)
Local x1:=0
Local aWBrowGru := {}  
Local aAuxGru   := {}    
Local lRet	 	:=.F.
Local nConReg   := 0  
Local cUsrOcor  :=UsrRetName(RetCodUsr())
Local cCodOcor  :=RetCodUsr()
Local aReg	    :={}   
Local cNumOcore :=0
Local cBloqueio :=Posicione("SZ3",1,xFilial("SZ3")+pCodOcor,'Z3_STATUS')
Local cStatus   :=IIF(FunName()="AFATP00","3","4")  
Local cFilCot   := ""

cBloqueio :=IIF(ALltrim(FunName())=="AFATP00","S",cBloqueio)

 	Begin Transaction   
		For nX := 1 To Len(poWBrowAux3:aArray)
			If poWBrowAux3:aArray[nX,1]
			    cFilCot := poWBrowAux3:aArray[nX,3]
			    cNumCot := poWBrowAux3:aArray[nX,4]
			    cEmp:=poWBrowAux3:aArray[nX,2]
			    IF cBloqueio =="S"     
 					If TCCanOpen(RetSqlName("SC1"))			
						_Retorno :=TCSQLExec("UPDATE SC1"+ cEmp +"0 SET C1_ZSTATUS = '"+cStatus+"' WHERE C1_COTACAO='" + cNumCot+ "' AND C1_FILIAL = '"+cFilCot+"'")  
					Endif 
					If _Retorno < 0 
						_GetErroTop := TCSQLError()							
						MsgStop("Error ocorreram na execucao da Query na tabela SC1. Veja detalhes "+_GetErroTop,"Erro","Alert")
					Endif

				   	If TCCanOpen(RetSqlName("SC8"))			
						_Retorno :=TCSQLExec("UPDATE "+ RetSqlName("SC8") + " SET C8_ZSTATUS = '"+cStatus+"' WHERE C8_NUM='" + cNumCot+ "'")                      
					Endif     
					If _Retorno < 0 
						_GetErroTop := TCSQLError()							
						MsgStop("Error ocorreram na execucao da Query na tabela SC8. Veja detalhes "+_GetErroTop,"Erro","Alert")
					Endif
				Endif	    
					
				dbSelectArea("SZ2") 
				cNumOcore := GetSxENum("SZ2","Z2_NUMERO") 
				ConfirmSX8()
	 			If RecLock("SZ2", .T.)
	 			    SZ2->Z2_FILIAL   := xFilial("SZ2")
	   			    SZ2->Z2_NUMERO   := cNumOcore
				    SZ2->Z2_CODIGO   := pCodOcor 
				   	SZ2->Z2_NUMSC    := SubStr(poWBrowAux3:aArray[nX,5],1,6)
				   	SZ2->Z2_NUMCOT   := poWBrowAux3:aArray[nX,4]
			        SZ2->Z2_EMP       :=poWBrowAux3:aArray[nX,2]
				   	SZ2->Z2_ITEMSC   := SubStr(poWBrowAux3:aArray[nX,5],8,4)
				   	SZ2->Z2_CODUSR   := cCodOcor
				   	SZ2->Z2_NOMEUSR  := cUsrOcor
				  	SZ2->Z2_MOTIVO   := pMotivo   
				   	SZ2->Z2_DATA     := DATE()
				   	SZ2->Z2_HORA     := TIME()
				   	SZ2->Z2_EMAIL1   := pMail
				   	SZ2->Z2_EMAIL2   :=""
				   	SZ2->Z2_EMAIL3   :=""
				   	SZ2->Z2_EMAIL4   :=""
				   	SZ2->Z2_EMAIL5   :=""
					MsUnLock()  
				Endif	 
			Endif	 
		Next
	End Transaction 
	For nX := 1 To Len(poWBrowAux3:aArray)
		If poWBrowAux3:aArray[nX,1]
	  		u_AFATR04({poWBrowAux3:aArray[nX,4],poWBrowAux3:aArray[nX,5],poWBrowAux3:aArray[nX,6],poWBrowAux3:aArray[nX,7],poWBrowAux3:aArray[nX,8],poWBrowAux3:aArray[nX,9],pMotivo,pMail})
	        //alert("Envio de e-mail, não valido")
	    endif
    Next
Return(lRet)  
                         

