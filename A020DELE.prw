#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} A020DELE() 
Na primeira validação após a confirmação da exclusão, antes de excluir 
o fornecedor, deve ser utilizado para validações adicionais para a 
EXCLUSÃO do fornecedor, para verificar algum arquivo/campo criado pelo
usuário, para validar se o movimento será efetuado ou não.
         
@author Fernando dos Santos Ferreira 
@since 16/11/2011
@version P11
@return lRet se verdadeiro permite a exclusão do fornecedor
@obs  
Ponto de Entrada Utiliza a função FSINTP09 para validação       
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function A020DELE()
Local lRet	:= .T.

lRet	:=	U_FSINTP09("E",SA2->A2_COD, SA2->A2_LOJA)

Return lRet