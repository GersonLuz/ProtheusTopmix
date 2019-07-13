#include "rwmake.ch"        

/*
+-------------------------------------------------------------------+
|Programa | GP670CPO | Autor  Juliana Hilarina   | Data |  11/10/06 |
|---------+---------------------------------------------------------|
|Desc.    |Ponto de Entrada para gravar informacao da Folha para os |       
|         |Titulos a Pagar gerados pela FOLHA                       |      
|---------+---------------------------------------------------------|        
|Uso      |                                                         |
|         |                                                         |        
+-------------------------------------------------------------------+

*/

User Function GP670CPO()

cHist := "PG "+ALLTRIM(RC1->RC1_DESCRI) +" REF."+SUBS(DTOC(RC1->RC1_EMISSAO),4,7)+" "
cNome := IIF(RC1->RC1_MAT <> '',Posicione("SRA",1,xFilial("SRA")+RC1->RC1_MAT,"RA_NOME"),"")
cHist := cHist + cNome

dbSelectArea("SE2")
SE2->(dbSetOrder(1))
If DbSeek(xFilial("SE2") +RC1->(RC1_PREFIX+RC1_NUMTIT+RC1_PARC+RC1_TIPO+RC1_FORNEC+RC1_LOJA), .T. )
   RecLock("SE2",.F.)
   REPLACE SE2->E2_HIST        WITH cHist
   REPLACE SE2->E2_CCD         WITH RC1->RC1_CC
   REPLACE SE2->E2_ZTITPRO     WITH "N"        
   REPLACE SE2->E2_CODRET      WITH RC1->RC1_CODIR
   SE2->(MsUnlock())
Endif

Return()