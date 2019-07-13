#include "protheus.ch" 

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSFINR06
Relatorio Impressão de Recibos com TmsPrinter (RA, Cheque, Cartão).
         
@author 	Luciano M. Pinto
@since 	28/09/2011
@version	P11

/*/
//---------------------------------------------------------------------------------------
User Function FSFINR06()
/****************************************************************************************
* Chamada do programa
*
*
*
***/

//Local nLin         	:= 80
//Local imprime      	:= .T.
//Private lEnd       	:= .F.
//Private lAbortPrint	:= .F.
//Private limite			:= 80
//Private tamanho      	:= "P"
//Private nomeprog     	:= "FSFINR06"
//Private aReturn      	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
//Private nLastKey     	:= 0
//Private wnrel      	:= "FSFINR06"
//Private cString 		:= "SE1"
Private li     		:= 5  

Private aItens		:= {}
Private cTrbP04	:= GetNextAlias()    

FParamB()
         
If (Select(cTrbP04) <> 0)
   dbSelectArea(cTrbP04)
   dbCloseArea()
EndIf

Return Nil


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FParamB
Montagem da Tela de Parametro com ParamBox

@protected         
@author 		Luciano M. Pinto
@since 		28/09/2011
@version		P11

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
Local cNomPrg	:= "FINR06"+AllTrim(xFilial())  

aadd(aPerg,{1,"Prefixo:"		,CriaVar("SE1->E1_PREFIXO")	,"@!","" ,"SE1001","",20 ,.F.}) 
aadd(aPerg,{1,"Titulo :"		,CriaVar("SE1->E1_NUM")			,"@!","" ,"","",50 ,.T.}) 
aadd(aPerg,{1,"Parcela:"		,CriaVar("SE1->E1_PARCELA")	,"@!","" ,"","",20 ,.F.}) 
aadd(aPerg,{1,"Cliente:"		,CriaVar("SE1->E1_CLIENTE")	,"@!","" ,"SA1","",30 ,.T.}) 
aadd(aPerg,{1,"Loja :"			,CriaVar("SE1->E1_LOJA")		,"@!","" ,"","",20 ,.T.})
aAdd(aPerg,{1,"Faturamento:" 	,CriaVar("SE1->E1_EMISSAO")	,"","","" ,"", 50, .T.})
aAdd(aPerg,{1,"Vencimento:"	,CriaVar("SE1->E1_VENCREA")	,"","","" ,"", 50, .T.})
aadd(aPerg,{1,"Produto:"		,Space(60)							,"" ,"" ,"","",80 ,.F.}) 

aPerg[01][03] := ParamLoad(cNomPrg,aPerg,01,aPerg[01][03]) 
aPerg[02][03] := ParamLoad(cNomPrg,aPerg,02,aPerg[02][03])   
aPerg[03][03] := ParamLoad(cNomPrg,aPerg,03,aPerg[03][03]) 
aPerg[04][03] := ParamLoad(cNomPrg,aPerg,04,aPerg[04][03])   
aPerg[05][03] := ParamLoad(cNomPrg,aPerg,05,aPerg[05][03]) 
aPerg[06][03] := ParamLoad(cNomPrg,aPerg,06,aPerg[06][03])   
aPerg[07][03] := ParamLoad(cNomPrg,aPerg,07,aPerg[07][03]) 
aPerg[08][03] := ParamLoad(cNomPrg,aPerg,08,aPerg[08][03])   

If !ParamBox(aPerg,"Parametros",aRet,,,,,,,cNomPrg,.T.,.T.) 
	Return Nil	
EndIf

aItens := aClone(aRet)
	
FTelaFil()

Return() 



//---------------------------------------------------------------------- 
/*/{Protheus.doc} FTelaFil 
Tela para seleção dos registros

@protected         
@author 		Luciano M. Pinto
@since 		23/09/2011
@version 	P11

/*/ 
//---------------------------------------------------------------------- 
Static Function FTelaFil()
/***********************************************************************
* Chamada inicial da Função
*
*
***/
Local cSetFilter	:= SE1->(DBFILTER())
Local nSavRec		:= SE1->(RecNo())
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
           
