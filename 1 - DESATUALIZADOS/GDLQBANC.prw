#include "rwmake.ch"
#DEFINE cEol CHR(13)+CHR(10)
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} GDLQBANC
Gerar Holerite do banco Bradesco
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
User Function GDLQBANC()
	
	Private cPerg     	:= 'GDLQIT'
	Private cString   	:= 'SRA'
	Private cSeqReBb		:= ''
	Private cLin			:= ''
	Private cNomeArq		:= ''
	Private nQtFunc		:= 0
	Private nHdl			:= 0
	Private nBanc			:= 0
	Private lLiq			:= .F.
	Private lData			:= .F.
	Private lHeader		:= .F.
	Private lContinua		:= .T.
	Private oGeraTxt
	Private nSoma234		:= 0
	Private cDataRef		:= GetMv('PI_DATAREF',.F.,'31122015')
	Private cDataLib		:= GetMv('PI_DATALIB',.F.,'31122015')
	Private cDataPag		:= GetMv('PI_DATAPAG',.F.,'07012016')
	
	fAsrPerg()
	pergunte(cPerg,.F.)
	
	dbSelectArea( "SRA" )
	dbSetOrder(1)
	
	//³ Montagem da tela de processamento.                                  ³
	@ 200,001 TO 410,480 DIALOG oGeraTxt TITLE OemToAnsi( "Geracao do Arquivo de Pagamento - SISPAG BRADESCO" )
		@ 002,010 TO 095,230
		@ 010,018 Say " Este programa ira gerar o arquivo de demonstrativo de pagamento    "
		@ 018,018 Say " para o Banco Bradesco - SISPAG.	 						   "
		@ 026,018 Say "                                                                    "
		
		@ 070,128 BMPBUTTON TYPE 05 ACTION Pergunte(cPerg,.T.)
		@ 070,158 BMPBUTTON TYPE 01 ACTION OkGeraTxt()
		@ 070,188 BMPBUTTON TYPE 02 ACTION Close(oGeraTxt)
	Activate Dialog oGeraTxt Centered
	
	If lLiq
		Aviso("ATENCAO","Valor liquido de alguns funcionarios com diferenças",{"Continuar"})
	Endif
	
	If nHdl > 0
		If fClose(nHdl)
			If lContinua .And. lData
				ApMsgInfo( 'Arquivo Gerado.  Processamento Concluido. ', 'ATENÇÃO' )
			Else
				/*If fErase(cNomeArq) == 0
					If !lContinua .Or. !lData
						ApMsgInfo( 'Nao Existem Registros a Serem Gravados. Processamento Concluido.', 'ATENÇÃO' )
					EndIf
				Else
					MsgAlert('Ocorreram problemas na tentativa de dele‡„o do arquivo ' + AllTrim(cNomeArq)+'.')
				EndIf*/
			EndIf
		Else
			MsgAlert('Ocorreram problemas no fechamento do arquivo '+AllTrim(cNomeArq)+'.')
		EndIf
	Else
		If !lContinua
			ApMsgInfo( 'Processamento Abortado.', 'ATENÇÃO' )
		Endif
	EndIf
	
Return(Nil)
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} OkGeraTxt
Funcao chamada pelo botao OK na tela inicial de processamento. 
Executa a geracao do arquivo texto. 
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function OkGeraTxt()
	
	Processa({|| RunCont() },"Processando...")
	//--Fecha objeto
	Close(oGeraTxt)
