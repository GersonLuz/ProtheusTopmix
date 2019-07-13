/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFATP17   บAutor  ณFausto Neto         บ Data ณ  03/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a exclusใo de toda a cota็ใo.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
************************************
User Function AFATP17               
************************************
*
*

Local cNumCot  := aWBrowse2[oWBrowse2:nAt,3] 
Local cFilSC   := aWBrowse2[oWBrowse2:nAt,9]
Local cQuery   := ""
Local cQueryEX := "" 

if Empty(cNumCot)
	ApMsgInfo("Nใo existe cota็ใo a ser excluํda !!!")
	return
endif   

cQuery := "SELECT DISTINCT C8_ZEMP, C8_FILIAL, C8_NUMSC, C8_PRODUTO"
cQuery += " FROM " + RetSqlName("SC8")
cQuery += " WHERE C8_FILIAL = '" + cFilSC + "' AND C8_NUM = '" + cNumCot + "'"
cQuery += " AND C8_NUMPED = ''"
cQuery += " AND D_E_L_E_T_ <> '*'" 

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBEXC",.T.,.T.) 

dbSelectArea("TRBEXC")
dbgoTop()

if !Eof("TRBEXC") 

	if !MsgYesNo( "A cota็ใo " + cNumCot + " serแ totalmente excluํda. Confirma ?" )    
		dbSelectArea("TRBEXC")
		dbCloseArea("TRBEXC")
		Return
	endif

	While !Eof("TRBEXC")  
	
		//Marca como deletada a Cota็ใo
	   //	cQueryEX := "DELETE FROM SC8" + TRBEXC->C8_ZEMP + "0 WHERE C8_NUM = '" + cNumCot + '""
		cQueryEX := "UPDATE " + RetSqlName("SC8") + " SET D_E_L_E_T_ = '*' WHERE C8_FILIAL = '" + cFilSC + "' AND C8_NUM = '" + cNumCot + "'"
		TcSqlExec( cQueryEX ) 
		
		 /*dbSelectArea("SC8")
         dbSetOrder(1)
         If dbSeek(cFilSC+cNumCot)	      
	     RecLock( "SC8", .F. )	         
	     SC8->( dbDelete() )	         
	     SC8->( MsUnLock() ) 
         endif  */
		
		//Atualiza a SC para gera็ใo de nova cota็ใo
		cQueryEX := "UPDATE SC1" + TRBEXC->C8_ZEMP + "0 SET C1_COTACAO = '', C1_ZSTATUS = '1', C1_QUJE = 0, C1_APROV = 'L' WHERE C1_FILIAL = '" + cFilSC + "' AND C1_COTACAO = '" + cNumCot + "' AND C1_NUM = '" + TRBEXC->C8_NUMSC + "' AND C1_PRODUTO = '" + TRBEXC->C8_PRODUTO + "'"		
		TcSqlExec( cQueryEX )
		
	
	
	
		dbSelectArea("TRBEXC")
		dbSkip()
	enddo 
	
else
	ApMsgInfo("Cota็ใo com pedido jแ gerado nใo poderแ ser excluํda !!!")
	return()
endif

dbSelectArea("TRBEXC")
dbCloseArea("TRBEXC")


return