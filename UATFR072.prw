#Include "Protheus.ch"
#Include "ATFR072.ch"

User Function UATFR072()

Local oReport
Local lTReport	:= FindFunction("TRepInUse") .And. TRepInUse()
Local lDefTop 	:= IIF( FindFunction("IfDefTopCTB"), IfDefTopCTB(), .F.) // verificar se pode executar query (TOPCONN)
Private aSelFil	:= {}
Private aSelMoed:= {} 
Private aSelClass:= {} 
Private lTodasFil:= .F.
PRIVATE cPerg   := "AFR072"

CriaSX1(cPerg)

If !lDefTop
	Return
EndIf

If !lTReport
	Return
ENdIf

lRet := Pergunte( cPerg , .T. )


If lRet
	If mv_par20 == 1 .And. Len( aSelFil ) <= 0
		aSelFil := AdmGetFil(@lTodasFil)
		If Len( aSelFil ) <= 0
			Return
		EndIf
	EndIf
	
	If mv_par03 == 1 .And. Len( aSelMoed ) <= 0
		aSelMoed := ADMGETMOED()
		If Len( aSelMoed ) <= 0
			Return
		EndIf
		If Len( aSelMoed ) > 5
			Help(" ",1,"Deve ser selecionado no máximo 5 moedas ",,'STR0002',1,0)//
			Return
		EndIf
	EndIf
	
	//Seleciona as classificações patrimoniais
	If mv_par26 == 1 .And. Len( aSelClass ) <= 0 .And. FindFunction("ADMGETCLAS")
		aSelClass := AdmGetClas()
		If Len( aSelClass ) <= 0
			Return
		EndIf 
	EndIf

	//Valida o Tipo de Saldo
	If !VldTpSald( MV_PAR25, .T. )
		Return
	EndIf

	
	oReport := ReportDef()
	oReport:PrintDialog()
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef ºAutor  ³Alvaro Camillo Neto º Data ³  23/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Definição de layout do relatório analítico                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local oReport
Local oSecEntCtb
Local oSecBem
Local oSecValores

Local oTotalGeral
Local oSubtotal

Local oTxtSubtotal
Local oTxtTotGer

Local oTxtFiscal
Local oTxtGerencial
Local oTxtIncentivada
Local oTxtFilial

Local cReport := "ATFR072"
Local cTitulo :=	OemToAnsi(STR0003)	//"Posicao Valorizada dos Bens na Data"
Local cDescri :=	OemToAnsi(STR0004) + " " +;	// "Este programa ir  emitir a posi‡„o valorizada dos"
OemToAnsi(STR0005) + " "   	//"bens em ate 5 (cinco) moedas."
Local aOrd	  := { OemToAnsi(STR0006), OemToAnsi(STR0007), OemToAnsi(STR0008), OemToAnsi(STR0009) }//"Conta"##"C Custo"##"Item Contábil"##"Classe de Valor"
Local bReport := {}

If MV_PAR02 == 1 // Analítico
	bReport := { |oReport|	oReport:SetTitle( oReport:Title() + OemtoAnsi(STR0010) + aOrd[oSecEntCtb:GetOrder()] + STR0011 ),;//" por "##" Analítico "
	PrtAnalitico( oReport ) }
ElseIf MV_PAR02 == 2 // Sintetico por COnta
	bReport := { |oReport|	oReport:SetTitle( oReport:Title() + OemtoAnsi(STR0010) + aOrd[oSecEntCtb:GetOrder()] + STR0012 ),;//" por "##" Sintético por Conta "
	PrtSintConta( oReport ) }
Else // Sintetico por Bem
	bReport := { |oReport|	oReport:SetTitle( oReport:Title() + OemtoAnsi(STR0010) + aOrd[oSecEntCtb:GetOrder()] + STR0013 ),;//" por "##" Sintético por Bem "
	PrtSintBem( oReport ) }
EndIf

oReport  := TReport():New( cReport, cTitulo, cPerg, bReport, cDescri )

