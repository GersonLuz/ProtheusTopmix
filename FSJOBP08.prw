#Include "Protheus.ch"
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSJobP08

JOB de Importa��es de T�tulos Financeiros provis�rios

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
//Controle de semaforo para n�o ocorrer mais de uma execu��o do Job ao mesmo tempo.
If !(MSFCreate("FSJobP08",0) > 0)
	ConOut("******************************************************************************")
	ConOut("* FSJobP08 em execucao. Aguarde!															  ")
	ConOut("******************************************************************************")
Else
	ConOut("******************************************************************************")
	ConOut("* INICIANDO PROCESSO FSJobP08                        " + DtoC(Date()) + " as " + Time() + "Hrs *")      
	ConOut("* Importa��o de T�tulos Provis�rios												                *")
	ConOut("******************************************************************************")	
	
	//Abertura do Sigamat e ambientes
	If (U_FSAbrSM0())
		
		dbSelectArea("SM0")    
		dbSetOrder(1)
		While SM0->(!Eof())  
		
			cCodEmp	:= SM0->M0_CODIGO
			cCodFil	:= SM0->M0_CODFIL
					
			//������������������������������������������������������Ŀ
			//� Abertura de ambiente                                 �
			//��������������������������������������������������������	
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
				ConOut("* Processo de Import��o de T�tulos Provis�rios")
				ConOut("******************************************************************************")
				U_FSINTP02()
			Else
				ConOut("Empresa " + SM0->M0_CODIGO + ". Nao Tem autorizacao para executar o processo. Verifique o parametro FS_GRPEMP.")			
			EndIf

			//������������������������������������������������������Ŀ
			//� Fecha ambiente                                       �
			//��������������������������������������������������������	
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
	ConOut("* Processo de Importa��o.			                  								 *")
	ConOut("******************************************************************************")
EndIf
		
Return Nil   


