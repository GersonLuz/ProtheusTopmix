#include "protheus.ch"
#Define cEol Chr(13)+Chr(10)

Static aDadOld	:= {} // Variavel utilizada para guardar os valores da tabela


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSLIB001
Função criada para efeitos de compatibilidade evitando que seja criada uma função com o 
nome deste prw.
         
@author 	Luciano M. Pinto
@since 		23/08/2011
@version 	P11

/*/ 
//---------------------------------------------------------------------------------------
User Function FSLIB001()
/****************************************************************************************
* Função criada para efeitos de compatibilidade evitando que seja criada uma função com o 
* nome deste prw.
*
***/
Return Nil   


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSGetVal
Obtem os valores do SA1 antes da alteração	
         
@author 	Luciano M. Pinto
@since 		23/08/2011
@version 	P11
@param		aDadSa1 Array com os dados da tabela SA1 antes da gravação

/*/ 
//---------------------------------------------------------------------------------------
User Function FSGetVal(aDadRet)  
/****************************************************************************************
* 
*
*
***/
Default aDadRet := {}

aDadOld := aClone(aDadRet) 

Return Nil


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FGetIden
Chamada inicial da Função que retorna a identificação do Registro

@protected         
@author 		Luciano M. Pinto
@since 		23/08/2011
@version 	P11
@return?		cRetFun	Identificacao do Registro

/*/ 
//---------------------------------------------------------------------------------------
Static Function FGetIden()  
/****************************************************************************************
*
*
*
***/    
Local cRetFun	:= ""
/*
Local dDataAt	:= Date()
Local cHoraAt	:= StrTran(Time(),":","")
Local cTipo		:= ""
*/                    

If INCLUI 

	cRetFun := "I"

ElseIf ALTERA

	cRetFun := "A"

Else

	cRetFun := "E"

End If


//***************************************************************************************
// Monta o retorno da Função		  
//***************************************************************************************
//cRetFun := cTipo
/*
cRetFun += StrZero(Day(dDataAt),2)+StrZero(Month(dDataAt),2)+Right(Str(Year(dDataAt)),4)
cRetFun += SubStr(cHoraAt,1,6)
*/
Return (cRetFun)  



//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSPutTab
Chamada inicial da Função qua atualiza o registro posicionado
      
