#INCLUDE "PROTHEUS.CH"

#DEFINE CAB_ARQTMP  01
#DEFINE CAB_POSATU  02
#DEFINE CAB_SAYGET  03
#DEFINE CAB_HFLD1   04
#DEFINE CAB_HFLD2   05
#DEFINE CAB_HFLD3   06
#DEFINE CAB_MARK    07 
#DEFINE CAB_GETDAD  08                     
#DEFINE CAB_COTACAO 09
#DEFINE CAB_MSMGET  10
#DEFINE CAB_ULTFORN 11
#DEFINE CAB_HISTORI 12
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A160Analis³Autor  ³Eduardo Riera          ³ Data ³09/08/2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de analise das cotacoes de compra                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Arquivo                                      ³±±
±±³          ³ExpN2: Numero do Registro                                    ³±±
±±³          ³ExpN3: Opcao do MBrowse                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGACOM                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function A160Analis(cAlias,nReg,nOpcX)

        Local aArea		:= GetArea()
Local aTitles   := {    OemToAnsi("Planilha"),;	//"Planilha"
						OemToAnsi("Auditoria"),;	//"Auditoria"
						OemToAnsi("Fornecedor"),;	//"Fornecedor"
						OemToAnsi("Historico")}		//"Historico"
						
Local aSizeAut	:= {}
Local aObjects	:= {}
Local aInfo 	:= {}
Local aInfo2 	:= {}
Local aPosGet	:= {}
Local aPosObj	:= {}
Local aPosObj3	:= {}
Local aPosObj4	:= {}
Local aRet160PLN:= {}

Local aPlanilha := {}
Local aAuditoria:= {}
Local aCotacao  := {}
Local aListBox  := {}
Local aHeadUltF := {}
Local aRefImpos := {}
Local aCabec	:= {"",0,Array(31,2),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil} 
Local aCT5      := {}
Local bCtbOnLine:= {||.T.}
Local lProceCot := MV_PAR17==1
Local bPage	    := {}
Local bOk		:= {||IIF(MA160TOK(nOpcX,nReg,aPlanilha,aAuditoria,aCotacao,aCabec,aSC8,aCpoSC8),Eval({|| Eval(bPage,0),nOpcA:=1,IIf(U_A160FeOdlg(lProceCot,@nOpcA,l160Visual,aCabec,aCotacao,aAuditoria),oDlg:End(),.F.)}),.F.)}
//{||IIF(MA160TOK(nOpcX,nReg,aPlanilha,aAuditoria,aCotacao,aCabec,aSC8,aCpoSC8),oDlg:End(),.F.)}
Local bCancel	:= {||oDlg:End()}
Local cLoteCtb  := ""
Local cArqCtb   := ""
Local c652      := ""
Local lSugere	:= MV_PAR01==1 .And. !l160Auto
Local lTes		:= MV_PAR02==1
Local lEntrega	:= MV_PAR03==1
Local lDtNeces  := MV_PAR04==1
Local lSelFor   := (MV_PAR05==1 .Or. !lSugere)
Local lBestFor  := MV_PAR09==1
Local lNota     := MV_PAR10==1
Local lCtbOnLine:= MV_PAR11==1 .And. SC7->(FieldPos("C7_DTLANC"))<>0 .And. VerPadrao("652")
Local lAglutina := MV_PAR12==1
Local lDigita   := MV_PAR13==1
Local l160Visual:= aRotina[nOpcX,4] <> 3 .And.aRotina[nOpcX,4] <> 4 .And. aRotina[nOpcX,4] <> 6
Local lMT160ok  := .T.
Local lSigaCus  := .T.
Local nOpcA		:= 0
Local nToler    := MV_PAR08
Local nX		:= 0
Local nY		:= 0
Local nOpcGetd  := nOpcX
Local nHdlPrv   := 0
Local nTotalCtb := 0
Local nScanCot  := 0
Local nPosNumCot:= 0
Local nSaveSX8  := GetSX8Len()
Local nResHor   := IIF(!l160Auto,GetScreenRes()[1],0) //Tamanho resolucao de video horizontal
Local nResVer   := IIF(!l160Auto,GetScreenRes()[2],0) //Tamanho resolucao de video horizontal
Local oDlg
Local oFolder
Local oFont
Local oScroll
Local cNumCot  := SC8->C8_NUM
Local cProdCot := ""
Local cItemCotID  := ""
Local cMoeda   := SubStr(GetMv("MV_SIMB"+GetMv("MV_MCUSTO"))+Space(4),1,4)
Local lProd1   := .T.
Local aAreaSC8 := SC8->(GetArea())

Local nScanGrd := 0
Local nScanIte := 0
Local nScanFor := 0
Local nScanLoj := 0
Local nScanNum := 0

Local nPos     := 0
Local nLoop    := 0
Local nLoop1   := 0
Local aCpoSC8  := {}
Local aCtbDia  := {}
Local lContinua:= .T.

Local nPFornSCE := 0
Local nPLojaSCE := 0
Local nPPropSCE := 0
Local nPItemSCE := 0
Local nPQtdeSCE := 0
Local nPUsrQtd  := 0
Local nPUsrItem := 0
Local nPUsrForn := 0
Local nPUsrLoja := 0
Local nPUsrProp := 0
Local nPACCNUM  := 0
Local nPACCITEM := 0
Local aAutItems := {}
Local nItmAuto  := 0
Local nForAuto  := 0
LOcal nForVenc  := 0
Local cCotACC	:= "(SC8->(FieldPos('C8_ACCNUM'))>0 .And. !Empty(SC8->C8_ACCNUM) .And. Empty(SC8->C8_NUMPED))"
Local cCompACC  := ""
Local aDadosACC := {}

// Projeto - botoes F5 e F6 para movimentacao
// guarda as teclas atuais
Local bOldF5 := SetKey(VK_F5)
Local bOldF6 := SetKey(VK_F6)


#IFDEF TOP
	Local cQuery    := ""
	Local cAliasCot := ""
#ENDIF	

PRIVATE aHeader     := {}
PRIVATE aCols       := {}
PRIVATE nMoedaAval  := 1
Private aSC8        := {}
If !lProceCot
	PRIVATE aProds  := {}
Endif	

If !l160Auto
	bPage := {|n| Eval(oFolder:bSetOption,1),oFolder:nOption:=1,Ma160Page(n,@aCabec,@aPlanilha,@aAuditoria,@aCotacao,oScroll,lProceCot,aCpoSC8,@oDlg,aPosGet)}
Else
   bPage := {|n| Ma160Page(n,@aCabec,@aPlanilha,@aAuditoria,@aCotacao,oScroll,lProceCot,aCpoSC8)}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao da Estrutura do array aCotaGrade ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ 1 - C8_FORNECE                             ³
//³ 2 - C8_LOJA                                ³
//³ 3 - C8_NUMPRO                              ³
//³ 4 - C8_ITEM                                ³
//³ 5 - C8_PRODUTO (Familia)                   ³
//³ 6 - Alimentado quando for produto de Grade ³
//³ 6.1 - C8_PRODUTO                           ³
//³ 6.2 - CE_QUANT                             ³
//³ 6.3 - C8_DATPRF                            ³
//³ 6.4 - C8_ITEMGRD                           ³
//³ 6.5 - Recno SC8                            ³
//³ 6.6 - C8_QUANT (Quantidade Original)       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aLinGrade := {}
PRIVATE aCotaGrade:= {}
PRIVATE lGrade    := MaGrade()
PRIVATE oGrade	  := MsMatGrade():New('oGrade',,"CE_QUANT",,"A160GValid()",,;
  						{ 	{"CE_QUANT"  ,NIL,NIL},;
							{"CE_ENTREGA",NIL,NIL}, ;
							{"CE_ITEMGRD",NIL,NIL} })
PRIVATE ALTERA    := .T.   // Necessario para o objeto grade

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desabilida button Replica do objeto de grade                    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGrade:lShowButtonRepl := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
   //	Aviso(STR0027,STR0029,{STR0028}) //"Atualizar patch do programa SIGACUS.PRW !!!"
	lSigaCus := .F.
EndIf
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
	//Aviso(STR0027,STR0030,{STR0028}) //"Atualizar patch do programa SIGACUSA.PRW !!!"
	lSigaCus := .F.
EndIf
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
   //	Aviso(STR0027,STR0031,{STR0028}) //"Atualizar patch do programa SIGACUS.PRW !!!"
	lSigaCus := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao do ATUALIZADOR  ³
//³ do dicionario do modulo de Compras necessario para o uso do     |
//| recurso de grade produtos no MP10 Relese I deverá ser retirado  |
//| no proximo Release da Versao quando o dicionario for Atualizado |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(FindFunction("UPDCOM01_V") .And. UPDCOM01_V() >= 20070615)
 //	Final("Atualizar UPDCOM01_V.PRW ou checar o processamento deste UPDATE !!!") // "Atualizar UPDCOM01_V.PRW ou checar o processamento deste UPDATE !!!"
EndIf

If FunName() # "RPC" .And. !l160Auto .And. &(cCotACC)
	If nOpcX # 2
		Aviso("Portal ACC","Esta cotação poderá ser manipulada somente via portal ACC.",{"Ok"})  //"Portal ACC"#""Esta cotação poderá ser manipulada somente via portal ACC.""
		lContinua := .F.
	EndIf
EndIf

