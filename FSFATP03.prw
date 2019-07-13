#Include "Protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFATP03()
Impede o usuário realize a exclusão de um pedido gerado a partir da 
importação do KP
     
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
Impede o usuário realize a exclusão de um pedido gerado a partir da 
importação do KP

@protected
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11 
@param lRet Retornando .T. essa função permite a exclusão de um pedido gerado pela integração KP
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     		Motivo 
23/02/2012  Fernando Ferreira    Modificação no processo de validação de alteração de PDV 
/*/ 
//------------------------------------------------------------------ 
Static Function FVldExcNFs(lRet)

If IsInCallStack("U_FSINTP03") .Or. IsInCallStack("U_FSINTP07")
	lRet := .T.
Else
/*	lRet	:=	IIF(Empty(SC5->C5_ZORIGEM), .T., .F. )
	If !lRet
		MsgInfo("Não foi possivel realizar a exclusão do Pedido: "+SC5->C5_NUM+", por que foi gerado a partir da integração com KP." , "Integração KP")
	EndIf  */ //MAX: Desabilitado porque precisamos excluir a KK que a KP fez...
EndIf
Return Nil                                                                     


