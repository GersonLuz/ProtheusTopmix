#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} M460NUM
O ponto de entrada é executado após a seleção da série na rotina de documento de saída. 
Seu objetivo é permitir a troca da série e do número do documento através de customização local.
O número do documento de saída pode ser alterado através da variável Private cNumero e a série pela variável cSerie.
Observações:

1) O ponto de entrada é executado fora da transação do programa de preparação do documento de saída.

2) O ponto de entrada tem um comportamento diferente quando o parâmetro MV_TPNRNFS estiver configurado como 3. 
Nesta situação o valor informado na variável cNumero não condiz com o próximo número que será gerado e caso o 
desenvolvedor queira que o sistema obtenha o próximo número, deve-se atribuir a variável cNumero uma string vazia.

@Obs	Se o pedido for do tipo cuja numeração da nota vem do KP então o WebService é chamado e o número da nota é 
		atribuído à variável privada cNumero e a série à variável cSerie


@protect          
@author Fernando dos Santos Ferreira 
@since 16/11/2011
@version P11
@obs  
Ponto de Entrada Utiliza a função FSINTP18 para processar o número da nota e serie vindas do KP.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo            
01/02/2012 Waldir de Oliveira Complemnto do projeto. Numeração. NF

/*/ 
//------------------------------------------------------------------ 
User Function M460NUM()
Local cNum 		:= ""
Local	cSerKp   := AllTrim(GetMv("FS_SERIEKP")) //Serie do KP

If SC5->C5_ZTIPO == "1" .And. !Empty(SC5->C5_ZPEDIDO)
	U_FSINTP18(cKpNumNot, cKpSerNot)
EndIf
                         
//Verificando se participa do processo que deve consultar o Ws de Numeração.
 If cSerKp == AllTrim(cSerie)
	If cSerie	((IsInCallStack("MATA410")  .And. Empty(SC5->C5_ZORIGEM) .And. SC5->C5_ZTIPO <> '2') .or.;
		(IsInCallStack("MATA460A") .And. u_FTstTipo() == 2))/*Tipo de nota para buscar do WS*/
		
		cNum := U_FSGetNumWS()//Obtendo o próximo numero de NF.         l
	
		//Variáveis Private do número da nota e séria do documento de saída.
		cNumero 	:= cNum
		cSerie	:= cSerKp
	EndIf
EndIf

Return Nil