If lContinua .And. lSigaCus
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua a montagem dos dados referentes ao fornecedor            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA2")
	dbSetOrder(1)
	MsSeek(xFilial("SA2")+SC8->C8_FORNECE+SC8->C8_LOJA)
	RegToMemory("SA2",.F.,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Iniciar lancamento do PCO                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoIniLan("000052")
    
    If !lProceCot
		#IFDEF TOP
			dbSelectArea("SC8")
			cAliasCot:= GetNextAlias()
			cQuery := "SELECT DISTINCT C8_PRODUTO, C8_IDENT "
			cQuery += "FROM "+RetSqlName("SC8")+" SC8 "
			cQuery += "WHERE SC8.C8_FILIAL='"+xFilial("SC8")+"' AND "
			cQuery += "SC8.C8_NUM='"+cNumCot+"' AND "
			cQuery += "SC8.D_E_L_E_T_=' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCot,.T.,.T.)
			While (cAliasCot)->(!Eof())
			    AADD(aProds,{(cAliasCot)->C8_PRODUTO,(cAliasCot)->C8_IDENT,IIF(lProd1,"X"," "),cNumCot})
			    If lProd1
				    cProdCot := (cAliasCot)->C8_PRODUTO
				    cItemCotID := (cAliasCot)->C8_IDENT
				    lProd1 := .F.
				Endif    
				(cAliasCot)->(dbSkip())
			EndDo
			dbSelectArea(cAliasCot)
			dbCloseArea()
   		#ELSE
   			dbSelectArea("SC8")
   			dbSetOrder(4)
   			dbSeek(xFilial("SC8")+cNumCot)
   			While !Eof() .And. SC8->C8_FILIAL+SC8->C8_NUM == xFilial("SC8")+cNumCot
			    nPos := Ascan(aProds,{|x| x[1]==SC8->C8_PRODUTO .And. x[2]==SC8->C8_IDENT})
			    If nPos == 0
				    AADD(aProds,{SC8->C8_PRODUTO,SC8->C8_IDENT,IIF(lProd1,"X"," "),cNumCot})
				    If lProd1
					    cProdCot := SC8->C8_PRODUTO
					    cItemCotID := SC8->C8_IDENT
					    lProd1 := .F.
					Endif    
				Endif	
	   			dbSkip()
   			EndDo
		#ENDIF
		RestArea(aAreaSC8)
	Endif	
	
	If MultLock("SC8",{cNumCot},1)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetua a montagem dos dados a serem exibidos pelo programa      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MaMontaCot(@aCabec,@aPlanilha,@aAuditoria,@aCotacao,@aListBox,@aRefImpos,lTes,nOpcX==2,lProceCot,cProdCot,cItemCotID,.T.,aSC8,aCpoSC8)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seleciona as melhores cotacoes conforme os parametros           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( nOpcX == 3 .And. (lSugere .Or. !lSelFor) )
				MaAvCotVen(@aPlanilha,@aCotacao,@aAuditoria,aCABEC[05],lEntrega,nToler,lNota,lBestFor,,aCpoSC8,lSelFor)
			EndIf
			
			dbSelectArea(aCabec[01])      
			
			If !l160Auto	
				aSizeAut := MsAdvSize(,.F.)
		
				aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],315,{{001,013,070,195,230,295,195,230},;
					{007,038,101,140,204,245,007,038,101,140}, {210,255}, {003,043,096,139,191,218} })
	
				aObjects := {}
				AAdd( aObjects, { 000, 025, .T., .F. } )
				AAdd( aObjects, { 100, 100, .T., .T., .T. } )
				aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
				aPosObj := MsObjSize( aInfo, aObjects )
	
				aObjects := {}
				AAdd( aObjects, { 000, 100, .T., .T. } )
				AAdd( aObjects, { 100, 084, .T., .T., .T. } )			
				aInfo2 := { 0, 0, aPosObj[2,3] - 3, aPosObj[2,4] - 13, 2, 2 }	
				aPosObj3 := MsObjSize( aInfo2, aObjects, .T. ) 	
		
				aObjects := {}
				AAdd( aObjects, { 000,100, .T., .T., .T. } )
				AAdd( aObjects, { 000,100, .T., .T., .T. } )	
				aInfo2 := { 129, 0, aPosObj[2,3] - 3, aPosObj[2,4] - 13, 2, 2 }	
				aPosObj4 := MsObjSize( aInfo2, aObjects ) 	
		
				DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
				DEFINE MSDIALOG oDlg TITLE OemToAnsi("Análise de Cotações") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL //"An lise de Cota‡”es"
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Definicao dos Gets do Cabecalho da Area de Trabalho             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DEFINE FONT oFont SIZE 8,0 BOLD
				
				@ 035,aPosGet[1,1] SAY   aCabec[03,1,1] PROMPT RetTitle("C8_PRODUTO") SIZE 22,09 PIXEL OF oDlg
				@ 035,aPosGet[1,2] MSGET aCabec[03,2,1] VAR aCabec[03,2,2] PICTURE PesqPict("SC8","C8_PRODUTO",30) SIZE 105,09 WHEN .F. PIXEL OF oDlg
		
				oScroll := TScrollBox():New( oDlg, 030, aPosGet[1,3] - 10, 25,aPosGet[1,3] + 45)
				@ 05, 02 SAY aCabec[03,3,1] PROMPT aCabec[03,3,2] SIZE 120,80 PIXEL Of oScroll
				aCabec[03,3,1]:Disable()
		
				@ 035,aPosGet[1,4] SAY   aCabec[03,4,1] PROMPT RetTitle("C8_QUANT") SIZE 30,09 PIXEL OF oDlg
				@ 035,aPosGet[1,5] MSGET aCabec[03,5,1] VAR aCabec[03,5,2] PICTURE PesqPict("SC8","C8_QUANT",30) SIZE 64,09 WHEN .F. PIXEL OF oDlg
				@ 035,aPosGet[1,6] SAY   aCabec[03,6,1] PROMPT aCabec[03,6,2] SIZE 30,09 COLOR CLR_BLUE PIXEL OF oDlg FONT oFont
				@ 048,aPosGet[1,7] SAY   aCabec[03,7,1] PROMPT OemToAnsi("Saldo") SIZE 30,09 PIXEL OF oDlg //"Saldo"
				@ 048,aPosGet[1,8] MSGET aCabec[03,8,1] VAR aCabec[03,8,2] PICTURE PesqPict("SC8","C8_QUANT",30) SIZE 64,09 WHEN .F. PIXEL OF oDlg
		
				If ExistBlock("MT160TEL")
					ExecBlock("MT160TEL",.F.,.F.,{@oDlg, aPosGet,nOpcx, nReg} )                
				EndIf  		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Criacao do Objeto oFolder com os Folders da Analise             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,{"HEADER"},oDlg,,,, .T., .F.,aPosObj[2,3],aPosObj[2,4])
				oFolder:bSetOption:={|x| Ma160Fld(x,oFolder:nOption,oFolder,@aCabec,@aListBox,aPosObj3)}
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Folder 1 - Planilha de Cotacao                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCabec[07]:=MsSelect():New(aCabec[01],"PLN_OK",,aCabec[04],.F.,"XX",{3,3,aPosObj[2,4] - 16,aPosObj[2,3] - 5},,,oFolder:aDialogs[1])
				aCabec[07]:oBrowse:lCanAllMark := .F.
				If ( nOpcX == 3 )
					If ( lSelFor )
						aCabec[07]:bMark := {|| Ma160Marca(@aCabec,@aPlanilha,@aCotacao,oScroll,@aListBox,aCpoSC8) }
					Else
						aCabec[07]:bAval := {|| .T. }
						nOpcGetd := 2
					Endif
				Else
					aCabec[07]:bAval := {|| .T. }
					nOpcGetd := 2
				EndIf	
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Folder 2 - Planilha de Auditoria                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aHeader := aCabec[05]
				aCols   := aAuditoria[1]
				aCabec[08]:=MSGetDados():New(3,3,aPosObj[2,4]-16,aPosObj[2,3]-5,nOpcGetd,"Ma160LinOk","","",.T.,,,,300,,,,,oFolder:aDialogs[2])
				aCabec[08]:oBrowse:bValid := {|lGrava| Ma160VldGd(@aCabec,@aPlanilha,@aCotacao,lGrava,aCpoSC8) }
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Folder 3 - Planilha do Fornecedor - Informaoes Cadastrais       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCabec[10]:=MsMGet():New("SA2",SA2->(RecNo()),1,,,,,{aPosObj3[1,1],aPosObj3[1,2],aPosObj3[1,3]+17,aPosObj3[1,4]-155},,2,,,,oFolder:aDialogs[3],,.T.,,,.F.)
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Folder 3 - Gets de Informacoes do Fornecedor.                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SA2->(dbSetOrder(1))
				SA2->(MsSeek(xFilial("SA2")+(aCabec[01])->PLN_FORNECE+(aCabec[01])->PLN_LOJA))
				@ 013,aPosObj3[1,4]-130 SAY "Saldo Historico"             SIZE 55,9 OF oFolder:aDialogs[3] PIXEL COLOR CLR_BLUE	 //"Saldo Historico"
				@ 027,aPosObj3[1,4]-130 SAY "Maior Compra"+" "+cMoeda  SIZE 55,9 OF oFolder:aDialogs[3] PIXEL COLOR CLR_BLUE	 //"Maior Compra"
				@ 041,aPosObj3[1,4]-130 SAY "Maior Nota"+" "+cMoeda  SIZE 55,9 OF oFolder:aDialogs[3] PIXEL COLOR CLR_BLUE	 //"Maior Nota"
				@ 055,aPosObj3[1,4]-130 SAY "Maior Saldo"+" "+cMoeda  SIZE 55,9 OF oFolder:aDialogs[3] PIXEL COLOR CLR_BLUE	 //"Maior Saldo"
				@ 069,aPosObj3[1,4]-130 SAY "Saldo Historico em"+" "+cMoeda  SIZE 55,9 OF oFolder:aDialogs[3] PIXEL COLOR CLR_BLUE	 //"Saldo Historico em"
				@ 083,aPosObj3[1,4]-130 SAY "Maior Atraso"    SIZE 55,9 OF oFolder:aDialogs[3] PIXEL COLOR CLR_BLUE	 //"Maior Atraso"
				@ 013,aPosObj3[1,4]-070 MSGET aCabec[03,14,1] VAR aCabec[03,14,2] SIZE 53,9 OF oFolder:aDialogs[3] PIXEL When .F. Picture PesQPict("SA2","A2_SALDUP",19)
				@ 027,aPosObj3[1,4]-070 MSGET aCabec[03,15,1] VAR aCabec[03,15,2] SIZE 53,9 OF oFolder:aDialogs[3] PIXEL When .F. Picture PesQPict("SA2","A2_MCOMPRA",19)
				@ 041,aPosObj3[1,4]-070 MSGET aCabec[03,16,1] VAR aCabec[03,16,2] SIZE 53,9 OF oFolder:aDialogs[3] PIXEL When .F. Picture PesQPict("SA2","A2_MNOTA",19)
				@ 055,aPosObj3[1,4]-070 MSGET aCabec[03,17,1] VAR aCabec[03,17,2] SIZE 53,9 OF oFolder:aDialogs[3] PIXEL When .F. Picture PesQPict("SA2","A2_MSALDO",19)
				@ 069,aPosObj3[1,4]-070 MSGET aCabec[03,18,1] VAR aCabec[03,18,2] SIZE 53,9 OF oFolder:aDialogs[3] PIXEL When .F. Picture PesQPict("SA2","A2_SALDUPM",19)
				@ 083,aPosObj3[1,4]-070 MSGET aCabec[03,19,1] VAR aCabec[03,19,2] SIZE 53,9 OF oFolder:aDialogs[3] PIXEL When .F. Picture PesqPictQt("A2_MATR")
				                                                                                                
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Folder 3 - Botao de consulta da Posicao do Fornecedor           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				@ 103,aPosObj3[1,4]-117 BUTTON "Consulta Posicao do Fornecedor" SIZE 100,012 ACTION A160ToFC030(aCabec) OF oFolder:aDialogs[3] PIXEL //"Consulta Posicao do Fornecedor"
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Folder 3 - ListBox das Propostas do Fornecedor para o Produto   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				@ aPosObj3[2,1]+17,aPosObj3[2,2] LISTBOX aCabec[09] FIELDS TITLE "" SIZE aPosObj3[2,3],aPosObj3[2,4]-17 OF oFolder:aDialogs[3] PIXEL
				aCabec[09]:aHeaders := aCabec[06]
				aCabec[09]:SetArray(aListBox[1][(aCabec[01])->(RecNo())])
				aCabec[09]:bLine := {|| aCabec[09]:aArray[aCabec[09]:nAT]}
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Folder 4 - Planilha Historico Produto - Gets Estoque Consolidado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
				// ---- Seta a Posição de acordo com a Resolução do Video --- //
				If !SetMDIChild()
					If nResHor < 1600
					    aPosGet[4,02]:= CalcRes(8,nResHor,,.T.)
					    aPosObj4[1,2]:= CalcRes(8,nResHor,,.T.)+60
					    aPosObj4[2,2]:= CalcRes(8,nResHor,,.T.)+60
					Else
					    aPosGet[4,02]:= CalcRes(6,nResHor,,.T.)
					    aPosObj4[1,2]:= CalcRes(6,nResHor,,.T.)+60
					    aPosObj4[2,2]:= CalcRes(6,nResHor,,.T.)+60			    
					EndIf
				Else
					If nResHor < 1600
					    aPosGet[4,02]:= CalcRes(7,nResHor,,.T.)
					    aPosObj4[1,2]:= CalcRes(7,nResHor,,.T.)+60
					    aPosObj4[2,2]:= CalcRes(7,nResHor,,.T.)+60
					Else
					    aPosGet[4,02]:= CalcRes(5,nResHor,,.T.)
					    aPosObj4[1,2]:= CalcRes(5,nResHor,,.T.)+60
					    aPosObj4[2,2]:= CalcRes(5,nResHor,,.T.)+60
					EndIf
				Endif
				// ---- Seta o tamanho de acordo com o Aspecto da Tela --- //			
				If  ( nResHor/nResVer < 1.4 )//Aspecto 4:3				
					aPosObj4[1,3]:= aPosObj4[1,3]-CalcRes(1,nResHor,,.T.)
					aPosObj4[2,3]:= aPosObj4[2,3]-CalcRes(1,nResHor,,.T.)
				ElseIf ( nResHor/nResVer > 1.7 ) // Aspecto 16:9
					aPosObj4[1,3]:= aPosObj4[1,3]-CalcRes(2,nResHor,,.T.)-10
					aPosObj4[2,3]:= aPosObj4[2,3]-CalcRes(2,nResHor,,.T.)-10
				Else// Aspecto 16:10 e outros
					aPosObj4[1,3]:= aPosObj4[1,3]-CalcRes(2.5,nResHor,,.T.)-10
					aPosObj4[2,3]:= aPosObj4[2,3]-CalcRes(2.5,nResHor,,.T.)-10
				EndIf
				
				@ aPosObj4[1,1]+03,003 SAY "Estoque Consolidado" OF oFolder:aDialogs[4] PIXEL FONT oBold COLOR CLR_RED //"Estoque Consolidado"
				@ aPosObj4[1,1]+13,003 TO aPosObj4[1,1]+14,120 OF oFolder:aDialogs[4] PIXEL 
				@ 019,aPosGet[4,01] SAY "Quantidade Disponivel    " OF oFolder:aDialogs[4] PIXEL //"Quantidade Disponivel    "
				@ 019,aPosGet[4,02] MsGet aCabec[03,20,1] VAR aCabec[03,20,2] Picture PesqPict("SB2","B2_QATU") SIZE 55,08 WHEN .F. PIXEL OF oFolder:aDialogs[4] RIGHT
				@ 033,aPosGet[4,01] SAY "Quantidade Empenhada " OF oFolder:aDialogs[4] PIXEL //"Quantidade Empenhada "
				@ 033,aPosGet[4,02] MsGet aCabec[03,21,1] VAR aCabec[03,21,2] Picture PesqPict("SB2","B2_QEMP") SIZE 55,08 WHEN .F. PIXEL OF oFolder:aDialogs[4] RIGHT
				@ 047,aPosGet[4,01] SAY "Saldo Atual   " OF oFolder:aDialogs[4] PIXEL //"Saldo Atual   "
				@ 047,aPosGet[4,02] MsGet aCabec[03,22,1] VAR aCabec[03,22,2] Picture PesqPict("SB2","B2_QATU") SIZE 55,08 WHEN .F. PIXEL OF oFolder:aDialogs[4] RIGHT
				@ 061,aPosGet[4,01] SAY "Qtd. Entrada Prevista" OF oFolder:aDialogs[4] PIXEL //"Qtd. Entrada Prevista"
				@ 061,aPosGet[4,02] MsGet aCabec[03,23,1] VAR aCabec[03,23,2] Picture PesqPict("SB2","B2_SALPEDI") SIZE 55,08 WHEN .F. PIXEL OF oFolder:aDialogs[4] RIGHT
				@ 075,aPosGet[4,01] SAY "Qtd. Pedido de Vendas  " OF oFolder:aDialogs[4] PIXEL //"Qtd. Pedido de Vendas  "
				@ 075,aPosGet[4,02] MsGet aCabec[03,24,1] VAR aCabec[03,24,2] Picture PesqPict("SB2","B2_QPEDVEN") SIZE 55,08 WHEN .F. PIXEL OF oFolder:aDialogs[4] RIGHT
				@ 089,aPosGet[4,01] SAY "Qtd. Reservada  " OF oFolder:aDialogs[4] PIXEL //"Qtd. Reservada  "
				@ 089,aPosGet[4,02] MsGet aCabec[03,25,1] VAR aCabec[03,25,2] Picture PesqPict("SB2","B2_RESERVA") SIZE 55,08 WHEN .F. PIXEL OF oFolder:aDialogs[4] RIGHT
				@ 103,aPosGet[4,01] SAY "Qtd. Empenhada S.A." OF oFolder:aDialogs[4] PIXEL //"Qtd. Empenhada S.A."
				@ 103,aPosGet[4,02] MsGet aCabec[03,26,1] VAR aCabec[03,26,2] Picture PesqPict("SB2","B2_QEMPSA") SIZE 55,08 WHEN .F. PIXEL OF oFolder:aDialogs[4] RIGHT
				@ 117,aPosGet[4,01] SAY RetTitle("B2_QTNP")    OF oFolder:aDialogs[4] PIXEL
				@ 117,aPosGet[4,02] MsGet aCabec[03,27,1] VAR aCabec[03,27,2] Picture PesqPict("SB2","B2_QTNP") SIZE 55,08 WHEN .F. PIXEL OF oFolder:aDialogs[4] RIGHT
				@ 131,aPosGet[4,01] SAY RetTitle("B2_QNPT")    OF oFolder:aDialogs[4] PIXEL
				@ 131,aPosGet[4,02] MsGet aCabec[03,28,1] VAR aCabec[03,28,2] Picture PesqPict("SB2","B2_QNPT") SIZE 55,08 WHEN .F. PIXEL OF oFolder:aDialogs[4] RIGHT
				@ 145,aPosGet[4,01] SAY RetTitle("B2_QTER")    OF oFolder:aDialogs[4] PIXEL 
				@ 145,aPosGet[4,02] MsGet aCabec[03,29,1] VAR aCabec[03,29,2] Picture PesqPict("SB2","B2_QTER") SIZE 55,08 WHEN .F. PIXEL OF oFolder:aDialogs[4] RIGHT
				@ 159,aPosGet[4,01] SAY RetTitle("B2_QEMPN")   OF oFolder:aDialogs[4] PIXEL 
				@ 159,aPosGet[4,02] MsGet aCabec[03,30,1] VAR aCabec[03,30,2] Picture PesqPict("SB2","B2_QEMPN") SIZE 55,08 WHEN .F. PIXEL OF oFolder:aDialogs[4] RIGHT
				@ 173,aPosGet[4,01] SAY RetTitle("B2_QACLASS") OF oFolder:aDialogs[4] PIXEL 
				@ 173,aPosGet[4,02] MsGet aCabec[03,31,1] VAR aCabec[03,31,2] Picture PesqPict("SB2","B2_QACLASS") SIZE 55,08 WHEN .F. PIXEL OF oFolder:aDialogs[4] RIGHT
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Folder 4 - ListBox da Posicao Analitica do estoque              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				@ aPosObj4[1,1]+03,aPosObj4[1,2] SAY "POSIÇÃO ANALITICA" OF oFolder:aDialogs[4] PIXEL FONT oBold COLOR CLR_RED //"POSIÇÃO ANALITICA"
				@ aPosObj4[1,1]+13,aPosObj4[1,2] TO aPosObj4[1,1]+14,aPosObj4[1,2]+aPosObj4[1,3] OF oFolder:aDialogs[4] PIXEL 
				@ aPosObj4[1,1]+17,aPosObj4[1,2] LISTBOX aCabec[12] FIELDS TITLE "" SIZE aPosObj4[1,3],aPosObj4[1,4]-17 OF oFolder:aDialogs[4] PIXEL
				aCabec[12]:aHeaders := {"","","","","","","","","",RetTitle("B2_QTNP"),RetTitle("B2_QNPT"),RetTitle("B2_QTER"),RetTitle("B2_QEMPN"),RetTitle("B2_QACLASS")}	
				aCabec[12]:SetArray({Array(14)})
				aCabec[12]:bLine := {|| aCabec[12]:aArray[aCabec[12]:nAt] }
				aCabec[12]:bChange := {|| A160UltFor(aCabec[12]:aArray[aCabec[12]:nAt,2],aCabec) }
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Folder 4 - Botao de consulta do Historico do Produto            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				@ 190,aPosGet[4,01] BUTTON "Mais Informacoes do Produto" SIZE 100,012 ACTION A160ComView(aCabec[12]:aArray[aCabec[12]:nAt,2]) OF oFolder:aDialogs[4] PIXEL //"Mais Informacoes do Produto"
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Folder 4 - ListBox dos Ultimos Fornecimentos do Produto         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaUltForn("",@aHeadUltF)
				@ aPosObj4[2,1]+03,aPosObj4[2,2] SAY "Ultimos Fornecimentos" OF oFolder:aDialogs[4] PIXEL FONT oBold COLOR CLR_RED //"Ultimos Fornecimentos"
				@ aPosObj4[2,1]+13,aPosObj4[2,2] TO aPosObj4[2,1]+14,aPosObj4[2,2]+aPosObj4[2,3] OF oFolder:aDialogs[4] PIXEL 
				@ aPosObj4[2,1]+17,aPosObj4[2,2] LISTBOX aCabec[11] FIELDS TITLE "" SIZE aPosObj4[2,3],aPosObj4[2,4]-17 OF oFolder:aDialogs[4] PIXEL
				aCabec[11]:aHeaders := aHeadUltF
				aCabec[11]:SetArray({aHeadUltF})
				aCabec[11]:bLine := {|| aCabec[11]:aArray[aCabec[11]:nAt] }
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Acerto na movimentacao do folder                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 to Len(oFolder:aDialogs)
					DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nX]
				Next nX
				
				ACTIVATE MSDIALOG oDlg ON INIT Ma160Bar(oDlg,bOk,bCancel,nOpcX,bPage,nReg,aPlanilha,aAuditoria,aCotacao,aListBox,aCabec,aRefImpos,lTes,lProceCot,aSC8,aCpoSC8)
			Else 
				PRIVATE bGetValid := {|lGrava| Ma160VldGd(@aCabec,@aPlanilha,@aCotacao,lGrava,aCpoSC8) }
						
				aHeader := aClone(aCabec[05])
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica os campos do aCols                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPItemSCE := aScan(aHeader,{|x| Trim(x[2])=="CE_ITEMCOT"}) 
				nPFornSCE := aScan(aHeader,{|x| Trim(x[2])=="CE_FORNECE"})
				nPLojaSCE := aScan(aHeader,{|x| Trim(x[2])=="CE_LOJA"   })
				nPPropSCE := aScan(aHeader,{|x| Trim(x[2])=="CE_NUMPRO" })
				nPQtdeSCE := aScan(aHeader,{|x| Trim(x[2])=="CE_QUANT"  })
		
		
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica os campos do array da rotina automatica                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				nPUsrItem := aScan(aAutoItens[1,1],{|x| Trim(x[1])=="CE_ITEMCOT"})
				nPUsrForn := aScan(aAutoItens[1,1],{|x| Trim(x[1])=="CE_FORNECE"})
				nPUsrLoja := aScan(aAutoItens[1,1],{|x| Trim(x[1])=="CE_LOJA"   })
				nPUsrProp := aScan(aAutoItens[1,1],{|x| Trim(x[1])=="CE_NUMPRO" })		
				nPUsrQtd  := aScan(aAutoItens[1,1],{|x| Trim(x[1])=="CE_QUANT"  })
				nPACCNUM  := aScan(aAutoItens[1,1],{|x| Trim(x[1])=="ACCNUM"    })
				nPACCITEM := aScan(aAutoItens[1,1],{|x| Trim(x[1])=="ACCITEM"    })
				
				nOpca := 1
				nX    := 1
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Varre paginacao da analise                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				While nX <= len(aAuditoria) .And. nOpca == 1
		                	aCols := aClone(aAuditoria[nX])//Carrega aCols com as propostas
		                	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona na pagina da analise |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Eval(bPage,nX)				
		                  
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se o item foi informado na rotina automatica          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nItmAuto := aScan(aAutoItens,{|x| x[1,nPUsrItem,2] == aAuditoria[nx,1,nPItemSCE]})
					If nItmAuto > 0
		     					For nY := 1 to Len(aCols)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica se o fornecedor foi informado na rotina automatica    ³
							//³ Em caso positivo copia sua quantidade						   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (nForAuto := aScan(aAutoItens[nItmAuto],{|x| x[nPUsrItem,2]+x[nPUsrForn,2]+x[nPUsrLoja,2]+x[nPUsrProp,2] == aCols[nY,nPItemSCE]+aCols[nY,nPFornSCE]+aCols[nY,nPLojaSCE]+aCols[nY,nPPropSCE]})) > 0
		    	   						aAuditoria[nX][nY][nPQtdeSCE] := aAutoItens[nItmAuto][nForAuto][nPUsrQtd][2]
		    	   						aAdd(aAutItems,aClone(aAutoItens[nItmAuto,nForAuto]))
		    	   						aAdd(aTail(aAutItems),{"LINPOS","CE_FORNECE+CE_LOJA",aAutoItens[nItmAuto][nForAuto][nPUsrForn][2],aAutoItens[nItmAuto][nForAuto][nPUsrLoja][2]})
		    	   						nForVenc := nForAuto
		    	   						If !Empty(nPACCNUM)
		    	   							aAdd(aDadosACC,{nX,nY,nItmAuto,nForAuto})
		    	   						EndIf
		    	  					Else
		    	  						aAdd(aAutItems,aClone(aAutoItens[nItmAuto,1]))
		                  		aTail(aAutItems)[nPUsrItem,2] := aCols[nY,nPItemSCE]
		                  		aTail(aAutItems)[nPUsrForn,2] := aCols[nY,nPFornSCE]
		                  		aTail(aAutItems)[nPUsrLoja,2] := aCols[nY,nPLojaSCE]
		                  		aTail(aAutItems)[nPUsrProp,2] := aCols[nY,nPPropSCE]
		                  		aTail(aAutItems)[nPUsrQtd,2]  := 0
		                  		aAdd(aTail(aAutItems),{"LINPOS","CE_FORNECE+CE_LOJA",aCols[nY,nPFornSCE],aCols[nY,nPLojaSCE]})
		        	          		EndIf
						Next
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Posiciona arquivo temporario no |
						//³ fornecedor vencedor. 			|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						While !(aCabec[01])->(EOF())
							If (aCabec[01])->PLN_FORNECE == aAutoItens[nItmAuto][nForVenc][nPUsrForn][2] .And.;
							   (aCabec[01])->PLN_LOJA == aAutoItens[nItmAuto][nForVenc][nPUsrLoja][2]						   
								Exit
							EndIf
							(aCabec[01])->(dbSkip())
						End
						
						If !MsGetDAuto(aAutItems,"Ma160LinOk",,aAutoCab,,.F.)
							nOpca := 0
							Exit
						Else
							nOpca := 1
						EndIf
					EndIf	 			                                
					nX++
					aAutItems := {}
				EndDo
			EndIf

			If ( Select(aCabec[01])<> 0 )
				dbSelectArea(aCabec[01])
				dbCloseArea()
				dbSelectArea("SC8")
			EndIf

		Else
			nOpcA := 0
		EndIf  
	    SC8->(MsUnlockAll())
	Endif
   

	// Projeto - botoes F5 e F6 para movimentacao
	// restaura as teclas
	SetKey(VK_F5,bOldF5)
	SetKey(VK_F6,bOldF6)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura o Array aAuditoria a condicao Original da tabela SC8³
	//³devido a glutinacao do mesmo para uso de produto de Grade.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If nOpcA == 1 .And. !l160Visual
		aAuditoria := U_A160Audit(aCabec,aAuditoria,aSC8,aCotagrade)
    EndIf

	If nOpcA == 1 .And. (ExistBlock("MT160OK") .Or. ExistBlock("MT160AOK"))

		If Len(aCotacao) >= 1
			nPosNumCot  := aScan(aCotacao[1][1],{|x| Trim(x[1])=="C8_NUM"})
			Private cA160num:= aCotacao[1,1,nPosNumCot,2]
		Endif
		
		If ExistBlock("MT160OK")

	   		lMT160ok := ExecBlock("MT160OK",.F.,.F.,aPlanilha)
	  		If ValType( lMT160ok ) == "L" .And. !lMT160ok
		   		nOpcA := 0
	   		EndIf
	   	
	   	ElseIf ExistBlock("MT160AOK")
			
			lMT160Aok := ExecBlock("MT160AOK",.F.,.F.,{aPlanilha, nOpcX})
			If ValType(lMT160Aok) == "L" .And. !lMT160Aok
				nOpcA := 0
			EndIf 
		EndIf
	EndIf

	If nOpcA == 1 .And. ExistBlock("MT160PLN")
		aRet160PLN := ExecBlock("MT160PLN",.F.,.F.,{aPlanilha,aAuditoria,aCotacao,nOpcX,aCpoSC8})
		If ValType( aRet160PLN ) == "A" 
			aPlanilha  := aRet160PLN[1]
			aAuditoria := aRet160PLN[2]
        EndIf
	EndIf

	If nOpcA == 1 .And. !l160Visual
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
		//³ Conforme situacao do parametro abaixo, integra com o SIGAGSP ³
		//³             MV_SIGAGSP - 0-Nao / 1-Integra                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÙ
		If SuperGetMV("MV_SIGAGSP",.F.,"0") == "1"
			GSPF200(aCotacao)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Prepara a contabilizacao On-Line                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCtbOnLine
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o numero do lote contabil                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SX5")
			dbSetOrder(1)
			If MsSeek(xFilial("SX5")+"09COM")
				cLoteCtb := AllTrim(X5Descri())
			Else
				cLoteCtb := "COM "
			EndIf		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa um execblock                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If At(UPPER("EXEC"),X5Descri()) > 0
				cLoteCtb := &(X5Descri())
			EndIf				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa o arquivo de contabilizacao                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nHdlPrv:=HeadProva(cLoteCtb,"MATA160",Subs(cUsuario,7,6),@cArqCtb)
			IF nHdlPrv <= 0
				HELP(" ",1,"SEM_LANC")
				lCtbOnLine := .F.
			EndIf
			If lCtbOnLine
				bCtbOnLine := {|| nTotalCtb += DetProva(nHdlPrv,"652","MATA120",cLoteCtb,,,,,@c652,@aCT5),;
				SC7->C7_DTLANC := dDataBase}
			EndIf
			
		EndIf
		
		//-- Tratamentos para o ACC gerar os pedidos de compra
		//-- com o grupo de aprovacao correto e gravando o numero ACC
		If l160Auto .And. (nPos := aScan(aAutoCab,{|x| x[1] == "COMPACC"})) > 0
			cCompACC := aAutoCab[nPos,2]
		EndIf
		
		If !Empty(aDadosACC)
			aEval(aDadosACC, {|x| aAdd(aAuditoria[x[1]][x[2]],aAutoItens[x[3]][x[4]][nPACCNUM][2]),aAdd(aAuditoria[x[1]][x[2]],aAutoItens[x[3]][x[4]][nPACCITEM][2])})
		EndIf
		
		Begin Transaction
			If ( U_MaAvalCOT("SC8",4,aSC8,aCABEC[05],aAuditoria,lDtNeces,Nil,bCtbOnLine,cCompACC) )
				EvalTrigger()
				While ( GetSX8Len() > nSaveSX8 )
					ConfirmSx8()		
				EndDo
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Conforme situacao do parametro abaixo, integra com SIGAGSP ³
				//³ MV_SIGAGSP - 0-Nao / 1-Integra                             ³
				//³ Para gerar os contratos no GSp                             ³
				//³ Solicitado por Roberto Mazzarolo em 25/10/2004 por e-mail  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If GetNewPar("MV_SIGAGSP","0") == "1"
					GSPF370(aCotacao,aCABEC[05],aAuditoria)
				EndIf
			Else
				While ( GetSX8Len() > nSaveSX8 )
					RollBackSx8()
				EndDo
			EndIf          		

		End Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para Workflow                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock( "MT160WF" )
			If !Empty( nScanCot := AScan( aCotacao[1,1], { |x| x[1] == "SC8RECNO" } ) )
				SC8->( dbGoto( aCotacao[ 1, 1, nScanCot, 2 ] ) )
				ExecBlock( "MT160WF", .f., .f., { SC8->C8_NUM } )
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia os dados para o modulo contabil                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCtbOnLine
			RodaProva(nHdlPrv,nTotalCtb)
			If nTotalCtb > 0
				If ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() )
					cCodDia := CTBAVerDia() 
					aCtbDia := {{"SC7",SC7->(RECNO()),cCodDia,"C7_NODIA","C7_DIACTB"}}
				Else
				    aCtbDia := {}
				EndIF    

				cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,,,aCtbDia)
			EndIf
		EndIf	
	Else
		While ( GetSX8Len() > nSaveSX8 )
			RollBackSx8()
		EndDo
		MsUnLockAll()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza processo de lancamento do PCO                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoFinLan("000052")
	PcoFreeBlq("000052")
	
	If ( Select(aCabec[01])<> 0 )
		dbSelectArea(aCabec[01])
		dbCloseArea()
		dbSelectArea("SC8")
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui arquivo de trabalho gerado por MontaCot na Comxfun ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If File(aCabec[01]+GetDBExtension())
		Ferase(aCabec[01]+GetDBExtension()) 
	Endif
	
