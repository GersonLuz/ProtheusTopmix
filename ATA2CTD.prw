#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'


User Function ATA2CTD()

Local 	cItemcont:=""
dbSelectArea("CTD")
dbSetOrder(1)
cItemcont:="F"+SA2->A2_COD+SA2->A2_LOJA
dbseek(xFilial("CTD")+cItemcont)
If ! Found()
	dbSelectArea("CTD")
	Reclock("CTD",.T.)
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
else
    Alert("ATENÇÃO: já existe um Item Contábil com esta codificação: "+cItemcont )	
    Alert("Falha na inclusão do Item Contábil, contacte o Administrador.")
EndIF

Return ()
                            
