#INCLUDE "PROTHEUS.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³AFATP00   ³ Autor ³ Jose Antonio (AMM)    ³ Data ³05/12/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³ rodrigo.hollerbach@gmail.com   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function AFATP00()   
Local lFlagUsu:=fValUsu() 

PRIVATE l110Auto	 := .F.
PRIVATE aAutoCab	 := {}
PRIVATE aAutoItens := {}
PRIVATE aRatSC  	 := {}
PRIVATE aRatProj   := {}
PRIVATE bFiltraBrw := {|| Nil}
PRIVATE lCopia     := .F.
PRIVATE l110Alt    := .T.
PRIVATE lGrade     := MaGrade()
PRIVATE lGatilha   := .T.  // Para preencher aCols em funcoes chamadas da validacao (X3_VALID)    
PRIVATE cReqSol 
PRIVATE cCusto		 := "" 
PRIVATE cNumCt
PRIVATE cNumRev	 := ""             
PRIVATE cTpSC
                     
PRIVATE lVldHead	:= GetNewPar( "MV_VLDHEAD",.T. )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis declaradas para guardar as informacoes do rateio qdo for alteracao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nFAltRat    := 0
PRIVATE nFAltRat2   := 0
PRIVATE aCPHSCX     := {}
PRIVATE ACPISCX     := {}

/*
Local aCores := {{ "SC1->C1_ZSTATUS='1'",'BR_VERDE'    },; 
  			     { "SC1->C1_ZSTATUS='2'",'BR_PRETO' },;
  			     { "SC1->C1_ZSTATUS='3'",'BR_AMARELO' },;
  			     { "SC1->C1_ZSTATUS='4'",'BR_VERMELHO' },;
  			     { "SC1->C1_ZSTATUS='5'",'BR_LARANJA' },;
  			     { "SC1->C1_ZSTATUS='6'",'BR_CINZA' },;
  			     { "SC1->C1_ZSTATUS='7'",'BR_PINK' },;
  			     { "SC1->C1_ZSTATUS='8'",'BR_BRANCO' },;
  			     { "SC1->C1_ZSTATUS='9'",'BR_MARRON' },;
  			     { "SC1->C1_ZSTATUS='A'",'BR_AZUL' }  }
*/  			     
aCores := {{'!Empty(C1_RESIDUO)'																			,'BR_PRETO'		},;	//SC Eliminada por Residuo
			{'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV$" ,L"' 		,'ENABLE'		},;	//SC em Aberto
			{'C1_QUJE==0.And.(C1_COTACAO==Space(Len(C1_COTACAO)).Or.C1_COTACAO=="IMPORT").And.C1_APROV="R"'	,'BR_LARANJA'	},;	//SC Rejeitada
			{'C1_QUJE==0.And.(C1_COTACAO==Space(Len(C1_COTACAO)).Or.C1_COTACAO=="IMPORT").And.C1_APROV="B"'	,'BR_CINZA' 	},;	//SC Bloqueada
			{'C1_QUJE==C1_QUANT' 																			,'DISABLE'		},;	//SC com Pedido Colocado
			{'C1_QUJE>0' 																					   ,'BR_AMARELO'	},;	//SC com Pedido Colocado Parcial
			{'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)) ' 								,'BR_AZUL'		},;	//SC em Processo de Cotacao
			{'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)).And. C1_APROV$" ,L"' 		,'BR_PINK'		}}	//SC com Produto Importado
  			     
  			      	 

