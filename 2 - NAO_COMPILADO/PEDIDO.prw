#INCLUDE "PROTHEUS.CH"
#Include "Rwmake.ch"
#Include "TopConn.ch" 
#INCLUDE "TBICONN.CH"
#INCLUDE "FWADAPTEREAI.CH"


/*************************************************************************************** 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            *                                                   
****************************************************************************************
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ***          DATA: 28/02/2018    * 
****************************************************************************************
                                   PROGRAMA: PEDIDO                                  *
****************************************************************************************
                    FUNÇÃO PARA GERAÇÃO DO RELATÓRIO ESPELHO DE PONTO                  * 
***************************************************************************************/ 

*************************************************
User Function PEDIDO()
*************************************************

Local nRegSC7 := 037906
Local nOpcPC := 2

DbSelectArea("SC7")
DbGoto(nRegSC7)

A120Pedido("SC7",nRegSC7,nOpcPC) // consulta


return()