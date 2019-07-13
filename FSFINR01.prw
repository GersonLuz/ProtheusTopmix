#include "protheus.ch"

//---------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINR01 
Rotina responsavel pelo filtro para geração dos Boletos Bancarios
         
@author	Luciano M. Pinto
@since 	23/09/2011
@version	P11 
@obs
Rotina utiliza os seguintes parâmetros:
FS_BRADES1	:	Texto 1 a ser impresso no Boleto - Bradesco
FS_BRADES2	:	Texto 2 a ser impresso no Boleto - Bradesco
FS_BRADES3	:	Texto 3 a ser impresso no Boleto - Bradesco
FS_ITAU1		:	Texto 1 a ser impresso no Boleto - Itau
FS_ITAU2		:	Texto 2 a ser impresso no Boleto - Itau
FS_ITAU3		:	Texto 3 a ser impresso no Boleto - Itau
FS_SANTAN1	:	Texto 1 a ser impresso no Boleto - Santander
FS_SANTAN2	:	Texto 2 a ser impresso no Boleto - Santander
FS_SANTAN3	:	Texto 3 a ser impresso no Boleto - Santander

/*/ 
//---------------------------------------------------------------------- 
User Function FSFINR01()
/***********************************************************************
* Chamada inicial da Função
*
*
***/
Local aPerg			:= {}
Local aRet			:= {}
Local cNomPrg		:= "FINR01"+AllTrim(xFilial())		
                                                                            
Private cLogoBco	:= "\system"                                         

Private cMarca		:= GetMark(,"SE1","E1_OK")

Private aTxtBol	:= {}
Private cQueryE1

aadd(aPerg,{1,"Filial de"			,CriaVar("SE1->E1_FILIAL")   ,"@!","" ,"SM0","",50 ,.T.}) 				// [1]
aadd(aPerg,{1,"Filial Ate"			,CriaVar("SE1->E1_FILIAL")   ,"@!","" ,"SM0","",50 ,.T.}) 				// [2]
aadd(aPerg,{1,"Banco"				,CriaVar("A6_COD")           ,"@!","" ,"SA6COD","",30 ,.T.}) 			// [3]
aadd(aPerg,{1,"Agencia:"			,CriaVar("SA6->A6_AGENCIA"),"@!","" ,"SA6AG","",30 ,.T.}) 				// [4]
aadd(aPerg,{1,"Conta Corrente:"	,CriaVar("SA6->A6_NUMCON") ,"@!","" ,"SA6CC","",50 ,.T.})				// [5]
aadd(aPerg,{2,"Reimpressão"		,"Não"	 	,{"Sim","Não"}	  	 		,50,".T.",.T. ,.T.})					// [6]
aadd(aPerg,{1,"Prefixo de:"		,CriaVar("SE1->E1_PREFIXO"),"@!","" ,"","",20 ,.F.}) 						// [7]
aadd(aPerg,{1,"Prefixo Ate:"		,CriaVar("SE1->E1_PREFIXO"),"@!","" ,"","",20 ,.T.})						// [8]
aadd(aPerg,{1,"Titulo de:"			,CriaVar("SE1->E1_NUM")		,"@!","" ,"","",50 ,.F.}) 						// [9]
aadd(aPerg,{1,"Titulo Ate:" 		,CriaVar("SE1->E1_NUM")		,"@!","" ,"","",50 ,.T.})						// [10]
aadd(aPerg,{1,"Parcela de:"		,CriaVar("SE1->E1_PARCELA"),"@!","" ,"","",20 ,.F.}) 						// [11]
aadd(aPerg,{1,"Parcela Ate:"		,CriaVar("SE1->E1_PARCELA"),"@!","" ,"","",20 ,.T.})						// [12]
aadd(aPerg,{1,"Bordero de:"		,CriaVar("SE1->E1_NUMBOR"), "@!","" ,"SE1BD","",30 ,.F.}) 				// [13]
aadd(aPerg,{1,"Bordero Ate:"		,CriaVar("SE1->E1_NUMBOR"), "@!","" ,"SE1BD","",30 ,.T.}) 				// [14]
aadd(aPerg,{1,"Cliente de:"		,CriaVar("SE1->E1_CLIENTE"),"@!","" ,"SA1","",30 ,.F.}) 					// [15]
aadd(aPerg,{1,"Cliente Ate:"		,CriaVar("SE1->E1_CLIENTE"),"@!","" ,"SA1","",30 ,.T.})					// [16]
aadd(aPerg,{1,"Loja de:"			,CriaVar("SE1->E1_LOJA")	,"@!","" ,"","",20 ,.F.}) 						// [17]
aadd(aPerg,{1,"Loja Ate:"			,CriaVar("SE1->E1_LOJA")	,"@!","" ,"","",20 ,.T.})						// [18]
aAdd(aPerg,{1,"Faturamento de:" 	,CriaVar("SE1->E1_EMISSAO"),""  ,"" ,"" ,"", 50, .T.})					// [19]
aAdd(aPerg,{1,"Faturamento ate:"	,CriaVar("SE1->E1_EMISSAO"),""  ,"" ,"" ,"", 50, .T.})					// [20]
aAdd(aPerg,{1,"Vencimento de:"	,CriaVar("SE1->E1_VENCREA"),""  ,"" ,"" ,"", 50, .T.})					// [21]
aAdd(aPerg,{1,"Vencimento ate:"	,CriaVar("SE1->E1_VENCREA"),""  ,"" ,"" ,"", 50, .T.})					// [22]

