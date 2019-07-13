#Include "Totvs.ch"
#Include "Fileio.ch"
#Include "rwmake.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFISR01
Relatório de amarração entre Notas de fatura X Notas Remessa

@author	Fernando dos Santos Ferreira 
@since 	02/04/2013
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFISR01()
Local		cAlias	:= GetNextAlias()
Local		cFilCur	:= xFilial("P02")
Local		aCabec	:= {}


If FGetDados(cAlias, cFilCur)
	If MV_PAR13 == 1
		AAdd(aCabec, AllTrim(RetTitle("F2_DOC")))
		AAdd(aCabec, AllTrim(RetTitle("F2_SERIE")))
		AAdd(aCabec, AllTrim(RetTitle("F2_CLIENTE")))
		AAdd(aCabec, AllTrim(RetTitle("F2_LOJA")))
		AAdd(aCabec, AllTrim(RetTitle("F2_ESPECIE")))
		AAdd(aCabec, AllTrim(RetTitle("F2_EMISSAO")))
		AAdd(aCabec, AllTrim(RetTitle("F2_OBRA")))
		AAdd(aCabec, AllTrim(RetTitle("A1_NOME")))
		AAdd(aCabec, AllTrim(RetTitle("A1_CGC")))
		AAdd(aCabec, AllTrim(RetTitle("F2_VALBRUT")))
		AAdd(aCabec, AllTrim(RetTitle("F2_BASEISS")))
		AAdd(aCabec, AllTrim(RetTitle("F2_VALISS")))
		AAdd(aCabec, AllTrim(RetTitle("F2_RECISS")))
		AAdd(aCabec, AllTrim(RetTitle("C6_ABATMAT")))
		AAdd(aCabec, AllTrim(RetTitle("C6_ABTMAT2")))
		AAdd(aCabec, AllTrim(RetTitle("F2_DOC")) + " - Remessa")
		AAdd(aCabec, AllTrim(RetTitle("F2_SERIE")) + " - Remessa")
		AAdd(aCabec, AllTrim(RetTitle("A1_NOME")) + " - Remessa")
		AAdd(aCabec, AllTrim(RetTitle("A1_LOJA")) + " - Remessa")
		AAdd(aCabec, AllTrim(RetTitle("F2_ESPECIE")) + " - Remessa")
		AAdd(aCabec, AllTrim(RetTitle("F2_EMISSAO")) + " - Remessa")
		AAdd(aCabec, AllTrim(RetTitle("F2_VALBRUT")) + " - Remessa")
		AAdd(aCabec, AllTrim(RetTitle("F3_DTCANC")) + " - Remessa")
		AAdd(aCabec, AllTrim(RetTitle("P02_OK")) + " - Remessa")
		FExpMSXls(cAlias,"", aCabec)
	Else
		FConfRel(cAlias)
	EndIf	
Else
	MsgBox("Não foram encontrados dados!", "GISS - Amarração", "ALERT")
EndIf

Return Nil 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FConfRel
Configuração da do relatóri.

@author	Fernando dos Santos Ferreira 
@since 	02/04/2013
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------
Static Function FConfRel(cAlias)
Local			cAlsTbl		:= cAlias
Local			cDescRel1	:=	"Relatório de Amarração de Notas - GISS"
Local			cDescRel2	:=	"Relatório irá exibir as notas que foram amarradas - GISS"
Local			cDescRel3	:=	""
Local			cNomPrg		:= "FSFISR01"
Local			lDic			:=	.F.
Local			lEscForImp	:=	.F.
Local			aOrd			:= {}

Private	wrel		:= Nil
Private	cTam		:= "G"
Private	cTitPrg	:= "Relatório de Amarração de Notas - GISS"
Private	aReturn 	:= { "Zebrado", 1,"Amarração de Notas", 1, 2, 1, "",1 }
Private	m_pag		:= 1

wrel	:=	SetPrint(cAlias, cNomPrg, /*cPgtPrg*/ , @cTitPrg, cDescRel1, cDescRel2, cDescRel3, lDic, aOrd  , lEscForImp, cTam, , .F.)

