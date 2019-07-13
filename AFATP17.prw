/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AFATP17   �Autor  �Fausto Neto         � Data �  03/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Faz a exclus�o de toda a cota��o.                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
************************************
User Function AFATP17               
************************************
*
*

Local cNumCot  := aWBrowse2[oWBrowse2:nAt,2] 
Local cFilSC   := aWBrowse2[oWBrowse2:nAt,6]
Local cQuery   := ""
Local cQueryEX := "" 

if Empty(cNumCot)
	ApMsgInfo("N�o existe cota��o a ser exclu�da !!!")
	return
endif   

cQuery := "SELECT DISTINCT C8_ZEMP, C8_FILIAL, C8_NUMSC, C8_PRODUTO, C8_NUMPRO "
cQuery += " FROM " + RetSqlName("SC8")
cQuery += " WHERE C8_FILIAL  = '" + cFilSC + "' AND C8_NUM = '" + cNumCot + "'"
cQuery += "   AND C8_NUMPED  = ' '"
cQuery += "   AND D_E_L_E_T_ <> '*'" 

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBEXC",.T.,.T.) 

dbSelectArea("TRBEXC")
dbgoTop()

if !Eof("TRBEXC") 

	if !MsgYesNo( "A cota��o " + cNumCot + " ser� totalmente exclu�da. Confirma ?" )    
		dbSelectArea("TRBEXC")
		dbCloseArea("TRBEXC")
		Return
	endif

	While !Eof("TRBEXC")  

		//Marca como deletada a Cota��o
		//cQueryEX := "DELETE FROM SC8" + TRBEXC->C8_ZEMP + "0 WHERE C8_NUM = '" + cNumCot + '""
		// acrescentado: + "' AND C8_NUMPED = ' ' AND C8_PRODUTO = '" + TRBEXC->C8_PRODUTO + "'"	
		cQueryEX := "UPDATE " + RetSqlName("SC8") + " SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_ ,C8_OBS = 'EXCLUIDO AFATP17' WHERE C8_FILIAL = '" + cFilSC + "' AND C8_NUM = '" + cNumCot + "' AND C8_NUMPED = ' ' AND C8_PRODUTO = '" + TRBEXC->C8_PRODUTO + "'"		
		TcSqlExec( cQueryEX ) 

		If TRBEXC->C8_NUMPRO == "01" // Atualiza a SC para gera��o de nova cota��o
		   cQueryEX := "UPDATE SC1" + TRBEXC->C8_ZEMP + "0 SET C1_COTACAO = ' ', C1_ZSTATUS = '1', C1_QUJE = 0, C1_APROV = 'L' WHERE C1_FILIAL = '" + cFilSC + "' AND C1_COTACAO = '" + cNumCot + "' AND C1_NUM = '" + TRBEXC->C8_NUMSC + "' AND C1_PRODUTO = '" + TRBEXC->C8_PRODUTO + "'"		
		   TcSqlExec( cQueryEX ) 
	   Endif
	
		dbSelectArea("TRBEXC")
		dbSkip()
	enddo 
	
else
	ApMsgInfo("Cota��o com pedido j� gerado n�o poder� ser exclu�da !!!")
endif

dbSelectArea("TRBEXC")
dbCloseArea("TRBEXC")

Return .t.