oSecEntCtb := TRSection():New( oReport, STR0014 ,{}, aOrd ) // "Entidade Contabil"
TRCell():New( oSecEntCtb, "CT1_CONTA"	, "CT1", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecEntCtb, "CT1_DESC01"	, "CT1", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,.T.,,,,.T.)
TRCell():New( oSecEntCtb, "CTT_CUSTO"	, "CTT", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecEntCtb, "CTT_DESC01"	, "CTT", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecEntCtb, "CTD_ITEM"		, "CTD", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecEntCtb, "CTD_DESC01"	, "CTD", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecEntCtb, "CTH_CLVL"		, "CTH", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecEntCtb, "CTH_DESC01"	, "CTH", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSecEntCtb:SetHeaderSection(.F.)

oSecBem := TRSection():New( oSecEntCtb,  STR0015 ) // "Dados da Entidade"
TRCell():New( oSecBem, "N3_FILIAL"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N3_CBASE"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N3_ITEM"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N3_TIPO"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N3_TIPODESC", "", STR0016, /*Picture*/, 30,/*lPixel*/,/*{|| code-block de impressao }*/,,.T.,,,,.T.,,,) //"Descrição Tipo"

//Incluido por Jair Ribeiro em 29/04/11
TRCell():New( oSecBem, "N3_TPDEPR"	,""		,OEMTOANSI(STR0044)	,									,15,,,,.T.,,,,.T.) 

TRCell():New( oSecBem, "N1_PATRIM"	, "SN1", /*X3Titulo*/, /*Picture*/, 15 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,.T.,,,,.T.)
TRCell():New( oSecBem, "N1_DESCRIC"	, "SN1", /*X3Titulo*/, /*Picture*/, 35 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,.T.,,,,.T.)
TRCell():New( oSecBem, "N1_AQUISIC"	, "SN1", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N1_BAIXA"	, "SN1", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N1_QUANTD"	, "SN1", /*X3Titulo*/, PesqPict("SN1","N1_QUANTD",11) /*Picture*/, 11 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N1_CHAPA"	, "SN1", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N3_TPSALDO"	, "SN3", /*X3Titulo*/, /*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N3_CCONTAB"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N3_CUSTBEM"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N3_SUBCCON"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecBem, "N3_CLVLCON"	, "SN3", /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSecBem:SetHeaderPage(.T.)

oSecValores := TRSection():New( oSecEntCtb, "Valores") // "Valores"
TRCell():New( oSecValores, "SIMBMOEDA"		, ""	 , STR0027 /*X3Titulo*/, "" /*Picture*/, 5 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  // "Moeda"
TRCell():New( oSecValores, "N3_VORIG1"	   	, "", STR0017/*X3Titulo*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Valor Original"
TRCell():New( oSecValores, "N3_AMPLIA1"		, "SN3", STR0018 /*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)// "Val Amplia"
TRCell():New( oSecValores, "VLATUALIZADO"	, "", STR0019 /*X3Titulo*/, PesqPict("SN3","N3_VORIG1" ,19,1) /*Picture*/, 19 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Valor Atualizado"
TRCell():New( oSecValores, "N3_VRDACM1"		, "", STR0020 /*X3Titulo*/, /*Picture*/, 19 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Deprec. Acumulada"
TRCell():New( oSecValores, "VLRESIDUAL"		, "", STR0021 /*X3Titulo*/, PesqPict("SN3","N3_VORIG1" ,19,1) /*Picture*/, 19 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Valor Atualizado"
TRCell():New( oSecValores, "N3_VRCDA1"		, "SN3", /*X3Titulo*/, /*Picture*/, 17 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSecValores, "N3_VRCACM1"		, "SN3", /*X3Titulo*/, /*Picture*/, 19 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSecValores:SetHeaderPage(.T.)
oSecValores:Cell("N3_VORIG1"):SetHeaderAlign("RIGHT")
oSecValores:Cell("N3_AMPLIA1"):SetHeaderAlign("RIGHT")
oSecValores:Cell("VLATUALIZADO"):SetHeaderAlign("RIGHT")
oSecValores:Cell("N3_VRDACM1"):SetHeaderAlign("RIGHT")
oSecValores:Cell("VLRESIDUAL"):SetHeaderAlign("RIGHT")
oSecValores:Cell("N3_VRCDA1"):SetHeaderAlign("RIGHT")
oSecValores:Cell("N3_VRCACM1"):SetHeaderAlign("RIGHT")


oTxtSubtotal  := TRSection():New( oSecEntCtb, STR0022 ) //"Texto Sub-total"
TRCell():New( oTxtSubtotal, "FILIAL"		, "",  STR0023 /*X3Titulo*/, /*Picture*/, 70 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oTxtSubtotal, "ENTIDADE"	, "" ,  STR0024 /*X3Titulo*/, "" /*Picture*/, 70 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  // "Entidade"
TRCell():New( oTxtSubtotal, "QUANTIDADE"	, "" , STR0025 /*X3Titulo*/, "" /*Picture*/, 20 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  // Quantidade
oTxtSubtotal:SetHeaderSection(.F.)
oTxtSubtotal:SetLeftMargin(7)

oSubTotal  := TRSection():New( oSecEntCtb, STR0026) //"Valores Sub-total"
TRCell():New( oSubTotal, "SIMBMOEDA"		, ""	 , STR0027 /*X3Titulo*/, "" /*Picture*/, 5 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  // "Moeda"
TRCell():New( oSubTotal, "N3_VORIG1"	   	, "", STR0017/*X3Titulo*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Valor Original"
TRCell():New( oSubTotal, "N3_AMPLIA1"		, "SN3", STR0018/*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSubTotal, "VLATUALIZADO"	, "", STR0019 /*X3Titulo*/, PesqPict("SN3","N3_VORIG1" ,19,1) /*Picture*/, 19 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Valor Atualizado"
TRCell():New( oSubTotal, "N3_VRDACM1"		, "", STR0020 /*X3Titulo*/, /*Picture*/, 19 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Deprec. Acumulada"
TRCell():New( oSubTotal, "VLRESIDUAL"		, "", STR0021 /*X3Titulo*/, PesqPict("SN3","N3_VORIG1" ,19,1) /*Picture*/, 19 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Valor Atualizado"
TRCell():New( oSubTotal, "N3_VRCDA1"		, "SN3", /*X3Titulo*/, /*Picture*/, 17 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSubTotal, "N3_VRCACM1"		, "SN3", /*X3Titulo*/, /*Picture*/, 19 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSubTotal:SetHeaderSection(.F.)
oSubTotal:Cell("N3_VORIG1"):SetHeaderAlign("RIGHT")
oSubTotal:Cell("N3_AMPLIA1"):SetHeaderAlign("RIGHT")
oSubTotal:Cell("VLATUALIZADO"):SetHeaderAlign("RIGHT")
oSubTotal:Cell("N3_VRDACM1"):SetHeaderAlign("RIGHT")
oSubTotal:Cell("VLRESIDUAL"):SetHeaderAlign("RIGHT")
oSubTotal:Cell("N3_VRCDA1"):SetHeaderAlign("RIGHT")
oSubTotal:Cell("N3_VRCACM1"):SetHeaderAlign("RIGHT")

oTxtTotGer  := TRSection():New( oReport, STR0028 ) // "Texto Total Geral"
TRCell():New( oTxtTotGer, "TEXTO"	, "", STR0029  /*X3Titulo*/, "" /*Picture*/, 70 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  // "Total Geral"
TRCell():New( oTxtTotGer, "QUANTIDADE"	 , ""	 , STR0025 /*X3Titulo*/, "" /*Picture*/, 20 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Quantidade"
oTxtTotGer:SetHeaderSection(.F.)
oTxtTotGer:SetLeftMargin(7)

oTotalGeral := TRSection():New( oReport, STR0030) // "Valores do Total Geral"
TRCell():New( oTotalGeral, "SIMBMOEDA"		, ""	 , STR0027 /*X3Titulo*/, "" /*Picture*/, 5 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  // "Moeda"
TRCell():New( oTotalGeral, "N3_VORIG1"	   	, "", STR0017/*X3Titulo*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Valor Original"
TRCell():New( oTotalGeral, "N3_AMPLIA1"		, "SN3", STR0018/*X3Titulo*/, /*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oTotalGeral, "VLATUALIZADO"	, "", STR0019 /*X3Titulo*/, PesqPict("SN3","N3_VORIG1" ,19,1) /*Picture*/, 19 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Valor Atualizado"
TRCell():New( oTotalGeral, "N3_VRDACM1"		, "", STR0020 /*X3Titulo*/, /*Picture*/, 19 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Deprec. Acumulada"
TRCell():New( oTotalGeral, "VLRESIDUAL"		, "", STR0021 /*X3Titulo*/, PesqPict("SN3","N3_VORIG1" ,19,1) /*Picture*/, 19 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Valor Atualizado"
TRCell():New( oTotalGeral, "N3_VRCDA1"		, "SN3", /*X3Titulo*/, /*Picture*/, 17 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oTotalGeral, "N3_VRCACM1"		, "SN3", /*X3Titulo*/, /*Picture*/, 19 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oTotalGeral:SetHeaderSection(.F.)
oTotalGeral:Cell("N3_VORIG1"):SetHeaderAlign("RIGHT")
oTotalGeral:Cell("N3_AMPLIA1"):SetHeaderAlign("RIGHT")
oTotalGeral:Cell("VLATUALIZADO"):SetHeaderAlign("RIGHT")
oTotalGeral:Cell("N3_VRDACM1"):SetHeaderAlign("RIGHT")
oTotalGeral:Cell("VLRESIDUAL"):SetHeaderAlign("RIGHT")
oTotalGeral:Cell("N3_VRCDA1"):SetHeaderAlign("RIGHT")
oTotalGeral:Cell("N3_VRCACM1"):SetHeaderAlign("RIGHT")

oTxtFiscal   := TRSection():New( oReport, 'STR0031' )//"Total Fiscal"
TRCell():New( oTxtFiscal, "TEXTO"	, "", 'STR0031' /*X3Titulo*/, "" /*Picture*/, 70 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Total Fiscal"
oTxtFiscal:SetHeaderSection(.F.)
oTxtFiscal:SetLeftMargin(7)

oTxtGerencial   := TRSection():New( oReport, 'STR0032' )//"Total Gerencial"
TRCell():New( oTxtGerencial, "TEXTO"	, "",  'STR0032' /*X3Titulo*/, "" /*Picture*/, 70 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Total Gerencial"
oTxtGerencial:SetHeaderSection(.F.)
oTxtGerencial:SetLeftMargin(7)

oTxtIncentivada   := TRSection():New( oReport, 'STR0033' )//"Total Por Filial"
TRCell():New( oTxtIncentivada, "TEXTO"	, "", 'STR0033'  /*X3Titulo*/, "" /*Picture*/, 70 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Total Por Filial"
oTxtIncentivada:SetHeaderSection(.F.)
oTxtIncentivada:SetLeftMargin(7)

oTxtFilial   := TRSection():New( oReport, 'STR0033' )//"Total Incentivada"
TRCell():New( oTxtFilial, "TEXTO"	, "", 'STR0033'  /*X3Titulo*/, "" /*Picture*/, 70 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Total Incentivada"
oTxtFilial:SetHeaderSection(.F.)
oTxtFilial:SetLeftMargin(7)

oSecEntCtb:SetColSpace(2)
oSecValores:SetColSpace(0)
oSubTotal:SetColSpace(0)
oTotalGeral:SetColSpace(0)
oReport:SetLandScape()
oReport:ParamReadOnly()
oReport:DisableOrientation()

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrtSintContaºAutor  ³Alvaro Camillo Neto º Data ³  28/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressão do relatório Sintético por Conta                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFR072                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrtSintConta( oReport )
Local oSecEntCtb	 := oReport:Section(1)
Local oSecBem		 := oReport:Section(1):Section(1)
Local oSecValores	 := oReport:Section(1):Section(2)
Local oTxtSubtotal 	 := oReport:Section(1):Section(3)
Local oSubtotal 	 := oReport:Section(1):Section(4)
Local oTxtTotGer	 := oReport:Section(2)
Local oTotalGeral	 := oReport:Section(3)
Local oTxtFiscal	 := oReport:Section(4)
Local oTxtGerencial	 := oReport:Section(5)
Local oTxtIncentivada:= oReport:Section(6)

Local oMeter
Local oText
Local oDlg
Local lEnd
Local cAliasQry 	:= GetNextAlias()
Local cAliasTRB 	:= GetNextAlias()
Local dDataSLD  	:= MV_PAR01
Local dAquIni		:= MV_PAR04
Local dAquFim   	:= MV_PAR05
Local cBemIni   	:= MV_PAR06
Local cBemFim   	:= MV_PAR08
Local cItemIni  	:= MV_PAR07
Local cItemFim  	:= MV_PAR09
Local cContaIni 	:= MV_PAR12
Local cContaFim 	:= MV_PAR13
Local cCCIni   	:= MV_PAR14
Local cCCFim   	:= MV_PAR15
Local cItCtbIni	:= MV_PAR16
Local cItCtbFim	:= MV_PAR17
Local cClvlIni		:= MV_PAR18
Local cClVlFim		:= MV_PAR19
Local cGrupoIni	:= MV_PAR10
Local cGrupoFim	:= MV_PAR11
Local n_pagini 	:= MV_PAR21
Local n_pagFim		:= MV_PAR22
Local n_pagRes		:= MV_PAR23
Local nTipoTotal	:= MV_PAR24
Local cTipoSLD		:= MV_PAR25
Local cChave		:= ""
Local cCond			:= ""
Local nCount		:= 0
Local aGerFiscal 	:= {}
Local aGerGerencial := {}
Local aGerIncentivada:= {}
Local nX			:= 0
Local nTotal 	 	:= 0
Local cCabCond1 	:= ""
Local cQuery		:= ""

Local nTipoEnt 		:= oSecEntCtb:GetOrder()
Local aValorFis		:= {}
Local aValorGer		:= {}
Local aValorInc		:= {}
Local aTipo			:= {}
Local cTipoFiscal	:= ATFXTpBem(1)
Local cTipoGerenc	:= ATFXTpBem(2)
Local cTipoIncent	:= ATFXTpBem(3)


aSelMoed := IIF(Empty(aSelMoed), {"01"} , aSelMoed )

If nTipoTotal == 1 //Fiscal
	aTipo := ATFXTpBem(1,.T.)
ElseIf nTipoTotal == 2 //Gerencial
	aTipo := ATFXTpBem(2,.T.)
ElseIf nTipoTotal == 3 //Incentivada
	aTipo := ATFXTpBem(3,.T.)
EndIf

// Desabilita todas as celulas de secao 1
oSecEntCtb:Cell("CT1_CONTA"):Disable()
oSecEntCtb:Cell("CT1_DESC01"):Disable()
oSecEntCtb:Cell("CTT_CUSTO"):Disable()
oSecEntCtb:Cell("CTT_DESC01"):Disable()
oSecEntCtb:Cell("CTD_ITEM"):Disable()
oSecEntCtb:Cell("CTD_DESC01"):Disable()
oSecEntCtb:Cell("CTH_CLVL"):Disable()
oSecEntCtb:Cell("CTH_DESC01"):Disable()

oSecValores:Cell("SIMBMOEDA"):SetTitle("")
oSubTotal:Cell("SIMBMOEDA"):SetTitle("")
oTotalGeral:Cell("SIMBMOEDA"):SetTitle("")

//Ordem do Arquivo
IF nTipoEnt == 1
	cChave := "FILIAL+CONTA+CCUSTO+CBASE+ITEM+TIPO+SEQ+SEQREAV+MOEDA"
	cCabCond1 := OemToAnsi("Conta   : ") //"Conta   : "
	cCpoEnt := "CONTA"
ElseIf nTipoEnt == 2
	cChave := "FILIAL+CCUSTO+CONTA+CBASE+ITEM+TIPO+SEQ+SEQREAV+MOEDA"
	cCabCond1 := OemToAnsi("C.Custo : ") //"C.Custo : "
	cCpoEnt := "CCUSTO"
ElseIf nTipoEnt == 3
	cChave := "FILIAL+SUBCTA+CCUSTO+CONTA+CBASE+ITEM+TIPO+SEQ+SEQREAV+MOEDA"
	cCabCond1 := OemToAnsi("It.Ctb. : ") //"It.Ctb. : "
	cCpoEnt := "SUBCTA"
ElseIf nTipoEnt == 4
	cChave := "FILIAL+CLVL+SUBCTA+CCUSTO+CONTA+CBASE+ITEM+TIPO+SEQ+SEQREAV+MOEDA"
	cCabCond1 := OemToAnsi("Clv.Vlr. : ") //"Clv.Vlr. : "
	cCpoEnt := "CLVL"
End

//Controle de reincio da numeracao de paginas
oReport:SetPageNumber(n_pagini)
oReport:OnPageBreak( {|| If((n_pagini+1) > n_pagFim, (n_pagini := n_pagRes,oReport:SetPageNumber(n_pagini-1)),n_pagini += 1) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
ATFGERSLDM(oMeter,oText,oDlg,lEnd,cAliasTRB,dAquIni,dAquFim,dDataSLD,cBemIni,cBemFim,cItemIni,cItemFim,cContaIni,cContaFim,;
cCCIni,cCCFim,cItCtbIni,cItCtbFim,cClvlIni,cClVlFim,cGrupoIni,cGrupoFim,aSelMoed,aSelFil,lTodasFil,cChave,.T.,aTipo,Nil,Nil,cTipoSLD,aSelClass) },;
OemToAnsi(OemToAnsi(STR0034)),; //"Criando Arquivo Temporário..."
OemToAnsi(STR0035))//"Posicao Valorizada dos Bens na Data"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
//³Estrutura do Arquivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
/*
FILIAL CBASE ITEM MOEDA	CLASSIF TIPO DESC_SINT AQUISIC DTBAIXA DTSALDO CHAPA GRUPO CONTA CCUSTO SUBCTA CLVL QUANTD ORIGINAL AMPLIACAO ATUALIZ DEPRECACM
RESIDUAL CORRECACM CORDEPACM VLBAIXAS
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleção do arquivo agrupando por bem³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery += " SELECT "
cQuery += " 	FILIAL, "
cQuery += cCpoEnt

cQuery += " FROM " + cAliasTRB
cQuery += " GROUP BY   "
cQuery += " 	FILIAL,  "
cQuery += cCpoEnt

cQuery := ChangeQuery(cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasQry , .T. , .F.)

// Orderna de acordo com a Ordem do relatorio
(cAliasQry)->(dbGoTop())
While (cAliasQry)->(!EOF()) .And. !oReport:Cancel()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controla a quebra no 1o. nivel                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilQbr1 := (cAliasQry)->FILIAL
	
	IF nTipoEnt == 1
		cEntidade := (cAliasQry)->CONTA
	ElseIf nTipoEnt == 2
		cEntidade := (cAliasQry)->CCUSTO
	ElseIf nTipoEnt == 3
		cEntidade := (cAliasQry)->SUBCTA
	ElseIf nTipoEnt == 4
		cEntidade :=  (cAliasQry)->CLVL
	EndIf
	
	aValorFis 	:= {}
	aValorGer	:= {}
	aValorInc	:= {}
	
	If nTipoTotal == 1 .Or. nTipoTotal == 4
		aValorFis		:= TotalCtb(cAliasTRB,(cAliasQry)->FILIAL,nTipoEnt,cEntidade,cTipoFiscal)
	EndIf
	If nTipoTotal == 2 .Or. nTipoTotal == 4
		aValorGer		:= TotalCtb(cAliasTRB,(cAliasQry)->FILIAL,nTipoEnt,cEntidade,cTipoGerenc)
	EndIf
	If nTipoTotal == 3 .Or. nTipoTotal == 4
   		aValorInc		:= TotalCtb(cAliasTRB,(cAliasQry)->FILIAL,nTipoEnt,cEntidade,cTipoIncent)
	EndIf
	
	If Empty(aValorFis) .And. Empty(aValorGer) .And. Empty(aValorInc)
		(cAliasQry)->(dbSkip())
		Loop
	EndIf
	
	cDescr 	:= AFR072Desc( nTipoEnt, cFilQbr1 , cEntidade )
	cDescrFil:= GetAdvFval("SM0","M0_FILIAL",cEmpAnt + cFilQbr1 )
	oTxtSubtotal:Cell("FILIAL"):SetBlock({|| OemToAnsi(STR0035) + " : " + cFilQbr1 + " - " + cDescrFil } )//"Filial"
	oTxtSubtotal:Cell("ENTIDADE"):SetBlock( { || OemToAnsi(STR0036) + cCabCond1 + cDescr } )//"TOTAL "
	oTxtSubtotal:Finish()
	
	
	If Len(aValorFis) > 0
		oTxtFiscal:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0037) } )//"TOTAL FISCAL "
		
		oTxtFiscal:Init()
		oTxtFiscal:PrintLine()
		oSecValores:Init()
		
		For nX := 1 To Len(aValorFis)
			cMoeda	:= aValorFis[nX][1]
			cSuf 	:= CValtoChar(Val( cMoeda ))
			oSecValores:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
			oSecValores:Cell("N3_VORIG1"):SetBlock( 	{ || aValorFis[nX][2] } )
			oSecValores:Cell("N3_AMPLIA1"):SetBlock( 	{ || aValorFis[nX][3] } )
			oSecValores:Cell("VLATUALIZADO"):SetBlock({ || aValorFis[nX][4] } )
			oSecValores:Cell("N3_VRDACM1"):SetBlock( 	{ || aValorFis[nX][5] } )
			oSecValores:Cell("VLRESIDUAL"):SetBlock( 	{ || aValorFis[nX][6] } )
			oSecValores:Cell("N3_VRCDA1"):SetBlock( 	{ || aValorFis[nX][8] } )
			oSecValores:Cell("N3_VRCACM1"):SetBlock( 	{ || aValorFis[nX][7] } )
			oSecValores:PrintLine()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$¿
			//³Soma os totais da quebra³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$Ù
			nPos := aScan(aGerFiscal,{ |x| Alltrim(x[1]) == Alltrim(cMoeda)})
			If nPos == 0
				AAdd(aGerFiscal, { "", 0, 0, 0, 0, 0, 0, 0 } )
				nPos := Len(aGerFiscal)
				aGerFiscal[nPos][1] := cMoeda
			EndIf
			aGerFiscal[nPos][2] += aValorFis[nX][2]
			aGerFiscal[nPos][3] += aValorFis[nX][3]
			aGerFiscal[nPos][4] += aValorFis[nX][4]
			aGerFiscal[nPos][5] += aValorFis[nX][5]
			aGerFiscal[nPos][6] += aValorFis[nX][6]
			aGerFiscal[nPos][7] += aValorFis[nX][8]
			aGerFiscal[nPos][8] += aValorFis[nX][7]
		Next
		oTxtFiscal:Finish()
		oSecValores:Finish()
	EndIf
	
	
	If Len(aValorGer) > 0
		oTxtGerencial:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0038) } )//"TOTAL GERENCIAL "
		
		oTxtGerencial:Init()
		oTxtGerencial:PrintLine()
		oSecValores:Init()
		
		For nX := 1 To Len(aValorGer)
			cMoeda	:= aValorGer[nX][1]
			cSuf 	:= CValtoChar(Val( cMoeda ))
			oSecValores:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
			oSecValores:Cell("N3_VORIG1"):SetBlock( 	{ || aValorGer[nX][2] } )
			oSecValores:Cell("N3_AMPLIA1"):SetBlock( 	{ || aValorGer[nX][3] } )
			oSecValores:Cell("VLATUALIZADO"):SetBlock(	{ || aValorGer[nX][4] } )
			oSecValores:Cell("N3_VRDACM1"):SetBlock( 	{ || aValorGer[nX][5] } )
			oSecValores:Cell("VLRESIDUAL"):SetBlock( 	{ || aValorGer[nX][6] } )
			oSecValores:Cell("N3_VRCDA1"):SetBlock( 	{ || aValorGer[nX][8] } )
			oSecValores:Cell("N3_VRCACM1"):SetBlock( 	{ || aValorGer[nX][7] } )
			oSecValores:PrintLine()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$¿
			//³Soma os totais da quebra³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$Ù
			nPos := aScan(aGerGerencial,{ |x| Alltrim(x[1]) == Alltrim(cMoeda)})
			If nPos == 0
				AAdd(aGerGerencial, { "", 0, 0, 0, 0, 0, 0, 0 } )
				nPos := Len(aGerGerencial)
				aGerGerencial[nPos][1] := cMoeda
			EndIf
			aGerGerencial[nPos][2] += aValorGer[nX][2]
			aGerGerencial[nPos][3] += aValorGer[nX][3]
			aGerGerencial[nPos][4] += aValorGer[nX][4]
			aGerGerencial[nPos][5] += aValorGer[nX][5]
			aGerGerencial[nPos][6] += aValorGer[nX][6]
			aGerGerencial[nPos][7] += aValorGer[nX][8]
			aGerGerencial[nPos][8] += aValorGer[nX][7]
			
		Next
		oTxtGerencial:Finish()
		oSecValores:Finish()
	EndIf
	
	If Len(aValorInc) > 0
		
		oTxtIncentivada:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0039) } )//"TOTAL INCENTIVADA "
		
		oTxtIncentivada:Init()
		oTxtIncentivada:PrintLine()
		oSecValores:Init()
		
		For nX := 1 To Len(aValorInc)
			cMoeda	:= aValorInc[nX][1]
			cSuf 	:= CValtoChar(Val( cMoeda ))
			oSecValores:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
			oSecValores:Cell("N3_VORIG1"):SetBlock( 	{ || aValorInc[nX][2] } )
			oSecValores:Cell("N3_AMPLIA1"):SetBlock( 	{ || aValorInc[nX][3] } )
			oSecValores:Cell("VLATUALIZADO"):SetBlock(	{ || aValorInc[nX][4] } )
			oSecValores:Cell("N3_VRDACM1"):SetBlock( 	{ || aValorInc[nX][5] } )
			oSecValores:Cell("VLRESIDUAL"):SetBlock( 	{ || aValorInc[nX][6] } )
			oSecValores:Cell("N3_VRCDA1"):SetBlock( 	{ || aValorInc[nX][8] } )
			oSecValores:Cell("N3_VRCACM1"):SetBlock( 	{ || aValorInc[nX][7] } )
			oSecValores:PrintLine()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$¿
			//³Soma os totais da quebra³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$Ù
			nPos := aScan(aGerIncentivada,{ |x| Alltrim(x[1]) == Alltrim(cMoeda)})
			If nPos == 0
				AAdd(aGerIncentivada, { "", 0, 0, 0, 0, 0, 0, 0 } )
				nPos := Len(aGerIncentivada)
				aGerIncentivada[nPos][1] := cMoeda
			EndIf
			aGerIncentivada[nPos][2] += aValorInc[nX][2]
			aGerIncentivada[nPos][3] += aValorInc[nX][3]
			aGerIncentivada[nPos][4] += aValorInc[nX][4]
			aGerIncentivada[nPos][5] += aValorInc[nX][5]
			aGerIncentivada[nPos][6] += aValorInc[nX][6]
			aGerIncentivada[nPos][7] += aValorInc[nX][8]
			aGerIncentivada[nPos][8] += aValorInc[nX][7]
		Next
		oTxtIncentivada:Finish()
		oSecValores:Finish()
	EndIf
	
	oTxtSubtotal:Init()
	oTxtSubtotal:PrintLine()
	
	(cAliasQry)->(dbSKip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a impressao da totalizacao na quebra do segundo nivel        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Len(aGerFiscal) > 0 .Or. Len(aGerGerencial) > 0  .Or. Len(aGerIncentivada) > 0
	oReport:SkipLine()
	oReport:ThinLine()
	oTxtTotGer:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0040) } ) // "* * *   T O T A L   G E R A L   * * *"
	
	oTxtTotGer:Init()
	oTxtTotGer:PrintLine()
	
	If Len(aGerFiscal) > 0
		oTxtFiscal:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0037) } )//"TOTAL FISCAL "
		oTxtFiscal:Init()
		oTxtFiscal:PrintLine()
		
		oTotalGeral:Init()
		For nX := 1 To Len(aGerFiscal)
			cMoeda	:= aGerFiscal[nX][1]
			cSuf 	:= CValtoChar(Val( cMoeda ))
			
			oTotalGeral:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
			oTotalGeral:Cell("N3_VORIG1"):SetBlock( 	{ || aGerFiscal[nX][2] } )
			oTotalGeral:Cell("N3_AMPLIA1"):SetBlock( 	{ || aGerFiscal[nX][3] } )
			oTotalGeral:Cell("VLATUALIZADO"):SetBlock({ || aGerFiscal[nX][4] } )
			oTotalGeral:Cell("N3_VRDACM1"):SetBlock( 	{ || aGerFiscal[nX][5] } )
			oTotalGeral:Cell("VLRESIDUAL"):SetBlock( 	{ || aGerFiscal[nX][6] } )
			oTotalGeral:Cell("N3_VRCDA1"):SetBlock( 	{ || aGerFiscal[nX][7] } )
			oTotalGeral:Cell("N3_VRCACM1"):SetBlock( 	{ || aGerFiscal[nX][8] } )
			
			oTotalGeral:PrintLine()
		Next
		oTotalGeral:Finish()
	EndIf
	
	If Len(aGerGerencial) > 0
		oTxtGerencial:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0038) } ) //"TOTAL GERENCIAL "
		oTxtGerencial:Init()
		oTxtGerencial:PrintLine()
		
		oTotalGeral:Init()
		For nX := 1 To Len(aGerGerencial)
			cMoeda	:= aGerGerencial[nX][1]
			cSuf 	:= CValtoChar(Val( cMoeda ))
			
			oTotalGeral:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
			oTotalGeral:Cell("N3_VORIG1"):SetBlock( 	{ || aGerGerencial[nX][2] } )
			oTotalGeral:Cell("N3_AMPLIA1"):SetBlock( 	{ || aGerGerencial[nX][3] } )
			oTotalGeral:Cell("VLATUALIZADO"):SetBlock({ || aGerGerencial[nX][4] } )
			oTotalGeral:Cell("N3_VRDACM1"):SetBlock( 	{ || aGerGerencial[nX][5] } )
			oTotalGeral:Cell("VLRESIDUAL"):SetBlock( 	{ || aGerGerencial[nX][6] } )
			oTotalGeral:Cell("N3_VRCDA1"):SetBlock( 	{ || aGerGerencial[nX][7] } )
			oTotalGeral:Cell("N3_VRCACM1"):SetBlock( 	{ || aGerGerencial[nX][8] } )
			
			oTotalGeral:PrintLine()
		Next
		oTotalGeral:Finish()
	EndIf
	
	If Len(aGerIncentivada) > 0
		oTxtIncentivada:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0039) } )//"TOTAL INCENTIVADA "
		oTxtIncentivada:Init()
		oTxtIncentivada:PrintLine()
		
		oTotalGeral:Init()
		For nX := 1 To Len(aGerIncentivada)
			cMoeda	:= aGerIncentivada[nX][1]
			cSuf 	:= CValtoChar(Val( cMoeda ))
			
			oTotalGeral:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
			oTotalGeral:Cell("N3_VORIG1"):SetBlock( 	{ || aGerIncentivada[nX][2] } )
			oTotalGeral:Cell("N3_AMPLIA1"):SetBlock( 	{ || aGerIncentivada[nX][3] } )
			oTotalGeral:Cell("VLATUALIZADO"):SetBlock({ || aGerIncentivada[nX][4] } )
			oTotalGeral:Cell("N3_VRDACM1"):SetBlock( 	{ || aGerIncentivada[nX][5] } )
			oTotalGeral:Cell("VLRESIDUAL"):SetBlock( 	{ || aGerIncentivada[nX][6] } )
			oTotalGeral:Cell("N3_VRCDA1"):SetBlock( 	{ || aGerIncentivada[nX][7] } )
			oTotalGeral:Cell("N3_VRCACM1"):SetBlock( 	{ || aGerIncentivada[nX][8] } )
			
			oTotalGeral:PrintLine()
			
		Next
		oTotalGeral:Finish()
	EndIf
	oTxtTotGer:Finish()
EndIf
(cAliasTRB)->(dbCloseArea())
(cAliasQry)->(dbCloseArea())
MSErase(cAliasTRB)

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrtSintBemºAutor  ³Alvaro Camillo Neto º Data ³  28/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressão do relatório Sintético por Bem                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFR072                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrtSintBem( oReport )
Local oSecEntCtb	 := oReport:Section(1)
Local oSecBem		 := oReport:Section(1):Section(1)
Local oSecValores	 := oReport:Section(1):Section(2)
Local oTxtSubtotal 	 := oReport:Section(1):Section(3)
Local oSubtotal 	 := oReport:Section(1):Section(4)
Local oTxtTotGer	 := oReport:Section(2)
Local oTotalGeral	 := oReport:Section(3)
Local oTxtFiscal	 := oReport:Section(4)
Local oTxtGerencial	 := oReport:Section(5)
Local oTxtIncentivada:= oReport:Section(6)

Local oMeter
Local oText
Local oDlg
Local lEnd
Local cAliasQry 	:= GetNextAlias()
Local dDataSLD  	:= MV_PAR01
Local dAquIni		:= MV_PAR04
Local dAquFim   	:= MV_PAR05
Local cBemIni   	:= MV_PAR06
Local cBemFim   	:= MV_PAR08
Local cItemIni  	:= MV_PAR07
Local cItemFim  	:= MV_PAR09
Local cContaIni 	:= MV_PAR12
Local cContaFim 	:= MV_PAR13
Local cCCIni   		:= MV_PAR14
Local cCCFim   		:= MV_PAR15
Local cItCtbIni		:= MV_PAR16
Local cItCtbFim		:= MV_PAR17
Local cClvlIni		:= MV_PAR18
Local cClVlFim		:= MV_PAR19
Local cGrupoIni		:= MV_PAR10
Local cGrupoFim		:= MV_PAR11
Local n_pagini 		:= MV_PAR21
Local n_pagFim		:= MV_PAR22
Local n_pagRes		:= MV_PAR23
Local nTipoTotal	:= MV_PAR24
Local cTipoSLD		:= MV_PAR25
Local cChave		:= ""
Local cCond			:= ""
Local nCount		:= 0
Local aFiscal		:= {}
Local aGerencial	:= {}
Local aIncentivada	:= {}
Local aGerFiscal 	:= {}
Local aGerGerencial := {}
Local aGerIncentivada:= {}
Local aSubFiscal 	:= {}
Local aSubGerencial := {}
Local aSubIncentivada:= {}
Local aFilFiscal	:= {}
Local aFilGerencial	:= {}
Local aFilIncentivada:= {}
Local aDadosBem		:= {}
Local nX			:= 0
Local nTotal 	 	:= 0
Local nQuantidade 	:= 0
Local nQtdFil	 	:= 0
Local cCabCond1 	:= ""
Local cQuery		:= ""
Local nTipoEnt		:= oSecEntCtb:GetOrder()
Local aTipo			:= {}   
Local cChaveBem		:= ""
Local cTipoFiscal	:= ATFXTpBem(1)
Local cTipoGerenc   := ATFXTpBem(2)
Local cTipoIncent	:= ATFXTpBem(3)   
Local cDescSld		:= ""

aSelMoed := IIF(Empty(aSelMoed), {"01"} , aSelMoed )

If nTipoTotal == 1 //Fiscal
	aTipo := ATFXTpBem(1,.T.)
ElseIf nTipoTotal == 2 //Gerencial
	aTipo := ATFXTpBem(2,.T.)
ElseIf nTipoTotal == 3 //Incentivada
	aTipo := ATFXTpBem(3,.T.)
EndIf

// Desabilita todas as celulas de secao 1
oSecEntCtb:Cell("CT1_CONTA"):Disable()
oSecEntCtb:Cell("CT1_DESC01"):Disable()
oSecEntCtb:Cell("CTT_CUSTO"):Disable()
oSecEntCtb:Cell("CTT_DESC01"):Disable()
oSecEntCtb:Cell("CTD_ITEM"):Disable()
oSecEntCtb:Cell("CTD_DESC01"):Disable()
oSecEntCtb:Cell("CTH_CLVL"):Disable()
oSecEntCtb:Cell("CTH_DESC01"):Disable()

oSecValores:Cell("SIMBMOEDA"):SetTitle("")
oSubTotal:Cell("SIMBMOEDA"):SetTitle("")

oTotalGeral:Cell("SIMBMOEDA"):SetTitle("")

//Ordem do Arquivo
IF nTipoEnt == 1
	cChave := "FILIAL+CONTA+CCUSTO+CBASE+ITEM+TIPO+SEQ+SEQREAV+MOEDA"
	cCabCond1 := OemToAnsi("Conta   : ") //"Conta   : "
ElseIf nTipoEnt == 2
	cChave := "FILIAL+CCUSTO+CONTA+CBASE+ITEM+TIPO+SEQ+SEQREAV+MOEDA"
	cCabCond1 := OemToAnsi("C.Custo : ") //"C.Custo : "
ElseIf nTipoEnt == 3
	cChave := "FILIAL+SUBCTA+CCUSTO+CONTA+CBASE+ITEM+TIPO+SEQ+SEQREAV+MOEDA"
	cCabCond1 := OemToAnsi("It.Ctb. : ") //"It.Ctb. : "
ElseIf nTipoEnt == 4
	cChave := "FILIAL+CLVL+SUBCTA+CCUSTO+CONTA+CBASE+ITEM+TIPO+SEQ+SEQREAV+MOEDA"
	cCabCond1 := OemToAnsi("Clv.Vlr. : ") //"Clv.Vlr. : "
End

//Controle de reincio da numeracao de paginas
oReport:SetPageNumber(n_pagini)
oReport:OnPageBreak( {|| If((n_pagini+1) > n_pagFim, (n_pagini := n_pagRes,oReport:SetPageNumber(n_pagini-1)),n_pagini += 1) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
ATFGERSLDM(oMeter,oText,oDlg,lEnd,cAliasQry,dAquIni,dAquFim,dDataSLD,cBemIni,cBemFim,cItemIni,cItemFim,cContaIni,cContaFim,;
cCCIni,cCCFim,cItCtbIni,cItCtbFim,cClvlIni,cClVlFim,cGrupoIni,cGrupoFim,aSelMoed,aSelFil,lTodasFil,cChave,.T.,aTipo,Nil,Nil,cTipoSLD,aSelClas) },;
OemToAnsi(OemToAnsi(STR0034)),; //"Criando Arquivo Temporário..."
OemToAnsi(STR0035))//"Posicao Valorizada dos Bens na Data"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
//³Estrutura do Arquivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
/*
FILIAL CBASE ITEM MOEDA	CLASSIF TIPO DESC_SINT AQUISIC DTBAIXA DTSALDO CHAPA GRUPO CONTA CCUSTO SUBCTA CLVL QUANTD ORIGINAL AMPLIACAO ATUALIZ DEPRECACM
RESIDUAL CORRECACM CORDEPACM VLBAIXAS
*/


//Descrição do tipo de saldo
SX5->(MsSeek(xFilial("SX5") + "SL"+ IIF(Empty(cTipoSLD),'1',cTipoSLD) ))
cDescSld := Alltrim(SX5->(X5Descri()))


// Orderna de acordo com a Ordem do relatorio
(cAliasQry)->(dbGoTop())
While (cAliasQry)->(!EOF()) .And. !oReport:Cancel()
	
	nQuantidade := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controla a quebra no 1o. nivel                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilQbr1 := (cAliasQry)->FILIAL
	IF nTipoEnt == 1
		cEntQbr1 := (cAliasQry)->CONTA
		cQuebra1 :=  cFilQbr1 + cEntQbr1
		cCond1   := cAliasQry + "->( FILIAL + CONTA ) == cQuebra1"
	ElseIf nTipoEnt == 2
		cEntQbr1 := (cAliasQry)->CCUSTO
		cQuebra1 :=  cFilQbr1 + cEntQbr1
		cCond1   := cAliasQry + "->( FILIAL + CCUSTO ) == cQuebra1"
	ElseIf nTipoEnt == 3
		cEntQbr1 := (cAliasQry)->SUBCTA
		cQuebra1 :=  cFilQbr1 + cEntQbr1
		cCond1   := cAliasQry + "->( FILIAL + SUBCTA ) == cQuebra1"
	ElseIf nTipoEnt == 4
		cEntQbr1 :=  (cAliasQry)->CLVL
		cQuebra1 :=  cFilQbr1 + cEntQbr1
		cCond1   := cAliasQry + "->( FILIAL + CLVL ) == cQuebra1"
	EndIf
	
	dbSelectArea(cAliasQry)
	
	IF Empty(cEntQbr1)
		(cAliasQry)->(dbSkip())
		Loop
	EndIf
	
	lDescricao 		:= .F.
	aSubFiscal 		:= {}
	aSubGerencial 	:= {}
	aSubIncentivada := {}
	
	While (cAliasQry)->(!Eof()) .AND. &cCond1 .And. !oReport:Cancel()
		aFiscal 	:= {}
		aGerencial	:= {}
		aIncentivada:= {}
		
		If !lDescricao
			AFR072Cab(nTipoEnt,cFilQbr1,cEntQbr1, oReport)
			lDescricao := .T.
		EndIf
		
		If AllTrim(cChaveBem) != AllTrim((cAliasQry)->FILIAL + (cAliasQry)->CBASE + (cAliasQry)->ITEM)  
			cChaveBem := (cAliasQry)->FILIAL + (cAliasQry)->CBASE + (cAliasQry)->ITEM   
			nQuantidade += (cAliasQry)->QUANTD  
			nQtdFil+= (cAliasQry)->QUANTD   
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controla a quebra no 2o. nivel                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDadosBem := {}
		aAdd(aDadosBem, (cAliasQry)->FILIAL ) 
		aAdd(aDadosBem, (cAliasQry)->CBASE ) 
		aAdd(aDadosBem, (cAliasQry)->ITEM ) 
		aAdd(aDadosBem, X3COMBO('N1_PATRIM',(cAliasQry)->CLASSIF)  ) 
		aAdd(aDadosBem, (cAliasQry)->DESC_SINT  ) 
		aAdd(aDadosBem,  (cAliasQry)->AQUISIC) 
		aAdd(aDadosBem, (cAliasQry)->DTBAIXA  ) 
		aAdd(aDadosBem, (cAliasQry)->QUANTD  ) 
		aAdd(aDadosBem, (cAliasQry)->CHAPA  ) 
		aAdd(aDadosBem, (cAliasQry)->CONTA  ) 
		aAdd(aDadosBem, (cAliasQry)->CCUSTO ) 
		aAdd(aDadosBem,  (cAliasQry)->SUBCTA ) 
		aAdd(aDadosBem, (cAliasQry)->CLVL ) 
		aAdd(aDadosBem, cDescSld  ) 		

		IF nTipoEnt == 1
			cQuebra2 :=  (cAliasQry)->( FILIAL+CONTA+CCUSTO+CBASE+ITEM )
			cCond2   := cAliasQry + "->( FILIAL+CONTA+CCUSTO+CBASE+ITEM ) == cQuebra2"
		ElseIf nTipoEnt == 2
			cQuebra2 :=  (cAliasQry)->( FILIAL+CCUSTO+CONTA+CBASE+ITEM )
			cCond2   := cAliasQry + "->( FILIAL+CCUSTO+CONTA+CBASE+ITEM ) == cQuebra2"
		ElseIf nTipoEnt == 3
			cQuebra2 :=  (cAliasQry)->( FILIAL+SUBCTA+CCUSTO+CONTA+CBASE+ITEM )
			cCond2   := cAliasQry + "->( FILIAL+SUBCTA+CCUSTO+CONTA+CBASE+ITEM ) == cQuebra2"
		ElseIf nTipoEnt == 4
			cQuebra2 := (cAliasQry)->( FILIAL+CLVL+SUBCTA+CCUSTO+CONTA+CBASE+ITEM )
			cCond2   := cAliasQry + "->( FILIAL+CLVL+SUBCTA+CCUSTO+CONTA+CBASE+ITEM ) == cQuebra2"
		EndIf

		While (cAliasQry)->(!Eof()) .AND. &cCond2 .And. !oReport:Cancel()
			If (nTipoTotal == 1 .Or. nTipoTotal == 4) .And. ( (cAliasQry)->TIPO $ cTipoFiscal )
				nPos := aScan(aFiscal,{ |x| Alltrim(x[1]) == Alltrim((cAliasQry)->MOEDA)})
				If nPos == 0
					AAdd(aFiscal, { "", 0, 0, 0, 0, 0, 0, 0 } )
					nPos := Len(aFiscal)
					aFiscal[nPos][1] := (cAliasQry)->MOEDA
				EndIf
				aFiscal[nPos][2] += (cAliasQry)->ORIGINAL
				aFiscal[nPos][3] += (cAliasQry)->AMPLIACAO
				aFiscal[nPos][4] += (cAliasQry)->ATUALIZ
				aFiscal[nPos][5] += (cAliasQry)->DEPRECACM
				aFiscal[nPos][6] += (cAliasQry)->RESIDUAL
				aFiscal[nPos][7] += (cAliasQry)->CORDEPACM
				aFiscal[nPos][8] += (cAliasQry)->CORRECACM
			EndIf
			
			If nTipoTotal == 2 .Or. nTipoTotal == 4 .And. (cAliasQry)->TIPO $ cTipoGerenc
				nPos := aScan(aGerencial,{ |x| Alltrim(x[1]) == Alltrim((cAliasQry)->MOEDA)})
				If nPos == 0
					AAdd(aGerencial, { "", 0, 0, 0, 0, 0, 0, 0 } )
					nPos := Len(aGerencial)
					aGerencial[nPos][1] := (cAliasQry)->MOEDA
				EndIf
				aGerencial[nPos][2] += (cAliasQry)->ORIGINAL
				aGerencial[nPos][3] += (cAliasQry)->AMPLIACAO
				aGerencial[nPos][4] += (cAliasQry)->ATUALIZ
				aGerencial[nPos][5] += (cAliasQry)->DEPRECACM
				aGerencial[nPos][6] += (cAliasQry)->RESIDUAL
				aGerencial[nPos][7] += (cAliasQry)->CORDEPACM
				aGerencial[nPos][8] += (cAliasQry)->CORRECACM
			EndIf
			
			If nTipoTotal == 3 .Or. nTipoTotal == 4 .And. ( (cAliasQry)->TIPO $ cTipoIncent )
				nPos := aScan(aIncentivada,{ |x| Alltrim(x[1]) == Alltrim((cAliasQry)->MOEDA)})
				If nPos == 0
					AAdd(aIncentivada, { "", 0, 0, 0, 0, 0, 0, 0 } )
					nPos := Len(aIncentivada)
					aIncentivada[nPos][1] := (cAliasQry)->MOEDA
				EndIf
				aIncentivada[nPos][2] += (cAliasQry)->ORIGINAL
				aIncentivada[nPos][3] += (cAliasQry)->AMPLIACAO
				aIncentivada[nPos][4] += (cAliasQry)->ATUALIZ
				aIncentivada[nPos][5] += (cAliasQry)->DEPRECACM
				aIncentivada[nPos][6] += (cAliasQry)->RESIDUAL
				aIncentivada[nPos][7] += (cAliasQry)->CORDEPACM
				aIncentivada[nPos][8] += (cAliasQry)->CORRECACM
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		
		If Empty(aFiscal) .And. Empty(aGerencial) .And. Empty(aIncentivada)
			(cAliasQry)->(dbSkip())
			Loop
		Else
			oSecBem:Init()
			oSecBem:Cell("N3_FILIAL"):SetBlock({|| aDadosBem[1] } )
			oSecBem:Cell("N3_CBASE"):SetBlock({||  aDadosBem[2]  } )
			oSecBem:Cell("N3_ITEM"):SetBlock({||   aDadosBem[3]  } )
			oSecBem:Cell("N1_PATRIM"):SetBlock({|| aDadosBem[4]    } )
			oSecBem:Cell("N1_DESCRIC"):SetBlock({||aDadosBem[5]  } )
			oSecBem:Cell("N1_AQUISIC"):SetBlock({||aDadosBem[6]  } )
			oSecBem:Cell("N1_BAIXA"):SetBlock({||  aDadosBem[7]  } )
			oSecBem:Cell("N1_QUANTD"):SetBlock({|| aDadosBem[8]  } )
			oSecBem:Cell("N1_CHAPA"):SetBlock({||  aDadosBem[9]  } )
			oSecBem:Cell("N3_TPSALDO"):SetBlock({||aDadosBem[14]  } )
			oSecBem:Cell("N3_CCONTAB"):SetBlock({||aDadosBem[10]  } )
			oSecBem:Cell("N3_CUSTBEM"):SetBlock({||aDadosBem[11] } )
			oSecBem:Cell("N3_SUBCCON"):SetBlock({||aDadosBem[12]  } )
			oSecBem:Cell("N3_CLVLCON"):SetBlock({||aDadosBem[13]  } )
			oSecBem:Cell("N3_TIPO"):SetBlock({|| "" } )
			oSecBem:PrintLine()
			oSecBem:Finish()
		EndIf
		
		If Len(aFiscal) > 0
			oTxtFiscal:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0037) } )//"TOTAL FISCAL "
			
			oTxtFiscal:Init()
			oTxtFiscal:PrintLine()
			oSecValores:Init()
			
			For nX := 1 To Len(aFiscal)
				cMoeda	:= aFiscal[nX][1]
				cSuf 	:= CValtoChar(Val( cMoeda ))
				oSecValores:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
				oSecValores:Cell("N3_VORIG1"):SetBlock( 	{ || aFiscal[nX][2] } )
				oSecValores:Cell("N3_AMPLIA1"):SetBlock( 	{ || aFiscal[nX][3] } )
				oSecValores:Cell("VLATUALIZADO"):SetBlock(	{ || aFiscal[nX][4] } )
				oSecValores:Cell("N3_VRDACM1"):SetBlock( 	{ || aFiscal[nX][5] } )
				oSecValores:Cell("VLRESIDUAL"):SetBlock( 	{ || aFiscal[nX][6] } )
				oSecValores:Cell("N3_VRCDA1"):SetBlock( 	{ || aFiscal[nX][7] } )
				oSecValores:Cell("N3_VRCACM1"):SetBlock( 	{ || aFiscal[nX][8] } )
				oSecValores:PrintLine()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$¿
				//³Soma os totais da quebra³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$Ù
				nPos := aScan(aSubFiscal,{ |x| Alltrim(x[1]) == Alltrim(cMoeda)})
				If nPos == 0
					AAdd(aSubFiscal, { "", 0, 0, 0, 0, 0, 0, 0 } )
					nPos := Len(aSubFiscal)
					aSubFiscal[nPos][1] := cMoeda
				EndIf
				aSubFiscal[nPos][2] += aFiscal[nX][2]
				aSubFiscal[nPos][3] += aFiscal[nX][3]
				aSubFiscal[nPos][4] += aFiscal[nX][4]
				aSubFiscal[nPos][5] += aFiscal[nX][5]
				aSubFiscal[nPos][6] += aFiscal[nX][6]
				aSubFiscal[nPos][7] += aFiscal[nX][7]
				aSubFiscal[nPos][8] += aFiscal[nX][8]
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$¿
				//³Soma os totais da filial ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$Ù
				nPos := aScan(aFilFiscal,{ |x| Alltrim(x[1]) == Alltrim(cMoeda)})
				If nPos == 0
					AAdd(aFilFiscal, { "", 0, 0, 0, 0, 0, 0, 0 } )
					nPos := Len(aFilFiscal)
					aFilFiscal[nPos][1] := cMoeda
				EndIf
				aFilFiscal[nPos][2] += aFiscal[nX][2]
				aFilFiscal[nPos][3] += aFiscal[nX][3]
				aFilFiscal[nPos][4] += aFiscal[nX][4]
				aFilFiscal[nPos][5] += aFiscal[nX][5]
				aFilFiscal[nPos][6] += aFiscal[nX][6]
				aFilFiscal[nPos][7] += aFiscal[nX][7]
				aFilFiscal[nPos][8] += aFiscal[nX][8]
			Next
			oTxtFiscal:Finish()
			oSecValores:Finish()
		EndIf
		
		
		If Len(aGerencial) > 0
			oTxtGerencial:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0038) } )//"TOTAL GERENCIAL "
			
			oTxtGerencial:Init()
			oTxtGerencial:PrintLine()
			oSecValores:Init()
			
			For nX := 1 To Len(aGerencial)
				cMoeda	:= aGerencial[nX][1]
				cSuf 	:= CValtoChar(Val( cMoeda ))
				oSecValores:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
				oSecValores:Cell("N3_VORIG1"):SetBlock( 	{ || aGerencial[nX][2] } )
				oSecValores:Cell("N3_AMPLIA1"):SetBlock( 	{ || aGerencial[nX][3] } )
				oSecValores:Cell("VLATUALIZADO"):SetBlock(	{ || aGerencial[nX][4] } )
				oSecValores:Cell("N3_VRDACM1"):SetBlock( 	{ || aGerencial[nX][5] } )
				oSecValores:Cell("VLRESIDUAL"):SetBlock( 	{ || aGerencial[nX][6] } )
				oSecValores:Cell("N3_VRCDA1"):SetBlock( 		{ || aGerencial[nX][7] } )
				oSecValores:Cell("N3_VRCACM1"):SetBlock( 	{ || aGerencial[nX][8] } )
				oSecValores:PrintLine()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$¿
				//³Soma os totais da quebra³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$Ù
				nPos := aScan(aSubGerencial,{ |x| Alltrim(x[1]) == Alltrim(cMoeda)})
				If nPos == 0
					AAdd(aSubGerencial, { "", 0, 0, 0, 0, 0, 0, 0 } )
					nPos := Len(aSubGerencial)
					aSubGerencial[nPos][1] := cMoeda
				EndIf
				aSubGerencial[nPos][2] += aGerencial[nX][2]
				aSubGerencial[nPos][3] += aGerencial[nX][3]
				aSubGerencial[nPos][4] += aGerencial[nX][4]
				aSubGerencial[nPos][5] += aGerencial[nX][5]
				aSubGerencial[nPos][6] += aGerencial[nX][6]
				aSubGerencial[nPos][7] += aGerencial[nX][7]
				aSubGerencial[nPos][8] += aGerencial[nX][8]
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$¿
				//³Soma os totais da filial ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$Ù
				nPos := aScan(aFilGerencial,{ |x| Alltrim(x[1]) == Alltrim(cMoeda)})
				If nPos == 0
					AAdd(aFilGerencial, { "", 0, 0, 0, 0, 0, 0, 0 } )
					nPos := Len(aFilGerencial)
					aFilGerencial[nPos][1] := cMoeda
				EndIf
				aFilGerencial[nPos][2] += aGerencial[nX][2]
				aFilGerencial[nPos][3] += aGerencial[nX][3]
				aFilGerencial[nPos][4] += aGerencial[nX][4]
				aFilGerencial[nPos][5] += aGerencial[nX][5]
				aFilGerencial[nPos][6] += aGerencial[nX][6]
				aFilGerencial[nPos][7] += aGerencial[nX][7]
				aFilGerencial[nPos][8] += aGerencial[nX][8]
			Next
			oTxtGerencial:Finish()
			oSecValores:Finish()
		EndIf
		
		If Len(aIncentivada) > 0
			
			oTxtIncentivada:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0039) } )//"TOTAL INCENTIVADA "
			
			oTxtIncentivada:Init()
			oTxtIncentivada:PrintLine()
			oSecValores:Init()
			
			For nX := 1 To Len(aIncentivada)
				cMoeda	:= aIncentivada[nX][1]
				cSuf 	:= CValtoChar(Val( cMoeda ))
				oSecValores:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
				oSecValores:Cell("N3_VORIG1"):SetBlock( 	{ || aIncentivada[nX][2] } )
				oSecValores:Cell("N3_AMPLIA1"):SetBlock( 	{ || aIncentivada[nX][3] } )
				oSecValores:Cell("VLATUALIZADO"):SetBlock(	{ || aIncentivada[nX][4] } )
				oSecValores:Cell("N3_VRDACM1"):SetBlock( 	{ || aIncentivada[nX][5] } )
				oSecValores:Cell("VLRESIDUAL"):SetBlock( 	{ || aIncentivada[nX][6] } )
				oSecValores:Cell("N3_VRCDA1"):SetBlock( 	{ || aIncentivada[nX][7] } )
				oSecValores:Cell("N3_VRCACM1"):SetBlock( 	{ || aIncentivada[nX][8] } )
				oSecValores:PrintLine()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$¿
				//³Soma os totais da quebra³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$Ù
				nPos := aScan(aSubIncentivada,{ |x| Alltrim(x[1]) == Alltrim(cMoeda)})
				If nPos == 0
					AAdd(aSubIncentivada, { "", 0, 0, 0, 0, 0, 0, 0} )
					nPos := Len(aSubIncentivada)
					aSubIncentivada[nPos][1] := cMoeda
				EndIf
				aSubIncentivada[nPos][2] += aIncentivada[nX][2]
				aSubIncentivada[nPos][3] += aIncentivada[nX][3]
				aSubIncentivada[nPos][4] += aIncentivada[nX][4]
				aSubIncentivada[nPos][5] += aIncentivada[nX][5]
				aSubIncentivada[nPos][6] += aIncentivada[nX][6]
				aSubIncentivada[nPos][7] += aIncentivada[nX][7]
				aSubIncentivada[nPos][8] += aIncentivada[nX][8]
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$¿
				//³Soma os totais da filial ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$Ù
				nPos := aScan(aFilIncentivada,{ |x| Alltrim(x[1]) == Alltrim(cMoeda)})
				If nPos == 0
					AAdd(aFilIncentivada, { "", 0, 0, 0, 0, 0, 0, 0 } )
					nPos := Len(aFilIncentivada)
					aFilIncentivada[nPos][1] := cMoeda
				EndIf
				aFilIncentivada[nPos][2] += aIncentivada[nX][2]
				aFilIncentivada[nPos][3] += aIncentivada[nX][3]
				aFilIncentivada[nPos][4] += aIncentivada[nX][4]
				aFilIncentivada[nPos][5] += aIncentivada[nX][5]
				aFilIncentivada[nPos][6] += aIncentivada[nX][6]
				aFilIncentivada[nPos][7] += aIncentivada[nX][7]
				aFilIncentivada[nPos][8] += aIncentivada[nX][8]
				
			Next
			oTxtIncentivada:Finish()
			oSecValores:Finish()
		EndIf
	EndDo
	
	If Len(aSubFiscal) > 0 .Or. Len(aSubGerencial) > 0  .Or. Len(aSubIncentivada) > 0
		dbSelectArea("CT1")
		dbSeek(xFilial("CT1",cFilQbr1)+cEntQbr1)
		
		cDescr 	:= AFR072Desc( nTipoEnt, cFilQbr1 , cEntQbr1 )
		cDescrFil:= GetAdvFval("SM0","M0_FILIAL",cEmpAnt + cFilQbr1 )
		oTxtSubtotal:Cell("FILIAL"):SetBlock({|| OemToAnsi(STR0035) + " : " + cFilQbr1 + " - " + cDescrFil } )//"Filial"
		oTxtSubtotal:Cell("ENTIDADE"):SetBlock( { || OemToAnsi("TOTAL ") + cCabCond1 + cDescr } )
		oTxtSubtotal:Cell("QUANTIDADE"):SetBlock( { || OemToAnsi(STR0041) + ": " + cValtoChar(nQuantidade) } )
		
		oTxtSubtotal:Init()
		oTxtSubtotal:PrintLine()
		
		nTotal += nQuantidade
		nQuantidade := 0
		
		If Len(aSubFiscal) > 0
			oTxtFiscal:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0037) } )//"TOTAL FISCAL "
			oTxtFiscal:Init()
			oTxtFiscal:PrintLine()
			
			oSubTotal:Init()
			For nX := 1 To Len(aSubFiscal)
				cMoeda	:= aSubFiscal[nX][1]
				cSuf 	:= CValtoChar(Val( cMoeda ))
				
				oSubTotal:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
				oSubTotal:Cell("N3_VORIG1"):SetBlock( 	{ || aSubFiscal[nX][2] } )
				oSubTotal:Cell("N3_AMPLIA1"):SetBlock( 	{ || aSubFiscal[nX][3] } )
				oSubTotal:Cell("VLATUALIZADO"):SetBlock({ || aSubFiscal[nX][4] } )
				oSubTotal:Cell("N3_VRDACM1"):SetBlock( 	{ || aSubFiscal[nX][5] } )
				oSubTotal:Cell("VLRESIDUAL"):SetBlock( 	{ || aSubFiscal[nX][6] } )
				oSubTotal:Cell("N3_VRCDA1"):SetBlock( 	{ || aSubFiscal[nX][7] } )
				oSubTotal:Cell("N3_VRCACM1"):SetBlock( 	{ || aSubFiscal[nX][8] } )
				
				oSubTotal:PrintLine()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Soma os totais do relatório³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPos := aScan(aGerFiscal,{ |x| Alltrim(x[1]) == Alltrim(cMoeda) } )
				If nPos == 0
					AAdd(aGerFiscal, { "", 0, 0, 0, 0, 0, 0, 0 } )
					nPos := Len(aGerFiscal)
					aGerFiscal[nPos][1] := cMoeda
				EndIf
				aGerFiscal[nPos][2] += aSubFiscal[nX][2]
				aGerFiscal[nPos][3] += aSubFiscal[nX][3]
				aGerFiscal[nPos][4] += aSubFiscal[nX][4]
				aGerFiscal[nPos][5] += aSubFiscal[nX][5]
				aGerFiscal[nPos][6] += aSubFiscal[nX][6]
				aGerFiscal[nPos][7] += aSubFiscal[nX][7]
				aGerFiscal[nPos][8] += aSubFiscal[nX][8]
			Next
			oSubTotal:Finish()
		EndIf
		
		If Len(aSubGerencial) > 0
			oTxtGerencial:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0038) } )//"TOTAL GERENCIAL "
			oTxtGerencial:Init()
			oTxtGerencial:PrintLine()
			
			oSubTotal:Init()
			For nX := 1 To Len(aSubGerencial)
				cMoeda	:= aSubGerencial[nX][1]
				cSuf 	:= CValtoChar(Val( cMoeda ))
				
				oSubTotal:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
				oSubTotal:Cell("N3_VORIG1"):SetBlock( 	{ || aSubGerencial[nX][2] } )
				oSubTotal:Cell("N3_AMPLIA1"):SetBlock( 	{ || aSubGerencial[nX][3] } )
				oSubTotal:Cell("VLATUALIZADO"):SetBlock({ || aSubGerencial[nX][4] } )
				oSubTotal:Cell("N3_VRDACM1"):SetBlock( 	{ || aSubGerencial[nX][5] } )
				oSubTotal:Cell("VLRESIDUAL"):SetBlock( 	{ || aSubGerencial[nX][6] } )
				oSubTotal:Cell("N3_VRCDA1"):SetBlock( 	{ || aSubGerencial[nX][7] } )
				oSubTotal:Cell("N3_VRCACM1"):SetBlock( 	{ || aSubGerencial[nX][8] } )
				
				oSubTotal:PrintLine()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Soma os totais do relatório³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPos := aScan(aGerGerencial,{ |x| Alltrim(x[1]) == Alltrim(cMoeda) } )
				If nPos == 0
					AAdd(aGerGerencial, { "", 0, 0, 0, 0, 0, 0, 0 } )
					nPos := Len(aGerGerencial)
					aGerGerencial[nPos][1] := cMoeda
				EndIf
				aGerGerencial[nPos][2] += aSubGerencial[nX][2]
				aGerGerencial[nPos][3] += aSubGerencial[nX][3]
				aGerGerencial[nPos][4] += aSubGerencial[nX][4]
				aGerGerencial[nPos][5] += aSubGerencial[nX][5]
				aGerGerencial[nPos][6] += aSubGerencial[nX][6]
				aGerGerencial[nPos][7] += aSubGerencial[nX][7]
				aGerGerencial[nPos][8] += aSubGerencial[nX][8]
			Next
			oSubTotal:Finish()
		EndIf
		
		If Len(aSubIncentivada) > 0
			oTxtIncentivada:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0039) } )//"TOTAL INCENTIVADA "
			oTxtIncentivada:Init()
			oTxtIncentivada:PrintLine()
			
			oSubTotal:Init()
			For nX := 1 To Len(aSubIncentivada)
				cMoeda	:= aSubIncentivada[nX][1]
				cSuf 	:= CValtoChar(Val( cMoeda ))
				
				oSubTotal:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
				oSubTotal:Cell("N3_VORIG1"):SetBlock( 	{ || aSubIncentivada[nX][2] } )
				oSubTotal:Cell("N3_AMPLIA1"):SetBlock( 	{ || aSubIncentivada[nX][3] } )
				oSubTotal:Cell("VLATUALIZADO"):SetBlock({ || aSubIncentivada[nX][4] } )
				oSubTotal:Cell("N3_VRDACM1"):SetBlock( 	{ || aSubIncentivada[nX][5] } )
				oSubTotal:Cell("VLRESIDUAL"):SetBlock( 	{ || aSubIncentivada[nX][6] } )
				oSubTotal:Cell("N3_VRCDA1"):SetBlock( 	{ || aSubIncentivada[nX][7] } )
				oSubTotal:Cell("N3_VRCACM1"):SetBlock( 	{ || aSubIncentivada[nX][8] } )
				
				oSubTotal:PrintLine()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Soma os totais do relatório³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPos := aScan(aGerIncentivada,{ |x| Alltrim(x[1]) == Alltrim(cMoeda) } )
				If nPos == 0
					AAdd(aGerIncentivada, { "", 0, 0, 0, 0, 0, 0, 0 } )
					nPos := Len(aGerIncentivada)
					aGerIncentivada[nPos][1] := cMoeda
				EndIf
				aGerIncentivada[nPos][2] += aSubIncentivada[nX][2]
				aGerIncentivada[nPos][3] += aSubIncentivada[nX][3]
				aGerIncentivada[nPos][4] += aSubIncentivada[nX][4]
				aGerIncentivada[nPos][5] += aSubIncentivada[nX][5]
				aGerIncentivada[nPos][6] += aSubIncentivada[nX][6]
				aGerIncentivada[nPos][7] += aSubIncentivada[nX][7]
				aGerIncentivada[nPos][8] += aSubIncentivada[nX][8]
			Next
			oSubTotal:Finish()
		EndIf
		
		oTxtSubtotal:Finish()
		oReport:SkipLine()
		oReport:ThinLine()
		lDescricao := .F.
		
	EndIf
	
	If cFilQbr1  != (cAliasQry)->FILIAL .And. (Len(aFilFiscal) > 0 .Or. Len(aFilGerencial) > 0  .Or. Len(aFilIncentivada) > 0)
		oTxtTotGer:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0042) } )//"* * *   T O T A L   F I L I A L   * * *"
		oTxtTotGer:Init()
		oTxtTotGer:PrintLine()
		
		oTxtSubtotal:Cell("FILIAL"):SetBlock({|| OemToAnsi(STR0035) + " : " + cFilQbr1 + " - " + cDescrFil } )
		oTxtSubtotal:Cell("QUANTIDADE"):SetBlock( { || OemToAnsi(STR0041) + ": " + cValtoChar(nQtdFil) } )
		oTxtSubtotal:Init()
		oTxtSubtotal:PrintLine()
		nQtdFil := 0
		
		If Len(aFilFiscal) > 0
			oTxtFiscal:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0037) } )//"TOTAL FISCAL "
			oTxtFiscal:Init()
			oTxtFiscal:PrintLine()
			
			oSubTotal:Init()
			For nX := 1 To Len(aFilFiscal)
				cMoeda	:= aFilFiscal[nX][1]
				cSuf 	:= CValtoChar(Val( cMoeda ))
				
				oSubTotal:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
				oSubTotal:Cell("N3_VORIG1"):SetBlock( 	{ || aFilFiscal[nX][2] } )
				oSubTotal:Cell("N3_AMPLIA1"):SetBlock( 	{ || aFilFiscal[nX][3] } )
				oSubTotal:Cell("VLATUALIZADO"):SetBlock({ || aFilFiscal[nX][4] } )
				oSubTotal:Cell("N3_VRDACM1"):SetBlock( 	{ || aFilFiscal[nX][5] } )
				oSubTotal:Cell("VLRESIDUAL"):SetBlock( 	{ || aFilFiscal[nX][6] } )
				oSubTotal:Cell("N3_VRCDA1"):SetBlock( 	{ || aFilFiscal[nX][7] } )
				oSubTotal:Cell("N3_VRCACM1"):SetBlock( 	{ || aFilFiscal[nX][8] } )
				
				oSubTotal:PrintLine()
			Next
			oSubTotal:Finish()
			aFilFiscal := {}
		EndIf
		
		If Len(aFilGerencial) > 0
			oTxtGerencial:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0038) } )//"TOTAL GERENCIAL "
			oTxtGerencial:Init()
			oTxtGerencial:PrintLine()
			
			oSubTotal:Init()
			For nX := 1 To Len(aFilGerencial)
				cMoeda	:= aFilGerencial[nX][1]
				cSuf 	:= CValtoChar(Val( cMoeda ))
				
				oSubTotal:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
				oSubTotal:Cell("N3_VORIG1"):SetBlock( 	{ || aFilGerencial[nX][2] } )
				oSubTotal:Cell("N3_AMPLIA1"):SetBlock( 	{ || aFilGerencial[nX][3] } )
				oSubTotal:Cell("VLATUALIZADO"):SetBlock({ || aFilGerencial[nX][4] } )
				oSubTotal:Cell("N3_VRDACM1"):SetBlock( 	{ || aFilGerencial[nX][5] } )
				oSubTotal:Cell("VLRESIDUAL"):SetBlock( 	{ || aFilGerencial[nX][6] } )
				oSubTotal:Cell("N3_VRCDA1"):SetBlock( 	{ || aFilGerencial[nX][7] } )
				oSubTotal:Cell("N3_VRCACM1"):SetBlock( 	{ || aFilGerencial[nX][8] } )
				
				oSubTotal:PrintLine()
				
			Next
			oSubTotal:Finish()
			aFilGerencial := {}
		EndIf
		
		If Len(aFilIncentivada) > 0
			oTxtIncentivada:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0039) } )//"TOTAL INCENTIVADA "
			oTxtIncentivada:Init()
			oTxtIncentivada:PrintLine()
			
			oSubTotal:Init()
			For nX := 1 To Len(aFilIncentivada)
				cMoeda	:= aFilIncentivada[nX][1]
				cSuf 	:= CValtoChar(Val( cMoeda ))
				
				oSubTotal:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
				oSubTotal:Cell("N3_VORIG1"):SetBlock( 	{ || aFilIncentivada[nX][2] } )
				oSubTotal:Cell("N3_AMPLIA1"):SetBlock( 	{ || aFilIncentivada[nX][3] } )
				oSubTotal:Cell("VLATUALIZADO"):SetBlock({ || aFilIncentivada[nX][4] } )
				oSubTotal:Cell("N3_VRDACM1"):SetBlock( 	{ || aFilIncentivada[nX][5] } )
				oSubTotal:Cell("VLRESIDUAL"):SetBlock( 	{ || aFilIncentivada[nX][6] } )
				oSubTotal:Cell("N3_VRCDA1"):SetBlock( 	{ || aFilIncentivada[nX][7] } )
				oSubTotal:Cell("N3_VRCACM1"):SetBlock( 	{ || aFilIncentivada[nX][8] } )
				
				oSubTotal:PrintLine()
			Next
			oSubTotal:Finish()
			aFilIncentivada := {}
		EndIf
		
		oTxtSubtotal:Finish()
		oReport:SkipLine()
		oReport:ThinLine()
	EndIF
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a impressao da totalizacao na quebra do segundo nivel        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aGerFiscal) > 0 .Or. Len(aGerGerencial) > 0  .Or. Len(aGerIncentivada) > 0
	oTxtTotGer:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0040) } ) // "* * *   T O T A L   G E R A L   * * *"
	oTxtTotGer:Cell("QUANTIDADE"):SetBlock( { || OemToAnsi(STR0041) + ": " + cValToChar(nTotal) } ) // "QUANTIDADE"
	
	oTxtTotGer:Init()
	oTxtTotGer:PrintLine()
	
	If Len(aGerFiscal) > 0
		oTxtFiscal:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0037) } )//"TOTAL FISCAL "
		oTxtFiscal:Init()
		oTxtFiscal:PrintLine()
		
		oTotalGeral:Init()
		For nX := 1 To Len(aGerFiscal)
			cMoeda	:= aGerFiscal[nX][1]
			cSuf 	:= CValtoChar(Val( cMoeda ))
			
			oTotalGeral:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
			oTotalGeral:Cell("N3_VORIG1"):SetBlock( 	{ || aGerFiscal[nX][2] } )
			oTotalGeral:Cell("N3_AMPLIA1"):SetBlock( 	{ || aGerFiscal[nX][3] } )
			oTotalGeral:Cell("VLATUALIZADO"):SetBlock(	{ || aGerFiscal[nX][4] } )
			oTotalGeral:Cell("N3_VRDACM1"):SetBlock( 	{ || aGerFiscal[nX][5] } )
			oTotalGeral:Cell("VLRESIDUAL"):SetBlock( 	{ || aGerFiscal[nX][6] } )
			oTotalGeral:Cell("N3_VRCDA1"):SetBlock( 	{ || aGerFiscal[nX][7] } )
			oTotalGeral:Cell("N3_VRCACM1"):SetBlock( 	{ || aGerFiscal[nX][8] } )
			
			oTotalGeral:PrintLine()
		Next
		oTotalGeral:Finish()
	EndIf
	
	If Len(aGerGerencial) > 0
		oTxtGerencial:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0038) } )//"TOTAL GERENCIAL "
		oTxtGerencial:Init()
		oTxtGerencial:PrintLine()
		
		oTotalGeral:Init()
		For nX := 1 To Len(aGerGerencial)
			cMoeda	:= aGerGerencial[nX][1]
			cSuf 	:= CValtoChar(Val( cMoeda ))
			
			oTotalGeral:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
			oTotalGeral:Cell("N3_VORIG1"):SetBlock( 	{ || aGerGerencial[nX][2] } )
			oTotalGeral:Cell("N3_AMPLIA1"):SetBlock( 	{ || aGerGerencial[nX][3] } )
			oTotalGeral:Cell("VLATUALIZADO"):SetBlock({ || aGerGerencial[nX][4] } )
			oTotalGeral:Cell("N3_VRDACM1"):SetBlock( 	{ || aGerGerencial[nX][5] } )
			oTotalGeral:Cell("VLRESIDUAL"):SetBlock( 	{ || aGerGerencial[nX][6] } )
			oTotalGeral:Cell("N3_VRCDA1"):SetBlock( 	{ || aGerGerencial[nX][7] } )
			oTotalGeral:Cell("N3_VRCACM1"):SetBlock( 	{ || aGerGerencial[nX][8] } )
			
			oTotalGeral:PrintLine()
		Next
		oTotalGeral:Finish()
	EndIf
	
	If Len(aGerIncentivada) > 0
		oTxtIncentivada:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0039) } )//"TOTAL INCENTIVADA "
		oTxtIncentivada:Init()
		oTxtIncentivada:PrintLine()
		
		oTotalGeral:Init()
		For nX := 1 To Len(aGerIncentivada)
			cMoeda	:= aGerIncentivada[nX][1]
			cSuf 	:= CValtoChar(Val( cMoeda ))
			
			oTotalGeral:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
			oTotalGeral:Cell("N3_VORIG1"):SetBlock( 	{ || aGerIncentivada[nX][2] } )
			oTotalGeral:Cell("N3_AMPLIA1"):SetBlock( 	{ || aGerIncentivada[nX][3] } )
			oTotalGeral:Cell("VLATUALIZADO"):SetBlock({ || aGerIncentivada[nX][4] } )
			oTotalGeral:Cell("N3_VRDACM1"):SetBlock( 	{ || aGerIncentivada[nX][5] } )
			oTotalGeral:Cell("VLRESIDUAL"):SetBlock( 	{ || aGerIncentivada[nX][6] } )
			oTotalGeral:Cell("N3_VRCDA1"):SetBlock( 	{ || aGerIncentivada[nX][7] } )
			oTotalGeral:Cell("N3_VRCACM1"):SetBlock( 	{ || aGerIncentivada[nX][8] } )
			
			oTotalGeral:PrintLine()
			
		Next
		oTotalGeral:Finish()
		oTxtTotGer:Finish()
	EndIf
