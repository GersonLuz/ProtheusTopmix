#include "protheus.ch" 
#include "msole.ch" 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINR05() 
Relatorio Integração com Word (Carta de Protesto).

@protected
@author Luciano M. Pinto
@since 28/09/2011 
@version P11
@obs
Rotina utiliza os seguintes parâmetros:
FS_DIRDOT: Diretório do arquivo modelo para carregar o arquivo .dot. 
Deve ser informado um diretório válido e caso não informado a rotina 
irá solicitar um diretório.
FS_CONTROL: Esse parâmetro é usado para carregar a assinatura do 
Responsável pela carta de protesto.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFINR05()
/****************************************************************************************
* Chamada do programa
*
*
*
***/

FParamB()

Return Nil


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FParamB
Montagem da Tela de Parametro com ParamBox

@protected
@author 		Luciano M. Pinto
@since 		28/09/2011
@version		P11
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 

/*/
//---------------------------------------------------------------------------------------
Static Function FParamB()
/****************************************************************************************
* Chamada do programa
*
*
*
***/
Local aPerg		:= {}
Local aRet		:= {}
Local cNomPrg	:= "FINR05"+AllTrim(xFilial())		

aadd(aPerg,{1,"Prefixo de:"		,CriaVar("SE1->E1_PREFIXO"),"@!","" ,"","",20 ,.F.}) 
aadd(aPerg,{1,"Prefixo Ate:"		,CriaVar("SE1->E1_PREFIXO"),"@!","" ,"","",20 ,.T.})
aadd(aPerg,{1,"Titulo de:"			,CriaVar("SE1->E1_NUM")		,"@!","" ,"","",50 ,.F.}) 
aadd(aPerg,{1,"Titulo Ate:" 		,CriaVar("SE1->E1_NUM")		,"@!","" ,"","",50 ,.T.})
aadd(aPerg,{1,"Parcela de:"	  	,CriaVar("SE1->E1_PREFIXO"),"@!","" ,"","",20 ,.F.}) 
aadd(aPerg,{1,"Parcela Ate:"		,CriaVar("SE1->E1_PREFIXO"),"@!","" ,"","",20 ,.T.})
aadd(aPerg,{1,"Cliente :"			,CriaVar("SE1->E1_CLIENTE"),"@!","" ,"SA1","",30 ,.T.}) 
aadd(aPerg,{1,"Loja :"				,CriaVar("SE1->E1_LOJA")	,"@!","" ,"","",20 ,.T.})
aAdd(aPerg,{1,"Faturamento de:" 	,CriaVar("SE1->E1_EMISSAO"),"","","" ,"", 50, .T.})
aAdd(aPerg,{1,"Faturamento ate:"	,CriaVar("SE1->E1_EMISSAO"),"","","" ,"", 50, .T.})
aAdd(aPerg,{1,"Vencimento de:"	,CriaVar("SE1->E1_VENCREA"),"","","" ,"", 50, .T.})
aAdd(aPerg,{1,"Vencimento ate:"	,CriaVar("SE1->E1_VENCREA"),"","","" ,"", 50, .T.})
aadd(aPerg,{1,"Cod Cartóriio:"	,CriaVar("P03->P03_COD")		,"" ,"ExistCpo('P03')" ,"P03","", 35,.T.}) 

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


If !ParamBox(aPerg,"Parametros",aRet,,,,,,,cNomPrg,.T.,.T.) 
	Return Nil	
EndIf


P03->(dbSetOrder(1))
P03->(dbSeek(xFilial("P03") + aRet[13]))

If !P03->(Eof())
	
	FTelaFil(aRet)
	
Else
	
	Alert("Este registro não existe na Tabela de Cartórios !")
	
End If


Return() 



