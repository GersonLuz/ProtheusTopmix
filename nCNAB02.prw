//-------------------------------------------------------------------------------------------------------------------------------------------------
/*
@author Daiana Andrade
@since 09/01/2012
@version P11
@Param N�o Possui
@Return cTrb
@obs
Fun��o criada para montar valor do t�tulo a receber para considerar os abatimentos, acr�scimos e decr�scimos.

Alteracoes Realizadas desde a Estruturacao Inicial
Programador     Data       Motivo

*/
//-------------------------------------------------------------------------------------------------------------------------------------------------

User Function nCNAB02()

Private cTributo 	:= ""

Private cTrb 		:= space(15)

		cTrb := IIF(SE1->E1_VALLIQ ==0,STRZERO(SE1->(E1_VALOR+E1_SDACRES-E1_SDDECRE-E1_ISS-E1_PIS-E1_CSLL-E1_IRRF-E1_COFINS-E1_INSS)*100,15),STRZERO((SE1->E1_SALDO)*100,15)) 

Return(cTrb)
 