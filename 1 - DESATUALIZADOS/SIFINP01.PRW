#include "protheus.ch" 
#include "msole.ch" 

//------------------------------------------------------------------- 
/*/{Protheus.doc} SIFINP01() 
Tela para Seleção dos Borderos que seram enviados ao Banco por Data.

@protected	
@author		Ederson Colen
@since		21/06/2012
@version 	P11
@obs			Desenvolvimento Atendimento Pontual
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 

User Function SIFINP01(cTipRot,cBordIni,cBordFin,cBancBor,dDtPgBor)

Local cAlias   := "TRSEA"
Local lRetQry  := .F.
Local xRetRot  := ""

Default cBordIni 	:= ""
Default cBordFin 	:= "ZZZZZZ"
Default cBancBor 	:= "237"
Default dDtPgBor  := CToD("")

Private nTotTela := 0

//Cria o Arquivo de Trabalho
MsgRun("Gerando o dados para a Tela...","Por Favor aguarde",{|| FQryCons(cBordIni,cBordFin,cBancBor,dDtPgBor,cAlias,@lRetQry)})

If lRetQry

   FGrvArqT(cAlias)

	FTelaFil(@xRetRot,cTipRot)    

Else
	Aviso("A T E N C A O","Não foram encontrados registros com os parâmetros informados.",{"OK"})
	If cTipRot == "FINA420"
		xRetTela := ' E2_NUM = "*********" '
	Else
		xRetTela := '"******#"'
	EndIf
EndIf

Return(xRetRot) 



//-------------------------------------------------------------------
/*/{Protheus.doc} FQryCons
Funcao para executar a query para selecao dos registros na base de dados
conforme parametros passados.

@protected
@author		Ederson Colen
@since		20/06/2012
@version 	P11.5
@obs			Referente atendimento pontual
@param		cBordIni  - Bordero Inicial
				cBordFin  - Bordero Final 
				cBancBor  - Portado do Bordero
				dDtPgBor  - Data de Pagamento do Bordero
				cAlias    - Alias do Arquivo de Trabalho
				lRetQry   - Retorno se a consulta foi realizada com sucesso.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo    
21/01/14   Rodrigo Artur   Alterado o campo: E2_FILIAL para E2_FILORIG
                           a pedido da Juliana Hilarina.
