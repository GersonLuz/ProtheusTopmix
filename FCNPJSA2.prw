#INCLUDE "rwmake.ch"
#include "protheus.ch"
/*
+-----------------------------------------------------------------------+
¦Programa  ¦FCNPJSA2 ¦ Autor ¦ Max Rocha              ¦ Data ¦17.01.2012¦
+----------+------------------------------------------------------------¦
¦Descriào  ¦ Valida inclusao do fornecedor                              |
+----------+------------------------------------------------------------¦
¦ Uso      ¦ ESPECIFICO                                                 ¦
+-----------------------------------------------------------------------¦
¦           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ¦
+-----------------------------------------------------------------------¦
¦PROGRAMADOR ¦ DATA   ¦ MOTIVO DA ALTERACAO                             ¦
+------------+--------+-------------------------------------------------¦
|            |        |                                                 |
+-----------------------------------------------------------------------+*/
User Function FCNPJSA2()
Local cRaiz  := ""
Local lRet   := .T.
Local cquery := ""
 
cRaiz := left(M->A2_CGC, 8)

cQuery := " SELECT A2_COD"
cQuery += " FROM "+retsqlname("SA2")
cQuery += " WHERE A2_FILIAL = '"+XFILIAL("SA2")+"'"
cQuery += "       AND SUBSTRING(A2_CGC, 1, 8) = '"+ cRAIZ + "' "
cQuery += "       AND D_E_L_E_T_      <> '*'"
cQuery := ChangeQuery(cQuery)   
     
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
dbSelectArea("TMP")
TMP->(DbGotop())
           
 

If ! Empty(Rtrim(TMP->A2_COD))
	IF M->A2_COD <> TMP->A2_COD // max validar se existe os primeiros 8 digitos do campo A2_CGC já gravado, se tiver
	   MsgBox("Já existe a raíz do CNPJ cadastrado. Favor alterar o código  para ["+ TMP->A2_COD +"]","...ATENÇÃO...","STOP")
	      lRet := .F.
		
	EndIF
EndIF	
DbCloseArea("TMP")
Return(lRet)