#include "protheus.ch"

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} CT030GRE
Ponto de Entrada executado antes da exclusão do Centro de Custo - Dentro da Transacao
         
@author 		Cláudio Luiz da Silva
@since 		08/11/2011
@version 	P11
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/ 
//---------------------------------------------------------------------------------------
User Function CT030GRE()

Local aAreOld := {GetArea()}

U_FSPutTab("CTT","E") //Efetua tratamento de integracao com KP

aEval(aAreOld, {|x| RestArea(x) }) 

Return
