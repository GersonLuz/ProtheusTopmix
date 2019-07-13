#Include 'protheus.ch'
#Include 'parmtype.ch'

/*/{Protheus.doc} EREST_01
Rotina para integração de produtos e grupos de produtos
@author Lucas Borges
@since 10/11/2017
@version 1.0
@type function
/*/
User Function EREST_2B()
Return

Class FULL_GRUPOSPROD
	
	Data GRUPOSPROD
	
	Method New() Constructor
	Method Add() 
	
EndClass  


/*/{Protheus.doc} New
Método contrutor
@author Lucas Borges
@since 25/04/2017
@type function
/*/
Method New() Class FULL_GRUPOSPROD
	::GRUPOSPROD := {}
Return(Self)
/*/{Protheus.doc} Add	
Adiciona um novo objeto de cliente
@author Lucas Borges
@since 25/04/2017
@param oCliente, object, Objeto da Classe GRUPOSPROD
@type function
/*/
Method Add(oGrupo) Class FULL_GRUPOSPROD
	Aadd(::GRUPOSPROD, oGrupo)
Return