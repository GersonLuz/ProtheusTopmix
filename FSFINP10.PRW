#include "protheus.ch"

//---------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINP10
Processo de Compesação de Títulos
         
@author	Fernando Ferreira
@since 	22/03/2012
@version	P11 
@obs
Alteracoes Realizadas desde a Estruturacao Inicial          

Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------- 
User Function FSFINP10()
Local		nValDisCom	:= 0
Local		nValTotCom	:= 0
Local		lRet			:= .T.      
Local		lExtRegNcc	:= .T.

Private 	lInverte 	:= .F.
Private 	cMark   		:= GetMark()
Private	oDlgCom		:= Nil
Private	oGetDtaVen	:= Nil
Private	oBtnFil		:= Nil
Private	oBtnCom		:= Nil
Private	oSayVen		:= Nil
Private	oLstTibAbt	:= Nil 
Private 	oLstComp		:= Nil
Private 	oBtnFin		:= Nil
Private 	oBtnPar		:= Nil
Private 	oCkcBol		:= Nil
Private 	oResComAbt	:= Nil
Private 	oResDisAbt	:= Nil
Private 	oSayDisCom	:= Nil
Private 	oSayTotCom	:= Nil
Private 	oGrpFilNfs	:= Nil
Private 	oGrpTitAbt	:= Nil
Private 	oGrpTitCom	:= Nil
Private 	oSayComAbt	:= Nil
Private 	oSayDisAbt	:= Nil
Private 	oSayDisTot	:= Nil
Private 	oSayComTot	:= Nil
Private 	oGetTrbVal	:= Nil
Private	lAglLan		:= .T.
Private	lMstLanc		:= .T.
Private lCotOnLin	:= .T.

// Crio os arquivos de Trabalho
FCreArqTrb()
// Get nos parametros do processo
lExtRegNcc := FGetParPrc()
// Montagem da Tela
If lExtRegNcc
	FMntComp()
EndIf
// Fecho os arquivos de trabalho
FCloAreTrb({"TRBNFS", "TRBCOM"})
Return Nil

//---------------------------------------------------------------------- 
/*/{Protheus.doc} FMntComp
Exibe Tela de Compesanção de Títulos
         
@author	Fernando Ferreira
@since 	21/03/2012
@version	P11 
@obs
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------- 
Static Function FMntComp()
Local	aSizAdv			:= MSAdvSize()
Local	aSizMin			:= {0, 11.5, 480, 281, 961, 563, 0} //tamanho em 1024 x 768
Local	aCpoCom			:= {}
Local	aCpoNfs			:= {}
Local	aCores			:= {}

Local nLstTibAbt 		:= 1  

Local nGetComAbt 		:= 0
Local nGetDisAbt 		:= 0
Local nGetDisCom 		:= 0                 
Local nGetTotCom 		:= 0
Local nLstComp 		:= 1

Local nPerDim			:= 0
Local nTotComDis		:= 0
Local	nTotComExe		:= 0
Local nMtdNfsAbt		:= 0
                        
Local nPosGrp			:= 0
Local nAuxLin			:= 0 
Local nUltLin			:= 0
                          
Private	lCkcBol 		:= .F.
Private	nRecCom		:= 0 
Private	dGetDtaVen	:= dDataBase + 30
Private	nTotDisNfs	:= 0
Private	nTotComNfs	:= 0
Private	nMtdTotCom	:= 0 
Private	aParPrc		:= {}

For nXi := 1 To Len(aSizAdv)
	aSizAdv[nXi] := Max(aSizAdv[nXi],aSizMin[nXi])
Next nXi

nPerDim := 5.8 * aSizAdv[4] /100

// Header dos campos de compensação
aCpoCom	:= FGetLabHea(1)
// Header dos campos de Notas fiscais
aCpoNfs 	:= FGetLabHea(2)
// Cores dos status do título
aCores	:= FGetColSta()

SetKey( VK_F12, { || FGetParPrc(@oBtnFil, @nTotComDis, @nTotComExe, @nMtdTotCom) } )

DEFINE MSDIALOG oDlgCom TITLE ".:Compensação Automática de NCC e RA:." FROM 000, 000  TO aSizAdv[6], aSizAdv[5] PIXEL
	  
	nAuxAlt := nUltLin + aSizAdv[4] * 42/100 // 25% da tela em altura
	
    // Grupo de titulos de créditos e Recibimento Adiantado
	@001, 001 GROUP 	oGrpTitCom 	TO nAuxAlt, 100 PROMPT "Títulos a Compensar" OF oDlgCom PIXEL
	nPosGrp := nUltLin + nAuxAlt
	nAuxAlt := aSizAdv[4] * 30/100 // 25% da tela em altura
	
	oLstComp := MsSelect():New("TRBCOM","E1_OK","",aCpoCom,@lInverte,@cMark, {011, 005,nUltLin +  nAuxAlt,aSizAdv[3] - 10},,,,,aCores)
   oLstComp:bMark := {| | FDisChkCom(@nRecCom, @nTotComDis, @nTotComExe, @nTotDisNfs, @nTotComNfs), FRefCpoWnd()}

   nUltLin := nUltLin + nAuxAlt
   
	@ nUltLin + nPerDim, 005 SAY 	oSayDisCom 	PROMPT 	"Total Disponivel" 	  									 		SIZE 044, 007 OF oGrpTitCom PIXEL
	@ nUltLin + nPerDim, 060 SAY 	oSayDisTot 	VAR Transform(nTotComDis, PesqPict("SE1","E1_VALOR"))				SIZE 060, 010 OF oGrpTitCom PIXEL
	@ nUltLin + nPerDim, 120 SAY 	oSayTotCom 	PROMPT 	"Total Compensado" 												SIZE 044, 007 OF oGrpTitCom PIXEL
	@ nUltLin + nPerDim, 190 SAY 	oSayComTot 	VAR Transform(nTotComExe, PesqPict("SE1","E1_VALOR"))				SIZE 060, 010 OF oGrpTitCom PIXEL
	
	nUltLin := nPosGrp 
	      
	nAuxAlt := aSizAdv[4] * 8/100 // 8% da tela em altura  
	 // Grupo de filtros a ser realizado no MarkBrowser
	@ nUltLin, 001 GROUP 	oGrpFilNfs 	TO nUltLin + nAuxAlt, 560 PROMPT "Filtro para títulos a abater" OF oDlgCom  PIXEL
	nPosGrp := nUltLin + nAuxAlt
	nUltLin := nPosGrp 
	@ nUltLin - nPerDim, 010 SAY 		 	oSayVen 		PROMPT "Vencimento até:"		 	SIZE 044, 007 OF oDlgCom PIXEL    
	@ nUltLin - nPerDim, 052 MSGET 	 	oGetDtaVen 	VAR 	 dGetDtaVen /*VALID FValDatNfs(nRecCom, dGetDtaVen)*/	SIZE 060, 010 OF oDlgCom PIXEL
	//oGetDtaVen:Disable()
	@ nUltLin - nPerDim, 183 CHECKBOX 	oCkcBol 		VAR    lCkcBol PROMPT "Somente Tit. c/ Bol.?"	SIZE 100, 008 OF oDlgCom PIXEL
	@ nUltLin - nPerDim, 309 BUTTON 		oBtnFil 		PROMPT "&Filtrar" SIZE 082, 014 OF oDlgCom PIXEL ACTION ( FGetRegNfs(nRecCom, dGetDtaVen, lCkcBol, @nTotDisNfs , @nTotComNfs, @nMtdTotCom))
	//oBtnFil:Disable()  

	nAuxAlt := aSizAdv[4] * 42/100 // 30% da tela em altura  
   // Grupo de titulos a realizar o abatimento
   @ nUltLin, 001 GROUP 	oGrpTitAbt TO nUltLin + nAuxAlt, 398 PROMPT "Títulos a Abater" OF oDlgCom PIXEL        
	nPosGrp := nUltLin + nAuxAlt
	   
 	nAuxAlt := aSizAdv[4] * 30/100 // 25% da tela em altura
                            
	oLstTibAbt := MsSelect():New("TRBNFS","E1_OK","",aCpoNfs,@lInverte,@cMark,{nUltLin + 10,005,nUltLin + nAuxAlt,aSizAdv[3] - 10},,,oDlgCom,,)
   oLstTibAbt:bMark := {| | FDisChkNfs(@nMtdTotCom,@nTotComNfs, nTotComDis)} 
	nUltLin := nUltLin + nAuxAlt  
	                                            
   @ nUltLin + nPerDim, 250 BUTTON 	oBtnCom 		PROMPT "&Compensar" 												SIZE 082, 014 OF oDlgCom PIXEL ACTION (FComTitFin(@nMtdTotCom, @nTotComDis, @nTotComExe, @nTotComNfs, @nTotDisNfs))
   @ nUltLin + nPerDim, 120 SAY 		oSayComAbt 	PROMPT "Total Compensado" 										SIZE 044, 007 OF oDlgCom PIXEL
   @ nUltLin + nPerDim, 190 SAY 		oResComAbt 	VAR Transform(nTotComNfs, PesqPict("SE1","E1_VALOR"))	SIZE 060, 010 OF oDlgCom PIXEL
   @ nUltLin + nPerDim, 005 SAY 		oSayDisAbt 	PROMPT "Total Disponivel" 										SIZE 044, 007 OF oDlgCom PIXEL
   @ nUltLin + nPerDim, 060 SAY 		oResDisAbt 	VAR Transform(nTotDisNfs, PesqPict("SE1","E1_VALOR"))	SIZE 060, 010 OF oDlgCom PIXEL
		
	//oBtnCom:Disable()
	nUltLin := nPosGrp 

 	nAuxAlt := aSizAdv[4] * 08/100 // 8% da tela em altura	
	@ nUltLin, 001 GROUP 	oGrpPar TO nUltLin + nAuxAlt, 398 PROMPT "" OF oDlgCom PIXEL    
	@ nUltLin + aSizAdv[4] * 2/100 , aSizAdv[3] - 100 BUTTON 	oBtnFin 		PROMPT "&Finalizar" 	SIZE 082, 014 OF oDlgCom PIXEL ACTION ( oDlgCom:End() )
	
	nPosGrp := nUltLin + nAuxAlt
	nUltLin := nPosGrp
                                               
	oGrpTitCom:Align 	:= CONTROL_ALIGN_TOP                      
	oGrpFilNfs:Align 	:= CONTROL_ALIGN_TOP  
	oGrpTitAbt:Align 	:= CONTROL_ALIGN_TOP  
	oGrpPar:Align 		:= CONTROL_ALIGN_TOP  
  
