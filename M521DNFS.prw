#Include "Protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} M521DNFS() 
O ponto de entrada M521DNFS existente na função MaDelNfs será disparado 
após o fechamento dos lançamentos contábeis onde o retorno deverá ser 
uma variável lógica. O ponto possui como parâmetro o Array aPedido. 
 
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
Ponto de entrada utiliza a função FSFATP04.
                                                                                                          
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function M521DNFS()
Local lRet	:=	.T.
// Função realiza a atualização do campo FLAGEXC na base de integração.
U_FSFATP04()
Return lRet


