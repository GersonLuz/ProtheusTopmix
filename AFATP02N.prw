#Include "PROTHEUS.CH"
#include "TopConn.ch"
#Define BMP_COT
//--------------------------------------------------------------
/*/{Protheus.doc} AFATP02N
Description Montagem painel de gestão

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
@Obs    MC_FREQATU: Tempo em segundos para atualizar as guias 
/*/
//--------------------------------------------------------------
User Function AFATP02N()
Local   oBitmap1
Local   oBitmap2
Local   oButton1
Local   oButton2
Local   oButton3
Local   oButton4
Local   oButton5
Local   oButton6
Local   oButton7
Local   oButton8
Local   oButton9
Local   oComboBo1
Local   oGet1
Local   cGet1    := Space(6)
Local   oGroup1
Local   oSay1
Local   oSay2
Local   oSButton1
Local   oSButton2
Local   nComboBo1 :="Numero da Solicitação"
Private nRegSC8   :=0
Private oFolder1
Private oFont1        := TFont():New("Calibri",,022,,.T.,,,,,.F.,.F.)
Private oFont2        := TFont():New("Calibri",,019,,.T.,,,,,.F.,.F.)
Private oFont3        := TFont():New("Calibri",,017,,.T.,,,,,.F.,.F.)
Private oFont4        := TFont():New("Calibri",,019,,.T.,,,,,.F.,.F.)

Private aRotina       := {}
Private oFlagVERMELHO := LoadBitMap(GetResources(),"BR_VERMELHO")
Private oFlagVERDE    := LoadBitMap(GetResources(),"BR_VERDE")
Private oFlagPRETO  	 := LoadBitMap(GetResources(),"BR_PRETO")
Private oFlagAMARELO  := LoadBitMap(GetResources(),"BR_AMARELO")
Private oFlagLARANJA  := LoadBitMap(GetResources(),"BR_LARANJA")
Private oFlagCINZA 	 := LoadBitMap(GetResources(),"BR_CINZA")
Private oFlagPINK 	 := LoadBitMap(GetResources(),"BR_PINK")
Private oFlagAZUL 	 := LoadBitMap(GetResources(),"BR_AZUL")
Private oFlagMARRON   := LoadBitMap(GetResources(),"BR_AZUL")
Private oFlagBRANCO   := LoadBitMap(GetResources(),"BR_AZUL")
Private oOk           := LoadBitmap( GetResources(), "LBOK")
Private oNo           := LoadBitmap( GetResources(), "LBNO")

Private oWBrowse1
Private aWBrowse1  := {}
Private oWBrowse2
Private aWBrowse2  := {}
Private oWBrowse3
Private aWBrowse3  := {}
Private oWBrowse4
Private aWBrowse4  := {}
Private oWBrowse5
Private oButton0
Private aWBrowse5  := {}
Private lWBrowse1  := .T.
Private lWBrowse2  := .T.
Private lWBrowse3  := .T.
Private lWBrowse4  := .T.
Private lWBrowse5  := .F.
Private cCodUser   := RetCodUsr()
Static  oDlg

Private aFilCla	 := {"1=Equipamento Parado","2=Manutencao Corretiva","3=Manutencao Preventiva","4=Compra para Estoque","5=Uso e Consumo","Todos"}
Private oFilCla
Private nFilCla	 := 0
Private nContSCs   := 0
Private cFilB1	    := Space(6)
Private cGrpB1	    := Space(4)
Private oFilB1
Private oGrpB1

Private cGrpPrd    := ""
Private aGrpPrd    := MCGRPCOM()

//Usuário que estiver neste parametro podera ver tudo.
//Caso não esteja, verá somente o que é seu.

Private cUsuMst    := SuperGetMv("MV_ZUSUPCO",,"000000")
Private lPainel5   := SuperGetMv("MV_ZPNLPND",,.F.) // Exibe painel pendente.
Private lChkNew    := .T.  // Atualiza as abas com os dados on-line.
Private lChkOld    := .T.

Private cFileDB04  := ""
Private aStr004    := {}
Private aBrw004    := {}
Private cPict      := "@E 999,999,999.99"
Private nInicio    := Seconds()
Private aInicio    := {nInicio,nInicio,nInicio,nInicio,nInicio}
Private lRotPad    := .F.

//Variáveis requeridas pela MsGetDb
Private aRotina, aCols:= {}, aHeader:= {}, lRefresh

aRotina:={{"Pesquisar" , "AxPesqui", 0, 1},;
          {"Visualizar", "AxVisual", 0, 2}}

SetKey( VK_F12, { || fConsulta() })

Define MsDialog oDlg TITLE "Painel de Gestão" FROM 000, 000  TO 550, 1000 COLORS 0, 16777215 PIXEL

@ 003, 166 SAY oSay1 PROMPT "PAINEL ON-LINE - GESTÃO DE COMPRAS" SIZE 165, 011 OF oDlg FONT oFont1 COLORS 255, 16777215 PIXEL
@ 015, 001 GROUP oGroup1 TO 262, 498 OF oDlg COLOR 0, 16777215 PIXEL
@ 019, 004 FOLDER oFolder1 SIZE 488, 239 OF oDlg ITEMS "SC - Pendentes","SC - Em Cotação","OC - Aguardando Aprovação","OC - Liberados" COLORS 128, 16777215 PIXEL

oFolder1:bSetOption := {|nAtu| fWBrowse(nAtu)}

// FOLDER 1 //
MsgRun("Carregando SC pendentes.. ",,{|| CursorWait(), fWBrowse1() ,CursorArrow()})  // aba 01
@ 208, 315 BUTTON oButton1 PROMPT "Visualizar"    SIZE 045, 012 OF oFolder1:aDialogs[1] FONT oFont3 ACTION Eval({||u_AFATP22("1"), fWBrowse(1) })       PIXEL
@ 208, 363 BUTTON oButton1 PROMPT "Marcar Todos"  SIZE 056, 012 OF oFolder1:aDialogs[1] FONT oFont3 ACTION Eval({||fMarcaT(aWBrowse1)})               PIXEL
@ 208, 425 BUTTON oButton1 PROMPT "Gerar Cotação" SIZE 056, 012 OF oFolder1:aDialogs[1] FONT oFont3 ACTION Eval({||u_AFATP03(aWBrowse1) , fWBrowse(1) }) PIXEL

@ C(161),C(005) Say    "Classificação"        Size C(037),C(008) COLOR CLR_BLACK    PIXEL OF oFolder1:aDialogs[1]
@ C(161),C(062) Say    "Filial"               Size C(018),C(008) COLOR CLR_BLACK    PIXEL OF oFolder1:aDialogs[1]
@ C(161),C(098) Say    "Grupo"                Size C(018),C(008) COLOR CLR_BLACK    PIXEL OF oFolder1:aDialogs[1]
@ C(161),C(135) Say    "Grupo de Compradores" Size C(070),C(008) COLOR CLR_BLACK    PIXEL OF oFolder1:aDialogs[1]
@ C(162),C(222) Button "Filtrar"              Size C(020),C(012) Action fFilBrw01() PIXEL OF oFolder1:aDialogs[1]

