#include "rwmake.ch"        

/*
+-------------------------------------------------------------------+
|Programa | MSDS460  | Autor  Juliana            | Data |  16/10/06 |
|---------+---------------------------------------------------------|
|Desc.    |Ponto de Entrada para gravar informacao do Centro Custo  | 
|---------+---------------------------------------------------------|        
|Uso      |                                                         |
|         |                                                         |        
+-------------------------------------------------------------------+
*/

User Function MSD2460()

dbSelectArea("SD2")
RecLock("SD2",.F.)
REPLACE SD2->D2_ZCC WITH SC6->C6_ZCC



MsUnlock()

Return()