#Include "Protheus.ch"

#Define cEol Chr(13)+Chr(10)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINR08
Programa de geração de relatório de faturamento Compensação de títulos NCC e RA
         
@author 	Fernando dos Santos Ferreira 
@since 	09/04/2012 
@version P11      
@return  Nil
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------- 
User Function FSFINR08()
Local	aOrd			:= {}
Local	aPerPar		:= {}

Local	cDescRel1	:=	"Relatório de Compensação de títulos NCC e RA"
Local	cDescRel2	:=	"Relatório irá exibir os títulos compensados do Tipo NF, NCC e RA"
Local	cDescRel3	:=	"" 
Local	cPgtPrg		:= ""
Local	cAlsTbl		:= "SE1"
Local	cNomPrg		:= "FINR08"+AllTrim(xFilial())
Local	cAli			:=	GetNextAlias()
Local dDatIni		:= CriaVar("SE1->E1_EMISSAO")
Local dDatFim		:= CriaVar("SE1->E1_EMISSAO")
Local	cCliIni		:= CriaVar("SA1->A1_COD")
Local	cCliFim		:= CriaVar("SA1->A1_COD")
Local	cNatIni		:= CriaVar("SE1->E1_NATUREZ")
Local	cNatFim		:= CriaVar("SE1->E1_NATUREZ")
Local	cFilIni		:= CriaVar("SE1->E1_FILIAL")
Local	cFilFim		:= CriaVar("SE1->E1_FILIAL")

Local	lDic			:=	.F.
Local	lEscForImp	:=	.F.

//	Variáveis utilizadas no relatório
Private	aReturn 	:= { "Zebrado", 1,"Compensação de títulos NCC e RA", 1, 2, 1, "",1 }
Private	aDados	:=	{}
Private	aCabec	:=	{"Prefixo", "Nº Título", "Parcela", "Tipo", "Cliente", "Loja", "Data de Emissão","Data Vencimento","Valor do Título"}
Private	cTitPrg	:= "Relatório de Compensação de títulos NCC e RA" 
Private	cTam		:= "G"
Private	m_pag		:= 1
Private	wrel 		:= "" 

aAdd(aPerPar,{1,"Data da Emissão de:" 	,dDatIni,""  ,"" ,"" ,"", 50, .T.})
aAdd(aPerPar,{1,"Data da Emissão ate:"	,dDatFim,""  ,"" ,"" ,"", 50, .T.})
aadd(aPerPar,{1,"Cliente de:"				,cCliIni,"@!","" ,"SA1","",30 ,.F.})
aadd(aPerPar,{1,"Cliente Ate:"			,cCliFim,"@!","" ,"SA1","",30 ,.T.})
aadd(aPerPar,{1,"Natureza de:"			,cNatIni,"@!","" ,"SED","",50 ,.F.})
aadd(aPerPar,{1,"Natureza Ate:"			,cNatFim,"@!","" ,"SED","",50 ,.T.})
aadd(aPerPar,{1,"Filial de"				,cFilIni ,"@!","" ,"SM0","",50 ,.T.})
aadd(aPerPar,{1,"Filial Ate"				,cFilFim ,"@!","" ,"SM0","",50 ,.T.})

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
If !ParamBox(aPerPar,".:Compensação de NCC e RA:.",,,,,,,,cNomPrg,.T.,.T.)
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
dDatIni := ParamLoad(cNomPrg,aPerPar,01,aPerPar[01][03])
dDatFim := ParamLoad(cNomPrg,aPerPar,02,aPerPar[02][03])
cCliIni := ParamLoad(cNomPrg,aPerPar,03,aPerPar[03][03])
cCliFim := ParamLoad(cNomPrg,aPerPar,04,aPerPar[04][03])
cNatIni := ParamLoad(cNomPrg,aPerPar,05,aPerPar[05][03])
cNatFim := ParamLoad(cNomPrg,aPerPar,06,aPerPar[06][03])
cFilIni := ParamLoad(cNomPrg,aPerPar,07,aPerPar[07][03])
cFilFim := ParamLoad(cNomPrg,aPerPar,08,aPerPar[08][03])	

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

