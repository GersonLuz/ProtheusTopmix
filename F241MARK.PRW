#Include "Protheus.Ch" 

//------------------------------------------------------------------- 
/*/{Protheus.doc} F241MARK()
Ponto de Entrada para Definição da Data de Pagamento.

@protected	
@author	 Ederson Colen
@since	 20/06/2012
@version  P11.5
@obs	  	 Referente atendimento pontual
@param    aCampos - Array com os campos do Mark Browse
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function F241MARK()

//Pergunta com da Data de Pagamento do Borderô.
If Upper(AllTrim(ProcName(2))) == "FA241BORDE"
	Pergunte("SIFINE02",.T.)
EndIf

If (Type('dDtPgtBor') = "U" .Or. dDtPgtBor = Nil)
//	Aviso("A T E N C A O","Ha Rotina FINA240 foi encapsulada e o menu não esta configurado corretamente. Favor entrar em contato com a TI e solicitar que o menu seja corrigido chamando a Rotina SIFINE01.",{"OK"})
EndIf

dDtPgtBor := MV_PAR01

Return (PARAMIXB)