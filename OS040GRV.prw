#include "protheus.ch"
                      

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} OS040GRV
Chamada do Ponto de Entrada Motoristas
         
@author 	Luciano M. Pinto
@since 		23/08/2011
@version 	P11
@obs
Ponto de Entrada utiliza a função FTPOALT.

/*/ 
//---------------------------------------------------------------------------------------
User Function OS040GRV()
/****************************************************************************************
* Chamada do Ponto de Entrada Motoristas
*
***/        

	//************************************************************************************
	//Integração TopMix
	//************************************************************************************ 
	Do Case
		Case PARAMIXB[1] == 3 //Inclusão 
				U_FTpoAlt(7)
		Case PARAMIXB[1] == 4 //Alteração
				U_FTpoAlt(8)
		Case PARAMIXB[1] == 5 //Exlusão
				U_FTpoAlt(9)
	End Case


Return Nil