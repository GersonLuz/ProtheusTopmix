#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} M020INC() 
Ponto de Entrada para complementar a inclusão no cadastro do Fornecedor.
          
@author Fernando dos Santos Ferreira 
@since 16/11/2011
@version P11
@obs
Ponto de entrada utiliza a função FSINTP09 para inclusão de fornecedores.  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function M020INC() 
// Top Mix função
U_ATA2CTD()

// Integração sistema KP
U_FSINTP09("I",SA2->A2_COD, SA2->A2_LOJA)
Return Nil