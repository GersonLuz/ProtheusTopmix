#include "protheus.ch"

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MA030BUT
Este ponto de entrada pertence � rotina de cadastro de clientes  para a op��o �Refer�ncias�, MATA030(). 
Ele permite ao usu�rio adicionar bot�es � barra no topo da tela.

@author Luciano Mariano
@since 24/06/2010 
@return cPar  Bot�es adicionais para a tela
@obs

/*/
//---------------------------------------------------------------------------------------
User Function MA030BUT()
/****************************************************************************************
* Chamada do Programa
*
***/
Local aArrBut := {}

// Zera as variaveis est�ticas.
U_FClrEnd()
aAdd(aArrBut,{"DBG07",{|| U_FSINTP06()},"Endere�o de Cobran�a","Endere�o de Cobran�a"})

Return(aArrBut)
