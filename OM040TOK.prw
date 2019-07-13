#include "protheus.ch"
                       

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} OM040TOK
Chamada do Ponto de Entrada na validação Motoristas
         
@author 	Luciano M. Pinto
@since 		26/10/2011
@version 	P11
@return		lRetFun Se Verdadeiro o processo irá continuar
@obs
Ponto de Entrada Utiliza a função FSINTP13.

/*/ 
//---------------------------------------------------------------------------------------
User Function OM040TOK()
/****************************************************************************************
*
*
***/        
Local lRetFun := .T.

	//************************************************************************************
	//Integração TopMix
	//************************************************************************************
	If ALTERA
		U_FSINTP13("DA4")
	End If

Return(lRetFun)