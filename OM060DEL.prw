#include "protheus.ch"


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} OM060DEL
Chamada do Ponto de Entrada na exclusão Veiculos
         
@author 	Luciano M. Pinto
@since 	23/08/2011
@version P11
@return	lRetFun Se verdadeiro permite a exclusão dos veiculos
@obs
Ponto de Entrada Utiliza a função FSVLDEXC.

/*/ 
//---------------------------------------------------------------------------------------
User Function OM060DEL()
/****************************************************************************************
*
*
***/        
Local lRetFun := .T.

	//************************************************************************************
	//Integração TopMix
	//************************************************************************************
	lRetFun := U_FSVldExc("DA3")

Return(lRetFun)