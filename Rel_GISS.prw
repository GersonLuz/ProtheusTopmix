#Include "RwMake.ch"

/*
+-----------------------------------------------------------------------+
¦Programa  ¦           ¦ Autor ¦ 					   ¦Data ¦00.00.0000¦
+----------+------------------------------------------------------------¦
¦Descricao ¦ 								                            ¦
+----------+------------------------------------------------------------¦
¦ Uso      ¦ ESPECIFICO PARA A TOPMIX                                   ¦
+-----------------------------------------------------------------------¦
¦           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ¦
+-----------------------------------------------------------------------¦
¦PROGRAMADOR ¦ DATA   ¦ MOTIVO DA ALTERACAO                             ¦
+------------+--------+-------------------------------------------------¦
¦            ¦        ¦                                                 ¦
+-----------------------------------------------------------------------+
*/

User Function Rel_GISS
*************************************************************************
*
*
*****

Private nOrdem    := 0
Private tamanho   := "M"
Private limite    := 132
Private titulo    := OemToAnsi(" Relacao de Notas Fiscais de Abatimentos ")
Private cDesc1    := OemToAnsi(" Relacao de Notas Fiscais de Abatimentos ")
Private cDesc2    := ""
Private cDesc3    := ""
Private aReturn   := { "Zebrado", 1,"Administracao",2, 2, 1, "",1}
Private nomeprog  := "Rel_Giss"
Private nLastKey  := 0
Private nLinha    := 0
Private wnrel     := "Rel_Giss"
Private cCabec1   := ""
Private cCabec2   := ""
Private cConIni   := ""
Private cConFim   := ""
Private dDataIni  := CTOD("")
Private dDatafIM  := CTOD("")
Private cFilial   := SM0->M0_CODFIL

putmv("MV_IMPSX1","N")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private m_pag      := 1
Private nMaxiLinh  := 59
Private nContLinh  := 60
Private nLastKey   := 0
Private aStru      := {}
Private cArq1      := ""
Private cString    := "SF3"
Private cPerg      := "REL_GISS"
Private aPerg      := {}

ValidPerg(cPerg)

Pergunte(cPerg,.T.)


titulo    := OemToAnsi(" Relação de NFs.Abatimentos para GISS" + DTOC(MV_PAR01) + "  Até  " + DTOC(MV_PAR02) )

wnrel := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho,,.T.)

dDataIni  := MV_PAR01
dDatafIM  := MV_PAR02

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

cCabecalho := "Gravacao do Arquivo de Trabalho"
cMsgRegua  := "Processando "

Processa( {|| FGravAqr()} ,cCabecalho,cMsgRegua )
RptStatus({|| FImprRel()})

putmv("MV_IMPSX1","S")

Set Device To Screen
dbCommitAll()

Setprc(0,0)

If aReturn[5] == 1
	Set Printer To
	ourspool(wnrel)
Endif


// dbSelectArea("GISS")
// GISS->dbCloseArea()

Return




Static Function FGravAqr
*******************************************************************************
* Criacao e gravacao dos arquivos de trabalho
*
*****

Local cQuery    := ""

