#include "rwmake.ch"



//-------------------------------------------------------------------------------------------------------------------------------------------------
/*
@author Daiana Andrade
@since 09/01/2012
@version P11
@Param Não Possui
@Return cTrb
@obs
Função criada para montar valor do título a pagar para considerar os abatimentos, acréscimos e decréscimos.

Alteracoes Realizadas desde a Estruturacao Inicial
Programador     Data       Motivo

*/
//-------------------------------------------------------------------------------------------------------------------------------------------------

User Function nCNAB03()

Private cTributo 	:= ""

Private cTrb 		:= space(15)

		cTrb := IIF(SE2->E2_VALLIQ ==0,STRZERO(SE2->(E2_VALOR+E2_SDACRES-E2_SDDECRE-E2_PIS-E2_CSLL-E2_COFINS)*100,15),STRZERO((SE2->E1_SALDO)*100,15)) 

Return(cTrb)