ACTIVATE MSDIALOG oDlgCom CENTERED

Return Nil

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FCreArqTrb
Cria arquivo de trabalho de títulos NCC e RA

@protected         
@author 		Fernando Ferreira
@since 		21/03/2012
@version		P11
@return		Nil
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/
//---------------------------------------------------------------------------------------
Static Function FCreArqTrb()
Local		aStrNccRa	:= {}
Local		aStrSe1Nf 	:= {}
Local		aCpoHeader	:= {}
Local		aCorLeg		:= {}

Local		cArqTrbCom	:= ""
Local		cArqTrbNf	:=	""

// Cria array de apoio NCC e RA
AAdd(aStrNccRa, {"E1_FILORIG"	,"C"	,TamSx3("E1_FILORIG")[1]		,0		})
AAdd(aStrNccRa, {"E1_PREFIXO"	,"C"	,TamSx3("E1_PREFIXO")[1]	,0		})
AAdd(aStrNccRa, {"E1_NUM"		,"C"	,TamSx3("E1_NUM")[1]			,0		})
AAdd(aStrNccRa, {"E1_PARCELA"	,"C"	,TamSx3("E1_PARCELA")[1]	,0		})
AAdd(aStrNccRa, {"E1_TIPO"		,"C"	,TamSx3("E1_TIPO")[1]		,0		})
AAdd(aStrNccRa, {"E1_CLIENTE"	,"C"	,TamSx3("E1_CLIENTE")[1]	,0		})
AAdd(aStrNccRa, {"E1_LOJA"		,"C"	,TamSx3("E1_LOJA")[1]		,0		})
AAdd(aStrNccRa, {"E1_HIST"		,"C"	,TamSx3("E1_HIST")[1]		,0		})
AAdd(aStrNccRa, {"E1_EMISSAO"	,"D"	,TamSx3("E1_EMISSAO")[1]	,0		})
AAdd(aStrNccRa, {"E1_VENCREA"	,"D"	,TamSx3("E1_VENCREA")[1]	,0		})
AAdd(aStrNccRa, {"E1_VALOR"	,"N"	,TamSx3("E1_VALOR")[1]		,2		})
AAdd(aStrNccRa, {"E1_SALDO"	,"N"	,TamSx3("E1_SALDO")[1]		,2		})
AAdd(aStrNccRa, {"E1_RECNO"	,"N"	,17								,0		})
AAdd(aStrNccRa, {"E1_STATUS"	,"C"	,1									,0		})
AAdd(aStrNccRa, {"E1_OK"		,"C"	,TamSx3("E1_OK")[1]			,0		})

// Cria array de apoio Notas Fiscais
AAdd(aStrSe1Nf, {"E1_OK"		,"C"	,TamSx3("E1_OK")[1]			,0		})
AAdd(aStrSe1Nf, {"E1_PREFIXO"	,"C"	,TamSx3("E1_PREFIXO")[1]	,0		})
AAdd(aStrSe1Nf, {"E1_NUM"		,"C"	,TamSx3("E1_NUM")[1]			,0		})
AAdd(aStrSe1Nf, {"E1_PARCELA"	,"C"	,TamSx3("E1_PARCELA")[1]	,0		})
AAdd(aStrSe1Nf, {"E1_TIPO"		,"C"	,TamSx3("E1_TIPO")[1]		,0		})
AAdd(aStrSe1Nf, {"E1_CLIENTE"	,"C"	,TamSx3("E1_CLIENTE")[1]	,0		})
AAdd(aStrSe1Nf, {"E1_LOJA"		,"C"	,TamSx3("E1_LOJA")[1]		,0		})
AAdd(aStrSe1Nf, {"E1_HIST"		,"C"	,TamSx3("E1_HIST")[1]		,0		})
AAdd(aStrSe1Nf, {"E1_EMISSAO"	,"D"	,TamSx3("E1_EMISSAO")[1]	,0		})
AAdd(aStrSe1Nf, {"E1_VENCREA"	,"D"	,TamSx3("E1_VENCREA")[1]	,0		})
AAdd(aStrSe1Nf, {"E1_VALOR"	,"N"	,TamSx3("E1_VALOR")[1]		,2		})
AAdd(aStrSe1Nf, {"E1_VLORIG"	,"N"	,TamSx3("E1_VALOR")[1]		,2		})
AAdd(aStrSe1Nf, {"E1_SLDCOM"	,"N"	,TamSx3("E1_SALDO")[1]		,2		})
AAdd(aStrSe1Nf, {"E1_SLDORIG"	,"N"	,TamSx3("E1_SALDO")[1]		,2		})
AAdd(aStrSe1Nf, {"E1_RECNO"	,"N"	,17								,0		})


