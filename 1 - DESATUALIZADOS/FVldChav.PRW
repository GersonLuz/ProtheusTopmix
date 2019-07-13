#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FVldChav
Função valida Chave
Utilizando em conjunto com ponto de entrada MT100TOK

@author	  .iNi Sistemas
@since	  16/03/2014
@version  P11.8
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FVldChav()
	
	Local lOk:= .F.
	
	lOk:=FsValChav()
		
Return(lOk)		

//-------------------------------------------------------------------
/*/{Protheus.doc} FsValChav

Função será utilizada para validar se as informações da nota informada
batem com as informações informadas na chave NFE
será validado numero da nota, serie e CNPJ

@author 	Helder Santos
@since 		16/04/2014
@version 	P11
@obs
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data		Programador		Motivo
/*/
Static Function FsValChav()
	/***Posições da Chave****************
	*02 - Codigo da Uf
	*04 - AAMM da emissão
	*14 - CNPJ do emitente
	*02 - Modelo
	*03 - Serie
	*09 - Numero da NF-e
	*09 - Codigo numerico
	*01 - DV 
	* Total de 44 caracteres
	*************************************/
   Local cSerTMP := IIf(FunName() $ "MATA920", c920Serie  , cSerie )
   Local cForTMP := IIf(FunName() $ "MATA920", "N"        , cFormul )
   Local cEspTMP := IIf(FunName() $ "MATA920", c920Especi , CESPECIE )
   
	Local lRet	  := .T. //Variavel retornar .T. ou .F. para função principal
	Local CNPJCHV := "" //Variavel utilizada para receber CNPJ informado informado na chave
	Local CNUNTIT := "" //variavel utilizada para receber numero do titulo informado na chave
	Local CSERTIT := "" //variavel utilizada para receber serie informado na chave
	Local cSerAux := Replicate("0",3 - Len(AllTrim(cSerTMP))) + AllTrim(cSerTMP) //variavel recebe tratamento de complemento de caracteres
	
	//If !Empty(CNFISCAL)
		IF AllTrim(cForTmp) <>  'S'//Variavel private acionada no fonte padrão - Helder Santos
		   
		   If Empty(AllTrim(cEspTMP)) //Valida se campo especie, caso campo esteja em branco sistema deve validar
			   ApMsgStop(OemToAnsi("Necessário preencher espécie do documento!"),OemToAnsi("Bloqueio!"))
			   Return(.F.)
		      //ElseIf AllTrim(cEspTMP) == "SPED" .Or. AllTrim(cEspTMP) == "CTR" .Or. AllTrim(cEspTMP) == "NFS" .Or. AllTrim(cEspTMP) == "CTE"
	 	   ElseIf AllTrim(cEspTMP) == "SPED" .Or. AllTrim(cEspTMP) == "CTE" // AllTrim(cEspTMP) == "CTR" .Or. (removido, pois não possui chave - Jean Santos 22/04/2014)
			
			If Len(aNfeDanfe)> 0 //Array contendo informações da danfe
				If Empty(aNfeDanfe[13]) //Array informa 
					//ApMsgStop(OemToAnsi("Para especie SPED/CTE é necessario preencher chave NFE"),OemToAnsi("Bloqueio!"))
					ApMsgStop(OemToAnsi("Para espécie SPED/CTE é necessário preencher chave NFE."),OemToAnsi("Bloqueio!"))
					Return(.F.)
				//Incluido novas validações
				//Caso especie seja SPED modelo da chave deve ser 55, caso contrario sistema deve barrar
		        ElseIf AllTrim(cEspTMP) == "SPED" .And. SubStr(aNfeDanfe[13],21,2) != "55"
		        	ApMsgStop(OemToAnsi("Chave inválida, não é permitido utilizar chave diferente do Modelo de documento SPED (Modelo 55)."),OemToAnsi("Bloqueio!"))
					Return(.F.)
				//Caso especie seja SPED modelo da chave deve ser 55, caso contrario sistema deve barrar
		        ElseIf AllTrim(cEspTMP) $ "CTE" .And. SubStr(aNfeDanfe[13],21,2) != "57"
		        	ApMsgStop(OemToAnsi("Chave inválida, não é permitido utilizar chave diferente do Modelo de documento CTE (Modelo 57)."),OemToAnsi("Bloqueio!"))
					Return(.F.)
		        Else
		        	CNPJCHV := SubStr(aNfeDanfe[13],7,14) //Recebe CNPJ informado na chave
		        	CNUNTIT := SubStr(aNfeDanfe[13],26,9) //Recebe numero do titulo informado na chave
		        	CSERTIT := SubStr(aNfeDanfe[13],23,3) //Recebe serie informado na chave
		            //Inicia validações de CNPJ e numero do titulo
			       	If AllTrim(CTIPO) $ "B/D" //Valida se o tipo é Beneficiamento/devolução, caso seja deve-se buscar na tabela de clientes (SA1)
						If !AllTrim(Posicione("SA1",1,xFilial("SA1") + CA100FOR + CLOJA,"A1_CGC")) == CNPJCHV //valida retorno do CNPJ com CNPJ da chave
							ApMsgStop(OemToAnsi("Chave inválida, CNPJ informado na chave não consiste com CNPJ do cliente."),OemToAnsi("Bloqueio!"))
							lRet := .F.
						EndIf
					Else
						//Caso nao seja, deve-se buscar na tabela de fornecedores (SA2)
						If !AllTrim(Posicione("SA2",1,xFilial("SA2") + CA100FOR + CLOJA,"A2_CGC")) == CNPJCHV
							ApMsgStop(OemToAnsi("Chave inválida, CNPJ informado na chave não consiste com CNPJ do fornecedor."),OemToAnsi("Bloqueio!"))
							lRet := .F.
						EndIf
					EndIf
					//Se passou pela validação do CNPJ entao deve-se validar numero do titulo confere com o titulo informado no cabeçalho
					If lRet
						//If (CNFISCAL + cSerAux) != (CNUNTIT+CSERTIT)//valida numero+serie informado no cabeçalho com numero+serie da chave
						If (CNFISCAL) != (CNUNTIT)//valida numero+serie informado no cabeçalho com numero+serie da chave
							ApMsgStop(OemToAnsi("Chave inválida, número da nota incompatível com número da chave."),OemToAnsi("Bloqueio!"))
							lRet := .F.
						ElseIf (cSerAux) != (CSERTIT)
							ApMsgStop(OemToAnsi("Chave inválida, número de série incompatível com série da chave."),OemToAnsi("Bloqueio!"))
							lRet := .F.
						EndIf
					EndIf
		    	EndIf
			EndIf //Fim validaçao array > 0
		EndIf
	EndIf
Return(lRet)