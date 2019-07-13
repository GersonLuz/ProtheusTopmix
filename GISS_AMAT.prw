#INCLUDE "COLORS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "APWEBSRV.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSXML
Cria arquivo XML para para integracao
Exportacao de movimentacoes de nota simples remessa
@author	   	
@since	   	07/04/12
@return		Nil
/*/
//-------------------------------------------------------------------

User Function GISS_AMAT()

Private cNomCam := "C:\GISS\"+Space(20)
Private cNomArq := Space(20)
Private cArqXML := nil
Private cQueLin	:= CHR(13)+CHR(10)
Private aLinSai := {}
Private cDesMem	:= ""
Private cTipEnv := ""
Private cVerPro := "0.7"
Private cPessoa := "1"
Private cPerg   := "GISS_AMAT"
Private cFilial := SM0->M0_CODFIL

// PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' TABLES 'CTT','CT1'

ValidPerg(cPerg)

pergunte(cPerg,.T.)

fPreTela()

Return()


Static Function fPreTela()
***********************************************************************************
*
*
*******


//Declaração de variaveis locais
Local oDlgJan
Local oCblPro
Local oRadCal
Local aItsPro 	:= {"Viagens","Movimentacoes"}
Local aRatio  	:= {"E-mail","WebService"}
Local dDatIni 	:= 	''
Local dDatFim	:= ''

Private oFontG:= TFont():New("Arial",10,22,,.T.,,,,.T.,.F.)

//Inicia o objeto de janela
DEFINE MSDIALOG oDlgJan FROM 000,000 TO 290,490 PIXEL TITLE OemToAnsi("Integração XML")

TSay():New(001,200, {|| OemToAnsi("VERSAO: "+cVerPro) },oDlgJan,,,,,,.T.,,,40,10)

//Coloca um objeto de group na tela
TGroup():New(005,005,030,237,OemToAnsi("Informação:"),oDlgJan,CLR_HBLUE,,.T.)

//Coloca um say na tela
TSay():New(012,010, {|| OemToAnsi("Esse program foi desenvolvido para fazer extrações de arquivos em XML do modulo  ") },oDlgJan,,,,,,.T.,CLR_BLACK,,300,10)
TSay():New(019,010, {|| OemToAnsi("GISS abatimento a ser entregue mensalmente.") },oDlgJan,,,,,,.T.,CLR_BLACK,,300,10)

//Informações do programa
TSay():New(040,005, {|| OemToAnsi("Geração XML GISS Abatimento") },oDlgJan,,oFontG,,,,.T.,CLR_BLUE,,300,10)

//Coloca um say na tela
TSay():New(088,005, {|| OemToAnsi("Salvar XML em:") },oDlgJan,,,,,,.T.,CLR_BLACK,,300,10)

//Coloca uma caixa de texto na tela
TGet():New(087,045,{|u| if(PCount()>0,cNomCam:=u,cNomCam)},oDlgJan,090,010,,,,,,,,.T.,,,,,,,,,"","cNomCam")

TButton():New(12,34,"&Parametros",oDlgJan, {|| (fPergunta())},035,015,,,.T.,,,OemToAnsi("Parametros"))
TButton():New(12,45,"&Exit",oDlgJan, {|| oDlgJan:End()},025,015,,,.T.,,,OemToAnsi("Sair sem executar"))
TButton():New(12,54,"&Ok",oDlgJan, {|| fGeraXML()},025,015,,,.T.,,,OemToAnsi("Executar"))

//Finaliza o objeto de janela
Activate MsDialog oDlgJan Center


Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} fGeraXML
Geracao do arquivo XML
Exportacao de movimentacoes de TMS para XML
@author	   	
@since	   	07/04/12
@return		Nil
/*/
//-------------------------------------------------------------------
Static Function fGeraXML()
***********************************************************************************
*
*
*******

Local aArrIts 	:= {} //array com itens de cada arquivo
Local aHeadOut  := {}
Local nItx    	:= 1
Local nItxI    	:= 1
Local oXmlSend	:= nil
Local oXmlRet 	:= nil
Local cUrl    	:= ""
Local cNomEsp   := "GISS"
Local cResult   := ""
Local cMensWeb  := ""
Local cFileName	:= ALLTRIM(cNomCam) + ALLTRIM(cNomEsp) +"_"+ StrTran(dtoc(date()),"/","-")+"_" +StrTran(Time(),":","-") + ".XML"

aArrIts := fBusVia() //Funcao que ira buscar informacoes de viajens

