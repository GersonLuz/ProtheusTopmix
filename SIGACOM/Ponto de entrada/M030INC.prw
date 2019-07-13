#include "protheus.ch"


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} M030Inc
Chamada do Ponto de Entrada Clientes
         
@author 	Luciano M. Pinto
@since 		23/08/2011
@version 	P11
@obs
Ponto de Entrada Utiliza a fun��o FTPOALT.

/*/ 
//---------------------------------------------------------------------------------------
User Function M030Inc()
/****************************************************************************************
* 
*
***/      
If PARAMIXB == 3	
   //Alert("usu�rio cancelou inclus�o")
   Return 
EndIf	

U_FTpoAlt(1)
//************************************************************************************
//Fun��o Interna Top Mix
//************************************************************************************
U_ATUCTD()
                    
Return Nil