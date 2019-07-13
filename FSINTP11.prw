#include "protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSINTP11()
Processo que valida os endereços se ele pode ser excluido.
          
@author Fernando Ferreira
@since 25/10/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSINTP11()

Local 	lRetSa1	:= .T.

lRetSa1 := U_FSVldExc("SA1")	

Return (lRetSa1)


