#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M030INC   �Autor  �Xxx                 � Data �  07/14/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � CRIA ITEM CONTABIL A PARTIR DA INCLUSAO DO CLIENTE         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ATUCTD()   

Local cItemcont := "C"+SA1->A1_COD+SA1->A1_LOJA
 
If INCLUI

   dbSelectArea("CTD")
   dbSetOrder(1)
   If ! dbseek(xFilial("CTD")+cItemcont)
	   dbSelectArea("CTD")
   	Reclock("CTD",.T.)
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
   
Endif   

Return
