#Include "RwMake.ch" 
#Define  _CRLF Chr(13)+Chr(10)
/*
+-----------+------------+----------------+-------------------+-------+---------------+
| Programa  | MT103LOK   | Desenvolvedor  | MAX/ROCHA         | Data  | 17/01/2012    |
+-----------+------------+----------------+-------------------+-------+---------------+
| Descricao | Validação da linha de nota fiscal de compra - verifica se existe na tabe|
+-----------+-------------------------------------------------------------------------+
|la de preços para gravação do custo médio e exportação para o KP Betonmix            |
+----------+-------------+------------------------------------------------------------+
| DATA     | PROGRAMADOR | MOTIVO                                                     |
+----------+-------------+------------------------------------------------------------+
+----------+-------------+------------------------------------------------------------+
*/                                           
User Function MT100LOK()   
Local aArea       := GetArea()
Local lRet        := .T. 
Local nXi         := 0              
Local cCodPro  	:= ""
Local cCodFor  	:= ""
Local cLojFor  	:= ""
Local nValUnit 	:= 0
Local	nValFrtUni 	:= 0
Local nQtd     	:= 0                  
Local cTabFor  	:= ""                   
Local cConta   	:= ""                      
Local cITem    	:= ""
Local cCC      	:= ""
Local cTesOK   	:= GetMv("MV_NFSERVF")
Local cTesSD1  	:= ""
Local nVlrMinPrc  := 0 // Valor minimo de Preço unitário aceito, tendo como base o valor informado no campo AIB_PRCCOM
Local nVlrMaxPrc  := 0 // Valor MAXIMO de Preço unitário aceito, tendo como base o valor informado no campo AIB_PRCCOM
Local nVlrMinFrt  := 0 // Valor minimo do frete aceito, tendo como base o valor informado no campo AIB_FRETE
Local nVlrMaxFrt  := 0 // Valor MAXIMO do frete aceito, tendo como base o valor informado no campo AIB_FRETE
Local nValMerc    := 0
Local nTotItem    := 0 
Local lVerifDesc  := .T.  // Considera o desconto informado no item para verificação da tabela de preços.
Local nX          := 0

// pesquisa DA1 
cCodPro  	:= aCols[n][GDFieldPos("D1_COD")]
cCodFor  	:= CA100FOR
cLojFor  	:= CLOJA
nValUnit 	:= aCols[n][GDFieldPos("D1_VUNIT")] 
nValFrtUni	:= aCols[n][GDFieldPos("D1_VALFRE")]   // Valor rateado do frete pelo valor total de cada item (ponderado)
nQtd     	:= aCols[n][GDFieldPos("D1_QUANT")] 
cTabFor  	:= aCols[n][GDFieldPos("D1_TABFOR")] 
cCONTA   	:= aCols[n][GDFieldPos("D1_CONTA")] 
cItem    	:= aCols[n][GDFieldPos("D1_ITEMCTA")]
cCC      	:= aCols[n][GDFieldPos("D1_CC")]
cTesSD1  	:= aCols[n][GDFieldPos("D1_TES")]
nTotItem    := aCols[n][GDFieldPos("D1_TOTAL")]    
cUndMed     := aCols[n][GDFieldPos("D1_UM")]
nVlrDesc    := aCols[n][GDFieldPos("D1_VALDESC")]

If nVlrDesc > 0 .And. lVerifDesc
   nValUnit := Round((Round(nQtd * nValUnit,2) - nVlrDesc) / nQtd,2) 
Endif

