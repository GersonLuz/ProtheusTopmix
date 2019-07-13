#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} MT410TOK() 
Este ponto de entrada é executado ao clicar no botão 'OK' e pode ser 
usado para validar a confirmação da operação (incluir, alterar, copiar e excluir). 
Se o ponto de entrada retorna .T., o sistema continua a operação, caso contrário, 
retorna a tela do pedido.

@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@return 	lRet	Se igual a verdadeiro continua operação.
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function MT410TOK()
Local lRet	:=	.T.

lRet	:=	U_FSFATP06()

Return lRet