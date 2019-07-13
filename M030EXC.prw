#include "protheus.ch"


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} M030EXC
Chamada do Ponto de Entrada na Exclus�o Clientes
         
@author 	Luciano M. Pinto
@since 		23/08/2011
@version 	P11
@return		lRet	Se retornar verdadeiro permite a exclus�o do cliente. .F. N�o permite a exclus�o.
@obs
Fun��o Utiliza a fun��o FTpoAlt para validar o processode exclus�o de cliente.

/*/ 
//---------------------------------------------------------------------------------------
User Function M030EXC()
/****************************************************************************************
* 
*
***/        
Local		lRet	:=	.T.
//************************************************************************************
//Integra��o TopMix
//************************************************************************************
lRet	:=	U_FTpoAlt(3)

Return lRet


