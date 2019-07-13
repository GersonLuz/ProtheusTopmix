#INCLUDE "PROTHEUS.CH"                                                

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINP17
Posição do cliente
         
@author 	Fernando dos Santos Ferreira 
@since 	25/01/2013 
@version P11      
@return  Nil
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------- 
User Function FSFINP17( cCodCli, cLoja )
Local		cAlias		:= GetNextAlias()
Local		aCmpSA1		:= {}
Local		cLblCli		:= ""
Local		nDiasAtr		:= 0
Local		cSayRis		:= "Risco"
Local		cLblLimite	:= "Limite de Crédito"
Local		cLblVenci	:= "Vencimento"
Local		cLblProv		:= "Total Provisório"
Local		cLblNota		:= "Total de Notas"
Local		cItems		:= ""
Local		dVencimento	:= CToD("")
Local		nLimite     := 0
Local		nProviso		:= 0
Local		nNotaFisc	:= 0
Local		nTotMov		:= 0
Local		nTotGer		:= 0

Private 	aFieldA1		:= {"A1_RISCO"} 

// Get as informações o cliente
FGetInfTit( cAlias, cCodCli, cLoja )

cItems		:= SA1->A1_RISCO
dVencimento	:= SA1->A1_VENCLC
nLimite     := SA1->A1_LC
nDiasAtr		:= FGetDiaAtr( SA1->A1_COD, SA1->A1_LOJA )
nProviso 	:= (cAlias)->PROVISORIO
nNotaFisc	:= (cAlias)->NOTA
nNccRa		:= (cAlias)->NCCRA
nTotMov		:= ( nProviso + nNotaFisc ) - nNccRa
nTotGer		:= SA1->A1_LC - nTotMov

FMod2aHeader("SA1", @aCmpSA1)

cLblCli += AllTrim(SA1->A1_COD) 
cLblCli += " - " + SA1->A1_LOJA 
cLblCli += " - " + AllTrim(SA1->A1_NOME) 
cLblCli += " - " + IIF(SA1->A1_PESSOA == "J", Transform(SA1->A1_CGC, "@r 99.999.999/9999-99"), Transform(SA1->A1_CGC, "@r 999.999.999-99"))

nPosFobDet := aScan( aCmpSA1 ,{ |x| Alltrim(x[02]) == AllTrim("A1_RISCO") } )
If nPosFobDet > 0
	aCombo := StrTokArr(aCmpSA1[nPosFobDet][11], ";")
EndIf

oDlg 		:= MsDialog():New(180,180,350,770, ".:: Posição do Cliente ::.",,,,,,,,,.T.)  

oSayCli	:= TSay():New(005,005,{||cLblCli},oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,220,20,,,,,,)

oSayRis	:= TSay():New(016,005,{||cSayRis},oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,090,20,,,,,,)
@ 023,005 MSCOMBOBOX oCombo VAR cItems ITEMS aCombo SIZE 055,10 OF oDlg PIXEL