@ C(166),C(006) ComboBox oFilCla VAR nFilCla Items aFilCla Size C(052),C(009) PIXEL OF oFolder1:aDialogs[1]
@ C(166),C(061) MsGet    oFilB1  Var cFilB1  Size C(35),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oFolder1:aDialogs[1] Valid fWBrowse1()
@ C(166),C(099) MsGet    oGrpB1  Var cGrpB1  Size C(35),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oFolder1:aDialogs[1] Valid fWBrowse1()
@ C(166),C(136) ComboBox oGrpPrd VAR cGrpPrd Items aGrpPrd Size C(080),C(009) PIXEL OF oFolder1:aDialogs[1] Valid fFilBrw01()

// FOLDER 2 //
MsgRun("Carregando SC - Em Cotação.. ",,{|| CursorWait(), fWBrowse2()() ,CursorArrow()})
@ 207, 005 BUTTON oButton0 PROMPT "E-mail"           SIZE 040, 012 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_AFATR02() , fWBrowse(2) }) PIXEL
@ 207, 050 BUTTON oButton0 PROMPT "Excluir Cot"      SIZE 040, 012 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_AFATP17(),lChkNew := .T., fWBrowse(2) }) PIXEL
@ 207, 095 BUTTON oButton0 PROMPT "Excluir For"      SIZE 040, 012 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_AFATP18(),lChkNew := .T., fWBrowse(2) }) PIXEL
@ 207, 140 BUTTON oButton2 PROMPT "Atualizar Cot."   SIZE 040, 012 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||IIF( ! Empty(aWBrowse2[oWBrowse2:nAt,2]),U_AFATP05(aWBrowse2[oWBrowse2:nAt,2],aWBrowse2[oWBrowse2:nAt,6],lRotPad),),fWBrowse(2) }) PIXEL
   
@ 207, 185 BUTTON oButton9 PROMPT "Incluir For"		  SIZE 040, 012 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_AFATP19() , fWBrowse(2) }) PIXEL
@ 207, 230 BUTTON oButton9 PROMPT "Visualizar SC."   SIZE 040, 012 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_AFATP04() , fWBrowse(2) }) PIXEL
@ 207, 275 BUTTON oButton2 PROMPT "Analisar Cot."    SIZE 040, 012 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({|| IIF(!Empty(aWBrowse2[oWBrowse2:nAt,2]),u_AFATP13(aWBrowse2[oWBrowse2:nAt,2],aWBrowse2[oWBrowse2:nAt,6]),) , fWBrowse(3) }) PIXEL
@ 207, 320 BUTTON oButton3 PROMPT "Gera Ocorr."      SIZE 040, 012 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_AFATP06(aWBrowse2) , fWBrowse(2) }) PIXEL
@ 207, 365 BUTTON oButton4 PROMPT "Gerar OC."     	  SIZE 040, 012 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||IIF(!Empty(aWBrowse2[oWBrowse2:nAt,2]),u_AFATP08(aWBrowse2[oWBrowse2:nAt,2]),) , fWBrowse(2) }) PIXEL
@ 207, 410 BUTTON oButton5 PROMPT "Acomp. Ocorr."    SIZE 040, 012 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||IIF(!Empty(aWBrowse2[oWBrowse2:nAt,2]),u_AFATP07(aWBrowse2[oWBrowse2:nAt,2]),) , fWBrowse(2)}) PIXEL

@ 005, 002 SAY oSay2 PROMPT "Pesquisar Por:" SIZE 052, 009 OF oFolder1:aDialogs[2] FONT oFont2 COLORS 128, 16777215 PIXEL
@ 263, 050 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS {"Numero da Solicitação","Numero da Cotação"} SIZE 077, 011 OF oFolder1:aDialogs[2] COLORS 0, 16777215 FONT oFont3 PIXEL
@ 263, 129 MSGET oGet1 VAR cGet1 SIZE 045, 011  OF oFolder1:aDialogs[2] COLORS 0, 16777215 FONT oFont3 PIXEL

// FOLDER 3 //
MsgRun("Carregando OC aguardando Aprovação.. ",,{|| CursorWait(), fWBrowse3() ,CursorArrow()})  // aba 03
@ 207, 350 BUTTON oButton6 PROMPT "Excluir OC."             SIZE 050, 012 OF oFolder1:aDialogs[3] FONT oFont3 ACTION Eval({||U_AFATP20("3"), lChkNew := .T. , fWBrowse(3) }) PIXEL
@ 207, 405 BUTTON oButton6 PROMPT "Visualizar Ordem Compra" SIZE 076, 012 OF oFolder1:aDialogs[3] FONT oFont3 ACTION Eval({||u_AFATP09(),fWBrowse(3)}) PIXEL
@ 207, 300 BUTTON oButton8 PROMPT "Imprimir OC"             SIZE 046, 012 OF oFolder1:aDialogs[3] FONT oFont3 ACTION Eval({||u_AFATR01(aWBrowse3[oWBrowse3:nAt,11])}) PIXEL
@ 207, 252 BUTTON oButton8 PROMPT "Mensagem PC"             SIZE 046, 012 OF oFolder1:aDialogs[3] FONT oFont3 ACTION Eval({||u_AFATT01(aWBrowse3[oWBrowse3:nAt,11])}) PIXEL

// FOLDER 4 //
MsgRun("Carregando OC -  Liberados.. ",,{|| CursorWait(), fWBrowse4() ,CursorArrow()})  // aba 04

DbSelectArea("DBTMP04")
DbGoTop()

oObjFld04 := BrGetDDB():New( 1,1,481,205,,,, oFolder1:aDialogs[4] ,,,,,,,,,,,,.F.,"DBTMP04",.T.,,.F.,,, ) 

For nXy := 1 To Len(aBrw004)
    bColumn := &("{|| DBTMP04->"+aBrw004[nXy][1]+" }")
    nTamPix := aStr004[nXy][3] * IIf(aStr004 [nXy][2]=="D",4,4) 
    nTamPix := IIf(nTamPix <= 0,Len(aBrw004[nXy][2]),nTamPix)
    cPosInf := IIf(aStr004 [nXy][2]=="C","LEFT","RIGHT")
    oObjFld04:AddColumn(TCColumn():New( aBrw004[nXy][2] , bColumn ,aBrw004[nXy][4],,, cPosInf , nTamPix ,.F.,.F.,,,,.F.,))
Next

@ 207, 295 BUTTON oButton6 PROMPT "Excluir OC." SIZE 050, 012 OF oFolder1:aDialogs[4] FONT oFont3 ACTION Eval({|| U_AFATP20("4.1",DBTMP04->C7_FILIAL,DBTMP04->C7_NUM,DBTMP04->C7_NUMCOT) , lChkNew := .T., fWBrowse(4) }) PIXEL

@ 207, 350 BUTTON oButton8 PROMPT "Imprimir OC" SIZE 046, 012 OF oFolder1:aDialogs[4] FONT oFont3 ACTION Eval({|| U_AFATR01( DBTMP04->RECSC7  )}) PIXEL //ok

@ 207, 398 BUTTON oButton7 PROMPT "Sinalizar Processo Finalizado" SIZE 085, 012 OF oFolder1:aDialogs[4] FONT oFont3 ACTION Eval({||u_AFATP11() , fWBrowse(4) }) PIXEL

// FOLDER 5 //
If lPainel5
   MsgRun("Carregando OC - Entrega Pendente.. ",,{|| CursorWait(), fWBrowse5() ,CursorArrow()})  // aba 05
	@ 207, 350 BUTTON oButton8 PROMPT "Imprimir OC" SIZE 046, 012 OF oFolder1:aDialogs[5] FONT oFont3  ACTION  Eval({||U_AFATR01(aWBrowse5[oWBrowse5:nAt,11])}) PIXEL