Private cCadastro := "Solicitações Compras"
Private cAliasMB  := "SC1"
Private aRotina   := {}



  // Rotinas a serem chamadas pelos botoes, atente para a ultima opcao
  // onde chamo a Funcao criada pelo Gaia.
  // OBS: Respeite a numeracao de 1 a 5 que vai de Pesquisar a Excluir pois esta
  //      informacao sera utilizada pelas NewGetDados e Enchoices do Sistema
  aAdd(aRotina,{"Pesquisar"   	 ,"U_AFATP01" ,0,1})
  aAdd(aRotina,{"Visualizar"  	 ,"U_AFATP01" ,0,2})
  aAdd(aRotina,{"Incluir"     	 ,"U_AFATP01" ,0,3})
  aAdd(aRotina,{"Alterar"     	 ,"U_AFATP01" ,0,4}) //  (A110Altera("SC1",SC1->(Recno()),4,.F./*lCopia*/,.F./*lWhenGet*/)) == 1 - Rodrigo Carvalho - 07/07/2015
//aAdd(aRotina,{"Alterar"     	 ,"A110Altera",0,4})
  aAdd(aRotina,{"Excluir"     	 ,"U_AFATP01" ,0,5})
  aAdd(aRotina,{"Legenda"   	    ,"U_FLegenda",0,6})
  IF lFlagUsu
  	  aAdd(aRotina,{"Aprovar SC."  ,"U_AFATP00B",0,7})
  	  aAdd(aRotina,{"Bloquear SC." ,"U_AFATP00B",0,8})
   
     Set Key VK_F5 TO U_AFATP00B()
     
  Endif	
  aAdd(aRotina,{"Tipo Ocorrencias","U_AFATP00C",0,9})
  aAdd(aRotina,{"Ocorrencias"  	 ,"U_AFATP06" ,0,10})
  aAdd(aRotina,{"Comprador"       ,"U_AFATP23" ,0,11})
  // Abre a Tabela e posiciona no primeiro registro
  DbSelectArea(cAliasMB)
  DbSetOrder(1)
  DbGoTop()
  
  mBrowse(6,1,22,75,cAliasMB,,,,,,aCores)

  Set Key VK_F5 TO
     
 Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³AFATP00A  ³ Autor  ³ Rodrigo Hollerbach     ³ Data ³05/12/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function AFATP00A(cAlias,nReg,nOpcX)
// Variaveis Locais da Funcao

// Variaveis Private da Funcao
Private oDlg				// Dialog Principal
// Variaveis que definem a Acao escolhida na MBrowse
Private VISUAL := (nOpcX == 2)
Private INCLUI := (nOpcX == 3)
Private ALTERA := (nOpcX == 4)
Private DELETA := (nOpcX == 5)

DEFINE MSDIALOG oDlg TITLE "Solicitações Compras" FROM C(178),C(181) TO C(548),C(717) PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para tema "Flat"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)


User Function FLegenda()
******************************************************************************************
*    Funcão para montar a legenda do browse do Manutençao de Oferta
**
***
****
Local cCadLegen := "Status Cotacoes"

/*
Local aCores2 := { {'ENABLE'    	, "SC. Liberada Para Cotação" },;
                   {'BR_PRETO'  	, "SC. Aguardando Liberação" },;
                   {'BR_AMARELO'   , "SC. Em Processo de Cotação" },;
                   {'DISABLE'   	, "SC. Bloqueada Por Ocorrência" },;
                   {'BR_LARANJA'   , "SC. Ordem de Compra Gerada" },;
                   {'BR_CINZA'   	, "SC. Pedido Liberado" },;
                   {'BR_PINK'    	, "SC. Pedido Liberado ao Fornecedor" },;
                   {'BR_BRANCO'   	, "SC. Aguardando Entrega Fornecedor/Filial" },;
                   {'BR_MARRON'   	, "SC. Aguardando Entrega Logística" },;
                   {'BR_AZUL'		, "SC. Entregue" } }
*/

Local aCores2 := {{'BR_PRETO'    ,'SC Eliminada por Residuo'},;
				  {'ENABLE'		 ,'SC em Aberto'},;
				  {'BR_LARANJA'  ,'SC Rejeitada'},;
			      {'BR_CINZA' 	 ,'SC Bloqueada'},;
			      {'DISABLE'	 ,'SC com Pedido Colocado'},;
				  {'BR_AMARELO'  ,'SC com Pedido Colocado Parcial'},;
				  {'BR_AZUL'	 ,'SC em Processo de Cotacao'},;
				  {'BR_PINK'	 ,'SC com Produto Importado'}}

