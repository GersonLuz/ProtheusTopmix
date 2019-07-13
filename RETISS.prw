#include "rwmake.ch"        

/*
+--------------------------------------------------------------------+
|Programa | RETISS   | Autor Juliana             | Data |  20/11/06  |
|---------+----------------------------------------------------------|
|Desc.    |UTILIZADO PARA VERIFICAR A RETENCAO DE IMPOSTOS NO MOMENTO|
|         |DA INCUSAO DA NOTA FISCAL                                 |
|---------+----------------------------------------------------------|        
|Uso      |Topmix                                                    |
|         |                                                          |        
+--------------------------------------------------------------------+

*/
/*
User Function RETISS()

Local cRet := ''
Local aAreaOld  := GetArea()
Local cTipISS  := 'ISS'
Local cCod     := ''

dbSelectArea("SE2")
dbSetOrder(6)
dbseek(xFilial("SE2")+SF1->(F1_FORNECE+F1_LOJA+F1_PREFIXO+F1_DOC))

//While (! Eof())                         .And. ;
	  (SF1->F1_FORNECE == E2_FORNECE) 	.And. ;
  	  (SF1->F1_LOJA == E2_LOJA) 	 	.And. ;
  	  (SF1->F1_PREFIXO == E2_PREFIXO) 	.And. ;
  	  (SF1->F1_DOC == E2_NUM) 	

   	IF SE2->E2_TIPO == "NF "  .AND. cRet=''                           
	  cRet := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
	Endif	
	
 //	dbskip()
//Enddo	  

dbSelectArea("SE2")
dbSetOrder(18)
If dbSeek(cTipISS+cRet) 
   cCod := SE2->(E2_FORNECE+E2_LOJA) 
EndIf 

RestArea(aAreaOld) 

Return(cCod)