cArqTrbCom	:= CriaTrab(aStrNccRa, .T.)
dbUseArea( .T.,, cArqTrbCom, "TRBCOM",.F.,.F.)
IndRegua("TRBCOM",cArqTrbCom,"E1_RECNO",,,"SeleCionando Registros...")

cArqTrbNf	:= CriaTrab(aStrSe1Nf, .T.)
dbUseArea( .T.,, cArqTrbNf, "TRBNFS",.F.,.F.)
IndRegua("TRBNFS",cArqTrbNf,"E1_RECNO",,,"SeleCionando Registros...")

Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetParPrc
Realiza o prenchimento dos parametros de processamento.
          
@author 	Fernando dos Santos Ferreira
@since 	22/03/2012 
@version P11  
@param	nValDisCom	Valor disponivel a compesar
@param	nValTotCom  Valor Total compesensado
@param	oBtnFil		Botão para habilitar o desabilitar.
@return  aParRet	Parametros do processo
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
Static Function FGetParPrc(oBtnFil, nValDisCom, nValTotCom, nMtdTotCom)
Local		aPerPar		:= {}
Local		lRet			:= .T.  
Local 	cNomPrg		:= "FINP10"+AllTrim(xFilial())
Private	aParPrc		:= {}

Default  nValDisCom	:= 0
Default  nValTotCom	:= 0  
Default  nMtdTotCom	:= 0
Default  oBtnFil		:= Nil

nValDisCom	:= 0
nValTotCom	:= 0
nMtdTotCom	:= 0

//IIF(oGetDtaVen != Nil,oGetDtaVen:Disable(), Nil)

// Array de parametros da consulta
aAdd(aPerPar,{1,"Data da Emissão de:" 	,CriaVar("SE1->E1_EMISSAO"),""  ,"" ,"" ,"", 50, .T.})					// [01]
aAdd(aPerPar,{1,"Data da Emissão ate:"	,CriaVar("SE1->E1_EMISSAO"),""  ,"" ,"" ,"", 50, .T.})					// [02]
aadd(aPerPar,{1,"Cliente de:"				,CriaVar("SE1->E1_CLIENTE"),"@!","" ,"SA1","",30 ,.F.}) 					// [03]
aadd(aPerPar,{1,"Cliente Ate:"			,CriaVar("SE1->E1_CLIENTE"),"@!","" ,"SA1","",30 ,.T.})					// [04]
aadd(aPerPar,{1,"Loja de:"					,CriaVar("SE1->E1_LOJA")	,"@!","" ,"","",20 ,.F.}) 						// [05]
aadd(aPerPar,{1,"Loja Ate:"				,CriaVar("SE1->E1_LOJA")	,"@!","" ,"","",20 ,.T.})						// [06]
aadd(aPerPar,{1,"Natureza de:"			,CriaVar("SE1->E1_NATUREZ"),"@!","" ,"SED","",50 ,.F.})					// [07]
aadd(aPerPar,{1,"Natureza Ate:"			,CriaVar("SE1->E1_NATUREZ"),"@!","" ,"SED","",50 ,.T.})					// [08]
aadd(aPerPar,{1,"Filial de"				,CriaVar("SE1->E1_FILIAL") ,"@!","" ,"SM0","",50 ,.T.}) 					// [09]
aadd(aPerPar,{1,"Filial Ate"				,CriaVar("SE1->E1_FILIAL") ,"@!","" ,"SM0","",50 ,.T.}) 					// [10]
aAdd(aPerPar,{5,"Aglutina Lançamento?"			,.F.	,150,'.F.',.T.}) 														// [11]
aAdd(aPerPar,{5,"Mostra Lançamentos?"			,.F.	,150,'.F.',.T.}) 														// [12]
aAdd(aPerPar,{5,"Contabiliza On-Line?"			,.T.	,150,'.T.',.T.}) 														// [13]

aPerPar[01][03]	:= ParamLoad(cNomPrg,aPerPar,01,aPerPar[01][03])
aPerPar[02][03]	:= ParamLoad(cNomPrg,aPerPar,02,aPerPar[02][03])
aPerPar[03][03]	:= ParamLoad(cNomPrg,aPerPar,03,aPerPar[03][03])
aPerPar[04][03]	:= ParamLoad(cNomPrg,aPerPar,04,aPerPar[04][03])
aPerPar[05][03]	:= ParamLoad(cNomPrg,aPerPar,05,aPerPar[05][03])
aPerPar[06][03]	:= ParamLoad(cNomPrg,aPerPar,06,aPerPar[06][03])
aPerPar[07][03]	:= ParamLoad(cNomPrg,aPerPar,07,aPerPar[07][03])
aPerPar[08][03]	:= ParamLoad(cNomPrg,aPerPar,08,aPerPar[08][03])
aPerPar[09][03]	:= ParamLoad(cNomPrg,aPerPar,09,aPerPar[09][03])
aPerPar[10][03]	:= ParamLoad(cNomPrg,aPerPar,10,aPerPar[10][03])
aPerPar[11][03]	:= ParamLoad(cNomPrg,aPerPar,01,aPerPar[11][03])
aPerPar[12][03]	:= ParamLoad(cNomPrg,aPerPar,02,aPerPar[12][03])
aPerPar[13][03]	:= ParamLoad(cNomPrg,aPerPar,03,aPerPar[13][03])

If ParamBox(aPerPar,"Parametros",aParPrc,,,,,,,cNomPrg,.T.,.T.)
	lAglLan		:= aParPrc[11]
	lMstLanc		:= aParPrc[12]
	lCotOnLin	:= aParPrc[13]
	// Preencho os dados alias TRBCOM
	FGetRegNcc(aParPrc)
	
	If !FCkcArqTrb("TRBCOM")
		MsgInfo("Não foram encontrados dados com os paramentros informados", "Aviso")		
		lRet	:= .F.
		Return lRet		
	EndIf
	
	If oLstComp != Nil
		oLstComp:oBrowse:Refresh()
	EndIf
	
	If oBtnFil != Nil
		oBtnFil:Disable()
	EndIf
Else
	lRet	:= .F.	
EndIf

Return lRet

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetRegNcc
Realiza o prenchimento 
          
@author 	Fernando dos Santos Ferreira
@since 	22/03/2012 
@version P11  
@param	aParPrc	Parametros de filtro para processamento
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
Static Function FGetRegNcc(aParPrc)
Local		cAli			:=	GetNextAlias()
Local		cQryPrc		:= ""
Default	aParPrc		:= {}

