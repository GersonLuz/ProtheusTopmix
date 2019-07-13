//______________________________________________________________________________________________________________________________________             
/*/{Protheus.doc} M410PVNF
Ponto de Entrada chamado ao preparar documento de saída pelo pedido de venda

Obs. Se o pedido for do tipo cuja numeração da nota vem do KP então eu verifico se o WS está no ar, caso contrário aborto o processo

@author  Waldir de Oliveira
@since   14/10/2011
/*/
//______________________________________________________________________________________________________________________________________     
User Function M410PVNF()
	Local lRet := .T.
	
	If(Empty(SC5->C5_ZORIGEM)  .And. SC5->C5_ZTIPO <> '2') //Verificando se participa do processo que deve consultar o Ws de Numeração.
		lRet := lRet .And. U_FSVerWS() //Verificando o WS de Numeração de NFs.
	EndIf
	
Return lRet