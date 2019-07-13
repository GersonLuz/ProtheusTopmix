#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FSFINP06
Verifica integridade com operadora de cartao

@author	   Giulliano Santos Silva
@since	   14/03/2012
@version	   P11
@obs	      
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSFINP06()

Local lRetFun	:= .T. // Retorno
Local aTabVal	:= {}  // Tabelas a serem validadas
Local nXi     	:= 0   // Contador

Aadd(aTabVal, {"P05",{{"P05_CODOPE",SA1->A1_COD},;
							 {"P05_LOJA", 	SA1->A1_LOJA}}})  
							 
Aadd(aTabVal, {"P06",{{"P06_CODCLI",SA1->A1_COD},;
							 {"P06_LOJA", 	SA1->A1_LOJA}}})  

For nXi:= 1 To Len(aTabVal)
	lRetFun	:= U_FSValQry(aTabVal[nXi][1], aTabVal[nXi][2])
	If !lRetFun
		Exit
	EndIf
Next nXi

Return(lRetFun)