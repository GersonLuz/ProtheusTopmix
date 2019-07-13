#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"

Static __cMbrRstFilter

/*/
 Funcao:  BrwLegenda
 Autor:  Marinaldo de Jesus
 Data:  22/04/2011
 Descricao: Legenda de Cores
 Sintaxe: StaticCall( u_mBrowseLFilter , BrwLegenda , cTitulo , cMensagem , aLegend , bAction , cMsgAction )
/*/
Static Function BrwLegenda( cTitulo , cMensagem , aLegend , bAction , cMsgAction )

 Local aListBox

 Local nItem
 Local nItens

 Local oDlg
 Local oFont
 Local oListBox

 BEGIN SEQUENCE

  DEFAULT aLegend  := {}
  nItens     := Len( aLegend )
  
  IF ( nItens == 0 )
   BREAK
  EndIF

  DEFAULT cTitulo  := "BrwLegenda"
  DEFAULT cMensagem := ""
  DEFAULT bAction  := { |cResName| !Empty( cResName ) }
  DEFAULT cMsgAction := ""

  aListBox := Array( nItens , 3 )
  For nItem := 1 To nItens
   aListBox[ nItem ][ 1 ] := LoadBitmap( GetResources() , aLegend[ nItem ][ 1 ] )
   aListBox[ nItem ][ 2 ] := aLegend[ nItem ][ 2 ]
  Next nItem 

  DEFINE MSDIALOG oDlg FROM 0,0 TO 345,410 TITLE OemToAnsi( cTitulo ) OF GetWndDefault() PIXEL

   DEFINE FONT oFont NAME "Arial" SIZE 0, -13 BOLD

   @ 03 , 05 SAY OemToAnsi( cMensagem ) OF oDlg PIXEL SIZE 200 , 010 FONT oFont
   @ 11 , 05 TO 012 , 200 LABEL "" OF oDlg PIXEL

   @ 15 , 05 LISTBOX oListBox FIELDS HEADER " ", "Status" SIZE 200 , 150 OF oDlg PIXEL

   oListBox:SetArray( aListBox )
   oListBox:bLDblClick   := { || Eval( bAction , aLegend[ oListBox:nAt][ 1 ] ) , oDlg:End() }
   oListBox:bLine    := { || { aListBox[ oListBox:nAt ][ 01 ] , aListBox[ oListBox:nAt ][ 02 ] }  }
   oListBox:cToolTip   := OemToAnsi( cMsgAction )
   oListBox:Refresh()

  ACTIVATE MSDIALOG oDlg CENTERED

 END SEQUENCE  

Return( NIL )

/*/
 Funcao:  BrwGetSLeg
 Autor:  Marinaldo de Jesus
 Data:  22/04/2011
 Descricao: Retornar o Status  conforme Array de Cores da mBrowse
 Sintaxe: StaticCall( u_mBrowseLFilter , BrwGetSLeg , cAlias , bGetColors , bGetLegend , cResName , lArrColors )
/*/
Static Function BrwGetSLeg( cAlias , bGetColors , bGetLegend , cResName , lArrColors )

 Local cBmpColor  := ""

 Local lFilter  := ( ValType( cResName ) == "C" )

 Local nLoop
 Local nLoops

 Local uC1Ret

 Private __aColors_ := {}
 Private __aLegend_ := {}

 TRYEXCEPTION
  Eval( bGetColors )  //Obtem __aColors_
 ENDEXCEPTION

 TRYEXCEPTION
  Eval( bGetLegend )  //Obtem __aLegend_
 ENDEXCEPTION

 BEGIN SEQUENCE

  DEFAULT lArrColors := .F.
  IF ( lArrColors )
   uC1Ret := { __aColors_ , __aLegend_ }
   BREAK
  EndIF

  TRYEXCEPTION
   IF ( lFilter )
    cResName := Upper( AllTrim( cResName ) )
   EndIF
   DEFAULT cAlias := Alias()
   nLoops := Len( __aColors_ )
   For nLoop := 1 To nLoops
    IF ( lFilter )
     cBmpColor  := Upper( AllTrim( __aColors_[ nLoop ][ 2 ] ) )
     nPosBmp   := aScan( __aLegend_ , { |aBmpLeg| Upper( AllTrim( aBmpLeg[ 1 ] ) ) == cBmpColor } )
     IF !( nPosBmp == 0 )
      uC1Ret := __aColors_[ nLoop ][ 1 ]       //Obtem a Condicao de Filtro
     EndIF 
    Else
     IF ( cAlias )-&gt;( &amp;( __aColors_[ nLoop ][ 1 ] ) )    //Analisa a Condicao
      cBmpColor  := Upper( AllTrim( __aColors_[ nLoop ][ 2 ] ) )
      nPosBmp   := aScan( __aLegend_ , { |aBmpLeg| Upper( AllTrim( aBmpLeg[ 1 ] ) ) == cBmpColor } )
      IF !( nPosBmp == 0 )
       uC1Ret := OemToAnsi( __aLegend_[ nPosBmp ][ 2 ] )  //Obtem a Descricao
      EndIF 
      Exit
     EndIF
    EndIF
   Next nLoop
   DEFAULT uC1Ret := ""
  CATCHEXCEPTION
   uC1Ret := ""
  ENDEXCEPTION    

 END SEQUENCE

