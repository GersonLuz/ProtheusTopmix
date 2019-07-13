#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} MA040DIN 
Na TudOK (validação da digitação) na inclusão e alteração de vendedores 
quando a validação do sistema for igual a .T. .
       
@author Fernando dos Santos Ferreira 
@since 16/11/2011
@version P11
@obs  
Ponto de entrada utiliza a função FSINTP10 para validar a inclusão e alteração 
dos vendedores.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function MA040DIN()

U_FSINTP10("I", SA3->A3_COD)

Return Nil