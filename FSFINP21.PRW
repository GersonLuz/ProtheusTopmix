#include "Protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINP06
Função chamada pelo ponto de entrada FA60CAN2 para atualização do 
SE1->E1_ZBANCO no estorno do Borderô.

@author Fernando dos Santos Ferreira 
@since 13/03/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFINP21
RecLock("SE1", .F.)
SE1->E1_ZBANCO	:= ""
SE1->(MsUnlock())
Return Nil   


