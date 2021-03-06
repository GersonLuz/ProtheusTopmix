#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FVldChav
Fun��o valida Chave
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

Fun��o ser� utilizada para validar se as informa��es da nota informada
batem com as informa��es informadas na chave NFE
ser� validado numero da nota, serie e CNPJ

@author 	Helder Santos
@since 		16/04/2014
@version 	P11
@obs
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data		Programador		Motivo
/*/
Static Function FsValChav()
	/***Posi��es da Chave****************
	*02 - Codigo da Uf
	*04 - AAMM da emiss�o
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
   
	Local lRet	  := .T. //Variavel retornar .T. ou .F. para fun��o principal
	Local CNPJCHV := "" //Variavel utilizada para receber CNPJ informado informado na chave
	Local CNUNTIT := "" //variavel utilizada para receber numero do titulo informado na chave
	Local CSERTIT := "" //variavel utilizada para receber serie informado na chave
	Local cSerAux := Replicate("0",3 - Len(AllTrim(cSerTMP))) + AllTrim(cSerTMP) //variavel recebe tratamento de complemento de caracteres
	
	//If !Empty(CNFISCAL)
		IF AllTrim(cForTmp) <>  'S'//Variavel private acionada no fonte padr�o - Helder Santos
		   
		   If Empty(AllTrim(cEspTMP)) //Valida se campo especie, caso campo esteja em branco sistema deve validar
			   ApMsgStop(OemToAnsi("Necess�rio preencher esp�cie do documento!"),OemToAnsi("Bloqueio!"))
			   Return(.F.)
		      //ElseIf AllTrim(cEspTMP) == "SPED" .Or. AllTrim(cEspTMP) == "CTR" .Or. AllTrim(cEspTMP) == "NFS" .Or. AllTrim(cEspTMP) == "CTE"
	 	   ElseIf AllTrim(cEspTMP) == "SPED" .Or. AllTrim(cEspTMP) == "CTE" // AllTrim(cEspTMP) == "CTR" .Or. (removido, pois n�o possui chave - Jean Santos 22/04/2014)
			
			If Len(aNfeDanfe)> 0 //Array contendo informa��es da danfe
				If Empty(aNfeDanfe[13]) //Array informa 
					//ApMsgStop(OemToAnsi("Para especie SPED/CTE � necessario preencher chave NFE"),OemToAnsi("Bloqueio!"))
					ApMsgStop(OemToAnsi("Para esp�cie SPED/CTE � necess�rio preencher chave NFE."),OemToAnsi("Bloqueio!"))
					Return(.F.)
				//Incluido novas valida��es
				//Caso especie seja SPED modelo da chave deve ser 55, caso contrario sistema deve barrar
		        ElseIf AllTrim(cEspTMP) == "SPED" .And. SubStr(aNfeDanfe[13],21,2) != "55"
		        	ApMsgStop(OemToAnsi("Chave inv�lida, n�o � permitido utilizar chave diferente do Modelo de documento SPED (Modelo 55)."),OemToAnsi("Bloqueio!"))
					Return(.F.)
				//Caso especie seja SPED modelo da chave deve ser 55, caso contrario sistema deve barrar
		        ElseIf AllTrim(cEspTMP) $ "CTE" .And. SubStr(aNfeDanfe[13],21,2) != "57"
		        	ApMsgStop(OemToAnsi("Chave inv�lida, n�o � permitido utilizar chave diferente do Modelo de documento CTE (Modelo 57)."),OemToAnsi("Bloqueio!"))
					Return(.F.)
		        Else
		        	CNPJCHV := SubStr(aNfeDanfe[13],7,14) //Recebe CNPJ informado na chave
		        	CNUNTIT := SubStr(aNfeDanfe[13],26,9) //Recebe numero do titulo informado na chave
		        	CSERTIT := SubStr(aNfeDanfe[13],23,3) //Recebe serie informado na chave
		            //Inicia valida��es de CNPJ e numero do titulo
			       	If AllTrim(CTIPO) $ "B/D" //Valida se o tipo � Beneficiamento/devolu��o, caso seja deve-se buscar na tabela de clientes (SA1)
						If !AllTrim(Posicione("SA1",1,xFilial("SA1") + CA100FOR + CLOJA,"A1_CGC")) == CNPJCHV //valida retorno do CNPJ com CNPJ da chave
							ApMsgStop(OemToAnsi("Chave inv�lida, CNPJ informado na chave n�o consiste com CNPJ do cliente."),OemToAnsi("Bloqueio!"))
							lRet := .F.
						EndIf
					Else
						//Caso nao seja, deve-se buscar na tabela de fornecedores (SA2)
						If !AllTrim(Posicione("SA2",1,xFilial("SA2") + CA100FOR + CLOJA,"A2_CGC")) == CNPJCHV
							ApMsgStop(OemToAnsi("Chave inv�lida, CNPJ informado na chave n�o consiste com CNPJ do fornecedor."),OemToAnsi("Bloqueio!"))
							lRet := .F.
						EndIf
					EndIf
					//Se passou pela valida��o do CNPJ entao deve-se validar numero do titulo confere com o titulo informado no cabe�alho
					If lRet
						//If (CNFISCAL + cSerAux) != (CNUNTIT+CSERTIT)//valida numero+serie informado no cabe�alho com numero+serie da chave
						If (CNFISCAL) != (CNUNTIT)//valida numero+serie informado no cabe�alho com numero+serie da chave
							ApMsgStop(OemToAnsi("Chave inv�lida, n�mero da nota incompat�vel com n�mero da chave."),OemToAnsi("Bloqueio!"))
							lRet := .F.
						ElseIf (cSerAux) != (CSERTIT)
							ApMsgStop(OemToAnsi("Chave inv�lida, n�mero de s�rie incompat�vel com s�rie da chave."),OemToAnsi("Bloqueio!"))
							lRet := .F.
						EndIf
					EndIf
		    	EndIf
			EndIf //Fim valida�ao array > 0
		EndIf
	EndIf
Return(lRet)