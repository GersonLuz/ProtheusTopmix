#Include "RwMake.ch" 
/*
+-----------+------------+----------------+-------------------+-------+---------------+
| Programa  | D1CONTA    | Desenvolvedor  | Juliana           | Data  | 25/09/2012    |
+-----------+------------+----------------+-------------------+-------+---------------+
| Descricao | Gatilho conta do produto                                                |
+-----------+-------------------------------------------------------------------------+
| DATA     | PROGRAMADOR | MOTIVO                                                     |
+----------+-------------+------------------------------------------------------------+
*/                                           
User Function D1CONTA()   
Local aArea   := GetArea()
Local cCodPro  := ""
Local cCC      := ""
Local cTES     := ""
Local cGrupo   := ""      
Local cEst     := ""

               
	//Preenche variaveis                                                     0
	cCodPro  := aCols[n][GDFieldPos("D1_COD")]
	cTES     := aCols[n][GDFieldPos("D1_TES")]
	cCC      := aCols[n][GDFieldPos("D1_CC")]
	
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
	        
	                                 
		Case !SUBSTR(cCC,1,4)=="0001" .OR.  SUBSTR(cCC ,5,2)=="020"
	        IF !Empty(Posicione("SBM",1,xFilial("SBM")+cGRUPO,"BM_CONTA3"))
	            cConta := SBM->BM_CONTA3
	        else                    
	            cConta:=Posicione("SB1",1,xFilial("SB1") +cCodPro,"B1_CONTA3")
	        Endif     
	        
	    Case  SUBSTR(cCC,1,4)=="0001" .OR.  SUBSTR(cCC,5,2)=="290" .OR. EMPTY(cCC) 
	        IF !Empty(Posicione("SBM",1,xFilial("SBM") +cGRUPO,"BM_CONTA2"))
	            cConta := SBM->BM_CONTA2
	        else                    
	            cConta:=Posicione("SB1",1,xFilial("SB1") +cCodPro,"B1_CONTA2")
	        Endif                        
	        
	EndCase   
	
	
	  
	RestArea(aArea)
Return(cConta)