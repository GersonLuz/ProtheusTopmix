#Include "Protheus.ch"   

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSJOBP03()
Job Responsável para preenchimento da tabela P02 Controle de Remessa X Fatura
          
@author Fernando Ferreira
@since 11/11/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSJOBP03()
Local aAreSm0 		:= {}
Local aRecnoSM0	:= {}

Local cCodEmp		:= ""
Local cCodFil		:= ""

Local	lEmpAutJob	:= .F.

Local nXi			:= 1    

//Controle de semaforo para não ocorrer mais de uma execução do Job ao mesmo tempo.
If !(MSFCreate("FSJOBP03",0) > 0)
   ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
	ConOut("******************************************************************************")
	ConOut("* FSJOBP03 em execucao. Aguarde!															  ")
	ConOut("******************************************************************************")
Else
   ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
	ConOut("******************************************************************************")
	ConOut("* INICIANDO PROCESSO FSJOBP03                        " + DtoC(Date()) + " as " + Time() + "Hrs *")      
	ConOut("* Importacao dos Controle de Faturas X Remessa. FSJOB003		                *")
	ConOut("******************************************************************************")	
	
If (U_FSAbrSM0())
		//Busca somente as empresas
		aRecnoSM0:= U_FSEmpInt(.T.)
		SM0->(dbGoto(aRecnoSM0[1,1]))
		
		
			
			For nI := 1 To Len(aRecnoSM0)
				//Abertura do Ambiente da Empresa
				SM0->(dbGoto(aRecnoSM0[nI,1]))
				 
		
			cCodEmp	:= SM0->M0_CODIGO
			cCodFil	:= SM0->M0_CODFIL
					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Abertura de ambiente                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			aAreSm0 := SM0->(GetArea())			
			RpcSetType(3)			
			RpcSetEnv(cCodEmp, cCodFil,/*USER*/,/*PSW*/)                        									
			nModulo := 12 	   			      
			
	  		lEmpAutJob	:= SuperGetMV("FS_GRPEMP", .T., .F.)
	  		If lEmpAutJob
				ConOut("******************************************************************************")
				ConOut("* Empresa: "+cCodEmp)
				ConOut("* Filial: "+cCodFil)
				ConOut("* Importacao dos Controle de Faturas X Remessa. FSJOB003                      ")
				ConOut("******************************************************************************")
           	Begin Transaction		       		
      		U_FSINTP02()    // importacao de titulos provisorios para o protheus (P02 -> P02010) 20160405
				End Transaction
				U_FSINTP08()  // exclusao dos titulos provisorios no protheus (P02 -> P02010)
			Else
				ConOut("Empresa " + cCodEmp + ". Nao Tem autorizacao para executar o processo. Verifique o parametro FS_GRPEMP.")			
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Fecha ambiente                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		//Restaura o ambiente
				RpcClearEnv()
				
				//Reabre tabela SM0
				If !(lOpen := U_FSAbrSM0())
					Exit
				EndIf
				
		Next nI	
		
	EndIf 
	ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
	ConOut("******************************************************************************")
	ConOut("* FIM PROCESSO FSJOBP03                              " + DtoC(Date()) + " as " + Time() + "Hrs *") 
	ConOut("* Importacao do Controle de Faturas X Remessa         								 *")
	ConOut("******************************************************************************")
EndIf
		
Return Nil   



