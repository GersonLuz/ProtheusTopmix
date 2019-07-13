#include "rwmake.ch"        

/*
+-------------------------------------------------------------------+
|Programa | MTA130C8 | Autor  Juliana            | Data |  20/09/06 |
|---------+---------------------------------------------------------|
|Desc.    |Ponto de Entrada para gravar informacao C1 p/ C8         |       
|         |                                                         |      
|---------+---------------------------------------------------------|        
|Uso      |Topmix                                                   |
|         |                                                         |        
+-------------------------------------------------------------------+

*/

User Function MTA130C8()  

Local cExcecao := "FPNLCOM/MATA150/MATA130" 

	dbSelectArea("SC8")
	RecLock("SC8",.F.)
	Replace C8_OP      With SC1->C1_OP
	Replace C8_CC      With SC1->C1_CC
	Replace C8_ZDESCRI With SC1->C1_DESCRI 
	Replace C8_ZEMAIL  With SA2->A2_EMAIL
	Replace C8_ZFILFAT With SC1->C1_ZFILFAT
	Replace C8_ZMARCA  With SC1->C1_ZMARCA
	Replace C8_OBS     With SC1->C1_OBS
	Replace C8_ZOBSADI With SC1->C1_ZOBSADI
	Replace C8_ZHORA   With Time()
	Replace C8_ZUSER	 With RetCodUsr()
	Replace C8_ZDENTRE With SC1->C1_DATPRF
	Replace C8_ZQUANTI With SC8->C8_QUANT
	Replace C8_ZTIPOPR With SC1->C1_ZTIPOPR // produto original.
	Replace C8_ZSTATUS With "3" 
	If Type("C8_ZAPLIC") <> "U"
      Replace C8_ZAPLIC  With SC1->C1_ZAPLIC
   Endif   
	If Type("C8_ZAPLIC") <> "U"
      Replace C8_ZSOLIC  With SC1->C1_SOLICIT // produto original.
	Endif
//	Replace C8_ZPRDSUB  //If(aCols[n,15] = 'S',SB1->B1_COD =  aCols[n,14], SB1->B1_ZREF1 = aCols[n,3])
//	Replace C8_ZTODESC
	SC8->(MsUnlock())

If ! FunName() $ cExcecao
   IIf(GdFieldGet("C8_ZTIPOPR",N) == "S",SB1->B1_COD == GdFieldGet("C8_PRODUTO",N), SB1->B1_ZREF1 = aCols[n,3])
Endif
	
Return