EndIf

(cAliasQry)->(dbCloseArea())
MSErase(cAliasQry)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrtAnaliticoºAutor  ³Alvaro Camillo Neto º Data ³  23/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao do relatorio Analitico                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFR072                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrtAnalitico( oReport )
Local oSecEntCtb	 := oReport:Section(1)
Local oSecBem		 := oReport:Section(1):Section(1)
Local oSecValores	 := oReport:Section(1):Section(2)
Local oTxtSubtotal 	 := oReport:Section(1):Section(3)
Local oSubtotal 	 := oReport:Section(1):Section(4)
Local oTxtTotGer	 := oReport:Section(2)
Local oTotalGeral	 := oReport:Section(3)
Local oTxtFiscal	 := oReport:Section(4)
Local oTxtGerencial	 := oReport:Section(5)
Local oTxtIncentivada:= oReport:Section(6)

Local oMeter
Local oText
Local oDlg
Local lEnd
Local cAliasQry 	:= GetNextAlias()
Local dDataSLD  	:= MV_PAR01
Local dAquIni		:= MV_PAR04
Local dAquFim   	:= MV_PAR05
Local cBemIni   	:= MV_PAR06
Local cBemFim   	:= MV_PAR08
Local cItemIni  	:= MV_PAR07
Local cItemFim  	:= MV_PAR09
Local cContaIni 	:= MV_PAR12
Local cContaFim 	:= MV_PAR13
Local cCCIni   		:= MV_PAR14
Local cCCFim   		:= MV_PAR15
Local cItCtbIni		:= MV_PAR16
Local cItCtbFim		:= MV_PAR17
Local cClvlIni		:= MV_PAR18
Local cClVlFim		:= MV_PAR19
Local cGrupoIni		:= MV_PAR10
Local cGrupoFim		:= MV_PAR11
Local n_pagini 		:= MV_PAR21
Local n_pagFim		:= MV_PAR22
Local n_pagRes		:= MV_PAR23
Local nTipoTotal	:= MV_PAR24
Local cTipoSLD		:= MV_PAR25
Local cChave		:= ""
Local cCond			:= ""
Local nCount		:= 0
Local aTotGeral 	:= {}
Local aTQuebra1 	:= {}
Local aTFilial		:= {}
Local nX			:= 0
Local nTotal 	 	:= 0
Local nQuantidade 	:= 0
Local nQtdFil	 	:= 0
Local cCabCond1 	:= ""
Local nTipoEnt		:= oSecEntCtb:GetOrder() 
Local aTipo			:= {}                     
Local cChaveBem		:= ""
Local cTipoFiscal	:= ATFXTpBem(1)
Local cTipoGerenc	:= ATFXTpBem(2)
Local cTipoIncent	:= ATFXTpBem(3) 
Local cDescSld		:= ""

