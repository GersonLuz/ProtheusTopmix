#include "protheus.ch"

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} MT080GRV
Ponto de Entrada apos gravacao dos dados da TES
         
@author 		Cláudio Luiz da Silva
@since 		08/11/2011
@version 	P11
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/ 
//---------------------------------------------------------------------------------------
User Function MT080GRV()

Local aAreOld := {GetArea()}

FIntKp() //Efetua tratamento de integracao com KP

aEval(aAreOld, {|x| RestArea(x) }) 

Return


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FIntKP
Efetua tratamento de integracao com KP

@protect         
@author 		Cláudio Luiz da Silva
@since 		08/11/2011
@version 	P11
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/ 
//---------------------------------------------------------------------------------------
Static Function FIntKP()

Local lRet	:= .T.
 
If INCLUI              
	If SF4->F4_CODIGO > "500"
		U_FSPutTab("SF4","I")
	EndIf
ElseIf ALTERA //Alteracao
   If U_FSVldAlt("SF4")  //Verifica se houve alteração nos campos
		lRet:= U_FSPutTab("SF4","A")
	End If
EndIf

Return
