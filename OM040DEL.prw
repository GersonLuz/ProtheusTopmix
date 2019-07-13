#include "protheus.ch"


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} OM040DEL
Chamada do Ponto de Entrada na exclus�o Motoristas
         
@author 	Luciano M. Pinto
@since 	23/08/2011
@version P11
@return	lRetFun Verdadeiro permite a exclus�o de motoristas.
@obs
Ponto de Entrada Utiliza a fun��o FSVLDEXC.

/*/ 
//---------------------------------------------------------------------------------------
User Function OM040DEL()
/****************************************************************************************
*
*
***/        
Local lRetFun := .T.

	//************************************************************************************
	//Integra��o TopMix
	//************************************************************************************
	lRetFun := U_FSVldExc("DA4")

Return(lRetFun)