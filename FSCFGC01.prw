#Include "Protheus.ch"
#Include "Rwmake.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSCFGC01
Rotina Cadastro de Aplica��o
          
@author 	.iNi Sistemas (HS)
@since 		09/08/2014
@version 	P11.5
@obs  
Projeto 	2014002TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 

User Function FSCFGC01()

	Local cTela	:= OemToAnsi('Tela Cadastro de Aplica��o')
   
	P09->(dbsetorder(01))	
	AxCadastro("P09",cTela,,"U_FsValOk()")

Return(Nil)              
//------------------------------------------------------------------- 
/*/{Protheus.doc} FsValOk
Fun��o valida OK
          
@author 	.iNi Sistemas (HS)
@since 		09/08/2014
@version 	P11.5
@obs  
Projeto 	2014002TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FsValOk()

	Local lcodApli	:= .T.

	If Inclui
		P09->(dbSetOrder(01))
		If !P09->(dbseek(xFilial('P09')+M->P09_CODAPL))
			If U_FSXVlApE(M->P09_CODAPL)
				SLEEP(500)
				If U_FSXVlApE(M->P09_CODAPL)
					SLEEP(1000)
					/* Incluir Rotina para gravar informa��es na empresa X*/	
					lcodApli:=U_FSIMPC03() 
			    Else
			    	lcodApli:=.F.
				EndIf
		    Else
		    	lcodApli:=.F.
		    EndIf
		Else
			MsgAlert(OemToAnsi('C�digo de aplica��o j� existente, favor informar outro c�digo!!'))
			lcodApli:=.F.
		Endif			
	Endif

Return(lcodApli)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSEQP09
Busca sequencial de Aplica��o
          
@author 	.iNi Sistemas (HS)
@since 		09/08/2014
@version 	P11.5
@obs  
Projeto 	2014002TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 

User Function FSEQP09(cTabela,cCampo)

	Local aArea	 := GetArea()//IR//
	Local cQuery := ""
	Local cCod	 := ""//IR//
	
	If (Select("INDEX")!= 0)
		dbSelectArea("INDEX")
		dbCloseArea()
		If File("INDEX"+GetDBExtension())
			FErase("INDEX"+GetDBExtension())
		EndIf
	EndIf

	cQuery := " SELECT MAX( " +ALLTRIM(CCAMPO)+") CAMPO FROM " + RetSqlName(ALLTRIM(cTabela))
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"INDEX",.F.,.F.)   
	DBSelectArea("INDEX")

	cCod:= StrZero((Val(AllTrim(INDEX->CAMPO))+1),(TamSx3(ALLTRIM(CCAMPO))[1]))

    Do While !MayIUseCode(cCod)                     
		cCod := StrZero((Val(AllTrim(cCod))+1),(TamSx3(ALLTRIM(CCAMPO))[1]))
    Enddo      

	RestArea(aArea)
	
Return(cCod)   