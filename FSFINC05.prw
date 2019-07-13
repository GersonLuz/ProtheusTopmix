#Include "Totvs.ch"
#include "rwmake.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINC05
Auxiliar para o cadastro de clientes, liberação de crédito
        
@author	Fernando dos Santos Ferreira
@since 	26/02/2013
@version P11
@return	
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------
User Function FSFINC05()
Local		aCmpSA1		:= {}
Local		oButton1		:= Nil
Local		oButton2		:= Nil
Local		oDlg			:= Nil
Local		oCombo		:= Nil  
Local		aCombo		:= Nil
Local		oSayRis		:= Nil
Local		nPosFobDet  := 0
Local		cItemOld		:= ""
Local		cLblCli		:= ""
Local		cSayRis		:= "Risco"
Local		cLblLimite	:= "Limite de Crédito"
Local		cLblVenci	:= "Vencimento"
Local		cLblLib		:= "Data da Liberação"
Local		cItems		:= SA1->A1_RISCO
Local		dVencimento	:= SA1->A1_VENCLC
Local		nLimite     := SA1->A1_LC
Local		dDataLib		:=	Date()
Local		aDadUser		:= FValidaUsr()
Local		lReadOnly	:= .F.
Local		lContinua	:= .T.

Private aFieldA1	:= {"A1_RISCO"} 

If aDadUser[01]
	
	// Cliente com risco igual a E e Nivel de usuário diferente de 1	
	lReadOnly	:= (cItems > "D" .And. aDadUser[06] != "1")
	
	If lReadOnly
	   MsgBox("Você não permissão para alteração do risco E", "Manutenção de Crédito", "INFO")
	EndIf
	
	lContinua	:= nLimite >= aDadUser[04] .And. nLimite <= aDadUser[05]
		
	FMod2aHeader("SA1", @aCmpSA1)
	
	cLblCli += AllTrim(SA1->A1_COD) 
	cLblCli += " - " + SA1->A1_LOJA 
	cLblCli += " - " + AllTrim(SA1->A1_NOME) 
	cLblCli += " - " + IIF(SA1->A1_PESSOA == "J", Transform(SA1->A1_CGC, "@r 99.999.999/9999-99"), Transform(SA1->A1_CGC, "@r 999.999.999-99"))
	
	nPosFobDet := aScan( aCmpSA1 ,{ |x| Alltrim(x[02]) == AllTrim("A1_RISCO") } )
	If nPosFobDet > 0
		aCombo := StrTokArr(aCmpSA1[nPosFobDet][11], ";")
	EndIf
	
	oDlg 		:= MsDialog():New(180,180,300,680, ".:: Manutenção de Crédito ::.",,,,,,,,,.T.)  
	
	oSayCli	:= TSay():New(005,005,{||cLblCli},oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,220,20,,,,,,)
	
	oSayRis	:= TSay():New(016,005,{||cSayRis},oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,090,20,,,,,,)
	@ 023,005 MSCOMBOBOX oCombo VAR cItems ITEMS aCombo SIZE 055,10 OF oDlg PIXEL Valid FValRisE(@lReadOnly, @nLimite, @cItems)
	
	oSayRis	:= TSay():New(016,065,{||cLblLimite},oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,090,20,,,,,,)
	oGetLim	:= TGet():New( 023,065 ,{|u| If(PCount() > 0,nLimite:=u, nLimite)},oDlg, 60, 009,PesqPict("SA1","A1_LC" ),{|| },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,@lReadOnly,.F.,"","nLimite",,)
	
	oSayVen	:= TSay():New(016,130,{||cLblVenci},oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,090,20,,,,,,)
	oGetVen	:= TGet():New(023,130 ,{|u| If(PCount() > 0,dVencimento:=u, dVencimento)},oDlg, 50, 009,PesqPict("SA1","A1_VENCLC" ),,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,@lReadOnly,.F.,"","dVencimento",,)
	
	oSayLib	:= TSay():New(016,190,{||cLblLib },oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,090,20,,,,,,)
	oGetLib	:= TGet():New(023,185,{|u| If(PCount() > 0, dDataLib:=u, dDataLib)}, oDlg, 50, 009, PesqPict("SA1","A1_LIBCRED" ),, CLR_BLACK  , CLR_WHITE,,,,.T.,"",,,.F.,.F.,, .T., .F.,"","dDataLib",,)
	
	oButton1	:=tButton():New(40,005,"Confirmar"	,oDlg,{|| FSave(@lContinua, @cItems, @nLimite, @dVencimento, @dDataLib, @aDadUser, @lReadOnly), IIF(@lContinua, oDlg:End(), Nil) },50,15,,,,.T.)
	oButton2	:=tButton():New(40,060,"Cancelar"	,oDlg,{|| oDlg:End()},50,15,,,,.T.)
	         
	oDlg:lCentered := .T.
	
	oCombo:LREADONLY := lReadOnly
	
	oDlg:Activate()
Else
   MsgBox("Você não tem privilégios para executar esse processo. Verifique no cadastro de alçadas.", "Manutenção de Crédito", "STOP")
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FValidaUsr
Realiza a validação do usuário

@author	   Fernando Ferreira
@since	   26/02/2012
@version    P11
@obs	      

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//------------------------------------------------------------------- 
Static Function FValidaUsr()
Local		aAreOld	:= {SA1->(GetArea()), P07->(GetArea()), GetArea()}
Local		aReturn 	:= {}
Local		cCodUser	:= RetCodUsr()

