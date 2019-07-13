#include "TopConn.ch"
#include "Protheus.ch"
#include "Colors.ch"
#include "Rwmake.ch"         
#include "Tbiconn.ch"
#include "Fwbrowse.ch"                      
#include 'Fwmvcdef.ch'
#INCLUDE 'FWMVCDEF.CH'
//--------------------------------------------------------------
/*/{Protheus.doc} FPNLCOM                                   

Chamadas das rotinas padrões do protheus para o compras

@param  
@author Rodrigo Carvalho
@since  15/12/2015
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
User Function FPNLCOM()

Local oChkMar
Local oChkAtu
Local oChkSC8
Local oChkSCR

Private cCadastro     := "Painel de Compras"
Private oFont1        := TFont():New("Calibri",,022,,.T.,,,,,.F.,.F.)
Private oFont2        := TFont():New("Calibri",,019,,.T.,,,,,.F.,.F.)
Private oFont3        := TFont():New("Calibri",,017,,.T.,,,,,.F.,.F.)
Private oFont4        := TFont():New("Calibri",,019,,.T.,,,,,.F.,.F.)
Private oDlgCom                       
Private aRegPnlCmp    := {1,1,1,1} // recno dos folders
Private cMarkSCR      := ""
Private cFilterSC1    := "" // filtro das solicitações pendentes.
Private cFilterCT     := "" // filtro das cotações pendentes.
Private cFilterPB     := "" // filtro do pedido de vendas bloqueado.
Private cFilterPL     := "" // filtro do pedido de venda pendentes de entregas.
Private cFilOld1      := xFilial("SC7")
Private aFiltro       := {"","","",""}
Private lChk          := .F. 
Private lChkGer       := .F. 
Private lChkOld       := .F.
Private lChkSCR       := .F. 
Private lChkSC8       := .T. 

Private oBrwSC1
Private oBrwSC8
Private oBrwSC7a
Private oBrwSCR
Private aRotina 

Private aIndexSC1     := {}
Private aIndexSC8     := {}
Private aIndexSCR	    := {}
Private aIndexSC7     := {}	      //Variavel Para Filtro
Private cAuxFilter    := "" 
Private bFiltraBrw	 := {|| Nil}

Private cCodUser      := RetCodUsr()
Private cUsrMaster    := SuperGetMv("MV_ZUSUPCO",,"000000")
Private lVisSCR       := cCodUser $ SuperGetMv("MC_USRVPBL",,"000295/000287/000047/000000/000302/")  // mostrar ped. pend. aprov. mesmo nao cad. nas alçadas.

Private cFilUsr       := Space(06)
Private cFilUsrOld    := Space(06)
Private oFilUsr       

Private aFilCla	    := {"1=Equipamento Parado","2=Manutencao Corretiva","3=Manutencao Preventiva","4=Compra para Estoque","5=Uso e Consumo","Todos"}
Private cFilCla	    := aFilCla[Len(aFilCla)]
Private nContSCs      := 0
Private oFilCla
Private cMsgFldr      := Space(20)
Private oMsgFldr      := Nil

Private cGrpUsr	    := Space(4)
Private oGrpUsr

Private aGrpPrd       := MCGRPCOM()
Private cGrpPrd       := aGrpPrd[Len(aGrpPrd)]

Private nTipoPed      := 1 // 1 - Ped. Compra 2 - Aut. Entrega
Private nGuia         := 0
Private oFldGCom      
Private Inclui        := .F.
Private Altera        := .T.

MCFiltros(.F.) // sem atualizar objetos com os filtros pré estabelecidos.

SetKey( VK_F10, { || FChamada(1) })
SetKey( VK_F11, { || FChamada(2) })
SetKey( VK_F12, { || FChamada(3) })

Define MsDialog oDlgCom Title "Painel de Gestão de Compras" From 000, 000  TO 535, 1300 Pixel

@ 001, 558 Bitmap oBitmap1 OF oDlgCom FILENAME "\Imagens\Flapa_Totvs.png"  Size 035, 015 NOBORDER Pixel
@ 001, 600 Bitmap oBitmap2 OF oDlgCom FILENAME "\Imagens\TopMix_Totvs.png" Size 035, 015 NOBORDER Pixel

@ 008, 004 Folder oFldGCom Size 645, 234 OF oDlgCom Items "SC - Pendentes","SC - Em Cotação","OC - Aguardando Aprovação","Ordem de Compra" Pixel

oFldGCom:bSetOption := {|nGuia| FWFolder(nGuia)} // atualiza as tabelas.

@ 245,005 Say    "Classificação"         Size 37,08 Color CLR_BLACK       Pixel OF oDlgCom
@ 245,099 Say    "Filial"                Size 18,08 Color CLR_BLACK       Pixel OF oDlgCom
@ 245,135 Say    "Grupo"                 Size 18,08 Color CLR_BLACK       Pixel OF oDlgCom
@ 245,170 Say    "Grupo de Compradores"  Size 70,08 Color CLR_BLACK       Pixel OF oDlgCom
@ 251,280 Button "Filtrar"               Size 20,10 Action MCFiltros(.T.) Pixel OF oDlgCom
@ 245,485 Say    "Ultimo doc. incluído"  Size 70,08                       Pixel OF oDlgCom

@ 246,310 CheckBox oChkMar Var lChk    Prompt "Parâmetros Gera Cotação"       Message  Size 150 , 007 Pixel Of oDlgCom
@ 255,310 CheckBox oChkAtu Var lChkGer Prompt "Parâmetros Atua.Cotação"       Message  Size 150 , 007 Pixel Of oDlgCom
@ 246,393 CheckBox oChkSC8 Var lChkSC8 Prompt "Atualiza Cotação em Sequência" Message  Size 150 , 007 Pixel Of oDlgCom
@ 255,393 CheckBox oChkSCR Var lChkSCR Prompt "Pedidos Bloqueados"            Message  Size 150 , 007 Pixel Of oDlgCom Valid MCFiltros(.F.)

@ 253,006 ComboBox oFilCla  VAR cFilCla  Items aFilCla Size 90,09   Pixel OF oDlgCom Valid  MCFiltros( .T. ) //Color CLR_BLACK
@ 253,099 MsGet    oFilUsr  Var cFilUsr  Size  35,09 Picture "@!"   Pixel OF oDlgCom Valid  MCVLDFL() When .F.
@ 253,135 MsGet    oGrpUsr  Var cGrpUsr  Size  35,09 Picture "@!"   Pixel OF oDlgCom Valid  MCFiltros( .T. )
@ 253,170 ComboBox oGrpPrd  VAR cGrpPrd  Items aGrpPrd Size 99,09   Pixel OF oDlgCom Valid  MCFiltros( .T. )
@ 253,485 MsGet    oMsgFldr Var cMsgFldr Size  110,09 Picture "@!"  Pixel OF oDlgCom When .F.
  
Define SBUTTON oSButton1 FROM 251, 600 Type 20 Action ( IIf( fConfirma() , oDlgCom:End() , .T.) ) OF oDlgCom Enable Pixel
       

