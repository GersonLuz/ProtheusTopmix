#INCLUDE "RWMAKE.CH"                                                                                   
#INCLUDE "TOPCONN.CH"                                                                                                                     
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#include "TBICODE.CH"
#include 'Ap5Mail.ch' 

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 04/06/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM005                                  -
----------------------------------------------------------------------------------------
                        VISUALIZAR COTAÇÃO DO PEDIDO DE COMPRAS                        -
--------------------------------------------------------------------------------------*/ 

**************************************
User Function TPCOM005()
**************************************

Local oFont1    := TFont():New("Arial",,020,,.T.,,,,,.F.,.F.)
Local oFont3    := TFont():New("Arial",,016,,.T.,,,,,.F.,.F.)
Local oFont4    := TFont():New("Arial",,016,,.F.,,,,,.F.,.F.)
Local oGet1
Local oSay3
Local oButton1, oButton2
Private oSay1
Private oGet2
Private aResolu := getScreenRes()
Private nTotReg := 0
Private aBrowseC := {}
Private cCotacao   := aCol[oGetDados:nAt][13]                                
Private cFilCota   := aBrowse[oBrowse:nAt,01]
Private cProduto   := ""
Private cCodPro    := ""
Private oBrowseC
Private cUserID    := __CUSERID
Private aPosObj	   := {}
Private aSizeAut   := MsAdvSize(,.F.)
Private aObjects   := {}
Private aInfo 	   := {}
Private aProduto   := {}
Private nY         := 1 
Private nFornece   := 0
Private nPag       := 1
Private nProduto   := 0  

