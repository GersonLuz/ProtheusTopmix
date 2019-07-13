#include "rwmake.ch"        

/*
+-------------------------------------------------------------------+
|Programa | MA106SCQ | Autor  Juliana            | Data |  01/10/06 |
|---------+---------------------------------------------------------|
|Desc.    |Ponto de Entrada para gravar informacao CP p/ CQ         |       
|         |                                                         |      
|---------+---------------------------------------------------------|        
|Uso      |Topmix                                                   |
|         |                                                         |        
+-------------------------------------------------------------------+

*/

User Function MA106SCQ()

dbSelectArea("SCQ")
RecLock("SCQ",.F.)
Replace CQ_OP With SCP->CP_OP
Replace CQ_CC With SCP->CP_CC
Replace CQ_DESCRI With SCP->CP_DESCRI
//Replace CQ_DESCRI1 With SCP->CP_DESCRI1

MsUnlock()

Return