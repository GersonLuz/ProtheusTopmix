#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AFATP20   �Autor  �Fausto Neto         � Data �  03/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exclui o pedido de compras e libera a cota��o               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
************************************
User Function AFATP20(cOrigem)
************************************
*
*

Local cZFilOri  := ""
Local cZNumPed  := ""
Local cZNumCot  := ""
Local lPodeEx   := .T.

if cOrigem == "3"    
	cZFilOri  := aWBrowse3[oWBrowse3:nAt,11]
	cZNumPed  := aWBrowse3[oWBrowse3:nAt,3]
	cZNumCot  := aWBrowse3[oWBrowse3:nAt,5]
elseif cOrigem == "4"
	cZFilOri  := aWBrowse4[oWBrowse4:nAt,12]
	cZNumPed  := aWBrowse4[oWBrowse4:nAt,3]
	cZNumCot  := aWBrowse4[oWBrowse4:nAt,6]
endif

if Empty(cZNumPed) 
	ApMsgInfo("N�o existe ordem de compras a ser exclu�da !!!")
	return
endif 

dbSelectArea("SC7")
dbSetOrder(1)
if dbSeek(cZFilOri+cZNumPed)
	While !Eof("SC7") .And. cZFilOri == SC7->C7_FILIAL .And. cZNumPed == SC7->C7_NUM
		if SC7->C7_QUJE > 0 
			lPodeEx := .F.
		endif
		dbSelectArea("SC7")
		dbSkip()
	enddo
endif    

if !lPodeEx
	ApMsgInfo("Ordem de compras j� amarrado a nota fiscal n�o pode ser exclu�do !")
	return
endif

if MsgYesNo( "A ordem de compras " + cZNumPed + " ser� exclu�da. Confirma ?" )    

	dbSelectArea("SC7")
	dbSetOrder(1)
	if dbSeek(cZFilOri+cZNumPed)
		While !Eof("SC7") .And. cZFilOri == SC7->C7_FILIAL .And. cZNumPed == SC7->C7_NUM
		
			cQueryEX := "UPDATE SC1" + SC7->C7_ZEMP + "0 SET C1_ZSTATUS = '3', C1_PEDIDO = '' WHERE C1_NUM = '" + SC7->C7_NUMSC + "' AND C1_ITEM = '" + SC7->C7_ITEMSC + "'"
			TcSqlExec( cQueryEX ) 		                                                         
			
			//Estorna a cota��o para aprovar novamente
			//cQueryEX := "DELETE FROM SC8" + TRBEXC->C8_ZEMP + "0 WHERE C8_NUM = '" + cZNumCot + '""
//			cQueryEX := "UPDATE " + RetSqlName("SC8") + " SET C8_NUMPED = '',  C8_ITEMPED = '', C8_ZSTATUS = '3' WHERE C8_NUM = '" + cZNumCot + "' AND C8_NUMSC = '" + SC7->C7_NUMSC + "' AND C8_ITEMSC = '" + SC7->C7_ITEMSC + "'"
			cQueryEX := "UPDATE " + RetSqlName("SC8") + " SET C8_NUMPED = '',  C8_ITEMPED = '', C8_ZSTATUS = '1' "+;
			            "WHERE C8_FILIAL = '" +SC7->C7_FILIAL + "' AND  C8_NUM = '" + cZNumCot + "' AND C8_PRODUTO = '" + SC7->C7_PRODUTO + "' AND C8_NUMSC = '" + SC7->C7_NUMSC + "' AND C8_ITEMSC = '" + SC7->C7_ITEMSC + "'"
			TcSqlExec( cQueryEX ) 

			//Marca como deletada a SCE
			cQueryEX := "UPDATE " + RetSqlName("SCE") + " SET D_E_L_E_T_ = '*' WHERE CE_FILIAL = '" + cZFilOri + "' AND CE_NUMCOT = '" + cZNumCot + "' AND CE_PRODUTO = '" + SC7->C7_PRODUTO + "'"
//			MsgStop(cQueryEX)
			TcSqlExec( cQueryEX )      


			dbSelectArea("SC7")
			dbSkip()
		enddo
	endif 

	//Marca como deletada a OC
	//cQueryEX := "DELETE FROM SC8" + TRBEXC->C8_ZEMP + "0 WHERE C8_NUM = '" + cZNumCot + '""
	cQueryEX := "UPDATE " + RetSqlName("SC7") + " SET D_E_L_E_T_ = '*' WHERE C7_NUM = '" + cZNumPed + "' AND C7_FILIAL = '" + cZFilOri + "'"
	TcSqlExec( cQueryEX )      
     

	//Estorna a cota��o para aprovar novamente
	//cQueryEX := "DELETE FROM SC8" + TRBEXC->C8_ZEMP + "0 WHERE C8_NUM = '" + cZNumCot + '""
	cQueryEX := "UPDATE " + RetSqlName("SCR") + " SET D_E_L_E_T_ = '*' WHERE CR_NUM = '" + cZNumPed + "' AND CR_FILIAL = '" + cZFilOri + "'"
	TcSqlExec( cQueryEX )   				
	MsgInfo("Exclus�o processada com sucesso.")	
endif

return