#Include "protheus.ch"   
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSINTP05
Processa a integração do cadastro de produtos do Protheus com o KP.
        
@author Rafael Almeida
@since 09/11/11
/*/
//---------------------------------------------------------------------------------------
User Function FSINTP05(cOpc,cCodPrd)

Local		aAreOld	:= {GetArea(),SB1->(GetArea())}

Local		lRet		:= .T.

Local		nRetMsg	:=	0

Default	cOpc		:= ""               
Default	cCodPrd 	:= ""


SB1->(dbSetOrder(1))

Do Case
	Case cOpc == "I" 
		SB1->(dbSeek(xFilial("SB1")+cCodPrd))
		If SB1->(!Eof()) .And.;
			xFilial("SB1") 			== SB1->B1_FILIAL .And.;
			cCodPrd 						== SB1->B1_COD .And.;
			(AllTrim(SB1->B1_GRUPO)	== "8001" .Or. AllTrim(SB1->B1_GRUPO) == "8002" .Or. AllTrim(SB1->B1_TIPO) == "CC")
			//Atualiza o banco de integração.
			U_FSPutTab("SB1","I")			
		EndIf                      
		
	Case cOpc == "A"
		SB1->(dbSeek(xFilial("SB1")+cCodPrd))
		If SB1->(!Eof()) .And.;
			xFilial("SB1") == SB1->B1_FILIAL .And.;
			cCodPrd == SB1->B1_COD .And.;
			(AllTrim(SB1->B1_GRUPO) == "8001" .Or. AllTrim(SB1->B1_GRUPO) == "8002" .Or. AllTrim(SB1->B1_TIPO) == "CC") .And.;
			!Empty(SB1->B1_ZFLAG)
			
			//Atualiza o banco de integração.
			U_FSPutTab("SB1","A")
		EndIf
			
	Case cOpc == "E"                       
		SB1->(dbSeek(xFilial("SB1")+cCodPrd))
		If SB1->(!Eof()) .And.;
			xFilial("SB1") == SB1->B1_FILIAL .And.;
			cCodPrd == SB1->B1_COD .And.;
			(AllTrim(SB1->B1_GRUPO) == "8001" .Or. AllTrim(SB1->B1_GRUPO) == "8002" .Or. AllTrim(SB1->B1_TIPO) == "CC") .And.;
			!Empty(SB1->B1_ZFLAG)	
		
			//Atualiza o banco de integração.     
			If U_FSVldExc("SB1")
				U_FSPutTab("SB1","E")
			Else
				lRet := .F.				
			EndIf
		EndIf
		
EndCase                      

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return lRet