EndIf

RestArea(aArea)
Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MA160TOK ºAutor  ³Turibio Miranda     º Data ³ 27/07/10    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao executada no botão Ok da enchoice Bar do programa    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ ExpN1: nOpc transmitida pela MBrowse - nOpcX               ³±±
±±³          ³ ExpN2: Numero do registro - nReg                           ³±±
±±³          ³ ExpA1: Array de planilhas de cotacao - aPlanilha           ³±±
±±³          ³ ExpA2: Array de auditorias - aAuditoria					  ³±±
±±³          ³ ExpA3: Array de cotacao - aCotacao	  					  ³±±
±±³          ³ ExpA3: Array de cotacao - aCotacao	  					  ³±±
±±³          ³ ExpA5: Array de campos considerados da SC8 - aSC8		  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA160								  	 	              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MA160TOK(nOpcX,nReg,aPlanilha,aAuditoria,aCotacao,aSC8)

Local lRet		:= .T.
Local nProd		:= aScan(aCotacao[1][1],{|x| Trim(x[1])=="C8_PRODUTO"})
Local nX		:= 0
Local cProd		:= ""
Local aAreaSB1	:= SB1->(GetArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Checa se produto está bloqueado                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	For nX := 1 To Len(aCotacao)
		cProd := aCotacao[nX][1][nProd][2]
		dbSelectArea("SB1")
		dbSetOrder(1)
		If MsSeek(xFilial("SB1")+cProd)
			If !RegistroOk("SB1")
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nX
EndIf

//Ponto de entrada para validar se permite a analise da cotacao
If ExistBlock("MA160TOK")
	lRet:= ExecBlock("MA160TOK",.F.,.F.,{nOpcX,nReg,aPlanilha,aAuditoria,aCotacao,aSC8})
	If ValType (lRet) <> "L"
		lRet:= .T.
	EndIf
EndIf

RestArea(aAreaSB1)

Return lRet



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±          
±±ºPrograma  ³CalcRes   ºAutor  ³Turibio Miranda     º Data ³  01/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que transforma um percentual da tela em pixels conforº±±
±±º          ³me a resolucao de video utilizada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nPerc   - Valor em percentual de video desejado		      º±±
±±º          ³nResHor - Resolucao Horizontal de referencia				  º±±
±±º          ³nResVer - Resolucao Vertical de referencia  		     	  º±±
±±º          ³lWidht  - Flag para controlar se a medida e vertical ou horzº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA160								  	 	              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CalcRes(nPerc,nResHor,nResVer,lWidth)
Local nRet

DEFAULT	nResHor:= GetScreenRes()[1]
DEFAULT nResVer:= GetScreenRes()[2]

if lWidth
	nRet := nPerc * nResHor / 100
else
	nRet := nPerc * nResVer / 100
endif

Return nRet  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma160Bar  ³ Autor ³ Eduardo Riera         ³ Data ³09.08.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ EnchoiceBar especifica do Mata160                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1: Objeto Dialog                                       ³±±
±±³          ³ ExpB2: Code Block para o Evento Ok                         ³±±
±±³          ³ ExpB3: Code Block para o Evento Cancel                     ³±±
±±³          ³ ExpN4: nOpc transmitido pela mbrowse                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ma160Bar(oDlg,bOk,bCancel,nOpc,bPage,nReg,aPlanilha,aAuditoria,aCotacao,aListBox,aCabec,aRefImpos,lTes,lProceCot,aSC8,aCpoSC8)

Local aButtons    := {}
Local aButtonUsr  := {}
Local nX		  := {}
Local cPrinter    := GetNewPar("MV_IMPRCOT"," ")
Local lMa160Imp   := IIf(!Empty( cPrinter ) .And. Existblock( cPrinter ),.T.,.F.)

DEFAULT aCpoSC8   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os botoes padroes                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aButtons,{"PMSPRINT",{|| IIF(!lMa160Imp,MA160Imp(aPlanilha,aAuditoria,aCotacao,aListBox,aCabec,aRefImpos,lTes,aCpoSC8),ExecBlock( cPrinter, .F., .F., {nReg,aPlanilha,aAuditoria,aCotacao,aListBox,aCabec,aRefImpos,lTes,aCpoSC8} )) },OemToAnsi(""),OemToAnsi("") })  

If lProceCot
	aadd(aButtons,{"PREV"    ,{|| Eval(bPage,-1)},OemToAnsi("Anterior"),OemToAnsi("Anterior")})	//"Anterior"
	aadd(aButtons,{"NEXT"    ,{|| Eval(bPage,+1)},OemToAnsi("Proximo"),OemToAnsi("Proximo")})	//"Proximo"

	// Projeto - botoes F5 e F6 para movimentacao
	// seta as teclas para realizar a movimentacao
	SetKey(VK_F5, {|| Eval(bPage,-1)}) 	//"Anterior"
	SetKey(VK_F6, {|| Eval(bPage,+1)}) 	//"Proximo"

Else
	aadd(aButtons,{"PREV"    ,{|| M160PRVNXT(.T.,aPlanilha,aAuditoria,aCotacao,aListBox,aCabec,aRefImpos,lTes,nOpc,bPage,lProceCot,aSC8,aCpoSC8)},OemToAnsi("Anterior"),OemToAnsi("Anterior")})	//"Anterior"
	aadd(aButtons,{"NEXT"    ,{|| M160PRVNXT(.F.,aPlanilha,aAuditoria,aCotacao,aListBox,aCabec,aRefImpos,lTes,nOpc,bPage,lProceCot,aSC8,aCpoSC8)},OemToAnsi("Proximo"),OemToAnsi("Proximo")})	//"Proximo"

	// Projeto - botoes F5 e F6 para movimentacao
	// seta as teclas para realizar a movimentacao
	SetKey(VK_F5, {|| M160PRVNXT(.T.,aPlanilha,aAuditoria,aCotacao,aListBox,aCabec,aRefImpos,lTes,nOpc,bPage,lProceCot,aSC8,aCpoSC8)}) 	//"Anterior"
	SetKey(VK_F6, {|| M160PRVNXT(.F.,aPlanilha,aAuditoria,aCotacao,aListBox,aCabec,aRefImpos,lTes,nOpc,bPage,lProceCot,aSC8,aCpoSC8)}) 	//"Proximo"

Endif	

Eval(bPage,1)

If ( ExistBlock("MA160BAR") )
	aButtonUsr := ExecBlock("MA160BAR",.F.,.F.,{nReg,aPlanilha,aAuditoria,aCotacao,aListBox,aCabec,aRefImpos,lTes,aCpoSC8})
	If ( ValType(aButtonUsr) == "A" )
		For nX := 1 To Len(aButtonUsr)
			Aadd(aButtons,aClone(aButtonUsr[nX]))
		Next nX
	EndIf
EndIf

Return(EnchoiceBar(oDlg,bOK,bCancel,,aButtons))   

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ma160Fld  ³Autor  ³Alexandre Inacio Lemes ³ Data ³11/06/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Tratamento dos Folders                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Numero do Folder de Destino                           ³±±
±±³          ³ExpN2: Numero do Folder Atual                                ³±±
±±³          ³ExpO3: Objeto do Folder                                      ³±±
±±³          ³ExpA4: Array contendo todos objetos da analise               ³±±
±±³          ³ExpA5: Array contendo os elementos da listbox do Folder 3    ³±±
±±³          ³ExpA6: Array contendo as posicoes dos Gets do Folder 3       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA160                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ma160Fld(nFldDst,nFldAtu,oFolder,aCabec,aListbox,aPosObj3)

Local aArea		 := GetArea()
Local aUltForn   := {}
Local aViewSB2   := {}
Local bCampo     := { |n| FieldName(n) }
Local cProduto   := ""
Local nPosAtu    := aCabec[02]
Local nX         := 0
Local nR         := 0
Local nSaldo     := 0
Local nDuracao   := 0
Local nTotDisp	 := 0
Local nQtPV		 := 0
Local nQemp		 := 0
Local nSalpedi	 := 0
Local nReserva	 := 0
Local nQempSA	 := 0
Local nQtdTerc	 := 0
Local nQtdNEmTerc:= 0
Local nSldTerc	 := 0                                                       
Local nQEmpN	 := 0
Local nQAClass	 := 0
Local nScan      := 0
Local nSaldoSB2  := 0
Local lSigaCus   := .T.

DEFAULT aCabec[11]:CARGO := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
   //	Aviso(STR0027,STR0029,{STR0028}) //"Atualizar patch do programa SIGACUS.PRW !!!"
	lSigaCus := .F.
EndIf
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
  //	Aviso(STR0027,STR0030,{STR0028}) //"Atualizar patch do programa SIGACUSA.PRW !!!"
	lSigaCus := .F.
EndIf
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
  //	Aviso(STR0027,STR0031,{STR0028}) //"Atualizar patch do programa SIGACUSB.PRW !!!"
	lSigaCus := .F.
EndIf

If lSigaCus
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua a atualizacao dos dados na Troca dos Folders                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( nFldDst <> nFldAtu )

		aCabec[07]:oBrowse:lDisablePaint := .T.
		aCabec[08]:oBrowse:lDisablePaint := .T.
		aCabec[09]:lDisablePaint := .T.
		aCabec[11]:lDisablePaint := .T.
		
		Do Case
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder 1 - Planilha Analisar - Efetua a atualizacao dos dados do Folder³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case ( nFldDst == 1 )
				
				aCabec[07]:oBrowse:lDisablePaint := .F.
				aCabec[07]:oBrowse:Reset()
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder 2 - Auditoria - Efetua a atualizacao dos dados do Folder        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case ( nFldDst == 2 )
				
				aCabec[08]:oBrowse:lDisablePaint := .F.
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder 3 - Fornecedor - Efetua a atualizacao dos dados do Folder       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case ( nFldDst == 3 )
				
				aCabec[09]:lDisablePaint := .F.
				dbSelectArea("SA2")
				dbSetOrder(1)
				MsSeek(xFilial("SA2")+(aCabec[01])->PLN_FORNECE+(aCabec[01])->PLN_LOJA)
				If ( M->A2_COD <> (aCabec[01])->PLN_FORNECE .Or.;
					M->A2_LOJA <> (aCabec[01])->PLN_LOJA )
					For nX := 1 To FCount()
						M->&(EVAL(bCampo,nX)) := FieldGet(nX)
					Next nX
					aCabec[10]:EnchRefreshAll()
				EndIf
				aCabec[03,14,2]:= SA2->A2_SALDUP
				aCabec[03,15,2]:= SA2->A2_MCOMPRA
				aCabec[03,16,2]:= SA2->A2_MNOTA
				aCabec[03,17,2]:= SA2->A2_MSALDO
				aCabec[03,18,2]:= SA2->A2_SALDUPM
				aCabec[03,19,2]:= SA2->A2_MATR
				
				aCabec[09]:SetArray(aListBox[nPosAtu][(aCabec[01])->(RecNo())])
				aCabec[09]:bLine := {|| aCabec[09]:aArray[aCabec[09]:nAT]}
				aCabec[09]:Refresh()
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder 4 - Historico do Produto e Estoques - Atualiza os Dados         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case ( nFldDst == 4 )
				
				aCabec[11]:lDisablePaint := .F.
				If aCabec[11]:CARGO <> aCabec[03,2,2]
					
					nScan := aScan( aCotaGrade, { |x| x[5] == aCabec[3,2,2] } )
					
					For nX := 1 to IIF( Len(aCotaGrade[nScan,6]) > 0 , Len(aCotagrade[nScan,6]) , 1 )

						If Len(aCotaGrade[nScan,6]) > 0
							cProduto := aCotagrade[nScan,6,nX,1]
						Else
							cProduto := aCabec[03,2,2]                                              
						EndIf
						
						dbSelectArea("SB2")
						dbSetOrder(1)
						MsSeek(xFilial("SB2")+cProduto)
						While !Eof() .And. xFilial("SB2")+cProduto == SB2->B2_FILIAL+SB2->B2_COD
							If !(SB2->B2_STATUS == '2')
								
								If SB2->B2_LOCAL < MV_PAR15 .Or. SB2->B2_LOCAL > MV_PAR16
									dbSkip()
									Loop
								EndIf
								
								nSaldoSB2:=SaldoSB2(,,,,,"SB2")
								
								aAdd(aViewSB2,{TransForm(SB2->B2_LOCAL,PesqPict("SB2","B2_LOCAL")),;
								TransForm(SB2->B2_COD,PesqPict("SB2","B2_COD")),;
								TransForm(nSaldoSB2,PesqPict("SB2","B2_QATU")),;
								TransForm(SB2->B2_QATU,PesqPict("SB2","B2_QATU")),;
								TransForm(SB2->B2_QPEDVEN,PesqPict("SB2","B2_QPEDVEN")),;
								TransForm(SB2->B2_QEMP,PesqPict("SB2","B2_QEMP")),;
								TransForm(SB2->B2_SALPEDI,PesqPict("SB2","B2_SALPEDI")),;
								TransForm(SB2->B2_QEMPSA,PesqPict("SB2","B2_QEMPSA")),;
								TransForm(SB2->B2_RESERVA,PesqPict("SB2","B2_RESERVA")),;
								TransForm(SB2->B2_QTNP,PesqPict("SB2","B2_QTNP")),;
								TransForm(SB2->B2_QNPT,PesqPict("SB2","B2_QNPT")),;
								TransForm(SB2->B2_QTER,PesqPict("SB2","B2_QTER")),;
								TransForm(SB2->B2_QEMPN,PesqPict("SB2","B2_QEMPN")),;
								TransForm(SB2->B2_QACLASS,PesqPict("SB2","B2_QACLASS"))})
								
								nTotDisp	+= nSaldoSB2
								nSaldo		+= SB2->B2_QATU
								nQtPV		+= SB2->B2_QPEDVEN
								nQemp		+= SB2->B2_QEMP
								nSalpedi	+= SB2->B2_SALPEDI
								nReserva	+= SB2->B2_RESERVA
								nQempSA		+= SB2->B2_QEMPSA
								nQtdTerc	+= SB2->B2_QTNP
								nQtdNEmTerc	+= SB2->B2_QNPT
								nSldTerc	+= SB2->B2_QTER
								nQEmpN		+= SB2->B2_QEMPN
								nQAClass	+= SB2->B2_QACLASS
								
							EndIf
							dbSelectArea("SB2")
							dbSkip()
						EndDo
						
					Next nX

					aCabec[12]:SetArray(aViewSB2)
					aCabec[12]:bLine := {|| aCabec[12]:aArray[aCabec[12]:nAt] }
					aCabec[12]:Refresh()
					
					aCabec[03,20,2] := nTotDisp
					aCabec[03,21,2] := nQemp
					aCabec[03,22,2] := nSaldo
					aCabec[03,23,2] := nSalPedi           
					aCabec[03,24,2] := nQtPv
					aCabec[03,25,2] := nReserva
					aCabec[03,26,2] := nQEmpSA
					aCabec[03,27,2] := nQtdTerc
					aCabec[03,28,2] := nQtdNEmTerc
					aCabec[03,29,2] := nSldTerc
					aCabec[03,30,2] := nQEmpN
					aCabec[03,31,2] := nQAClass

				   	U_A160UltFor(aCabec[12]:aArray[aCabec[12]:nAt,2],aCabec)
					
				EndIf
				
		EndCase
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua Refresh nos Objetos da Getdados da Auditoria e Todos SayGets    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCabec[08]:oBrowse:Refresh()
	
	For nR :=14 to Len(aCabec[03])
		aCabec[03,nR,1]:Refresh()
	Next nR
	
