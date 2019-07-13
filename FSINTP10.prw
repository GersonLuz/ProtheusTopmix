#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSINTP10
Processo de cadastro de Vendedores integra��o KP

@author Fernando dos Santos Ferreira 
@since 17/11/2011
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSINTP10(cOpc,  cCodVed)
Local		aAreOld	:= {GetArea(),SA3->(GetArea())}

Local		lRet		:= .T.

Local		nRetMsg	:=	0

Default	cOpc		:= ""               
Default	cCodVed 	:= ""

SA3->(dbSetOrder(1)) // A3_FILIAL+A3_COD

Do Case   
	// Inclus�o na base de integra��o
	Case Upper(cOpc) == "I"
		SA3->(dbSeek(xFilial("SA3")+cCodVed))
		If SA3->(!Eof()) 	.And. xFilial("SA3")	==	SA3->A3_FILIAL;
								.And. cCodVed 			== SA3->A3_COD
			U_FSPutTab("SA3","I")
		EndIf                         
	// Altera��o do registro na base de integra��o		
	Case Upper(cOpc) == "A"
		SA3->(dbSeek(xFilial("SA3")+cCodVed))
		If SA3->(!Eof()) 	.And. xFilial("SA3")	==	SA3->A3_FILIAL;
						.And. cCodVed 			== SA3->A3_COD;
						.And.	!Empty(SA3->A3_ZFLAG)						
			//Atualiza o banco de integra��o.
			U_FSPutTab("SA3","A")						
		EndIf		
	// Exclus�o do registro 		
	Case Upper(cOpc) == "E"	
		SA3->(dbSeek(xFilial("SA3")+cCodVed))
		If SA3->(!Eof()) 	.And. xFilial("SA3")	==	SA3->A3_FILIAL;
						.And. cCodVed 			== SA3->A3_COD;
						.And.	!Empty(SA3->A3_ZFLAG)		
		If U_FSVldExc("SA3")
				lRet := U_FSPutTab("SA3","E")
			Else
				lRet := .F.				
			EndIf		
		EndIf
EndCase

aEval(aAreOld, {|xAux| RestArea(xAux)})
Return lRet