//---------------------------------------------------------------------- 
/*/{Protheus.doc} FTelaFil 
Tela para seleção dos registros

@protected
@author 		Luciano M. Pinto
@since 		23/09/2011
@version 	P11
@param		aItens Array com os itens para o filtro

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
Local cChave		:= ""

Local nOpcA			:= 0
Local lInverte		:= .F.
Local lRImp			:= .F.
Local aCpos			:= {}
Local aDadBanco	:= {}

Local bOk1
Local bOk2
Local oDlg
           
Private cMarca	:= GetMark(,"SE1","E1_OK")

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

cFiltro := "E1_FILIAL=='"		+ xFilial("SE1")+"'.And. ROUND(E1_SALDO,2) = 0 .And.  "  
cFiltro += "E1_PREFIXO >='" 	+ AllTrim(aItens[01]) + "'.And. E1_PREFIXO <='" + AllTrim(aItens[02]) + "'.And."
cFiltro += "E1_NUM>='" 			+ AllTrim(aItens[03]) + "'.And. E1_NUM<='" 		+ AllTrim(aItens[04]) + "'.And."
cFiltro += "E1_PARCELA>='" 	+ AllTrim(aItens[05]) + "'.And. E1_PARCELA<='" 	+ AllTrim(aItens[06]) + "'.And."
cFiltro += "E1_CLIENTE =='" 	+ AllTrim(aItens[07]) + "'.And."   
cFiltro += "E1_LOJA =='" 		+ AllTrim(aItens[08]) + "'.And."   
cFiltro += "DTOS(E1_EMISSAO)>='"+DTOS(aItens[09])+"'.and.DTOS(E1_EMISSAO)<='"+DTOS(aItens[10])+"' .And. "
cFiltro += "DTOS(E1_VENCREA)>='"+DTOS(aItens[11])+"'.and.DTOS(E1_VENCREA)<='"+DTOS(aItens[12])+"'"

If !SE1->(Eof())
	
	cIndex := CriaTrab( Nil,.F. )
	IndRegua( "SE1",cIndex,cChave,,cFiltro,"Selecionando Registros..." ) //"Selecionando Registros..."
	dbSetOrder(1)
	dbGoTop()
	
	aSize := MSAdvSize()
	Define MSDialog oDlg Title "Carta de Protesto" From aSize[7],00 To aSize[6],aSize[5] Pixel
	
	oMark:= MsSelect():New( cAlias,"E1_OK", ,aCpos,@lInverte,@cMarca,{ 15,oDlg:nLeft,oDlg:nBottom,oDlg:nRight } )
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT // Somente Interface MDI
	oMark:oBrowse:lhasMark = .T.
	oMark:oBrowse:lCanAllmark := .T.
	oMark:oBrowse:bAllMark := { || FInverte(cMarca) }
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:Refresh(.T.)
	
	bOk1 := { || nOpca := 1,oDlg:End() } 
	bOk2 := { || nOpca := 2,oDlg:End() }	
	
	Activate MSDialog oDlg on Init ( EnchoiceBar( oDlg,	{ || Eval( bOk1 )},{|| Eval( bOk2 )},,)) Center
	
Else
	
	nOpcA := 2

End If


If nOpcA == 1	// Confirma

	FImpWord()	
	
EndIf

SE1->(dbSetOrder( 1 ))
SE1->(dbGoTop())
RetIndex( "SE1" )
If !Empty( cIndex )
	Ferase( cIndex+OrdBagExt() )
Endif

dbSelectArea( "SE1" )
// Restaura o filtro
Set Filter To &cSetFilter
dbSetOrder( 1 )

If nSavRec > 0
	dbGoTo( nSavRec )
Endif

Return Nil


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FImpWord
Rotina de Conexão com Word

@protected
@author 		Luciano M. Pinto
@since 		28/09/2011
@version		P11

/*/
//---------------------------------------------------------------------------------------
Static Function FImpWord()
/****************************************************************************************
* Chamada do programa
*
*
*
***/
Private cPathDot 	:= GetMv("FS_DIRDOT")
Private cPathDoc 	:= ""
Private cWord	 	:= OLE_CreateLink()
Private cArqDoc	:= ""

If !File(cPathDot)

	If MsgYesNo("Arquivo de Modelo da Carta de Protesto nao foi Localizado." + Chr(13) + ;
                "Deseja localizar manualmente?")
    	cPathDot := cGetFile("Documentos  (*.dot)        | *.dot | ","Dialogo de Selecao de Arquivos")
 	Else
         Return Nil
    EndIf
    
Endif

If Empty(cPathDoc) .Or. cPathDoc == Nil
	cPathDoc := cGetFile("Arquivos do Word|*.doc","Salvar",,,.F.)                   
EndIf                                                                                    


If(!Empty(cPathDoc))
	If(!".doc"$cPathDoc)
		cPathDoc+=".doc"
	EndIf
EndIf

If (cWord < "0")
	Alert("MS-WORD nao encontrado nessa maquina !!") 
	OLE_CloseLink(cWord) //fecha o Link com o Word 
	Return()
Endif

