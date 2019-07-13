#Include "protheus.ch"   

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSINTP13
Salvar os valores dos campos para verificar se houve alteração para gravar na base intermediaria
        
@author 	Luciano M. Pinto
@since 	31/10/2011 
@return 	Nil
@param 	cAlias Alias da tabela do qual se deve salvar os valores dos campos	
/*/
//---------------------------------------------------------------------------------------
User Function FSINTP13(cAlias)
/****************************************************************************************
* 
*
*
***/ 
Local aCpoRet	:= {}
Local aValRet	:= {}

aCpoRet := U_FSGetCmp(cAlias)  	

// Preenche a variavel com os campos e valores da Tabela         
For nX := 1 to Len(aCpoRet)
   
   If !Empty(aCpoRet[nX,3])
   
		aAdd(aValRet, {aCpoRet[nX,3], &(aCpoRet[nX,3])})
	
	End If       
	
Next


//***************************************************************************************
// Salvar os valores na variavel Static
//***************************************************************************************
U_FSGetVal(aValRet)


Return Nil