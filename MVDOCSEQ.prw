#Include "Rwmake.ch"
#include "Topconn.ch"

*/ 

User Function MVDOCSEQ()
**************************************************************************************
*
**
Private cDocSeq := "000000"
Private cQuery  

MsgBox("Por Segurança, peça a Todos que ABANDONE o sistema","Atenção IMPORTANTE","INFO")

cQuery  := "Select Max(D1_NUMSEQ) AS SEQ FROM "+RetSqlName("SD1")+" WHERE D_E_L_E_T_ <> '*'"
cDocSeq := cRetDocSeq()

cQuery  := "Select Max(D2_NUMSEQ) AS SEQ FROM "+RetSqlName("SD2")+" WHERE D_E_L_E_T_ <> '*'"
cDocSeq := cRetDocSeq()

cQuery  := "Select Max(D3_NUMSEQ) AS SEQ FROM "+RetSqlName("SD3")+" WHERE D_E_L_E_T_ <> '*'"
cDocSeq := cRetDocSeq()

cQuery  := "Select Max(C9_NUMSEQ) AS SEQ FROM "+RetSqlName("SC9")+" WHERE D_E_L_E_T_ <> '*'"
cDocSeq := cRetDocSeq()

dbSelectArea("SX6")
dbSetOrder(1)
dbSeek( xFilial("SX6")+ "MV_DOCSEQ")

If !MsgYesNo(OemToAnsi("Deseja Atualizar o Parametro MV_DOCSEQ desta FILIAL com o numero: "+cDocSeq+" (S/N)"+chr(13)+;
                       "Numero Atual: "+IIF(Rtrim(X6_VAR) == "MV_DOCSEQ",Rtrim(X6_CONTEUD),"VAZIO")),OemToAnsi("ATENÇÃO"),"INFO") 
   Return(.F.) 
EndIf 
		
dbSelectArea("SX6")
dbSetOrder(1)
If dbSeek(xFilial("SX6") + "MV_DOCSEQ")
	If cDocSeq > X6_CONTEUD
		If RecLock("SX6",.f.)
		   Replace X6_CONTEUD With cDocSeq
		   Replace X6_CONTSPA With cDocSeq
		   Replace X6_CONTENG With cDocSeq
		   MsUnlock() 
		   MsgBox("Parametro atualizado com sucesso!!!","Atenção IMPORTANTE","INFO")
		EndIf
	EndIf
EndIf     

Return .t.




Static Function cRetDocSeq()
**************************************************************************************
*
**
TcQuery cQuery New Alias "DOCSEQ"
DbSelectArea("DOCSEQ")
If cDocSeq < DOCSEQ->SEQ
   cDocSeq := Soma1(DOCSEQ->SEQ,Len(DOCSEQ->SEQ))
Endif
DbCloseArea()
Return(cDocSeq)