@author 		Luciano M. Pinto
@since 		23/08/2011
@version 	P11
@param	cAlias	Alias da tabela a ser processada
@param	cTipo		Tipo de processamento A:Alteração, E: Exclusão e I:Inclusão
@param	lRegDel	Verifica se o registro está excluido da base
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
08/11/2011 	Claudio Silva		Alteracao da funcao de static FPutTab para User Function FSPutTab
17/11/2011 	Fernando Ferreira Foi incluido os dados da integração de Fornecedore e Vendedores
23/02/2012	Fernando Ferreira Foi Retirado as informações da tabela SD3
/*/ 
//---------------------------------------------------------------------------------------
User Function FSPutTab(cAlias,cTipo,lRegDel,lPrim,lAtPosCli)

Local aCpoTab 		:= {} 
Local aCpoWhe 		:= {} 
Local cTabKp 		:= ""
Local lRet			:= .T.          
Local cNomCmpFlg	:= ""
Local lExcBetPrd  := SuperGetMv("ES_EXBTPRD",,.F.)

Default cAlias		:= ""
Default cTipo		:= ""
Default lRegDel 	:= .F.   
Default lPrim		:= .T.
Default lAtPosCli := .F.
//***************************************************************************************
// Gravação do campo Identidade
//***************************************************************************************

Do Case
	
	Case cAlias == "SA1"
	
		Reclock("SA1",.F.)
		SA1->A1_ZIDENT := cTipo//FGetIden()	//Obtem o Identificador do Registro 
		cNomCmpFlg := "A1_ZFLAG"

		// Retorna os campos
		aCpoTab 	:= U_FSGetCmp("SA1")
		aAdd(aCpoTab , {"DATAINTERFACE", "NULL", "INT"})
		cTabKp 	:= "CLIENTES"  			
      
		// Campos do Where
		aAdd(aCpoWhe,{"FILIAL"			,SA1->A1_FILIAL," = "}) 
		aAdd(aCpoWhe,{"CODIGOCLIENTE"	,SA1->A1_COD	," = "})
		aAdd(aCpoWhe,{"LOJA"				,SA1->A1_LOJA	," = "})
		
		If cTipo == "E" 
			aCpoTab:= {}
			aAdd(aCpoTab,{"DATAINTERFACE"	, "NULL"}) 
			aAdd(aCpoTab,{"IDENTIFICA"		, "E"})		
		End IF
	
	// Tabela de Endereços.		
	Case cAlias == "P01"		
		cNomCmpFlg := "P01_ZFLAG"  
		
		// Retorna os campos
		aCpoTab 	:= U_FSGetCmp("P01")
		aAdd(aCpoTab , {"IDENTIFICA"	 , cTipo		, "INT"})
		aAdd(aCpoTab , {"DATAINTERFACE", "NULL"	, "INT"})
		cTabKp 	:= "SZ1"
		
		// Campos do Where  
		aAdd(aCpoWhe,{"Z1_FILIAL"	,P01->P01_FILIAL	," = "}) 
		aAdd(aCpoWhe,{"Z1_COD"		,P01->P01_COD		," = "})
		aAdd(aCpoWhe,{"Z1_LOJA"		,P01->P01_LOJA		," = "})
		aAdd(aCpoWhe,{"Z1_ITEM"		,P01->P01_ITEM		," = "})
		
		If cTipo == "E"
	  		aCpoTab:= {} 
			aAdd(aCpoTab , {"IDENTIFICA", cTipo, "INT"})				  		
			aAdd(aCpoTab , {"DATAINTERFACE", "NULL", "INT"})
		End If		
		
	Case cAlias == "DA3"
		cNomCmpFlg := "DA3_ZFLAG"
		Reclock("DA3",.F.)
		DA3->DA3_ZIDENT := cTipo//FGetIden()	//Obtem o Identificador do Registro		
		MsUnlock()

		// Retorna os campos	   
		aCpoTab 	:= U_FSGetCmp("DA3") 
		aAdd(aCpoTab , {"DATAINTERFACE", "NULL"	, "INT"})
		cTabKp	:= "VEICULOS"	//GetMv(FS_TABVEI)	

		// Campos do Where	
		aAdd(aCpoWhe,{"CODIGOCENTRAL"	,DA3->DA3_FILIAL," = "}) 
		aAdd(aCpoWhe,{"CODIGOVEICULO"	,DA3->DA3_COD	 ," = "})
	
	   If cTipo == "E"
	  		aCpoTab:= {}
			aAdd(aCpoTab,{"DATAINTERFACE"	, "NULL"}) 
			aAdd(aCpoTab,{"IDENTIFICA"		, "E"})		
		End If
	
	Case cAlias == "DA4"
		cNomCmpFlg := "DA4_ZFLAG"

		// Retorna os campos
		aCpoTab 	:= U_FSGetCmp("DA4") 	
		aAdd(aCpoTab,{"IDENTIFICA", cTipo, "(cAlias)->IDENTIFICA"})
		aAdd(aCpoTab , {"DATAINTERFACE", "NULL"	, "INT"})
		cTabKp 	:= "MOTORISTAS"  			//GetMv(FS_TABMOT) 
	
		// Campos do Where
		aAdd(aCpoWhe,{"CODIGOCENTRAL"		,DA4->DA4_FILIAL	," = "}) 
		aAdd(aCpoWhe,{"CODIGOMOTORISTA"	,DA4->DA4_COD		," = "})
	      
	   If cTipo == "E"
	  		aCpoTab:= {}
			aAdd(aCpoTab,{"IDENTIFICA", cTipo, "(cAlias)->IDENTIFICA"})
			aAdd(aCpoTab,{"DATAINTERFACE"	, "NULL"}) 
		End If

	Case cAlias == "SF4"      
		cNomCmpFlg := "F4_ZFLAG"
		// Retorna os campos
		aCpoTab 	:= U_FSGetCmp("SF4")
		aAdd(aCpoTab,{"IDENTIFICA"		, cTipo})
		aAdd(aCpoTab , {"DATAINTERFACE", "NULL"	, "INT"})
		cTabKp 	:= "SF4"
	
		// Campos do Where
		aAdd(aCpoWhe,{"F4_FILIAL"	,SF4->F4_FILIAL	," = "}) 
		aAdd(aCpoWhe,{"F4_CODIGO"	,SF4->F4_CODIGO	," = "})
	      
	   If cTipo == "E"
	  		aCpoTab:= {}
			aAdd(aCpoTab,{"IDENTIFICA"		, cTipo})
			aAdd(aCpoTab,{"DATAINTERFACE"	, "NULL"}) 
		End If

	Case cAlias == "CTT"
		cNomCmpFlg := "CTT_ZFLAG"
		// Retorna os campos
		aCpoTab 	:= U_FSGetCmp("CTT")
		aAdd(aCpoTab,{"IDENTIFICA"		, cTipo})
		aAdd(aCpoTab,{"DATAINTERFACE"	, "NULL"}) 		
		cTabKp 	:= "CTT"
	
		// Campos do Where
		aAdd(aCpoWhe,{"CTT_FILIAL"	,CTT->CTT_FILIAL	," = "}) 
		aAdd(aCpoWhe,{"CTT_CUSTO"	,CTT->CTT_CUSTO	," = "})
	      
	   If cTipo == "E"
	  		aCpoTab:= {}
			aAdd(aCpoTab,{"IDENTIFICA"		, cTipo})	  		
			aAdd(aCpoTab,{"DATAINTERFACE"	, "NULL"}) 
		End If

	Case cAlias == "SB1"    
		cNomCmpFlg := "B1_ZFLAG"
		// Retorna os campos
		aCpoTab 	:= U_FSGetCmp("SB1")
		aAdd(aCpoTab , {"IDENTIFICA", cTipo, "INT"})
		aAdd(aCpoTab , {"DATAINTERFACE", "NULL"	, "INT"})
		cTabKp 	:= "SB1"  		
		
		// Campos do Where
		aAdd(aCpoWhe,{"B1_FILIAL"		,SB1->B1_FILIAL	," = "}) 
		aAdd(aCpoWhe,{"B1_COD"			,SB1->B1_COD		," = "})
		
		If cTipo == "E"
	  		aCpoTab:= {} 
			aAdd(aCpoTab , {"IDENTIFICA", cTipo, "INT"})				  		
			aAdd(aCpoTab , {"DATAINTERFACE", "NULL"	, "INT"})
		End If

	Case cAlias == "SA2"
		cNomCmpFlg := "A2_ZFLAG"
		// Retorna Campos
		aCpoTab 	:= U_FSGetCmp("SA2")
		aAdd(aCpoTab , {"IDENTIFICA"	 , cTipo		, "INT"})
		aAdd(aCpoTab , {"DATAINTERFACE", "NULL"	, "INT"})
		cTabKp 	:= "FORNECEDOR"  		
		
		// Campos do Where
		aAdd(aCpoWhe,{"CENTRAL"						,SA2->A2_FILIAL	," = "}) 
		aAdd(aCpoWhe,{"CODIGOFORNECEDOR"			,SA2->A2_COD 		," = "})
		aAdd(aCpoWhe,{"LOJA"							,SA2->A2_LOJA 		," = "})	
		
		If cTipo == "E"
	  		aCpoTab:= {} 
			aAdd(aCpoTab , {"IDENTIFICA"	 , cTipo		, "INT"})
			aAdd(aCpoTab , {"DATAINTERFACE", "NULL"	, "INT"})
		End If
		
	Case cAlias == "SA3"
		cNomCmpFlg := "A3_ZFLAG"
		// Retorna Campos
		aCpoTab 	:= U_FSGetCmp("SA3")
		aAdd(aCpoTab , {"IDENTIFICA"	 , cTipo		, "INT"})
		aAdd(aCpoTab , {"DATAINTERFACE", "NULL"	, "INT"})
		cTabKp 	:= "VENDEDOR"
		
		// Campos do Where
		aAdd(aCpoWhe,{"CENTRAL"						,SA3->A3_FILIAL	," = "}) 
		aAdd(aCpoWhe,{"CODIGOVENDEDOR"			,SA3->A3_COD 		," = "})
		
		If cTipo == "E"
	  		aCpoTab:= {} 
			aAdd(aCpoTab , {"IDENTIFICA"	 , cTipo		, "INT"})
			aAdd(aCpoTab , {"DATAINTERFACE", "NULL"	, "INT"})
		End If		

	Case cAlias == "POSCLI"
		// Retorna os campos
		aCpoTab 	:= U_FSGetCmp(cAlias)
		cTabKp 	:= "TITULO"

		//aAdd(aCpoTab,{"DATAINTERFACE"	, U_FSDtaExc()}) 

	Case cAlias == "CUSMED"
		// Retorna os campos
		aCpoTab 	:= U_FSGetCmp(cAlias)
		cTabKp 	:= "CUSTOMEDIO"

		aAdd(aCpoTab,{"DATA"				, dDatabase}) 
		//aAdd(aCpoTab,{"DATAINTERFACE"	, U_FSDtaExc()})  
	
	Case cAlias == "TRBSD1"
		// Retorna Campos
		aCpoTab 	:= U_FSGetCmp("TRBSD1")
		cTabKp 	:= "COTACAOMCC"  		
	
End Case  
       
If (lPrim .Or. lAtPosCli) .And. cAlias == "POSCLI"

	Conout("INICIO - Executando exclusao de dados da tabela de integracao TITULO - FSPutTab "+IIf(lAtPosCli,"-PARCIAL"+(cAlias)->E1_CLIENTE,"-FULL"))
	cQryPrcN := "DELETE FROM TITULO " 
	If lAtPosCli // Apenas atualizacao.
	   cQryPrcN += " WHERE CODIGOCLIENTE = '" + (cAlias)->E1_CLIENTE + "' AND LOJACLIENTE = '"+(cAlias)->E1_LOJA+"'"
	Endif   
	lRet  := FExecQry(cQryPrcN,"",1)
	lPrim := .F.	                    
		
	If lRet
		Conout("*** Exclusao de dados da tabela de integracao TITULO efetuada com sucesso ***")   
	Else
		Conout("*** Nao foi possivel excluir de dados da tabela de integracao TITULO ***")		
	EndIf

	If lAtPosCli .And. lExcBetPrd
      cQryPrcN := "DELETE [192.168.0.19].[betonMIXProducao].DBO.TITULO WHERE CLIENTEID IN "
      cQryPrcN += "(SELECT CLIENTEID FROM [192.168.0.19].[betonMIXProducao].DBO.CLIENTE WHERE CODIGO LIKE '"+(cAlias)->E1_CLIENTE+"-"+(cAlias)->E1_LOJA+"%')
      nRet  :=	TCSQLExec(cQryPrcN)
	   If nRet == 0
		   Conout("*** Exclusao de dados da tabela [betonMIXProducao].DBO.TITULO ["+(cAlias)->E1_CLIENTE+"-"+(cAlias)->E1_LOJA+"] efetuada com sucesso ***")   
      Else
		   Conout("*** Nao foi possivel excluir de dados da tabela [betonMIXProducao].DBO.TITULO ***")		
      EndIf
   Endif
   
EndIf

Conout("INICIO - Atualizando interface")		
lRet:= FPrcIntTbl(aCpoTab,cTabKp, aCpoWhe,lRegDel, cTipo , @lAtPosCli )                         
Conout("FIM - Atualizando interface")		
			
If !Empty(cNomCmpFlg) 
	RecLock(cAlias,.F.)
	&(cAlias+"->"+cNomCmpFlg) := Iif(lRet,"*","")
	MsUnlock()                  
EndIf		

Return(lRet)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FPrcIntTbl
Processa as atualizações das integrações KP
        
@protected
@author Fernando Ferreira
@since 24/06/2010 
@param aCmp				Array com campos where
@param cTbl				Tabala de Integração KP
@param aCpoWhe			Array com campos where
@param lRegDel			Logico que informa se registro está deletado ou não
@param cTipTrs			Tipo da transação 
@return lRet
/*/
//---------------------------------------------------------------------------------------
Static Function FPrcIntTbl(aCmp, cTbl, aCpoWhe, lRegDel, cTipTrs , lAtPosCli )
Local 	cTblIns		:= ""
Local		cTblUpd		:= ""
Local		cWheQry		:=	""
Local		cTpoVar		:= ""
Local		uValVar		:= ""
Local		cTblSel		:=	""
Local		cQryPrc		:= ""			
Local		cId			:= ""

