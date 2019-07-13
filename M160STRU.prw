#Include "Rwmake.ch"
#include "Protheus.ch"
//-------------------------------------------------------------------
/* {Protheus.doc} M160STRU

@protected
@author    Rodrigo Carvalho
@since     10/03/2015
@obs       Acrescenta Campos no arquivo temporário 
           (< aStru> , < aCabec> , < aCpoSC8> ) 

           Nome      Descrição			
           aStru     Estrutura do arquivo temporário
           aCabec    Estrutura do cabeçalho das planilhas
           aCpoSC8   Array contendo os campos das planilhas

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
             
User Function M160STRU()

Local aArea    := GetArea()
Local cFntPad  := "MATA160/FPNLCOM"
Local aStr     := PARAMIXB[1]
Local aCabec1  := PARAMIXB[2]
Local aCpoSC81 := PARAMIXB[3]

Local aStrNew := {}
Local aCabNew := {}
Local aCpoNew := {}   

Local cCampo  := ""
Local nXy     := 1

aAdd(aCpoNew,"PLN_OK"     )
aAdd(aCpoNew,"PLN_FORNECE")
aAdd(aCpoNew,"PLN_LOJA"   )
aAdd(aCpoNew,"PLN_NREDUZ" )
aAdd(aCpoNew,"PLN_QUANT"  )
aAdd(aCpoNew,"PLN_PRECO"  )
aAdd(aCpoNew,"PLN_TOTAL"  )
aAdd(aCpoNew,"PLN_DESCRI" )
aAdd(aCpoNew,"PLN_COND"   )
aAdd(aCpoNew,"PLN_DATPRF" )
aAdd(aCpoNew,"PLN_DATPRZ" )
aAdd(aCpoNew,"PLN_VLDESC" )
aAdd(aCpoNew,"PLN_NUMPRO" )
aAdd(aCpoNew,"C8_ZOBSADI")

For nXy := 1 To Len(aCpoSC81)             
    nPos := aScan( aCpoNew , aCpoSC81[nXy] )
    If nPos == 0 // campo nao existe na nova estrutura.
       aAdd(aCpoNew,aCpoSC81[nXy])
    Endif
Next       

DbSelectArea("SX3")	
DbSetOrder(2)	
 
For nXy := 1 To Len(aCpoNew)
    nPos := aScan( aCpoSC81 , aCpoNew[nXy] )
    If nPos > 0
       aadd(aStrNew,aStr[nPos]  )		
       aadd(aCabNew,aCabec1[nPos])
    Else
       cCampo := StrTran(aCpoNew[nXy],"PLN_","C8_")
       If dbSeek(cCampo)
          aadd(aStrNew ,{aCpoNew[nXy],SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})		
          aadd(aCabNew ,{aCpoNew[nXy],"",RetTitle(cCampo),PesqPict("SC8",cCampo)})		
       Else
          ApMsgInfo("Falta o campo: "+cCampo+" no dicionario de dados! - Rotina: M160STRU()")    
       Endif       
    Endif   
Next

If Len(aStrNew) <> Len(aCpoNew) .Or. Len(aStrNew) <> Len(aCabNew)
   ApMsgInfo("Erro na estrutura dos novos campos!")    
   Return ( {aStr,aCabec1,aCpoSC81}  )
Endif

dbSelectArea("SX3")	
dbSetOrder(2)	
For nXy := 1 To Len(aCpoNew)
    nPos := aScan( aCpoSC81 , aCpoNew[nXy] )
    If nPos == 0
       aadd(aStr    , aStrNew[nXy] )		
       aadd(aCabec1 , aCabNew[nXy] )		
       aAdd(aCpoSC81, aCpoNew[nXy] )
   EndIf
Next           

RestArea(aArea)

Return IIf( FunName() $ cFntPad , {aStrNew,aCabNew,aCpoNew} , {aStr,aCabec1,aCpoSC81}  )