Endif

@ 207, 247 BUTTON oButton8 PROMPT "Mensagem PC" SIZE 046, 012 OF oFolder1:aDialogs[4] FONT oFont3  ACTION  Eval({|| U_AFATT01( DBTMP04->RECSC7 )}) PIXEL  //ok

Define SBUTTON oSButton2 FROM 263, 178 TYPE 17 ACTION fPesquisa(nComboBo1,cGet1) OF oFolder1:aDialogs[2] ENABLE
Define SBUTTON oSButton1 FROM 263, 468 TYPE 01 ACTION fConfirma() OF oDlg ENABLE

@ 263,002 CheckBox oChkMar Var lChkNew Prompt "Atualiza Dados On-Line?" Message Size 80, 007 Pixel OF oDlg ON CLICK FMsgAviso()

@ 000, 418 BITMAP oBitmap1 SIZE 035, 015 OF oDlg FILENAME "\Imagens\Flapa_Totvs.png" PIXEL
@ 000, 460 BITMAP oBitmap2 SIZE 035, 015 OF oDlg FILENAME "\Imagens\TopMix_Totvs.png" PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Set Key VK_F12	To

If Select("DBTMP04") > 0
   DbSelectArea("DBTMP04")
   DbCloseArea()
   FErase(cFileDB04 + GetDBExtension())
Endif

Return




//--------------------------------------------------------------
/*/{Protheus.doc} fWBrowse

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fWBrowse(pop) //

If (Seconds() - aInicio[pop]) <= SuperGetMv("MC_FREQATU",,30)
   Return .T.
Endif

MsgRun("Atualizando informações... ",,{|| CursorWait(), MCATUFLD(pop) ,CursorArrow()})

aInicio[pop] := Seconds()

Return(.T.)




//--------------------------------------------------------------
/*/{Protheus.doc} fconfirma

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fConfirma(aBrow1,oMSNewGe1) //

oDlg:End()

Return(.T.)





//--------------------------------------------------------------
/*/{Protheus.doc} fWBrowse1

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fWBrowse1()
Local aAUx:= {}

If ! lChkNew
	If Empty(cFilB1) .And. Empty(cGrpB1) // .F. = não atualiza o browse
		Return .T.
	Else
		lChkNew := .T.
		oChkMar:Refresh()
	Endif
Endif

aWBrowse1:={}
aAUx := fSelecao1()

If Len(aAUx)==0
	Aadd(aWBrowse1,{.F.,oFlagVERMELHO,"","","","","",0,"","","","","",""})
ElSe
	aWBrowse1:=Aclone(aAUx)
Endif

If lWBrowse1
	lWBrowse1 :=.F.
	@ 00,00 LISTBOX oWBrowse1 Fields HEADER "","Flag","Empresa","Filial Solicitante","C.Custo","Numero da SC","Descrição","Quantidade","Classificação","Grupo","Descrição Grupo","Produto","Item SC" SIZE 481, 205 OF oFolder1:aDialogs[1] PIXEL ColSizes 50,50
Endif

oWBrowse1:SetArray(aWBrowse1)
oWBrowse1:bLine := {|| {If(aWBrowse1[oWBrowse1:nAT,1],oOk,oNo),;
                           aWBrowse1[oWBrowse1:nAt,02],;
                           aWBrowse1[oWBrowse1:nAt,03],;
                           aWBrowse1[oWBrowse1:nAt,04],;
                           aWBrowse1[oWBrowse1:nAt,05],;
                           aWBrowse1[oWBrowse1:nAt,06],;
                           aWBrowse1[oWBrowse1:nAt,07],;
                           aWBrowse1[oWBrowse1:nAt,08],;
                           aWBrowse1[oWBrowse1:nAt,09],;
                           aWBrowse1[oWBrowse1:nAt,10],;
                           aWBrowse1[oWBrowse1:nAt,11],;
                           aWBrowse1[oWBrowse1:nAt,12],;
                           aWBrowse1[oWBrowse1:nAt,13],;
                           aWBrowse1[oWBrowse1:nAt,14] }}

oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],;
oWBrowse1:DrawSelect()}
oWBrowse1:Refresh()

Return()





//--------------------------------------------------------------
/*/{Protheus.doc} fWBrowse2

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fWBrowse2()//SC - Em Cotação
Local aAUx		 := {}
Local nreg      :=1

If ! lChkNew
	If Empty(cFilB1) .And. Empty(cGrpB1) // .F. = não atualiza o browse
		Return .T.
	Else
		lChkNew := .T.
		oChkMar:Refresh()
	Endif
Endif

nRegSC8  :=0
aWBrowse2:={}
aAUx:=fSelecao2()

If Len(aAUx)=0
	Aadd(aWBrowse2,{oFlagVERMELHO," "," "," "," "," "," "," "})
ElSe
	aWBrowse2:=Aclone(aAUx)
Endif

// Insert items here
If lWBrowse2
	lWBrowse2:=.F.
	@ 000, 000 LISTBOX oWBrowse2 Fields HEADER "Flag","Num. Cotação","Cod.Forn.","Loja","Nome do Fornecedor","Filial","Comprador","Num. SC." SIZE 481, 205 OF oFolder1:aDialogs[2] PIXEL ColSizes 50,50
Endif
oWBrowse2:SetArray(aWBrowse2)
oWBrowse2:bLine := {|| {aWBrowse2[oWBrowse2:nAt,1],;
                        aWBrowse2[oWBrowse2:nAt,2],;
                        aWBrowse2[oWBrowse2:nAt,3],;
                        aWBrowse2[oWBrowse2:nAt,4],;
                        aWBrowse2[oWBrowse2:nAt,5],;
                        aWBrowse2[oWBrowse2:nAt,6],;
                        aWBrowse2[oWBrowse2:nAt,7],;
                        aWBrowse2[oWBrowse2:nAt,8]}}

// DoubleClick event
oWBrowse2:bChange  	:= {||nRegSC8:=oWBrowse2:nAt,oWBrowse2:Refresh() }//oBrowse:bSeekChange
oWBrowse2:Refresh()
Return()





//--------------------------------------------------------------
/*/{Protheus.doc} fWBrowse3

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fWBrowse3() //OC -  Aguardando Aprovação
Local aAUx      :={}
If ! lChkNew
	If Empty(cFilB1) .And. Empty(cGrpB1) // .F. = não atualiza o browse
		Return .T.
	Else
		lChkNew := .T.
		oChkMar:Refresh()
	Endif
Endif
aWBrowse3 := {}
aAUx:=fSelecao3()
If Len(aAUx)=0
	Aadd(aWBrowse3,{oFlagAZUL,"","","","","","","","","",""})
ElSe
	nRegSC8:=1
	aWBrowse3:=Aclone(aAUx)
Endif
// Insert items here
If lWBrowse3
	lWBrowse3:=.F.
	@ 000, 000 LISTBOX oWBrowse3 Fields HEADER "Flag","Num. OC","Num. SC","Num. Cotação","Fornecedor","Loja","Produto","Descrição","Quantidade","Filial" SIZE 481, 205 OF oFolder1:aDialogs[3] PIXEL ColSizes 50,50
Endif
oWBrowse3:SetArray(aWBrowse3)
oWBrowse3:bLine := {|| {aWBrowse3[oWBrowse3:nAt,1],;
                        aWBrowse3[oWBrowse3:nAt,2],;
                        aWBrowse3[oWBrowse3:nAt,3],;
                        aWBrowse3[oWBrowse3:nAt,4],;
                        aWBrowse3[oWBrowse3:nAt,5],;
                        aWBrowse3[oWBrowse3:nAt,6],;
                        aWBrowse3[oWBrowse3:nAt,7],;
                        aWBrowse3[oWBrowse3:nAt,8],;
                        aWBrowse3[oWBrowse3:nAt,9],;
                        aWBrowse3[oWBrowse3:nAt,10]}}
// DoubleClick event
oWBrowse3:bChange  	:= {||nRegSC8:=oWBrowse3:nAt,oWBrowse3:Refresh() }//oBrowse:bSeekChange
oWBrowse3:Refresh()
Return()





//--------------------------------------------------------------
/*/{Protheus.doc} fWBrowse4

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fWBrowse4() //"OC -  Liberados"

