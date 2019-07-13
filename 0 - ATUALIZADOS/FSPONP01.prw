#include "protheus.ch"


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSPONP01 
Processo de Calculo Compensacao de Horas no mes de competencia
         
@author 	Luciano M. Pinto
@since 		30/08/2011
@version 	P11

/*/ 
//---------------------------------------------------------------------------------------
User Function FSPONP01()
/****************************************************************************************
* Chamada inicial da Funcao
*
*
***/ 
Local lEnd		:= .F.
Local lOk		:= .T.
		
Local oProcess

Private aRetPB	:= {}

//***************************************************************************************
// Exibe a tela de Parametros
//***************************************************************************************
If ! FParamB()

   Return Nil

Else

	If MsgYesNo("A rotina de Calculo Mensal ja foi executada para a Data de Calculo " + ;
				"informada ?!" ,"Compensacao de Horas")
		
		oProcess := MsNewProcess():New({|lEnd| lOk := FCalcHoras(@oProcess, @lEnd) },;
										"Compensacao de Horas","Efetuando Compensacoes",.T.)
		oProcess :Activate()
		
		If lOk
			
			MsgInfo("Compensacao de Horas foi concluida com sucesso !!")
			
		Else
			
//			Alert("A operacao foi cancelada pelo usuario !!")
			
		End If
	
	Else
	
		MsgInfo("Nao existem dados com os parametros informados.") 

	End If
		
Endif


Return Nil



//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FCalcHoras 
                            
@protected
@author 		Luciano M. Pinto
@since 		31/08/2011
@version 	P11                        
@param		oProcess Objeto do Processo 
@param		lEnd Verifica se o processo foi cancelado pelo usuario
@return		lRetFun Verdadeiro ou Falso

/*/ 
//---------------------------------------------------------------------------------------
Static Function FCalcHoras(oProcess,lEnd)
/****************************************************************************************
* Funcao responsavel por ...
* 
*
***/ 
Local aVrbProv	:= {}
Local aVrbDesc	:= {} 
Local aGrpDesc	:= {}	// Grupo com descontos Filial + Matricula

Local cFilIni 	:= CriaVar("PB_FILIAL")
Local cFilFin 	:= CriaVar("PB_FILIAL")
Local cMatIni 	:= CriaVar("PB_MAT")
Local cMatFin 	:= CriaVar("PB_MAT")
Local cCstIni 	:= CriaVar("PB_CC")
Local cCstFin 	:= CriaVar("PB_CC")
Local dDtaCal 	:= CriaVar("PB_DATA")
Local dDtaCalA 	:= CriaVar("PB_DATA")

Local nX		:= 0  
Local nY		:= 0  
Local nZ		:= 0 
//Local nTotDesc	:= 0

Local lRetFun	:= .T.
//***************************************************************************************
//	Campos do Parambox
//***************************************************************************************
//	Filial De
//	Filial Ate
//	Matricula De
//	Matricula Ate
//	Centro Custo De
//	Centro Custo Ate
//	Data do Calculo
//***************************************************************************************

cFilIni  := aRetPB[01] //Mv_Par01
cFilFin  := aRetPB[02] //Mv_Par02
cMatIni  := aRetPB[03] //Mv_Par03
cMatFin  := aRetPB[04] //Mv_Par04 
cCstIni  := aRetPB[05] //Mv_Par05
cCstFin  := aRetPB[06] //Mv_Par06
dDtaCal  := aRetPB[07] //Mv_Par07
//dDtaCalA := aRetPB[08] //Mv_Par08
               
//***************************************************************************************
// Retorna um agrupamento (Filial + Matricula + Centro de Custo) dos Descontos
//***************************************************************************************
aGrpDesc := FQryGrp(cFilIni,cFilFin,cMatIni,cMatFin,cCstIni,cCstFin,dDtaCal,"2")

If Empty(aGrpDesc) 

	MsgInfo("Nao existem dados com os parametros informados.") 
	Return Nil
	
End If

oProcess:SetRegua1(Len(aGrpDesc))