/*/
//-------------------------------------------------------------------  
Static Function FQryCons(cBordIni,cBordFin,cBancBor,dDtPgBor,cAlias,lRetQry)

Local cQryTXT	:= ""

//Fecha o arquivo caso esteja aberto
U_FCloseArea(cAlias)

//cQryTXT += Chr(13) + "SELECT E2_VENCREA, E2_FILIAL, E2_NUMBOR, E2_PORTADO, SUM(((E2.E2_VALOR - E2.E2_SDDECRE)+E2.E2_SDACRES)) AS XX_VALOR, CASE WHEN E2.E2_IDCNAB <> '' THEN 'ENVIADO BANCO' ELSE '' END AS EA_TRANSF "   
  cQryTXT += Chr(13) + "SELECT E2_VENCREA, E2_FILIAL, E2_NUMBOR, E2_PORTADO, SUM(((E2.E2_SALDO - E2.E2_SDDECRE)+E2.E2_SDACRES)) AS XX_VALOR, CASE WHEN E2.E2_IDCNAB <> '' THEN 'ENVIADO BANCO' ELSE '' END AS EA_TRANSF "
cQryTXT += Chr(13) + "FROM "+RetSqlName("SE2")+" E2 "
cQryTXT += Chr(13) + "INNER JOIN "+RetSqlName("SEA")+" EA ON(EA.D_E_L_E_T_ <> '*' AND EA.EA_FILORIG = E2.E2_FILORIG AND EA.EA_PREFIXO = E2.E2_PREFIXO AND EA.EA_NUM = E2.E2_NUM  "
cQryTXT += Chr(13) + "AND EA.EA_PARCELA = E2.E2_PARCELA AND EA.EA_FORNECE = E2.E2_FORNECE AND EA.EA_NUMBOR = E2.E2_NUMBOR AND EA.EA_PORTADO = '"+cBancBor+"' AND EA.EA_CART = 'P') "
cQryTXT += Chr(13) + "WHERE E2.D_E_L_E_T_ <> '*' "
cQryTXT += Chr(13) + "AND E2.E2_NUMBOR BETWEEN '"+cBordIni+"' AND '"+cBordFin+"' "
cQryTXT += Chr(13) + "AND E2.E2_SALDO > 0.00 "
If ! Empty(dDtPgBor)
	cQryTXT += Chr(13) + " AND ((E2.E2_VENCREA >= '"+DToS(dDtPgBor)+"') OR (E2.E2_VENCREA < '"+DToS(dDtPgBor)+"' AND E2.E2_CONAPRE = 'S')) "
EndIf
cQryTXT += Chr(13) + "GROUP BY E2_NUMBOR, E2_FILIAL, E2_PORTADO, E2_VENCREA, CASE WHEN E2.E2_IDCNAB <> '' THEN 'ENVIADO BANCO' ELSE '' END "
cQryTXT += Chr(13) + "ORDER BY E2_VENCREA, E2_FILIAL, E2_NUMBOR " 

//Cria o arquivo de trabalho da query posicionada
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryTXT),cAlias,.F.,.T.)
(cAlias)->(dbGoTop())

//Valida se exitem informacoes no arquivo gerado.
If ((cAlias)->(!Eof()))
	lRetQry := .T.
EndIf

Return Nil



//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FGrvArqT()
Grava arquivo de Trabalho da Tela de Seleção Borderos.

@protected         
@author 		Ederson Colen
@since 		21/06/2012
@version		P11
@return		
@obs        Desenvolvimento Atendimento Pontual
@param		cAlias - Alias do Arquivo consulta SQL


Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/
//---------------------------------------------------------------------------------------
Static Function FGrvArqT(cAlias)

Local		aStrTRBSE2 	:= {}
Local		cArqTrbNf	:=	""

nTotTela := 0

//Fecha o arquivo caso esteja aberto
U_FCloseArea("TRBSE2")

// Cria array de apoio Notas Fiscais
AAdd(aStrTRBSE2, {"E2_OK"	  		,"C"	,TamSx3("E2_OK")[1]			,0		})
AAdd(aStrTRBSE2, {"E2_VENCREA"	,"D"	,TamSx3("E2_VENCREA")[1]	,0		})
AAdd(aStrTRBSE2, {"E2_FILIAL"	,"C"	,TamSx3("E2_FILIAL")[1]		,0		})
AAdd(aStrTRBSE2, {"E2_NUMBOR"	,"C"	,TamSx3("E2_NUMBOR")[1]		,0		})
AAdd(aStrTRBSE2, {"E2_PORTADO"	,"C"	,TamSx3("E2_PORTADO")[1]	,0		})
//AAdd(aStrTRBSE2, {"E2_VALOR"		,"N"	,TamSx3("E2_VALOR")[1]		,2		})   
AAdd(aStrTRBSE2, {"E2_SALDO"		,"N"	,TamSx3("E2_SALDO")[1]		,2		})
AAdd(aStrTRBSE2, {"EA_TRANSF"	,"C"	,13		,0		})

cArqTrbNf	:= CriaTrab(aStrTRBSE2, .T.)
dbUseArea( .T.,, cArqTrbNf, "TRBSE2",.F.,.F.)
IndRegua("TRBSE2",cArqTrbNf,"DTOS(E2_VENCREA)+E2_FILIAL+E2_NUMBOR",,,"Selecionando Registros...")

While (cAlias)->(!Eof())
	nTotTela	+= (cAlias)->XX_VALOR

	RecLock("TRBSE2", .T.)
		TRBSE2->E2_OK			:=	Space(2)
		TRBSE2->E2_VENCREA	:=	SToD((cAlias)->E2_VENCREA)
		TRBSE2->E2_FILIAL	:=	(cAlias)->E2_FILIAL
		TRBSE2->E2_NUMBOR	:=	(cAlias)->E2_NUMBOR
		TRBSE2->E2_PORTADO	:=	(cAlias)->E2_PORTADO
	  //	TRBSE2->E2_VALOR		:=	(cAlias)->XX_VALOR 
	  	TRBSE2->E2_SALDO		:=	(cAlias)->XX_VALOR
		TRBSE2->EA_TRANSF	:=	(cAlias)->EA_TRANSF
		TRBSE2->(MsunLock())

	(cAlias)->(dbSkip())

EndDo

//Fecha o arquivo caso esteja aberto
U_FCloseArea(cAlias)

Return Nil



//---------------------------------------------------------------------- 
/*/{Protheus.doc} FTelaFil 
Tela para seleção dos registros

@protected
@author 		Ederson Colen
@since 		21/06/2011
@version 	P11
@param		aItens Array com os itens para o filtro

@xRetRot,cTipRot

