#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

/*/{Protheus.doc} EREST_01
Rotina para integra��o de produtos e grupos de produtos
@author Lucas Borges
@since 10/11/2017
@version 1.0
@type function
/*/
User Function EREST01()	
Return

/*/{Protheus.doc} GRUPOS DE PRODUTOS
Defini��o da estrutura do webservice
@author Lucas Borges
@since 10/11/2017
@type class
/*/
WSRESTFUL GRUPOSPROD DESCRIPTION "Servi�o REST para manipula��o de Grupos Produtos"
 
WSMETHOD GET DESCRIPTION "Retorna o produto informado na URL" WSSYNTAX "/GRUPOSPROD " //Disponibilizamos um m�todo do tipo GET
 
END WSRESTFUL         

/*/{Protheus.doc} GET           
Processa as informa��es e retorna o json
@author Lucas Borges
@since 10/11/2017
@version 1.0
@param oSelf, object, Objeto contendo dados da requisi��o efetuada pelo cliente, tais como:
   - Par�metros querystring (par�metros informado via URL)
   - Objeto JSON caso o requisi��o seja efetuada via Request Post
   - Header da requisi��o
   - entre outras ...
@type Method
/*/
WSMETHOD GET WSSERVICE GRUPOSPROD

Local aArea		:= GetArea()
Local cNextAlias 	:= GetNextAlias()
Local oGrupo := GRUPOSPROD():New() // --> Objeto da classe GRUPOSPROD 
Local oResponse  := FULL_GRUPOSPROD():New() // --> Objeto que ser� serializado
Local cJSON		 := ""
Local lRet		 := .T.


::SetContentType("application/json")    

BeginSQL Alias cNextAlias
	SELECT BM_FILIAL, BM_GRUPO, BM_DESC, BM_GRUREL, BM_MSBLQL 
	FROM %table:SBM% SBM
	WHERE SBM.%notdel%
EndSQL

(cNextAlias)->( DbGoTop() )
If (cNextAlias)->( !Eof() )
	While (cNextAlias)->( !Eof() )
		
		oGrupo:SetFiliall( AllTrim((cNextAlias)->BM_FILIAL ))
  		oGrupo:SetCodigo( AllTrim((cNextAlias)->BM_GRUPO ))
		oGrupo:SetDescricao( AllTrim((cNextAlias)->BM_DESC)) 
		oGrupo:SetGrupoRel( AllTrim((cNextAlias)->BM_GRUREL))
		oGrupo:SetBloqueado( AllTrim((cNextAlias)->BM_MSBLQL))
		oResponse:Add(oGrupo)
		oGrupo := GRUPOSPROD():New()
		(cNextAlias)->( DbSkip() )
	
	EndDo
	
	cJSON := FWJsonSerialize(oResponse, .T., .T.,,.F.)
	::SetResponse(cJSON)
		
Else
	SetRestFault(400, "SBM Empty")
	lRet := .F.
EndIf
RestArea(aArea)
Return(lRet)