aSelMoed := IIF(Empty(aSelMoed), {"01"} , aSelMoed )

If nTipoTotal == 1 //Fiscal
	aTipo := ATFXTpBem(1,.T.)
ElseIf nTipoTotal == 2 //Gerencial
	aTipo := ATFXTpBem(2,.T.)
ElseIf nTipoTotal == 3 //Incentivada
	aTipo := ATFXTpBem(3,.T.)
EndIf


// Desabilita todas as celulas de secao 1
oSecEntCtb:Cell("CT1_CONTA"):Disable()
oSecEntCtb:Cell("CT1_DESC01"):Disable()
oSecEntCtb:Cell("CTT_CUSTO"):Disable()
oSecEntCtb:Cell("CTT_DESC01"):Disable()
oSecEntCtb:Cell("CTD_ITEM"):Disable()
oSecEntCtb:Cell("CTD_DESC01"):Disable()
oSecEntCtb:Cell("CTH_CLVL"):Disable()
oSecEntCtb:Cell("CTH_DESC01"):Disable()

oSecValores:Cell("SIMBMOEDA"):SetTitle("")
oSubTotal:Cell("SIMBMOEDA"):SetTitle("")
oTotalGeral:Cell("SIMBMOEDA"):SetTitle("")

//Ordem do Arquivo
IF nTipoEnt == 1
	cChave := "FILIAL+CONTA+CCUSTO+CBASE+ITEM+TIPO+SEQ+SEQREAV+MOEDA"
	cCabCond1 := OemToAnsi("Conta   : ") //"Conta   : "
