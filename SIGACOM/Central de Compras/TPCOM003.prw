#Include "Rwmake.ch"
#Include "TopConn.ch"

/*
+-----------------------------------------------------------------------+
¦Programa  ¦ TPCOM003 ¦ Autor ¦ Cristiano Ferreira    ¦ Data ¦10/05/2018¦
¦----------+------------------------------------------------------------¦
¦Descrição ¦ Função para gerar numeração do pedido de compras por       ¦
¦          ¦ empresa                                                    ¦
¦----------+------------------------------------------------------------¦
¦ Uso      ¦ TopMix                                                     ¦
¦----------+------------------------------------------------------------¦
¦ Técnico  ¦ Data   ¦      Descrição da Alteração                       ¦
¦----------+--------+---------------------------------------------------¦
¦          ¦        ¦                                                   ¦
+-----------------------------------------------------------------------+
*/

User Function TPCOM003()

Local cQuery, cMaxNum, cNumPc
Local nTamFil := TamSX3("C7_FILIAL")[1]

cNumPc := GetSXENum("SC7","C7_NUM",Space(nTamFil)+"\PC01")

//Busca maior numero de pedido da empresa
cQuery := "SELECT MAX(C7_NUM) AS C7NUM "
cQuery += "FROM " + RetSqlName("SC7") + " SC7 "
cQuery += "WHERE SC7.D_E_L_E_T_ = ''"
                                                           
TcQuery cQuery Alias TMP New
DbSelectArea("TMP")
DbGotop()

cMaxNum := TMP->C7NUM

TMP->(DbCloseArea())

//Testa se o número retornado é maior que o GetSXENum. Se for, ajusta o SXE.
If cMaxNum >= cNumPc

	RollBackSXE()

	DbUseArea(.T., __LocalDriver, "SXE", "SXE_PC", .T.,.F.)

	DbSelectArea("SXE_PC")
	DbGoTop()
	While !Eof()
		If RTrim(XE_FILIAL) == Space(nTamFil)+"\PC01"

			RecLock("SXE_PC",.F.)
   	       SXE_PC->XE_NUMERO := cMaxNum
	       MsUnlock()

			Exit

		EndIf

		DbSelectArea("SXE_PC")
		DbSkip()
	End

	SXE_PC->(DbCloseArea())

	GetSXENum("SC7","C7_NUM",Space(nTamFil)+"\PC01")
	ConfirmSX8()

	GetSXENum("SC7","C7_NUM",Space(nTamFil)+"\PC01")
	ConfirmSX8()

	cNumPc := GetSXENum("SC7","C7_NUM",Space(nTamFil)+"\PC01")

EndIf

Return(cNumPc)
