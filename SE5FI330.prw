//-------------------------------------------------------------------
/*/{Protheus.doc} SE5FI330
Ponto de Entrada que permite realizar grava��es complementares na tabela 
SE5, ap�s a grava��o do movimento banc�rio do t�tulo principal na compensa��o 
a receber autom�tica.

@author		Fernando Ferreira
@since    	22/01/2013
Alteracoes	Realizadas desde a Estruturacao Inicial 
Data       	Programador     					Motivo 
/*/
//-------------------------------------------------------------------
User Function SE5FI330()

	If IsInCallStack("FSFINP10")
		If SE5->(RecLock("SE5"), .F.)
		   SE5->E5_FILORIG = xFilial("SE5")
		   SE5->(MsUnLock())
		EndIf	          
	EndIf
	
Return Nil


