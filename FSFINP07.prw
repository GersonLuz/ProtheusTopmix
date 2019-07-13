#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FSFINP07
Validar amarração banco com pre recebimento

@author	   Giulliano Santos Silva
@since	   14/03/2012
@version	   P11
@obs	      
Projeto


Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSFINP07()

Local lRetFun	:= .T. // Retorno
Local aTabVal	:= {}  // Tabelas a serem validadas
Local nXi     	:= 0   // Contador

Aadd(aTabVal, {"P06",{{"P06_BANCO", SA6->A6_COD},;
							 {"P06_AGENCI",SA6->A6_AGENCIA},;
							 {"P06_NUMCON",SA6->A6_NUMCON}}})  
							 

For nXi:= 1 To Len(aTabVal)
	lRetFun	:= U_FSValQry(aTabVal[nXi][1], aTabVal[nXi][2])
	If !lRetFun
		Exit
	EndIf
Next nXi

Return(lRetFun)