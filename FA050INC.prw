#include "rwmake.ch"        

/*
+--------------------------------------------------------------------+
|Programa | FA050INC | Autor  Juliana            | Data |  20/11/06  |
|---------+----------------------------------------------------------|
|Desc.    |VALIDA INCLUSAO CONTAS A PAGAR                            |
|---------+----------------------------------------------------------|        
|Uso      |Topmix                                                    |
|         |                                                          |        
+--------------------------------------------------------------------+
*/

User Function FA050INC()

Local lret := .T.//lret := ParamIxb

Do Case
   Case (FunName() = 'GPEM670') //Inclusão do nome da rotina de integração da Folha para não obrigar preenchimento de CC. Jean Santos
	    lret := .T.
   Case Empty(M->E2_CCD) 
   lret :=MSGBOX("Favor informar o centro de custo", "Atençao!", "STOP"  ) 
   lRet := .F.
EndCase

Return(lRet)