AAdd( aObjects, { 000, 070, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo  := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj:= MsObjSize( aInfo, aObjects )   
  

aSize := MsAdvSize(.F.)
 /*
 MsAdvSize (http://tdn.totvs.com/display/public/mp/MsAdvSize+-+Dimensionamento+de+Janelas)
 aSize[1] = 1 -> Linha inicial área trabalho.
 aSize[2] = 2 -> Coluna inicial área trabalho.
 aSize[3] = 3 -> Linha final área trabalho.
 aSize[4] = 4 -> Coluna final área trabalho.
 aSize[5] = 5 -> Coluna final dialog (janela).
 aSize[6] = 6 -> Linha final dialog (janela).
 aSize[7] = 7 -> Linha inicial dialog (janela).  */      
 TPCOM5C() // NÚMERO DE FORNECEDORES
                     
DEFINE MSDIALOG oDlgC TITLE "Cotação" FROM aSize[7],0 TO aSize[6],aSize[5] COLORS 0, 16777215 PIXEL

oDlgC:bInit := {||EnchoiceBar(oDlgC,{||oDlgC:End()},{|| oDlgC:End()},,)}

@ 040, 007 SAY oSay3 PROMPT "Numero da Cotação:" SIZE 081, 007 OF oDlgC FONT oFont3 COLORS 0, 16777215 PIXEL 
@ 037, 070 MSGET oGet1 VAR cCotacao SIZE 042, 011 OF oDlgC COLORS 0, 16777215 FONT oFont1 READONLY PIXEL WHEN .F.
@ 055, 007 SAY oSay1 PROMPT "Produto:" SIZE 081, 007 OF oDlgC FONT oFont3 COLORS 0, 16777215 PIXEL 
@ 052, 070 MSGET oGet2 VAR cProduto SIZE 350, 011 OF oDlgC COLORS 0, 16777215 FONT oFont1 READONLY PIXEL WHEN .F.
IF (aResolu[1] == 1440 .AND. aResolu[2] == 900) // MONITOR RESOLUÇÃO 1440 x 900
@ 075, 547 BUTTON oButton1 PROMPT "Anterior" SIZE 050, 010 OF oDlgC FONT oFont1 ACTION Eval({||TPCOM5D('A')}) PIXEL
oButton1:SetCSS("QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
@ 075, 600 BUTTON oButton2 PROMPT "Próximo" SIZE 050, 010 OF oDlgC FONT oFont1 ACTION Eval({||TPCOM5D('P')}) PIXEL
oButton2:SetCSS("QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
@ 075, 665 SAY oSay1 PROMPT CVALTOCHAR(nPag)+"/"+CVALTOCHAR(nProduto)+' '+"Produto(s):" SIZE 081, 007 OF oDlgC FONT oFont3 COLORS 0, 16777215 PIXEL 
ELSEIF (aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080
@ 075, 747 BUTTON oButton1 PROMPT "Anterior" SIZE 050, 010 OF oDlgC FONT oFont1 ACTION Eval({||TPCOM5D('A')}) PIXEL
oButton1:SetCSS("QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
@ 075, 800 BUTTON oButton2 PROMPT "Próximo" SIZE 050, 010 OF oDlgC FONT oFont1 ACTION Eval({||TPCOM5D('P')}) PIXEL
oButton2:SetCSS("QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
@ 075, 870 SAY oSay1 PROMPT CVALTOCHAR(nPag)+"/"+CVALTOCHAR(nProduto)+' '+"Produto(s):" SIZE 081, 007 OF oDlgC FONT oFont3 COLORS 0, 16777215 PIXEL
ELSE
@ 075, 447 BUTTON oButton1 PROMPT "Anterior" SIZE 050, 010 OF oDlgC FONT oFont1 ACTION Eval({||TPCOM5D('A')}) PIXEL
oButton1:SetCSS("QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
@ 075, 500 BUTTON oButton2 PROMPT "Próximo" SIZE 050, 010 OF oDlgC FONT oFont1 ACTION Eval({||TPCOM5D('P')}) PIXEL
oButton2:SetCSS("QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
@ 075, 570 SAY oSay1 PROMPT CVALTOCHAR(nPag)+"/"+CVALTOCHAR(nProduto)+' '+"Produto(s):" SIZE 081, 007 OF oDlgC FONT oFont3 COLORS 0, 16777215 PIXEL
ENDIF

TPCOM5B()
U_TPCOM5A(aCol[oGetDados:nAt][13],aBrowse[oBrowse:nAt,01])
   

//oBrowseC:Align := CONTROL_ALIGN_ALLCLIENT 

ACTIVATE MSDIALOG oDlgC CENTERED 

return

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 04/06/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM5A                                   -
----------------------------------------------------------------------------------------
                    FUNÇÃO PARA SELEÇÃO DO PEDIDO DE COMPRAS PENDENTE                   -
--------------------------------------------------------------------------------------*/ 

**************************************
User Function TPCOM5A()
**************************************

Local nX         
Local aHeaderEx  := {}
Local aColsEx    := {}
Local aHeaderHs  := {}
Local aColsHs    := {}
Local aFieldFill := {}
Local aFields      := {"C8_ITEM","A2_NOME","B1_ZREF1","C8_UM","C8_ZPRDSUB","C8_QUANT","C8_PRECO","C8_TOTAL","C8_ZDENTR","C8_ZOBSADI","C8_OBS","C8_ALIIPI","C8_PICM","C8_DESC","C8_VLDESC","C8_PRODUTO","C1_ZTIPOPR","C8_ZGANHAD","C8_DATPRF"}
Local nUsado       := Len(aFields)  

Local nPostTpPr		:= aScan(aFields,{|x| AllTrim(x) == "C1_ZTIPOPR"})
Local nPostZRef		:= aScan(aFields,{|x| AllTrim(x) == "B1_ZREF1"})
Local nPostForn		:= aScan(aFields,{|x| AllTrim(x) == "A2_NOME"})
  
Static oMSNewGe1
	// Define field properties
	DbSelectArea("SX3")
  	SX3->(DbSetOrder(2))
  	For nX := 1 to Len(aFields)
    	If SX3->(DbSeek(aFields[nX]))
      		Aadd(aHeaderEx, {IIF(AllTrim(X3Titulo()) == 'Item Cotacao','Item',AllTrim(X3Titulo())),SX3->X3_CAMPO,SX3->X3_PICTURE,;
      		           IIF(AllTrim(X3Titulo()) == 'Desc Produto',37,IIF(AllTrim(X3Titulo()) == 'Cod.Original',15,SX3->X3_TAMANHO)),;
      		           SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,;
      		           SX3->X3_CBOX,SX3->X3_RELACAO,SX3->X3_WHEN,SX3->X3_VISUAL,SX3->X3_VLDUSER,SX3->X3_PICTVAR,SX3->X3_OBRIGAT})            
	    Endif
  	Next nX
  	 
  	cCodProd := aProduto[nY]
  	dbSelectArea("SC8")
  	dbSetOrder(3)          
  	dbSeek(cFilCota+cCotacao+cCodProd)
  	While !Eof() .And. SC8->C8_FILIAL+SC8->C8_NUM+SC8->C8_PRODUTO == cFilCota+cCotacao+cCodProd 
                     
	  	aadd(aColsEx,Array(Len(aHeaderEx)+2))
		  
		cProduto:=Left(Posicione("SB1",1,xFilial("SB1")+SC8->C8_PRODUTO,"B1_DESC"),90)
		oGet2:refresh()                                                                                                 
		
		cCondPgto := SC8->C8_COND     
      		  
		For nX := 1 To Len(aHeaderEx)
			if !Alltrim(aHeaderEx[nx,2]) $ "C1_ZTIPOPR)"
		  		aColsEx[Len(aColsEx)][nX] :=  SC8->(FieldGet(FieldPos(aHeaderEx[nx,2]) ))
		 	endif
		Next nX                          
  		aColsEx[Len(aColsEx)][nPostTpPr] := Posicione("SC1",1,SC8->C8_FILIAL+SC8->C8_NUMSC+SC8->C8_ITEMSC,"C1_ZTIPOPR")
  		
  		aColsEx[Len(aColsEx)][nPostZRef] := Posicione("SB1",1,xFilial("SB1")+SC8->C8_PRODUTO,"B1_ZREF1")
  		aColsEx[Len(aColsEx)][nPostForn] := Posicione("SA2",1,xFilial("SA2")+SC8->C8_FORNECE+SC8->C8_LOJA,"A2_NOME")
	  	aColsEx[Len(aColsEx)][Len(aHeaderEx)+1] := SC8->(Recno())	
		aColsEx[Len(aColsEx)][Len(aHeaderEx)+2] := .F.	
		dbSelectArea("SC8")
		dbSkip()
  EndDo    
  
	 IF(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080
	  oBrowseC := MsNewGetDados():New( 090, 006, aPosObj[1,3]+330,aPosObj[1,4]-3, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+C8_ITEM",,, Len(aColsEx), "AllwaysTrue", "", "AllwaysTrue", oDlgC, aHeaderEx, aColsEx)		   
	 ELSEIF (aResolu[1] == 1440 .AND. aResolu[2] == 900) // MONITOR RESOLUÇÃO 1440 x 900
	  oBrowseC := MsNewGetDados():New( 090, 006, aPosObj[1,3]+260,aPosObj[1,4]-3, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+C8_ITEM",,, Len(aColsEx), "AllwaysTrue", "", "AllwaysTrue", oDlgC, aHeaderEx, aColsEx)		   
	 ELSE
	  oBrowseC := MsNewGetDados():New( 090, 006, aPosObj[1,3]+197,aPosObj[1,4]+5, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+C8_ITEM",,, Len(aColsEx), "AllwaysTrue", "", "AllwaysTrue", oDlgC, aHeaderEx, aColsEx)	
	 ENDIF
	
	  oBrowseC:oBrowse:Refresh()

Return

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 04/06/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM5B                                   -
----------------------------------------------------------------------------------------
                   FUNÇÃO PARA SELEÇÃO DOS PRODUTOS DA COTAÇÃO                        -
--------------------------------------------------------------------------------------*/ 

**************************************
Static Function TPCOM5B()
**************************************

Local cQuery := "" 

	cQuery :=" SELECT DISTINCT C8_PRODUTO " 
	cQuery +=" FROM "+RetSqlName("SC8")+ " SC8 "
	cQuery +=" WHERE C8_FILIAL = '"+cFilCota+"' "
	cQuery +=" AND C8_NUM =  '"+cCotacao+"' "
    cQuery +=" AND SC8.D_E_L_E_T_ <> '*' "
	cQuery +=" ORDER BY 1 "
				
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP", .T., .T.)                                      
			
	TMP->(dbGoTop())
	While !TMP->(EoF())
	 aadd(aProduto,TMP->C8_PRODUTO )
	TMP->(dbskip())
	EndDo
    
    nProduto := Len(aProduto)
    dbCloseArea()

return(aProduto)

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 04/06/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM5C                                   -
----------------------------------------------------------------------------------------
                   FUNÇÃO PARA SELEÇÃO DOS FORNECEDORES DA COTAÇÃO                    -
--------------------------------------------------------------------------------------*/ 

**************************************
Static Function TPCOM5C()
**************************************

Local cQuery := ""
 

	cQuery :=" SELECT DISTINCT C8_FORNECE " 
	cQuery +=" FROM "+RetSqlName("SC8")+ " SC8 "
	cQuery +=" WHERE C8_FILIAL = '"+cFilCota+"' "
	cQuery +=" AND C8_NUM =  '"+cCotacao+"' "
    cQuery +=" AND SC8.D_E_L_E_T_ <> '*' "
	cQuery +=" ORDER BY 1 "
				
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP", .T., .T.)                                      
			
	TMP->(dbGoTop())
	While !TMP->(EoF())
	 nFornece += 1
	TMP->(dbskip())
	EndDo

    dbCloseArea()

return(nFornece)

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 04/06/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM5D                                   -
----------------------------------------------------------------------------------------
                   FUNÇÃO PARA ALTERAÇÃO DA VISUALIZAÇÃO POR PRODUTO                   -
--------------------------------------------------------------------------------------*/ 

**************************************
Static Function TPCOM5D(cBot)
**************************************

Local cQuery := ""
 
   If(nPag <= nProduto) .AND. (cBot == 'A')  .AND. (nPag > 1)
    nPag -= 1
    If(nPag <> nProduto)
    nY := nY -=1
    IIF(nY == 0,nY := 1, nY)
    U_TPCOM5A()
    Endif
   Elseif (nPag < nProduto) .AND. (cBot == 'P') .AND. (nPag > 0)
    If(nPag <> nProduto)
    nPag += 1
    nY := nY +=1
    IIF (nY > Len(aProduto),nY := Len(aProduto), nY)
    U_TPCOM5A()
    Endif
   Endif
   oSay1:refresh()
    
return()