aPerg[01][03] := ParamLoad(cNomPrg,aPerg,01,aPerg[01][03])
aPerg[02][03] := ParamLoad(cNomPrg,aPerg,02,aPerg[02][03])
aPerg[03][03] := ParamLoad(cNomPrg,aPerg,03,aPerg[03][03])
aPerg[04][03] := ParamLoad(cNomPrg,aPerg,04,aPerg[04][03])
aPerg[05][03] := ParamLoad(cNomPrg,aPerg,05,aPerg[05][03])
aPerg[06][03] := ParamLoad(cNomPrg,aPerg,06,aPerg[06][03])
aPerg[07][03] := ParamLoad(cNomPrg,aPerg,07,aPerg[07][03])
aPerg[08][03] := ParamLoad(cNomPrg,aPerg,08,aPerg[08][03])
aPerg[09][03] := ParamLoad(cNomPrg,aPerg,09,aPerg[09][03])
aPerg[10][03] := ParamLoad(cNomPrg,aPerg,10,aPerg[10][03])
aPerg[11][03] := ParamLoad(cNomPrg,aPerg,11,aPerg[11][03])
aPerg[12][03] := ParamLoad(cNomPrg,aPerg,12,aPerg[12][03])
aPerg[13][03] := ParamLoad(cNomPrg,aPerg,13,aPerg[13][03])
aPerg[14][03] := ParamLoad(cNomPrg,aPerg,14,aPerg[14][03])
aPerg[15][03] := ParamLoad(cNomPrg,aPerg,15,aPerg[15][03])
aPerg[16][03] := ParamLoad(cNomPrg,aPerg,16,aPerg[16][03])
aPerg[17][03] := ParamLoad(cNomPrg,aPerg,17,aPerg[17][03])
aPerg[18][03] := ParamLoad(cNomPrg,aPerg,18,aPerg[18][03])
aPerg[19][03] := ParamLoad(cNomPrg,aPerg,19,aPerg[19][03])
aPerg[20][03] := ParamLoad(cNomPrg,aPerg,20,aPerg[20][03])
aPerg[21][03] := ParamLoad(cNomPrg,aPerg,21,aPerg[21][03])
aPerg[22][03] := ParamLoad(cNomPrg,aPerg,22,aPerg[22][03])  

