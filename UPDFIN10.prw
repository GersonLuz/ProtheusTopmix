#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ UPDFST   บ Autor ณ TOTVS Protheus     บ Data ณ  29/03/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de update dos dicionแrios para compatibiliza็ใo     ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ UPDFST     - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function UPDFIN10( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAวรO DE DICIONมRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como fun็ใo fazer  a atualiza็ใo  dos dicionแrios do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja nใo podem haver outros"
Local   cDesc3    := "usuแrios  ou  jobs utilizando  o sistema.  ษ extremamente recomendav้l  que  se  fa็a um"
Local   cDesc4    := "BACKUP  dos DICIONมRIOS  e da  BASE DE DADOS antes desta atualiza็ใo, para que caso "
Local   cDesc5    := "ocorra eventuais falhas, esse backup seja ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk
	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualiza็ใo dos dicionแrios ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

		If lAuto
			If lOk
				MsgStop( "Atualiza็ใo Realizada.", "UPDFST" )
				dbCloseAll()
			Else
				MsgStop( "Atualiza็ใo nใo Realizada.", "UPDFST" )
				dbCloseAll()
			EndIf
		Else
			If lOk
				Final( "Atualiza็ใo Concluํda." )
			Else
				Final( "Atualiza็ใo nใo Realizada." )
			EndIf
		EndIf

		Else
			MsgStop( "Atualiza็ใo nใo Realizada.", "UPDFST" )

		EndIf

	Else
		MsgStop( "Atualiza็ใo nใo Realizada.", "UPDFST" )

	EndIf

EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSTProc  บ Autor ณ TOTVS Protheus     บ Data ณ  29/03/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da grava็ใo dos arquivos           ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSTProc    - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSTProc( lEnd, aMarcadas )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// So adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualiza็ใo da empresa " + aRecnoSM0[nI][2] + " nใo efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF + CRLF

			oProcess:SetRegua1( 8 )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o dicionแrio SX2         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oProcess:IncRegua1( "Dicionแrio de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX2( @cTexto )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o dicionแrio SX3         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			FSAtuSX3( @cTexto )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o dicionแrio SIX         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oProcess:IncRegua1( "Dicionแrio de ํndices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSIX( @cTexto )

			oProcess:IncRegua1( "Dicionแrio de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/ํndices" )

			// Alteracao fisica dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualiza็ใo da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionแrio e da tabela.", "ATENวรO" )
					cTexto += "Ocorreu um erro desconhecido durante a atualiza็ใo da estrutura da tabela : " + aArqUpd[nX] + CRLF
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o dicionแrio SX6         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oProcess:IncRegua1( "Dicionแrio de parโmetros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX6( @cTexto )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o dicionแrio SX7         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oProcess:IncRegua1( "Dicionแrio de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX7( @cTexto )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o dicionแrio SXB         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oProcess:IncRegua1( "Dicionแrio de consultas padrใo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXB( @cTexto )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza os helps                 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuHlp( @cTexto )

			RpcClearEnv()

		Next nI

		If MyOpenSm0(.T.)

			cAux += Replicate( "-", 128 ) + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += "LOG DA ATUALIZACAO DOS DICIONมRIOS" + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF
			cAux += " Dados Ambiente" + CRLF
			cAux += " --------------------"  + CRLF
			cAux += " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt  + CRLF
			cAux += " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
			cAux += " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
			cAux += " DataBase...........: " + DtoC( dDataBase )  + CRLF
			cAux += " Data / Hora Inicio.: " + DtoC( Date() )  + " / " + Time()  + CRLF
			cAux += " Environment........: " + GetEnvServer()  + CRLF
			cAux += " StartPath..........: " + GetSrvProfString( "StartPath", "" )  + CRLF
			cAux += " RootPath...........: " + GetSrvProfString( "RootPath" , "" )  + CRLF
			cAux += " Versao.............: " + GetVersao(.T.)  + CRLF
			cAux += " Usuario TOTVS .....: " + __cUserId + " " +  cUserName + CRLF
			cAux += " Computer Name......: " + GetComputerName() + CRLF

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				cAux += " "  + CRLF
				cAux += " Dados Thread" + CRLF
				cAux += " --------------------"  + CRLF
				cAux += " Usuario da Rede....: " + aInfo[nPos][1] + CRLF
				cAux += " Estacao............: " + aInfo[nPos][2] + CRLF
				cAux += " Programa Inicial...: " + aInfo[nPos][5] + CRLF
				cAux += " Environment........: " + aInfo[nPos][6] + CRLF
				cAux += " Conexao............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) )  + CRLF
			EndIf
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF

			cTexto := cAux + cTexto + CRLF

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
			cTexto += Replicate( "-", 128 ) + CRLF

			cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cTexto )

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualizacao concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuSX2 บ Autor ณ TOTVS Protheus     บ Data ณ  29/03/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SX2 - Arquivos      ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuSX2   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAtuSX2( cTexto )
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

cTexto  += "Inicio da Atualizacao" + " SX2" + CRLF + CRLF

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"  , "X2_NOMESPA", "X2_NOMEENG", ;
             "X2_DELET"  , "X2_MODO"   , "X2_TTS"    , "X2_ROTINA", "X2_PYME"   , "X2_UNICO"  , ;
             "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO"} 


dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela P05
//
aAdd( aSX2, { ;
	'P05'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'P05'+cEmpr																, ; //X2_ARQUIVO
	'OPERADORAS DE CARTAO'													, ; //X2_NOME
	'OPERADORAS DE CARTAO'													, ; //X2_NOMESPA
	'OPERADORAS DE CARTAO'													, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela P06
//
aAdd( aSX2, { ;
	'P06'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'P06'+cEmpr																, ; //X2_ARQUIVO
	'PRE RECEBIMENTO DE TITULOS'											, ; //X2_NOME
	'PRE RECEBIMENTO DE TITULOS'											, ; //X2_NOMESPA
	'PRE RECEBIMENTO DE TITULOS'											, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Atualizando dicionแrio
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			cTexto += "Foi incluํda a tabela " + aSX2[nI][1] + CRLF
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
				cTexto += "Foi alterada chave unica da tabela " + aSX2[nI][1] + CRLF
			Else
				cTexto += "Foi criada   chave unica da tabela " + aSX2[nI][1] + CRLF
			EndIf
		EndIf

	EndIf

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuSX3 บ Autor ณ TOTVS Protheus     บ Data ณ  29/03/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SX3 - Campos        ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuSX3   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAtuSX3( cTexto )
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

cTexto  += "Inicio da Atualizacao" + " SX3" + CRLF + CRLF

aEstrut := { "X3_ARQUIVO", "X3_ORDEM"  , "X3_CAMPO"  , "X3_TIPO"   , "X3_TAMANHO", "X3_DECIMAL", ;
             "X3_TITULO" , "X3_TITSPA" , "X3_TITENG" , "X3_DESCRIC", "X3_DESCSPA", "X3_DESCENG", ;
             "X3_PICTURE", "X3_VALID"  , "X3_USADO"  , "X3_RELACAO", "X3_F3"     , "X3_NIVEL"  , ;
             "X3_RESERV" , "X3_CHECK"  , "X3_TRIGGER", "X3_PROPRI" , "X3_BROWSE" , "X3_VISUAL" , ;
             "X3_CONTEXT", "X3_OBRIGAT", "X3_VLDUSER", "X3_CBOX"   , "X3_CBOXSPA", "X3_CBOXENG", ;
             "X3_PICTVAR", "X3_WHEN"   , "X3_INIBRW" , "X3_GRPSXG" , "X3_FOLDER" , "X3_PYME"   }

//
// Tabela P05
//
aAdd( aSX3, { ;
	'P05'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'P05_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P05'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'P05_REFOPE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ref.Operador'															, ; //X3_TITULO
	'Ref.Operador'															, ; //X3_TITSPA
	'Ref.Operador'															, ; //X3_TITENG
	'Ref. Operadora'														, ; //X3_DESCRIC
	'Ref. Operadora'														, ; //X3_DESCSPA
	'Ref. Operadora'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'GETSXENUM("P05","P05_REFOPE")'											, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P05'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'P05_CODOPE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod Operador'															, ; //X3_TITULO
	'Cod Operador'															, ; //X3_TITSPA
	'Cod Operador'															, ; //X3_TITENG
	'Codigo Operadora'														, ; //X3_DESCRIC
	'Codigo Operadora'														, ; //X3_DESCSPA
	'Codigo Operadora'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SA1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	'ExistCpo("SA1") .And. ExistChav("P05",M->P05_CODOPE+M->P05_LOJA,2)'	, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'!ALTERA'																, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'001'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P05'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'P05_LOJA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Loja'																	, ; //X3_TITULO
	'Loja'																	, ; //X3_TITSPA
	'Loja'																	, ; //X3_TITENG
	'Loja'																	, ; //X3_DESCRIC
	'Loja'																	, ; //X3_DESCSPA
	'Loja'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	'existcpo("SA1",M->P05_CODOPE+M->P05_LOJA  ) .And. ExistChav("P05",M->P05_CODOPE+M->P05_LOJA,2)', ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'!ALTERA'																, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'002'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P05'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'P05_CNPJ'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'CNPJ'																	, ; //X3_TITULO
	'CNPJ'																	, ; //X3_TITSPA
	'CNPJ'																	, ; //X3_TITENG
	'CNPJ da Operadora'														, ; //X3_DESCRIC
	'CNPJ da Operadora'														, ; //X3_DESCSPA
	'CNPJ da Operadora'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'Posicione("SA1",1,xFilial("SA1") + M->P05_CODOPE+M->P05_LOJA,"A1_CGC")'	, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P05'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'P05_PESSOA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Pessoa'															, ; //X3_TITULO
	'Tipo Pessoa'															, ; //X3_TITSPA
	'Tipo Pessoa'															, ; //X3_TITENG
	'Tipo Pessoa'															, ; //X3_DESCRIC
	'Tipo Pessoa'															, ; //X3_DESCSPA
	'Tipo Pessoa'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Pertence("JF")'														, ; //X3_VLDUSER
	'F=Fisica;J=Juridica'													, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P05'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'P05_BAND'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Bandeira'																, ; //X3_TITULO
	'Bandeira'																, ; //X3_TITSPA
	'Bandeira'																, ; //X3_TITENG
	'Bandeira  da operadora'												, ; //X3_DESCRIC
	'Bandeira  da operadora'												, ; //X3_DESCSPA
	'Bandeira  da operadora'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P05'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'P05_DESCRI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Descricao'																, ; //X3_TITULO
	'Descricao'																, ; //X3_TITSPA
	'Descricao'																, ; //X3_TITENG
	'Descricao da Operadora'												, ; //X3_DESCRIC
	'Descricao da Operadora'												, ; //X3_DESCSPA
	'Descricao da Operadora'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P05'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'P05_TIPO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo'																	, ; //X3_TITULO
	'Tipo'																	, ; //X3_TITSPA
	'Tipo'																	, ; //X3_TITENG
	'Tipo (Debito/Credito)'													, ; //X3_DESCRIC
	'Tipo (Debito/Credito)'													, ; //X3_DESCSPA
	'Tipo (Debito/Credito)'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"CC"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'CD=Debito; CC=Credito'													, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P05'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'P05_TAXA'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Taxa'																	, ; //X3_TITULO
	'Taxa'																	, ; //X3_TITSPA
	'Taxa'																	, ; //X3_TITENG
	'Percentual de Taxa'													, ; //X3_DESCRIC
	'Percentual de Taxa'													, ; //X3_DESCSPA
	'Percentual de Taxa'													, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P05'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'P05_VENPAD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Venc Padrao'															, ; //X3_TITULO
	'Venc Padrao'															, ; //X3_TITSPA
	'Venc Padrao'															, ; //X3_TITENG
	'Vencimento Padrao'														, ; //X3_DESCRIC
	'Vencimento Padrao'														, ; //X3_DESCSPA
	'Vencimento Padrao'														, ; //X3_DESCENG
	'@E 999'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'positivo() .and.  M->P05_VENPAD <= 31'									, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P05'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'P05_VENFIN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Venc Financ'															, ; //X3_TITULO
	'Venc Financ'															, ; //X3_TITSPA
	'Venc Financ'															, ; //X3_TITENG
	'Vencimento Financiado'													, ; //X3_DESCRIC
	'Vencimento Financiado'													, ; //X3_DESCSPA
	'Vencimento Financiado'													, ; //X3_DESCENG
	'@E 999'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

//
// Tabela P06
//
aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'P06_STATUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status'																, ; //X3_TITULO
	'Status'																, ; //X3_TITSPA
	'Status'																, ; //X3_TITENG
	'Status do Pre Recebimento'												, ; //X3_DESCRIC
	'Status do Pre Recebimento'												, ; //X3_DESCSPA
	'Status do Pre Recebimento'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	'IIF(INCLUI,"P", M->P06_STATUS)'										, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'P06_ID'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod ID'																, ; //X3_TITULO
	'Cod ID'																, ; //X3_TITSPA
	'Cod ID'																, ; //X3_TITENG
	'Codigo de Identificacao'												, ; //X3_DESCRIC
	'Codigo de Identificacao'												, ; //X3_DESCSPA
	'Codigo de Identificacao'												, ; //X3_DESCENG
	'@R 99999999999999999-9'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,U_FSCRIAID(),M->P06_ID)'									, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	'ExistChav("P06")'														, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'P06_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'P06_CODCLI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Cliente'															, ; //X3_TITULO
	'Cod.Cliente'															, ; //X3_TITSPA
	'Cod.Cliente'															, ; //X3_TITENG
	'Codigo do Cliente'														, ; //X3_DESCRIC
	'Codigo do Cliente'														, ; //X3_DESCSPA
	'Codigo do Cliente'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SA1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	'ExistCpo("SA1")'														, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'001'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'P06_LOJA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Loja'																	, ; //X3_TITULO
	'Loja'																	, ; //X3_TITSPA
	'Loja'																	, ; //X3_TITENG
	'Loja do cliente'														, ; //X3_DESCRIC
	'Loja do cliente'														, ; //X3_DESCSPA
	'Loja do cliente'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'002'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'P06_PESSOA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Fisica/Jurid'															, ; //X3_TITULO
	'Fisica/Jurid'															, ; //X3_TITSPA
	'Fisica/Jurid'															, ; //X3_TITENG
	'Pessoa Fisica/Juridica'												, ; //X3_DESCRIC
	'Pessoa Fisica/Juridica'												, ; //X3_DESCSPA
	'Pessoa Fisica/Juridica'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,"", Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_PESSOA"))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'F=Fisica;J=Juridica'													, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'P06_CGC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'CNPJ\CPF'																, ; //X3_TITULO
	'CNPJ\CPF'																, ; //X3_TITSPA
	'CNPJ\CPF'																, ; //X3_TITENG
	'CNPJ ou CPF'															, ; //X3_DESCRIC
	'CNPJ ou CPF'															, ; //X3_DESCSPA
	'CNPJ ou CPF'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,"", Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_CGC"))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'P06_NOME'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome'																	, ; //X3_TITULO
	'Nome'																	, ; //X3_TITSPA
	'Nome'																	, ; //X3_TITENG
	'Nome do cliente'														, ; //X3_DESCRIC
	'Nome do cliente'														, ; //X3_DESCSPA
	'Nome do cliente'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,"", Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_NOME"))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'P06_END'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'End'																	, ; //X3_TITULO
	'End'																	, ; //X3_TITSPA
	'End'																	, ; //X3_TITENG
	'Endereco do cliente'													, ; //X3_DESCRIC
	'Endereco do cliente'													, ; //X3_DESCSPA
	'Endereco do cliente'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,"", Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_END"))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'P06_BAIRRO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Bairro'																, ; //X3_TITULO
	'Bairro'																, ; //X3_TITSPA
	'Bairro'																, ; //X3_TITENG
	'Bairro do cliente'														, ; //X3_DESCRIC
	'Bairro do cliente'														, ; //X3_DESCSPA
	'Bairro do cliente'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,"", Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_BAIRRO"))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'P06_MUN'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Municipio'																, ; //X3_TITULO
	'Municipio'																, ; //X3_TITSPA
	'Municipio'																, ; //X3_TITENG
	'Municipio do cliente'													, ; //X3_DESCRIC
	'Municipio do cliente'													, ; //X3_DESCSPA
	'Municipio do cliente'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,"", Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_MUN"))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'P06_ESTADO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Estado'																, ; //X3_TITULO
	'Estado'																, ; //X3_TITSPA
	'Estado'																, ; //X3_TITENG
	'Estado'																, ; //X3_DESCRIC
	'Estado'																, ; //X3_DESCSPA
	'Estado'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,"", Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_EST"))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'P06_CEP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cep'																	, ; //X3_TITULO
	'Cep'																	, ; //X3_TITSPA
	'Cep'																	, ; //X3_TITENG
	'Cep do cliente'														, ; //X3_DESCRIC
	'Cep do cliente'														, ; //X3_DESCSPA
	'Cep do cliente'														, ; //X3_DESCENG
	'@R 99999-999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,"", Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_CEP"))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'P06_INSCR'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	18																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ins. Estad.'															, ; //X3_TITULO
	'Ins. Estad.'															, ; //X3_TITSPA
	'Ins. Estad.'															, ; //X3_TITENG
	'Inscricao Estadual'													, ; //X3_DESCRIC
	'Inscricao Estadual'													, ; //X3_DESCSPA
	'Inscricao Estadual'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,"", Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_INSCR"))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'P06_TEL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Telefone'																, ; //X3_TITULO
	'Telefone'																, ; //X3_TITSPA
	'Telefone'																, ; //X3_TITENG
	'Telefone do cliente'													, ; //X3_DESCRIC
	'Telefone do cliente'													, ; //X3_DESCSPA
	'Telefone do cliente'													, ; //X3_DESCENG
	'@R 9999-9999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,"", Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_TEL"))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'P06_EMAIL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'E-Mail'																, ; //X3_TITULO
	'E-Mail'																, ; //X3_TITSPA
	'E-Mail'																, ; //X3_TITENG
	'E-Mail'																, ; //X3_DESCRIC
	'E-Mail'																, ; //X3_DESCSPA
	'E-Mail'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,"", Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_EMAIL"))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'P06_BANCO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Banco'																, ; //X3_TITULO
	'Cod.Banco'																, ; //X3_TITSPA
	'Cod.Banco'																, ; //X3_TITENG
	'Codigo Banco'															, ; //X3_DESCRIC
	'Codigo Banco'															, ; //X3_DESCSPA
	'Codigo Banco'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SA6'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	'ExistCpo("SA6")'														, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'18'																	, ; //X3_ORDEM
	'P06_AGENCI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nro Agencia'															, ; //X3_TITULO
	'Nro Agencia'															, ; //X3_TITSPA
	'Nro Agencia'															, ; //X3_TITENG
	'Agencia do banco'														, ; //X3_DESCRIC
	'Agencia do banco'														, ; //X3_DESCSPA
	'Agencia do banco'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'19'																	, ; //X3_ORDEM
	'P06_NUMCON'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nro Conta'																, ; //X3_TITULO
	'Nro Conta'																, ; //X3_TITSPA
	'Nro Conta'																, ; //X3_TITENG
	'Conta Corrente no Banco'												, ; //X3_DESCRIC
	'Conta Corrente no Banco'												, ; //X3_DESCSPA
	'Conta Corrente no Banco'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'20'																	, ; //X3_ORDEM
	'P06_PREFIX'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Prefixo'																, ; //X3_TITULO
	'Prefixo'																, ; //X3_TITSPA
	'Prefixo'																, ; //X3_TITENG
	'Prefixo do titulo'														, ; //X3_DESCRIC
	'Prefixo do titulo'														, ; //X3_DESCSPA
	'Prefixo do titulo'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	'U_FSP06NUM(M->P06_PREFIX)'												, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'!ALTERA'																, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'21'																	, ; //X3_ORDEM
	'P06_NUM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nro Titulo'															, ; //X3_TITULO
	'Nro Titulo'															, ; //X3_TITSPA
	'Nro Titulo'															, ; //X3_TITENG
	'Numero do Titulo'														, ; //X3_DESCRIC
	'Numero do Titulo'														, ; //X3_DESCSPA
	'Numero do Titulo'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'018'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'22'																	, ; //X3_ORDEM
	'P06_NATURE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Natureza'																, ; //X3_TITULO
	'Natureza'																, ; //X3_TITSPA
	'Natureza'																, ; //X3_TITENG
	'Codigo da natureza'													, ; //X3_DESCRIC
	'Codigo da natureza'													, ; //X3_DESCSPA
	'Codigo da natureza'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SED'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	'ExistCpo("SED")'														, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'23'																	, ; //X3_ORDEM
	'P06_VALOR'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr.Titulo'															, ; //X3_TITULO
	'Vlr.Titulo'															, ; //X3_TITSPA
	'Vlr.Titulo'															, ; //X3_TITENG
	'Valor do Titulo'														, ; //X3_DESCRIC
	'Valor do Titulo'														, ; //X3_DESCSPA
	'Valor do Titulo'														, ; //X3_DESCENG
	'@E 99,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'24'																	, ; //X3_ORDEM
	'P06_TIPO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Deposit'															, ; //X3_TITULO
	'Tipo Deposit'															, ; //X3_TITSPA
	'Tipo Deposit'															, ; //X3_TITENG
	'Tipo Deposito'															, ; //X3_DESCRIC
	'Tipo Deposito'															, ; //X3_DESCSPA
	'Tipo Deposito'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI,"R$", M->P06_TIPO)'											, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	'Pertence("R$CH")'														, ; //X3_VLDUSER
	'R$=Dinheiro; CH=Cheque'												, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'25'																	, ; //X3_ORDEM
	'P06_EMISSA'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Emis'																, ; //X3_TITULO
	'Data Emis'																, ; //X3_TITSPA
	'Data Emis'																, ; //X3_TITENG
	'Data Emissao'															, ; //X3_DESCRIC
	'Data Emissao'															, ; //X3_DESCSPA
	'Data Emissao'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF(INCLUI, DDATABASE , M-> P06_EMISSA)'								, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'26'																	, ; //X3_ORDEM
	'P06_HISTOR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	25																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Historico'																, ; //X3_TITULO
	'Historico'																, ; //X3_TITSPA
	'Historico'																, ; //X3_TITENG
	'Historico do Titulo'													, ; //X3_DESCRIC
	'Historico do Titulo'													, ; //X3_DESCSPA
	'Historico do Titulo'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'27'																	, ; //X3_ORDEM
	'P06_DEPOSI'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt Deposito'															, ; //X3_TITULO
	'Dt Deposito'															, ; //X3_TITSPA
	'Dt Deposito'															, ; //X3_TITENG
	'Data do Deposito'														, ; //X3_DESCRIC
	'Data do Deposito'														, ; //X3_DESCSPA
	'Data do Deposito'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P06'																	, ; //X3_ARQUIVO
	'28'																	, ; //X3_ORDEM
	'P06_DIMPRE'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt Impressao'															, ; //X3_TITULO
	'Dt Impressao'															, ; //X3_TITSPA
	'Dt Impressao'															, ; //X3_TITENG
	'Data de Impressao ID'													, ; //X3_DESCRIC
	'Data de Impressao ID'													, ; //X3_DESCSPA
	'Data de Impressao ID'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

//
// Tabela SE1
//
aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'E1_ZCARTAO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pg c/ Cartao'															, ; //X3_TITULO
	'Pg c/ Cartao'															, ; //X3_TITSPA
	'Pg c/ Cartao'															, ; //X3_TITENG
	'Pagamento com Cartao'													, ; //X3_DESCRIC
	'Pagamento com Cartao'													, ; //X3_DESCSPA
	'Pagamento com Cartao'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"N"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	'Pertence("SN")'														, ; //X3_VLDUSER
	'S=Sim; N=Nao'															, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'N3'																	, ; //X3_ORDEM
	'E1_ZBANCO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod Banco'																, ; //X3_TITULO
	'Cod Banco'																, ; //X3_TITSPA
	'Cod Banco'																, ; //X3_TITENG
	'Codigo do Banco Boleto'												, ; //X3_DESCRIC
	'Codigo do Banco Boleto'												, ; //X3_DESCSPA
	'Codigo do Banco Boleto'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'N4'																	, ; //X3_ORDEM
	'E1_ZBOLETO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Gera Boleto?'															, ; //X3_TITULO
	'Gera Boleto?'															, ; //X3_TITSPA
	'Gera Boleto?'															, ; //X3_TITENG
	'Gera Boleto?'															, ; //X3_DESCRIC
	'Gera Boleto?'															, ; //X3_DESCSPA
	'Gera Boleto?'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'S=Sim;N=Nao'															, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'N5'																	, ; //X3_ORDEM
	'E1_ZREMES'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Num. Rem. KP'															, ; //X3_TITULO
	'Num. Rem. KP'															, ; //X3_TITSPA
	'Num. Rem. KP'															, ; //X3_TITENG
	'Numero de Remessa do KP'												, ; //X3_DESCRIC
	'Numero de Remessa do KP'												, ; //X3_DESCSPA
	'Numero de Remessa do KP'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'N6'																	, ; //X3_ORDEM
	'E1_ZDEPOSI'															, ; //X3_CAMPO
	'M'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Deposito'																, ; //X3_TITULO
	'Deposito'																, ; //X3_TITSPA
	'Deposito'																, ; //X3_TITENG
	'Info. Deposito'														, ; //X3_DESCRIC
	'Info. Deposito'														, ; //X3_DESCSPA
	'Info. Deposito'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'N7'																	, ; //X3_ORDEM
	'E1_ZCCREDI'															, ; //X3_CAMPO
	'M'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cart. Credit'															, ; //X3_TITULO
	'Cart. Credit'															, ; //X3_TITSPA
	'Cart. Credit'															, ; //X3_TITENG
	'Cartao de Credito'														, ; //X3_DESCRIC
	'Cartao de Credito'														, ; //X3_DESCSPA
	'Cartao de Credito'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'N8'																	, ; //X3_ORDEM
	'E1_ZOP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Op do Cartao'															, ; //X3_TITULO
	'Op do Cartao'															, ; //X3_TITSPA
	'Op do Cartao'															, ; //X3_TITENG
	'Cod da Op de Cartao'													, ; //X3_DESCRIC
	'Cod da Op de Cartao'													, ; //X3_DESCSPA
	'Cod da Op de Cartao'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'FSCP05'																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Iif ( (AllTrim(M->E1_TIPO) == "NCC"  .And. AllTrim(M->E1_ZCARTAO) == "S") , (NaoVazio() .And. ExistCpo("P05")) , VAZIO())', ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'N9'																	, ; //X3_ORDEM
	'E1_ZBAND'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Bandeira'																, ; //X3_TITULO
	'Bandeira'																, ; //X3_TITSPA
	'Bandeira'																, ; //X3_TITENG
	'Bandeira Cartao'														, ; //X3_DESCRIC
	'Bandeira Cartao'														, ; //X3_DESCSPA
	'Bandeira Cartao'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'O0'																	, ; //X3_ORDEM
	'E1_ZTIPO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo'																	, ; //X3_TITULO
	'Tipo'																	, ; //X3_TITSPA
	'Tipo'																	, ; //X3_TITENG
	'Tipo (Debito/Credito)'													, ; //X3_DESCRIC
	'Tipo (Debito/Credito)'													, ; //X3_DESCSPA
	'Tipo (Debito/Credito)'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'CD=Debito; CC=Credito'													, ; //X3_CBOX
	'CD=Debito; CC=Credito'													, ; //X3_CBOXSPA
	'CD=Debito; CC=Credito'													, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'O1'																	, ; //X3_ORDEM
	'E1_ZTAXA'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Taxa Cartao'															, ; //X3_TITULO
	'Taxa Cartao'															, ; //X3_TITSPA
	'Taxa Cartao'															, ; //X3_TITENG
	'Taxa Cartao'															, ; //X3_DESCRIC
	'Taxa Cartao'															, ; //X3_DESCSPA
	'Taxa Cartao'															, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'O2'																	, ; //X3_ORDEM
	'E1_ZNUMTID'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	29																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Num. Transac'															, ; //X3_TITULO
	'Num. Transac'															, ; //X3_TITSPA
	'Num. Transac'															, ; //X3_TITENG
	'Numero da Transacao'													, ; //X3_DESCRIC
	'Numero da Transacao'													, ; //X3_DESCSPA
	'Numero da Transacao'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'O3'																	, ; //X3_ORDEM
	'E1_ZNVEZES'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Num de Vezes'															, ; //X3_TITULO
	'Num de Vezes'															, ; //X3_TITSPA
	'Num de Vezes'															, ; //X3_TITENG
	'Numero de Vezes'														, ; //X3_DESCRIC
	'Numero de Vezes'														, ; //X3_DESCSPA
	'Numero de Vezes'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'Z1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'ExistCpo("SX5","Z1"+M->E1_ZNVEZES)'									, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'Iif((M->E1_ZTIPO=="CD"),(M->E1_ZNVEZES:="01",.F.),.T.)'				, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

//
// Atualizando dicionแrio
//

nPosArq := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x ) == "X3_GRPSXG"  } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajsuta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				cTexto += "O tamanho do campo " + aSX3[nI][nPosCpo] + " nao atualizado e foi mantido em ["
				cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF
				cTexto += "   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF + CRLF
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				FieldPut( FieldPos( aEstrut[nJ] ), cSeqAtu )

			ElseIf FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		cTexto += "Criado o campo " + aSX3[nI][nPosCpo] + CRLF

	Else

		//
		// Verifica se o campo faz parte de um grupo e ajsuta tamanho
		//
		If !Empty( SX3->X3_GRPSXG ) .AND. SX3->X3_GRPSXG <> aSX3[nI][nPosSXG]
			SXG->( dbSetOrder( 1 ) )
			If SXG->( MSSeek( SX3->X3_GRPSXG ) )
				If aSX3[nI][nPosTam] <> SXG->XG_SIZE
					aSX3[nI][nPosTam] := SXG->XG_SIZE
					cTexto +=  "O tamanho do campo " + aSX3[nI][nPosCpo] + " nao atualizado e foi mantido em ["
					cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + "]"+ CRLF
					cTexto +=  "   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF + CRLF
				EndIf
			EndIf
		EndIf

		//
		// Verifica todos os campos
		//
		For nJ := 1 To Len( aSX3[nI] )

			//
			// Se o campo estiver diferente da estrutura
			//
			If aEstrut[nJ] == SX3->( FieldName( nJ ) ) .AND. ;
				PadR( StrTran( AllToChar( SX3->( FieldGet( nJ ) ) ), " ", "" ), 250 ) <> ;
				PadR( StrTran( AllToChar( aSX3[nI][nJ] )           , " ", "" ), 250 ) .AND. ;
				AllTrim( SX3->( FieldName( nJ ) ) ) <> "X3_ORDEM"

				cMsg := "O campo " + aSX3[nI][nPosCpo] + " estแ com o " + SX3->( FieldName( nJ ) ) + ;
				" com o conte๚do" + CRLF + ;
				"[" + RTrim( AllToChar( SX3->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
				"que serแ substituido pelo NOVO conte๚do" + CRLF + ;
				"[" + RTrim( AllToChar( aSX3[nI][nJ] ) ) + "]" + CRLF + ;
				"Deseja substituir ? "

				If      lTodosSim
					nOpcA := 1
				ElseIf  lTodosNao
					nOpcA := 2
				Else
					nOpcA := Aviso( "ATUALIZAวรO DE DICIONมRIOS E TABELAS", cMsg, { "Sim", "Nใo", "Sim p/Todos", "Nใo p/Todos" }, 3, "Diferen็a de conte๚do - SX3" )
					lTodosSim := ( nOpcA == 3 )
					lTodosNao := ( nOpcA == 4 )

					If lTodosSim
						nOpcA := 1
						lTodosSim := MsgNoYes( "Foi selecionada a op็ใo de REALIZAR TODAS altera็๕es no SX3 e NรO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a a็ใo [Sim p/Todos] ?" )
					EndIf

					If lTodosNao
						nOpcA := 2
						lTodosNao := MsgNoYes( "Foi selecionada a op็ใo de NรO REALIZAR nenhuma altera็ใo no SX3 que esteja diferente da base e NรO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta a็ใo [Nใo p/Todos]?" )
					EndIf

				EndIf

				If nOpcA == 1
					cTexto += "Alterado o campo " + aSX3[nI][nPosCpo] + CRLF
					cTexto += "   " + PadR( SX3->( FieldName( nJ ) ), 10 ) + " de [" + AllToChar( SX3->( FieldGet( nJ ) ) ) + "]" + CRLF
					cTexto += "            para [" + AllToChar( aSX3[nI][nJ] )          + "]" + CRLF + CRLF

					RecLock( "SX3", .F. )
					FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )
					dbCommit()
					MsUnLock()
				EndIf

			EndIf

		Next

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuSIX บ Autor ณ TOTVS Protheus     บ Data ณ  29/03/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SIX - Indices       ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuSIX   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAtuSIX( cTexto )
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

cTexto  += "Inicio da Atualizacao" + " SIX" + CRLF + CRLF

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela SE1
//
aAdd( aSIX, { ;
	'SE1'																	, ; //INDICE
	'Q'																		, ; //ORDEM
	'E1_FILIAL+E1_PREFIXO+E1_ZREMES'										, ; //CHAVE
	'[Exclusivo TopMix] Ordenacao por numero de remessa'					, ; //DESCRICAO
	'[Exclusivo TopMix] Ordenacao por numero de remessa'					, ; //DESCSPA
	'[Exclusivo TopMix] Ordenacao por numero de remessa'					, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'FSIND00004'															, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE1'																	, ; //INDICE
	'R'																		, ; //ORDEM
	'E1_FILIAL+E1_ZNUMTID'													, ; //CHAVE
	'Filial + Transac'														, ; //DESCRICAO
	'Filial + Transac'														, ; //DESCSPA
	'Filial + Transac'														, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'FSIND00005'															, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE1'																	, ; //INDICE
	'S'																		, ; //ORDEM
	'E1_FILIAL+E1_PREFIXO+E1_ZREMES'										, ; //CHAVE
	'[Exclusivo TopMix] Ordenacao por numero de remessa'					, ; //DESCRICAO
	'[Exclusivo TopMix] Ordenacao por numero de remessa'					, ; //DESCSPA
	'[Exclusivo TopMix] Ordenacao por numero de remessa'					, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'FSIND00004'															, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE1'																	, ; //INDICE
	'T'																		, ; //ORDEM
	'E1_FILIAL+E1_TIPO+E1_ZNUMTID+E1_PARCELA'								, ; //CHAVE
	'Tipo+Num. Transac+Parcela'												, ; //DESCRICAO
	'Tipo+Num. Transac+Cuota'												, ; //DESCSPA
	'Type+Num. Transac+Cuota'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'FSIND00006'															, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Atualizando dicionแrio
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		RecLock( "SIX", .T. )
		lDelInd := .F.
		cTexto += "อndice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF
	Else
		lAlt := .F.
		RecLock( "SIX", .F. )
	EndIf

	If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "") == ;
	    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
		aAdd( aArqUpd, aSIX[nI][1] )

		If lAlt
			lDelInd := .T. // Se for alteracao precisa apagar o indice do banco
			cTexto += "อndice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF
		EndIf

		For nJ := 1 To Len( aSIX[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
			EndIf
		Next nJ

		If lDelInd
			TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] ) // Exclui sem precisar baixar o TOP
		EndIf

	EndIf

	dbCommit()
	MsUnLock()

	oProcess:IncRegua2( "Atualizando ํndices..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuSX6 บ Autor ณ TOTVS Protheus     บ Data ณ  29/03/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SX6 - Parโmetros    ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuSX6   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAtuSX6( cTexto )
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

cTexto  += "Inicio da Atualizacao" + " SX6" + CRLF + CRLF

aEstrut := { "X6_FIL"    , "X6_VAR"  , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , "X6_DSCSPA1",;
             "X6_DSCENG1", "X6_DESC2", "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PROPRI" , "X6_PYME" }

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_RCTNATU'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Natureza recebimento de titulos'										, ; //X6_DESCRIC
	'Natureza recebimento de titulos'										, ; //X6_DSCSPA
	'Natureza recebimento de titulos'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'10002'																	, ; //X6_CONTEUD
	'10002'																	, ; //X6_CONTSPA
	'10002'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_RSOCIAL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Descricao gerada no relatorio ID'										, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'TopMix Engenharia e Tecnologia de concreto S/A'						, ; //X6_CONTEUD
	'TopMix Engenharia e Tecnologia de concreto S/A'						, ; //X6_CONTSPA
	'TopMix Engenharia e Tecnologia de concreto S/A'						, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME


//
// Atualizando dicionแrio
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		cTexto += "Foi incluํdo o parโmetro " + aSX6[nI][1] + aSX6[nI][2] + " Conte๚do [" + AllTrim( aSX6[nI][13] ) + "]"+ CRLF
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( "Atualizando Arquivos (SX6)..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuSX7 บ Autor ณ TOTVS Protheus     บ Data ณ  29/03/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SX7 - Gatilhos      ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuSX7   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAtuSX7( cTexto )
Local aEstrut   := {}
Local aSX7      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

cTexto  += "Inicio da Atualizacao" + " SX7" + CRLF + CRLF

aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", ;
             "X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }

//
// Campo P05_CODOPE
//
aAdd( aSX7, { ;
	'P05_CODOPE'														, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P05_CODOPE+M->P05_LOJA,"A1_CGC")'	, ; //X7_REGRA
	'P05_CNPJ'															, ; //X7_CDOMIN
	'P'																	, ; //X7_TIPO
	'N'																	, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																	, ; //X7_PROPRI
	''																		} ) //X7_CONDIC


//
// Campo P05_CODOPE
//
aAdd( aSX7, { ;
	'P05_CODOPE'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P05_CODOPE+M->P05_LOJA,"A1_PESSOA")'	, ; //X7_REGRA
	'P05_PESSOA'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC


//
// Campo P06_CODCLI
//
aAdd( aSX7, { ;
	'P06_CODCLI'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_CGC")'	, ; //X7_REGRA
	'P06_CGC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_CODCLI'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_NOME")'	, ; //X7_REGRA
	'P06_NOME'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_CODCLI'															, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_END")'	, ; //X7_REGRA
	'P06_END'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_CODCLI'															, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_BAIRRO")'	, ; //X7_REGRA
	'P06_BAIRRO'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_CODCLI'															, ; //X7_CAMPO
	'005'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_MUN")'	, ; //X7_REGRA
	'P06_MUN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_CODCLI'															, ; //X7_CAMPO
	'006'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_EST")'	, ; //X7_REGRA
	'P06_ESTADO'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_CODCLI'															, ; //X7_CAMPO
	'007'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_CEP")'	, ; //X7_REGRA
	'P06_CEP'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_CODCLI'															, ; //X7_CAMPO
	'008'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_INSCR")'	, ; //X7_REGRA
	'P06_INSCR'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_CODCLI'															, ; //X7_CAMPO
	'009'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_TEL")'	, ; //X7_REGRA
	'P06_TEL'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_CODCLI'															, ; //X7_CAMPO
	'010'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_EMAIL")'	, ; //X7_REGRA
	'P06_EMAIL'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_CODCLI'															, ; //X7_CAMPO
	'011'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_PESSOA")'	, ; //X7_REGRA 
	'P06_PESSOA'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo P06_LOJA
//
aAdd( aSX7, { ;
	'P06_LOJA'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_CGC")'	, ; //X7_REGRA
	'P06_CGC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_LOJA'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_NOME")'	, ; //X7_REGRA
	'P06_NOME'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_LOJA'																, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_END")'	, ; //X7_REGRA
	'P06_END'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_LOJA'																, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_BAIRRO")'	, ; //X7_REGRA
	'P06_BAIRRO'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_LOJA'																, ; //X7_CAMPO
	'005'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_MUN")'	, ; //X7_REGRA
	'P06_MUN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_LOJA'																, ; //X7_CAMPO
	'006'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_EST")'	, ; //X7_REGRA
	'P06_ESTADO'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_LOJA'																, ; //X7_CAMPO
	'007'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_CEP")'	, ; //X7_REGRA
	'P06_CEP'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_LOJA'																, ; //X7_CAMPO
	'008'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_INSCR")'	, ; //X7_REGRA
	'P06_INSCR'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_LOJA'																, ; //X7_CAMPO
	'009'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_TEL")'	, ; //X7_REGRA
	'P06_TEL'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'P06_LOJA'																, ; //X7_CAMPO
	'010'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_EMAIL")'	, ; //X7_REGRA
	'P06_EMAIL'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC  
	
	
aAdd( aSX7, { ;
	'P06_LOJA'															, ; //X7_CAMPO
	'012'																	, ; //X7_SEQUENC
	'Posicione("SA1",1,xFilial("SA1") + M->P06_CODCLI+M->P06_LOJA,"A1_PESSOA")'	, ; //X7_REGRA 
	'P06_PESSOA'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Atualizando dicionแrio
//
oProcess:SetRegua2( Len( aSX7 ) )

dbSelectArea( "SX7" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX7 )

	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

		If !( aSX7[nI][1] $ cAlias )
			cAlias += aSX7[nI][1] + "/"
			cTexto += "Foi incluํdo o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] + CRLF
		EndIf

		RecLock( "SX7", .T. )
		For nJ := 1 To Len( aSX7[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

	EndIf
	oProcess:IncRegua2( "Atualizando Arquivos (SX7)..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuSXB บ Autor ณ TOTVS Protheus     บ Data ณ  29/03/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SXB - Consultas Pad ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuSXB   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAtuSXB( cTexto )
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

cTexto  += "Inicio da Atualizacao" + " SXB" + CRLF + CRLF

aEstrut := { "XB_ALIAS",  "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , ;
             "XB_DESCRI", "XB_DESCSPA", "XB_DESCENG", "XB_CONTEM" }

//
// Consulta FSCP05
//
aAdd( aSXB, { ;
	'FSCP05'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Operadoras'															, ; //XB_DESCRI
	'Operadoras'															, ; //XB_DESCSPA
	'Operadoras'															, ; //XB_DESCENG
	'P05'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FSCP05'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Filial+cod Operador+'													, ; //XB_DESCRI
	'Sucursal+cod Operado'													, ; //XB_DESCSPA
	'Branch+cod Operador+'													, ; //XB_DESCENG
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FSCP05'																, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FSCP05'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Ref.Operador'															, ; //XB_DESCRI
	'Ref.Operador'															, ; //XB_DESCSPA
	'Ref.Operador'															, ; //XB_DESCENG
	'P05_REFOPE'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FSCP05'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod Operador'															, ; //XB_DESCRI
	'Cod Operador'															, ; //XB_DESCSPA
	'Cod Operador'															, ; //XB_DESCENG
	'P05_CODOPE'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FSCP05'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Loja'																	, ; //XB_DESCSPA
	'Loja'																	, ; //XB_DESCENG
	'P05_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FSCP05'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Bandeira'																, ; //XB_DESCRI
	'Bandeira'																, ; //XB_DESCSPA
	'Bandeira'																, ; //XB_DESCENG
	'P05_BAND'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FSCP05'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	'P05_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FSCP05'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Tipo'																	, ; //XB_DESCRI
	'Tipo'																	, ; //XB_DESCSPA
	'Tipo'																	, ; //XB_DESCENG
	'P05_TIPO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FSCP05'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	'P05->P05_REFOPE'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FSCP05'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	'P05->P05_BAND'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FSCP05'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	'P05->P05_TIPO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FSCP05'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	'P05->P05_TAXA'															} ) //XB_CONTEM

//
// Atualizando dicionแrio
//
oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				cTexto += "Foi incluํda a consulta padrใo " + aSXB[nI][1] + CRLF
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If !Empty( FieldName( FieldPos( aEstrut[nJ] ) ) )
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					 StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )

					cMsg := "A consulta padrao " + aSXB[nI][1] + " estแ com o " + SXB->( FieldName( nJ ) ) + ;
					" com o conte๚do" + CRLF + ;
					"[" + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
					", e este ้ diferente do conte๚do" + CRLF + ;
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAวรO DE DICIONมRIOS E TABELAS", cMsg, { "Sim", "Nใo", "Sim p/Todos", "Nใo p/Todos" }, 3, "Diferen็a de conte๚do - SXB" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a op็ใo de REALIZAR TODAS altera็๕es no SXB e NรO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a a็ใo [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a op็ใo de NรO REALIZAR nenhuma altera็ใo no SXB que esteja diferente da base e NรO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta a็ใo [Nใo p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

						If !( aSXB[nI][1] $ cAlias )
							cAlias += aSXB[nI][1] + "/"
							cTexto += "Foi Alterada a consulta padrao " + aSXB[nI][1] + CRLF
						EndIf

					EndIf

				EndIf

			Next

		EndIf

	EndIf

	oProcess:IncRegua2( "Atualizando Consultas Padroes (SXB)..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuHlp บ Autor ณ TOTVS Protheus     บ Data ณ  29/03/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao dos Helps de Campos    ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuHlp   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAtuHlp( cTexto )
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

cTexto  += "Inicio da Atualizacao" + " " + "Helps de Campos" + CRLF + CRLF


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

//
// Helps Tabela P05
//
aHlpPor := {}
aAdd( aHlpPor, '[Topmix]' )
aAdd( aHlpPor, 'C๓digo referencial da operadora' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP05_REFOPE", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P05_REFOPE" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Codigo Operadora' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP05_CODOPE", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P05_CODOPE" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Informa็ใo da loja do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP05_LOJA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P05_LOJA  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'CNPJ da operadora do cartao.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP05_CNPJ  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P05_CNPJ  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Tipo Pessoa' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP05_PESSOA", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P05_PESSOA" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Bandeira  da operadora' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP05_BAND  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P05_BAND  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Descri็ใo da operadora de cartใo.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP05_DESCRI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P05_DESCRI" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'D้bito/Cr้dito' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP05_TIPO  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P05_TIPO  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Percentual de Taxa' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP05_TAXA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P05_TAXA  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Dia do m๊s em que a administradora' )
aAdd( aHlpPor, 'costuma fazer o credito' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP05_VENPAD", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P05_VENPAD" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'N๚meros de dias para recebimento do' )
aAdd( aHlpPor, 'tํtulo financiado a partir da data' )
aAdd( aHlpPor, 'venda. Ex Venda 19/01/12 quantidade de' )
aAdd( aHlpPor, 'dias 30, o titulo sera gerado para o dia' )
aAdd( aHlpPor, '19/02/12' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP05_VENFIN", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P05_VENFIN" + CRLF

//
// Helps Tabela P06
//
aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Status do Pre Recebimento' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_STATUS", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_STATUS" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'ID Gerado pela TopMix' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_ID    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_ID    " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'C๓digo do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_CODCLI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_CODCLI" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Loja do Cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_LOJA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_LOJA  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Tipo de Pessoa Fisica ou Juridica' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_PESSOA", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_PESSOA" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'CNPJ ou CPF do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_CGC   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_CGC   " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Nome do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_NOME  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_NOME  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Endere็o do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_END   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_END   " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Bairro do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_BAIRRO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_BAIRRO" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Municipio do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_MUN   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_MUN   " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Estado do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_ESTADO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_ESTADO" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Cep do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_CEP   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_CEP   " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Inscricao Estadual' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_INSCR ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_INSCR " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Telefone do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_TEL   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_TEL   " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'E-Mail  cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_EMAIL ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_EMAIL " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Codigo do Banco' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_BANCO ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_BANCO " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Agencia do Banco' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_AGENCI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_AGENCI" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Conta Corrente no banco' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_NUMCON", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_NUMCON" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Prefixo do titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_PREFIX", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_PREFIX" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Numero do Titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_NUM   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_NUM   " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Codigo da natureza' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_NATURE", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_NATURE" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Valor do Titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_VALOR ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_VALOR " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Tipo Deposito' )
aAdd( aHlpPor, 'R$ - Dinheiro' )
aAdd( aHlpPor, 'CH - Cheque' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_TIPO  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_TIPO  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Data Emissao' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_EMISSA", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_EMISSA" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Historico do Titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_HISTOR", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_HISTOR" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Data do Deposito' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_DEPOSI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_DEPOSI" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Data da Impressao do Relatorio ID' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP06_DIMPRE", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P06_DIMPRE" + CRLF

//
// Helps Tabela SE1
//
aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Pagamento com cartao' )
aAdd( aHlpPor, 'S=Sim e Tipo = NCC (Segue processo' )
aAdd( aHlpPor, 'TopMix)' )
aAdd( aHlpPor, 'N=Nao e Tipo = NCC (Segue processo' )
aAdd( aHlpPor, 'Padrao)' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PE1_ZCARTAO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "E1_ZCARTAO" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Para garantir a integridade das' )
aAdd( aHlpPor, 'informa็๕es impressas na 2ช via do' )
aAdd( aHlpPor, 'boleto. Este campo serแ' )
aAdd( aHlpPor, 'preenchido automaticamente com o c๓digo' )
aAdd( aHlpPor, 'do banco, no momento em que for gerado o' )
aAdd( aHlpPor, 'boleto bancแrio.' )
aAdd( aHlpPor, '[Campo Especifico TopMix]' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PE1_ZBANCO ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "E1_ZBANCO " + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Este campo indica se gera Boeto Sim/Nao' )
aAdd( aHlpPor, '[Campo Especifico TopMix]' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PE1_ZBOLETO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "E1_ZBOLETO" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Numero da remessa do sistema KP' )
aAdd( aHlpPor, 'integra็ใo Protheus.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PE1_ZREMES ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "E1_ZREMES " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Campo customizado para salvar a' )
aAdd( aHlpPor, 'operadora de cartao' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PE1_ZOP    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "E1_ZOP    " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix~]' )
aAdd( aHlpPor, 'Bandeira Cartao' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PE1_ZBAND  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "E1_ZBAND  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Tipo do cartao.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PE1_ZTIPO  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "E1_ZTIPO  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Taxa da operadora de cartao.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PE1_ZTAXA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "E1_ZTAXA  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Numero unico que identifica cada' )
aAdd( aHlpPor, 'transa็ใo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PE1_ZNUMTID", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "E1_ZNUMTID" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Numero de Vezes para passar o cartao' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PE1_ZNVEZES", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "E1_ZNVEZES" + CRLF

cTexto += CRLF + "Final da Atualizacao" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return {}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณESCEMPRESAบAutor  ณ Ernani Forastieri  บ Data ณ  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Generica para escolha de Empresa, montado pelo SM0_ บฑฑ
ฑฑบ          ณ Retorna vetor contendo as selecoes feitas.                 บฑฑ
ฑฑบ          ณ Se nao For marcada nenhuma o vetor volta vazio.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EscEmpresa()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametro  nTipo                           ณ
//ณ 1  - Monta com Todas Empresas/Filiais      ณ
//ณ 2  - Monta so com Empresas                 ณ
//ณ 3  - Monta so com Filiais de uma Empresa   ณ
//ณ                                            ณ
//ณ Parametro  aMarcadas                       ณ
//ณ Vetor com Empresas/Filiais pre marcadas    ณ
//ณ                                            ณ
//ณ Parametro  cEmpSel                         ณ
//ณ Empresa que sera usada para montar selecao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local   aSalvAmb := GetArea()
Local   aSalvSM0 := {}
Local   aRet     := {}
Local   aVetor   := {}
Local   oDlg     := NIL
Local   oChkMar  := NIL
Local   oLbx     := NIL
Local   oMascEmp := NIL
Local   oMascFil := NIL
Local   oButMarc := NIL
Local   oButDMar := NIL
Local   oButInv  := NIL
Local   oSay     := NIL
Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
Local   oNo      := LoadBitmap( GetResources(), "LBNO" )
Local   lChk     := .F.
Local   lOk      := .F.
Local   lTeveMarc:= .F.
Local   cVar     := ""
Local   cNomEmp  := ""
Local   cMascEmp := "??"
Local   cMascFil := "??"

Local   aMarcadas  := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 270, 396 Pixel

oDlg:cToolTip := "Tela para M๚ltiplas Sele็๕es de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualiza็ใo"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos"   Message  Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

@ 123, 10 Button oButInv Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Sele็ใo" Of oDlg

// Marca/Desmarca por mascara
@ 113, 51 Say  oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet  oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), cMascFil := StrTran( cMascFil, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Mแscara Empresa ( ?? )"  Of oDlg
@ 123, 50 Button oButMarc Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando mแscara ( ?? )"    Of oDlg
@ 123, 80 Button oButDMar Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando mแscara ( ?? )" Of oDlg

Define SButton From 111, 125 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop "Confirma a Sele็ใo"  Enable Of oDlg
Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop "Abandona a Sele็ใo" Enable Of oDlg
Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณMARCATODOSบAutor  ณ Ernani Forastieri  บ Data ณ  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Auxiliar para marcar/desmarcar todos os itens do    บฑฑ
ฑฑบ          ณ ListBox ativo                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณINVSELECAOบAutor  ณ Ernani Forastieri  บ Data ณ  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Auxiliar para inverter selecao do ListBox Ativo     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณRETSELECAOบAutor  ณ Ernani Forastieri  บ Data ณ  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Auxiliar que monta o retorno com as selecoes        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณ MARCAMAS บAutor  ณ Ernani Forastieri  บ Data ณ  20/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para marcar/desmarcar usando mascaras               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] :=  lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณ VERTODOS บAutor  ณ Ernani Forastieri  บ Data ณ  20/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao auxiliar para verificar se estao todos marcardos    บฑฑ
ฑฑบ          ณ ou nao                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ MyOpenSM0บ Autor ณ TOTVS Protheus     บ Data ณ  29/03/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento abertura do SM0 modo exclusivo     ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ MyOpenSM0  - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MyOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( "Nใo foi possํvel a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENวรO" )
EndIf

Return lOpen


/////////////////////////////////////////////////////////////////////////////
