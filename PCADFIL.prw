#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} PCADFIL
PE para a consulta de pedidos no historico de compras (MaComView)
Altera o SQL de consulta para buscar todas as filiais.

@protected
@author    Rodrigo Carvalho
@since     26/08/2015
@obs       Especifico Topmix. SQL Padrao: cQryPed  := ParamIxb[1] 

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------

User Function PCADFIL()

Local cQryPed  := ParamIxb[1]

If MsgYesNo(OemToAnsi("Deseja consultar todas as filiais (S/N)"))

   cQryPed := "SELECT * FROM "+RetSqlName("SC7")+" WHERE C7_PRODUTO='"+SB1->B1_COD+"' AND D_E_L_E_T_ <> '*' ORDER BY C7_FILIAL,C7_DATPRF DESC" 
   
   SetKey( VK_F11, { || U_UMaViewPC() })
   
Endif   

Return(cQryPed)
				 


//-------------------------------------------------------------------
/*/{Protheus.doc} CTADFIL
PE para a consulta da cotacao. (MaComView)
Altera o SQL de consulta para buscar todas as filiais.

@protected
@author    Rodrigo Carvalho
@since     26/08/2015
@obs       Especifico Topmix. SQL Padrao: cQryPed  := ParamIxb[1] 

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------

User Function CTADFIL()

Local cQryCot  := ParamIxb[1]

If MsgYesNo(OemToAnsi("Deseja consultar todas as filiais (S/N)"))

   cQryCot := "SELECT * FROM "+RetSqlName("SC8")+" WHERE C8_PRODUTO='"+SB1->B1_COD+"' AND C8_PRECO <> 0  AND D_E_L_E_T_ <> '*' ORDER BY C8_FILIAL,C8_DATPRF DESC"

Endif

Return(cQryCot)					





//-------------------------------------------------------------------
/*/{Protheus.doc} PCADLINE
PE para acrescentar um campo na tela de consulta de pedidos (MaComView)

@protected
@author    Rodrigo Carvalho
@since     26/08/2015
@obs       Especifico Topmix. 

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function PCADLINE() 

Local aRet := ParamIxb 
  
Aadd(aRet,C7_FILIAL)   

Return(aRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} PCADHEAD
PE para a consulta de pedidos (MaComView)

@protected
@author    Rodrigo Carvalho
@since     26/08/2015
@obs       Especifico Topmix. SQL Padrao: cQryPed  := ParamIxb[1] 

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function PCADHEAD()   

Local aRet := ParamIxb   

Aadd(aRet, RetTitle("C7_FILIAL"))   

Return(aRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} CTADLINE
Adiciona dados nas colunas da tela de Últimas Cotações

@protected
@author    Rodrigo Carvalho
@since     26/08/2015
@obs       Especifico Topmix. SQL Padrao: cQryPed  := ParamIxb[1] 

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function CTADLINE()   

Local aRet := ParamIxb   

Aadd(aRet,C8_FILIAL)     

Return(aRet)




//-------------------------------------------------------------------
/*/{Protheus.doc} CTADCOLH
PE para acrescentar um campo na tela de consulta de cotacao (MaComView)

@protected
@author    Rodrigo Carvalho
@since     26/08/2015
@obs       Especifico Topmix. 

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function CTADCOLH()

Local aRet := ParamIxb 

Aadd(aRet, RetTitle("C8_FILIAL")) 

Return(aRet)




//-------------------------------------------------------------------
/*/{Protheus.doc} UMaViewPC
PE para a consulta de pedidos (MaComView)

@protected
@author    Rodrigo Carvalho
@since     26/08/2015
@obs       Especifico Topmix.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function UMaViewPC()

Local   aArea		:= GetArea()
Local   aAreaSC7	:= SC7->(GetArea())
Local   aAreaSB1	:= SB1->(GetArea())
Local   nCol      := 0
Local   cFilPar   := ""
Local   cPedPar   := ""

Private aRotina	:= {{ , , 0 , 2 }}
Private nTipoPed	:= 1
Private l120Auto	:= .F.

If Type("oListBox") <> "O"
   Return .T.
Endif   

Set Key VK_F11	To      

nCol := aScan( oListBox:AHeaders , RetTitle("C7_FILIAL") ) // localiza o campo filial no aheader
   
If nCol <= 0
   nCol := 10  // default
Endif   

cFilPar := aViewSC7[oListBox:nAT][ncol]   
cPedPar := aViewSC7[oListBox:nAT][1]
   
If ! Empty(cFilPar) .And. ! Empty(cPedPar)

   dbSelectArea("SC7")
   dbSetOrder(1)

   If MsSeek( cFilPar + cPedPar )

      cFilOld1 := cFilAnt
      cFilAnt  := cFilPar
	   MatA120(SC7->C7_TIPO,,,2)
   	cFilAnt := cFilOld1

   EndIf

Endif

RestArea(aAreaSC7)
RestArea(aAreaSB1)
RestArea(aArea)

SetKey( VK_F11, { || U_UMaViewPC() })

Return(.T.)