Local		nPosExc		:= 0

Local		lRet			:= .T.

Default	aCmp		 := {}                                                       
Default	cTbl      := ""
Default	aCpoWhe	 := {}                                                       
Default	lRegDel 	 := .F.   
Default  lAtPosCli := .F.

If Len(aCmp) > 0 .And. !Empty(cTbl)	     	
   If Len(aCpoWhe) > 0 
		// Cria a query de Update
		cTblUpd	:= FCrtQryUpd(aCmp, cTbl)
	
		// Carrega os campos Where utilizado no UPDATE
		cWheQry	:= FCrtQryWhe(aCpoWhe)               
	
		cId := FChkRegBd(cTbl,cWheQry)
	EndIf
	If !Empty(cId)
      If cId == "E"
			cQryPrc += cTblUpd + ", IDENTIFICA = 'I'" + cEol + cWheQry	
		ElseIf lRegDel
			cQryPrc += cTblUpd + ", IDENTIFICA = 'E'" + cEol + cWheQry	
		Else     
			cQryPrc += cTblUpd + ", IDENTIFICA = '"+cTipTrs+"'" + cEol + cWheQry				
		EndIf	
	Else
		// Cria a query de insert
		If lRegDel
			nPosExc := aScan( aCmp,{ |x| Alltrim(x[1]) == "IDENTIFICA" } )
			If nPosExc > 0
				acmp[nPosExc][2] := "E" 
			EndIf
			cTblIns	:= FCrtQryIns(aCmp, cTbl)		
		Else
			cTblIns	:= FCrtQryIns(aCmp, cTbl)
		EndIf
		cQryPrc := cTblIns
	EndIf 
   Conout("INICIO - Processa as atualizações das integrações KP - FPrcIntTbl")	
	lRet	  :=		FExecQry(cQryPrc,"",1)
   Conout("FIM - Processa as atualizações das integrações KP - FPrcIntTbl")	
Else
	lRet	:= .F.
EndIf

Return lRet 

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FCrtQryWhe
Cria Where das clausulas SQL
        
@protected
@author Fernando Ferreira
@since 24/06/2010 
@param aCpoWhe			Array com campos where
@return cQryWhe
/*/
//---------------------------------------------------------------------------------------
Static Function FCrtQryWhe(aCpoWhe)
Local 	cQryWhe	:= ""
Local		cTpoVar	:= ""
Local		uValVar	:= ""

Default	aCpoWhe	:=	{}

If Len(aCpoWhe) > 0
// Inicio da Montagem da Clausula Where para Update
	cQryWhe := " WHERE "               	
	For nX := 1 to Len(aCpoWhe) 	
		cTpoVar	:= ValType(aCpoWhe[nX,02])
		uValVar	:= aCpoWhe[nX,02]
		
		Do Case			
			Case cTpoVar == 'C'			
				cValVar := "'" + Trim(uValVar) + "'"
				
			Case cTpoVar == 'N'			
				cValVar := lTrim(Str(uValVar))
				
			Case cTpoVar == 'D'			
				cValVar := "'" +Str(Year(uValVar), 4)+ "-" +  StrZero(Month(uValVar),2) + "-" + StrZero(Day(uValVar), 2) + "'" 		
		End Case	
		cQryWhe += aCpoWhe[nX,01] + aCpoWhe[nX,03] + cValVar + " And "	
	Next	
	cQryWhe := Substr(cQryWhe,1, len(cQryWhe)-5) + ""	
EndIf

Return cQryWhe

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FCrtQryIns
Cria Where das clausulas SQL
        
@protected
@author Fernando Ferreira
@since 24/06/2010 
@param  aCmp			Array com campos da tabela
@param  cTbl			Tabela a se processada
@return cTblIns
/*/
//---------------------------------------------------------------------------------------
Static Function FCrtQryIns(aCmp, cTbl)
Local		cTblIns 	:= ""
Local		cTpoVar	:= ""
Local		uValVar	:= ""

Default	aCmp		:= {}

If Len(aCmp) > 0
	cTblIns := cEol + " INSERT INTO "
	cTblIns += " [" + cTbl + "] "
	cTblIns += cEol + "("
	
	// Nomes dos campos
	For nX := 1 To Len(aCmp)
		cTblIns += aCmp[nX,01] + " , "
	Next nX
	cTblIns := Substr(cTblIns,1, len(cTblIns)-3)+ ") "
	cTblIns += cEol + "VALUES ("
	
	// Valores dos Campos
	For nX := 1 To Len(aCmp)
		cTpoVar	:= ValType(aCmp[nX,02])
		uValVar	:= aCmp[nX,02]
		Do Case
			Case cTpoVar == 'C'
				StrTran(uValVar,"'","'+Chr(39)+'")
				If "NULL" $ uValVar			
					cValVar := Trim(uValVar)
				Else
					cValVar := "'" + Trim(uValVar) + "'"
				EndIf
				
			Case cTpoVar == 'N'			
				cValVar := lTrim(Str(uValVar))
				
			Case cTpoVar == 'D'			
				cValVar := "'" +StrZero(Day(uValVar), 2)+ "/" +  StrZero(Month(uValVar),2) + "/" + Str(Year(uValVar, 4), 4) + "'"	
		EndCase
		cTblIns += cValVar + " , "
	Next
	
	cTblIns	:= Substr(cTblIns,1, len(cTblIns)-3)+ ")"
EndIf

Return cTblIns

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FCrtQryUpd
Cria Where das clausulas SQL
        
@protected
@author Fernando Ferreira
@since 24/06/2010 
@param  aCmp			Array com campos da tabela
@param  cTbl			Tabela que será realizado o Update

