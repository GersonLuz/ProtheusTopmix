#include "protheus.ch"

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} MA080VLD
Ponto de Entrada na validacao de TES
         
@author 		Cláudio Luiz da Silva
@since 		08/11/2011
@version 	P11
@return		lRetFun 		Valida processo
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/ 
//---------------------------------------------------------------------------------------
User Function MA080VLD()

Local aAreOld := {GetArea()}
Local lRetFun 	:= .T.

lRetFun:= FIntKp() //Efetua tratamento de integracao com KP

aEval(aAreOld, {|x| RestArea(x) }) 

Return(lRetFun)


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FIntKP
Efetua tratamento de integracao com KP

@protect         
@author 		Cláudio Luiz da Silva
@since 		08/11/2011
/*/ 
//---------------------------------------------------------------------------------------
Static Function FIntKP()

Local lRet	:= .T.

If ALTERA //Alteracao
	U_FSChkAlt("SF4") //Salva valores atuais dos campos definidos em array
ElseIf !ALTERA .And. !INCLUI //Exclusao
	lRet:= U_FSVldExc("SF4")
EndIf

Return(lRet)