//Verificar na tabela de produtos x fornecedores (AIA e AIB)

	IF (RTRIM(CESPECIE) <> "CTR") .AND. (RTRIM(CESPECIE) <> "CTE")  .AND. (RTRIM(CESPECIE) <> "NFST") .AND. !(cTesSD1 $ cTesOK) .AND.;
	 (aCols[n,Len(aHeader)+1]) == .F. // VERIFICA LINHA DELETADA)
	
		If SB1->B1_TIPO="CC"         
		   DBSelectArea("DA1")
		   DbSetOrder(1)   
		  /* Comentado por Felipe Andrews - Solicitacao da Juliana
		   * If ! DBSeek(xFilial("DA1")+"000"+cCodPro ) */
		   If ! DBSeek(xFilial("DA1")+"001"+cCodPro)
		      MSGBOX("Produto ainda não cadastrado no Faturamento\Cenário de Vendas\Tabela de preços... ", "Atenção: ", "STOP"  ) 
		      lRet := .F.
		   EndIF
		EndIF
			
		If SB1->B1_TIPO == "CC" 
		   DBSelectArea("AIB")
		   //DbSetOrder(3)   
		   dbOrderNickName("AIBUSR1") //Filial + Produto + Fornecedor + Loja
		   If ! DBSeek(xFilial("AIB") + cCodPro + cCodFor + cLojFor + cTabFor )
		      MSGBOX("Produto ainda não cadastrado na Tabela ["+cTabFor+"] de Preços de Fornecedores... ", "Atenção: Contacte o Dpto.Tecnológico!", "STOP"  ) 
		      lRet := .F.
		   Else 
		      //avaliar se o preço unitario da nota esta dentro do valor minimo e maximo de aceite.
			   nVlrMinPrc := Round(Round(AIB->AIB_PRCCOM,5) * ( 1 - (SuperGetMv("TM_TMINPRC",,10) / 100 )),5) // valor minimo do preco com 5 decimais
			   nVlrMaxPrc := Round(Round(AIB->AIB_PRCCOM,5) * ( 1 + (SuperGetMv("TM_TMAXPRC",,10) / 100 )),5) // valor maximo do preco com 5 decimais
     		   nVlrMinFrt := Round(Round(AIB->AIB_FRETE ,5) * ( 1 - (SuperGetMv("TM_TMINFRT",, 3) / 100 )),5) // valor minimo do frete com 5 decimais
     		   nVlrMaxFrt := Round(Round(AIB->AIB_FRETE ,5) * ( 1 + (SuperGetMv("TM_TMAXFRT",, 3) / 100 )),5) // valor maximo do frete com 5 decimais

				If Round(nValUnit,5) <> Round(AIB->AIB_PRCCOM,5)  //trabalhar com maximo de 5 casas decimais 
			      If ! (Round(nValUnit,5) >= nVlrMinPrc .And. Round(nValUnit,5) <= nVlrMaxPrc)  // se o PREÇO UNITARIO não estiver entre o minimo e o maximo
                  ApMsgAlert("Foram encontradas inconformidades no VALOR UNITÁRIO: "           +_CRLF +;
			                    "Produto: "+Alltrim(SB1->B1_COD)+ " " +Alltrim(SB1->B1_DESC)      +_CRLF +;
			        	           "Valor Unit Informado: "+Transform(nValUnit,"@E 999,999.999999")  +_CRLF +;
			        	           "Valor minimo Aceito: "+Transform(nVlrMinPrc,"@E 999,999.999999") +" "+;			           	
			                    "Valor maximo Aceito: "+Transform(nVlrMaxPrc,"@E 999,999.999999"))   
			         lRet := .F.
			      Endif
            Endif
		   
		   	If nValFrtUni > 0 // verificar além do preço unitario, também o valor do frete.
		   	   If AIB->AIB_FRETE <= 0
		   	      ApMsgAlert("O valor do frete foi informado na NOTA mas não consta o valor do frete na tabela de preços. Campo: AIB_FRETE!")  
		   	      lRet := .F.
		   	   Endif
			      If ! (Round(nValFrtUni/nQtd,5) >= nVlrMinFrt .And. Round(nValFrtUni/nQtd,5) <= nVlrMaxFrt)// se o FRETE não estiver entre o minimo e o maximo (frete/qtde)
                  ApMsgAlert("Foram encontradas inconformidades no VALOR DO FRETE: "           +_CRLF +;
			                    "Produto: "+Alltrim(SB1->B1_COD)+ " " +Alltrim(SB1->B1_DESC)      +_CRLF +;
			                    "Frete/Qtde Informado: "+Transform(Round(nValFrtUni/nQtd,5),"@E 999,999.999999")  +_CRLF +;
			                    "Valor minimo Aceito: "+Transform(nVlrMinFrt,"@E 999,999.999999") +" "+;			           	
			                    "Valor maximo Aceito: "+Transform(nVlrMaxFrt,"@E 999,999.999999"))         
			         lRet := .F.           
			      Endif              
		   	EndIf		      		
		   	
		   EndIF
		EndIF
		
	 //	For nX := 1 To Len(aCols)  // PRODUTO DO PARAMETRO MV_TOPPROD NÃO SERÁ ACEITO NA CLASSIFICAÇÃO DO DOCUMENTO DE ENTRADA
 		 if (ALLTRIM(aCOLS[n][GdFieldPos("D1_COD", aHeader)]) == GETMV("MV_TOPPROD"))
			 MSGBOX("O produto 99980001 deve ser substituído pelo produto referente ao fornecedor da nota.", "STOP"  ) 
		 lRet := .F.
		 endif		
	 //	Next nX 
		
	EndIF	
   
    
   IF SB1->B1_GRUPO > '1000' .AND. SF4->F4_PODER3 = "N" //abaixo de 1000 são considerados CC
      if ! (cFilAnt $ GETMV("MV_FILEST")) 
         IF SF4->F4_ESTOQUE="S"  //MAX: 23/10/2012 DESCONSIDERAR TES COM PODER DE TERCEIROS 
            MSGBOX("Não é permitido a utilização de TES com movimentação de estoque, para esta filial.", "ATENÇÃO" ,"STOP") 
            lRet := .f.
         EndIF
      EndIF
   EndIF 
   
   IF SB1->B1_ESTOQUE="1" .and. SB1->B1_GRUPO > "1000" .AND. SF4->F4_PODER3 = "N" 
   	if (cFilAnt $ GETMV("MV_FILEST")) 
      	IF SF4->F4_ESTOQUE<>"S"  
         	MSGBOX("Não é permitido a utilização de TES sem movimentação de estoque, para esta filial e este produto.", "ATENÇÃO" ,"STOP") 
         	lRet := .f.
         EndIF	
      EndIF
   EndIF 
   
   DBSelectArea("CT1")
   DbSetOrder(1)   
   IF dbSeek(xFilial("CT1")+cConta)
      If CT1->CT1_CCOBRG = "1" .AND. Empty(cCC) 
        	MSGBOX("Favor informar o Centro de Custo para este produto.", "ATENÇÃO" ,"STOP") 
        	lRet := .f.
      EndIF
      If CT1->CT1_ITOBRG = "1" .AND. Empty(cItem) 
        	MSGBOX("Favor informar o Item Contábil para este produto.", "ATENÇÃO" ,"STOP") 
        	lRet := .f.
      EndIF
   EndIF          