// ATUALIZAÇÃO DO VENCIMENTO REAL DE ACORDO COM O VENCIMENTO								
cQueryE1 := "UPDATE " + RetSqlName("SE1") + " SET E1_VENCREA = E1_VENCTO  WHERE E1_VENCTO <> E1_VENCREA  AND E1_EMISSAO > '20180801' "		
TcSqlExec( cQueryE1 ) 


If ! ParamBox( aPerg,  "Parametros",aRet,,,,,,,cNomPrg,.T.,.T.)  // ParamBox(aPerg,"Parâmetros...",@aRet)  //ParamBox( aPerg,  "Parametros",aRet,,,,,,,cNomPrg,.T.,.T.)  // ParamBox( aPerg,  "Parametros",aRet,,,,,,,cNomPrg,.T.,.T.) 
	Return .t.	
EndIf

FTelaFil(aRet)

Return Nil


//---------------------------------------------------------------------- 
/*/{Protheus.doc} FTelaFil 
Tela para seleção dos registros

@protected         
@author 		Luciano M. Pinto
@since 		23/09/2011
@version 	P11
@param		aItens Array com os itens para o filtro 

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador      Motivo
27/12/2012 Leandro de Faria Alterado a linha 163, retirado o .F. do dbSeek
/*/ 
//---------------------------------------------------------------------- 
Static Function FTelaFil(aItens)
/***********************************************************************
* Chamada inicial da Função
*
*
***/
Local cSetFilter	:= SE1->(DBFILTER())
Local nSavRec		:= SE1->(RecNo())

Local cAlias		:= "SE1"
Local cFiltro  	:= ""  
Local cIndex		:= ""
Local cBanco		:= ""
Local cAgenc		:= ""
Local cConta		:= ""
Local cChave		:= ""

Local nOpcA			:= 0 
Local nBanco		:= 0

Local lInverte		:= .F.
Local lRImp			:= .F.

Local aCpos			:= {}
Local aDadBanco	:= {}

Local bOk1
Local bOk2
Local oDlg

Aadd( aCpos, { "E1_OK"		,, " "			, "@!"  } )
Aadd( aCpos, { "E1_NUM"  	,, AllTrim(RetTitle("E1_NUM")) 		, PesqPict("SE1","E1_NUM" ) } )			//"Numero"
Aadd( aCpos, { "E1_PARCELA",, AllTrim(RetTitle("E1_PARCELA")) 	, PesqPict("SE1","E1_PARCELA" ) } )		//"Parcela"
Aadd( aCpos, { "E1_NOMCLI"	,, AllTrim(RetTitle("E1_NOMCLI"))	, PesqPict("SE1","E1_NOMCLI" ) } )		//"Nome"
Aadd( aCpos, { "E1_SERIE"	,, AllTrim(RetTitle("E1_SERIE"))  	, PesqPict("SE1","E1_SERIE" ) } )		//"Serie"
Aadd( aCpos, { "E1_EMISSAO",, AllTrim(RetTitle("E1_EMISSAO"))	, PesqPict("SE1","E1_EMISSAO" ) } )		//"Emissao"
Aadd( aCpos, { "E1_VENCTO"	,, AllTrim(RetTitle("E1_VENCTO"))	, PesqPict("SE1","E1_VENCTO" ) } )		//"Vencimento"
Aadd( aCpos, { "E1_VENCREA",, AllTrim(RetTitle("E1_VENCREA"))	, PesqPict("SE1","E1_VENCREA") } )		//"Vencto Real"
Aadd( aCpos, { "E1_VALOR"	,, AllTrim(RetTitle("E1_VALOR"))		, PesqPict("SE1","E1_VALOR" ) } )		//"Valor"
Aadd( aCpos, { "E1_SALDO"	,, AllTrim(RetTitle("E1_SALDO"))		, PesqPict("SE1","E1_SALDO" ) } )		//"Saldo"

dbSelectArea( "SE1" )
cChave  := IndexKey()

cBanco := AllTrim(aItens[3])