// Carrega os parâmentros da query
If !FCarParQry(cAli, dDatIni, dDatFim, cCliIni, cCliFim, cNatIni, cNatFim, cFilIni, cFilFim)
	MsgInfo("Não foram encotrados dados com os paramentros informados", "Aviso")
Else
	RptStatus({|lFim| FImpRel(cAli, @lFim, cAlsTbl, cTitPrg, cNomPrg, cTam )}, "Carregando dados do Relatório","Processando...")		
EndIf

Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FCarParQry
Executa query para criação do arquivo de trabalho para execução do 
relatório. Se tiver dados Retorna True senão false.
         
@author Fernando dos Santos Ferreira
@since 25/07/2011 
@version P10 R1.4 
@return     lRet
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
Static Function FCarParQry(cAli, dDatIni, dDatFim, cCliIni, cCliFim, cNatIni, cNatFim, cFilIni, cFilFim)
Local		lRet 		:= .F. 
Local		cQryPrc	:= ""

Default	cAli		:= ""
Default	dDatIni	:= CriaVar("SE1->E1_EMISSAO")
Default	dDatFim	:= CriaVar("SE1->E1_EMISSAO")
Default	cCliIni	:= CriaVar("SA1->A1_COD")
Default	cCliFim	:= CriaVar("SA1->A1_COD")
Default	cNatIni	:= CriaVar("SE1->E1_NATUREZ")
Default	cNatFim	:= CriaVar("SE1->E1_NATUREZ")
Default	cFilIni	:= CriaVar("SE1->E1_FILIAL")
Default	cFilFim	:= CriaVar("SE1->E1_FILIAL")

cQryPrc	+= "SELECT SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SA1.A1_NOME E1_NOME, SE1.E1_LOJA, SE1.E1_EMISSAO, SE1.E1_VENCREA, SE1.E1_VALOR, SE1.E1_SALDO " + cEol
cQryPrc	+= "FROM " + RetSqlName("SE1") + " SE1" + cEol
cQryPrc	+= "INNER JOIN " + RetSqlName("SA1") + " SA1 " + cEol
cQryPrc	+= "ON SE1.E1_CLIENTE = SA1.A1_COD " + cEol
cQryPrc	+= "AND SE1.E1_LOJA = SA1.A1_LOJA" + cEol
cQryPrc	+= "WHERE SE1.D_E_L_E_T_ <> '*'" + cEol
cQryPrc	+= "AND SA1.D_E_L_E_T_ <> '*'" + cEol
cQryPrc	+= "AND SE1.E1_EMISSAO	BETWEEN'" + DtoS(dDatIni) +"' AND '" + DtoS(dDatFim) + "'" + cEol
cQryPrc	+= "AND SE1.E1_SALDO <> SE1.E1_VALOR" + cEol
cQryPrc	+= "AND SE1.E1_TIPO IN ('NCC', 'RA')" + cEol
cQryPrc	+= "AND SE1.E1_CLIENTE	BETWEEN'" + cCliIni +"' AND	'" + cCliFim + "'" + cEol
cQryPrc	+= "AND SE1.E1_NATUREZ	BETWEEN'" + cNatIni + "' AND	'" + cNatFim + "'" + cEol
cQryPrc	+= "AND SE1.E1_FILORIG	BETWEEN'" + cFilIni + "' AND	'" + cFilFim + "'"  + cEol

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryPrc), cAli, .F., .T.)

lRet := FCkcArqTrb(cAli)

Return lRet

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
Static Function FImpRel(cAli, lFim, cAls, cTit, cTitPrg, cTam )
Local		cRodaTxt	:= "Relatório de Compensação de títulos NCC e RA"
Private 	nLin		:=	80
Private 	nCotImp	:= 0

If Select(cAli) > 0
	While (cAli)->(!Eof()) 

		// Imprime cabeçalho		
		FImpCab()
		
		// Imprime as informações do título.
		FImpInfTit(cAli)
		
		// Imprime as informações das baixas realizadas.
		FImpInfBax((cAli)->E1_PREFIXO, (cAli)->E1_NUM, (cAli)->E1_PARCELA, (cAli)->E1_TIPO)
		
		// Imprime Cabeçalho
		FImpCab()
      
		(cAli)->(dbSkip())	
		
	EndDo
