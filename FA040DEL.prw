#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FA040DEL
Executa processamento após a exclusao dos titulos

@author Giulliano Santos
@since  19/03/2012 
@version P11
@obs  

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FA040DEL()
Local lRet := .T.

//Pega os dados do SE1
u_FSEXCP06()

Return lRet