If ! lChkNew
	If Empty(cFilB1) .And. Empty(cGrpB1) // .F. = não atualiza o browse
		Return .T.
	Else
		lChkNew := .T.
		oChkMar:Refresh()
	Endif
Endif

aWBrowse4 := {}
nRegSC8   :=1

fSelecao4()

Aadd(aWBrowse4,{oFlagVERDE,"","","","","","","","","",""})

Return()




//--------------------------------------------------------------
/*/{Protheus.doc} fWBrowse5

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fWBrowse5() //OC - Entrega Pendente
If ! lChkNew
	If Empty(cFilB1) .And. Empty(cGrpB1) // .F. = não atualiza o browse
		Return .T.
	Else
		lChkNew := .T.
		oChkMar:Refresh()
	Endif
Endif

If ! lPainel5
	Return .T. // não executa o painel 5
Endif

aWBrowse5 := {}

aAUx:=fSelecao5()

If Len(aAUx)=0
	Aadd(aWBrowse5,{oFlagAMARELO,"","","","","","","","",""})
ElSe
	aWBrowse5:=Aclone(aAUx)
Endif

// Insert items here
If lWBrowse5 .And. lPainel5
	lWBrowse5:=.F.
	@ 000, 000 LISTBOX oWBrowse5 Fields HEADER "Flag","Num. OC","Num. SC","Num. Cotação","Fornecedor","Loja","Produto","Descrição Produto","Quantidade","Filial" SIZE 481, 205 OF oFolder1:aDialogs[5] PIXEL ColSizes 50,50
Endif
oWBrowse5:SetArray(aWBrowse5)
oWBrowse5:bLine := {|| {aWBrowse5[oWBrowse5:nAt,1],;
                        aWBrowse5[oWBrowse5:nAt,2],;
                        aWBrowse5[oWBrowse5:nAt,3],;
                        aWBrowse5[oWBrowse5:nAt,4],;
                        aWBrowse5[oWBrowse5:nAt,5],;
                        aWBrowse5[oWBrowse5:nAt,6],;
                        aWBrowse5[oWBrowse5:nAt,7],;
                        aWBrowse5[oWBrowse5:nAt,8],;
                        aWBrowse5[oWBrowse5:nAt,9],;
                        aWBrowse5[oWBrowse5:nAt,10]}}
oWBrowse5:DrawSelect()
Return





//--------------------------------------------------------------
/*/{Protheus.doc} fSelecao1

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fSelecao1()
Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()
Local aWBrowAux := {}
Local aClassi   := {}
Local aEmpresa  :={}
Local xE        :=0
Local cFilAtu 	:= cFilial
Local cEmpAux   :=""
Local cFromSC1  := "%"+"SC1"+cEmpAux+"%"
Local cFromSB1  := "%"+"SB1"+cEmpAux+"%"
Local cFromSBM  := "%"+"SBM"+cEmpAux+"%"

fClassi(@aClassi)

aEmpresa:=u_FNSIGAMAT()// Funcao para buscar as empresas


For xE:=1 to Len(aEmpresa)
	
	cEmpAux   := aEmpresa[xE,1]+"0"
	cFromSC1  := "%"+"SC1"+cEmpAux+"%"
	cFromSB1  := "%"+"SB1"+cEmpAux+"%"
	cFromSBM  := "%"+"SBM"+cEmpAux+"%"
	cAliasQry := GetNextAlias()
	
	cQuery := "SELECT C1_ZEMP,"
	cQuery += "       C1_FILIAL,"
	cQuery += "       C1_ZSTATUS,"
	cQuery += "       C1_ZCLASSI,"
	cQuery += "       C1_NUM,"
	cQuery += "       C1_PRODUTO,"
	cQuery += "       B1_DESC,"
	cQuery += "       C1_QUANT - C1_QUJE C1_QUANT,"
	cQuery += "       B1_GRUPO,"
	cQuery += "       BM_DESC,"
	cQuery += "       C1_ZAPLIC,"
	cQuery += "       C1_CC,"
	cQuery += "       C1_ITEM"
	cQuery += "  FROM "+StrTran(cFromSC1,"%","")+" SC1, "+StrTran(cFromSB1,"%","")+" SB1, "+StrTran(cFromSBM,"%","")+" SBM"
	cQuery += " WHERE SC1.C1_ZSTATUS = '1'"
	cQuery += "   AND SC1.C1_APROV   = 'L'"
	cQuery += "   AND SC1.D_E_L_E_T_ <> '*'"
	cQuery += "   AND C1_QUANT <> C1_QUJE"
	cQuery += "   AND SC1.C1_PRODUTO = SB1.B1_COD"
	cQuery += "   AND SB1.D_E_L_E_T_ <> '*'"
	cQuery += "   AND SB1.B1_GRUPO   = SBM.BM_GRUPO"
	cQuery += "   AND SBM.D_E_L_E_T_ <> '*'"
	
	If ! Empty(cFilB1)
		cQuery += "   AND SC1.C1_FILIAL = '" + cFilB1 + "'"
	Endif
	
	If ! Empty(cGrpB1)
		cQuery += "   AND SB1.B1_GRUPO = '" + cGrpB1 + "'"
	Endif
	
	If ValType(nFilCla) == "N"
		if nFilCla <> 0 .And. nFilCla <> Len(aFilCla)
			cQuery += " AND SC1.C1_ZCLASSI = '" + Alltrim(Str(nFilCla)) + "'"
		Endif
	Elseif ValType(nFilCla) == "C"
		If !Empty(nFilCla) .And. Upper(aFilCla[Len(aFilCla)]) <> Upper(Alltrim(nFilCla))
			cQuery += " AND SC1.C1_ZCLASSI = '" + Alltrim(nFilCla) + "'"
		Endif
	Endif
	
	If aScan( aGrpPrd , cGrpPrd ) > 0 .And. aScan( aGrpPrd , cGrpPrd ) < Len(aGrpPrd) // menor que o tamanho total do array, pois a ultima posicao é sempre TODOS.
		cQuery += "   AND SB1.B1_GRUPCOM = '" + Right(cGrpPrd,6) + "'"
	Endif
	
	cQuery += " ORDER BY C1_ZEMP, C1_FILIAL, C1_NUM, B1_GRUPO"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	(cAliasQry)->( DbGoTop() )
	While !(cAliasQry)->(EOF())
		   Aadd(aWBrowAux,{.F.,;          		   // Marca    	1
		   fGetFlag((cAliasQry)->C1_ZSTATUS),;    // Flag     	2
         (cAliasQry)->C1_ZEMP,;  			      // Empresa   	3
		   (cAliasQry)->C1_FILIAL,;  				   // Filial   	4
		   (cAliasQry)->C1_CC,;  			     	   // Filial   	5
		   (cAliasQry)->C1_NUM,;     				   // Numero SC  	6
		   (cAliasQry)->B1_DESC,;  			      // Descrição   	7
		   (cAliasQry)->C1_QUANT,;  			      // Quantidade  	8
		   aClassi[val((cAliasQry)->C1_ZCLASSI)],;// Status     	9
		   (cAliasQry)->B1_GRUPO,; 				   // Grupo    	10
		   (cAliasQry)->BM_DESC,;  				   // Desc Grupo   11 //        	(cAliasQry)->C1_ZAPLIC,;  				// Aplicação    9
		   (cAliasQry)->C1_PRODUTO,;  				// Cod.Produto  12
		   (cAliasQry)->C1_ITEM,;                 //Item SC 13
		   })
		
		   (cAliasQry)->(dbskip())
	EndDo
	
	nContSCs := Len(aWBrowAux)
	
	(cAliasQry)->(dbCloseArea())
	
