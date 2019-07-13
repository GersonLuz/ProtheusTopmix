#Include "RwMake.ch" 
//-------------------------------------------------------------------
/* {Protheus.doc} MT110LOK
Valida se os produtos são do mesmo grupo na linha da solicitação de 
compras 

@protected
@author    Rodrigo Carvalho
@since     26/04/2016
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
                                           
User Function MT110LOK()

Local aArea    := GetArea()
Local nPosPrd  := aScan(aHeader,{|x| Rtrim(x[2]) == "C1_PRODUTO"}) 
Local nPosItem := aScan(aHeader,{|x| Rtrim(x[2]) == "C1_ITEM"})
Local nPosCCus := aScan(aHeader,{|x| Rtrim(x[2]) == "C1_CC"})
Local lRet     := .T.
Local lVldGrp  := SuperGetMv("MC_VLDGRUP",,.T.)
Local cGrpProd := ""   
Local cItem    := "" 

		
		If lVldGrp .And. Len(aCols) > 1
		   For nXy := 1 To Len(aCols)
		
		       If aCols[ Len(aCols) ][ Len(aHeader)+1 ]
		          Loop
		       Endif   
		       
		       cProduto := aCols[ nXy ][ nPosPrd ]  
		       cItem    := aCols[ nXy ][ nPosItem ]  
		   
		       DbSelectArea("SB1")
		       DbSetOrder(1)
		       DbSeek(xFilial("SB1") + cProduto )
		       
		       cGrpProd := IIf(Empty(cGrpProd),SB1->B1_GRUPO,cGrpProd)
		
		       If cGrpProd <> SB1->B1_GRUPO
		          Alert("O Grupo de produtos do item anterior ["+cGrpProd+"] não é igual ao grupo ["+SB1->B1_GRUPO+"] informado nesse registro! - Item: "+cItem)
		          lRet := .F.
		          Exit
		       Endif
		   Next
		Endif
              
RestArea(aArea)

Return( lRet )