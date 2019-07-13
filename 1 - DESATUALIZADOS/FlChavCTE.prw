#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FlChavCTE
Valida��o chave no momento da entrada do CTE/CTR, utilizado
em conjunto com ponto de entrada MT116TOK

@author	  .iNi Sistemas
@since	  16/04/2014
@version  P11.8
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FlChavCTE()
    
	Local lRet:=.F.

	lRet:= FsValChave()
	
Return(lRet)	

//------------------------------------------------------------------- 
/*/{Protheus.doc} FsValChav

Fun��o ser� utilizada para validar se as informa��es da nota informada
batem com as informa��es informadas na chave NFE
ser� validado numero da nota e CNPJ 
          
@author   Helder Santos
@since	  16/04/2014
@version  P11.8
@obs  
Projeto 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------                             
Static Function FsValChave() 		
	
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
	
Local lRet		:= .T.//Variavel retornar .T. ou .F. para fun��o principal
Local CNPJCHV	:= ''//Variavel utilizada para receber CNPJ informado informad na chave
Local CNUNTIT	:= ''//variavel utilizada para receber numero do titulo informado na chave
Local CSERTIT	:= ''//variavel utilizada para receber serie informado na chave
Local cSerAux	:= Replicate("0",3 -Len(AllTrim(CSERIE)))+AllTrim(CSERIE)//variavel recebe tratamento de complemento de caracteres

If !Empty(CNFISCAL)
	If Empty(Alltrim(CESPECIE))//Valida se campo especie, caso campo esteja em branco sistema deve validar
		ApMsgStop(OemToAnsi("Necess�rio preencher esp�cie do documento!"),OemToAnsi("Bloqueio!"))
		Return(.F.)
		//	ElseIf AllTrim(CESPECIE) == "SPED" .Or. AllTrim(CESPECIE) == "CTR" .Or. AllTrim(CESPECIE) == "NFS" .Or. AllTrim(CESPECIE) == "CTE"
	ElseIf AllTrim(CESPECIE) == "SPED" .Or. AllTrim(CESPECIE) == "CTE" // AllTrim(CESPECIE) == "CTR" .Or. (removido, pois n�o possui chave - Jean Santos 22/04/2014)
		
		If Len(aNfeDanfe)> 0//Array contendo informa��es da danfe
			If Empty(aNfeDanfe[13])//Array informa
				//ApMsgStop(OemToAnsi("Para especie SPED/CTR/NFS/CTE � necessario preencher chave NFE"),OemToAnsi("Bloqueio!"))
				ApMsgStop(OemToAnsi("Para esp�cie SPED/CTE � necess�rio preencher chave NFE."),OemToAnsi("Bloqueio!"))
				Return(.F.)
				//Incluido novas valida��es
				//Caso especie seja SPED modelo da chave deve ser 55, caso contrario sistema deve barrar
			ElseIf AllTrim(CESPECIE) == "SPED" .And. SUBSTR(aNfeDanfe[13],21,2) != '55'
				ApMsgStop(OemToAnsi("Chave inv�lida, n�o � permitido utilizar chave diferente do modelo de documento SPED (Modelo 55)."),OemToAnsi("Bloqueio!"))
				Return(.F.)
				//Caso especie seja SPED modelo da chave deve ser 55, caso contrario sistema deve barrar
			ElseIf AllTrim(CESPECIE) $ "CTE" .And. SUBSTR(aNfeDanfe[13],21,2) != '57'
				ApMsgStop(OemToAnsi("Chave inv�lida, n�o � permitido utilizar chave diferente do Modelo de documento CTE (Modelo 57)."),OemToAnsi("Bloqueio!"))
				Return(.F.)
			Else
				CNPJCHV:=SUBSTR(aNfeDanfe[13],7,14)//Recebe CNPJ informado na chave
				CNUNTIT:=SUBSTR(aNfeDanfe[13],26,9)//Recebe numero do titulo informado na chave
				CSERTIT:=SUBSTR(aNfeDanfe[13],23,3)//Recebe serie informado na chave
				//Inicia valida��es de CNPJ e numero do titulo
				If (IF(INCLUI,AllTrim(CTIPO),AllTrim(SF1->F1_TIPO)) $ 'B/D')//Valida se o tipo � Beneficiamento/devolu��o, caso seja deve-se buscar na tabela de clientes (SA1)
					If !AllTrim(Posicione('SA1',1,xFilial("SA1")+CA100FOR + CLOJA,'A1_CGC'))==CNPJCHV//valida retorno do CNPJ com CNPJ da chave
						//ApMsgStop(OemToAnsi("Chave inv�lida, CNPJ informado na chave n�o consiste com CNPJ do cliente."),OemToAnsi("Bloqueio!"))
						//lRet:=.F.
					EndIf
				Else
					//Caso nao seja, deve-se buscar na tabela de fornecedores (SA2)
					If !AllTrim(Posicione('SA2',1,xFilial("SA2")+CA100FOR + CLOJA,'A2_CGC'))==CNPJCHV
						ApMsgStop(OemToAnsi("Chave inv�lida, CNPJ informado na chave n�o consiste com CNPJ do fornecedor."),OemToAnsi("Bloqueio!"))
						lRet:=.F.
					EndIf
				EndIf
				//Se passou pela valida��o do CNPJ entao deve-se validar numero do titulo confere com o titulo informado no cabe�alho
				If lRet
					//If (CNFISCAL + cSerAux) != (CNUNTIT+CSERTIT)//valida numero+serie informado no cabe�alho com numero+serie da chave
					If (CNFISCAL) != (CNUNTIT)//valida numero+serie informado no cabe�alho com numero+serie da chave
						ApMsgStop(OemToAnsi("Chave inv�lida, n�mero da nota incompat�vel com n�mero da chave."),OemToAnsi("Bloqueio!"))
						lRet:=.F.
					ElseIf (cSerAux) != (CSERTIT)
						ApMsgStop(OemToAnsi("Chave inv�lida, n�mero de s�rie incompat�vel com s�rie da chave."),OemToAnsi("Bloqueio!"))
						lRet:=.F.
					EndIF
				EndIf
			EndIf
		Endif//Fim valida�ao array > 0
	EndIf	
EndIf					                              		
	
Return(lRet)