@return cTblUpd Senteça sql do update
/*/
//---------------------------------------------------------------------------------------
Static Function FCrtQryUpd(aCmp, cTbl)
Local		cTblUpd 	:= ""
Local		cTpoVar	:= ""
Local		uValVar	:= ""

Default	aCmp		:= {}

If Len(aCmp) > 0
	cTblUpd := cEol + " UPDATE "
	cTblUpd += " [" + cTbl + "] "
	cTblUpd += " SET " + cEol
	
	// Valores dos Campos
	For nX := 1 To Len(aCmp)	
		cTpoVar	:= ValType(aCmp[nX,02])
		uValVar	:= aCmp[nX,02]
		If aCmp[nX,01] != "IDENTIFICA"
			Do Case			
				Case cTpoVar == 'C'
					If "NULL" $ uValVar
						cValVar	:= Trim(uValVar)
					Else
						cValVar := "'" + Trim(uValVar) + "'"							
					EndIf						
					
				Case cTpoVar == 'N'			
					cValVar := lTrim(Str(uValVar))
					
				Case cTpoVar == 'D'								
					cValVar := "'" +StrZero(Day(uValVar), 2)+ "/" +  StrZero(Month(uValVar),2) + "/" + Str(Year(uValVar, 4), 4) + "'"			
			EndCase		
			cTblUpd += aCmp[nX,01] + " = " + cValVar + " , "	
		EndIf
	Next
	cTblUpd := Substr(cTblUpd,1, len(cTblUpd)-3) + ""
EndIf

Return cTblUpd

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSQryIns
Função Responsavel por montar a query de Inclusao Generica

@author 	Luciano M. Pinto
@since 		23/08/2011
@version	P11
@param 		aCampos		Campos e valores para montagem da Qeury
@param		cIdentif		Identificador do registro
@param		cTabela		Tabela do Banco
@return		lRet 			Retorna se foi processado com sucesso ou nao
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
09/11/2011 Claudio Silva	Adequacao para retornar se foi processado com sucesso ou nao
/*/ 
//---------------------------------------------------------------------------------------
User Function FSQryIns(aCampos, cTabela, aCpoWhe, cIdentif)

Local cInsert	:= ""
Local	cDelReg	:= ""
Local lRet		:= .T.

Default cIdentif := "123"	
//***************************************************************************************
// Inicio da Montagem da Query para inserir os dados
//***************************************************************************************
cInsert := " INSERT INTO "

cInsert +=  " [" + cTabela + "] " 

//***************************************************************************************
// Titulo dos Campos da Tabela CLientes
//***************************************************************************************
cInsert += " ("

For nX := 1 To Len(aCampos)
	
	cInsert += aCampos[nX,01] + " , "
	
Next nX

cInsert := Substr(cInsert,1, len(cInsert)-3)+ ") VALUES ("

//***************************************************************************************
// Valores dos Campos
//***************************************************************************************
For nX := 1 To Len(aCampos)
	
	cTpoVar	:= ValType(aCampos[nX,02])
	uValVar	:= aCampos[nX,02]
	
	Do Case	
		
		Case cTpoVar == 'C'
			uValVar := StrTran(uValVar,"'","'+Chr(39)+'")
			If "NULL" $ uValVar			
				cValVar := Trim(uValVar)
			Else
				cValVar := "'" + Trim(uValVar) + "'"
			EndIf
			
		Case cTpoVar == 'N'
			
			cValVar := lTrim(Str(uValVar))
			
		Case cTpoVar == 'D'			
			cValVar := "'" +StrZero(Day(uValVar), 2)+ "/" +  StrZero(Month(uValVar),2) + "/" + Str(Year(uValVar, 4), 4) + "'"				
	End Case
		
	cInsert += cValVar + " , "
	
Next nX

cInsert	:= Substr(cInsert,1, len(cInsert)-3)+ ")"

cDelReg	+=	"DELETE " + cTabela

//***************************************************************************************
// Clausula Where
//***************************************************************************************
If Len(aCpoWhe) > 0

	cDelReg += cEol + " WHERE " 
	
	For nX := 1 to Len(aCpoWhe) 
	
		cTpoVar	:= ValType(aCpoWhe[nX,02])
		uValVar	:= aCpoWhe[nX,02]

		Do Case	
			
			Case cTpoVar == 'C'
				
				cValVar := "'" + Trim(uValVar) + "'"
				
			Case cTpoVar == 'N'
				
				cValVar := lTrim(Str(uValVar))
				
			Case cTpoVar == 'D'								
				cValVar := "'" +StrZero(Day(uValVar), 2)+ "/" +  StrZero(Month(uValVar),2) + "/" + Str(Year(uValVar, 4), 4) + "'"	
	
		End Case
		

		cDelReg += aCpoWhe[nX,01] + aCpoWhe[nX,03] + cValVar + " And "
	
	Next
	
End If

cDelReg := Substr(cDelReg,1, len(cDelReg)-5) + ""

If !Empty(cInsert)
	// Conecta no Banco de Dados de Integracao e executa a Query
	// Caso o registro já existir na base de integração 
	// ele será excluido e inserido novamente.
   Conout("INICIO - Del Reg. - FSQryIns")	
	FExecQry(cDelReg,cIdentif,1)
   Conout("Parte 2")	
	lRet:= FExecQry(cInsert,cIdentif,1)
	Conout("FIM - Insert Reg - FSQryIns")	
End If

Return(lRet)


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSQryUpd
Função Responsavel por montar a query de Update Generica

@author 		Luciano M. Pinto
@since 		23/08/2011
@version		P11
@param 		aCampos	Campos e valores para montagem da Qeury
@param		cIdentif	Identificador do registro
@param		cTabela	Tabela do Banco 
@param		aWhere	Campos da clausula Where
@return		lRet 		Retorna se foi processado com sucesso ou nao
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
09/11/2011 Claudio Silva	Adequacao para retornar se foi processado com sucesso ou nao
/*/ 
//---------------------------------------------------------------------------------------
User Function FSQryUpd(aCampos,cTabela,aWhere,cIdentif)
/****************************************************************************************
* 
* cValue and uValue
***/
Local cUpdate	:= ""
Local nX			:= 0
Local lRet		:= .T.

Default cIdentif := "123"	

//***************************************************************************************
// Inicio da Montagem da Query para inserir os dados
//***************************************************************************************
cUpdate := " UPDATE "

cUpdate += " [" + cTabela + "] "

//***************************************************************************************
// Titulo dos Campos da Tabela CLientes
//***************************************************************************************
cUpdate += " SET "

//***************************************************************************************
// Valores dos Campos
//***************************************************************************************
For nX := 1 To Len(aCampos)
	
	cTpoVar	:= ValType(aCampos[nX,02])
	uValVar	:= aCampos[nX,02]
	
	Do Case	
		
		Case cTpoVar == 'C'    
			uValVar := StrTran(uValVar,"'","'+Chr(39)+'")
			If "NULL" $ uValVar
				cValVar	:= Trim(uValVar)
			Else
				cValVar := "'" + Trim(uValVar) + "'"							
			EndIf						
			
		Case cTpoVar == 'N'
			
			cValVar := lTrim(Str(uValVar))
			
		Case cTpoVar == 'D'						
			cValVar := "'" +StrZero(Day(uValVar), 2)+ "/" +  StrZero(Month(uValVar),2) + "/" + Str(Year(uValVar, 4), 4) + "'"	
	End Case
		
	cUpdate += aCampos[nX,01] + " = " + cValVar + " , "
	