/*/ 
//---------------------------------------------------------------------- 
Static Function FTelaFil(xRetRot,cTipRot)

Local nPerDim	:= 0
Local aSize 	:= {}
Local aCores	:= {}
Local nTotSel	:= 0
Local nUltLin	:= 0
Local nAuxAlt	:= 0
Local oFntTit1

Local cFiltro  	:= ""
Local cIndex		:= ""
Local cChave		:= ""

Local nOpcA			:= 0
Local lInverte		:= .F.
Local lRImp			:= .F.
Local aCpos			:= {}
Local aDadBanco	:= {}

Local	oBtnFin		:= Nil
Local xRetTela    := ""

Local oDlg
           
Private cMarca	:= GetMark(,"TRBSE2","E2_OK")

Aadd( aCpos, { "E2_OK"		,, " "			, "@!"  } )
Aadd( aCpos, { "E2_VENCREA",, AllTrim(RetTitle("E2_VENCREA"))	, PesqPict("SE2","E2_VENCREA" ) } )		//"Data Vencimento"
Aadd( aCpos, { "E2_FILIAL"	,, AllTrim(RetTitle("E2_FILIAL"))	, PesqPict("SE2","E2_FILIAL" ) } )		//"Filial"
Aadd( aCpos, { "E2_NUMBOR"	,, AllTrim(RetTitle("E2_NUMBOR")) 	, PesqPict("SE2","E2_NUMBOR" ) } )		//"Bordero"
Aadd( aCpos, { "E2_PORTADO",, AllTrim(RetTitle("E2_PORTADO"))	, PesqPict("SE2","E2_PORTADO" ) } )		//"Portado"
//Aadd( aCpos, { "E2_VALOR"	,, AllTrim(RetTitle("E2_VALOR"))  	, PesqPict("SE2","E2_VALOR" ) } )		//"Valor"  
Aadd( aCpos, { "E2_SALDO"	,, AllTrim(RetTitle("E2_SALDO"))  	, PesqPict("SE2","E2_SALDO" ) } )		//"Valor"
Aadd( aCpos, { "EA_TRANSF"	,, AllTrim(RetTitle("EA_TRANSF"))	, PesqPict("SEA","EA_TRANSF" ) } )		//"Transferido"

dbSelectArea("TRBSE2")
dbGotop()

//// Cores dos status do título
aCores	:= FGetColSta()
	
While ! lSaiTela

	aSize    := MSAdvSize()
	nTotSel  := 0
	nUltLin	:= 0
	nPerDim	:= 0

	Define MSDialog oDlg Title "Seleção de Borderos" From aSize[7],00 To aSize[6],aSize[5] Pixel
	Define FONT oFntTit1 NAME "Arial" Size 000,020 BOLD

	nAuxAlt := nUltLin + aSize[4] * 100/100 // 25% da tela em altura
	nPerDim := aSize[4]/100
	
    // Grupo de Borderos
	@001,001 GROUP oGrpTitCom 	TO nAuxAlt,aSize[3] PROMPT "Borderos de Títulos" OF oDlg PIXEL
	nPosGrp := nUltLin + nAuxAlt
	nAuxAlt := aSize[4] * 95/100 // 25% da tela em altura

	oMark := MsSelect():New("TRBSE2","E2_OK","",aCpos,@lInverte,@cMarca, {011,005,nUltLin+nAuxAlt,aSize[3]-5},,,,,aCores)
	oMark:oBrowse:lhasMark = .T.
	oMark:oBrowse:lCanAllmark := .T.
	oMark:oBrowse:bAllMark := { || FInverte(cMarca,lInverte,@nTotSel,oDlg) }
	oMark:bMark := {|| FMarBord(@nTotSel,lInverte,oDlg)}
	oMark:oBrowse:Refresh(.T.)

   nUltLin := nUltLin + nAuxAlt

	@ nUltLin + nPerDim, 005 SAY 	oSayDisCom 	PROMPT 	"Total da Tela" 	  									 		SIZE 060, 010 OF oGrpTitCom FONT oFntTit1 PIXEL COLOR CLR_HBLUE 
  //	@ nUltLin + nPerDim, 070 SAY 	oSayDisTot 	VAR Transform(nTotTela, PesqPict("SE2","E2_VALOR"))				SIZE 070, 010 OF oGrpTitCom FONT oFntTit1 PIXEL COLOR CLR_BLACK    
  	@ nUltLin + nPerDim, 070 SAY 	oSayDisTot 	VAR Transform(nTotTela, PesqPict("SE2","E2_SALDO"))				SIZE 070, 010 OF oGrpTitCom FONT oFntTit1 PIXEL COLOR CLR_BLACK
	@ nUltLin + nPerDim, 250 SAY 	oSayTotCom 	PROMPT 	"Total Selecionado" 												SIZE 060, 010 OF oGrpTitCom FONT oFntTit1 PIXEL COLOR CLR_HBLUE 
//	@ nUltLin + nPerDim, 340 SAY 	oSayComTot 	VAR Transform(nTotSel, PesqPict("SE2","E2_VALOR"))				SIZE 070, 010 OF oGrpTitCom FONT oFntTit1 PIXEL COLOR CLR_HRED 
	@ nUltLin + nPerDim, 340 SAY 	oSayComTot 	VAR Transform(nTotSel, PesqPict("SE2","E2_SALDO"))				SIZE 070, 010 OF oGrpTitCom FONT oFntTit1 PIXEL COLOR CLR_HRED 

	@ nUltLin + aSize[4] * 1/100 , aSize[3] - 200 BUTTON 	oBtnFin 		PROMPT "&Gerar Arq." 	SIZE 070, 014 OF oDlg PIXEL ACTION {|| FConfTela(@xRetTela,@lSaiTela,cTipRot,lInverte,oDlg)}
	@ nUltLin + aSize[4] * 1/100 , aSize[3] - 100 BUTTON 	oBtnFin 		PROMPT "&Cancelar" 	SIZE 070, 014 OF oDlg PIXEL ACTION {|| FCancTela(@xRetTela,@lSaiTela,cTipRot,lInverte,oDlg)}

	nUltLin := nPosGrp 

	ACTIVATE MSDIALOG oDlg CENTERED

EndDo

xRetRot := xRetTela

Return Nil



//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetColSta
Define as cores do Status do Bordero
         
@author 	Ederson Colen
@since 	21/06/2012 
@version P11  
@return	aColSta	Array com as cores do status dos Borderos
@obs     Desenvolvimento Atendimento Pontual
@param	
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
Static Function FGetColSta()

Local		aColSta	:= {}
Local		cValVrd	:= "TRBSE2->EA_TRANSF <> 'ENVIADO BANCO'"
Local		cValVer	:= "TRBSE2->EA_TRANSF == 'ENVIADO BANCO'"

AAdd(aColSta,{"TRBSE2->EA_TRANSF <> 'ENVIADO BANCO'","BR_VERDE"		})
AAdd(aColSta,{"TRBSE2->EA_TRANSF == 'ENVIADO BANCO'","BR_VERMELHO"	})

Return AClone(aColSta)

 

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FInverte
Marca e Desmarca

@protected         
@author 		Ederson Colen
@since 		21/06/2012
@version		P11
@param		cMarca	 Marca do campo  
				lInverte	 Verifica se são todos ou apenas um campo
				nTotSel
/*/
//---------------------------------------------------------------------------------------
Static Function FInverte(cMarca,lInverte,nTotSel,oDlg)

