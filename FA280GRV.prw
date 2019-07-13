#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FA280GRV
O ponto de entrada FA280 � executado durante a grava��o dos dados da 
fatura no SE1. Utilizado para grava��o de dados complementares.

@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
Ponto de Entrada utiliza a fun��o FSFINP02.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FA280GRV(uPar)
U_FSFINP02()                                                                  
Return Nil