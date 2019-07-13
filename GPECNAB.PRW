#include "rwmake.ch"        

/*
+------------------------------------------------------------------+
|Programa | GPECNAB  | Autor  Juliana Hilarina   | Data | 16/11/06 |
|---------+--------------------------------------------------------|
|Desc.    |Sequencia CNAB BENEFICIARIO - BRADFOL                   |       
|---------+--------------------------------------------------------|        
|Uso      |Topmix                                                  |
+------------------------------------------------------------------+

*/


User Function GPECNAB()        
                     
Local cDate:=DTOS(DATE())
Local cHora:=SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)
Local cSeq:=" "

cSeq:=cHora+cDate  
                    

Return(cSeq)                                                        