#include "Protheus.ch"
#include "Rwmake.ch"         
//--------------------------------------------------------------
/*/{Protheus.doc} MCMTR150

Chamadas das rotinas padrões do protheus para o compras

@param  
@author Rodrigo Carvalho
@since  15/12/2015
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
User Function MCMTR150( cAlias, nRegSC8 , nOpcX )

DbSelectArea("SC1")
cAuxFilter := "(SC1->C1_FILIAL == SC8->C8_FILIAL)" 
aIndexSC1  := {}
bFiltraBrw := {|| FilBrowse("SC1",@aIndexSC1,@cAuxFilter) }
Eval(bFiltraBrw)   
SET FILTER TO &(cAuxFilter)                               
           
dbSelectArea("SC8")
dbSetOrder(1)

cFilOld := cFilAnt
cFilAnt := SC8->C8_FILIAL

A130Impri(SC8->C8_NUM)

cFilAnt := cFilOld      
  	   
SetsDefault()

If ! Empty(cFilterSC1)
   DbSelectArea("SC1")
   cAuxFilter := "("+cFilterSC1+")" 
   aIndexSC1  := {}
   bFiltraBrw := {|| FilBrowse("SC1",@aIndexSC1,@cAuxFilter) }
   Eval(bFiltraBrw)   
   SET FILTER TO &(cAuxFilter)
   DbSelectArea("SB8")
Endif

Return .T.