#Include "Protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFATP06()
Impede o usu�rio realize a Altera��o de um pedido gerado a partir da 
importa��o do KP
     
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFATP06()
Local lRet :=	.T.

FVldAltNFs(@lRet)

Return lRet

//------------------------------------------------------------------- 
/*/{Protheus.doc} FVldAltNFs
Impede o usu�rio realize a altera��o de um pedido gerado a partir da 
importa��o do KP

@protected
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11 
@param lRet Retornando .T. essa fun��o permite a altera��o de um pedido gerado pela integra��o KP
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     		Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FVldAltNFs(lRet)
	If !Empty(SC5->C5_ZORIGEM) .And. SC5->C5_ZTIPO == "1"
		MsgInfo("N�o � possivel realizar a altera��o do Pedido: "+SC5->C5_NUM+", por que foi gerado a partir da integra��o com KP." , "Integra��o KP")
		lRet :=  .F.
	EndIf
Return Nil                                                                     


