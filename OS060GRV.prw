#include "protheus.ch"


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} OS060GRV
Chamada do Ponto de Entrada apos a gravacao dos dados (Veiculos)
         
@author 	Luciano M. Pinto
@since 		26/10/2011
@version 	P11
@return		lRetFun Se verdadeiro o processo de gravação irá continuar.
@obs
Ponto de Entrada utiliza a função FTPOALT.

/*/ 
//---------------------------------------------------------------------------------------
User Function OS060GRV()
/****************************************************************************************
*
*
***/        
Local lRetFun := .T.

	//************************************************************************************
	//Integração TopMix
	//************************************************************************************ 
	Do Case
		Case PARAMIXB[1] == 3 //Inclusão 
			U_FTpoAlt(4)
		Case PARAMIXB[1] == 4 //Alteração
			U_FTpoAlt(5)
		Case PARAMIXB[1] == 5 //Exlusao     
			U_FTpoAlt(6)
   End Case

Return(lRetFun)
