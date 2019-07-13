#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPDPINI
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  10/08/2014
@obs    Gerado por EXPORDIC - V.4.21.9.4 EFS / Upd. V.4.19.10 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDPINI( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
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
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização Realizada.", "UPDPINI" )
				Else
					MsgStop( "Atualização não Realizada.", "UPDPINI" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização Concluída." )
				Else
					Final( "Atualização não Realizada." )
				EndIf
			EndIf

		Else
			MsgStop( "Atualização não Realizada.", "UPDPINI" )

		EndIf

	Else
		MsgStop( "Atualização não Realizada.", "UPDPINI" )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  10/08/2014
@obs    Gerado por EXPORDIC - V.4.21.9.4 EFS / Upd. V.4.19.10 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
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
		// Só adiciona no aRecnoSM0 se a empresa for diferente
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
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SX2
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX2()

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()

			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSIX()

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			// Alteração física dos arquivos
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
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//------------------------------------
			// Atualiza o dicionário SX6
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de parâmetros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			
			//------------------------------------
			// Atualiza os helps
			//------------------------------------
			oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuHlp()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

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


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX2
Função de processamento da gravação do SX2 - Arquivos

@author TOTVS Protheus
@since  10/08/2014
@obs    Gerado por EXPORDIC - V.4.21.9.4 EFS / Upd. V.4.19.10 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SX2" + CRLF )

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"  , "X2_NOMESPA", "X2_NOMEENG", ;
             "X2_DELET"  , "X2_MODO"   , "X2_TTS"    , "X2_ROTINA", "X2_PYME"   , "X2_UNICO"  , ;
             "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }

dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela P09
//
aAdd( aSX2, { ;
	'P09'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'P09'+cEmpr																, ; //X2_ARQUIVO
	'CADASTRO DE APLICACAO'													, ; //X2_NOME
	'CADASTRO DE APLICACAO'													, ; //X2_NOMESPA
	'CADASTRO DE APLICACAO'													, ; //X2_NOMEENG
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
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			AutoGrLog( "Foi incluída a tabela " + aSX2[nI][1] )
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
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			RecLock( "SX2", .F. )
			SX2->X2_UNICO := aSX2[nI][12]
			MsUnlock()

			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
			EndIf

			AutoGrLog( "Foi alterada a chave única da tabela " + aSX2[nI][1] )
		EndIf

	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  10/08/2014
@obs    Gerado por EXPORDIC - V.4.21.9.4 EFS / Upd. V.4.19.10 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
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
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, ;
             { "X3_TITULO" , 0 }, { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, ;
             { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, ;
             { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, ;
             { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, ;
             { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, { "X3_PYME"   , 0 }  }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )


//
// Campos Tabela P09
//
aAdd( aSX3, { ;
	'P09'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'P09_FILIAL'																, ; //X3_CAMPO
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
	'P09'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'P09_SEQ'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sequencial'															, ; //X3_TITULO
	'Sequencial'															, ; //X3_TITSPA
	'Sequencial'															, ; //X3_TITENG
	'Sequencial'															, ; //X3_DESCRIC
	'Sequencial'															, ; //X3_DESCSPA
	'Sequencial'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'U_FSEQP09("P09","P09_SEQ")'												, ; //X3_RELACAO
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
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P09'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'P09_CODAPL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod Aplic'																, ; //X3_TITULO
	'Cod Aplic'																, ; //X3_TITSPA
	'Cod Aplic'																, ; //X3_TITENG
	'Cod Aplicacao'															, ; //X3_DESCRIC
	'Cod Aplicacao'															, ; //X3_DESCSPA
	'Cod Aplicacao'															, ; //X3_DESCENG
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
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'INCLUI'																, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'P09'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'P09_DESCAP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc Apli'																, ; //X3_TITULO
	'Desc Apli'																, ; //X3_TITSPA
	'Desc Apli'																, ; //X3_TITENG
	'Desc Aplicacao'														, ; //X3_DESCRIC
	'Desc Aplicacao'														, ; //X3_DESCSPA
	'Desc Aplicacao'														, ; //X3_DESCENG
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


//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
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
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo] )

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  10/08/2014
@obs    Gerado por EXPORDIC - V.4.21.9.4 EFS / Upd. V.4.19.10 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela P09
//
aAdd( aSIX, { ;
	'P09'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'P09_FILIAL+P09_CODAPL'													, ; //CHAVE
	'Cod Aplic'																, ; //DESCRICAO
	'Cod Aplic'																, ; //DESCSPA
	'Cod Aplic'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'P09'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'P09_FILIAL+P09_SEQ'														, ; //CHAVE
	'Sequencial'															, ; //DESCRICAO
	'Sequencial'															, ; //DESCSPA
	'Sequencial'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt    := .F.
	lDelInd := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "") == ;
		    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
			lDelInd := .T. // Se for alteração precisa apagar o indice do banco
		EndIf
	EndIf

	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()

	dbCommit()

	If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf

	oProcess:IncRegua2( "Atualizando índices..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX6
Função de processamento da gravação do SX6 - Parâmetros

@author TOTVS Protheus
@since  10/08/2014
@obs    Gerado por EXPORDIC - V.4.21.9.4 EFS / Upd. V.4.19.10 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX6()
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

AutoGrLog( "Ínicio da Atualização" + " SX6" + CRLF )

aEstrut := { "X6_FIL"    , "X6_VAR"  , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , "X6_DSCSPA1",;
             "X6_DSCENG1", "X6_DESC2", "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PROPRI" , "X6_PYME" }

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_AGCIELO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Agencia que a Cielo devera efetuar o credito'							, ; //X6_DESCRIC
	'Agencia que a Cielo devera efetuar o credito'							, ; //X6_DSCSPA
	'Agencia que a Cielo devera efetuar o credito'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1430'																	, ; //X6_CONTEUD
	'1430'																	, ; //X6_CONTSPA
	'1430'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_AGREDE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Agencia que a Redecard devera efetuar o credito'						, ; //X6_DESCRIC
	'Agencia que a Redecard devera efetuar o credito'						, ; //X6_DSCSPA
	'Agencia que a Redecard devera efetuar o credito'						, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1430'																	, ; //X6_CONTEUD
	'1430'																	, ; //X6_CONTSPA
	'1430'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_AGTLACC'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'[Exclusivo TopMix] Mostra lancto contabil'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Parametro usado somente no processo de integracao.'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_BCCIELO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Banco que a Cielo devera efetuar o credito'							, ; //X6_DESCRIC
	'Banco que a Cielo devera efetuar o credito'							, ; //X6_DSCSPA
	'Banco que a Cielo devera efetuar o credito'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'341'																	, ; //X6_CONTEUD
	'341'																	, ; //X6_CONTSPA
	'341'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_BCOREDE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Banco que a Redecard devera efetuar o credito'							, ; //X6_DESCRIC
	'Banco que a Redecard devera efetuar o credito'							, ; //X6_DSCSPA
	'Banco que a Redecard devera efetuar o credito'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'341'																	, ; //X6_CONTEUD
	'341'																	, ; //X6_CONTSPA
	'341'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_BRADES1'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Texto 1 a ser impresso no Boleto - BRADESCO'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'FONE COBRANCA: (31) 2103 - 1347'										, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_BRADES2'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Texto 2 a ser impresso no Boleto - BRADESCO'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'NOTIFICADO: 03 DIAS APOS O VENCIMENTO DOS TITULOS NAO PAGOS SERAO ENCAMINHADOS A CARTORIO PARA CITACAO E PROTESTO.', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_BRADES3'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Texto 3 a ser impresso no Boleto - BRADESCO'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'PERCENTUAL JUROS/MORA POR DIA DE ATRASO: 0,20% PERCENTUAL DE MULTA POR DIA DE ATRASO: 0,06%', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_CCCIELO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Conta que a Cielo devera efetuar o credito'							, ; //X6_DESCRIC
	'Conta que a Cielo devera efetuar o credito'							, ; //X6_DSCSPA
	'Conta que a Cielo devera efetuar o credito'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'44323'																	, ; //X6_CONTEUD
	'44323'																	, ; //X6_CONTSPA
	'44323'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_CCREDE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Conta que a Redecard devera efetuar o credito'							, ; //X6_DESCRIC
	'Conta que a Redecard devera efetuar o credito'							, ; //X6_DSCSPA
	'Conta que a Redecard devera efetuar o credito'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'44323'																	, ; //X6_CONTEUD
	'44323'																	, ; //X6_CONTSPA
	'44323'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_CONDFAT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condicao de pagamento de faturamente de pedidos'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'[Exclusivo integracao KP]'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'F02'																	, ; //X6_CONTEUD
	'F02'																	, ; //X6_CONTSPA
	'F02'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_CONDREM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Esse parametro e responsavel por armazenar  o'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'codigo da condicao de pagamento padrao.'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'002'																	, ; //X6_CONTEUD
	'002'																	, ; //X6_CONTSPA
	'002'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_CONTROL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Nome do Controler'														, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_CPOSCLI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campos do SA1 que serao utilizados na Base de Inte'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'gracao. - Favor colocar somente o nome do campo se'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'm o prefixo - ex.: A1_COD/A1_LOJA fica COD/LOJA/'						, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MSBLQL/NOME/NREDUZ/VEND/PESSOA/CGC/PFISICA/INSCR/INSCRM/DDD/FAX/TEL/HPAGE/LC/END/COMPLEM/BAIRRO/COD_MUN/MUN/EST/CEP/ENDCOB/BAIRROC', ; //X6_CONTEUD
	'MSBLQL/NOME/NREDUZ/VEND/PESSOA/CGC/PFISICA/INSCR/INSCRM/DDD/FAX/TEL/HPAGE/LC/END/COMPLEM/BAIRRO/COD_MUN/MUN/EST/CEP/ENDCOB/BAIRROC', ; //X6_CONTSPA
	'MSBLQL/NOME/NREDUZ/VEND/PESSOA/CGC/PFISICA/INSCR/INSCRM/DDD/FAX/TEL/HPAGE/LC/END/COMPLEM/BAIRRO/COD_MUN/MUN/EST/CEP/ENDCOB/BAIRROC', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_CTBLINE'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'[Exclusivo TopMix]Contabiliza On-Line'									, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Parametro usado somente no processo de integracao.'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_DIRDOT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Diretorio do Arquivo .dot'												, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_EMAIL'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Email Top MIX'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'topmix@topmix.com.br'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_EMPABAT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Empresa que nao utilizam o abatimento de materias.'					, ; //X6_DESCRIC
	'Empresa que nao utilizam o abatimento de materias.'					, ; //X6_DSCSPA
	'Empresa que nao utilizam o abatimento de materias.'					, ; //X6_DSCENG
	'O codigo das empresas devem ser dividos por " |"'						, ; //X6_DESC1
	'O codigo das empresas devem ser dividos por " |"'						, ; //X6_DSCSPA1
	'O codigo das empresas devem ser dividos por " |"'						, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'010113|'																, ; //X6_CONTEUD
	'010113|010103'															, ; //X6_CONTSPA
	'010113|010103'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_FAXCOB3'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Telefone de cobrança'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'3288-2006'																, ; //X6_CONTEUD
	'3288-2006'																, ; //X6_CONTSPA
	'3288-2006'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_FINLIB'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Guarda o prefixo dos que apareceram na tela de lib'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'liberacao.'															, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'R$,CH, CC,CD,BO'														, ; //X6_CONTEUD
	'R$,CH, CC,CD,BO'														, ; //X6_CONTSPA
	'R$,CH, CC,CD,BO'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_GRPEMP'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Grupo de empresas que pode realizar o processo'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'agendado.'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_GRPPRD'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Grupo de Produtos da Integracao'										, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'8003'																	, ; //X6_CONTEUD
	'8003'																	, ; //X6_CONTSPA
	'U'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_INTDBAM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MSSQL/betonMIXInterface'												, ; //X6_CONTEUD
	'MSSQL/betonMIXInterface'												, ; //X6_CONTSPA
	'MSSQL/betonMIXInterface'												, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_INTDBIP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'IP servidor BD para integracao com KP'									, ; //X6_DESCRIC
	'IP servidor BD para integracao com KP'									, ; //X6_DSCSPA
	'IP servidor BD para integracao com KP'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'192.168.0.20'															, ; //X6_CONTEUD
	'192.168.0.20'															, ; //X6_CONTSPA
	'192.168.0.20'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_ITAU1'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Texto 1 a ser impresso no Boleto - ITAU'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'Notificacao: 05 dias apos o vencimento os titulos nao pagos serao encaminhados a cartorio para citacao e protesto.', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_ITAU2'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Texto 2 a ser impresso no Boleto - ITAU'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'FONE COBRANCA: (31) 2103 - 1347'										, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_ITAU3'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Texto 3 a ser impresso no Boleto - ITAU'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'PERCENTUAL JUROS/MORA POR DIA DE ATRASO: 0,20% PERCENTUAL DE MULTA POR DIA DE ATRASO: 0,06%', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_LACCTAB'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'[Exclusivo Top Mix] Mostra lancto contabil'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Parametro usado somente no processo de integracao.'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_LOTE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Lote controlado de baixas'												, ; //X6_DESCRIC
	'Lote controlado de baixas'												, ; //X6_DSCSPA
	'Lote controlado de baixas'												, ; //X6_DSCENG
	'Lote controlado de baixas'												, ; //X6_DESC1
	'Lote controlado de baixas'												, ; //X6_DSCSPA1
	'Lote controlado de baixas'												, ; //X6_DSCENG1
	'Lote controlado de baixas'												, ; //X6_DESC2
	'Lote controlado de baixas'												, ; //X6_DSCSPA2
	'Lote controlado de baixas'												, ; //X6_DSCENG2
	'201203000000001'														, ; //X6_CONTEUD
	'201203000000001'														, ; //X6_CONTSPA
	'201203000000001'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_MENNOTA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Mensagem a ser impressa na NF Fatura'									, ; //X6_DESCRIC
	'Mensagem a ser impressa na NF Fatura'									, ; //X6_DSCSPA
	'Mensagem a ser impressa na NF Fatura'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SERVICO ISENTO DE RETENCAO DOS 4,65% CONFORME LEI NO. 10.833 de 29/12/2003. NAO SUJEITO A RETENCAO DE 11% DE INSS, CONFORME ART.143. INCISO IV DA IN RFB No. 971 de 13/11/2009.', ; //X6_CONTEUD
	'SERVICO ISENTO DE RETENCAO DOS 4,65% CONFORME LEI NO. 10.833 de 29/12/2003.  NAO SUJEITO A RETENCAO DE 11% DE INSS, CONFORME ART.143. INCISO IV DA IN RFB No. 971 de 13/11/2009.', ; //X6_CONTSPA
	'SERVICO ISENTO DE RETENCAO DOS 4,65% CONFORME LEI NO. 10.833 de 29/12/2003.  NAO SUJEITO A RETENCAO DE 11% DE INSS, CONFORME ART.143. INCISO IV DA IN RFB No. 971 de 13/11/2009.', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_MSGPDR'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigo das mensagens padrao para os pedidos de'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'venda tipo 2.'															, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'001,002,003,004'														, ; //X6_CONTEUD
	'001,002,003,004,005'													, ; //X6_CONTSPA
	'001,002,003,004,005'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_MUNABT2'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Municipios que nao utilizam o abatimento de materi'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'3518404/'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_NATUREZ'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'10104'																	, ; //X6_CONTEUD
	'10104'																	, ; //X6_CONTSPA
	'10104'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_PEDCART'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'[Exclusivo TopMix] Pedido em carteira'									, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Parametro usado somente no processo de integracao.'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_PREREB'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Prefixo do titulo a ser recebimento'									, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'REC'																	, ; //X6_CONTEUD
	'REC'																	, ; //X6_CONTSPA
	'REC'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_PSSWSKP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Senha do Ws de Numeração'												, ; //X6_DESCRIC
	'Senha do Ws de Numeração'												, ; //X6_DSCSPA
	'Senha do Ws de Numeração'												, ; //X6_DSCENG
	'Senha do Ws de Numeração'												, ; //X6_DESC1
	'Senha do Ws de Numeração'												, ; //X6_DSCSPA1
	'Senha do Ws de Numeração'												, ; //X6_DSCENG1
	'Senha do Ws de Numeração'												, ; //X6_DESC2
	'Senha do Ws de Numeração'												, ; //X6_DSCSPA2
	'Senha do Ws de Numeração'												, ; //X6_DSCENG2
	'kp!betonmix'															, ; //X6_CONTEUD
	'kp!betonmix'															, ; //X6_CONTSPA
	'kp!betonmix'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_RCTNATU'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Natureza recebimento cartao de credito'								, ; //X6_DESCRIC
	'Natureza recebimento cartao de credito'								, ; //X6_DSCSPA
	'Natureza recebimento cartao de credito'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'10199'																	, ; //X6_CONTEUD
	'10199'																	, ; //X6_CONTSPA
	'10199'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_RPSTX1'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Mensagem RPS'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'mulario continuo'														, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'Tel Cobrança'															, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_RPSTX2'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Mensagem RPS'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'mulario continuo'														, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'Tel FAX'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
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

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_SANTAN1'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Texto 1 a ser impresso no Boleto - SANTANDER'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'FONE COBRANCA: (31) 2103 - 1347'										, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_SANTAN2'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Texto 2 a ser impresso no Boleto - SANTANDER'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'NOTIFICADO: 03 DIAS APOS O VENCIMENTO DOS TITULOS NAO PAGOS SERAO ENCAMINHADOS A CARTORIO PARA CITACAO E PROTESTO.', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_SANTAN3'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Texto 3 a ser impresso no Boleto - SANTANDER'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'PERCENTUAL JUROS/MORA POR DIA DE ATRASO: 0,20% PERCENTUAL DE MULTA POR DIA DE ATRASO: 0,06%', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_SERIEKP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie do Sistema KP'													, ; //X6_DESCRIC
	'Serie do Sistema KP'													, ; //X6_DSCSPA
	'Serie do Sistema KP'													, ; //X6_DSCENG
	'Serie do Sistema KP'													, ; //X6_DESC1
	'Serie do Sistema KP'													, ; //X6_DSCSPA1
	'Serie do Sistema KP'													, ; //X6_DSCENG1
	'Serie do Sistema KP'													, ; //X6_DESC2
	'Serie do Sistema KP'													, ; //X6_DSCSPA2
	'Serie do Sistema KP'													, ; //X6_DSCENG2
	'XXX'																	, ; //X6_CONTEUD
	'XXX'																	, ; //X6_CONTSPA
	'XXX'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_SRVNFKP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Url do Kp para numeracao da nota'										, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.100:80/WebServiceERP/Service1.svc'					, ; //X6_CONTEUD
	'http://192.168.0.100:80/WebServiceERP/Service1.svc'					, ; //X6_CONTSPA
	'http://192.168.0.100:80/WebServiceERP/Service1.svc'					, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_TABPRC'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define tabela de preco padrao para Integracao de C'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'usto com KP.'															, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'000'																	, ; //X6_CONTEUD
	'000'																	, ; //X6_CONTSPA
	'000'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_TELCOB1'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Telefone de cobrança'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2103-1332'																, ; //X6_CONTEUD
	'2103-1332'																, ; //X6_CONTSPA
	'2103-1332'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_TELCOB2'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Telefone de cobrança'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2103-1347'																, ; //X6_CONTEUD
	'2103-1347'																, ; //X6_CONTSPA
	'2103-1347'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_TESREM'															, ; //X6_VAR
	'C'																	, ; //X6_TIPO
	'O codigo correspondente a TS de Saida'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'531'																	, ; //X6_CONTEUD
	'531'																	, ; //X6_CONTSPA
	'531'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_TESROM'															, ; //X6_VAR
	'C'																	, ; //X6_TIPO
	'TES para importacao na interface de notas fiscais'	, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'de remessa Romaneio'											, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'538'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																	, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_TIPPRD'															, ; //X6_VAR
	'C'																	, ; //X6_TIPO
	'Define o tipo de produto para Integracao com apura'	, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'cao de custo com KP.'											, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'CC'																	, ; //X6_CONTEUD
	'CC'																	, ; //X6_CONTSPA
	'CC'																	, ; //X6_CONTENG
	'U'																	, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_TX3'																, ; //X6_VAR
	'C'																	, ; //X6_TIPO
	'Mensagem nota Lay Out 2'										, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'Mensagem nota Lay Out 2'										, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																	, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_USRWSKP'														, ; //X6_VAR
	'C'																	, ; //X6_TIPO
	'usuario do servidor de ws de numeracao kp'				, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'kp'																	, ; //X6_CONTEUD
	'kp'																	, ; //X6_CONTSPA
	'kp'																	, ; //X6_CONTENG
	'U'																	, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_ZCEI'															, ; //X6_VAR
	'C'																	, ; //X6_TIPO
	'Filiais do RJ que utilizarao o CEI junto no Cod.Ob'	, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ra.'																	, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'010102;010110;010127;'											, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																	, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_ VCHVNF'														, ; //X6_VAR
	'L'																	, ; //X6_TIPO
	'Verifica se a chave da NFE confere com a NFE'			, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'que esta sendo digitada'										, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																	, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_ATFVLNF'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Utilizado na funcao A030VlNota() da rotina ATFA030'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ou desabilitar a validacao da nota fiscal informad'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'com a tabela de notas fiscais de saida SF2.'							, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_CEI'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica o codigo no Cadastro Especifico do INSS par'					, ; //X6_DESCRIC
	'Indica o codigo no Cadastro Especifico do INSS par'					, ; //X6_DSCSPA
	'Indica o codigo no Cadastro Especifico do INSS par'					, ; //X6_DSCENG
	'a contribuinte.'														, ; //X6_DESC1
	'a contribuinte.'														, ; //X6_DSCSPA1
	'a contribuinte.'														, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_CMCCLI'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'A1_INSCRM'																, ; //X6_CONTEUD
	'A1_INSCRM'																, ; //X6_CONTSPA
	'A1_INSCRM'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_CMCFOR'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'A2_INSCRM'																, ; //X6_CONTEUD
	'A2_INSCRM'																, ; //X6_CONTSPA
	'A2_INSCRM'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_DESCFIN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se o desconto financeiro sera aplicado inte'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'gral ("I") no primeiro pagamento, ou proporcional'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'("P") ao valor pago en cada parcela.'									, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'I'																		, ; //X6_CONTEUD
	'I'																		, ; //X6_CONTSPA
	'I'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_DESFOL'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Ano e Mes de competencia do inicio da desoneracao'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'da folha de pagamento'													, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'201401'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_DIFNF'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Diferenca aceitavel na entrada da NF de MCC'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'TOPMIX'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_FILEST'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Filiais com controle de estoque'										, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'010100'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_FINATFN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'"1" = Fluxo Caixa On-Line,"2" = Fluxo Caixa Off-Li'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ne'																	, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_GRUPRA'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Grupo de usuario com permissao para inclusao do RA'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'via contas a receber'													, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_INSCRIM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica o numero da Inscricao Municipal para contri'					, ; //X6_DESCRIC
	'Indica o numero da Inscricao Municipal para contri'					, ; //X6_DSCSPA
	'Indica o numero da Inscricao Municipal para contri'					, ; //X6_DSCENG
	'buinte'																, ; //X6_DESC1
	'buinte'																, ; //X6_DSCSPA1
	'buinte'																, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_INSDIPJ'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define o codigo da retencao do INSS'									, ; //X6_DESCRIC
	'Define o codigo da retencao do INSS'									, ; //X6_DSCSPA
	'Define o codigo da retencao do INSS'									, ; //X6_DSCENG
	'para que o Sistema gere a DIPJ.'										, ; //X6_DESC1
	'para que o Sistema gere a DIPJ.'										, ; //X6_DSCSPA1
	'para que o Sistema gere a DIPJ.'										, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2631'																	, ; //X6_CONTEUD
	'2631'																	, ; //X6_CONTSPA
	'2631'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MUNDMA'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campos das tabelas SA1 e SA2 que contem o'								, ; //X6_DESCRIC
	'Campos das tabelas SA1 e SA2 que contem o'								, ; //X6_DSCSPA
	'Campos das tabelas SA1 e SA2 que contem o'								, ; //X6_DSCENG
	'codigo do municipio do cliente / fornecedor'							, ; //X6_DESC1
	'codigo do municipio do cliente / fornecedor'							, ; //X6_DSCSPA1
	'codigo do municipio do cliente / fornecedor'							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'{“SA1->A1_COD_MUN”,”SA2->A2_COD_MUN”}'									, ; //X6_CONTEUD
	'{“SA1->A1_COD_MUN”,”SA2->A2_COD_MUN”}'									, ; //X6_CONTSPA
	'{“SA1->A1_COD_MUN”,”SA2->A2_COD_MUN”}'									, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NFSERVF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tes usada para entrada de nota fiscal de servico p'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ara referente ao frete de MCC'											, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'058061'																, ; //X6_CONTEUD
	'058'																	, ; //X6_CONTSPA
	'058'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NIT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica o numero de inscricao no cadastro correspon'					, ; //X6_DESCRIC
	'Indica o numero de inscricao no cadastro correspon'					, ; //X6_DSCSPA
	'Indica o numero de inscricao no cadastro correspon'					, ; //X6_DSCENG
	'dente ao  PIS/PASEP/CI/SUS para contribuinte.'							, ; //X6_DESC1
	'dente ao  PIS/PASEP/CI/SUS para contribuinte.'							, ; //X6_DSCSPA1
	'dente ao  PIS/PASEP/CI/SUS para contribuinte.'							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_REGIESP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RISCOE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Numero de dias de Atraso toleravel no Pagemnto de'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Titulos para Clientes com Risco E no Cadastro de'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_SQSPAG'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Gera sequencial cnab'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2149'																	, ; //X6_CONTEUD
	'2149'																	, ; //X6_CONTSPA
	'2149'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_TIPO9SP'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Permite pedidos com codicao tipo 9 e valores d'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'e parcelas diferente do total do pedido, serem inc'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'luidos no sistema.'													, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_UFDESB'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'F1_EST'																, ; //X6_CONTEUD
	'F1_EST'																, ; //X6_CONTSPA
	'F1_EST'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'TM_DIAVCRE'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Dias sem compra do cliente para bloqueio do credit'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'o.'																	, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'90'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'TM_DIFNF'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Diferenca aceitavel na entrada da NF de MCC'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'TOPMIX'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'10'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'TM_PREFKP'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Prefixos utilizados de acordo com regra de series'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=1;2=2;R=R;R2=S;R3=T;R4=V;R5=X;B=B;B1=C;B2=D;B3=E;B4=F;B5=G'			, ; //X6_CONTEUD
	'1=1;R=R;R2=S;R3=T;R4=V;R5=X;B=B;B1=C;B2=C;B3=D;B4=E;B5=F'				, ; //X6_CONTSPA
	'1=1;R=R;R2=S;R3=T;R4=V;R5=X;B=B;B1=C;B2=C;B3=D;B4=E;B5=F'				, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'TM_TMAXFRT'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Diferenca maxima entre o valor do frete da tabela'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'e o valor informado na nota de cohecimento'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'3'																		, ; //X6_CONTEUD
	'3'																		, ; //X6_CONTSPA
	'3'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'TM_TMINFRT'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Diferenca minima entre o valor do frete da tabela'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'e o valor informado na nota de cohecimento'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'3'																		, ; //X6_CONTEUD
	'3'																		, ; //X6_CONTSPA
	'3'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010100'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"00"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010100'																, ; //X6_FIL
	'MV_MODDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Modelo dos documentos da DESBH'										, ; //X6_DESCRIC
	'Modelo dos documentos da DESBH'										, ; //X6_DSCSPA
	'Modelo dos documentos da DESBH'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"U"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010100'																, ; //X6_FIL
	'MV_SERDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DESCRIC
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCSPA
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"SE"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010102'																, ; //X6_FIL
	'FS_KPON'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Verifica se o web serice do kp estao on-line'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010102'																, ; //X6_FIL
	'FS_SRVNFKP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DESCRIC
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCSPA
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCENG
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DESC1
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCSPA1
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCENG1
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DESC2
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCSPA2
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCENG2
	'http://192.168.0.32:81/WebServiceERP/Service1.svc'						, ; //X6_CONTEUD
	'http://192.168.0.31/WebServiceERP/Service1.svc'						, ; //X6_CONTSPA
	'http://192.168.0.31/WebServiceERP/Service1.svc'						, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010102'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"02"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"02"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"02"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010102'																, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	'Informar en este parametro el nombre del municipio'					, ; //X6_DSCSPA
	'Enter the name of the city referring to the Tax'						, ; //X6_DSCENG
	'esta estabelecido.'													, ; //X6_DESC1
	'donde el Contribuyente esta establecido'								, ; //X6_DSCSPA1
	'Payer in this parameter'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'CAJU'																	, ; //X6_CONTEUD
	'CAJU'																	, ; //X6_CONTSPA
	'CAJU'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010102'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084302'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010102'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;U=RPS'															, ; //X6_CONTEUD
	'1=SPED;U=RPS'															, ; //X6_CONTSPA
	'1=SPED;U=RPS'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010102'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema, pa-'					, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema, pa-'					, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema, pa-'					, ; //X6_DSCENG
	'ra efeito de calculo de ICMS (7, 12 ou 18%).'							, ; //X6_DESC1
	'ra efeito de calculo de ICMS (7, 12 ou 18%).'							, ; //X6_DSCSPA1
	'ra efeito de calculo de ICMS (7, 12 ou 18%).'							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RJ'																	, ; //X6_CONTEUD
	'RJ'																	, ; //X6_CONTSPA
	'RJ'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010102'																, ; //X6_FIL
	'MV_MDTDTFI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DESCRIC
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DSCSPA
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DSCENG
	'das secoes do P.P.P.'													, ; //X6_DESC1
	'das secoes do P.P.P.'													, ; //X6_DSCSPA1
	'das secoes do P.P.P.'													, ; //X6_DSCENG1
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DESC2
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DSCSPA2
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010102'																, ; //X6_FIL
	'MV_MODDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Modelo dos documentos da DESBH'										, ; //X6_DESCRIC
	'Modelo dos documentos da DESBH'										, ; //X6_DSCSPA
	'Modelo dos documentos da DESBH'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"U"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010102'																, ; //X6_FIL
	'MV_NGMDTRP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se ira executar a reprogramacao'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'automaticamente para exames de programa'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'de saude. 1=Sim;2=Nao;3=Exibe pergunta.'								, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010102'																, ; //X6_FIL
	'MV_NGMDTVA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se ira considerar funcionarios afastados na'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'programacao de exames.'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'1=Sim;2=Nao'															, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010102'																, ; //X6_FIL
	'MV_SERDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DESCRIC
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCSPA
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"SE"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010102'																, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010102'																, ; //X6_FIL
	'MV_TPSERIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DESCRIC
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCSPA
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCENG
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DESC1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCSPA1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RPS-SE /1A -1A /1F -1F /AV -AV /S  -S  /SE -SE /SF -SF /V1 -V1 /VF -VF /ST -ST /', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010103'																, ; //X6_FIL
	'FS_KPON'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Verifica se o web serice do kp estao on-line'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010103'																, ; //X6_FIL
	'FS_MENNOTA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SERVICO ISENTO DE RETENCAO DOS 4,65% CONF LEI 10.833 de 29/12/2003. NAO SUJEITO A RETENCAO DE 11% DE INSS, CONF ART.143 INCISO IV DA IN RFB 971 de 13/11/2009. EXIGIBILIDADE SUSPENSA POR DECISAO JUDICIAL CONF.PROCESSO 048070128870 10-08-2009', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010103'																, ; //X6_FIL
	'FS_SRVNFKP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DESCRIC
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCSPA
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCENG
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DESC1
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCSPA1
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCENG1
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DESC2
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCSPA2
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCENG2
	'http://192.168.0.32:81/WebServiceERP/Service1.svc'						, ; //X6_CONTEUD
	'http://192.168.0.31/WebServiceERP/Service1.svc'						, ; //X6_CONTSPA
	'http://192.168.0.31/WebServiceERP/Service1.svc'						, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010103'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"03"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"03"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"03"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010103'																, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DSCSPA
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DSCENG
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESC1
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DSCSPA1
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DSCENG1
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESC2
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DSCSPA2
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DSCENG2
	'SERRA'																	, ; //X6_CONTEUD
	'SERRA'																	, ; //X6_CONTSPA
	'SERRA'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010103'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084303'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010103'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;U=RPS'															, ; //X6_CONTEUD
	'1=SPED;U=RPS'															, ; //X6_CONTSPA
	'1=SPED;U=RPS'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010103'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'ES'																	, ; //X6_CONTEUD
	'ES'																	, ; //X6_CONTSPA
	'ES'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010103'																, ; //X6_FIL
	'MV_LOCKCT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Controle de Geracao de Cotacoes por Filial'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010103'																, ; //X6_FIL
	'MV_MODDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Modelo dos documentos da DESBH'										, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"U"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010103'																, ; //X6_FIL
	'MV_SERDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"SE"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010103'																, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010103'																, ; //X6_FIL
	'MV_TPSERIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RPS-SE /1A -1A /1F -1F /AV -AV /S  -S  /SE -SE /SF -SF /V1 -V1 /VF -VF /ST -ST /', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010103'																, ; //X6_FIL
	'MV_WFPROCI'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Usado para gerecao de codigo sequencial pelo SigaW'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'67'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010104'																, ; //X6_FIL
	'FS_KPON'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Verifica se o web serice do kp estao on-line'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010104'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"04"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"04"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"04"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010104'																, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DSCSPA
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'NITEROI'																, ; //X6_CONTEUD
	'NITEROI'																, ; //X6_CONTSPA
	'NITEROI'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010104'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084304'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010104'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;U=RPS'															, ; //X6_CONTEUD
	'1=SPED;U=RPS'															, ; //X6_CONTSPA
	'1=SPED;U=RPS'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010104'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RJ'																	, ; //X6_CONTEUD
	'RJ'																	, ; //X6_CONTSPA
	'RJ'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010104'																, ; //X6_FIL
	'MV_LOCKCT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Controle de Geracao de Cotacoes por Filial'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010104'																, ; //X6_FIL
	'MV_MDTDTFI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'das secoes do P.P.P.'													, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010104'																, ; //X6_FIL
	'MV_MODDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Modelo dos documentos da DESBH'										, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"U"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010104'																, ; //X6_FIL
	'MV_NGMDTRP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se ira executar a reprogramacao'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'automaticamente para exames de programa'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'de saude. 1=Sim;2=Nao;3=Exibe pergunta.'								, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010104'																, ; //X6_FIL
	'MV_NGMNT10'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sinistro'																, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Animais'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Orgaos Autuadores'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010104'																, ; //X6_FIL
	'MV_SERDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"SE"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010104'																, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010104'																, ; //X6_FIL
	'MV_TPSERIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RPS-SE /1A -1A /1F -1F /AV -AV /S  -S  /SE -SE /SF -SF /V1 -V1 /VF -VF /ST -ST /', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010104'																, ; //X6_FIL
	'MV_WFPROCI'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Usado para gerecao de codigo sequencial pelo SigaW'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'67'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010106'																, ; //X6_FIL
	'FS_KPON'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Verifica se o web serice do kp estao on-line'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010106'																, ; //X6_FIL
	'FS_SRVNFKP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DESCRIC
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCSPA
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCENG
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DESC1
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCSPA1
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCENG1
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DESC2
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCSPA2
	'Endereco do Servidor de Numeracao de Nf'								, ; //X6_DSCENG2
	'http://192.168.0.100/WebServiceERP/Service1.svc'						, ; //X6_CONTEUD
	'http://192.168.0.100/WebServiceERP/Service1.svc'						, ; //X6_CONTSPA
	'http://192.168.0.100/WebServiceERP/Service1.svc'						, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010106'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084306'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010106'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;U=RPS'															, ; //X6_CONTEUD
	'1=SPED;U=RPS'															, ; //X6_CONTSPA
	'1=SPED;U=RPS'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010106'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MG'																	, ; //X6_CONTEUD
	'MG'																	, ; //X6_CONTSPA
	'MG'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010106'																, ; //X6_FIL
	'MV_MODDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Modelo dos documentos da DESBH'										, ; //X6_DESCRIC
	'Modelo dos documentos da DESBH'										, ; //X6_DSCSPA
	'Modelo dos documentos da DESBH'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"U"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010106'																, ; //X6_FIL
	'MV_SERDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DESCRIC
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCSPA
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"SE"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010106'																, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010106'																, ; //X6_FIL
	'MV_TPSERIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DESCRIC
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCSPA
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCENG
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DESC1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCSPA1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RPS-SE /1A -1A /1F -1F /AV -AV /S  -S  /SE -SE /SF -SF /V1 -V1 /VF -VF /ST -ST /', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010107'																, ; //X6_FIL
	'FS_KPON'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Verifica se o web serice do kp estao on-line'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010107'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"07"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"07"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"07"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010107'																, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'INFORME A CIDADE'														, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'BETIM'																	, ; //X6_CONTEUD
	'BETIM'																	, ; //X6_CONTSPA
	'BETIM'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010107'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084307'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010107'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;A=NFS;U=RPS'													, ; //X6_CONTEUD
	'1=SPED;A=NFS'															, ; //X6_CONTSPA
	'1=SPED;A=NFS;U=RPS'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010107'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MG'																	, ; //X6_CONTEUD
	'MG'																	, ; //X6_CONTSPA
	'MG'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010107'																, ; //X6_FIL
	'MV_LOCKCT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Controle de Geracao de Cotacoes por Filial'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010107'																, ; //X6_FIL
	'MV_MODDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Modelo dos documentos da DESBH'										, ; //X6_DESCRIC
	'Modelo dos documentos da DESBH'										, ; //X6_DSCSPA
	'Modelo dos documentos da DESBH'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"U"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010107'																, ; //X6_FIL
	'MV_SERDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DESCRIC
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCSPA
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"SF"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010107'																, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010107'																, ; //X6_FIL
	'MV_TPSERIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DESCRIC
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCSPA
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCENG
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DESC1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCSPA1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RPS-SF /1A -1A /1F -1F /AV -AV /S  -S  /SE -SE /SF -SF /V1 -V1 /VF -VF /ST -ST /', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'FS_KPON'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Verifica se o web serice do kp estao on-line'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"08"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"08"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"08"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'JUIZ DE FORA'															, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084308'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;U=RPS'															, ; //X6_CONTEUD
	'A=NFS;1=NF;229=NF;U=NF'												, ; //X6_CONTSPA
	'1=SPED;U=RPS'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MG'																	, ; //X6_CONTEUD
	'MG'																	, ; //X6_CONTSPA
	'MG'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_LOCKCT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Controle de Geracao de Cotacoes por Filial'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_MDTDTFI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DESCRIC
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DSCSPA
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DSCENG
	'das secoes do P.P.P.'													, ; //X6_DESC1
	'das secoes do P.P.P.'													, ; //X6_DSCSPA1
	'das secoes do P.P.P.'													, ; //X6_DSCENG1
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DESC2
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DSCSPA2
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_MODDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Modelo dos documentos da DESBH'										, ; //X6_DESCRIC
	'Modelo dos documentos da DESBH'										, ; //X6_DSCSPA
	'Modelo dos documentos da DESBH'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"U"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_NGMDTRP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se ira executar a reprogramacao'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'automaticamente para exames de programa'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'de saude. 1=Sim;2=Nao;3=Exibe pergunta.'								, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_NGMNT10'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sinistro'																, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Animais'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Orgaos Autuadores'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_NGMOTAB'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica qual(is) tipos de motoristas podem realizar'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'abastecimentos: 1=Proprio;2=Terceiro;3=Agregado.'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Para mais de 1 tipo o conteudo pode ser ex: 1;2'						, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_NGPRSB2'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Busca preco medio na tabela SB2'										, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Informar S=Sim ou N=Nao'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'N'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_SERDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DESCRIC
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCSPA
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"SE"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_TPSERIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DESCRIC
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCSPA
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCENG
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DESC1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCSPA1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RPS-SE /1A -1A /1F -1F /AV -AV /S  -S  /SE -SE /SF -SF /V1 -V1 /VF -VF /ST -ST /', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010108'																, ; //X6_FIL
	'MV_WFPROCI'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Usado para gerecao de codigo sequencial pelo SigaW'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'67'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010109'																, ; //X6_FIL
	'FS_KPON'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Verifica se o web serice do kp estao on-line'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010109'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"09"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"09"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"09"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010109'																, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SAO JOSE DOS CAMPOS'													, ; //X6_CONTEUD
	'SAO JOSE DOS CAMPOS'													, ; //X6_CONTSPA
	'SAO JOSE DOS CAMPOS'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010109'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084309'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010109'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;U=RPS'															, ; //X6_CONTEUD
	'1=SPED;U=RPS'															, ; //X6_CONTSPA
	'1=SPED;U=RPS'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010109'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SP'																	, ; //X6_CONTEUD
	'SP'																	, ; //X6_CONTSPA
	'SP'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010109'																, ; //X6_FIL
	'MV_LOCKCT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Controle de Geracao de Cotacoes por Filial'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010109'																, ; //X6_FIL
	'MV_MODDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Modelo dos documentos da DESBH'										, ; //X6_DESCRIC
	'Modelo dos documentos da DESBH'										, ; //X6_DSCSPA
	'Modelo dos documentos da DESBH'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"U"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010109'																, ; //X6_FIL
	'MV_NGMNT10'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sinistro'																, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Animais'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Orgaos Autuadores'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010109'																, ; //X6_FIL
	'MV_SERDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DESCRIC
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCSPA
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"SE"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010109'																, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010109'																, ; //X6_FIL
	'MV_TPSERIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DESCRIC
	'Configuracao da serie a ser apresentada pe'							, ; //X6_DSCSPA
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCENG
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DESC1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCSPA1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RPS-SE /1A -1A /1F -1F /AV -AV /S  -S  /SE -SE /SF -SF /V1 -V1 /VF -VF /ST -ST /', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010109'																, ; //X6_FIL
	'MV_WFPROCI'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Usado para gerecao de codigo sequencial pelo SigaW'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'67'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'FS_KPO'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Verifica se o web serice do kp estao on-line'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"10"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'SF2->F2_SERIE'															, ; //X6_CONTSPA
	'SF2->F2_SERIE'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'JACAREPAGUA'															, ; //X6_CONTEUD
	'JACAREPAGUA'															, ; //X6_CONTSPA
	'JACAREPAGUA'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084310'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;U=RPS'															, ; //X6_CONTEUD
	'1=SPED;U=RPS'															, ; //X6_CONTSPA
	'1=SPED;U=RPS'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RJ'																	, ; //X6_CONTEUD
	'RJ'																	, ; //X6_CONTSPA
	'RJ'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_LOCKCT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Controle de Geracao de Cotacoes por Filial'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_MDTDTFI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DESCRIC
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DSCSPA
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DSCENG
	'das secoes do P.P.P.'													, ; //X6_DESC1
	'das secoes do P.P.P.'													, ; //X6_DSCSPA1
	'das secoes do P.P.P.'													, ; //X6_DSCENG1
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DESC2
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DSCSPA2
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_MODDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Modelo dos documentos da DESBH'										, ; //X6_DESCRIC
	'Modelo dos documentos da DESBH'										, ; //X6_DSCSPA
	'Modelo dos documentos da DESBH'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"U"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_NG2CTRC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se deve enviar e-mail de aviso na transfe-'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'rencia de uma consulta.'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'S=Sim ou N=Nao.'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'N'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_NG2D190'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Indica a quantidade de dias que o funcionario nao'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'tera exame agendado na reprogramacao por data'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'informada, baseado na dt. do ultimo exame agendado'					, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_NG2D685'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Indica a quantidade minima de dias de afastamento'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'suficiente para gerar automaticamente'									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'um exame(NR7)de retorno do trabalho.'									, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_NG2EV13'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se utiliza os 13 eventos contidos na NR23,'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ao gerar uma Ordem de Inspecao de Extintor.'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'S=Sim ou N=Nao.'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_NG2GRAV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se imprime o 1=Indice de Avaliacao de Gra-'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'vidade ou a 2=Taxa de Gravidade no relatorio de'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Acidentes C/ Vitima (MDTR865).'										, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_NG2PPPC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Se o CNPJ/CEI do C.C. do Funcionario estiver preen'					, ; //X6_DESCRIC
	'Se o CNPJ/CEI do C.C. do Funcionario estiver preen'					, ; //X6_DSCSPA
	'Se o CNPJ/CEI do C.C. do Funcionario estiver preen'					, ; //X6_DSCENG
	'chido, indica se imprimira o mesmo no P.P.P. ou o'						, ; //X6_DESC1
	'chido, indica se imprimira o mesmo no P.P.P. ou o'						, ; //X6_DSCSPA1
	'chido, indica se imprimira o mesmo no P.P.P. ou o'						, ; //X6_DSCENG1
	'que estiver definido no arquivo de empresas. 1/2'						, ; //X6_DESC2
	'que estiver definido no arquivo de empresas. 1/2'						, ; //X6_DSCSPA2
	'que estiver definido no arquivo de empresas. 1/2'						, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_NG2UTM9'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se deve inicializar os campos Equipamento e'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Responsavel do exame auditivo, com as informacoes'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'utilizadas na ultima inclusao. S=Sim ou N=Nao.'						, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'N'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_NGALMDF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se possibilitara o cancelamento dos'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'exames  periodicos pendentes, ao realizar'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'a mudanca de funcao.1=Nao;2=Sim'										, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_NGCATFU'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica as categorias funcionais de funcionarios'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'que nao irao aparecer no PPRA.'										, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Exemplo: A/M/T'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_NGEXREL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais exames devem estar habilitados'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'na inclusao de Atestado(ASO). 1=Apenas exames'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'ja realizados, 2=Todos os exames previstos.'							, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_NGMDTRI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se todos os riscos serao impressos no'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'atestado ASO ou apenas os que foram selecionados.'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'1 = Todos; 2 = Selecionados.'											, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_NGMDTRP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se ira executar a reprogramacao'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'automaticamente para exames de programa'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'de saude. 1=Sim;2=Nao;3=Exibe pergunta.'								, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_NGMDTVA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se ira considerar funcionarios afastados na'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'programacao de exames.'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'1=Sim;2=Nao'															, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_NGMNT10'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sinistro'																, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Animais'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Orgaos Autuadores'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_SERDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DESCRIC
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCSPA
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"SE"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_TPSERIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DESCRIC
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCSPA
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCENG
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DESC1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCSPA1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RPS-SE /1A -1A /1F -1F /AV -AV /S  -S  /SE -SE /SF -SF /V1 -V1 /VF -VF /ST -ST /', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010110'																, ; //X6_FIL
	'MV_WFPROCI'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Usado para gerecao de codigo sequencial pelo SigaW'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'67'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010111'																, ; //X6_FIL
	'FS_KPON'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Verifica se o web serice do kp estao on-line'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010111'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"11"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"11"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"11"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010111'																, ; //X6_FIL
	'MV_ALISSB1'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'ISS Brasilia conforme tratamento de divisao do ISS'					, ; //X6_DESCRIC
	'ISS Brasilia conforme tratamento de divisao do ISS'					, ; //X6_DSCSPA
	'ISS Brasilia conforme tratamento de divisao do ISS'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'B1_ISSDF'																, ; //X6_CONTEUD
	'B1_ISSDF'																, ; //X6_CONTSPA
	'B1_ISSDF'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010111'																, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'BRASILIA'																, ; //X6_CONTEUD
	'BRASILIA'																, ; //X6_CONTSPA
	'BRASILIA'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010111'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084311'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010111'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'A=NFS;R=ROM;2=ROM;L=LOC'												, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010111'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'DF'																	, ; //X6_CONTEUD
	'DF'																	, ; //X6_CONTSPA
	'DF'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010111'																, ; //X6_FIL
	'MV_MDTDTFI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DESCRIC
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DSCSPA
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DSCENG
	'das secoes do P.P.P.'													, ; //X6_DESC1
	'das secoes do P.P.P.'													, ; //X6_DSCSPA1
	'das secoes do P.P.P.'													, ; //X6_DSCENG1
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DESC2
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DSCSPA2
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010111'																, ; //X6_FIL
	'MV_MODDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Modelo dos documentos da DESBH'										, ; //X6_DESCRIC
	'Modelo dos documentos da DESBH'										, ; //X6_DSCSPA
	'Modelo dos documentos da DESBH'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"U"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010111'																, ; //X6_FIL
	'MV_NGMDTRP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se ira executar a reprogramacao'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'automaticamente para exames de programa'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'de saude. 1=Sim;2=Nao;3=Exibe pergunta.'								, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010111'																, ; //X6_FIL
	'MV_NGMNT10'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sinistro'																, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Animais'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Orgaos Autuadores'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010111'																, ; //X6_FIL
	'MV_SERDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DESCRIC
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCSPA
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"SE"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010111'																, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010111'																, ; //X6_FIL
	'MV_TPSERIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DESCRIC
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCSPA
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCENG
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DESC1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCSPA1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RPS-SE /1A -1A /1F -1F /AV -AV /S  -S  /SE -SE /SF -SF /V1 -V1 /VF -VF /ST -ST /', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010112'																, ; //X6_FIL
	'FS_KPON'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Verifica se o web serice do kp estao on-line'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010112'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"12"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"12"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"12"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010112'																, ; //X6_FIL
	'MV_ALISSB1'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Verifica se o web serice do kp estao on-line'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'B1_ISSDF'																, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010112'																, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SALVADOR'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	'SALVADOR'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010112'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084312'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010112'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'										, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'U=RPS;R=ROM;R2=ROM;R3=ROM;R4=ROM;R5=ROM'					, ; //X6_CONTEUD
	'U=RPS;1=RPS;R=ROM;R2=ROM;R3=ROM;R4=ROM;R5=ROM'			, ; //X6_CONTSPA
	'U=RPS;1=RPS;R=ROM;R2=ROM;R3=ROM;R4=ROM;R5=ROM'			, ; //X6_CONTENG
	'U'																	, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010112'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'BA'																	, ; //X6_CONTEUD
	'BA'																	, ; //X6_CONTSPA
	'BA'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010112'																, ; //X6_FIL
	'MV_MODDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Modelo dos documentos da DESBH'										, ; //X6_DESCRIC
	'Modelo dos documentos da DESBH'										, ; //X6_DSCSPA
	'Modelo dos documentos da DESBH'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"U"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010112'																, ; //X6_FIL
	'MV_NGMNT10'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sinistro'																, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Animais'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Orgaos Autuadores'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010112'																, ; //X6_FIL
	'MV_SERDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DESCRIC
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCSPA
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"SE"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010112'																, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010112'																, ; //X6_FIL
	'MV_TPSERIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DESCRIC
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCSPA
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCENG
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DESC1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCSPA1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RPS-SE /1A -1A /1F -1F /AV -AV /S  -S  /SE -SE /SF -SF /V1 -V1 /VF -VF /ST -ST /', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010112'																, ; //X6_FIL
	'MV_WFPROCI'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Usado para gerecao de codigo sequencial pelo SigaW'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'67'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'FS_KPON'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Verifica se o web serice do kp estao on-line'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'FS_MENNOTA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SERVICO ISENTO DE RETENCAO DOS 4,65% CONF LEI 10.833 de 29/12/2003. NAO SUJEITO A RETENCAO DE 11% DE INSS, CONF ART.143 INCISO IV DA IN RFB 971 de 13/11/2009. EXIGIBILIDADE SUSPENSA POR DECISAO JUDICIAL CONF.PROCESSO 01073252020128260000', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"13"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"13"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"13"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'GUARATINGUETA'															, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	'GUARATINGUETA'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084313'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;A=RPS;U=RPS'													, ; //X6_CONTEUD
	'1=SPED;A=RPS;U=RPS'													, ; //X6_CONTSPA
	'1=SPED;A=RPS;U=RPS'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SP'																	, ; //X6_CONTEUD
	'SP'																	, ; //X6_CONTSPA
	'SP'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_GISSISS'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'T'																		, ; //X6_CONTEUD
	'T'																		, ; //X6_CONTSPA
	'T'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_MDTDTFI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DESCRIC
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DSCSPA
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DSCENG
	'das secoes do P.P.P.'													, ; //X6_DESC1
	'das secoes do P.P.P.'													, ; //X6_DSCSPA1
	'das secoes do P.P.P.'													, ; //X6_DSCENG1
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DESC2
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DSCSPA2
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_NG1ANAT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais serao os destinos que sofrerao'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'entradas/baixas no estoque.'											, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'3467'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_NG1VALV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe se sera permitido abrir O.S. para'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'veiculos que estao em viagem. 1=Sim; 2=Nao'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_NGIMPOR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se na importacao de arquivos relacionados'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'a abastecimento, considera: 1 - Cod. Convenio ou'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'2 - Cod. Combustivel.'													, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_NGMDTRP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se ira executar a reprogramacao'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'automaticamente para exames de programa'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'de saude. 1=Sim;2=Nao;3=Exibe pergunta.'								, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_NGMNT10'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sinistro'																, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Animais'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Orgaos Autuadores'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_NGMNTNO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se ira vincular a ordem de servico'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'automaticamente aos pedidos informados na NFE'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'e na baixa de pre-requisicao.1=Sim;2=Nao'								, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_NGMOTAB'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica qual(is) tipos de motoristas podem realizar'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'abastecimentos: 1=Proprio;2=Terceiro;3=Agregado.'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Para mais de 1 tipo o conteudo pode ser ex: 1;2'						, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_NGPRSB2'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Busca preco medio na tabela SB2'										, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Informar S=Sim ou N=Nao'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'N'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_NGWFHT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica o IP e a Porta para a comunicacao HTTP'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'do workflow.'															, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://127.0.0.1:8080'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_NGWFLG'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se gera log especifico do processamento'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'do workflow (0 - Desabilita; 1 - Habilita).'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010113'																, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010114'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"14"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"14"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"14"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010114'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084314'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010114'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DSCSPA
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	'emissao de notas fiscais'												, ; //X6_DSCSPA1
	'emissao de notas fiscais'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'R=ROM;U=RPS'															, ; //X6_CONTEUD
	'R=ROM;U=RPS'															, ; //X6_CONTSPA
	'R=ROM;U=RPS'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010114'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'BA'																	, ; //X6_CONTEUD
	'BA'																	, ; //X6_CONTSPA
	'BA'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010115'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"15"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"15"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"15"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010115'																, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'CARUARU'																, ; //X6_CONTEUD
	'CARUARU'																, ; //X6_CONTSPA
	'CARUARU'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010115'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084315'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010115'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'U=RPS;L=LOC;R=ROM;R2=ROM;R3=ROM;R4=ROM;R5=ROM'												, ; //X6_CONTEUD
	'1=SPED;U=RPS;L=LOC'													, ; //X6_CONTSPA
	'1=SPED;U=RPS;L=LOC'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010115'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'PE'																	, ; //X6_CONTEUD
	'PE'																	, ; //X6_CONTSPA
	'PE'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010115'																, ; //X6_FIL
	'MV_GISSISS'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'F'																		, ; //X6_CONTEUD
	'F'																		, ; //X6_CONTSPA
	'F'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010115'																, ; //X6_FIL
	'MV_GISSOBR'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010116'																, ; //X6_FIL
	'FS_MENNOTA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Mensagem a ser impressa na NF Fatura'									, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SERVICO ISENTO DE RETENCAO DOS 4,65% CONF LEI 10.833 de 29/12/2003. NAO SUJEITO A RETENCAO DE 11% DE INSS, CONF ART.143 INCISO IV DA IN RFB 971 de 13/11/2009.', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010116'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"16"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"16"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"16"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010116'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084316'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010116'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;U=RPS;L=LOC'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010116'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MG'																	, ; //X6_CONTEUD
	'MG'																	, ; //X6_CONTSPA
	'MG'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010118'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"18"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"18"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"18"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010118'																, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SAO PAULO'																, ; //X6_CONTEUD
	'SAO PAULO'																, ; //X6_CONTSPA
	'SAO PAULO'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010118'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084318'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010118'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;U=RPS;'															, ; //X6_CONTEUD
	'1=SPED;U=RPS;'															, ; //X6_CONTSPA
	'1=SPED;U=RPS;'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010118'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SP'																	, ; //X6_CONTEUD
	'SP'																	, ; //X6_CONTSPA
	'SP'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010119'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"19"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"19"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"19"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010119'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SP'																	, ; //X6_CONTEUD
	'SP'																	, ; //X6_CONTSPA
	'SP'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010120'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"20"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"20"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"20"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010120'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084320'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010120'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'BA'																	, ; //X6_CONTEUD
	'BA'																	, ; //X6_CONTSPA
	'BA'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010121'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"21"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"21"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"21"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010121'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistem'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MG'																	, ; //X6_CONTEUD
	'MG'																	, ; //X6_CONTSPA
	'MG'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010122'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"22"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"22"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"22"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010122'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MG'																	, ; //X6_CONTEUD
	'MG'																	, ; //X6_CONTSPA
	'MG'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010123'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"23"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010123'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084323'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010123'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'A=NFS;1=SPED;U=RPS;'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010123'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RJ'																	, ; //X6_CONTEUD
	'RJ'																	, ; //X6_CONTSPA
	'RJ'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010124'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"24"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"24"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"24"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010124'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'BA'																	, ; //X6_CONTEUD
	'BA'																	, ; //X6_CONTSPA
	'BA'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'FS_KPON'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Verifica se o web serice do kp estao on-line'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"25"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"25"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"25"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'esta estabelecido.'													, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'BOM DESPACHO'															, ; //X6_CONTEUD
	'BOM DESPACHO'															, ; //X6_CONTSPA
	'BOM DESPACHO'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084325'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;A=NFS;U=NFS'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MG'																	, ; //X6_CONTEUD
	'MG'																	, ; //X6_CONTSPA
	'MG'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_MDTDTFI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'das secoes do P.P.P.'													, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NG1ANAT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais serao os destinos que sofrerao'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'entradas/baixas no estoque.'											, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'3467'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NG1VALV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe se sera permitido abrir O.S. para'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'veiculos que estao em viagem. 1=Sim; 2=Nao'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NG2CTRC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se deve enviar e-mail de aviso na transfe-'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'rencia de uma consulta.'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'S=Sim ou N=Nao.'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'N'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NG2D190'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Indica a quantidade de dias que o funcionario nao'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'tera exame agendado na reprogramacao por data'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'informada, baseado na dt. do ultimo exame agendado'					, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NG2D685'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Indica a quantidade minima de dias de afastamento'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'suficiente para gerar automaticamente'									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'um exame(NR7)de retorno do trabalho.'									, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NG2EV13'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se utiliza os 13 eventos contidos na NR23,'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ao gerar uma Ordem de Inspecao de Extintor.'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'S=Sim ou N=Nao.'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NG2GRAV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se imprime o 1=Indice de Avaliacao de Gra-'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'vidade ou a 2=Taxa de Gravidade no relatorio de'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Acidentes C/ Vitima (MDTR865).'										, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NG2PPPC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Se o CNPJ/CEI do C.C. do Funcionario estiver preen'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'chido, indica se imprimira o mesmo no P.P.P. ou o'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'que estiver definido no arquivo de empresas. 1/2'						, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NG2UTM9'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se deve inicializar os campos Equipamento e'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Responsavel do exame auditivo, com as informacoes'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'utilizadas na ultima inclusao. S=Sim ou N=Nao.'						, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'N'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NGALMDF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se possibilitara o cancelamento dos'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'exames  periodicos pendentes, ao realizar'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'a mudanca de funcao.1=Nao;2=Sim'										, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NGCATFU'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica as categorias funcionais de funcionarios'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'que nao irao aparecer no PPRA.'										, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Exemplo: A/M/T'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NGEXREL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais exames devem estar habilitados'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'na inclusao de Atestado(ASO). 1=Apenas exames'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'ja realizados, 2=Todos os exames previstos.'							, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NGIMPOR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se na importacao de arquivos relacionados'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'a abastecimento, considera: 1 - Cod. Convenio ou'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'2 - Cod. Combustivel.'													, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NGMDTRI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se todos os riscos serao impressos no'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'atestado ASO ou apenas os que foram selecionados.'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'1 = Todos; 2 = Selecionados.'											, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NGMDTRP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se ira executar a reprogramacao'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'automaticamente para exames de programa'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'de saude. 1=Sim;2=Nao;3=Exibe pergunta.'								, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NGMDTVA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se ira considerar funcionarios afastados na'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'programacao de exames.'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'1=Sim;2=Nao'															, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NGMNT10'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sinistro'																, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Animais'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Orgaos Autuadores'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NGMNTNO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se ira vincular a ordem de servico'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'automaticamente aos pedidos informados na NFE'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'e na baixa de pre-requisicao.1=Sim;2=Nao'								, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NGWFHT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica o IP e a Porta para a comunicacao HTTP'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'do workflow.'															, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://127.0.0.1:8080'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_NGWFLG'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se gera log especifico do processamento'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'do workflow (0 - Desabilita; 1 - Habilita).'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010125'																, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010126'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"26"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"26"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"26"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010126'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084326'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010126'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;U=RPS'															, ; //X6_CONTEUD
	'1=SPED;U=RPS'															, ; //X6_CONTSPA
	'1=SPED;U=RPS'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010126'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RJ'																	, ; //X6_CONTEUD
	'RJ'																	, ; //X6_CONTSPA
	'RJ'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010127'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"27"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"27"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"27"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010127'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084327'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010127'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;U=RPS;R=ROM;R1=ROM;R2=ROM;R3=ROM;R4=ROM;R5=ROM'								, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010127'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RJ'																	, ; //X6_CONTEUD
	'RJ'																	, ; //X6_CONTSPA
	'RJ'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010128'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"28"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"28"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"28"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010128'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084328'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010128'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;U=RPS'															, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010128'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SP'																	, ; //X6_CONTEUD
	'SP'																	, ; //X6_CONTSPA
	'SP'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010130'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"30"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"15"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"15"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010130'																, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'IPOJUCA'																, ; //X6_CONTEUD
	'CARUARU'																, ; //X6_CONTSPA
	'CARUARU'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010130'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;U=RPS;L=LOC'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	'1=SPED;U=RPS;L=LOC'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010130'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'PE'																	, ; //X6_CONTEUD
	'PE'																	, ; //X6_CONTSPA
	'BA'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010130'																, ; //X6_FIL
	'MV_GISSISS'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'F'																		, ; //X6_CONTEUD
	'F'																		, ; //X6_CONTSPA
	'F'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010130'																, ; //X6_FIL
	'MV_GISSOBR'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010131'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084331'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010131'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MG'																	, ; //X6_CONTEUD
	'MG'																	, ; //X6_CONTSPA
	'MG'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010131'																, ; //X6_FIL
	'MV_MODDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Modelo dos documentos da DESBH'										, ; //X6_DESCRIC
	'Modelo dos documentos da DESBH'										, ; //X6_DSCSPA
	'Modelo dos documentos da DESBH'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"U"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010131'																, ; //X6_FIL
	'MV_SERDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DESCRIC
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCSPA
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"SE"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010131'																, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010131'																, ; //X6_FIL
	'MV_TPSERIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DESCRIC
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCSPA
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCENG
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DESC1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCSPA1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RPS-SE /1A -1A /1F -1F /AV -AV /S  -S  /SE -SE /SF -SF /V1 -V1 /VF -VF /ST -ST /', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'FS_KPON FS'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Verifica se o web serice do kp estao on-line'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"32"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'SF2->F2_SERIE'															, ; //X6_CONTSPA
	'SF2->F2_SERIE'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DSCSPA
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DSCENG
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESC1
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DSCSPA1
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'VESPAZIANO'															, ; //X6_CONTEUD
	'VESPAZIANO'															, ; //X6_CONTSPA
	'VESPAZIANO'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084332'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	'Contiene tipos de documentos fiscales usados en'						, ; //X6_DSCSPA
	'Contain categories of fiscal documents used in'						, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	'la emision de facturas'												, ; //X6_DSCSPA1
	'the issuance of invoices.'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;U=RPS'															, ; //X6_CONTEUD
	'1=SPED;U=RPS'															, ; //X6_CONTSPA
	'1=SPED;U=RPS'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DESCRIC
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCSPA
	'Sigla do estado da empresa usuaria do Sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MG'																	, ; //X6_CONTEUD
	'MG'																	, ; //X6_CONTSPA
	'MG'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_MDTDTFI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DESCRIC
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DSCSPA
	'Indica quais datas serao consideradas na impressao'					, ; //X6_DSCENG
	'das secoes do P.P.P.'													, ; //X6_DESC1
	'das secoes do P.P.P.'													, ; //X6_DSCSPA1
	'das secoes do P.P.P.'													, ; //X6_DSCENG1
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DESC2
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DSCSPA2
	'1 - Responsaveis; 2 - Funcionarios'									, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_MODDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Modelo dos documentos da DESBH'										, ; //X6_DESCRIC
	'Modelo dos documentos da DESBH'										, ; //X6_DSCSPA
	'Modelo dos documentos da DESBH'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"U"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NG1ANAT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais serao os destinos que sofrerao'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'entradas/baixas no estoque.'											, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'3467'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NG1VALV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe se sera permitido abrir O.S. para'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'veiculos que estao em viagem. 1=Sim; 2=Nao'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NG2CTRC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se deve enviar e-mail de aviso na transfe-'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'rencia de uma consulta.'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'S=Sim ou N=Nao.'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'N'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NG2D190'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Indica a quantidade de dias que o funcionario nao'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'tera exame agendado na reprogramacao por data'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'informada, baseado na dt. do ultimo exame agendado'					, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NG2D685'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Indica a quantidade minima de dias de afastamento'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'suficiente para gerar automaticamente'									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'um exame(NR7)de retorno do trabalho.'									, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NG2EV13'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se utiliza os 13 eventos contidos na NR23,'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ao gerar uma Ordem de Inspecao de Extintor.'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'ao gerar uma Ordem de Inspecao de Extintor.'							, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NG2GRAV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se imprime o 1=Indice de Avaliacao de Gra-'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'vidade ou a 2=Taxa de Gravidade no relatorio de'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Acidentes C/ Vitima (MDTR865).'										, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NG2PPPC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Se o CNPJ/CEI do C.C. do Funcionario estiver preen'					, ; //X6_DESCRIC
	'Se o CNPJ/CEI do C.C. do Funcionario estiver preen'					, ; //X6_DSCSPA
	'Se o CNPJ/CEI do C.C. do Funcionario estiver preen'					, ; //X6_DSCENG
	'chido, indica se imprimira o mesmo no P.P.P. ou o'						, ; //X6_DESC1
	'chido, indica se imprimira o mesmo no P.P.P. ou o'						, ; //X6_DSCSPA1
	'chido, indica se imprimira o mesmo no P.P.P. ou o'						, ; //X6_DSCENG1
	'que estiver definido no arquivo de empresas. 1/2'						, ; //X6_DESC2
	'que estiver definido no arquivo de empresas. 1/2'						, ; //X6_DSCSPA2
	'que estiver definido no arquivo de empresas. 1/2'						, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NG2UTM9'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se deve inicializar os campos Equipamento e'					, ; //X6_DESCRIC
	'Indica se deve inicializar os campos Equipamento e'					, ; //X6_DSCSPA
	'Indica se deve inicializar os campos Equipamento e'					, ; //X6_DSCENG
	'Responsavel do exame auditivo, com as informacoes'						, ; //X6_DESC1
	'Responsavel do exame auditivo, com as informacoes'						, ; //X6_DSCSPA1
	'Responsavel do exame auditivo, com as informacoes'						, ; //X6_DSCENG1
	'utilizadas na ultima inclusao. S=Sim ou N=Nao.'						, ; //X6_DESC2
	'Indica se deve inicializar os campos Equipamento e'					, ; //X6_DSCSPA2
	'Indica se deve inicializar os campos Equipamento e'					, ; //X6_DSCENG2
	'N'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NGALMDF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se possibilitara o cancelamento dos'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'exames  periodicos pendentes, ao realizar'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'a mudanca de funcao.1=Nao;2=Sim'										, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NGCATFU'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica as categorias funcionais de funcionarios'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'que nao irao aparecer no PPRA.'										, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Exemplo: A/M/T'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NGEXREL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais exames devem estar habilitados'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'na inclusao de Atestado(ASO). 1=Apenas exames'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'ja realizados, 2=Todos os exames previstos.'							, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NGIMPOR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se na importacao de arquivos relacionados'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'a abastecimento, considera: 1 - Cod. Convenio ou'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'2 - Cod. Combustivel.'													, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NGMDTRI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se todos os riscos serao impressos no'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'atestado ASO ou apenas os que foram selecionados.'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'1 = Todos; 2 = Selecionados.'											, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NGMDTRP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se ira executar a reprogramacao'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'automaticamente para exames de programa'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'de saude. 1=Sim;2=Nao;3=Exibe pergunta.'								, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NGMDTVA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se ira considerar funcionarios afastados na'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'programacao de exames.'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'1=Sim;2=Nao'															, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NGMNT10'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sinistro'																, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Animais'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Orgaos Autuadores'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NGMNTNO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se ira vincular a ordem de servico'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'automaticamente aos pedidos informados na NFE'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'e na baixa de pre-requisicao.1=Sim;2=Nao'								, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NGMOTAB'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica qual(is) tipos de motoristas podem realizar'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'abastecimentos: 1=Proprio;2=Terceiro;3=Agregado.'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Para mais de 1 tipo o conteudo pode ser ex: 1;2'						, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NGPRSB2'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Busca preco medio na tabela SB2'										, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Informar S=Sim ou N=Nao'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'N'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NGWFHT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica o IP e a Porta para a comunicacao HTTP'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'do workflow.'															, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://127.0.0.1:8080'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_NGWFLG'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se gera log especifico do processamento'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'do workflow (0 - Desabilita; 1 - Habilita).'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_SERDES'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DESCRIC
	'Informe o campo que contem a serie das notas fisca'					, ; //X6_DSCSPA
	'Informe o campo que contem a serie das nota'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"SE"'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010132'																, ; //X6_FIL
	'MV_TPSERIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DESCRIC
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCSPA
	'Configuracao da serie a ser apresentada pelos docs'					, ; //X6_DSCENG
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DESC1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCSPA1
	'DES no arquivo de Notas Emitidas e Notas Recebidas'					, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RPS-SE /1A -1A /1F -1F /AV -AV /S  -S  /SE -SE /SF -SF /V1 -V1 /VF -VF /ST -ST /', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010134'																, ; //X6_FIL
	'FS_MENNOTA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Mensagem a ser impressa na NF Fatura'									, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SERVICO ISENTO DE RETENCAO DOS 4,65% CONFORME LEI NO. 10.833 de 29/12/2003. NAO SUJEITO A RETENCAO DE 11% DE INSS, CONFORME ART.143. INCISO IV DA IN RFB No. 971 de 13/11/2009.', ; //X6_CONTEUD
	'SERVICO ISENTO DE RETENCAO DOS 4,65% CONFORME LEI NO. 10.833 de 29/12/2003. NAO SUJEITO A RETENCAO DE 11% DE INSS, CONFORME ART.143. INCISO IV DA IN RFB No. 971 de 13/11/2009.', ; //X6_CONTSPA
	'SERVICO ISENTO DE RETENCAO DOS 4,65% CONFORME LEI NO. 10.833 de 29/12/2003. NAO SUJEITO A RETENCAO DE 11% DE INSS, CONFORME ART.143. INCISO IV DA IN RFB No. 971 de 13/11/2009.', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010134'																, ; //X6_FIL
	'FS_MSGPDR'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigo das mensagens padrao para os pedidos de'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'venda tipo 2.'															, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'001,002,003,004,005'													, ; //X6_CONTEUD
	'001,002,003,004,005'													, ; //X6_CONTSPA
	'001,002,003,004,005'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010134'																, ; //X6_FIL
	'MV_1DUPREF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo ou dado a ser gravado no prefixo do titulo.'						, ; //X6_DESCRIC
	'Campo o dato a ser grabado en el prefijo del titu-'					, ; //X6_DSCSPA
	'Field or data to be recorded in the bill prefix'						, ; //X6_DSCENG
	'Quando o mesmo for gerado automaticamente pelo mo-'					, ; //X6_DESC1
	'lo cuando este es emitido automaticamente por el'						, ; //X6_DSCSPA1
	'when this is automatically generated by the'							, ; //X6_DSCENG1
	'dulo de faturamento.'													, ; //X6_DESC2
	'modulo de Facturacion.'												, ; //X6_DSCSPA2
	'invoicing module'														, ; //X6_DSCENG2
	'"34"+SF2->F2_SERIE'													, ; //X6_CONTEUD
	'"34"+SF2->F2_SERIE'													, ; //X6_CONTSPA
	'"34"+SF2->F2_SERIE'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010134'																, ; //X6_FIL
	'MV_CLIDANF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CLIENTE DANFE'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00084334'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010134'																, ; //X6_FIL
	'MV_ESPECIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Contem tipos de documentos fiscais utilizados na'						, ; //X6_DESCRIC
	'Contiene tipos de documentos fiscales usados en'						, ; //X6_DSCSPA
	'Contain categories of fiscal documents used in'						, ; //X6_DSCENG
	'emissao de notas fiscais'												, ; //X6_DESC1
	'la emision de facturas'												, ; //X6_DSCSPA1
	'the issuance of invoices.'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1=SPED;U=RPS'															, ; //X6_CONTEUD
	'1=SPED;U=RPS'															, ; //X6_CONTSPA
	'1=SPED;U=RPS'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010134'																, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema, pa-'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'ES'																	, ; //X6_CONTEUD
	'ES'																	, ; //X6_CONTSPA
	'ES'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010134'																, ; //X6_FIL
	'MV_NGIMPOR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se na importacao de arquivos relacionados'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'a abastecimento, considera: 1 - Cod. Convenio ou'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'2 - Cod. Combustivel.'													, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010134'																, ; //X6_FIL
	'MV_NGPRSB2'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Busca preco medio na tabela SB2'										, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Informar S=Sim ou N=Nao'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'N'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010134'																, ; //X6_FIL
	'MV_NGWFHT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica o IP e a Porta para a comunicacao HTTP'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'do workflow.'															, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://127.0.0.1:8080'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010134'																, ; //X6_FIL
	'MV_NGWFLG'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se gera log especifico do processamento'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'do workflow (0 - Desabilita; 1 - Habilita).'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'010134'																, ; //X6_FIL
	'MV_SPEDURL'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Caminho do TSS'														, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTEUD
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTSPA
	'http://192.168.0.24:1300/nfe'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

//
// Atualizando dicionário
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
		AutoGrLog( "Foi incluído o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " Conteúdo [" + AllTrim( aSX6[nI][13] ) + "]" )
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

AutoGrLog( CRLF + "Final da Atualização" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp
Função de processamento da gravação dos Helps de Campos

@author TOTVS Protheus
@since  10/08/2014
@obs    Gerado por EXPORDIC - V.4.21.9.4 EFS / Upd. V.4.19.10 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "Ínicio da Atualização" + " " + "Helps de Campos" + CRLF )


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

//
// Helps Tabela P09
//
aHlpPor := {}
aAdd( aHlpPor, 'Código que identifica a filial da' )
aAdd( aHlpPor, 'empre-sa usuária do sistema.' )

PutHelp( "PP09_FILIAL ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "P09_FILIAL" )

aHlpPor := {}
aAdd( aHlpPor, 'Sequencial' )

PutHelp( "PP09_SEQ    ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "P09_SEQ" )

aHlpPor := {}
aAdd( aHlpPor, 'Cod Aplicacao' )

PutHelp( "PP09_CODAPL", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "P09_CODAPL" )

aHlpPor := {}
aAdd( aHlpPor, 'Desc Aplicacao' )

PutHelp( "PP09_DESCAP", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "P09_DESCAP" )

AutoGrLog( CRLF + "Final da Atualização" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF )

Return {}


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


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

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), oDlg:End()  ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  10/08/2014
@obs    Gerado por EXPORDIC - V.4.21.9.4 EFS / Upd. V.4.19.10 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
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
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  10/08/2014
@obs    Gerado por EXPORDIC - V.4.21.9.4 EFS / Upd. V.4.19.10 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
