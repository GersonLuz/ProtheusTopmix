#include "protheus.ch"


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSPONE01 
Rotina de Ecapsulamento da Rotina PONM040 - Integracao com a Folha 
         
@author	Luciano M. Pinto
@since 	02/09/2011
@version	P11

/*/ 
//---------------------------------------------------------------------------------------
User Function FSPONE01()
/****************************************************************************************
* Chamada inicial da Funcao
*
*
***/ 
Local cEndLin := Chr(13) + Chr(10)

If MsgYesNo("Verifique os parametros da rotina antes de executa-la, esse processamento " +;
			"nao podera ser desfeito! " + cEndLin +;
			"A rotina customizada [Calculo Compensacao] ja foi executada ?" ,"Ao usuario..") 

	//***********************************************************************************
	// Chamada da Rotina Padrao
	//***********************************************************************************
	PONM040()				

End If         

Return Nil  
