#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FA040B01
Ponto de entrada para pegar os dados do SE1 antes da exclusão

@author Giulliano Santos
@since  19/03/2012 
@version P11
@obs  

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FA040B01()
Local lRet := .T.

If !U_FsRebVal("lExcSE1")
	
	//Pega os dados do SE1
	u_FSGETP06()
			
	//Pega os dados do SE1
	If SE1->E1_TIPO == 'RCT'
		lRet := .F.
		Alert("Não se pode excluir um título RCT!")
	EndIf
	
	If lRet
		//Processo customizado para exclusao de titulos RCT
		If AllTrim(SE1->E1_ZCARTAO) == "S" .And. AllTrim(SE1->E1_TIPO) == "NCC"
			lRet := u_FSFINP13()
		EndIf		
	EndIf	

EndIf	
	
Return lRet