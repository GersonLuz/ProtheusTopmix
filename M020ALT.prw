#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} M020ALT() 
Após alterar o registro do Fornecedor, deve ser utilizado para gravar 
arquivos/campos do usuário, complementando a alteração.
   
@author Fernando dos Santos Ferreira 
@since 16/11/2011
@version P11
@obs    
Ponto de entrada utiliza a função FSINTP09 para alteração de fornecedores.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function M020ALT()                  
// Integração Protheus
U_FSINTP09("A",SA2->A2_COD, SA2->A2_LOJA)
Return Nil