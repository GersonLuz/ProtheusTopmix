#Include "Protheus.ch"
#Define _CRLF CHR(13) + CHR(10)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINP15
Valida a alteração do titulo RCT

@author Giulliano Santos
@since  19/03/2012 
@version P11
@obs  

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFINP15()

Local lRetFun := .T.    
Local cMsgError := ""

If !U_FsRebVal("lAltSE1")
   
	If AllTrim(M->E1_TIPO) == "RCT" .Or. AllTrim(M->E1_TIPO) == "NCC"
		lRetFun := .F.    
		cMsgError := "Processo TopMix"  + _CRLF
		cMsgError += "Não se pode alterar um titulo do tipo RCT/NCC de forma manual!" + _CRLF
		MsgAlert(cMsgError)	
	EndIf

EndIf	

Return lRetFun