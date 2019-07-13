#INCLUDE "RWMAKE.CH"                                                                                   
#INCLUDE "TOPCONN.CH"                                                                                                                     
#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH" 

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 26/05/2017    - 
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM002                                  -
----------------------------------------------------------------------------------------
                   FUNÇÃO PARA ALTERAR CNPJ DE UM MESMO FORNECEDOR                     -
                                DO PEDIDO DE COMPRA                                    -
----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------*/ 

**************************************
User Function TPCOM002()
**************************************

Local oDlg, oForn, oLoja
Private cFil    := aWBrowse4[oWBrowse4:nAt,12]
Private cNumPed := aWBrowse4[oWBrowse4:nAt,3]
Private cForn   := aWBrowse4[oWBrowse4:nAt,14]
Private cLoja   := aWBrowse4[oWBrowse4:nAt,8] 

	DEFINE MSDIALOG oDlg FROM 0,0 TO 070,296 PIXEL TITLE "Alterar CNPJ Fornecedor"      
	
	@ 12,023 MSGET oForn VAR cForn SIZE 45,08 OF oDlg PIXEL  WHEN .F. Picture PesqPict("SC7","C7_NUM")
	@ 12,070 MSGET oLoja VAR cLoja SIZE 25,08 OF oDlg PIXEL F3 "SA22" Picture PesqPict("SC7","C7_LOJA")
	
	@ 18,120 BMPBUTTON TYPE 01 ACTION IIF (TPCOM01() == .T., oDlg:End(),.F.)  Object bt01                          
	
	ACTIVATE MSDIALOG oDlg Centered  

Return

*****************************
Static Function TPCOM01()                     
*****************************
 
Local lRet := .T.
Local cLock := 'N'

	dbSelectAre("SC7")
	dbSetOrder(1)
	If dbSeek(cFil+cNumPed )
	 dbSelectAre("SA2") // VALIDAR FORNECEDOR
	 dbSetOrder(1)
	  If dbSeek(xFilial("SA2")+cForn+cLoja)
		 While ! Eof() .AND. ((cFil == SC7->C7_FILIAL) .AND. (cNumPed == SC7->C7_NUM))
			     	If RecLock("SC7", .F.)
						SC7->C7_LOJA := cLoja
						SC7->(MsUnLock())
						cLock := 'S'
					EndIf		     
			      DbSkip()
		Enddo
			If cLock == 'S'
			MsgInfo("O CNPJ foi alterado com sucesso.")
			Endif
	  Else
	  MsgInfo("O CNPJ informado não corresponde ao Fornecedor Original do Pedido de Compras. Favor selecionar o CNPJ correto.")
	  lRet := .F.
	  Endif	
	Endif 

return lRet     