Do Case
	Case cBanco == "033"
		nBanco := 2
	Case cBanco == "341"
		nBanco := 1	
	Case cBanco == "237"
		nBanco := 3	
End Case


cFiltro += "E1_SALDO 		 > 0 .And. E1_ZBOLETO == 'S' .And."																					   // Verifica saldo e se gera boleto
cFiltro += "E1_FILORIG      >='"		+ aItens[01] 		 	 + "' .And. E1_FILORIG 		<='" + aItens[02] 			+ "' .And. " 	// Filial de Até
cFiltro += "DTOS(E1_EMISSAO)>='"		+ DTOS(aItens[19])	 + "'.and.DTOS(E1_EMISSAO)	<='" + DTOS(aItens[20])	   + "' .And. "	// Data de Emissão
cFiltro += "DTOS(E1_VENCREA)>='"		+ DTOS(aItens[21])	 + "'.and.DTOS(E1_VENCREA)	<='" + DTOS(aItens[22])	   + "' .And. "	// Vencimento Real
cFiltro += "E1_PREFIXO      >='"    + AllTrim(aItens[07]) + "'.And. E1_PREFIXO 		<='" + AllTrim(aItens[08]) + "' .And. " 	// prefixo
cFiltro += "E1_NUM          >='" 	+ AllTrim(aItens[09]) + "'.And. E1_NUM				<='" + AllTrim(aItens[10]) + "' .And. " 	// Numero do Laçamento
cFiltro += "E1_PARCELA      >='" 	+ AllTrim(aItens[11]) + "'.And. E1_PARCELA		<='" + AllTrim(aItens[12]) + "' .And. "	// Parcela do Lançamento
cFiltro += "E1_NUMBOR       >='"		+ AllTrim(aItens[13]) + "'.And. E1_NUMBOR 		<='" + AllTrim(aItens[14]) + "' .And. " 	// Borderô
cFiltro += "E1_CLIENTE      >='"		+ AllTrim(aItens[15]) + "'.And. E1_CLIENTE		<='" + AllTrim(aItens[16]) + "' .And. " 	// Cliente
cFiltro += "E1_LOJA         >='"		+ AllTrim(aItens[17]) + "'.And. E1_LOJA			<='" + AllTrim(aItens[18]) + "' .And. " 	// Loja


If SubStr(aItens[06],1,1) == "S"      // Reimpressão
	cFiltro += " E1_ZBANCO == '" + cBanco + "' "	
Else
	cFiltro += " Empty(E1_ZBANCO) "
End IF

// Posiciona o SA6 (Bancos)
SA6->(dbSetOrder(1))
/*
Alterado por: Leandro de Faria
Data:27/12/2011
Retirado o comando .F. da linha do dbSeek
*/
SA6->(dbSeek(xFilial("SA6")+cBanco + aItens[04] + aItens[05])) // Agência + Conta corrente

If SA6->(Eof())
	
	Alert("Agencia ou Conta incorretos !")
	nOpcA := 2
	
