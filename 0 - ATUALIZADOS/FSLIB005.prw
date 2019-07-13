#include "protheus.ch"
#include "fileio.ch"
#include "common.ch"  
#include "PRTOPDEF.CH
"

#Define cEol Chr(13)+Chr(10)
#Define _LIMSTR 	1048576

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSLIB005
Função criada para efeitos de compatibilidade evitando que seja criada uma função com o 
nome deste prw.

@author 		Fernando Ferreira	
@since 		25/10/2011
@version 	P11

/*/ 
//---------------------------------------------------------------------------------------
User Function FSLIB005()
Return Nil           


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSTBLINF
Realiza a conversão de parcelas Letra Alfabeto para Numero
        
@author Fernando Ferreira
@since 24/06/2010 
@param cTbl			String Nome da tabela a ser pesquisada.
@return aRetorno
/*/
//---------------------------------------------------------------------------------------
User Function FSTBLINF(cTbl)
Local 	aProTbl		:= {}

Local 	cQry			:= ""
Local		cHdlInt		:=	SuperGetMv( "FS_INTDBAM" , .F., " " )  // Parâmetro utilizado para o ambiente da base de integração
Local		cEndIp		:=	SuperGetMv( "FS_INTDBIP" , .F., " " )	// Parâmetro utilizado para informar o IP do servidor da base de integração
Local		cAlsTem		:=	GetNextAlias()

Local 	nHdlInt		:=	-1
Local 	nHdlErp		:=	AdvConnection()

Default 	cTbl			:= ""

If !Empty(cHdlInt) .And. !Empty(cEndIp)
	nHdlInt		:=	TcLink(cHdlInt,cEndIp)
EndIf

If nHdlInt < 0
	ConOut("Nao foi possivel realizar conexao com banco de dados de integracao. Gentileza verificar configuracoes." + DtoC(Date())+" - "+Time())
	Conout("TOPMIX222222222222") 
Else
    Conout("TOPMIX1111111111111111111")
	cQry	+=			"SELECT"
	cQry	+= cEol + "		COLUNAS.NAME AS COLUNA,"
	cQry	+=	cEol + "		TIPOS.NAME AS TIPO,"
	cQry	+=	cEol + "		COLUNAS.LENGTH AS TAMANHO,"
	cQry	+=	cEol + "		COLUNAS.ISNULLABLE AS EH_NULO"		
	
	cQry	+= cEol + "FROM "
	cQry	+= cEol + "		SYSOBJECTS AS TABELAS, "
	cQry	+= cEol + "		SYSCOLUMNS AS COLUNAS, "
	cQry	+= cEol + "		SYSTYPES   AS TIPOS "  
	
	cQry	+= cEol + "WHERE "
	cQry	+= cEol + "    TABELAS.ID = COLUNAS.ID"
	cQry	+= cEol + "    AND COLUNAS.USERTYPE = TIPOS.USERTYPE"
	cQry	+= cEol + "    AND TABELAS.NAME = '"+cTbl+"'"
	cQry	+= cEol + "ORDER BY"
	cQry	+= cEol + "		COLUNA"
	
	TCSetConn(nHdlInt)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAlsTem, .F., .T.)
	
	While (cAlsTem)->(!Eof())
		AAdd(aProTbl, {(cAlsTem)->(COLUNA), (cAlsTem)->(TIPO), (cAlsTem)->(TAMANHO),(cAlsTem)->(EH_NULO)})	
		(cAlsTem)->(dbSkip())		
	EndDo     
	
	TCSetConn(nHdlErp)
EndIf

TcUnlink(nHdlInt)

Return AClone(aProTbl)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSSETERR
Salva o erro ocorrido nas rotinas de integração com o KP
        
@author Fernando Ferreira
@since 25/10/2011 
@param cFilOri	-	Filial de Origem do erro
@param dDatErr	-	Data da ocorrência do erro
@param cHorErr	-	Hora da ocorrência do erro
@param cPedKp	-	Número do Pedido no Kp
@param cRot		-	Rotina que disparou o erro
@param mErr		- 	Mensagem de erro.
@return Nil
/*/
//---------------------------------------------------------------------------------------
User Function FSSETERR(cFilOri, dDatErr, cHorErr, cPedKp, cRot, mErr)
Default	cFilOri	:=	""
Default	dDatErr	:=	""
Default	cHorErr	:=	""
Default	cPedKp	:=	""
Default	cRot		:=	""
Default	mErr		:= ""

If (Empty(dDatErr) .Or. Empty(cHorErr) .Or. Empty(cPedKp) .Or. Empty(cRot) .Or. Empty(mErr))
	Conout("Nao foi possivel gravar o erro. Parametros informados, sao insuficientes para realizar a gravacao.")
Else                            
	cPedKp := Iif(ValType(cPedKp) == "N",cValToChar(cPedKp),cPedKp)
	RecLock("P00", .T.)
	P00->P00_ID			:=	GetSXENum("P00","P00_ID")                                                                                                       							
	P00->P00_FILIAL 	:=	xFilial("P00")
	P00->P00_FILORI 	:= cFilOri
	P00->P00_DATA	 	:=	dDatErr
	P00->P00_HORA		:=	cHorErr
	P00->P00_PEDKP 	:=	cPedKp
	P00->P00_ROTINA 	:=	cRot
	P00->P00_ERRO		:=	mErr
	P00->(MsUnLock())
	ConfirmSX8()
EndIf

Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FArrSigAut
Função que monta e retorna o array com os dados para execução do 
SigaAuto.c
         
@author Fernando dos Santos Ferreira 
@since 25/10/2011 
@version P11      
@param	cAlias	Alias da tabela
@param	cPrf		Prefixo da tabela
@return aDadSigAut - Array com os dados para processamento do sigaauto                  
/*/ 
//------------------------------------------------------------------ 
User Function FArrSigAut(cAlias,cPrf)    

Local		aDadSigAut		:= {} 
  
Local		cPrfAtu			:= ""
Local		nXi 				:= 0
Local		nQtdCol			:= ""        
Local		cTipDad			:= ""
Local		xCntCmp			:= ""

Default	cAlias 			:= ""
Default 	cPrf				:= ""

nQtdCol		:=	(cAlias)->(FCount())

If Empty(cPrf)
	For nXi := 1 To nQtdCol
		cCmp := (cAlias)->(FieldName(nXi))		
		Aadd(aDadSigAut,{cCmp,&((cAlias)+"->"+cCmp),Nil})
	Next     
Else
	For nXi := 1 To nQtdCol
		cCmp	:= (cAlias)->(FieldName(nXi))
		cPrfAtu := SubStr((cAlias)->(FieldName(nXi)),1,At('_',cCmp)-1)

		If cPrfAtu == cPrf
			cTipDad := Iif(Len(TamSx3(cCmp))== 3,TamSx3(cCmp)[3],"")
			xCntCmp := &((cAlias)+"->"+cCmp)
			If cTipDad == "D" .And. ValType(xCntCmp) == "C"
				Aadd(aDadSigAut,{cCmp,StoD(xCntCmp),Nil})
			Else
				Aadd(aDadSigAut,{cCmp,xCntCmp,Nil})
			EndIf
		EndIf
	Next     
EndIf     

Return AClone(aDadSigAut)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSTblDtb
Função que cria o arquivo de trabalho de acordo com a consulta passada
como parâmetro.
         
@author Fernando dos Santos Ferreira 
@since 04/08/2011 
@version P11
@param      cAlias   Alias usado para nomear a consulta
@param      nTip   	Tipo do processamento
@return		cAli		Alias do arquivo de trabalho.
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     		Motivo 
30/01/2011  Fernando Ferreira    Inclusão do campo customizado C6_ABTMAT2
22/03/2013	Fernando Ferreira		Inclusão dos campos C5_ZENDOB,C5_ZNUMOB,C5_ZCOMOB,
											C5_BAIROB,C5_ZMUNOB,C5_ZESTOB,C5_ZCEPOB, C5_OBRA, C5_MUNPRES
