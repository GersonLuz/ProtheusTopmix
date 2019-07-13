#Include "Protheus.ch"              
#Define cEol Chr(13)+Chr(10)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSINTP07()
Processo de Importa��o de Pedidos de Fatura
          
@author Fernando Ferreira     7
@since 25/10/2011 
@version P11
@obs  
Par�mentros Utilizados:
FS_INTDBAM : Par�metro onde � informado o ambiente de integra��o configurado no Top Connect
FS_INTDBIP : Par�metro utilizado para informar o IP do servidor da base de integra��o
FS_LACCTAB : Parametro que informa lancto contabil utilizado na integra��o
FS_AGTLACC :
FS_CTBLINE : Informa se contabiliza��o ser� on-line
FS_PEDCART : Informa se o pedido ser� em carteira
FS_CONDFAT : Condi��o de pagamento para pedidos de fatura
FS_GRPPRD  : Grupo de produtos para gera��o do pedido de fatura.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSINTP89()
FPrcPedFat()
Return Nil  

//------------------------------------------------------------------- 
/*/{Protheus.doc} FPrcPedFat
Fun��o inclui pedidos de vendas de faturameno da base integra��o do 
KP.

@protected       
@author Fernando Ferreira
@since 25/10/2011 
@version P11
@obs 
Par�mentros Utilizados:
FS_INTDBAM : Par�metro onde � informado o ambiente de integra��o configurado no Top Connect
FS_INTDBIP : Par�metro utilizado para informar o IP do servidor da base de integra��o
FS_LACCTAB : Parametro que informa lancto contabil utilizado na integra��o
FS_AGTLACC :
FS_CTBLINE : Informa se contabiliza��o ser� on-line
FS_PEDCART : Informa se o pedido ser� em carteira
FS_CONDFAT : Condi��o de pagamento para pedidos de fatura
FS_GRPPRD  : Grupo de produtos para gera��o do pedido de fatura.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     		Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FPrcPedFat()
Local		aDadNts		:=	{}
Local		aPedInt		:= {}			// Dados da Cabe�alho do Pedido de Venda	
Local		aNot			:=	{}
                                                                  
Local		cHdlInt		:=	SuperGetMv( "FS_INTDBAM" , .F., " " )  // Par�metro utilizado para o ambiente da base de integra��o
Local		cEndIp		:=	SuperGetMv( "FS_INTDBIP" , .F., " " )	// Par�metro utilizado para informar o IP do servidor da base de integra��o
Local		cFil			:=	""  
Local		cPed			:=	""
Local		cChvIss		:= ""
Local 	cMsgErr		:= ""

Local		lMstCot		:=	SuperGetMv( "FS_LACCTAB", .F.)
Local		lAglCot		:=	SuperGetMv( "FS_AGTLACC", .F.)
Local		lCont			:=	SuperGetMv( "FS_CTBLINE", .F.)
Local		lCar			:=	SuperGetMv( "FS_PEDCART", .F.)

Local		nXi			:=	1

Private  cNumPed     := ""

Private 	nHdlInt		:=	-1//TcLink(cHdlInt,cEndIp)
Private 	nHdlErp		:=	AdvConnection()
//MAX: 28-11-2012 -> Corrigir problema do CFOP fora do Estado
Private  cTip			:= ""
Private  cEstCli     := ""
Private  cEmpEst     := ""

If !Empty(cHdlInt) .Or. !Empty(cEndIp)
	nHdlInt		:=	TcLink(cHdlInt,cEndIp)
EndIf