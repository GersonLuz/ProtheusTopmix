#include "protheus.ch"


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} OM060DEL
Chamada do Ponto de Entrada na exclus�o Veiculos
         
@author 	Luciano M. Pinto
@since 	23/08/2011
@version P11
@return	lRetFun Se verdadeiro permite a exclus�o dos veiculos
@obs
Ponto de Entrada Utiliza a fun��o FSVLDEXC.

/*/ 
//---------------------------------------------------------------------------------------
User Function OM060DEL()
/****************************************************************************************
*
*
***/        
Local lRetFun := .T.

	//************************************************************************************
	//Integra��o TopMix
	//************************************************************************************
	lRetFun := U_FSVldExc("DA3")

Return(lRetFun)