Next
RestArea(aAliasOLD)
Return(aWBrowAux)






//--------------------------------------------------------------
/*/{Protheus.doc} fSelecao2

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fSelecao2()

Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()
Local aWBrowAux := {}

cQuery := "SELECT DISTINCT C8_FILIAL,"
cQuery += "                C8_NUM,"
cQuery += "                C8_FORNECE,"
cQuery += "                C8_LOJA,"
cQuery += "                A2_NOME,"
cQuery += "                C8_ZSTATUS,"
cQuery += "                C8_NUMSC,"
cQuery += "                C8_ZUSER"
cQuery += "  FROM "+RetSqlName("SC8")+" SC8"
cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2"
cQuery += "    ON SC8.C8_FORNECE = SA2.A2_COD"
cQuery += "   AND SC8.C8_LOJA    = SA2.A2_LOJA"
cQuery += "   AND SA2.D_E_L_E_T_ <> '*'"
cQuery += " WHERE SC8.D_E_L_E_T_ <> '*'"
if ! cCodUser $ cUsuMst
	cQuery += "    AND	SC8.C8_ZUSER    = '" + cCodUser + "'"
endif
If ! Empty(cFilB1)
	cQuery += "    AND	SC8.C8_FILIAL    = '" + cFilB1 + "'"
Endif
cQuery += "   AND SC8.C8_ZSTATUS IN ('3', '4')"
cQuery += " ORDER BY C8_NUM, A2_NOME"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

(cAliasQry)->( DbGoTop() )
While !(cAliasQry)->(EOF())
	    Aadd(aWBrowAux,{fGetFlag((cAliasQry)->C8_ZSTATUS),;  //Flag        1
       (cAliasQry)->C8_NUM,;  			    	   //Numero Solicitacao   2
	    (cAliasQry)->C8_FORNECE,;  				//Codigo do fornecedor 3
	    (cAliasQry)->C8_LOJA,;     				//Loja  			   4
	    (cAliasQry)->A2_NOME,;     				//Nome dor fornecedor  5
	    (cAliasQry)->C8_FILIAL,;       			//Filial  6
	    UsrRetName((cAliasQry)->C8_ZUSER),;    //ID do usuário;
	    (cAliasQry)->C8_NUMSC})       			//Num solic.
	    (cAliasQry)->(dbskip())
EndDo

(cAliasQry)->(dbCloseArea())

RestArea(aAliasOLD)
Return(aWBrowAux)





//--------------------------------------------------------------
/*/{Protheus.doc} fSelecao3

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fSelecao3() //OC -  Aguardando Aprovação

Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()
Local aWBrowAux := {}

cQuery := "SELECT C7_FILIAL,"
cQuery += "       C7_NUM,"
cQuery += "       C7_NUMSC,"
cQuery += "       C7_NUMCOT,"
cQuery += "       A2_NOME,"
cQuery += "       C7_LOJA,"
cQuery += "       C7_PRODUTO,"
cQuery += "       B1_DESC,"
cQuery += "       C7_QUANT,"
cQuery += "       SC7.R_E_C_N_O_ AS RECSC7"
cQuery += "  FROM "+RetSqlName("SC7")+" SC7"
cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2"
cQuery += "    ON SC7.C7_FORNECE = SA2.A2_COD"
cQuery += "   AND SC7.C7_LOJA    = SA2.A2_LOJA"
cQuery += "   AND SA2.D_E_L_E_T_ <> '*'"
cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1"
cQuery += "    ON SC7.C7_PRODUTO = SB1.B1_COD"
cQuery += "   AND SB1.D_E_L_E_T_ <> '*'"
cQuery += " WHERE SC7.C7_CONAPRO = 'B'"
cQuery += "   AND SC7.D_E_L_E_T_ <> '*'"
If ! Empty(cFilB1)
	cQuery += "   AND SC7.C7_FILIAL = '" + cFilB1 + "'"
Endif
if ! cCodUser $ cUsuMst
	cQuery += "   AND	SC7.C7_USER    = '" + cCodUser + "'"
endif
cQuery += " ORDER BY C7_NUM, A2_NOME, C7_PRODUTO"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

(cAliasQry)->( DbGoTop() )
While !(cAliasQry)->(EOF())
	   Aadd(aWBrowAux,{oFlagAZUL,;  			//Flag     	           1
      (cAliasQry)->C7_NUM,;  					//Numero Ordem compra  2
      (cAliasQry)->C7_NUMSC,;  				//Numero Solicitacao   3
      (cAliasQry)->C7_NUMCOT,;  				//Numero Cotacao       4
      (cAliasQry)->A2_NOME,;     			//Nome dor fornecedor  5
      (cAliasQry)->C7_LOJA,;     			//Loja  			   6
      (cAliasQry)->C7_PRODUTO,; 				//Produto    	       7
      Substr((cAliasQry)->B1_DESC,1,30),; 	//Descricao do Produto 8
      Transform( (cAliasQry)->C7_QUANT,"@E 999,999,999.99"),;  //Quantidade 9
      (cAliasQry)->C7_FILIAL,;
      (cAliasQry)->RECSC7 }) 				   //Recno() SC7 11
	
      (cAliasQry)->(dbskip())
EndDo

(cAliasQry)->(dbCloseArea())

RestArea(aAliasOLD)
Return(aWBrowAux)


      