EndIf

(cAli)->(DbCloseArea())

If nLin != 80
   	Roda(nCotImp,cRodaTxt,cTam)
EndIf

Set Device To Screen

//SetPgEject(.F.)

If(aReturn[5] = 1)
	Set Printer To
	OurSpool(wrel)	
EndIf

MS_FLUSH()

Return Nil

//------------------------------------------------------------------- 
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
Local cCab1:= "      Prefixo   Nº Título   Parcela   Tipo   Cliente                         Loja     Data Emissão     Data Venc.         Valor Saldo   Saldo a Compensar                                                                  ."
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
Static Function FImpInfTit(cAli)               
Local		oCouNew08N  := TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)          // Negrito
Local		nSldCom		:= 0
Default	cAli			:= ""

nSldCom := (cAli)->E1_VALOR - ((cAli)->E1_VALOR - (cAli)->E1_SALDO)

FImpCab()
@ nLin, 008 PSAY (cAli)->E1_PREFIXO
@ nLin, 016 PSAY (cAli)->E1_NUM
@ nLin, 031 PSAY (cAli)->E1_PARCELA
@ nLin, 039 PSAY (cAli)->E1_TIPO
@ nLin, 045 PSAY SubStr((cAli)->E1_NOME, 1, 30)
@ nLin, 079 PSAY (cAli)->E1_LOJA
@ nLin, 088 PSAY DtoC(SToD((cAli)->E1_EMISSAO))
@ nLin, 103 PSAY DtoC(SToD((cAli)->E1_VENCREA))
@ nLin, 115 PSAY Transform((cAli)->E1_SALDO	,	PesqPict("SE1","E1_SALDO"))
@ nLin, 135 PSAY Transform(nSldCom	,	PesqPict("SE1","E1_SALDO"))
nLin++
Return Nil