cQryPrc	+= "SELECT 	E1.E1_FILORIG, E1.E1_PREFIXO, E1.E1_NUM, E1.E1_PARCELA, E1.E1_TIPO, E1.E1_CLIENTE, E1.E1_LOJA, " + CHR(13) + CHR(10)
cQryPrc	+= "			E1.E1_HIST, E1.E1_EMISSAO, E1.E1_VENCREA, E1.E1_VALOR, E1.E1_SALDO, E1.R_E_C_N_O_ AS E1_RECNO " + CHR(13) + CHR(10)
cQryPrc	+= "FROM " + RetSqlName("SE1") + " E1 " + CHR(13) + CHR(10)
cQryPrc	+= "WHERE E1.D_E_L_E_T_ <> '*'" + CHR(13) + CHR(10)
cQryPrc	+= "AND		E1.E1_SALDO > 0" + CHR(13) + CHR(10)
cQryPrc	+= "AND		E1.E1_TIPO IN ('NCC', 'RA')" + CHR(13) + CHR(10)
cQryPrc	+= "AND		E1.E1_EMISSAO	BETWEEN'" + DtoS(aParPrc[01]) +"' AND '" + DtoS(aParPrc[02]) + "'" + CHR(13) + CHR(10)
cQryPrc	+= "AND		E1.E1_CLIENTE	BETWEEN'" + aParPrc[03] +"' AND	'" + aParPrc[04] + "'" + CHR(13) + CHR(10)
cQryPrc	+= "AND		E1.E1_LOJA		BETWEEN'" + aParPrc[05] + "' AND	'" + aParPrc[06] + "'" + CHR(13) + CHR(10)
cQryPrc	+= "AND		E1.E1_NATUREZ	BETWEEN'" + aParPrc[07] + "' AND	'" + aParPrc[08] + "'" + CHR(13) + CHR(10)
cQryPrc	+= "AND		E1.E1_FILORIG	BETWEEN'" + aParPrc[09] + "' AND	'" + aParPrc[10] + "'" + CHR(13) + CHR(10)
cQryPrc	+= "ORDER BY E1.E1_EMISSAO, E1.E1_CLIENTE"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryPrc), cAli, .F., .T.)
(cAli)->(dbGoTop())

TRBCOM -> ( __dbZap() )
TRBNFS -> ( __dbZap() )

While (cAli)->(!Eof())
	RecLock("TRBCOM", .T.)
		TRBCOM->E1_FILORIG	:= (cAli)->E1_FILORIG
		TRBCOM->E1_PREFIXO	:= (cAli)->E1_PREFIXO
		TRBCOM->E1_NUM			:= (cAli)->E1_NUM
		TRBCOM->E1_PARCELA	:= (cAli)->E1_PARCELA
		TRBCOM->E1_TIPO		:= (cAli)->E1_TIPO
		TRBCOM->E1_CLIENTE	:= (cAli)->E1_CLIENTE
		TRBCOM->E1_LOJA		:= (cAli)->E1_LOJA
		TRBCOM->E1_HIST		:= (cAli)->E1_HIST
		TRBCOM->E1_EMISSAO	:= SToD((cAli)->E1_EMISSAO)
		TRBCOM->E1_VENCREA	:= SToD((cAli)->E1_VENCREA)
		TRBCOM->E1_VALOR		:= (cAli)->E1_VALOR
		TRBCOM->E1_SALDO		:= (cAli)->E1_SALDO
		TRBCOM->E1_RECNO		:= (cAli)->E1_RECNO
		Do Case
			Case (cAli)->E1_SALDO == (cAli)->E1_VALOR
				TRBCOM->E1_STATUS		:= "1"
			Case (cAli)->E1_SALDO == 0
				TRBCOM->E1_STATUS		:= "2"		
			Otherwise
				TRBCOM->E1_STATUS		:= "3"
		EndCase		
	TRBCOM->(MsunLock())

	(cAli)->(dbSkip())
EndDo
TRBCOM->(dbGoTop())
(cAli)->(DbCloseArea())
Return Nil

//---------------------------------------------------------------------- 
/*/{Protheus.doc} FGetRegNfs
Get nos registros das notas para compesar
         
@author	Fernando Ferreira
@since 	22/03/2012
@version	P11 
@param	nRecCom Recno do arquivo de trabalho TRBCOM
@param	dDtaVenFim 	Data de Vencimento
@param	lCkcBol		Paramentro para incluir o titulos com boleto
@param	nTotDisNfs	Total disponivel de títulos do tipo notas fiscais
@param	nTotComNfs	Total de titulos de de notas fiscais compensados
@obs
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 

/*/ 
//---------------------------------------------------------------------- 
Static Function FGetRegNfs(nRecCom, dDtaVenFim, lCkcBol, nTotDisNfs, nTotComNfs, nMtdTotCom)
Local		cAli			:=	GetNextAlias()
Local		aAreOld		:= {TRBCOM->(GetArea())}
Local		cAli			:=	GetNextAlias()
Local		cQryPrc		:= ""

Default	nRecCom		:= 0
Default	dDtaVenFim	:= CToD("")
Default	lCkcBol		:= .F.
Default	nTotDisNfs	:= 0
Default	nTotComNfs	:= 0
Default	nMtdTotCom	:= 0
                
// Zero os valares dos acumuladores
nTotDisNfs	:= 0
nTotComNfs	:= 0
nMtdTotCom	:= 0
                       
// Posiciono no registro marcado
TRBCOM->(dbSetOrder(1))
If TRBCOM->(dbSeek(nRecCom)) .And. TRBCOM->(!Eof())
	cQryPrc	+= "SELECT 	E1.E1_PREFIXO, E1.E1_NUM, E1.E1_PARCELA, E1.E1_TIPO, E1.E1_CLIENTE, E1.E1_LOJA, " 						+ CHR(13) + CHR(10)
	cQryPrc	+= "			E1.E1_HIST,  E1.E1_EMISSAO, E1.E1_VENCREA, E1.E1_VALOR, E1.E1_SALDO, E1.R_E_C_N_O_ AS E1_RECNO " 	+ CHR(13) + CHR(10)
	cQryPrc	+= "FROM " + RetSqlName("SE1") + " E1 " 	+ CHR(13) + CHR(10)
	cQryPrc	+= "WHERE E1.D_E_L_E_T_ <> '*' "  			+ CHR(13) + CHR(10)
	cQryPrc	+= "AND		E1.E1_SALDO > 0 "  				+ CHR(13) + CHR(10)
	cQryPrc	+= "AND		E1.E1_TIPO IN ('NF ') "  		+ CHR(13) + CHR(10)
