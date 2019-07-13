#Include "Protheus.ch"
#Define _CRLF CHR(13) + CHR(10)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FA040GRV
Após a gravação do titulo.

@author Giulliano Santos
@since  19/03/2012 
@version P11
@obs  

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FA040GRV()

If	U_FsRebVal("lProSE1") .And. AllTrim(SE1->E1_TIPO) != "RCT"
	u_FSFINP12() // Gerar os titulos RCT  
	//Desligar o processo para gerar os tiulos no SE1
	u_FSPutVal("lProSE1", .F.)
EndIf

Return Nil