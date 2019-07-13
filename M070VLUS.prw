#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} M070VLUS
Ponto de entrada que permite a exclusao de bancos.

@author Giulliano Santos
@since  19/03/2012 
@version P11
@obs  

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function M070VLUS

Local nOpc := paramixb
Local lRetFun := .T.
   
//Somente Exclusão
If nOpc == 5
	lRetFun := u_FSFINP07() 
EndIf

Return lRetFun