cQuery := " SELECT F3_FILIAL, F3_SERIE, F3_NFISCAL, F3_EMISSAO, F3_VALCONT,  "
cQuery += " RIGHT(F3_ENTRADA,2) NR_DIA_NF, SUBSTRING(F3_ENTRADA,5,2) NR_MES_NF, LEFT(F3_ENTRADA,4) NR_ANO_NF, "
cQuery += " C5_NUM, C5_SERIE, C5_NOTA, C5_OBRA,     									" 
cQuery += " C6_NUM, C6_SERIE, C6_NOTA, C6_ZREMES,     									" 
cQuery += " A1_NOME NM_TOM_RAZAO_SOCIAL, A1_PESSOA, A1_CGC NR_TOM_CNPJ_CPF, SUBSTRING(A1_END,1,3) NM_TOM_TIPO_LOGRADOURO, 			"
cQuery += " SUBSTRING(A1_END,4,30) NM_TOM_TITULO_LOGRADOURO, SUBSTRING(A1_END,4,30) NM_TOM_LOGRADOURO, ' ' NM_TOM_COMPL_LOGRADOURO,	"
cQuery += " A1_BAIRRO NM_TOM_BAIRRO, A1_CEP CD_TOM_CEP,	A1_MUN NM_TOM_CIDADE, A1_EST CD_TOM_ESTADO,  ' ' NM_TOM_NR_LOGRADOURO,  	"
cQuery += " A1_END, A1_INSCR, A1_INSCRM, A1_COD, A1_LOJA,								"
cQuery += " convert(varchar(2000),convert(varbinary(2000),C6_ZREMES)) AS 'REMESSAS'     "
                                                                                        "
cQuery += " FROM "+RetSQLName("SF3")+" SF3 "                                            "
cQuery += " INNER JOIN "+RetSQLName("SC5")+" SC5 "                                      "
cQuery += " ON  F3_FILIAL   = C5_FILIAL "                                               "
cQuery += " AND F3_SERIE 	= C5_SERIE  "                                               "
cQuery += " AND F3_NFISCAL	= C5_NOTA   "                                               "
cQuery += " INNER JOIN "+RetSQLName("SC6")+" SC6 "										"
cQuery += " ON  C5_FILIAL   = C6_FILIAL "                                               "
cQuery += " AND C5_SERIE 	= C6_SERIE  "                                               "
cQuery += " AND C5_NOTA		= C6_NOTA   "                                               "
cQuery += " INNER JOIN "+RetSQLName("SA1")+" SA1 "										"
cQuery += " ON  F3_CLIEFOR  = A1_COD 	                                                "
cQuery += " AND F3_LOJA 	= A1_LOJA                                                   "
                                                                                        "
cQuery += " WHERE LEFT(F3_CFO,1)		>= '5'                                          "
cQuery += " 	AND   F3_ISSMAT			> 0                                             "
cQuery += " 	AND   F3_DTCANC			= ''                                            "
cQuery += " 	AND   F3_CODISS			<> ''                                           "
                                                                                        "
cQuery += "		AND SF3.F3_FILIAL 		>= '"+cFilial+"' "                              "
cQuery += "		AND SF3.F3_FILIAL 		<= '"+cFilial+"' "                              "
cQuery += "		AND SF3.F3_ENTRADA 		>= "+DtoS(MV_PAR01)+" "	                        "
cQuery += "		AND SF3.F3_ENTRADA 		<= "+DtoS(MV_PAR02)+" "	                        "
cQuery += " 	AND   SF3.D_E_L_E_T_	= ''                                            "
cQuery += " 	AND   SC5.D_E_L_E_T_	= ''                                            "
cQuery += " 	AND   SC6.D_E_L_E_T_	= ''                                            "
cQuery += " 	AND   SA1.D_E_L_E_T_	= ''                                            "
cQuery += " ORDER BY 2, 3                                                               "
                                                                  