//--------------------------------------------------------------
/*/{Protheus.doc} fSelecao4

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fSelecao4()//OC -  Liberados

Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()
Local aWBrowAux := {}
Local cQuery4   := ""

cQuery4 := "SELECT C7_FILIAL,"
cQuery4 += "       C7_NUM,"
cQuery4 +=  "      CAST(C7_EMISSAO AS SMALLDATETIME) C7_EMISSAO,"+CRLF
cQuery4 += "       C7_NUMSC,"
cQuery4 += "       C7_NUMCOT,"
cQuery4 += "       A2_NOME,"
cQuery4 += "       C7_LOJA,"
cQuery4 += "       C7_PRODUTO,"
cQuery4 += "       B1_DESC,"
cQuery4 += "       C7_QUANT,"
cQuery4 += "       SC7.R_E_C_N_O_ AS RECSC7"
cQuery4 += "  FROM "+RetSqlName("SC7")+" SC7"
cQuery4 += " INNER JOIN "+RetSqlName("SA2")+" SA2 ON SC7.C7_FORNECE = SA2.A2_COD AND SC7.C7_LOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_ <> '*'"
cQuery4 += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SC7.C7_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ <> '*'"
cQuery4 += " WHERE SC7.C7_CONAPRO = 'L'"
cQuery4 += "   AND SC7.C7_QUJE    = 0 "
cQuery4 += "   AND SC7.C7_ENCER   = ' '"
cQuery4 += "   AND SC7.D_E_L_E_T_ <> '*'"
if ! cCodUser $ cUsuMst
	cQuery4 += "   AND SC7.C7_USER = '"+cCodUser+"'"
Endif
cQuery4 += " ORDER BY C7_NUM, A2_NOME, C7_PRODUTO"

cQuery4 := ChangeQuery(cQuery4)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery4),"QTMP04",.T.,.T.)

If Select("DBTMP04") > 0
   DbSelectArea("DBTMP04")
   DbCloseArea()
   FErase(cFileDB04 + GetDBExtension())
Endif

cFileDB04 := U_TRQUERY("QTMP04","DBTMP04")   

DbSelectArea("DBTMP04")
DBTMP04->(DbGotop())
aStr004 := DBTMP04->(DbStruct())
aBrw004 := fAtuaStrDB( aStr004 )

Return




//--------------------------------------------------------------
/*/{Protheus.doc} fSelecao5

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fSelecao5() //OC - Entrega Pendente

Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()
Local aWBrowAux := {}

//	BeginSql Alias cAliasQry

cQuery := "SELECT C7_FILIAL, C7_NUM,C7_NUMSC,C7_NUMCOT,A2_NOME,C7_LOJA,C7_PRODUTO,B1_DESC,C7_QUANT,SC7.R_E_C_N_O_ AS RECSC7"
cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
cQuery += " 		INNER JOIN " + RetSqlName("SA2") + " SA2 ON SC7.C7_FORNECE = SA2.A2_COD AND SC7.C7_LOJA   = SA2.A2_LOJA AND SA2.D_E_L_E_T_ <> '*'"
cQuery += " 		INNER JOIN " + RetSqlName("SB1") + " SB1 ON SC7.C7_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ <> '*'"
cQuery += " 		WHERE SC7.C7_CONAPRO = 'L' "
if !cCodUser $ cUsuMst
	cQuery += "    AND	SC7.C7_USER    = '" + cCodUser + "'"
endif
cQuery += " 		AND SC7.C7_QUJE <> SC7.C7_QUANT "
cQuery += " 		AND SC7.D_E_L_E_T_ <> '*'"
cQuery += "      	ORDER BY C7_NUM"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

//	EndSql
(cAliasQry)->( DbGoTop() )
While !(cAliasQry)->(EOF())
      Aadd(aWBrowAux,{oFlagAMARELO,;  		//Flag  	           1
      (cAliasQry)->C7_NUM,;  					//Numero Ordem compra  2
      (cAliasQry)->C7_NUMSC,;  				//Numero Solicitacao   3
      (cAliasQry)->C7_NUMCOT,;  				//Numero Cotacao       4
      (cAliasQry)->A2_NOME,;     			//Nome dor fornecedor  5
      (cAliasQry)->C7_LOJA,;     			//Loja  			   6
      (cAliasQry)->C7_PRODUTO,; 				//Produto    	       7
      (cAliasQry)->B1_DESC,; 					//Descricao do Produto 8
      Transform( (cAliasQry)->C7_QUANT,"@E 999,999,999.99"),;  //Quantidade 9
      (cAliasQry)->C7_FILIAL,;  					//Recno() SC7 10
      (cAliasQry)->RECSC7})
	
      (cAliasQry)->(dbskip())
EndDo

(cAliasQry)->(dbCloseArea())

RestArea(aAliasOLD)
Return(aWBrowAux)





//--------------------------------------------------------------
/*/{Protheus.doc} fGetFlag

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fGetFlag(pStatus)
Local lRet    := ""
Do Case
	Case pStatus == '4'  // SC Liberada para contaçao
		Return oFlagVermelho
	Case pStatus == '1'  // SC Aguardando liberaçao
		Return oFlagVERDE
	Case pStatus == '2'  // SC Em processo de contacao
		Return oFlagPRETO
	Case pStatus == '3'  // SC Bloqueada por ocorrencia
		Return oFlagAMARELO
	Case pStatus == '5'  // SC Ordem de compra gerada
		Return oFlagLARANJA
	Case pStatus == '6'  // SC Pedido liberado
		Return oFlagCINZA
	Case pStatus == '7'  // SC Pedido liberado ao fornecedor
		Return oFlagPINK
	Case pStatus == '8'  // SC Aguardando entrega do fornecedor/ Filial
		Return oFlagBRANCO
	Case pStatus == '9'  // SC Aguardando entrega logistica
		Return oFlagMARROM
	Case pStatus == 'A'  // SC Entregue
		Return oFlagAZUL
EndCase

Return(lRet)





//--------------------------------------------------------------
/*/{Protheus.doc} fBrowseG

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function  fWBrowseG(oBrow1) // SAIR
Local x1:=0
Local oWBrowGru
Local aWBrowGru := {}
Local aAuxGru   := {}
Local lFlag     :=.F.

For x1:=1 to Len(oBrow1)
	If oBrow1[x1,1]
		cKey :=oBrow1[x1,11]+oBrow1[x1,6]
		lFlag:=.T.
		nPos := Ascan(aAuxGru, {|e| e[1]+e[2]  == cKey})
		If Empty(nPos)
			//  Grupo        Produto     quantidade
			Aadd(aAuxGru,{oBrow1[x1,11],oBrow1[x1,6],oBrow1[x1,13] })
		Else
			aAuxGru[nPos,3]+=oBrow1[x1,13]
		Endif
	Endif
Next

aSort(aAuxGru,,,{|x,y| x[1] < y[1]})

If lFlag

	For x1:=1 to Len(aAuxGru)
		Aadd(aWBrowGru,{aAuxGru[x1,1],;  // Grupo  1
		aAuxGru[x1,2],;  //Produto 2
		Posicione("SB1",1,xFilial("SB1")+aAuxGru[x1,2],"B1_DESC"),;  // Descricao do produto 3
		Transform(aAuxGru[x1,3],"@E 9,999,999,999.99") })            // Quantidade acumulada 4
	Next
	
	@ 036, 007 LISTBOX oWBrowGru Fields HEADER "Grupo","Produto","Descrição","Quantiade" SIZE 235, 141 OF oDlg1 PIXEL ColSizes 50,50
	// Insert items here
	oWBrowGru:SetArray(aWBrowGru)
	oWBrowGru:bLine := {|| {;
	aWBrowGru[oWBrowGru:nAt,1],;
	aWBrowGru[oWBrowGru:nAt,2],;
	aWBrowGru[oWBrowGru:nAt,3],;
	aWBrowGru[oWBrowGru:nAt,4]}}
	// DoubleClick event
	oWBrowGru:bLDblClick := {|| aWBrowGru[oWBrowGru:nAt,1] := !aWBrowGru[oWBrowGru:nAt,1],;
	oWBrowGru:DrawSelect()}
