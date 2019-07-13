#include "protheus.ch"

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MA030BUT
Este ponto de entrada pertence à rotina de cadastro de clientes  para a opção “Referências”, MATA030(). 
Ele permite ao usuário adicionar botões à barra no topo da tela.

@author Luciano Mariano
@since 24/06/2010 
@return cPar  Botões adicionais para a tela
@obs

/*/
//---------------------------------------------------------------------------------------
User Function MA030BUT()
/****************************************************************************************
* Chamada do Programa
*
***/
Local aArrBut := {}

// Zera as variaveis estáticas.
U_FClrEnd()
aAdd(aArrBut,{"DBG07",{|| U_FSINTP06()},"Endereço de Cobrança","Endereço de Cobrança"})

Return(aArrBut)
