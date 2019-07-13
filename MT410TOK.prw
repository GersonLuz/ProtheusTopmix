#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} MT410TOK() 
Este ponto de entrada � executado ao clicar no bot�o 'OK' e pode ser 
usado para validar a confirma��o da opera��o (incluir, alterar, copiar e excluir). 
Se o ponto de entrada retorna .T., o sistema continua a opera��o, caso contr�rio, 
retorna a tela do pedido.

@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@return 	lRet	Se igual a verdadeiro continua opera��o.
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function MT410TOK()
Local lRet	:=	.T.

lRet	:=	U_FSFATP06()

Return lRet