For nY := 1 to Len(aGrpDesc)

	If (lEnd)
      
		lRetFun	:= .F.
		Exit
		
	End If

	oProcess:IncRegua1("Lendo Registro: "+aGrpDesc[nY,2])
	

	//***********************************************************************************
	// Retorna os valores da tabela SPB (Proventos)
	//***********************************************************************************
	aVrbProv := FQryVerb(aGrpDesc[nY,01],aGrpDesc[nY,02],aGrpDesc[nY,03],dDtaCal,"1")
	
	
	//***********************************************************************************
	// Retorna os valores da tabela SPB (Descontos)
	//***********************************************************************************
	aVrbDesc := FQryVerb(aGrpDesc[nY,01],aGrpDesc[nY,02],aGrpDesc[nY,03],dDtaCal,"2")
	
	
	If Empty(aVrbProv) .Or. Empty(aVrbDesc)
		
		Loop
		
	End If
	
	
	//***********************************************************************************
	// Totaliza os Descontos (Faltas / Atrasos)
	//***********************************************************************************
	/*
	nTotDesc := 0
	
	For Nx :=  1 to Len(aVrbDesc)
		
		nTotDesc +=	aVrbDesc[Nx,08]
		aVrbDesc[Nx,08] := 0
		
	Next
	*/
	
	//***********************************************************************************
	// Efetua o confronto de Descontos X Proventos
	//*********************************************************************************** 
	oProcess:SetRegua2(Len(aVrbProv)) 

	For Nz :=  1 to Len(aVrbDesc) 	//Varre os Descontos
	
		For Nx :=  1 to Len(aVrbProv) //Varre os Proventos
			
			
			If (lEnd)
				
				lRetFun	:= .F.
				Exit
				
			End If
			
			oProcess:IncRegua2("Confrontando Proventos x Descontos: " + aVrbProv[Nx,3])
			//*******************************************************************************
			// Desconto igual ao Provento
			//*******************************************************************************
			If aVrbDesc[Nz,08] == aVrbProv[Nx,08]
				
				aVrbProv[Nx,08] := 0
				aVrbDesc[Nz,08] := 0
				Exit
				
			End If

			//******************************************************************************
			// Desconto menor que o Provento
			//******************************************************************************
			If aVrbDesc[Nz,08] < aVrbProv[Nx,08]
				
				nValTmp	:=  aVrbProv[Nx,08] - aVrbDesc[Nz,08]
				aVrbProv[Nx,08] := nValTmp
				aVrbDesc[Nz,08] := 0
				Exit
				
			End If

			//******************************************************************************
			// Desconto maior que o Provento
			//******************************************************************************
			If aVrbDesc[Nz,08] > aVrbProv[Nx,08]
				
				nValTmp	:= aVrbDesc[Nz,08] - aVrbProv[Nx,08]
				aVrbProv[Nx,08] := 0
				aVrbDesc[Nz,08] := nValTmp
				
			End If

			//	Sleep(1000)
		Next Nx
		
	Next Nz
		

	If !(lEnd)
	
		//*******************************************************************************
		// Atualiza a tabela SPB (Proventos)
		//*******************************************************************************
		FAtuVerb(aVrbProv)
		
		
		//*******************************************************************************
		// Atualiza a tabela SPB (Descontos)
		//*******************************************************************************
		FAtuVerb(aVrbDesc)
	//	Sleep(1000)
	
	End If
		
Next nY

Return (lRetFun)



//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FQryVerb 
         
@protected
@author 		Luciano M. Pinto
@since 		25/07/2011
@version 	P11
@return		lRetFun
@param		cFilSPB Filial do arquivo SPB	 
@param		cMatSPB Matricula do Funcionario
@param		cCCtSPB Centro de Custo do Funcionario
@param		dDtaCal Data do Calculo
@param		cTpoVerb Tipo de Verba - Desconto ou Provento
@return		aRetFun Array com os dados filtrados

/*/ 
//---------------------------------------------------------------------------------------
Static Function FQryVerb(cFilSPB,cMatSPB,cCCtSPB,dDtaCal,cTpoVerb)
/****************************************************************************************
* Funcao para recuperar as Verbas de acordo com os parametros
* 
*
***/ 
Local cTrbSPB	:= GetNextAlias()   
Local aRetFun 	:= {}

BeginSql alias cTrbSPB

	SELECT  
	
		PB.PB_FILIAL, 
		PB.PB_MAT, 
		PB.PB_PD, 
		PB.PB_CC, 	
		PB.PB_DEPTO, 
		PB.PB_POSTO, 	
		PB.PB_CODFUNC, 	
		PB.PB_HORAS,
		PB_DATA

	FROM  %table:SPB% PB
		INNER JOIN %table:SRV% RV
		ON RV.%notDel%
		
		AND PB.PB_PD = RV.RV_COD 
		
	WHERE	PB.%notDel%
		AND PB.PB_FILIAL	= %Exp:cFilSPB%
		AND PB.PB_MAT 		= %Exp:cMatSPB%
		AND PB.PB_CC		= %Exp:cCCtSPB%
		AND PB.PB_DATA 		= %Exp:dDtaCal%
		AND RV.RV_TIPOCOD	= %Exp:cTpoVerb% 
		AND RV.RV_ZCSCOMP	= 'S'
		
		ORDER BY RV.RV_ZORPREC

