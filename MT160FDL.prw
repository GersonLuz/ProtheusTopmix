#INCLUDE "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} MT160FDL
Dentro da rotina de cotação

@param  
@author Rodrigo Carvalho
@since  04/01/2016
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------

User Function MT160FDL()

Local a := 1 //Ma160Fld(x,oFolder:nOption,oFolder,@aCabec,@aListBox,aPosObj3)

Return Nil



User Function M160MARK()
 
Local ExpC1 := PARAMIXB[1] 
Local ExpA1 := PARAMIXB[2]
Local ExpA2 := PARAMIXB[3]
Local ExpA3 := PARAMIXB[4]                                               
Local ExpA4 := PARAMIXB[5] 

Return {ExpA1,ExpA2,ExpA3}



User Function MT160PCOK()

Local a := 1

Return NIL



User Function MTA160MNU()

aadd(aRotina,{'Teste','U_MCMTA160' , 0 , 3,0,NIL})     

Return ()  