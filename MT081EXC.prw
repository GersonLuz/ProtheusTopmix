#include "protheus.ch"

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} MT081EXC
Ponto de Entrada executado após a exclusão da TES, se parâmertro MV_GERIMPV = 'S'
         
@author 		Cláudio Luiz da Silva
@since 		08/11/2011
@version 	P11
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/ 
//---------------------------------------------------------------------------------------
User Function MT081EXC()

Local aAreOld := {GetArea()}

U_FSPutTab("SF4","E") //Efetua tratamento de integracao com KP

aEval(aAreOld, {|x| RestArea(x) }) 

Return
