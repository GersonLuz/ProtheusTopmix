#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFATR01() 
Imprime notas de saida  - Relatorio RPS

@author Giulliano Santos
@since 31/10/2011 
@version P11
@obs 
Projeto FS005495
 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFATR01()
					
Local cDescr1	:= "Este programa tem como objetivo imprimir relatorio "
Local cDescr2  := "de acordo com os parametros informados pelo usuario."
Local cDescr3  := ""
Local cPict    := ""
Local titulo   := "RPS"

Local imprime  := .T.
Local cValPeg	:= "FSFATR01"	 
Local aOrd 		:= {}

Local cNotIni  := CriaVar("F2_DOC"   , .F.)
Local cNotFim  := CriaVar("F2_DOC"   , .F.)
Local cNotSer  := CriaVar("F2_SERIE" , .F.)
Private lImpostos   := .T.   // Imprime o valor aproximado dos impostos/
Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ""
Private limite      := 80
Private tamanho     := "M"
Private nomeprog    := "FSFATR01" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
//Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "FSFATR01" // Coloque aqui o nome do arquivo usado para impressao em disco 
Private lRetQry	  := .T.	
Private nLinRel     := 60
Private aArrRod 	  := {}  //Array para as parcelas   
Private nSE1Tot	  := 0   //Valor total da nota
Private nQtdLin	  := 16
Private lIniOne 	  := .T.
Private nConLin 	  := 0 
Private cTES        := ""
Private cISSST      := ""

//Funcao para criar/ajustar o grupo de perguntas da SX1
FSAjuSX1(cValPeg)

//Chamada das perguntas
If !Pergunte(cValPeg,.T.)
	Return 
EndIf

wnrel := SetPrint("SF2" ,NomeProg,""    ,@titulo  ,cDescr1 ,cDescr2, cDescr3,.F.,.F.,.F.,Tamanho) 

Pergunte(cValPeg,.F.)

cNotIni  := MV_PAR01
cNotFim  := MV_PAR02
cNotSer  := MV_PAR03

// Valida se o usuario cancelou a ação
If (LastKey() == 27 .Or. nLastKey == 27)
   Return
EndIf    

SetDefault(aReturn,"SF2")  

u_FSAjusImp()

MsgRun("Gerando o relatório de RPS","Por favor, aguarde....",{|| lRetQry := FQryRel(cNotIni,cNotFim,cNotSer)})

nTipo := If(aReturn[4]==1,15,18)

//Se a query retornar algum registro, o relátorio é impresso
If (lRetQry)
  	RptStatus({|| FImpRel()},"Imprimindo . . . ","Processando...")
   //+-------------------------------------------------------------------------------
	//| Tratamentos de finalizacao do relatorio
   //+-------------------------------------------------------------------------------
	
	//SetPgEject(.F.)
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif
	MS_FLUSH() 

Else
	Alert("Verificar parametros! Notas inválidas")
EndIf

U_FSFecAre({"TRBCABEC","TRBITENS","TRBFIN"})

Return Nil           

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSAjuSX1() 
Ajusta pergunta no SX1

@protected
@author Giulliano Santos
@since 31/10/2011 
@version P11
@obs 
Projeto FS005495
 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FSAjuSX1(cValPeg)

Local aPergs   := {}
Local aHelpPor := {}

Aadd(aPergs,{ "Da nota fiscal ?","Da nota fiscal ?","Da nota fiscal ?","mv_ch1","C",TamSx3("F2_DOC")[1],0,0,"G","",;
              "MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SF2","018","" }) 
Aadd(aPergs,{ "Até a nota fiscal ? ","Até a nota fiscal ? ","Até a nota fiscal ? ","mv_ch2","C",TamSx3("F2_DOC")[1],0,0,"G","",;
              "MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SF2","018","" }) 
Aadd(aPergs,{ "Da Serie ?","Da Serie ?","Da Serie ?","mv_ch3","C",TamSx3("F1_SERIE")[1],0,0,"G","",;
              "MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","" }) 

//Cria perguntas (padrao)
//AjustaSx1(cValPeg, aPergs)

//Help das perguntas
//Tamanho Linha '1234567890123456789012345678901234567890' )
aHelpPor:= {}
Aadd( aHelpPor, '"Nota de" a ser impressa.' )
PutSX1Help("P." + cValPeg + "01.",aHelpPor,aHelpPor,aHelpPor)

aHelpPor:= {}
Aadd( aHelpPor, '"Nota Até" a ser impressa.' )
PutSX1Help("P." + cValPeg + "02.",aHelpPor,aHelpPor,aHelpPor)

aHelpPor:= {}
Aadd( aHelpPor, '"Serie" a ser impressa.' )
PutSX1Help("P." + cValPeg + "03.",aHelpPor,aHelpPor,aHelpPor)

Return Nil   


//------------------------------------------------------------------- 
/*/{Protheus.doc} FQryRel() 
Monta query para impressao 

@protected
@author Giulliano Santos
@since 31/10/2011 
@version P11
@obs 
Projeto FS005495
 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     		Motivo 
13/02/2012 	Fernando Ferreira    Inclusão dos abatimentos de materiais customizado.
25/05/2012		Fernando Ferreira		Validação para verificar qual produto será totalizado nos totais de quantidades.
/*/ 
//------------------------------------------------------------------ 
Static Function FQryRel(cNotIni,cNotFim,cNotSer)

Local 	cSF2DOC 	:=  CriaVar("F2_DOC",   .F.)
Local 	cSF2SER 	:=  CriaVar("F2_SERIE", .F.)
Local 	lRetFun 	:= .T.
Local		lFlux	  		:= .T.
Local		aDadCliRps := {}

//Cria Arquivo de Trabalho
FCriaTrab()

