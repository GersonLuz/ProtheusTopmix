//Visualiza a solicitação de compras
//16JAN2015
//Alecio

***********************************
User Function AFATP22(pTipo)       
***********************************

Local cEmpSC := "" 
Local cFilSC := "" 
Local cNumSC := "" 

If pTipo = "2" 
	cEmpSC := axWBrowse1[oxWBrowse1:nAt,02]
	cFilSC := axWBrowse1[oxWBrowse1:nAt,08]
	cNumSC := axWBrowse1[oxWBrowse1:nAt,03]
Else                                                       
	cEmpSC := aWBrowse1[oWBrowse1:nAt,03]
	cFilSC := aWBrowse1[oWBrowse1:nAt,14]
	cNumSC := aWBrowse1[oWBrowse1:nAt,06]
EndIf
	
dbSelectArea("SC1")
dbSeek(cFilSC + cNumSC)

U_AFATP01('SC1',0,2)

Return