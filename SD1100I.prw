#include "topconn.ch"
#Include "RwMake.ch"   
#Include "Protheus.ch"

/*
+----------+-----------+----------+-------------------------+------+-----------+
|Programa  |SD1100I    | Autor    |MaxRocha                 |Data  |08.12.2011 |
+----------+-----------+----------+-------------------------+------+-----------+
|Descricao | Ponto de Entrada após gravação da nota fiscal de entrada.         |
+----------+-------------------------------------------------------------------+
| USO      | Compras -> Alterar Tabela de Precos DA1 c/ B2_CM1 (Custo Medio)   |
+----------+-------------------------------------------------------------------+
|                    ALTERACOES FEITAS DESDE A CRIACAO                         |
+----------+-----------+-------------------------------------------------------+
|Autor     | Data      | Descrição                                             |
+----------+-----------+-------------------------------------------------------+
|Max Rocha |08-12-2011 | Inicio das Atividades                                 |
+----------+-----------+-------------------------------------------------------+
|INCLUSAO DE CAMPOS DE USUARIO NECESSARIOS                                     |
+----------------------+----+----+---------------------------------------------+
|SB1->B1_TABMCC        | C  | 01 | Especifica se atualiza ou nao Custo Medio na|
|                      |    |    | tabela de MCC
|DA1->DA1_VARIA        | N  |6,2 | Margem de variacao do custo medio 999.99    | 
+----------------------+----+----+---------------------------------------------+
*/  

User Function SD1100I()                         
     Local aAreaOld := GetArea() //Salvar posições de memoria e ponteiros de tabelas
     Local nCM1 := 0
     Local cTesOK :=  GETMV("MV_NFSERVF")
     Local cTesSD1 := ""
     Local cCodPro := ""
          
     //Etapas a cumprimir
     //1. Identificar produto que entrou, verificar se ele deve atualizar preços no sistema
     cTesSD1       := SD1->D1_TES
     cCodPro       := SD1->D1_COD
     DbSelectArea("SB1")
     DBSetOrder(1)
     If DBSeek(xFilial("SB1")+cCodPro)       
     	If SB1->B1_TIPO == "CC"  //MAX/JULIANA DEFINIDO TIPO = CC   SAO TODOS OS PRODUTOS CONSUMIDOS POR TRAÇOS.
     	   //SB1->B1_TABMCC='S' //Produto Controla e grava custo médio 
     	   //Acha custo médio
     	   DbSelectArea("SB2")
           DBSetOrder(1)
           If DBSeek(xFilial("SB2")+cCodPro+SD1->D1_LOCAL)
              nCM1 := SB2->B2_CM1
           Else
              nCM1 := (SD1->D1_CUSTO/SD1->D1_QUANT)   
     	   EndIF                                   
     	   if  (cTesSD1 <> cTesOk)
	     	  //2. Localizar registro da tabela 001 do produto
	     	   DBSelectArea("DA1")
	     	   DbSetOrder(1)
   		 /* Comentado por Felipe Andrews - Solicitacao da Juliana
	     	   If DBSeek(xFilial("DA1")+"000"+cCodPro ) */
	     	   If DBSeek(xFilial("DA1")+"001"+cCodPro ) 
	     	        //3. comparar preço final, com preço atual,se dentro da margem.
	      	     MSGBOX(rtrim(cCodPro) +" -> " + rTrim (left(SB1->B1_DESC, 25)) + " -> Novo Custo Médio: " + Transform(nCM1, "@E 9,999.9999" ) + " -> Variação de: " + Transform(  (((nCM1 - DA1->DA1_PRCVEN) / DA1->DA1_PRCVEN ) * 100)  , "@e 999.9999" ) + "%", "Atualização de Custo Médio/Tabela de Preços:", "INFO" )
	      	     If abs((( nCM1 - DA1->DA1_PRCVEN) / DA1->DA1_PRCVEN ) * 100) <= DA1->DA1_VARIA
	      	         Reclock("DA1",.F.)
	  			     REPLACE DA1_PRCVEN With nCM1 //MAX: Custo de entrada na nota (SD1->D1_CUSTO/SD1->D1_QUANT)
	                 MsUnlock("DA1")  
	              Else
	                 MSGBOX("Custo médio com variação acima do permitido, ajuste a tabela de preços manualmente!!! "+rtrim(cCodPro) +"->" + rTrim(left(SB1->B1_DESC, 25))  , "Atenção: Confira a Nota Fiscal!!!", "STOP"  )
	              EndIF
	           Else 
	              MSGBOX("Produto ainda não cadastrado no Faturamento\Cenário de Vendas\Tabela de preços... ", "Atenção: ", "STOP"  ) 
	     	   EndIF
	     	EndIF   
	     	//DBSelectArea("SB2")
     	   //DbSetOrder(1)
     	   //If DBSeek(xFilial("SB2")+cCodPro ) 
     	   // 	 Alert("SB2 Custo Medio gravado: " + str(SB2->B2_CM1)) )
     	   //EndIF 	 
     	 EndIF
     endIF
     


     //4. salvar preço atual em tabela de log, alterar preco 
                    
     //Restaura área anterior
     RestArea(aAreaOld)
  
Return