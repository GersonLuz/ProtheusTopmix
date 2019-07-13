#include "rwmake.ch"        

/*
+-------------------------------------------------------------------+
|Programa | MT106SC1 | Autor  Juliana            | Data |  01/10/06 |
|---------+---------------------------------------------------------|
|Desc.    |Ponto de Entrada para gravar informacao CQ p/ C1         |       
|         |                                                         |      
|---------+---------------------------------------------------------|        
|Uso      |Topmix                                                   |
|         |                                                         |        
+-------------------------------------------------------------------+

*/

User Function MT106SC1()

dbSelectArea("SC1")
RecLock("SC1",.F.)
Replace C1_OP With SCQ->CQ_OP
Replace C1_CC  With SCQ->CQ_CC
Replace C1_DESCRI With SCQ->CQ_DESCRI
//Replace C1_DESCRI1  With SCQ->CQ_DESCRI1

MsUnlock()

Return