If(nLastKey == 27)
	Set Filter To
	Return
EndIf

SetDefault(aReturn, cAlsTbl)

If(nLastKey == 27)
	Set Filter To
	Return
EndIf			

RptStatus({|lFim| FImpRel(cAlsTbl, @lFim, cAlsTbl, cTitPrg, cNomPrg, cTam )}, "Carregando dados do Relatório","Processando...")

SET DEVICE TO SCREEN

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wrel)
EndIf
	
MS_FLUSH()

Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetDados
Get nas informações dos dados das notas

@author	Fernando dos Santos Ferreira 
@since 	02/04/2013
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------
Static Function FGetDados(cAlias, cFilCur)
Local		cPerg  	:= "FSFISR01"
Local		lReturn	:= .T.

	//FSAjuSX1(cPerg)

If Pergunte(cPerg, .T.)                                                                  

	BeginSql Alias cAlias
		COLUMN F2_EMISSAO AS DATE
		COLUMN EMISREM		AS DATE
		COLUMN DTACANREM 	AS DATE
		
	 	SELECT SF2.F2_DOC, SF2.F2_SERIE, SC5.C5_CLIOBRA F2_CLIENTE, SC5.C5_LOJOBRA F2_LOJA, SC5.C5_OBRA F2_OBRA, SF2.F2_ESPECIE, SF2.F2_EMISSAO, SA1.A1_NOME, SA1.A1_CGC,  
				SF2.F2_VALBRUT, SF2.F2_BASEISS, SF2.F2_VALISS, SF2.F2_RECISS, 
																			   ISNULL((SELECT SUM(SC6.C6_ABATMAT)
																			   FROM %table:SC6% SC6
																			   WHERE SC6.%notdel%
																			   AND SC6.C6_FILIAL = SC5.C5_FILIAL
																			   AND SC6.C6_NUM = SC5.C5_NUM), 0) F2_ABATMAT, 
																			   ISNULL((SELECT SUM(SC6.C6_ABTMAT2)
																			   FROM %table:SC6% SC6
																			   WHERE SC6.%notdel%
																			   AND SC6.C6_FILIAL = SC5.C5_FILIAL
																			   AND SC6.C6_NUM = SC5.C5_NUM), 0) F2_ABATMA2,
																			   P02.P02_NUM2 NFREMES, P02.P02_SERIE2 SERIREMES,
																			   ISNULL((SELECT SC5.C5_CLIOBRA 
																				FROM %table:SC5% SC5
																				WHERE SC5.C5_NOTA = P02.P02_NUM2
																				AND SC5.C5_SERIE = P02.P02_SERIE2
																				AND SC5.C5_FILIAL = P02.P02_FILIAL 
																				AND SC5.%notdel%), '      ') CLIEREM,
																				ISNULL((SELECT SC5.C5_LOJOBRA 
																				FROM %table:SC5% SC5
																				WHERE SC5.C5_NOTA = P02.P02_NUM2
																				AND SC5.C5_SERIE = P02.P02_SERIE2 
																				AND SC5.C5_FILIAL = P02.P02_FILIAL
																				AND SC5.%notdel%), '  ') LOJAREM,																			
																				ISNULL((SELECT SF2.F2_ESPECIE
																				FROM %table:SF2% SF2
																				WHERE SF2.F2_DOC = P02.P02_NUM2
																				AND SF2.F2_SERIE = P02.P02_SERIE2 
																				AND SF2.F2_FILIAL = P02.P02_FILIAL
																				AND SF2.%notdel%), '   ') ESPEREM,
																				ISNULL((SELECT SF2.F2_EMISSAO
																				FROM %table:SF2% SF2
																				WHERE SF2.F2_DOC = P02.P02_NUM2
																				AND SF2.F2_SERIE = P02.P02_SERIE2 
																				AND SF2.F2_FILIAL = P02.P02_FILIAL
																				AND SF2.%notdel%), '        ') EMISREM,
																				ISNULL((SELECT SF2.F2_VALBRUT
																				FROM %table:SF2% SF2
																				WHERE SF2.F2_DOC = P02.P02_NUM2
																				AND SF2.F2_SERIE = P02.P02_SERIE2 
																				AND SF2.F2_FILIAL = P02.P02_FILIAL
																				AND SF2.%notdel%), 0) VBRUREM,
																			  	ISNULL((SELECT SF3.F3_DTCANC
																				FROM %table:SF3% SF3                                 													
																				WHERE SF3.%notdel%
																			 	AND SF3.F3_FILIAL = P02.P02_FILIAL
																			 	AND SUBSTRING(SF3.F3_CFO,1,1) >= '5'
																			   AND SF3.F3_NFISCAL = P02.P02_NUM2
																			 	AND SF3.F3_SERIE = P02.P02_SERIE2
																				AND SF3.F3_DTCANC <> '        '), '        ') DTACANREM,   
																				P02.P02_OK
		FROM %table:P02% P02, %table:SC5% SC5, %table:SA1% SA1, %table:SF2% SF2
		WHERE P02.%notdel%
		AND SC5.%notdel%
		AND SF2.%notdel%	  
		//AND P02.P02_OK <> ' ' //retirado a pedido da consultora Juliana - 21/06/2013
		AND P02.P02_FILIAL = %exp:cFilCur%
		AND P02.P02_DTEMI1 BETWEEN %exp:DToS(MV_PAR01)% AND %exp:DToS(MV_PAR02)%   
		AND SC5.C5_CLIOBRA BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04%
		AND SC5.C5_LOJOBRA BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR06%
		AND SUBSTRING(SC5.C5_MUNPRES,3,6) BETWEEN %exp:MV_PAR07% AND %exp:MV_PAR08%
		AND SC5.C5_NOTA BETWEEN %exp:MV_PAR09% AND %exp:MV_PAR10%
		AND SC5.C5_SERIE BETWEEN %exp:MV_PAR11% AND %exp:MV_PAR12%
		AND SC5.C5_FILIAL = SF2.F2_FILIAL
		AND SC5.C5_NOTA = SF2.F2_DOC
		AND SC5.C5_SERIE = SF2.F2_SERIE
		AND SC5.C5_CLIENT = SF2.F2_CLIENTE
		AND SC5.C5_LOJACLI = SF2.F2_LOJA
		AND SC5.C5_ZTIPO = '2'
		//AND SA1.A1_COD  = SC5.C5_CLIOBRA 
		AND SA1.A1_COD  = SC5.C5_CLIENTE   
		AND SA1.A1_LOJA = SC5.C5_LOJACLI		
		AND P02.P02_FILIAL = SC5.C5_FILIAL
		AND SC5.C5_ZPEDIDO = P02.P02_NUM1
		ORDER BY SF2.F2_DOC, SF2.F2_SERIE, SC5.C5_CLIOBRA, SF2.F2_LOJA, SF2.F2_ESPECIE, SF2.F2_EMISSAO, SA1.A1_NOME, SA1.A1_CGC, 
				SF2.F2_VALBRUT, SF2.F2_BASEISS, SF2.F2_VALISS, SF2.F2_RECISS 
	EndSql   
