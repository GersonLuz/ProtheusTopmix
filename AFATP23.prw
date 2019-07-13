#Include "PROTHEUS.CH"
#include "rwmake.ch"   

//Rastreia a solicitação de compras
//26JAN2015
//Alecio

User Function AFATP23(pPar)
Local aAliasOLD   := GetArea()
pPar := Iif(pPar<>Nil,pPar,"999")

fMostraCom()

//funcao para acertar os campos C8_IDENT, C1_IDENT dos pedidos
//fAcertaIdent()

If pPar == "SC8"
	fAcertaSC8()
ElseIf pPar = "FIL"
	fAcertaFil()
ElseIf pPar = "SC1"
	fAcertaSC()
EndIf

RestArea(aAliasOLD)

Return


Static Function fMostraCom

Local cMsg := ""
dbSelectArea("SC8")
dbSetOrder(1)
                
dbSeek(SC1->C1_FILIAL + SC1->C1_COTACAO)

If Found()
	cMsg := "Comprador " + Alltrim(UsrRetName(SC8->C8_ZUSER)) + "  Cotacao: " + SC1->C1_COTACAO + "  Pedido de Compra: " + SC1->C1_PEDIDO
	MsgInfo(cMsg)
Else
	If SC1->C1_ZSTATUS <> '1'
		If RecLock("SC1",.F.)
			SC1->C1_PEDIDO  := " "
			SC1->C1_ITEMPED := " "
			SC1->C1_QUJE    := 0
			SC1->C1_ZSTATUS := "1"
			SC1->C1_COTACAO := ""
			MsUnlock()
		EndIf
	EndIf	
	MsgInfo("Sem comprador vinculado")
EndIf

Return

		
		
Static Function fAcertaSC8

dbSelectArea("SC8")   // Grava na tabela de contação o numero do pedido de compra   
dbSetOrder(3) 

dbSelectArea("SC7")
dbGoTop()
Do While !Eof()

	cFilCota := SC7->C7_FILIAL
	cNUMCOT  := SC7->C7_NUMCOT
	cPedido  := SC7->C7_NUM
	cItemPed := SC7->C7_ITEM             
	cProd    := SC7->C7_PRODUTO
	     

	dbSelectArea("SC8")   // Grava na tabela de contação o numero do pedido de compra   
	//dbSeek(xFilial("SC8")+cNUMCOT+cPRODUTO,.T.)//+cFORNECE+cLoja,.T.) 
	if dbSeek(cFilCota + cNUMCOT + cProd)//+cFORNECE+cLoja,.T.) 	
		While !Eof() .And. SC8->C8_FILIAL == cFilCota .And. SC8->C8_NUM == cNUMCOT .AND. SC8->C8_PRODUTO == cProd
		  If Empty(SC8->C8_NUMPED)
		     If SC8->C8_ZGANHAD='S'  //.And. Empty(SC8->C8_NUMOC)                                                                                                  
			  	   IF RecLock("SC8",.F.)
					   SC8->C8_ZSTATUS := "5"
					   SC8->C8_NUMPED  := cPedido 
					   SC8->C8_ITEMPED := cITEMPed 
					   SC8->(MsUnlock())
				   Endif 
			  else
			  	   IF RecLock("SC8",.F.)
				     SC8->C8_ZSTATUS := "5"
					  SC8->C8_NUMPED  := "XXXXXX" 
					  SC8->C8_ITEMPED := "XXXX" 
					  SC8->(MsUnlock())
				   Endif 				
			  Endif 
		  EndIf
		  dbSkip()	
	   Enddo
   Endif
	
	dbSelectArea("SC7")
	dbSkip()
EndDo    





Static Function fAcertaFil

dbSelectArea("SC8")   // Grava na tabela de contação o numero do pedido de compra   
dbSetOrder(3) 

dbSelectArea("SC7")
dbGoTop()
Do While !Eof()

	cFilCota := SC7->C7_FILIAL
	cNUMCOT  := SC7->C7_NUMCOT
	cPedido  := SC7->C7_NUM
	cItemPed := SC7->C7_ITEM             
	cProd    := SC7->C7_PRODUTO
	     
			dbSelectArea("SC8")   // Grava na tabela de contação o numero do pedido de compra   
			//dbSeek(xFilial("SC8")+cNUMCOT+cPRODUTO,.T.)//+cFORNECE+cLoja,.T.) 
			if dbSeek(cFilCota+cNUMCOT+cProd)//+cFORNECE+cLoja,.T.) 	
			If !Found()
				If dbSeek("010100" + cNumCot + cProd)
					If RecLOck("SC8",.f.)
					MsgStop(SC7->C7_NUM)
					EndIf
				EndIf
			EndIf
			EndIf
	
	dbSelectArea("SC7")
	dbSkip()
