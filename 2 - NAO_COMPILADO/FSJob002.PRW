#Include "Protheus.ch"
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSJob001

JOB de Importações de Pedidos de Remessa
                                             
@author        Fernando Ferreira
@since         07/11/2011
@version       P11
@Observacao

FSJob001()  JOB de Importações de Pedidos de Remessa (FSINTP08,FSINTP03,FSINTP07)
FSJOBP02()	Integracao da Posicao do Cliente
FSJOBP03()	Job Responsável para preenchimento da tabela P02 Controle de Remessa X Fatura (FSINTP08)
FSJOBP04()	Integracao Manual de Apuracao do Custo Medio
FSJOBP05()	Envio de cotação (formação de precos)
FSJOBP06()	Importaçao de Movimentação de produção
FSJobP07()  JOB de Importações de Pedidos de Remessa
FSJobP08()  JOB de Importações de Títulos Financeiros provisórios
FSJOBP10()  Atualização do preço de venda das tabelas de preços
FSJOBP11()	Job de amarração entre as notas de faturas e notas de remessa

FSINTP01()	Visualiza os erros gerados na integração KP
FSINTP02()	Importação titulos provisorios.
FSINTP03()	Processo de Importação de Pedidos de Remessa da BetonMix.
FSINTP04() 	Grava a chave da NF-e no cabeçalho da nota gerada e na tabela de livros fiscais (SFT)
FSINTP05()	Processa a integração do cadastro de produtos do Protheus com o KP.
FSINTP06()	Tela de Cadastro de Endereços de Cobrança do Cliente
FSINTP07()	Função inclui pedidos de vendas de faturameno da base integração do KP
FSINTP08()	Processo que realiza importação das informações dos titulos provisórios que serão excluidos
FSINTP09()	Processo de cadastro de Fornecedores integração KP
FSINTP10()	Processo de cadastro de Vendedores integração KP
FSINTP11()	Processo que valida os endereços se ele pode ser excluido.
FSINTP12()	Processo de exclusão Endereços relacionados ao cliente
FSINTP13()	Salvar os valores dos campos para verificar se houve alteração para gravar na base intermediaria
FSINTP17()	integração dos registros {"SA1","SA2","SA3","SB1","SF4","CTT","DA3","DA4","P01"} 
FSINTP18()	Atribui o numero da nota e a serie para notas tipo remessa
/*/
//---------------------------------------------------------------------------------------
User Function FSJob002()    

Local aAreSm0 		:= {}
Local aRecnoSM0	:= {}

Local cCodEmp		:= ""
Local cCodFil		:= ""

Local	lEmpAutJob	:= .F.

Local nXi			:= 1    

//Controle de semaforo para não ocorrer mais de uma execução do Job ao mesmo tempo.
If !(MSFCreate("FSJOB001",0) > 0)
	ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
	ConOut("******************************************************************************")
	ConOut("* FSJOB001 em execucao. Aguarde!															  ")
	ConOut("******************************************************************************")
Else
	ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
	ConOut("******************************************************************************")
	ConOut("* INICIANDO PROCESSO FSJOB001                        " + DtoC(Date()) + " as " + Time() + "Hrs *")      
	ConOut("* Importacao de Pedidos de Remessa e Fatura						                *")
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

				ConOut("******************************************************************************")
				ConOut("* Abrindo empresa/Filial: "+cCodEmp+"/"+cCodFil)
				ConOut("******************************************************************************")
										
				RpcSetType(3) //Não consumir licença
				RpcSetEnv(cCodEmp, cCodFil)
	
				If (Emprok(cCodEmp + cCodFil))  // Valida se a empresa está liberada pela Totvs
				
					lEmpAutJob	:= SuperGetMV("FS_GRPEMP", .T., .F.)

					If lEmpAutJob			

					  // Premissa: Rodar primeiro o FSINTP08() para depois rodar o FSINTP03(), pois no ato do faturamento
					  // devera existir os dados na tabela P02 para excluir os titulos provisorios. Em muitos casos os 
					  // titulos permaneciam no SE1, pois faltava rodar primeiro o FSINTP08.
					  // incluido para gerar os dados da P02 em 30/03/2015. - Rodrigo Carvalho

				      ConOut("******************************************************************************")
       			   	ConOut("* Empresa: "+cCodEmp)
		       		ConOut("* Filial: "+cCodFil)
      				ConOut("* Importacao dos Controle de Faturas X Remessa. FSJOB001")
		       		ConOut("******************************************************************************")
                	//Begin Transaction		       		
		       		//U_FSINTP02()    // importacao de titulos provisorios para o protheus (P02 -> P02010) 20160405  *****cristiano
    					//End Transaction
                   //	Begin Transaction		       		
      			   //	U_FSINTP08()  // exclusao de titulos provisorios para o protheus (P02 -> P02010)      ******cristiano
    					//End Transaction
    					
						//ConOut("******************************************************************************")
						//ConOut("* Empresa: "+cCodEmp)
					   //ConOut("* Filial: "+cCodFil)
						//ConOut("* Importacao de Pedidos de Remessa")
					   //	ConOut("******************************************************************************")
					   //	Begin Transaction
					  	   //	U_FSINTP03()     
					  	//End Transaction
						
						ConOut("******************************************************************************")
						ConOut("* Empresa: "+cCodEmp)
						ConOut("* Filial: "+cCodFil)
						ConOut("* Importacao de Pedidos de Fatura")
						ConOut("******************************************************************************")
						Begin Transaction
							U_FSINTP07()     
						End Transaction
						ConOut("************************FIM****************************************")
					Else
						ConOut("Empresa " + cCodEmp + ". Nao Tem autorizacao para executar o processo. Verifique o parametro FS_GRPEMP.")			
					EndIf
				EndIF
	
				//Restaura o ambiente
			   //	RpcClearEnv()
			
				//Reabre tabela SM0
				If !(lOpen := U_FSAbrSM0())
					Exit 
				EndIf 
	
			Next nI

		EndIf
	EndIf 
	
	ConOut("******************************************************************************")
	ConOut("* FIM PROCESSO FSJOB001                              " + DtoC(Date()) + " as " + Time() + "Hrs *") 
	ConOut("* Importacao de Pedidos de Remessa                  								 *")
	ConOut("******************************************************************************")
	
EndIf
		
Return Nil   


