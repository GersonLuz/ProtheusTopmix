#include "rwmake.ch"        

/*
+------------------------------------------------------------------+
|Programa | AT010GRV | Autor  Juliana Hilarina   | Data | 16/11/06 |
|---------+--------------------------------------------------------|
|Desc.    |Codificacao do BEM                                      |       
|---------+--------------------------------------------------------|        
|Uso      |Topmix                                                  |
+------------------------------------------------------------------+

*/


User Function AF010INC()        

	dbselectarea("SNG")
	dbSetOrder(1)
		RecLock("SNG",.F.)
		Replace SNG->NG_SEQUENC with STRZERO((VAL(NG_SEQUENC)+1),4)
		MsUnlock()
      


                         

Return()