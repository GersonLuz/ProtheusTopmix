#Include "Protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFATP01() 
Processo responsável por atualizar o campo FLAGEXC da tabela de integração
Cabeçalho de pedidos, gravando nesse campo '*' para pedidos faturados.
      
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFATP01()
FGrvFlgExc()
Return Nil                                                            

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGrvFlgExc()
Grava campo FLAGEXC com '*' no faturamento do Pedido de faturamento 
gerado pelo KP.

@protected
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FGrvFlgExc()
Local 	aCmp			:=	{}
Local 	aWhr			:=	{}

Local		cFil			:= ""
Local		cPed			:=	""

cFil	:=	SC5->C5_FILIAL
cPed	:=	SC5->C5_ZPEDIDO
AAdd(aWhr,	{"C5_FILIAL"	, 	cFil, "="})
AAdd(aWhr,	{"C5_ZPEDIDO"	, 	cPed, "="})
AAdd(aCmp,	{"FLAGEXC"		,	"*" 		})

ConOut("Preparando.. FSQryUpd - "+Funname())
U_FSQryUpd(aCmp,"SC5",aWhr)

Return Nil