SF2->(dbSetOrder(1))   // Filial + nota + serie
If SF2->(dbSeek(xFilial("SF2") + cNotIni + cNotSer)) //F2_FILIAL, F2_DOC, F2_SERIE, 
   
	//Cabeçalho
	While (SF2->(!Eof()) ) .And. (SF2->F2_FILIAL == xFilial("SF2")) .And. (SF2->F2_DOC <= cNotFim)
		
		If (SF2->F2_SERIE <> cNotSer)
			SF2->(dbSkip())
			Loop
		Endif
		
		cSF2DOC :=  SF2->F2_DOC
		cSF2SER :=  SF2->F2_SERIE
		
		TRBCABEC->(RecLock("TRBCABEC",.T.))
      TRBCABEC->F2_FILIAL  := SF2->F2_FILIAL 
		TRBCABEC->F2_DOC     := SF2->F2_DOC 
      TRBCABEC->F2_SERIE   := SF2->F2_SERIE 
      TRBCABEC->F2_EMISSAO := SF2->F2_EMISSAO
		TRBCABEC->F2_COND    := SF2->F2_COND 
		TRBCABEC->F2_VALFAT  := SF2->F2_VALFAT    
		
		TRBCABEC->F2_PREFIXO :=	SF2->F2_PREFIXO 
		TRBCABEC->F2_TOTIMP  :=	SF2->F2_TOTIMP
		TRBCABEC->F2_DUPL  	:=	SF2->F2_DUPL    
		TRBCABEC->F2_VALISS	:=	SF2->F2_VALISS
		TRBCABEC->F2_BASEISS	:=	SF2->F2_BASEISS
		TRBCABEC->F2_NFELETR := SF2->F2_NFELETR //MAX: NUMERO NOTA ELETRONICA;
		
		SF3->(dbSetOrder(5))  //SF3_FILIAL, F3_SERIE, F3_NFISCAL, F3_CLIEFOR, F3_LOJA, F3_IDENTFT, R_E_C_N_O_, D_E_L_E_T_
		If (SF3->(dbSeek(xFilial("SF3") + cSF2SER + cSF2DOC + SF2->F2_CLIENTE + SF2->F2_LOJA))) 
			TRBCABEC->F3_ISSMAT  := SF3->F3_ISSMAT
			TRBCABEC->F3_BASEICM := SF3->F3_BASEICM 
			TRBCABEC->F3_ALIQICM := SF3->F3_ALIQICM 
			TRBCABEC->F3_VALICM  := SF3->F3_VALICM 
			TRBCABEC->F3_VALCONT := SF3->F3_VALCONT
		EndIf
	
		SC5->(dbOrderNickName("FSIND03"))// C5_FILIAL, C5_NOTA, C5_SERIE, R_E_C_N_O_, D_E_L_E_T_
		If (SC5->(dbSeek(xFilial("SC5") + cSF2DOC + cSF2SER))) 
			TRBCABEC->C5_MENPAD  := SC5->C5_MENPAD 
		  	TRBCABEC->C5_MENPAD1 := SC5->C5_MENPAD1 
		  	TRBCABEC->C5_MENPAD2 := SC5->C5_MENPAD2 
		  	TRBCABEC->C5_MENPAD3 := SC5->C5_MENPAD3 
		  	TRBCABEC->C5_MENPAD4 := SC5->C5_MENPAD4 
		  	TRBCABEC->C5_ZCEI    := SC5->C5_ZCEI //JULIANA 
		  	TRBCABEC->C5_ZENDCOB := SC5->C5_ZENDCOB 
		  	TRBCABEC->C5_ZNUMOB  := SC5->C5_ZNUMOB
		  	TRBCABEC->C5_ZCOMOB  := SC5->C5_ZCOMOB
		  	TRBCABEC->C5_ZBAIROB := SC5->C5_ZBAIROB
		  	TRBCABEC->C5_ZMUNOB  := SC5->C5_ZMUNOB
		  	TRBCABEC->C5_ZESTOB  := SC5->C5_ZESTOB
		  	TRBCABEC->C5_ZCEPOB  := SC5->C5_ZCEPOB 
		  	TRBCABEC->C5_ZCC     := SC5->C5_ZCC
		  	TRBCABEC->C5_ZUF     := SC5->C5_ZUF 
		  	TRBCABEC->C5_ZBAIROC := SC5->C5_ZBAIROC 
		  	TRBCABEC->C5_ZMUN    := SC5->C5_ZMUN
		  	TRBCABEC->C5_ZEST    := SC5->C5_ZEST
		  	TRBCABEC->C5_ZCEP    := SC5->C5_ZCEP
		  	TRBCABEC->C5_ZCONT   := SC5->C5_ZCONT
		  	TRBCABEC->C5_RECISS  := SC5->C5_RECISS  
		  	TRBCABEC->C5_ZENDOB	:= SC5->C5_ZENDOB   
		  	TRBCABEC->C5_ZENDNUM := SC5->C5_ZENDNUM

		 EndIf
		 
		 //Cliente
		 SA1->(dbSetOrder(1)) // 	A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_, D_E_L_E_T_
		 If (SA1->(dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))) 
   		 TRBCABEC->A1_NOME 	:= SA1->A1_NOME
			 TRBCABEC->A1_END    := SA1->A1_END 
			 TRBCABEC->A1_BAIRRO := SA1->A1_BAIRRO
			 TRBCABEC->A1_MUN 		:= SA1->A1_MUN
			 TRBCABEC->A1_EST 		:= SA1->A1_EST
			 TRBCABEC->A1_CEP 		:= SA1->A1_CEP
			 TRBCABEC->A1_CGC 		:= SA1->A1_CGC
			 TRBCABEC->A1_INSCR 	:= SA1->A1_INSCR
			 TRBCABEC->A1_INSCRM := SA1->A1_INSCRM
			 TRBCABEC->A1_EMAIL := SA1->A1_EMAIL 
		 EndIf
		
	   //Itens
		SD2->(dbSetOrder(3))  //D2_FILIAL, D2_DOC, D2_SERIE, 
		SD2->(dbSeek(xFilial("SD2") + cSF2DOC + cSF2SER)) 
		TRBCABEC->D2_ALIQISS	:= SD2->D2_ALIQISS
    	TRBCABEC->F4_ISSST   := Posicione("SF4",1, xFilial("SF4") + SD2->D2_TES,"F4_ISSST")               //MAX: localiza tes		
    	
		//Grava Natureza da operação
		//cISSST             :=  Posicione("SF4",1, xFilial("SF4") + SD2->D2_TES,"F4_ISSST")               //localiza tes
		TRBCABEC->F4_TEXTO :=  Posicione("SF4",1, xFilial("SF4") + SD2->D2_TES,"F4_TEXTO")

		While(SD2->(!Eof()) .And. SD2->(D2_FILIAL + D2_DOC  + D2_SERIE ) == (xFilial("SD2") + cSF2DOC + cSF2SER ))
				
				TRBITENS->(RecLock("TRBITENS",.T.))
				TRBITENS->D2_FILIAL := SD2->D2_FILIAL
				TRBITENS->D2_DOC    := SD2->D2_DOC
				TRBITENS->D2_SERIE  := SD2->D2_SERIE
				TRBITENS->D2_ITEM   := SD2->D2_ITEM
				TRBITENS->D2_QUANT  := SD2->D2_QUANT
				TRBITENS->D2_PRCVEN := SD2->D2_PRCVEN				
				TRBITENS->D2_TOTAL  := SD2->D2_TOTAL				
				TRBITENS->D2_TES    := SD2->D2_TES				
				
				SC6->(dbSetOrder(1))// C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
		      If SC6->(dbSeek(xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV+SD2->D2_COD)) 
					TRBITENS->C6_DESCCOM := SC6->C6_DESCCOM
					TRBITENS->C6_ZREMES  := SC6->C6_ZREMES
					//MAX: Totalizo os valores do C6_ABTMAT2 customizado.
					TRBCABEC->F3_ABTMAT	+= SC6->C6_ABTMAT2
					
					// Realizo os somatórios das quantidades somente se o quatro primeiros caractes forem iguais a 8001
					If !Empty(SC6->C6_CODF) .And. SubStr(AllTrim(SC6->C6_CODF), 1, 4) == "8001" 
						//Totalizo a quantidade da nota faturada
						TRBCABEC->F2_TOTAL  += SD2->D2_QUANT
					ElseIf Empty(SC6->C6_CODF)
						TRBCABEC->F2_TOTAL  += SD2->D2_QUANT
					EndIf
					
				EndIf		
				
				//Totalizo os itens, para caso nao tenha financeiro seja impresso o valor
				TRBCABEC->F2_VALTOT += SD2->D2_TOTAL
				
				SD2->(dbSkip())
				TRBITENS->(MsUnLock())
		EndDo
	
		
		
		//Financeiro
		SE1->(dbSetOrder(1))// E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
			If SE1->( dbSeek (xFilial("SE1") + SF2->F2_PREFIXO +  SF2->F2_DUPL) ) 
			
			//Se tiver financeiro, pego o valor do financeiro
			TRBCABEC->F2_VALTOT := 0
			lFlux := .T.			
			While(SE1->(!Eof()) .And. SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM) == (xFilial("SE1") + SF2->F2_PREFIXO +  SF2->F2_DUPL) ) 
				
				//Considera somente os titulos do tipo NF
				If (AllTrim(SE1->E1_TIPO) == 'NF')
					
					TRBFIN->(RecLock("TRBFIN",.T.))
					TRBFIN->E1_FILIAL  := SE1->E1_FILIAL 
					TRBFIN->E1_PREFIXO := SE1->E1_PREFIXO
					TRBFIN->E1_NUM     := SE1->E1_NUM
					TRBFIN->E1_PARCELA := SE1->E1_PARCELA
					TRBFIN->E1_EMISSAO := SE1->E1_EMISSAO
					TRBFIN->E1_VENCTO  := SE1->E1_VENCTO
