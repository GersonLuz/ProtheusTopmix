#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFATR03 
Imprime notas de saida  - Relatorio RPS

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
User Function FSFATR03()
					
Local cDescr1	:= "Este programa tem como objetivo imprimir relatorio "
Local cDescr2  := "de acordo com os parametros informados pelo usuario."
Local cDescr3  := ""
Local cPict    := ""
Local titulo   := "NOTA FISCAL LAYOUT2"

Local imprime  := .T.
Local cValPeg	:= "FSFATR03"	 
Local aOrd 		:= {}

Local cNotIni  := CriaVar("F2_DOC"   , .F.)
Local cNotFim  := CriaVar("F2_DOC"   , .F.)
Local cNotSer  := CriaVar("F2_SERIE" , .F.)

Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ""
Private limite      := 80
Private tamanho     := "M"
Private nomeprog    := "FSFATR03" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
//Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "FSFATR03" // Coloque aqui o nome do arquivo usado para impressao em disco 
Private lRetQry	  := .T.	
Private nLinRel     := 60
Private aArrRod 	  := {}  //Array para as parcelas   
Private nSE1Tot	  := 0   //Valor total da nota
Private nQtdLin	  := 13
Private lIniOne := .T. 
Private nConLin := 0
 
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

MsgRun("Gerando o notas fiscais","Por favor, aguarde....",{|| lRetQry := FQryRel(cNotIni,cNotFim,cNotSer)})

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
AjustaSx1(cValPeg, aPergs)

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
25/05/2012		Fernando Ferreira		Validação para verificar qual produto será totalizado nos totais de quantidades.
/*/ 
//------------------------------------------------------------------ 
Static Function FQryRel(cNotIni,cNotFim,cNotSer)

Local cSF2DOC :=  CriaVar("F2_DOC",   .F.)
Local cSF2SER :=  CriaVar("F2_SERIE", .F.)
Local lRetFun := .T.

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
		TRBCABEC->F2_DUPL  	:=	SF2->F2_DUPL    
		TRBCABEC->F2_VALISS	:=	SF2->F2_VALISS
		TRBCABEC->F2_BASEISS	:=	SF2->F2_BASEISS
		
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
		  	TRBCABEC->C5_ZCEI    := SC5->C5_ZCEI
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
   		 TRBCABEC->A1_NOME 	:= SA1-> A1_NOME
			 TRBCABEC->A1_END    := SA1->A1_END 
			 TRBCABEC->A1_BAIRRO := SA1-> A1_BAIRRO
			 TRBCABEC->A1_MUN 	:= SA1->A1_MUN
			 TRBCABEC->A1_EST 	:= SA1->A1_EST
			 TRBCABEC->A1_CEP 	:= SA1->A1_CEP
			 TRBCABEC->A1_CGC 	:= SA1->A1_CGC
			 TRBCABEC->A1_INSCR 	:= SA1->A1_INSCR
			 TRBCABEC->A1_INSCRM := SA1->A1_INSCRM 
			 TRBCABEC->A1_TEL    :=	SA1->A1_TEL  
			 TRBCABEC->A1_PESSOA :=	SA1->A1_PESSOA  
			 TRBCABEC->A1_RG     := SA1->A1_RG  //corrigido: Max Rocha
		 EndIf
		
	   //Itens
		SD2->(dbSetOrder(3))  //D2_FILIAL, D2_DOC, D2_SERIE, 
		SD2->(dbSeek(xFilial("SD2") + cSF2DOC + cSF2SER)) 
		TRBCABEC->D2_ALIQISS	:= SD2->D2_ALIQISS
		
		//Grava Natureza da operação
		TRBCABEC->F4_TEXTO :=  Posicione("SF4",1, xFilial("SF4") + SD2->D2_TES,"F4_TEXTO")
		
		While(SD2->(!Eof()) .And. SD2->(D2_FILIAL + D2_DOC  + D2_SERIE) == (xFilial("SD2") + cSF2DOC + cSF2SER))
				
				TRBITENS->(RecLock("TRBITENS",.T.))
				TRBITENS->D2_FILIAL := SD2->D2_FILIAL
				TRBITENS->D2_DOC    := SD2->D2_DOC
				TRBITENS->D2_SERIE  := SD2->D2_SERIE
				TRBITENS->D2_ITEM   := SD2->D2_ITEM
				TRBITENS->D2_PRCVEN := SD2->D2_PRCVEN
				TRBITENS->D2_QUANT  := SD2->D2_QUANT
				TRBITENS->D2_TOTAL  := SD2->D2_TOTAL				
				
				SC6->(dbSetOrder(1))// C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
		      If SC6->(dbSeek(xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV)) 
					TRBITENS->C6_DESCCOM := SC6->C6_DESCCOM
					TRBITENS->C6_ZREMES  := SC6->C6_ZREMES
					
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
					TRBFIN->E1_VALOR   := 33
					//IIF(lFlux, SE1->E1_VALOR - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA), SE1->E1_VALOR)
					
					If Empty(SC5->C5_ZDESCPG)
						TRBFIN->E4_DESCRI  := Posicione("SE4",1, xFilial("SE4") + SF2->F2_COND,"E4_DESCRI") // E4_FILIAL, E4_CODIGO, R_E_C_D_E_L_ 
					Else
						TRBFIN->E4_DESCRI  := AllTrim(SUBSTR(SC5->C5_ZDESCPG, 1, 30))  
					EndIf
					
					TRBCABEC->F2_VALTOT += SE1->E1_VALOR
					TRBFIN->(MsUnLock())
					lFlux := .F.
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
Data       Programador     Motivo
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

Aadd(aTempStru,{"F3_ISSMAT",  "N",TamSx3("F3_ISSMAT")[1],TamSx3("F3_ISSMAT")[2]})	
Aadd(aTempStru,{"F3_BASEICM", "N",TamSx3("F3_BASEICM")[1],TamSx3("F3_BASEICM")[2]})	
Aadd(aTempStru,{"F3_ALIQICM", "N",TamSx3("F3_ALIQICM")[1],TamSx3("F3_ALIQICM")[2]})
Aadd(aTempStru,{"F3_VALICM",  "N",TamSx3("F3_VALICM")[1],TamSx3("F3_VALICM")[2]}) 
Aadd(aTempStru,{"F3_VALCONT", "N",TamSx3("F3_VALCONT")[1],TamSx3("F3_VALCONT")[2]}) 	
Aadd(aTempStru,{"F2_TOTAL",   "N",TamSx3("F3_VALCONT")[1],TamSx3("F3_VALCONT")[2]})   
Aadd(aTempStru,{"F2_PREFIXO", "C",TamSx3("F2_PREFIXO")[1],0})		
Aadd(aTempStru,{"F2_DUPL",    "C",TamSx3("F2_DUPL")[1],0})		
Aadd(aTempStru,{"D2_ALIQISS", "N",TamSx3("D2_ALIQISS")[1],0})	

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
Aadd(aTempStru,{"A1_MUN",     "C",TamSx3("A1_MUN")[1],0})	  	
Aadd(aTempStru,{"A1_EST",     "C",TamSx3("A1_EST")[1],0})	  	
Aadd(aTempStru,{"A1_CEP",     "C",TamSx3("A1_CEP")[1],0})	  	
Aadd(aTempStru,{"A1_CGC",     "C",TamSx3("A1_CGC")[1],0})	  	
Aadd(aTempStru,{"A1_INSCR",   "C",TamSx3("A1_INSCR")[1],0})	  	
Aadd(aTempStru,{"A1_INSCRM",  "C",TamSx3("A1_INSCRM")[1],0})
Aadd(aTempStru,{"A1_RG",      "C",TamSx3("A1_RG")[1],0})	  	        

Aadd(aTempStru,{"A1_TEL",     "C",TamSx3("A1_TEL")[1],0})	  	        
Aadd(aTempStru,{"A1_PESSOA",  "C",TamSx3("A1_PESSOA")[1],0})	  	        

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
		@ nLinRel  , 000 PSAY Iif (!Empty(TRBCABEC->C5_ZCEI)   , "CEI: "+SubStr(TRBCABEC->C5_ZCEI ,1,78) , "")  
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
		@ nLinRel  , 000 PSAY Iif (!Empty(TRBCABEC->C5_ZCEI)   , "CEI: "+SubStr(TRBCABEC->C5_ZCEI ,1,78) , "")  
		
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

SetPrc(0,0)                   
If !(lIniOne)
	@ 10,0 PSAY "....."
	nLinRel := 10
Else
	@ 0,0 PSAY "....."
	nLinRel := 0
EndIf

@ nLinRel,021 PSAY AllTrim(TRBCABEC->F4_TEXTO) 
@ nLinRel,043 PSAY U_FSAjuDat(TRBCABEC->F2_EMISSAO)
@ nLinRel,064 PSAY Upper(FDesc_Mes(Month(TRBCABEC->F2_EMISSAO),10))
@ nLinRel,074 PSAY Year(TRBCABEC->F2_EMISSAO)

If !(lIniOne)
	nLinRel += 3
Else
	nLinRel += 3
EndIf

@ nLinRel,007 PSAY AllTrim(TRBCABEC->C5_ZCONT) + " / "
@ nLinRel,025 PSAY SubStr(AllTrim(TRBCABEC->A1_NOME), 1 , 40)
@ nLinRel,071 PSAY AllTrim(TRBCABEC->F2_DOC)

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
@ nLinRel,035 PSAY Transform(TRBITENS->D2_PRCVEN , "@E 999,999,999.99") 
@ nLinRel,051 PSAY Transform(TRBITENS->D2_QUANT  , "@E 999,999,999.99") 
@ nLinRel,065 PSAY Transform(TRBITENS->D2_TOTAL  , "@E 999,999,999.99") 
nLinRel++
nConLin++

cSC6Rem := StrTran(AllTRIM(TRBITENS->C6_ZREMES),CHR(13), "")
nSC6Num := MLCount(cSC6Rem , 40) 
For nY := 1 To nSC6Num
	Aadd(aASC6Re, AllTrim(MemoLine( cSC6Rem, 40,  nY)) )
Next nY 

For nY := 1 To Len(aASC6Re)                  
	cRem := AllTrim(Iif (!Empty(aASC6Re[nY]) , aASC6Re[nY] , "..."))
	cRem := StrTran(cRem,CHR(10), " ")
	@nLinRel++,000 PSAY cRem
	nConLin++
	If(nConLin >= nQtdLin)
		FRodRel(,lIniOne)
		FCabRel(lIniOne)
		nConLin := 0
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
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FRodRel(lFimRel,lPriPag)

Local nDirPos := 80 
Local nDirEsq := 00
Local aAreas  := {SM0->(GetArea())}
Local nX := 0
Local nXj:= 0
Local cLinha := "" 

Default lFimRel := .F.          
Default lPriPag := .T.

//Linhas dos totais
//nLinRel := Iif(lPriPag,26,33)
nLinRel := Iif(lPriPag,29,39)

//Comprime impressao
@ nLinRel,000 PSAY CHR(15)

	@ nLinRel,041 PSAY Transform(TRBCABEC->D2_ALIQISS,"@E 999.99") // Campo 21    
	@ nLinRel,046 PSAY Transform(TRBCABEC->F2_VALISS,"@E 999,999,999.99")  // Campo 22
	@ nLinRel,100 PSAY Transform(TRBCABEC->F2_TOTAL, "@E 999,999.99")  // Campo 24
	@ nLinRel,110 PSAY Transform(TRBCABEC->F2_VALTOT,"@E 999,999,999.99")  // Campo 25   
	
	nLinRel += 2
	
	cEndCob := AllTrim(TRBCABEC->C5_ZENDOB) + " , " + AllTrim(TRBCABEC->C5_ZNUMOB) + " , " + AllTrim(TRBCABEC->C5_ZCOMOB);
				  + ", " + TRBCABEC->C5_ZBAIROB  /*Campo 27*/    
				  
	//Serviços
	@ nLinRel,000 PSAY SubStr(cEndCob, 1, 70)
	@ nLinRel, 000 PSAY SubStr(cEndCob,70, 70)
	
	nLinRel := nLinRel + 1
	
	@ nLinRel,000 PSAY U_FSRetMun(TRBCABEC->C5_ZESTOB, TRBCABEC->C5_ZMUNOB)
	@ nLinRel,060 PSAY TRBCABEC->C5_ZESTOB  //Campo 29
	@ nLinRel,075 PSAY TRBCABEC->C5_ZCEPOB  //Campo 30