Else
	MsgAlert("Não existe registros marcados!!!","Atenção")
Endif
Return




//--------------------------------------------------------------
/*/{Protheus.doc} fPesquisa

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fPesquisa(pComboBo,pCod)

If pComboBo="Numero da Solicitação"
	nPos := Ascan(aWBrowse2, {|e| e[9]  == pCod})  //"Numero da Solicitação"
Else
	nPos := Ascan(aWBrowse2, {|e| e[2]  == pCod}) //"Numero da Cotacao"
Endif

If Empty(nPos)
	Aviso('Atenção', 'Não encontrou registros com este codigo', {'Ok'})
Else
	oWBrowse2:nAT := nPos
Endif

Return()




//------------------------------------------------
//* Funcao para buscar a empresa no banco
// SIGAMAT
//------------------------------------------------
User Function FNSIGAMAT()
Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()
Local aEmpresa  :={}
Local lEmpAll   := .F. // Carrega todas as empresas ???? = .T. = Sim, .F. = Não.

BeginSql Alias cAliasQry
	SELECT DISTINCT  M0_CODIGO
	FROM SIGAMAT
	WHERE %notDel%
EndSql

(cAliasQry)->( DbGoTop() )
While !(cAliasQry)->(EOF())
	If SM0->M0_CODIGO == (cAliasQry)->M0_CODIGO .Or. lEmpAll
		aAdd( aEmpresa, {(cAliasQry)->M0_CODIGO} )
	Endif
	(cAliasQry)->( dbSkip() )
End
(cAliasQry)->(dbCloseArea())

RestArea(aAliasOLD)
Return(aEmpresa)




//--------------------------------------------------------------
/*/{Protheus.doc} fFilBrw01

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fFilBrw01

Local aClassi := {}
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")

aWBrowse1 := {}
aEmpresa  := u_FNSIGAMAT()// Funcao para buscar as empresas
fClassi(@aClassi)

For xE :=1 to Len(aEmpresa)
	
	cEmpAux   := aEmpresa[xE,1]+"0"
	cFromSC1  := "SC1"+cEmpAux
	cFromSB1  := "SB1"+cEmpAux
	cFromSBM  := "SBM"+cEmpAux
	cAliasQry := GetNextAlias()

	cQuery := "SELECT DISTINCT C1_ZEMP,C1_FILIAL,C1_ZSTATUS,C1_ZCLASSI, C1_NUM,B1_GRUPO,BM_DESC,C1_ZAPLIC,C1_ITEM,C1_PRODUTO,C1_CC,B1_DESC,C1_QUANT"
	cQuery += " FROM " + cFromSC1 + " SC1 INNER JOIN " + cFromSB1 + " SB1 ON SC1.C1_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ <> '*' AND SC1.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN " + cFromSBM + " SBM ON SB1.B1_GRUPO   = SBM.BM_GRUPO AND SBM.D_E_L_E_T_ <> '*'"
	cQuery += " WHERE SC1.C1_ZSTATUS = '1' AND SC1.C1_APROV = 'L' AND C1_QUANT <> C1_QUJE "

	if !Empty(cFilB1)
    	cQuery += " AND SC1.C1_FILIAL = '" + cFilB1 + "'"
	endif
	if !Empty(cGrpB1)
	   cQuery += " AND SB1.B1_GRUPO = '" + cGrpB1 + "'"
	endif
	If aScan( aGrpPrd , cGrpPrd )  > 0 .And. aScan( aGrpPrd , cGrpPrd )  < Len(aGrpPrd) // menor que o tamanho total do array, pois a ultima posicao é sempre TODOS.
	   cQuery += "   AND SB1.B1_GRUPCOM = '" + Right(cGrpPrd,6) + "'"
	Endif
	if ValType(nFilCla) == "N"
	   if nFilCla <> 0 .And. nFilCla <> Len(aFilCla)
	      cQuery += " AND SC1.C1_ZCLASSI = '" + Alltrim(Str(nFilCla)) + "'"
	   endif
	elseif ValType(nFilCla) == "C"
	   if !Empty(nFilCla) .And. Upper(aFilCla[Len(aFilCla)]) <> Upper(Alltrim(nFilCla))
       	cQuery += " AND SC1.C1_ZCLASSI = '" + Alltrim(nFilCla) + "'"
    	endif
	endif
	
	cQuery += " ORDER BY C1_ZEMP, C1_FILIAL, C1_NUM, B1_GRUPO"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	dbSelectArea(cAliasQry)
	dbgoTop()
	While !Eof(cAliasQry)
	      Aadd(aWBrowse1,{.F.,;          		// Marca    	1
      	fGetFlag((cAliasQry)->C1_ZSTATUS),; // Flag     	2
      	(cAliasQry)->C1_ZEMP,;  			   // Empresa   	3
      	(cAliasQry)->C1_FILIAL,;  				// Filial   	4
      	(cAliasQry)->C1_CC,;  			     	// Filial   	5
      	(cAliasQry)->C1_NUM,;     				// Numero SC  	6
      	(cAliasQry)->B1_DESC,;  			   // Descrição   	7
      	(cAliasQry)->C1_QUANT,;  			   // Quantidade  	8
      	aClassi[val((cAliasQry)->C1_ZCLASSI)],; // Status     	9
      	(cAliasQry)->B1_GRUPO,; 				// Grupo    	10
      	(cAliasQry)->BM_DESC,;  				// Desc Grupo   11 //        	(cAliasQry)->C1_ZAPLIC,;  				// Aplicação    9
      	(cAliasQry)->C1_PRODUTO,;  			// Cod.Produto  12
      	(cAliasQry)->C1_ITEM,;              //Item SC 13
      	})
      	(cAliasQry)->(dbskip())
	EndDo
		
	nContSCs := Len(aWBrowse1)
	(cAliasQry)->(dbCloseArea())
	oWBrowse1:SetArray(aWBrowse1)
	
	oWBrowse1:bLine := {|| {;
	If(aWBrowse1[oWBrowse1:nAT,1],oOk,oNo),;
      	aWBrowse1[oWBrowse1:nAt,02],;
      	aWBrowse1[oWBrowse1:nAt,03],;
      	aWBrowse1[oWBrowse1:nAt,04],;
      	aWBrowse1[oWBrowse1:nAt,05],;
      	aWBrowse1[oWBrowse1:nAt,06],;
      	aWBrowse1[oWBrowse1:nAt,07],;
      	aWBrowse1[oWBrowse1:nAt,08],;
      	aWBrowse1[oWBrowse1:nAt,09],;
      	aWBrowse1[oWBrowse1:nAt,10],;
      	aWBrowse1[oWBrowse1:nAt,11],;
      	aWBrowse1[oWBrowse1:nAt,12],;
      	aWBrowse1[oWBrowse1:nAt,13] }} 
      	
      	oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],;
      	oWBrowse1:DrawSelect()}
      	oWBrowse1:Refresh()

Next

return .T.




//--------------------------------------------------------------
/*/{Protheus.doc} fMarcaT

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fMarcaT
For nXXCont := 1 To Len(aWBrowse1)
	aWBrowse1[nXXCont,1] := .T.
Next

return




//--------------------------------------------------------------
/*/{Protheus.doc} fClassi