For nItx:=1 To Len(aArrIts)

    If nItxI  = 1 
		cFileName	:=	ALLTRIM(cNomCam) + ALLTRIM(cNomEsp) +"_"+ StrTran(dtoc(date()),"/","-")+"_" +StrTran(Time(),":","-") + ".XML"
		cArqXML		:= 	fCreate(ALLTRIM(cFileName) + ".XML",0)
		cGravaXML 	:= 	'<?xml version="1.0" encoding="UTF-8"?>' + cQueLin
		cGravaXML 	+= 	'<NF_ABATIMENTOS xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' + cQueLin
    Endif
    
	cGravaXML += '<NFS>' + cQueLin
	cGravaXML += '<INDICADOR>'+'1'+'</INDICADOR>' + cQueLin //989 Número de la compañía filial BH y 924 para SP (claves aún por confirmar)
	cGravaXML += '<NR_DIA_NF>'+aArrIts[nItx][1]+'</NR_DIA_NF>' + cQueLin // Número de Operador  - Campo a ser criado no DA4
	cGravaXML += '<NR_MES_NF>'+aArrIts[nItx][2]+'</NR_MES_NF>' + cQueLin //Número de control (podría ser el número de viaje) - DT6_NUMVGA
	cGravaXML += '<NR_ANO_NF>'+aArrIts[nItx][3]+'</NR_ANO_NF>' + cQueLin //Número de control (podría ser el número de viaje) - DT6_NUMVGA
	cGravaXML += '<NR_DOC_NF>'+aArrIts[nItx][4]+'</NR_DOC_NF>' + cQueLin //Documento nota fiscal
	cGravaXML += '<VL_DOC_NF>'+aArrIts[nItx][5]+'</VL_DOC_NF>' + cQueLin //Valor nota fiscal
	cGravaXML += '<VL_BASE_CALCULO>'+aArrIts[nItx][6]+'</VL_BASE_CALCULO>' + cQueLin //Valor base de calculo
 	cGravaXML += '<ID_OBRA>'+aArrIts[nItx][19]+'</ID_OBRA>' + cQueLin //Valor base de calculo
	cGravaXML += '<NR_PST_CNPJ_CPF>'+SM0->M0_CGC+'</NR_PST_CNPJ_CPF>' + cQueLin //CNPJ da empresa
	cGravaXML += '<NR_PST_INSCRICAO_ESTADUAL>'+SM0->M0_INSC+'</NR_PST_INSCRICAO_ESTADUAL>' + cQueLin //Insc. Estadual da Empresa
	cGravaXML += '<NM_TOM_ESTABELECIDO>'+'S'+'</NM_TOM_ESTABELECIDO>' + cQueLin //CNPJ da empresa
	cGravaXML += '<NR_TOM_INSCRICAO_MUNICIPAL>'+'0'+'</NR_TOM_INSCRICAO_MUNICIPAL>' + cQueLin //Inscrição Municipal
	cGravaXML += '<NR_TOM_INSCRICAO_ESTADUAL>'+ALLTRIM(aArrIts[nItx][8])+'</NR_TOM_INSCRICAO_ESTADUAL>' + cQueLin //Inscrição Estadual
	cGravaXML += '<NM_TOM_RAZAO_SOCIAL>'+ALLTRIM(aArrIts[nItx][9])+'</NM_TOM_RAZAO_SOCIAL>' + cQueLin //Razão Social
	cGravaXML += '<CD_TOM_TIPO_CADASTRO>'+cPessoa+'</CD_TOM_TIPO_CADASTRO>' + cQueLin //Razão Social
	cGravaXML += '<NR_TOM_CNPJ_CPF>'+ALLTRIM(aArrIts[nItx][10])+'</NR_TOM_CNPJ_CPF>' + cQueLin //cnpj
	cGravaXML += '<NM_TOM_TIPO_LOGRADOURO>'+ALLTRIM(aArrIts[nItx][11])+'</NM_TOM_TIPO_LOGRADOURO>' + cQueLin //LOGRADOURO
	cGravaXML += '<NM_TOM_TITULO_LOGRADOURO>'+'-'+'</NM_TOM_TITULO_LOGRADOURO>' + cQueLin //LOGRADOURO
	cGravaXML += '<NM_TOM_LOGRADOURO>'+ALLTRIM(aArrIts[nItx][17])+'</NM_TOM_LOGRADOURO>' + cQueLin //LOGRADOURO
	cGravaXML += '<NM_TOM_COMPL_LOGRADOURO>'+'-'+'</NM_TOM_COMPL_LOGRADOURO>' + cQueLin //Complemento Logradouro
	cGravaXML += '<NR_TOM_NR_LOGRADOURO>'+aArrIts[nItx][18]+'</NR_TOM_NR_LOGRADOURO>' + cQueLin //Complemento Logradouro
	cGravaXML += '<NM_TOM_BAIRRO>'+ALLTRIM(aArrIts[nItx][13])+'</NM_TOM_BAIRRO>' + cQueLin //Complemento Logradouro
	cGravaXML += '<CD_TOM_CEP>'+aArrIts[nItx][14]+'</CD_TOM_CEP>' + cQueLin //Complemento Logradouro
	cGravaXML += '<NM_TOM_CIDADE>'+ALLTRIM(aArrIts[nItx][15])+'</NM_TOM_CIDADE>' + cQueLin //Complemento Logradouro
	cGravaXML += '<CD_TOM_ESTADO>'+aArrIts[nItx][16]+'</CD_TOM_ESTADO>' + cQueLin //Complemento Logradouro
	cGravaXML += '</NFS>' + cQueLin
	nItxI ++
 
	If 	nItxI  > 850 .or. nItx = Len(aArrIts)
		nItxI 		:= 1
		cGravaXML 	+= '</NF_ABATIMENTOS>' + cQueLin
		fWrite(cArqXML,cGravaXML) //GRAVA LINHA
		fClose(cArqXML)
	Endif
	
