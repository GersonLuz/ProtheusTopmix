#Include 'Protheus.ch'


User function MA110BUT()

	Local nOpc:= PARAMIXB[1]
	Local aBut:= PARAMIXB[2]//Customiza��o Desejada     
	
	Aadd( aBut, {"S4WB005N", {|| alert(aCols[1][1])}, "Hist�ricX...", "Hist�ricX" , {|| .T.}} ) 

Return aBut




