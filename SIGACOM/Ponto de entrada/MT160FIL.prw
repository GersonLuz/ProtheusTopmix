#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"

User Function MT160FIL()

Local cAliasSC8 := ParamIxb[1]
Local cFilUser   := ''

cFilUser :=  "C8_FILIAL='"+xFilial("SC8")+"' And "
cFilUser += "C8_NUMPED='"+Space(Len(SC8->C8_NUMPED))+"'" 

Return (cFilUser) 









