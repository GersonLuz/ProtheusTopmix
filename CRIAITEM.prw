#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRIAITEM  �Autor  �X                   � Data �  07/14/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � PROGRAMA PARA CRIACAO DO ITEM CONTABIL                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CRIAITEM()
Processa( {|| PrcCtb01()} ,OemToAnsi("Atualiza��o do Item Cont�bil - Fornecedores"),"Processando...")
Processa( {|| PrcCtb02()} ,OemToAnsi("Atualiza��o do Item Cont�bil - Clientes"),"Processando...")
Return

Static Function PrcCtb01()
*****************************************************************************************************
Local cItemCont := ""
dbSelectArea("SA2")
dbGoTop()      
ProcRegua(RecCount()) // Numero de registros a processar
While !Eof()
    IncProc()
	dbSelectArea("CTD")
	dbSetOrder(1)
	cItemCont := "F"+SA2->A2_COD+SA2->A2_LOJA
	dbSeek(xFilial("CTD")+cItemCont)
	If Eof()
		RecLock("CTD",.T.)
		Replace CTD_FILIAL With xFilial("CTD") 
		Replace CTD_ITEM   With cItemcont      
		Replace CTD_DESC01 With SA2->A2_NOME   
		Replace CTD_CLASSE With "2"            
		Replace CTD_NORMAL With "0"            
		Replace CTD_DTEXIS With ctod("01/01/1980") 
		Replace CTD_BLOQ   With '2'
		Replace CTD_CLOBRG With '2'
	   Replace CTD_ACCLVL With '1'
		MsUnlock("CTD")
	EndIf
	dbSelectArea("SA2")
	dbSkip()
End
Return

Static Function PrcCtb02()
Local cItemCont := ""
dbSelectArea("SA1")
dbGoTop()
ProcRegua(RecCount()) // Numero de registros a processar
While !Eof()
	incproc()
	dbSelectArea("CTD")
	dbSetOrder(1)
	cItemCont := "C"+SA1->A1_COD+SA1->A1_LOJA
	dbSeek(xFilial("CTD")+cItemCont)
	If Eof()
		RecLock("CTD",.T.)
		Replace CTD_FILIAL With xFilial("CTD") 
		Replace CTD_ITEM   With cItemcont      
		Replace CTD_DESC01 With SA1->A1_NOME   
		Replace CTD_CLASSE With "2"            
		Replace CTD_NORMAL With "0"            
		Replace CTD_DTEXIS With ctod("01/01/1980") 
		Replace CTD_BLOQ   With '2'               
		Replace CTD_CLOBRG With '2'
	    Replace CTD_ACCLVL With '1'
		MsUnlock("CTD")
	EndIf
	dbSelectArea("SA1")
	dbSkip()
End
Return
