#Include "Totvs.ch"
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSJOBP11

Job de amarração entre as notas de faturas e notas de remessa

@author        Fernando Ferreira
@since         26/03/2013
@version       P11
/*/
//---------------------------------------------------------------------------------------
User Function FSJOBP11()

Local aAreSm0 		:= {}
Local aRecnoSM0	:= {}

Local cCodEmp		:= ""
Local cCodFil		:= ""

Local	lEmpAutJob	:= .F.

Local nXi			:= 1    

//Controle de semaforo para não ocorrer mais de uma execução do Job ao mesmo tempo.
ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
If !(MSFCreate("FSJOBP11",0) > 0)
	ConOut("******************************************************************************")
	ConOut("* FSJOBP11 em execucao. Aguarde!															  ")
	ConOut("******************************************************************************")
Else
	ConOut("******************************************************************************")
	ConOut("* INICIANDO PROCESSO FSJOBP11                        " + DtoC(Date()) + " as " + Time() + "Hrs *")      
	ConOut("* Amarracao entre notas de fatura com notas de remessa			                *")
	ConOut("******************************************************************************")	
	
	//Abertura do Sigamat e ambientes
	If (U_FSAbrSM0())	
		//Busca somente as empresas
		aRecnoSM0:= U_FSEmpInt(.T.)
		SM0->(dbGoto(aRecnoSM0[1,1]))

		If(lOpen := U_FSAbrSM0()	)

  			For nI := 1 To Len(aRecnoSM0)  
  				//Abertura do Ambiente da Empresa
				SM0->(dbGoto(aRecnoSM0[nI,1]))
				
				cCodEmp	:= SM0->M0_CODIGO
				cCodFil	:= SM0->M0_CODFIL
											
				RpcSetType(3) //Não consumir licença
				RpcSetEnv(cCodEmp, cCodFil)
	
				If (Emprok(cCodEmp + cCodFil))  // Valida se a empresa está liberada pela Totvs
					lEmpAutJob	:= SuperGetMV("FS_GRPEMP", .T., .F.)                            
					ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
					If lEmpAutJob			
						ConOut("******************************************************************************")
						ConOut("* Empresa: "+cCodEmp)
						ConOut("* Filial: "+cCodFil)
						ConOut("* Amarracao de notas Remessa X Fatura													  ")
						ConOut("******************************************************************************")
						U_FSFATP07(cCodFil)						
					Else
						ConOut("Empresa " + cCodEmp + ". Nao Tem autorizacao para executar o processo. Verifique o parametro FS_GRPEMP.")			
					EndIf
				EndIF
	
				//Restaura o ambiente
				RpcClearEnv()
			
				//Reabre tabela SM0
				If !(lOpen := U_FSAbrSM0())
					Exit 
				EndIf 
	
			Next nI

		EndIf
	EndIf 
	ConOut("******************************************************************************")
	ConOut("* FIM PROCESSO FSJOBP11                              " + DtoC(Date()) + " as " + Time() + "Hrs *") 
	ConOut("* Fim da atualizacao!!                  								 *")
	ConOut("******************************************************************************")
EndIf
		
Return Nil   


