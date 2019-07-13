#include "protheus.ch"

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} CT030GRA
Ponto de Entrada apos gravacao de alteracao dos dados do Centro de Custo
         
@author 		Cláudio Luiz da Silva
@since 		08/11/2011
@version 	P11
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/ 
//---------------------------------------------------------------------------------------
User Function CT030GRA()

Local aAreOld := {GetArea()}

FIntKp() //Efetua tratamento de integracao com KP

aEval(aAreOld, {|x| RestArea(x) }) 

Return


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FIntKP
Efetua tratamento de integracao com KP

@protected
@author 		Cláudio Luiz da Silva
@since 		08/11/2011
/*/ 
//---------------------------------------------------------------------------------------
Static Function FIntKP

If U_FSVldAlt("CTT")  //Verifica se houve alteração nos campos
	U_FSPutTab("CTT","A")
End If

Return
