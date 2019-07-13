#Include "Protheus.Ch" 

//------------------------------------------------------------------- 
/*/{Protheus.doc} F240GRV()
Ponto de Entrada para Gravação do Campo E2_ZGRVARQ para Geração do Log.

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
User Function F240GRV()

Local cCodUser := RetCodUsr()
Local cDarReg  := cCodUser+StrTran(DToC(dDataBase),"/")+Left(StrTran(Time(),":"),4)

If SE2->(! Eof())
	Reclock("SE2")
	SE2->E2_ZGRVARQ := cDarReg
	MsUnlock()
EndIf

Return Nil