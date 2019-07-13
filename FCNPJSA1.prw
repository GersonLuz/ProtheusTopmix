#INCLUDE "rwmake.ch"
/*
+-----------------------------------------------------------------------+
¦Programa  ¦FCNPJSA1 ¦ Autor ¦ Juliana Hilarina       ¦ Data ¦17.01.2012¦
+----------+------------------------------------------------------------¦
¦Descriào  ¦ Valida inclusao do CNPJ de Clientes                        |
+----------+------------------------------------------------------------¦
¦ Uso      ¦ ESPECIFICO                                                 ¦
+-----------------------------------------------------------------------¦
¦           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ¦
+-----------------------------------------------------------------------¦
¦PROGRAMADOR ¦ DATA   ¦ MOTIVO DA ALTERACAO                             ¦
+------------+--------+-------------------------------------------------¦
|            |        |                                                 |
+-----------------------------------------------------------------------+*/
User Function FCNPJSA1()
Local cRaiz  := ""
Local lRet   := .T.
Local cquery := ""
 
cRaiz := left(M->A1_CGC, 8)

cQuery := " SELECT A1_COD"
cQuery += " FROM "+retsqlname("SA1")
cQuery += " WHERE A1_FILIAL = '"+XFILIAL("SA1")+"'"
cQuery += "       AND SUBSTRING(A1_CGC, 1, 8) = '"+ cRAIZ + "' "
cQuery += "       AND D_E_L_E_T_      <> '*'"
cQuery := ChangeQuery(cQuery)   
     
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPSA1",.T.,.T.)
dbSelectArea("TMPSA1")
TMPSA1->(DbGotop())
           
 

If ! Empty(Rtrim(TMPSA1->A1_COD))
		IF M->A1_COD <> TMPSA1->A1_COD // max validar se existe os primeiros 8 digitos do campo A1_CGC já gravado, se tiver
		   MsgBox("Já existe a raíz do CNPJ cadastrado. Favor alterar o código  para ["+ TMPSA1->A1_COD +"]","...ATENÇÃO...","STOP")
		   lRet := .F.
			
		EndIF
EndIF
		DBCloseArea("TMPSA1")
Return(lRet)