Local nReg := TRBSE2->(Recno())

TRBSE2->(dbGoTop())

While TRBSE2->(!Eof())

	RecLock("TRBSE2",.F.)
	If TRBSE2->E2_OK == cMarca
		If lInverte
			TRBSE2->E2_OK := cMarca
		  //	nTotSel += TRBSE2->E2_VALOR      
		  nTotSel += TRBSE2->E2_SALDO
		Else
			TRBSE2->E2_OK := Space(Len(TRBSE2->E2_OK))
		   //nTotSel -= TRBSE2->E2_VALOR 
		   nTotSel -= TRBSE2->E2_SALDO
		Endif
	Else
		If lInverte
			TRBSE2->E2_OK := Space(Len(TRBSE2->E2_OK))
		   //nTotSel -= TRBSE2->E2_VALOR
		   nTotSel -= TRBSE2->E2_SALDO
		Else
			TRBSE2->E2_OK := cMarca
		   //nTotSel += TRBSE2->E2_VALOR 
		   nTotSel += TRBSE2->E2_SALDO
	  Endif
	Endif
	TRBSE2->(MsUnLock())

	TRBSE2->(dbSkip())

Enddo

TRBSE2->(dbGoto(nReg))
oMark:oBrowse:Refresh(.t.)
oDlg:Refresh()
oSayComTot:Refresh()

Return Nil
                                  