Next nX

cUpdate := Substr(cUpdate,1, len(cUpdate)-3) + ""

//***************************************************************************************
// Clausula Where
//***************************************************************************************
If Len(aWhere) > 0

	cUpdate += " WHERE " 
	
	For nX := 1 to Len(aWhere) 
	
		cTpoVar	:= ValType(aWhere[nX,02])
		uValVar	:= aWhere[nX,02]

		Do Case	
			
			Case cTpoVar == 'C'       
				uValVar := StrTran(uValVar,"'","'+Chr(39)+'")
				
				cValVar := "'" + Trim(uValVar) + "'"
				
			Case cTpoVar == 'N'
				
				cValVar := lTrim(Str(uValVar))
				
			Case cTpoVar == 'D'
				cValVar := "'" +StrZero(Day(uValVar), 2)+ "/" +  StrZero(Month(uValVar),2) + "/" + Str(Year(uValVar, 4), 4) + "'"										
		End Case
		

		cUpdate += aWhere[nX,01] + aWhere[nX,03] + cValVar + " And "
	
	Next
	
End If

cUpdate := Substr(cUpdate,1, len(cUpdate)-5) + ""

If !Empty(cUpdate)

	//***********************************************************************************
	// Conecta no Banco de Dados de Integracao e executa a Query
	//***********************************************************************************
	cDocTrans := ""
	
	nPosTmp := aScan( aWhere , { |x| Alltrim(x[1]) == "C5_ZPEDIDO" } )
	If nPosTmp > 0
    	cDocTrans := aWhere[nPosTmp][2]
   Endif

	ConOut("INICIO - Executando Update...")
	lRet:= FExecQry(cUpdate,cIdentif,"",cDocTrans)
	ConOut("FIM - Executando Update...")
End If

Return(lRet)


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FExecQry
Função Responsavel por Executar a Query na Base de Integração

@protected         
@author 		Fernando Ferreira
@since 		
@version 	P11
@param		cQuery 	SQL a ser processado
@param		cIdent
@return		lRet		Retornar valor logico se foi processado com sucesso ou nao
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
09/11/2011 Claudio Silva	Adequacao para retornar se foi processado com sucesso ou nao
/*/ 
//---------------------------------------------------------------------------------------
Static Function FExecQry(cQuery,cIdent,nTp,cDocTrans)

Local cServer	:= SuperGetMv( "FS_INTDBIP" , .F., "" )
Local cAmbi		:= SuperGetMv( "FS_INTDBAM" , .F., "" )
Local cInsert	:= ""	
Local nRetTop 	:= 0
Local nX			:= 0 
Local lRet		:= .T.                     
Local cSqlErr	:= ""

Local nAmbERP	:= advConnection()
Local nAmbINT	:= -1//TcLink( cAmbi, cServer )
                                           
If !Empty(cAmbi) .And. !Empty(cServer)
	nAmbINT		:=	TcLink(cAmbi,cServer)
Else
	Aviso("Problema","Parametros inválidos! - FS_INTDBIP ou FS_INTDBAM", {"Ok"})
	Conout("Parametros inválidos! - FS_INTDBIP ou FS_INTDBAM / "+xFilial("P00"))
EndIf

Default cIdent    := "123"	
Default cDocTrans := "" // alterado em 20150525

Conout("Conectando.."+cAmbi+" / "+cServer)

//***************************************************************************************
// Valida a conexão com a base de integração
//***************************************************************************************
if nAmbINT < 0 
 //	Aviso("Problema","Erro de conexão com o ambiente de integração.", {"Ok"})
  //	lRet:= .F.
Else
	//***********************************************************************************
	// Altera o ambiente para Integração
	//***********************************************************************************
	ConOut("Setando ambiente de integração/interface..")
	TCSetConn(nAmbINT)
	
	//***********************************************************************************
	// Executa a Query
	//***********************************************************************************
	ConOut("Executando a query no ambiente de interface..")
	nRetTop := TCSQLExec(cQuery)
	cSqlErr := TCSQLError()

	//***********************************************************************************
	// Fecha conexão com a Base de Interface - 20150602 / alterado a ordem, primeiro 
	// fecha a interface para depois retornar ao ambiente inicial. Estava trocado. MC
	//***********************************************************************************
	ConOut("Fechando interface..")
	TcUnlink(nAmbINT)

	//***********************************************************************************
	// Retorna o ambiente inicial
	//***********************************************************************************
	ConOut("Voltando para o ambiente do Protheus..")
	TCSetConn(nAmbERP)

	//***********************************************************************************
	// Verifica a existencia de erros
	//***********************************************************************************
	If nRetTop <> 0 .And. nAmbERP > 0		
		Aviso("Problema","Falha na tentativa de atualizar a Base de Interface.", {"Ok"})		
		Conout("***************************************************************************")
		Conout("Falha na tentativa de atualizar a Base de Interface.")
		Conout("***************************************************************************")
		Conout(cSqlErr)                                                               
		Conout("***************************************************************************")
		cMsgErr	:= "Falha na tentativa de atualizar a Base de Interface.:" + cDocTrans
		If ! Empty(cDocTrans)
    		U_FSSETERR(xFilial("P00"), dDataBase, Time(), cDocTrans , "Ped. Rem", cMsgErr)
		Endif
		lRet:=.F.
	EndIf		
	
EndIf

Return(lRet)



//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSSelSql
Função responsável por realizar select na base de integração.

@author 		Luciano M. Pinto
@since 		23/08/2011
@version		P11
@param 		cQuery	SQL a ser processado
@return		Array		Array de duas posições 1:Arquivo de trabalho, 2: Handler de conexão com base de Integração.
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
09/11/2011 Claudio Silva	Adequacao para retornar se foi processado com sucesso ou nao
/*/ 
//---------------------------------------------------------------------------------------
User Function FSSelSql(cQuery,cIdent)
/****************************************************************************************
* Função Responsavel por Executar a Query na Base de Integração
* Implementação com TcLink
*
***/ 
Local cServer	:= SuperGetMv( "FS_INTDBIP" , .F.,"" ) //"10.31.3.22" //GetMv(FS_IPSERV)
Local cAmbi		:= SuperGetMv( "FS_INTDBAM" , .F.,"" )

Local nAmbERP	:= advConnection()
Local nAmbINT	:= -1

Local cAliaTRB := GetNextAlias() 

Default cIdent := "123"	

If !Empty(cAmbi) .And. !Empty(cServer)
	nAmbINT	:= TcLink(cAmbi, cServer )
EndIf

//***************************************************************************************
// Valida a conexão com a base de integração
//***************************************************************************************
if nAmbINT < 0 
	
//	Aviso("Problema","Erro de conexão com o ambiente de integração.", {"Ok"})

Else
	
	//***********************************************************************************
	// Altera o ambiente para Integração
	//***********************************************************************************
	Conout("Alterando para o ambiente de integração..")
	TCSetConn(nAmbINT)
	

	//***********************************************************************************
	// Executa a Query
	//***********************************************************************************
	Conout("Executando a query..")
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliaTRB,.T.,.T.) 
	

	//***********************************************************************************
	// Retorna o ambiente inicial
	//***********************************************************************************
	Conout("Retornando para o ambiente inicial..")
	TCSetConn(nAmbERP)                                           
	
	//***********************************************************************************
	// Fecha conexão com a Base de Interface
	//***********************************************************************************