EndIf

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma160Page ³ Autor ³ Eduardo Riera         ³ Data ³10.08.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1:                                                     ³±±
±±³          ³ ExpB2:                                                     ³±±
±±³          ³ ExpB3:                                                     ³±±
±±³          ³ ExpN4:                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ma160Page(nSoma,aCabec,aPlanilha,aAuditoria,aCotacao,oScroll,lProceCot,aCpoSC8,oDlg,aPosGet)

Local aArea   	  := GetArea()
Local cCodPro     := ""
Local cDescPro    := ""
Local cAlias      := aCabec[01]
Local nPosAtu     := If(!l160Auto,aCabec[02],nSoma)
Local nPosAnt     := nPosAtu
Local nPNumSC     := aScan(aCotacao[1][1],{|x| Trim(x[1])=="C8_NUMSC"})
Local nPItemSC    := aScan(aCotacao[1][1],{|x| Trim(x[1])=="C8_ITEMSC"})
Local nPItemGrd   := aScan(aCotacao[1][1],{|x| Trim(x[1])=="C8_ITEMGRD"})
Local nPQtdSC8    := aScan(aCotacao[1][1],{|x| Trim(x[1])=="C8_QUANT"})
Local nPGrdSC8    := aScan(aCotacao[1][1],{|x| Trim(x[1])=="C8_GRADE"})
Local nPQtdSCE    := aScan(aCabec[05],{|x| Trim(x[2])=="CE_QUANT"})
Local nPProd      := aScan(aCotacao[1][1],{|x| Trim(x[1])=="C8_PRODUTO"})
Local nSaldo      := 0
Local nX		  := 0
Local nY	  	  := 0
Local lValido     := .T.
Local lReferencia := Nil
Local lVldQuant   := GetNewPar("MV_DIFQTDC","N") == "N" .And. If(Type('lIsACC')#"L",.T.,!lIsACC)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a validacao do Saldo a Distribuir da pagina atual do Folder    ³
//³ Auditoria. O Par.MV_DIFQTDC usado para permitir que a analise gere PCs ³
//³ mesmo que exista saldo a distribuir so tera efeito com produtos que nao³
//³ usem grade de produto, caso contrario so proseguira a analise quando   ³
//³ nao existir mais saldo a distribuir para os produtos de grade.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nPosAnt <> 0 )
	For nX := 1 To Len(aCols)
		nSaldo += aCols[nX][nPQtdSCE]
	Next nX
	If lVldQuant .Or. aCotacao[nPosAnt][1][nPGrdSC8][2] == "S"
		If ( nSaldo <> aCotacao[nPosAnt][1][nPQtdSC8][2] .And. nSaldo > 0 )
			lValido := .F.	
		EndIf
	Else
		If ( nSaldo > aCotacao[nPosAnt][1][nPQtdSC8][2] .And. nSaldo > 0 )
  			lValido := .F.	
		EndIf
	Endif	
	nSaldo := 0
EndIf

If lValido 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta a nova posicao atual                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	If !l160Auto
		nPosAtu += nSoma
	Else
		nPosAtu := nSoma
	EndIf
	nPosAtu := Min(nPosAtu,Len(aPlanilha))
	nPosAtu := Max(1,nPosAtu)
	aCabec[02] := nPosAtu	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o saldo restante a ser selecionado                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSaldo := 0
	For nX := 1 To Len(aAuditoria[nPosAtu])
		nSaldo += aAuditoria[nPosAtu][nX][nPQtdSCE]
	Next nX

	nSaldo := aCotacao[nPosAtu][1][nPQtdSC8][2] - nSaldo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa o arquivo temporario                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAlias)
	ZAP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza os dados da Planilha de cotacao                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aPlanilha[nPosAtu])
		RecLock(cAlias,.T.)
		For nY := 1 To FCount()
			FieldPut(nY,aPlanilha[nPosAtu][nX][nY])
		Next nY
		MsUnLock()
	Next nX         
	If !l160Auto
		aCabec[07]:oBrowse:GoTop()
		aCabec[07]:oBrowse:Refresh()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza os dados da Planilha de auditoria                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	N := 1
	If ( nPosAnt <> 0 )
		If !l160Auto
			aCabec[08]:oBrowse:lDisablePaint := .T.
		EndIf
		aAuditoria[nPosAnt] := aClone(aCols)
		aCols := aClone(aAuditoria[nPosAtu])
		If !l160Auto
			aCabec[08]:oBrowse:lDisablePaint := .F.
			aCabec[08]:oBrowse:Refresh()
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza os dados do cabecalho da analise da cotacao                   ³
	//| Caso não existir a SC1, busca a descrição da SB1 ou SB5                |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC1")
	dbSetOrder(1)
	If MsSeek(xFilial("SC1")+aCotacao[nPosAtu][1][nPNumSC][2]+aCotacao[nPosAtu][1][nPItemSC][2])
		cCodPro  := SC1->C1_PRODUTO
		cDescPro := SC1->C1_DESCRI
	Else
		cCodPro  := aCotacao[nPosAtu][1][nPProd][2]
		dbSelectArea("SB1")
		dbSetOrder(1)
		If MsSeek(xFilial("SB1")+cCodPro)    
			cDescPro := SB1->B1_DESC
			dbSelectArea("SB5")
			dbSetOrder(1)
			If MsSeek(xFilial("SB5")+cCodPro) 
				cDescPro := SB5->B5_CEME
			EndIf
		EndIf
	EndIf

	If lGrade .And. !Empty(aCotacao[nPosAtu][1][nPItemGrd][2])
		If (lReferencia := MatGrdPrRf(@cCodPro,.T.))
			cCodPro  := RetCodProdFam(SC1->C1_PRODUTO)
			cDescPro := DescPrRF(cCodPro)
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atribuido o codigo do produto a variavel PUBLICA VAR_IXB para uso em ponto de entrada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	VAR_IXB :={}
	aAdd(VAR_IXB,{"PRODUTO", cCodPro}) 
	
	If !l160Auto
		aCabec[03,2,2] := cCodPro	//Codigo do Produto
		aCabec[03,2,1] :Refresh()
	
		aCabec[03,3,1]:SetText( Transform( cDescPro, PesqPict("SC8","C8_DESCRI",30) ) )
		oScroll:Reset()
	
		aCabec[03,5,2] := aCotacao[nPosAtu][1][nPQtdSC8][2] //Quantidade
		aCabec[03,5,1] :Refresh()
		If lProceCot
			aCabec[03,6,1] :cCaption := StrZero(nPosAtu,3)+"/"+StrZero(Len(aPlanilha),3) //Ordem
		Else	
			aCabec[03,6,1] :cCaption := StrZero(nPosAtu,3)+"/"+StrZero(Len(aProds),3) //Ordem
		Endif	
		aCabec[03,6,1] :Refresh()
	
		aCabec[03,8,2] := nSaldo //Saldo
		aCabec[03,8,1] :Refresh()
	EndIf
Else
	Help(" ",1,"QTDDIF")
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para atualizar as Gets criadas pelo MT160TEL   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l160Auto .And. ExistBlock("MT160ATU")
	ExecBlock("MT160ATU",.F.,.F.,{@oDlg,aPosGet,Var_Ixb} )
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a Grade para o Produto Analisado.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
A160ColsGrade(aCabec[03,2,2], .T.)

If !l160Auto
	aCabec[08]:oBrowse:refresh()
EndIf

RestArea(aArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ao trocar o produto mantem sempre a MarkBrowse posicionada no   ³
//³no inicio do Arquivo independente do fornecedor selecionado.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
(calias)->(Dbgotop())

Return(.T.) 

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ma160Marca³Autor  ³Eduardo Riera          ³ Data ³09.08.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1:                                                       ³±±
±±³          ³ExpN2:                                                       ³±±
±±³          ³ExpN3:                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGACOM                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ma160Marca(aCabec,aPlanilha,aCotacao,oScroll,aListBox,aCpoSC8)

Local aArea    	 := GetArea()
Local cCodPro  	 := ""
Local cDescPro 	 := ""
Local cAlias   	 := aCabec[01]
Local nPosAtu  	 := aCabec[02]
Local nPCodPro 	 := aScan(aCotacao[nPosAtu][1],{|x| Trim(x[1])=="C8_PRODUTO"})
Local nPQtdSC8 	 := aScan(aCotacao[nPosAtu][1],{|x| Trim(x[1])=="C8_QUANT"  })
Local nPNumSC  	 := aScan(aCotacao[nPosAtu][1],{|x| Trim(x[1])=="C8_NUMSC"  })
Local nPItemSC 	 := aScan(aCotacao[nPosAtu][1],{|x| Trim(x[1])=="C8_ITEMSC" })
Local nPItemGrd	 := aScan(aCotacao[nPosAtu][1],{|x| Trim(x[1])=="C8_ITEMGRD"})
Local nSC8Recno	 := aScan(aCotacao[nPosAtu][1],{|x| Trim(x[1])=="SC8RECNO"  })
Local nPQtdSCE 	 := aScan(aCabec[05],{|x| Trim(x[2])=="CE_QUANT"  })
Local nPFornSCE	 := aScan(aCabec[05],{|x| Trim(x[2])=="CE_FORNECE"})
Local nPLojaSCE	 := aScan(aCabec[05],{|x| Trim(x[2])=="CE_LOJA"   })
Local nPPropSCE	 := aScan(aCabec[05],{|x| Trim(x[2])=="CE_NUMPRO" })
Local nPItemSCE	 := aScan(aCabec[05],{|x| Trim(x[2])=="CE_ITEMCOT"})
Local nPDataSCE	 := aScan(aCabec[05],{|x| Trim(x[2])=="CE_ENTREGA"})
Local nLinha   	 := (cAlias)->(RecNo())
Local nSaldo   	 := 0
Local nX       	 := 0
Local nY       	 := 0
Local nG       	 := 0
Local nScan    	 := 0
Local lRet	   	 := .T.
Local aRet160Mar := {}    
Local aRet160Mrk := {}
Local nPlanOK    := aScan(aCpoSC8,"PLN_OK")
Local nPlanTotal := aScan(aCpoSC8,"PLN_TOTAL")
Local nPlanFlag  := aScan(aCpoSC8,"PLN_FLAG")
Local lMarca     := .T.
Local lMt160P    := .T.
Local cItemPE	 := ""

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula a quantidade selecionada ate o momento                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aCols)
		nSaldo += aCols[nX][nPQtdSCE]
	Next nX

	nSaldo := aCotacao[nPosAtu][1][nPQtdSC8][2] - nSaldo

	If ( nPlanFlag > 0 .And. aPlanilha[nPosAtu][nLinha][nPlanFlag] == 1 )
		nSaldo := 0
	EndIf	
	
	If ( nPlanTotal > 0 .And. aPlanilha[nPosAtu][nLinha][nPlanTotal] == 0 )
		Help(" ",1,"A160ATU")
		nSaldo := 0
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a SC esta vinculada a um Edital              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	If (SC1->C1_QUJE>0 .And. !Empty(SC1->C1_CODED) )
		Aviso("",""+SC1->C1_NUM+""+Alltrim(SC1->C1_CODED)+"",{"Ok"})
		nSaldo := 0
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se um novo fornecedor pode ser escolhido e atualiza os dados  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAlias)->(IsMark("PLN_OK",ThisMark(),ThisInv()))

		If ( nSaldo == 0 )
			RecLock(cAlias)
			(cAlias)->PLN_OK := ""
			MsUnLock()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe algum fornecedor marcado  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aScan(aPlanilha[nPosAtu],{|x| x[nPlanOK] == ThisMark()}) == 0
				lMarca:=.F.
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se vencedor e o Produto for de Grade alimenta a Quantidade do item de Grade com a quantidade do SC8.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nScan := aScan(aCotaGrade, {|z| z[1] + z[2] + z[3] + z[4] == ;
			aCols[nLinha][nPFornSCE] + aCols[nLinha][nPLojaSCE] + aCols[nLinha][nPPropSCE] + aCols[nLinha][nPItemSCE] })
			
			If Len(aCotaGrade[nScan][6]) > 0

				For nG := 1 To Len(aCotaGrade[nScan][6])
					aCotaGrade[nScan][6][nG][2] := aCotaGrade[nScan][6][nG][6]
					aCotaGrade[nScan][6][nG][3] := aCols[nLinha][nPDataSCE]
				Next nG

				aCols[nLinha][nPQtdSCE] := aCotacao[nPosAtu][1][nPQtdSC8][2]

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Apos marcar um Vencedor e preencher os itens da grade com a quantidade original do SC8, esta rotina  ³
				//³zera as quantidades da grade das propostas dos demais fornecedores da cotacao deste produto.         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 To Len(aCotaGrade)
					If Len(aCotaGrade[nX][6]) > 0 .And. nX <> nScan .And. aCotaGrade[nX][4] == aCotaGrade[nScan][4]
						For nY:= 1 to Len(aCotaGrade[nX][6])
							aCotaGrade[nX, 6, nY, 2] := 0
						Next nY
					EndIf
				Next nX
	
				For nX := 1 To Len(aCols)
					If nX <> nLinha
						aCols[nX][nPQtdSCE]:= 0
               		EndIf 
				Next nX
			
   			Else
            	aCols[nLinha][nPQtdSCE] += nSaldo
			EndIf
			
			nSaldo := 0

		EndIf

	Else

		nSaldo += aCols[nLinha][nPQtdSCE]
		aCols[nLinha][nPQtdSCE] := 0
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao for o vencedor e o Produto for de Grade zera a Quantidade do item de Grade.                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nScan := aScan(aCotaGrade, {|z| z[1] + z[2] + z[3] + z[4] == ;
		aCols[nLinha][nPFornSCE] + aCols[nLinha][nPLojaSCE] + aCols[nLinha][nPPropSCE] + aCols[nLinha][nPItemSCE] })
		
		If Len(aCotaGrade[nScan][6]) > 0
			For nG := 1 To Len(aCotaGrade[nScan][6])
				aCotaGrade[nScan][6][nG][2] := 0
			Next nG
		EndIf
		
	EndIf

	If (nPlanOK > 0)
		aPlanilha[nPosAtu][nLinha][nPlanOK] := (cAlias)->PLN_OK
	EndIf
	
	If ExistBlock("M160MARK")
		aRet160Mar := ExecBlock("M160MARK",.F.,.F.,{cAlias,aPlanilha[nPosAtu][nLinha],aCotacao[nPosAtu][nLinha],aListBox,aCabec[06]})
		If ValType( aRet160Mar ) == "A" 
			aPlanilha[nPosAtu][nLinha] := aRet160Mar[1]
			aCotacao[nPosAtu][nLinha]  := aRet160Mar[2]
			aListBox := aRet160Mar[3]
        EndIf
        aCabec[07]:oBrowse:Refresh()
        aCabec[09]:Refresh()
	EndIf			
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para customizar os arrays utilizados na marcacao do fornecedor vencedor       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	      
	If ExistBlock("M160MRK1")
		aRet160Mrk := ExecBlock("M160MRK1",.F.,.F.,{cAlias,aPlanilha,aCotacao,aListBox,aCabec})
		If ValType( aRet160Mrk ) == "A" 
			aPlanilha := aClone(aRet160Mrk[1])
			aCotacao  := aClone(aRet160Mrk[2])
			aListBox  := aClone(aRet160Mrk[3])
        EndIf           
        aCabec[07]:oBrowse:Refresh()
        aCabec[09]:Refresh()
	EndIf  
				
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza os dados do cabecalho da analise da cotacao                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC1")
	dbSetOrder(1)
	MsSeek(xFilial("SC1")+aCotacao[nPosAtu][1][nPNumSC][2]+aCotacao[nPosAtu][1][nPItemSC][2])
	
	cCodPro  := SC1->C1_PRODUTO
	cDescPro := SC1->C1_DESCRI
	
	If lGrade .And. !Empty(aCotacao[nPosAtu][1][nPItemGrd][2])
		If (lReferencia := MatGrdPrRf(@cCodPro,.T.))
			cCodPro  := RetCodProdFam(SC1->C1_PRODUTO)
			cDescPro := DescPrRF(cCodPro)
		Endif
	Endif

	aCabec[03,2,2] := cCodPro	//Codigo do Produto
	aCabec[03,2,1] :Refresh()
	
	aCabec[03,3,1]:SetText( Transform( cDescPro, PesqPict("SC8","C8_DESCRI",30) ) ) //Descricao do Produto
	oScroll:Reset()
	
	aCabec[03,5,2] := aCotacao[nPosAtu][1][nPQtdSC8][2] //Quantidade
	aCabec[03,5,1] :Refresh()
	
	aCabec[03,6,1] :cCaption := StrZero(nPosAtu,3)+"/"+StrZero(Len(aPlanilha),3) //Ordem
	aCabec[03,6,1] :Refresh()
	
	aCabec[03,8,2] := nSaldo //Saldo
	aCabec[03,8,1] :Refresh()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a Grade para o Produto Analisado.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A160ColsGrade(aCabec[03,2,2], .T.)
	
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Ponto de entrada para ser utilizado antes da validação do SIGAPCO |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT160PCOK")
	If ValType(aCols)=="A"
		If Len(aCols[1]) >= 9
			cItemPe := aCols[1][9]	// C8_ITEM
		EndIf
	EndIf
	lMt160P := ExecBlock("MT160PCOK",.F.,.F.,{aPlanilha,cItemPE})
	If Valtype(lMt160P) <> "L"
		lMt160P:=.T.
	EndIf
EndIf

If !lMarca
	Aviso("Este fornecedor não pode ser selecionado, pois não atende aos critérios de avaliação solicitados através dos parâmetros da rotina (F12).",;
	"Este fornecedor não pode ser selecionado, pois não atende aos critérios de avaliação solicitados através dos parâmetros da rotina (F12).",{""})