dbSelectArea( "SE1" )
cChave  := IndexKey()
                                                                                                      
//cFiltro := "E1_FILIAL=='"		+ xFilial("SE1")+"'.And. E1_SALDO > 0 .And. E1_ZBOLETO == 'S' .And.  "  
cFiltro := "E1_FILIAL=='"		+ xFilial("SE1")+"' .And. E1_TIPO $ 'RA _NCC _CD _CH ' .And.  "  
cFiltro += "E1_PREFIXO =='" 	+ aItens[01] + "'.And."
cFiltro += "E1_NUM =='" 		+ aItens[02] + "'.And."
        
If Empty(AllTrim(aItens[03]))
	cFiltro += "E1_PARCELA =='" 	+ CriaVar("SE1->E1_PARCELA") + "'.And."
Else
	cFiltro += "E1_PARCELA =='" 	+ aItens[03] + "'.And."
End If

cFiltro += "E1_CLIENTE =='" 	+ aItens[04] 	+ "'.And."   
cFiltro += "E1_LOJA =='" 		+ aItens[05]	+ "'.And."   
cFiltro += "DTOS(E1_EMISSAO) =='"+DTOS(aItens[06])		+ "'.And."
cFiltro += "DTOS(E1_VENCREA) =='"+DTOS(aItens[07])		+ "'"


cIndex := CriaTrab( Nil,.F. )
IndRegua( "SE1",cIndex,cChave,,cFiltro,"Selecionando Registros..." ) //"Selecionando Registros..."
dbSetOrder(1)
dbGoTop()

If SE1->(Eof())
	
	Alert("Não existem dados com os parâmetros informados !") 	
		
Else
	    
//	RptStatus({|lEnd|FImpRec(@lEnd,wnRel,cString)},"Imprimindo...")	 
	FImpRec()
	
End If

dbSelectArea( "SE1" )
// Restaura o filtro
Set Filter To &cSetFilter
dbSetOrder( 1 )

If nSavRec > 0
	dbGoTo( nSavRec )
Endif

Return Nil


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FImpRec
Rotina responsavel pela impressão do relatório do recibo.

@protected         
@author 		Luciano M. Pinto
@since 		28/09/2011
@version		P11

/*/
//---------------------------------------------------------------------------------------
Static Function FImpRec()
/***********************************************************************
* Chamada inicial da Função
*
*
***/
Private oPrnRec	:= TMSPrinter():New()
Private oFont09  	:= TFont():New( "Courier New",,09,,.f.,,,,,.f. )
Private oFont09b	:= TFont():New( "Courier New",,09,,.t.,,,,,.f. )
Private oFont10	:= TFont():New( "Courier New",,10,,.f.,,,,,.f. )
Private oFont10b	:= TFont():New( "Courier New",,10,,.t.,,,,,.f. )
Private oFont16	:= TFont():New( "Courier New",,16,,.f.,,,,,.f. )
Private oFont16b	:= TFont():New( "Courier New",,16,,.t.,,,,,.f. )
 
FPrintRec()

oPrnRec:EndPage()

oPrnRec:Setup()

oPrnRec:Preview()

MS_FLUSH()

Return Nil


//------------------------------------------------------------------- 
/*/{Protheus.doc} FPrintRec
Realiza a impressão dos Recibos

@protected                   
@author Luciano Mariano
@since 11/11/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FPrintRec()
/***********************************************************************
* Chamada inicial da Função
*
*
***/
Local cDataExt	:= ""
Local cExtenso	:= ""
Local cPrDesc	:= "" 
Local cMsgTit	:= ""

Local nVlrLiq	:= 0

Local aDiaSem 	:= {"Domingo", "Segunda-Feira", "Terça-Feira","Quarta-Feira","Quinta-Feira","Sexta-Feira", "Sábado"}
Local	aMsgFrt	:= {}
Local	aDadChq	:= {}

Local lReimp	:= .F. 