BrwLegenda(cCadLegen,"Legenda do Browse",aCores2)

Return   
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³AFATP00B  ³ Autor  ³ Jose Antonio           ³ Data ³20/12/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³Bloqueada e Liberada   SC                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function AFATP00B(cAlias,nReg,nOpcX) 
Local cSolicit :=UsrRetName(RetCodUsr())
Local cCodSoli :=RetCodUsr() 
Local lRet     :=.F. 
Local cNumOcor :=""    
Local cFilSC   := SC1->C1_FILIAL
Local cNumSC   := SC1->C1_NUM           
Local nRegSC1  := SC1->(Recno())

Default cAlias := Alias()
Default nReg   := Recno()
Default nOpcX  := 7

Do Case 
	Case nOpcX == 7
		If  SC1->C1_ZSTATUS $ "1" .And. SC1->C1_APROV == "B"  
		
			If MsgYesNo("Deseja aprovar a SC " + cNumSc + " de forma integral?")				
			   
				dbSelectArea("SC1")
		 		dbSeek(cFilSC+cNumSC)
		 		Do While !Eof() .And. SC1->C1_FILIAL == cFilSC .And. SC1->C1_NUM == cNumSC
		 			If RecLock("SC1", .F.)
		    			SC1->C1_APROV   := "L"   
		    			SC1->C1_NOMAPRO := UsrRetName(RetCodUsr())
		    			If Type("SC1->C1_ZDTAPRO")<>"U" 
		    			   SC1->C1_ZDTAPRO := Date() // Data de aprovacao da solicitacao de compras;
		    			Endif
		 				MsUnLock()  
						lRet:=.T. 
					Endif
					dbSelectArea("SC1")
					dbSkip()
				EndDo
			Else
				dbSelectArea("SC1")
		 		If RecLock("SC1", .F.)
		    		SC1->C1_APROV := "L"
		    		SC1->C1_NOMAPRO := UsrRetName(RetCodUsr())		    		
	    			If Type("SC1->C1_ZDTAPRO")<>"U" 
	    			   SC1->C1_ZDTAPRO := Date() // Data de aprovacao da solicitacao de compras;
	    			Endif
		 			MsUnLock()  
					lRet:=.T. 
				Endif
			EndIf			
   		SysRefresh()			
		Else
			MsgAlert("SC não está aguardando liberação. Favor verificar.","Atenção")
		Endif
	Case nOpcX == 8
		If  SC1->C1_ZSTATUS $ "1" .And. SC1->C1_APROV == "L"                    
			
			If MsgYesNo("Deseja Bloquear a " + cNumSc + " de forma integral?")				
			   
				dbSelectArea("SC1")
		 		dbSeek(cFilSC+cNumSC)

		 		Do While !Eof() .And. SC1->C1_FILIAL == cFilSC .And. SC1->C1_NUM == cNumSC

					dbSelectArea("SC1")
					If RecLock("SC1", .F.)
		    			SC1->C1_APROV := "B"	
		 				MsUnLock()  
						lRet:=.T. 
					Endif
					dbSelectArea("SC1")
					dbSkip()
				EndDo						
			Else
				dbSelectArea("SC1")
				If RecLock("SC1", .F.)
		    		SC1->C1_APROV := "B"				    	
		 			MsUnLock()  
					lRet:=.T. 
				Endif
      	EndIf
		Else
			MsgAlert("SC/Item já está Bloqueada. Favor verificar.","Atenção")
		Endif
Endcase		                    

dbSelectArea("SC1")
dbGoTo(nRegSC1)                	
		
Return()
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³FVALUSU  ³ Autor  ³ Jose Antonio            ³ Data ³20/12/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static function fVALUSU()
Local lRet:=.F.
Local cCodUsu:=RetCodUsr()
	dbSelectArea("SAK")
	dbSetOrder(2)
	lRet:=dbSeek(xFilial("SAK")+cCodUsu)
