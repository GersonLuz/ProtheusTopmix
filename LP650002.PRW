#INCLUDE "rwmake.ch"

User Function LP650002()

local  cConta := " "  
local  cEst := " "   
local  cAtiv := " "  
Local  cParam :=  ParamIxb[1]

	
cTEs   := SD1->D1_TES
cCod   := SD1->D1_COD
cLocal := SD1->D1_LOCAL


IF !Empty(cTes)
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbseek(xFilial("SF4")+SD1->D1_TES)
	cEst := SF4->F4_ESTOQUE   
	cAtiv:= SF4->F4_ATUATF
EndIf

Do Case
   Case cEst=="S" .OR. cAtiv=="S"    
        IF !Empty(Posicione("SBM",1,xFilial("SBM") +SD1->D1_GRUPO,"BM_CONTA1"))
		    cConta := SBM->BM_CONTA1
        else       
		    cConta:=Posicione("SB1",1,xFilial("SB1") +SD1->D1_COD,"B1_CONTA")
        Endif  
        
                                 
	Case !SUBSTR(SD1->D1_CC,1,4)=="0001" .OR.  SUBSTR(SD1->D1_CC,5,2)=="020"
        IF !Empty(Posicione("SBM",1,xFilial("SBM") +SD1->D1_GRUPO,"BM_CONTA3"))
            cConta := SBM->BM_CONTA3
        else                    
            cConta:=Posicione("SB1",1,xFilial("SB1") +SD1->D1_COD,"B1_CONTA3")
        Endif     
        
    Case  SUBSTR(SD1->D1_CC,1,4)=="0001" .OR.  SUBSTR(SD1->D1_CC,5,2)=="290" .OR. EMPTY(SD1->D1_CC) 
        IF !Empty(Posicione("SBM",1,xFilial("SBM") +SD1->D1_GRUPO,"BM_CONTA2"))
            cConta := SBM->BM_CONTA2
        else                    
            cConta:=Posicione("SB1",1,xFilial("SB1") +SD1->D1_COD,"B1_CONTA2")
        Endif                        
        
EndCase   

Return(cConta)
                                                                                                                                                                                                                                                                                               