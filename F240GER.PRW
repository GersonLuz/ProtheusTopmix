#Include "Protheus.Ch" 

//------------------------------------------------------------------- 
/*/{Protheus.doc} F240GER()
Ponto de Entrada para Inclus�o da Tela de Log ao final do Processo SISPAG

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
User Function F240GER()

Local cCanTelFil := ""

//Rotina Padr�o do Sistema
Processa({||SisPagGer("SE2")})

If Select("TRBSE2") <> 0 .And. cCanTelFil <> '"******#"'
	//Tela de Log da Gera��o do Arquivo CNAB
	U_FTelLog("SISPAG")
EndIf

Return (.T.)