//------------------------------------------------------------------- 
/*/{Protheus.doc} FImpInfBax
Realiza a impressão das informações da baixa do título.
         
@author Fernando dos Santos Ferreira
@since 11/04/2012
@version P11      
@return     Nil 
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------  
Static Function FImpInfBax(cPrefixo, cNum, cParcela, cTipo)
Local		nSldCom		:= 0

Default	cPrefixo		:= ""
Default	cNum			:= ""
Default	cParcela		:= ""
Default	cTipo			:= ""
                          
// Get nos títulos baixados
cAli := FGetInfBxa(cPrefixo, cNum, cParcela, cTipo)
nLin++
While (cAli)->(!Eof())
	//Verifica se tem baixa cancelada-
	If TemBxCanc((cAli)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ),.T.)
		(cAli)->(dbskip())
		Loop
	EndIf
	FImpCab()    	
	nSldCom := (cAli)->E5_VALSE1 - ((cAli)->E5_VALSE1 - (cAli)->E5_SALDO)
	@ nLin, 001 PSAY "( - )"
	@ nLin, 008 PSAY (cAli)->E5_PREFIXO
	@ nLin, 016 PSAY (cAli)->E5_NUMERO
	@ nLin, 031 PSAY (cAli)->E5_PARCELA
	@ nLin, 039 PSAY (cAli)->E5_TIPO
	@ nLin, 045 PSAY SubStr((cAli)->E5_CLIENTE, 1, 30)
	@ nLin, 079 PSAY (cAli)->E5_LOJA
	@ nLin, 088 PSAY SToD((cAli)->E5_EMISSAO)
	@ nLin, 103 PSAY SToD((cAli)->E5_DATA)
	@ nLin, 115 PSAY Transform((cAli)->E5_VALOR	,	PesqPict("SE5","E5_VALOR"))
	@ nLin, 135 PSAY Transform(nSldCom	,	PesqPict("SE1","E1_SALDO"))
	nLin++		
	(cAli)->(dbSkip())
EndDo
nLin++
(cAli)->(DbCloseArea())

Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FCloAreTrb
Fecha e apaga os arquivos temporários criados pela rotina.
         
@author Fernando dos Santos Ferreira
@since 25/07/2011 
@version P10 R1.4 
@return     Nil
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
Static Function FCloAreTrb(cArqTemp)
If Select(cArqTemp) != 0
	(cArqTemp)->(dbCloseArea())
	If File(cArqTemp+GetDBExtension())
		FErase(cArqTemp+GetDBExtension())
	EndIf
EndIf
Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FCkcArqTrb()
Verifica se o arquivo de trabalho existe e verifica se tem registros.
         
@author Fernando dos Santos Ferreira
@since 25/07/2011 
@version P10 R1.4 
@return     lExtReg
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------           
Static Function FCkcArqTrb(cArqTemp)
Local	lExtReg	:= .F.

If Select(cArqTemp) != 0
	(cArqTemp)->(dbGoTop())
	If (cArqTemp)->(!Eof()) 
		lExtReg	:= .T.		
	EndIf
EndIf

Return (lExtReg)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetInfBxa
Executa query para criação do arquivo de trabalho para execução do 
relatório. Se tiver dados Retorna True senão false.
         
@author Fernando dos Santos Ferreira
@since 25/07/2011 
@version P10 R1.4 
@return     cAli	Alias das baix
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------

Static Function FGetInfBxa(cPrefixo, cNum, cParcela, cTip)
Local		nTamTit		:= 0
Local		nTamTip		:= 0
Local		cQryPrc		:= ""
Local		cAli			:= GetNextAlias()

Default	cPrefixo		:= ""
Default	cNum			:= ""
Default	cParcela		:= ""
Default	cTip			:= ""

nTamTit	:= TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]
nTamTip	:= TamSX3("E1_TIPO")[1]

cQryPrc	+= "SELECT SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_TIPO, SA1.A1_NOME E5_CLIENTE, SA1.A1_LOJA E5_LOJA, " + cEol
cQryPrc	+= "SE1.E1_EMISSAO E5_EMISSAO, SE5.E5_DATA, SE5.E5_VALOR, SE1.E1_VALOR E5_VALSE1, SE1.E1_SALDO E5_SALDO, E5_SEQ, E5_CLIFOR" + cEol
cQryPrc	+= "FROM " + RetSqlName("SE5") + " SE5" + cEol
cQryPrc	+= "INNER JOIN " + RetSqlName("SA1") + " SA1 ON" + cEol
cQryPrc	+= "SA1.A1_COD = SE5.E5_CLIFOR" + cEol
cQryPrc	+= "AND SA1.A1_LOJA = SE5.E5_LOJA" + cEol
cQryPrc	+= "INNER JOIN " + RetSqlName("SE1") + " SE1" + cEol
cQryPrc	+= "ON SE1.E1_FILORIG = SE5.E5_FILORIG" + cEol
cQryPrc	+= "AND SE1.E1_PREFIXO = SE5.E5_PREFIXO" + cEol
cQryPrc	+= "AND SE1.E1_NUM = SE5.E5_NUMERO" + cEol
cQryPrc	+= "AND SE1.E1_PARCELA = SE5.E5_PARCELA" + cEol
cQryPrc	+= "AND SE1.E1_TIPO = SE5.E5_TIPO" + cEol
cQryPrc	+= "WHERE SE5.D_E_L_E_T_ <> '*'" + cEol
cQryPrc	+= "AND SA1.D_E_L_E_T_ <> '*'" + cEol
cQryPrc	+= "AND SE1.D_E_L_E_T_ <> '*'" + cEol
cQryPrc	+= "AND SE5.E5_TIPODOC = 'CP'" + cEol
cQryPrc	+= "AND SE5.E5_TIPO	   = 'NF'" + cEol
cQryPrc	+= "AND SE5.E5_MOTBX   = 'CMP'" + cEol
cQryPrc	+= "AND SE5.E5_RECPAG  = 'R'" + cEol
cQryPrc	+= "AND SUBSTRING(SE5.E5_DOCUMEN, 1, "+Str(nTamTit+nTamTip)+") = '"+cPrefixo+cNum+cParcela+cTip +"'" + cEol
cQryPrc	+= "ORDER BY SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_DATA" + cEol

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryPrc), cAli, .F., .T.)

Return cAli