Else
	
	//Verifica se alguma Msg do corpo do Boleto esta preenchida
	If ! FVldMsg(nBanco)
	
		Alert("Não existem Mensagens para o Boleto deste Banco!")
		nOpcA := 2 // Não imprime Boleto
		
	Else
		
		cIndex := CriaTrab( Nil,.F. )
		IndRegua( "SE1",cIndex,cChave,,cFiltro,"Selecionando Registros..." ) //"Selecionando Registros..."
		dbSetOrder(1)
		dbGoTop()
		
		If !SE1->(Eof())
			
			aDadBanco := {SA6->A6_COD,;									// [1]Numero do Banco
			SA6->A6_NREDUZ,;													// [2] Nome do Banco
			SA6->A6_AGENCIA,;													// [3] Agencia
			IIF(nBanco == 2,SA6->A6_ZCONVEN,SA6->A6_NUMCON),;		// [4] Conta Corrente
			SA6->A6_CARTEIR,;													// [5] Carteira
			SA6->A6_DVCTA,;													// [6] Dígito verificador da conta
			SA6->A6_DVAGE}														// [7] Digito verificador da Agência
			
			aSize := MSAdvSize()
			Define MSDialog oDlg TITLE "Impressao de Boletos" From aSize[7],00 To aSize[6],aSize[5] Pixel
			
			oMark:= MsSelect():New( cAlias,"E1_OK", ,aCpos,@lInverte,@cMarca,{ 15,oDlg:nLeft,oDlg:nBottom,oDlg:nRight } )
			oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT // Somente Interface MDI
			oMark:oBrowse:lhasMark = .T.
			oMark:oBrowse:lCanAllmark := .T.
			oMark:oBrowse:bAllMark := { || FInverte(cMarca) }
			oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oMark:oBrowse:Refresh(.T.)
			
			bOk1 := { || nOpca := 1,oDlg:End() }
			bOk2 := { || nOpca := 2,oDlg:End() }
			
			Activate MSDialog oDlg ON INIT ( EnchoiceBar( oDlg,	{ || Eval( bOk1 )},{|| Eval( bOk2 )},,)) Center
			
		Else
			
			Alert("Não existem dados com os parâmetros informados !")
			nOpcA := 2
			
		End If
		
	End If
	
End If

If nOpcA == 1	// Confirma

	Do Case
	
		Case nBanco == 1	
		   	U_FSFINR03(aDadBanco)	//Itau
		Case nBanco == 2
			U_FSFINR02(aDadBanco)	//Santander
		Case nBanco == 3	
			U_FSFINR04(aDadBanco)	//Bradesco
			
	End Case

EndIf

SE1->(dbSetOrder(1))
SE1->(dbGoTop())
RetIndex( "SE1" )
If !Empty(cIndex )
	Ferase(cIndex+OrdBagExt())
Endif

dbSelectArea( "SE1" )
// Restaura o filtro
Set Filter To &cSetFilter
dbSetOrder(1)

If nSavRec > 0
	dbGoTo(nSavRec)
Endif

Return Nil



//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FInverte
Marca e Desmarca

@protected         
@author 		Luciano M. Pinto
@since 		28/09/2011
@version		P11
@param		cMarca	Marca do campo  
@param		lTudo		Verifica se são todos ou apenas um campo

/*/
//---------------------------------------------------------------------------------------
Static Function FInverte(cMarca,lTudo)
/***********************************************************************
* Marca e desmarca
*
*
***/

Local nReg := SE1->(Recno())
Local lBxTit := .T.
Default lTudo := .T.

dbSelectArea("SE1")
dbGoTop()

While !Eof()
	If SE1->(MsRLock())
		IF AllTrim(E1_OK) == cMarca
			SE1->E1_OK := "  "
			SE1->(MsUnlock())
		Else
			lBxTit := .T.
			SE1->E1_OK := cMarca
			If !lBxTit
				SE1->E1_OK := "  "
				SE1->(MsUnlock())
			Endif
		Endif
		If !lTudo
			Exit
		Endif
	Endif
	dbSkip()
Enddo

SE1->(dbGoto(nReg))
oMark:oBrowse:Refresh(.t.)

Return Nil


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FVldMsg
Valida a Msg do Banco

@protected         
@author 		Luciano M. Pinto
@since 		28/09/2011
@version		P11
@param		nNumBco	1 = Itau, 2 Santander e 3 Bradesco
@return		lRetFun	Verdadeiro possui Msg - Falso não

/*/
//---------------------------------------------------------------------------------------
Static Function FVldMsg(nNumBco)
/***********************************************************************
* Marca e desmarca
*
*
***/
Local lRetFun := .F.

aTxtBol := U_FSGetIns(nNumBco)

For nCont := 1 to Len(aTxtBol)
	
	If !Empty(aTxtBol[nCont])
		
		lRetFun := .T.
		
	End IF
Next


Return(lRetFun)