ElseIf nTipoEnt == 2
	cChave := "FILIAL+CCUSTO+CONTA+CBASE+ITEM+TIPO+SEQ+SEQREAV+MOEDA"
	cCabCond1 := OemToAnsi("C.Custo : ") //"C.Custo : "
ElseIf nTipoEnt == 3
	cChave := "FILIAL+SUBCTA+CCUSTO+CONTA+CBASE+ITEM+TIPO+SEQ+SEQREAV+MOEDA"
	cCabCond1 := OemToAnsi("It.Ctb. : ") //"It.Ctb. : "
ElseIf nTipoEnt == 4
	cChave := "FILIAL+CLVL+SUBCTA+CCUSTO+CONTA+CBASE+ITEM+TIPO+SEQ+SEQREAV+MOEDA"
	cCabCond1 := OemToAnsi("It.Ctb. : ") //"It.Ctb. : "
End

//Controle de reincio da numeracao de paginas
oReport:SetPageNumber(n_pagini)
oReport:OnPageBreak( {|| If((n_pagini+1) > n_pagFim, (n_pagini := n_pagRes,oReport:SetPageNumber(n_pagini-1)),n_pagini += 1) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
ATFGERSLDM(oMeter,oText,oDlg,lEnd,cAliasQry,dAquIni,dAquFim,dDataSLD,cBemIni,cBemFim,cItemIni,cItemFim,cContaIni,cContaFim,;
cCCIni,cCCFim,cItCtbIni,cItCtbFim,cClvlIni,cClVlFim,cGrupoIni,cGrupoFim,aSelMoed,aSelFil,lTodasFil,cChave,.T.,aTipo,Nil,Nil,cTipoSLD,aSelClass) },;
OemToAnsi(OemToAnsi(STR0034)),; //"Criando Arquivo Temporário..."
OemToAnsi(STR0035))//"Posicao Valorizada dos Bens na Data"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
//³Estrutura do Arquivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
/*
FILIAL CBASE ITEM MOEDA	CLASSIF TIPO DESC_SINT AQUISIC DTBAIXA DTSALDO CHAPA GRUPO CONTA CCUSTO SUBCTA CLVL QUANTD ORIGINAL AMPLIACAO ATUALIZ DEPRECACM
RESIDUAL CORRECACM CORDEPACM VLBAIXAS
*/

