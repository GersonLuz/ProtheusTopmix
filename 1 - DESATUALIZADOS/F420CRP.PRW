#Include "Protheus.Ch" 

//------------------------------------------------------------------- 
/*/{Protheus.doc} F420CRP()
Ponto de Entrada para chamar a tela de Log da Geração do Arquivo CNAB

@protected	
@author	 Ederson Colen
@since	 03/07/2012
@version  P11.5
@obs	  	 Referente atendimento pontual
@param    
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function F420CRP()

If Select("TRBSE2") <> 0 .And. cFilBord <> ' E2_NUM = "*********" '
	//Tela de Log da Geração do Arquivo CNAB
	U_FTelLog("CNAB")
EndIf

Return Nil 