EndSql

/*
cQuery := GetLastQuery()[2]
memowrite("c:\cQuery.sql",cQuery)
*/

While !(cTrbSPB)->(Eof())
	aAdd(aRetFun,{	(cTrbSPB)->PB_FILIAL,;
					(cTrbSPB)->PB_MAT,;
					(cTrbSPB)->PB_PD,;
					(cTrbSPB)->PB_CC,;
					(cTrbSPB)->PB_DEPTO,;
					(cTrbSPB)->PB_POSTO,;
					(cTrbSPB)->PB_CODFUNC,;
					(cTrbSPB)->PB_HORAS,;
					0,;
					(cTrbSPB)->PB_DATA})

	(cTrbSPB)->(dbSkip())	
	
End Do

If (Select(cTrbSPB) <> 0)
   dbSelectArea(cTrbSPB)
   dbCloseArea()
EndIf


Return (aRetFun)



//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FQryGrp

@protected         
@author 		Luciano M. Pinto
@since 		25/07/2011
@version 	P11
@param		cFilIni Filial Inicial 
@param		cFilFin Filial Final
@param		cMatIni Matricula Inicial
@param		cMatFin Matricula Inicial
@param		cCstIni Centro de Custo Inicial
@param		cCstFin Centro de Custo Inicial
@param		dDtaCal Data Base do Calculo
@param		cTpoVerb Tipo de Verba - Desconto ou Provento
@return		aRetFun Array com os dados filtrados

/*/ 
//---------------------------------------------------------------------------------------
Static Function FQryGrp(cFilIni,cFilFin,cMatIni,cMatFin,cCstIni,cCstFin,dDtaCal,cTpoVerb)
/****************************************************************************************
* Funcao para recuperar agrupar os descontos 
* 
*
***/ 
Local cTrbSPB	:= GetNextAlias()   
Local aRetFun 	:= {}

BeginSql alias cTrbSPB

	SELECT DISTINCT  
	
		PB.PB_FILIAL, 
		PB.PB_MAT,  
		PB.PB_CC 		

	FROM  %table:SPB% PB
		INNER JOIN %table:SRV% RV
		ON RV.%notDel%
		
		AND PB.PB_PD = RV.RV_COD 
		
	WHERE	PB.%notDel%
		AND PB.PB_FILIAL	BETWEEN  %Exp:cFilIni% AND %Exp:cFilFin% 
		AND PB.PB_MAT 		BETWEEN  %Exp:cMatIni% AND %Exp:cMatFin%  
		AND PB.PB_CC		BETWEEN  %Exp:cCstIni% AND %Exp:cCstFin% 		
		AND PB.PB_DATA 		=  %Exp:dDtaCal% 
		AND RV.RV_TIPOCOD 	= %Exp:cTpoVerb% 
		AND RV.RV_ZCSCOMP 	= 'S' 

EndSql

/*
cQuery := GetLastQuery()[2]
memowrite("c:\cQuery.sql",cQuery)
*/

While !(cTrbSPB)->(Eof())                                                   

	aAdd(aRetFun,{(cTrbSPB)->PB_FILIAL,(cTrbSPB)->PB_MAT,(cTrbSPB)->PB_CC})

	(cTrbSPB)->(dbSkip())	
	
End Do

If (Select(cTrbSPB) <> 0)
   dbSelectArea(cTrbSPB)
   dbCloseArea()
EndIf


Return (aRetFun)


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FAtuVerb

@protected         
@author 	Luciano M. Pinto
@since 		25/07/2011
@version 	P11
@return		lRetFun	

/*/ 
//---------------------------------------------------------------------------------------
Static Function FAtuVerb(aVerbas)
/****************************************************************************************
* Funcao responsavel por atualizar a verba (excluir ou incluir)
* 
*
***/ 
Local nX		:= 0 
Local nY		:= 0
Local aItmSPB	:= {}        
                
