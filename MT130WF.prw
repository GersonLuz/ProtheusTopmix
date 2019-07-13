#include "TopConn.ch"
#include "Protheus.ch"
//--------------------------------------------------------------
/*/{Protheus.doc} MT130WF
PE Apos a confirmacao da COTACAO.

@param  
@author Rodrigo Carvalho
@since  09/03/2016
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
User Function MT130WF()

Local aNumCot  := ParamIXB[2] 
Local cCot     := ""

If Len(aNumCot) > 0 .And. FunName() == "FPNLCOM"
   aEval(aNumCot , {|xCot|  cCot += xCot+CRLF })
   Aviso("Cota��o Gerada","Segue a lista das cota��es geradas: "+CRLF+cCot,{"OK"},3)
Endif
Return Nil