Local dDateSE1 := dDataBase

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1") + aItens[4] + aItens[5]))

cNomCli	:= SA1->A1_NOME
cEndCli	:= SA1->A1_END
cBaiCli	:= SA1->A1_BAIRRO
cMunCli 	:= SA1->A1_MUN
cEstCli	:= SA1->A1_EST
cCepCli	:= TransForm(SA1->A1_CEP,"@R 99999-999")
cFonCli	:= "(" + AllTrim(SA1->A1_DDD) + ")" +  TransForm(SA1->A1_Tel,"@R 9999 99999")
cCPFCli	:= Transform(SA1->A1_CGC,PicPesFJ(If(Len(AllTrim(SA1->A1_CGC))<14,"F","J")))
cInsCli	:=	SA1->A1_INSCR
cPrDesc	:= aItens[8]
cNumRec  := NextNumero("P04",1,"P04_SEQUEN",.T.)	

// Carregas os campos SE1->E1_ZDEPOSI ou SE1->E1_ZCCREDI
cMsgTit	:= IIF(Empty(SE1->E1_ZDEPOSI), SE1->E1_ZCCREDI,SE1->E1_ZDEPOSI)

// Realizo as quebras dividindo em array
aMsgFrt	:=	U_FSQbrStr(SubStr(cMsgTit, 1, 150),60, Space(1))

nVlrLiq	:= SE1->E1_VALOR

cExtenso := Extenso(nVlrLiq,.F.,1)
cExtenso := PadR(Alltrim(cExtenso),240,"*")   

aDadChq	:= FGetChq(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO)

If Li > 1000

	oPrnRec:EndPage()
 	oPrnRec:StartPage() 
 	
Endif


If FVerP04(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO)
	dDateSE1 := (cTrbP04)->P04_DATA
	cNumRec	:= (cTrbP04)->P04_SEQUEN
	lReimp := .T.
End If

Li := 150
oPrnRec:Say(Li,0855,"RECIBO Nº"	+ cNumRec + "/" + SM0->M0_CODFIL,oFont16b,50)

Li+=200
oPrnRec:Say(Li,0200,"Recebimento :",oFont10,50)
oPrnRec:Say(Li,0855,"ANTECIPADO",oFont10,50)

Li+=100
oPrnRec:Say(Li,0200,"Recebemos de",oFont10,50)
oPrnRec:Say(Li,0855,cNomCli,oFont10,50) 
//oPrnRec:Say(Li,1505,"CONTRATO: 003594",oFont10,50)
       
Li+=050
oPrnRec:Say(Li,0855,"CNPJ: " 			+ cCPFCli,oFont10,50) 
oPrnRec:Say(Li,1505,"INSCR EST: "	+ cInsCli,oFont10,50)

Li+=050
oPrnRec:Say(Li,0855,"Endereço: " 	+ cEndCli,oFont10,50) 

Li+=050
oPrnRec:Say(Li,0855,"Bairro..: " 	+ cBaiCli,oFont10,50)  
oPrnRec:Say(Li,1500,"Cidade..: " 	+ cMunCli,oFont10,50) 

Li+=050
oPrnRec:Say(Li,0855,"Estado..: " 	+ cEstCli,oFont10,50)  
oPrnRec:Say(Li,1150,"CEP: " 			+ cCepCli,oFont10,50)  
oPrnRec:Say(Li,1500,"Fone....: " 	+ cFonCli,oFont10,50) 

Li+=150
oPrnRec:Say(Li,0200,OemToAnsi("A importância de"),oFont10,50)
oPrnRec:Say(Li,0855,"R$" + " "+Transform(nVlrLiq,PesqPict("SE1","E1_VALOR")),oFont10,50)
               
Li+=050
oPrnRec:Say(Li,0855,Substr(cExtenso,001,060),oFont10,50)  
Li+=050
oPrnRec:Say(Li,0855,Substr(cExtenso,061,060),oFont10,50) 
Li+=050
oPrnRec:Say(Li,0855,Substr(cExtenso,121,060),oFont10,50) 
Li+=050
oPrnRec:Say(Li,0855,Substr(cExtenso,181,060),oFont10,50)                     
Li+=200

