#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                              
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 05/04/2017    - 
----------------------------------------------------------------------------------------
                                  PROGRAMA: TPGPE001                                   -
----------------------------------------------------------------------------------------                          
----------------------------------------------------------------------------------------
                      FUN��O PARA DELETAR A VERBA 331 DA TABELA SRC                    -
                   (C�LCULO FOLHA DE PAGAMENTO)- LAN�AMENTOS DE VALES                  -
---------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------*/ 

*************************************
User Function TPGPE001()
************************************* 

Local cVerba := '331'

	dbSelectArea("SRC")
	dbSetOrder(3)
	dbSeek (xFilial("SRC")+cVerba)
	While !SRC->(Eof()) .And. SRC->RC_PD == cVerba 
	 RecLock("SRC",.F.)
	  dbDelete() // MARCAR COMO DELETADO O REGISTRO
	 MsUnlock()
	 Dbskip()               
	 EndDo
       
return