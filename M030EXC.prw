#include "protheus.ch"


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} M030EXC
Chamada do Ponto de Entrada na Exclusão Clientes
         
@author 	Luciano M. Pinto
@since 		23/08/2011
@version 	P11
@return		lRet	Se retornar verdadeiro permite a exclusão do cliente. .F. Não permite a exclusão.
@obs
Função Utiliza a função FTpoAlt para validar o processode exclusão de cliente.

/*/ 
//---------------------------------------------------------------------------------------
User Function M030EXC()
/****************************************************************************************
* 
*
***/        
Local		lRet	:=	.T.
//************************************************************************************
//Integração TopMix
//************************************************************************************
lRet	:=	U_FTpoAlt(3)

Return lRet