Else
	If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"
		//Variaveis para analise de orcamento
		SC8->(MsGoTo(aCotacao[nPosAtu][nLinha][nSC8Recno][2]))
		SC1->(DbSetOrder(1))
		SC1->(MsSeek(xFilial("SC1")+aCotacao[nPosAtu][nLinha][nPNumSC][2]+aCotacao[nPosAtu][nLinha][nPItemSC][2]))
		
		If !PcoVldLan('000052','02',,,Empty((cAlias)->PLN_OK)) .And. lMt160P 
			//Forca a liberacao de todos os lancamentos de bloqueio, pois cada item é uma liberacao exclusiva
			PcoFreeBlq('000052')
			RecLock(cAlias)
				(cAlias)->PLN_OK := ""
			(cAlias)->(MsUnLock())
			
			//Atualizo a planilha para que, caso tenha havido bloqueio, a planilha não contenha os registros marcados
			//Isso evitará que ao ser pressionado o botão "Próximo" a MarkBrowse seja "ticada" incorretamente
			If ValType(nPlanOk) == "N" .And. nPlanOk > 0
				aPlanilha[nPosAtu][nLinha][nPlanOK] := (cAlias)->PLN_OK							
			EndIf
		Endif
		
		If !(cAlias)->(IsMark("PLN_OK",ThisMark(),ThisInv()))
			nSaldo += aCols[nLinha][nPQtdSCE]
			aCols[nLinha][nPQtdSCE] := 0
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao for o vencedor e o Produto for de Grade zera a Quantidade do item de Grade.                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nScan := aScan(aCotaGrade, {|z| z[1] + z[2] + z[3] + z[4] == ;
			aCols[nLinha][nPFornSCE] + aCols[nLinha][nPLojaSCE] + aCols[nLinha][nPPropSCE] + aCols[nLinha][nPItemSCE] })
			
			If Len(aCotaGrade[nScan][6]) > 0
				For nG := 1 To Len(aCotaGrade[nScan][6])
					aCotaGrade[nScan][6][nG][2] := 0
				Next nG
			EndIf		
		EndIf

		aCabec[03,2,2] := cCodPro	//Codigo do Produto
		aCabec[03,2,1] :Refresh()
		
		aCabec[03,3,1]:SetText( Transform( cDescPro, PesqPict("SC8","C8_DESCRI",30) ) ) //Descricao do Produto
		oScroll:Reset()
		
		aCabec[03,5,2] := aCotacao[nPosAtu][1][nPQtdSC8][2] //Quantidade
		aCabec[03,5,1] :Refresh()
		
		aCabec[03,6,1] :cCaption := StrZero(nPosAtu,3)+"/"+StrZero(Len(aPlanilha),3) //Ordem
		aCabec[03,6,1] :Refresh()
		
		aCabec[03,8,2] := nSaldo //Saldo
		aCabec[03,8,1] :Refresh()
		
	Endif
EndIf

RestArea(aArea)

Return(.T.) 

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A160UltFor³ Autor ³Alexandre Inacio Lemes ³ Data ³30/05/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Busca os 4 ultimos Fornecimentos do produto informado e      ³±±
±±³          ³atualiza o LixtBox do Folder 4 - Historico do Produto        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Produto a ser pesquisado                              ³±±
±±³          ³ExpA1: Array contendo todos os Objetos da Analise            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function A160UltFor(cProduto,aCabec)

If cProduto == Nil
   cProduto := ""
EndIf   
   
aUltForn := MaUltForn(cProduto)
aCabec[11]:CARGO := cProduto
aCabec[11]:SetArray(aUltForn)
aCabec[11]:bLine := {|| aCabec[11]:aArray[aCabec[11]:nAt] }
aCabec[11]:Refresh()

Return(.T.)



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaUltForn ³ Autor ³ Eduardo Riera         ³ Data ³27.07.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Avalia os ultimos fornecimentos de materiais ( entrada )     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpA1 := MaUltForn(ExpC1,ExpA2,ExpA3,ExpN1,ExpL1)			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Produto                                     ³±±
±±³          ³ExpA2: Array de retorno dos titulos dos campos definidos em  ³±±
±±³          ³       ExpA3.                                                ³±±
±±³          ³ExpA3: Array com a estrutura dos campos a serem retornados   ³±±
±±³          ³       [1] Nome do Campo                                     ³±±
±±³          ³       [2] Tipo do campo                                     ³±±
±±³          ³       [3] Tamanho do campo                                  ³±±
±±³          ³       [4] Numero de decimais do campo                       ³±±
±±³          ³       * Somente do SD1                                      ³±±
±±³          ³ExpN1: Quantidade de ultimos fornecimentos (Default 4)       ³±±
±±³          ³ExpL1: Efetua a conversao para a picture contida no diciona- ³±±
±±³          ³       rio de dados.                                         ³±±
±±³          ³       * DEFAULT .T.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array contendo os ultimos fornecimentos com os campos ³±±
±±³          ³       solicitados no parametro ExpA2.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo avaliar as ultimas <ExpN1>     ³±±
±±³          ³entregas do produto <ExpC1> retornando os campos ExpA3.      ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MaUltForn(cProduto,aTitles,aCampos,nQtUltFor,lPicture)

Local aArea    := GetArea()
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSX3 := SX3->(GetArea())
Local aUltFor  := {}
Local cAliasSD1:= ""
Local nX       := 0
Local nY	      := 0                        
#IFDEF TOP
	Local cQuery := ""