//Descomprime impressao
@ nLinRel,000 PSAY CHR(18)	

nLinRel += 3

//Estabelecimento emissor
@ nLinRel,050 PSAY TRBCABEC->C5_ZCC//Campo 201
@ nLinRel,060 PSAY Posicione("CTT", 1, xFilial("CTT") + TRBCABEC->C5_ZCC ,"CTT_DESC01")//Campo 202
@ nLinRel,075 PSAY TRBCABEC->C5_ZUF //Campo 203

nLinRel += 3

//Empresa Top Mix Engenharia e concreto
SM0->(dbSetOrder(1))
SM0->(dbSeek(cEmpAnt + TRBCABEC->F2_FILIAL))

//Comprime impressao
@ nLinRel,000 PSAY CHR(15)
	@ nLinRel  ,060 PSAY AllTrim(SM0->M0_ENDCOB)//Campo 204
	@ nLinRel++,115 PSAY AllTrim(SM0->M0_BAIRCOB)//Campo 205
//Restaura impressao
@ nLinRel,000 PSAY CHR(18)	
	
@ nLinRel, 035 PSAY AllTrim(SM0->M0_CIDENT)//Campo 206
@ nLinRel, 055 PSAY AllTrim(SM0->M0_ESTENT)//Campo 207
@ nLinRel, 065 PSAY AllTrim(SM0->M0_CEPENT)//Campo 208
 
