#Include "Protheus.ch"
/*
+-----------+------------+----------------+-------------------+-------+---------------+
| Programa  | LP650IS    | Desenvolvedor  | Juliana           | Data  | 17/03/2009    |
+-----------+------------+----------------+-------------------+-------+---------------+
| Descricao | Busca valor do titulo de ISS Provisao                                   |
+-----------+-------------------------------------------------------------------------+
| Uso       | Exclusivo Geosol                                                        |
+-----------+-------------------------------------------------------------------------+
|                  Modificacoes desde a construcao inicial                            |
+-----------+-------------------------------------------------------------------------+
|           |         |                                                               |
+-------------------------------------------------------------------------------------+
*/
User Function LP650IS()
Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()                                                                                
Local cCod    :=""     
Local pDoc      :=SF1->F1_DOC         
Local pSerie    :=SF1->F1_SERIE
Local pFornece  :=SF1->F1_FORNECE 
Local pLoja     :=SF1->F1_LOJA
	BeginSql Alias cAliasQry         
	  SELECT A2_COD
		FROM %table:SE2%  SE2    
		INNER JOIN %table:SA2% SA2 ON(SA2.A2_COD = SE2.E2_FORNECE AND SA2.A2_LOJA = SE2.E2_LOJA AND SE2.E2_TIPO=%Exp:"ISS"% AND SE2.%notdel%)  
		WHERE SE2.%notDel% AND 
			SUBSTRING(SE2.E2_TITPAI,1,3)  = %Exp:pSerie%    AND
			SUBSTRING(SE2.E2_TITPAI,4,9)  = %Exp:pDoc%      AND 
			SUBSTRING(SE2.E2_TITPAI,19,6) = %Exp:pFornece%  AND  
			SUBSTRING(SE2.E2_TITPAI,25,2) = %Exp:pLoja%    
  	EndSql   
	cCod:=(cAliasQry)->A2_COD
	(cAliasQry)->(dbCloseArea())
RestArea(aAliasOLD)   
Return(cCod) 
