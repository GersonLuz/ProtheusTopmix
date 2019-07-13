#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} MA040DIN 
Na TudOK (valida��o da digita��o) na inclus�o e altera��o de vendedores 
quando a valida��o do sistema for igual a .T. .
       
@author Fernando dos Santos Ferreira 
@since 16/11/2011
@version P11
@obs  
Ponto de entrada utiliza a fun��o FSINTP10 para validar a inclus�o e altera��o 
dos vendedores.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function MA040DIN()

U_FSINTP10("I", SA3->A3_COD)

Return Nil