//					TRBFIN->E1_VALOR   := IIF(lFlux, SE1->E1_VALOR - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA), SE1->E1_VALOR)
//					Alteração para considerar o abatimento caso seja antecipado, mas o cliente retem o ISS - Jean Santos
					TRBFIN->E1_VALOR   := IIF(lFlux, SE1->E1_VALOR - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA), (IIF (TRBCABEC->C5_RECISS=="1", SE1->E1_VALOR - SE1->E1_ISS, SE1->E1_VALOR))) 
                                                              	
					If Empty(SC5->C5_ZDESCPG)
						TRBFIN->E4_DESCRI  := Posicione("SE4",1, xFilial("SE4") + SF2->F2_COND,"E4_DESCRI") // E4_FILIAL, E4_CODIGO, R_E_C_D_E_L_ 
					Else
						TRBFIN->E4_DESCRI  :=AllTrim(SUBSTR(SC5->C5_ZDESCPG, 1, 30))  
					EndIf
					
					TRBCABEC->F2_VALTOT += SE1->E1_VALOR
					TRBFIN->(MsUnLock())
					lFlux	:= .F.
					SE1->(dbSkip())
				
				Else
					SE1->(dbSkip())
					Loop
				EndIf
			
			EndDo
		EndIf				
		
		TRBCABEC->(MsUnLock())
		
	SF2->(dbSkip())
	EndDo

Else
	//Caso nao encontrou a nota
	lRetFun := .F.
EndIf

Return lRetFun


//-------------------------------------------------------------------
/*/{Protheus.doc} FCriaTrab
Monta Arquivo de trabalho

@protected
@author Giulliano Santos
@since 31/10/2011 
@version P11
@obs 
Projeto FS005495

Alteracoes Realizadas desde a Estruturacao Inicial
Data       	Programador     		Motivo
30/01/2011  Fernando Ferreira    Abatimento de materias customizado.
/*/
//-------------------------------------------------------------------
Static Function FCriaTrab()
/*************************************************************************************
* Cria os arquivos de trabalho
*
*******/
Local aTempStru := {}

//Itens da nota
Aadd(aTempStru,{"D2_FILIAL", "C",TamSx3("D2_FILIAL")[1],0})	    
Aadd(aTempStru,{"D2_DOC",    "C",TamSx3("D2_DOC")[1],0})
Aadd(aTempStru,{"D2_SERIE",  "C",TamSx3("D2_SERIE")[1],0})	    	    
Aadd(aTempStru,{"D2_ITEM",   "C",TamSx3("D2_ITEM")[1],0})	    	    
Aadd(aTempStru,{"D2_PRCVEN", "N",TamSx3("D2_PRCVEN")[1],TamSx3("D2_PRCVEN")[2]})
Aadd(aTempStru,{"D2_QUANT",  "N",TamSx3("D2_QUANT")[1] ,TamSx3("D2_QUANT")[2]})	
Aadd(aTempStru,{"D2_TOTAL",  "N",TamSx3("D2_TOTAL")[1] ,TamSx3("D2_TOTAL")[2]})	
Aadd(aTempStru,{"C6_DESCCOM","M",TamSx3("C6_DESCCOM")[1],0})	
Aadd(aTempStru,{"C6_ZREMES", "M",TamSx3("C6_ZREMES")[1],0})
Aadd(aTempStru,{"D2_TES",    "C",TamSx3("D2_TES")[1],0})