//	TcUnlink(nAmbINT)
	
	
End If


Return {cAliaTRB,nAmbINT}



//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FTpoAlt 
Verifica qual o tipo de integração com a base

@author 	Luciano M. Pinto
@since 		23/08/2011
@version 	P11
@param      nTipo Tipo de alteração Inclusao,Alteração, Exclusão e qual a tabela

/*/ 
//---------------------------------------------------------------------------------------
User Function FTpoAlt(nTipo)
/****************************************************************************************
* 
*
*
***/

Local	lRet	:=	.T.

Do Case

	Case nTipo == 1 //	Inclusão [Cliente]

		If SA1->A1_ZTIPO == 'S' // Se confirmou a Inclusão e o cliente é CONCRETO
			U_FSPutTab("SA1","I")
			U_FAtuEnd()
		End If
	
	Case nTipo == 2 //	Alteração [Cliente]
	
		If SA1->A1_ZTIPO == 'S'			// Verifica se Cliente é Concreto
			U_FSPutTab("SA1","A")
			U_FAtuEnd()
		End If
	
	Case nTipo == 3 //	Exclusão [Cliente] 
	
		If SA1->A1_ZTIPO == 'S'	//	Verifica se Cliente é Concreto
			U_FSINTP12(xFilial("SA1"), SA1->A1_COD, SA1->A1_LOJA)
			lRet	:= U_FSPutTab("SA1","E")
			FExcEnd( SA1->A1_COD,SA1->A1_LOJA)
		End If
		
	Case nTipo == 4 //	Inclusão [Veiculo]
		
		U_FSPutTab("DA3","I")
			
	Case nTipo == 5 //	Alteração [Veiculo]
	
		   If U_FSVldAlt("DA3")  //Verifica se houve alteração nos campos
				U_FSPutTab("DA3","A")
			End If
			
	Case nTipo == 6 //	Exclusão [Veiculo]
		
			U_FSPutTab("DA3","E")

	Case nTipo == 7 //	Inclusão [Motorista]
	
			U_FSPutTab("DA4","I")
			
	Case nTipo == 8 //	Alteração [Motorista]

			If U_FSVldAlt("DA4")  //Verifica se houve alteração nos campos	
				U_FSPutTab("DA4","A")
			End If

	Case nTipo == 9 //	Exclusão [Motorista]
	
			U_FSPutTab("DA4","E")
			
		
End Case


Return lRet


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSVldAlt 
Verifica se houve alteração nos campos do SA1

@author 		Luciano M. Pinto
@since 		23/08/2011
@version 	P11
@return		lRetFun	Existem campos alterados (Verdadeiro/Falso)
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
08/11/2011 Claudio Silva		Alteracao da funcao de static FVldAlt para User Function FSVldAlt   
10/04/2012 Fernando Ferreira  Incluido a tabela para macro substituição.
/*/ 
//---------------------------------------------------------------------------------------
User Function FSVldAlt(cAlias)

Local 	lRetFun	:= .F.
Local 	nX			:= 0

Default 	cAlias	:= ""
               
For nX := 1 to Len(aDadOld)
	//***********************************************************************************
	// Comparação dos campos	  
	//***********************************************************************************
	If &(cAlias+"->"+aDadOld[nX,1]) <>  aDadOld[nX,2]
		lRetFun := .T.
		Exit         
	End If
Next

Return (lRetFun) 



//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSDtaExc 
Formada a data a ser gravada no campo DATAINTERFACE

@author 	Luciano M. Pinto
@since 	27/10/2011
@version P11
@param 	dData		Data (opcional)
@return	cRetFun	Data + Hora sem "/" ou ":"
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
09/11/2011 Claudio Silva	Adequacao no formato da data devido alteracao campo DATAINTERFACE para DATE
/*/ 
//---------------------------------------------------------------------------------------
User Function FSDtaExc(dData)

Local cRetFun := ""

Default dData := dDataBase 

cRetFun := GravaData(dData,.T.,5) //DD/MM/AAAA

Return (cRetFun)


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSVldExc
Função para validar a Exclusão dos Veiculos
         
