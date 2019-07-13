#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} AFATP20
Exclui o pedido de compra e libera a cotação    

@protected
@author    Fausto Neto
@since     03/10/10
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador      Motivo
09/06/2015 Rodrigo Carvalho Alteração na forma de exclusao dos registros.
/*/
//-------------------------------------------------------------------

User Function AFATP20(cOrigem , cFilBrw4 , cPedBrw4 , cCotBrw4 )

Local cZFilOri   := ""
Local cZNumPed   := ""
Local cZNumCot   := ""
Local lPodeEx    := .T.
Local lAgrupado  := .F.

Default cFilBrw4 := ""
Default cPedBrw4 := ""
Default cCotBrw4 := ""

If cOrigem == "3"    
	cZFilOri  := aWBrowse3[oWBrowse3:nAt,10]
	cZNumPed  := aWBrowse3[oWBrowse3:nAt,2 ]
	cZNumCot  := aWBrowse3[oWBrowse3:nAt,4 ]
elseIf cOrigem == "4"
	cZFilOri  := aWBrowse4[oWBrowse4:nAt,11]
	cZNumPed  := aWBrowse4[oWBrowse4:nAt,2 ]
	cZNumCot  := aWBrowse4[oWBrowse4:nAt,5 ]
elseIf cOrigem == "4.1"
	cZFilOri  := cFilBrw4
	cZNumPed  := cPedBrw4
	cZNumCot  := cCotBrw4
Endif

If Empty(cZNumPed) 
	ApMsgInfo("Não existe Pedido de Compra a ser excluído !!!")
	return
Endif 

dbSelectArea("SC7")
dbSetOrder(1)
If DbSeek(cZFilOri + cZNumPed)
	While !Eof("SC7") .And. cZFilOri == SC7->C7_FILIAL .And. cZNumPed == SC7->C7_NUM
		If SC7->C7_QUJE > 0 
			lPodeEx := .F.
		Endif
		dbSelectArea("SC7")
		dbSkip()
	EndDo
Endif    

If !lPodeEx
	ApMsgInfo("Pedido de Compra já amarrado à nota fiscal não pode ser excluído !")
	return
Endif

If MsgYesNo( "O Pedido de Compra " + cZNumPed + " será excluído. Confirma ?" )    

	dbSelectArea("SC7")
	dbSetOrder(1)
   
	If DbSeek( cZFilOri + cZNumPed )
	   
	   Begin Transaction 
   
   	U_FLogFile("Iniciando exclusão do Pedido de Compra: "+cZFilOri+"/"+cZNumPed)   
	
		While ! Eof("SC7") .And. cZFilOri == SC7->C7_FILIAL .And. cZNumPed == SC7->C7_NUM
		      
		      /*--------------------------------------------------------------------------------------------------------------------
		      Observação: Não mais terão solicitacoes provenientes de outras empresas, o que certamente Inviabilizaria a modificacao
                        para exclusão via advpl.
		      /*--------------------------------------------------------------------------------------------------------------------
			   cQueryEX := "UPDATE SC1" + SC7->C7_ZEMP + "0 SET C1_ZSTATUS = '3', C1_PEDIDO = ' ' WHERE C1_NUM = '" + SC7->C7_NUMSC +;
			   "' AND C1_ITEM = '" + SC7->C7_ITEMSC + "' AND C1_FILIAL = '"+SC7->C7_FILIAL+"'"
			   TcSqlExec( cQueryEX ) 		                                                         
		      */
		      
		      DbSelectArea("SC1")
		      DbSetOrder(1) //C1_FILIAL + C1_NUM + C1_ITEM
		      
		      If DbSeek( SC7->(C7_FILIAL + C7_NUMSC + C7_ITEMSC) )
   	         Reclock("SC1",.F.)  
               SC1->C1_ZSTATUS := "3"
               SC1->C1_PEDIDO  := " "
               SC1->C1_ITEMPED := " "
               MsUnlock("SC1")
            Else
          		ApMsgAlert("Item Solicitação não encontrado! Copie essa tela e encaminhe ao analista! - "+SC7->(C7_FILIAL +"/"+ C7_NUMSC +"/"+ C7_ITEMSC))   
               U_FLogFile("Tentativa de exclusão da tabela SC1 - Pedido de Compra: "+cZFilOri+"/"+cZNumPed+" - NÃO EXCLUIDO")		                 	            		
		      Endif
		      
		      /*
			   cQueryEX := "UPDATE " + RetSqlName("SC8") + " SET C8_NUMPED = ' ',  C8_ITEMPED = ' ', C8_ZSTATUS = '3' , C8_ZGANHAD = ' ' "+;
                        "WHERE C8_FILIAL = '" +SC7->C7_FILIAL + "' AND  C8_NUM = '" + cZNumCot + "' AND C8_PRODUTO = '" + SC7->C7_PRODUTO + ;
			               "' AND C8_NUMSC = '" + SC7->C7_NUMSC + "'"
			   TcSqlExec( cQueryEX ) 
            */
            
		      DbSelectArea("SC8")
            DbSetOrder(3) // C8_FILIAL + C8_NUM    + C8_PRODUTO + C8_FORNECE + C8_LOJA + C8_NUMPED + C8_ITEMPED+C8_ITSCGRD //10607
            If DbSeek( SC7->(C7_FILIAL + C7_NUMCOT + C7_PRODUTO ) , .T. )
               Do While ! Eof() .And. SC7->(C7_FILIAL + C7_NUMCOT + C7_PRODUTO ) == SC8->(C8_FILIAL + C8_NUM + C8_PRODUTO)
   	            Reclock("SC8",.F.)    
   	            SC8->C8_ITEMSC  := IIf(Alltrim(SC8->C8_OK) == "X","999",SC8->C8_ITEMSC)
                  SC8->C8_NUMPED  := " "
                  SC8->C8_ITEMPED := " "
                  SC8->C8_ZSTATUS := "3"
                  SC8->C8_ZGANHAD := " "
                  MsUnlock("SC8")
                  lAgrupado := Alltrim(SC8->C8_ITEMSC) == "999"
                  SC8->(DbSkip())
               Enddo
            Else
          		ApMsgAlert("Item Cotação não encontrado! Copie essa tela e encaminhe ao analista! - "+SC7->(C7_FILIAL+"/"+C7_NUMCOT+"/"+C7_PRODUTO+"/"+C7_FORNECE+"/"+C7_LOJA+"/"+C7_NUM+"/"+C7_ITEM))
                U_FLogFile("Tentativa de exclusão da tabela SC8 - Pedido de Compra: "+cZFilOri+"/"+cZNumPed+" - NÃO EXCLUIDO")		                 	            		
            Endif

           /*
			  cQueryEX := "UPDATE "+RetSqlName("SCE")+" SET D_E_L_E_T_ = '*' WHERE CE_FILIAL='"+cZFilOri+"' AND CE_NUMCOT='"+cZNumCot+"' AND CE_PRODUTO='"+SC7->C7_PRODUTO+"'"
			  TcSqlExec( cQueryEX )
			  */
			  
			  DbSelectArea("SCE")
			  DbSetOrder(1) // CE_FILIAL + CE_NUMCOT + CE_ITEMCOT + CE_PRODUTO + CE_FORNECE + CE_LOJA+CE_ITEMGRD
			  If DbSeek( SC7->(C7_FILIAL + C7_NUMCOT + C7_ITEM    + C7_PRODUTO + C7_FORNECE + C7_LOJA ) , .T.)
   	        Reclock("SCE",.F.) 
              SCE->(dbDelete()) 
              MsUnlock("SCE") 
           Else
              If ! lAgrupado
             	  ApMsgAlert("Item SCE não encontrado! Copie essa tela e encaminhe ao analista! - "+SC7->(C7_FILIAL+"/"+C7_NUMCOT+"/"+C7_PRODUTO+"/"+C7_FORNECE+"/"+C7_LOJA+"/"+C7_NUM+"/"+C7_ITEM))
                 U_FLogFile("Tentativa de exclusão da tabela SCE - Pedido de Compra: "+cZFilOri+"/"+cZNumPed+" - NÃO EXCLUIDO")		                 	  
              Endif
           Endif
           
			  DbSelectArea("SC7")
   	     Reclock("SC7",.F.) 
           SC7->(dbDelete()) 
           MsUnlock("SC7")
           
			  DbSkip()
		EndDo

    	End Transaction 

   	cQueryEX := "UPDATE " + RetSqlName("SCR") + " SET D_E_L_E_T_ = '*' WHERE CR_NUM = '" + cZNumPed + "' AND CR_FILIAL = '" + cZFilOri + "'"
	   TcSqlExec( cQueryEX )   				

      U_FLogFile("Finalizado exclusão do Pedido de Compra: "+cZFilOri+"/"+cZNumPed)		
      
   Else
      U_FLogFile("Tentativa de exclusão do Pedido de Compra: "+cZFilOri+"/"+cZNumPed+" - NÃO EXCLUIDO")		      
	Endif 

Endif

return