// P07_FILIAL+P07_USARIO+P07_TIPO
P07->(dbSetOrder(01))

If P07->(dbSeek(xFilial("P07")+cCodUser))
	AAdd(aReturn, .T.)
	AAdd(aReturn, cCodUser)
	AAdd(aReturn, P07->P07_TIPO)
	AAdd(aReturn, P07->P07_VLRINI)
	AAdd(aReturn, P07->P07_VLRFIM)
	AAdd(aReturn, P07->P07_NVLUSU)
Else
	AAdd(aReturn, .F.)
	AAdd(aReturn, cCodUser)
	AAdd(aReturn, "")
	AAdd(aReturn, 0 )
	AAdd(aReturn, 0 )
	AAdd(aReturn, 0 )
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return AClone(aReturn)

//-------------------------------------------------------------------
/*/{Protheus.doc} FSave
Salva os valores na SA1

@author	   Fernando Ferreira
@since	   11/06/2012
@version    P11
@param		lReadOnly	Se true continua o processo
@param		cItems		Risco
@param		nLimite		Limite de crédito
@obs	      

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo                  
/*/
//-------------------------------------------------------------------
Static Function FValRisE(lReadOnly, nLimite, cItems)

If cItems == "E"
	lReadOnly 	:= .T.
	nLimite		:= 0
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FSave
Salva os valores na SA1

@author	   Fernando Ferreira
@since	   11/06/2012
@version    P11
@param		lContinua	Se true continua o processo
@param		cItems		Risco
@param		nLimite		Limite de crédito
@param		dVencimento	Data de Vencimento
@param		dDataLib		Data de Liberação
@obs	      

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
                  
/*/
//-------------------------------------------------------------------
Static Function FSave(lContinua, cItems, nLimite, dVencimento, dDataLib, aDadUser, lReadOnly)
Local		cVlrInicial	:= ""
Local		cVlrFinal	:= ""
Local		lExibMsg		:= .T.

FValValor(@nLimite, @aDadUser, @lContinua)

If cItems == "E" .And. nLimite > 0
	lContinua 	:= .F.
	lExibMsg		:= .F.
	MsgBox("Ao definir um risco E o valor do limite de crédito não pode se maior do que 0.", "Manutenção de Crédito", "Alert")		
EndIf

If lContinua
	If SA1->(RecLock("SA1", .F.))
		SA1->A1_RISCO 		:= cItems
		SA1->A1_VENCLC		:= dVencimento
		SA1->A1_LC			:= nLimite
		SA1->A1_LIBCRED	:= dDataLib
		SA1->(MsUnLock()) 
		If SA1->A1_ZTIPO == 'S'
			U_FSPutTab("SA1","A")
		EndIf
	Else
		lContinua 	:= .F.			
	EndIf
	
	If lContinua 
		FSetLogAlt(SA1->A1_RISCO, SA1->A1_VENCLC, SA1->A1_LC, SA1->A1_COD, SA1->A1_LOJA)
	EndIf
	
ElseIf lExibMsg
	cVlrInicial	:= Transform(aDadUser[04], PesqPict("SA1","A1_LC" ))
	cVlrFinal	:= Transform(aDadUser[05], PesqPict("SA1","A1_LC" ))	
	MsgBox("Valor fora da sua alçada Valor Minimo: " + AllTrim(cVlrInicial) + " Valor Máximo: " + AllTrim(cVlrFinal), "Manutenção de Crédito", "Alert")	
EndIf

Return Nil
                            
//-------------------------------------------------------------------
/*/{Protheus.doc} FValValor
Valida o valor digitado está dentro do valor da alçada.

@author	   Fernando Ferreira
@since	   11/06/2012
@version    P11
@param		nLimite 	Valor do informado
@param		aDadUser	Dadoss do usuário
@obs	      

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
                  
/*/
//-------------------------------------------------------------------
Static Function FValValor(nLimite, aDadUser, lContinua )
Local		lReturn 	:= .T.

If !(nLimite >= aDadUser[04] .And. nLimite <= aDadUser[05])
	lReturn := .F.
	lContinua := .F.
Else
	lContinua := .T.	
EndIf

Return lReturn

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
/*/{Protheus.doc} FMod2aHeader
Monta a aHeader

@author	   Fernando Ferreira
@since	   11/06/2012
@version    P11
@param		cRisco			Risco do cliente
@param		dVencimento		Data de vencimento
@param		nLimite			Limite de crédito
@obs	      

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo

/*/
//------------------------------------------------------------------- 
Static Function FSetLogAlt(cRisco, dVencimento, nLimite, cCodigo, cLoja)
Default		cRisco			:= ""
Default		dVencimento		:= CTod("")
Default		nLimite			:= 0

If P08->(RecLock("P08", .T.))
	P08->P08_FILIAL	:= xFilial("P08")
	P08->P08_SEQ		:= U_FSGETCOD("P08","P08_SEQ","",9)
	P08->P08_USUARI	:= RetCodUsr()
	P08->P08_CLIENT	:= cCodigo
	P08->P08_LOJA		:= cLoja
	P08->P08_DATA		:= Date()
	P08->P08_HORA		:= Time()
	P08->P08_RISCO 	:= cRisco
	P08->P08_VENCLC	:= dVencimento
	P08->P08_LC    	:= nLimite
	P08->(MsUnLock()) 
EndIf

Return Nil
          
