#Include "Protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINP02() 
Função chamada pelo ponto de entrada FA280 para atualização do 
SE1->E1_ZBOLETO no momento do faturamento do pedido.

@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFINP02()       

Local aAreOld	:=	GetArea("SE1")
Local	cFilFatCrt		:=	""								// Filial da Fatura
Local	cCliFatCrt		:=	"" 							// Cliente da Fatura
Local cLojFatCrt		:=	""								// Loja da Fatura
Local	cPrfFatCrt		:= ""								// Prefixo da Fatura
Local	cNumFatCrt		:=	""								// Número da Fatura

Local	nRetMsg			:=	0								// Retorno da Mensagem

cFilFatCrt		:=	xFilial("SE1")
cCliFatCrt		:=	SE1->E1_CLIENTE
cLojFatCrt		:=	SE1->E1_LOJA
cPrfFatCrt		:= SE1->E1_PREFIXO
cNumFatCrt		:=	SE1->E1_NUM

nRetMsg	:= MessageBox("Fatura irá gerar Boleto?","",4)

SE1->(dbSetOrder(2))//Filial+Cliente+Loja+Serie+Doc
SE1->(dbSeek(cFilFatCrt+cCliFatCrt+cLojFatCrt+cPrfFatCrt+cNumFatCrt))

While SE1->(!Eof())	.And.	SE1->E1_FILIAL		== cFilFatCrt		.And.;
								 	SE1->E1_CLIENTE 	== cCliFatCrt		.And.;
								 	SE1->E1_LOJA		== cLojFatCrt 		.And.;
								 	SE1->E1_PREFIXO  	== cPrfFatCrt		.And.;
								 	SE1->E1_NUM 		== cNumFatCrt
	SE1->(RecLock("SE1",.F.))
	IIf(nRetMsg == 6 .And. AllTrim(Upper(SE1->E1_FATURA)) == "NOTFAT", SE1->E1_ZBOLETO := "S", SE1->E1_ZBOLETO := "N")
	SE1->(MsUnlock())
	SE1->(dbSkip())			
EndDo
Return Nil                     


