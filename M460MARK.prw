/*/{Protheus.doc} M460MARK
Verifica se a tela de Faturamento poder� prosseguir com a rotina de preparar documentos.
Se houver tipos conflitantes de pedidos selecionados ao mesmo tempo, a rotina n�o poder� prosseguir.

@Return lRet Se a rotina poder� ou n�o prosseguir.

@author  Waldir de Oliveira
@since   14/10/2011
/*/
//______________________________________________________________________________________________________________________________________  
User Function M460MARK()
	Local lRet := .T.
	Local nTipo := 0
	
	
	nTipo := U_FTstTipo() //Tipo 1 == pedido normal, tipo 2 == Pedido a ser faturado pelo WS, tipo 3 == misturado
	
	//N�o poder� processar se tiver mais de um tipo de nota.
	If(nTipo == 3)
		msgStop('N�o � poss�vel faturar estes itens, pois os tipos dos pedidos s�o conflitantes.')
		lRet := .F.
	ElseIf(nTipo == 2)
		lRet := lRet .And. u_FSVerWS() //Verificando o WS de Numera��o de NFs.
	EndIf	
	
	                                                                       
Return lRet