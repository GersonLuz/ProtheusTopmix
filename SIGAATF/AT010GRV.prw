#include "rwmake.ch"        

/*
+------------------------------------------------------------------+
|Programa | AT010GRV | Autor  Juliana Hilarina   | Data | 16/11/06 |
|---------+--------------------------------------------------------|
|Desc.    |Codificacao do BEM                                      |       
|---------+--------------------------------------------------------|        
|Uso      |Topmix                                                  |
+------------------------------------------------------------------+
AT010GRV - Grava inclusão/alteração de ativo
*/

User Function AT010GRV()        

	
If INCLUI .OR. Alltrim(Funname())$ "ATFA240" 
	dbselectarea("SNG")
	If dbseek(xFilial("SNG")+SN1->N1_GRUPO)
		RecLock("SNG",.F.)
		Replace NG_SEQUENC with STRZERO((VAL(NG_SEQUENC)+1),4)
		MsUnlock()
	EndIf	      
EndIf	

Return()