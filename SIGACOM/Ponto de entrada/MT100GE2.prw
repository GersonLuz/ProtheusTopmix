#Include 'Protheus.ch'

/*--------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                   	
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 21/11/2018    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: MT100GE2                                  -
----------------------------------------------------------------------------------------
               PONTO DE ENTRADA PARA INFORMAR O CODIGO DE BARRAS DA ABA                -
                              DUPLICATAS NO FINANCEIRO                                 - 
----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------*/ 

********************************* 
User Function MT100GE2()
*********************************

Local aTitAtual   := PARAMIXB[1]
Local nOpc        := PARAMIXB[2]
Local aHeadSE2    := PARAMIXB[3]
//Local aParcelas   := ParamIXB[5]
//Local nX          := ParamIXB[4]

Local nPos:=Ascan(aHeadSE2,{|x| Alltrim(x[2]) == 'E2_CODBAR'})  
   If nOpc == 1 //.. inclusao
       SE2->E2_CODBAR:= aTitAtual[nPos]
   EndIf
Return (Nil)