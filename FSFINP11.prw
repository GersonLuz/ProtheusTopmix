#Include "Protheus.ch"
#Define _CRLF CHR(13) + CHR(10)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINP11
Chamado ponto de entrada FA040INC

@author Giulliano Santos
@since  19/03/2012 
@version P11
@obs  

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFINP11()

Local lRetFun := .T.    
Local cMsgError := ""    

        
If AllTrim(M->E1_TIPO) == "NCC" .And. AllTrim(M->E1_ZCARTAO) == "S"  
	
	If Empty(M->E1_ZOP)   .Or. Empty(M->E1_ZNUMTID) .Or. Empty(M->E1_ZNVEZES) ;
	  .Or. Empty(M->E1_ZCARTAO)
	  	lRetFun := .F.    
		cMsgError := "Processo TopMix"  + _CRLF
		cMsgError += "Para utilizar o processo de transação de cartão, os campos são obrigatorios:"  + _CRLF
		cMsgError += "Op do Cartão - Operadora do Cartão"  + _CRLF
		cMsgError += "Num. Transac - Numero da transação"  + _CRLF
		cMsgError += "Num de Vezes - Numero de vezes"      
  	   MsgAlert(cMsgError)
	Else
		//Ligar o processo para gerar os tiulos no SE1
		U_FSPutVal("lProSE1", .T.)
	EndIf

EndIf

If	lRetFun .And. !(U_FsRebVal("lProSE1")) .And. AllTrim(M->E1_TIPO) == "RCT" 
		/*
		lRetFun := .F.    
		cMsgError := "Processo TopMix"  + _CRLF
		cMsgError += "Não se pode incluir um titulo do tipo RCT de forma manual!" + _CRLF
		cMsgError += "Somente via processo customizado!" + _CRLF
		MsgAlert(cMsgError)
		*/
EndIf

Return lRetFun