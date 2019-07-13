#Include "RwMake.ch" 
/*
+-----------+------------+----------------+-------------------+-------+---------------+
| Programa  | M410LIOK   | Desenvolvedor  | MAX/ROCHA         | Data  | 25/09/2012    |
+-----------+------------+----------------+-------------------+-------+---------------+
| Descricao | Validação da linha do pedido de Vendas                                  |
+-----------+-------------------------------------------------------------------------+
| DATA     | PROGRAMADOR | MOTIVO                                                     |
+----------+-------------+------------------------------------------------------------+
*/                                           
User Function M410LIOK()   
Local aArea   := GetArea()
Local lRet := .T. 
Local cCodPro  := ""
Local cConta   := ""                      
Local cITem    := ""
Local cCC      := ""
Local cTES     := ""
Local cGrupo   := ""
                
//preenche variaveis
cCodPro  := aCols[n][GDFieldPos("C6_PRODUTO")]
cTES     := aCols[n][GDFieldPos("C6_TES")]
cItem    := aCols[n][GDFieldPos("C6_ITEMCON")]
cZCC      := aCols[n][GDFieldPos("C6_ZCC")]

IF !Empty(cTES)
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbseek(xFilial("SF4")+cTES)
EndIf
cEst     := SF4->F4_ESTOQUE 


IF !Empty(cCodPro)
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbseek(xFilial("SB1")+cCodPro)
EndIf
cGrupo := SB1->B1_GRUPO




Do Case
   Case cEst=="S" 
        IF !Empty(Posicione("SBM",1,xFilial("SBM")+cGrupo,"BM_CONTA1"))
		    cConta := SBM->BM_CONTA1
        else       
		    cConta:=Posicione("SB1",1,xFilial("SB1") +cCodPro, "B1_CONTA")
        Endif  
        
                                 
	Case !SUBSTR(cZCC,1,4)=="0001" .OR.  SUBSTR(cZCC ,5,2)=="020"
        IF !Empty(Posicione("SBM",1,xFilial("SBM")+cGRUPO,"BM_CONTA3"))
            cConta := SBM->BM_CONTA3
        else                    
            cConta:=Posicione("SB1",1,xFilial("SB1") +cCodPro,"B1_CONTA3")
        Endif     
        
    Case  SUBSTR(cZCC,1,4)=="0001" .OR.  SUBSTR(cZCC,5,2)=="290" .OR. EMPTY(cZCC) 
        IF !Empty(Posicione("SBM",1,xFilial("SBM") +cGRUPO,"BM_CONTA2"))
            cConta := SBM->BM_CONTA2
        else                    
            cConta:=Posicione("SB1",1,xFilial("SB1") +cCodPro,"B1_CONTA2")
        Endif                        
        
EndCase   


    
   IF SB1->B1_GRUPO > '1000' //abaixo de 1000 são considerados CC
      if ! (cFilAnt $ GETMV("MV_FILEST")) 
         IF SF4->F4_ESTOQUE="S"
            MSGBOX("Não é permitido a utilização de TES com movimentação de estoque, para esta filial.", "ATENÇÃO" ,"STOP") 
            lRet := .f.
         EndIF
      EndIF
   EndIF 
   
   IF SB1->B1_ESTOQUE="1" .and. SB1->B1_GRUPO > "1000"
   	if (cFilAnt $ GETMV("MV_FILEST")) 
      	IF SF4->F4_ESTOQUE<>"S"  
         	MSGBOX("Não é permitido a utilização de TES sem movimentação de estoque, para esta filial e este produto.", "ATENÇÃO" ,"STOP") 
         	lRet := .f.
         EndIF	
      EndIF
   EndIF 
   
   DBSelectArea("CT1")
   DbSetOrder(1)   
   IF dbSeek(xFilial("CT1")+cConta)
      If CT1->CT1_CCOBRG = "1" .AND. Empty(cZCC) 
        	MSGBOX("Favor informar o Centro de Custo para este produto.", "ATENÇÃO" ,"STOP") 
        	lRet := .f.
      EndIF
      //If CT1->CT1_ITOBRG = "1" .AND. Empty(cItem) 
      //  	MSGBOX("Favor informar o Item Contábil para este produto.", "ATENÇÃO" ,"STOP") 
      //  	lRet := .f.
      //EndIF
   EndIF          


RestArea(aArea)
Return(lRet)