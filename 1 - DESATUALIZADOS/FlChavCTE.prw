#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FlChavCTE
Validação chave no momento da entrada do CTE/CTR, utilizado
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

Função será utilizada para validar se as informações da nota informada
batem com as informações informadas na chave NFE
será validado numero da nota e CNPJ 
          
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
	
Local lRet		:= .T.//Variavel retornar .T. ou .F. para função principal
Local CNPJCHV	:= ''//Variavel utilizada para receber CNPJ informado informad na chave
Local CNUNTIT	:= ''//variavel utilizada para receber numero do titulo informado na chave
Local CSERTIT	:= ''//variavel utilizada para receber serie informado na chave
Local cSerAux	:= Replicate("0",3 -Len(AllTrim(CSERIE)))+AllTrim(CSERIE)//variavel recebe tratamento de complemento de caracteres

If !Empty(CNFISCAL)
	If Empty(Alltrim(CESPECIE))//Valida se campo especie, caso campo esteja em branco sistema deve validar
		ApMsgStop(OemToAnsi("Necessário preencher espécie do documento!"),OemToAnsi("Bloqueio!"))
		Return(.F.)
		//	ElseIf AllTrim(CESPECIE) == "SPED" .Or. AllTrim(CESPECIE) == "CTR" .Or. AllTrim(CESPECIE) == "NFS" .Or. AllTrim(CESPECIE) == "CTE"
	ElseIf AllTrim(CESPECIE) == "SPED" .Or. AllTrim(CESPECIE) == "CTE" // AllTrim(CESPECIE) == "CTR" .Or. (removido, pois não possui chave - Jean Santos 22/04/2014)
		
		If Len(aNfeDanfe)> 0//Array contendo informações da danfe
			If Empty(aNfeDanfe[13])//Array informa
				//ApMsgStop(OemToAnsi("Para especie SPED/CTR/NFS/CTE é necessario preencher chave NFE"),OemToAnsi("Bloqueio!"))
				ApMsgStop(OemToAnsi("Para espécie SPED/CTE é necessário preencher chave NFE."),OemToAnsi("Bloqueio!"))
				Return(.F.)
				//Incluido novas validações
				//Caso especie seja SPED modelo da chave deve ser 55, caso contrario sistema deve barrar
			ElseIf AllTrim(CESPECIE) == "SPED" .And. SUBSTR(aNfeDanfe[13],21,2) != '55'
				ApMsgStop(OemToAnsi("Chave inválida, não é permitido utilizar chave diferente do modelo de documento SPED (Modelo 55)."),OemToAnsi("Bloqueio!"))
				Return(.F.)
				//Caso especie seja SPED modelo da chave deve ser 55, caso contrario sistema deve barrar
			ElseIf AllTrim(CESPECIE) $ "CTE" .And. SUBSTR(aNfeDanfe[13],21,2) != '57'
				ApMsgStop(OemToAnsi("Chave inválida, não é permitido utilizar chave diferente do Modelo de documento CTE (Modelo 57)."),OemToAnsi("Bloqueio!"))
				Return(.F.)
			Else
				CNPJCHV:=SUBSTR(aNfeDanfe[13],7,14)//Recebe CNPJ informado na chave
				CNUNTIT:=SUBSTR(aNfeDanfe[13],26,9)//Recebe numero do titulo informado na chave
				CSERTIT:=SUBSTR(aNfeDanfe[13],23,3)//Recebe serie informado na chave
				//Inicia validações de CNPJ e numero do titulo
				If (IF(INCLUI,AllTrim(CTIPO),AllTrim(SF1->F1_TIPO)) $ 'B/D')//Valida se o tipo é Beneficiamento/devolução, caso seja deve-se buscar na tabela de clientes (SA1)
					If !AllTrim(Posicione('SA1',1,xFilial("SA1")+CA100FOR + CLOJA,'A1_CGC'))==CNPJCHV//valida retorno do CNPJ com CNPJ da chave
						//ApMsgStop(OemToAnsi("Chave inválida, CNPJ informado na chave não consiste com CNPJ do cliente."),OemToAnsi("Bloqueio!"))
						//lRet:=.F.
					EndIf
				Else
					//Caso nao seja, deve-se buscar na tabela de fornecedores (SA2)
					If !AllTrim(Posicione('SA2',1,xFilial("SA2")+CA100FOR + CLOJA,'A2_CGC'))==CNPJCHV
						ApMsgStop(OemToAnsi("Chave inválida, CNPJ informado na chave não consiste com CNPJ do fornecedor."),OemToAnsi("Bloqueio!"))
						lRet:=.F.
					EndIf
				EndIf
				//Se passou pela validação do CNPJ entao deve-se validar numero do titulo confere com o titulo informado no cabeçalho
				If lRet
					//If (CNFISCAL + cSerAux) != (CNUNTIT+CSERTIT)//valida numero+serie informado no cabeçalho com numero+serie da chave
					If (CNFISCAL) != (CNUNTIT)//valida numero+serie informado no cabeçalho com numero+serie da chave
						ApMsgStop(OemToAnsi("Chave inválida, número da nota incompatível com número da chave."),OemToAnsi("Bloqueio!"))
						lRet:=.F.
					ElseIf (cSerAux) != (CSERTIT)
						ApMsgStop(OemToAnsi("Chave inválida, número de série incompatível com série da chave."),OemToAnsi("Bloqueio!"))
						lRet:=.F.
					EndIF
				EndIf
			EndIf
		Endif//Fim validaçao array > 0
	EndIf	
EndIf					                              		
	
Return(lRet)