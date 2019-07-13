#INCLUDE "PROTHEUS.CH"

/*--------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                   	
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 21/11/2018    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: MT103SE2                                  -
----------------------------------------------------------------------------------------
               PONTO DE ENTRADA PARA INCLUSÃO DO CAMPO CODIGO DE BARRAS NA ABA         -
                        DUPLICATAS NA ROTINA DE DOCUMENTO DE ENTRADA                   - 
----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------*/ 

********************************
User Function MT103SE2
********************************

Local aHead    := PARAMIXB[1]
Local lVisual  := PARAMIXB[2]
Local aRet     := {}// Customizações desejadas para adição do campo no grid de informações


If  MsSeek("E2_CODBAR")   // Campo de Vencimento Original

AADD(aRet,{ TRIM(X3Titulo()),SX3->X3_CAMPO, SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL, "",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX, SX3->X3_RELACAO, ".T."}) 

EndIf 

Return (aRet)