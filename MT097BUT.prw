#Include "Protheus.ch"
#include "rwmake.ch"     
//-------------------------------------------------------------------
/*/{Protheus.doc} MT097BUT
Informações do pedido de compra na tela de liberação de doctos.

@protected
@author    Rodrigo Carvalho
@since     02/02/2016
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 
User Function MT097BUT()

Local   cSavAlias  := Alias()
Local   cSavOrd    := IndexOrd()
Local   cSavReg    := RecNo()
Local   nOpcx      := 2

Private nTipoPed   :=  1   // 1 - Ped. Compra 2 - Aut. Entrega
Private l120Auto   := .F.

SetKey(VK_F4,{|| U_FSALDOPRD()})  

DbSelectArea("SC7")
dbSetOrder(1)
If MsSeek(xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM)))
   
   cRecSCR := SCR->(Recno())
   
   If Type("oBrwSC1") == "O" .And. Type("oBrwSC8") == "O"

      //oBrwSC1:SetFilter Default( "SC1->C1_NUM == SC7->C7_NUMSC .And. SC1->C1_FILIAL == SC7->C7_FILIAL" )
      //oBrwSC1:ChangeTopBot(.T.)

      DbSelectArea("SC1")
      cAuxFilter := "(SC1->C1_NUM == SC7->C7_NUMSC .And. SC1->C1_FILIAL == SC7->C7_FILIAL)" 
      aIndexSC1  := {}
      bFiltraBrw := {|| FilBrowse("SC1",@aIndexSC1,@cAuxFilter) }
      Eval(bFiltraBrw)   
      SET FILTER TO &(cAuxFilter) 

      //oBrwSC8:SetFilter Default( "SC8->C8_NUM == SC7->C7_NUMCOT .And. SC8->C8_FILIAL == SC7->C7_FILIAL" )
      //oBrwSC8:ChangeTopBot(.T.)

      DbSelectArea("SC8")
      cAuxFilter := "(SC8->C8_NUM == SC7->C7_NUMCOT .And. SC8->C8_FILIAL == SC7->C7_FILIAL)" 
      aIndexSC8  := {}
      bFiltraBrw := {|| FilBrowse("SC8",@aIndexSC8,@cAuxFilter) }
      Eval(bFiltraBrw)   
      SET FILTER TO &(cAuxFilter) 
   
   Endif
   
   cFilOld := cFilAnt
   cFilAnt := SC7->C7_FILIAL
   
	A097Visual("SCR",cRecSCR,2)

   cFilAnt := cFilOld      

   If Type("oBrwSC1") == "O" .And. Type("oBrwSC8") == "O"

      //oBrwSC1:SetFilter Default( cFilterSC1 )
      //oBrwSC1:ChangeTopBot(.T.)
      
      DbSelectArea("SC1")
      cAuxFilter := "("+cFilterSC1+")" 
      aIndexSC1  := {}
      bFiltraBrw := {|| FilBrowse("SC1",@aIndexSC1,@cAuxFilter) }
      Eval(bFiltraBrw)   
      SET FILTER TO &(cAuxFilter)
      
      //oBrwSC8:SetFilter Default( cFilterCT )
      //oBrwSC8:ChangeTopBot(.T.)

      DbSelectArea("SC8")
      cAuxFilter := "("+cFilterCT+")" 
      aIndexSC8  := {}
      bFiltraBrw := {|| FilBrowse("SC8",@aIndexSC8,@cAuxFilter) }
      Eval(bFiltraBrw)   
      SET FILTER TO &(cAuxFilter)
   
   Endif
   
   DbSelectArea("SCR")
   SCR->(DbGoto(cRecSCR))
   
EndIf

Set Key VK_F4 To

dbSelectArea(cSavAlias)
dbSetOrder(cSavOrd)
dbGoto(cSavReg)

Return .T.




//-------------------------------------------------------------------
/*/{Protheus.doc} FSALDOPRD
Informa o saldo do produto

@protected
@author    Rodrigo Carvalho
@since     10/09/2014
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 
User Function FSALDOPRD()

Local aArea    := GetArea()
Local nPosProd := aScan(aHeader,{|x| Trim(x[2])=="C7_PRODUTO"})
Local cCodProd := aCols[n][nPosProd]
             
MaViewSB2(cCodProd)    

RestArea(aArea)
Return .t.
