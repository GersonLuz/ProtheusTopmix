#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#Define cEol Chr(13)+Chr(10)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINR09
Relatório de posição do cliente
         
@author 	Fernando dos Santos Ferreira 
@since 	25/01/2013 
@version P11      
@return  Nil
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------- 
User Function FSFINR09()
Local	aOrd			:= {}
Local	aPerPar		:= {}
Local	aCabec		:= {}

Local	cDescRel1	:=	"Relatório de Posição do cliente"
Local	cDescRel2	:=	"Relatório irá exibir a posição do cliente"
Local	cDescRel3	:=	"" 
Local	cPgtPrg		:= ""
Local	cAlsTbl		:= "SE1"
Local	cNomPrg		:= "FINR09"+AllTrim(xFilial())
Local	cAlias		:=	""
Local	lDic			:=	.F.
Local	lEscForImp	:=	.F.

Private dDatIni		:= CriaVar("E1_EMISSAO")
Private dDatFim		:= CriaVar("E1_EMISSAO")
Private cCliIni		:= CriaVar("A1_COD")
Private cCliFim		:= CriaVar("A1_COD")
Private cLojIni		:= CriaVar("A1_LOJA")
Private cLojFim		:= CriaVar("A1_LOJA")
Private nImpExcel		:= 2
Private nDefDtas		:= 2

//	Variáveis utilizadas no relatório
Private	aReturn 	:= { "Zebrado", 1,"Posição do cliente", 1, 2, 1, "",1 }
Private	aDados	:=	{}
Private	cTitPrg	:= "Relatório de posição do cliente." 
Private	cTam		:= "G"
Private	m_pag		:= 1
Private	wrel 		:= ""


aAdd(aPerPar,{1,"Data da Emissão de:" 	,dDatIni,""  ,"" ,"" ,"", 50, .T.})
aAdd(aPerPar,{1,"Data da Emissão ate:"	,dDatFim,""  ,"" ,"" ,"", 50, .T.})
aadd(aPerPar,{1,"Cliente de:"				,cCliIni,"@!","" ,"SA1","",30 ,.F.})
aadd(aPerPar,{1,"Cliente Ate:"			,cCliFim,"@!","" ,"SA1","",30 ,.T.})
aadd(aPerPar,{1,"Loja de:"					,cLojIni,"@!","" ,"","",50 ,.F.})
aadd(aPerPar,{1,"Loja Ate:"				,cLojFim,"@!","" ,"","",50 ,.T.})
aadd(aPerPar,{3,"Importar para Excel?"	,nImpExcel, {"Sim", "Nao"} , 50	,'.T.' ,.T.})   			// [09]
aadd(aPerPar,{3,"Utilizar Datas Definidas?",nDefDtas,  {"Sim", "Nao"} , 50	,'.T.' ,.T.})   			// [09]


