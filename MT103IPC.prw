#Include "RwMake.ch"   
/*-------------------------------------------------------------------
{Protheus.doc} MT103IPC
   Ponto de entrada no momento da amarracao pedido X nota.       

@protected
@author    Juliana
@since     12/05/2015
@obs        
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
12/05/15   Rodrigo Carvalho
*/
//-------------------------------------------------------------------
User Function MT103IPC()

Local cNumIteA   := PARAMIXB
Local nLinAcols  := PARAMIXB[01]                       

Local nPosOP     := aScan( aHeader ,{ |aAux1| AllTrim(aAux1[2] ) == "D1_OP"})
Local nPosCC     := aScan( aHeader ,{ |aAux1| AllTrim(aAux1[2] ) == "D1_CC"})
Local nPosDESC   := aScan( aHeader ,{ |aAux1| AllTrim(aAux1[2] ) == "D1_DESCRI"})
//Local nPosDESC1  := aScan( aHeader ,{ |aAux1| AllTrim(aAux1[2] ) == "D1_DESCRI1"})
Local nCodBem    := aScan( aHeader ,{ |aAux1| Alltrim(aAux1[2] ) == "D1_CODBEM"})

aCols[nLinAcols,nPosOP]    := SC7->C7_OP
aCols[nLinAcols,nPosCC]    := SC7->C7_CC 
aCols[nLinAcols,nPosDESC]  := SC7->C7_DESCRI 
//aCols[nLinAcols,nPosDESC1] := SC7->C7_DESCRI1 

If nCodBem > 0 .And. Type("SC7->C7_ZAPLIC") <> "U"
   ACols[nLinAcols,nCodBem] := SC7->C7_ZAPLIC
Endif

Return .t.