//fim pesquisa

/*
dbSelectArea("SB1")
SB1->(dbSetOrder(1))
SB1->(MsSeek(xFilial("SB1")+aCols[n][GDFieldPos("D1_COD")] ))
If SB1->(Found()) 
    If SB1->B1_LIBMEIO $ "RN"
 		MsgBox(OemToAnsi("Produto com Restição ao Meio Ambiente! Favor verificar!!"),OemtoAnsi("Aviso !!!"),"ALERT")
		lRet := .F.
	Endif
    If SB1->B1_LIBMED $ "RN" .And. lRet
 		MsgBox(OemToAnsi("Produto com Restição a Medicina! Favor verificar!!"),OemtoAnsi("Aviso !!!"),"ALERT")
		lRet := .F.
	Endif
    If SB1->B1_LIBSEG $ "RN" .And. lRet
 		MsgBox(OemToAnsi("Produto com Restição a Segurança! Favor verificar!!"),OemtoAnsi("Aviso !!!"),"ALERT")
		lRet := .F.
	Endif
    If SB1->B1_LIBSEG $ "RN" .And. lRet
 		MsgBox(OemToAnsi("Produto com Restição a Segurança! Favor verificar!!"),OemtoAnsi("Aviso !!!"),"ALERT")
		lRet := .F.
	Endif                
	
   dbselectarea("SZ1")
   dbsetorder(1)
   If dbseek(xFilial("SZ1")+SB1->B1_GRUPO+SB1->B1_CODCLAS+SB1->B1_COSUCLA)
 //  If dbseek(xFilial("SZ1")+SD1->D1_GRUPO+SUBSTRING(SD1->D1_COD,3,6))
      If SZ1->Z1_NCM="S" .And. Empty(aCols[n][GDFieldPos("D1_POSIPI")])
 		MsgBox(OemToAnsi("Obrigatorio informar o NCM deste Produto! Favor verificar!!"),OemtoAnsi("Aviso !!!"),"ALERT")
		lRet := .F.
      Endif
   Endif

EndIf

*/

