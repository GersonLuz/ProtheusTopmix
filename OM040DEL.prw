#include "protheus.ch"


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} OM040DEL
Chamada do Ponto de Entrada na exclusão Motoristas
         
@author 	Luciano M. Pinto
@since 	23/08/2011
@version P11
@return	lRetFun Verdadeiro permite a exclusão de motoristas.
@obs
Ponto de Entrada Utiliza a função FSVLDEXC.

/*/ 
//---------------------------------------------------------------------------------------
User Function OM040DEL()
/****************************************************************************************
*
*
***/        
Local lRetFun := .T.

	//************************************************************************************
	//Integração TopMix
	//************************************************************************************
	lRetFun := U_FSVldExc("DA4")

Return(lRetFun)