Next nItx

/*
cGravaXML += '</NF_ABATIMENTOS>' + cQueLin
fWrite(cArqXML,cGravaXML) //GRAVA LINHA
//--------------------------MONTAGEM DA ESTRUTURA XML -------------------
//Fechar arquivo usado
fClose(cArqXML)
*/

MsgBox("Arquivo gerado com sucesso!" + CHR(13)+CHR(10)+ "Local: "+cFileName + CHR(13)+CHR(10)+cResult)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fBusVia
Busca informacoes sobre viajens
Exportacao de movimentacoes de TMS para XML
@author	   	
@since	   	07/04/12
@return		aRetVia	Array com informacoes de viajens
/*/
//-------------------------------------------------------------------

Static Function fBusVia()
***********************************************************************************
*
*
*******

Local aRetVia := {}

////////////////////////////////////////////////////////////////////////
//-----------MONTAGEM DA ESTRUTURA ITENS XML ---------------------------
//Estrutura do array
//aArrIts[1] Data e Hora
//aArrIts[2] Filial
//aArrIts[3] Operador
//aArrIts[4] Numero da Viagam
//aArrIts[5] Lote Viagem
//aArrIts[6] Remetente
//aArrIts[7] Destino
//aArrIts[8] Tipo transporte
//aArrIts[9] Km/h
//aArrIts[10] Data hora inicio
//aArrIts[11] Data hora fim

cQuery := " SELECT F3_FILIAL, F3_SERIE, F3_NFISCAL, F3_EMISSAO,  "
cQuery += " RIGHT(F3_ENTRADA,2) DIA_NF, SUBSTRING(F3_ENTRADA,5,2) MES_NF, LEFT(F3_ENTRADA,4) ANO_NF, "
cQuery += " C5_NUM, C5_SERIE, C5_NOTA, C5_OBRA, C5_MUNPRES,    									" 
cQuery += " C6_NUM, C6_SERIE, C6_NOTA, C6_ZREMES,     									" 
cQuery += " A1_NOME NM_TOM_RAZAO_SOCIAL, A1_PESSOA, A1_CGC NR_TOM_CNPJ_CPF, SUBSTRING(A1_END,1,3) NM_TOM_TIPO_LOGRADOURO, 			"
cQuery += " SUBSTRING(A1_END,4,30) NM_TOM_TITULO_LOGRADOURO, SUBSTRING(A1_END,4,30) NM_TOM_LOGRADOURO, ' ' NM_TOM_COMPL_LOGRADOURO,	"
cQuery += " A1_BAIRRO NM_TOM_BAIRRO, A1_CEP CD_TOM_CEP,	A1_MUN NM_TOM_CIDADE, A1_EST CD_TOM_ESTADO,  ' ' NM_TOM_NR_LOGRADOURO,  	"
cQuery += " A1_END, A1_INSCR, A1_INSCRM,												"
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
cQuery += "		AND SF3.F3_FILIAL 				>= '"+cFilial+"' "                      "
cQuery += "		AND SF3.F3_FILIAL 				<= '"+cFilial+"' "                      "
cQuery += "		AND SF3.F3_ENTRADA 				>= "+DtoS(MV_PAR01)+" "	                "
cQuery += "		AND SF3.F3_ENTRADA 				<= "+DtoS(MV_PAR02)+" "	                "
cQuery += "		AND RIGHT(SC5.C5_MUNPRES,5) 	>= '"+MV_PAR03+"' "                     "
cQuery += "		AND RIGHT(SC5.C5_MUNPRES,5) 	<= '"+MV_PAR04+"' "                     "
cQuery += " 	AND   SF3.D_E_L_E_T_	= ''                                            "
cQuery += " 	AND   SC5.D_E_L_E_T_	= ''                                            "
cQuery += " 	AND   SC6.D_E_L_E_T_	= ''                                            "
cQuery += " 	AND   SA1.D_E_L_E_T_	= ''                                            "
cQuery += " ORDER BY 2, 3                                                               "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"GISS",.F.,.T.)

dbSelectArea("GISS")
dbGoTop()


While ! (GISS->(Eof()))

	aRet := StrTokArr(GISS->REMESSAS,",")
	
	For nXi := 1 To Len(aRet)
		cZero 	 :=  9 - LEN(AllTrim(aRet[nXi]))
	 	cDocAbat := strzero(0,cZero) +  AllTrim(aRet[nXi])         
	 	cSerAbat := "1"

		nValor    := Posicione("SF2",1,xFilial("SF2")+cDocAbat+cSerAbat,"F2_VALBRUT")
 		cEmissao  := DTOC(SF2->F2_EMISSAO) 

        If !Empty(cEmissao)
	        NR_DIA_NF = LEFT(cEmissao,2) 
			NR_MES_NF = Substr(cEmissao,4,2)
			NR_ANO_NF = Right(cEmissao,4)
		Else
			NR_DIA_NF = GISS->DIA_NF
			NR_MES_NF = GISS->MES_NF
			NR_ANO_NF = GISS->ANO_NF
		Endif
        			
		VL_DOC     := STRZERO(nValor,12,2)
		VL_BASE    := STRZERO(nValor,12,2)
		Logradouro := Substr(FisGetEnd(GISS->A1_END)[1],4)
		Numero	   := alltrim(str(FisGetEnd(GISS->A1_END)[2]))
		cObra      := GISS->C5_OBRA
		cPessoa    := IIF(GISS->A1_PESSOA 	= "J","2","1")
		Insc_Est   := IIF(LEFT(A1_INSCR,4) 	= "ISEN",'0',A1_INSCR)
		Insc_Mun   := IIF(LEFT(A1_INSCRM,4) = "ISEN",'0',A1_INSCRM)

		If nvalor > 0
			Aadd(aRetVia,{NR_DIA_NF, NR_MES_NF, NR_ANO_NF, cDocAbat, VL_DOC, VL_BASE, Insc_Mun, Insc_Est, ;
			NM_TOM_RAZAO_SOCIAL, NR_TOM_CNPJ_CPF, NM_TOM_TIPO_LOGRADOURO, NM_TOM_LOGRADOURO, NM_TOM_BAIRRO, CD_TOM_CEP, NM_TOM_CIDADE, ;
			CD_TOM_ESTADO, Logradouro, Numero, cObra, cPessoa})
	    Endif
	Next
	
	dbSelectArea("GISS")
	GISS->(dbSkip())
	
EndDo


dbSelectArea("GISS")
dbCloseArea("GISS")


Return aRetVia


Static Function fPergunta()
*****************************************************************************************
*   Função que monta a tla de pergunta do relatório.
**
***
****

Pergunte(cPerg,.T.)

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
	
  PutSx1(cPerg,"01"  ,"Dt. Emissao De		",""     ,""     ,"mv_ch1","D"  ,08      ,00      ,0      ,"G" ,"NaoVazio",""      ,""     ,""   ,"mv_par01",""         ,""         ,""         ,""    ,""       ,""      ,""        ,""      ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
  PutSx1(cPerg,"02"  ,"Dt. Emissao Fim		",""     ,""     ,"mv_ch2","D"  ,08      ,00      ,0      ,"G" ,"NaoVazio",""      ,""     ,""   ,"mv_par02",""			,""			,""			,""    ,""		 ,""	  ,""		 ,""      ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
  PutSx1(cPerg,"03"  ,"Do  Municipio		",""     ,""     ,"mv_ch3","C"  ,05      ,00      ,0      ,"G" ,"        ",""      ,""     ,""   ,"mv_par03",""         ,""         ,""         ,""    ,""       ,""      ,""        ,""      ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"" ,"" ,"","","","CC2")
  PutSx1(cPerg,"04"  ,"Ate Municipio		",""     ,""     ,"mv_ch4","C"  ,05      ,00      ,0      ,"G" ,"        ",""      ,""     ,""   ,"mv_par04",""         ,""         ,""         ,""    ,""       ,""      ,""        ,""      ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"" ,"" ,"","","","CC2")
RestArea(aAreaVal)

Return