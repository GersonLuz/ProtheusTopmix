#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} F10NATDEL
Valida exclusao de natureza

@author Giulliano Santos
@since  19/03/2012 
@version P11
@obs  

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function F10NATDEL()
Local lRet := .T.

//Pega os dados do SE1
lRet := u_FSFINP08()

Return lRet