//Descrição do tipo de saldo
SX5->(MsSeek(xFilial("SX5") + "SL"+ IIF(Empty(cTipoSLD),'1',cTipoSLD) ))
cDescSld := Alltrim(SX5->(X5Descri()))

// Orderna de acordo com a Ordem do relatorio
(cAliasQry)->(dbGoTop())
While (cAliasQry)->(!EOF()) .And. !oReport:Cancel()
	
	nQuantidade := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controla a quebra no 1o. nivel                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilQbr1 := (cAliasQry)->FILIAL
	IF nTipoEnt == 1
		cEntQbr1 := (cAliasQry)->CONTA
		cQuebra1 :=  cFilQbr1 + cEntQbr1
		cCond1   := cAliasQry + "->( FILIAL + CONTA ) == cQuebra1"
	ElseIf nTipoEnt == 2
		cEntQbr1 := (cAliasQry)->CCUSTO
		cQuebra1 :=  cFilQbr1 + cEntQbr1
		cCond1   := cAliasQry + "->( FILIAL + CCUSTO ) == cQuebra1"
	ElseIf nTipoEnt == 3
		cEntQbr1 := (cAliasQry)->SUBCTA
		cQuebra1 :=  cFilQbr1 + cEntQbr1
		cCond1   := cAliasQry + "->( FILIAL + SUBCTA ) == cQuebra1"
	ElseIf nTipoEnt == 4
		cEntQbr1 := (cAliasQry)->CLVL
		cQuebra1 :=  cFilQbr1 + cEntQbr1
		cCond1   := cAliasQry + "->( FILIAL + CLVL ) == cQuebra1"
	EndIf
	
	dbSelectArea(cAliasQry)
	
	IF Empty(cEntQbr1)
		(cAliasQry)->(dbSkip())
		Loop
	EndIf
	
	lDescricao := .F.
	aTQuebra1 := {}
	
	While (cAliasQry)->(!Eof()) .AND. &cCond1 .And. !oReport:Cancel()
		
		If !lDescricao
			AFR072Cab(nTipoEnt,cFilQbr1,cEntQbr1, oReport)
			lDescricao := .T.
		EndIf
		
		If AllTrim(cChaveBem) != AllTrim((cAliasQry)->FILIAL + (cAliasQry)->CBASE + (cAliasQry)->ITEM)  
			cChaveBem := (cAliasQry)->FILIAL + (cAliasQry)->CBASE + (cAliasQry)->ITEM   
			nQuantidade += (cAliasQry)->QUANTD  
			nQtdFil+= (cAliasQry)->QUANTD   
		EndIf

		
		oSecBem:Init()
		oSecBem:Cell("N3_FILIAL"):SetBlock({|| (cAliasQry)->FILIAL } )
		oSecBem:Cell("N3_CBASE"):SetBlock({|| (cAliasQry)->CBASE } )
		oSecBem:Cell("N3_ITEM"):SetBlock({|| (cAliasQry)->ITEM } )
		oSecBem:Cell("N3_TIPO"):SetBlock({|| (cAliasQry)->TIPO  } )
		SX5->(MsSeek(xFilial("SX5") + "G1"+ (cAliasQry)->TIPO ))
		oSecBem:Cell("N3_TIPODESC"):SetValue( X5Descri() )
		//Incluido tipo de depreciacao para relatorio analitico 
		//Incluido por Jair Ribeiro em 29/04/11
		oSecBem:Cell("N3_TPDEPR"):SetValue( GetAdvFVal("SN0","N0_DESC01",xFilial("SN0")+"04"+GetAdvFVal("SN3","N3_TPDEPR",(cAliasQry)->(FILIAL+CBASE+ITEM+TIPO+FLAGBAIXA+SEQ))) ) 
		oSecBem:Cell("N1_PATRIM"):SetBlock({|| X3COMBO('N1_PATRIM',(cAliasQry)->CLASSIF)   } )
		oSecBem:Cell("N1_DESCRIC"):SetBlock({|| (cAliasQry)->DESC_SINT } )
		oSecBem:Cell("N1_AQUISIC"):SetBlock({|| (cAliasQry)->AQUISIC } )
		oSecBem:Cell("N1_BAIXA"):SetBlock({|| (cAliasQry)->DTBAIXA } )
		oSecBem:Cell("N1_QUANTD"):SetBlock({|| (cAliasQry)->QUANTD } )
		oSecBem:Cell("N1_CHAPA"):SetBlock({|| (cAliasQry)->CHAPA } )  
		oSecBem:Cell("N3_TPSALDO"):SetBlock({|| cDescSld  } )		
		oSecBem:Cell("N3_CCONTAB"):SetBlock({|| (cAliasQry)->CONTA } )
		oSecBem:Cell("N3_CUSTBEM"):SetBlock({|| (cAliasQry)->CCUSTO } )
		oSecBem:Cell("N3_SUBCCON"):SetBlock({|| (cAliasQry)->SUBCTA } )
		oSecBem:Cell("N3_CLVLCON"):SetBlock({|| (cAliasQry)->CLVL } )
		oSecBem:PrintLine()
		oSecBem:Finish()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controla a quebra no 2o. nivel                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		IF nTipoEnt == 1
			cQuebra2 :=  (cAliasQry)->( FILIAL+CONTA+CCUSTO+CBASE+ITEM+TIPO+SEQ+SEQREAV )
			cCond2   := cAliasQry + "->( FILIAL+CONTA+CCUSTO+CBASE+ITEM+TIPO+SEQ+SEQREAV ) == cQuebra2"
		ElseIf nTipoEnt == 2
			cQuebra2 :=  (cAliasQry)->( FILIAL+CCUSTO+CONTA+CBASE+ITEM+TIPO+SEQ+SEQREAV )
			cCond2   := cAliasQry + "->( FILIAL+CCUSTO+CONTA+CBASE+ITEM+TIPO+SEQ+SEQREAV ) == cQuebra2"
		ElseIf nTipoEnt == 3
			cQuebra2 :=  (cAliasQry)->( FILIAL+SUBCTA+CCUSTO+CONTA+CBASE+ITEM+TIPO+SEQ+SEQREAV )
			cCond2   := cAliasQry + "->( FILIAL+SUBCTA+CCUSTO+CONTA+CBASE+ITEM+TIPO+SEQ+SEQREAV ) == cQuebra2"
		ElseIf nTipoEnt == 4
			cQuebra2 := (cAliasQry)->( FILIAL+CLVL+SUBCTA+CCUSTO+CONTA+CBASE+ITEM+TIPO+SEQ+SEQREAV )
			cCond2   := cAliasQry + "->( FILIAL+CLVL+SUBCTA+CCUSTO+CONTA+CBASE+ITEM+TIPO+SEQ+SEQREAV ) == cQuebra2"
		EndIf
		oSecValores:Init()
		While (cAliasQry)->(!Eof()) .AND. &cCond2 .And. !oReport:Cancel()
			cSuf := CValtoChar(Val((cAliasQry)->MOEDA))
			oSecValores:Cell("SIMBMOEDA"):SetBlock( { || SuperGetMV("MV_SIMB"+cSuf) } )
			oSecValores:Cell("N3_VORIG1"):SetBlock( { || (cAliasQry)->ORIGINAL } )
			oSecValores:Cell("N3_AMPLIA1"):SetBlock( { || (cAliasQry)->AMPLIACAO } )
			oSecValores:Cell("VLATUALIZADO"):SetBlock( { || (cAliasQry)->ATUALIZ } )
			oSecValores:Cell("N3_VRDACM1"):SetBlock( { || (cAliasQry)->DEPRECACM } )
			oSecValores:Cell("VLRESIDUAL"):SetBlock( { || (cAliasQry)->RESIDUAL } )
			oSecValores:Cell("N3_VRCDA1"):SetBlock( { || (cAliasQry)->CORDEPACM } )
			oSecValores:Cell("N3_VRCACM1"):SetBlock( { || (cAliasQry)->CORRECACM } )
			oSecValores:PrintLine()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$¿
			//³Soma os totais da quebra³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$Ù
			nPos := aScan(aTQuebra1,{ |x| Alltrim(x[1]) == Alltrim((cAliasQry)->MOEDA)})
			If nPos == 0
				AAdd(aTQuebra1, { "", 0, 0, 0, 0, 0, 0, 0, 0 } )
				nPos := Len(aTQuebra1)
				aTQuebra1[nPos][1] := (cAliasQry)->MOEDA
			EndIf
			aTQuebra1[nPos][2] += (cAliasQry)->ORIGINAL
			aTQuebra1[nPos][3] += (cAliasQry)->AMPLIACAO
			aTQuebra1[nPos][4] += (cAliasQry)->ATUALIZ
			aTQuebra1[nPos][5] += (cAliasQry)->DEPRECACM
			aTQuebra1[nPos][6] += (cAliasQry)->RESIDUAL
			aTQuebra1[nPos][7] += (cAliasQry)->CORDEPACM
			aTQuebra1[nPos][8] += (cAliasQry)->CORRECACM
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$¿
			//³Soma os totais da quebra³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$Ù
			nPos := aScan(aTFilial,{ |x| Alltrim(x[1]) == Alltrim((cAliasQry)->MOEDA)})
			If nPos == 0
				AAdd(aTFilial, { "", 0, 0, 0, 0, 0, 0, 0, 0 } )
				nPos := Len(aTFilial)
				aTFilial[nPos][1] := (cAliasQry)->MOEDA
			EndIf
			aTFilial[nPos][2] += (cAliasQry)->ORIGINAL
			aTFilial[nPos][3] += (cAliasQry)->AMPLIACAO
			aTFilial[nPos][4] += (cAliasQry)->ATUALIZ
			aTFilial[nPos][5] += (cAliasQry)->DEPRECACM
			aTFilial[nPos][6] += (cAliasQry)->RESIDUAL
			aTFilial[nPos][7] += (cAliasQry)->CORDEPACM
			aTFilial[nPos][8] += (cAliasQry)->CORRECACM
			
			(cAliasQry)->(dbSkip())
		EndDo
		oSecValores:Finish()
	EndDo
	
	cDescr 	:= AFR072Desc( nTipoEnt, cFilQbr1 , cEntQbr1 )
	cDescrFil:= GetAdvFval("SM0","M0_FILIAL",cEmpAnt + cFilQbr1 )
	oTxtSubtotal:Cell("FILIAL"):SetBlock({|| OemToAnsi(STR0035) + " : " + cFilQbr1 + " - " + cDescrFil } )
	oTxtSubtotal:Cell("ENTIDADE"):SetBlock( { || OemToAnsi(STR0036) + cCabCond1 + cDescr } )
	oTxtSubtotal:Cell("QUANTIDADE"):SetBlock( { || OemToAnsi(STR0041) + ": " + cValToChar(nQuantidade) } )
	
	oTxtSubtotal:Init()
	oTxtSubtotal:PrintLine()
	
	nTotal += nQuantidade
	nQuantidade := 0
	
	dbSelectArea("CT1")
	dbSeek(xFilial("CT1",cFilQbr1)+cEntQbr1)
	
	oSubTotal:Init()
	For nX := 1 To Len(aTQuebra1)
		
		cMoeda	:= aTQuebra1[nX][1]
		cSuf 	:= CValtoChar(Val( cMoeda ))
		
		oSubTotal:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
		oSubTotal:Cell("N3_VORIG1"):SetBlock( 	{ || aTQuebra1[nX][2] } )
		oSubTotal:Cell("N3_AMPLIA1"):SetBlock( 	{ || aTQuebra1[nX][3] } )
		oSubTotal:Cell("VLATUALIZADO"):SetBlock({ || aTQuebra1[nX][4] } )
		oSubTotal:Cell("N3_VRDACM1"):SetBlock( 	{ || aTQuebra1[nX][5] } )
		oSubTotal:Cell("VLRESIDUAL"):SetBlock( 	{ || aTQuebra1[nX][6] } )
		oSubTotal:Cell("N3_VRCDA1"):SetBlock( 	{ || aTQuebra1[nX][7] } )
		oSubTotal:Cell("N3_VRCACM1"):SetBlock( 	{ || aTQuebra1[nX][8] } )
		
		oSubTotal:PrintLine()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Soma os totais do relatório³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := aScan(aTotGeral,{ |x| Alltrim(x[1]) == Alltrim(cMoeda) } )
		If nPos == 0
			AAdd(aTotGeral, { "", 0, 0, 0, 0, 0, 0, 0 } )
			nPos := Len(aTotGeral)
			aTotGeral[nPos][1] := cMoeda
		EndIf
		aTotGeral[nPos][2] += aTQuebra1[nX][2]
		aTotGeral[nPos][3] += aTQuebra1[nX][3]
		aTotGeral[nPos][4] += aTQuebra1[nX][4]
		aTotGeral[nPos][5] += aTQuebra1[nX][5]
		aTotGeral[nPos][6] += aTQuebra1[nX][6]
		aTotGeral[nPos][7] += aTQuebra1[nX][7]
		aTotGeral[nPos][8] += aTQuebra1[nX][8]
	Next
	oSubTotal:Finish()
	oTxtSubtotal:Finish()
	oReport:SkipLine()
	oReport:ThinLine()
	lDescricao := .F.
	If Len(aTFilial) > 0 .And. cFilQbr1  != (cAliasQry)->FILIAL
		oTxtTotGer:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0042) } ) //"* * *   T O T A L   F I L I A L   * * *"
		oTxtTotGer:Init()
		oTxtTotGer:PrintLine()
		
		oTxtSubtotal:Cell("FILIAL"):SetBlock({|| OemToAnsi(STR0035) + " : " + cFilQbr1 + " - " + cDescrFil } )
		oTxtSubtotal:Cell("QUANTIDADE"):SetBlock( { || OemToAnsi(STR0041) + ": " + cValToChar(nQtdFil) } )//"QUANTIDADE"
		oTxtSubtotal:Init()
		oTxtSubtotal:PrintLine()
		
		oSubTotal:Init()
		For nX := 1 To Len(aTFilial)
			
			cMoeda	:= aTFilial[nX][1]
			cSuf 	:= CValtoChar(Val( cMoeda ))
			
			oSubTotal:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
			oSubTotal:Cell("N3_VORIG1"):SetBlock( 	{ || aTFilial[nX][2] } )
			oSubTotal:Cell("N3_AMPLIA1"):SetBlock( 	{ || aTFilial[nX][3] } )
			oSubTotal:Cell("VLATUALIZADO"):SetBlock({ || aTFilial[nX][4] } )
			oSubTotal:Cell("N3_VRDACM1"):SetBlock( 	{ || aTFilial[nX][5] } )
			oSubTotal:Cell("VLRESIDUAL"):SetBlock( 	{ || aTFilial[nX][6] } )
			oSubTotal:Cell("N3_VRCDA1"):SetBlock( 	{ || aTFilial[nX][7] } )
			oSubTotal:Cell("N3_VRCACM1"):SetBlock( 	{ || aTFilial[nX][8] } )
			
			oSubTotal:PrintLine()
		Next
		
		aTFilial := {}
		nQtdFil := 0
		oSubTotal:Finish()
		oTxtSubtotal:Finish()
		oTotalGeral:Finish()
		oReport:SkipLine()
		oReport:ThinLine()
	EndIF
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a impressao da totalizacao na quebra do segundo nivel        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len( aTotGeral ) > 0
	
	oTxtTotGer:Cell("TEXTO"):SetBlock( { || OemToAnsi(STR0040) } ) // "* * *   T O T A L   G E R A L   * * *"
	oTxtTotGer:Cell("QUANTIDADE"):SetBlock( { || OemToAnsi(STR0041) + ": " + cValToChar(nTotal) } ) // "QUANTIDADE"
	
	oTxtTotGer:Init()
	oTxtTotGer:PrintLine()
	
	oTotalGeral:Init()
	
	
	For nX := 1 To Len(aTotGeral)
		cMoeda	:= aTotGeral[nX][1]
		cSuf 	:= CValtoChar(Val( cMoeda ))
		oTotalGeral:Cell("SIMBMOEDA"):SetBlock( 	{ || SuperGetMV("MV_SIMB"+cSuf) } )
		oTotalGeral:Cell("N3_VORIG1"):SetBlock( 	{ || aTotGeral[nX][2] } )
		oTotalGeral:Cell("N3_AMPLIA1"):SetBlock( 	{ || aTotGeral[nX][3] } )
		oTotalGeral:Cell("VLATUALIZADO"):SetBlock({ || aTotGeral[nX][4] } )
		oTotalGeral:Cell("N3_VRDACM1"):SetBlock( 	{ || aTotGeral[nX][5] } )
		oTotalGeral:Cell("VLRESIDUAL"):SetBlock( 	{ || aTotGeral[nX][6] } )
		oTotalGeral:Cell("N3_VRCDA1"):SetBlock( 	{ || aTotGeral[nX][7] } )
		oTotalGeral:Cell("N3_VRCACM1"):SetBlock( 	{ || aTotGeral[nX][8] } )
		oTotalGeral:PrintLine()
	Next
	
	oTotalGeral:Finish()
	oTxtTotGer:Finish()
