#Include "Protheus.Ch" 

//------------------------------------------------------------------- 
/*/{Protheus.doc} F240TIT()
Ponto de Entrada para tratamento na selecção de titulos para bordero.

@protected	
@author		Ederson Colen
@since		22/06/2012
@version 	P11
@obs			Desenvolvimento Atendimento Pontual
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function F240TIT()

Local lRet:=.T. 

If AllTrim(Upper(FunName())) == "SIFINE02"
	If (Type('dDtPgtBor') = "U" .Or. dDtPgtBor = Nil)
	  //	Aviso("A T E N C A O","Ha Rotina FINA240 foi encapsulada e o menu não esta configurado corretamente. Favor entrar em contato com a TI e solicitar que o menu seja corrigido chamando a Rotina SIFINE01.",{"OK"})
		dDtPgtBor := dDataBase
	EndIf

	If Empty(dDtPgtBor)
		dDtPgtBor := dDataBase
	EndIf

	If SE2->E2_VENCREA < dDtPgtBor .And. SE2->E2_CONAPRE <> 'S'
	   If AllTrim(Upper(ProcName(3))) == "FA240MARK"
			Aviso("A T E N C A O","Este Titulo não poderá ser marcado pois o vencimento real é menor que a data de pagamento.",{"OK"})
	   EndIf
		lRet := .F. 
	EndIf
EndIf

Return(lRet)