//	cQryPrc	+= "AND		E1.E1_VENCREA BETWEEN '"+DToS(TRBCOM->E1_EMISSAO)+"' AND '"+DToS(dDtaVenFim)+"'" + CHR(13) + CHR(10)
	cQryPrc	+= "AND		E1.E1_CLIENTE	='"+TRBCOM->E1_CLIENTE+"'" + CHR(13) + CHR(10)
	cQryPrc	+= "AND		E1.E1_LOJA		='"+TRBCOM->E1_LOJA+"'"  	+ CHR(13) + CHR(10)
	cQryPrc	+= "AND		E1.E1_FILORIG	='"+TRBCOM->E1_FILORIG+"'" + CHR(13) + CHR(10)
	If lCkcBol
		cQryPrc	+= "AND		E1.E1_ZBOLETO	='S'"  + CHR(13) + CHR(10)	
	Else
		cQryPrc	+= "AND		E1.E1_ZBOLETO	<> 'S'"  + CHR(13) + CHR(10)				
	EndIf
	cQryPrc	+= "ORDER BY E1.E1_EMISSAO"
EndIf

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryPrc), cAli, .F., .T.)
(cAli)->(dbGoTop())

TRBNFS -> ( __dbZap() )

If (cAli)->(!Eof()) 
	While (cAli)->(!Eof())
		nTotDisNfs	+= (cAli)->E1_SALDO
		RecLock("TRBNFS", .T.)
			TRBNFS->E1_OK			:=	Space(2)
			TRBNFS->E1_PREFIXO	:=	(cAli)->E1_PREFIXO
			TRBNFS->E1_NUM			:=	(cAli)->E1_NUM
			TRBNFS->E1_PARCELA	:=	(cAli)->E1_PARCELA
			TRBNFS->E1_TIPO		:=	(cAli)->E1_TIPO
			TRBNFS->E1_CLIENTE	:=	(cAli)->E1_CLIENTE
			TRBNFS->E1_LOJA		:=	(cAli)->E1_LOJA
			TRBNFS->E1_HIST		:=	(cAli)->E1_HIST
			TRBNFS->E1_EMISSAO	:=	SToD((cAli)->E1_EMISSAO)
			TRBNFS->E1_VENCREA	:=	SToD((cAli)->E1_VENCREA)
			TRBNFS->E1_VALOR		:=	(cAli)->E1_VALOR
			TRBNFS->E1_VLORIG		:= (cAli)->E1_VALOR
			TRBNFS->E1_SLDCOM		:=	(cAli)->E1_SALDO
			TRBNFS->E1_SLDORIG	:=	(cAli)->E1_SALDO
			TRBNFS->E1_RECNO		:=	(cAli)->E1_RECNO
		TRBNFS->(MsunLock())
		(cAli)->(dbSkip())
	EndDo
	TRBNFS->(dbGoTop())
Else
	MsgInfo("Não foram encotrados títulos para serem compemsados.", "Aviso")	
EndIf    

(cAli)->(DbCloseArea())
                
oBtnCom:Disable()

AEval(aAreOld,{|x| restArea(x) })
Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FDisChkCom
Funcao executada ao Marcar/Desmarcar um registro.
         
@author Fernando dos Santos Ferreira
@since 22/03/2012 
@version P11
@param	nRecCom			Recno do Título a ser compensado
@param	nTotComDis		Total a ser compensado
@param	nTotComExe		Total de compensações executadas
@param	nTotDisNfs		Total dos valores de titulos do tipo NF e serem compensados
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
Static Function FDisChkCom(nRecCom, nTotComDis, nTotComExe, nTotDisNfs, nTotComNfs)
Local aAreas 		:= {TRBCOM->(getArea()),GetArea()}
Local nMarked 		:= 0

Default	nRecCom		:= 0
Default	nTotComDis	:= 0
Default	nTotComExe	:= 0
Default	nTotDisNfs	:= 0

nRecCom 		:= 0

If TRBCOM->E1_SALDO > 0
	// Verifico se existe mais de item do grid selecionado
	TRBCOM->(dbGoTop())
	TRBCOM->(dbEval({||  Iif(TRBCOM->E1_OK == cMark,nMarked++,Nil)  } ))
	AEval(aAreas,{|x| restArea(x) })
	
	// Se existir mais de um eu desmarco e envio mensagem para o usuário   
	If(nMarked > 1 )
		RecLock("TRBCOM",.F.)
		TRBCOM->E1_OK := Space(Len(TRBCOM->E1_OK))
		TRBCOM->(MsUnlock())
		oLstTibAbt:oBrowse:Refresh()
		MsgInfo("Você só pode marcar um título para compensação!", "Aviso")	
	EndIf
Else
	RecLock("TRBCOM",.F.)
	TRBCOM->E1_OK := Space(Len(TRBCOM->E1_OK))
	TRBCOM->(MsUnlock())
	oLstTibAbt:oBrowse:Refresh()		
EndIf

// Busco qual registro está marcado e reservo o seu recno.
TRBCOM->(dbGoTop())
TRBCOM->(dbEval({||  Iif(TRBCOM->E1_OK == cMark, nRecCom := TRBCOM->E1_RECNO,Nil)  } ))

If nRecCom != 0
	//oGetDtaVen:Enable()
	If TRBCOM->(dbSeek(nRecCom))
		nTotComDis 	:= TRBCOM->E1_SALDO
		nTotComExe  := TRBCOM->E1_VALOR - TRBCOM->E1_SALDO
		FGetRegNfs(nRecCom, dGetDtaVen, lCkcBol, @nTotDisNfs , @nTotComNfs, @nMtdTotCom)
	EndIf    	
Else
	oBtnFil:Disable()
	//oGetDtaVen:Disable()
	TRBNFS -> ( __dbZap() )       
	nTotComDis	:= 0
	nTotComExe	:= 0
	nTotDisNfs	:= 0
	nTotComNfs	:= 0
	RecLock("TRBCOM",.F.)
	TRBCOM->E1_OK := Space(Len(TRBCOM->E1_OK))
	TRBCOM->(MsUnlock())
EndIf

FRefCpoWnd()

AEval(aAreas,{|x| restArea(x) })
Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetLabHea
Define quais colunas (campos da TTRB) serao exibidas na MsSelect
         
@author Fernando dos Santos Ferreira
@since 22/03/2012 
@version P11  
@param      nTip   	Tipo do cabeçalho a ser retornado. 1 para Compensação 2 
						 	Notas Fiscais. 
@return     aCpoHea	Array com os campos do header.
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
Static Function FGetLabHea(nTip)
Local		aCpoHea	:= {}

Default	nTip	:= 1
If nTip == 1
	AAdd(aCpoHea, {"E1_OK"			, , ""						, PesqPict("SE1","E1_OK" )})
	AAdd(aCpoHea, {"E1_PREFIXO"	, , "Prefixo"				, PesqPict("SE1","E1_PREFIXO" )})
	AAdd(aCpoHea, {"E1_NUM"			, , "Número" 				, PesqPict("SE1","E1_NUM" )})
	AAdd(aCpoHea, {"E1_PARCELA"	, , "Parcela"				, PesqPict("SE1","E1_PARCELA" )})
	AAdd(aCpoHea, {"E1_TIPO"		, , "Tipo" 					, PesqPict("SE1","E1_TIPO" )})
	AAdd(aCpoHea, {"E1_CLIENTE"	, , "Cliente"				, PesqPict("SE1","E1_CLIENTE" )})
	AAdd(aCpoHea, {"E1_LOJA"		, , "Loja"					, PesqPict("SE1","E1_LOJA" )})
	AAdd(aCpoHea, {"E1_HIST"		, , "Descrição"			, PesqPict("SE1","E1_HIST" )})
	AAdd(aCpoHea, {"E1_EMISSAO"	, , "Emissão"				, PesqPict("SE1","E1_EMISSAO" )})
	AAdd(aCpoHea, {"E1_VENCREA"	, , "Vencimento"			, PesqPict("SE1","E1_VENCREA" )})
	AAdd(aCpoHea, {"E1_VALOR"		, , "Valor do Título"	, PesqPict("SE1","E1_VALOR" )})
	AAdd(aCpoHea, {"E1_SALDO"		, , "Valor do Saldo"		, PesqPict("SE1","E1_SALDO" )})