@author 	Luciano M. Pinto
@since 		23/08/2011
@version 	P11
@return		lRetFun 	Registro pode ser excluido
/*/ 
//---------------------------------------------------------------------------------------
User Function FSVldExc(cTipo)

Local 	cMsgRet 		:= ""        
Local 	cTxtEol 		:= Chr(13) + Chr(10)
Local		cHdlInt		:=	SuperGetMv( "FS_INTDBAM" , .F.,"" )  // Parâmetro utilizado para o ambiente da base de integração
Local		cEndIp		:=	SuperGetMv( "FS_INTDBIP" , .F.,"" )	// Parêmetro utilizado para informar o IP do servidor da base de integração
Local		cQryTbl		:=	""
Local		cAlsTem		:= GetNextAlias()

Local 	nHdlInt		:=	-1
Local 	nHdlErp		:=	AdvConnection()
Local		nRetMsg		:= 0

Local 	lRetFun := .T.   

If !Empty(cHdlInt).And.!Empty(cEndIp)
	nHdlInt		:=	TcLink(cHdlInt,cEndIp)
EndIf

Do Case                

	Case cTipo == "SA1"
	 
	   If SA1->A1_ZFLAG == '*'
			cMsgRet := "O Cliente " + AllTrim(SA1->A1_COD) + "/" + AllTrim(SA1->A1_LOJA) 
			If FVldDel("SA1")
				lRetFun := .F.
			End If
		End If

	Case cTipo == "SZ1"
		If P01->P01_ZFLAG == "*"
			If nHdlInt < 0 
				ConOut("Nao foi possivel realizar conexao com banco de dados de integracao. " + DtoC(Date())+" - "+Time())
			Else
				TcSetConn(nHdlInt)
				cQryTbl	:=	"SELECT"
				cQryTbl	+=	cTxtEol + "	Z1.FLAGEXC"
				cQryTbl	+=	cTxtEol + "FROM"
				cQryTbl	+=	cTxtEol + "	SZ1 Z1"
				cQryTbl	+=	cTxtEol + "WHERE "
				cQryTbl	+=	cTxtEol + "	Z1.Z1_FILIAL 	= '"+ xFilial("P01")	 +"' 				AND"
				cQryTbl	+=	cTxtEol + "	Z1.Z1_COD		= '"+ P01->P01_COD  	 +"' 				AND"
				cQryTbl	+=	cTxtEol + "	Z1.Z1_LOJA		= '"+ P01->P01_LOJA   +"' 				AND"
				cQryTbl	+=	cTxtEol + "	Z1.Z1_ITEM		= '"+ P01->P01_ITEM   +"'"			
				
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryTbl), cAlsTem, .F., .T.)
				TCSetConn(nHdlErp)
				cMsgRet := "O Endereço do cliente: " + AllTrim(P01->P01_COD) +  " Loja: " + P01->P01_LOJA + " Item: " + P01->P01_ITEM
				If ((cAlsTem)->(!Eof())) .And. (P01->P01_ZFLAG == "*") .And. ((cAlsTem)->FLAGEXC == "*")
					lRetFun := .F.
				EndIf
			EndIf		
		EndIf
	Case cTipo == "DA3" 
	   If DA3->DA3_ZFLAG == '*'
			cMsgRet := "O Veiculo " + AllTrim(DA3->DA3_COD) 
			If FVldDel("DA3")
				lRetFun := .F.
			End If
		End If
	Case cTipo == "DA4" 
	
	   If DA4->DA4_ZFLAG == '*'
			cMsgRet := "O Motorista " + AllTrim(DA4->DA4_COD) 	   
			If FVldDel("DA4")
				lRetFun := .F.
			End If
		End If

	Case cTipo == "SF4" 
		cMsgRet := "O TES " + AllTrim(SF4->F4_CODIGO) 	
	   If SF4->F4_ZFLAG == '*'
			If FVldDel("SF4")
				lRetFun := .F.
			End If
		End If

	Case cTipo == "CTT" 
	
	   If CTT->CTT_ZFLAG == '*'
	   	cMsgRet := "O Centro de Custo " + AllTrim(CTT->CTT_CUSTO)
			If FVldDel("CTT")				
				lRetFun := .F.
			End If
		End If

	Case cTipo == "SB1"
		If nHdlInt < 0 
			ConOut("Nao foi possivel realizar conexao com banco de dados de integracao. " + DtoC(Date())+" - "+Time())
		Else
			TcSetConn(nHdlInt)
			cQryTbl	:=	"SELECT"
			cQryTbl	+=	cTxtEol + "	B1.FLAGEXC"
			cQryTbl	+=	cTxtEol + "FROM"
			cQryTbl	+=	cTxtEol + "	SB1 B1"
			cQryTbl	+=	cTxtEol + "WHERE "
			cQryTbl	+=	cTxtEol + "	B1.B1_FILIAL 	= '"+xFilial("SB1")+"' 				AND"
			cQryTbl	+=	cTxtEol + "	B1.B1_COD		= '"+SB1->B1_COD+	"'"
			
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryTbl), cAlsTem, .F., .T.)
			TCSetConn(nHdlErp)                                                                     
			cMsgRet := "O Produto " + AllTrim(SB1->B1_COD)
			If ((cAlsTem)->(!Eof())) .And. (SB1->B1_ZFLAG == "*") .And. ((cAlsTem)->FLAGEXC == "*")
				lRetFun := .F.
			EndIf
		EndIf
	Case cTipo == "SA2"
		If nHdlInt < 0
			ConOut("Nao foi possivel realizar conexao com banco de dados de integracao. " + DtoC(Date())+" - "+Time())
		Else
			TcSetConn(nHdlInt)
			cQryTbl	:=	"SELECT"
			cQryTbl	+=	cTxtEol + "	A2.FLAGEXC"
			cQryTbl	+=	cTxtEol + "FROM"
			cQryTbl	+=	cTxtEol + "	FORNECEDOR A2"
			cQryTbl	+=	cTxtEol + "WHERE"
			cQryTbl	+=	cTxtEol + "	A2.CENTRAL				= '"+xFilial("SA2")+"'		AND"
			cQryTbl	+=	cTxtEol + "	A2.CODIGOFORNECEDOR 	= '"+SA2->A2_COD+	"'			AND"
			cQryTbl	+=	cTxtEol + "	A2.LOJA					= '"+SA2->A2_LOJA+"'"
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryTbl), cAlsTem, .F., .T.)
			TCSetConn(nHdlErp)                                                                     
			cMsgRet := "O Fornecedor " + AllTrim(SA2->A2_COD)
			If ((cAlsTem)->(!Eof())) .And. (SA2->A2_ZFLAG == "*") .And. ((cAlsTem)->FLAGEXC == "*")
				lRetFun := .F.
			EndIf
		EndIf
	Case cTipo == "SA3"
		If nHdlInt < 0
			ConOut("Nao foi possivel realizar conexao com banco de dados de integracao. " + DtoC(Date())+" - "+Time())
		Else
			TcSetConn(nHdlInt)
			cQryTbl	:=	"SELECT"
			cQryTbl	+=	cTxtEol + "	A3.FLAGEXC"
			cQryTbl	+=	cTxtEol + "FROM"
			cQryTbl	+=	cTxtEol + "	VENDEDOR A3"
			cQryTbl	+=	cTxtEol + "WHERE"
			cQryTbl	+=	cTxtEol + "	A3.CENTRAL				= '"+xFilial("SA3")+"'		AND"
			cQryTbl	+=	cTxtEol + "	A3.CODIGOVENDEDOR 	= '"+SA3->A3_COD+	"'"
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryTbl), cAlsTem, .F., .T.)
			TCSetConn(nHdlErp)
			cMsgRet := "O Vendedor " + AllTrim(SA3->A3_COD)
			If ((cAlsTem)->(!Eof())) .And. (SA3->A3_ZFLAG == "*") .And. ((cAlsTem)->FLAGEXC == "*")
				lRetFun := .F.
			EndIf
		EndIf					
End Case
U_FSCloAre(cAlsTem)
TcUnlink(nHdlInt)
//Case falso exibe a mensagem
If !lRetFun

	Aviso("A T E N C A O", cMsgRet + " já foi enviado para a base de" + ;
			" integração e já foi utilizado pelo KP." + cTxtEol + ; 
			"E portanto não poderá	 ser excluído." + cTxtEol + ;							
			"Entre em contato com o administrador do sistema!",{"OK"})
Else
	nRetMsg	:= MessageBox(cMsgRet + " já foi enviado para a base de integração e ainda não foi utilizado pelo KP.";
									+" Deseja Prosseguir  com a exclusão?","Integração KP",4)
	IIF(nRetMsg == 6,lRetFun := .T., lRetFun := .F.)
EndIf
	
Return(lRetFun) 


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FVldDel
Função utilizada para montar a query que verifica o flag de exclusão
         
@protected
@author	Luciano M. Pinto
@since 	28/10/2011
@version	P11
/*/ 
//--------------------------------------------------------------------------------------- 
Static Function FVldDel(cTipo)

Local cQuery  := ""
Local cTrbRet := ""
Local aRetFun := {}			    
Local lRetFun := .F.	

cQuery := " SELECT FLAGEXC "                      

Do Case

	Case cTipo == "SA1"
		cQuery += " FROM CLIENTES "
		cQuery += " WHERE FILIAL = '" + AllTrim(xFilial("SA1")) + "'"
		cQuery += " AND CODIGOCLIENTE = '" + AllTrim(SA1->A1_COD) + "'"  
		cQuery += " AND LOJA = '" + AllTrim(SA1->A1_LOJA) + "'" 		
	
	Case cTipo == "DA3"
		cQuery += " FROM VEICULOS "
		cQuery += " WHERE CODIGOCENTRAL = '" + AllTrim(xFilial("DA3")) + "'"
		cQuery += " AND CODIGOVEICULO = '" + AllTrim(DA3->DA3_COD) + "'" 

	Case cTipo == "DA4"
		cQuery += " FROM MOTORISTAS "
		cQuery += " WHERE CODIGOCENTRAL = '" + AllTrim(xFilial("DA4")) + "'"
		cQuery += " AND CODIGOMOTORISTA = '" + AllTrim(DA4->DA4_COD) + "'" 

	Case cTipo == "SF4"
		cQuery += " FROM SF4 "
		cQuery += " WHERE F4_FILIAL = '" + AllTrim(xFilial("SF4")) + "'"
		cQuery += " AND F4_CODIGO = '" + AllTrim(SF4->F4_CODIGO) + "'" 

	Case cTipo == "CTT"
		cQuery += " FROM CTT "
		cQuery += " WHERE CTT_FILIAL = '" + AllTrim(xFilial("CTT")) + "'"
		cQuery += " AND CTT_CUSTO = '" + AllTrim(CTT->CTT_CUSTO) + "'" 