cArqTrab := CriaTrab(aTempStru,.T.)

dbUseArea( .T.,, cArqTrab, "TRBITENS",.F.,.F.)
IndRegua("TRBITENS",cArqTrab,"D2_FILIAL+D2_DOC+D2_SERIE",,,"SeleCionando Registros...")

//Cabeçalho nota 
aTempStru := {}
cArqTrab  := ""

Aadd(aTempStru,{"F2_FILIAL",  "C",TamSx3("F2_FILIAL")[1],0})	    
Aadd(aTempStru,{"F2_DOC",     "C",TamSx3("F2_DOC")[1],0})
Aadd(aTempStru,{"F2_SERIE",   "C",TamSx3("F2_SERIE")[1],0})	    	    
Aadd(aTempStru,{"F4_TEXTO",   "C",TamSx3("F4_TEXTO")[1],0})   // Campo 01   
Aadd(aTempStru,{"F2_EMISSAO", "D",TamSx3("F2_EMISSAO")[1],0}) // Campo 02   
Aadd(aTempStru,{"F2_COND",    "C",TamSx3("F2_COND")[1],0})  
Aadd(aTempStru,{"F2_VALFAT",  "N",TamSx3("F2_VALFAT")[1],TamSx3("F2_VALFAT")[2]})  
Aadd(aTempStru,{"F2_VALTOT",  "N",TamSx3("F2_VALFAT")[1],TamSx3("F2_VALFAT")[2]}) 
Aadd(aTempStru,{"F2_VALISS",  "N",TamSx3("F2_VALISS")[1],TamSx3("F2_VALISS")[2]}) 
Aadd(aTempStru,{"F2_BASEISS", "N",TamSx3("F2_BASEISS")[1],TamSx3("F2_BASEISS")[2]})  
Aadd(aTempStru,{"F2_NFELETR", "C",TamSx3("F2_NFELETR")[1],0}) //MAX: Campo do numero da nota

// Abatimento de materiais customizado - Para melhor leitura o prefixo F3 foi deixado
// com intuito de um melhor entendimento.                                                                                 
Aadd(aTempStru,{"F3_ABTMAT",  "N",TamSx3("F3_ISSMAT")[1],TamSx3("F3_ISSMAT")[2]})

Aadd(aTempStru,{"F3_ISSMAT",  "N",TamSx3("F3_ISSMAT")[1],TamSx3("F3_ISSMAT")[2]})
Aadd(aTempStru,{"F3_BASEICM", "N",TamSx3("F3_BASEICM")[1],TamSx3("F3_BASEICM")[2]})	
Aadd(aTempStru,{"F3_ALIQICM", "N",TamSx3("F3_ALIQICM")[1],TamSx3("F3_ALIQICM")[2]})
Aadd(aTempStru,{"F3_VALICM",  "N",TamSx3("F3_VALICM")[1],TamSx3("F3_VALICM")[2]}) 
Aadd(aTempStru,{"F3_VALCONT", "N",TamSx3("F3_VALCONT")[1],TamSx3("F3_VALCONT")[2]}) 	
Aadd(aTempStru,{"F2_TOTAL",   "N",TamSx3("F3_VALCONT")[1],TamSx3("F3_VALCONT")[2]})   
Aadd(aTempStru,{"F2_TOTIMP",  "N",TamSx3("F2_TOTIMP")[1],TamSx3("F2_TOTIMP")[2]})   
Aadd(aTempStru,{"F2_PREFIXO", "C",TamSx3("F2_PREFIXO")[1],0})		
Aadd(aTempStru,{"F2_DUPL",    "C",TamSx3("F2_DUPL")[1],0})		
Aadd(aTempStru,{"D2_ALIQISS", "N",TamSx3("D2_ALIQISS")[1],0})	
Aadd(aTempStru,{"F4_ISSST",   "C",TamSx3("F4_ISSST")[1],0})		//MAX: CRIA CAMPO ISSST

Aadd(aTempStru,{"C5_MENPAD",  "C",TamSx3("C5_MENPAD")[1],0})		
Aadd(aTempStru,{"C5_MENPAD1", "C",TamSx3("C5_MENPAD1")[1],0})	
Aadd(aTempStru,{"C5_MENPAD2", "C",TamSx3("C5_MENPAD2")[1],0})		
Aadd(aTempStru,{"C5_MENPAD3", "C",TamSx3("C5_MENPAD3")[1],0})		
Aadd(aTempStru,{"C5_MENPAD4", "C",TamSx3("C5_MENPAD4")[1],0})	
Aadd(aTempStru,{"C5_ZCEI"   , "C",TamSx3("C5_ZCEI")[1],0})	
Aadd(aTempStru,{"C5_ZENDCOB", "C",TamSx3("C5_ZENDCOB")[1],0})	 
Aadd(aTempStru,{"C5_ZNUMOB",  "C",TamSx3("C5_ZNUMOB")[1],0})	 
Aadd(aTempStru,{"C5_ZCOMOB",  "C",TamSx3("C5_ZCOMOB")[1],0})	
Aadd(aTempStru,{"C5_ZMUNOB",  "C",TamSx3("C5_ZMUNOB")[1],0})	
Aadd(aTempStru,{"C5_ZESTOB",  "C",TamSx3("C5_ZESTOB")[1],0})	
Aadd(aTempStru,{"C5_ZCEPOB",  "C",TamSx3("C5_ZCEPOB")[1],0})	
Aadd(aTempStru,{"C5_ZBAIROB", "C",TamSx3("C5_ZBAIROB")[1],0})	
Aadd(aTempStru,{"C5_ZUF",     "C",TamSx3("C5_ZUF")[1],0})	  
Aadd(aTempStru,{"C5_ZBAIROC", "C",TamSx3("C5_ZBAIROC")[1],0})		
Aadd(aTempStru,{"C5_ZMUN",  	"C",TamSx3("C5_ZMUN")[1],0})	
Aadd(aTempStru,{"C5_ZEST",  	"C",TamSx3("C5_ZEST")[1],0})		
Aadd(aTempStru,{"C5_ZCEP",  	"C",TamSx3("C5_ZCEP")[1],0})		
Aadd(aTempStru,{"C5_ZCONT",  	"C",TamSx3("C5_ZCONT")[1],0}) // Campo 3	  
Aadd(aTempStru,{"C5_RECISS",  "C",TamSx3("C5_RECISS")[1],0})	
Aadd(aTempStru,{"C5_ZCC",     "C",TamSx3("C5_ZCC")[1],0})	    
Aadd(aTempStru,{"C5_ZENDOB",  "C",TamSx3("C5_ZENDOB")[1],0})	 
Aadd(aTempStru,{"C5_ZENDNUM", "C",TamSx3("C5_ZENDNUM")[1],0})	    

