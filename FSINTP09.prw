#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSINTP09
Processo de cadastro de Fornecedores integração KP
      
@author Fernando dos Santos Ferreira 
@since 17/11/2011
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSINTP09(cOpc,  cCodFor, cLojFor)
Local		aAreOld	:= {GetArea(),SA2->(GetArea())}

Local		lRet		:= .T.

Local		nRetMsg	:=	0

Default	cOpc		:= ""               
Default	cCodFor 	:= ""
Default	cLojFor 	:= ""   

SA2->(dbSetOrder(1)) // A2_FILIAL+A2_COD+A2_LOJA

Do Case   
	// Inclusão na base de integração
	Case Upper(cOpc) == "I"
		SA2->(dbSeek(xFilial("SA2")+cCodFor+cLojFor))
		If SA2->(!Eof()) 	.And. xFilial("SA2")	==	SA2->A2_FILIAL;
								.And. cCodFor 			== SA2->A2_COD;
								.And.	cLojFor			== SA2->A2_LOJA
			U_FSPutTab("SA2","I")
		EndIf                         
	// Alteração do registro na base de integração		
	Case Upper(cOpc) == "A"
		SA2->(dbSeek(xFilial("SA2")+cCodFor+cLojFor))
		If SA2->(!Eof()) 	.And. xFilial("SA2")	==	SA2->A2_FILIAL;
						.And. cCodFor 			== SA2->A2_COD;
						.And.	cLojFor			== SA2->A2_LOJA;
						.And.	!Empty(SA2->A2_ZFLAG)						
			//Atualiza o banco de integração.
			U_FSPutTab("SA2","A")						
		EndIf		
	// Exclusão do registro 		
	Case Upper(cOpc) == "E"	
		SA2->(dbSeek(xFilial("SA2")+cCodFor+cLojFor))
		If SA2->(!Eof()) 	.And. xFilial("SA2")	==	SA2->A2_FILIAL;
						.And. cCodFor 			== SA2->A2_COD;
						.And.	cLojFor			== SA2->A2_LOJA;
						.And.	!Empty(SA2->A2_ZFLAG)		
			If U_FSVldExc("SA2")
				U_FSPutTab("SA2","E")
			Else
				lRet := .F.				
			EndIf		
		EndIf
EndCase

aEval(aAreOld, {|xAux| RestArea(xAux)})
Return lRet