For nXi := 1 To Len(aMsgFrt)
	oPrnRec:Say(Li,0855, aMsgFrt[nXi], oFont10,50)
	Li+=050
Next

oPrnRec:Say(Li,0855,"Cheque(s) relacionado(s) abaixo :",oFont10,50)
Li+=100                                                                                                                
oPrnRec:Say(Li,0160,"                                        NUM DA             DATA DE                      DATA PARA",oFont10b,50)
Li+=050
oPrnRec:Say(Li,0160,      "BANCO AGENCIA COMP   NUM DO CHEQUE   P  RAZÃO     CONTA    ABERTURA        VALOR        DEPOSITO",oFont10b,50)
Li+=050


For nXi := 1 To Len(aDadChq)
	Li+=050
	oPrnRec:Say(Li,0180,aDadChq[nXi][1],oFont10,50)	// Imprime o código do banco
	oPrnRec:Say(Li,320,aDadChq[nXi][2],oFont10,50)	// Imprime a agência
	oPrnRec:Say(Li,480,aDadChq[nXi][3],oFont10,50)	// Imprime a Compesação
	oPrnRec:Say(Li,610,aDadChq[nXi][4],oFont10,50)	// Imprime a Número do Cheque
	oPrnRec:Say(Li,975,aDadChq[nXi][5],oFont10,50)	// Imprime a Parcela do título
	oPrnRec:Say(Li,1060,aDadChq[nXi][6],oFont10,50)	// Imprime a Razão título
	oPrnRec:Say(Li,1240,SubStr(aDadChq[nXi][7],1,7),oFont10,50)	// Imprime a Conta do cheque
	oPrnRec:Say(Li,1430,Dtoc(aDadChq[nXi][8]),oFont10,50)	// Imprime a Data da Abertura
	oPrnRec:Say(Li,1680,TransForm(aDadChq[nXi][9],PesqPict("SEF","EF_VALOR")),oFont10,50)	// Imprime o valor do cheque
	oPrnRec:Say(Li,2090,Dtoc(aDadChq[nXi][10]),oFont10,50)	// Imprime a Data de depósito
Next


Li+=300
oPrnRec:Say(Li,0200,"Relativo a ...",oFont10,50)
oPrnRec:Say(Li,0855,cPrDesc,oFont10,50) 

Li+=300

cDataExt := AllTrim(SM0->M0_CIDENT) 		+ ", "	+;
				aDiaSem[Dow(dDateSE1)] 			+ " " + ;
				AllTrim(Str(Day(dDateSE1))) 	+ " de "+;
				MesExtenso(dDateSE1) 			+ " de " + ;
				Alltrim(Str(Year(dDateSE1)))

oPrnRec:Say(Li,0200,cDataExt,oFont10,50)

           
Li+=500
oPrnRec:Say(Li,200,Replicate("_",Len(SM0->M0_NOMECOM) + 3),oFont10,50)
Li+=050
oPrnRec:Say(Li,220,SM0->M0_NOMECOM,oFont10b,50)            
Li+=100
      

// Grava registro no P04 se não for reimpressão
If !lReimp
	FGrvP04(cNumRec)
End IF

Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGrvP04
Função responsavel por gravar a tabela P04

@protected                   
@author Luciano Mariano
@since 11/11/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FGrvP04(cNum)
/***********************************************************************
* Função responsavel por gravar a tabela P04
*
*
***/


P04->(RecLock("P04",.T.))

	P04->P04_FILIAL 	:= xFilial("P04")
	P04->P04_SEQUEN	:= cNum
	P04->P04_PREFIX	:= SE1->E1_PREFIXO
	P04->P04_TIPO		:= SE1->E1_TIPO
	P04->P04_NUM		:= SE1->E1_NUM
	P04->P04_PARCEL	:= SE1->E1_PARCELA
	P04->P04_DATA		:= dDatabase
	P04->P04_FILORI	:= SE1->E1_FILORIG

