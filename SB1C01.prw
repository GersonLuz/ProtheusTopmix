#Include "RWMAKE.CH"
/*
+-----------+------------+----------------+-------------------+-------+---------------+
| Programa  | SB1C01     | Desenvolvedor  | Juliana/MaxRocha  | Data  | 06/09/2011    |
+-----------+-------------------------------------------------------------------------+
| Descricao | Gatilho para gerar codigo sequencial do  codigo do produto              |
+-----------+-------------------------------------------------------------------------+
|                  Modificacoes desde a construcao inicial                            |             
+----------+-------------+------------------------------------------------------------+
| DATA     | PROGRAMADOR | Max Rocha                                                  |
+----------+-------------+------------------------------------------------------------+
|          |             |                                                            |
+----------+-------------+------------------------------------------------------------+
*/    
     
User Function SB1C01()
Local aArea   := GetArea()
Local nSeque  := 0
Local cCodNew := Space(8) 
Local cProd   :=M->B1_GRUPO
    
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+cProd,.T.)
	While ! SB1->(Eof()) .And. SB1->B1_FILIAL == xFilial("SB1") .And. Alltrim(SB1->B1_GRUPO) == cProd
 	nSeque := Val(Substr(SB1->B1_COD,5,4))     
	      dbSelectArea("SB1")
	      dbSkip()
	EndDo
	nSeque++
	While .T.
	      cCodNew := cProd+StrZero(nSeque,4,0)
	      dbSelectArea("SB1")
	      dbSetOrder(1)
	      If !dbSeek(xFilial("SB1")+cCodNew)
	         Exit
	      Else
	         nSeque++
	      Endif    
	      Loop
	End         
	//M->B1_CODIGO := cCodNew
RestArea(aArea)
Return(cCodNew)