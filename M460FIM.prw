#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} M460FIM
Ponto de entrada executado após gravação da Nota Fiscal fora da 
Transação.
          
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
Ponto de entrada utiliza as seguintes funções:
	FSINTP04;
	FSFATP01;
	FSFINP03;
	
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function M460FIM(uPar)

// Função utilizada para gravar o campo E1_ZBOLETO a partir do campo C5_ZBOLETO.
U_FSFINP01()

//Comentado por Jean em 26/07/2012, pois segundo Max, não ha necessidade da função.
//U_FGRAVGISS() //Função utilizada para gravação de flag para geração da GissOnline. 

If SC5->C5_ZTIPO == "1" // 1 = Nota de Remessa.
	// Função salva a chave NF-e do pedido para o SF2 e SFT
	U_FSINTP04()
ElseIf SC5->C5_ZTIPO == "2" // 2 = Nota de Fatura
	// Função realiza a gravação do campo FLAGEXC quando é faturado uma nota a partir da integração KP
	U_FSFATP01()
	// Função realiza a exclusão dos Títulos Provisórios .
	U_FSFINP03()
EndIf

Return Nil