/*/ 
//------------------------------------------------------------------ 
User Function FSTblDtb(cTbl, nTip)

Local 	cQry			:= "" 

Local 	cAli			:= GetNextAlias()
Local    aUf         

Default	cTbl			:= "NFD"
Default	nTip			:= 1
Private  cExecSQL    := "" // Atualizado na rotina FSCodUf()
                                                                        

aUF := U_FSCodUf()

cExecSQL := StrTran(cExecSQL,"XVARTMP1","C5.C5_ZESTOB")
cExecSQL := StrTran(cExecSQL,"XVARTMP2","C5.C5_ZMUNOB")

TcSetConn(nHdlInt) 
Do Case   
	// Importação de Controle de  Fatura.	                                     
	Case Upper(cTbl) == "P02" .And. nTip == 1
		cQry	+= cEol + "SELECT  "
		cQry	+= cEol + "		P2.P02_FILIAL, "
		cQry	+= cEol + "		P2.P02_FLORI1, "
		cQry	+= cEol + "		SUBSTRING(REPLACE(CONVERT(CHAR(10), P2.P02_DTEMI1,102), '.' , ''), 1,8) P02_DTEMI1, "
		cQry	+= cEol + "		P2.P02_NUM1, "
		cQry	+= cEol + "		P2.P02_SERIE1, "
		cQry	+= cEol + "		P2.P02_FLORI2, "
		cQry	+= cEol + "		SUBSTRING(REPLACE(CONVERT(CHAR(10), P2.P02_DTEMI2,102), '.' , ''), 1,8) P02_DTEMI2, "
		cQry	+= cEol + "		P2.P02_NUM2, "
		cQry	+= cEol + "		P2.P02_SERIE2,"
		cQry	+= cEol + "		P2.P02_ID"
		cQry	+= cEol + "FROM"
		cQry	+= cEol + "		P02 P2"
		cQry	+= cEol + "WHERE"
		cQry	+= cEol + "		P2.DATAINTERFACE IS NULL"
		cQry	+= cEol + "AND	P2.P02_FILIAL ='"+cFilAnt+"'"
		
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAli, .F., .T.)
	// Títulos Provisorios
	Case Upper(cTbl) == "SE1" .And. nTip == 1
		cQry	+= cEol + "SELECT " 
		cQry	+= cEol + "		E1.E1_FILIAL,"		
		cQry	+= cEol + "		E1.E1_PREFIXO,"
		cQry	+= cEol + "		E1.E1_NUM,"
		cQry	+= cEol + "		E1.E1_ZREMES,"
		cQry	+= cEol + "		E1.E1_PARCELA,"
		cQry	+= cEol + "		E1.E1_CLIENTE,"
		cQry	+= cEol + "		E1.E1_LOJA,"
		cQry	+= cEol + "		E1.E1_TIPO,"
		cQry	+= cEol + "		E1.E1_FILORIG,"
		cQry	+= cEol + "		SUBSTRING(REPLACE(CONVERT(CHAR(10), E1.E1_EMISSAO,102), '.', ''), 1,8) E1_EMISSAO,"
		cQry	+= cEol + "		SUBSTRING(REPLACE(CONVERT(CHAR(10), E1.E1_VENCTO,102), '.' , ''), 1,8) E1_VENCTO,"
		cQry	+= cEol + "		E1.E1_VALOR,"
		cQry	+= cEol + "		E1.E1_HIST,"
		cQry	+= cEol + "		E1.E1_NATUREZ 	"
		cQry	+= cEol + "FROM "
		cQry	+= cEol + "		SE1 E1"
		cQry	+= cEol + "WHERE "
		cQry	+= cEol + "		E1.DATAINTERFACE IS NULL	"  
		// Realizo filtro usando o cFilAnt por causa do SE1 ser compartilhado.
		cQry	+= cEol + "AND	E1.E1_FILORIG ='"+cFilAnt+"'"						
		cQry	+= cEol + "ORDER BY"		
		cQry	+= cEol + "		E1.E1_FILIAL, E1.E1_PREFIXO, E1.E1_NUM, E1.E1_ZREMES, E1.E1_PARCELA "
		
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAli, .F., .T.)		
	
	// Remessa
	Case Upper(cTbl) == "SC5" .And. nTip == 1
		cQry	+= cEol + "SELECT "
		cQry	+= cEol + "		C5.C5_FILIAL,"
		cQry	+= cEol + "		C5.C5_ZPEDIDO,"
		cQry	+= cEol + "		C5.ID,"		
		cQry	+= cEol + "		C5.C5_ZEXCLUI,"
		cQry	+= cEol + "		C5.C5_ZTIPO,"
		cQry	+= cEol + "		C5.C5_ZCHVNFE,"
//INICIO COLEN EM 26072012 
//		cQry	+= cEol + "		C5.C5_CLIENTE,"
//		cQry	+= cEol + "		C5.C5_LOJACLI,"
		cQry	+= cEol + "    CASE WHEN C5.C5_ZTIPO = '2' THEN C5.C5_CLIENTE ELSE '"+Left(AllTrim(GetMv("MV_CLIDANF")),6)+"' END AS C5_CLIENTE, "
		cQry	+= cEol + "    CASE WHEN C5.C5_ZTIPO = '2' THEN C5.C5_LOJACLI ELSE '"+SubStr(AllTrim(GetMv("MV_CLIDANF")),7,2)+"' END AS C5_LOJACLI, "
//FIM
		cQry	+= cEol + "		C5.C5_FORNISS,"		
		cQry	+= cEol + "		SUBSTRING (REPLACE(CONVERT(CHAR(10), C5.C5_EMISSAO,102), '.' , ''), 1,8) C5_EMISSAO,"
		cQry	+= cEol + "		SUBSTRING (REPLACE(CONVERT(CHAR(10), C5.C5_DTEXCNF,102), '.' , ''), 1,8) C5_DTEXCNF,"
		cQry	+= cEol + "		C5.C5_VEICULO,"
		cQry	+= cEol + "		C5.C5_ZCEI,"
		cQry	+= cEol + "		C5.C5_ZCONT,"
		cQry	+= cEol + "		C5.C5_ZCC,"
		cQry	+= cEol + "		C5.C5_ZUF,"
		cQry	+= cEol + "		C5.C5_ZBOLETO,"
		cQry	+= cEol + "		C5.C5_NOTA,"
		cQry	+= cEol + "		C5.C5_SERIE,"
		
		cQry	+= cEol + "		C5.C5_ZENDOB,"
		cQry	+= cEol + "		C5.C5_ZNUMOB,"
		cQry	+= cEol + "		C5.C5_ZCOMOB,"
		cQry	+= cEol + "		C5.C5_ZBAIROB,"
		cQry	+= cEol + "		C5.C5_ZMUNOB,"
		cQry	+= cEol + "		C5.C5_ZESTOB,"
		cQry	+= cEol + "		C5.C5_ZCEPOB,"
		cQry	+= cEol + "		C5.C5_OBRA,"
//		cQry	+= cEol + "		C5.C5_ZESTOB+C5.C5_ZMUNOB AS C5_MUNPRES," 
		cQry	+= cEol + cExecSQL + " AS C5_MUNPRES, "	// Alterado Rodrigo Artur			

//INICIO COLEN EM 26072012 
		cQry	+= cEol + "    C5.C5_CLIENTE AS C5_CLIOBRA, "
		cQry	+= cEol + "    C5.C5_LOJACLI AS C5_LOJOBRA, "
//FIM
		cQry	+= cEol + "		C6.C6_FILIAL,"
		cQry	+= cEol + "		C6.C6_ZPEDIDO,"
		cQry	+= cEol + "		C6.C6_ITEM,"
		cQry	+= cEol + "		C6.ID,"
		cQry	+= cEol + "		C6.C6_PRODUTO,"
		cQry	+= cEol + "		C6.C6_QTDVEN,"
		cQry	+= cEol + "		C6.C6_PRCVEN,"
		cQry	+= cEol + "		C6.C6_ZCC "
		cQry	+= cEol + "FROM "
		cQry	+= cEol + "			SC5 C5, SC6 C6	"
		cQry	+= cEol + "WHERE"                                    
		cQry	+= cEol + "		C5.C5_FILIAL			= '" + xFilial("SC5") + "' AND"
		cQry	+= cEol + "		C5.C5_ZTIPO				= '1' 				AND"
		cQry	+= cEol + "		C5.DATAINTERFACE_PR 	IS NULL	  			AND"
		cQry	+= cEol + "		C5.C5_FILIAL 			= C6.C6_FILIAL		AND"
		cQry	+= cEol + "		C5.C5_ZPEDIDO			= C6.C6_ZPEDIDO 		"
		cQry	+= cEol + "ORDER BY	" 
		cQry	+= cEol + "		C5.C5_FILIAL, C5.C5_EMISSAO , C5.C5_ZPEDIDO  , C5.C5_CLIENTE , C5.ID	" 	
		
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAli, .F., .T.)
		       
	// Fatura
	Case Upper(cTbl) == "SC5" .And. nTip == 2
		cQry	+= cEol + "SELECT "
		cQry	+= cEol + "		C5.C5_FILIAL, "
		cQry	+= cEol + "		C5.C5_ZPEDIDO, "
		cQry	+= cEol + "		C5.ID, 		"
		cQry	+= cEol + "		C5.C5_ZEXCLUI, "
		cQry	+= cEol + "		C5.C5_ZTIPO, "
//INICIO COLEN EM 26072012 
//		cQry	+= cEol + "		C5.C5_CLIENTE, "
//		cQry	+= cEol + "		C5.C5_LOJACLI, "
		cQry	+= cEol + "    CASE WHEN C5.C5_ZTIPO = '2' THEN C5.C5_CLIENTE ELSE '"+Left(AllTrim(GetMv("MV_CLIDANF")),6)+"' END AS C5_CLIENTE, "
		cQry	+= cEol + "    CASE WHEN C5.C5_ZTIPO = '2' THEN C5.C5_LOJACLI ELSE '"+SubStr(AllTrim(GetMv("MV_CLIDANF")),7,2)+"' END AS C5_LOJACLI, "
//FIM
		cQry	+= cEol + "		C5.C5_VEND1, "
		cQry	+= cEol + "		SUBSTRING (REPLACE(CONVERT(CHAR(10), C5.C5_EMISSAO,102), '.' , ''), 1,8) C5_EMISSAO,"
		cQry	+= cEol + "		C5.C5_PARC1, "
		cQry	+= cEol + "		SUBSTRING(REPLACE(CONVERT(CHAR(10), C5.C5_DATA1,102), '.' , ''), 1,8) C5_DATA1,"
		cQry	+= cEol + "		C5.C5_PARC2, "
		cQry	+= cEol + "		SUBSTRING(REPLACE(CONVERT(CHAR(10), C5.C5_DATA2,102), '.' , ''), 1,8) C5_DATA2,"
		cQry	+= cEol + "		C5.C5_PARC3, "
		cQry	+= cEol + "		SUBSTRING(REPLACE(CONVERT(CHAR(10), C5.C5_DATA3,102), '.' , ''), 1,8) C5_DATA3,"
		cQry	+= cEol + "		C5.C5_PARC4, "
		cQry	+= cEol + "		SUBSTRING(REPLACE(CONVERT(CHAR(10), C5.C5_DATA4,102), '.' , ''), 1,8) C5_DATA4,"
		cQry	+= cEol + "		C5.C5_PARC5, "
		cQry	+= cEol + "		SUBSTRING(REPLACE(CONVERT(CHAR(10), C5.C5_DATA5,102), '.' , ''), 1,8) C5_DATA5,"
		cQry	+= cEol + "		C5.C5_PARC6, "
		cQry	+= cEol + "		SUBSTRING(REPLACE(CONVERT(CHAR(10), C5.C5_DATA6,102), '.' , ''), 1,8) C5_DATA6,"
		cQry	+= cEol + "		C5.C5_RECISS, "
		cQry	+= cEol + "		C5.C5_VEICULO, "
		cQry	+= cEol + "		C5.C5_ZCEI, "
		cQry	+= cEol + "		C5.C5_ZCONT, "
		cQry	+= cEol + "		C5.C5_ZENDCOB, "
		cQry	+= cEol + "		C5.C5_ZENDNUM, "
		cQry	+= cEol + "		C5.C5_ZCOMPLE, "
		cQry	+= cEol + "		C5.C5_ZBAIROC, "
		cQry	+= cEol + "		C5.C5_ZCOD_MU,  "
		cQry	+= cEol + "		C5.C5_ZMUN, "
		cQry	+= cEol + "		C5.C5_ZEST, "
		cQry	+= cEol + "		C5.C5_ZCEP, "
		cQry	+= cEol + "		C5.C5_ZENDOB, "
		cQry	+= cEol + "		C5.C5_ZNUMOB, "
		cQry	+= cEol + "		C5.C5_ZCOMOB, "
		cQry	+= cEol + "		C5.C5_ZBAIROB, "
		cQry	+= cEol + "		C5.C5_ZMUNOB, "
	   cQry	+= cEol + "		C5.C5_ZMUNOB AS C5_MUNPRES, " 
		cQry	+= cEol + "		C5.C5_ZESTOB, "
		cQry	+= cEol + "		C5.C5_ZCEPOB, "
		cQry	+= cEol + "		C5.C5_ZBOLETO, "
		cQry	+= cEol + "		C5.C5_ZCC, "
		cQry	+= cEol + "		C5.C5_ZUF,"
		cQry	+= cEol + "		C5.C5_OBRA,"
		cQry	+= cEol + "		C5.C5_FORNISS,"
		cQry	+= cEol + "		C5_ZDESCPG, "		  //MAX: 05-06-2012
		cQry	+= cEol + "		C5_ZNUMFAT, "		  //MAX: 05-06-2012
//INICIO COLEN EM 26072012 
		cQry	+= cEol + "    C5.C5_CLIENTE AS C5_CLIOBRA, "
		cQry	+= cEol + "    C5.C5_LOJACLI AS C5_LOJACLI, "
//FIM
		cQry	+= cEol + "		C6.C6_FILIAL, "
		cQry	+= cEol + "		C6.C6_ZPEDIDO, "
		cQry	+= cEol + "		C6.C6_ITEM, "
		cQry	+= cEol + "		C6.C6_PRODUTO, "
		cQry	+= cEol + "		C6.C6_QTDVEN, "
		cQry	+= cEol + "		C6.C6_PRCVEN, "
		cQry	+= cEol + "		C6.C6_TES, "
		cQry	+= cEol + "		C6.C6_ABATMAT, "
		cQry	+= cEol + "		C6.C6_ZCC, "
		cQry	+= cEol + "		C6.C6_ZCODIS, "
		cQry	+= cEol + "		C6.C6_ZALIQIS, "
		cQry	+= cEol + "		C6.C6_ZCNAE, "		
		cQry	+= cEol + "		C6.C6_ZTRIBMU, "				
		cQry	+= cEol + "		C6.C6_DESCCOM,"
		cQry	+= cEol + "		C6.C6_CODF, "
		cQry	+= cEol + "		CONVERT(VARCHAR(4000),CONVERT(VARBINARY(4000),C6.C6_ZREMES)) C6_ZREMES	"
		cQry	+= cEol + "FROM "
		cQry	+= cEol + "		SC5 C5, SC6 C6"
		cQry	+= cEol + "WHERE"
		cQry	+= cEol + "		C5.C5_FILIAL			= '" + xFilial("SC5") + "' AND"
		cQry	+= cEol + "		C5.C5_ZTIPO				= '2' 				AND"
		cQry	+= cEol + "		C5.DATAINTERFACE_PF 	IS NULL	  			AND"
		cQry	+= cEol + "		C5.C5_FILIAL 			= C6.C6_FILIAL		AND"
		cQry	+= cEol + "		C5.C5_ZPEDIDO			= C6.C6_ZPEDIDO 		"
		cQry	+= cEol + "ORDER BY	 "
		cQry	+= cEol + "		C5.C5_FILIAL, C5.C5_EMISSAO , C5.C5_ZPEDIDO  , C5.C5_CLIENTE , C5.ID	" 	
				
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAli, .F., .T.)		
		
	Otherwise
		conout("Tabela Informada não existe.")
EndCase
TcSetConn(nHdlErp)
//ConOut("======================= DEBUG SELECT ====================================")
//ConOut(cQry)
//ConOut("<====================== /DEBUG SELECT ===================================>")

Return (cAli)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSCloAre
Fecha e apaga os arquivos temporários criados pela rotina.
         
@author Fernando dos Santos Ferreira
@since 25/07/2011 
@version P11  
@param      cArqTemp   Arquivo temporário 
@return     Nil
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
User Function FSCloAre(cArqTemp)

Default	cArqTemp	:=	"TEMP"

If Select(cArqTemp) != 0
	(cArqTemp)->(dbCloseArea())

	If File(cArqTemp+GetDBExtension())
		FErase(cArqTemp+GetDBExtension())
	EndIf  
	
EndIf  

Return Nil 
           
//-------------------------------------------------------------------
/*/{Protheus.doc} FSAceArr
Coloca o array para sigaauto na mesma ordem do SX3