//-------------------------------------------------------------------
/*/{Protheus.doc} FMarBord
Validações na marcação do MSSelect do Bordero

@author  Ederson Colen
@since   22/06/2012
@param	nTotSel	- Total Selecionado
			lInverte - Variável de controle de inversão seleção
			oDlg		- Objeto da Tela

Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/
//-------------------------------------------------------------------
Static Function FMarBord(nTotSel,lInverte,oDlg)

Local lRetFunc := .T.

RecLock("TRBSE2", .F.)
If IsMark("E2_OK",cMarca,lInverte)
	If ! lInverte
		TRBSE2->E2_OK := cMarca
		//nTotSel += TRBSE2->E2_VALOR 
		nTotSel += TRBSE2->E2_SALDO
	Else
		TRBSE2->E2_OK := Space(Len(TRBSE2->E2_OK))
	 //  nTotSel -= TRBSE2->E2_VALOR  
	  nTotSel -= TRBSE2->E2_SALDO
	Endif
Else
	If ! lInverte
		TRBSE2->E2_OK := Space(Len(TRBSE2->E2_OK))
	   //nTotSel -= TRBSE2->E2_VALOR
	   nTotSel -= TRBSE2->E2_SALDO
	Else
		TRBSE2->E2_OK := cMarca
	   //nTotSel -= TRBSE2->E2_VALOR
	   nTotSel -= TRBSE2->E2_SALDO
  Endif
Endif
TRBSE2->(MsUnLock())

oDlg:Refresh()
oSayComTot:Refresh()

Return(lRetFunc)



//------------------------------------------------------------------- 
/*/{Protheus.doc} FConfTela
Função de confirmação da Tela de Seleção dos Borderos.
         
@author 	 Ederson Colen
@since 	 22/06/2012 
@version  P11  
@return	 xRetTela - Retorno para os pontos de entrada com os Borderos selecionados.
@obs	  	 Referente atendimento pontual
@param    lSaiTela - Variável de Tratamento da Tela
			 cTipRot  - Tipo de Rotina (SisPag ou Arquivo Pagamento)
			 lInverte - Opção de Inversão dos Marks
			 oDlg     - Objeto da Tela
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
Static Function FConfTela(xRetTela,lSaiTela,cTipRot,lInverte,oDlg)

Local lExistReg := .F.  

If cTipRot == "FINA420"
	xRetTela := 'E2_NUMBOR $ "'
   TRBSE2->(dbGoTop())
	While TRBSE2->(!Eof())
		If IsMark("E2_OK",cMarca,lInverte)
			xRetTela += TRBSE2->E2_NUMBOR+"#"
			If IsMark("E2_OK",cMarca,lInverte)
				RecLock("TRBSE2", .F.)
				TRBSE2->E2_OK := "XX"
				TRBSE2->(MsUnLock())
			Endif
			lExistReg := .T.
		EndIf
		TRBSE2->(dbSkip())
	EndDo
   If Right(xRetTela,1) == "#"
      xRetTela := SubStr(xRetTela,1,Len(xRetTela)-1)
   EndIf
	xRetTela += '"'
Else
	xRetTela := '"'
   TRBSE2->(dbGoTop())
	While TRBSE2->(!Eof())
		If IsMark("E2_OK",cMarca,lInverte)
			RecLock("TRBSE2", .F.)
			TRBSE2->E2_OK := "XX"
			TRBSE2->(MsUnLock())
			xRetTela += TRBSE2->E2_NUMBOR+"#"
			lExistReg := .T.
		EndIf
		TRBSE2->(dbSkip())
	EndDo
   If Right(xRetTela,1) == "#"
      xRetTela := SubStr(xRetTela,1,Len(xRetTela)-1)
   EndIf
	xRetTela += '"'
EndIf

If ! lExistReg
	Aviso("A T E N C A O","Deverá ser selecionado pelo menos um Bordero para geração do Arquivo.",{"OK"})
	xRetTela := ''
Else
   lSaiTela := .T.
	(oDlg:End())
EndIf

Return Nil



//------------------------------------------------------------------- 
/*/{Protheus.doc} FCancTela
Função de confirmação da Tela de Seleção dos Borderos.
         
@author 	 Ederson Colen
@since 	 22/06/2012 
@version  P11  
@return	 xRetTela - Retorno para os pontos de entrada com os Borderos selecionados.
@obs	  	 Referente atendimento pontual
@param    lSaiTela - Variável de Tratamento da Tela
			 cTipRot  - Tipo de Rotina (SisPag ou Arquivo Pagamento)
			 lInverte - Opção de Inversão dos Marks
			 oDlg     - Objeto da Tela
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
Static Function FCancTela(xRetTela,lSaiTela,cTipRot,lInverte,oDlg)

Local lExistReg := .F.  

If cTipRot == "FINA420"
	xRetTela := ' E2_NUM = "*********" '
Else
	xRetTela := '"******#"'
	cCanTelFil := xRetTela
EndIf

lSaiTela := .T.
(oDlg:End())

Return Nil



//------------------------------------------------------------------- 
/*/{Protheus.doc} FTelLog
Tela de Log e Gravação do arquivo de Log.
         
