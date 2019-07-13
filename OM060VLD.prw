#include "protheus.ch"
                       

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} OM060VLD
Chamada do Ponto de Entrada na validação Veiculos
         
@author 	Luciano M. Pinto
@since 		23/08/2011
@version 	P11
@return		lRetFun Se for verdadeiro o processo irá continuar.
@obs
Ponto de Entrada Utiliza a função FSINTP13.

/*/ 
//---------------------------------------------------------------------------------------
User Function OM060VLD()
/****************************************************************************************
*
*
***/ 
Local lRetFun := .T.

	//************************************************************************************
	//Integração TopMix
	//************************************************************************************
	If ALTERA
		U_FSINTP13("DA3")
	End If
   
Return(lRetFun)