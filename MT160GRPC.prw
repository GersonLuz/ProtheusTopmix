#INCLUDE "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} MT160GRPC
Grava campos complementares no pedido de compra

@param  
@author Rodrigo Carvalho
@since  15/05/2016
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
User Function MT160GRPC()

//Local aAreaPE := GetArea()

DbSelectArea("SC1") 
DbSetOrder(1) // C1_FILIAL+C1_NUM+C1_ITEM
DbSeek(xFilial("SC1") + SC8->(C8_NUMSC + C8_ITEMSC) , .t. )

SC7->C7_ZOBSADI := IIF(SC7->C7_NUMCOT == SC8->C8_NUM , SC8->C8_ZOBSADI , SC7->C7_ZOBSADI )
SC7->C7_ZMARCOD := IIF(SC7->C7_NUMCOT == SC8->C8_NUM , SC8->C8_ZMARCA  , SC7->C7_ZMARCOD )
SC7->C7_DESCRI  := IIF(SC7->C7_NUMCOT == SC8->C8_NUM , SC8->C8_ZDESCRI , SC7->C7_DESCRI  )
SC7->C7_UM      := IIF(SC7->C7_NUMCOT == SC8->C8_NUM , SC8->C8_UM      , SC7->C7_UM      )           
SC7->C7_ZAPLIC  := IIf(SC7->C7_NUMCOT == SC8->C8_NUM , SC8->C8_ZAPLIC  , SC7->C7_ZAPLIC  ) 
SC7->C7_CC      := IIF(SC7->C7_NUMCOT == SC8->C8_NUM , SC8->C8_CC      , SC7->C7_CC      )
SC7->C7_OBS     := IIF(SC7->C7_NUMCOT == SC8->C8_NUM , SC8->C8_OBS     , SC7->C7_OBS     )
SC7->C7_FILENT  := IIf(SC7->C7_NUMSC  == SC1->C1_NUM , SC1->C1_FILENT  , SC7->C7_FILENT  )

If Empty(SC7->C7_ZOBSADI)
   SC7->C7_ZOBSADI := IIf(SC7->C7_NUMSC  == SC1->C1_NUM , SC1->C1_ZOBSADI , SC7->C7_ZOBSADI )
Endif

//RestArea(aAreaPE)

Return Nil   