@param  Parameter Description
@return Return Description
@author Jose Antonio (AMM)
@since  17/12/2012
/*/
//--------------------------------------------------------------
Static Function fClassi(aClassi)
Local cClassi := ""
dbSelectArea("SX3")
SX3->(dbSetOrder(02))
If SX3->(dbSeek("C1_ZCLASSI"))
	cClassi := Alltrim(SX3->X3_CBOX)
Endif
XX:=0
Do While !Empty(cClassi)
	aAdd(aClassi,SubStr(cClassi,03,IIf(!Empty(AT(";",cClassi)),AT(";",cClassi)-3,Len(cClassi) )) )
	cClassi := SubStr(cClassi,Len(aClassi[Len(aClassi)])+04,Len(cClassi))
Enddo

Return




//-------------------------------------------------------------------
/*/{Protheus.doc} FMsgAviso
Mensagem ao usuário

@protected
@author    Rodrigo Carvalho
@since     28/04/2015
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FMsgAviso()
If lChkOld <> lChkNew
	If lChkNew
		Aviso("Atenção", "Painel de Gestão ON-Line", {"Ok"})
	Else
		Aviso("Atenção", "Painel de Gestão OFF-Line"+Chr(13)+Chr(10)+"Sem atualização", {"Ok"})
	Endif
	lChkOld := lChkNew
Endif
Return .T.





//-------------------------------------------------------------------
/*/{Protheus.doc} fConsulta
Consulta historico do produto.

@protected
@author    Rodrigo Carvalho
@since     19/08/2015
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function fConsulta(cFilialCon,cPrdConsulta)

Local   aArea     := GetArea()
Local   cFilOld   := ""

Private cCadastro := "Historico do Produto"
Private aRotina   := {{"P&esquisar" ,'AxPesqui'  ,0,1},;
{"V&isualizar",'MC050Con()',0,2}}

Private nOpcA     := 0

Default cPrdConsulta := ""
Default cFilialCon   := ""

If Empty(cPrdConsulta)
	Do Case
		Case oFolder1:nOption == 1
			cPrdConsulta := aWBrowse1[oWBrowse1:nAt,12]
			cFilialCon   := aWBrowse1[oWBrowse1:nAt,4]
			
		Case oFolder1:nOption == 2
			If Type("oMSNewGeP05") == "O"
				cPrdConsulta := oMSNewGeP05:aCols[oMSNewGeP05:nAt][14]
				cFilialCon   := aWBrowse2[oWBrowse2:nAt,6]
			Endif
			
		Case oFolder1:nOption == 3
			cPrdConsulta := aWBrowse3[oWBrowse3:nAt,7 ]
			cFilialCon   := aWBrowse3[oWBrowse3:nAt,10]
			
		Case oFolder1:nOption == 4
			cPrdConsulta := aWBrowse4[oWBrowse4:nAt,8 ]
			cFilialCon   := aWBrowse4[oWBrowse4:nAt,11]
			
	EndCase
Endif

If ! Empty(cPrdConsulta)
	
	Set Key VK_F12	To
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1") + cPrdConsulta)
		
		cFilOld := cFilAnt
		cFilAnt := cFilialCon
		
		MsgRun("Carregando informações...",,{|| CursorWait() , MaComView(SB1->B1_COD) ,CursorArrow()})  // aba 01 MC050Con()
		
		cFilAnt := cFilOld
		Set Key VK_F11	To
		
	Endif
	RestArea(aArea)
	SetKey( VK_F12, { || fConsulta() })
	
Endif

Return .t.




//-------------------------------------------------------------------
/*/{Protheus.doc} MCGRPCOM()

@protected
@author    Rodrigo Carvalho
@since     10/11/2015
@obs       Carrega o grupo de compras

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function MCGRPCOM()

Local aGrpPrd1  := {}
Local cDescTbV0 := ""

DbSelectArea("SAJ")
DbGotop()
DbSetOrder(1)

Do While ! Eof()
	cDescTbV0 := ""
	
	If SAJ->(FieldPos("AJ_TIPOGRP")) > 0
		cDescTbV0 := Capital(GetAdvFVal( "SX5" , "X5_DESCRI" , XFILIAL("SX5") + "V0" + Alltrim(SAJ->AJ_TIPOGRP) , 1))
		If Empty(cDescTbV0)
			cDescTbV0 := Alltrim(SAJ->AJ_TIPOGRP)
		Endif
	Endif
	
	aAdd(aGrpPrd1,OemToAnsi(cDescTbV0+" - "+Capital(SAJ->(AJ_US2NAME+Replicate(" ",40)+AJ_GRCOM))))
	
	If SAJ->AJ_USER $ cCodUser
		cGrpPrd := aGrpPrd1[Len(aGrpPrd1)]
	Endif
	
	SAJ->(DbSkip())
Enddo

aAdd(aGrpPrd1,"999999-Todos os Grupos")

If Empty(cGrpPrd)
	cGrpPrd := aGrpPrd1[Len(aGrpPrd1)]
Endif

Return(aGrpPrd1)




//-------------------------------------------------------------------
/*/{Protheus.doc} MCATUFLD()

@protected
@author    Rodrigo Carvalho
@since     10/11/2015
@obs       Atualiza folders

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function MCATUFLD(pop)

Do Case
	Case pop = 1
		 fWBrowse1()  	//SC - Pendentes      
	Case pop = 2
		 fWBrowse2() 	//SC - Em Cotação
	Case pop = 3
		 fWBrowse3() 	//OC - Aguardando Aprovação
	Case pop = 4
		 fWBrowse4() 	//OC - Liberados
	Case pop = 5
		 fWBrowse5() 	//OC - Entrega Pendente"
   Otherwise
	   Aviso('Atenção', 'Folder não tratado!', {'Ok'})
EndCase      
Return .T.





//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaStrDB()

@protected
@author    Rodrigo Carvalho
@since     08/03/2015
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FAtuaStrDB( aStrTMP )

Local aBrwTMP := {}
Local cTitCmp := ""

For nXy := 1 To Len(aStrTMP)

    If aStrTMP[nXy][2] == "N" 
       aStrTMP[nXy][4] := 2 // duas casas decimais
    Endif

    dbSelectArea("SX3")
    dbSetOrder(2)
    If dbSeek(aStrTMP[nXy,1])
       aAdd(aBrwTmp,{ Capital(Alltrim(aStrTMP[nXy,1])) , Capital(Alltrim(X3Titulo())) , Capital(Alltrim(X3Titulo())),IIf(aStrTMP[nXy,2] == "N",cPict,"")})   
       aStrTMP[nXy][2] := SX3->X3_TIPO 
    Else                                                       
        cTitCmp := Capital(Alltrim(aStrTMP[nXy,1]))
       aAdd(aBrwTmp,{Capital(Alltrim(aStrTMP[nXy,1])) , cTitCmp , cTitCmp ,IIf(aStrTMP[nXy,2] == "N",cPict,"")})                    
    Endif
    
    IF Left(aStrTMP[nXy,1],4) $ "AAMM"  
       aBrwTmp[Len(aBrwTmp)][2] := MesExtenso(Val(SubStr(aBrwTmp[Len(aBrwTmp)][2],9,2))) +" "+ SubStr(aBrwTmp[Len(aBrwTmp)][2],5,4)
       aBrwTmp[Len(aBrwTmp)][3] := aBrwTmp[Len(aBrwTmp)][2]
    Endif
    
Next    

Return(aBrwTmp)