/* MAX: ENTENDENDO CODIGO SQL COLOCADO
SELECT F3_FILIAL, F3_SERIE, F3_NFISCAL, F3_EMISSAO, F3_VALCONT,  
        RIGHT(F3_ENTRADA,2) NR_DIA_NF, SUBSTRING(F3_ENTRADA,5,2) NR_MES_NF, LEFT(F3_ENTRADA,4) NR_ANO_NF, 
		C5_NUM, C5_SERIE, C5_NOTA, C5_OBRA,     									
		C6_NUM, C6_SERIE, C6_NOTA, C6_ZREMES,     									
		A1_NOME NM_TOM_RAZAO_SOCIAL, A1_PESSOA, A1_CGC NR_TOM_CNPJ_CPF, SUBSTRING(A1_END,1,3) NM_TOM_TIPO_LOGRADOURO, 			
		SUBSTRING(A1_END,4,30) NM_TOM_TITULO_LOGRADOURO, SUBSTRING(A1_END,4,30) NM_TOM_LOGRADOURO, ' ' NM_TOM_COMPL_LOGRADOURO,	
		A1_BAIRRO NM_TOM_BAIRRO, A1_CEP CD_TOM_CEP,	A1_MUN NM_TOM_CIDADE, A1_EST CD_TOM_ESTADO,  ' ' NM_TOM_NR_LOGRADOURO,  	
		A1_END, A1_INSCR, A1_INSCRM, A1_COD, A1_LOJA,								
		convert(varchar(2000),convert(varbinary(2000),C6_ZREMES)) AS 'REMESSAS'     
                                                                                        
 FROM SF3010  SF3	INNER JOIN SC5010 SC5 ON  F3_FILIAL   = C5_FILIAL AND F3_SERIE = C5_SERIE  AND F3_NFISCAL	= C5_NOTA   
					INNER JOIN SC6010 SC6 ON  C5_FILIAL   = C6_FILIAL AND C5_SERIE 	= C6_SERIE AND C5_NOTA		= C6_NOTA   
					INNER JOIN SA1010 SA1 ON  F3_CLIEFOR  = A1_COD AND F3_LOJA 	= A1_LOJA 
 WHERE	LEFT(F3_CFO,1)		>=	'5'                                          
 		AND		F3_ISSMAT		>	0                                             
 		AND		F3_DTCANC	    =	''                                            
 		AND		F3_CODISS		<>	''
 		AND		SF3.F3_FILIAL 	>= '010115'
		AND		SF3.F3_FILIAL 	<= '010115' 
		AND		SF3.F3_ENTRADA 	>= '20120601'
		AND		SF3.F3_ENTRADA 	<= '20120630'
 		AND		SF3.D_E_L_E_T_	= ''                                            
 		AND		SC5.D_E_L_E_T_	= ''                                            
 		AND		SC6.D_E_L_E_T_	= ''                                            
 		AND		SA1.D_E_L_E_T_	= ''                                            
 ORDER BY 2, 3 
*/
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"GISS",.F.,.T.)

dbSelectArea("GISS")
dbGoTop()


Return



Static Function FImprRel
*****************************************************************************
* Impressao do Relatorio
*
***

Local nContAuxi := 0
Local lImpFil   := .T.
Local cFilOld   := ""
Local cFilNew   := ""
Local cConOld   := ""
Local cConNew   := ""
Local cTpNew    := ""
Local cTp       := ""
Local nVlrRPS	:= 0
Local nVlrAbat	:= 0

cCabec1 := OemToAnsi("Prf   Recibo    Emissao   Cheque      Valor        Descricao           Beneficiario")

SetRegua(GISS->(RecCount()))
ProcRegua(GISS->(RecCount()))


If nLinha == 0
	nLinha  := Cabec(titulo,cCabec1,cCabec2,nomeprog,Tamanho) +1
EndIf             