P04->(MsUnlock())

Return Nil



//---------------------------------------------------------------------- 
/*/{Protheus.doc} FVerP04 
Função responsável por verificar se ja existe registro
gravado no P04

@protected         
@author 	Luciano M. Pinto
@since 	18/10/2011
@version P11
@param	cPrefSE1	Prefixo do Titulo  
@param	cNumSE1 	Numero do Titulo  
@param	cParcSE1	Parcela do Titulo   
@param	cTipoSE1	Tipo do Titulo   
@return	lRetFun Verdadeiro ou Falso 		

Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------- 
Static Function FVerP04(cPrefSE1,cNumSE1,cParcSE1,cTipoSE1)
/***********************************************************************
* Função para gerar a query
* 
*
***/
Local lRetFun := .T.

BeginSql alias cTrbP04
        
	COLUMN P04_DATA as Date  

	SELECT	
		P04_FILIAL, 
		P04_SEQUEN, 
		P04_PREFIX, 
		P04_TIPO, 
		P04_NUM, 
		P04_PARCEL, 
		P04_DATA, 
		P04_FILORI
	FROM %table:P04% P04
	WHERE P04.%notDel%
		AND P04.P04_FILIAL 	= %xFilial:P04%
		AND P04.P04_PREFIX = %Exp:cPrefSE1%
		AND P04.P04_NUM 		= %Exp:cNumSE1%
		AND P04.P04_PARCEL = %Exp:cParcSE1%
		AND P04.P04_TIPO 	= %Exp:cTipoSE1%

EndSql

/*
cQuery := GetLastQuery()[2]
memowrite("c:\cQuery.sql",cQuery)
*/

If (cTrbP04)->(Eof())
	lRetFun := .F.	
End If

Return (lRetFun)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FGetChq
Retorna array com os cheques gerados do título

@protected
@author Fernando Ferreira
@since 10/01/2012 
@param cPrx 		- Prefixo do título
@param cNum 		- Número do título
@param cPar 		- Parcela do Título
@param cTip 	 	- Tipo do Título
@return aDadChq 	- Array contendo as informações do cheque.
/*/
//---------------------------------------------------------------------------------------
Static Function FGetChq(cPrx, cNum, cPar, cTip)
Local		aDadChq	:= {}
Local		aAreOld	:=	{}
Local		aPrcChq	:= {}

Local		cFilSef	:= ""

Default	cPrx		:= ""
Default	cNum		:= ""
Default	cPar		:= ""
Default	cTip		:= ""

AAdd(aAreOld,GetArea("SEF"))

cFilSef	:= xFilial("SEF")
              
// EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_NUM+EF_SEQUENC
SEF->(dbSetOrder(3))
SEF->(dbSeek(cFilSef+cPrx+cNum+cPar+cTip))

While SEF->(!Eof())	.And. SEF->EF_FILIAL		==	cFilSef;
							.And.	SEF->EF_PREFIXO	==	cPrx;
							.And.	SEF->EF_TITULO		==	cNum;
							.And. SEF->EF_PARCELA	==	cPar;
							.And.	SEF->EF_TIPO		== cTip
	aPrcChq	:={}
								
	AAdd(aPrcChq, SEF->EF_BANCO)
	AAdd(aPrcChq, SEF->EF_AGENCIA)
	AAdd(aPrcChq, SEF->EF_COMP)
	AAdd(aPrcChq, SEF->EF_NUM)
	AAdd(aPrcChq, SEF->EF_PARCELA)
	AAdd(aPrcChq, SEF->EF_TIPO)
	AAdd(aPrcChq, SEF->EF_CONTA)
	AAdd(aPrcChq, SEF->EF_DATA)
	AAdd(aPrcChq, SEF->EF_VALOR)
	AAdd(aPrcChq, SEF->EF_VENCTO)
	
	AAdd(aDadChq, aPrcChq)
	SEF->(dbSkip())
EndDo

aEval(aAreOld, {|xAux| RestArea(xAux)})
Return aDadChq

