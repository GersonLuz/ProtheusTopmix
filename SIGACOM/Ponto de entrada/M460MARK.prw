/*/{Protheus.doc} M460MARK
Verifica se a tela de Faturamento poderá prosseguir com a rotina de preparar documentos.
Se houver tipos conflitantes de pedidos selecionados ao mesmo tempo, a rotina não poderá prosseguir.

@Return lRet Se a rotina poderá ou não prosseguir.

@author  Waldir de Oliveira
@since   14/10/2011
/*/
//______________________________________________________________________________________________________________________________________  
User Function M460MARK()
	Local lRet := .T.
	Local nTipo := 0
	
	
	nTipo := U_FTstTipo() //Tipo 1 == pedido normal, tipo 2 == Pedido a ser faturado pelo WS, tipo 3 == misturado
	
	//Não poderá processar se tiver mais de um tipo de nota.
	If(nTipo == 3)
		msgStop('Não é possível faturar estes itens, pois os tipos dos pedidos são conflitantes.')
		lRet := .F.
	ElseIf(nTipo == 2)
		lRet := lRet .And. u_FSVerWS() //Verificando o WS de Numeração de NFs.
	EndIf	
	
	                                                                       
Return lRet