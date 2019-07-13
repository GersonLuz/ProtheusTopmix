#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} M020ALT() 
Ap�s alterar o registro do Fornecedor, deve ser utilizado para gravar 
arquivos/campos do usu�rio, complementando a altera��o.
   
@author Fernando dos Santos Ferreira 
@since 16/11/2011
@version P11
@obs    
Ponto de entrada utiliza a fun��o FSINTP09 para altera��o de fornecedores.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function M020ALT()                  
// Integra��o Protheus
U_FSINTP09("A",SA2->A2_COD, SA2->A2_LOJA)
Return Nil