EndIf

//AND SA1.A1_LOJA = SC5.C5_LOJOBRA
If Select( cAlias ) > 0
	If (cAlias)->(Eof())
		lReturn	:= .F.
		(cAlias)->(dbCloseArea())
	EndIf
EndIf

Return lReturn

//------------------------------------------------------------------- 
/*/{Protheus.doc} FImpRel 
Função que imprime o relatório de Relatório de Amarração de NFS
         
@author Fernando dos Santos Ferreira
@since 25/07/2011 
@version P10 R1.4 
@param		lFim		Verifica se o botão cancelar foi clicado
@param		cAls		Alias do arquivo a ser impresso.
@param    	cTit		Título do relatório
@param		cTitPrg	Nome do arquivo a ser gerado em disco
@param		cTam		Tamanho do relatório "P","M" ou "G".
@return    Nil 
@obs 

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
Static Function FImpRel(cAlias, lFim, cAls, cTit, cTitPrg, cTam )
Local		cRodaTxt		:= "Relatório de Amarração de NFS"
Local		oCouNew08N	:= TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)          // Negrito
Local		cFilReg		:= ""
Local		cLotCtrl		:= ""
Local		cCliente 	:= ""
Local		cSerie		:= ""
Local		cNota			:= ""
Local		cLoja			:= ""
Local		cLotCarg		:= ""
Local		cNumRom		:= ""
Local		lPrtCabIte	:= .T.
Local		cNumero		:= ""
Local		cSerie		:= ""
Local		cCliente		:= ""
Local		cLoja			:= ""
Local		cEspecie		:= ""
Local		lLinha1		:= .T.

Private 	nLin		:= 080
Private 	nCotImp	:= 0

While (cAlias)->(!Eof())
	If cNumero != (cAlias)->F2_DOC .Or. cSerie != (cAlias)->F2_SERIE .Or. ;
		cCliente != (cAlias)->F2_CLIENTE .Or. cLoja != (cAlias)->F2_LOJA .Or. cEspecie != (cAlias)->F2_ESPECIE
		
		FImpCab()
		
		cNumero		:= (cAlias)->F2_DOC
		cSerie		:= (cAlias)->F2_SERIE
		cCliente		:= (cAlias)->F2_CLIENTE
		cLoja			:= (cAlias)->F2_LOJA
		cEspecie		:= (cAlias)->F2_ESPECIE
		
		If !lLinha1
			nLin++	
		EndIf
		
		@ nLin	, 	002	PSAY	"Numero"
		@ nLin	, 	012	PSAY	"Serie Docto."
		@ nLin	, 	026	PSAY	"Cliente"
		@ nLin	, 	035	PSAY	"Loja"
		@ nLin	, 	041	PSAY	"Nome" 
		@ nLin	, 	063	PSAY	"Obra" 		
		@ nLin	, 	080	PSAY	"CNPJ/CPF"		
		@ nLin	, 	095	PSAY	"Espec.Docum."
		@ nLin	, 	110	PSAY	"DT Emissao"
		@ nLin	, 	134	PSAY	"Vlr.Bruto"
		@ nLin	, 	151	PSAY	"Base ISS"
		@ nLin	, 	166	PSAY	"Valor ISS"
		@ nLin	, 	178	PSAY	"Rec. ISS"
		@ nLin	, 	194	PSAY	"Abat. Mat."
		@ nLin	, 	207	PSAY	"Abat. Mat. 2"
		
		@ ++nLin	, 	002	PSAY	(cAlias)->F2_DOC
		@ nLin	, 	012	PSAY	(cAlias)->F2_SERIE
		@ nLin	, 	026	PSAY	(cAlias)->F2_CLIENTE
		@ nLin	, 	035	PSAY	(cAlias)->F2_LOJA
		@ nLin	, 	041	PSAY	SubStr((cAlias)->A1_NOME, 1, 20)	
		@ nLin	, 	063	PSAY	SubStr((cAlias)->F2_OBRA, 1, 15)	 			
		@ nLin	, 	080	PSAY	(cAlias)->A1_CGC		
		@ nLin	, 	095	PSAY	(cAlias)->F2_ESPECIE
		@ nLin	, 	110	PSAY	DToc((cAlias)->F2_EMISSAO)
		@ nLin	, 	129	PSAY	Transform((cAlias)->F2_VALBRUT, "@E 999,999,999.99")
		@ nLin	, 	145	PSAY	Transform((cAlias)->F2_BASEISS, "@E 999,999,999.99")
		@ nLin	, 	161	PSAY	Transform((cAlias)->F2_VALISS, "@E 999,999,999.99")
		@ nLin	, 	184	PSAY	(cAlias)->F2_RECISS
		@ nLin	, 	189	PSAY	Transform((cAlias)->F2_ABATMAT, "@E 999,999,999.99")
		@ nLin	, 	205	PSAY	Transform((cAlias)->F2_ABATMA2, "@E 999,999,999.99")
		@ ++nLin,	002	PSAY	Replicate("-", 218)
		
		@ ++nLin	, 	002	PSAY	"Remessas"
		
		@ ++nLin	, 	012	PSAY	"Numero"
		@ nLin	, 	025	PSAY	"Serie Docto."
		@ nLin	, 	038	PSAY	"Cliente"
		@ nLin	, 	047	PSAY	"Loja"
		@ nLin	, 	052	PSAY	"Espec.Docum."		
		@ nLin	, 	066	PSAY	"DT Emissao"
		@ nLin	, 	083	PSAY	"Vlr.Bruto"
		@ nLin	, 	096	PSAY	"Dt. Cancel."
		@ nLin	, 	110	PSAY	"Flag Amarra"
		@ ++nLin,	012	PSAY	Replicate("-", 208)
		nLin++
		lLinha1 := .F.
	EndIf
	
	@ nLin	, 	012	PSAY	(cAlias)->NFREMES
	@ nLin	, 	029	PSAY	(cAlias)->SERIREMES
	@ nLin	, 	040	PSAY	(cAlias)->CLIEREM
	@ nLin	, 	048	PSAY	(cAlias)->LOJAREM
	@ nLin	, 	055	PSAY	(cAlias)->ESPEREM
	@ nLin	, 	067	PSAY	DToC((cAlias)->EMISREM)
	@ nLin	, 	080	PSAY	Transform((cAlias)->VBRUREM, "@E 999,999,999.99")
	@ nLin	, 	098	PSAY	DToC((cAlias)->DTACANREM)
	@ nLin	, 	118	PSAY	(cAlias)->P02_OK
	nLin++
	 	
	(cAlias)->(dbSkip())
EndDo

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
Local cCab1:= "                                                                                               Relatório de Amarração de NFS                                                                                               ."
Local cCab2:= ""

If nLin > 65 
	Cabec("", cCab1, cCab2, "", cTam, 18)
	nLin 		:= 8
	nCotImp++
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FSAjuSX1
Ajusta Perguntas

@protected
@author    Fernando Ferreira
@since     02/04/2013
@version   P11
@param     cPerg  Nome Pergunta

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FSAjuSX1(cPerg)

Local aPergs   := {}
Local aHelpPor := {}

Aadd(aPergs,{ "Emissão de","Emissão de","Emissão de","mv_ch1","D",TamSX3("P02_DTEMI1")[1],0,0,"G","",;
"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd(aPergs,{ "Emissão Até","Emissão Até","Emissão Até","mv_ch2","D",TamSX3("P02_DTEMI1")[1],0,0,"G","",;
"MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd(aPergs,{ "De Cliente","De Cliente","De Cliente","mv_ch3","C",TamSX3("C5_CLIOBRA")[1],0,0,"G","",;
"MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","" })
Aadd(aPergs,{ "Até Cliente","Até Cliente","Até Cliente","mv_ch4","C",TamSX3("C5_CLIOBRA")[1],0,0,"G","",;
"MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","" })
Aadd(aPergs,{ "De Loja","De Loja","De Loja","mv_ch5","C",TamSX3("C5_LOJACLI")[1],0,0,"G","",;
"MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd(aPergs,{ "Até Loja","Até Loja","Até Loja","mv_ch6","C",TamSX3("C5_LOJACLI")[1],0,0,"G","",;
"MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd(aPergs,{ "De Munic. Prest.","De Munic. Prest.","De Munic. Prest.","mv_ch7","C",TamSX3("C5_MUNPRES")[1],0,0,"G","",;
"MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","CC2","","" })
Aadd(aPergs,{ "Até Munic. Prest.","Até Munic. Prest.","Até Munic. Prest.","mv_ch8","C",TamSX3("C5_MUNPRES")[1],0,0,"G","",;
"MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","CC2","","" })
Aadd(aPergs,{ "Da Nota Fat.","Da Nota Fat.","Da Nota Fat.","mv_ch9","C",TamSX3("C5_NOTA")[1],0,0,"G","",;
"MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd(aPergs,{ "Até Nota Fat.","Até Nota Fat.","Até Nota Fat.","mv_ch10","C",TamSX3("C5_NOTA")[1],0,0,"G","",;
"MV_PAR010","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd(aPergs,{ "Da Série Fat.","Da Série Fat.","Da Série Fat.","mv_ch11","C",TamSX3("C5_SERIE")[1],0,0,"G","",;
"MV_PAR011","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd(aPergs,{ "Até Série Fat.","Até Série Fat.","Até Série Fat.","mv_ch12","C",TamSX3("C5_SERIE")[1],0,0,"G","",;
"MV_PAR012","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
aAdd(aPergs,{"Exporta para Excel?","Exporta para Excel?","Exporta para Excel?","mv_ch13", "C", 6,0,0, "C","",;
"MV_PAR13","SIM","SIM","SIM","","","NÃO","NÃO","NÃO","","","","","","","","","","","","","","","","",""})

//Cria perguntas (padrao)
AjustaSx1(cPerg, aPergs)

//Help das perguntas
//Tamanho Linha '1234567890123456789012345678901234567890' )
aHelpPor:= {}
Aadd( aHelpPor, 'Emissão da Nota' )
PutSX1Help("P."+cPerg+"01.",aHelpPor,aHelpPor,aHelpPor)

aHelpPor:= {}
Aadd( aHelpPor, 'Emissão da Nota' )
PutSX1Help("P."+cPerg+"02.",aHelpPor,aHelpPor,aHelpPor)

aHelpPor:= {}
Aadd( aHelpPor, 'Cliente da Nota' )
PutSX1Help("P."+cPerg+"03.",aHelpPor,aHelpPor,aHelpPor)

aHelpPor:= {}
Aadd( aHelpPor, 'Cliente da Nota' )
PutSX1Help("P."+cPerg+"04.",aHelpPor,aHelpPor,aHelpPor)

aHelpPor:= {}
Aadd( aHelpPor, 'Loja do Cliente' )
PutSX1Help("P."+cPerg+"05.",aHelpPor,aHelpPor,aHelpPor)

aHelpPor:= {}
Aadd( aHelpPor, 'Loja do Cliente' )
PutSX1Help("P."+cPerg+"06.",aHelpPor,aHelpPor,aHelpPor)

aHelpPor:= {}
Aadd( aHelpPor, 'Múnicipio de Prestação' )
PutSX1Help("P."+cPerg+"07.",aHelpPor,aHelpPor,aHelpPor)

aHelpPor:= {}
Aadd( aHelpPor, 'Múnicipio de Prestação' )
PutSX1Help("P."+cPerg+"08.",aHelpPor,aHelpPor,aHelpPor)

aHelpPor:= {}
Aadd( aHelpPor, 'Número da Nota Faturada' )
PutSX1Help("P."+cPerg+"09.",aHelpPor,aHelpPor,aHelpPor)

aHelpPor:= {}
Aadd( aHelpPor, 'Número da Nota Faturada' )
PutSX1Help("P."+cPerg+"10.",aHelpPor,aHelpPor,aHelpPor)
                                                                                                
aHelpPor:= {}
Aadd( aHelpPor, 'Série da Nota Faturada' )
PutSX1Help("P."+cPerg+"11.",aHelpPor,aHelpPor,aHelpPor)

aHelpPor:= {}
Aadd( aHelpPor, 'Série da Nota Faturada' )
PutSX1Help("P."+cPerg+"12.",aHelpPor,aHelpPor,aHelpPor)

Return Nil


//------------------------------------------------------------------- 

/*/{Protheus.doc} FSExpExcel

Gera planilha do Excel em formato xls

@Param cAlias		Alias Que será processado.
@Param cArquivo	Arquivo que será gerado, se não for informado irá aparecer uma tela para selecionar o caminho
@Param aCabec		Captions das colunas, se não for informado será utilizado o nome do campo
@Param aCampos		Campos que serão exportados, se não for informado serão todos os campos

@Return 	Nil

@author  Fernando Ferreira
@since   05/04/2013
@version 11.5
/*/
//------------------------------------------------------------------- 
Static Function FExpMSXls(cAlias,cArquivo,aCabec,aCampos)
	
	Local nQtdCol	:= (cAlias)->(FCount())
	Local aArea		:= (cAlias)->(GetArea()) 
	Local nX			:= 0
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
@since   05/04/2013
@version 11.5
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

          