@author 	Ederson Colen
@since 	22/06/2012 
@version P11  
@obs	  	Referente atendimento pontual
@param   cTipRot - Tipo de Rotina pois é chamada Geração Arquivo e Sispag
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
User Function FTelLog(cTipRot)

Local oDlgLog, oTelLog
//Local nOpcT := 0
Local aLogs := {}

Local aTMTela  := {000,000,550,715}
Local aTGLog   := {005,005,350,250}
Local aPosBu1  := {257,240,050,014}
Local aPosBu2  := {257,300,030,014}

Local lSaiTLog := .T.
Local nTotBord := 0
Local nTotEnvi := 0

Local cFilePar := MV_PAR04

AADD(aLogs,"VENCIMENTO |FILIAL  |BORDERO |BANCO|               VALOR|ENV|")

cBorEnv := "'"
TRBSE2->(dbGoTop())
While TRBSE2->(! Eof())
	If TRBSE2->E2_OK == "XX"
        cBorEnv += TRBSE2->E2_NUMBOR+"','"
	EndIf
	TRBSE2->(dbSkip())
EndDo
cBorEnv := SubStr(cBorEnv,1,Len(AllTrim(cBorEnv))-2)
If ! Empty(cBorEnv)
	If FQryTela(cBorEnv)
		TRTSE2->(dbGoTop())
		While TRTSE2->(! Eof())
			AADD(aLogs,PADR(DTOC(STOD(TRTSE2->E2_VENCREA)),11)+"| "+PADR(TRTSE2->E2_FILIAL,7)+"| "+;
						  PADR(TRTSE2->E2_NUMBOR,7)+"| "+PADR(TRTSE2->E2_PORTADO,4)+"|"+PADL(Transform(TRTSE2->XX_VALOR,"@E 999,999,999,999.99"),19)+" | "+TRTSE2->EA_TRANSF+" |")
  	    If TRTSE2->EA_TRANSF == "S"
				nTotEnvi += TRTSE2->XX_VALOR
			EndIf	
			nTotBord += TRTSE2->XX_VALOR
		TRTSE2->(dbSkip())
		EndDo
	Else
		AADD(aLogs,"---------------------------------------------------------")
		AADD(aLogs,"   OCORREU ALGUM PROBLEMA DURANTE A GERACAO DO ARQUIVO ")
		AADD(aLogs,"        DE ENVIO CNAB FAVOR CORRIGIR OS PROBLEMAS")
		AADD(aLogs,"---------------------------------------------------------")
	EndIf
Else
	AADD(aLogs,"---------------------------------------------------------")
	AADD(aLogs,"   OCORREU ALGUM PROBLEMA DURANTE A GERACAO DO ARQUIVO ")
	AADD(aLogs,"        DE ENVIO CNAB FAVOR CORRIGIR OS PROBLEMAS")
	AADD(aLogs,"---------------------------------------------------------")
EndIf

If nTotBord > 0.00
	AADD(aLogs,"---------------------------------------------------------")
	AADD(aLogs,"TOTAL DE BORDEROS SELECIONADOS:    |"+PADL(Transform(nTotBord,"@E 999,999,999,999.99"),19)+" |")
	AADD(aLogs,"TOTAL DE BORDEROS TRANSMITIDOS:    |"+PADL(Transform(nTotEnvi,"@E 999,999,999,999.99"),19)+" |")
	AADD(aLogs,"---------------------------------------------------------")
EndIf

AADD(aLogs,"---------------------------------------------------------")
AADD(aLogs,"Caminho\Arquivo: "+cFilePar)
AADD(aLogs,"Usuário: "+SubString(cUsuario,7,15))
AADD(aLogs,"---------------------------------------------------------")

cLog := FGerLog(aLogs)

