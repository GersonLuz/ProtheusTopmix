#include "protheus.ch"

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} CT030GRI
Ponto de Entrada apos gravacao de inclusao dos dados do Centro de Custo
         
@author 		Cláudio Luiz da Silva
@since 		08/11/2011
@version 	P11
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/ 
//---------------------------------------------------------------------------------------
User Function CT030GRI()

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
Static Function FIntKP()

If U_FSPutTab("CTT","I")
	Reclock("CTT",.F.)
	CTT->CTT_ZFLAG	:= '*'
	MsUnlock()
EndIf

Return
