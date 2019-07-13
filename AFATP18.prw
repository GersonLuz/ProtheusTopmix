/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFATP18   บAutor  ณFausto Neto         บ Data ณ  03/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a exclusใo de um fornecedor da cota็ใo.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
************************************
User Function AFATP18               
************************************
*
Local cZNumCot  := aWBrowse2[oWBrowse2:nAt,2]
Local cZFornec  := aWBrowse2[oWBrowse2:nAt,3]
Local cZLoja    := aWBrowse2[oWBrowse2:nAt,4]
Local cFilCot   := aWBrowse2[oWBrowse2:nAt,6]
Local nConta    := 0
Local k         := 0
Local cFornLoja := ""

if Empty(cZNumCot) .Or. Empty(cZFornec) 
	ApMsgInfo("Nใo existe cota็ใo a ser excluํda !!!")
	return
endif                

For k := 1 To Len(aWBrowse2)
	If aWBrowse2[k,2] == cZNumCot 
	   If ! (aWBrowse2[k,3] + aWBrowse2[k,4]) $ cFornLoja
		   nConta ++
		   cFornLoja += (aWBrowse2[k,3] + aWBrowse2[k,4]) +"/"
		Endif   
	EndIf
Next

//impede a exclusao da cota็ใo neste momento pois existem outros tratamentos a serem feitos para liberacao da SC
If nConta <= 1                                                                                                   
	MsgStop("Utilize a op็ใo de Excluir Cota็ใo, pois trata-se de apenas 1 fornecedor nesta cota็ใo de pre็o!")
	Return
EndIf

if MsgYesNo( "O fornecedor " + cZFornec+"/"+cZLoja + " serแ excluํdo da cota็ใo " + cZNumCot + ". Confirma ?" )    

	//Marca como deletada a Cota็ใo
	//cQueryEX := "DELETE FROM SC8" + TRBEXC->C8_ZEMP + "0 WHERE C8_NUM = '" + cZNumCot + '""
	cQueryEX := "UPDATE " + RetSqlName("SC8") + " SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_ , C8_OBS = 'EXCLUIDO AFATP18' WHERE C8_FILIAL = '" + cFilCot + "' AND C8_NUMPED = ' ' AND C8_NUM = '" + cZNumCot + "' AND C8_FORNECE = '" + cZFornec + "' AND C8_LOJA = '" + cZLoja + "'"
	TcSqlExec( cQueryEX ) 
	
 //	//volta para estado de cota็ใo liberada
//	cQueryEX := "UPDATE SC1" + TRBEXC->C8_ZEMP + "0 SET C1_COTACAO = '', C1_ZSTATUS = '1', C1_QUJE = 0, C1_APROV = 'L' WHERE C1_COTACAO = '" + cNumCot + "' AND C1_NUM = '" + TRBEXC->C8_NUMSC + "' AND C1_PRODUTO = '" + TRBEXC->C8_PRODUTO + "'"		
//	TcSqlExec( cQueryEX ) 

		
endif

return