EndDo     


Static Function fAcertaSC

dbSelectArea("SC8")   // Grava na tabela de contação o numero do pedido de compra   
dbSetOrder(1) 
aSC8 := {}
dbSelectArea("SC1")
dbGoTop()
Do While !Eof()

	cFilSC   := SC1->C1_FILIAL
	cCota    := SC1->C1_COTACAO
	cItemSC:= SC1->C1_ITEM
	cProd    := SC1->C1_PRODUTO
	
	lCota := .T.
//	If SC1->C1_NUM = "000003"	
	
	dbSelectArea("SC8")
 	If cFilSC <> "010100"
		If dbSeek("010100" + cCota)
			lCota := .T.
			Do While !Eof() .And. "010100" == SC8->C8_FILIAL .And. SC8->C8_NUM == cCota
				If SC8->C8_PRODUTO == cProd .And. cFilSC <> '010100'
					If RecLock("SC8",.F.)  
//						SC8->C8_FILIAL := cFilSC 
						AADD(aSC8,{SC8->(Recno()),cFilSC} )
//						MsgStop("Cota " + cCota)
						MsUnlock()    
						AutoGRLog(SC1->C1_FILIAL + " SC " + SC1->C1_NUM + " Cotação " + cCota + " na filial 010100  pc "+SC1->C1_PEDIDO )

					EndIf
				EndIf
				
				dbSelectArea("SC8")
				dbSkip()
			EndDo
		Else
			lCota := dbSeek(cFilSC + cCota)
		EndIf
	EndIf             
	
 //	ENDIF
	
	If !lCota .And. !Empty(cCota)       
		If RecLock("SC1",.F.)
			SC1->C1_PEDIDO  := ""  
			SC1->C1_ITEMPED := " "
			SC1->C1_QUJE    := 0
			SC1->C1_ZSTATUS := "1"
			SC1->C1_COTACAO := ""
			MsUnlock()
		EndIf
		  AutoGRLog("SC " + SC1->C1_NUM +" Cotação nao existe " + cCota)
	EndIf
	
	dbSelectArea("SC1")
	dbSkip()
EndDo                                              

dbSelectARea("SC8")
For k := 1 To Len(aSC8)
               MsGoTo(aSC8[k,1])
               
					If RecLock("SC8",.F.)  
						SC8->C8_FILIAL := aSC8[k,2]
						MsUnlock()    
					EndIf

Next                 

Return


Static Function fAcertaIdent()

dbSelectArea("SC7")
dbGoTop()   
do While !Eof()
	lOk := .T.
	lOk := C7_EMISSAO >= dDataBase -2
	
	If !lOk
		dbSelectArea("SC7")
		dbSkip()
		Loop
	EndIf
	
	cCotacao := SC7->C7_NUMCOT
	cFilCota := SC7->C7_FILIAL
	
	dbSelectArea("SC8")
	dbSeek(cFilCota + cCotacao)
	
	Do While !Eof() .And. C8_FILIAL = cFilCota .And. C8_NUM = cCotacao
	
		cFilSc := SC8->C8_FILIAL
		cNumSC := SC8->C8_NUMSC
		cItemSC:= SC8->C8_ITEMSC
		
		If RecLock("SC8",.f.)
			SC8->C8_IDENT := If(Alltrim(SC8->C8_ITEM) = '999','0001',SC8->C8_ITEM)
			MsUnlock()
		EndIf		
		
		dbSelectArea("SC1")
		dbSeek(cFilSC + cNumSC + cItemSC)
		
		If Found()
			If RecLock("SC1",.f.)
				SC1->C1_IDENT := SC8->C8_IDENT
				MsUnlock()
			EndIf
		EndIf	
	
		dbSelectArea("SC8")
		dbSkip()
	EndDo
		

	dbSelectArea("SC7")
	dbSkip()
EndDo

Return
