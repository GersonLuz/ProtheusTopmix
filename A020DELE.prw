#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} A020DELE() 
Na primeira valida��o ap�s a confirma��o da exclus�o, antes de excluir 
o fornecedor, deve ser utilizado para valida��es adicionais para a 
EXCLUS�O do fornecedor, para verificar algum arquivo/campo criado pelo
usu�rio, para validar se o movimento ser� efetuado ou n�o.
         
@author Fernando dos Santos Ferreira 
@since 16/11/2011
@version P11
@return lRet se verdadeiro permite a exclus�o do fornecedor
@obs  
Ponto de Entrada Utiliza a fun��o FSINTP09 para valida��o       
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function A020DELE()
Local lRet	:= .T.

lRet	:=	U_FSINTP09("E",SA2->A2_COD, SA2->A2_LOJA)

Return lRet