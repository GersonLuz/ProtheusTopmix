#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINP05
Processo realiza a alteração dos campos do Título
          
@author Fernando Ferreira
@since 24/02/2012
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFINP05
If IsInCallStack("U_FSINTP02")
	Reclock("SE1",.F.)
		SE1->E1_EMIS1 := SE1->E1_EMISSAO
	MsUnlock()
EndIf
Return Nil


