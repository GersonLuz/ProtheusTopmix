#include "protheus.ch"
#Define cEol Chr(13)+Chr(10)
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFATP05() 
Valida a exclusção dos documentos de saida criado via integração

@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFATP05()
Local lRet :=	.T.

lRet	:=	FValIntKp(SF2->F2_DOC + SF2->F2_SERIE  )

Return lRet

//------------------------------------------------------------------- 
/*/{Protheus.doc} FValIntKp
Valida a exclusção dos documentos de saida criado via integração

@protected
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FValIntKp(cNot)

/*Local		aAreSd2		:=	GetArea("SF2")
Local		cQry			:=	""
Local		cAli			:=	GetNextAlias()
Local 	lRet			:=	.F.

Default	cNot			:=	""

cQry += cEol +	"SELECT DISTINCT C5.C5_ZORIGEM, C5.C5_ZTIPO"
cQry += cEol +	"FROM " +RetSqlName("SC5")+ " C5"
cQry += cEol +	"WHERE C5.C5_NOTA + C5.C5_SERIE = '"+cNot+"'"  //MAX: FALTAVA SERIE
cQry += cEol +	" AND C5.C5_FILIAL 	= '"+xFilial("SC5")+"'"
cQry += cEol +	" AND C5.D_E_L_E_T_ 	<> '*'"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAli, .F., .T.)

lRet :=	IIF(	("KP" $ AllTrim((cAli)->C5_ZORIGEM) 	.And.	(cAli)->C5_ZTIPO == "1")	, .F.	, .T.	)

If !lRet
	MsgInfo("Essa nota não poderá ser excluída, pois o faturamento ocorreu no KP. Entre em contato com administrador do sistema!", "Integração KP")
EndIf

U_FSCloAre(cAli)


Return  lRet

//MAX: Desabilitei pois precisamos excluir varios pedidos da KP duplicados...

*/    
Return .t.  