@author	Cláudio Luiz da Silva
@since    

@param   aArrPar   Array tipo cabecalho
@param   cAliasSX3 Alias da tabela a ser pesquisada

@return  aArrAux   Array ordenado
/*/
//-------------------------------------------------------------------
User Function FSAceArr(aArrPar, cAliasSX3)

Local nPos		:= 0
Local nXi   	:= 0
Local aArrAux	:= {}

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAliasSX3,.T.)
While !Eof() .And. (X3_ARQUIVO==cAliasSX3)
	
	//Acerta array com somente uma linha
	If (nPos:= aScan(aArrPar,{|x| Alltrim(x[1]) == Alltrim(X3_CAMPO) })) <> 0
		aadd(aArrAux,aClone(aArrPar[nPos]))
	EndIf
	
	dbSkip()
	
EndDo

Return(aArrAux)

//-------------------------------------------------------------------
/*/{Protheus.doc} FSAceIte
Coloca o array para sigaauto na mesma ordem do SX3, utilizado para array de itens

@author	Cláudio Luiz da Silva
@since    

@param   aArrPar   Array tipo item
@param   cAliasSX3 Alias da tabela a ser pesquisada

@return  aArrAux   Array ordenado
/*/
//-------------------------------------------------------------------
User Function FSAceIte(aArrPar, cAliasSX3)

Local aArrAux	:= {}
Local aArrAux2 := {}
Local nPos		:= 0
Local nXi 		:= 0

//Acerta array com varias linhas
For nXi:= 1 To Len(aArrPar)
	
	aArrAux2:= aArrPar[nXi]
	aArrAux2:= U_FSAceArr(aArrAux2, cAliasSX3)
	
	If Len(aArrAux2) <> 0
		aadd(aArrAux,aClone(aArrAux2))
	EndIf
	
Next nXi

Return(aArrAux)

//-------------------------------------------------------------------
/*/{Protheus.doc} FSLibPdV
Efetua a liberacao do pedido de venda.
A transacao devera ser controlada na rotina de origem.

@author	   Cláudio Luiz da Silva
@since	   

@param 		cPedVen    Numero do Pedido de Venda
@param 		nTipo      1-Avalia bloqueio 2-Libera pedido

@return     lRet       verdadeiro se todos os itens forem liberados
/*/
//-------------------------------------------------------------------
User Function FSLibPdV(cPedVen,nTipo)

Local aAreaOld	:= GetArea()
Local aAreaSC5	:= SC5->(GetArea())
Local aBloqueio:= {}
Local aPvlNfs	:= {}

Default nTipo  := 2

dbSelectArea("SC5")
dbSetOrder(1)
dbSeek(xFilial("SC5") + cPedVen)
If !Eof()

	//Rotina padrao de liberacao do pedido
	Ma410LbNfs(nTipo,@aPvlNfs,@aBloqueio)

EndIf

RestArea(aAreaSC5)
RestArea(aAreaOld)

Return({Len(aPvlNfs)<>0,Len(aBloqueio)==0})

//-------------------------------------------------------------------
/*/{Protheus.doc} FSLibBlq
Efetua a liberacao de bloqueio de estoque.

