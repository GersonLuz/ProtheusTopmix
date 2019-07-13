#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                              
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 29/11/2017    - 
----------------------------------------------------------------------------------------
                                  PROGRAMA: MT120FIM                                   -
----------------------------------------------------------------------------------------                          
----------------------------------------------------------------------------------------
                    PONTO DE ENTRADA NA CONFIRMAÇÃO DO PEDIDO DE COMPRA                -
---------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------*/ 

*************************************
User Function MT120FIM()
*************************************

	Local cFil := SC7->C7_FILIAL
	Local cNum := SC7->C7_NUM
	Local nValor := 0
	Local cQuery := "" 
	
	 // Alteração Pedido de Compras
	    
	dbSelectArea("SC7")
	dbSetOrder(1)
	dbSeek (SC7->C7_FILIAL+SC7->C7_NUM)
	While !SC7->(Eof()) .And. SC7->C7_FILIAL == cFil .And. SC7->C7_NUM == cNum
		nValor := SC7->C7_TOTAL
		RecLock("SC7",.F.)
		Replace SC7->C7_CONAPRO With 'B' // MARCAR COMO BLOQUEADO
		MsUnlock()
		Dbskip()               
	EndDo
		 
		 ////// TABELA DE ALÇADAS //////
		                                       
	cQuery := " UPDATE TOP(3)" + RetSqlName ("SCR") "
	cQuery += " SET D_E_L_E_T_ = '', CR_STATUS = '02' "
	cQuery += " WHERE R_E_C_N_O_ IN (SELECT  TOP(3)R_E_C_N_O_ FROM " + RetSqlName ("SCR")  "
	cQuery += " WHERE CR_NUM ='"+cNum+"' "
	cQuery += " AND CR_FILIAL ='"+cFil+"' "
	cQuery += " ORDER BY 1 DESC) "    
		
	TCSqlExec(cQuery) 
	       
	//Rotina para Verificar se existe alçada
	dbSelectArea("SAL")
	dbSetOrder(1)
	dbSeek (SC7->C7_FILIAL+SC7->C7_APROV)
	While !SAL->(Eof()) 
		Conout (SAL->AL_DESC)
	EndDo
	                                                                                  
	dbSelectArea("SCR")
	dbSetOrder(1)
	dbSeek (cFil+'PC'+cNum)
	While !SCR->(Eof()) .And. SCR->CR_FILIAL == cFil .And. Alltrim(SCR->CR_NUM) == cNum 
		RecLock("SCR",.F.)
		Replace SCR->CR_TOTAL With nValor
		DBRECALL()
		MsUnlock()
	EndDo   
return