If Empty(FCpo(cPathDoc))                              
	Alert("Caminho não encontrado para proposta !!")
	OLE_CloseLink(cWord) //fecha o Link com o Word  
	Return()
EndIF

Processa( { |lEnd| FINR05Impr()})

//fecha o Link com o Word
OLE_CloseLink(cWord) 

//Aviso("A T E N C A O","Carta de Protesto gerada com sucesso !",{"OK"})
ShellExecute( "open", cArqDoc, "", "", 1 ) 

Return Nil

       
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FINR05Impr
Geração do documento Word com as informação do Banco

@protected
@author 		Luciano M. Pinto
@since 		28/09/2011
@version		P11

/*/
//---------------------------------------------------------------------------------------
Static Function FINR05Impr()
/****************************************************************************************
* Chamada do programa
*
*
*
***/
Local cXi 		:= ""
Local nXi 		:= 1 
Local cContrle	:= GetMv("FS_CONTROL")


SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA ))

OLE_SetProperty(cWord, oleWdVisible  ,.F. )
OLE_SetProperty(cWord, oleWdPrintBack,.F. )
OLE_NewFile( cWord,cPathDot)

//	Funcao que atualiza as variaveis do Word. - Carta de Protesto
OLE_SetDocumentVar(cWord, "n_Dia"		, Day(dDataBase) )
OLE_SetDocumentVar(cWord, "c_Mes"     	, MesExtenso(Month(dDataBase)))
OLE_SetDocumentVar(cWord, "n_Ano"     	, Year(dDataBase)) 

OLE_SetDocumentVar(cWord, "c_Sacado" 	, SA1->A1_NREDUZ) 
OLE_SetDocumentVar(cWord, "c_Cpf" 	 	, Transform(SA1->A1_CGC,PicPesFJ(If(Len(AllTrim(SA1->A1_CGC))<14,"F","J"))))
       
OLE_SetDocumentVar(cWord, "c_NomCart" 	, P03->P03_NOME)  
OLE_SetDocumentVar(cWord, "c_EndCart" 	, P03->P03_END)  
OLE_SetDocumentVar(cWord, "c_CepCart" 	, P03->P03_CEP)  
OLE_SetDocumentVar(cWord, "c_MunCart" 	, P03->P03_MUN)  
OLE_SetDocumentVar(cWord, "c_BaiCart" 	, P03->P03_BAIRRO) 
OLE_SetDocumentVar(cWord, "c_EstCart" 	, P03->P03_EST) 

OLE_SetDocumentVar(cWord, "c_Control" 	, FCpo(cContrle)) 

SE1->(dbGoTop())

While SE1->(!Eof()) 
		
		If ! AllTrim(SE1->E1_OK) == cMarca
			SE1->(dbSkip())
			Loop
		End If 
		
		cXi := cValToChar(nXI)
		IncProc("Gerando doc... "+SE1->E1_NUM)
		
		OLE_SetDocumentVar(cWord, "c_Titulo"+cXi	, FCpo(SE1->E1_NUM))
		OLE_SetDocumentVar(cWord, "c_Vencim"+cXi 	, SE1->E1_VENCREA) 
		OLE_SetDocumentVar(cWord, "c_Valor"+cXi  	, Transform(SE1->E1_VALOR,PesqPict("SE1","E1_VALOR" ))) 
		nXi++
		SE1->(dbSkip())
EndDo

OLE_SetDocumentVar(cWord,"c_nroitens",cXi)
nXi := 1	

OLE_ExecuteMacro(cWord,"intp11")
OLE_UpdateFields(cWord) 

cArqDoc := FCpo(cPathDoc) + AllTrim(SA1->A1_COD) + "_Carta_Protesto" + ".doc"

OLE_SetProperty(cWord, oleWdWindowState, "MAX" ) 
OLE_SaveAsFile(cWord, cArqDoc)

Return ()


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FCpo
Formata a String retirando os Espaços em branco

@protected         
@author 		Luciano M. Pinto
@since 		28/09/2011
@version		P11
@param		cCpo 		Texto a ser tratado
@return		cRetFun	Texto limpo
/*/
//---------------------------------------------------------------------------------------
Static Function FCpo(cCpo)
/****************************************************************************************
* 
*
*
*
***/
Local cRetFun := ""


If Len(AllTrim(cCpo)) > 0
	cRetFun := AllTrim(cCpo)
Else
	cRetFun := " "
EndIf

Return (cRetFun) 


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
* 
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
                                  

