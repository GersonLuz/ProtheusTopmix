#INCLUDE "PROTHEUS.CH"

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 10/03/2017    - 
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM001                                  -
----------------------------------------------------------------------------------------
                 FUNÇÃO PARA VALIDAR DUPLICIDADE DE CENTRO DE CUSTO NA SC              - 
----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------*/ 

******************************
User Function TPCOM001()
******************************

Local lRet     := .T.
Local nX       := 0
Local nPosCCus := aScan(aHeader,{|x| Rtrim(x[2]) == "C1_CC"})
Local nValid   := 0

For nX := 1 To Len(aCols)
 If Len(aCols) > 1
  If M->C1_CC == aCols[nX][ nPosCCus ] .AND. (nValid == 0) // NAO VALIDAR A PROPRIA LINHA E SOMENTE UMA VEZ
   Alert("O Centro de Custo "+M->C1_CC+"já foi selecionado. Não será permitido sua utilização.")
	lRet   := .F.
   nValid := 1
  Endif
 Endif   
Next nX

return lRet