#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFATP04()
Função realiza a atualização do campo FLAGEXC na base de integração.
          
@author Fernando Ferreira
@since 25/10/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFATP04()
Local aAreOld		:=	{ GetArea("SC5"), GetArea("SD2")}
Local aCmp			:=	{}
Local aWhr			:=	{}

Local	cFilSd2		:=	""
Local	cDocSd2		:=	""
Local	cSerSd2		:= ""
Local	cCliSd2		:= ""
Local	cLojSd2		:= ""

// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
SD2->(dbSetOrder(3))

// C5_FILIAL+C5_NUM
SC5->(dbSetOrder(1))
SC5->(dbSeek(	xFilial("SC5")+SD2->D2_PEDIDO	))

If SC5->(!Eof())
	AAdd(aWhr,	{"C5_FILIAL"	, 	xFilial("SC5")		, "="	})
	AAdd(aWhr,	{"C5_ZPEDIDO"	, 	SC5->C5_ZPEDIDO	, "="	})
	AAdd(aCmp,	{"FLAGEXC"		,	" "							})
   ConOut("Preparando.. FSQryUpd - "+Funname())
	U_FSQryUpd(aCmp,"SC5",aWhr)				
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})
Return Nil                         


