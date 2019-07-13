#include "protheus.ch"
//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} MS520VLD
Ponto de Entrada utilizado para validar a Exclusão das notas fiscais
         
@author 	Fernando Ferreira
@since		31/10/2011
@version	P11  
@return		lRet Se retornar verdadeiro permite a exclusão das notas fiscais.
@obs
Ponto de Entrada utiliza a função FSFATP05.
/*/ 
//--------------------------------------------------------------------------------------- 
User Function MS520VLD()
Local lRet		:=	.F.

lRet	:=	U_FSFATP05()

Return(lRet)

