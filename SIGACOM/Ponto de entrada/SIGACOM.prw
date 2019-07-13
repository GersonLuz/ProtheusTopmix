#INCLUDE "RWMAKE.CH"
#include "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH" 

/*------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                          -                                                    
--------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 01/03/2019  - 
--------------------------------------------------------------------------------------
                                   PROGRAMA: SIGACOM                                 -
--------------------------------------------------------------------------------------
                    PONTO DE ENTRADA AO LOGAR NO MÓDULO DE COMPRAS                   -
-------------------------------------------------------------------------------------*/ 

********************************
User Function SIGACOM()
********************************

Local cQuery       := ""
Public aProxPed    := {}
Public cProxPed    := "" 

cQuery := "UPDATE "+RetSqlName("SC7")+" SET C7_CONAPRO = 'L' FROM "+RetSqlName("SC7")+" 
cQuery += "INNER JOIN "+RetSqlName("SCR")+" ON CR_FILIAL = C7_FILIAL AND CR_NUM = C7_NUM AND SCR.D_E_L_E_T_ = '' "
cQuery += "WHERE CR_DATALIB <> '' AND CR_LIBAPRO <> '' AND C7_CONAPRO = 'B' AND C7_EMISSAO >= '20190101' AND SC7.D_E_L_E_T_ = ''"
TCSqlExec(cQuery)

return()