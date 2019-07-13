#include "TopConn.ch"
#include "Protheus.ch"
//--------------------------------------------------------------
/*/{Protheus.doc} MT160WF
PE Apos a confirmacao a ANALISE DA COTACAO.

@param  
@author Rodrigo Carvalho
@since  09/03/2016
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
User Function MT160WF( cNumPed )

Local   cNumCot   := PARAMIXB[1]
Local   cPcGerado := FLstPC(cNumCot)
Default cNumPed   := ""

If cNumCot == SC7->C7_NUMCOT .And. FunName() == "FPNLCOM"
   If Empty(cPcGerado)
      Aviso("Pedido de Venda Gerado","Número do Pedido Gerado: "+CRLF+SC7->C7_NUM,{"OK"},3)
   Else
      Aviso("Pedido de Venda Gerado",cPcGerado,{"OK"},3)   
   Endif
Endif
	
Return .t.




//--------------------------------------------------------------
/*/{Protheus.doc} FLstPC

@param  
@author Rodrigo Carvalho
@since  09/03/2016
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
Static Function FLstPC(cNumCot)

Local   cListaPC := ""
Local   cQryC7   := ""
Default cNumCot  := ""

If Empty(cNumCot)
   Return cListaPC
Endif   

cQryC7 += "SELECT DISTINCT C7_NUM, A2_NOME, C7_LOJA"
cQryC7 += "  FROM "+RetSqlName("SC7")+" C7(NOLOCK)"
cQryC7 += " INNER JOIN "+RetSqlName("SA2")+" A2 ON A2_COD = C7_FORNECE"
cQryC7 += "                     AND A2_LOJA = C7_LOJA"
cQryC7 += "                     AND A2.D_E_L_E_T_ <> '*'"
cQryC7 += " WHERE C7_EMISSAO = '" + DtoS(date())   + "'"
cQryC7 += "   AND C7_FILIAL  = '" + xFilial("SC7") + "'"
cQryC7 += "   AND C7_NUMCOT  = '" + cNumCot        + "'"
cQryC7 += "   AND C7.D_E_L_E_T_ <> '*'"
cQryC7 += " ORDER BY 1 DESC"

TCQuery cQryC7 Alias "TMPSC7" New	

DbSelectArea("TMPSC7")
Do While ! TMPSC7->(Eof()) 
   cListaPC += TMPSC7->("Pedido: "+C7_NUM +" => "+ Capital(Alltrim(A2_NOME)) + "-"+ C7_LOJA) + CRLF
   TMPSC7->(DbSkip())
Enddo   
DbCloseArea("TMPSC7")
 
Return(cListaPC) 