oSayRis	:= TSay():New(016,065,{||cLblLimite},oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,090,20,,,,,,)
oGetLim	:= TGet():New( 023,065 ,{|u| If(PCount() > 0,nLimite:=u, nLimite)},oDlg, 60, 009,PesqPict("SA1","A1_LC" ),{|| },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nLimite",,)

oSayVen	:= TSay():New(016,130,{||cLblVenci},oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,090,20,,,,,,)
oGetVen	:= TGet():New(023,130 ,{|u| If(PCount() > 0,dVencimento:=u, dVencimento)},oDlg, 50, 009,PesqPict("SA1","A1_VENCLC" ),,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","dVencimento",,)

oSayLib	:= TSay():New(016,185,{|| "Dias de Atraso" },oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,090,20,,,,,,)
oGetLib	:= TGet():New(023,185,{|u| If(PCount() > 0, nDiasAtr :=u, nDiasAtr )}, oDlg, 50, 009, "@E 99999",, CLR_BLACK  , CLR_WHITE,,,,.T.,"",,,.F.,.F.,, .T., .F.,"","nDiasAtr",,)

oSayLib	:= TSay():New(016,240, {|| "Provisório" },oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,090,20,,,,,,)
oGetLib	:= TGet():New(023,240, {|u| If(PCount() > 0, nProviso := u, nProviso )}, oDlg, 50, 009, PesqPict("SE1","E1_VALOR" ),, CLR_BLACK  , CLR_WHITE,,,,.T.,"",,,.F.,.F.,, .T., .F.,"","nProviso",,)

oSayLib	:= TSay():New(040,005, {|| "Tit.Rec" },oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,090,20,,,,,,)
oGetLib	:= TGet():New(047,005, {|u| If(PCount() > 0, nNotaFisc := u, nNotaFisc )}, oDlg, 50, 009, PesqPict("SE1","E1_VALOR" ),, CLR_BLACK  , CLR_WHITE,,,,.T.,"",,,.F.,.F.,, .T., .F.,"","nNotaFisc",,)

oSayLib	:= TSay():New(040,060, {|| "Adiantame. NCC/RA" },oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,090,20,,,,,,)
oGetLib	:= TGet():New(047,060, {|u| If(PCount() > 0, nNccRa := u, nNccRa )}, oDlg, 50, 009, PesqPict("SE1","E1_VALOR" ),, CLR_BLACK  , CLR_WHITE,,,,.T.,"",,,.F.,.F.,, .T., .F.,"","nNccRa",,)

oSayLib	:= TSay():New(040,115, {|| "Tot.Mov" },oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,090,20,,,,,,)
oGetLib	:= TGet():New(047,115, {|u| If(PCount() > 0, nTotMov := u, nTotMov )}, oDlg, 50, 009, PesqPict("SE1","E1_VALOR" ),, CLR_BLACK  , CLR_WHITE,,,,.T.,"",,,.F.,.F.,, .T., .F.,"","nTotMov",,)

oSayLib	:= TSay():New(040,170, {|| "Posição Atual" },oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,090,20,,,,,,)
oGetLib	:= TGet():New(047,170, {|u| If(PCount() > 0, nTotGer := u, nTotGer )}, oDlg, 50, 009, PesqPict("SE1","E1_VALOR" ),, CLR_BLACK  , CLR_WHITE,,,,.T.,"",,,.F.,.F.,, .T., .F.,"","nTotGer",,)

oButton2	:=tButton():New(64,240,"&Ok"	,oDlg,{|| oDlg:End()},50,15,,,,.T.)
         
oDlg:lCentered := .T.

oCombo:LREADONLY := .T.

oDlg:Activate()

(cAlias)->(dbCloseArea())

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
Static Function FGetInfTit( cAlias, cCliIni, cLojIni )
Local		aExecRes		:= {}
Local		cSepNeg		:= If("|"$MV_CRNEG,"|",",")
Local		cSepProv		:= If("|"$MVPROVIS,"|",",")
Local		cSepRec		:= If("|"$MVRECANT,"|",",")
Local		cAbatimen	:= "%"+FormatIn(MVABATIM,"|")+"%"
Local		cCredNeg		:= "%"+FormatIn(MV_CRNEG,cSepNeg)+"%"
Local		cProviso		:= "%"+FormatIn(MVPROVIS,cSepProv)+"%"
Local		cRecAdia		:= "%"+FormatIn(MVRECANT,cSepRec)+"%"
Local		cDatIni	   := "20000101"
Local		cDatFim		:= DToS(Date())

BeginSql Alias cAlias
	COLUMN A1_VENCLC AS DATE
	
	SELECT SA1.A1_FILIAL,SA1.A1_COD,SA1.A1_LOJA,SA1.A1_NOME,SA1.A1_LC,SA1.A1_RISCO,SA1.A1_VENCLC,
	  (
		SELECT COALESCE(SUM(SE1.E1_SALDO),0)
		FROM %table:SE1% SE1
		WHERE SE1.%notDel% 
	     AND SE1.E1_SALDO > 0
	     AND SE1.E1_CLIENTE = SA1.A1_COD
	     AND SE1.E1_LOJA = SA1.A1_LOJA
	 	  AND SE1.E1_EMISSAO BETWEEN %Exp:cDatIni% AND	%Exp:cDatFim% 
	     AND SE1.E1_TIPO = 'PR '
	   ) PROVISORIO,
	  (
		SELECT COALESCE(SUM(SE1.E1_SALDO),0)
		FROM %table:SE1% SE1
		WHERE SE1.%notDel% 
	    AND SE1.E1_SALDO > 0
	    AND SE1.E1_CLIENTE = SA1.A1_COD
	    AND SE1.E1_LOJA = SA1.A1_LOJA
    	 AND SE1.E1_EMISSAO BETWEEN %Exp:cDatIni% AND	%Exp:cDatFim% 
	    AND SE1.E1_TIPO NOT IN %Exp:cAbatimen%
	    AND SE1.E1_TIPO NOT IN %Exp:cCredNeg%
	    AND SE1.E1_TIPO NOT IN %Exp:cProviso%
	    AND SE1.E1_TIPO NOT IN %Exp:cRecAdia%) NOTA,
	  (
		SELECT COALESCE(SUM(SE1.E1_SALDO),0)
		FROM %table:SE1% SE1
		WHERE SE1.%notDel% 
	   AND SE1.E1_SALDO > 0
	   AND SE1.E1_CLIENTE = SA1.A1_COD
	   AND SE1.E1_LOJA = SA1.A1_LOJA
   	AND SE1.E1_EMISSAO BETWEEN %Exp:cDatIni% AND	%Exp:cDatFim% 
	   AND SE1.E1_TIPO IN ('NCC','RA ')
	 ) 
	  NCCRA
	FROM %table:SA1% SA1
	WHERE SA1.%notDel% 
		AND	SA1.A1_FILIAL  = %exp:xFilial("SA1")%	
		AND	SA1.A1_COD  = %exp:cCliIni%	
		AND   SA1.A1_LOJA = %exp:cLojIni%		  	  
EndSql

aExecRes :=  GetLastQuery()

If (cAlias)->(Eof())
	(cAlias)->(dbCloseArea())
	cAlias := ""
End               

Return cAlias          

//-------------------------------------------------------------------
/*/{Protheus.doc} FMod2aHeader
Monta a aHeader

@author	   Fernando Ferreira
@since	   11/06/2012
@version    P11
@param		cAlias 	Alias da tabela
@param		aHeader	Header do processo.
@obs	      

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo

/*/
//------------------------------------------------------------------- 
Static Function FMod2aHeader(cAlias, aHeader) 
Local		nPosField	:= 0
Default	cAlias		:=	{}
Default	aHeader		:=	{}

SX3->(dbSetOrder(1)) 
SX3->(dbGoTop())
SX3->(dbSeek(cAlias)) 

While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == cAlias 
  
  If SX3->(X3Uso(SX3->X3_USADO)) .And. cNivel >= SX3->X3_NIVEL .And. cNivel >= SX3->X3_NIVEL
		nPosFobDet := aScan( aFieldA1 ,{ |x| Alltrim(x) == AllTrim(SX3->X3_CAMPO) } )
		If nPosFobDet > 0
	   	AADD( aHeader, {SX3->X3_TITULO,; 
	  		SX3->X3_CAMPO,;    
	  		SX3->X3_PICTURE,;
	  		SX3->X3_TAMANHO,;
	  		SX3->X3_DECIMAL,;
	  		SX3->X3_VALID,;
	  		SX3->X3_USADO,;
	  		SX3->X3_TIPO,;
	  		SX3->X3_F3,;
	  		SX3->X3_CONTEXT,;
	  		SX3->X3_CBOX,;
	  		SX3->X3_RELACAO,;
	  		SX3->X3_WHEN,;
	  		SX3->X3_VISUAL,;
	  		SX3->X3_VLDUSER,;
	  		SX3->X3_PICTVAR,;
	  		SX3->X3_BROWSE,;
	  		SX3->X3_OBRIGAT})
  		EndIf
  Endif 
  SX3->(dbSkip()) 
EndDo   

Return Nil

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


