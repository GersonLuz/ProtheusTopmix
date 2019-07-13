#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

/*/{Protheus.doc} EREST_01
Rotina para integração de produtos e grupos de produtos
@author Lucas Borges
@since 10/11/2017
@version 1.0
@type function
/*/
User Function EREST01A()	
Return

CLASS GRUPOSPROD
	DATA filiall	AS String
	DATA codigo		AS String
	DATA descricao	AS String
	DATA grupoRel	AS String
	DATA bloqueado	AS String

	Method New() Constructor
	Method SetFiliall(filiall)
	Method SetCodigo(cCodigo)
	Method SetDescricao(cDescricao)
	Method SetGrupoRel(cGrupoRel)
	Method SetBloqueado(cBoqueado)

EndClass

/*/{Protheus.doc} New
Método Construtor
@author Lucas Borges
@since 10/11/2017
@version undefined
@type function
/*/
Method New() Class GRUPOSPROD
::filiall 	:= ""
::codigo 		:= ""
::descricao   	:= ""
::grupoRel   	:= ""
::bloqueado   	:= ""
Return(Self) 

// --> Métodos Setters
Method SetFiliall(cFiliall) Class GRUPOSPROD
Return (::filiall := cFiliall)

Method SetCodigo(cCodigo) Class GRUPOSPROD
Return (::codigo := cCodigo)    

Method SetDescricao(cDescricao) Class GRUPOSPROD
Return (::descricao := cDescricao) 

Method SetGrupoRel(cGrupoRel) Class GRUPOSPROD
Return (::grupoRel := cGrupoRel) 

Method SetBloqueado(cBoqueado) Class GRUPOSPROD
Return (::bloqueado := cBoqueado) 
   



