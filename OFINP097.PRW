#include "rwmake.ch"



//-------------------------------------------------------------------------------------------------------------------------------------------------
/*
@author Daiana Andrade
@since 22/03/2011
@version P10
@Param Não Possui
@Return cTrb
@obs
Função criada para montar Seguimento N - Impostos

Alteracoes Realizadas desde a Estruturacao Inicial
Programador     Data       Motivo

/*/
//-------------------------------------------------------------------------------------------------------------------------------------------------

User Function OFINP097()

Private cTributo 	:= ""

Private cTrb 		:= space(120)
Private _cSeuNum 	:= SE2->E2_IDCNAB

Do Case
	Case SEA->EA_MODELO = "17" //GPS
		cTrb := "01"+STRZERO(VAL(SE2->E2_CODTRIB),4)+SUBSTR(DTOS(SE2->E2_PERIODO),5,2)+SUBSTR(DTOS(SE2->E2_PERIODO),1,4)+ SUBSTR(SM0->M0_CGC,1,14)
		cTrb := cTrb+STRZERO((SE2->E2_SALDO-SE2->E2_OUTENT)*100,14)+STRZERO((SE2->E2_OUTENT)*100,14)+STRZERO((SE2->E2_ACRESC)*100,14)+STRZERO((SE2->E2_SALDO+SE2->E2_ACRESC-SE2->E2_DECRESC)*100,14)
		cTrb := cTrb+GRAVADATA(DDATABASE,.F.,5)+SPACE(58)+SM0->M0_NOMECOM                       
 
	Case SEA->EA_MODELO = "16" //DARF NORMAL
		 //cTrb := "02"+STRZERO(VAL(SE2->E2_CODRET),4)+"2"+SUBSTR(SM0->M0_CGC,1,14)+GRAVADATA(SE2->E2_PERIODO,.F.,5)+ SPACE(17)+STRZERO((SE2->E2_VALOR)*100,14) 
	   cTrb := "02"+IIF(!EMPTY(SE2->E2_CODRET),STRZERO(VAL(SE2->E2_CODRET),4),STRZERO(VAL(SE2->E2_CODTRIB),4))+"2"+SUBSTR(SM0->M0_CGC,1,14)+GRAVADATA(SE2->E2_PERIODO,.F.,5)+ SPACE(17)+STRZERO((SE2->E2_VALOR)*100,14)
		cTrb := cTrb+STRZERO((SE2->E2_MULTA)*100,14)+STRZERO((SE2->E2_JUROS)*100,14)+STRZERO((SE2->E2_SALDO)*100,14)+GRAVADATA(SE2->E2_VENCREA,.F.,5)
	   cTrb := cTrb+GRAVADATA(DDATABASE,.F.,5)+SPACE(30)+SM0->M0_NOMECOM

	Case SEA->EA_MODELO = "35" //FGTS       
		//cTrb := "11"+STRZERO(VAL(SE2->E2_CODTRIB),4)+"1"+SUBSTR(SM0->M0_CGC,1,14)+SE2->(E2_CODBAR + E2_IDFGTS) + REPLICATE ("0",11) +LEFT(SM0->M0_NOMECOM,30)- LINHA ABAIXO ALTERADO JULIANA. 
		cTrb := "11"+STRZERO(VAL(SE2->E2_CODTRIB),4)+"1"+IIF(EMPTY(SE2->E2_CGCCONT),SUBSTR(SM0->M0_CGC,1,14),SUBSTR(SE2->E2_CGCCONT,1,14))+SE2->(E2_CODBAR + E2_IDFGTS) + REPLICATE ("0",11) +LEFT(SM0->M0_NOMECOM,30)
		cTrb := cTrb+GRAVADATA(DDATABASE,.F.,5)+STRZERO((SE2->E2_VALOR)*100,14)+SPACE(30)

	Case SEA->EA_MODELO $ "25" //IPVA
		cTrb := "07"+SPACE(04)+"2"+SM0->M0_CGC+SUBSTR(dtos(SE2->E2_EMISSAO),1,4)+STRZERO(VAL(SE2->E2_RENAVAM),9)+SUBSTR(SE2->E2_UFIPVA,1,2)+SUBSTR(SE2->E2_MUNIPVA,1,5)+SUBSTR(SE2->E2_PLCA,1,7)
		cTrb := cTrb+STRZERO(VAL(SE2->E2_PGTIPVA),1)+STRZERO((SE2->(E2_VALOR + E2_ACRESC))*100,14)+STRZERO((SE2->E2_DECRESC)*100,14)+STRZERO((SE2->(E2_VALOR + E2_ACRESC))*100,14)
        	cTrb := cTrb+Gravadata(SE2->E2_VENCREA,.F.,5)+Gravadata(SE2->E2_VENCREA,.F.,5)+SPACE(41)+SM0->M0_NOMECOM

	Case SEA->EA_MODELO $ "27" //DPVAT
    		cTrb := "08"+SPACE(04)+"2"+SM0->M0_CGC+SUBSTR(dtos(SE2->E2_EMISSAO),1,4)+STRZERO(VAL(SE2->E2_RENAVAM),9)+SUBSTR(SE2->E2_UFIPVA,1,2)+SUBSTR(SE2->E2_MUNIPVA,1,5)+SUBSTR(SE2->E2_PLCA,1,7)
		cTrb := cTrb+"0"+STRZERO((SE2->(E2_VALOR + E2_ACRESC))*100,14)+STRZERO((SE2->E2_DECRESC)*100,14)+STRZERO((SE2->(E2_VALOR + E2_ACRESC))*100,14)
        	cTrb := cTrb+Gravadata(SE2->E2_VENCREA,.F.,5)+Gravadata(SE2->E2_VENCREA,.F.,5)+SPACE(41)+SM0->M0_NOMECOM

	EndCase

Return(cTrb)
 