#include "protheus.ch"


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} M030DEL
Chamada do Ponto de Entrada antes da Exclus�o Clientes
         
@author 	Luciano M. Pinto
@since 		23/08/2011
@version 	P11
@return 		lRetFun Ser verdadeiro permite a exclus�o do cliente.
@obs
Ponto de Entrada utiliza a fun��o FSVLDEXC.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
14/03/2012 Giulliano Santos	Altera��o para validar a integridade com P05 e P06


/*/ 
//---------------------------------------------------------------------------------------
User Function M030DEL()   
/****************************************************************************************
* 
*
***/
Local lRetFun := .T.        

//************************************************************************************
//Integra��o TopMix
//************************************************************************************
lRetFun := U_FSVldExc("SA1") 

//Alterado GS 14/03/2012
If lRetFun 
	lRetFun := U_FSFINP06() 
EndIf
	
Return(lRetFun)                                                