Aadd(aTempStru,{"A1_NOME",    "C",TamSx3("A1_NOME")[1],0}) // Campo 6	  
Aadd(aTempStru,{"A1_END",     "C",TamSx3("A1_END")[1],0})	  	
Aadd(aTempStru,{"A1_BAIRRO",  "C",TamSx3("A1_BAIRRO")[1],0})  
Aadd(aTempStru,{"A1_EMAIL",  "C",TamSx3("A1_EMAIL")[1],0})	  	
Aadd(aTempStru,{"A1_MUN",     "C",TamSx3("A1_MUN")[1],0})	  	
Aadd(aTempStru,{"A1_EST",     "C",TamSx3("A1_EST")[1],0})	  	
Aadd(aTempStru,{"A1_CEP",     "C",TamSx3("A1_CEP")[1],0})	  	
Aadd(aTempStru,{"A1_CGC",     "C",TamSx3("A1_CGC")[1],0})	  	
Aadd(aTempStru,{"A1_INSCR",   "C",TamSx3("A1_INSCR")[1],0})	  	
Aadd(aTempStru,{"A1_INSCRM",  "C",TamSx3("A1_INSCRM")[1],0})	  	

cArqTrab := CriaTrab(aTempStru,.T.)

dbUseArea( .T.,, cArqTrab, "TRBCABEC",.F.,.F.)
IndRegua("TRBCABEC",cArqTrab,"F2_FILIAL+F2_DOC+F2_SERIE",,,"SeleCionando Registros...") 

//Financeiro
aTempStru := {}
cArqTrab  := ""

Aadd(aTempStru,{"E1_FILIAL",  "C",TamSx3("E1_FILIAL")[1],0})	    	
Aadd(aTempStru,{"E1_PREFIXO", "C",TamSx3("E1_PREFIXO")[1],0})	    
Aadd(aTempStru,{"E1_NUM",     "C",TamSx3("E1_NUM")[1],0})	    
Aadd(aTempStru,{"E1_PARCELA", "C",TamSx3("E1_PARCELA")[1],0})	    
Aadd(aTempStru,{"E1_EMISSAO", "D",TamSx3("E1_EMISSAO")[1],0})	    	
Aadd(aTempStru,{"E1_VENCTO",  "D",TamSx3("E1_VENCTO")[1],0})	    
Aadd(aTempStru,{"E1_VALOR",   "N",TamSx3("E1_VALOR")[1],TamSx3("E1_VALOR")[2]})	    
Aadd(aTempStru,{"E4_DESCRI",  "C",TamSx3("E4_DESCRI")[1],0}) 	

cArqTrab := CriaTrab(aTempStru,.T.)

dbUseArea( .T.,, cArqTrab, "TRBFIN",.F.,.F.)
IndRegua("TRBFIN",cArqTrab,"E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA",,,"Selecionando Registros...") //E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_


Return Nil 


//------------------------------------------------------------------- 
/*/{Protheus.doc} FImpRel
Imprime o relatorio

@protected
@author Giulliano Santos
@since 31/10/2011 
@version P11
@obs 
Projeto FS005495
 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FImpRel 

Local nQuePag := 0
Local	nQtdMens := 0  

SetRegua(RecCount())

TRBCABEC->(dbGotop())
TRBITENS->(dbGotop())
TRBFIN->(dbGoTop())
While TRBCABEC->(!Eof())
    
    FCabRel(lIniOne)
    
    If (lIniOne)
		 nLinRel += 3
		 nConLin += 3
	 EndIf
    
    While TRBITENS->(!Eof()) .And. TRBCABEC->(F2_FILIAL + F2_DOC + F2_SERIE) == TRBITENS->(D2_FILIAL + D2_DOC + D2_SERIE)
       FImpIte()
       nLinRel++
     	 TRBITENS->(dbSkip())
    EndDo
     
    nQuePag := nQtdLin - nConLin
    nQtdMens := 0
	
	 For nX := 1 to 4               
	   cPos := Iif(nX==1,"", cValToChar(nX))
		If(!Empty( &("TRBCABEC->C5_MENPAD" + cPos) ))
			 nQtdMens++		
		EndIf
	 Next
    // Se existir espaço imprime sem quebrar a pagina
    If nQuePag >= nQtdMens
    	@ nLinRel++, 000 PSAY Iif (!Empty(TRBCABEC->C5_MENPAD),  SubStr(Formula(TRBCABEC->C5_MENPAD)  ,1,78) , "")   
    	@ nLinRel++, 000 PSAY Iif (!Empty(TRBCABEC->C5_MENPAD1), SubStr(Formula(TRBCABEC->C5_MENPAD1) ,1,78) , "")   
		@ nLinRel++, 000 PSAY Iif (!Empty(TRBCABEC->C5_MENPAD2), SubStr(Formula(TRBCABEC->C5_MENPAD2) ,1,78) , "")   
		@ nLinRel++, 000 PSAY Iif (!Empty(TRBCABEC->C5_MENPAD3), SubStr(Formula(TRBCABEC->C5_MENPAD3) ,1,78) , "")   
		@ nLinRel++, 000 PSAY Iif (!Empty(TRBCABEC->C5_MENPAD4), SubStr(Formula(TRBCABEC->C5_MENPAD4) ,1,78) , "") 
		If lImpostos
		@ nLinRel++, 000 PSAY "Valor aproximado dos tributos: R$ " + Transform(TRBCABEC->F2_TOTIMP,"99,999,999.99")
		Endif
		@ nLinRel  , 000 PSAY Iif (!Empty(TRBCABEC->C5_ZCEI)   , "CEI: " + SubStr(TRBCABEC->C5_ZCEI,1,78) , "")     //JULIANA.
		//Imprime as mensagens somente no ultimo item
    	FRodRel(.T.,lIniOne)   
	 Else // Se nao imprime na proxima pagina
	 	FRodRel(,lIniOne)
	   FCabRel(lIniOne)
   
    	@ nLinRel++, 000 PSAY Iif (!Empty(TRBCABEC->C5_MENPAD),  SubStr(Formula(TRBCABEC->C5_MENPAD)  ,1,78) , "")   
    	@ nLinRel++, 000 PSAY Iif (!Empty(TRBCABEC->C5_MENPAD1), SubStr(Formula(TRBCABEC->C5_MENPAD1) ,1,78) , "")   
		@ nLinRel++, 000 PSAY Iif (!Empty(TRBCABEC->C5_MENPAD2), SubStr(Formula(TRBCABEC->C5_MENPAD2) ,1,78) , "")   
		@ nLinRel++, 000 PSAY Iif (!Empty(TRBCABEC->C5_MENPAD3), SubStr(Formula(TRBCABEC->C5_MENPAD3) ,1,78) , "")   
		@ nLinRel++, 000 PSAY Iif (!Empty(TRBCABEC->C5_MENPAD4), SubStr(Formula(TRBCABEC->C5_MENPAD4) ,1,78) , "")  
		@ nLinRel++, 000 PSAY "Valor aproximado dos tributos: R$ " + Transform(TRBCABEC->F2_TOTIMP,"99,999,999.99")		
		@ nLinRel  , 000 PSAY Iif (!Empty(TRBCABEC->C5_ZCEI)   , "CEI: " +SubStr(TRBCABEC->C5_ZCEI,1,78) , "")  //JULIANA.  
	
     	//Imprime as mensagens somente no ultimo item
    	FRodRel(.T.,lIniOne)     
	 EndIf
    
    lIniOne := .F.
    TRBCABEC->(dbSkip())
    aArrRod := {} // Reseta array com as parcelas  
    nSE1Tot := 0
EndDo


Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FCabRel
Imprime o cabeçalho da nota

@protected
@author Giulliano Santos
@since 31/10/2011 
@version P11
@obs 
Projeto FS005495

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FCabRel(lIniOne)

Local nDirPos := 060 
Local nDirEsq := 030
                         
/*If !(lIniOne)
	@ nLinRel,000 PSAY Space(1)
EndIf*/