Return(Nil)
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} RunCont
Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA monta a janela com a regua 
de processamento.
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function RunCont
	
	Local lIgual                 //Variavel de retorno na comparacao do SRC
	Local cArqNew                //Variavel de retorno caso SRC # SX3
	Local cMesArqRef
	Local aOrdBag     := {}
	Local cArqMov     := ""
	Local cAliasMov   := ""
	Local nReg		  	:= 0
	Local cAcessaSR1  := &("{ || " + ChkRH("GPER030","SR1","2") + "}")
	Local cAcessaSRA  := &("{ || " + ChkRH("GPER030","SRA","2") + "}")
	Local cAcessaSRC  := &("{ || " + ChkRH("GPER030","SRC","2") + "}")
	Local cAcessaSRI  := &("{ || " + ChkRH("GPER030","SRI","2") + "}")
	Local cAcessaSRR  := &("{ || " + ChkRH("GPER030","SRR","2") + "}")
	
	//Variaveis para emissao do arquivo de ferias
	Local cDataBas		:= ""
	Local cDBaseAt		:= ""
	Local cDFerias		:= ""
	Local cDAbonPe		:= ""
	Local nSomFunc		:= 0
	Local nTotProv		:= 0
	
	Private dDataRef, cEsc, nEsc, Semana, cFilDe, cFilAte, cCcDe, cCcAte, cMatDe
	Private cMatAte, Mensag1, Mensag2, Mensag3, cSit, cCat
	Private cMesAnoRef, lAtual, dDtBusFer, dDtFerIni
	Private cBancoDe, cBancoAte, cContaDe, cContaAte
	
	Private cFinPgt, nSequenc, dDataPagto, dDataDe, dDataAte
	
	Private aTotLote := {0,0}
	
	Private TOTVENC, TOTDESC, FLAG, CHAVE
	Private Desc_Fil, Desc_End, DESC_CGC, DESC_FUNC
	Private DESC_MSG1, DESC_MSG2, DESC_MSG3
	Private cFilialAnt, cFuncaoAnt, cCcAnt, Vez, OrdemZ
	
	Private nAteLim, nBaseFgts, nFgts, nBaseIr, nBaseIrFe, nLiquido
	
	Private aLanca := {}
	Private aProve := {}
	Private aDesco := {}
	Private aBases := {}
	Private aInfo  := {}
	Private aCodFol:= {}
	Private cFolMes_ := GETMV("MV_FOLMES")
	
	Pergunte(cPerg,.F.)
	dDataRef   := mv_par01
	cEsc       := mv_par02
	Semana     := mv_par03
	cFilDe     := mv_par04
	cFilAte    := mv_par05
	cCcDe      := mv_par06
	cCcAte     := mv_par07
	cMatDe     := mv_par08
	cMatAte    := mv_par09
	Mensag1    := mv_par10
	Mensag2    := mv_par11
	Mensag3    := mv_par12
	cSit       := mv_par13
	cCat       := mv_par14
	cNomeArq   := Alltrim(mv_par15)
	dDataPagto := mv_par16
	dDataDe	  := mv_par17
	dDataAte   := mv_par18
	nBanc	     := mv_par19

	/*dbSelectArea('SEE')
	SEE->(dbSetOrder(1))//EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
	SEE->(dbGoTop())
	//If !SEE->(dbSeek(xFilial('SEE') + MV_PAR20 + MV_PAR21 + MV_PAR22 + MV_PAR23))
	If !SEE->(dbSeek(xFilial('SEE') + MV_PAR20 + MV_PAR21 + AvKey(MV_PAR22,'EE_CONTA')))
		MsgAlert('Configuração bancária, (Banco, Agencia, Conta, Subconta) inválido.')
		Return()
	EndIf*/
	
	For nReg := 1 to Len(cEsc)
		If !("*" == Substr(cEsc,nReg,1))
			nEsc	:= Val(Substr(cEsc,nReg,1))
			Exit
		EndIf
	Next nReg
		
	//Cria o arquivo texto
	While .T.
		If File(cNomeArq)
			If (nAviso := Aviso('AVISO','Deseja substituir o ' + AllTrim(cNomeArq) + ' existente ?', {'Sim','Nao','Cancela'})) == 1
				If fErase(cNomeArq) == 0
					Exit                                      
				Else
					MsgAlert('Ocorreram problemas na tentativa de dele‡„o do arquivo '+AllTrim(cNomeArq)+'.')
				EndIf
			//ElseIf nAviso == 2
			//	Pergunte(cPerg,.T.)
			//	Loop
			//Else
			//	lContinua := .F.
			//	Return
			EndIf
		Else
			Exit
		EndIf
	EndDo
	
	nHdl := fCreate(cNomeArq)
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cNomeArq+" nao pode ser executado! Verifique os parametros.","Atencao!")
		Return
	Endif
	
	cMesAnoRef := StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)
	cMesArqRef  := If(nEsc == 4,"13"+Right(cMesAnoRef,4),cMesAnoRef)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Verifica se existe o arquivo de fechamento do mes informado  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF nEsc <> 6
		//	lAtual := ( !fExistArq( cMesArqRef,,0 ) .And. MesAno(dDataRef) == MesAno(dDataBase) )
		lAtual := ( !fExistArq( cMesArqRef,,0 ) .And. MesAno(dDataRef) == cFolMes_ )
		If !lAtual
			If !fIniArqMov( cMesArqRef, @cAliasMov , @aOrdBag , @cArqMov )
				ChkFile( cAliasMov , .F. )
				Return
			EndIf
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Selecionando a Ordem de impressao escolhida no parametro.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SI3" )
	dbSetOrder(1)
	dbSelectArea( "SRF" )
	dbSetOrder(1)
	dbSelectArea( "SRH" )
	dbSetOrder(1)
	dbSelectArea( "SRJ" )
	dbSetOrder(1)
	dbSelectArea( "SRR" )
	dbSetOrder(1)
	dbSelectArea( "SRA" )
	dbSetOrder(1)
	dbGoTop()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Selecionando o Primeiro Registro e montando Filtro.          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSeek(cFilDe + cMatDe,.T.)
	cCond := "SRA->RA_FILIAL + SRA->RA_MAT <= cFilAte + cMatAte"
	
	dbSelectArea("SRA")
	ProcRegua(RecCount(0))
	
	TOTVENC    := TOTDESC   := FLAG      := CHAVE     := 0
	Desc_Fil   := Desc_End  := DESC_CGC   := DESC_FUNC := ""
	DESC_MSG1  := DESC_MSG2 := DESC_MSG3 := Space(01)
	cFilialAnt := "  "
	cFuncaoAnt := "    "
	cCcAnt     := Space(9)
	Vez        := 0
	OrdemZ     := 0
	nSequenc   := 0
	
	If nEsc == 1			// Adiantamento
		cFinPgt := "02"
	ElseIf nEsc == 2		// Folha
		cFinPgt := "01"
	ElseIf nEsc == 3		// 1a Parcela
		cFinPgt := "04"
	ElseIf nEsc == 4		// 2a Parcela
		cFinPgt := "04"
	ElseIf nEsc	== 5		// Extras
		cFinPgt := "10"
	ElseIf nEsc == 6		// Ferias
		cFinPgt := "07"
	EndIf
	
	//Verifica Banco a ser Gerado
	//Filtra Banco 341 (Itau)
	//If SEE->EE_CODIGO != '341'
	//	Aviso("ATENCAO BANCO ITAU","Banco Diferente de 341 (Itaú)",{"Continuar"})
	//	Return
	//Endif
	
	dbSelectArea("SRA")
	Do While SRA->(!Eof()) .And. &cCond .And. lContinua
		IncProc("Fil: "+SRA->RA_FILIAL+"  Matr: "+SRA->RA_MAT)
		
		If (SRA->RA_FILIAL   < cFilDe)  .Or. (SRA->RA_FILIAL   > cFilAte) .Or. ;
				(SRA->RA_CC       < cCcDe)   .Or. (SRA->RA_CC       > cCcAte)  .Or. ;
				(SRA->RA_MAT      < cMatDe)  .Or. (SRA->RA_MAT      > cMatAte)
			SRA->(dbSkip())
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Data Demissao         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSitFunc := SRA->RA_SITFOLH
		dDtPesqAf:= CTOD("01/" + Left(cMesAnoRef,2) + "/" + Right(cMesAnoRef,4),"DDMMYY")
		If cSitFunc == "D" .And. (!Empty(SRA->RA_DEMISSA) .And. MesAno(SRA->RA_DEMISSA) > MesAno(dDtPesqAf))
			cSitFunc := " "
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste situacao e categoria dos funcionarios			     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !( cSitFunc $ cSit ) .OR.  ! ( SRA->RA_CATFUNC $ cCat )
			dbSkip()
			Loop
		Endif
		If cSitFunc $ "D" .And. Mesano(SRA->RA_DEMISSA) # Mesano(dDataRef)
			dbSkip()
			Loop
		Endif

		aLanca  := {}
		aProve  := {}
		aDesco  := {}
		aBases  := {}
		
		cDataBas	:= ""
		cDBaseAt	:= ""
		cDFerias	:= ""
		cDAbonPe	:= ""
		
		nAteLim := nBaseFgts := nFgts := nBaseIr := nBaseIrFe := nLiquido := 0.00
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste controle de acessos e filiais validas		        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
			SRA->(dbSkip())
			Loop
		EndIf
		//-- Verifica se é do banco bradesco
		If Left(SRA->RA_BCDEPSA,3) != '237'
			SRA->(dbSkip())
			Loop
		EndIf
		
		If SRA->RA_CODFUNC # cFuncaoAnt           // Descricao da Funcao
			DescFun(Sra->Ra_Codfunc,Sra->Ra_Filial)
			cFuncaoAnt := Sra->Ra_CodFunc
		Endif
		
		If SRA->RA_CC # cCcAnt                   // Centro de Custo
			DescCC(Sra->Ra_Cc,Sra->Ra_Filial)
			cCcAnt := SRA->RA_CC
		Endif
		
		If SRA->RA_Filial # cFilialAnt
			If !Fp_CodFol(@aCodFol,Sra->Ra_Filial) .Or. ! fInfo(@aInfo,Sra->Ra_Filial)
				lContinua := .F.
				Exit
			Endif
			Desc_Fil := aInfo[3]
			Desc_End := aInfo[4]                // Dados da Filial
			Desc_CGC := aInfo[8]
			DESC_MSG1:= DESC_MSG2 := DESC_MSG3 := Space(01)
			
			// MENSAGENS
			If MENSAG1 # SPACE(1)
				If FPHIST82(SRA->RA_FILIAL,"06",SRA->RA_FILIAL+MENSAG1)
					DESC_MSG1 := Left(SRX->RX_TXT,30)
				ElseIf FPHIST82(SRA->RA_FILIAL,"06","  "+MENSAG1)
					DESC_MSG1 := Left(SRX->RX_TXT,30)
				Endif
			Endif
			
			If MENSAG2 # SPACE(1)
				If FPHIST82(SRA->RA_FILIAL,"06",SRA->RA_FILIAL+MENSAG2)
					DESC_MSG2 := Left(SRX->RX_TXT,30)
				ElseIf FPHIST82(SRA->RA_FILIAL,"06","  "+MENSAG2)
					DESC_MSG2 := Left(SRX->RX_TXT,30)
				Endif
			Endif
			
			If MENSAG3 # SPACE(1)
				If FPHIST82(SRA->RA_FILIAL,"06",SRA->RA_FILIAL+MENSAG3)
					DESC_MSG3 := Left(SRX->RX_TXT,30)
				ElseIf FPHIST82(SRA->RA_FILIAL,"06","  "+MENSAG3)
					DESC_MSG3 := Left(SRX->RX_TXT,30)
				Endif
			Endif
			
			dbSelectArea("SRA")
			
			cFilialAnt := SRA->RA_FILIAL
		Endif
		
		Totvenc := Totdesc := 0
		
		SI3->(dbSeek( xFilial("SI3",SRA->RA_FILIAL)+SRA->RA_CC ))
		SRJ->(dbSeek( xFilial("SRJ",SRA->RA_FILIAL)+SRA->RA_CODFUNC ))
		SRH->(dbSeek( xFilial("SRH",SRA->RA_FILIAL)+SRA->RA_MAT ))
		
		If nEsc == 1 .OR. nEsc == 2
			dbSelectArea("SRC")
			If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
				Do While !Eof() .And. SRC->RC_FILIAL+SRC->RC_MAT == SRA->RA_FILIAL+SRA->RA_MAT
					If SRC->RC_SEMANA # Semana
						dbSkip()
						Loop
					Endif
					If !Eval(cAcessaSRC)
						dbSkip()
						Loop
					EndIf
					If (nEsc == 1) .And. (Src->Rc_Pd == aCodFol[7,1])      // Desconto de Adto
						fSomaPd("P",aCodFol[6,1],SRC->RC_HORAS,SRC->RC_VALOR)
						TOTVENC += Src->Rc_Valor
					Elseif (nEsc == 1) .And. (Src->Rc_Pd == aCodFol[12,1])
						fSomaPd("D",aCodFol[9,1],SRC->RC_HORAS,SRC->RC_VALOR)
						TOTDESC += SRC->RC_VALOR
					Elseif (nEsc == 1) .And. (Src->Rc_Pd == aCodFol[8,1])
						fSomaPd("P",aCodFol[8,1],SRC->RC_HORAS,SRC->RC_VALOR)
						TOTVENC += SRC->RC_VALOR
					Else
						If PosSrv( Src->Rc_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
							If (nEsc #1) .Or. (nEsc == 1 .And. PosSrv(Src->Rc_Pd,Sra->Ra_Filial,"RV_ADIANTA") == "S")
								fSomaPd("P",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
								TOTVENC += Src->Rc_Valor
							Endif
						Elseif PosSrv( Src->Rc_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
							If (nEsc #1) .Or. (nEsc == 1 .And. PosSrv(Src->Rc_Pd,Sra->Ra_Filial,"RV_ADIANTA") == "S")
								fSomaPd("D",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
								TOTDESC += Src->Rc_Valor
							Endif
						Elseif PosSrv( Src->Rc_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "3"
							If (nEsc #1) .Or. (nEsc == 1 .And. PosSrv(Src->Rc_Pd,Sra->Ra_Filial,"RV_ADIANTA") == "S")
								fSomaPd("B",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
							Endif
						Endif
					Endif
					If nESC = 1
						If SRC->RC_PD == aCodFol[10,1]
							nBaseIr := SRC->RC_VALOR
						Endif
					ElseIf SRC->RC_PD == aCodFol[13,1]
						nAteLim += SRC->RC_VALOR
					Elseif SRC->RC_PD$ aCodFol[108,1]+'*'+aCodFol[17,1]
						nBaseFgts += SRC->RC_VALOR
					Elseif SRC->RC_PD$ aCodFol[109,1]+'*'+aCodFol[18,1]
						nFgts += SRC->RC_VALOR
					Elseif SRC->RC_PD == aCodFol[15,1]
						nBaseIr += SRC->RC_VALOR
					Elseif SRC->RC_PD == aCodFol[16,1]
						nBaseIrFe += SRC->RC_VALOR
					Elseif SRC->RC_PD == aCodFol[47,1]
						nLiquido := SRC->RC_VALOR
					Endif
					dbSelectArea("SRC")
					dbSkip()
				Enddo
			Endif
		Elseif nEsc == 3
			dbSelectArea("SRC")
			If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
				Do While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRC->RC_FILIAL + SRC->RC_MAT
					If !Eval(cAcessaSRC)
						dbSkip()
						Loop
					EndIf
					If SRC->RC_PD == aCodFol[22,1]
						fSomaPd("P",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
						TOTVENC += SRC->RC_VALOR
					Elseif SRC->RC_PD == aCodFol[172,1]
						fSomaPd("D",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
						TOTDESC += SRC->RC_VALOR
					Elseif SRC->RC_PD == aCodFol[108,1] .Or. SRC->RC_PD == aCodFol[109,1] .Or. SRC->RC_PD == aCodFol[173,1]
						fSomaPd("B",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
					Endif
					
					If SRC->RC_PD == aCodFol[108,1]
						nBaseFgts := SRC->RC_VALOR
					Elseif SRC->RC_PD == aCodFol[109,1]
						nFgts     := SRC->RC_VALOR
					Endif
					dbSelectArea("SRC")
					dbSkip()
				Enddo
				nLiquido := TOTVENC - TOTDESC
			Endif
		Elseif nEsc == 4
			dbSelectArea("SRI")
			dbSetOrder(2)
			If dbSeek(SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT)
				Do While !Eof() .And. SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT == SRI->RI_FILIAL + SRI->RI_CC + SRI->RI_MAT
					If !Eval(cAcessaSRI)
						dbSkip()
						Loop
					EndIf
					If PosSrv( SRI->RI_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
						fSomaPd("P",SRI->RI_PD,SRI->RI_HORAS,SRI->RI_VALOR)
						TOTVENC = TOTVENC + SRI->RI_VALOR
					Elseif PosSrv( SRI->RI_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
						fSomaPd("D",SRI->RI_PD,SRI->RI_HORAS,SRI->RI_VALOR)
						TOTDESC = TOTDESC + SRI->RI_VALOR
					Elseif PosSrv( SRI->RI_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "3"
						fSomaPd("B",SRI->RI_PD,SRI->RI_HORAS,SRI->RI_VALOR)
					Endif
					
					If SRI->RI_PD == aCodFol[19,1]
						nAteLim += SRI->RI_VALOR
					Elseif SRI->RI_PD$ aCodFol[108,1]
						nBaseFgts += SRI->RI_VALOR
					Elseif SRI->RI_PD$ aCodFol[109,1]
						nFgts += SRI->RI_VALOR
					Elseif SRI->RI_PD == aCodFol[27,1]
						nBaseIr += SRI->RI_VALOR
					Elseif SRI->RI_PD == aCodFol[21,1]
						nLiquido := SRI->RI_VALOR
					Endif
					dbSkip()
				Enddo
			Endif
		Elseif nEsc == 5
			dbSelectArea("SR1")
			dbSetOrder(1)
			If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
				Do While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT ==	SR1->R1_FILIAL + SR1->R1_MAT
					If Semana #"99"
						If SR1->R1_SEMANA #Semana
							dbSkip()
							Loop
						Endif
					Endif
					If !Eval(cAcessaSR1)
						dbSkip()
						Loop
					EndIf
					If PosSrv( SR1->R1_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
						fSomaPd("P",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
						TOTVENC = TOTVENC + SR1->R1_VALOR
					Elseif PosSrv( SR1->R1_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
						fSomaPd("D",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
						TOTDESC = TOTDESC + SR1->R1_VALOR
					Elseif PosSrv( SR1->R1_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "3"
						fSomaPd("B",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
					Endif
					dbskip()
				Enddo
				nLiquido := TOTVENC - TOTDESC
			Endif
		Elseif nEsc == 6
			
			dDtFerIni := cTod("  /  /  ")
			dDtBusFer := cTod("  /  /  ")
			//Busca Data Inicial e Data de Pagamento de Férias
			fCheckFer('INI') // Busca RH_DATAINI
			
			If (dDtFerIni >= dDataDe .And. dDtFerIni <= dDataAte)
				
				If SRR->(dbSeek( xFilial("SRR",SRA->RA_FILIAL) + SRA->RA_MAT + "F" + dTos(dDtBusFer),.T.))
					
					Do While SRR->(!Eof()) .And. (SRA->RA_FIlIAL + SRA->RA_MAT + "F" + dTos(dDtBusFer) ==;
							SRR->RR_FILIAL + SRR->RR_MAT + SRR->RR_TIPO3 + dTos(SRR->RR_DATA))
						
						If !Eval(cAcessaSRR)
							dbSkip()
							Loop
						EndIf
						
						If SRR->RR_PD # aCodFol[102,1]
							
							If PosSrv( SRR->RR_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
								fSomaPd("P",SRR->RR_PD,SRR->RR_HORAS,SRR->RR_VALOR)
								TOTVENC := TOTVENC + SRR->RR_VALOR
							ElseIf PosSrv( SRR->RR_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
								fSomaPd("D",SRR->RR_PD,SRR->RR_HORAS,SRR->RR_VALOR)
								TOTDESC := TOTDESC + SRR->RR_VALOR
							Endif
							
						Endif
						
						If SRR->RR_PD == aCodFol[013,1]
							nAteLim += SRR->RR_VALOR
						Elseif SRR->RR_PD == aCodFol[016,1]
							nBaseIr += SRR->RR_VALOR
						Elseif SRR->RR_PD == aCodFol[102,1]
							nLiquido := SRR->RR_VALOR
						Endif
						
						SRR->(dbSkip())
						
					Enddo
				EndIf
			Endif
		Endif
		
		dbSelectArea("SRA")
		
		If TOTVENC == 0 .And. TOTDESC == 0
			SRA->(dbSkip())
			Loop
		Endif
		
		If Vez == 0  .And.  nEsc == 2 //--> Verifica se for FOLHA.
			PerSemana() // Carrega Datas referentes a Semana.
		EndIf
		
		nSequenc++
		
		cDataBas	:= DtoC(SRH->RH_DATABAS)
		cDBaseAt	:= DtoC(SRH->RH_DBASEAT)
		cDFerias	:= Str(SRH->RH_DFERIAS)
		cDAbonPe	:= Str(SRH->RH_DABONPE)
		
		//Há dados a ser informado
		If lData
			//-- Verifica se existe registro de movimentação
			If (Len(aProve)>0 .And. Len(aDesco) > 0) .And. !FVldAfas(SRA->RA_FILIAL, SRA->RA_MAT, SRA->RA_SITFOLH)
				//Verifica Header
				If !lHeader				
					// Monta Header da empresa- Registro Tipo "0"
					fMonta0(@nSomFunc)
					//Incrementa de funcionarios				
					lHeader := .T.
				Endif				
				// Monta Header de Lote - Registro Tipo "1"
				fMonta1(@nSomFunc)
				// Monta Header de Lote - Registro Tipo "3" Segmento "E" --> Proventos
				fMonta2E( aProve, "1", @nSomFunc, @nTotProv )
				// Monta Header de Lote - Registro Tipo "3" Segmento "E" --> Descontos
				fMonta2E( aDesco, "3", @nSomFunc, nTotProv )
				// Mensagem
				fMonta3(@nSomFunc)
				//Dependented
				fMonta4(@nSomFunc)
				//
				fMonta5(@nSomFunc)
			EndIf	
		Endif
		
		dbSelectArea("SRA")
		
		dbSkip()
		TOTDESC := TOTVENC := 0
		nTotProv:= 0
		nSoma234:=0
	EndDo
	
	//Ha Dados a Serem Gerados
	If lData						
		fMonta6(@nSomFunc)
	Endif
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona arq. defaut do Siga caso Imp. Mov. Anteriores      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nEsc <> 6
		If !lAtual
			fFimArqMov( cAliasMov , aOrdBag , cArqMov )
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Termino do relatorio                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SRC")
	dbSetOrder(1)          // Retorno a ordem 1
	dbSelectArea("SRI")
	dbSetOrder(1)          // Retorno a ordem 1
	dbSelectArea("SRA")
	SET FILTER TO
	
	fClose( nHdl )
	If !(Type("cNomeArq") == "U")
		fErase(cNomeArq + OrdBagExt())
	Endif
	
	MS_FLUSH()
	
Return()
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} PerSemana
Pesquisa datas referentes a semana.
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function PerSemana()
	
	If !Empty(Semana)
		cChaveSem := StrZero(Year(dDataRef),4)+StrZero(Month(dDataRef),2)+SRA->RA_TNOTRAB
		If !Srx->(dbSeek(If(cFilial=="  ","  ",SRA->RA_FILIAL) + "01" + cChaveSem + Semana , .T. )) .And. ;
				!Srx->(dbSeek(If(cFilial=="  ","  ",SRA->RA_FILIAL) + "01" + Subs(cChaveSem,3,9) + Semana , .T. )) .And. ;
				!Srx->(dbSeek(If(cFilial=="  ","  ",SRA->RA_FILIAL) + "01" + Left(cChaveSem,6)+"999"+ Semana , .T. )) .And. ;
				!Srx->(dbSeek(If(cFilial=="  ","  ",SRA->RA_FILIAL) + "01" + Subs(cChaveSem,3,4)+"999"+ Semana , .T. )) .And. ;
				HELP( " ",1,"SEMNAOCAD" )
			Return Nil
		Endif
		
		If Len(AllTrim(SRX->RX_COD)) == 9
			cSem_De  := Transforma(CtoD(Left(SRX->RX_TXT,8)),"DDMMYY")
			cSem_Ate := Transforma(CtoD(Subs(SRX->RX_TXT,10,8)),"DDMMYY")
		Else
			cSem_De  := Transforma(If("/" $ SRX->RX_TXT , CtoD(SubStr( SRX->RX_TXT, 1,10)) , StoD(SubStr( SRX->RX_TXT, 1,8 ))),"DDMMYY")
			cSem_Ate := Transforma(If("/" $ SRX->RX_TXT , CtoD(SubStr( SRX->RX_TXT, 12,10)), StoD(SubStr( SRX->RX_TXT,12,8 ))),"DDMMYY")
		EndIf
	EndIf
	
Return Nil
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} fSomaPd
Pesquisa datas referentes a semana.
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function fSomaPd(cTipo,cPd,nHoras,nValor)
	
	Local Desc_paga
	
	lData	:= .T.  //Há Dados a serem informados
	
	Desc_paga := DescPd(cPd,Sra->Ra_Filial)  // mostra como pagto
	
	If cTipo #'B'
		//--Array para Recibo Pre-Impresso
		nPos := Ascan(aLanca,{ |X| X[2] = cPd })
		If nPos == 0
			Aadd(aLanca,{cTipo,cPd,Desc_Paga,nHoras,nValor})
		Else
			aLanca[nPos,4] += nHoras
			aLanca[nPos,5] += nValor
		Endif
	Endif
	
	//--Array para o Recibo Pre-Impresso
	If cTipo = 'P'
		cArray := "aProve"
	Elseif cTipo = 'D'
		cArray := "aDesco"
	Elseif cTipo = 'B'
		cArray := "aBases"
	Endif
	
	nPos := Ascan(&cArray,{ |X| X[1] = cPd })
	If nPos == 0
		Aadd(&cArray,{cPd+" "+left(Desc_Paga,19),nHoras,nValor })
	Else
		&cArray[nPos,2] += nHoras
		&cArray[nPos,3] += nValor
	Endif
	
Return()
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} Transforma
Transforma as datas no formato DD/MM/AAAA 
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function Transforma(dData)
	
Return(StrZero(Day(dData),2) +"/"+ StrZero(Month(dData),2) +"/"+ Right(Str(Year(dData)),4))
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} fConvData
Converte a data
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function fConvData( dData, xTipo )
	
	Local cRet := Space(08)
	
	If xTipo == "DDMMAAAA"
		cRet := StrZero(Day(dData),2) + StrZero(Month(dData),2) + StrZero(Year(dData),4)
	ElseIf xTipo == "MMAAAA"
		cRet := StrZero(Month(dData),2) + StrZero(Year(dData),4)
	EndIf
		
Return( cRet )
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} fCheckFer
Converte a data
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function fCheckFer( xTipo)
	
	Local aOld := GETAREA()
	Local cRet := Replicate("0",08)
		
	If SRA->RA_SITFOLH $ " *F*A" // SRP - 30/04/2008 - Incluido a situação "branco" normal.
		SRH->(dbsetorder(2))
		SRH->(dbSeek( SRA->(RA_FILIAL+RA_MAT)+dtos(dDataDe),.t. ))
		If SRH->(RH_FILIAL+RH_MAT) == SRA->(RA_FILIAL+RA_MAT) .and. SRH->RH_DATAINI <= dDataAte
			If xTipo == "INI"
				cRet := fConvData( SRH->RH_DATAINI, "DDMMAAAA" )
				dDtBusFer	:= SRH->RH_DTRECIB
				dDtFerIni   := SRH->RH_DATAINI
			ElseIf xTipo == "FIM"
				cRet := fConvData( SRH->RH_DATAFIM, "DDMMAAAA" )
			EndIf
		EndIf
		SRH->(dbsetorder(1))
	EndIf
	
	
	RESTAREA( aOld )
	
Return( cRet )
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} fConvHora
Converte a Hora
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function fConvHora( cHora )
	
	Local cRet := SubStr(cHora,1,2)+SubStr(cHora,4,2)+SubStr(cHora,7,2)
	
Return( cRet )
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} fMonta0
Monta cabeçalho linha 1
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function fMonta0(nSomFunc)

	Local cSeqArq	:= GetMv('TP_SEQARQ',.F.,'000000000')
	Local cDataAux	:= Dtos(MV_PAR24)
	Local cDtRef	:= SubStr(cDataAux,7,2)+SubStr(cDataAux,5,2)+Left(cDataAux,4)

	cLin := '0'					                        	    		//Tipo de registro [001-001]
	cLin += "REMESSA HPAG EMPRESA"             	            	//Descrição do arquivo [002-021]
	cLin += "000004067"														//Codigo do convenio [022-030]            	                                	
	cLin += Soma1(cSeqArq)       	                  				//Numero do Lote [031-039]
	cLin += '002229411' 	                         	            //Codigo CNPJ [040-048]
	cLin += "0001"                                	            //Filial do CNPJ [049-052]
	cLin += "89"                                	            	//Digito de controle CNPJ [052-054]
	//cLin += cDataRef							                     //Data do Movimento [055-062]
	cLin += cDtRef							                           //Data do Movimento [055-062]
	cLin += 'I'                          								//Referencia da operação do Lote [063-063]
	cLin += '00777'                         			 				//Codigo de lançamento do produto [064-068]
	cLin += Space(155)				                            	//FILLER [069-223]
	cLin += ' '                          								//Indicador da remessa [224-224]
	cLin += Space(09)                          						//Reservado 1 [225-233]
	cLin += Space(12)                          						//Reservado 1 [234-245]
	cLin += StrZero(nSomFunc+=1,5)                          		//Sequencial do Arquivo [246-250]
	cLin += cEol
	
	fGravaTxt()
	
	//Sequencial de geração de arquivo
	PutMv('TP_SEQARQ',Soma1(cSeqArq))
	
Return(Nil)
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} fMonta1
Monta cabeçalho linha 2
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function fMonta1(nIncre)

	Local cDtAux:= DTOS(Mv_Par25)
	Local cDtAux1:= DTOS(Mv_Par26)
	
	cLin := '1'					                        	    							//Tipo de registro [001-001]
	cLin += 'I'             	            												//REFERÊNCIA DA OPERAÇÃO DO COMPROVANTE [002-002]
	cLin += '001'																					//Tipo de comprovante [003-005]
	//cLin += Right(cDataRef,6)       	            									//Mes ano de referencia [006-011]
	cLin += SubStr(cDtAux,5,2)+Left(cDtAux,4)     								      //Mes ano de referencia [006-011]
	//cLin += cDataLib							    											//Data de liberação do comprovante [012-019]
	cLin += SubStr(cDtAux1,7,2)+SubStr(cDtAux1,5,2)+Left(cDtAux1,4)				//Data de liberação do comprovante [012-019]
	cLin += '0237'                                	            					//Banco do funcionario [020-023]
	cLin += '0'+SubStr(SRA->RA_BCDEPSA,4,4)            								//Numero da agencia do funcionario [024-028]	
	cLin += '00'+Left(SRA->RA_CTDEPSA,11)                       					//Numero da conta do funcionario [029-041]
	cLin += Space(01)+Right(SRA->RA_CTDEPSA,1)                  					//Digito da conta [042-043]
	cLin += Left(SRA->RA_CIC,9)                       									//Cpf do funcionario [044-052]
	cLin += Right(SRA->RA_CIC,2)                       								//Digito do Cpf do funcionario [053-054]
	cLin += '00'+SRA->RA_PIS                       										//Pis do funcionario [055-068]
	cLin += Padr(StrTran(StrTran(StrTran(SRA->RA_RG,'M',''),'-',''),'.',''),13)//Numero do RG do funcionario [069-081]
	cLin += FComZeroE(ALLTRIM(SRA->RA_NUMCP),9)+ALLTRIM(SRA->RA_NUMCP)			//Numero dA CTPS do funcionario [082-090]
	cLin += Left(SRA->RA_NOME,30)                  			  							//Nome do funcionario [091-120]
	cLin += '000000'+SRA->RA_MAT                  										//Numero da matricula funcionario [121-132]
	cLin += Space(20)+Posicione('SRJ',1,xFilial('SRJ')+SRA->RA_CODFUNC,'RJ_DESC')//Função do funcionario [133-172]	
	cLin += fConvData(SRA->RA_ADMISSA,'DDMMAAAA')										//Data de admissão do funcionario [173-180]		
	cLin += Space(53)				                            							//FILLER [181-233]
	cLin += Space(12)                          											//Reservado 1 [234-245]	
	cLin += Strzero(nIncre+=1,5)                          							//Sequencial do Arquivo [246-250]
	cLin += cEol
	
	fGravaTxt()         		
	
Return(Nil)
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} fMonta2E

       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function fMonta2E( aTemp, xTipo, nIncre, nTotProv )
	
	Local i, nLen
	Local nSomaPD	:= 0
	Local cTextAux	:= ''
	Local nCalcVerb:= 0
	
	For nLim:= 1 To Len(aTemp)
		cLin := '2'					                        	    				//Tipo de registro [001-001]
		cLin += Left(aTemp[nLim][1],3)+Space(01)		             	      //Codido do lançamento [002-005]
		cLin += Posicione('SRV',1,xFilial('SRV')+Left(aTemp[nLim][1],3),'RV_DESC')//Descrição do lançamento [006-025]
		cLin += FConvVlr(aTemp[nLim][3])
		cLin += xTipo																		//Identificação de lançamento [038-038]	
		cLin += Space(198)				                            			//FILLER [039-236]
		cLin += Space(09)                          								//Reservado [236-245]	
		cLin += Strzero(nIncre+=1,5)                          				//Sequencial do Arquivo [246-250]
		cLin += cEol
		
		fGravaTxt()
		//Somatorio das verbas [Provento/Desconto]		
		nSomaPD+=aTemp[nLim][3]
		
		nSoma234++
		
	Next nLim      					
	
	cTextAux:= IIF(xTipo=='1','TOTAL PROVENTOS','TOTAL DESCONTOS')
	
	cLin := '2'					                        	//Tipo de registro [001-001]
	cLin += Space(04)		             	            	//Codido do lançamento [002-005]
	cLin += cTextAux+Space(5)									//Descrição do lançamento [006-025]
	cLin += FConvVlr(nSomaPD)
	cLin += IIF(xTipo=='1','2','4')							//identificação de lançamento [038-038]	
	cLin += Space(198)				                     //FILLER [039-236]
	cLin += Space(09)                          			//Reservado [236-245]	
	cLin += Strzero(nIncre+=1,5)                       //Sequencial do Arquivo [246-250]
	cLin += cEol
   
   fGravaTxt()  
   
   nSoma234++
   
   If xTipo == '1'
		nTotProv:=nSomaPD
	Else
		nCalcVerb:=nTotProv-nSomaPD
		cLin := '2'					                        	//Tipo de registro [001-001]
		cLin += Space(04)		             	            	//Codido do lançamento [002-005]
		cLin += 'LIQUIDO'+Space(13)								//Descrição do lançamento [006-025]		
		cLin += IIF(nCalcVerb>0,FConvVlr(nCalcVerb),FConvVlr(Abs(nCalcVerb)))
		cLin += IIF(nCalcVerb>0,'5','6')							//identificação de lançamento [038-038]	
		cLin += Space(198)				                     //FILLER [039-236]
		cLin += Space(09)                          			//Reservado [236-245]	
		cLin += Strzero(nIncre+=1,5)                       //Sequencial do Arquivo [246-250]
		cLin += cEol
		fGravaTxt()
		nSoma234++		
	EndIf	
			      
Return(Nil)
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} fMonta3

       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function fMonta3(nSomFunc)

	If !Empty(DESC_MSG1)
		cLin := '3'
		cLin += DESC_MSG1+Space(10) 	                    				//Mensagem [002-041]
		cLin += Space(195)														//Filler [042-236]
		cLin += Space(09)															//Reservado [237-245]
		cLin += Strzero(nSomFunc+=1,5)	
		fGravaTxt()
		nSoma234++
   EndIf
	
	If !Empty(DESC_MSG2)
		cLin := '3'
		cLin := DESC_MSG2+Space(10) 	                    				//Mensagem [002-041]
		cLin += Space(195)														//Filler [042-236]
		cLin += Space(09)															//Reservado [237-245]
		cLin += Strzero(nSomFunc+=1,5)	
		fGravaTxt()
		nSoma234++		
   EndIf
	
	If !Empty(DESC_MSG3)
		cLin := '3'
		cLin := DESC_MSG3+Space(10) 	                    				//Mensagem [002-041]
		cLin += Space(195)														//Filler [042-236]
		cLin += Space(09)															//Reservado [237-245]
		cLin += Strzero(nSomFunc+=1,5)	
		fGravaTxt()
		nSoma234++		
   EndIf

Return(Nil)            
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} fMonta4

       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function fMonta4(nSomFunc)
	
	Local cDtPag	:= Dtos(MV_PAR26)
	Local cDtPagAux:= SubStr(cDtPag,7,2)+SubStr(cDtPag,5,2)+Left(cDtPag,4)

	cLin := '4'					                        	   	//TIpo de registro [001-001]
	//cLin += cDataPag								               //REFERÊNCIA DA OPERAÇÃO DO COMPROVANTE [002-002]
	cLin += cDtPagAux								               	//REFERÊNCIA DA OPERAÇÃO DO COMPROVANTE [002-002]
	cLin += IIF(Empty(SRA->RA_DEPIR),'00',SRA->RA_DEPIR)		//Numero de dependete IRRF [010-011]
	cLin += IIF(Empty(SRA->RA_DEPSF),'00',SRA->RA_DEPSF)		//Numero de dependete Salario Familia [012-013]
	cLin += AllTrim(Str(SRA->RA_HRSEMAN))       	            //Horas trabalhadas semanalmente [014-015]
	cLin += FConvVlr(SRA->RA_SALARIO) 								//Data de liberação do comprovante [016-027]
	cLin += FComZeroE('',2)                                	//Quantidade Faltas, Periodo de Ferias [028-029]
	cLin += 'S'                                              //Indicador de impressao de dados bancarios [030-030]
	cLin += FComZeroE('',128)                          		//Campos em branco [Ajuste]
	cLin += Space(78)														//Filler [159-236]
	cLin += Space(9)														//Reservado [237-245]
	cLin += Strzero(nSomFunc+=1,5)                          	//Sequencial do Arquivo [246-250]
	cLin += cEol
	
	fGravaTxt()
	nSoma234++

Return(Nil)
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} fMonta5

       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function fMonta5(nSomFunc)

	cLin := '5'					                        	   	//TIpo de registro [001-001]
	cLin += StrZero(nSoma234,5)             						//Total de lançamento do comprovante [002-006]
	cLin += Space(230)													//Filler [007-236]
	cLin += Space(09)														//Reservadro [237-245]
	cLin += Strzero(nSomFunc+=1,5)
	cLin += cEol
	fGravaTxt()

Return(Nil)
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} fMonta6

       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function fMonta6(nSomFunc)

	cLin := '9'					                        	   	//TIpo de registro [001-001]
	cLin += StrZero(nSomFunc+=1,5)             					//Total de registros do lote [002-006]
	cLin += Space(230)													//Filler [007-236]
	cLin += Space(09)														//Reservadro [237-245]
	cLin += Strzero(nSomFunc,5)
	
	fGravaTxt()

Return(Nil)
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} fGravaTxt
Funçao utilizada para realizar escrita no arquivo
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function fGravaTxt()
	
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
	Endif
	
Return()
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} fRecibos
Opçao de recibo
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
User Function fRecibos()
	
	Local cTitulo	:=	""
	Local MvParDef	:=	""
	Local l1Elem 	:= .T.
	Local MvPar		:= ""
	Local oWnd
	Local cTipoAu
	
	Private aResul	:={}
	
	oWnd 	:= GetWndDefault()
	MvPar	:=	&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet	:=	Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	
	cTitulo := "Tipos de Recibos"
	aResul  := {"Adiantamento","Folha","1a Parcela","2a Parcela","Extra","Ferias"}
	
	MvParDef:=	"123456"
	
	f_Opcoes(@MvPar,cTitulo,aResul,MvParDef,12,49,l1Elem,,1)		// Chama funcao f_Opcoes
	&MvRet := mvpar 					   	// Devolve Resultado
	
Return()
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} fAsrPerg
Função utilizada para Criar pergunta
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function fAsrPerg()
	
	Local aRegs		:= {}
	Local aHelp		:= {}
	Local aHelpE	:= {}
	Local aHelpI	:= {}
	Local cHelp		:= ""
	
	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs,{ cPerg,'01','Data de Referencia           ?','Data de Referencia           ?','Data de Referencia           ?','mv_ch1','D',08,0,0,'G','NaoVazio'   ,'mv_par01',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	
	
	aHelp := {	"Informe o tipo de recibo que deseja ",;
		"emitir. Apenas um tipo de recibo ",;
		"podera ser selecionado." }
	aHelpE:= {	"Informe o tipo de recibo que deseja ",;
		"emitir. Apenas um tipo de recibo ",;
		"podera ser selecionado." }
	aHelpI:= {	"Informe o tipo de recibo que deseja ",;
		"emitir. Apenas um tipo de recibo ",;
		"podera ser selecionado." }
	cHelp := ".GDLQIT02."
	
	aAdd(aRegs,{cPerg,'02','Emitir Recibos?'		,'Emitir Recibos?'	,'Emitir Recibos?'	,'MV_CH2','C',06,0,0,'G','U_fRecibos()','MV_PAR02',''                ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','','',aHelp  ,aHelpI   ,aHelpE  ,cHelp})
	aAdd(aRegs,{cPerg,'03','Numero da Semana?'	,'Numero da Semana?'	,'Numero da Semana?'	,'mv_ch3','C',02,0,0,'G',''           ,'mv_par03',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{cPerg,'04','Filial De?'				,'Filial De?'			,'Filial De?'			,'mv_ch4','C',06,0,0,'G',''           ,'mv_par04',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'SM0','' })
	aAdd(aRegs,{cPerg,'05','Filial Ate?'			,'Filial Ate?'			,'Filial Ate?'			,'mv_ch5','C',06,0,0,'G','NaoVazio'   ,'mv_par05',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'SM0','' })
	aAdd(aRegs,{cPerg,'06','Centro Custo De?'		,'Centro Custo De?'	,'Centro Custo De?'	,'mv_ch6','C',09,0,0,'G',''           ,'mv_par06',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'CTT','' })
	aAdd(aRegs,{cPerg,'07','Centro Custo Ate?'	,'Centro Custo Ate?'	,'Centro Custo Ate?'	,'mv_ch7','C',09,0,0,'G','NaoVazio'   ,'mv_par07',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'CTT','' })
	aAdd(aRegs,{cPerg,'08','Matricula De?'			,'Matricula De?'		,'Matricula De?'		,'mv_ch8','C',06,0,0,'G',''           ,'mv_par08',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'SRA','' })
	aAdd(aRegs,{cPerg,'09','Matricula Ate?'		,'Matricula Ate?'		,'Matricula Ate?'		,'mv_ch9','C',06,0,0,'G','NaoVazio'   ,'mv_par09',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'SRA','' })
	aAdd(aRegs,{cPerg,'10','Mensagem 1?'			,'Mensagem 1?'			,'Mensagem 1?'			,'mv_cha','C',01,0,0,'G',''           ,'mv_par10',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{cPerg,'11','Mensagem 2?'			,'Mensagem 2?'			,'Mensagem 2?'			,'mv_chb','C',01,0,0,'G',''           ,'mv_par11',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{cPerg,'12','Mensagem 3?'			,'Mensagem 3?'			,'Mensagem 3?'			,'mv_chc','C',01,0,0,'G',''           ,'mv_par12',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{cPerg,'13','Situacoes?'			,'Situacoes?'			,'Situacoes?'			,'mv_chd','C',05,0,0,'G','fSituacao'  ,'mv_par13',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{cPerg,'14','Categorias?'			,'Categorias?'			,'Categorias?'			,'mv_che','C',12,0,0,'G','fCategoria' ,'mv_par14',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{cPerg,'15','Arquivo de Saida?'		,'Arquivo de Saida?'	,'Arquivo de Saida?'	,'mv_chf','C',30,0,0,'G','NaoVazio'   ,'mv_par15',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{cPerg,'16','Data Para Pagamento?'	,'Data Para Pagamento?'	,'Data Para Pagamento?'	,'mv_chg','D',08,0,0,'G','NaoVazio'   ,'mv_par16',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{cPerg,'17','Data de Ferias De?'	,'Data de Ferias De?'	,'Data de Ferias De?'	,'mv_chh','D',08,0,0,'G',''           ,'mv_par17',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{cPerg,'18','Data de Ferias Ate?'	,'Data de Ferias Ate?'	,'Data de Ferias Ate?'	,'mv_chi','D',08,0,0,'G','NaoVazio'   ,'mv_par18',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	
	aHelp := {"Informe o Banco a Ser Gerado do CNAB"}
	aHelpE:= {"Informe o Banco a Ser Gerado do CNAB"}
	aHelpI:= {"Informe o Banco a Ser Gerado do CNAB"}
	cHelp := ".GDLCNAB."
	
	Aadd(aRegs,{cPerg,'19' ,'CNAB do Banco?','CNAB do Banco?'		,'CNAB do Banco?'		,'mv_chj','N' ,01,0,1,'C','          ','_mv_par19','Banco Bradesco ','','','','','','','','','','','','','','','','','','','','','','','','','','',aHelp  ,aHelpI   ,aHelpE  ,cHelp})
	aAdd(aRegs,{cPerg,'20','Banco?'		,'Banco?'		,'Banco?'		,'mv_chk','C',03,0,0,'G','NaoVazio','mv_par20',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'SEE','' })
	aAdd(aRegs,{cPerg,'21','Agencia?'		,'Agencia?'		,'Agencia?'		,'mv_chl','C',05,0,0,'G','NaoVazio','mv_par21',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'SEE','' })
	aAdd(aRegs,{cPerg,'22','Conta?'		,'Conta?'		,'Conta?'		,'mv_chm','C',10,0,0,'G','NaoVazio','mv_par22',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'SEE','' })	
	aAdd(aRegs,{cPerg,'23','Sub-Conta?'	,'Sub-Conta?'	,'Sub-Conta?'	,'mv_chn','C',03,0,0,'G','NaoVazio','mv_par23',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'SEE','' })

	aAdd(aRegs,{cPerg,'24','Data Referencia?'	,'Data Referencia?'	,'Data Referencia?','mv_chn','D',08,0,0,'G','NaoVazio','mv_par24','','','','','','','','','','','','','','','','','','','','','','','','' ,'','' })
	aAdd(aRegs,{cPerg,'25','Período?'	,'Período?'	,'Período?','mv_chn','D',08,0,0,'G','NaoVazio','mv_par25','','','','','','','','','','','','','','','','','','','','','','','','' ,'','' })
	aAdd(aRegs,{cPerg,'26','Data PGTO? (dia útil)'	,'Data PGTO? (dia útil)'	,'Data PGTO? (dia útil)','mv_chn','D',08,0,0,'G','NaoVazio','mv_par26','','','','','','','','','','','','','','','','','','','','','','','','' ,'','' })
	
	ValidPerg(aRegs,cPerg)
	
Return()
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} FConvVlr
Função utilizada para converter valores
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function FConvVlr(nVlr)

	Local cVlrAux:= Replicate('0',12-Len(StrTran(Alltrim(Transform(nVlr, "@E 999999.99" )),',','')))+StrTran(Alltrim(Transform(nVlr, "@E 999999.99" )),',','')

Return(cVlrAux)
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} FComZeroE
Função utilizada para incluir zeros a esquerda
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function FComZeroE(cStr, nQuant)
Return(Replicate('0',nQuant-(Len(cStr))))
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} FVldAfas
Função utilizada para validar afastamento
       
@author		.iNi Sistemas
@since     	01/11/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
Static Function FVldAfas(cFilAux, cMatFunc, cSit)

	Local lRet		:= .F.
	Local cQuery	:= ''
	Local cAliasTrb:= GetNextAlias()
	Local cMesRef	:= GetMv('MV_FOLMES')
	Local nUltDiaM	:= Val(Right(DtoS(Lastday(Stod(GetMv('MV_FOLMES')+'01'),2)),2))//Transforma ultimo dia do mes
		
	cQuery+=Chr(13)+Chr(10)+" SELECT TOP 1 R8_DATAINI "
	cQuery+=Chr(13)+Chr(10)+" FROM "+RetSqlName('SR8')+" "
	cQuery+=Chr(13)+Chr(10)+" WHERE R8_FILIAL = '"+cFilAux+"' "
	cQuery+=Chr(13)+Chr(10)+" AND R8_MAT 		= '"+cMatFunc+"' "
	If cSit <> 'A'
		cQuery+=Chr(13)+Chr(10)+" AND LEFT(R8_DATAINI,6) = '"+cMesRef+"' "
	EndIf	
	cQuery+=Chr(13)+Chr(10)+" AND R8_TIPO <> 'F' "
	cQuery+=Chr(13)+Chr(10)+" AND R8_DURACAO >= '15' "
	cQuery+=Chr(13)+Chr(10)+" AND D_E_L_E_T_ <> '*' "		
	cQuery+=Chr(13)+Chr(10)+" ORDER BY R8_DATAINI DESC "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.F.,.T.)
	
	(cAliasTrb)->(DbGoTop())
	If (cAliasTrb)->(!Eof())
		If Left((cAliasTrb)->R8_DATAINI,6) == GetMv('MV_FOLMES')
			lRet:= (nUltDiaM - Val(Right((cAliasTrb)->R8_DATAINI,2))) >= 15
		Else
			lRet:=.T.
		EndIf	
	EndIf
	//--Fecha tabela temporaria
	(cAliasTrb)->(DbCloseArea())

Return(lRet)