For nX := 1 to Len(aVerbas)

	dbSelectArea("SPB")
	dbOrderNickName("FSIDXSPB01")
	SPB->(dbSeek(aVerbas[nX,1]+aVerbas[nX,2]+aVerbas[nX,3]+aVerbas[nX,4]+aVerbas[nX,5]+aVerbas[nX,6]+aVerbas[nX,7]+aVerbas[nX,10]))
	
	If !SPB->(Eof())

    	If aVerbas[nX,08] > 0  // Contem Saldo ?    	
    	
	    	aItmSPB	:= {}
    	    
			//******************************************************************************
			// Salva os valores dos campos 
			//******************************************************************************
			dbSelectArea("SPB")    	
			For nY := 1  To  FCount()
				aAdd(aItmSPB,SPB->(FieldGet(nY)))
			Next
			
			Begin Transaction
						
			//******************************************************************************
			// Exclui o registro
			//******************************************************************************
            RecLock("SPB",.F.)
				SPB->PB_ZORIG := Upper(FunName())           
				SPB->(dbDelete())
				MsUnlock()
		    
		    		    
			//******************************************************************************
			// Inclui um novo registro com os valores salvos
			//******************************************************************************
			RecLock("SPB",.T.)			
				
				For nY := 1  To  FCount()
					SPB->(FieldPut(nY,aItmSPB[nY]))
				Next                        

				//***************************************************************************
				// Atualiza o saldo de horas(Upper(FunName()))
				//***************************************************************************
				SPB->PB_HORAS := aVerbas[nX,08]				
				SPB->PB_ZORIG := Upper(FunName())				
			MsUnlock()
			
			End Transaction 
			
		Else

	    	If aVerbas[nX,08] == 0  // As horas foram absorvidas
				//***************************************************************************
				// Exclui o registro
				//***************************************************************************
				RecLock("SPB",.F.)
					SPB->PB_ZORIG := Upper(FunName())			
					SPB->(dbDelete())
				MsUnlock()
				
			End If		    
			
		End If
		
	End If
Next

Return Nil
         


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FParamB
Montagem da Tela de Parametro com ParamBox

@protected         
@author 		Luciano M. Pinto
@since 		28/09/2011
@version		P11

/*/
//---------------------------------------------------------------------------------------
Static Function FParamB()
/****************************************************************************************
* Chamada do ParamBox
*
*
*
***/
Local lRetFun	:= .F.

Local aPerg		:= {}

Local cNomPrg	:= "FSPONP01"+AllTrim(xFilial())
		
aadd(aPerg,{1,"Filial De"			,CriaVar("PB_FILIAL"),"@!","" ,"XM0","",20 ,.F.}) 
aadd(aPerg,{1,"Filial Ate"			,CriaVar("PB_FILIAL"),"@!","" ,"XM0","",20 ,.T.})
aadd(aPerg,{1,"Matricula De"		,CriaVar("RA_MAT")	,"@!","" ,"SRA","",30 ,.F.}) 
aadd(aPerg,{1,"Matricula Ate" 	    ,CriaVar("RA_MAT")	,"@!","" ,"SRA","",30 ,.T.})
aadd(aPerg,{1,"Centro Custo De"	    ,CriaVar("CTT_CUSTO"),"@!","" ,"CTT","",40 ,.F.}) 
aadd(aPerg,{1,"Centro Custo Ate"	,CriaVar("CTT_CUSTO"),"@!","" ,"CTT","",40 ,.T.})
aAdd(aPerg,{1,"Data do Calculo De" 	,CriaVar("PB_DATA")	,""  ,"" ,"SPB","",50, .T.})
aAdd(aPerg,{1,"Data do Calculo Ate" ,CriaVar("PB_DATA")	,""  ,"" ,"SPB","",50, .T.}) 

aPerg[01][03] := ParamLoad(cNomPrg,aPerg,01,aPerg[01][03]) 
aPerg[02][03] := ParamLoad(cNomPrg,aPerg,02,aPerg[02][03])   
aPerg[03][03] := ParamLoad(cNomPrg,aPerg,03,aPerg[03][03]) 
aPerg[04][03] := ParamLoad(cNomPrg,aPerg,04,aPerg[04][03])   
aPerg[05][03] := ParamLoad(cNomPrg,aPerg,05,aPerg[05][03]) 
aPerg[06][03] := ParamLoad(cNomPrg,aPerg,06,aPerg[06][03])   
aPerg[07][03] := ParamLoad(cNomPrg,aPerg,07,aPerg[07][03])
aPerg[08][03] := ParamLoad(cNomPrg,aPerg,08,aPerg[08][03]) 

If ParamBox(aPerg,"Parametros",aRetPB,,,,,,,cNomPrg,.T.,.T.) 
	lRetFun := .T.
EndIf

Return(lRetFun) 


