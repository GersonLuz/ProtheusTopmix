#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FSFINP08
Verifica integridade com a natureza

@author	   Giulliano Santos Silva
@since	   14/03/2012
@version	   P11
@obs	      
Projeto
PneuSola FSWPD005464

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSFINP08()

Local lRetFun	:= .T. // Retorno
Local aTabVal	:= {}  // Tabelas a serem validadas
Local nXi     	:= 0   // Contador

Aadd(aTabVal, {"P06",{{"P06_NATURE",SED->ED_CODIGO}}})  
							 
For nXi:= 1 To Len(aTabVal)
	lRetFun	:= U_FSValQry(aTabVal[nXi][1], aTabVal[nXi][2])
	If !lRetFun
		Exit
	EndIf
Next nXi

Return(lRetFun)