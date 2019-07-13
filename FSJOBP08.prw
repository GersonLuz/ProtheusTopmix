#Include "Protheus.ch"
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSJobP08

JOB de Importações de Títulos Financeiros provisórios

@author        Fernando Ferreira
@since         14/02/2012
@version       P11
/*/
//---------------------------------------------------------------------------------------
User Function FSJobP08()    

Local aAreSm0 		:= {}
Local aRecnoSM0	:= {}

Local cCodEmp		:= ""
Local cCodFil		:= ""  

Local	lEmpAutJob	:=	.F.  

Local nXi			:= 1    

ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
//Controle de semaforo para não ocorrer mais de uma execução do Job ao mesmo tempo.
If !(MSFCreate("FSJobP08",0) > 0)
	ConOut("******************************************************************************")
	ConOut("* FSJobP08 em execucao. Aguarde!															  ")
	ConOut("******************************************************************************")
Else
	ConOut("******************************************************************************")
	ConOut("* INICIANDO PROCESSO FSJobP08                        " + DtoC(Date()) + " as " + Time() + "Hrs *")      
	ConOut("* Importação de Títulos Provisórios												                *")
	ConOut("******************************************************************************")	
	
	//Abertura do Sigamat e ambientes
	If (U_FSAbrSM0())
		
		dbSelectArea("SM0")    
		dbSetOrder(1)
		While SM0->(!Eof())  
		
			cCodEmp	:= SM0->M0_CODIGO
			cCodFil	:= SM0->M0_CODFIL
					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Abertura de ambiente                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			aAreSm0 := SM0->(GetArea())			
			RpcSetType(3)			
			RpcSetEnv(cCodEmp, cCodFil,,)                        									
			nModulo := 12 	   			      
			
			lEmpAutJob	:= SuperGetMV("FS_GRPEMP", .T., .F.)	

			ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
			If lEmpAutJob
				ConOut("******************************************************************************")
				ConOut("* Empresa: "+cCodEmp)
				ConOut("* Filial: "+cCodFil)
				ConOut("* Processo de Importção de Títulos Provisórios")
				ConOut("******************************************************************************")
				U_FSINTP02()
			Else
				ConOut("Empresa " + SM0->M0_CODIGO + ". Nao Tem autorizacao para executar o processo. Verifique o parametro FS_GRPEMP.")			
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Fecha ambiente                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			RpcClearEnv()
			
			//Reabre tabela SM0
			If !( U_FSAbrSM0() )
				Exit 
			EndIf 
			RestArea(aAreSm0)
			dbSelectArea("SM0")	
			dbSkip()
		EndDo	
		
	EndIf 
   
   ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
	ConOut("******************************************************************************")
	ConOut("* FIM PROCESSO FSJobP08                              " + DtoC(Date()) + " as " + Time() + "Hrs *") 
	ConOut("* Processo de Importação.			                  								 *")
	ConOut("******************************************************************************")
EndIf
		
Return Nil   