nLinRel += 1

//Fone . . . .  . Fax . . . . .  . 
//@ nLinRel,  043 PSAY SM0->M0_TEL //Campo 209
//@ nLinRel++,069 PSAY SM0->M0_FAX //Campo 210


//CGC
@ nLinRel++,045 PSAY Transform(ALLTRIM(SM0->M0_CGC),"@R 99.999.999/9999-99")//Campo 211
//INS
@ nLinRel++,045 PSAY SM0->M0_INSC //Campo 212 
@ nLinRel++,045 PSAY SM0->M0_INSCM //Campo 213

//Lado esquerdo
@ nLinRel,   000 PSAY SuperGetMv("FS_RPSTX1",  .F. , "FS_RPSTX1") //Campo 215
@ nLinRel, 	 018 PSAY SuperGetMv("FS_TELCOB1", .F. , "FS_TELCOB1") //Campo 216
@ nLinRel++, 045 PSAY U_FSAjuDat(TRBCABEC->F2_EMISSAO)//Campo 214
@ nLinRel  , 000 PSAY SuperGetMv("FS_RPSTX2" , .F. , "FS_RPSTX2")  //Campo 219

While TRBFIN->(!Eof()) .And.  TRBFIN->(E1_FILIAL + E1_PREFIXO + E1_NUM) == TRBCABEC->(xFilial("SE1") + F2_PREFIXO +  F2_DUPL) 
   aAdd(aArrRod, {AllTrim(TRBFIN->E1_NUM) + "/" + AllTrim(TRBFIN->E1_PARCELA),;
                  U_FSAjuDat(TRBFIN->E1_VENCTO),;
                  AllTrim(Transform(TRBFIN->E1_VALOR, "@E 999,999,999.99")),;
                  AllTrim(TRBCABEC->F2_COND),;
                  AllTrim(TRBFIN->E4_DESCRI)})
  	TRBFIN->(dbSkip())
