#INCLUDE "rwmake.ch"

User Function LP610002()

local  cConta := " "  
local  cEst := " "   
local  cAtiv := " "  
Local  cParam :=  ParamIxb[1]

	
cTEs   := SD2->D2_TES
cCod   := SD2->D2_COD
cLocal := SD2->D2_LOCAL


IF !Empty(cTes)
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbseek(xFilial("SF4")+SD2->D2_TES)
	cEst := SF4->F4_ESTOQUE   
	cAtv := SF4->F4_ATUATF
EndIf

Do Case
   Case cEst=="S" .OR. cAtv=="S"    
        IF !Empty(Posicione("SBM",1,xFilial("SBM") +SD2->D2_GRUPO,"BM_CONTA1"))
		    cConta := SBM->BM_CONTA1
        else       
		    cConta:=Posicione("SB1",1,xFilial("SB1") +SD2->D2_COD,"B1_CONTA")
        Endif  
        
                                 
	Case !SUBSTR(SD2->D2_ZCC,1,4)=="0001" .OR.  SUBSTR(SD2->D2_ZCC,5,2)=="020"
        IF !Empty(Posicione("SBM",1,xFilial("SBM") +SD2->D2_GRUPO,"BM_CONTA3"))
            cConta := SBM->BM_CONTA3
        else                    
            cConta:=Posicione("SB1",1,xFilial("SB1") +SD2->D2_COD,"B1_CONTA3")
        Endif     
        
    Case  SUBSTR(SD2->D2_ZCC,1,4)=="0001" .OR.  SUBSTR(SD2->D2_ZCC,5,2)=="290" .OR. EMPTY(SD2->D2_ZCC) 
        IF !Empty(Posicione("SBM",1,xFilial("SBM") +SD2->D2_GRUPO,"BM_CONTA2"))
            cConta := SBM->BM_CONTA2
        else                    
            cConta:=Posicione("SB1",1,xFilial("SB1") +SD2->D2_COD,"B1_CONTA2")
        Endif                        
        
EndCase   

Return(cConta)
                                                                                                                                                                                                                                                                                               