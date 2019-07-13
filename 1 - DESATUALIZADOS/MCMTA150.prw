#INCLUDE "PROTHEUS.CH"

#DEFINE VALMERC 	1  // Valor total do mercadoria
#DEFINE VALDESC 	2  // Valor total do desconto
#DEFINE VALIPI  	3  // Valor total do IPI
#DEFINE VALICM  	4  // Valor total do ICMS
#DEFINE FRETE   	5  // Valor total do Frete
#DEFINE VALDESP 	6  // Valor total da despesa
#DEFINE TOTF1		7  // Total de Despesas Folder 1
#DEFINE TOTPED		8  // Total do Pedido
#DEFINE BASEIPI 	9  // Base de IPI
#DEFINE BASEICM   10 // Base de ICMS
#DEFINE BASESOL   11 // Base do ICMS Sol.
#DEFINE VALSOL		12 // Valor do ICMS Sol.
#DEFINE VALCOMP 	13 // Valor do ICMS Com.
#DEFINE SEGURO		14 // Valor total do seguro
#DEFINE TOTF3		15 // Total utilizado no Folder 3

//--------------------------------------------------------------
/*/{Protheus.doc} MCCOTPAD

Chamadas das rotinas padrões do protheus para o compras

@param  
@author Rodrigo Carvalho
@since  15/12/2015
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------

User Function MCMTA150( cAlias, nRegSC8 , nOpcX )

Local aAliasOLD    := GetArea()
Local aGrupo 		 := {}
Local cGrupComp	 := ""
Local cFiltraSc8	 := ""
Local cFilUser		 := ""
Local nX           := 0
Local aCores		 := {}
Local lSolic		 := (GetMv("MV_RESTCOM")=="S")
Local aCorUsr      := {}
Local nCnt         := 0
Local nCntFor		 := 0
Local cLoop1       := ""
Local cLoop2       := ""
Local cCotACC		 := "(SC8->(FieldPos('C8_ACCNUM'))>0 .And. !Empty(SC8->C8_ACCNUM) .And. Empty(SC8->C8_NUMPED))"
Local aFixe 		 :={{ OemToAnsi("Numero")      , "C8_NUM"     },;		//
						    { OemToAnsi("Fornecedor")  , "C8_FORNECE" },;		//
						    { OemToAnsi("Loja")        , "C8_LOJA"    },;		//
						    { OemToAnsi("Proposta")    , "C8_NUMPRO"  },;		//
  						    { OemToAnsi("Cod.Produto") , "C8_PRODUTO" },;		//
						    { OemToAnsi("Preco")       , "C8_PRECO"   },;		//
						    { OemToAnsi("Validade ")   , "C8_VALIDA"  }}		//

Private cCadastro	 := "Atualizacao Precos da Cotacao"
Private aRotina	 := MenuDef()
Private l150Auto	 := .f.
Private lOnUpdate  := .T.
Private aAutoCab	 := {}
Private aAutoItens := {}
Private lGrade     := MaGrade()
Private cFornBKP   := ""
Private cLojBKP    := ""
Private lTrm       := .F.
Private xRecno     := ""   

Aadd( aCores , { "Empty(C8_NUMPED) .And. C8_PRECO <> 0",'BR_VERDE' } )   //Cotacao em aberto
Aadd( aCores , { "! Empty(C8_NUMPED)",'DISABLE'} )				             //Cotacao Baixada
Aadd( aCores , { "Empty(C8_NUMPED) .And. C8_PRECO == 0",'BR_AMARELO' })  //Cotacao nao digitada

If lChkGer
   Pergunte("MTA150",.T.)
Else
   Pergunte("MTA150",.F.)
Endif

DbSelectArea("SC8")
cFiltraSc8 := "C8_NUMPED = ' '"
aIndexSC8  := {}
bFiltraBrw := {|| FilBrowse("SC8",@aIndexSC8,@cFiltraSC8) }
Eval(bFiltraBrw)

DbSelectArea("SC8")
DbSetOrder(1)
DbGoto(nRegSC8)

If nOpcX == 5 .And. ! Empty(SC8->C8_ZUSER) .And. SC8->C8_ZUSER <> cCodUser
   ApMsgAlert("Somente o usuário: "+Alltrim(UsrFullName(SC8->C8_ZUSER))+", está autorizado a excluir essa cotação!")
   Return .F.   
Endif

cFilOld  := cFilAnt
cFilAnt  := SC8->C8_FILIAL
cLoop1   := SC8->(C8_FILIAL+C8_NUM)

DbSelectArea("SC1") 
SC1->(DBClearFilter())
oBrwSC1:SetFilterDefault( "SC1->C1_FILIAL == '"+SC8->C8_FILIAL+"'" )
DbSetOrder(1)
SC1->(DbGoTop())

DbSetOrder(1)
If ! DbSeek( SC8->(C8_FILIAL + C8_NUMSC) , .T. )
   ApMsgAlert("Aviso, Solicitação: "+xFilial("SC1") +" / "+ SC8->C8_NUMSC+" não encontrado!")
Endif

DbSelectArea("SC8")
Do While cLoop1 == SC8->(C8_FILIAL+C8_NUM) .And. ! Eof()     

   lRetDig := A150Digita("SC8",SC8->(Recno()),nOpcX) // Chamada da rotina
  
   If ! lChkSC8 .Or. nOpcX <> 3
      Exit
   Endif   

   cLoop2  := SC8->(C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA)
   
   Do While ! SC8->(Eof()) .And. cLoop2 == SC8->(C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA)
      SC8->(DbSkip())                      
   Enddo

Enddo   

DbSelectArea("SC8")
DbGoto(nRegSC8)

DbSelectArea("SC1")
cAuxFilter := "("+cFilterSC1+")" 
aIndexSC1  := {}
bFiltraBrw := {|| FilBrowse("SC1",@aIndexSC1,@cAuxFilter) }
Eval(bFiltraBrw)   
SET FILTER TO &(cAuxFilter)

DbSelectArea("SC8")
cFilAnt := cFilOld

SysRefresh()
            
RestArea(aAliasOLD)     

Return .T.