End Case

//cQuery += " AND DATAINTERFACE IS NULL "
		
aRetFun := U_FSSelSql(cQuery)
cTrbRet := aRetFun[1]

If !(cTrbRet)->(Eof())
	
	If (cTrbRet)->FLAGEXC == "*"    
		lRetFun := .T.	                              
	End If
	
End If
	                  
//Fechar o Link com a base de Integração
TcUnlink(aRetFun[2])

Return(lRetFun)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSChkAlt
Salvar os valores dos campos para verificar se houve alteração para gravar na base intermediaria
        
@author 	Luciano M. Pinto
@since 	31/10/2011 
@return 	Nil
@param 	cAlias Alias da tabela do qual se deve salvar os valores dos campos	
/*/
//---------------------------------------------------------------------------------------
User Function FSChkAlt(cAlias)
/****************************************************************************************
* 
*
*
***/ 
Local aCpoRet	:= {}
Local aValRet	:= {}

aCpoRet := U_FSGetCmp(cAlias)  	

// Preenche a variavel com os campos e valores da Tabela         
For nX := 1 to Len(aCpoRet)
   
   If !Empty(aCpoRet[nX,3])
   
		aAdd(aValRet, {aCpoRet[nX,3], &(aCpoRet[nX,3])})
	
	End If       
	
Next


//***************************************************************************************
// Salvar os valores na variavel Static
//***************************************************************************************
U_FSGetVal(aValRet)

Return Nil

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSChkReg
Função Verifica se o Registro existe na tabela de integração.
        
@protected
@author Fernando Ferreira
@since 24/06/2010 
@param cEndFil			Filial do Endereço do clientecEndFil.
@param cCliCod			Código do cliente do endereço.
@param cCliLoj			Loja do cliente do endereço. 
@param cEndIte			Item Endereço. 
@return lRet
/*/
//---------------------------------------------------------------------------------------
User Function FSChkReg(cEndFil, cCliCod, cCliLoj, cEndIte)
Local 	cQry			:= ""
Local		cHdlInt		:=	SuperGetMv( "FS_INTDBAM" , .F.," " )  // Parâmetro utilizado para o ambiente da base de integração
Local		cEndIp		:=	SuperGetMv( "FS_INTDBIP" , .F.," " )	// Parêmetro utilizado para informar o IP do servidor da base
Local		cAlsTem		:=	GetNextAlias() 

Local 	nHdlInt		:=	-1
Local 	nHdlErp		:=	AdvConnection()
                          
Local		lRet 			:= .T.

Default cEndFil	:=	""
Default cCliCod	:=	""
Default cCliLoj	:=	""
Default cEndIte	:=	""

If !Empty(cHdlInt).And.!Empty(cEndIp)
	nHdlInt		:=	TcLink(cHdlInt,cEndIp)
EndIf

If nHdlInt < 0
	ConOut("Nao foi possivel realizar conexao com banco de dados de integracao. Gentileza verificar configuracoes." + DtoC(Date())+" - "+Time()) 
Else
	cQry	+=			 "SELECT "
	cQry	+= cEol + "		count(*) Z1_GRAVADO"
	cQry	+= cEol + "FROM"
	cQry	+= cEol + "		SZ1"
	cQry	+= cEol + "WHERE"
	cQry	+= cEol + "		Z1_FILIAL	=	'"+cEndFil+"' 		AND"
	cQry	+= cEol + "		Z1_COD		=	'"+cCliCod+"'		AND"
	cQry	+= cEol + "		Z1_LOJA		=	'"+cCliLoj+"'		AND"
	cQry	+= cEol + "		Z1_ITEM 	=	'"+cEndIte+"'			"
	
	TCSetConn(nHdlInt)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAlsTem, .F., .T.)	
	
	If (cAlsTem)->Z1_GRAVADO == 0
		// Inclusão
		lRet	:= .T.		
	Else           
		// Alteração
		lRet	:= .F.
	EndIf		
EndIf
TCSetConn(nHdlErp)
U_FSCloAre(cAlsTem)
TcUnlink(nHdlInt)
Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSEndInt
Realiza a gravação do endereços do cliente na base de integração
        
@author 	Fernando Ferreira
@param	cAtuExc	Processo que será realizado
@since 21/11/2011 

Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSEndInt(cAtuExc)
Local		lRet		:=	.T.

Default	cAtuExc	:= ""

If SA1->A1_ZTIPO == 'S'	
	If	Upper(cAtuExc) == "E"
		lRet	:=	U_FSPutTab("P01","E")	
	ElseIf U_FSChkReg(P01->P01_FILIAL, P01->P01_COD, P01->P01_LOJA, P01->P01_ITEM)
		lRet	:=	U_FSPutTab("P01","I")
	Else
		lRet	:=	U_FSPutTab("P01","A")
	EndIf									
EndIf
Return Nil

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FChkRegBd
Verifica se o registro existe no banco de dados de integração.
        
@protected
@author Rafael Almeida
@since 21/11/2011 
/*/
//---------------------------------------------------------------------------------------
Static Function FChkRegBd(cTbl,cWheQry)

Local		aAreOld	:= {GetArea()}
Local		cAlias	:= GetNextAlias()                          
Local		cQry		:= ""
Local		cId    	:= ""                           

Local cServer	:= SuperGetMv( "FS_INTDBIP" , .F.," " ) //"10.31.3.22" //GetMv(FS_IPSERV)
Local cAmbi		:= SuperGetMv( "FS_INTDBAM" , .F.," " )
Local nAmbERP	:= advConnection()
Local nAmbINT	:= -1

Default	cTbl		:= ""
Default	cWheQry	:= ""                            

If !Empty(cAmbi).And.!Empty(cServer)
	nAmbINT		:=	TcLink(cAmbi,cServer)
EndIf                         

                    
//***************************************************************************************
// Valida a conexão com a base de integração
//***************************************************************************************
If nAmbINT < 0 
//	Aviso("Problema","Erro de conexão com o ambiente de integração.", {"Ok"})
  //	lRet:= .F.
	U_FSCloAre(cAlias)
	TcUnlink(nAmbINT)
Else
	TCSetConn(nAmbINT)

	cQry := " SELECT IDENTIFICA FROM "+cTbl+cWheQry
			
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAlias, .F., .T.)
	(cAlias)->(dbGoTop())	
	If(cAlias)->(!Eof())
		cId := (cAlias)->IDENTIFICA
	EndIf
	
	U_FSCloAre(cAlias)
	TcUnlink(nAmbINT)
EndIf               

TCSetConn(nAmbERP)

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return cId                                                           

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FExcEnd
Efetua a exclusão de todos os endereços do cliente.
        
@protected
@author Rafael Almeida
@since 21/11/2011 
/*/
//---------------------------------------------------------------------------------------
Static Function FExcEnd(cCodCli,cLojCli)

Local		aAreOld	:= {GetArea(),P01->(GetArea())}

Default cCodCli	:= ""
Default cLojCli	:= ""

P01->(dbSetOrder(1))
P01->(dbSeek(xFilial("P01")+cCodCli+cLojCli))
While P01->(!Eof()).And.;
	cCodCli == P01->P01_COD .And.;   
	cLojCli == P01->P01_LOJA
	
	U_FSPutTab("P01","E")	
	
	P01->(dbSkip())
EndDo
	                            
aEval(aAreOld, {|xAux| RestArea(xAux)})

Return 