aPerPar[01][03] := ParamLoad(cNomPrg,aPerPar,01,aPerPar[01][03])
aPerPar[02][03] := ParamLoad(cNomPrg,aPerPar,02,aPerPar[02][03])
aPerPar[03][03] := ParamLoad(cNomPrg,aPerPar,03,aPerPar[03][03])
aPerPar[04][03] := ParamLoad(cNomPrg,aPerPar,04,aPerPar[04][03])
aPerPar[05][03] := ParamLoad(cNomPrg,aPerPar,05,aPerPar[05][03])
aPerPar[06][03] := ParamLoad(cNomPrg,aPerPar,06,aPerPar[06][03])
aPerPar[07][03] := ParamLoad(cNomPrg,aPerPar,07,aPerPar[07][03])
aPerPar[08][03] := ParamLoad(cNomPrg,aPerPar,08,aPerPar[08][03])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria a tela de parâmetros                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ParamBox(aPerPar,".:Relatório de Posição do cliente:.",,,,,,,,cNomPrg,.T.,.T.)
	Return Nil
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva os parametros.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ParamSave(cNomPrg,aPerPar,"1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transfere os valores escolhidos nos paramentros para as       ³
//³variaveis usadas no programa.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dDatIni 	:= ParamLoad(cNomPrg,aPerPar,01,aPerPar[01][03])
dDatFim 	:= ParamLoad(cNomPrg,aPerPar,02,aPerPar[02][03])
cCliIni 	:= ParamLoad(cNomPrg,aPerPar,03,aPerPar[03][03])
cCliFim 	:= ParamLoad(cNomPrg,aPerPar,04,aPerPar[04][03])
cLojIni 	:= ParamLoad(cNomPrg,aPerPar,05,aPerPar[05][03])
cLojFim 	:= ParamLoad(cNomPrg,aPerPar,06,aPerPar[06][03])
nImpExcel:= ParamLoad(cNomPrg,aPerPar,07,aPerPar[07][03]) 
nDefDtas := ParamLoad(cNomPrg,aPerPar,08,aPerPar[08][03]) 

cAlias := FGetInfTit(dDatIni,dDatFim,cCliIni,cCliFim,cLojIni,cLojFim)

If nDefDtas == 2
	dDatIni	:= CToD("01/01/2000")
	dDatFim	:= Date()
EndIf

If !Empty(cAlias)
	
	If nImpExcel == 2
		wrel	:=	SetPrint(cAlsTbl, cNomPrg, /*cPgtPrg*/ , @cTitPrg, cDescRel1, cDescRel2, cDescRel3, lDic, aOrd  , lEscForImp, cTam, , .F.)
		
		If(nLastKey == 27)
			Set Filter To
			Return
		EndIf
		
		SetDefault(aReturn, cAlsTbl)
		
		If(nLastKey == 27)
			Set Filter To
			Return
		EndIf	
		
		RptStatus({|lFim| FImpRel(cAlias, @lFim, cAlsTbl, cTitPrg, cNomPrg, cTam )}, "Carregando dados do Relatório","Processando...")
	Else
		AAdd(aCabec, "Cliente")
		AAdd(aCabec, "Loja")
		AAdd(aCabec, "Nome")
		AAdd(aCabec, "Risco")
		AAdd(aCabec, "Data de Venc.")
		AAdd(aCabec, "Dias de Atraso")
		AAdd(aCabec, "Lim. de Credito")
		AAdd(aCabec, "Provisório")
		AAdd(aCabec, "Tit.Rec")
		AAdd(aCabec, "Adiantamento NCC/RA")
		AAdd(aCabec, "Tot.Mov")
		AAdd(aCabec, "Posição Atual")	
		FExpMSXls(cAlias,"",aCabec)	
	EndIf
Else
	MsgInfo("Não foram encotrados dados com os paramentros informados", "Aviso")
EndIf

Return Nil      

//------------------------------------------------------------------- 
/*/{Protheus.doc} FImpRel 
Função que imprime o relatório de Relatório de Compensação de títulos a 
receber do tipo NCC e RA realizando as quebras necessárias - Título SE1 e 
baixas realizadas.
         
@author Fernando dos Santos Ferreira
@since 25/07/2011 
@version P10 R1.4 
@param      lFim		Verifica se o botão cancelar foi clicado
@param      cAls		Alias do arquivo a ser impresso.
@param     	cTit		Título do relatório
@param     	cTitPrg	Nome do arquivo a ser gerado em disco
@param     	cTam		Tamanho do relatório "P","M" ou "G".
@return     Nil 
@obs 

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
Static Function FImpRel(cAlias, lFim, cAls, cTit, cTitPrg, cTam )
Local		cRodaTxt	:= "Relatório de Compensação de títulos NCC e RA"
Private 	nLin		:=	80
Private 	nCotImp	:= 0

If Select(cAlias) > 0
	While (cAlias)->(!Eof()) 

		// Imprime cabeçalho		
		FImpCab() 
		
		// Imprime as informações		
		FImpInfTit(cAlias)
				
		// Imprime Cabeçalho
		FImpCab()
      
		(cAlias)->(dbSkip())	
		
	EndDo
EndIf

(cAlias)->(DbCloseArea())

If nLin != 80
   	Roda(nCotImp,cRodaTxt,cTam)
EndIf

Set Device To Screen

If(aReturn[5] = 1)
	Set Printer To
	OurSpool(wrel)	
EndIf

MS_FLUSH()

Return Nil
            
//------------------------------------------------------------------- 

/*/{Protheus.doc} FGetInfTit
Get nos resultados dos clientes de acordo com parâmetros
         
@author Fernando dos Santos Ferreira
@since 25/07/2011 
@version P10 R1.4 
@param	dDatIni	Data inicial do titulo
@param	dDatFim	Data Final do titulo
@param	cCliIni	Código do cliente inicial
@param	cCliFim	Código do cliente final
@param	cLojIni	Loja inicial do cliente
@param	cLojFim 	Loja final do cliente
@return     Nil 
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------  
Static Function FGetInfTit(dDatIni,dDatFim,cCliIni,cCliFim,cLojIni,cLojFim)
Local		cAlias	:= GetNextAlias()
Local		aExecRes	:= {}
Local		cSepNeg		:= If("|"$MV_CRNEG,"|",",")
Local		cSepProv		:= If("|"$MVPROVIS,"|",",")
Local		cSepRec		:= If("|"$MVRECANT,"|",",")
Local		cFilProv		:= ""
Local		cFilNota		:= ""
Local		cFilNcc		:= ""

cFilProv	:= "%SE1.E1_TIPO = 'PR ' %"
cFilNota += "%"
cFilNota += " SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
cFilNota += " SE1.E1_TIPO NOT IN " + FormatIn(MV_CRNEG,cSepNeg)  + " AND "
cFilNota += " SE1.E1_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
cFilNota += " SE1.E1_TIPO NOT IN " + FormatIn(MVRECANT,cSepRec)
cFilNota += "%"
cFilNcc	+= "% SE1.E1_TIPO IN ('NCC','RA ') %"

BeginSql Alias cAlias
	COLUMN A1_VENCLC AS DATE

	SELECT	CONSULTA.A1_COD, CONSULTA.A1_LOJA,
				CONSULTA.A1_NOME, CONSULTA.A1_RISCO, CONSULTA.A1_VENCLC,
				CONSULTA.NUMDIAS, CONSULTA.A1_LC, CONSULTA.PROVISAO, CONSULTA.TITREC,
				CONSULTA.NCCRA, (CONSULTA.PROVISAO + CONSULTA.TITREC) - CONSULTA.NCCRA TOTMOV,
				CONSULTA.A1_LC - ((CONSULTA.PROVISAO + CONSULTA.TITREC) - CONSULTA.NCCRA)  POSIATUAL
	FROM	(SELECT 	SA1.A1_FILIAL, SA1.A1_COD, SA1.A1_LOJA, 
					SA1.A1_NOME, SA1.A1_LC, 
					SA1.A1_RISCO, SA1.A1_VENCLC,
					
					(SELECT DATEDIFF(DAY, convert(datetime, MIN(SE1.E1_VENCREA)), GETDATE() )
					FROM %table:SE1% SE1
					WHERE SE1.%notDel% 
					AND SE1.E1_SALDO > 0
					AND CONVERT(datetime, SE1.E1_VENCREA) < GETDATE()
					AND E1_CLIENTE = SA1.A1_COD
					AND E1_LOJA = SA1.A1_LOJA AND
					%Exp:cFilNota%) NUMDIAS,
					
					(SELECT ISNULL(SUM(SE1.E1_SALDO), 0)
					FROM %table:SE1% SE1
					WHERE SE1.%notDel%
					AND SE1.E1_SALDO > 0
					AND SE1.E1_CLIENTE = SA1.A1_COD
					AND SE1.E1_LOJA = SA1.A1_LOJA
					AND SE1.E1_EMISSAO BETWEEN %Exp:DToS(dDatIni)% AND	%Exp:DToS(dDatFim)% AND
					%Exp:cFilProv%) PROVISAO,
					
					(SELECT ISNULL(SUM(SE1.E1_SALDO), 0)
					FROM %table:SE1% SE1
					WHERE SE1.%notDel%
					AND SE1.E1_SALDO > 0
					AND SE1.E1_CLIENTE = SA1.A1_COD
					AND SE1.E1_LOJA = SA1.A1_LOJA
					AND SE1.E1_EMISSAO BETWEEN %Exp:DToS(dDatIni)% AND	%Exp:DToS(dDatFim)% AND
					%Exp:cFilNota%) TITREC,
					
					(SELECT ISNULL(SUM(SE1.E1_SALDO), 0)
					FROM %table:SE1% SE1
					WHERE SE1.%notDel%
					AND SE1.E1_SALDO > 0
					AND SE1.E1_CLIENTE = SA1.A1_COD
					AND SE1.E1_LOJA = SA1.A1_LOJA
					AND SE1.E1_EMISSAO BETWEEN %Exp:DToS(dDatIni)% AND	%Exp:DToS(dDatFim)% AND
					%Exp:cFilNcc%) NCCRA
		FROM %table:SA1% SA1
		WHERE  SA1.%notDel% 
		AND	SA1.A1_COD BETWEEN %exp:cCliIni% AND %exp:cCliFim%	
		AND   SA1.A1_LOJA BETWEEN %exp:cLojIni% AND %exp:cLojFim% ) CONSULTA
		ORDER BY CONSULTA.A1_FILIAL, CONSULTA.A1_COD, CONSULTA.A1_LOJA, CONSULTA.A1_VENCLC
		  
EndSql

aExecRes :=  GetLastQuery()

If (cAlias)->(Eof())
	(cAlias)->(dbCloseArea())
	cAlias := ""
End
               

Return cAlias          

/*/{Protheus.doc} FImpCab                                  
Realiza a impressão do relatório e as quebras de páginas do relatório
         
@author Fernando dos Santos Ferreira
@since 25/07/2011 
@version P10 R1.4 
@return     Nil 
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------  
Static Function FImpCab()
//0            1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
//             012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Local cCab1:= "      Cliente                                       Risco    Data de Venc.  Dias de Atraso      Lim. de Credito            Provisório               Tit.Rec   Adiantamento NCC/RA           Tot.Mov      Posição Atual                      ."
Local cCab2	:= " "

If nLin > 65 
	Cabec(cTitPrg, cCab1, cCab2, cTitPrg, cTam, 18)
	nLin 		:= 8
	nCotImp++
EndIf

Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FImpInfTit
Realiza a impressão do relatório e as quebras de páginas do relatório
         
@author Fernando dos Santos Ferreira
@since 25/07/2011 
@version P10 R1.4 
@return     Nil 
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------  
Static Function FImpInfTit(cAlias)               
Local		oCouNew08N  := TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)          // Negrito

Default	cAlias		:= ""

FImpCab()
@ nLin, 006 PSAY (cAlias)->A1_COD + " - " + (cAlias)->A1_LOJA
@ nLin, 020 PSAY SubStr((cAlias)->A1_NOME, 1, 30)
@ nLin, 054 PSAY (cAlias)->A1_RISCO
@ nLin, 063 PSAY DToC((cAlias)->A1_VENCLC)
@ nLin, 078 PSAY Transform((cAlias)->NUMDIAS, "@E 99999")
@ nLin, 094 PSAY Transform((cAlias)->A1_LC, PesqPict("SA1","A1_LC"))
@ nLin, 112 PSAY Transform((cAlias)->PROVISAO, PesqPict("SE1","E1_SALDO"))
@ nLin, 134 PSAY Transform((cAlias)->TITREC,PesqPict("SE1","E1_SALDO"))
@ nLin, 156 PSAY Transform((cAlias)->NCCRA, PesqPict("SE1","E1_SALDO"))
@ nLin, 175 PSAY Transform((cAlias)->TOTMOV,PesqPict("SE1","E1_SALDO"))
@ nLin, 192 PSAY Transform((cAlias)->POSIATUAL,	PesqPict("SE1","E1_SALDO"))

nLin++

Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetTit
Retorna o valor total de títulos do cliente de acorco com o tipo de título
         
@author Fernando dos Santos Ferreira
@since 25/07/2011 
@version P10 R1.4 
@return     Nil 
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------  
Static Function FGetTit(cCodigo, cLoja, dDatIni, dDatFim, cTipo)
Local		nValor		:= 0
Local		cWhere		:= ""
Local		cAlias		:= GetNextAlias()
Local		cSepNeg		:= If("|"$MV_CRNEG,"|",",")
Local		cSepProv		:= If("|"$MVPROVIS,"|",",")
Local		cSepRec		:= If("|"$MVRECANT,"|",",")

Do Case
	Case cTipo == "PR"
		cWhere := "%SE1.E1_TIPO = 'PR ' %"
	Case cTipo == "NF"
		cWhere += "%"
		cWhere += " SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
		cWhere += " SE1.E1_TIPO NOT IN " + FormatIn(MV_CRNEG,cSepNeg)  + " AND "
		cWhere += " SE1.E1_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
		cWhere += " SE1.E1_TIPO NOT IN " + FormatIn(MVRECANT,cSepRec)
		cWhere += "%"
	Case cTipo == "NCCRA"
		cWhere := "% SE1.E1_TIPO IN ('NCC','RA ') %"
EndCase

BeginSql Alias cAlias
	SELECT ISNULL(SUM(SE1.E1_SALDO), 0) TOTTIT
	FROM %table:SE1% SE1
	WHERE SE1.%notDel%
	AND SE1.E1_SALDO > 0
	AND SE1.E1_CLIENTE = %Exp:cCodigo%
	AND SE1.E1_LOJA = %Exp:cLoja%
	AND SE1.E1_EMISSAO BETWEEN %Exp:DToS(dDatIni)% AND	%Exp:DToS(dDatFim)% AND
	%Exp:cWhere%
EndSql

aExecRes :=  GetLastQuery()

If (cAlias)->(!Eof())
	nValor := (cAlias)->TOTTIT
EndIf

(cAlias)->(dbCloseArea())

Return nValor


//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetDiaAtr
Retorna os dias de atraso do clientes
         
@author Fernando dos Santos Ferreira
@since 		08/03/2013
@version 	P11 
@return     Nil 
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------  
Static Function FGetDiaAtr(cCliente, cLoja)
Local		nDias		:= 0
Local		cWhere	:= ""
Local		cAlias	:= GetNextAlias()
Local		cSepNeg		:= If("|"$MV_CRNEG,"|",",")
Local		cSepProv		:= If("|"$MVPROVIS,"|",",")
Local		cSepRec		:= If("|"$MVRECANT,"|",",")

cWhere += "%"
cWhere += " SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
cWhere += " SE1.E1_TIPO NOT IN " + FormatIn(MV_CRNEG,cSepNeg)  + " AND "
cWhere += " SE1.E1_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
cWhere += " SE1.E1_TIPO NOT IN " + FormatIn(MVRECANT,cSepRec)
cWhere += "%"

BeginSql Alias cAlias
	SELECT DATEDIFF(DAY, convert(datetime, MIN(SE1.E1_VENCREA)), GETDATE() )  NUMDIAS
	FROM %table:SE1% SE1
	WHERE SE1.%notDel% 
	AND SE1.E1_SALDO > 0
	AND CONVERT(datetime, SE1.E1_VENCREA) < GETDATE()
	AND E1_CLIENTE = %Exp:cCliente%
	AND E1_LOJA = %Exp:cLoja% AND
	%Exp:cWhere%
EndSql

If (cAlias)->(!Eof())
	nDias := (cAlias)->NUMDIAS
	(cAlias)->(dbCloseArea())
Else
	(cAlias)->(dbCloseArea())
EndIf

Return nDias


//------------------------------------------------------------------- 

/*/{Protheus.doc} FSExpExcel

Gera planilha do Excel em formato xls

@Param cAlias		Alias Que será processado.
@Param cArquivo	Arquivo que será gerado, se não for informado irá aparecer uma tela para selecionar o caminho
@Param aCabec		Captions das colunas, se não for informado será utilizado o nome do campo
@Param aCampos		Campos que serão exportados, se não for informado serão todos os campos

@Return 	Nil

@author  Fernando Ferreira
@since   19/04/2013
@version 10.1.1.4
/*/
//------------------------------------------------------------------- 
Static Function FExpMSXls(cAlias,cArquivo,aCabec,aCampos)
	
	Local nQtdCol	:= (cAlias)->(FCount())
	Local aArea		:= (cAlias)->(GetArea()) 
	Local nX		:= 0
	Local cCampo	:= ""
	Local hArquivo	:= -1
	
	ProcRegua((cAlias)->(recCount()))
	
	//Criando o arquivo para ser escrito
	If(cArquivo == Nil .Or. Empty(cArquivo))
		cArquivo := cGetFile("Arquivos do Excel|*.xls","Salvar",,,.F.)                   
	EndIf
	
	If(!Empty(cArquivo))
		
		If(!".xls"$cArquivo)
			cArquivo+=".xls"
		EndIf
		
		If(File ( cArquivo ) )			
			If(MessageBox("O arquivo já existe, deseja substituí-lo?","",4)==6)
				FErase ( cArquivo ) 
				hArquivo := FCreate (cArquivo,FC_NORMAL)	
			EndIf
		Else
			hArquivo := FCreate (cArquivo,FC_NORMAL)	
		EndIf
    EndIf
		  
	If(  hArquivo != -1 )    
	
		//indo para o início do arquivo.
		(cAlias)->(dbGoTop())
		

	 	FWrite (hArquivo, "<html>" )  		
	 	FWrite (hArquivo, "<head>" )  		
	 	FWrite (hArquivo, "<style>" )  		
	 	FWrite (hArquivo, '.xl24 {mso-number-format:"\@";}')
	 	FWrite (hArquivo, '.xl25 {mso-number-format:"Short Date";}')
	 	FWrite (hArquivo, ".xl26 {mso-number-format:Fixed;}")
	 	FWrite (hArquivo, "</style>")
	 	FWrite (hArquivo, "</head>")
	 	FWrite (hArquivo, "<body>")
	 	FWrite (hArquivo, "<table border = 1>")
        
		FWrite (hArquivo, "<tr>")
		//PAra cada linha do arquivo.  
		If(aCabec != Nil .And. !Empty(aCabec))
 			For nX :=1 to Len(aCabec)				        
			 	FWrite (hArquivo, FconvCSV(aCabec[nX] ,.T.,"#CCCCCC" ) )  
			Next                        
		Else
			For nX :=1 to nQtdCol
				If(aScan(aCampos,(cAlias)->(FieldName(nX))) > 0  .or. (aCampos == Nil .or. Empty(aCampos))  )
				 	FWrite (hArquivo, FconvCSV( (cAlias)->(FieldName(nX)) ,.T., "#CCCCCC" ))  			
				EndIf
			Next				
		EndIf                    
		
		FWrite (hArquivo, "</tr>")

		MsgRun("Criando arquivo...","Processando",{|| FProcess(@hArquivo, @cAlias, @nQtdCol, @aCampos) })				
		
		FWrite (hArquivo, "</table>")
		FWrite (hArquivo, "</body>")
		FWrite (hArquivo, "</html>")


		FClose(hArquivo)
    EndIf
    
   restArea(aArea) 
   
Return cArquivo

//------------------------------------------------------------------- 
/*/{Protheus.doc} FconvCSV

Gera planilha do Excel em formato xls

@Param 		uDado Dado que será convertido

@Return 	cNewDado Dado em formato String com a representação correta do tipo para o excel.

@author  Fernando Ferreira
@since   19/04/2013
@version 10.1.1.4
/*/
//------------------------------------------------------------------- 
Static Function FconvCSV(uDado, lcor, cCor)                                 
	Local cNewDado := ""
	Local cNewCor := ""
	
	Default lcor := .F.
	Default cCor := ""

	cNewCor := IIf(lcor==.T., " bgcolor = "+cCor+" " ,"")
	
	If(ValType(uDado)=="D")
		cNewDado := "<td class=xl25 " + cNewCor + " >" +dToC(uDado) + "</td>"
	ElseIf(ValType(uDado)=="N")
		cNewDado := "<td class=xl26 " + cNewCor + " >" + Transform(uDado, "@E 999,999,999,999.99") + "</td>"
	ElseIf(ValType(uDado)=="C")
		cNewDado :=	"<td class=xl24" + cNewCor + "  >"+ uDado +"</td>"
	EndIf
	
Return cNewDado

//------------------------------------------------------------------- 
/*/{Protheus.doc} FProcess
Realiza o processamento da criação do arquivo Excel
         
@author 	Fernando dos Santos Ferreira 
@since 	19/04/2013
@version P11      
@return  Nil
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------- 
Static Function FProcess(hArquivo, cAlias, nQtdCol, aCampos)
While((cAlias)->(!Eof()))
	//Para cada campo do Alias
 			IncProc()                   		
	FWrite (hArquivo, "<tr>")
	For nX :=1 to nQtdCol
		If(aScan(aCampos,(cAlias)->(FieldName(nX))) > 0 .or. (aCampos == Nil .or. Empty(aCampos)) )			                                                          
			cCampo := cAlias+"->"+(cAlias)->(FieldName(nX))
			FWrite (hArquivo,FconvCSV(&cCampo,.F.,""))  
		EndIf 
	Next                                       
 		FWrite (hArquivo, "</tr>")
	(cAlias)->(dbSkip())
EndDo
Return Nil
                        
