#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH" 

/*--------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                   	
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 17/07/2017    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: MA130QSC                                  -
----------------------------------------------------------------------------------------
                  PONTO DE ENTRADA PARA EVITAR AGLUTINA��O DO MESMO PRODUTO            -
                                   NOS PEDIDO DE COMPRAS                              - 
----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------*/ 

*********************************                                                                     
User Function MA130QSC()
*********************************

Local bQuebra  := Paramixb[1] := {||R_E_C_N_O_}  //Defini��o do bloco de c�digo para quebra                  

Return bQuebra