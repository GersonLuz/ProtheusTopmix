#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} MT160ATU

@protected
@author		Rodrigo Carvalho
@since		10/03/2015
@param
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       	Programador      Motivo
/*/
//-------------------------------------------------------------------
User Function MT160ATU()

Local oNewDialog  := PARAMIXB[1]
Local aArea       := GetArea()
Local nlin,ncol   
Local cOriginal   := ""
Local cFabrican   := ""
Local cObservac   := ""
Local nRegSC8     := Ascan(aHeader,{|x| Alltrim(x[2])== "CE_REC_WT"})
Local cAviso      := ""

DbSelectArea("SB1")
DbSetOrder(1)
If DbSeek(xFilial("SB1")+PARAMIXB[3][1][2])
   cOriginal   := "/Original: "+IIf(type( "SB1->B1_ZRORIG" ) == "U","",Alltrim(IIf(SB1->B1_ZRORIG=="1","SIM",IIf(SB1->B1_ZRORIG=="2","NÃO","Não informado"))))
   cFabrican   := "/Fabricante: "+Alltrim(IIf(Empty(SB1->B1_FABRIC),"Não informado",SB1->B1_FABRIC))
Endif

DbSelectArea("SC8")
If nRegSC8 > 0
   If acols[n][nRegSC8] > 0
      DbGoto(acols[n][nRegSC8])
      cObservac   := " / Observação: "+IIf(type( "SC8->C8_ZOBSADI" ) == "U","",Capital(Alltrim(IIf(Empty(SC8->C8_ZOBSADI),"Não informado",SC8->C8_ZOBSADI))))
   Endif
Endif      

cAviso := cFabrican + cOriginal + cObservac

DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
nlin:=1
ncol:=1
@ nlin,ncol MSGET oAviso1 VAR cAviso SIZE 500,10 OF oNewDialog FONT oBold PIXEL COLOR CLR_BLUE When .F. // Imprime acima da descrição do Produto
//@ 040,010   MSGET oAviso2 VAR cAviso SIZE 500,10 OF oScrollBox FONT oBold PIXEL COLOR CLR_BLUE When .F. //JSANTOS - 20150310 - Imprime abaixo da descrição do Produto

	
RestArea( aArea )

Return .t.