While lSaiTLog

   DEFINE MSDIALOG oDlgLog FROM aTMTela[01],aTMTela[02] TO aTMTela[03],aTMTela[04] PIXEL TITLE "BORDEROS SELECIONADOS"
  	oTelLog:= tMultiget():New(aTGLog[01],aTGLog[02],{|u|if(Pcount()>0,cLog:=u,cLog)},oDlgLog,aTGLog[03],aTGLog[04],,,,,,.T.,,,,,,.F.)
   @ aPosBu1[01],aPosBu1[02] BUTTON oBtn       PROMPT "Cons.Arq.Gerado" SIZE aPosBu1[03],aPosBu1[04] OF oDlgLog           ACTION {|| FTelaArq(cFilePar,@lSaiTLog,@oDlgLog)} Of oDlgLog PIXEL
   @ aPosBu2[01],aPosBu2[02] BUTTON oBtn       PROMPT "Fecha"           SIZE aPosBu2[03],aPosBu2[04] OF oDlgLog           ACTION {|| FSaiTela(cFilePar,aLogs,@lSaiTLog,@oDlgLog)} Of oDlgLog PIXEL

   ACTIVATE MSDIALOG oDlgLog CENTERED

EndDo

Return Nil



//-------------------------------------------------------------------
/*/{Protheus.doc} FQryTela
Funcao para executar a query para selecao dos registros na base de dados
conforme parametros passados.

@protected
@author		Ederson Colen
@since		03/07/2012
@version 	P11.5
@obs			Referente atendimento pontual
@param		cBorEnv - Borderos Selecionados

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------  
Static Function FQryTela(cBorEnv)

Local cQryTXT	:= ""
Local lRetQry  := .T.
Local cCodUser := RetCodUsr()
Local cDarReg  := cCodUser+StrTran(DToC(dDataBase),"/")+Left(StrTran(Time(),":"),3)

//Fecha o arquivo caso esteja aberto
U_FCloseArea("TRTSE2")

//cQryTXT := "SELECT E2_VENCREA, E2_FILIAL, E2_NUMBOR, E2_PORTADO, SUM(((E2.E2_VALOR - E2.E2_SDDECRE)+E2.E2_SDACRES)) AS XX_VALOR, CASE WHEN SUBSTRING(E2.E2_ZGRVARQ,1,"+AllTrim(Str(Len(AllTrim(cDarReg))))+") = '"+cDarReg+"' THEN 'S' ELSE 'N' END AS EA_TRANSF "
cQryTXT := "SELECT E2_VENCREA, E2_FILIAL, E2_NUMBOR, E2_PORTADO, SUM(((E2.E2_SALDO - E2.E2_SDDECRE)+E2.E2_SDACRES)) AS XX_VALOR, CASE WHEN SUBSTRING(E2.E2_ZGRVARQ,1,"+AllTrim(Str(Len(AllTrim(cDarReg))))+") = '"+cDarReg+"' THEN 'S' ELSE 'N' END AS EA_TRANSF "
cQryTXT += Chr(13) + "FROM "+RetSqlName("SE2")+" E2 "
cQryTXT += Chr(13) + "INNER JOIN "+RetSqlName("SEA")+" EA ON(EA.D_E_L_E_T_ <> '*' AND EA.EA_FILORIG = E2.E2_FILORIG AND EA.EA_PREFIXO = E2.E2_PREFIXO AND EA.EA_NUM = E2.E2_NUM  "
cQryTXT += Chr(13) + "AND EA.EA_PARCELA = E2.E2_PARCELA AND EA.EA_FORNECE = E2.E2_FORNECE AND EA.EA_NUMBOR = E2.E2_NUMBOR AND EA.EA_CART = 'P') "
cQryTXT += Chr(13) + "WHERE E2.D_E_L_E_T_ <> '*' "
cQryTXT += Chr(13) + "AND E2.E2_NUMBOR IN("+cBorEnv+") "
cQryTXT += Chr(13) + "AND E2.E2_SALDO > 0.00 "
cQryTXT += Chr(13) + "GROUP BY E2_NUMBOR, E2_FILIAL, E2_PORTADO, E2_VENCREA, CASE WHEN SUBSTRING(E2.E2_ZGRVARQ,1,"+AllTrim(Str(Len(AllTrim(cDarReg))))+") = '"+cDarReg+"' THEN 'S' ELSE 'N' END "
cQryTXT += Chr(13) + "ORDER BY E2_VENCREA, E2_FILIAL, E2_NUMBOR " 

//Cria o arquivo de trabalho da query posicionada
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryTXT),"TRTSE2",.F.,.T.)
("TRTSE2")->(dbGoTop())

//Valida se exitem informacoes no arquivo gerado.
If (("TRTSE2")->(Eof()))
	lRetQry  := .F.
EndIf

Return (lRetQry)



//------------------------------------------------------------------- 
/*/{Protheus.doc} FGerLog
Gera linhas com o arrey de logs.
         
@author 	Ederson Colen
@since 	22/06/2012 
@version P11  
@return	Linhas com as informações do arrey.
@obs	  	Referente atendimento pontual
@param   aLogs - Arrey com as informações do Log
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//-------------------------------------------------------------------
Static Function FGerLog(aLogs)

