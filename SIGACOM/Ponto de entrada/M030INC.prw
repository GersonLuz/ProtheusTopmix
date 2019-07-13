#include "protheus.ch"


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} M030Inc
Chamada do Ponto de Entrada Clientes
         
@author 	Luciano M. Pinto
@since 		23/08/2011
@version 	P11
@obs
Ponto de Entrada Utiliza a função FTPOALT.

/*/ 
//---------------------------------------------------------------------------------------
User Function M030Inc()
/****************************************************************************************
* 
*
***/      
If PARAMIXB == 3	
   //Alert("usuário cancelou inclusão")
   Return 
EndIf	

U_FTpoAlt(1)
//************************************************************************************
//Função Interna Top Mix
//************************************************************************************
U_ATUCTD()
                    
Return Nil