//SetPrc(0,0)                   
If !(lIniOne)
	@ 5,5 PSAY "....."
	nLinRel := 5
Else
	@ 0,0 PSAY "....."
	nLinRel := 0
EndIf

@ nLinRel,019 PSAY AllTrim(TRBCABEC->F4_TEXTO) 
@ nLinRel,041 PSAY U_FSAjuDat(TRBCABEC->F2_EMISSAO)
@ nLinRel,063 PSAY Upper(FDesc_Mes(Month(TRBCABEC->F2_EMISSAO),10))
@ nLinRel,074 PSAY Year(TRBCABEC->F2_EMISSAO)

If !(lIniOne)
	nLinRel += 3
Else
	nLinRel += 4
EndIf

@ nLinRel,007   PSAY AllTrim(TRBCABEC->C5_ZCONT) + " / "
@ nLinRel,025   PSAY SubStr(AllTrim(TRBCABEC->A1_NOME), 1 , 40)
@ nLinRel,063   PSAY "RPS: " + AllTrim(TRBCABEC->F2_DOC) 
@ nLinRel+1,062 PSAY "NFSe: "+AllTrim(TRBCABEC->F2_NFELETR)


If !(lIniOne)
	nLinRel += 3
EndIf



Return Nil   


//-------------------------------------------------------------------
/*/{Protheus.doc} FImpIte
Imprime os itens da nota

@protected
@author Giulliano Santos
@since 31/10/2011 
@version P11
@obs 
Projeto FS005495

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FImpIte()
Local aZreMes := {}
Local aZreMe2 := {}
Local nX		  := 0
Local nY		  := 0 
Local nLinAnt := 0
Local lContro := .T.
Local aASC6Re := {}

@ nLinRel,000 PSAY AlLTrim(TRBITENS->C6_DESCCOM) // Campo 8 
@ nLinRel,040 PSAY TRBITENS->D2_PRCVEN picture "@E 999,999.99" //Transform(TRBITENS->D2_PRCVEN , "@E 999,999,999.99") 
@ nLinRel,056 PSAY TRBITENS->D2_QUANT  picture "@E 999,999.99" //Transform(TRBITENS->D2_QUANT  , "@E 999,999,999.99") 
@ nLinRel,067 PSAY TRBITENS->D2_TOTAL  picture "@E 9,999,999.99" //Transform(TRBITENS->D2_TOTAL  , "@E 999,999,999.99") 
nLinRel++ 
nConLin++

cSC6Rem := StrTran(AllTRIM(TRBITENS->C6_ZREMES),CHR(13), "")
nSC6Num := MLCount(cSC6Rem , 44) 
For nY := 1 To nSC6Num
	Aadd(aASC6Re, AllTrim(MemoLine( cSC6Rem, 44,  nY)) )
Next nY 

For nY := 1 To Len(aASC6Re)                  
	cRem := AllTrim(Iif (!Empty(aASC6Re[nY]) , aASC6Re[nY] , "..."))
	cRem := StrTran(cRem,CHR(10), " ")
	@nLinRel++,000 PSAY cRem
	nConLin++
	If(nConLin >= nQtdLin)
		//Imprime o rodape
		FRodRel(,lIniOne)
		FCabRel(lIniOne)
		nConLin := 0
		//nLinRel := 06
	EndIf
Next 

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FRodRel
Imprime o rodape

@protected
@author Giulliano Santos
@since 31/10/2011 
@version P11
@obs 
Projeto FS005495

Alteracoes Realizadas desde a Estruturacao Inicial
Data      	 Programador     		Motivo
30/01/2011   Fernando Ferreira   Inclusão da validação por empresas para abatimento de materiais.
/*/
//-------------------------------------------------------------------
Static Function FRodRel(lFimRel,lPriPag)