EndDo

//Se o Array estiver com conteudo é por que ja foi alimentado pelo while uma vez, e ele tera seu valor resetado no loop do TRBCABEC
nLinRel := Iif(lPriPag,47,57)

//Comprime impressao
@ nLinRel,000 PSAY CHR(15)

@ nLinRel,024 PSAY AllTrim(TRBCABEC->F2_DOC) 	    		                // Campo 217

If (Len(aArrRod) > 0)
	@ nLinRel  ,043 PSAY aArrRod[1][3]             			                // Campo 218
	@ nLinRel  ,068 PSAY aArrRod[1][1] + " de " + cValToChar(Len(aArrRod)) // Campo 219
	@ nLinRel++,090 PSAY aArrRod[1][2]                                    // Campo 220
	cNatSE1 := aArrRod[1][5]
Else
	@ nLinRel  ,043 PSAY "0000"             			                // Campo 218
	@ nLinRel  ,037 PSAY "000000" + " de " + "00"							 // Campo 219
	@ nLinRel++,051 PSAY "00/00/0000"                               // Campo 220
	cNatSE1 := ""
EndIf
//Comprime impressao
@ nLinRel,000 PSAY CHR(18)

nLinRel += 2

@ nLinRel, 030  PSAY SuperGetMv("FS_TX3" , .F. , "FS_TX3") //Campo 215

