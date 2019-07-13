#Include "Protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} M521DNFS() 
O ponto de entrada M521DNFS existente na fun��o MaDelNfs ser� disparado 
ap�s o fechamento dos lan�amentos cont�beis onde o retorno dever� ser 
uma vari�vel l�gica. O ponto possui como par�metro o Array aPedido. 
 
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
Ponto de entrada utiliza a fun��o FSFATP04.
                                                                                                          
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function M521DNFS()
Local lRet	:=	.T.
// Fun��o realiza a atualiza��o do campo FLAGEXC na base de integra��o.
U_FSFATP04()
Return lRet