While (! Eof())
	
	IncRegua()
	
		If lAbortPrint
			@ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
			lContinua := .F.
			Exit
		EndIf
		
		If nLinha == 0
			nLinha  := Cabec(titulo,cCabec1,cCabec2,nomeprog,Tamanho) +1
		EndIf
	
		@ nLinha,000 PSAY 	GISS->F3_SERIE
		@ nLinha,005 PSAY 	GISS->F3_NFISCAL
		@ nLinha,015 PSAY 	STOD(GISS->F3_EMISSAO)
		@ nLinha,026 PSAY 	GISS->A1_COD
		@ nLinha,033 PSAY 	GISS->A1_LOJA		
		@ nLinha,036 PSAY 	GISS->NM_TOM_RAZAO_SOCIAL		
		@ nLinha,077 PSAY 	GISS->C6_NUM
		@ nLinha,083 PSAY 	GISS->C5_OBRA		
		@ nLinha,091 PSAY 	GISS->F3_VALCONT  Picture "@E 99,999,999.99"

    	nVlrRPS	 = nVlrRPS  + GISS->F3_VALCONT

		If nLinha = 56
			nLinha  := 0
			nLinha  := Cabec(titulo,cCabec1,cCabec2,nomeprog,Tamanho) +1
		EndIf

		nContAuxi++
		nLinha++

	aRet := StrTokArr(GISS->REMESSAS,",")
	
	For nXi := 1 To Len(aRet)
		cZero 	 :=  9 - LEN(AllTrim(aRet[nXi]))
	 	cDocAbat := strzero(0,cZero) +  AllTrim(aRet[nXi])         
	 	cSerAbat := "1"

		nValor   := Posicione("SF2",1,xFilial("SF2")+cDocAbat+cSerAbat,"F2_VALBRUT")
			
		VL_BASE    := nValor
		cObra      := GISS->C5_OBRA

		@ nLinha,005 PSAY 	cSerAbat
		@ nLinha,010 PSAY 	cDocAbat
		@ nLinha,020 PSAY 	SF2->F2_EMISSAO
		@ nLinha,041 PSAY 	cObra
		@ nLinha,061 PSAY 	VL_BASE Picture "@E 99,999,999.99"

    	nVlrAbat	 = nVlrAbat  + VL_BASE

		If nLinha = 56
			nLinha  := 0
			nLinha  := Cabec(titulo,cCabec1,cCabec2,nomeprog,Tamanho) +1
		EndIf
		
		nContAuxi++
		nLinha++

	Next

		If nLinha = 56
			nLinha  := 0                                                 
			nLinha  := Cabec(titulo,cCabec1,cCabec2,nomeprog,Tamanho) +1			
		EndIf
  
		nLinha++

		GISS->(dbSkip())


EndDo

dbSelectArea("GISS")
dbCloseArea("GISS")

@ nLinha,000 PSAY REPLICATE("=",132)
nLinha++
@ nLinha,000 PSAY "Total Fatura :  " 
@ nLinha,029 PSAY 	nVlrRPS Picture "@E 99,999,999.99"
nLinha++
@ nLinha,000 PSAY "Total Abatimento :  " 
@ nLinha,029 PSAY 	nVlrAbat Picture "@E 99,999,999.99"
nLinha++
@ nLinha,000 PSAY REPLICATE("=",132)

Roda(0,"",tamanho)

Return



Static Function ValidPerg(cPerg)
********************************************************************************************
*   Função que irá criar ou validar as perguntas cridas.
**
***
****

Local aAreaVal := GetArea()
Local cKey     := ""
Local aHelpEng := {}
Local aHelpPor := {}
Local aHelpSpa := {}
	
//PutSx1(cGrupo,cOrdem,cPergunt           ,cPerSpa,cPerEng,cVar    ,cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid    ,cF3  ,cGrpSxg,cPyme,cVar01    ,cDef01    ,cDefSpa1   ,cDefEng1   ,cCnt01,cDef02   ,cDefSpa2,cDefEng2  ,cDef03  ,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)
  PutSx1(cPerg,"01"  ,"Dt. Emissao De		",""     ,""     ,"mv_ch1","D"  ,08      ,00      ,0      ,"G" ,"NaoVazio",""      ,""     ,""   ,"mv_par01",""         ,""         ,""         ,""    ,""       ,""      ,""        ,""      ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
  PutSx1(cPerg,"02"  ,"Dt. Emissao Fim		",""     ,""     ,"mv_ch2","D"  ,08      ,00      ,0      ,"G" ,"NaoVazio",""      ,""     ,""   ,"mv_par02",""			,""			,""			,""    ,""		 ,""	  ,""		 ,""      ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")

RestArea(aAreaVal)

Return