nLinRel += 2

@ nLinRel  ,020 PSAY TRBCABEC->A1_NOME //Campo 301

//Comprime impressao
@ nLinRel,000 PSAY CHR(15)
	
	@ nLinRel  ,116 PSAY cNatSE1      		//Campo 315
//Comprime impressao
@ nLinRel,000 PSAY CHR(18)

nLinRel += 2       

@ nLinRel  ,020 PSAY TRBCABEC->A1_END    //Campo 302
@ nLinRel++,060 PSAY TRBCABEC->A1_BAIRRO //Campo 303

@ nLinRel  ,025 PSAY TRBCABEC->A1_MUN //Campo 304
@ nLinRel  ,060 PSAY TRBCABEC->A1_EST //Campo 305
@ nLinRel++,070 PSAY TRBCABEC->A1_CEP //Campo 306


@ nLinRel  ,020 PSAY AllTrim(TRBCABEC->C5_ZENDCOB) + ", " +AllTrim(TRBCABEC->C5_ZENDNUM)//Campo 307
@ nLinRel++,060 PSAY TRBCABEC->C5_ZBAIROC //Campo 308


@ nLinRel  ,020 PSAY U_FSRetMun(TRBCABEC->C5_ZESTOB, TRBCABEC->C5_ZMUNOB)
@ nLinRel  ,050 PSAY TRBCABEC->C5_ZEST //Campo 310
@ nLinRel  ,060 PSAY TRBCABEC->C5_ZCEP //Campo 311
@ nLinRel++,070 PSAY TRBCABEC->A1_TEL  //Campo 312

@ nLinRel   ,025 PSAY Iif(Len(AllTrim(TRBCABEC->A1_CGC)) == 14 , Transform(TRBCABEC->A1_CGC , "@R 99.999.999/9999-99") , Transform(TRBCABEC->A1_CGC , "@R 999.999.999-99"))//Campo 313
@ nLinRel++ ,060 PSAY IIF(TRBCABEC->A1_PESSOA=="F",TRBCABEC->A1_RG,IF(TRBCABEC->A1_PESSOA=="J",TRBCABEC->A1_INSCR,"")) //Campo 314

nLinRel += 2     

If (lFimRel)
	cExtenso := Extenso(TRBCABEC->F2_VALTOT) + Space(01) + Replicate("*", 210)
	@ nLinRel++, 021 PSAY SubStr(cExtenso,001,60) //Campo 315  
	@ nLinRel++, 021 PSAY SubStr(cExtenso,060,60) 
	nConLin := 0
Else
	cExtenso:= "VALORES IMPRESSOS NA ULTIMA PAGINA" + Space(01) + Replicate("*", 210)
	@ nLinRel++, 021 PSAY SubStr(cExtenso,001,60) //Campo 315  
	@ nLinRel++, 021 PSAY SubStr(cExtenso,060,60)
EndIf	


lIniOne := .F.


aEval(aAreas, {|x|RestArea(x)})   

Return Nil

