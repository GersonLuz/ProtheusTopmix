#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} M460FIM
Ponto de entrada executado ap�s grava��o da Nota Fiscal fora da 
Transa��o.
          
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
Ponto de entrada utiliza as seguintes fun��es:
	FSINTP04;
	FSFATP01;
	FSFINP03;
	
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function M460FIM(uPar)

// Fun��o utilizada para gravar o campo E1_ZBOLETO a partir do campo C5_ZBOLETO.
U_FSFINP01()

//Comentado por Jean em 26/07/2012, pois segundo Max, n�o ha necessidade da fun��o.
//U_FGRAVGISS() //Fun��o utilizada para grava��o de flag para gera��o da GissOnline. 

If SC5->C5_ZTIPO == "1" // 1 = Nota de Remessa.
	// Fun��o salva a chave NF-e do pedido para o SF2 e SFT
	U_FSINTP04()
ElseIf SC5->C5_ZTIPO == "2" // 2 = Nota de Fatura
	// Fun��o realiza a grava��o do campo FLAGEXC quando � faturado uma nota a partir da integra��o KP
	U_FSFATP01()
	// Fun��o realiza a exclus�o dos T�tulos Provis�rios .
	U_FSFINP03()
EndIf

Return Nil


