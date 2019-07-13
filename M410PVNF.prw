//______________________________________________________________________________________________________________________________________             
/*/{Protheus.doc} M410PVNF
Ponto de Entrada chamado ao preparar documento de sa�da pelo pedido de venda

Obs. Se o pedido for do tipo cuja numera��o da nota vem do KP ent�o eu verifico se o WS est� no ar, caso contr�rio aborto o processo

@author  Waldir de Oliveira
@since   14/10/2011
/*/
//______________________________________________________________________________________________________________________________________     
User Function M410PVNF()
	Local lRet := .T.
	
	If(Empty(SC5->C5_ZORIGEM)  .And. SC5->C5_ZTIPO <> '2') //Verificando se participa do processo que deve consultar o Ws de Numera��o.
		lRet := lRet .And. U_FSVerWS() //Verificando o WS de Numera��o de NFs.
	EndIf
	
Return lRet