Local 	nDirPos 		:= 80 
Local 	nDirEsq 		:= 00
Local 	aAreas  		:= {SM0->(GetArea())}
Local 	nX 			:= 0
Local 	nXj			:= 0
Local 	cLinha 		:= "" 
//MAX: 11-09-2012 Tratamento de Abatimento por municipio // desabilitado por Filial  Local		cEmpAbtMat	:= AllTrim(SuperGetMv("FS_EMPABAT", .T., ""))
Local    cMunAbt2    := AllTrim(SuperGetMv("FS_MUNABT2", .T., ""))  

Default 	lFimRel 		:= .F.          
Default 	lPriPag 		:= .T.

//Linhas dos totais
//nLinRel := Iif(lPriPag,26,33)
nLinRel := Iif(lPriPag,29.5,34.5)

//Comprime impressao
@ nLinRel,000 PSAY CHR(15)
	
	If (AllTrim(TRBCABEC->C5_ZMUNOB) $ cMunAbt2)   //max: 11-09-2012 (cFilAnt $ cEmpAbtMat)  Desabilitado por filial// novo tratamento por municipio da obra
		// Impressão do somatário do campo customizado SC6->C6_ABTMAT
		@ nLinRel,000 PSAY Transform(TRBCABEC->F3_ABTMAT,"@E 999,999.99")  // Campo 19
	Else
		@ nLinRel,000 PSAY Transform(TRBCABEC->F3_ISSMAT,"@E 999,999.99")  // Campo 19
	EndIf
	//MAX: Cálculo da base do ISS nos casos de Exigibilidade Suspensa deverá ser o TOTAL da nota menos o ABATIMENTO MATERIAL     

	If (TRBCABEC->F4_ISSST <> "5" .AND. TRBCABEC->F4_ISSST <> "6") 
		@ nLinRel,017 PSAY Transform(TRBCABEC->F2_BASEISS,"@E 999,999.99") // Campo 20
	Else
	   @ nLinRel,017 PSAY Transform((TRBCABEC->F2_BASEISS - TRBCABEC->F3_ABTMAT ),"@E 999,999.99") // Campo 20	
	   //- IIF((AllTrim(TRBCABEC->C5_ZMUNOB) $ cMunAbt2), TRBCABEC->F3_ABTMAT, TRBCABEC->F3_ISSMAT)
   EndIF		                                           
   
	@ nLinRel,041 PSAY Transform(TRBCABEC->D2_ALIQISS,"@E 999.99") // Campo 21    

	//MAX: Cálculo do ISS nos casos de Exigibilidade Suspensa deverá ser o (TOTAL - ABATIMENTO MATERIAL * aliquota)    
	If (TRBCABEC->F4_ISSST <> "5" .AND.  TRBCABEC->F4_ISSST <> "6")
		@ nLinRel,046 PSAY Transform(TRBCABEC->F2_VALISS,"@E 999,999,999.99")  // Campo 22
	Else 
		@ nLinRel,046 PSAY Transform( (((TRBCABEC->F2_BASEISS - TRBCABEC->F3_ABTMAT) *TRBCABEC->D2_ALIQISS)/100),"@E 999,999,999.99")  // Campo 22	
	EndIF	
		
	@ nLinRel,075 PSAY Iif(TRBCABEC->C5_RECISS=="1", "SIM", "NAO") //Campo 23
	@ nLinRel,100 PSAY Transform(TRBCABEC->F2_TOTAL, "@E 999,999.99")  // Campo 24
	@ nLinRel,110 PSAY Transform(TRBCABEC->F2_VALTOT,"@E 999,999,999.99")  // Campo 25   
	
	nLinRel += 2
	cEndCob := ""
	cEndCob := AllTrim(TRBCABEC->C5_ZENDOB) + " , " + AllTrim(TRBCABEC->C5_ZNUMOB) + " , " + AllTrim(TRBCABEC->C5_ZCOMOB) + ", " + TRBCABEC->C5_ZBAIROB  /*Campo 27*/
	
	//Serviços
	@ nLinRel,000 PSAY SubStr(cEndCob, 1, 140)
	//@ nLinRel,000 PSAY SubStr(cEndCob,71, 70)
	                         
	
	nLinRel := nLinRel + 1
	
	@ nLinRel,000 PSAY U_FSRetMun(TRBCABEC->C5_ZESTOB, TRBCABEC->C5_ZMUNOB)  //Campo 28 
	@ nLinRel,060 PSAY TRBCABEC->C5_ZESTOB  //Campo 29
	@ nLinRel,075 PSAY TRBCABEC->C5_ZCEPOB  //Campo 30

//Descomprime impressao
@ nLinRel,000 PSAY CHR(18)	

nLinRel += 3

//Estabelecimento emissor
//@ nLinRel,050 PSAY TRBCABEC->C5_ZCC//Campo 201
//@ nLinRel,060 PSAY Posicione("CTT", 1, xFilial("CTT") + TRBCABEC->C5_ZCC ,"CTT_DESC01")//Campo 202
//@ nLinRel,075 PSAY TRBCABEC->C5_ZUF //Campo 203

nLinRel += 2

//Empresa Top Mix Engenharia e concreto
SM0->(dbSetOrder(1))
SM0->(dbSeek(cEmpAnt + TRBCABEC->F2_FILIAL))

//Comprime impressao
@ nLinRel,000 PSAY CHR(15)
	@ nLinRel  ,056 PSAY AllTrim(SM0->M0_ENDCOB)//Campo 204
	@ nLinRel++,115 PSAY AllTrim(SM0->M0_BAIRCOB)//Campo 205
//Restaura impressao
@ nLinRel,000 PSAY CHR(18)	
	
@ nLinRel, 033 PSAY AllTrim(SM0->M0_CIDENT)//Campo 206
@ nLinRel, 050 PSAY AllTrim(SM0->M0_ESTENT)//Campo 207
@ nLinRel, 060 PSAY AllTrim(SM0->M0_CEPENT)//Campo 208
 
nLinRel += 2

//Fone . . . .  . Fax . . . . .  . 
@ nLinRel,  043 PSAY SM0->M0_TEL //Campo 209
@ nLinRel++,069 PSAY SM0->M0_FAX //Campo 210