Local nX := 0
Local cLin := ""
   
For nX:= 1 to Len(aLogs)
	cLin += aLogs[nX] + chr(13) + chr(10)
	If(Len(cLin) >  50000)
		Exit
	EndIf
Next

Return (cLin)



//------------------------------------------------------------------- 
/*/{Protheus.doc} FTelaArq
Apresenta tela com as informações do Arquivo Gerado conforme parâmetro passado.
         
@author 	Ederson Colen
@since 	22/06/2012
@version P11
@return
@obs	  	Referente atendimento pontual
@param   cNomArqView - Nome do Arquivo texto que será apresentado
			lSaiTLog    - Variavel tratamento para fechamento da tela
			oDlgLog     - Objeto da tela.
        
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/ 
//-------------------------------------------------------------------
Static Function FTelaArq(cNomArqView,lSaiTLog,oDlgLog)

Local oDlgMemo, oMemo
Local cMemo := MemoRead(cNomArqView)

Local aTMTela  := {000,000,550,715}
Local aTGMemo  := {005,005,350,250}
Local aPosBut  := {257,300}
Local lSaiTMem := .T.

If Empty(cMemo) .And. At(".REM",cNomArqView) > 0
	cMemo := MemoRead(StrTran(cNomArqView,".REM",".TXT"))
EndIf

While lSaiTMem

   DEFINE MSDIALOG oDlgMemo FROM aTMTela[01],aTMTela[02] TO aTMTela[03],aTMTela[04] PIXEL TITLE Iif(Empty(cNomArqView),"ARQUIVO",cNomArqView)
   oMemo:= tMultiget():New(aTGMemo[01],aTGMemo[02],{|u|if(Pcount()>0,cMemo:=u,cMemo)},oDlgMemo,aTGMemo[03],aTGMemo[04],,,,,,.T.,,,,,,.F.)
   @ aPosBut[01],aPosBut[02] BUTTON oBtn PROMPT "Fecha" OF oDlgMemo PIXEL ACTION {|| lSaiTMem := .F. , oDlgMemo:End()} Of oDlgMemo Pixel

   ACTIVATE MSDIALOG oDlgMemo CENTERED

EndDo

Return Nil



//------------------------------------------------------------------- 
/*/{Protheus.doc} FSaiTela
Função para saida da Tela e gravação do arquivo de Log.
         
@author 	Ederson Colen
@since 	22/06/2012
@version P11
@return
@obs	  	 Referente atendimento pontual
@param    cNomArqView - Caminho e Nome do arquivo gerado CNAB
			 aLogs		 - Arrey de Logs
			 lSaiTLog    - Variavel de controle da Tela
			 oDlgLog     - Objeto da Tela
        
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FSaiTela(cNomArqView,aLogs,lSaiTLog,oDlgLog)

FGrvArgLog(cNomArqView,aLogs)

lSaiTLog := .F.
oDlgLog:End()
lSispag := .F.

Return Nil



//------------------------------------------------------------------- 
/*/{Protheus.doc} FGrvArgLog
Função de Gravação do Arquivo de Log.
         
@author 	Ederson Colen
@since 	22/06/2012
@version P11
@return
@obs	  	 Referente atendimento pontual
@param    cNomArqView - Caminho e Nome do arquivo gerado CNAB
			 aLogs		 - Arrey de Logs
        
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FGrvArgLog(cNomArqView,aLogs)

Local cFile := "" 
Local nHandle := 0
Local nX := 0
Local cLin := ""
Local nPosB := 0

//Busca o Nome do arquivo cnab para gerar o mesmo para Log.
If ! AT(".",cNomArqView) > 0
   For nXX := 1 To Len(AllTrim(cNomArqView))
		 If SubStr(cNomArqView,nXX,1) = "\"
			 nPosB := nXX
       EndIf
   Next nXX
	If nPosB > 0
      cFile := SubStr(cNomArqView,1,nPosB)+AllTrim(SubStr(cNomArqView,nPosB+1))+"LOG.Log"
	EndIf
Else
	cFile := StrTran(cNomArqView,SubStr(cNomArqView,AT(".",cNomArqView),4),"LOG.log")
EndIf

// Grava o arquivo de Log
nHandle := FCreate(cFile)

For nX:= 1 to Len(aLogs)
		cLin := aLogs[nX] + chr(13) + chr(10)
		FWrite (nHandle,cLin)
Next
FClose(nHandle)

Return Nil