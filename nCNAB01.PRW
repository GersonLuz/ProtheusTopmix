#include "rwmake.ch"



//-------------------------------------------------------------------------------------------------------------------------------------------------
/*
@author Daiana Andrade
@since 09/01/2012
@version P11
@Param Não Possui
@Return cTrb
@obs
Função criada para montar valor do título a receber para considerar os abatimentos, acréscimos e decréscimos.

Alteracoes Realizadas desde a Estruturacao Inicial
Programador     Data       Motivo

*/
//-------------------------------------------------------------------------------------------------------------------------------------------------

User Function nCNAB01()

Local  nVlrPrinc := 0
Local  nAbatim   := 0
Local  nVlrTot   := 0

// Private cTributo 	:= ""

// Private cTrb 		:= space(13)

nVlrPrinc  := SE1->E1_VALOR

nAbatim	   := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,"R",SE1->E1_MOEDA,,SE1->E1_CLIENTE,SE1->E1_LOJA)

nVlrTot    := (nVlrPrinc - (nAbatim + SE1->E1_DESCISS))


  //	nVlrTot := IIF(SE1->E1_VALLIQ =0,STRZERO(SE1->((E1_VALOR+E1_ACRESC)-(E1_ISS+E1_DESC+E1_DECRESC+E1_PIS+E1_CSLL+E1_IRRF+E1_COFINS+E1_INSS))*100,13),STRZERO((SE1->E1_SALDO)*100,13)) 

// Return(cTrb)

nVlrTot := STRZERO(nVlrTot*100,13)

Return(nVlrTot)
                                           
 
 