EndIf
(cAliasQry)->(dbCloseArea())
MSErase(cAliasQry)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TotalCtb  ºAutor  ³Alvaro Camillo Neto º Data ³  28/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina que totaliza as informações pela entidade contabil  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFR072                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TotalCtb(cAlias,cFilx,nTipoEnt,cEntidade,cTipoIn)
Local aValores 	:= {}
Local cQuery	:= ""
Local cAliasTRB := "TRBCTB"
Local cCPOEnt	:= ""

Default cTipoIn := ""


If nTipoEnt == 1 //Conta
	cCPOEnt := "CONTA"
ElseIf nTipoEnt == 2 //Centro de Custo
	cCPOEnt := "CCUSTO"
ElseIf nTipoEnt == 3 //Item Contabil
	cCPOEnt := "SUBCTA"
ElseIf nTipoEnt == 4 //Classe de Valor
	cCPOEnt := "CLVL"
EndIf

cQuery	+= " SELECT "
cQuery	+= cCPOEnt 	+",  "
cQuery	+= " 	MOEDA,  "
cQuery	+= " 	SUM(ORIGINAL) ORIGINAL , "
cQuery	+= " 	SUM(AMPLIACAO) AMPLIACAO , "
cQuery	+= " 	SUM(ATUALIZ) ATUALIZ ,  "
cQuery	+= " 	SUM(DEPRECACM) DEPRECACM , "
cQuery	+= " 	SUM(RESIDUAL) RESIDUAL , "
cQuery	+= " 	SUM(CORRECACM) CORRECACM , "
cQuery	+= " 	SUM(CORDEPACM) CORDEPACM , "
cQuery	+= " 	SUM(VLBAIXAS) VLBAIXAS  "
cQuery	+= " FROM  " +  cAlias
cQuery	+= " WHERE "

cQuery	+= " 	FILIAL = '" + cFilx + "'"
cQuery	+= " 	AND " +cCPOEnt+ " = '" + cEntidade + "' "

If !Empty(cTipoIn)
	cQuery	+= " 	AND TIPO IN " + FormatIn(cTipoIn,"/")
EndIf

cQuery	+= " GROUP BY  "
cQuery	+= cCPOEnt + " , "
cQuery	+= " MOEDA  "

cQuery := ChangeQuery(cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasTRB , .T. , .F.)

While (cAliasTRB)->(!EOF())
	AAdd(aValores, { "", 0, 0, 0, 0, 0, 0, 0 } )
	nPos := Len(aValores)
	aValores[nPos][1] := (cAliasTRB)->MOEDA
	aValores[nPos][2] += (cAliasTRB)->ORIGINAL
	aValores[nPos][3] += (cAliasTRB)->AMPLIACAO
	aValores[nPos][4] += (cAliasTRB)->ATUALIZ
	aValores[nPos][5] += (cAliasTRB)->DEPRECACM
	aValores[nPos][6] += (cAliasTRB)->RESIDUAL
	aValores[nPos][7] += (cAliasTRB)->CORRECACM
	aValores[nPos][8] += (cAliasTRB)->CORDEPACM
	(cAliasTRB)->(dbSKip())
EndDo

(cAliasTRB)->(dbCloseArea())
Return aValores

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AFR070Cab  ³ Autor ³ Cesar C S Prado       ³ Data ³ 09.08.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao do cabecalho do relatorio (Nivel 1 de quebra)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ AFR070Cab(cPar01,nPar01,@nPar02)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cPar01 - Cabecalho a ser impresso                            ³±±
±±³          ³ nPar01 - Ordem da impressao do relatorio (1-Conta/2-C.Custo) ³±±
±±³          ³ nPar02 - Linha corrente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFR070                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AFR072Cab(nOrdem,cFilCab,cChave, oReport)
Local oSection1 := oReport:Section(1)
Local cCabNiv1 := ""

IF nOrdem == 1
	oSection1:Cell("CT1_CONTA"):Enable()
	oSection1:Cell("CT1_DESC01"):Enable()
	oSection1:Cell("CT1_CONTA"):SetBlock( { || MascaraCTB(cChave) } )
	dbSelectArea("CT1")
	dbSetOrder(1)
	CT1->(dbSeek(xFilial("CT1",cFilCab) + cChave))
	oSection1:Cell("CT1_DESC01"):SetBlock( { || CT1->CT1_DESC01 } )
ElseIf nOrdem == 2
	oSection1:Cell("CTT_CUSTO"):Enable()
	oSection1:Cell("CTT_DESC01"):Enable()
	oSection1:Cell("CTT_CUSTO"):SetBlock( {|| cChave })
	dbSelectAre("CTT")
	dbSetOrder(1)
	CTT->( dbSeek(xFilial("CTT",cFilCab) +cChave ) )
	oSection1:Cell("CTT_DESC01"):SetBlock( {|| CTT->CTT_DESC01 })
ElseIf nOrdem == 3
	oSection1:Cell("CTD_ITEM"):Enable()
	oSection1:Cell("CTD_DESC01"):Enable()
	oSection1:Cell("CTD_ITEM"):SetBlock( {|| cChave })
	dbSelectAre("CTD")
	dbSetOrder(1)
	CTD->( dbSeek(xFilial("CTD",cFilCab) +cChave ) )
	oSection1:Cell("CTD_ITEM"):SetBlock( {|| CTD->CTD_DESC01 })
	oSection1:Cell("CTD_ITEM"):SetBlock( {|| "" })
	
ElseIf nOrdem == 4
	oSection1:Cell("CTH_CLVL"):Enable()
	oSection1:Cell("CTH_DESC01"):Enable()
	oSection1:Cell("CTH_CLVL"):SetBlock( {|| cChave })
	dbSelectAre("CTH")
	dbSetOrder(1)
	CTH->( dbSeek(xFilial("CTH",cFilCab) +cChave ) )
	oSection1:Cell("CTD_ITEM"):SetBlock( {|| CTH->CTH_DESC01 })
	
EndIf
oSection1:Init()
oSection1:PrintLine()
oSection1:Finish()
Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AFR072Desc ³ Autor ³ Alvaro Camillo Neto   ³ Data ³ 27.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca a descricao a ser impressa para subtotal / total       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ AFR072Desc(nPar01)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ nPar01 - Ordem da impressao do relatorio (1-Conta/2-C.Custo) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFR072                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AFR072Desc(nOrdem, cFilCab ,cChave )
Local aArea  := GetArea()
Local cDescr  := ""

If nOrdem == 1
	dbSelectArea("CT1")
	IF MsSeek(xFilial("CT1",cFilCab)+cChave)
		cDescr := MascaraCTB(cChave) + " " + CT1->CT1_DESC01
	Endif
ElseIf nOrdem == 2
	dbSelectArea("CTT")
	IF MsSeek(xFilial("CTT",cFilCab)+cChave)
		cDescr := cChave + " " + CTT->CTT_DESC01
	EndIf
ElseIf  nOrdem == 3
	dbSelectArea("CTD")
	IF MsSeek(xFilial("CTD",cFilCab)+cChave)
		cDescr := cChave + " " + CTD->CTD_DESC01
	EndIf
ElseIf nOrdem == 4
	dbSelectArea("CTH")
	IF MsSeek(xFilial("CTH",cFilCab)+cChave)
		cDescr := cChave + " " + CTH->CTH_DESC01
	EndIf
EndIf

RestArea(aArea)
Return (cDescr)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaSX1 ºAutor  ³Rafael Gama         º Data ³  05/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona uma pergunta para o acrescimo de pesquisa por     º±±
±±º          ³ Filiais                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA210                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaSX1(cPerg)
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}
Local aArea	:= GetArea()
Local lExistSN0 := IIf(FindFunction("ATFEXSTPTR"),ATFEXSTPTR(),.F.) 

If SX1->(dbSeek(Pad(cPerg,Len(SX1->X1_GRUPO))+Pad("24",Len(SX1->X1_ORDEM)))) .And. Empty(SX1->X1_DEF04)
	RecLock("SX1",.F.)  
		SX1->(dbDelete())
	MsUnLock()
EndIf

