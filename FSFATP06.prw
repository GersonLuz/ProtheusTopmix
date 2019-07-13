#Include "Protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFATP06()
Impede o usuário realize a Alteração de um pedido gerado a partir da 
importação do KP
     
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
Impede o usuário realize a alteração de um pedido gerado a partir da 
importação do KP

@protected
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11 
@param lRet Retornando .T. essa função permite a alteração de um pedido gerado pela integração KP
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     		Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FVldAltNFs(lRet)
	If !Empty(SC5->C5_ZORIGEM) .And. SC5->C5_ZTIPO == "1"
		MsgInfo("Não é possivel realizar a alteração do Pedido: "+SC5->C5_NUM+", por que foi gerado a partir da integração com KP." , "Integração KP")
		lRet :=  .F.
	EndIf
Return Nil                                                                     


