#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} M460NUM
O ponto de entrada � executado ap�s a sele��o da s�rie na rotina de documento de sa�da. 
Seu objetivo � permitir a troca da s�rie e do n�mero do documento atrav�s de customiza��o local.
O n�mero do documento de sa�da pode ser alterado atrav�s da vari�vel Private cNumero e a s�rie pela vari�vel cSerie.
Observa��es:

1) O ponto de entrada � executado fora da transa��o do programa de prepara��o do documento de sa�da.

2) O ponto de entrada tem um comportamento diferente quando o par�metro MV_TPNRNFS estiver configurado como 3. 
Nesta situa��o o valor informado na vari�vel cNumero n�o condiz com o pr�ximo n�mero que ser� gerado e caso o 
desenvolvedor queira que o sistema obtenha o pr�ximo n�mero, deve-se atribuir a vari�vel cNumero uma string vazia.

@Obs	Se o pedido for do tipo cuja numera��o da nota vem do KP ent�o o WebService � chamado e o n�mero da nota � 
		atribu�do � vari�vel privada cNumero e a s�rie � vari�vel cSerie


@protect          
@author Fernando dos Santos Ferreira 
@since 16/11/2011
@version P11
@obs  
Ponto de Entrada Utiliza a fun��o FSINTP18 para processar o n�mero da nota e serie vindas do KP.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo            
01/02/2012 Waldir de Oliveira Complemnto do projeto. Numera��o. NF

/*/ 
//------------------------------------------------------------------ 
User Function M460NUM()
Local cNum 		:= ""
Local	cSerKp   := AllTrim(GetMv("FS_SERIEKP")) //Serie do KP

If SC5->C5_ZTIPO == "1" .And. !Empty(SC5->C5_ZPEDIDO)
	U_FSINTP18(cKpNumNot, cKpSerNot)
EndIf
                         
//Verificando se participa do processo que deve consultar o Ws de Numera��o.
 If cSerKp == AllTrim(cSerie)
	If cSerie	((IsInCallStack("MATA410")  .And. Empty(SC5->C5_ZORIGEM) .And. SC5->C5_ZTIPO <> '2') .or.;
		(IsInCallStack("MATA460A") .And. u_FTstTipo() == 2))/*Tipo de nota para buscar do WS*/
		
		cNum := U_FSGetNumWS()//Obtendo o pr�ximo numero de NF.         l
	
		//Vari�veis Private do n�mero da nota e s�ria do documento de sa�da.
		cNumero 	:= cNum
		cSerie	:= cSerKp
	EndIf
EndIf

Return Nil