Return(lRet) 
              
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³AFATP00C  ³ Autor  ³ Jose Antonio           ³ Data ³20/12/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Cadastro de tipo de ocorrencias                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function AFATP00C()      
	dbSelectarea("SZ3")
	dbSetOrder(1)
	AxCadastro("SZ3","Cadastro Tipo de Ocorrencias") 
Return(.T.)   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³FTELAMOT  ³ Autor  ³ Jose Antonio           ³ Data ³20/12/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Monta a tela de correncias e motivos                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function FTelaMot()
Local oBitmap1
Local oBitmap2
Local oFont1 := TFont():New("Calibri",,022,,.T.,,,,,.F.,.F.)
Local oFont2 := TFont():New("Calibri",,020,,.T.,,,,,.F.,.F.)
Local oFont3 := TFont():New("Calibri",,018,,.T.,,,,,.F.,.F.)
Local oFont4 := TFont():New("Calibri",,018,,.F.,,,,,.F.,.F.)
Local oGet1
Local cGet1 := CriaVar("Z2_CODIGO")
Local oGet2
Local cGet2 := CriaVar("Z3_DESC")
Local oGet3
Local cGet3 := CriaVar("Z2_MOTIVO")
Local oGroup1
Local oGroup2
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSButton1
Local oSButton2 
Local lOk
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Registro de Ocorrencias" FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL

    @ 002, 050 SAY oSay1 PROMPT "Bloqueio da SC" SIZE 122, 011 OF oDlg FONT oFont1 COLORS 32768, 16777215 PIXEL
    @ 000, 165 BITMAP oBitmap1 SIZE 041, 015 OF oDlg FILENAME "\Imagens\Flapa_Totvs.png" NOBORDER PIXEL
    @ 000, 207 BITMAP oBitmap2 SIZE 041, 015 OF oDlg FILENAME "\Imagens\TopMix_Totvs.png" NOBORDER PIXEL
 
    @ 016, 002 GROUP oGroup1 TO 080, 248 OF oDlg COLOR 0, 16777215 PIXEL
    @ 021, 005 SAY oSay2 PROMPT "Informe Dados da Ocorrência" SIZE 111, 009 OF oDlg FONT oFont2 COLORS 128, 16777215 PIXEL
 
    @ 030, 005 GROUP oGroup2 TO 076, 245 OF oDlg COLOR 0, 16777215 PIXEL
    @ 040, 007 SAY oSay3 PROMPT "Código" SIZE 025, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
    @ 040, 067 SAY oSay4 PROMPT "Descrição" SIZE 031, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
    @ 055, 007 SAY oSay5 PROMPT "Motivo" SIZE 025, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
   
    @ 037, 029 MSGET oGet1 VAR cGet1 SIZE 029, 011 OF oDlg COLORS 0, 16777215 FONT oFont4 F3 "SZ3"  PIXEL VALID !Empty(cGet1) .And. ExistCpo("SZ3",cGet1)
    @ 037, 097 MSGET oGet2 VAR cGet2 SIZE 144, 011 OF oDlg COLORS 0, 16777215 FONT oFont4 PIXEL WHEN  Eval({||cGet2:= Posicione("SZ3",1,xFilial("SZ3")+cGet2,"Z3_DESC")} )
    @ 052, 029 MSGET oGet3 VAR cGet3 SIZE 212, 011 OF oDlg COLORS 0, 16777215 FONT oFont4 PIXEL 
 
    DEFINE SBUTTON oSButton1 FROM 85, 190 TYPE 01 ACTION  ( lOk:=.T., oDlg:END() ) OF oDlg ENABLE
    DEFINE SBUTTON oSButton2 FROM 85, 219 TYPE 02 ACTION  ( lOk:=.F., oDlg:END() ) OF oDlg ENABLE

 
  ACTIVATE MSDIALOG oDlg CENTERED

Return({lOk,cGet1,cGet3})

