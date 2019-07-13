#INCLUDE "rwmake.ch"
/*
+-----------------------------------------------------------------------+
¦Programa  ¦FCHECP01¦ Autor ¦ Max Rocha              ¦ Data ¦02.03.2012¦
+----------+------------------------------------------------------------¦
¦Descriào  ¦ Checa se foi incluido o endereço de cobrança do cliente    |
+----------+------------------------------------------------------------¦
¦ Uso      ¦ ESPECIFICO                                                 ¦
+-----------------------------------------------------------------------¦
¦           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ¦
+-----------------------------------------------------------------------¦
¦PROGRAMADOR ¦ DATA   ¦ MOTIVO DA ALTERACAO                             ¦
+------------+--------+-------------------------------------------------¦
|            |        |                                                 |
+-----------------------------------------------------------------------+*/
User Function FCHECP01()
Local lRet   := .T.
Local cquery := ""
Local cCodCli := ""
Local cLojCli := ""

cCodCli := M->A1_COD
cLojCli := M->A1_LOJA

cQuery := " SELECT * "
cQuery += " FROM "+retsqlname("P01")
cQuery += " WHERE P01_FILIAL = '"+XFILIAL("SA1")+"'"
cQuery += "       AND P01_COD   = '"+ cCodCli + "' "
cQuery += "       AND P01_LOJA  = '"+ cLojCli + "' "
cQuery += "       AND D_E_L_E_T_      <> '*'"
cQuery := ChangeQuery(cQuery)   
     
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPP01",.T.,.T.)
dbSelectArea("TMPP01")
TMPP01->(DbGotop())
           
 

	If  Empty(Rtrim(TMPP01->P01_COD))
	    MsgBox("Obrigatório inclusão do endereço de cobrança. Verifique em [Ações Relacionadas]->[Endereço de Cobrança]","...ATENÇÃO...","STOP")
	    lRet := .F.
	EndIF
	DBCloseArea("TMPP01")
Return(lRet)