@author	   Cláudio Luiz da Silva
@since	   25/05/2010

@param 		cPedVen   Pedido de Venda
/*/
//-------------------------------------------------------------------
User Function FSLibBlq(cPedVen)

Local aAreaOld	:= GetArea()
Local aAreaSC5	:= SC5->(GetArea())
Local aAreaSC6	:= SC6->(GetArea())
Local cSeek		:= ""

dbSelectArea("SC6")
dbSetOrder(1)
dbSeek(cSeek:=xFilial("SC6")+cPedVen)
While  !Eof() .And. cSeek==C6_Filial+C6_Num
	
	dbSelectArea("SC9")
	dbSetOrder(1)
	dbSeek(cSeek2:=xFilial("SC9")+SC6->C6_Num+SC6->C6_Item)
	While !Eof() .And. cSeek2==C9_Filial+C9_Pedido+C9_Item

		MaAvalSC9("SC9",6,{{ "","","","",SC9->C9_QTDLIB,SC9->C9_QTDLIB2,Ctod(""),"","","",SC9->C9_LOCAL}},Nil,Nil,.F.)
		Reclock("SC9",.F.)
		SC9->C9_BLEST := ""
		MsUnlock()
		MaAvalSC9("SC9",5,{{ "","","","",SC9->C9_QTDLIB,SC9->C9_QTDLIB2,Ctod(""),"","","",SC9->C9_LOCAL}})
   
		dbSelectArea("SC9")
		dbSkip()
	EndDo
	
	dbSelectArea("SC6")
	dbSkip()
EndDo

SC6->(RestArea(aAreaSC6))
SC5->(RestArea(aAreaSC5))
RestArea(aAreaOld)

Return(Nil)
           
//-------------------------------------------------------------------
/*/{Protheus.doc} FSGerNFS
Efetua geracao da nota fiscal de saida utilizando processo padrao.
Será utilizado o parametro FS_SERCOF para definir a serie da nota fiscal a ser gerada.

@author	   Cláudio Luiz da Silva
@since	   15/04/2010

@param 		cPedVen   Pedido de Venda

@return     cNota     Numero da nota fiscal gerada
/*/
//-------------------------------------------------------------------
User Function FSGerNFS(cPedVen,cTipPedNF,cTipPed)

Local 	aAreaOld			:= GetArea()
Local 	cNota				:= ""
Local		cSerie			:= ""
Local		aSerDis			:=	{}
Local		dDatOld			:= dDataBase

Default 	cTipPed			:=	""
Default	cTipPedNF   	:=	""
            
aSerDis	:=	StrToKarr(AllTrim(GetMV("MV_ESPECIE")), ";")

For nXi := 1 To Len(aSerDis)
	If AllTrim(cTipPedNF) $ aSerDis[nXi]
		cSerie	:=	SubStr(aSerDis[nXi], 1, At("=",aSerDis[nXi]) - 1)
	EndIf
Next                                                                                                              

If !Empty(cSerie)
	dDataBase := dDatBtnTop
   Conout(replicate("_",80))
	Conout("Gerando nota do pedido: "+cPedVen+" serie: "+cSerie+" Hora: "+TIME()+"PROXIMO MV_DOCSEQ: "+Soma1(GetMv("MV_DOCSEQ")))	   
   __lNoErro := .T. // Inicio Alteração feita em 20151007
   CheckSeque()
   Do While ! __lNoErro
      CheckSeque()
   Enddo
   // fim Alteração feita em 20151007
	IncNota(cPedVen, cSerie)

	DbCommit()
	SD2->(ConfirmSx8())
	Conout("Nota Gerada. - "+SF2->(F2_DOC+"/"+F2_SERIE)+" Sequencial do MV_DOCSEQ gravado: "+GetMv("MV_DOCSEQ"))
   Conout(replicate("_",80))
   Conout("")
   Conout("")   
	dDataBase := dDatOld
	cNota   := SF2->F2_DOC 
EndIf

RestArea(aAreaOld)

Return(cNota)
                      
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSExcNot
Função que relaliza a exclusão de nota fiscal de saida
         
@author Fernando Ferreira 
@since 04/08/2011 
@version P11
@param      cDoc   Número da nota que será excluida
@param      cSer   Serie da nota que será excluida 
@param      cCli   Cliente da nota que será excluida
@param      cLoj   Loja da nota que será excluida  

@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     		Motivo 

/*/ 
//------------------------------------------------------------------ 
User Function FSExcNot(cDoc, cSer, cCli, cLoj, lMstCot, lAglCot, lCont, lCar)
Local		aRegSD2 	:= {}
Local		aRegSE1 	:= {}
Local		aRegSE2 	:= {}
Local		dDtaOld	:=  dDataBase

Default	lMstCot	:=	SuperGetMv( "FS_LACCTAB", .T.)
Default	lAglCot	:=	SuperGetMv( "FS_AGTLACC", .T.)
Default	lCont		:=	SuperGetMv( "FS_CTBLINE", .T.)
Default	lCar		:=	SuperGetMv( "FS_PEDCART", .T.)

