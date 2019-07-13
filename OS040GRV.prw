#include "protheus.ch"
                      

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} OS040GRV
Chamada do Ponto de Entrada Motoristas
         
@author 	Luciano M. Pinto
@since 		23/08/2011
@version 	P11
@obs
Ponto de Entrada utiliza a fun��o FTPOALT.

/*/ 
//---------------------------------------------------------------------------------------
User Function OS040GRV()
/****************************************************************************************
* Chamada do Ponto de Entrada Motoristas
*
***/        

	//************************************************************************************
	//Integra��o TopMix
	//************************************************************************************ 
	Do Case
		Case PARAMIXB[1] == 3 //Inclus�o 
				U_FTpoAlt(7)
		Case PARAMIXB[1] == 4 //Altera��o
				U_FTpoAlt(8)
		Case PARAMIXB[1] == 5 //Exlus�o
				U_FTpoAlt(9)
	End Case


Return Nil