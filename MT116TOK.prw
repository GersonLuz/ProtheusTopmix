#include "TOTVS.CH"
                   
//------------------------------------------------------------------- 
/*/{Protheus.doc} MT116TOK
Este ponto de entrada pertence a rotina de digitação de conhecimento de frete,
MATA116(). Executado na rotina de validação dos dados do conhecimento, A116TUDOK().
          
@author 	Fernando dos Santos Ferreira 
@since 	13/08/2013
@version P11
@obs  
	
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function MT116TOK()
Local		lReturn		:=.F.   

lReturn	:= U_FSCOMP01() 

If lReturn
	lReturn := U_FlChavCTE()	
EndIf

Return lReturn