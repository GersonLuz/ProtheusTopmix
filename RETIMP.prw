#include "rwmake.ch"        

/*
+--------------------------------------------------------------------+
|Programa | RETIMP   | Autor  Juliana Hilarina   | Data |  20/11/06  |
|---------+----------------------------------------------------------|
|Desc.    |UTILIZADO PARA VERIFICAR A RETENCAO DE IMPOSTOS NO MOMENTO|
|         |DA INCUSAO DA NOTA FISCAL                                 |
|---------+----------------------------------------------------------|        
|Uso      |Topmix                                                    |
|         |                                                          |        
+--------------------------------------------------------------------+

*/

User Function RETIMP()

Local vRet := 0

dbSelectArea("SE2")
dbSetOrder(6)
dbseek(xFilial("SE2")+SF1->(F1_FORNECE+F1_LOJA+F1_PREFIXO+F1_DOC))

While (! Eof())                         .And. ;
	  (SF1->F1_FORNECE == SE2->E2_FORNECE) 	.And. ;
  	  (SF1->F1_LOJA == SE2->E2_LOJA) 	 	.And. ;
  	  (SF1->F1_PREFIXO == SE2->E2_PREFIXO) 	.And. ;
  	  (SF1->F1_DOC == E2_NUM) 	

   	IF SE2->E2_TIPO == "NF "                             
	  vRet += SE2->(E2_VRETPIS+E2_VRETCOF+E2_VRETCSL)
	Endif	  
	dbskip()                          	
Enddo	  

Return(vRet)