Return( uC1Ret )

/*/
 Funcao:  BrwFiltLeg
 Autor:  Marinaldo de Jesus
 Data:  22/04/2011
 Descricao: Filtra o Browse de acordo com a Opcao da Legenda da mBrowse
 Sintaxe: StaticCall( u_mBrowseLFilter , BrwFiltLeg , cAlias , aColors , aLegend , cTitle , cMsg , cMsgAction , cVarName )
/*/
Static Function BrwFiltLeg( cAlias , aColors , aLegend , cTitle , cMsg , cMsgAction , cVarName )

 Local aIndex

 Local bAction := { |cResName| cBmpName := cResName }
 
 Local cBmpName
 Local cExpFilter
 Local cSvExprFilTop
 
 Local nBmpPos

 BrwLegenda( OemToAnsi( cTitle ) , OemToAnsi( cMsg ) , @aLegend , bAction , OemToAnsi( cMsgAction ) )

 nBmpPos   := aScan( aColors , { |aBmp| Upper( AllTrim( aBmp[2] ) ) == cBmpName } )
 IF ( nBmpPos &gt; 0 )
  cExpFilter := aColors[ nBmpPos ][ 1 ]
 Else
  cExpFilter := ""
 EndIF

 cSvExprFilTop := ( cAlias )-&gt;( dbFilter() )
 __cMbrRstFilter := cSvExprFilTop
 IF ( Type( cVarName ) == "C" )
  &amp;( cVarName ) := cSvExprFilTop
 EndIF

 aIndex   := {}
 EndFilBrw( cAlias , @aIndex )
 ( cAlias )-&gt;( dbClearFilter() )
 bFiltraBrw   := { || FilBrowse( cAlias , @aIndex , @cExpFilter ) }
 Eval( bFiltraBrw )

 oObjBrow := GetObjBrow()
 oObjBrow:ResetLen()
 oObjBrow:GoTop()
 oObjBrow:Refresh()

Return( cSvExprFilTop )

/*/
 Funcao:  MbrRstFilter
 Autor:  Marinaldo de Jesus
 Data:  22/04/2011
 Descricao: Restaura o Filtro de Browse
 Sintaxe: StaticCall( u_mBrowseLFilter , MbrRstFilter, cAlias , cVarName )
/*/
Static Function MbrRstFilter( cAlias , cVarName )
 
 Local aIndex
 Local oObjBrow
 Local cMbrRstFilter
 
 IF ( ( ValType( cVarName )== "C" ) )
  cMbrRstFilter := &amp;( cVarName )
 Else
  cMbrRstFilter := &amp;( __cMbrRstFilter )
 EndIF

 aIndex   := {}
 EndFilBrw( cAlias , @aIndex )
 ( cAlias )-&gt;( dbClearFilter() )
 bFiltraBrw   := { || FilBrowse( cAlias , @aIndex , @cMbrRstFilter ) }
 Eval( bFiltraBrw )

 oObjBrow := GetObjBrow()
 oObjBrow:ResetLen()
 oObjBrow:GoTop()
 oObjBrow:Refresh()

Return( NIL )

/*/
 Funcao:  __Dummy
 Autor:  Marinaldo de Jesus
 Data:  22/04/2011
 Descricao: __Dummy (nao faz nada, apenas previne warning de compilacao)
 Sintaxe: 
/*/
Static Function __Dummy( lRecursa )
 Local oException
 TRYEXCEPTION
  DEFAULT lRecursa := .F.
  IF !( lRecursa )
   BREAK
  EndIF
  BrwLegenda()
  BrwGetSLeg()
  BrwFiltLeg()
  MbrRstFilter()
  lRecursa := __Dummy( .F. )
 CATCHEXCEPTION USING oException
 ENDEXCEPTION
Return( lRecursa )