aHelpPor := {"Informe a data da posição ","valorizada."}
aHelpSpa := {"Introduzca la fecha de la posición ","valorada."}
aHelpEng := {"Enter the date of valued  ","position."}
PutSX1(cPerg,"01","Data do Saldo?" , "¿Fecha de la balanza?", "Date of Balance?","mv_ch1","D",8,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Identifica o tipo do relatório,"," caso indicado sintetico serão impressos"," somente os totais divididos por código"," base, caso contrário o relatório é impresso de forma"," completa (detalhando os dados do bem)." }
aHelpSpa := {"Identifica el tipo de informe,"," si se indica sintética se imprimirá"," sólo los totales divididos por el código base,"," de lo contrario se imprime el informe en su totalidad"," (se detallan los datos también)."}
aHelpEng := {"Identifies the type of report,"," if indicated synthetic will print only"," the totals divided by the base code,"," otherwise the report is printed in full"," (detailing the data well)."}
PutSX1(cPerg,"02","Tipo?" , "¿Tipo?", "Type?","mv_ch2","N",1,0,1,"C","","","","","mv_par02","Analitico","Analítica","Analytical","","Sint Conta","Sint Conta","Synth Account","Sint Bem","Sint Bien","Synth Asset","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Indique quais moedas serão"," demonstradas no relatório "," Caso selecione 'Não' será ","demonstrada a moeda 01" }
aHelpSpa := {"Sírvanse indicar qué monedas se"," demuestra en el informe,","Si selecciona 'No' se ","mostrará la moneda 01"}
aHelpEng := {"Please indicate which currencies"," will be demonstrated in the report","If you select 'No' will be"," shown the currency 01"}
PutSX1(cPerg,"03","Seleciona Moedas?" , "¿Selecciona Monedas?", "Select Currencies?","mv_ch3","N",1,0,1,"C","","","","","mv_par03","Sim","Si","Yes","","Não","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Indique a data de aquisição","Bem Inicial" }
aHelpSpa := {"Introduzca la Fecha de Adquisicion "," Inicio"}
aHelpEng := {"Enter Initial ","Purchase Date"}
PutSX1(cPerg,"04","Da Data de aquisição ?" , "¿ De Fecha de Adquisicion ?", "From Purchase Date?","mv_ch4","D",8,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Indique a data de aquisição","Bem Final" }
aHelpSpa := {"Introduzca la Fecha de Adquisicion ","de Bien Final"}
aHelpEng := {"Enter Final ","Purchase Date "}
PutSX1(cPerg,"05","Até Data de aquisição ?" , "¿ A Fecha de Adquisicion ?", "To Purchase Date?","mv_ch5","D",8,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Indique o Código do ","Bem Inicial" }
aHelpSpa := {"Introduzca el Código de ","Buen Inicio"}
aHelpEng := {"Enter Initial ","Asset Code"}
PutSX1(cPerg,"06","Do Cod Base ?" , "¿ De Cod Base ?", "Initial Base Code?","mv_ch6","C",TamSX3("N1_CBASE")[1],0,0,"G","","SN1","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Indique o Código do ","Item do Bem Inicial" }
aHelpSpa := {"Introduzca el Código de ","Item del Bien Inicio"}
aHelpEng := {"Enter Initial ","Asset item Code"}
PutSX1(cPerg,"07","Do Item ?" , "¿ De Item ?", "Initial Base Code?","mv_ch7","C",TamSX3("N1_ITEM")[1],0,0,"G","","","","","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Indique o Código do ","Bem Final" }
aHelpSpa := {"Introduzca el Código ","de Bien Final"}
aHelpEng := {"Enter Final ","Asset Code"}
PutSX1(cPerg,"08","Até Cod Base ?" , "¿ A Cod Base ?", "Final Base Code?","mv_ch8","C",TamSX3("N1_CBASE")[1],0,0,"G","","SN1","","","mv_par08","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Indique o Código do ","Item do Bem Final" }
aHelpSpa := {"Introduzca el Código ","de Item del Bien Final"}
aHelpEng := {"Enter Final ","Asset Item Code"}
PutSX1(cPerg,"09","Até Item ?" , "¿ A Item ?", "Final Item?","mv_ch9","C",TamSX3("N1_ITEM")[1],0,0,"G","","","","","mv_par09","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Indique o Código do ","grupo Inicial" }
aHelpSpa := {"Introduzca el Código de ","grupo Inicio"}
aHelpEng := {"Enter Initial ","group Code"}
PutSX1(cPerg,"10","Do Grupo ?" , "¿ De Grupo ?", "Initial Group?","mv_cha","C",TamSX3("N1_GRUPO")[1],0,0,"G","","SNG","","","mv_par10","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Indique o Código do ","grupo Final" }
aHelpSpa := {"Introduzca el Código de ","grupo Final"}
aHelpEng := {"Enter Final ","group Code"}
PutSX1(cPerg,"11","Até Grupo ?" , "¿ A Grupo ?", "Final Group?","mv_chb","C",TamSX3("N1_GRUPO")[1],0,0,"G","","SNG","","","mv_par11","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Informe a conta inicial a ","partir da qual se deseja"," imprimir o relatório. Caso queira ","imprimir todas as contas,"," deixe esse campo em branco",". Utilize <F3> para escolher." }
aHelpSpa := {"Introduzca la cuenta inicial"," que para imprimir el informe."," Si desea imprimir todas"," las cuentas, deje este campo en blanco",". Utilice <F3> elegir."}
aHelpEng := {"Enter the initial account"," from which to print the report."," If you want to print all"," accounts, leave this ","field blank",". Use <F3> to choose."}
PutSX1(cPerg,"12","Da Conta ?" , "¿ De Cuenta ?", "From Account ?","mv_chc","C",TamSX3("CT1_CONTA")[1],0,0,"G","","CT1","","","mv_par12","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Informe a conta final até qual"," se deseja imprimir o relatório."," Caso queira imprimir todas ","as contas preencha"," com 'ZZZZZZZZZZZZZZZZZZZZ'",".Utilize <F3> para escolher." }
aHelpSpa := {"Introduzca la cuenta final por"," el cual desea imprimir el informe."," Si desea imprimir todas las cuentas completa"," con. 'ZZZZZZZZZZZZZZZZZZZZ' <F3> Se utiliza para elegir."}
aHelpEng := {"Enter the final account by"," which to print the report."," If you want to print all"," accounts complete"," with 'ZZZZZZZZZZZZZZZZZZZZ'."," <F3> Use to choose from."}
PutSX1(cPerg,"13","Até Conta ?" , "¿ A Cuenta ?", "To Account ?","mv_chd","C",TamSX3("CT1_CONTA")[1],0,0,"G","","CT1","","","mv_par13","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Informe o centro de custo inicial"," a partir do qual se deseja ","imprimir o relatório. Caso"," queira imprimir todos ","os centro de custos,"," deixe esse campo em branco."," Utilize <F3> para escolher." }
aHelpSpa := {"Entre el centro de coste inicial"," de la que desea imprimir"," el reporte. Si desea imprimir todos los centros de"," coste, deje este campo"," en blanco."," <F3> Utilícelo para elegir."}
aHelpEng := {"Enter the initial cost center"," from which to print the report."," If you want to print all"," of the cost center,"," leave this field blank."," <F3> Use to choose."}
PutSX1(cPerg,"14","Do Centro Custo ?" , "¿De Centro de Costo ?", "From Cost Center ?","mv_che","C",TamSX3("CTT_CUSTO")[1],0,0,"G","","CTT","","","mv_par14","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Informe o centro de custo final"," até o qual se deseja"," imprimir o relatório. Caso"," queira imprimir todos os"," centro de custos, preencha"," esse campo com 'ZZZZZZZZZ'",".Utilize <F3> para escolher." }
aHelpSpa := {"Entre el centro de coste final"," para el que desea imprimir"," el informe. Si desea"," imprimir todos los centros"," de coste, rellene este"," campo con. 'ZZZZZZZZZ' ","<F3> Utilícelo para elegir."}
aHelpEng := {"Enter the final cost center ","to which you want to print the"," report. If you want"," to print all of the cost"," center, fill this field"," with 'ZZZZZZZZZ'",". <F3> Use to choose."}
PutSX1(cPerg,"15","Ate Centro Custo ?" , "¿A Centro de Costo ?", "To Cost Center ?","mv_chf","C",TamSX3("CTT_CUSTO")[1],0,0,"G","","CTT","","","mv_par15","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Informe o Item Contábil inicial"," a partir do qual se deseja ","imprimir o relatório. Caso"," queira imprimir todos ","os itens,"," deixe esse campo em branco."," Utilize <F3> para escolher." }
aHelpSpa := {"Entre el Item Contable inicial"," de la que desea imprimir"," el reporte. Si desea imprimir todos los itens","  deje este campo"," en blanco."," <F3> Utilícelo para elegir."}
aHelpEng := {"Enter the initial Accounting Item  "," from which to print the report."," If you want to print all"," of the item,"," leave this field blank."," <F3> Use to choose."}
PutSX1(cPerg,"16","Do Item Contábil ?" , "¿De Item Contable ?", "From Accounting Item ?","mv_chg","C",TamSX3("CTD_ITEM")[1],0,0,"G","","CTD","","","mv_par16","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Informe o Item Contábil final"," até o qual se deseja"," imprimir o relatório. Caso"," queira imprimir todos os"," itens, preencha"," esse campo com 'ZZZZZZZZZ'",".Utilize <F3> para escolher." }
aHelpSpa := {"Entre el Item Contable  final"," para el que desea imprimir"," el informe. Si desea"," imprimir todos los itens"," , rellene este"," campo con. 'ZZZZZZZZZ' ","<F3> Utilícelo para elegir."}
aHelpEng := {"Enter the final Accounting Item ","to which you want to print the"," report. If you want"," to print all of the item"," , fill this field"," with 'ZZZZZZZZZ'",". <F3> Use to choose."}
PutSX1(cPerg,"17","Ate Item Contábil ?" , "¿A Item Contable ?", "To Accounting Item ?","mv_chh","C",TamSX3("CTD_ITEM")[1],0,0,"G","","CTD","","","mv_par17","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Informe a Classe de Valor inicial"," a partir do qual se deseja ","imprimir o relatório. Caso"," queira imprimir todos ","as classes,"," deixe esse campo em branco."," Utilize <F3> para escolher." }
aHelpSpa := {"Entre el Clase de Valor inicial"," de la que desea imprimir"," el reporte. Si desea imprimir todos las clases","  deje este campo"," en blanco."," <F3> Utilícelo para elegir."}
aHelpEng := {"Enter the initial Value Cat.Code   "," from which to print the report."," If you want to print all"," of the value cat,"," leave this field blank."," <F3> Use to choose."}
PutSX1(cPerg,"18","Da Classe de Valor ?" , "¿De Clase de Valor ?", "From Value Cat.Code ?","mv_chi","C",TamSX3("CTH_CLVL")[1],0,0,"G","","CTH","","","mv_par18","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Informe o Item Contábil final"," até o qual se deseja"," imprimir o relatório. Caso"," queira imprimir todos as"," classes, preencha"," esse campo com 'ZZZZZZZZZ'",".Utilize <F3> para escolher." }
aHelpSpa := {"Entre el Clase de Valor final"," para el que desea imprimir"," el informe. Si desea"," imprimir todos las clases"," , rellene este"," campo con. 'ZZZZZZZZZ' ","<F3> Utilícelo para elegir."}
aHelpEng := {"Enter the final Value Cat.Code  ","to which you want to print the"," report. If you want"," to print all of the value cat"," , fill this field"," with 'ZZZZZZZZZ'",". <F3> Use to choose."}
PutSX1(cPerg,"19","Ate Classe de Valor ?" , "¿A Clase de Valor ?", "To Value Cat.Code?","mv_chj","C",TamSX3("CTH_CLVL")[1],0,0,"G","","CTH","","","mv_par19","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Seleciona Filiais?"}
aHelpSpa := {"¿Selecciona Sucursal?"}
aHelpEng := {"Select Branch?"}

PutSX1(cPerg,"20","Seleciona Filiais?" , "¿Selecciona Sucursal?", "Select Branch?","mv_chk","N",1,0,2,"C","","","","","mv_par20","Sim","Si","Yes","","Não","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Informe o número com"," o qual deseja iniciar ","a numeração de ","página do relatório." }
aHelpSpa := {"Introduzca el número con"," el que iniciar la"," numeración de ","páginas del informe."}
aHelpEng := {"Enter the number with"," which to start the"," page numbering ","of the report."}
PutSX1(cPerg,"21","Folha Inicial ? " , "¿Pagina Inicial ? ", "Initial Page ?","mv_chl","N",4,0,0,"G","","","","","mv_par21","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Informe o número com"," o qual deseja finalizar ","a numeração de ","página do relatório." }
aHelpSpa := {"Introduzca el número con"," el que finalizar la"," numeración de ","páginas del informe."}
aHelpEng := {"Enter the number with"," which to finish the"," page numbering ","of the report."}
PutSX1(cPerg,"22","Folha Final ? " , "¿Pagina Final ? ", "Final Page ?","mv_chm","N",4,0,0,"G","","","","","mv_par22","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Determine qual a numeração"," a partir da qual continuará"," a impressão do Livro."," Estas três perguntas"," “Folha Inicial”, “Folha Final”"," e “Folha ao Reiniciar”"," se referem à numeração das páginas."," Quando o Livro é muito extenso,"," costuma-se dividi-lo em dois"," ou mais livros. Por isso,"," a pergunta “Folha Final” ","se refere à última ","página de um dos livros"," e a “Folha ao Reiniciar” ","se refere à primeira página"," do livro seguinte." }
aHelpSpa := {'Determinar lo que el número',' desde el que continua',' con la impresión del papel.',' Estas tres preguntas ','"¿Pagina Inicial ? ','¿Pagina Final ? " ','y "¿Nro. Pagina de Reinicio ?" ','se refieren a los números de página.',' Cuando el libro es muy extenso,',' por lo general es dividirlo en',' dos libros o más. Por lo tanto,',' la cuestión de "¿Pagina Final ?" ',' hace referencia a la',' última página de un libro y',' "¿Nro. Pagina de Reinicio ?" se',' refiere a la primera',' página del libro que viene ".'}
aHelpEng := {'Determine what the numbers',' from which to continue',' printing the paper.',' These three questions "Initial Page ?','Final Page ?"and" Page to Restart',' "refer to page numbers.',' When the book is very extensive,',' it is usually divide it into',' two or more books. ','Therefore, the question ','"Final Page ?" refers to',' the last page of a ','book and "Page to Restart"',' refers to the first',' page of the next book.'}
PutSX1(cPerg,"23","No. Pag Reiniciar ?" , "¿Nro. Pagina de Reinicio ?", "Page No.To Restart ?","mv_chn","N",4,0,0,"G","","","","","mv_par23","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Determine os totais "," a serem impressos,"," Fiscais ( Tipo de Ativo "," 01/02/03/04/05/06/07/11/13)/ "," Gerencial (Tipos de Ativo "," 10,12,17,4x,5x)",", Incentivada ou todos" }
aHelpSpa := {"Determine el total a ","ser impreso, ","Fiscal (tipo de activos"," 01/02/03/04/05/06/07/11/13)"," / de Gestión ( Tipos de Bienes ","10,12,17,4 x, 5x)",", Motivadas o todos"}
aHelpEng := {"Determine the total to ","be printed, Fiscal (Asset Type"," 01/02/03/04/05/06/07/11/13)"," / Management (Asset Type"," 10,12,17,4 x, 5x)",", Incentivada or all"}
PutSX1(cPerg,"24","Exibe Informações ?" , "¿Muestra información?", "Displays information?","mv_cho","N",1,0,4,"C","","","","","mv_par24","Fiscal","Fiscal","Fiscal","","Gerencial","De gestión","Management","Incentivadas","Incentivadas","Incentivadas","Todos","Todos","All","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")

aHelpPor := {"Informe qual o tipo ","de saldo que deverá ser"," mostrado. Utilize <F3> para ","escolher. * se deseja ","imprimir todos " }
aHelpSpa := {"Dile a qué tipo de ","saldo que se debe mostrar."," Utilice <F3> elegir. *"," Si desea imprimir todos"  }
aHelpEng := {"Tell what kind of ","balance that should be shown. ","Use <F3> to choose. *"," if you want to print all"  }
PutSX1(cPerg,"25","Tipo Saldo ?" , "¿Tipo de Saldo ?", "Tp Balance ?","mv_chp","C",1,0,1,"G","","SLD","","","mv_par25","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,"","","","","","","","")
              
//Verifica se existe a tabela auxiliar, e se existe a tabela de classificações cadastradas
If lExistSN0
	aHelpPor :=	{"Define se seleciona a classificação " ," patrimonial das fichas de imobilizado"}
	aHelpSpa :=	{"Define si selecciona la clasificacion", "patrimonial  de las fichas del fijo  "  }
	aHelpEng :=	{"Defines if it selects the asset "     , "classification from the fixed ", "asset form"}

	PutSx1( cPerg, 	"26","Selec Classif Patrimonial?  ","¿Selec Clasif Patrimonial ? ","Selects Equity Classif ?","MV_CHQ","N",1,0,2,"C","","","","S",;
					"MV_PAR26","Sim","Si","Yes","","Não","No","No",;
					"","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa,".AFR07226.")  
EndIf



RestArea(aArea)
Return