Default	cDoc		:=	""  
Default	cSer		:=	""
Default	cCli		:=	""
Default	cLoj		:=	""
cSer := Left(cSer + Space(3) , Len(SF2->F2_SERIE))
SF2->(dbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
If SF2->(dbSeek(xFilial("SF2")+cDoc+cSer+cCli+cLoj))
	dDataBase := SF2->F2_EMISSAO // dDatExcBkp // Alterado a data para a emissao da nota, pois o cancelamento nao estava sendo aplicado se canc. no dia seguinte.
	If MaCanDelF2("SF2", SF2->(Recno()), @aRegSD2,@aRegSE1,@aRegSE2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estorna o documento de saida                                   ³
		//³ A variavel dDatExcBkp é privada sendo preenchida no FSINTP03	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,lMstCot,lAglCot,lCont,lCar))	
		SF2->(MsUnLockAll())	 

		DbSelectArea("SF3")
		DbSetOrder(4) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
      If SF3->(dbSeek(xFilial("SF3")+cCli+cLoj+cDoc+cSer,.T.))
		   RecLock("SF3")
		   Replace SF3->F3_DTCANC With dDatExcBkp // atualiza a data de cancelamento da nota fiscal
		   MsUnlock("SF3")
      Endif
      
      DbSelectArea("SFT")
      DbSetOrder(1)//FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
      If SFT->(dbSeek(xFilial("SFT")+'S'+cSer+cDoc+cCli+cLoj,.T.))
         Do While ! Eof() .And. xFilial("SFT")+'S'+cSer+cDoc+cCli+cLoj == SFT->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA)
		      RecLock("SFT")
		      Replace SFT->FT_DTCANC With dDatExcBkp // atualiza a data de cancelamento da nota fiscal
		      MsUnlock("SFT")
		      DbSkip()
		   Enddo   
      Endif		
	EndIf                  
	dDataBase := dDtaOld
Else
	Conout("Não existe nota para o pedido informado.")	
EndIf
Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSExcNfs
Realiza a exclusão das notas

@author Fernando Ferreira
@since 25/10/2011 
@version P11
@param 	aNtsExc de notas a ser excluidas
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSExcNfs(aNtsExc)
Local 	nXi		:= 0
Default	aNtsExc	:=	{}

If !Empty(aNtsExc)	
	For nXi := 1 to len(aNtsExc)
		U_FSExcNot(aNtsExc[nXi][1], aNtsExc[nXi][2], aNtsExc[nXi][3], aNtsExc[nXi][4])
	Next
EndIf

Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSPrpExc
Carregas os dados do pedido para exclusão

@author Fernando Ferreira
@since 25/10/2011 
@version P11
@param	aIte - Itens do pedido de venda
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSPrpExc(aIte)
Local		aRet		:=	{}   
Local		aAreOld	:=	GetArea("SD2")
Local		aAreSf2	:= GetArea("SF2")
Local		aRegSD2	:= {}
Local		aRegSE1	:= {}
Local		aRegSE2	:= {}

Local		cDoc		:=	""
Local		cSer     :=	""
Local		cCli     :=	""
Local		cLoj     :=	""  

Local		dDtaOld	:= dDataBase

Local		nPosDoc := 0
Local		nPosSer := 0
Local		nPosCli := 0
Local		nPosLoj := 0
 
Local		nXi		:= 1

Default	aIte		:= {}

If !Empty(aIte)              
	nPosDoc := aScan(aIte[1], {|x| x[1] == "C6_NOTA"})    
	nPosSer := aScan(aIte[1], {|x| x[1] == "C6_SERIE"})    
	nPosCli := aScan(aIte[1], {|x| x[1] == "C6_CLI"})
	nPosLoj := aScan(aIte[1], {|x| x[1] == "C6_LOJA"})

	SF2->(dbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	
	For nXi := 1 To Len(aIte)
		SF2->(dbSeek(xFilial("SF2")+aIte[nXi][nPosDoc][2]+aIte[nXi][nPosSer][2]+aIte[nXi][nPosCli][2]+aIte[nXi][nPosLoj][2]))
		If SF2->(!Eof())	.And. SF2->F2_FILIAL		== xFilial("SF2");
								.And. SF2->F2_DOC			== aIte[nXi][nPosDoc][2];
								.And.	SF2->F2_SERIE		== aIte[nXi][nPosSer][2];
								.And. SF2->F2_CLIENTE	== aIte[nXi][nPosCli][2];
								.And. SF2->F2_LOJA		== aIte[nXi][nPosLoj][2]
			dDataBase := SF2->F2_EMISSAO //dDatExcBkp  // Alterado a data para a emissao da nota, pois o cancelamento nao estava sendo aplicado se canc. no dia seguinte.
			If MaCanDelF2("SF2", SF2->(Recno()), @aRegSD2,@aRegSE1,@aRegSE2)
				AAdd(aRet,{;
				aIte[nXi][nPosDoc][2],;// N. NF
				aIte[nXi][nPosSer][2],;// Serie NF
				aIte[nXi][nPosCli][2],;// Cod. Cliente
				aIte[nXi][nPosLoj][2]})// Loja Cliente
			EndIf
			dDataBase	:= dDtaOld
		EndIf
	Next
EndIf

RestArea(aAreSf2)
RestArea(aAreOld)
Return AClone(aRet) 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSGetDad
Carregas os dados do pedido para exclusão

@author Fernando Ferreira
@since 25/10/2011 
@version P11
@param cFil - Filial do Pedido de Venda
@param cPed - Código de Pedido de Venda
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSGetDad(cFil, cPed)
Local		aAreOld	:=	{}
Local		aDadCab	:=	{}
Local		aDadIte	:= {}
Local		aRet		:=	{}

Local		nIdt		:=	0  

Default	cAli		:=	""
Default	cFil		:= xFilial("SC5")
Default	cPed		:=	""       

cFil := SubStr(cFil,1,Len(CriaVar("C5_FILIAL")))

AAdd(aAreOld,GetArea("SC5"))
AAdd(aAreOld,GetArea("SC6"))

aDadCab	:= {}
aDadIte	:= {}

SC5->(dbOrderNickName("FSIND00002"))
SC6->(dbSetOrder(1))                                            

SC5->(dbSeek(cFil+cPed))

IF SC5->(!Eof()).And. cFil == SC5->C5_FILIAL .And. cPed == SC5->C5_ZPEDIDO
	cFil	:= SC5->C5_FILIAL
	cPed	:=	SC5->C5_ZPEDIDO
	aDadCab	:=	U_FArrSigAut("SC5", "C5")
	
	SC6->(dbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
	While SC6->(!Eof()) .And. SC5->C5_FILIAL	==	SC6->C6_FILIAL	.And.	SC5->C5_NUM	==	SC6->C6_NUM
		AAdd(aDadIte, U_FArrSigAut("SC6", "C6"))
		SC6->(dbSkip())
	EndDo         
EndIf

AAdd(aRet, aDadCab)
AAdd(aRet, aDadIte)

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return AClone(aRet)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSPrcSig
Função realiza a inclusão das NF de Saída da base de integração para a 
base protheus.

@author Fernando Ferreira
@since 25/10/2011 
@version P11
@param	aDadCab	- Dados da capa do pedido de venda
@param	aDadIte	- Itens do pedido de venda.
@param	cOpc		- Opção para processameno do SigaAuto
@param 	cFil 		- Filial do Pedido de Venda          
@param	cPed		- Código do pedido na Integração.
@param	cTip		- Tipo do Pedido de venda
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSPrcSig(aDadCab, aDadIte, nOpc, cFil, cPed, cTip, cDta)
Local 	aCmp		:=	{}
Local 	aWhr		:=	{}
Local 	aAreas   := {SC5->(GetArea()),GetArea()}
Local		cDta		:= DToS(dDataBase)
Local		cRot		:=	"Ped. Rem" 
Local		cMsgErr	:= ""
Local		lRet		:= .T.
Local    lVerifSC5:= .T. // verifica se o ZPEDIDO ja esta gravado na tabela SC5.
Local    lExecSC5 := .T. // se executa o execauto ou nao na gravacao do pedido de venda.

Private	lMsErroAuto	:= .F.

Default	aDadCab	:= {}
Default	aDadIte	:= {}
Default	nOpc 		:= 0
Default	cDta		:= DToS(dDataBase)

If cTip == "2"
	AAdd(aCmp,{"DATAINTERFACE_PF",cDta })
	cRot	:=	"Ped. Fat"
	AAdd(aWhr, {"C5_FILIAL", 	cFil, "="})
	AAdd(aWhr, {"C5_ZPEDIDO", 	cPed, "="})
EndIf

nPosPed := aScan(aDadCab, {|x| AllTrim(x[01]) ==  "C5_ZPEDIDO"})
nPosFil := aScan(aDadCab, {|x| AllTrim(x[01]) ==  "C5_FILIAL"})

ConOut("******************************************************************************")
ConOut("* Iniciando a gravação do pedido")        
ConOut("* Filial do Pedido: "+aDadCab [nPosFil][2])
ConOut("* Pedido de Venda : "+aDadCab [nPosPed][2])
ConOut("******************************************************************************")

Begin Transaction  

   If lVerifSC5 // Verificar se o ZPEDIDO existe no SC5, caso não executar o SIGAAUTO.   
      nPosPed := aScan(aDadCab, {|x| AllTrim(x[01]) ==  "C5_ZPEDIDO"})
      If nPosPed > 0
         DbSelectArea("SC5")
         SC5->(dbOrderNickName("FSIND00002")) // chave filial + ZPEDIDO
         If SC5->(dbSeek(cFil+aDadCab [nPosPed][2]) )
            lExecSC5 := .F.
         Endif   
      Endif
   Endif
   
   If lExecSC5
   	MSExecAuto({|x,y,z| MATA410(x,y,z)}, aDadCab, aDadIte, nOpc)
	Endif
	U_zArrToTxt(aDadCab, .T., "D:\LOGS_FATURAS\cabec_"+aDadCab [nPosPed][2]+".txt")
	U_zArrToTxt(aDadIte, .T., "D:\LOGS_FATURAS\corpo_"+aDadCab [nPosPed][2]+".txt")
	If lMsErroAuto
		ConOut("******************************************************************************")
		ConOut("* Erro no processamento do pedido de venda: "+aDadCab [nPosPed][2])
		ConOut("******************************************************************************")
		
		cMsgErr	:=	MemoRead(NomeAutoLog())
		U_FSSETERR(cFilAnt, dDataBase, Time(), cPed, cRot, cMsgErr)
		Ferase(NomeAutoLog()) 
		lRet	:= .F.
	Else
		If cTip == "2" 
		   ConOut("Preparando.. FSQryUpd - "+Funname())
			U_FSQryUpd(aCmp,"SC5",aWhr)
		EndIf
	EndIf  
	
End Transaction

aEval(aAreas, {|xAux| RestArea(xAux)})

Return lRet

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSGerNot
Função realiza a inclusão das NF de Saída da base de integração para a 
base protheus.

@author Fernando Ferreira
@since 25/10/2011 
@version P11
@param 	cNumPed	- Número do Pedido
@param 	cNumNot	- Número da nota no Kp
@param 	cSerNot	- Serie da nota no kp
@return  cNumNotRet - Número da nota gerada.
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     		Motivo 
16/03/2012  Fernando Ferreira    Inclusão do retorno com o número da nota
/*/ 
//------------------------------------------------------------------ 
User Function FSGerNot(cNumPed,cNumNot, cSerNot)
Local		aAreas		:= {SC5->(GetArea()), GetArea()}
Local		cNumNotRet	:= ""                       
Private	cKpNumNot	:= cNumNot
Private	cKpSerNot	:=	cSerNot

Default	cNumPed		:= ""
Default	cNumNot		:= ""
Default	cSerNot		:= ""

//Efetua liberacao do pedido 
U_FSLibPdV(cNumPed,2)

//Se existir itens bloqueados forca desbloqueio
If !U_FSLibPdV(cNumPed,1)[2]
	U_FSLibBlq(cNumPed)
EndIf

//Avalia se existem itens a faturar e se
//nao existem itens bloqueados do pedido
If U_FSLibPdV(cNumPed,1)[1] .And. U_FSLibPdV(cNumPed,1)[2]
	cNumNotRet	:=	U_FSGerNFS(cNumPed,cSerNot)
	If Empty(cNumNotRet)
		conout("Erro ao tentar gerar a nota de saida de remessa. Pedido:" + cNumPed + " Nota: "+cKpNumNot +" Serie: "+cKpSerNot + " Filial:"+ xFilial("SC5") )
		cMsgErr	:= "Erro ao tentar gerar a nota de saida de remessa. Pedido: " + cNumPed
  		U_FSSETERR(xFilial("P00"), dDataBase, Time(), cNumPed , "Ped. Rem", cMsgErr)		
	EndIf
EndIf 

aEval(aAreas, {|xAux| RestArea(xAux)})
Return cNumNotRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSAbrSM0
Efetua a abertura do SM0
	
@author Claudio Silva
@since 24/06/2010 
@param lSM0Comp		Sigamat aberto 
@return .T.		.F. 	
/*/
//---------------------------------------------------------------------------------------
User Function FSAbrSM0(lSM0Comp)

Local lOpen := .F. 
Local nLoop := 0 

Default lSM0Comp:= .T.

For nLoop := 1 To 20

	If Select("SM0")>0
		dbSelecTArea("SM0")
		SM0->(dbCloseArea())
	EndIf
	dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", lSM0Comp, .F. ) 
	If !Empty( Select( "SM0" ) ) 
		lOpen := .T. 
		dbSetIndex("SIGAMAT.IND") 
		Exit	
	EndIf
	Sleep( 500 ) 

Next nLoop 

Return( lOpen )

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSMsgCus
Efetua a intervenção na descrição do serviço na transmissão para prefeitura.
	
@author Fernando Ferreira
@since 24/06/2010 
@param cNatOper		Natureza da operação a ser transmitida para prefeitura.
@param cNumDoc			Número do documento
@param cSerDoc			Série do documento
@param cCliDoc			Cliente do documento
@param cLojDoc			Loja do documento
@return Nil
/*/
//---------------------------------------------------------------------------------------
User Function FSMsgCus(cNatOper, cNumDup, cPrfDoc, cCliDoc, cLojDoc, cNumDoc, cSerDoc)
Local		aAreOld	:=	{}
Local		aMsgCus	:=	{}
Local		aDadSf2	:=	{}
Local		aDadSe1	:=	{}
Local		aDadSd2	:=	{}
Local		aDadSc6	:=	{}                                                                      
Local		aDadSc5	:=	{}

Local		cNumPed		:=	""
Local		cTelCob		:=	GetMv("FS_TELCOB1")
Local		cFaxCob		:=	GetMv("FS_FAXCOB3")
Local		cMsgAux		:=	""
Local		cMsgFrmDpu  := " SERV. CONCRETAGEM RPS:"
Local		cMsgFrmVal  := " VALOR:"
Local		cMsgFrmVec  := " VENCIMENTO:"

Local		nValIss	:= 0

Local		nTotAbt	:=	0

Default	cNatOper	:=	""
Default	cNumDup	:=	""
Default	cPrfDoc	:= ""
Default	cCliDoc	:=	""
Default	cLojDoc	:=	""
Default	cNumDoc	:=	""
Default	cSerDoc	:=	""


AAdd(aAreOld, GetArea("SC5"))
AAdd(aAreOld, GetArea("SC6"))
AAdd(aAreOld, GetArea("SF2"))
AAdd(aAreOld, GetArea("SD2"))
AAdd(aAreOld, GetArea("SE1"))
AAdd(aAreOld, GetArea("SM4"))

// Carrega informações referentes ao cabeçalho da nota.
SF2->(dbSetOrder(2)) //	Indice 2 SF2:F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
SF2->(dbSeek(xFilial("SF2")+cCliDoc+cLojDoc+cNumDoc+cSerDoc))

If SF2->(!Eof())
	AAdd(aDadSf2, SF2->F2_BASEISS)		// [1]Base de calculo do ISS
EndIf
                 
// Carrega informações referenteas ao titulo gerado pela nota.
SE1->(dbSetOrder(2)) // Indice 2 SE1:E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
SE1->(dbSeek(xFilial("SE1")+cCliDoc+cLojDoc+cPrfDoc+cNumDup))


While SE1->(!Eof())	.And. SE1->E1_FILIAL		== xFilial("SE1");
							.And. SE1->E1_CLIENTE	== cCliDoc;
							.And.	SE1->E1_LOJA		== cLojDoc;
							.And. SE1->E1_PREFIXO	== cPrfDoc;
							.And. SE1->E1_NUM			== cNumDup 
	If SE1->E1_TIPO == "IS-"
		nValIss :=  SE1->E1_VALOR
		SE1->(dbSkip())
	Else
		AAdd(aDadSe1, {SE1->E1_NUM + " " + SE1->E1_PARCELA, SE1->E1_VENCREA, SE1->E1_VALOR})
		SE1->(dbSkip())
	EndIf
EndDo

// Carrega Informações referentes do itens da Nota
SD2->(dbSetOrder(3))	// Indice 3 SD2:D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
SD2->(dbSeek(xFilial("SD2")+cNumDoc+cSerDoc+cCliDoc+cLojDoc))

If SD2->(!Eof())
	AAdd(aDadSd2, SD2->D2_ALIQISS)		// [1]Aliquota de ISS utilizada
EndIf

// Carrega informações referentes dos itens do pedido de venda.
SC6->(dbSetOrder(4)) // Indice 4 SC6:C6_FILIAL+C6_NOTA+C6_SERIE
SC6->(dbSeek(xFilial("SC6")+cNumDoc+cSerDoc))

cNumPed	:=	SC6->C6_NUM

// Realiza a soma dos abatimentos dos itens do pedido
While SC6->(!Eof())	.And. SC6->C6_FILIAL == xFilial("SC6");
							.And.	SC6->C6_NOTA	==	cNumDoc;
							.And.	SC6->C6_SERIE	== cSerDoc	
	nTotAbt	+=	SC6->C6_ABATMAT
	SC6->(dbSkip())
EndDo

AAdd(aDadSc6, nTotAbt)

SC5->(dbSetOrder(1)) // Indice 1 SC5:C5_FILIAL+C5_NUM
SC5->(dbSeek(xFilial("SC5")+cNumPed))

// Carrega as informações referenteas a cabeçalho do pedido.
If SC5->(!Eof()) .And. SC5->(Found())
	AAdd(aDadSc5, SC5->C5_ZCC)			// [1] Número do centro de custo,  usado com número da obra - André Duque
	AAdd(aDadSc5, SC5->C5_ZENDOB)		// [2] Endereço da obra
	AAdd(aDadSc5, SC5->C5_ZNUMOB)		// [3] Número da obra
	AAdd(aDadSc5, SC5->C5_ZCOMOB)		//	[4] Complemento de Endereço da obra
	AAdd(aDadSc5, SC5->C5_ZBAIROB)	// [5] Bairro da obra
	AAdd(aDadSc5, SC5->C5_ZMUNOB)		// [6] Municipio da obra
	AAdd(aDadSc5, SC5->C5_ZESTOB)		// [7] Estado da obra
	AAdd(aDadSc5, SC5->C5_ZCEI)		// [8] Número do CEI
	AAdd(aDadSc5, SC5->C5_MENNOTA)	// [9] Mensagem da Nota
EndIf
            
cMsgAux	+=	"OBRA " + AllTrim(aDadSc5[1]) + ": " 	+ AllTrim(aDadSc5[2]) + ", " + AllTrim(aDadSc5[3])
cMsgAux	+=	" "	  + AllTrim(aDadSc5[4]) + " "		+ AllTrim(aDadSc5[5]) + "  " + AllTrim(aDadSc5[6])
cMsgAux	+=	AllTrim(aDadSc5[7])

For nXi := 1 To Len(aDadSe1)
	cMsgFrmDpu += " " + aDadSe1[nXi][1]
	cMsgFrmVec += " " + DToc(aDadSe1[nXi][2])
	cMsgFrmVal += " " + Transform(aDadSe1[nXi][3], "@E 9,999,999.99")
Next nXi
                     
cMsgAux	+=	cMsgFrmDpu
cMsgAux	+=	cMsgFrmVec
cMsgAux	+=	cMsgFrmVal
cMsgAux	+=	" BASE CALC ISS: " +  Transform(aDadSf2[1], "@E 9,999,999.99")
cMsgAux	+=	" ALIQ ISS: " + Transform(aDadSd2[1], "@E 9,999,999.99") + " VALOR ISS: " + Transform(nValIss, "@E 9,999,999.99")
cMsgAux	+=	" MAT. ADQUIRIDO DE TERC. APLICADO NO SERV. R$ " + Transform(nTotAbt, "@E 9,999,999.99")
If cFilAnt == '010104'	
	cMsgAux  += " " + "PROCESSO JUDICIAL N.2009.002.014530-1"
EndIf

cMsgAux  += " " + IIF(SA1->A1_REID=="S",ALLTRIM(SA1->A1_MENPROC),"")		

cMsgAux	+=	" TEL DE COBRANCA: " + AllTrim(cTelCob)  + " CEI: " + AllTrim(aDadSc5[8])

// Preenche mensagem auxiliar com mensagem contida no cNatOper
cMsgAux	+= +" " + AllTrim(cNatOper)

cNatOper := ""

cNatOper := cMsgAux

aEval(aAreOld, {|xAux| RestArea(xAux)})
Return Nil
                   

//-------------------------------------------------------------------
/*/{Protheus.doc} FSTraExe
Controle para travar e destravar rotina para ser executada somente 1 vez

@author	   Cláudio Luiz da Silva
@since	   

@param      nHdlLock  Identificador interno para o arquivo de trava
@param      cNomArq   Nome Arquivo a ser gerado com extensao .L01 onde 01 empresa
@param      lTrava    Avalia se a rotina sera para travar ou destravar
@param      lManual   Avalia se a rotina esta sendo executada Manualmente ou Automatico

@return     lRet .T. ou .F. - Avalida se a rotina podera ser executada ou nao
/*/
//-------------------------------------------------------------------
User Function FSTraExe(nHdlLock, cNomArq, lTrava, lManual)

Local lRet:= .F.
Local cNomUsu:= Iif(Type("cUserName")<>"U", cUserName, "Workflow")

Default lManual:= .T.
Default lTrava	:= .F.

If lTrava

	// Nao permite o acesso simultaneo … rotina por mais de 1 usuario.
	IF ( nHdlLock := MSFCREATE(cNomArq+".L"+cEmpAnt)) < 0
		If lManual
			MsgAlert("A rotina esta sendo utilizada por outro usuário."+cEol+;
						"Por questões de integridade de dados, não é permitida"+cEol+;
						"a utilização desta rotina por mais de um usuário simultaneamente."+cEol+;
						"Tente novamente mais tarde.","::Atenção::")
		else
			ConOut("** A rotina esta sendo utilizada por outro usuário **" + DtoC(Date()) + " as " + Time() + "Hrs")
		EndIf
		lRet:= .T.
	Endif
	
	//Grava no sem foro informações sobre quem está utilizando
	FWrite(nHdlLock,"Operador: "+cNomUsu+cEol+;
					"Empresa.: "+cEmpAnt+cEol+;
					"Filial..: "+cFilAnt+cEol)

else

	If nHdlLock > -1
		fclose(nHdlLock)
		Ferase(cNomArq+".L"+cEmpAnt)
	Endif
	
EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSEnvMai
Rotina de Envio de email do Sistema utilizando WF.

@author     Cláudio Luiz da Silva
@since    	18/03/2011

@param      cDestino   Destino do email
@param      cSubject   Assunto do email
@param      cMensTit   Mensagem a ser enviada no corpo do email como titulo
@param      cMensLog   Mensagem a ser enviada no corpo do email
@param      cAttach    Nome do arquivo a ser enviado
/*/
//-------------------------------------------------------------------
User Function FSEnvMai(cDestino,cSubject,cMensTit,cMensLog,cAttach)

Local oHTML, oProcess
Local aFiles:= {}

Default cDestino  := GetMv("MV_WFADMIN")
Default cSubject  := "Email Automático - Log de Erro - "+Dtoc(Date()) + " " + Time()
Default cAttach   := ""
Default cMensTit  := ""
Default cMensLog  := ""

oProcess:= TWFProcess():New("AVISO", "Email Automatico")
oProcess:NewTask("AVISO", "\WORKFLOW\AVISO.htm")
oProcess:cTo:= cDestino
oProcess:cSubject:= cSubject

//Envio de arquivo em anexo
If !Empty(cAttach)
	//Busca atributos do arquivo a ser anexado
	aFiles:= Directory(cAttach)
	//Se anexo maior que 5M nao envia por email
   If aFiles[1,2] > (1024*1024*5)
   	If !Empty(cMensLog)
      	   cMensLog+= "<br><br>"
          EndIf
	    	cMensLog+= "Arquivo de log possui mais de 5Mb.<br>"
	      cMensLog+= "Favor verificar o arquivo no caminho "+cAttach+ "."
	   Else
      If Empty(cMensLog)
      	cMensLog := "Segue arquivo descritivo do erro em anexo."
      EndIf
         oProcess:AttachFile(cAttach)
    	EndIf
Else
		If Empty(cMensLog)
      	cMensLog := "Segue arquivo descritivo do erro em anexo."
  		EndIf
EndIf

oProcess:cBody:= cMensLog
oHTML:= oProcess:oHTML

oHtml:ValByName("Titulo",cMensTit)
oHtml:ValByName("Mensagem",cMensLog)

oProcess:Start()
oProcess:Finish()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSEmpInt
Carrega array somente com as empresas, desconsiderando as filiais.

@author	   Cláudio Luiz da Silva
@since	   

@return		aRecnoSM0  		array com as empresas
/*/
//-------------------------------------------------------------------
User Function FSEmpInt(lGetFil)

Local 	aRecnoSM0	:= {}
Default	lGetFil		:= .F.   

dbSelectArea("SM0")
dbGotop()
While !Eof() 
   If ! DELETED() 
	If lGetFil
		If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODFIL}) == 0 //--So adiciona no aRecnoSM0 se a empresa for diferente
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		EndIf
	Else 
		If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 //--So adiciona no aRecnoSM0 se a filial for diferente
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		EndIf			
	EndIf
	Endif
	dbSkip()
	
EndDo	

Return(aRecnoSM0)  


//-------------------------------------------------------------------
/*/{Protheus.doc} FSChkBug
Tratamento de erro especifico para capturar o erro e armazenar em variavel.

@author	   Cláudio Luiz da Silva
@since	   

@param 		e         Objeto do erro
@param 		lManual   Define se a rotina esta sendo executada manualmente

@obs	      
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSChkBug(e, lManual)

Local	cDescErr	:= ""
Local cDetaErr	:= ""
Local cMensAux	:= ""

Default lManual:= .F.

IF e:gencode > 0
	If lManual
		HELP(" ",1,"ERR_MSG",,e:Description,2,1)
	EndIf

	cDescErr:= "Erro.....: "+ e:Description	+ cEol
   cDetaErr:= "Descricao: "+ e:ErrorStack 	+ cEol

	If Len(cMensErr)+Len(cDescErr)+Len(cDetaErr) >= _LIMSTR //Limite string 1Mb
		//Caso a variavel cFileLog e nHdlLog esteja definida cria arquivo log
		//caso contrario limita a mensagem a 1Mb
		If Type("cFileLog")=="U" .And. Type("nHdlLog")=="U"
			U_FSTraStr(@cMensAux, cMensErr)
			U_FSTraStr(@cMensAux, cDescErr)
			U_FSTraStr(@cMensAux, cDetaErr)
			cMensErr := cMensAux
		Else
			U_FSGrvLog(cMensErr + cEol)
			U_FSGrvLog(cDescErr)
			U_FSGrvLog(cDetaErr)
		EndIf
	Else
		cMensErr	+= cDescErr
		cMensErr	+= cDetaErr
	EndIf

Endif

Break


//-------------------------------------------------------------------
/*/{Protheus.doc} FSTraStr
Efetua tratamento de string para nao ultrapassar 1Mb

@author	   Cláudio Luiz da Silva
@since	   
@param      cMensAux  Mensagem final
@param      cMensNew  Mensagem a ser aglutinada
/*/
//-------------------------------------------------------------------
User Function FSTraStr(cMensAux, cMensNew)

Local cRet		:= ""
Local nTamMsg	:= Len(cMensAux)
Local nTamNew	:= Len(cMensNew)

If (nTamMsg+nTamNew) >= _LIMSTR //Limite String 1Mb
	cMensAux+= Left(cMensNew,nLimite-nTamMsg)
Else
	cMensAux+= cMensNew
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSGrvLog
Cria e grava arquivo de log

@author	   Cláudio Luiz da Silva
@since	   

@param      cMensagem	Mensagem a ser gravada
@param      lFecha   	Informa se o arquivo sera fechado
@param      lApaga	  	Apaga arquivo de log

@return     lRet 			.T. ou .F. - Avalia se a rotina foi executada sem erro
/*/
//-------------------------------------------------------------------
User Function FSGrvLog(cMensagem, lFecha, lApaga)

Local lRet:= .T.
Local nRet:= 0

Default lFecha:= .F.
Default lApaga:= .F.

If !lApaga
	If !lFecha

		If !File(cFileLog)
			//Criacao de novo arquivo
			IF (nHdlLog:= MSFCREATE(cFileLog,0)) > 0
				lRet:= .T.
				FCLOSE(nHdlLog)
			Endif
		Else
			If !Empty(cMensagem)
				//Abre de novo o arquivo de log
				nHdlLog:= FOPEN(cFileLog,2)
				If nHdlLog > 0
					//Posiciona no fim do arquivo
		   		FSeek(nHdlLog, 0, FS_END) 
		   		//Grava a mensagem
					nRet:= FWrite(nHdlLog, cMensagem + cEol)
					//Fecha o arquivo
					FCLOSE(nHdlLog)
				EndIf
			EndIf
		EndIf
	Else
		//Fecho o arquivo	
		If nHdlLog > -1
			FCLOSE(nHdlLog)
		Endif
	EndIf
Else	
	//Apago o arquivo
	If File(cFileLog)
		FErase(cFileLog)
	EndIf
EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FSMaiAvi
Envia E-Mail de alerta, caso o processo tenha gerado erro. 

@author	   Giulliano Santos Silva
@since	   05/08/2011
@version	   P11
@obs	      Executa a ação
				Retorna uma data válida
Projeto


Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//------------------------------------------------------------------- 
User Function FSMaiAvi(cDesPro)

Local cSubject   	:= "Monitoramento de Eventos"
Local cMensTit   	:= "Aviso - " + cDesPro
Local cMensEve		:= cDesPro
Local cMensLog   	:= ""
Local cAttach
Local cDestino	 		// Se a variavel for vazio será enviado e-mail para o admistrador do sistema.

cMensLog := '<html><head><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"><title>Monitoramento de Eventos</title>'
cMensLog += '<style type="text/css">'
cMensLog += '<!--'
cMensLog += '.style1 {font-family: Verdana, Arial, Helvetica, sans-serif;font-size: x-small;font-weight: bold;}'
cMensLog += '.style6 {font-size: x-small; font-family: Verdana, Arial, Helvetica, sans-serif; }'
cMensLog += '.style8 {font-family: Verdana, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold; color: #CC0000; }'
cMensLog += '-->'
cMensLog += '</style></head>'
cMensLog += '<body><table width="100%"  border="1" cellspacing="0" cellpadding="0"><tr><td bgcolor="#FFFFCC""><div align="center"><span class="style1">Monitoramento de Eventos </span></div></td>  </tr>'
cMensLog += '<tr><td><table width="100%"  border="0" cellspacing="0" cellpadding="0"><tr><td valign="top" width="17%"><span class="style1">Evento:</span></td>'
cMensLog += '<td valign="top" width="83%"><span class="style1"> ' +  cMensEve  + ' </span></td></tr>'
cMensLog += '<tr><td valign="top"><span class="style1">Situa&ccedil;&atilde;o:</span></td>'
cMensLog += '<td valign="top"><span class="style8">Problemas de execucao. Necessaria verificacao.</span></td>'
cMensLog += '</tr><tr><td valign="top"><span class="style1">Ocorr&ecirc;ncia:</span></td>'
cMensLog += '<td valign="top"><span class="style6">Existem processos nao finalizados!</span></td>'
cMensLog += '</tr><tr><td valign="top"><span class="style1">Erro gerado: </span></td>'
cMensLog += '<td valign="top"><span class="style6">' +  cMensErr  + '</span></td>'
cMensLog += '</tr><tr><td valign="top"><span class="style1">Dados adicionais: </span></td>'
cMensLog += '<td valign="top"><span class="style6">Monitoramento realizado em ' + DToC(Date()) + ' as ' + Time() + '.</span></td>'
cMensLog += '</tr></table></td></tr></table></body></html>'
 
//Envia E-mail alertando sobre o erro gerado na rotina. 
U_FSEnvMai(cDestino,cSubject,cMensTit,cMensLog) //cDestino,cSubject,cMensTit,cMensLog,cAttach

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FSCheEnd
Cria e grava arquivo de log

@author	   Fernando Ferreiras
@since	   

@param      cFil			Filial do Endereço
@param      cCodCli   	Código do cliente
@param      cLojCli	  	Loja do cliente

@return     lRet 			.T. ou .F. - Se True permite a cadastro do cliente 
/*/
//-------------------------------------------------------------------
User Function FSCheEnd(cFil, cCodCli, cLojCli)
Local lRet	:= .F.
                 
//P01_FILIAL+P01_COD+P01_LOJA                  
P01->(dbSetOrder(1))
lRet := P01->(dbSeek(cFil+cCodCli+cLojCli))

Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSVerRis
Verifica se o cliente tem bloqueio por risco ou não.

@protected         
@author 	Fernando Ferreira
@since 		15/01/2013
@version P11
@param	cCodCli			Código do cliente a ser validado
@param	cLojCli			Loja do cliente
@param	cRisCli			Riso do cliente
@return	lReturn			Se .T. Bloqueia Pedido de venda
@obs  
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     		Motivo      

/*/
//---------------------------------------------------------------------------------------
User Function FSVerRis(cCodCli, cLoja, cRisCli)
Local		lReturn		:=	.T.
Local		nNumDias	:=	0
Local		cAliasSE1	:=	GetNextAlias()
Local		cSepNeg		:= If("|"$MV_CRNEG,"|",",")
Local		cSepProv	:= If("|"$MVPROVIS,"|",",")
Local		cSepRec		:= If("|"$MVRECANT,"|",",")
Local		cQuery		:= ""
 		
If ( !Empty(cRisCli) .And. ! cRisCli $ "E,Z" )

	nNumDias := SuperGetMv("MV_RISCO"+cRisCli, .T., "")
	
	cQuery	:= "SELECT MIN(E1_VENCREA) VENCREAL "
	cQuery	+= "FROM "+RetSqlName("SE1")+" SE1 "
	cQuery	+= "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
	cQuery	+= "SE1.E1_CLIENTE='"+cCodCli+"' AND "
	cQuery	+= "SE1.E1_LOJA='"+cLoja+"' AND "
	cQuery	+= "SE1.E1_SALDO > 0 AND "
	cQuery	+= "SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "	                    
	cQuery	+= "SE1.E1_TIPO NOT IN " + FormatIn(MV_CRNEG,cSepNeg)  + " AND "
	cQuery	+= "SE1.E1_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
	cQuery	+= "SE1.E1_TIPO NOT IN " + FormatIn(MVRECANT,cSepRec)  + " AND "							
	cQuery	+= "SE1.D_E_L_E_T_=' ' "

	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.T.,.T.)
	
	TcSetField(cAliasSE1,"VENCREAL","D",8,0)
	
	If (cAliasSE1)->(!Eof()) .And. !Empty((cAliasSE1)->VENCREAL) .And. (dDataBase - (cAliasSE1)->VENCREAL) >= nNumDias
		lReturn	:= .F.
	EndIf		
	
	(cAliasSE1)->(dbCloseArea())
			
EndIf

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} FSGetCod
Obtem próximo sequêncial numérico efetuando controle de lock.  
Para o controle de lock, foi utilizada a função MayIUseCode

@author        Marlon Samora
@since         12/06/2010

@param         cAlias		Alias da tabela desejada Ex.: SB1
@param         cCampo		Campo que contem o sequencial Ex.: B1_COD
@param         cChave		Prefixo do sequencial. Ex.: M->B1_GRUPO
@param         nTamSeq		Tamanho do sequêncial

@Obs
Exemplos de uso: 
->Código do produto B1_COD será formado pelo campo B1_GRUPO + sequencial de 4 dígitos.
	* Criar um gatilho no campo B1_GRUPO com regra: U_FSGetCod("SB1","B1_COD",M->B1_GRUPO,4)
	
->Código do produto B1_COD será formado pelo campo B1_GRUPO+B1_TIPO + sequencial de 2 dígitos.
	* Criar um gatilho no campo B1_GRUPO com regra: U_FSGetCod("SB1","B1_COD",M->B1_GRUPO+M->B1_TIPO,2)	

->Código do grupo BM_GRUPO será formado pelo campo BM_TIPGRU + sequencial de 4 dígitos.
	* Criar um gatilho no campo BM_TIPGRU com regra: U_FSGetCod("SBM","BM_GRUPO",M->BM_TIPGRU,4)

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo

/*/
//-------------------------------------------------------------------
User Function FSGetCod(cAlias,cCampo,cChave,nTamSeq, cFiltro, cBusca)

Local 	aAreas  	:= {(cAlias)->(GetArea()),GetArea()}
Local		cCodFin  := ""
Local		cQuery 	:= ""	
Local		nTotal 	:= 0

Default	cFiltro	:= ""
Default	cBusca	:= ""

If (Select("TMPQRY")!= 0)
   TMPQRY->(dbCloseArea())
EndIf

cQuery := CHR(13) + "SELECT MAX("+cCampo+") AS CODIGO " 
cQuery += CHR(13) + "FROM " + RetSqlName(cAlias) + " 
cQuery += CHR(13) + "WHERE D_E_L_E_T_ <> '*' "

If !Empty(cChave)
	cQuery += CHR(13) + "AND " + cCampo + " LIKE '"+ cChave +"%' "
EndIf

If !Empty(cFiltro)
	cQuery += CHR(13) + "AND " + cFiltro + " = '"+ cBusca +"' "
EndIf

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TMPQRY",.F.,.T.) 
TMPQRY->(dbGoTop())

cCodFin := AllTrim(TMPQRY->CODIGO)

If !TMPQRY->(Eof())
   cCodFin := cChave+Soma1(StrZero(Val(SUBSTR(cCodFin,Len(cChave)+1,nTamSeq)),nTamSeq))
   
   //Controle de Semaforo
   Do while !MayIUseCode(cCodFin)
 		cCodFin := cChave+Soma1(StrZero(Val(SUBSTR(cCodFin,Len(cChave)+1,nTamSeq)),nTamSeq))
	Enddo      
	
Else
	cCodFin := cChave+StrZero(1,nTamSeq)
Endif

FreeUsedCode()

TMPQRY->(dbCloseArea())

aEval(aAreas, {|x| RestArea(x) }) 

Return cCodFin                                        

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSGetSre
Retorna a série definida no parâmetro TM_PREFKP
          
@protected
@author 		Fernando Ferreira
@since 		11/11/2011 
@version 	P11
@param		Serie Kp
@return		cSerie (Filial + Serie TM_PREFKP)
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSGetSre(cSerInt)
Local		cSerie		:= ""
Local		cEspecie		:= ""
Local		aSerie 		:= {}
Local		nPos			:= 0

Default	cSerInt		:= ""

	cEspecie	:= SuperGetMv( "TM_PREFKP"  , .F., " " )	// Espécie de para de séries e prefixo
aSerie 	:= StrTokarr(cEspecie, ";")
nPos		:= aScan(aSerie, {|x|  SubStr(x, 1,AT( "=", x ) - 1)  == AllTrim(cSerInt) })

If nPos > 0
	cSerie	:= AvKey(FWFilial()+SubStr(aSerie[nPos], AT( "=", aSerie[nPos] ) +1, 1), "E1_PREFIXO")
Else
	cSerie	:= AvKey(FWFilial(), "E1_PREFIXO")
EndIf 

Return cSerie


                                        

                                                  

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSCodUf
Retorna um array com o código da UF
          
@protected
@author 		Rodrigo Artur
@since 		21/01/2014
@version 	P11
@param		 
@return		 
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 

User Function FSCodUf()

Local aUFTmp := {}
Local cCrlf  := Chr(13)+Chr(10)

DbSelectArea("SX5") 
DbSetOrder(1)
If DbSeek( xFilial("SX5") + "AA" )
   Do While ! Eof() .And. xFilial("SX5") + "AA" == SX5->(X5_FILIAL + X5_TABELA)
      aAdd( aUFTmp , { Alltrim(SX5->X5_CHAVE) , StrZero( Val(SX5->X5_DESCRI),2) })
      DbSkip()
   Enddo

   cExecSQL := "(Case "+cCrlf
   For nXy := 1 To Len(aUFTmp)
       cExecSQL += "When XVARTMP1 = '"+ aUFTmp[nXy][1] + "' Then '" + aUFTmp[nXy][2] +"' + XVARTMP2 "+cCrlf
   Next
   cExecSQL += " Else '99' + XVARTMP2  End) "

Else  
	conout("Tabela AA do SX5 não esta disponível! (Código da UF)")
Endif  

Return(aUFTmp)
		