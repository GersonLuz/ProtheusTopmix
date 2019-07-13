#include "protheus.ch"

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} CTB030VLD
Ponto de Entrada na validacao de Centro de Custo
         
@author 		Cláudio Luiz da Silva
@since 		08/11/2011
@version 	P11
@return		lRetFun 		Ser resultado for verdadeiro o processo continuará.
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/ 
//---------------------------------------------------------------------------------------
User Function CTB030VLD()

Local aAreOld 	:= {GetArea()}
Local lRetFun 	:= .T.
Local	nOpcMen	:= PARAMIXB

lRetFun:= FIntKp(nOpcMen) //Efetua tratamento de integracao com KP

aEval(aAreOld, {|x| RestArea(x) }) 

Return(lRetFun)


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FIntKP
Efetua tratamento de integracao com KP

@protected
@author 		Cláudio Luiz da Silva
@since 		08/11/2011
/*/ 
//---------------------------------------------------------------------------------------
Static Function FIntKP(nOpcMen)

Local lRet	:= .T.

If nOpcMen==4 //Alteracao
	U_FSChkAlt("CTT") //Salva valores atuais dos campos definidos em array
ElseIf nOpcMen==5 //Exclusao
	lRet:= U_FSVldExc("CTT")
EndIf

Return(lRet)