ElseIf nTip == 2
	AAdd(aCpoHea, {"E1_OK"			, , ""						, PesqPict("SE1","E1_OK" )})
	AAdd(aCpoHea, {"E1_PREFIXO"	, , "Prefixo"				, PesqPict("SE1","E1_PREFIXO" )})
	AAdd(aCpoHea, {"E1_NUM"			, , "Número" 				, PesqPict("SE1","E1_NUM" )})
	AAdd(aCpoHea, {"E1_PARCELA"	, , "Parcela"				, PesqPict("SE1","E1_PARCELA" )})
	AAdd(aCpoHea, {"E1_TIPO"		, , "Tipo" 					, PesqPict("SE1","E1_TIPO" )})
	AAdd(aCpoHea, {"E1_CLIENTE"	, , "Cliente"				, PesqPict("SE1","E1_CLIENTE" )})
	AAdd(aCpoHea, {"E1_LOJA"		, , "Loja"					, PesqPict("SE1","E1_LOJA" )})
	AAdd(aCpoHea, {"E1_HIST"		, , "Descrição"			, PesqPict("SE1","E1_HIST" )})
	AAdd(aCpoHea, {"E1_EMISSAO"	, , "Emissão"				, PesqPict("SE1","E1_EMISSAO" )})
	AAdd(aCpoHea, {"E1_VENCREA"	, , "Vencimento"			, PesqPict("SE1","E1_VENCREA" )})
	AAdd(aCpoHea, {"E1_VALOR"		, , "Valor do Título"	, PesqPict("SE1","E1_VALOR" )})
	AAdd(aCpoHea, {"E1_SLDCOM"		, , "Saldo a Compensar"	, PesqPict("SE1","E1_SALDO" )})
EndIf

Return AClone(aCpoHea)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetColSta
Define as cores do Status do títulos NCC e RA
         
@author Fernando dos Santos Ferreira
@since 22/03/2012 
@version P11  
@return     aColSta	Array com as cores do status do títulos
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
Static Function FGetColSta()
Local		aColSta	:= {}
Local		cValVrd	:= "TRBCOM->E1_STATUS == '1'"
Local		cValVer	:= "TRBCOM->E1_STATUS == '2'"
Local		cValAzu	:= "TRBCOM->E1_STATUS == '3'"

AAdd(aColSta,{"TRBCOM->E1_STATUS == '1'",	"BR_VERDE"		})
AAdd(aColSta,{"TRBCOM->E1_STATUS == '2'",	"BR_VERMELHO"	})
AAdd(aColSta,{"TRBCOM->E1_STATUS == '3'",	"BR_AZUL"		})

Return AClone(aColSta)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FValDatNfs
Valida a data informada é maior do que a data do título selecionado
         
@author Fernando dos Santos Ferreira
@since 23/03/2012 
@version P11  
@param	  	nRecCom	Recno do registro selecionado.
@param		oBtnFil  Se retorno for positivo habilita o botão.
@param		dDtaVen	Data de Vencimento a se comparada
@return 		lRet		Retorna T se data for válida
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
Static Function FValDatNfs(nRecCom, dDtaVen)
Local 	aAreas 	:= {TRBCOM->(getArea()),GetArea()}
Local		lRet		:= .F.
Default  nRecCom	:= 0
Default	oBtnFil	:= Nil
                       
// Busco o registro selecionado no grid.
TRBCOM->(dbSetOrder(1))
TRBCOM->(dbSeek(nRecCom))
If TRBCOM->(!Eof()) .And. dDtaVen >= TRBCOM->E1_EMISSAO
	lRet	:= .T.
Else
	lRet := .F.
	MsgInfo("A data que você informou é menor do que a data do título, " + DtoC(TRBCOM->E1_EMISSAO) + ", gentileza informa uma data maior.", "Aviso")	
EndIf

AEval(aAreas,{|x| restArea(x) })
Return lRet

