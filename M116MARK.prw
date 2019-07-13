#include "TOTVS.CH"

//------------------------------------------------------------------- 
/*/{Protheus.doc} M116MARK
Este Ponto de Entrada permite validar os documentos de entrada, durante
 a  marcação para geração da Nota de Conhecimento de Frete. 
          
@author 	Fernando dos Santos Ferreira 
@since 	13/08/2013
@version P11
@obs  
	
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function M116MARK()
Local cMark		:= ThisMark()

RecLock("SF1",.F.) 
If IsMark('F1_OK',cMark)
	SF1->F1_OK :=Space(2)
Else
	SF1->F1_OK :=cMark
EndIf
MsUnLock()

FGetNotas(  )
MarkBRefresh()
Return Nil         

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetNotas
Retorna as notas marcadas pelo rotina de geração de notas de conhecimmento
de frete.
          
@author 	Fernando dos Santos Ferreira 
@since 	13/08/2013
@version P11
@obs  
	
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FGetNotas(  )
If !Empty( SF1->F1_OK )
	U_FPutNotas( SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA )
Else
	U_FDelNotas( SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA )
EndIf  
Return Nil