RestArea(aArea)
Return(lRet)






/*
		   	If nValFrtUni > 0
					//Produto foi encontrado na tabela de preços, então deve verificar se o Valor coicide.
			      If round(nValUnit,5) <> round(AIB->AIB_PRCCOM,5)  //trabalhar com maximo de 5 casas decimais
			         //avaliar se a diferença é maior que um parametro pré-determinado  = 1 real por exemplo
			         If abs(round((AIB->AIB_PRCCOM*nQtd) + (AIB->AIB_FRETE * nQtd ), 5) -  round((nValUnit*nQtd)+nValFrtUni,5)) > getmv("MV_DIFNF") 
			            MSGBOX("Valor informado, diverge do valor cadastrado na Tabela de Preços de Fornecedores... ", ;
			            				"Atenção: Contacte o Dpto.Tecnológico!", "STOP"  ) 
			            MSGBOX("Produto: " + SB1->B1_COD + " " +SB1->B1_DESC + Chr(13)+Chr(10) + "Valor da Nota: " + ;
			            			Transform(nValUnit,"@E 999,999.999999") + Chr(13)+Chr(10) + "Valor Tabelado: " +;
			            			Transform(AIB->AIB_PRCCOM,"@E 999,999.999999") + Chr(13)+Chr(10) + "Valor Frete: " +;
			            			Transform(AIB->AIB_FRETE,"@E 999,999.999999"), "Atenção: Contacte o Dpto.Tecnológico!", "STOP"  ) 
			            lRet := .F.
				      EndIF   
			      EndIF		   	
		   	Else
    				 //avaliar se a diferença é maior que um parametro pré-determinado  = 1 real por exemplo
		         If abs(round(AIB->AIB_PRCCOM*nQtd, 5) -  round(nValUnit*nQtd,5)) > getmv("MV_DIFNF") 
		            MSGBOX("Valor informado, diverge do valor cadastrado na Tabela de Preços de Fornecedores... ", ;
		            			"Atenção: Contacte o Dpto.Tecnológico!", "STOP"  ) 
		            MSGBOX("Produto: " + SB1->B1_COD + " " +SB1->B1_DESC + Chr(13)+Chr(10) + "Valor da Nota: " + ;
		            			Transform(nValUnit,"@E 999,999.999999") + Chr(13)+Chr(10) + "Valor Tabelado: " +;
		            			Transform(AIB->AIB_PRCCOM,"@E 999,999.999999") + Chr(13)+Chr(10), "Atenção: Contacte o Dpto.Tecnológico!", "STOP"  ) 
		            lRet := .F.
			      EndIF   		   	
		   	EndIf		      		

*/