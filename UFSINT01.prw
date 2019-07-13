#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ UFSINT01 บ Autor ณ TOTVS Protheus     บ Data ณ  29/11/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de update dos dicionแrios para compatibiliza็ใo     ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ UFSINT01   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function UFSINT01( cEmpAmb, cFilAmb )

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
				MsgStop( "Atualiza็ใo Realizada.", "UFSINT01" )
				dbCloseAll()
			Else
				MsgStop( "Atualiza็ใo nใo Realizada.", "UFSINT01" )
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
			MsgStop( "Atualiza็ใo nใo Realizada.", "UFSINT01" )

		EndIf

	Else
		MsgStop( "Atualiza็ใo nใo Realizada.", "UFSINT01" )

	EndIf

EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSTProc  บ Autor ณ TOTVS Protheus     บ Data ณ  29/11/2011 บฑฑ
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
ฑฑบ Programa ณ FSAtuSX2 บ Autor ณ TOTVS Protheus     บ Data ณ  29/11/2011 บฑฑ
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
             "X2_MODOEMP", "X2_MODOUN" }

dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela P00
//
aAdd( aSX2, {'P00',cPath,'P00'+cEmpr,'LOG INTEGRACAO KP','LOG INTEGRACAO KP','LOG INTEGRACAO KP',0,'C','','','','','C','C',0} )
//
// Tabela P01
//
aAdd( aSX2, {'P01',cPath,'P01'+cEmpr,'ENDERECOS DE COBR. CLIENTES','ENDERECOS DE COBR. CLIENTES','ENDERECOS DE COBR. CLIENTES',0,'C','','','','','C','C',0} )
//
// Tabela P02
//
aAdd( aSX2, {'P02',cPath,'P02'+cEmpr,'CONTROLE DE FATURA X REMESSA','CONTROLE DE FATURA X REMESSA','CONTROLE DE FATURA X REMESSA',0,'C','','','','','C','C',0} )
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
ฑฑบ Programa ณ FSAtuSX3 บ Autor ณ TOTVS Protheus     บ Data ณ  29/11/2011 บฑฑ
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
// Tabela CTT
//
aAdd( aSX3, {'CTT','48','CTT_ZFLAG','C',1,0,'Flag Export.','Flag Export.','Flag Export.','Flag de Exportacao','Flag de Exportacao','Flag de Exportacao','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',0,	Chr(254) + Chr(192),'','','U','N','V','R','','','','','','','','','','',''} )
//
// Tabela DA1
//
aAdd( aSX3, {'DA1','06','DA1_UM','C',2,0,'Unid. Medida','Unid. Medida','Unid. Medida','Unidade de Medida','Unidade de Medida','Unidade de Medida','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','','','','','','','','','','',''} )
//
// Tabela DA3
//
aAdd( aSX3, {'DA3','57','DA3_ZIDENT','C',16,0,'Identifica','Identifica','Identifica','Identificador do Registro','Identificador do Registro','Identificador do Registro','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',0,	Chr(254) + Chr(192),'','','U','N','V','R','','','','','','','','','','',''} )
aAdd( aSX3, {'DA3','58','DA3_ZFLAG','C',1,0,'Flag de Expo','Flag de Expo','Flag de Expo','Flag de Exportacao','Flag de Exportacao','Flag de Exportacao','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','V','R','','','','','','','','','','',''} )
//
// Tabela DA4
//
aAdd( aSX3, {'DA4','56','DA4_ZFLAG','C',1,0,'Flag de Expo','Flag de Expo','Flag de Expo','Flag de Exportacao','Flag de Exportacao','Flag de Exportacao','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','V','R','','','','','','','','','','',''} )
//
// Tabela P00
//
aAdd( aSX3, {'P00','01','P00_ID','C',9,0,'Num Seq','Num Seq','Num Seq','Numero Sequencial','Numero Sequencial','Numero Sequencial','@X','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'GETSXENUM("P00","P00_ID")','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','NaoVazio() .And. ExistChav("P00")','','','','','','','','',''} )
aAdd( aSX3, {'P00','02','P00_FILIAL','C',2,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',1,	Chr(254) + Chr(192),'','','U','N','','','','','','','','','','','033','',''} )
aAdd( aSX3, {'P00','03','P00_FILORI','C',2,0,'Fil. Origem','Fil. Origem','Fil. Origem','Filial Origem do Erro','Filial Origem do Erro','Filial Origem do Erro','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P00','04','P00_DATA','D',8,0,'Data','Data','Data','Data do Erro','Data do Erro','Data do Erro','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P00','05','P00_HORA','C',8,0,'Hora','Hora','Hora','Hora','Hora','Hora','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P00','06','P00_PEDKP','C',20,0,'Ped. KP','Ped. KP','Ped. KP','Pedido do KP','Pedido do KP','Pedido do KP','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P00','07','P00_ROTINA','C',10,0,'Rotina','Rotina','Rotina','Rotina do Erro','Rotina do Erro','Rotina do Erro','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P00','08','P00_ERRO','M',10,0,'Erro Siga','Erro Siga','Erro Siga','Erro de Execucao','Erro de Execucao','Erro de Execucao','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
//
// Tabela P01
//
aAdd( aSX3, {'P01','01','P01_FILIAL','C',2,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',1,	Chr(254) + Chr(192),'','','U','N','','','','','','','','','','','033','',''} )
aAdd( aSX3, {'P01','02','P01_COD','C',6,0,'Codigo','Codigo','Codigo','Codigo do Cliente','Codigo do Cliente','Codigo do Cliente','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','€','','','','','','','','','',''} )
aAdd( aSX3, {'P01','03','P01_LOJA','C',2,0,'Loja','Loja','Loja','Loja do Cliente','Loja do Cliente','Loja do Cliente','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','€','','','','','','','','','',''} )
aAdd( aSX3, {'P01','04','P01_ITEM','C',2,0,'Item','Item','Item','Item do Endereco','Item do Endereco','Item do Endereco','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','V','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P01','05','P01_END','C',40,0,'Endereco','Endereco','Endereco','Endereco do cliente','Endereco do cliente','Endereco do cliente','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','€','','','','','','','','','',''} )
aAdd( aSX3, {'P01','06','P01_COMPLE','C',50,0,'Complemento','Complemento','Complemento','Complemento de Endereco','Complemento de Endereco','Complemento de Endereco','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P01','07','P01_BAIRRO','C',30,0,'Bairro','Bairro','Bairro','Bairro do cliente','Bairro do cliente','Bairro do cliente','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P01','08','P01_EST','C',2,0,'Estado','Estado','Estado','Estado do cliente','Estado do cliente','Estado do cliente','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','€','ExistCpo("SX5","12"+M->P01_EST)','','','','','','','','',''} )
aAdd( aSX3, {'P01','09','P01_CODMUN','C',5,0,'Cd.Municipio','Cd.Municipio','Cd.Municipio','Codigo do Municipio','Codigo do Municipio','Codigo do Municipio','@9','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','CC2SA1',0,	Chr(254) + Chr(192),'','S','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P01','10','P01_MUN','C',15,0,'Municipio','Municipio','Municipio','Municipio do cliente','Municipio do cliente','Municipio do cliente','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P01','11','P01_CEP','C',8,0,'CEP','CEP','CEP','Cod Enderecamento Postal','Cod Enderecamento Postal','Cod Enderecamento Postal','@R 99999-999','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P01','12','P01_ZFLAG','C',1,0,'Flag De Int.','Flag De Int.','Flag De Int.','Flag de Integracao','Flag de Integracao','Flag de Integracao','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','V','R','','A030Cep()','','','','','','','','',''} )
//
// Tabela P02
//
aAdd( aSX3, {'P02','01','P02_ID','C',6,0,'Cod. Fat. Re','Cod. Fat. Re','Cod. Fat. Re','Codigo Fatu. Remessa','Codigo Fatu. Remessa','Codigo Fatu. Remessa','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P02','02','P02_FILIAL','C',2,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(254) + Chr(192),'','','U','S','A','R','','','','','','','','','033','',''} )
aAdd( aSX3, {'P02','03','P02_FLORI1','C',2,0,'Filial NF Fa','Filial NF Fa','Filial NF Fa','Filial da NF de Fatura','Filial da NF de Fatura','Filial da NF de Fatura','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P02','04','P02_DTEMI1','D',8,0,'Emis. NF Fat','Emis. NF Fat','Emis. NF Fat','Emissao NF Fatura','Emissao NF Fatura','Emissao NF Fatura','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P02','05','P02_NUM1','C',20,0,'Num. Fatura','Num. Fatura','Num. Fatura','Numero da Fatura','Numero da Fatura','Numero da Fatura','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P02','06','P02_SERIE1','C',3,0,'Serie NF Fat','Serie NF Fat','Serie NF Fat','Serie da Nota de Fatura','Serie da Nota de Fatura','Serie da Nota de Fatura','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P02','07','P02_FLORI2','C',2,0,'Filial NF Re','Filial NF Re','Filial NF Re','Filial da NF de Remessa','Filial da NF de Remessa','Filial da NF de Remessa','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P02','08','P02_DTEMI2','D',8,0,'Emis NF Rem','Emis NF Rem','Emis NF Rem','Emissao Nota de Remessa','Emissao Nota de Remessa','Emissao Nota de Remessa','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P02','09','P02_NUM2','C',20,0,'Num NF Rem','Num NF Rem','Num NF Rem','Numero da NF Remessa','Numero da NF Remessa','Numero da NF Remessa','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'P02','10','P02_SERIE2','C',3,0,'Serie NF Rem','Serie NF Rem','Serie NF Rem','Serie da NF de Remessa','Serie da NF de Remessa','Serie da NF de Remessa','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','','','','','','','','','','',''} )
//
// Tabela SA1
//
aAdd( aSX3, {'SA1','J8','A1_ZIDENT','C',16,0,'Identifica','Identifica','Identifica','Identificador do Registro','Identificador do Registro','Identificador do Registro','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','V','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SA1','J9','A1_ZTIPO','C',1,0,'Concreto','Concreto','Concreto','Cliente de Concreto','Cliente de Concreto','Cliente de Concreto','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','€','Pertence("SN")','S=Sim;N=Nao','S=Sim;N=Nao','S=Sim;N=Nao','','','','','',''} )
aAdd( aSX3, {'SA1','K0','A1_ZFLAG','C',1,0,'Flag de Expo','Flag de Expo','Flag de Expo','Flag de Exportacao','Flag de Exportacao','Flag de Exportacao','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',0,	Chr(254) + Chr(192),'','','U','N','V','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SA1','K5','A1_INCULT','C',1,0,'Inc. Cultura','Inc. Cultura','Inc. Cultura','Incentivo a Cultura','Incentivo a Cultura','Incentivo a Cultura','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','Pertence(12)','1=Sim; 2=Nao','','','','','','','',''} )
//
// Tabela SA2
//
aAdd( aSX3, {'SA2','F6','A2_ZFLAG','C',1,0,'Flag de Imp','Flag de Imp','Flag de Imp','Flag de Importacao','Flag de Importacao','Flag de Importacao','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
//
// Tabela SA3
//
aAdd( aSX3, {'SA3','69','A3_ZFLAG','C',1,0,'Flag de Imp','Flag de Imp','Flag de Imp','Flag de Importacao','Flag de Importacao','Flag de Importacao','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
//
// Tabela SB1
//
aAdd( aSX3, {'SB1','O3','B1_ZFLAG','C',1,0,'Prd. Inte.','Prd. Inte.','Prd. Inte.','Prdo da Integracao','Prdo da Integracao','Prdo da Integracao','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
//
// Tabela SC5
//
aAdd( aSX3, {'SC5','03','C5_ZPEDIDO','C',20,0,'Num. ID. KP','Num. ID. KP','Num. ID. KP','Numero de ident. KP','Numero de ident. KP','Numero de ident. KP','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','04','C5_ZTIPO','C',1,0,'Tp. Pedido','Tp. Pedido','Tp. Pedido','Tipo do Pedido','Tipo do Pedido','Tipo do Pedido','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','V','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','40','C5_PARC5','N',12,2,'Parcela 5','Parcela 5','Parcela 5','Valor da Parcela 5','Valor da Parcela 5','Valor da Parcela 5','@E 999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','45','C5_DATA5','D',8,0,'Vencimento 5','Vencimento 5','Vencimento 5','Vencimento da Parcela 5','Vencimento da Parcela 5','Vencimento da Parcela 5','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','46','C5_PARC6','N',12,2,'Parcela 6','Parcela 6','Parcela 6','Valor da Parcela 6','Valor da Parcela 6','Valor da Parcela 6','@E 999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','95','C5_ZBOLETO','C',1,0,'Gera Boleto?','Gera Boleto?','Gera Boleto?','Gera Boleto?','Gera Boleto?','Gera Boleto?','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','€','','S=SIM; N=NAO','S=SIM; N=NAO','S=SIM; N=NAO','','','','','',''} )
aAdd( aSX3, {'SC5','96','C5_ZENDCOB','C',60,0,'End Cobranca','End Cobranca','End Cobranca','Endereco de Cobranca','Endereco de Cobranca','Endereco de Cobranca','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','97','C5_ZENDNUM','C',15,0,'Num Endereco','Num Endereco','Num Endereco','Numero do Endereco de Cob','Numero do Endereco de Cob','Numero do Endereco de Cob','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','98','C5_ZCOMPLE','C',50,0,'Compl End','Compl End','Compl End','Complemento do Endereco','Complemento do Endereco','Complemento do Endereco','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','99','C5_ZBAIROC','C',30,0,'Bairro End','Bairro End','Bairro End','Bairro do Endereco de Cob','Bairro do Endereco de Cob','Bairro do Endereco de Cob','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','A0','C5_ZMUN','C',5,0,'Mun Ender','Mun Ender','Mun Ender','Municipio do Endereco Cob','Municipio do Endereco Cob','Municipio do Endereco Cob','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','A1','C5_ZEST','C',2,0,'Est Ender','Est Ender','Est Ender','Estado do Endereco de Cob','Estado do Endereco de Cob','Estado do Endereco de Cob','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','A2','C5_ZCEP','C',8,0,'CEP Ender','CEP Ender','CEP Ender','CEP do Endereco de Cob','CEP do Endereco de Cob','CEP do Endereco de Cob','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','A3','C5_ZCHVNFE','C',44,0,'Chave NF-e','Chave NF-e','Chave NF-e','Chave da NF-e Assinada','Chave da NF-e Assinada','Chave da NF-e Assinada','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','S','V','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','A4','C5_ZEXCLUI','C',1,0,'NF-e Canc.','NF-e Canc.','NF-e Canc.','NF-e Cancelada','NF-e Cancelada','NF-e Cancelada','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','V','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','A5','C5_ZCEI','C',14,0,'Num. CEI','Num. CEI','Num. CEI','Numero do CEI','Numero do CEI','Numero do CEI','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','A6','C5_ZCONT','C',14,0,'Num. Cont','Num. Cont','Num. Cont','Numero do Contrato','Numero do Contrato','Numero do Contrato','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','A7','C5_ZCOD_MU','C',5,0,'Cod do Mun','Cod do Mun','Cod do Mun','Codigo Municipio','Codigo Municipio','Codigo Municipio','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','A8','C5_ZENDOB','C',60,0,'End. Obra','End. Obra','End. Obra','Endereco da Obra','Endereco da Obra','Endereco da Obra','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','A9','C5_ZNUMOB','C',15,0,'Num. Obra','Num. Obra','Num. Obra','Numero da Obra','Numero da Obra','Numero da Obra','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','B0','C5_ZCOMOB','C',50,0,'Com. Obra','Com. Obra','Com. Obra','Complemento da Obra','Complemento da Obra','Complemento da Obra','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','B1','C5_ZBAIROB','C',30,0,'End. da Obra','End. da Obra','End. da Obra','Endereco da Obra','Endereco da Obra','Endereco da Obra','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','B2','C5_ZMUNOB','C',5,0,'Cod. Mun. Ob','Cod. Mun. Ob','Cod. Mun. Ob','Cod. Mun. da Obra','Cod. Mun. da Obra','Cod. Mun. da Obra','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','B3','C5_ZESTOB','C',2,0,'Estado Obra','Estado Obra','Estado Obra','Estado da Obra','Estado da Obra','Estado da Obra','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','B4','C5_ZCEPOB','C',8,0,'CEP. Obra','CEP. Obra','CEP. Obra','CEP da Obra','CEP da Obra','CEP da Obra','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','B5','C5_ZCC','C',9,0,'Centro Custo','Centro Custo','Centro Custo','Centro de Custo','Centro de Custo','Centro de Custo','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','B6','C5_ZUF','C',2,0,'UF. da Obra','UF. da Obra','UF. da Obra','UF. da Obra','UF. da Obra','UF. da Obra','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','B7','C5_ZORIGEM','C',2,0,'Origem','Origem','Origem','Origem do Registro','Origem do Registro','Origem do Registro','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','V','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','C1','C5_DATA6','D',8,0,'Vencimento 6','Vencimento 6','Vencimento 6','Vencimento da Parcela 6','Vencimento da Parcela 6','Vencimento da Parcela 6','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','C2','C5_VEICULO','C',8,0,'Cod. Veiculo','Cod. Veiculo','Cod. Veiculo','Codigo do Veiculo','Codigo do Veiculo','Codigo do Veiculo','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC5','C3','C5_MENPAD1','C',3,0,'Mens. Pad 1','Mens. Pad 1','Mens. Pad 1','Mens. Padrao 1','Mens. Padrao 1','Mens. Padrao 1','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','SM4',0,	Chr(254) + Chr(192),'','','U','N','A','R','','Vazio().Or.ExistCpo("SM4")','','','','','','','','',''} )
aAdd( aSX3, {'SC5','C4','C5_MENPAD2','C',3,0,'Mens. Pad 2','Mens. Pad 2','Mens. Pad 2','Mens. Padrao 2','Mens. Padrao 2','Mens. Padrao 2','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','SM4',0,	Chr(254) + Chr(192),'','','U','N','A','R','','Vazio().Or.ExistCpo("SM4")','','','','','','','','',''} )
aAdd( aSX3, {'SC5','C5','C5_MENPAD3','C',3,0,'Mens. Pad 3','Mens. Pad 3','Mens. Pad 3','Mens. Padrao 3','Mens. Padrao 3','Mens. Padrao 3','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','SM4',0,	Chr(254) + Chr(192),'','','U','N','A','R','','Vazio().Or.ExistCpo("SM4")','','','','','','','','',''} )
aAdd( aSX3, {'SC5','C6','C5_MENPAD4','C',3,0,'Mens. Pad 4','Mens. Pad 4','Mens. Pad 4','Mens. Padrao 4','Mens. Padrao 4','Mens. Padrao 4','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','SM4',0,	Chr(254) + Chr(192),'','','U','N','A','R','','Vazio().Or.ExistCpo("SM4")','','','','','','','','',''} )
//
// Tabela SC6
//
aAdd( aSX3, {'SC6','A6','C6_ZPEDIDO','C',20,0,'Num. Ide. KP','Num. Ide. KP','Num. Ide. KP','Numero de Ident. KP','Numero de Ident. KP','Numero de Ident. KP','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC6','A7','C6_ZID','N',18,0,'ID Base Int','ID Base Int','ID Base Int','ID da base de Int','ID da base de Int','ID da base de Int','@E 99999','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC6','A8','C6_ZCC','C',9,0,'Centro Custo','Centro Custo','Centro Custo','Centro de Custo','Centro de Custo','Centro de Custo','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC6','A9','C6_ZREMES','M',10,0,'Ntas. Reme.','Ntas. Reme.','Ntas. Reme.','Notas de Remessa','Notas de Remessa','Notas de Remessa','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC6','B2','C6_DESCCOM','C',50,0,'Desc. Comp','Desc. Comp','Desc. Comp','Descricao Complementar','Descricao Complementar','Descricao Complementar','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SC6','B4','C6_CODF','C',15,0,'Cod. Fatura','Cod. Fatura','Cod. Fatura','Codigo da Fatura do PV','Codigo da Fatura do PV','Codigo da Fatura do PV','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
//
// Tabela SD1
//
aAdd( aSX3, {'SD1','L5','D1_ZFLAG','C',1,0,'Proces Cotac','Proces Cotac','Proces Cotac','Processa Cotacao','Processa Cotacao','Processa Cotacao','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'"N"','',0,	Chr(254) + Chr(192),'','','U','N','V','R','','','','','','','','','','',''} )
//
// Tabela SD3
//
aAdd( aSX3, {'SD3','81','D3_ZTM','C',3,0,'T.M KP','T.M. KP','T.M. KP','TIPO MOVIMENTACAO KP','TIPO MOVIMENTACAO KP','TIPO MOVIMENTACAO KP','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SD3','82','D3_ZCUSTKP','N',14,2,'Custo Tot KP','CUSTO TOT KP','CUSTO TOT KP','Custo da movimentacao KP','Custo da movimentacao KP','Custo da movimentacao KP','@E 99,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SD3','83','D3_ZNOTA','C',9,0,'Nota KP','Nota KP','Nota KP','Nota KP','Nota de Remessa KP','Nota de Remessa KP','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SD3','84','D3_ZSERIE','C',3,0,'Serie KP','Serie KP','Serie KP','Serie de remessa KP','Serie de remessa KP','Serie de remessa KP','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
aAdd( aSX3, {'SD3','85','D3_ZORIGEM','C',10,0,'Origem KP','Origem KP','Origem KP','Origem KP','Origem KP','Origem KP','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','',''} )
//
// Tabela SE1
//
aAdd( aSX3, {'SE1','M9','E1_ZBANCO','C',3,0,'Cod Banco','Cod Banco','Cod Banco','Codigo do Banco Boleto','Codigo do Banco Boleto','Codigo do Banco Boleto','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'SE1','N0','E1_ZBOLETO','C',1,0,'Gera Boleto?','Gera Boleto?','Gera Boleto?','Gera Boleto?','Gera Boleto?','Gera Boleto?','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','€','','S=Sim;N=Nao','','','','','','','','S'} )
aAdd( aSX3, {'SE1','N2','E1_ZREMES','C',20,0,'Num. Rem. KP','Num. Rem. KP','Num. Rem. KP','Numero de Remessa do KP','Numero de Remessa do KP','Numero de Remessa do KP','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',0,	Chr(254) + Chr(192),'','','U','N','A','R','','','','','','','','','','','S'} )
//
// Tabela SF4
//
aAdd( aSX3, {'SF4','H6','F4_ZFLAG','C',1,0,'Flag Export.','Flag Export.','Flag Export.','Flag de Exportacao','Flag de Exportacao','Flag de Exportacao','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',0,	Chr(254) + Chr(192),'','','U','N','V','R','','','','','','','','','','',''} )
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
ฑฑบ Programa ณ FSAtuSIX บ Autor ณ TOTVS Protheus     บ Data ณ  29/11/2011 บฑฑ
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
// Tabela P00
//
aAdd( aSIX, {'P00','1','P00_FILIAL+P00_FILORI+P00_DATA+P00_HORA','Indice inicial','Indice inicial','Indice inicial','U','','','S'} )
//
// Tabela P01
//
aAdd( aSIX, {'P01','1','P01_FILIAL+P01_COD+P01_LOJA+P01_ITEM','Codigo+Loja+Item','Codigo+Loja+Item','Codigo+Loja+Item','U','','','S'} )
//
// Tabela P02
//
aAdd( aSIX, {'P02','1','P02_FILIAL+P02_FLORI1+P02_DTEMI1+P02_NUM1+P02_SERIE1+P02_FLORI2+P02_DTEMI2+P02_NUM2+P02_SERIE2','Numero de Fatura','Numero de Fatura','Numero de Fatura','U','','','S'} )
aAdd( aSIX, {'P02','2','P02_ID+P02_FILIAL+P02_NUM1+P02_SERIE1','Numero da Fatura Integracao','Numero da Fatura Integracao','Numero da Fatura Integracao','U','','','N'} )
//
// Tabela SC5
//
aAdd( aSIX, {'SC5','5','C5_FILIAL+C5_ZPEDIDO','[Exclusivo TopMix] Ordenacao por pedido','[Exclusivo TopMix] Ordenacao por pedido','[Exclusivo TopMix] Ordenacao por pedido','U','','FSIND00002','N'} )
aAdd( aSIX, {'SC5','6','C5_FILIAL+C5_NOTA+C5_SERIE','[Exclusivo TopMix] Ordenacao por nota e serie','[Exclusivo TopMix] Ordenacao por nota e serie','[Exclusivo TopMix] Ordenacao por nota e serie','U','','FSIND03','S'} )
//
// Tabela SC6
//
aAdd( aSIX, {'SC6','C','C6_FILIAL+C6_ZPEDIDO','[Exclusivo TopMix] Indice ordenado por pedido KP','[Exclusivo TopMix] Indice ordenado por pedido KP','[Exclusivo TopMix] Indice ordenado por pedido KP','U','','FSIND00001','N'} )
//
// Tabela SE1
//
aAdd( aSIX, {'SE1','Q','E1_FILIAL+E1_PREFIXO+E1_ZREMES','[Exclusivo TopMix] Ordenacao por numero de remessa','[Exclusivo TopMix] Ordenacao por numero de remessa','[Exclusivo TopMix] Ordenacao por numero de remessa','U','','FSIND00004','S'} )
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
ฑฑบ Programa ณ FSAtuSX6 บ Autor ณ TOTVS Protheus     บ Data ณ  29/11/2011 บฑฑ
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

aAdd( aSX6, {'  ','FS_AGTLACC','L','[Exclusivo TopMix] Mostra lancto contabil','','','Parametro usado somente no processo de integracao.','','','','','','.T.','.T.','.T.','U',''} )
aAdd( aSX6, {'  ','FS_BRADES1','C','Texto 1 a ser impresso no Boleto - BRADESCO','','','','','','','','','FONE COBRANCA: (31) 2103 - 1347                                                                                                                                                                                                                           ','FONE COBRANCA: (31) 2103 - 1347                                                                                                                                                                                                                           ','FONE COBRANCA: (31) 2103 - 1347                                                                                                                                                                                                                           ','U',''} )
aAdd( aSX6, {'  ','FS_BRADES2','C','Texto 2 a ser impresso no Boleto - BRADESCO','','','','','','','','','NOTIFICADO: 03 DIAS APOS O VENCIMENTO DOS TITULOS NAO PAGOS SERAO ENCAMINHADOS A CARTORIO PARA CITACAO E PROTESTO.                                                                                                                                        ','NOTIFICADO: 03 DIAS APOS O VENCIMENTO DOS TITULOS NAO PAGOS SERAO ENCAMINHADOS A CARTORIO PARA CITACAO E PROTESTO.                                                                                                                                        ','NOTIFICADO: 03 DIAS APOS O VENCIMENTO DOS TITULOS NAO PAGOS SERAO ENCAMINHADOS A CARTORIO PARA CITACAO E PROTESTO.                                                                                                                                        ','U',''} )
aAdd( aSX6, {'  ','FS_BRADES3','C','Texto 3 a ser impresso no Boleto - BRADESCO','','','','','','','','','PERCENTUAL JUROS/MORA POR DIA DE ATRASO: 0,20% PERCENTUAL DE MULTA POR DIA DE ATRASO: 0,06%                                                                                                                                                               ','PERCENTUAL JUROS/MORA POR DIA DE ATRASO: 0,20% PERCENTUAL DE MULTA POR DIA DE ATRASO: 0,06%                                                                                                                                                               ','PERCENTUAL JUROS/MORA POR DIA DE ATRASO: 0,20% PERCENTUAL DE MULTA POR DIA DE ATRASO: 0,06%                                                                                                                                                               ','U',''} )
aAdd( aSX6, {'  ','FS_CONDFAT','C','Condicao de pagamento de faturamente de pedidos','','','[Exclusivo integracao KP]','','','','','','F02','F02','F02','U',''} )
aAdd( aSX6, {'  ','FS_CONDREM','C','Esse parametro e responsavel por armazenar  o','','','codigo da condicao de pagamento padrao.','','','','','','002','002','002','U',''} )
aAdd( aSX6, {'  ','FS_CONTROL','C','Nome do Controler','','','','','','','','','Tharso Bossolani','','','U',''} )
aAdd( aSX6, {'  ','FS_CPOSCLI','C','Campos do SA1 que serao utilizados na Base de Inte','','','gracao. - Favor colocar somente o nome do campo se','','','m o prefixo - ex.: A1_COD/A1_LOJA fica COD/LOJA/','','','MSBLQL/NOME/NREDUZ/VEND/PESSOA/CGC/PFISICA/INSCR/INSCRM/DDD/FAX/TEL/HPAGE/LC/END/COMPLEM/BAIRRO/COD_MUN/MUN/EST/CEP/ENDCOB/BAIRROC','MSBLQL/NOME/NREDUZ/VEND/PESSOA/CGC/PFISICA/INSCR/INSCRM/DDD/FAX/TEL/HPAGE/LC/END/COMPLEM/BAIRRO/COD_MUN/MUN/EST/CEP/ENDCOB/BAIRROC','MSBLQL/NOME/NREDUZ/VEND/PESSOA/CGC/PFISICA/INSCR/INSCRM/DDD/FAX/TEL/HPAGE/LC/END/COMPLEM/BAIRRO/COD_MUN/MUN/EST/CEP/ENDCOB/BAIRROC','U',''} )
aAdd( aSX6, {'  ','FS_CTBLINE','L','[Exclusivo TopMix]Contabiliza On-Line','','','Parametro usado somente no processo de integracao.','','','','','','.T.','.T.','.T.','U',''} )
aAdd( aSX6, {'  ','FS_DIRDOT','C','Diretorio do Arquivo .dot','','','','','','','','','U:\CartaProt.DOT','','','U',''} )
aAdd( aSX6, {'  ','FS_FAXCOB3','C','[Exclusivo TopMix] Fax de cobranca','','','','','','','','','31-3375-9638','31-3375-9638','31-3375-9638','U',''} )
aAdd( aSX6, {'  ','FS_GRPPRD','C','Grupo de Produtos da Integracao','','','','','','','','','8003','8003','U',''} )
aAdd( aSX6, {'  ','FS_INTDBAM','C','','','','','','','','','','MSSQL/betonMIXInterface','MSSQL/betonMIXInterface','MSSQL/betonMIXInterface','U',''} )
aAdd( aSX6, {'  ','FS_INTDBIP','C','','','','','','','','','','192.168.0.20','192.168.0.20','192.168.0.20','U',''} )
aAdd( aSX6, {'  ','FS_ITAU1','C','Texto 1 a ser impresso no Boleto - ITAU','','','','','','','','','Notificacao: 05 dias apos o vencimento os titulos nao pagos serao encaminhados a cartorio para citacao e protesto.','Notificacao: 05 dias apos o vencimento os titulos nao pagos serao encaminhados a cartorio para citacao e protesto.','Notificacao: 05 dias apos o vencimento os titulos nao pagos serao encaminhados a cartorio para citacao e protesto.','U',''} )
aAdd( aSX6, {'  ','FS_ITAU2','C','Texto 2 a ser impresso no Boleto - ITAU 	','','','','','','','','','FONE COBRANCA: (31) 2103 - 1347','FONE COBRANCA: (31) 2103 - 1347','FONE COBRANCA: (31) 2103 - 1347','U',''} )
aAdd( aSX6, {'  ','FS_ITAU3','C','Texto 3 a ser impresso no Boleto - ITAU 	','','','','','','','','','PERCENTUAL JUROS/MORA POR DIA DE ATRASO: 0,20% PERCENTUAL DE MULTA POR DIA DE ATRASO: 0,06%','PERCENTUAL JUROS/MORA POR DIA DE ATRASO: 0,20% PERCENTUAL DE MULTA POR DIA DE ATRASO: 0,06%','PERCENTUAL JUROS/MORA POR DIA DE ATRASO: 0,20% PERCENTUAL DE MULTA POR DIA DE ATRASO: 0,06%','U',''} )
aAdd( aSX6, {'  ','FS_LACCTAB','L','[Exclusivo Top Mix] Mostra lancto contabil','','','Parametro usado somente no processo de integracao.','','','','','','.T.','.T.','.T.','U',''} )
aAdd( aSX6, {'  ','FS_PEDCART','L','[Exclusivo TopMix] Pedido em carteira','','','Parametro usado somente no processo de integracao.','','','','','','.T.','.T.','.T.','U',''} )
aAdd( aSX6, {'  ','FS_SANTAN1','C','Texto 1 a ser impresso no Boleto - SANTANDER','','','','','','','','','FONE COBRANCA: (31) 2103 - 1347','FONE COBRANCA: (31) 2103 - 1347','FONE COBRANCA: (31) 2103 - 1347','U',''} )
aAdd( aSX6, {'  ','FS_SANTAN2','C','Texto 2 a ser impresso no Boleto - SANTANDER','','','','','','','','','NOTIFICADO: 03 DIAS APOS O VENCIMENTO DOS TITULOS NAO PAGOS SERAO ENCAMINHADOS A CARTORIO PARA CITACAO E PROTESTO.','NOTIFICADO: 03 DIAS APOS O VENCIMENTO DOS TITULOS NAO PAGOS SERAO ENCAMINHADOS A CARTORIO PARA CITACAO E PROTESTO.','NOTIFICADO: 03 DIAS APOS O VENCIMENTO DOS TITULOS NAO PAGOS SERAO ENCAMINHADOS A CARTORIO PARA CITACAO E PROTESTO.','U',''} )
aAdd( aSX6, {'  ','FS_SANTAN3','C','Texto 3 a ser impresso no Boleto - SANTANDER','','','','','','','','','PERCENTUAL JUROS/MORA POR DIA DE ATRASO: 0,20% PERCENTUAL DE MULTA POR DIA DE ATRASO: 0,06%','PERCENTUAL JUROS/MORA POR DIA DE ATRASO: 0,20% PERCENTUAL DE MULTA POR DIA DE ATRASO: 0,06%','PERCENTUAL JUROS/MORA POR DIA DE ATRASO: 0,20% PERCENTUAL DE MULTA POR DIA DE ATRASO: 0,06%','U',''} )
aAdd( aSX6, {'  ','FS_TABPRC','C','Define tabela de preco padrao para Integracao de C','','','usto com KP.','','','','','','000','000','000','U',''} )
aAdd( aSX6, {'  ','FS_TELCOB1','C','[Exclusivo TopMix] Fax de cobrancao','','','','','','','','','31-2103-1332','31-2103-1332','31-2103-1332','U',''} )
aAdd( aSX6, {'  ','FS_TESREM','C','O codigo correspondente a TS de Saida','','','','','','','','','531','531','531','U',''} )
aAdd( aSX6, {'  ','FS_TIPPRD','C','Define o tipo de produto para Integracao com apura','','','cao de custo com KP.','','','','','','CC','CC','CC','U',''} )
aAdd( aSX6, {'  ','MV_ENVSINC','C','Informe a forma de envio de RPS na rotina de Nfse.','Informe a forma de envio de RPS na rotina de Nfse.','Informe a forma de envio de RPS na rotina de Nfse.','Informe a forma de envio de RPS na rotina de Nfse.','Informe a forma de envio de RPS na rotina de Nfse.','Informe a forma de envio de RPS na rotina de Nfse.','Informe a forma de envio de RPS na rotina de Nfse.','Informe a forma de envio de RPS na rotina de Nfse.','Informe a forma de envio de RPS na rotina de Nfse.','N','N','N','U',''} )
aAdd( aSX6, {'  ','MV_ITEMAGL','C','Permite a aglutinacao dos itens do pedido de','','','faturamento [Exclusivo TOPMIX]','','','','','','S','S','S','U',''} )
aAdd( aSX6, {'  ','MV_MAXLOTE','C','Informe o numero maximo de lotes que a rotina de','','','Nfse ira permitir que sejam transmitidos em uma','','','remessa.','','','1','1','1','U',''} )
aAdd( aSX6, {'  ','MV_SPEDURL','C','','','','','','','','','','','','','U',''} )
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
ฑฑบ Programa ณ FSAtuSX7 บ Autor ณ TOTVS Protheus     บ Data ณ  29/11/2011 บฑฑ
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
// Campo P01_CODMUN
//
aAdd( aSX7, {'P01_CODMUN','001','CC2->CC2_MUN','P01_MUN','P','S','CC2',1,'XFILIAL("CC2")+M->P01_EST+M->P01_CODMUN','U',''} )
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
ฑฑบ Programa ณ FSAtuHlp บ Autor ณ TOTVS Protheus     บ Data ณ  29/11/2011 บฑฑ
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
// Helps Tabela CTT
//
aHlpPor := {}
aAdd( aHlpPor, 'Flag de Exportacao' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PCTT_ZFLAG ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "CTT_ZFLAG " + CRLF

//
// Helps Tabela DA1
//
aHlpPor := {}
aAdd( aHlpPor, 'Unidade de Medida' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PDA1_UM    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "DA1_UM    " + CRLF

//
// Helps Tabela DA3
//
aHlpPor := {}
aAdd( aHlpPor, 'Identifica็ใo do Registro' )
aAdd( aHlpPor, 'A01082011181111' )
aAdd( aHlpPor, 'A=Identifica Altera็ใo' )
aAdd( aHlpPor, '01082011=Data altera็ใo' )
aAdd( aHlpPor, '181111=Hora Altera็ใo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PDA3_ZIDENT", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "DA3_ZIDENT" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Campo exclusivo TopMix]' )
aAdd( aHlpPor, 'Flag para sinalizar arquivo Exportado' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PDA3_ZFLAG ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "DA3_ZFLAG " + CRLF

//
// Helps Tabela DA4
//
aHlpPor := {}
aAdd( aHlpPor, '[campo exclusivo cliente TopMix]' )
aAdd( aHlpPor, 'Campo que sinaliza registro exportado.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PDA4_ZFLAG ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "DA4_ZFLAG " + CRLF

//
// Helps Tabela P00
//
aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'N๚mero sequencial da tabela' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP00_ID    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P00_ID    " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Filial de origem do erro gerado na' )
aAdd( aHlpPor, 'integra็ใo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP00_FILORI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P00_FILORI" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Data do Erro gerado na integra็ใo.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP00_DATA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P00_DATA  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Hora do Erro de Integra็ใo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP00_HORA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P00_HORA  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Pedido KP que ocorreu erro na integra็ใo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP00_PEDKP ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P00_PEDKP " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Rotina que gerou o erro na integra็ใo.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP00_ROTINA", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P00_ROTINA" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Erro gerado na integra็ใo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP00_ERRO  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P00_ERRO  " + CRLF

//
// Helps Tabela P01
//
aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Codigo do Cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP01_COD   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P01_COD   " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Codigo que identifica a Loja do Cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP01_LOJA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P01_LOJA  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Item do Endere็o' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP01_ITEM  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P01_ITEM  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Endereco do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP01_END   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P01_END   " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Complemento de Endereco do Cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP01_COMPLE", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P01_COMPLE" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Bairro do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP01_BAIRRO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P01_BAIRRO" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Estado do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP01_EST   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P01_EST   " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Codigo do Municipio' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP01_CODMUN", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P01_CODMUN" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Municipio do cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP01_MUN   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P01_MUN   " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Cod Enderecamento Postal do Cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP01_CEP   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P01_CEP   " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, "Se preenchido com '*' significa que o" )
aAdd( aHlpPor, 'registro estแ na base de integra็ใo.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP01_ZFLAG ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P01_ZFLAG " + CRLF

//
// Helps Tabela P02
//
aHlpPor := {}
aAdd( aHlpPor, '[Especifico TopMix]' )
aAdd( aHlpPor, 'Campo auto Incremento na tabela' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP02_ID    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P02_ID    " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Filial da Nota Fiscal de Fatura.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP02_FLORI1", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P02_FLORI1" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMIx]' )
aAdd( aHlpPor, 'Emissใo da Nota Fiscal de Fatura.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP02_DTEMI1", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P02_DTEMI1" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[ExclusivoTopMix]' )
aAdd( aHlpPor, 'N๚mero da NF Fatura' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP02_NUM1  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P02_NUM1  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Serie da Nota Fiscal de Fatura' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP02_SERIE1", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P02_SERIE1" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Filial da Nota Fiscal de Remessa' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP02_FLORI2", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P02_FLORI2" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Data de Emissใo da Nota fiscal de' )
aAdd( aHlpPor, 'remessa' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP02_DTEMI2", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P02_DTEMI2" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'N๚mero da Nota FIscal de Remessa' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP02_NUM2  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P02_NUM2  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[TopMix]' )
aAdd( aHlpPor, 'Serie da Nota Fiscal de Remessa' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PP02_SERIE2", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "P02_SERIE2" + CRLF

//
// Helps Tabela SA1
//
aHlpPor := {}
aAdd( aHlpPor, 'Identifica็ใo do Registro' )
aAdd( aHlpPor, 'A01082011181111' )
aAdd( aHlpPor, 'A=Identifica Altera็ใo' )
aAdd( aHlpPor, '01082011=Data altera็ใo' )
aAdd( aHlpPor, '181111=Hora Altera็ใo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_ZIDENT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "A1_ZIDENT " + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Cliente de Concreto' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_ZTIPO  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "A1_ZTIPO  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Campo exclusivo TopMix]' )
aAdd( aHlpPor, 'Flag para sinalizar arquivo Exportado' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA1_ZFLAG  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "A1_ZFLAG  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Informe se Cliente faz parte do Incentiv' )
aAdd( aHlpPor, 'a Cultura.' )
aHlpEng := {}
aAdd( aHlpEng, 'Informe se Cliente faz parte do Incentiv' )
aAdd( aHlpEng, 'a Cultura.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe se Cliente faz parte do Incentiv' )
aAdd( aHlpSpa, 'a Cultura.' )

PutHelp( "PA1_INCULT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "A1_INCULT " + CRLF

//
// Helps Tabela SA2
//
aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Campo de Integra็ใo que informa que o' )
aAdd( aHlpPor, 'registro foi enviado para a base de' )
aAdd( aHlpPor, 'integra็ใo, se estiver com conteudo' )
aAdd( aHlpPor, "igual a '*'" )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA2_ZFLAG  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "A2_ZFLAG  " + CRLF

//
// Helps Tabela SA3
//
aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Campo de Integra็ใo que informa que o' )
aAdd( aHlpPor, 'registro foi enviado para a base de' )
aAdd( aHlpPor, 'integra็ใo, se estiver com conteudo' )
aAdd( aHlpPor, "igual a '*'" )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PA3_ZFLAG  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "A3_ZFLAG  " + CRLF

//
// Helps Tabela SB1
//
aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Produto integrado com o KP' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PB1_ZFLAG  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "B1_ZFLAG  " + CRLF

//
// Helps Tabela SC5
//
aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo KP]' )
aAdd( aHlpPor, 'N๚mero de Identifica็ใo do KP.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZPEDIDO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZPEDIDO" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Informa qual o tipo do Pedido 1-Remessa,' )
aAdd( aHlpPor, '2-Fatura.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZTIPO  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZTIPO  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Valor ou percentual da parcela 5,' )
aAdd( aHlpPor, 'depende da condi็ใo de pagamento (tipo 9' )
aAdd( aHlpPor, 'da condi็ใo de pagamento)' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_PARC5  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_PARC5  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Data de Vencimento da parcela 5, se' )
aAdd( aHlpPor, 'informado o valor da parcela 1(tipo 9 da' )
aAdd( aHlpPor, 'condi็ใo de pagamento)' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_DATA5  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_DATA5  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Valor ou percentual da parcela 6,' )
aAdd( aHlpPor, 'depende da condi็ใo de pagamento (tipo 9' )
aAdd( aHlpPor, 'da condi็ใo de pagamento)' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_PARC6  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_PARC6  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Indica se gera Boleto Sim/NAO' )
aAdd( aHlpPor, '[Campo Especifico TopMix]' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZBOLETO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZBOLETO" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo cliente TopMix]' )
aAdd( aHlpPor, 'Ender็o do Cliente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZENDCOB", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZENDCOB" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo cliente TopMix]' )
aAdd( aHlpPor, 'Numero do Endere็o de Cobranca' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZENDNUM", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZENDNUM" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo cliente TopMix]' )
aAdd( aHlpPor, 'Complemento do Endereco  de Cobran็a' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZCOMPLE", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZCOMPLE" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo cliente TopMix]' )
aAdd( aHlpPor, 'Bairro do Endereco de Cobranca' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZBAIROC", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZBAIROC" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo cliente TopMix]' )
aAdd( aHlpPor, 'Municipio do Endereco Cobranca' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZMUN   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZMUN   " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo cliente TopMix]' )
aAdd( aHlpPor, 'Estado do Endereco de Cobran็a' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZEST   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZEST   " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo cliente TopMix]' )
aAdd( aHlpPor, 'CEP do Endereco de Cobranca' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZCEP   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZCEP   " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo para TopMix]' )
aAdd( aHlpPor, 'Campo contendo a chave da NF-e' )
aAdd( aHlpPor, 'disponibilizada pelo KP' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZCHVNFE", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZCHVNFE" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Informa se a nota de originada no KP foi' )
aAdd( aHlpPor, 'cancelada.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZEXCLUI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZEXCLUI" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TOPMIX]' )
aAdd( aHlpPor, 'Numero do CEI' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZCEI   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZCEI   " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMixz]' )
aAdd( aHlpPor, 'Numero do Contrato' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZCONT  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZCONT  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'C๓digo do Municipio' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZCOD_MU", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZCOD_MU" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Endere็o da Obra' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZENDOB ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZENDOB " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Excluisivo TopMix]' )
aAdd( aHlpPor, 'N๚mero do Endere็o' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZNUMOB ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZNUMOB " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Complemeno de endere็o da Obra' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZCOMOB ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZCOMOB " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Endere็o da Obra' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZBAIROB", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZBAIROB" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'C๓digo do Municipio da Obra' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZMUNOB ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZMUNOB " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Estado onde a Obra estแ sendo realizada.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZESTOB ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZESTOB " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'CEP de onde a obra estแ sendo executada.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZCEPOB ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZCEPOB " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Centro de custo equivalente ao informado' )
aAdd( aHlpPor, 'no KP' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZCC    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZCC    " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'UF do estado onde a obra estแ sendo' )
aAdd( aHlpPor, 'executada.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZUF    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZUF    " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo cliente TopMix]' )
aAdd( aHlpPor, 'Origem do Registro' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_ZORIGEM", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_ZORIGEM" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Data de Vencimento da parcela 6, se' )
aAdd( aHlpPor, 'informado o valor da parcela 1(tipo 9 da' )
aAdd( aHlpPor, 'condi็ใo de pagamento)' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_DATA6  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_DATA6  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Veiculo utilizado no Transporte do pedid' )
aHlpEng := {}
aAdd( aHlpEng, 'Veiculo utilizado no Transporte do pedid' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Veiculo utilizado no Transporte do pedid' )

PutHelp( "PC5_VEICULO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_VEICULO" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Mensagem Padrใo 1' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_MENPAD1", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_MENPAD1" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Mensagem Padrใo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_MENPAD2", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_MENPAD2" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Mensagem Padrใo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_MENPAD3", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_MENPAD3" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Mensagem Padrใo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC5_MENPAD4", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C5_MENPAD4" + CRLF

//
// Helps Tabela SC6
//
aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Numero de Identifica็ใo do KP' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC6_ZPEDIDO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C6_ZPEDIDO" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Identificador da base de integra็ใo com' )
aAdd( aHlpPor, 'KP' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC6_ZID    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C6_ZID    " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Centro de custos equivalente a obra do' )
aAdd( aHlpPor, 'KP' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC6_ZCC    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C6_ZCC    " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Notas de remessa.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC6_ZREMES ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C6_ZREMES " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'Descri็ใo complementar do item do pedido' )
aAdd( aHlpPor, 'de venda' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC6_DESCCOM", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C6_DESCCOM" + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Exclusivo TopMix]' )
aAdd( aHlpPor, 'C๓digo do produto do PV fatura' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PC6_CODF   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C6_CODF   " + CRLF

//
// Helps Tabela SD1
//
aHlpPor := {}
aAdd( aHlpPor, 'Processa a Cotacao' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PD1_ZFLAG  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "D1_ZFLAG  " + CRLF

//
// Helps Tabela SD3
//
aHlpPor := {}
aAdd( aHlpPor, '[TOP MIX]' )
aAdd( aHlpPor, 'TIPO MOVIMENTACAO KP' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PD3_ZTM    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "D3_ZTM    " + CRLF

aHlpPor := {}
aAdd( aHlpPor, '[Top Mix]' )
aAdd( aHlpPor, 'Custo da moviemta็ใo KP' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PD3_ZCUSTKP", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "D3_ZCUSTKP" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Nota de remessa KP' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PD3_ZNOTA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "D3_ZNOTA  " + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Serie de remssa KP' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PD3_ZSERIE ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "D3_ZSERIE " + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Origem KP' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PD3_ZORIGEM", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "D3_ZORIGEM" + CRLF

//
// Helps Tabela SE1
//
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

//
// Helps Tabela SF4
//
aHlpPor := {}
aAdd( aHlpPor, 'Flag de Exportacao' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PF4_ZFLAG  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "F4_ZFLAG  " + CRLF

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
ฑฑบ Programa ณ MyOpenSM0บ Autor ณ TOTVS Protheus     บ Data ณ  29/11/2011 บฑฑ
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