//------------------------------------------------------------------- 
/*/{Protheus.doc} FCloAreTrb
Fecha e apaga os arquivos temporários criados pela rotina.
         
@author Fernando dos Santos Ferreira
@since 22/03/2012 
@version P11  
@param      aArqTemp   Array com arquivos temporários 
@return     Nil
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
Static Function FCloAreTrb(aArqTemp)
Local 	nXi		:= 0

Default	aArqTemp	:=	{}

For nXi :=  1 To Len(aArqTemp)
If Select(aArqTemp[nXi]) != 0
	(aArqTemp[nXi])->(dbCloseArea())
	If File(aArqTemp[nXi]+GetDBExtension())
		FErase(aArqTemp[nXi]+GetDBExtension())
	EndIf  	
EndIf  
Next nXi

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FShwMsgSld
Janela utilizada para informar novo valor para compensar
                                                        	
@param	cPrfTit		- Prefixo do Título
@param	cNumTit		- Número do Título
@param	cPrcTit		- Paracela do Título
@param	nRecno		- Recno do título
@param	nDifDisNfs	- Diferencça dos valores do saldo e do valor a ser compensado.
@author   Fernando Ferreira
@since    23/03/2012
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/
//-------------------------------------------------------------------
Static Function FShwMsgSld(cPrfTit,  cNumTit, cPrcTit, nRecno, nDifDisNfs)

Local lRet        := .F.
Local lOk      	:= .F.
Local lConfirma	:= .T.
Local oDlgLib, oSay1, oSay2, oGet1, oGet2, oButton2, oButton2, oFont
Local	cMsgUse1		:= ""
Local	cMsgUse2		:= ""
Local	cMsgUse3		:= "" 
Local	cVarTxt		:= ""
Local	oGetTrbPrf	:= Nil
Local	oGetTrbNum	:= Nil
Local	oGetTrbPar	:= Nil
Local	nValNum		:= 0      

Default	cPrfTit		:= ""
Default	cNumTit		:= ""
Default	cPrcTit		:= ""
Default	nRecno		:= 0

cMsgUse1 := "Atenção:"
cMsgUse2 := "O valor do título selecionado é maior que o saldo do NCC ou RA informado."
cMsgUse3 := "Altere o valor a compensar!"

DEFINE MSDIALOG oDlgLib FROM 000,000 To 200,500 PIXEL TITLE OemToAnsi(".:Alerta para Saldo:.")
                
	oFont := TFont():New('Arial',,-12,,.T.)
	oSay1:= tSay():New(05,05,{||OemToAnsi(cMsgUse1)},oDlgLib,,,,,,.T.,,,100,10)
	oSay2:= tSay():New(15,05,{||OemToAnsi(cMsgUse2)},oDlgLib,,,,,,.T.,,,400,10)
	oSay3:= tSay():New(25,05,{||OemToAnsi(cMsgUse3)},oDlgLib,,,,,,.T.,,,400,10)
	
	oGroup:= tGroup():New(40,05,100,245,'Informe o novo valor a Compensar',oDlgLib,,,.T.)
	
	oSay4:= tSay():New(50,10,{||OemToAnsi("Prefixo")},oDlgLib,,,,,,.T.,,,100,10)
	@ 060, 010 MSGET oGetTrbPrf 	VAR cPrfTit SIZE 040, 010 OF oDlgLib PIXEL
	oGetTrbPrf:Disable()
	
	oSay5:= tSay():New(50,55,{||OemToAnsi("Número")},oDlgLib,,,,,,.T.,,,100,10)
	@ 060, 055 MSGET oGetTrbNum 	VAR cNumTit SIZE 040, 010 OF oDlgLib PIXEL
	oGetTrbNum:Disable()
	
	oSay6:= tSay():New(50,100,{||OemToAnsi("Parcela")},oDlgLib,,,,,,.T.,,,100,10)
	@ 060, 100 MSGET oGetTrbPar 	VAR cPrcTit SIZE 020, 010 OF oDlgLib PIXEL
	oGetTrbPar:Disable()
	
	oSay6:= tSay():New(50,125,{||OemToAnsi("Valor a Compensar")},oDlgLib,,,,,,.T.,,,100,10)
	@ 060, 125 MSGET oGetTrbVal VAR nDifDisNfs PICTURE PesqPict('SE1','E1_VALOR') VALID FValVlrAlt(nDifDisNfs, TRBNFS->E1_VALOR) SIZE 060, 010 OF oDlgLib PIXEL HASBUTTON
	oGetTrbVal:Refresh()
	                                 
	oButton1:=tButton():New(080,010,'Confirmar',oDlgLib,{|| IIf(FAtuVlrTit(@lRet, nRecno, nDifDisNfs),oDlgLib:End(),lRet := .T.) },50,15,,,,.T.)
	oButton2:=tButton():New(080,070,'Cancelar' ,oDlgLib,{||oDlgLib:End(), lRet:=.F.},50,15,,,,.T.)
                               
ACTIVATE MSDIALOG oDlgLib CENTERED

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} FDisChkNfs
Validações na marcação do MSSelect de títulos de notas fiscais

@param	nTotDisNfs	- Total disponivel de títulos do tipo NF
@param	nTotComNfs	- Total a ser compensado dos titulos NCC e RA
@param	nTotComDis	- Total a ser compensado disponivel.
@author  Fernando Ferreira
@since   23/03/2012
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/
//-------------------------------------------------------------------
Static Function FDisChkNfs(nTotDisNfs, nTotComNfs, nTotComDis)
Local aAreas 		:= {TRBNFS->(getArea()), TRBCOM->(getArea()), GetArea()}
Local	nDifDisNfs	:= 0  
Local	nRecno		:= 0
Local	cPrfTit		:= ""
Local	cNumTit		:= ""
Local	cPrcTit		:= ""
Local	nMarked		:= 0
Local	nMrkCom		:= 0

RecLock("TRBNFS", .F.)
If !(AllTrim(TRBCOM->E1_TIPO) == "RA" .And. TRBNFS->E1_VENCREA < TRBCOM->E1_VENCREA)

	If TRBNFS->E1_OK == cMark
		If (nTotDisNfs + TRBNFS->E1_SLDCOM) > nTotComDis
			nRecno		:= TRBNFS->E1_RECNO
			cPrfTit		:= TRBNFS->E1_PREFIXO
			cNumTit		:= TRBNFS->E1_NUM
			cPrcTit		:= TRBNFS->E1_PARCELA
			nDifDisNfs	:= nTotComDis - nTotDisNfs
			
			If nDifDisNfs == 0
				MsgInfo("A soma dos valores dos títulos de abatimento não pode ser maior do o título NCC/RA!","Totvs")
				TRBNFS->E1_OK := Space(Len(TRBNFS->E1_OK))
			Else
				If FShwMsgSld(cPrfTit,  cNumTit, cPrcTit, nRecno, nDifDisNfs)	
					nTotDisNfs += TRBNFS->E1_SLDCOM
				Else
					TRBNFS->E1_OK := Space(Len(TRBNFS->E1_OK))
				EndIf
			EndIf
		Else
			nTotDisNfs += TRBNFS->E1_SLDCOM
		EndIf
		oBtnCom:Enable()
	Else	
		// Retiro o valor atribuido.
		nTotDisNfs -= TRBNFS->E1_SLDCOM
		
		// Atribuo os valores originais para o Registro do TRB
		TRBNFS->E1_VALOR	:= TRBNFS->E1_VLORIG
		TRBNFS->E1_SLDCOM	:= TRBNFS->E1_SLDORIG
	EndIf                                     
Else				
	MsgInfo("Não é permmitido selecionar um NF com data menor do que a data do RA.", "Aviso - Título RA")
	TRBNFS->E1_OK := Space(Len(TRBNFS->E1_OK))
EndIf

TRBNFS->(MsUnLock())

// Verifico se existe mais de item do grid selecionado
TRBNFS->(dbGoTop())
TRBNFS->(dbEval({||  IIf(TRBNFS->E1_OK == cMark,nMarked++,Nil)  } ))
AEval(aAreas,{|x| restArea(x) })

// Se tiver um registro marcado habilito o botão de baixar.
IIF(nMarked > 0,oBtnCom:Enable(), oBtnCom:Disable())  

FRefCpoWnd()
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuVlrTit
Atualiza os valores do título que será compensado
@param	nRecno		- Recno do título que terá seu valor atualizado
@param	nDifDisNfs	- Diferença do valor entre titulo NCC e NF
@author   Fernando Ferreira
@since    23/03/2012
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/
//-------------------------------------------------------------------
Static Function FAtuVlrTit(lRet, nRecno, nDifDisNfs)
Local 	aAreas 	:= {TRBNFS->(getArea()),GetArea()}

Default	nRecno		:= 0  
Default	lRet			:= .T.
Default	oGetTrbVal	:= Nil

TRBNFS->(dbSetOrder(1))
TRBNFS->(dbSeek(nRecno))

If TRBNFS->(!Eof()) .And. (TRBNFS->E1_RECNO == nRecno)
	RecLock("TRBNFS", .F.)
		TRBNFS->E1_SLDCOM 	:= nDifDisNfs	
	TRBNFS->(MsUnLock())
	lRet := .T. 
Else
	lRet := .F.		
EndIf

oGetTrbVal:Refresh()
AEval(aAreas,{|x| restArea(x) })
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FValVlrAlt
Verifica se o primeiro valor é menor do que o segundo valor

@param	nDifDisNfs	-  Valor da diferença entre NCC e NF
@param	nVlrOrgTit	-	Vakir Original do Título
@author   Fernando Ferreira
@since    23/03/2012
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/
//-------------------------------------------------------------------
Static Function FValVlrAlt(nDifDisNfs, nVlrOrgTit)
Local		lRet			:= .T.
Default	nDifDisNfs	:= 0
Default	nVlrOrgTit	:= 0

If !(nDifDisNfs <= TRBNFS->E1_VALOR)
	lRet			:= .F.
	MsgInfo("O Valor informado é maior do que o valor original do título. Gentileza informar um valor menor.", "Totvs")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FComTitFin
Executa a compensação dos Títulos Financeiros.

@param	nMtdTotCom	-	Montante do total a compensar
@param	nTotComDis	- 	Total a compensar disponivel
@param	nTotComExe	- 	Total compensados executado
@param	nTotComNfs	- 	Total dos valores dos títulos NF compensados
@param	nTotDisNfs	-	Total disponivel de títulos NF para compensar.

@author   Fernando Ferreira
@since    02/04/2012
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/
//-------------------------------------------------------------------
Static Function FComTitFin(nMtdTotCom, nTotComDis, nTotComExe, nTotComNfs, nTotDisNfs)
Local 	aAreas 		:= {TRBNFS->(getArea()),TRBCOM->(getArea()),GetArea()}
Local 	aRecRaNcc	:= {}
Local		aVlrRaNcc	:= {}
Local		aRecAbtNf	:= {}
Local		aVlrAbtNf	:= {}
Local		aParPrg		:= {}
Local		cMsgErr		:= ""
Local		nXi			:= 0
Local		lErrPrc		:= .F.
Local 	lContinua	:= .T.

Default	nTotComDis	:= 0		// Total Disponivel da Compensação
Default	nTotComExe	:= 0		// Total Compensado da Compensação
Default	nTotComNfs	:= 0		// Total Compensado do abatimento
Default	nTotDisNfs	:= 0		// Total Disponivel do abatimento

// Zero a variavel que controla o somatórios dos valores a serem abatidos.
nMtdTotCom	:= 0

cMsgErr += "Não foi possível a compensação dos Seguintes Titulos:" + CHR(10)+CHR(13)
                                                     
// Pego o recno e o valor do titulos RA/NCC
TRBCOM->(dbGoTop())
TRBCOM->(dbEval({|| FGetTitAbt("TRBCOM",@aRecRaNcc, @aVlrRaNcc) } ))

// Pego o recno e o valor do titulos do Tipo NF
TRBNFS->(dbGoTop())
TRBNFS->(dbEval({|| FGetTitAbt("TRBNFS",@aRecAbtNf, @aVlrAbtNf) , TRBNFS->E1_OK := Space(Len(TRBNFS->E1_OK))} ))

AEval(aAreas,{|x| restArea(x) })

TRBCOM->(dbSeek(aRecRaNcc[1]))
For nXi := 1 To Len(aRecAbtNf)
	MsgRun("Aguarde....Realizando compensação","Processando",{|| lContinua :=  MaIntBxCR(3, aRecAbtNf[nXi], ,aRecRaNcc, ,{lCotOnLin,lAglLan,lMstLanc,.F.,.F.,.F.}, , ,, ,dDatabase , ,aVlrAbtNf[nXi], )})
	If lContinua
		nTotComDis			-= aVlrAbtNf[nXi][1]
		nTotDisNfs			-= aVlrAbtNf[nXi][1]
		nTotComExe			+=	aVlrAbtNf[nXi][1]
		nTotComNfs			+= aVlrAbtNf[nXi][1]
		          
		RecLock("TRBCOM", .F.)
			TRBCOM->E1_SALDO  -= aVlrAbtNf[nXi][1]
			Do Case
				Case TRBCOM->E1_SALDO == TRBCOM->E1_VALOR
					TRBCOM->E1_STATUS		:= "1"
					TRBCOM->E1_OK 			:= cMark
				Case TRBCOM->E1_SALDO == 0
					TRBCOM->E1_STATUS		:= "2"		
					TRBCOM->E1_OK 			:= Space(Len(TRBCOM->E1_OK))
				Otherwise
					TRBCOM->E1_STATUS		:= "3"
					TRBCOM->E1_OK 			:= cMark
			EndCase							
		TRBCOM->(MsUnLock())
		
		If TRBNFS->(dbSeek(aRecAbtNf[nXi][1]))
			If (TRBNFS->E1_SLDORIG - aVlrAbtNf[nXi][1]) == 0
				TRBNFS->(dbDelete())
			Else
				RecLock("TRBNFS", .F.)
					TRBNFS->E1_SLDORIG	:= TRBNFS->E1_SLDORIG - aVlrAbtNf[nXi][1]
					TRBNFS->E1_SLDCOM		:= TRBNFS->E1_SLDORIG
				TRBNFS->(MsUnLock())							
			EndIf
		EndIf
	Else	
		cMsgErr += "Prefixo: " + TRBNFS->E1_PREFIXO
		cMsgErr += " Título:"  + TRBNFS->E1_NUM
		cMsgErr += " Parcela:" + TRBNFS->E1_PARCELA
		lErrPrc		:= .T.
	EndIf	
Next nXi

// Se o saldo for igual a zero executo o zap no arquivo de trabalho de notas
If TRBCOM->E1_SALDO == 0  
	nTotDisNfs	:= 0
	nTotComNfs	:= 0
	TRBNFS -> ( __dbZap() )
EndIf

If lErrPrc
	Help("CMPAUTO",1,"HELP","CMPAUTO",cMsgErr,1,0)
EndIf

oSayVen:Disable()
oBtnFil:Disable()
oBtnCom:Disable()
// Atualizo os Componentes.  
FRefCpoWnd()

oLstTibAbt:oBrowse:Refresh()

AEval(aAreas,{|x| restArea(x) })
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FGetTitAbt
Get nos títulos selecionados

@param	cAlias   	- Alias da tabela a buscar os dados
@param	aRecAbtNf	- Array de recnos dos títulos
@param	aVlrAbtNf	- Array de valores dos titulos

@author   Fernando Ferreira
@since    02/04/2012
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/
//-------------------------------------------------------------------
Static Function FGetTitAbt(cAlias, aRecAbtNf, aVlrAbtNf)

If (cAlias)->E1_OK == cMark 
	Do Case
		Case cAlias ==	"TRBCOM" 
			AAdd(aRecAbtNf, (cAlias)->E1_RECNO)
			AAdd(aVlrAbtNf, (cAlias)->E1_SALDO)
		Case cAlias == "TRBNFS"
			AAdd(aRecAbtNf, {(cAlias)->E1_RECNO})
			AAdd(aVlrAbtNf, {(cAlias)->E1_SLDCOM})
	EndCase
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FRefCpoWnd
Atualiza os objetos da Window

@author   Fernando Ferreira
@since    02/04/2012
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/
//-------------------------------------------------------------------
Static Function FRefCpoWnd()

oGetDtaVen:Refresh()
oBtnFil:Refresh()
oBtnCom:Refresh()
oSayVen:Refresh()
oBtnFin:Refresh()
oCkcBol:Refresh()
oResComAbt:Refresh()
oResDisAbt:Refresh()
oSayDisCom:Refresh()
oSayTotCom:Refresh()
oGrpFilNfs:Refresh()
oGrpTitAbt:Refresh()
oGrpTitCom:Refresh()
oSayComAbt:Refresh()
oSayDisAbt:Refresh()
oSayDisTot:Refresh()
oSayComTot:Refresh()
oDlgCom:Refresh()
oLstTibAbt:oBrowse:Refresh()

Return nil


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


