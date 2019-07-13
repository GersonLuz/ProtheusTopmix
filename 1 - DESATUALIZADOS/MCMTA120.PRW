#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWADAPTEREAI.CH"

#DEFINE VALMERC  	 1  // Valor total do mercadoria 
#DEFINE VALDESC 	 2  // Valor total do desconto
#DEFINE FRETE   	 3  // Valor total do Frete
#DEFINE VALDESP 	 4  // Valor total da despesa
#DEFINE TOTF1		 5  // Total de Despesas Folder 1
#DEFINE TOTPED		 6  // Total do Pedido
#DEFINE SEGURO		 7  // Valor total do seguro
#DEFINE TOTF3		 8  // Total utilizado no Folder 3
#DEFINE IMPOSTOS   9  // Array contendo Os Valores de Impostos Exibidos no ListBox
#DEFINE NTRIB	   10  // Valor das despesas nao tributadas - Portugal
#DEFINE TARA      11  // Valor da Tara - Portugal
#DEFINE MAXGETDAD 999

//--------------------------------------------------------------
/*/{Protheus.doc} MCMTA120
Chamada da consulta do pedido de compras

@param  
@author Rodrigo Carvalho
@since  16/02/2016
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------

User Function MCMTA120(cAlias, nRegSC7 , nOpcX ) // MCMTA120(nFuncao,xAutoCab,xAutoItens,nOpcAuto,lWhenGet,xRatCTBPC,xAdtPC,xRatProj)
Local   aAliasOLD  := GetArea()
Local   aFixe      := {{"Numero do PC","C7_NUM"},{"Data Emissao","C7_EMISSAO"},{"Fornecedor","C7_FORNECE"}}
Local   aGrupo 	 := {}
Local   aIndexSC7	 := {}
Local   aCores     := {}
Local   aCoresUsr  := {}
Local   cFiltro	 := ""
Local   cFilQuery	 := ""  
Local   cMt120Fil  := ""
Local   nOrderSC7  := 0
Local   nPos		 := 0
Local   nX    	    := 0
Local   bBlock                                         
Local   uMt120Dft   

Private nFuncao    := 1
Private lWhenGet   := .F.

Private aBackSC7   := {}
Private aAutoCab   := {}
Private aAutoItens := {}
Private aRatCTBPC  := {}
Private aAdtPC     := {}
Private aRatProj   := {}

Private nAutoAdt   := 0
Private bFiltraBrw := {|| Nil }
Private nTipoPed   := nFuncao // 1 - Ped. Compra 2 - Aut. Entrega
Private cCadastro  := If(nTipoPed == 2 , "Autorizacao de Entrega" , "Pedidos de Compra")
Private l120Auto   := .F.
Private lPedido    := .T.
Private lGatilha   := .T.                          // Para preencher aCols em funcoes chamadas da validacao (X3_VALID)
Private lVldHead   := GetNewPar( "MV_VLDHEAD",.T. )// O parametro MV_VLDHEAD e' usado para validar ou nao o aCols (uma linha ou todo), a partir das validacoes do aHeader -> VldHead()

Private lIntGC     := .F.   
Private aRotina    := {}

aAdd(aCores,    { 'C7_TIPO!=nTipoPed'                       , 'BR_PRETO'  }) //-- Autorizacao de Entrega ou Pedido
aAdd(aCores,    { '!Empty(C7_RESIDUO)'                      , 'BR_CINZA'  }) //-- Eliminado por Residuo
aAdd(aCores,    { 'C7_CONAPRO=="B".And.C7_QUJE < C7_QUANT'	, 'BR_AZUL'   }) //-- Bloqueado
aAdd(aCores,    { 'C7_QUJE==0 .And. C7_QTDACLA==0'   		   , 'ENABLE'    }) //-- Pendente
aAdd(aCores,    { 'C7_QUJE<>0.And.C7_QUJE<C7_QUANT'			, 'BR_AMARELO'}) //-- Pedido Parcialmente Atendido
aAdd(aCores,    { 'C7_QUJE>=C7_QUANT'   					      , 'DISABLE'   }) //-- Pedido Atendido
aAdd(aCores,    { 'C7_QTDACLA >0' 							      , 'BR_LARANJA'}) //-- Pedido Usado em Pre-Nota

aAdd(aRotina,{"Pesquisar"   ,"PesqBrw"   , 0, 1, 0, .F. }) //
aAdd(aRotina,{"Visualizar"  ,"A120Pedido", 0, 2, 0, Nil }) //
aAdd(aRotina,{"Incluir"     ,"A120Pedido", 0, 3, 0, Nil }) //
aAdd(aRotina,{"Alterar"     ,"A120Pedido", 0, 4, 6, Nil }) //
aAdd(aRotina,{"Excluir"     ,"A120Pedido", 0, 5, 7, Nil }) //
aAdd(aRotina,{"Copia"       ,"A120Copia" , 0, 4, 0, Nil }) //
aAdd(aRotina,{"Imprimir"    ,"A120Impri" , 0, 2, 0, Nil }) //
aAdd(aRotina,{"Legenda"     ,"A120Legend", 0, 1, 0, .F. }) //
aAdd(aRotina,{"Conhecimento","MsDocument", 0, 4, 0, Nil }) //	

INCLUI   := .F.
ALTERA   := .F.
nOrderSC7:= 1

DbSelectArea("SC7")
DbGoto(nRegSC7)

cFilOld := cFilAnt
cFilAnt := SC7->C7_FILIAL
      
Do Case
   Case nOpcX == 1
        FPesqPC(nRegSC7,2) // consulta 2
   Case nOpcX == 2
        FPesqPC(nRegSC7,5) // excluir 5
   Case nOpcX == 3
        U_AFATR01( nRegSC7 )        // MATR110( "SC7", nRegSC7, 1 ) 
   Case nOpcX == 4
        A097Legend()
   Case nOpcX == 5
        U_AFATT01(SC7->(Recno()))
   Case nOpcX == 6
        U_TPCOM002(SC7->C7_FILIAL,SC7->C7_NUM, SC7->C7_FORNECE,SC7->C7_LOJA)
EndCase

DbSelectArea("SC7")
DbGoto(nRegSC7)

cFilAnt := cFilOld

SysRefresh()
RestArea(aAliasOLD)

Return(.T.)





//--------------------------------------------------------------
/*/{Protheus.doc} FPesqPC

@param  
@author Rodrigo Carvalho
@since  16/02/2016
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------

Static Function FPesqPC(nRegSC7,nOpcPC)

Default nOpcPC := 2

oBrwSC1:SetFilterDefault( "SC1->C1_FILIAL == SC7->C7_FILIAL" )
oBrwSC1:ChangeTopBot(.T.)

oBrwSC8:SetFilterDefault( "SC8->C8_NUM == SC7->C7_NUMCOT .And. SC8->C8_FILIAL == SC7->C7_FILIAL" )
oBrwSC8:ChangeTopBot(.T.)

DbSelectArea("SC7")
DbGoto(nRegSC7)

cFilOld := cFilAnt
cFilAnt := SC7->C7_FILIAL

A120Pedido("SC7",nRegSC7,nOpcPC) // consulta

cFilAnt := cFilOld      
  	   
oBrwSC1:SetFilterDefault( cFilterSC1 )
oBrwSC1:ChangeTopBot(.T.)

oBrwSC8:SetFilterDefault( cFilterCT )
oBrwSC8:ChangeTopBot(.T.)
           
Return .t.           