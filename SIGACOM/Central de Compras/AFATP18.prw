/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFATP18   ºAutor  ³Fausto Neto         º Data ³  03/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a exclusão de um fornecedor da cotação.                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
************************************
User Function AFATP18               
************************************
*
*

Local cZNumCot  := aWBrowse2[oWBrowse2:nAt,3]
Local cZFornec  := aWBrowse2[oWBrowse2:nAt,4]
Local cZLoja    := aWBrowse2[oWBrowse2:nAt,5]
Local cFilCot   := aWBrowse2[oWBrowse2:nAt,9]
Local nConta    := 0
Local k         := 0 

BEGIN TRANSACTION
if Empty(cZNumCot) .Or. Empty(cZFornec) 
	ApMsgInfo("Não existe cotação a ser excluída !!!")
	return
endif                

For k := 1 To Len(aWBrowse2)
	If aWBrowse2[k,2] = cZNumCot 
		nConta ++
	EndIf
Next

//impede a exclusao da cotação neste momento pois existem outros tratamentos a serem feitos para liberacao da SC
If nConta = 1                                                                                                   
	MsgStop("Utilize a opção de Excluir Cotação, pois trata-se de apenas 1 fornecedor nesta cotação de preço!")
	Return
EndIf

if MsgYesNo( "O fornecedor " + cZFornec+"/"+cZLoja + " será excluído da cotação " + cZNumCot + ". Confirma ?" )    

	//Marca como deletada a Cotação
	//cQueryEX := "DELETE FROM SC8" + TRBEXC->C8_ZEMP + "0 WHERE C8_NUM = '" + cZNumCot + '""
   //	cQueryEX := "UPDATE " + RetSqlName("SC8") + " SET D_E_L_E_T_ = '*' WHERE C8_FILIAL = '" + cFilCot + "' AND C8_NUMPED = '' AND C8_NUM = '" + cZNumCot + "' AND C8_FORNECE = '" + cZFornec + "' AND C8_LOJA = '" + cZLoja + "'"
	//TcSqlExec( cQueryEX ) 

 //	//volta para estado de cotação liberada
//	cQueryEX := "UPDATE SC1" + TRBEXC->C8_ZEMP + "0 SET C1_COTACAO = '', C1_ZSTATUS = '1', C1_QUJE = 0, C1_APROV = 'L' WHERE C1_COTACAO = '" + cNumCot + "' AND C1_NUM = '" + TRBEXC->C8_NUMSC + "' AND C1_PRODUTO = '" + TRBEXC->C8_PRODUTO + "'"		
//	TcSqlExec( cQueryEX )

   dbSelectArea("SC8")
   dbSetOrder(1)
   If dbSeek(cFilCot+cZNumCot+cZFornec+cZLoja)	      
	While !Eof() .And. SC8->C8_FILIAL == cFilCot .And. SC8->C8_NUM == cZNumCot .And. SC8->C8_FORNECE == cZFornec .And. SC8->C8_LOJA == cZLoja
	 RecLock( "SC8", .F. )	         
	  SC8->( dbDelete() )	         
	  SC8->( MsUnLock() )
	 dbskip()
	 enDdo  
   endif
endif
END TRANSACTION 

return .T.