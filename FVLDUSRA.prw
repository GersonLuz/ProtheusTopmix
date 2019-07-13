#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldUSRA()
Validação de campos inclusão/alteração de funcionário.

@author	  .iNi Sistemas
@since	  16/03/2014
@version  P11.8
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function fVldUSRA(cNomCmp)

Local lOk 		:= .T. 
Local aArea 	:= GetArea()

If AllTrim(cNomCmp) == "RA_CIC"
	lOk := fVldCIC()
EndIf

If AllTrim(cNomCmp) == "RA_PIS"
	lOk := fVldPIS()
EndIf

If AllTrim(cNomCmp) == "RA_MAE"
	lOk := fVldMAE()
EndIf

RestArea(aArea)

Return(lOk)

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldCIC()
Validação de CPF.

@author	  .iNi Sistemas
@since	  16/03/2014
@version  P11.8
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function fVldCIC()

Local lOk 		:= .T.
Local cQuery 	:= ""                

cQuery := " SELECT RA_MAT "
cQuery += " FROM "+RetSqlName("SRA")
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += " 	AND RA_CIC = '"+M->RA_CIC+"' "
dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),"VLDTMP",.F.,.T.)

If !VLDTMP->(Eof())
 	lOk := MsgYesNo("Encontrado um funcionário cadastrado com o mesmo CPF informado. Deseja autorizar?","Atenção!")
EndIf
VLDTMP->(DbCloseArea())

Return(lOk)

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldPIS()
Validação de PIS.

@author	  .iNi Sistemas
@since	  16/03/2014
@version  P11.8
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function fVldPIS()

Local lOk 		:= .T.
Local cQuery 	:= ""

cQuery := " SELECT RA_MAT "
cQuery += " FROM "+RetSqlName("SRA")
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += " 	AND RA_PIS = '"+M->RA_PIS+"' "
dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),"VLDTMP",.F.,.T.)

If !VLDTMP->(Eof())
 	lOk := MsgYesNo("Encontrado um funcionário cadastrado com o mesmo PIS informado. Deseja autorizar?","Atenção!")
EndIf
VLDTMP->(DbCloseArea())

Return(lOk)

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldMAE()
Validação de PIS.

@author	  .iNi Sistemas
@since	  16/03/2014
@version  P11.8
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function fVldMAE()

Local lOk 		:= .T.
Local cQuery 	:= ""

cQuery := " SELECT RA_MAT "
cQuery += " FROM "+RetSqlName("SRA")
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += " 	AND RA_MAE = '"+M->RA_MAE+"' "
dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),"VLDTMP",.F.,.T.)

If !VLDTMP->(Eof())
	lOk := MsgYesNo("Encontrado um funcionário cadastrado com o mesmo nome de mãe informado. Deseja autorizar?","Atenção!")
EndIf
VLDTMP->(DbCloseArea())

Return(lOk)