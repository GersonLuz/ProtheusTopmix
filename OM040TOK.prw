#include "protheus.ch"
                       

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} OM040TOK
Chamada do Ponto de Entrada na valida��o Motoristas
         
@author 	Luciano M. Pinto
@since 		26/10/2011
@version 	P11
@return		lRetFun Se Verdadeiro o processo ir� continuar
@obs
Ponto de Entrada Utiliza a fun��o FSINTP13.

/*/ 
//---------------------------------------------------------------------------------------
User Function OM040TOK()
/****************************************************************************************
*
*
***/        
Local lRetFun := .T.

	//************************************************************************************
	//Integra��o TopMix
	//************************************************************************************
	If ALTERA
		U_FSINTP13("DA4")
	End If

Return(lRetFun)