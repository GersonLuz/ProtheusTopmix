#INCLUDE "RWMAKE.CH"
#include "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH" 

/*------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                          -                                                    
--------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 02/12/2018  - 
--------------------------------------------------------------------------------------
                                   PROGRAMA: MT120TEL                                -
--------------------------------------------------------------------------------------
                    PONTO DE ENTRADA PARA ARMAZENAR OBJETO MESDIALOG                 -
                      DE ROTINA DE LIBERA��O DE PEDIDO DE COMPRAS                    -
-------------------------------------------------------------------------------------*/ 

********************************
User Function MT120TEL()
********************************

Local aPosGet      := PARAMIXB[2]
Local aObj         := PARAMIXB[3]
Local nOpcx        := PARAMIXB[4]
Local nReg         := PARAMIXB[5]//-- Customiza��es do usuario
Public oNewDialog  := PARAMIXB[1] 


Return 