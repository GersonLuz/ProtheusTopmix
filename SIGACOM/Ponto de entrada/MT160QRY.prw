#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"

User Function MT160QRY

Local cAlias:= PARAMIXB[1]
Local cFilUserQry:= ""// Expressão do filtro na sintaxe SQL

cFilUserQry :=  '  C8_NUM == "019621"   '


Return (cFilUserQry)