//Lado esquerdo
@ nLinRel,  000 PSAY SuperGetMv("FS_RPSTX1",  .F. , "FS_RPSTX1") //Campo 215
@ nLinRel,  018 PSAY SuperGetMv("FS_TELCOB1", .F. , "FS_TELCOB1") //Campo 216

//CGC
@ nLinRel++,043 PSAY Transform(ALLTRIM(SM0->M0_CGC),"@R 99.999.999/9999-99")//Campo 211

//Telefone de cobrança e Inscrição estadual
@ nLinRel  ,018 PSAY SuperGetMv("FS_TELCOB2", .F. , "FS_TELCOB2")//Campo 217 
@ nLinRel++,043 PSAY SM0->M0_INSC //Campo 212

@ nLinRel  ,000 PSAY SuperGetMv("FS_RPSTX2" , .F. , "FS_RPSTX2")  //Campo 219
@ nLinRel  ,018 PSAY SuperGetMv("FS_FAXCOB3", .F. , "FS_FAXCOB3") //Campo 218
@ nLinRel++,043 PSAY SM0->M0_INSCM //Campo 213


@ nLinRel,000 PSAY SuperGetMv("FS_EMAIL"  , .F. , "FS_EMAIL") //Campo 220
@ nLinRel,043 PSAY U_FSAjuDat(TRBCABEC->F2_EMISSAO)//Campo 214

While TRBFIN->(!Eof()) .And.  TRBFIN->(E1_FILIAL + E1_PREFIXO + E1_NUM) == TRBCABEC->(xFilial("SE1") + F2_PREFIXO +  F2_DUPL) 
   aAdd(aArrRod, {AllTrim(TRBFIN->E1_NUM) + "/" + AllTrim(TRBFIN->E1_PARCELA),;
                  U_FSAjuDat(TRBFIN->E1_VENCTO),;
                  AllTrim(Transform(TRBFIN->E1_VALOR, "@E 999,999,999.99")),;
                  AllTrim(TRBCABEC->F2_COND),;
                  AllTrim(TRBFIN->E4_DESCRI)})
  	TRBFIN->(dbSkip())
EndDo

nLinRel += 2

//Se o Array estiver com conteudo é por que ja foi alimentado pelo while uma vez, e ele tera seu valor resetado no loop do TRBCABEC
//Comprime impressao
//nLinRel := Iif(lPriPag,41,49)
nLinRel := Iif(lPriPag,45.5,50.5)
@ nLinRel,000 PSAY CHR(15)
	For nXj := 1 To 5
		cLinha := ""
		For nX := 1 To Len(aArrRod)   
			cLinha += space(05) +  padR(aArrRod[nX][nXj],15)	
		Next
		@ nLinRel++, 007  PSAY cLinha
	Next   
//Descomprime impressao
@ nLinRel,000 PSAY CHR(18)	

nLinRel += 3

//Area do sacado
@ nLinRel++, 020 PSAY TRBCABEC->A1_NOME	 //Campo 301
@ nLinRel++, 020 PSAY TRBCABEC->A1_END 	 //Campo 302
@ nLinRel++, 020 PSAY ALLTRIM(TRBCABEC->A1_BAIRRO) +" - "+ AllTrim(TRBCABEC->A1_EMAIL)  //Campo 303 -Juliana acrescentei o email do cliente

@ nLinRel++, 020 PSAY AllTrim(TRBCABEC->A1_MUN)  + " / " + TRBCABEC->A1_EST  + " - " + TRBCABEC->A1_CEP //Campo 304

@ nLinRel++, 020 PSAY AllTrim(TRBCABEC->C5_ZENDCOB) /*Campo 307*/ + "," + AllTrim(TRBCABEC->C5_ZENDNUM)  +  " / " + AllTrim(TRBCABEC->C5_ZBAIROC) 

@ nLinRel++, 020 PSAY AllTrim(U_FSRetMun(TRBCABEC->C5_ZEST , TRBCABEC->C5_ZMUN)) /*Campo 309*/ + " / " + AllTrim(TRBCABEC->C5_ZEST) /*Campo 310*/ +  " / " + AllTrim(TRBCABEC->C5_ZCEP) //Campo 311

@ nLinRel,	 023 PSAY Iif (Len(AllTrim(TRBCABEC->A1_CGC)) == 14 , Transform(TRBCABEC->A1_CGC , "@R 99.999.999/9999-99") , Transform(TRBCABEC->A1_CGC , "@R 999.999.999-99"))//Campo 312
@ nLinRel,   046 PSAY TRBCABEC->A1_INSCR//Campo 313
@ nLinRel,   067 PSAY TRBCABEC->A1_INSCRM//Campo 314

nLinRel += 2                              

If (lFimRel)
	cExtenso := Extenso(TRBCABEC->F2_VALTOT) + Space(01) + Replicate("*", 210)
	@ nLinRel++, 020 PSAY SubStr(cExtenso,001,60) //Campo 315  
	@ nLinRel++, 020 PSAY SubStr(cExtenso,060,60)
	@ nLinRel++, 020 PSAY SubStr(cExtenso,121,60)
	nConLin := 0
Else
	cExtenso:= "VALORES IMPRESSOS NA ULTIMA PAGINA" + Space(01) + Replicate("*", 210)
	@ nLinRel++, 020 PSAY SubStr(cExtenso,001,60) //Campo 315  
	@ nLinRel++, 020 PSAY SubStr(cExtenso,060,60)
	@ nLinRel++, 020 PSAY SubStr(cExtenso,121,60)
EndIf	

nLinRel += 3
@ nLinRel,004 PSAY TRBCABEC->F2_DOC //Campo 316

lIniOne := .F.


aEval(aAreas, {|x|RestArea(x)})   

Return Nil  

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSRetMun
Busca o código dos municipios.

@author Giulliano Santos
@since 31/10/2011 
@version P11
@param	cUF 	UF do municipio
@param	cMun	Municipio
@obs 
Projeto FS005495
 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSRetMun(cUF, cMun)
Local aAreas  := {CC2->(GetArea()), GetArea()}
Local cMunCc2 := ""

CC2->(dbSetOrder(1))
If (CC2->(dbSeek(xFilial("CC2") + cUF + cMun )))
	cMunCc2 := CC2->CC2_MUN  
EndIf   

aEval(aAreas, {|x|RestArea(x)})   
Return cMunCc2


