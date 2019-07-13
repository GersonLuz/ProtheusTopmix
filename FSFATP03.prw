#Include "Protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFATP03()
Impede o usu�rio realize a exclus�o de um pedido gerado a partir da 
importa��o do KP
     
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFATP03()
Local lRet :=	.T.

FVldExcNFs(@lRet)

Return lRet

//------------------------------------------------------------------- 
/*/{Protheus.doc} FVldExcNFs
Impede o usu�rio realize a exclus�o de um pedido gerado a partir da 
importa��o do KP

@protected
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11 
@param lRet Retornando .T. essa fun��o permite a exclus�o de um pedido gerado pela integra��o KP
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     		Motivo 
23/02/2012  Fernando Ferreira    Modifica��o no processo de valida��o de altera��o de PDV 
/*/ 
//------------------------------------------------------------------ 
Static Function FVldExcNFs(lRet)

If IsInCallStack("U_FSINTP03") .Or. IsInCallStack("U_FSINTP07")
	lRet := .T.
Else
/*	lRet	:=	IIF(Empty(SC5->C5_ZORIGEM), .T., .F. )
	If !lRet
		MsgInfo("N�o foi possivel realizar a exclus�o do Pedido: "+SC5->C5_NUM+", por que foi gerado a partir da integra��o com KP." , "Integra��o KP")
	EndIf  */ //MAX: Desabilitado porque precisamos excluir a KK que a KP fez...
EndIf
Return Nil                                                                     


