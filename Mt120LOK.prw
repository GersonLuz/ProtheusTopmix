//------------------------------------------------------------------- 
/*/{Protheus.doc} Mt120LOK
Ponto de entrada na confirmação da LINHA do pedido de compra.
     
@author	Rodrigo Carvalho
@since 21/09/2015
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
11/06/2013 Felipe Andrews  Filial do Parametro vinha com espacos
/*/ 
//------------------------------------------------------------------ 

User Function Mt120LOK()

Local lOk       := .T.        
Local nXy       := 1
Local nPosFlEnt := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_FILENT'})
Local nPosFil   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_FILIAL'})

For nXy := 1 To Len(Acols)
                                                                  '
    If ACols[ nXy , Len(aHeader) + 1]
       lOk := .F.
       ApMsgAlert("Não autorizado a exclusão de itens do pedido de compra! - Item: "+Alltrim(Str(nXy)))       
    Endif   
    
    If nPosFlEnt > 0 .And. nPosFil > 0 .And. Empty(ACols[ nXy , nPosFlEnt])
       ACols[ nXy , nPosFlEnt] := IIf( nPosFil > 0 .And. ! Empty(ACols[ nXy , nPosFil]) , ACols[ nXy , nPosFil] , xFilial("SC7") )
    Endif

Next

Return lOk