#ENDIF
DEFAULT aTitles     := {}
DEFAULT aCampos 	:= {}
DEFAULT nQtUltFor	:= 4
DEFAULT lPicture    := .T.
cAliasSD1:= "SD1"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a estrutura default da rotina                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( Empty(aCampos) )
	dbSelectArea("SX3")
	dbSetOrder(2)
	MsSeek("D1_EMISSAO")
	aadd(aCampos,{Trim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	MsSeek("D1_QUANT")
	aadd(aCampos,{Trim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	MsSeek("D1_VUNIT")
	aadd(aCampos,{Trim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	MsSeek("D1_TOTAL")
	aadd(aCampos,{Trim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	If cPaisLoc == "BRA"
		MsSeek("D1_VALIPI")
		aadd(aCampos,{Trim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	Endif
	MsSeek("D1_CUSTO")
	aadd(aCampos,{Trim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	MsSeek("D1_FORNECE")
	aadd(aCampos,{Trim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	MsSeek("D1_LOJA")
	aadd(aCampos,{Trim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSelectArea("SX3")
	dbSetOrder(1)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Avalia os ultimos fornecimentos do material                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	If ( TcSrvType()<>"AS/400" )
		cAliasSD1 := "MAULTFOR"
		For nX := 1 To Len(aCampos)
			cQuery += ","+aCampos[nX][1]
		Next nX
		cQuery := "SELECT "+SubStr(cQuery,2)+" "
		cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
		cQuery += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
		cQuery += "SD1.D1_COD='"+cProduto+"' AND "
		cQuery += "SD1.D1_TIPO='N' AND "
		cQuery += "SD1.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY SD1.R_E_C_N_O_ DESC "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
		For nX := 1 To Len(aCampos)
			If ( aCampos[nX][2]<>"C" )
				TcSetField(cAliasSD1,aCampos[nX,1],aCampos[nX,2],aCampos[nX,3],aCampos[nX,4])
			EndIf
		Next nX

		SX3->(dbSetOrder(2))
		SX3->(MsSeek("A2_NOME"))
		aadd(aCampos,{Trim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		SX3->(dbSetOrder(1))
		
		While ( !Eof() )
			aadd(aUltFor,Array(Len(aCampos)))
			nY++
			For nX := 1 To Len(aCampos)
				aUltFor[nY][nX] := FieldGet(FieldPos(aCampos[nX][1]))
				aUltFor[nY][Len(aCampos)] := IIF(SA2->(MsSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)),SA2->A2_NOME,"")
			Next nX
			If ( Len(aUltFor)>=nQtUltFor )
				Exit
			EndIf			
			dbSelectArea(cAliasSD1)
			dbSkip()
		EndDo	
		dbSelectArea(cAliasSD1)
		dbCloseArea()
		dbSelectArea("SD1")
	Else
#ENDIF
	SX3->(dbSetOrder(2))
	SX3->(MsSeek("A2_NOME"))
	aadd(aCampos,{Trim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	SX3->(dbSetOrder(1))
	
	dbSelectArea("SD1")
	dbSetOrder(5)
	MsSeek(xFilial("SD1")+cProduto,.T.)
	While ( !Eof() .And. SD1->D1_FILIAL == xFilial("SD1") .And.;
			SD1->D1_COD == cProduto )			
		If ( SD1->D1_TIPO == "N" )
			If ( Len(aUltFor)<nQtUltFor )
				aadd(aUltFor,Array(Len(aCampos)))
				nY++
			Else
				For nY := 1 To nQtUltFor-1
					aUltFor[nY] := aClone(aUltFor[nY+1])
				Next nY
				nY := nQtUltFor
			EndIf
			For nX := 1 To Len(aCampos)
				aUltFor[nY][nX] := FieldGet(FieldPos(aCampos[nX][1]))
				aUltFor[nY][Len(aCampos)] := IIF(SA2->(MsSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)),SA2->A2_NOME,"")
			Next nX
		EndIf
		dbSelectArea("SD1")
		dbSkip()			
	EndDo
	#IFDEF TOP
	EndIf
	#ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem os titulos com base no dicionario de dados             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lPicture )
	If ( Len(aUltFor) == 0 )
		aadd(aUltFor,{})
		For nX := 1 To Len(aCampos)
			aadd(aUltFor[1],"")
		Next nX
	EndIf
	dbSelectArea("SX3")
	dbSetOrder(2)
	For nX := 1 To Len(aCampos)
		MsSeek(Trim(aCampos[nX][1]))
		aadd(aTitles,X3Titulo())
		For nY := 1 To Len(aUltFor)
			aUltFor[nY][nX] := TransForm(aUltFor[nY][nX],SX3->X3_PICTURE)
		Next nY
	Next nX
EndIf
RestArea(aAreaSX3)
RestArea(aAreaSD1)
RestArea(aArea)
Return(aUltFor) 

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A160FeOdlg³Autor  ³Nereu Humberto Junior  ³ Data ³18/09/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina verifica se todos os itens foram analisados quan-³±±
±±³          ³do a analise for produto a produto.                          ³±±
±±³          ³Verifica se todos os itens foram analisados - Cot. p/ Produto³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function A160FeOdlg(lProceCot,nOpcA,l160Visual,aCabec,aCotacao,aAuditoria)

Local nPosAtu := aCabec[02]
Local nPQtdSC8:= aScan(aCotacao[1][1],{|x| Trim(x[1])=="C8_QUANT"})
Local nPGrdSC8:= aScan(aCotacao[1][1],{|x| Trim(x[1])=="C8_GRADE"})
Local nPProSCE:= aScan(aCabec[05],{|x| Trim(x[2])=="CE_NUMPRO"})
Local nPForSCE:= aScan(aCabec[05],{|x| Trim(x[2])=="CE_FORNECE"})
Local nPLojSCE:= aScan(aCabec[05],{|x| Trim(x[2])=="CE_LOJA"})
Local nPQtdSCE:= aScan(aCabec[05],{|x| Trim(x[2])=="CE_QUANT"})
Local nPMotSCE:= aScan(aCabec[05],{|x| Trim(x[2])=="CE_MOTIVO"})
Local nSaldo  := 0
Local nX      := 0
Local nY      := 0
Local lRet    := .T. 
Local lVldQtd := GetNewPar("MV_DIFQTDC","N") == "N" .And. If(Type('lIsACC')#"L",.T.,!lIsACC)

If !l160Visual .And. !lProceCot
	If nOpcA == 1 
		For nX:= 1 To Len(aProds)
			If Empty(aProds[nx][3])
				nOpcA:= 0
				lRet := .F.
				Aviso("A cotacao so podera ser confirmada quando todos os itens forem analisados !","A cotacao so podera ser confirmada quando todos os itens forem analisados !",;
				{"A cotacao so podera ser confirmada quando todos os itens forem analisados !"}) //"A cotacao so podera ser confirmada quando todos os itens forem analisados !"
				Exit
			Endif
		Next
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a validacao do Saldo a Distribuir da pagina atual do Folder    ³
//³ Auditoria. O Par.MV_DIFQTDC usado para permitir que a analise gere PCs ³
//³ mesmo que exista saldo a distribuir so tera efeito com produtos que nao³
//³ usem grade de produto, caso contrario so proseguira a analise quando   ³
//³ nao existir mais saldo a distribuir para os produtos de grade.         ³
//³ Obs:O Help e exibido previamente na Funcao Ma160Page pelo codeBlock    ³
//³ a validacao aqui impede que o usuario prosiga caso confirme a Analise. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l160Visual .And. nPosAtu <> 0 
	For nX := 1 To Len(aCols)
		nSaldo += aCols[nX][nPQtdSCE]
	Next nX
	If lVldQtd .Or. aCotacao[nPosAtu][1][nPGrdSC8][2] == "S"
		If ( nSaldo <> aCotacao[nPosAtu][1][nPQtdSC8][2] .And. nSaldo > 0 )
			nOpcA:= 0
			lRet := .F.
		EndIf
	Else
		If ( nSaldo > aCotacao[nPosAtu][1][nPQtdSC8][2] .And. nSaldo > 0 )
			nOpcA:= 0
			lRet := .F.
		EndIf
	Endif	
EndIf  

If GetNewPar("MV_MOTIVOK",.F.) .And. !l160Visual .And. lRet // "Tratamento para obrigatoriedade do preenchimento do Campo MOTIVO do Folder Auditoria da proposta "
    For nX :=1 To Len(aAuditoria)
    	For nY := 1 To Len(aAuditoria[nX])
    	    If aAuditoria[nX][nY][nPQtdSCE] > 0 .And. Empty(aAuditoria[nX][nY][nPMotSCE])			
			   //	Aviso("A160MOTIVO", STR0075 + aAuditoria[nX][nY][nPProSCE] + " " + STR0076 + aAuditoria[nX][nY][nPForSCE]+" "+aAuditoria[nX][nY][nPLojSCE],{STR0028})     
				nOpcA:= 0
		 			lRet := .F.
				Exit
            EndIf
        Next nY
        If !lRet
           Exit
        EndIf                     
    Next nX
EndIf

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A160Audit ³Autor  ³Alexandre Inacio Lemes³Data  ³04/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ A funcao e utilizada para recompor o array aAuditoria de   ³±±
±±³          ³ forma compativel a gravacao da funcao MaAvalCot da Comxfun.³±±
±±³          ³ Na analise o Array sofreu aglutinacao para uso do recurso  ³±±
±±³          ³ de grade de produtos.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1: Array com todos os elementos da Analise             ³±±
±±³          ³ ExpA2: Array contendo dados da auditoria usada na Analise  ³±±
±±³          ³ ExpA3: Array contendo todos os itens da cotacao original   ³±±
±±³          ³ ExpA4: Array contendo todos elementos da Grade calculada.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1: Array aAudtoria compativel a gravacao da MaAvalCot  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function A160Audit(aCabec,aAuditoria,aSC8,aCotagrade)

Local aNewAudit := {}
Local nPosRecn  := aScan(aSC8[1][1],{|x| Trim(x[1])=="SC8RECNO"})
Local nPosProp  := aScan(aSC8[1][1],{|x| Trim(x[1])=="C8_NUMPRO"})
Local nPosForn  := aScan(aSC8[1][1],{|x| Trim(x[1])=="C8_FORNECE"})
Local nPosLoja  := aScan(aSC8[1][1],{|x| Trim(x[1])=="C8_LOJA"})
Local nPosItCt  := aScan(aSC8[1][1],{|x| Trim(x[1])=="C8_ITEM"}) 
Local nPosProd  := aScan(aSC8[1][1],{|x| Trim(x[1])=="C8_PRODUTO"}) 
Local nPosNCot  := aScan(aSC8[1][1],{|x| Trim(x[1])=="C8_NUM"}) 
Local nPosIGrd  := aScan(aSC8[1][1],{|x| Trim(x[1])=="C8_ITEMGRD"}) 
Local nPPropSCE := aScan(aCabec[05],{|x| Trim(x[2])=="CE_NUMPRO"}) 
Local nPFornSCE := aScan(aCabec[05],{|x| Trim(x[2])=="CE_FORNECE"}) 
Local nPLojaSCE := aScan(aCabec[05],{|x| Trim(x[2])=="CE_LOJA"})  
Local nPICotSCE := aScan(aCabec[05],{|x| Trim(x[2])=="CE_ITEMCOT"}) 
Local nPQtdeSCE := aScan(aCabec[05],{|x| Trim(x[2])=="CE_QUANT"}) 
Local nPMotiSCE := aScan(aCabec[05],{|x| Trim(x[2])=="CE_MOTIVO"}) 
Local nPEntrSCE := aScan(aCabec[05],{|x| Trim(x[2])=="CE_ENTREGA"}) 

Local nProdGrd  := 0
Local nScan     := 0
Local nA        := 0
Local nG        := 0
Local nX		:= 0
Local nY 		:= 0
Local nZ        := 0

For nX := 1 to Len(aSC8)
	
	aadd(aNewAudit,{})
	
	For nY := 1 to Len(aSC8[nX])
		
		aadd(aNewAudit[nX],Array(Len(aCabec[05])+1))
		
		For nZ := 1 To Len(aCabec[05])
			
			Do Case
				
				Case IsHeadRec(aCabec[05][nZ][2])
					aNewAudit[nX][Len(aNewAudit[nX])][nZ] := aSC8[nX][nY][nPosRecn][2]
				Case IsHeadAlias(aCabec[05][nZ][2])
					aNewAudit[nX][Len(aNewAudit[nX])][nZ] := "SC8"
				Case aCabec[05][nZ][2]=="CE_NUMPRO"
					aNewAudit[nX][Len(aNewAudit[nX])][nZ] := aSC8[nX][nY][nPosProp][2]
				Case aCabec[05][nZ][2]=="CE_FORNECE"
					aNewAudit[nX][Len(aNewAudit[nX])][nZ] := aSC8[nX][nY][nPosForn][2]
				Case aCabec[05][nZ][2]=="CE_LOJA"
					aNewAudit[nX][Len(aNewAudit[nX])][nZ] := aSC8[nX][nY][nPosLoja][2]
				Case  aCabec[05][nZ][2]=="CE_ITEMCOT"
					aNewAudit[nX][Len(aNewAudit[nX])][nZ] := aSC8[nX][nY][nPosItCt][2]
				Case  aCabec[05][nZ][2]=="CE_NUMCOT"
					aNewAudit[nX][Len(aNewAudit[nX])][nZ] := aSC8[nX][nY][nPosNCot][2]
				Case  aCabec[05][nZ][2]=="CE_ITEMGRD"
					aNewAudit[nX][Len(aNewAudit[nX])][nZ] := aSC8[nX][nY][nPosIGrd][2]
				Case  aCabec[05][nZ][2]=="CE_QUANT"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Em caso de produto de grade obtem a quantidade do item do Array aCotaGrade,se nao,obtem do aAuditoria³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nScan := aScan(aCotaGrade, {|z| z[1] + z[2] + z[3] + z[4] == ;
					aSC8[nX][nY][nPosForn][2] + aSC8[nX][nY][nPosLoja][2] + aSC8[nX][nY][nPosProp][2] + aSC8[nX][nY][nPosItCt][2] })
					If Len(aCotaGrade[nScan][6]) > 0
						nProdGrd := aScan(aCotaGrade[nScan][6], {|z| z[1] == aSC8[nX][nY][nPosProd][2]})
						aNewAudit[nX][Len(aNewAudit[nX])][nZ] := aCotaGrade[nScan][6][nProdGrd][2]
					Else
						For nA := 1 To Len(aAuditoria)
							nScan := aScan(aAuditoria[nA], {|z| z[nPPropSCE] + z[nPFornSCE] + z[nPLojaSCE] + z[nPICotSCE] == ;
							aSC8[nX][nY][nPosProp][2] + aSC8[nX][nY][nPosForn][2] + aSC8[nX][nY][nPosLoja][2] + aSC8[nX][nY][nPosItCt][2] })
							If nScan > 0
								Exit
							EndIf
						Next nA
						aNewAudit[nX][Len(aNewAudit[nX])][nZ] := aAuditoria[nA][nScan][nPQtdeSCE]
					EndIf
				Case  aCabec[05][nZ][2]=="CE_ENTREGA"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Em caso de produto de grade obtem a data Entrega do Array aCotaGrade,se nao,obtem do aAuditoria      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nScan := aScan(aCotaGrade, {|z| z[1] + z[2] + z[3] + z[4] == ;
					aSC8[nX][nY][nPosForn][2] + aSC8[nX][nY][nPosLoja][2] + aSC8[nX][nY][nPosProp][2] + aSC8[nX][nY][nPosItCt][2]})
					If Len(aCotaGrade[nScan][6]) > 0
						nProdGrd := aScan(aCotaGrade[nScan][6], {|z| z[1] == aSC8[nX][nY][nPosProd][2]})
						aNewAudit[nX][Len(aNewAudit[nX])][nZ] := aCotaGrade[nScan][6][nProdGrd][3]
					Else
						For nA := 1 To Len(aAuditoria)
							nScan := aScan(aAuditoria[nA], {|z| z[nPPropSCE] + z[nPFornSCE] + z[nPLojaSCE] + z[nPICotSCE] == ;
							aSC8[nX][nY][nPosProp][2] + aSC8[nX][nY][nPosForn][2] + aSC8[nX][nY][nPosLoja][2] + aSC8[nX][nY][nPosItCt][2] })
							If nScan > 0
								Exit
							EndIf
						Next nA
						aNewAudit[nX][Len(aNewAudit[nX])][nZ] := aAuditoria[nA][nScan][nPEntrSCE]
					EndIf
				Case  aCabec[05][nZ][2]=="CE_MOTIVO"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³O Motivo da Analise sempre sera obtido do array aAuditoria aglutinado para compor o novo aAuditoria. ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nA := 1 To Len(aAuditoria)
						nScan := aScan(aAuditoria[nA], {|z| z[nPPropSCE] + z[nPFornSCE] + z[nPLojaSCE] + z[nPICotSCE] == ;
						aSC8[nX][nY][nPosProp][2] + aSC8[nX][nY][nPosForn][2] + aSC8[nX][nY][nPosLoja][2] + aSC8[nX][nY][nPosItCt][2] })
						If nScan > 0
							Exit
						EndIf
					Next nA
					aNewAudit[nX][Len(aNewAudit[nX])][nZ] := aAuditoria[nA][nScan][nPMotiSCE]
				OtherWise
					nScan := 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Identifica o campo especifico no array original da auditoria ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nA := 1 To Len(aAuditoria)
						nScan := aScan(aAuditoria[nA], {|z| z[nPPropSCE] + z[nPFornSCE] + z[nPLojaSCE] + z[nPICotSCE] == ;
						aSC8[nX][nY][nPosProp][2] + aSC8[nX][nY][nPosForn][2] + aSC8[nX][nY][nPosLoja][2] + aSC8[nX][nY][nPosItCt][2] })
						If nScan > 0
							Exit
						EndIf
					Next nA
					If nScan > 0
						aNewAudit[nX][Len(aNewAudit[nX])][nZ] := aAuditoria[nX][nScan][nZ]
					Else
						aNewAudit[nX][Len(aNewAudit[nX])][nZ] := CriaVar(aCabec[CAB_HFLD2][nZ][2],.T.)
					EndIF
			EndCase
			
		Next nZ
		
		aNewAudit[nX][Len(aNewAudit[nX])][ Len(aCabec[05])+1] := .F.
		
	Next nY
	
Next nX

Return(aNewAudit)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaAvalCOT ³ Autor ³ Eduardo Riera         ³ Data ³27.07.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao dos eventos do processo de cotacao       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MaAvalCOT(ExpC1,ExpN1,ExpA1,ExpA2,ExpA3,ExpL1,ExpL2,ExpB1)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1:*Alias da tabela de cotacao                            ³±±
±±³          ³ExpN1:*Codigo do Evento                                      ³±±
±±³          ³       [01] Geracao de uma cotacao                           ³±±
±±³          ³       [02] Atualizacao dos precos de uma cotacao            ³±±
±±³          ³       [03] Cancelamento de uma cotacao                      ³±±
±±³          ³       [04] Analise de uma cotacao                           ³±±
±±³          ³ExpA1: Array com as cotacoes(SC8)                            ³±±
±±³          ³       [x] Array com os produtos/identificadores da cotacao  ³±±
±±³          ³    [x][y] Array com os dados de uma cotacao                 ³±±
±±³          ³ [x][y][1] Nome do campo                                     ³±±
±±³          ³       [2] Conteudo do campotaacao                           ³±±
±±³          ³ExpA2: Array no formato aHeader das cotacoes vencedoras      ³±±
±±³          ³ExpA3: Array com os produtos/identificadores das cotacoes    ³±±
±±³          ³       vencedoras(SCE)                                       ³±±
±±³          ³       [x] Array no formato acols das cotacoes vencedoras    ³±±
±±³          ³ExpL1: .T. - Mantem a data da necessidade da cotacao(D)      ³±±
±±³          ³       .F. - Ajusta a data da necessidade para a Entrega     ³±±
±±³          ³ExpL2: .T. - Indica que eh o ultimo item da cotacao a ser Av.³±±
±±³          ³ExpB1: Codeblock de contabilizacao  On-Line.                 ³±±
±±³          ³ExpC2: Codigo do comprador responsavel vindo do ACC		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. 	                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo atualizar os eventos vinculados³±±
±±³          ³a uma cotacao, como:                                         ³±±
±±³          ³A) Atualizacao das tabelas complementares.                   ³±±
±±³          ³B) Atualizacao das informacoes complementares a cotacao      ³±±
±±³          ³C) Executar o B2B                                            ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MaAvalCOT(cAliasSC8,nEvento,aSC8,aHeadSCE,aCOLSSCE,lNecessid,lLast,bCtbOnLine,cCompACC)

Local aArea 	:= GetArea()
Local aAreaSC8  := SC8->(GetArea())
Local aRegSC1   := {}
Local aVencedor := {}
Local aPaginas  := {}
Local aRefImp   := {}
Local aSCMail	:= {}
Local aNroItGrd := {}
Local cNumCot   := ""
Local cProduto  := ""
Local cIdent    := ""
Local cQuery    := ""
Local cCursor   := ""
Local cNumPed   := ""
Local cItemPC   := ""
Local cUsers 	:= ""
Local cCndCot	:= ""
Local cNumContr := ""
Local cItemContr:= ""
Local cFLuxo    := Criavar("C7_FLUXO")
Local lQuery    := .F.
Local lCotSC  	:= SuperGetMV("MV_COTSC")=="S"
Local lTrava	:= .T.
Local nA		:= 0
Local nB		:= 0
Local nX        := 0
Local nY        := 0
Local nZ		:= 0
Local nTotal    := 0
Local nPQtdSCE  := 0
Local nPMotSCE  := 0
Local nPRegSC8  := 0
Local nPForSC8  := 0
Local nPLojSC8  := 0
Local nPCndSC8  := 0
Local nPPrdSC8  := 0
Local nPFilSC8  := 0
Local nScan     := 0
Local nSaveSX8  := GetSX8Len()
Local cGrupo	:= SuperGetMv("MV_PCAPROV")
Local lLiberou	:= .F.
Local lPEGerPC  := ExistBlock("MT160GRPC")

DEFAULT aSC8      := {}
DEFAULT aHeadSCE  := {}
DEFAULT aCOLSSCE  := {}
DEFAULT lNecessid := .T.
DEFAULT lLast     := .F.
DEFAULT bCtbOnLine:= {|| .T.}
DEFAULT cCompACC  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o grupo de aprovacao do Comprador.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SY1")
dbSetOrder(3)
If dbSeek(xFilial("SY1")+If(Empty(cCompACC),RetCodUsr(),cCompACC))
	cGrupo	:= If(!Empty(Y1_GRAPROV),SY1->Y1_GRAPROV,cGrupo)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para alterar o Grupo de Aprovacao.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Implantacao de uma cotacao                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case nEvento == 1
	cNumCot   := (cAliasSC8)->C8_NUM
	cProduto  := (cAliasSC8)->C8_PRODUTO
	cIdent    := (cAliasSC8)->C8_IDENT
	If ( lLast )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³M-Message - Verifica o Evento 003 - Solicitacao com cotacao pendente.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MExistMail("003")
			#IFDEF TOP
				If ( TcSrvType()<>"AS/400" )
					cCursor := "MAAVALCOT"
					cQuery := "SELECT C1_NUM,C1_ITEM,C1_DESCRI,C1_USER,C1_SOLICIT,C1_OP "
					cQuery += "FROM "+RetSqlName("SC1")+" SC1 "
					cQuery += "WHERE SC1.C1_FILIAL='"+xFilial("SC1")+"' AND "
					cQuery += "SC1.C1_COTACAO='"+cNumCot+"' AND "
					cQuery += "SC1.C1_PRODUTO='"+cProduto+"' AND "
					cQuery += "SC1.C1_IDENT='"+cIdent+"' AND "
					cQuery += "SC1.D_E_L_E_T_<>'*'"
					cQuery := ChangeQuery(cQuery)
					SC1->(dbCommit())					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor,.T.,.T.)
					While ( !Eof() )
						aadd(aSCMail,C1_NUM+"/"+C1_ITEM+" "+C1_SOLICIT+" "+C1_DESCRI)
						cUsers += C1_USER+"#"							
						dbSelectArea(cCursor)
						dbSkip()					
					EndDo
					dbSelectArea(cCurSor)
					dbCloseArea()
					dbSelectArea("SC1")					
				Else
			#ENDIF
				dbSelectArea("SC1")
				dbSetOrder(5)
				MsSeek(xFilial("SC1")+cNumCot+cProduto+cIdent)
				While ( !Eof() .And. xFilial("SC1")	== SC1->C1_FILIAL .And.;
						cNumCot		== SC1->C1_COTACAO.And.;
						cProduto == SC1->C1_PRODUTO.And.;
						cIdent == SC1->C1_IDENT )
					aadd(aSCMail,C1_NUM+"/"+C1_ITEM+" "+C1_SOLICIT+" "+C1_DESCRI)
					cUsers += C1_USER+"#"
					dbSelectArea("SC1")
					dbSkip()
				EndDo
				#IFDEF TOP
				EndIf			
				#ENDIF
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Envia e-mail do Evento 003                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MEnviaMail("003",{cNumCot,aSCMail},cUsers)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neogrid - Verifica a existencia da Administracao colaborativa de Pedidos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( NeoEnable("001") )
			NeoEnvCot(cNumCot)
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizacao dos precos de uma cotacao                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case nEvento == 2
	cNumCot   := (cAliasSC8)->C8_NUM
	cCndCot   := (cAliasSC8)->C8_COND
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a existencia do Evento 004 - Cotacao com analise pendente.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLast .And. !Empty(cCndCot)
		MEnviaMail("004",{cNumCot})
	EndIf		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cancelamento da cotacao                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case nEvento == 3
	cNumCot   := (cAliasSC8)->C8_NUM
	cProduto  := (cAliasSC8)->C8_PRODUTO
	cIdent    := (cAliasSC8)->C8_IDENT
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente estornar a solicitacao de compra quando esta nao possuir cotacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasSC8)
	dbSetOrder(4)		
	If ( !MsSeek(xFilial("SC8")+cNumCot+cIdent+cProduto) )
		#IFDEF TOP
			If ( TcSrvType()<>"AS/400" )
				cCursor := "MAAVALCOT"
				cQuery := "SELECT R_E_C_N_O_ SC1RECNO "
				cQuery += "FROM "+RetSqlName("SC1")+" SC1 "
				cQuery += "WHERE SC1.C1_FILIAL='"+xFilial("SC1")+"' AND "
				cQuery += "SC1.C1_COTACAO='"+cNumCot+"' AND "
				cQuery += "SC1.C1_PRODUTO='"+cProduto+"' AND "
				cQuery += "SC1.C1_IDENT='"+cIdent+"' AND "
				cQuery += "SC1.D_E_L_E_T_<>'*'"
				cQuery := ChangeQuery(cQuery)
				SC1->(dbCommit())					
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor,.T.,.T.)
				While ( !Eof() )
					aadd(aRegSC1,SC1RECNO)
					dbSelectArea(cCursor)
					dbSkip()					
				EndDo
				dbSelectArea(cCurSor)
				dbCloseArea()
				dbSelectArea("SC1")					
			Else
		#ENDIF
			dbSelectArea("SC1")
			dbSetOrder(5)
			MsSeek(xFilial("SC1")+cNumCot+cProduto+cIdent)
			While ( !Eof() .And. xFilial("SC1")	== SC1->C1_FILIAL .And.;
					cNumCot		== SC1->C1_COTACAO.And.;
					cProduto == SC1->C1_PRODUTO.And.;
					cIdent == SC1->C1_IDENT )
				aadd(aRegSC1,RecNo())
				dbSelectArea("SC1")
				dbSkip()
			EndDo
			#IFDEF TOP
			EndIf			
			#ENDIF			
		For nX := 1 To Len(aRegSC1)
			dbSelectArea("SC1")
			MsGoto(aRegSC1[nX])
			RecLock("SC1",.F.)
			If ( lCotSC .And. SC1->C1_QUJE < SC1->C1_QUANT )
				SC1->C1_COTACAO := ""
			Else
				SC1->C1_COTACAO := Repl("X",Len(SC1->C1_COTACAO))
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de Entrada para tratamento dos registros da solicitacao compras.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("MT150EXC")
				ExecBlock("MT150EXC",.f.,.f.)
			Endif
		Next nX
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Analise da cotacao                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case nEvento == 4
	nPQtdSCE  := aScan(aHeadSCE,{|x| Trim(x[2])=="CE_QUANT"})
	nPMotSCE  := aScan(aHeadSCE,{|x| Trim(x[2])=="CE_MOTIVO"})
	nPEntSCE  := aScan(aHeadSCE,{|x| Trim(x[2])=="CE_ENTREGA"})
	nPRegSC8  := aScan(aSC8[1][1],{|x| Trim(x[1])=="SC8RECNO"})
	nPForSC8  := aScan(aSC8[1][1],{|x| Trim(x[1])=="C8_FORNECE"})
	nPLojSC8  := aScan(aSC8[1][1],{|x| Trim(x[1])=="C8_LOJA"})
	nPCndSC8  := aScan(aSC8[1][1],{|x| Trim(x[1])=="C8_COND"})
	nPPrdSC8  := aScan(aSC8[1][1],{|x| Trim(x[1])=="C8_PRODUTO"})
	nPFilSC8  := aScan(aSC8[1][1],{|x| Trim(x[1])=="C8_FILENT"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico quais fornecedores possuem cotacoes vencedoras                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aColsSCE)
		For nY := 1 To Len(aColsSCE[nX])
			dbSelectArea("SC8")
			MsGoto(aSC8[nX][nY][nPRegSC8][2])
			If ( aColsSCE[nX][nY][nPQtdSCE] > 0 )
				If ( RecLock("SC8") )
					nZ := aScan(aVencedor,{|x| x[1]==aSC8[nX][nY][nPForSC8][2].And.;
						x[2]==aSC8[nX][nY][nPLojSC8][2].And.;
						x[3]==aSC8[nX][nY][nPCndSC8][2].And.;
						x[4]==aSC8[nX][nY][nPFilSC8][2]})
					If ( nZ == 0 )
						aadd(aVencedor,{aSC8[nX][nY][nPForSC8][2],;
							aSC8[nX][nY][nPLojSC8][2],;
							aSC8[nX][nY][nPCndSC8][2],;
							aSC8[nX][nY][nPFilSC8][2]})
					EndIf
				EndIf
			EndIf
		Next nY
	Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a quais impostos devem ser gravados.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRefImp := MaFisRelImp('MT100',{"SC7"})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua a gravacao dos pedidos para cada Vencedor                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nZ := 1 To Len(aVencedor)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Travo todos os registros antes de iniciar a gravacao                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lTrava := .T.
		For nX := 1 To Len(aColsSCE)
			For nY := 1 To Len(aColsSCE[nX])
				If ( aVencedor[nZ][1]==aSC8[nX][nY][nPForSC8][2].And.;
						aVencedor[nZ][2]==aSC8[nX][nY][nPLojSC8][2].And.;
						aVencedor[nZ][3]==aSC8[nX][nY][nPCndSC8][2].And.;
						aVencedor[nZ][4]==aSC8[nX][nY][nPFilSC8][2] )
					
					dbSelectArea("SC8")
					MsGoto(aSC8[nX][nY][nPRegSC8][2])
					If (!RecLock("SC8") )
						lTrava := .F.
						Exit
					EndIf
				EndIf
			Next nY
		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicio o processo de gravacao do Pedido de Compra                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( lTrava )
			cNumPed   := CriaVar("C7_NUM",.T.)
			While ( GetSX8Len() > nSaveSX8 )
				ConfirmSx8()
			EndDo
			cItemPC   := StrZero(1,Len(SC7->C7_ITEM))
			nTotal    := 0
			If ( Empty(cNumPed) )
				cNumPed := GetNumSC7(.F.)
			EndIf
			For nX := 1 To Len(aColsSCE)
				For nY := 1 To Len(aColsSCE[nX])
					If ( aVencedor[nZ][1]==aSC8[nX][nY][nPForSC8][2].And.;
							aVencedor[nZ][2]==aSC8[nX][nY][nPLojSC8][2].And.;
							aVencedor[nZ][3]==aSC8[nX][nY][nPCndSC8][2].And.;
							aVencedor[nZ][4]==aSC8[nX][nY][nPFilSC8][2].And.;
							aColsSCE[nX][nY][nPQtdSCE]<>0)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Guarda as paginas que houveram vencedores                               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ( aScan(aPaginas,nX)==0 )
							aadd(aPaginas,nX)
						EndIf
						dbSelectArea("SB1")
						dbSetOrder(1)
						MsSeek(xFilial("SB1")+aSC8[nX][nY][nPPrdSC8][2])
						dbSelectArea("SC8")
						MsGoto(aSC8[nX][nY][nPRegSC8][2])
						dbSelectArea("SC1")
						dbSetOrder(5)
						MsSeek(xFilial("SC1")+SC8->C8_NUM+SC8->C8_PRODUTO+SC8->C8_IDENT)
						dbSelectArea("SA2")
						dbSetOrder(1)
						MsSeek(xFilial("SA2")+aVencedor[nZ][1]+aVencedor[nZ][2])
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Incluo o item do Pedido de Compra                                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RecLock("SC7",.T.)
						dbSelectArea("SC7")
						For nA := 1 to SC7->(FCount())
							nB := SC8->(FieldPos("C8"+SubStr(SC7->(FieldName(nA)),3)))
							If ( nB <> 0 )
								FieldPut(nA,SC8->(FieldGet(nB)))
							EndIf
						Next nA

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Controla a numeracao do Item no PC quando for Item de Grade vindo do SC8³
						//³Observar que o Numero do Item no PC C7_ITEM sera trocado toda vez que na³
						//³mesma grade o C8_PRECO for diferente, ou seja, somente sera aglutinado  ³
						//³na mesma grade (mesmo C7_ITEM) os itens do Grid que possuirem o mesmo   ³
						//³preco para preservar os valores,calculos de impostos e afins.           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SC8->C8_GRADE == "S"

							cProdRef := SC8->C8_PRODUTO
							lReferencia := MatGrdPrrf(@cProdRef, .T.)
							
							If (nScan := aScan(aNroItGrd, {|x| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] + x[7] + x[8] == ;
								SC8->C8_ITEM + cProdRef + SC8->C8_NUMPRO + SC8->C8_FORNECE + SC8->C8_LOJA + SC8->C8_NUMSC + SC8->C8_ITEMSC + TransForm(SC8->C8_PRECO,PesqPict("SC8","C8_PRECO")) })) == 0

								Aadd(aNroItGrd, { SC8->C8_ITEM , cProdRef , SC8->C8_NUMPRO , SC8->C8_FORNECE , SC8->C8_LOJA ,SC8->C8_NUMSC ,SC8->C8_ITEMSC ,TransForm(SC8->C8_PRECO,PesqPict("SC8","C8_PRECO")) , cItemPc } )
								nScan := Len(aNroItGrd)
								cItemPc	:= Soma1(cItemPc)

							Endif
						Else
							nScan := Nil
						EndIf
												
						SC7->C7_FILIAL := xFilial("SC7")
						SC7->C7_TIPO   := 1
						SC7->C7_NUM    := cNumPed
						SC7->C7_ITEM   := If(nScan == Nil, cItemPc , aNroItGrd[nScan, 9 ])
						SC7->C7_GRADE  := SC8->C8_GRADE
						SC7->C7_ITEMGRD:= SC8->C8_ITEMGRD
						SC7->C7_FORNECE:= aVencedor[nZ][1]
						SC7->C7_LOJA   := aVencedor[nZ][2]
						SC7->C7_COND   := aVencedor[nZ][3]
						SC7->C7_OP     := SC1->C1_OP
						SC7->C7_LOCAL  := SC1->C1_LOCAL
						SC7->C7_DESCRI := SC1->C1_DESCRI
						SC7->C7_UM     := SC1->C1_UM
						SC7->C7_SEGUM  := SC1->C1_SEGUM
						SC7->C7_QUANT  := aColsSCE[nX][nY][nPQtdSCE]
						SC7->C7_QTDSOL := 0 //aColsSCE[nX][nY][nPQtdSCE]
						SC7->C7_QTSEGUM := IIf(SB1->B1_CONV==0,SC1->C1_QTSEGUM,ConvUm(aSC8[nX][nY][nPPrdSC8][2],aColsSCE[nX][nY][nPQtdSCE],0,2))
						SC7->C7_PRECO   := SC8->C8_PRECO
						SC7->C7_TOTAL   := NoRound(SC7->C7_QUANT*SC7->C7_PRECO)
						SC7->C7_CONTATO := SC8->C8_CONTATO
						SC7->C7_OBS     := SC8->C8_OBS
						SC7->C7_EMISSAO := dDataBase
						SC7->C7_DATPRF  := IIf(lNecessid,aColsSCE[nX][nY][nPentSCE],dDataBase+SC8->C8_PRAZO)
						SC7->C7_CC      := SC1->C1_CC
						SC7->C7_ITEMCTA := SC1->C1_ITEMCTA
						SC7->C7_CLVL    := SC1->C1_CLVL
						SC7->C7_CONTA   := SC1->C1_CONTA
						SC7->C7_ITEMCTA := SC1->C1_ITEMCTA
						SC7->C7_ORIGEM  := SC1->C1_ORIGEM
						SC7->C7_DESC1   := SC8->C8_DESC1
						SC7->C7_DESC2   := SC8->C8_DESC2
						SC7->C7_DESC3   := SC8->C8_DESC3
						SC7->C7_REAJUST := SC8->C8_REAJUST
						SC7->C7_IPI     := SC8->C8_ALIIPI
						SC7->C7_NUMSC   := SC8->C8_NUMSC
						SC7->C7_ITEMSC  := SC8->C8_ITEMSC
						SC7->C7_NUMCOT  := SC8->C8_NUM
						SC7->C7_FILENT  := SC8->C8_FILENT
						SC7->C7_TPFRETE := SC8->C8_TPFRETE
						SC7->C7_VLDESC  := ((SC7->C7_TOTAL*SC8->C8_VLDESC)/SC8->C8_TOTAL)
						SC7->C7_IPIBRUT := "B"
						SC7->C7_VALEMB  := SC8->C8_VALEMB
						SC7->C7_FRETE   := SC8->C8_TOTFRE
						SC7->C7_FLUXO   := cFluxo  
						
						If SC7->(FieldPos("C7_RATEIO")) > 0
							SC7->C7_RATEIO  := CriaVar('C7_RATEIO',.T.)			
						EndIf
						
						If SC7->(FieldPos("C7_ACCNUM")) > 0 .And. If(Type('lIsACC')#"L",.F.,lIsACC)
							SC7->C7_ACCNUM  := aColsSCE[nX][nY][Len(aColsSCE[nX][nY])-1]
							SC7->C7_ACCITEM := aColsSCE[nX][nY][Len(aColsSCE[nX][nY])]
							SC7->C7_USER    := cCompACC
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³PE para atualizacao de campos especificos do SC7      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
						If lPEGerPC
							ExecBlock("MT160GRPC",.F.,.F.,{aVencedor,aSC8})
						EndIf
						
						MaFisIni(aVencedor[nZ][1],aVencedor[nZ][2],"F","N","R",aRefImp)						
						
						If cItemPC == StrZero(1,Len(SC7->C7_ITEM)) .And. ExistBlock("MT120APV")
							cGrupo := ExecBlock("MT120APV",.F.,.F.,{aVencedor,aSC8})
						EndIf
						SC7->C7_APROV   := cGrupo
						MaFisIniLoad(1)
						For nA := 1 To Len(aRefImp)
							MaFisLoad(aRefImp[nA][3],FieldGet(FieldPos(aRefImp[nA][2])),1)
						Next nA
						MaFisRecal("",1)
						MaFisEndLoad(1)
						MaFisAlt("IT_ALIQIPI",SC7->C7_IPI,1)
						MaFisAlt("IT_ALIQICM",SC7->C7_PICM,1)
						MaFisWrite(1,"SC7",1)
						MaFisWrite(2,"SC7",1,.F.)
						nTotal += MaFisRet(1,"IT_TOTAL")
						MaFisEnd()
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Encerro a cotacao vencedora                                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("SC8")
						MsGoto(aSC8[nX][nY][nPRegSC8][2])
						SC8->C8_NUMPED := cNumPed
						SC8->C8_ITEMPED:= If(nScan == Nil, cItemPc , aNroItGrd[nScan, 9 ])
						SC8->C8_MOTIVO := aColsSCE[nX][nY][nPMotSCE]
						SC8->C8_DATPRF := IIf(lNecessid,aColsSCE[nX][nY][nPentSCE],dDataBase+SC8->C8_PRAZO)
						SC8->C8_PRAZO  := SC8->C8_DATPRF - dDataBase
						RecLock("SCE",.T.)
						SCE->CE_FILIAL := xFilial("SCE")
						SCE->CE_NUMCOT := SC8->C8_NUM
						SCE->CE_ITEMCOT:= SC8->C8_ITEM
						SCE->CE_NUMPRO := SC8->C8_NUMPRO
						SCE->CE_PRODUTO:= SC8->C8_PRODUTO
						SCE->CE_FORNECE:= SC8->C8_FORNECE
						SCE->CE_LOJA   := SC8->C8_LOJA
						SCE->CE_ITEMGRD:= SC8->C8_ITEMGRD
						For nA := 1 To Len(aHeadSCE)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Nao grava campos virutais e de controle (walkthru)   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !(IsHeadRec(Trim(aHeadSCE[nA][2])) .OR. IsHeadAlias(Trim(aHeader[nA][2])) .OR. aHeader[nA][10] == "V")
								FieldPut(FieldPos(aHeadSCE[nA][2]),aCOLSSCE[nX][nY][nA])
							EndIf
						Next nA
						SCE->CE_MOTIVO := aColsSCE[nX][nY][nPMotSCE]
						SCE->CE_ENTREGA:= IIf(lNecessid,aColsSCE[nX][nY][nPentSCE],dDataBase+SC8->C8_PRAZO)							
						If SC8->C8_QTDCTR > 0
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Gravacao do Contrato de Parceria                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If Empty(cNumContr)
								cNumContr := CriaVar("C3_NUM",.T.)
								cItemContr:= Strzero(1,Len(SC3->C3_ITEM))
								While ( GetSX8Len() > nSaveSX8 )
									ConfirmSx8()
								EndDo				
							EndIf
							RecLock("SC3",.T.)
							dbSelectArea("SC3")
							SC3->C3_FILIAL  := xFilial("SC3")
							SC3->C3_NUM     := cNumContr
							SC3->C3_FORNECE := aVencedor[nZ][1]
							SC3->C3_LOJA    := aVencedor[nZ][2]
							SC3->C3_GRADE   := SC8->C8_GRADE
							SC3->C3_ITEMGRD := SC8->C8_ITEMGRD
							SC3->C3_ITEM    := cItemContr
							SC3->C3_PRODUTO := SC8->C8_PRODUTO
							SC3->C3_QUANT   := SC8->C8_QTDCTR
							SC3->C3_PRECO   := SC8->C8_PRECO
							SC3->C3_TOTAL   := SC3->C3_PRECO*SC3->C3_QUANT
							SC3->C3_DATPRI  := dDataBase
							SC3->C3_DATPRF  := IIf(lNecessid,aColsSCE[nX][nY][nPentSCE],dDataBase+SC8->C8_PRAZO)
							SC3->C3_LOCAL   := SC1->C1_LOCAL
							SC3->C3_COND    := aVencedor[nZ][3]
							SC3->C3_CONTATO := SC8->C8_CONTATO
							SC3->C3_FILENT  := SC8->C8_FILENT
							SC3->C3_EMISSAO := dDatabase
							SC3->C3_REAJUST := SC8->C8_REAJUST
							SC3->C3_TPFRETE := SC8->C8_TPFRETE
							SC3->C3_FRETE   := SC8->C8_TOTFRE
							SC3->C3_OBS     := SC8->C8_OBS
							If SC3->(FieldPos("C3_AVISTA"))<>0
								SC3->C3_AVISTA := SC8->C8_AVISTA
							EndIf
							If SC3->(FieldPos("C3_TAXAFOR"))<>0
								SC3->C3_TAXAFOR := SC8->C8_TAXAFOR
							EndIf
							MsUnLock()
							SB1->(DBSetOrder(1))
							If SB1->(MsSeek(xFilial("SB1")+SC8->C8_PRODUTO))
								RecLock("SB1",.F.)
								Replace SB1->B1_CONTRAT With "S"
								Replace SB1->B1_PROC    With aVencedor[nZ][1]
								Replace SB1->B1_LOJPROC With aVencedor[nZ][2]
								MsUnLock()
							EndIf
							cItemContr  :=  Soma1(cItemContr,Len(SC3->C3_ITEM))
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualizo os acumulados do Pedido de Compra           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
						MaAvalPC("SC7",1,nZ==Len(aVencedor),Nil,Nil,Nil,bCtbOnLine,.F.)

						If nScan == Nil 
  							cItemPc	:= Soma1(cItemPc)
         				EndIf

						If (Existblock("AVALCOT"))
							ExecBlock("AVALCOT",.F.,.F.,{nEvento})
						EndIf
					EndIf
				Next nY
			Next nX

			lLiberou := U_MaAlcDoc({SC7->C7_NUM,"PC",nTotal,,,SC7->C7_APROV,,SC7->C7_MOEDA,SC7->C7_TXMOEDA,SC7->C7_EMISSAO},dDataBase,1)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Integracao ACC envia aprovacao do pedido            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If lLiberou .And. If(FindFunction("WebbConfig"),WebbConfig(.F.),.F.) .And. !Empty(SC7->C7_ACCNUM)
				If IsBlind()
					Webb533(SC7->C7_NUM)
				Else
					MsgRun("Aguarde, comunicando aprovação ao portal","Portal ACC",{|| Webb533(SC7->C7_NUM)}) //Aguarde, comunicando aprovação ao portal ## Portal ACC
				EndIf
			EndIf
			
			#IFDEF TOP
				If TcSrvType()<>"AS/400"
					SC7->(dbCommit())
					cQuery := "UPDATE "
					cQuery += RetSqlName("SC7")+" "	
					cQuery += "SET C7_CONAPRO = '"+ IIf( !lLiberou .Or. GetNewPar("MV_SIGAGSP","0") == "1" , "B" , "L" ) + "' "
					cQuery += "WHERE C7_FILIAL='"+xFilial("SC7")+"' AND "
					cQuery += "C7_NUM='"+cNumPed+"' AND "
					cQuery += "D_E_L_E_T_=' ' "					
					TcSqlExec(cQuery)
					SC7->(DbGoto(RecNo()))
				Else
			#ENDIF
				dbSelectArea("SC7")
				dbSetOrder(1)
				dbSeek(xFilial()+cNumPed)
				While !Eof() .And. C7_FILIAL+C7_NUM == xFilial("SC7")+cNumPed
					RecLock("SC7",.F.)    // CRISTIANO FERREIRA
					If !lLiberou .Or. GetNewPar("MV_SIGAGSP","0") == "1" //Consiste parametro de integracao do SIGAGSP. GERAR SEMPRE BLOQUEADO  
						SC7->C7_CONAPRO := "B"
					Else
						SC7->C7_CONAPRO := "B"  
					EndIf
					MsUnlock()
					dbSkip()
				EndDo                                                                                 
				#IFDEF TOP
				EndIf
				#ENDIF
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia e-mail na inclusao do Pedido de Compras.                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SC7->(MsSeek(xFilial("SC7")+cNumPed))
				MEnviaMail("037",{SC7->C7_NUM,SC7->C7_NUMCOT,SC7->C7_APROV,SC7->C7_CONAPRO,Subs(cUsuario,7,15)})
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ PE para manipular cada PC gravado pela analise da cotacao.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Existblock("AVALCOPC"))
			ExecBlock("AVALCOPC",.F.,.F.)
		EndIf

	Next nZ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento das cotacoes perdedoras que foram analisadas                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nZ := 1 To Len(aPaginas)
		nX := aPaginas[nZ]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicio o processo de gravacao do Pedido de Compra                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nY := 1 To Len(aColsSCE[nX])
			dbSelectArea("SC8")
			MsGoto(aSC8[nX][nY][nPRegSC8][2])
			If ( Empty(SC8->C8_NUMPED) )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Encerro as cotacoes perdedoras                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("SC8")
				SC8->C8_NUMPED := Repl("X",Len(SC8->C8_NUMPED))
				SC8->C8_ITEMPED:= Repl("X",Len(SC8->C8_ITEMPED))
				SC8->C8_MOTIVO := aColsSCE[nX][nY][nPMotSCE]
			EndIf
		Next nY
	Next nZ
EndCase

RestArea(aAreaSC8)
RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MaAlcDoc ³ Autor ³ Aline Correa do Vale  ³ Data ³07.08.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controla a alcada dos documentos (SCS-Saldos/SCR-Bloqueios)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MaAlcDoc(ExpA1,ExpD1,ExpN1,ExpC1,ExpL1)               	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com informacoes do documento                 ³±±
±±³          ³       [1] Numero do documento                              ³±±
±±³          ³       [2] Tipo de Documento                                ³±±
±±³          ³       [3] Valor do Documento                               ³±±
±±³          ³       [4] Codigo do Aprovador                              ³±±
±±³          ³       [5] Codigo do Usuario                                ³±±
±±³          ³       [6] Grupo do Aprovador                               ³±±
±±³          ³       [7] Aprovador Superior                               ³±±
±±³          ³       [8] Moeda do Documento                               ³±±
±±³          ³       [9] Taxa da Moeda                                    ³±±
±±³          ³      [10] Data de Emissao do Documento                     ³±±
±±³          ³      [11] Grupo de Compras                                 ³±±
±±³          ³      [12] Aprovador Original                               ³±±
±±³          ³ ExpD1 = Data de referencia para o saldo                    ³±±
±±³          ³ ExpN1 = Operacao a ser executada                           ³±±
±±³          ³       1 = Inclusao do documento                            ³±±
±±³          ³       2 = Transferencia para Superior                      ³±±
±±³          ³       3 = Exclusao do documento                            ³±±
±±³          ³       4 = Aprovacao do documento                           ³±±
±±³          ³       5 = Estorno da Aprovacao                             ³±±
±±³          ³       6 = Bloqueio Manual da Aprovacao                     ³±±
±±³          ³ ExpC1 = Chave(Alternativa) do SF1 para exclusao SCR        ³±±
±±³          ³ ExpL1 = Eliminacao de Residuos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MaAlcDoc(aDocto,dDataRef,nOper,cDocSF1,lResiduo)

Local cDocto	:= aDocto[1]
Local cTipoDoc	:= aDocto[2]
Local nValDcto	:= aDocto[3]
Local cAprov	:= If(aDocto[4]==Nil,"",aDocto[4])
Local cUsuario	:= If(aDocto[5]==Nil,"",aDocto[5])
Local nMoeDcto	:= If(Len(aDocto)>7,If(aDocto[8]==Nil, 1,aDocto[8]),1)
Local nTxMoeda	:= If(Len(aDocto)>8,If(aDocto[9]==Nil, 0,aDocto[9]),0)
Local cObs      := If(Len(aDocto)>10,If(aDocto[11]==Nil, "",aDocto[11]),"")
Local aArea		:= GetArea()
Local aAreaSCS	:= SCS->(GetArea())
Local aAreaSCR	:= SCR->(GetArea())
Local aRetPe	:= {}
Local nSaldo	:= 0
Local cGrupo	:= If(aDocto[6]==Nil,"",aDocto[6])
Local lFirstNiv:= .T.
Local cAuxNivel:= ""
Local cNextNiv := ""
Local cNivIgual:= ""
Local cStatusAnt:= ""
Local cAprovOri := ""    
Local cUserOri  := ""
Local lAchou	:= .F.
Local nRec		:= 0
Local lRetorno	:= .T.
Local aSaldo	:= {} 
Local aMTALCGRU := {}
Local lDeletou := .F.
Local dDataLib := IIF(dDataRef==Nil,dDataBase,dDataRef) 
Private cGeraSCR := 'S'
DEFAULT dDataRef := dDataBase
DEFAULT cDocSF1 := cDocto
DEFAULT lResiduo := .F.
cDocto := cDocto+Space(Len(SCR->CR_NUM)-Len(cDocto))
cDocSF1:= cDocSF1+Space(Len(SCR->CR_NUM)-Len(cDocSF1))

If ExistBlock("MT097GRV")
	lRetorno := (Execblock("MT097GRV",.F.,.F.,{aDocto,dDataRef,nOper,cDocSF1,lResiduo}))
	If Valtype( lRetorno ) <> "L"
		lRetorno := .T.
	EndIf
Endif

If lRetorno

	If Empty(cUsuario) .And. (nOper != 1 .And. nOper != 6) //nao e inclusao ou estorno de liberacao
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSeek(xFilial()+cAprov)
		cUsuario :=	AK_USER
		nMoeDcto :=	AK_MOEDA
		nTxMoeda	:=	0
	EndIf
	If nOper == 1  //Inclusao do Documento
		cGrupo := If(!Empty(aDocto[6]),aDocto[6],cGrupo)
		dbSelectArea("SAL")
		dbSetOrder(2)
		If !Empty(cGrupo) .And. dbSeek(xFilial("SAL")+cGrupo)
			While !Eof() .And. xFilial("SAL")+cGrupo == AL_FILIAL+AL_COD

                If cTipoDoc <> "NF"  
					If SAL->AL_AUTOLIM == "S" .And. !MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda)
						dbSelectArea("SAL")
						dbSkip()
						Loop
					EndIf	
                EndIf
                 
				If lFirstNiv
					cAuxNivel := SAL->AL_NIVEL
					lFirstNiv := .F.
				EndIf

				Do Case
				Case cTipoDoc == "NF"
					SF1->(FkCommit())
				Case cTipoDoc == "PC" .Or.cTipoDoc == "AE"
					SC7->(FkCommit())
				Case cTipoDoc == "CP"
					SC3->(FkCommit())
				Case cTipoDoc == "SC"
					SC1->(FkCommit())
				Case cTipoDoc == "CO"
					SC8->(FkCommit())
				Case cTipoDoc == "MD"
					CND->(FkCommit())
				EndCase

				Reclock("SCR",.T.)
				SCR->CR_FILIAL	:= xFilial("SCR")
				SCR->CR_NUM		:= cDocto
				SCR->CR_TIPO	:= cTipoDoc
				SCR->CR_NIVEL	:= SAL->AL_NIVEL
				SCR->CR_USER	:= SAL->AL_USER
				SCR->CR_APROV	:= SAL->AL_APROV
				SCR->CR_STATUS	:= IIF(SAL->AL_NIVEL == cAuxNivel,"02","01")
				SCR->CR_TOTAL	:= nValDcto
				SCR->CR_EMISSAO:= aDocto[10]
				SCR->CR_MOEDA	:=	nMoeDcto
				SCR->CR_TXMOEDA:= nTxMoeda
				MsUnlock()
				dbSelectArea("SAL")
				dbSkip()
			EndDo
		EndIf
		lRetorno := lFirstNiv
	EndIf
	
	If nOper == 2  //Transferencia da Alcada para o Superior
		//dbSelectArea("SCR")
		//dbSetOrder(1)
		//dbSeek(xFilial("SCR")+cTipoDoc+cDocto)
		// O SCR deve estar posicionado, para que seja transferido o atual para o Superior
		If !Eof() .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM == xFilial("SCR")+cTipoDoc+cDocto
			// Carrega dados do Registro a ser tranferido e exclui
			cTipoDoc := SCR->CR_TIPO
			cAuxNivel:= SCR->CR_STATUS
			nValDcto := SCR->CR_TOTAL
			nMoeDcto :=	SCR->CR_MOEDA
			cNextNiv := SCR->CR_NIVEL
			nTxMoeda := SCR->CR_TXMOEDA
			dDataRef := SCR->CR_EMISSAO
			cAprovOri:= SCR->CR_APROV
			cUserOri := SCR->CR_USER
			Reclock("SCR",.F.,.T.)
			dbDelete()
			MsUnlock()
			// Inclui Registro para Aprovador Superior
			Reclock("SCR",.T.)
			SCR->CR_FILIAL	:= xFilial("SCR")
			SCR->CR_NUM		:= cDocto
			SCR->CR_TIPO	:= cTipoDoc
			SCR->CR_NIVEL	:= cNextNiv
			SCR->CR_USER	:= cUsuario
			SCR->CR_APROV	:= cAprov
			SCR->CR_STATUS	:= cAuxNivel
			SCR->CR_TOTAL	:= nValDcto
			SCR->CR_EMISSAO:= dDataRef
			SCR->CR_MOEDA	:=	nMoeDcto
			SCR->CR_TXMOEDA:= nTxMoeda                     
			SCR->CR_OBS 	:= cObs  
			
			//Aplicar UPDCOM10 se não existir campos na base //
			If !Empty(SCR->(FieldPos("CR_APRORI"))) .And. !Empty(SCR->(FieldPos("CR_USERORI")))
				SCR->CR_APRORI  := cAprovOri	
				SCR->CR_USERORI := cUserOri
			EndIf

			MsUnlock()
		EndIf
		lRetorno := .T.
	EndIf
	
	If nOper == 3  //exclusao do documento
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+cTipoDoc+cDocto)		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua uma nova busca caso o cDocto nao for encontrado no SCR³
		//³ pois seu conteudo em caso de NF foi alterado para chave unica³
		//³ do SF1, o cDocSF1 sera a busca alternativa com o conteudo ori³
		//³ ginal do lancamento da versao que poderia causar duplicidades³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SCR->( Eof() ) .And. cTipoDoc == "NF"
			dbSeek(xFilial("SCR")+cTipoDoc+cDocSF1)
			cDocto := cDocSF1
		EndIf

		While !Eof() .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM == xFilial("SCR")+cTipoDoc+cDocto
			If SCR->CR_STATUS == "03"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Reposiciona o usuario aprovador.               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SAK")
				dbSeek(xFilial("SAK")+SCR->CR_LIBAPRO)
				dbSelectArea("SAL")
				dbSetOrder(3)
				dbSeek(xFilial("SAL")+cGrupo+SAK->AK_COD)
				If SAL->AL_LIBAPR == "A"
					dbSelectArea("SCS")
					dbSetOrder(2)
					If dbSeek(xFilial("SCS")+SAK->AK_COD+DTOS(MaAlcDtRef(SCR->CR_LIBAPRO,SCR->CR_DATALIB,SCR->CR_TIPOLIM)))
						RecLock("SCS",.F.)
						SCS->CS_SALDO := SCS->CS_SALDO + SCR->CR_VALLIB
						MsUnlock()
					EndIf
				EndIf
			EndIf
			Reclock("SCR",.F.,.T.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf
	
	If nOper == 4 //Aprovacao do documento
		dbSelectArea("SCS")
		dbSetOrder(2)
		aSaldo := MaSalAlc(cAprov,dDataRef,.T.)
		nSaldo 	:= aSaldo[1]
		dDataRef	:= aSaldo[3]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o saldo do aprovador.                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSeek(xFilial("SAK")+cAprov)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona a Tabela SAL pelo Aprovador de Origem caso o Documento tenha sido ³
		//| transferido por Ausência Temporária ou Transferência superior e o aprovador |
		//| de destino não fizer parte do Grupo de Aprovação.                           |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SAL")
		dbSetOrder(3)
		dbSeek(xFilial("SAL")+cGrupo+cAprov) 
	    If !Empty(SCR->(FieldPos("CR_USERORI"))) .And. !Empty(SCR->(FieldPos("CR_APRORI"))) .And. !Empty(SCR->CR_APRORI)
    		dbSeek(xFilial("SAL")+cGrupo+SCR->CR_APRORI) 
    	EndIf   
    	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona a Tabela SAL pelo Aprovador de Origem caso o Documento que esta   ³
		//| sendo aprovado, pela opcao: SUPERIOR e o aprovador Superior nao fizer parte |
		//| do mesmo Grupo de Aprovação.  									                            |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If Len(aDocto)>11 .And. !Empty(SCR->(FieldPos("CR_USERORI"))) .And. !Empty(SCR->(FieldPos("CR_APRORI"))) .And. Empty(SCR->CR_APRORI)
	    	If !Empty(aDocto[12])
				dbSeek(xFilial("SAL")+cGrupo+aDocto[12])     	
    		EndIf
    	EndIf                               
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para alterar o Aprovador 	 												³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   	If ExistBlock("MTALCGRU")
			aMTALCGRU := If(ValType(aRetPe:=ExecBlock("MTALCGRU",.F.,.F.,{cAprov,cGrupo}))=="A",aRetPe,aMTALCGRU)
			If Len(aMTALCGRU) >= 1 .And. ValType(aMTALCGRU[1]) == "C"
				cAprov := aMTALCGRU[1]
			EndIf
			If Len(aMTALCGRU) >= 2 .And. ValType(aMTALCGRU[2]) == "C"
				cGrupo := aMTALCGRU[2]
			EndIf	
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Libera o pedido pelo aprovador.                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SCR")
		cAuxNivel := CR_NIVEL
		Reclock("SCR",.F.)
		dbSetOrder(1)
		CR_STATUS	:= "03"
		CR_OBS		:= If(Len(aDocto)>10,aDocto[11],"")
		CR_DATALIB	:= dDataLib
		CR_USERLIB	:= SAK->AK_USER
		CR_LIBAPRO	:= SAK->AK_COD
		CR_VALLIB	:= nValDcto
		CR_TIPOLIM	:= SAK->AK_TIPO
		MsUnlock()
		dbSeek(xFilial("SCR")+cTipoDoc+cDocto+cAuxNivel)
		nRec := RecNo()
		While !Eof() .And. xFilial("SCR")+cDocto+cTipoDoc == CR_FILIAL+CR_NUM+CR_TIPO
			If cAuxNivel == CR_NIVEL .And. CR_STATUS != "03" .And. SAL->AL_TPLIBER$"U "
				Exit
			EndIf
			If cAuxNivel == CR_NIVEL .And. CR_STATUS != "03" .And. SAL->AL_TPLIBER$"NP"
				Reclock("SCR",.F.)
				CR_STATUS	:= "05"
				CR_DATALIB	:= dDataLib
				CR_USERLIB	:= SAK->AK_USER
				CR_APROV	:= cAprov
				CR_OBS		:= ""
				MsUnlock()
			EndIf
			If CR_NIVEL > cAuxNivel .And. CR_STATUS != "03" .And. !lAchou
				lAchou := .T.
				cNextNiv := CR_NIVEL
			EndIf
			If lAchou .And. CR_NIVEL == cNextNiv .And. CR_STATUS != "03"
				Reclock("SCR",.F.)
				CR_STATUS := If(SAL->AL_TPLIBER=="P","05",;
					If(( Empty(cNivIgual) .Or. cNivIgual == CR_NIVEL ) .And. cStatusAnt <> "01" ,"02",CR_STATUS))

				If CR_STATUS == "05"
					CR_DATALIB	:= dDataLib
				EndIf
				MsUnlock()
				cNivIgual := CR_NIVEL					
				lAchou    := .F.
			Endif

			cStatusAnt := SCR->CR_STATUS

			dbSkip()
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Reposiciona e verifica se ja esta totalmente liberado.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbGoto(nRec)
		While !Eof() .And. xFilial("SCR")+cTipoDoc+cDocto == CR_FILIAL+CR_TIPO+CR_NUM
			If CR_STATUS != "03" .And. CR_STATUS != "05"
				lRetorno := .F.
			EndIf
			dbSkip()
		EndDo
		If SAL->AL_LIBAPR == "A"
			dbSelectArea("SCS")
			If dbSeek(xFilial()+cAprov+dToS(dDataRef))
				Reclock("SCS",.F.)
			Else
				Reclock("SCS",.T.)                                    
			EndIf
			CS_FILIAL:= xFilial("SCS")
			CS_SALDO := CS_SALDO - nValDcto
			CS_APROV := cAprov
			CS_USER	 := cUsuario
			CS_MOEDA := nMoeDcto
			CS_DATA	 := dDataRef
			MsUnlock()
		EndIf
	EndIf
	
	If nOper == 5  //Estorno da Aprovacao
		cGrupo := If(!Empty(aDocto[6]),aDocto[6],cGrupo)
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+cTipoDoc+cDocto)
		nMoeDcto := SCR->CR_MOEDA
		nTxMoeda := SCR->CR_TXMOEDA
		While !Eof() .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM == xFilial("SCR")+cTipoDoc+cDocto
			If SCR->CR_STATUS == "03"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Reposiciona o usuario aprovador.               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SAK")
				dbSeek(xFilial("SAK")+SCR->CR_LIBAPRO)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona a Tabela SAL pelo Aprovador de Origem caso o Documento tenha sido ³
				//| transferido por Ausência Temporária ou Transferência superior e o aprovador |
				//| de destino não fizer parte do Grupo de Aprovação.                           |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SAL")
				dbSetOrder(3)
				dbSeek(xFilial("SAL")+cGrupo+SAK->AK_COD)
				If Eof()
				    If !Empty(SCR->(FieldPos("CR_USERORI")))
			    		dbSeek(xFilial("SAL")+cGrupo+SCR->CR_APRORI) 
	    			EndIf
	   			EndIf
	   			
				If SAL->AL_LIBAPR == "A"
					dbSelectArea("SCS")
					dbSetOrder(2)
					If dbSeek(xFilial("SCS")+SAK->AK_COD+DTOS(MaAlcDtRef(SAK->AK_COD,SCR->CR_DATALIB)))
						RecLock("SCS",.F.)
						SCS->CS_SALDO := SCS->CS_SALDO + If(nValDcto>0 .And. nValDcto < SCR->CR_VALLIB,nValDcto,SCR->CR_VALLIB)
						If SCS->CS_SALDO > SAK->AK_LIMITE
							SCS->CS_SALDO := SAK->AK_LIMITE
						EndIf
						MsUnlock()
					EndIf
				EndIf
			EndIf
			Reclock("SCR",.F.,.T.)
			If nValDcto > 0 .And. nValDcto < SCR->CR_TOTAL
				SCR->CR_TOTAL	:= SCR->CR_TOTAL - nValDcto
				SCR->CR_VALLIB	:= SCR->CR_VALLIB - nValDcto
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³A variavel lResiduo informa se devera ou nao reconstituir um  ³
				//³novo bloqueio SCR  se ainda houver saldo apos a eliminacao de ³
				//³residuos, em caso da opcao de estorno a recosntituicao do SCR ³
				//³e obrigatoria, apos a delecao.                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				If lResiduo
					lDeletou := IF(SCR->CR_TOTAL - nValDcto > 0,.T.,.F.)
				Else
					lDeletou := .T.
				EndIf
				dbDelete()
			EndIf
			MsUnlock()
			dbSkip()
		EndDo

		dbSelectArea("SAL")
		dbSetOrder(2)
		If	(!Empty(cGrupo) .And. dbSeek(xFilial("SAL")+cGrupo) .And. nValDcto > 0 .And. lDeletou) .Or. ;
			(!Empty(cGrupo) .And. dbSeek(xFilial("SAL")+cGrupo) .And. cTipoDoc == "NF" .And. lDeletou)
			
			While !Eof() .And. xFilial("SAL")+cGrupo == AL_FILIAL+AL_COD

                If cTipoDoc <> "NF"  
					If SAL->AL_AUTOLIM == "S" .And. !MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda)
						dbSelectArea("SAL")
						dbSkip()
						Loop
					EndIf             	
                EndIf
                 				
				If lFirstNiv
					cAuxNivel := SAL->AL_NIVEL
					lFirstNiv := .F.
				EndIf
				Reclock("SCR",.T.)
				SCR->CR_FILIAL	:= xFilial("SCR")
				SCR->CR_NUM		:= cDocto
				SCR->CR_TIPO	:= cTipoDoc
				SCR->CR_NIVEL	:= SAL->AL_NIVEL
				SCR->CR_USER	:= SAL->AL_USER
				SCR->CR_APROV	:= SAL->AL_APROV
				SCR->CR_STATUS	:= IIF(SAL->AL_NIVEL == cAuxNivel,"02","01")
				SCR->CR_TOTAL	:= nValDcto
				SCR->CR_EMISSAO:= dDataRef
				SCR->CR_MOEDA	:=	nMoeDcto
				SCR->CR_TXMOEDA:= nTxMoeda
				MsUnlock()
				dbSelectArea("SAL")
				dbSkip()
			EndDo
		EndIf
		lRetorno := lFirstNiv
	EndIf
	
	If nOper == 6  //Bloqueio manual
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSeek(xFilial("SAK")+cAprov)
	
		Reclock("SCR",.F.)
		CR_STATUS   := "04"
		CR_OBS	    := If(Len(aDocto)>10,aDocto[11],"")
		CR_DATALIB  := dDataRef
		CR_USERLIB	:= SAK->AK_USER
		CR_LIBAPRO	:= SAK->AK_COD
		cAuxNivel   := CR_NIVEL
		MsUnlock()
		lRetorno 	:= .F.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Bloqueia todos os Aprovadores do Nível  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSeek(xFilial("SCR")+cTipoDoc+cDocto+cAuxNivel)
		nRec := RecNo()
		While !Eof() .And. xFilial("SCR")+cDocto+cTipoDoc+cAuxNivel == CR_FILIAL+CR_NUM+CR_TIPO+CR_NIVEL
			If CR_STATUS != "04" 
				Reclock("SCR",.F.)
				CR_STATUS	:= "05"
				CR_OBS	    := SAK->AK_COD
				CR_DATALIB	:= dDataRef
				CR_USERLIB	:= SAK->AK_USER
				CR_LIBAPRO	:= SAK->AK_COD
				MsUnlock()
			EndIf             
			                                           
			dbSkip()
		EndDo
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao ACC envia aprovacao do pedido            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. cTipoDoc == "PC" .And. (nOper == 1 .Or. nOper == 4) .And. If(FindFunction("WebbConfig"),WebbConfig(),.F.)
		aAreaSC7 := SC7->(GetArea())
		
		SC7->(dbSetOrder(1))
		If SC7->(dbSeek(xFilial("SC7")+AllTrim(cDocto))) .And. !Empty(SC7->C7_ACCNUM)	
			If IsBlind()
				Webb533(SC7->C7_NUM)
			Else
				MsgRun("Aguarde, comunicando aprovação ao portal...","Portal ACC",{|| Webb533(SC7->C7_NUM)})	//Aguarde, comunicando aprovação ao portal... ## Portal ACC
			EndIf
		EndIf
		
		dbSelectArea("SC7")
		RestArea(aAreaSC7)
	EndIf
	
	If ExistBlock("MTALCDOC")
		Execblock("MTALCDOC",.F.,.F.,{aDocto,dDataRef,nOper})
	Endif	
EndIf

If ExistBlock("MTALCFIM")
	lCalculo := Execblock("MTALCFIM",.F.,.F.,{aDocto,dDataRef,nOper,cDocSF1,lResiduo})
	If Valtype( lCalculo ) == "L"
		lRetorno := lCalculo
	EndIf
Endif

dbSelectArea("SCR")
RestArea(aAreaSCR)
dbSelectArea("SCS")
RestArea(aAreaSCS)
RestArea(aArea)

Return(lRetorno)
    
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MaFisRet ³ Autor ³ Edson Maricate        ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os impostos calculados pela MATXFIS.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Valor do imposto.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
User Function MaFisRet(nItem,cCampo)

Local nRetorno
Local cPosCpo := MaFisScan(cCampo)

Do Case
Case Substr(cCampo,1,2) == "IT"
	If ValType(cPosCpo) == "A"
		nRetorno:=aNfItem[nItem][cPosCpo[1]][cPosCpo[2]]
	Else
		If nItem == Nil
			nRetorno:=aNfItem[1][Val(cPosCpo)]
			else
			nRetorno:=aNfItem[nItem][Val(cPosCpo)]
		EndIf
	EndIf
Case Substr(cCampo,1,2) == "LF"
	If nItem == Nil
		nRetorno:=aNfItem[nItem][NF_LIVRO][cPosCpo]
	Else
		nRetorno:=aNfItem[nItem][IT_LIVRO][cPosCpo]
	EndIf
OtherWise
	If ValType(cPosCpo) == "A"
		nRetorno:=aNfCab[cPosCpo[1]][cPosCpo[2]]
	Else
		nRetorno:=aNfCab[Val(cPosCpo)]
	EndIf
EndCase

Return nRetorno

