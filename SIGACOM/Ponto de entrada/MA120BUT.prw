#INCLUDE "RWMAKE.CH"
#include "PROTHEUS.CH"  
#include "TBICONN.CH"
#include "TBICODE.CH"      
#INCLUDE "TOPCONN.CH" 

#DEFINE VALMERC  	 1  // Valor total do mercadoria
#DEFINE VALDESC 	 2  // Valor total do desconto
#DEFINE FRETE   	 3  // Valor total do Frete
#DEFINE VALDESP 	 4  // Valor total da despesa
#DEFINE TOTF1		 5  // Total de Despesas Folder 1
#DEFINE TOTPED		 6  // Total do Pedido
#DEFINE SEGURO		 7  // Valor total do seguro
#DEFINE TOTF3		 8  // Total utilizado no Folder 3
#DEFINE IMPOSTOS     9  // Array contendo Os Valores de Impostos Exibidos no ListBox

#DEFINE MAXGETDAD 999


/*------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                          -                                                    
--------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 27/11/2018  - 
--------------------------------------------------------------------------------------
                                   PROGRAMA: MA120BUT                                -
--------------------------------------------------------------------------------------
                    PONTO DE ENTRADA PARA ADICIONAR BOTÃO NO PC                      -
-------------------------------------------------------------------------------------*/                 

******************************
User Function MA120BUT()      
******************************

Local aButtons := {} // Botoes a adicionar

aadd(aButtons,{'APROVAR',{|| MA120A('S')},'Aprovacao','APROVAR'})
aadd(aButtons,{'PRÓXIMO',{|| MA120A('N')},'Proximo'  ,'PRÓXIMO'}) 

Return (aButtons ) 

/*------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                          -                                                    
--------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 27/11/2018  - 
--------------------------------------------------------------------------------------
                                   PROGRAMA: MA120A                                  -
--------------------------------------------------------------------------------------
                     FUNÇÃO PARA LOCALIZAR PEDIDOS PARA APROVAÇÃO                    -
-------------------------------------------------------------------------------------*/

*******************************
Static Function MA120A(cAprov)      
******************************* 

Local cQuery        := ''
Local cPedido       := SC7->C7_NUM
Local cFilial       := SC7->C7_FILIAL
Local nRecno, cPed
Local k             := 0                                                    


/*If (cAprov == 'S')                                                                 	                                                    
	If (SC7->C7_TIPO == 1 .AND. (Posicione("SAL", 4, Substr(xFilial("SCR"),1,4)+space(2) + '000005'+ __cUserID, "SAL->AL_NIVEL") == '01'))   // USUARIO NIVEL 2
		Do While SC7->(!Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == cFilial+cPedido
		 If Reclock("SC7",.F.)
		  Replace	SC7->C7_CONAPRO With "L"
		 SC7->(MsUnlock())                                                        
		 Endif                                                                    
		 SC7->(dbSkip())
		EndDo
	Endif 

  DbGoto(nRecno)
 dbSelectArea("SCR")
  dbSetOrder(1)
   if dbSeek(SC7->C7_FILIAL+"PC"+SC7->C7_NUM+Space(44))
    While !Eof("SCR") .And. SCR->CR_FILIAL == SC7->C7_FILIAL .And. Alltrim(SCR->CR_TIPO) == "PC" .And. Alltrim(SC7->C7_NUM) == Alltrim(SCR->CR_NUM)
 	 if RecLock("SCR",.F.) 
 	  	if (Posicione("SAL", 4, Substr(xFilial("SCR"),1,4)+Space(2) + '000005'+ __cUserID, "SAL->AL_NIVEL") == '01')   // USUARIO NIVEL 2   
 	      Replace SCR->CR_STATUS   With Iif((__cUserID == SCR->CR_USER),"03","05")
	      Replace SCR->CR_DATALIB  With date()
	      Replace SCR->CR_USERLIB  With Iif((__cUserID == SCR->CR_USER),SCR->CR_USER," ")
	      Replace SCR->CR_LIBAPRO  With Iif((__cUserID == SCR->CR_USER),SCR->CR_APROV," ")
	      Replace SCR->CR_VALLIB   With SCR->CR_TOTAL
	      Replace SCR->CR_TIPOLIM  With 'D' 				
	  endif	
		MsUnLock()
     endif      
	 dbSelectArea("SCR")
	 dbSkip()
	enddo
   Endif	 
Endif    */
If Select("TMP") > 0 
     dbSelectArea("TMP") 
     dbCloseArea() 
EndIf  

cQuery += Chr(13)+" SELECT DISTINCT CR_FILIAL AS FILIAL, CR_NUM AS PEDIDO FROM "+RetSqlName("SCR")+" SCR "	
cQuery += Chr(13)+" INNER JOIN " + RetSqlName("SC7") + " SC7 ON C7_FILIAL = CR_FILIAL AND C7_NUM = CR_NUM AND SC7.D_E_L_E_T_ = '' "                                      
cQuery += Chr(13)+" WHERE SCR.D_E_L_E_T_ <> '*' "
cQuery += Chr(13)+" AND CR_USER = '"+__CUSERID+"' "
cQuery += Chr(13)+" AND CR_STATUS IN ('02') "
cQuery += Chr(13)+" AND C7_CONAPRO = 'B' "
cQuery += Chr(13)+" AND C7_ENCER <> 'E' "
If (cAprov == 'N')  .OR. Len(aProxPed) > 0
AAdd(aProxPed,"'"+SC7->C7_NUM+"'")
	For k:=1 To Len(aProxPed)
		cProxPed := IIF(!Empty(cProxPed), cProxPed +','+ aProxPed[k] , aProxPed[k])	
	Next
cQuery += Chr(13)+" AND C7_NUM NOT IN "+'('+cProxPed+')'+" "           
Endif	
cQuery += Chr(13)+" ORDER BY 1,2 "

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.F.,.T.)

TMP->(dbGoTop())
IF TMP->(!EOF())
    
    cEmpAnt := SM0->M0_CODIGO //Seto as variaveis de ambiente
	cFilAnt := TMP->FILIAL
	cPed    := TMP->PEDIDO
	    
	    dbCloseAll() //Fecho todos os arquivos abertos
		OpenSM0() //Abrir Tabela SM0 (Empresa/Filial)
		dbSelectArea("SM0") //Abro a SM0
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(cEmpAnt + cFilAnt,.T.)) //Posiciona Empresa
		OpenFile(cEmpAnt + cFilAnt) //Abro a empresa que eu desejo trabalhar
			
			dbSelectArea("SC7")     // PROXIMO PEDIDO DE COMPRAS                                                                   
		    SC7->(dbSetOrder(1))                 
		    If SC7->(DbSeek(cFilAnt+Alltrim(cPed)))
		  	oNewDialog:end()                                                                                
		  	U_A121Pedido('SC7',SC7->(Recno()),2)	                                                                           
		    Endif
Else
	MsgAlert("APROVAÇÃO FINALIZADA.")
	MsgAlert(OemTOAnsi('Não existem dados a serem exibidos!!')) 
	lFinal := .T.
    oNewDialog:end()
    U_PILibDoc('MT120FIM')
Endif	                                                                                           
return

User Function A121Pedido(cAlias,nReg,nOpcX,xFiller,lCopia,lWhenGet,aRecnoSE2RA)

Local aAreaSM0   := SM0->(GetArea())
Local aArea      := GetArea()
Local aRefImpos  := MaFisRelImp('MT100',{"SC7"})
Local aCpoValid  := {"C7_NUMSC","C7_ITEMSC","C7_DATPRF","C7_NUMCOT","C7_APROV","C7_QTDSOL","C7_RESIDUO"}
Local aCombo	 := CarregaTipoFrete()
Local aButtons   := {}
Local aObj	      // Array com os objetos utilizados no Folder
Local aObj2[2]	 // Array 2 com objetos utilizados no Folder
Local aSizeAut   := MsAdvSize(,.F.,400)
Local aUsButtons := {}
Local aObjects	 := {}
Local aInfo 	 := {}
Local aPosGet	 := {}
Local aPosObj	 := {}
Local aPosObjPE  := {}
Local aStruSC7   := {}
Local aCt5       := {}
Local aNoFields  := {"C7_FABRICA","C7_LOJFABR","C7_DT_EMB","C7_TEC","C7_EX_NCM","C7_EX_NBM","C7_DIACTB"}
Local aL120PvTran   := {}
Local aL120PedAglut :={}
Local aCPed  	 :={}
Local aCPed1     :={}

Local bCtbOnLine := {|| .T.}
Local bWhenCond  := {|| .T.}
Local bWhenMoed  := {|| .T.}

Local aColsSCH     := {}
Local aHeadSCH     := {}

Local cItCop     := StrZero(0,Len(SC7->C7_ITEM))
Local cQuery     := ""
Local cPedido    := ""
Local cArqCtb    := ""
Local cLoteCtb   := ""
Local c652       := ""
Local c657       := ""  
Local cWhenCond  := ""
Local cWhenMoed  := ""
Local cWhenLiq   := ""
Local cSeek      := ""
Local cWhile     := ""

Local nOpcA		 := 0
Local nX         := 0
Local nY         := 0
Local nJ		 := 0
Local nHdlPrv    := 0
Local nTotalCtb  := 0
Local nTpRodape  := 0
Local nSaveSX8 	 := If(Type('nSaveSx8')=='U', GetSX8Len(), nSaveSX8)    

Local lQuery     := .F.
Local l120Visual := .F.
Local l120Inclui := .F.
Local l120Deleta := .F.
Local l120Altera := .F.
Local lContinua	 := .T.
Local lGravaOk 	 := .T.
Local lCtbOnLine := .F.
Local lDigita    := .F.
Local lAglutina  := .F.
Local lWhenCond  := .T.
Local lWhenMoed  := .T.
Local lMt120Alt  := .T.
Local lMt120Ped  := .F.
Local lMta120E   := .T.
Local lMt120GRV  := .T.
Local lMt120Scr  := ExistBlock("MT120SCR")
Local lMt120TEL  := ExistBlock("MT120TEL")
Local lMt120Get  := ExistBlock("MT120GET")
Local lPcFilEnt	 := SuperGetMv("MV_PCFILEN")
Local lGrade	 := MaGrade()
Local aCpsGrade  := {{"C7_QUANT",.T.,{{"C7_QTSEGUM",{||ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),aCols[nLinha][nColuna],0,2)}}}},;
					{"C7_ITEM"   ,NIL,NIL},;
					{"C7_DATPRF" ,NIL,NIL},;
					{"C7_TOTAL"  ,NIL,NIL},;
					{"C7_QTDSOL" ,.T.,{||A120Quant(aCols[nLinha][nColuna])}},;
					{"C7_QTSEGUM",NIL,{{"C7_QUANT",{||ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),0,aCols[nLinha][nColuna],1)}}}},;
					{"C7_VLDESC" ,NIL,NIL},;
					{"C7_QUJE" ,NIL,NIL}}    					
Local oDlg
Local oGetDados
Local oca120Forn
Local oca120Loj
Local oCond
Local oDescCond
Local oDescMoed
Local oGetMoeda
Local aCtbDia	 	:= {} 
Local cItemSCH 		:= "" 
Local nItemSCH 		:= 0 
Local nOpcAdt  		:= If( Type( "nAutoAdt" ) == "N",nAutoAdt,0)
Local aAreaAdt		:= {}
Local aColsBKPRat	:= {}                                                                                                                

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ "Contabilizacao na Exclusao do PC, mesmo SE o parametro: Contabiliza On-Line=="NAO"  ³
//³                                              .T.-Contabiliza / .F.-Nao Contabiliza"  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                  
Local lMV_COEXCPC:= SuperGetMv("MV_COEXCPC") 

DEFAULT lCopia   := .F.
DEFAULT l120Auto := .F.

PRIVATE aRatAJ7     := {}
PRIVATE aA120PID    := {}
PRIVATE aColsBkp    := {}
PRIVATE aInfForn	:= {"","",CTOD(""),CTOD(""),"","",""}
PRIVATE aValores	:= {0,0,0,0,0,0,0,0,{{'','',0,0,0}},0,0}
PRIVATE aTitles     := {"Totais",; //"Totais"
						"Inf. Fornecedor",; //"Inf. Fornecedor"
					 	"Frete/Despesas",; //"Frete/Despesas"
					 	"Descontos",; //"Descontos"
					 	"Impostos",; //"Impostos"
					 	"Mensagem/Reajuste" } //"Mensagem/Reajuste"
PRIVATE bPMSDlgPC	:= {||PmsDlgPC(nOpcx,ca120Num)}
PRIVATE cDescMsg	:= ""
PRIVATE cDescFor	:= ""
PRIVATE oFolder
PRIVATE aBackSCH    := {}


PRIVATE cCondPAdt   := "0" //Controle p/ cond. pgto. com aceite de Adt. 0=normal 1=Adt
PRIVATE cCondPOld   := If(nOpcX==4,SC7->C7_COND,"")    
If ( Type("nFAltRat") == "U" )
	PRIVATE nFAltRat   := 0	
EndIf

Default aRecnoSE2RA := {} // Array com os titulos selecionados pelo Adiantamento

If cPaisLoc == "PTG"
   aObj:= Array(28)
Else               
   aObj:= Array(24)
EndIf

If cPaisLoc == "BRA"
	aAdd(aCpsGrade,{"C7_ICMCOMP",NIL,NIL})
	aAdd(aCpsGrade,{"C7_ICMSRET",NIL,NIL})
	aAdd(aCpsGrade,{"C7_VALIPI" ,NIL,NIL})
	aAdd(aCpsGrade,{"C7_VALICM" ,NIL,NIL})
	aAdd(aCpsGrade,{"C7_BASEICM",NIL,NIL})
	aAdd(aCpsGrade,{"C7_BASEIPI",NIL,NIL})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto para validar se continua ou nao a Rotina.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT120ALT")
	lMt120Alt := Execblock("MT120ALT",.F.,.F.,{aRotina[nOpcX,4]})
	If ValType( lMt120Alt ) == "L" .And. !lMt120Alt
		lContinua := .F.
	EndIf
EndIf     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pedidos de Compras gerados pelos Modulos de Transporte SIGATMS ou Gestao de ³
//³ Contratos SIGAGCT nao poderao ser alterados ou excluidos por essa Rotina.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nOpcx == 4 .Or. nOpcx == 5 ) .And. lContinua
	If !l120Auto .And. nTipoPed == 1 .And. Alltrim(SC7->C7_ORIGEM) == "SIGATMS"	
		MsgAlert( "TMS", "TMS" )
		lContinua := .F.
	EndIf	

	If ( FunName() != "CNTA120" .And. FunName() != "CNTA150" ) .And. lContinua
		If !Empty(SC7->C7_CONTRA)
			If nOpcX == 5
		    	lContinua:= .F.
			Aviso("SIGAGCT","",{"Ok"}) 
			EndIf
	    	If lContinua                                  
	  			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Obtém os campos que poderão ser alterados  ³
				//|através do PE: MT120PED                    |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               	aCPed:={}   
               	aCPed1:={}
                If ExistBlock("MT120PED")
                   	If ValType(ExecBlock("MT120PED",.F.,.F.,{})) == 'A'
                   		aCPed:=ExecBlock("MT120PED",.F.,.F.,{})
                    		
                    	//Somente campos de usuário poderão ser alterados //
                    	dbSelectArea("SX3")
						dbSetOrder(2)
						For nX:=1 To Len(aCPed)
						    MsSeek(aCPed[nX])
						    If !EOF() .And. X3_PROPRI == "U"
						      	AADD(aCPed1,aCPed[nX])
						    EndIf
						Next nX
						//Não encontrou nenhum campo de usuário, invalida a utilização do PE
						If Len(aCPed1) == 0
							lMt120Ped:= .F.
							lContinua:= lMt120Ped  
 							Aviso("SIGACOM"," ",{"Ok"})
						Else
							lMt120Ped:= .T.
						EndIf
                   	Else
                    	lMt120Ped:= .F.
                    Endif
      			Else
    		    	lContinua:= .F.
					Aviso("SIGAGCT","",{"Ok"}) 
	   			EndIf
	   		EndIf
		EndIf
	EndIF    
	
	If nOpcx == 5 
		If SC7->(FieldPos("C7_CODED")) > 0 .And. SC7->(FieldPos("C7_NUMPR")) > 0
			If !Empty(SC7->C7_CODED) .Or. !Empty(SC7->C7_NUMPR) 
				Help(" ",1,"A120EDITAL")
				lContinua := .F.
			EndIf
		EndIf 
	EndIf	
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica se o Pedido é Aglutinado por Central de Compras para Entrega na Filial Centralizadora |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nOpcx == 6 .And. lContinua
	If AliasInDic("SDP") 
		dbSelectArea("SDP")
		dbSetOrder(4)
		If MsSeek(xFilial("SDP")+SC7->C7_FILENT+SC7->C7_NUM+SC7->C7_ITEM)
			Help(" ",1,"A120NPCEN")
			lContinua := .F.
		EndIf
	EndIf
EndIf

// Valida o array Rateio por CCusto - rotina automatica
If (Type('l120Auto') <> 'U' .And. l120Auto)
	lContinua := a120RatAut(aRatCTBPC)
Endif


If lContinua

	Pergunte("MTA120",.F.)

	lWhenGet := IIf(ValType(lWhenGet) <> "L" , .F. , lWhenGet)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
	Case aRotina[nOpcX][4] == 2
		l120Visual := .T.
	Case aRotina[nOpcX][4] == 3 .Or. lCopia
		l120Inclui	:= .T.
	Case aRotina[nOpcX][4] == 4
		l120Altera	:= .T.
	Case aRotina[nOpcX][4] == 5
		l120Deleta	:= .T.
		l120Visual	:= .T.
	EndCase

	If l120Inclui .Or. l120Altera .Or. l120Deleta
		lCtbOnLine := (MV_PAR05==1 .And. (VerPadrao("652") .Or. VerPadrao("657")))
		lAglutina  := MV_PAR06==1
		lDigita    := MV_PAR07==1
		nTpRodape  := MV_PAR04
	Else
		lCtbOnLine := .F.
		lAglutina  := .F.
		lDigita    := .F.
		nTpRodape  := 1
	EndIf
	
    If lMV_COEXCPC .And. l120Deleta
		lCtbOnLine := .T.
    Endif
    
	PRIVATE bFolderRefresh:= {|| ((A120REFRESH(@AVALORES)),IF(L120AUTO, .T. ,(A120FREFRESH(AOBJ))))}
	PRIVATE bGDRefresh    := {|| If(l120Auto,.T.,(oGetDados:oBrowse:Refresh())) }
	PRIVATE bZeraDesc     := {|| (nDesc1:=0),(nDesc2:=0),(nDesc3:=0)}
	PRIVATE bRefresh      := {|| (A120VDesc(nDesc1,nDesc2,nDesc3,@aValores)),(Eval(bFolderRefresh))}
	PRIVATE bListRefresh  := {|| (MaFisToCols(aHeader,aCols,,"MT120")),(Eval(bRefresh),Eval(bGDRefresh)) }
	PRIVATE cA120Num   	  := '' //-- O Tratamento desta variavel serah feito logo abaixo...
	PRIVATE dA120Emis     := If(l120Inclui,CriaVar("C7_EMISSAO"),SC7->C7_EMISSAO)
	PRIVATE cA120Forn     := If(l120Inclui.And. !lCopia,CriaVar("C7_FORNECE"),SC7->C7_FORNECE)
	PRIVATE cA120Loj      := If(l120Inclui.And. !lCopia,CriaVar("C7_LOJA"),SC7->C7_LOJA)
	PRIVATE cCondicao     := If(l120Inclui.And. !lCopia,CriaVar("C7_COND"),SC7->C7_COND)
	PRIVATE cDescCond     := If(l120Inclui.And. !lCopia,CriaVar("E4_DESCRI"),SE4->E4_DESCRI)
	PRIVATE cContato      := If(l120Inclui.And. !lCopia,CriaVar("C7_CONTATO"),SC7->C7_CONTATO)
	PRIVATE cFilialEnt    := If(l120Inclui.And. !lCopia,CriaVar("C7_FILENT"),SC7->C7_FILENT)
	PRIVATE cA120ProvEnt  := If(l120Inclui.And. !lCopia,If(SC7->(FieldPos("C7_PROVENT"))>0,CriaVar("C7_PROVENT"),""),Iif(SC7->(FieldPos("C7_PROVENT"))>0,SC7->C7_PROVENT,"") )
	PRIVATE cMsg          := If(l120Inclui.And. !lCopia,CriaVar("C7_MSG"),SC7->C7_MSG)
	PRIVATE cReajuste     := If(l120Inclui.And. !lCopia,CriaVar("C7_REAJUST"),SC7->C7_REAJUST)
	PRIVATE cTpFrete      := If(l120Inclui.And. !lCopia,RetTipoFrete(CriaVar("C7_TPFRETE",.T.)),RetTipoFrete(SC7->C7_TPFRETE))
	PRIVATE nDesc1        := If(l120Inclui.And. !lCopia,CriaVar("C7_DESC1"),SC7->C7_DESC1)
	PRIVATE nDesc2        := If(l120Inclui.And. !lCopia,CriaVar("C7_DESC2"),SC7->C7_DESC2)
	PRIVATE nDesc3	      := If(l120Inclui.And. !lCopia,CriaVar("C7_DESC3"),SC7->C7_DESC3)
	PRIVATE lNaturez      := FieldPos("C7_NATUREZ") > 0
	PRIVATE cCodNatu      := If(lNaturez,If(l120Inclui .And. !lCopia,CriaVar("C7_NATUREZ"),SC7->C7_NATUREZ),"")
	PRIVATE aCols         := {}
	PRIVATE aHeader    	  := {}
	PRIVATE n             := 1
	PRIVATE nMoedaPed     := If(l120Inclui.And. !lCopia,1,Max(SC7->C7_MOEDA,1))
	PRIVATE cDescMoed     := SuperGetMv("MV_MOEDA"+AllTrim(Str(nMoedaPed,2)))
	PRIVATE nTxMoeda 	  := If(l120Inclui.And. !lCopia,0,SC7->C7_TXMOEDA)
	PRIVATE lProvEnt	  := FieldPos("C7_PROVENT") > 0
	PRIVATE oGrade	      := MsMatGrade():New('oGrade',,"C7_QUANT",,'A120GValid()',,aCpsGrade)
	PRIVATE cCodDiario	  := ""
	PRIVATE c120LiqImp    := ""   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega campos enviados por Rotina Automatica 								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	If l120Inclui .And. l120Auto          
		nX:=aScan(aAutoCab,{|x| AllTrim(x[1]) == "C7_TPFRETE"})
		If nX>0        
			cTpFrete:=RetTipoFrete(aAutoCab[nX][2])
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria codigo do diario da contabilidade e liquidacao de importacao - Portugal ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() ) 
		cCodDiario := If(l120Inclui.And. !lCopia,CriaVar("C7_DIACTB"),SC7->C7_DIACTB)
	EndIf
	If cPaisLoc == "PTG"
		c120LiqImp := If(l120Inclui.And. !lCopia,CriaVar("C7_LIQIMP"),SC7->C7_LIQIMP)
	EndIf                      
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para que o sistema nao gere documentos com numeracao saltada quando executadas via rotina automatica ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l120Inclui
		If l120Auto .And. !Empty(aAutoCab[ProcH('C7_NUM'),2])
			cA120Num := aAutoCab[ProcH('C7_NUM'),2] //-- Considera o numero passado na rotina automatica
		Else
			cA120Num := CriaVar('C7_NUM', .T.) //-- Incrementa a numeracao
		EndIf
	Else
		cA120Num := SC7->C7_NUM
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada executado após a inicialização das variáveis do cabeçalho do pedido    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (ExistBlock("MT120CPE"))
		ExecBlock("MT120CPE",.F.,.F.,{nOpcX,lCopia})   
	EndIf	     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se integrado ao SIGAPMS adiciona o Botao                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If IntePms() .And. (nTipoPed == 1 .Or. nTipoPed == 2)
		aadd(aButtons,{'PROJETPMS',{||Eval(bPmsDlgPC)},"" })
	Endif

	If AliasInDic("SCH")
		Aadd(aButtons, {'S4WB013N'    ,{||oGetDados:oBrowse:lDisablePaint:=.T.,a120RatCC(aHeadSCH,aColsSCH,l120Altera .Or. l120Inclui ) ,oGetDados:oBrowse:lDisablePaint:=.F.,aBackColsSCH:=ACLONE(aColsSCH) }	,"Rateio por Item do pedido","Rateio" })//"Rateio por Item do pedido"##"Rateio "  
	Endif
	
	If !l120Visual 
		aadd(aButtons,{"SOLICITA",     {|| a120PID(oGetDados,oCond,oDescCond) },If(nTipoPed == 1, "Solicitacoes", "Solicitacoes" ),If(nTipoPed == 1, "Solicitacoes", "Solicitacoes" )})	//"Solicitacoes"
		aadd(aButtons,{"PEDIDO",       {|| a120F4(oCond,oDescCond) }			,If(nTipoPed == 1, "Solicitacoes por item", "Solicitacoes por item" ),If(nTipoPed == 1, "Solicitacoes por item", "Solicitacoes por item" )})	//"Solicitacoes por item"
		aadd(aButtons,{"S4WB005N",     {|| A120ComView() }					    ,"Historico de Produtos","Historico de Produtos"})	//Historico de Produtos
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O processo de Recebimento Antecipado estará disponivel ³
		//³apenas para TOP no Financeiro.                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		#IFDEF TOP
			If cPaisLoc $ "ANG|BRA|MEX" .and. AliasInDic("FIE") 
				aAreaAdt	:= SC7->( GetArea() )
				aRecnoSE2RA := FPedAdtPed("P", {cA120Num},,nOpcAdt)

				DbSelectArea( "SC7" )
				SC7->( DbSetOrder( 1 ) )
				SC7->( DbSeek( xFilial( "SC7" ) + cA120Num ) )
				If !l120Inclui .AND. SC7->C7_QUJE >= SC7->C7_QUANT // Pedido Atendido
					aAdd(aButtons,{"FINIMG32",{|| FPDxADTREL("P", cA120Num, 0, @aRecnoSE2RA, cA120Forn, cA120loj, .T.)},"Pagamento antecipado","Adiantamento"}) //"Pagamento antecipado"##"Adiantamento"
				Else
					aAdd(aButtons,{"FINIMG32",{|| A120Adiant(cA120Num, cCondicao,  @aRecnoSE2RA, , cA120Forn, cA120loj,aRatCTBPC,aAdtPC,@cCondPAdt)},"Pagamento antecipado","Adiantamento"}) //"Pagamento antecipado"##"Adiantamento"
				EndIf

				RestArea( aAreaAdt )
			EndIf
		#ENDIF
		SetKey( VK_F4, { || A120PID(oGetDados,oCond,oDescCond) } )	
		SetKey( VK_F5, { || A120F4(oCond,oDescCond) } )		
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ATENCAO!!!Se for PYME retira a consulta a aprovacao do PC   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !__lPyme
			aadd(aButtons,{"BUDGET",   {|| a120Posic(cAlias,nReg,nOpcx)},"Consulta Aprovacao","Consulta Aprovacao" }) //"Consulta Aprovacao"
		EndIf                           		
		#IFDEF TOP                     
			If cPaisLoc $ "ANG|BRA|MEX" .and. AliasInDic("FIE")
				aRecnoSE2RA := FPedAdtPed("P", {cA120Num},,nOpcAdt)
				aadd(aButtons,{"FINIMG32",{|| FPDxADTREL("P", cA120Num, 0, @aRecnoSE2RA, cA120Forn, cA120loj, .T.)},"Pagamento antecipado","Adiantamento"}) //"Pagamento antecipado"##"Adiantamento"		
			EndIf
		#ENDIF


		aadd(aButtons,{"S4WB005N",     {|| A120ComView() },              "Historico de Produtos","Historico de Produtos" })  //Historico de Produtos

		If !AtIsRotina("A120TRACK")
			aadd(aButtons,{"BMPORD1",  {|| A120Track() },                "System Tracker", "System Tracker"})  // "System Tracker"
		EndIf

	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para exportar dados para EXCEL                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction("RemoteType") .And. RemoteType() == 1
		aAdd(aButtons,{PmsBExcel()[1],{|| DlgToExcel({{"CABECALHO","",{RetTitle("C7_NUM") ,RetTitle("C7_EMISSAO"),RetTitle("C7_FORNECE"),RetTitle("C7_LOJA"),RetTitle("C7_COND"),RetTitle("C7_CONTATO"),RetTitle("C7_FILENT"),RetTitle("C7_MOEDA" ),RetTitle("C7_TXMOEDA")},{cA120Num,dA120Emis,cA120Forn,ca120Loj,cCondicao,cContato,cFilialEnt,nMoedaPed,nTxMoeda}},{"GETDADOS","",aHeader,aCols}}),Pergunte("MTA120",.F.)},PmsBExcel()[2],PmsBExcel()[3]})
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Avalia botoes do usuario                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "MA120BUT" )
		If ValType( aUsButtons := ExecBlock( "MA120BUT", .F., .F. ) ) == "A"
			AEval( aUsButtons, { |x| AAdd( aButtons, x ) } ) 	 	
		EndIf 	
	EndIf 	

	dbSelectArea("SX3")
	dbSetOrder(2)
	cWhenCond  :=If(MsSeek("C7_COND"),AllTrim(SX3->X3_WHEN),.T.)
	cWhenMoed  :=If(MsSeek("C7_MOEDA"),AllTrim(SX3->X3_WHEN),.T.)
	bWhenCond  := { || !l120Visual .And. VisualSX3('C7_COND') }
	bWhenMoed  := { || !l120Visual .And. VisualSX3('C7_MOEDA') }
	If cPaisLoc == "PTG"
		cWhenLiq   :=If(MsSeek("C7_LIQIMP"),AllTrim(SX3->X3_WHEN),.T.)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida a operacao com o pedido de compra ou AE                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !l120Inclui .Or. lCopia
		If l120Altera .Or. l120Deleta .Or. lCopia
			If !A120VldAlt(lCopia)
				lContinua := .F.
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa as variaveis utilizadas na exibicao do Pedido   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		A120Forn(SC7->C7_FORNECE,SC7->C7_LOJA,@aInfForn,.F.)
		A120CabOk(@oCond,@oca120Forn,@oca120Loj,aRefImpos)
		A120FormDesc(cMsg,@cDescMsg)
		A120FormReaj(cReajuste,@cDescFor)
		A120DescCnd(cCondicao,,@cDescCond)
		A120DescMoed(nMoedaPed,,@cDescMoed)
	EndIf

	If lContinua

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta aHeader e aCols utilizando a funcao FillGetDados.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l120Inclui .And. !lCopia

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FillGetDados(nOpcX,"SC7",1,,,,aNoFields,,,,,.T.,,,,,{|aHeaderX| A120AfterH(l120Auto,aHeaderX)} )
			aCols[1][aScan(aHeader,{|x| Trim(x[2])=="C7_ITEM"})] := StrZero(1,Len(SC7->C7_ITEM))

		Else

			nX      := 0
			nY      := 0	
			cPedido := SC7->C7_NUM
			dbSelectArea("SC7")
			dbSetOrder(1)
			#IFDEF TOP
				aStruSC7 := SC7->(dbStruct())

				If !InTransaction() .And. !(l120Altera .Or. l120Deleta) .And. Empty(Ascan(aStruSC7,{|x| x[2]=="M"}))

					lQuery := .T.
					cQuery := "SELECT SC7.*,SC7.R_E_C_N_O_ SC7RECNO "
					cQuery += "FROM "+RetSqlName("SC7")+" SC7 "
					cQuery += "WHERE SC7.C7_FILIAL='"+xFilial("SC7")+"' AND "
					cQuery += "SC7.C7_NUM = '"+cPedido+"' AND "
					cQuery += "SC7.D_E_L_E_T_ = ' ' "
					cQuery += "ORDER BY "+SqlOrder(SC7->(IndexKey()))

					cQuery := ChangeQuery(cQuery)

					dbSelectArea("SC7")
					dbCloseArea()

				Else
			#ENDIF
				MsSeek(xFilial("SC7")+cPedido)
			#IFDEF TOP
				EndIf	
			#ENDIF		

			cSeek  := xFilial("SC7")+cPedido
			cWhile := "SC7->C7_FILIAL+SC7->C7_NUM"
			//Zera Matrix Fiscal
			MaFisClear()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
//			FillGetDados(nOpcX,"SC7",1,cSeek,{|| &cWhile },,aNoFields,,,cQuery,,,,, {|aColsX| A120AfterC(aColsX,aRefImpos,l120Altera,l120Deleta,lCopia,@lContinua,@cItCop,lGrade)},,,"SC7")
			FillGetDados(nOpcX,"SC7",1,cSeek,{|| &cWhile },,aNoFields,,,cQuery,,,,, {|aColsX| A120AfterC(aColsX,aRefImpos,l120Altera,l120Deleta,lCopia,@lContinua,@cItCop,lGrade)},,IIF(cModulo == "EIC",{|aHeaderX| A120AfterH(l120Auto,aHeaderX)},),"SC7")
			//-- Cópia de acols para verificar se houve mudança
			aColsBKPRat := aClone(aCols)			

			If lQuery
				dbSelectArea("SC7")
				dbCloseArea()
				ChkFile("SC7",.F.)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa o Refresh nos valores de impostos.                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			A120Refresh(@aValores)
			
			If AliasInDic("SCH")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta o Array contendo as registros do SCH           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MsSeek(xFilial("SC7")+cPedido)
				DbSelectArea("SCH")
				DbSetOrder(1)
				cAliasSCH := "SCH"		
				#IFDEF TOP
					If TcSrvType()<>"AS/400"
						lQuery    := .T.
						aStruSCH  := SCH->(dbStruct())
						cAliasSCH := "A120NFISCAL"
						cQuery    := "SELECT SCH.*,SCH.R_E_C_N_O_ SCHRECNO "
						cQuery    += "FROM "+RetSqlName("SCH")+" SCH "
						cQuery    += "WHERE SCH.CH_FILIAL='"+xFilial("SCH")+"' AND "
						cQuery    += "SCH.CH_PEDIDO='"+SC7->C7_NUM+"' AND "
						cQuery    += "SCH.CH_FORNECE='"+SC7->C7_FORNECE+"' AND "
						cQuery    += "SCH.CH_LOJA='"+SC7->C7_LOJA+"' AND "
						cQuery    += "SCH.D_E_L_E_T_=' ' "
						cQuery    += "ORDER BY "+SqlOrder(SCH->(IndexKey()))
	
						cQuery := ChangeQuery(cQuery)
	
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCH,.T.,.T.)
						For nX := 1 To Len(aStruSCH)
							If aStruSCH[nX,2]<>"C"
								TcSetField(cAliasSCH,aStruSCH[nX,1],aStruSCH[nX,2],aStruSCH[nX,3],aStruSCH[nX,4])
							EndIf
						Next nX
						
					Else
				#ENDIF
					MsSeek(xFilial("SCH")+SC7->C7_NUM+SC7->C7_FORNECE+SC7->C7_LOJA)
					#IFDEF TOP
					EndIf
					#ENDIF
				dbSelectArea(cAliasSCH)
				While ( !Eof() .And. lContinua .And.;
						xFilial('SCH') == (cAliasSCH)->CH_FILIAL .And.;
						SC7->C7_NUM == (cAliasSCH)->CH_PEDIDO .And.;
						SC7->C7_FORNECE == (cAliasSCH)->CH_FORNECE .And.;
						SC7->C7_LOJA == (cAliasSCH)->CH_LOJA )
					If Empty(aBackSCH)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Montagem do aHeader                                          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("SX3")
						DbSetOrder(1)
						MsSeek("SCH")
						While ( !EOF() .And. SX3->X3_ARQUIVO == "SCH" )
							If X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !"CH_CUSTO"$SX3->X3_CAMPO
								aadd(aBackSCH,{ TRIM(X3Titulo()),;
									SX3->X3_CAMPO,;
									SX3->X3_PICTURE,;
									SX3->X3_TAMANHO,;
									SX3->X3_DECIMAL,;
									SX3->X3_VALID,;
									SX3->X3_USADO,;
									SX3->X3_TIPO,;
									SX3->X3_F3,;
									SX3->X3_CONTEXT })
							EndIf
							DbSelectArea("SX3")
							dbSkip()
						EndDo
					EndIf
					aHeadSCH  := aBackSCH

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona os campos de Alias e Recno ao aHeader para WalkThru.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ADHeadRec("SCH",aHeadSCH)
					 
					If cItemSCH <> 	(cAliasSCH)->CH_ITEMPD
						cItemSCH	:= (cAliasSCH)->CH_ITEMPD
						aadd(aColsSCH,{cItemSCH,{}})
						nItemSCH++
					EndIf
	
					aadd(aColsSCH[nItemSCH][2],Array(Len(aHeadSCH)+1))       
					
					For nY := 1 to Len(aHeadSCH)
						If IsHeadRec(aHeadSCH[nY][2])
							aColsSCH[nItemSCH][2][Len(aColsSCH[nItemSCH][2])][nY] := IIf(lQuery , (cAliasSCH)->SCHRECNO , SCH->(Recno())  )
						ElseIf IsHeadAlias(aHeadSCH[nY][2])
							aColsSCH[nItemSCH][2][Len(aColsSCH[nItemSCH][2])][nY] := "SCH"
						ElseIf ( aHeadSCH[nY][10] <> "V")
							aColsSCH[nItemSCH][2][Len(aColsSCH[nItemSCH][2])][nY] := (cAliasSCH)->(FieldGet(FieldPos(aHeadSCH[nY][2])))
						Else
							aColsSCH[nItemSCH][2][Len(aColsSCH[nItemSCH][2])][nY] := (cAliasSCH)->(CriaVar(aHeadSCH[nY][2]))
						EndIf
						aColsSCH[nItemSCH][2][Len(aColsSCH[nItemSCH][2])][Len(aHeadSCH)+1] := .F.
					Next nY
					DbSelectArea(cAliasSCH)
					dbSkip()
				EndDo
				aBackColsSCH:=ACLONE(aColsSCH)
				If lQuery
					DbSelectArea(cAliasSCH)
					dbCloseArea()
					DbSelectArea("SCH")
				EndIf
			EndIf
		EndIf

		If lContinua

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o Recurso de Grade de Produtos estiver Ativado, o aCols   ³
			//³sera processado pela funcao aColsGrade e a MatxFis sera      ³
			//³Finalizada e Reiniciada para sincronizar o novo aCols formado³
			//³pela aColsGrade().                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If l120Altera .or. l120Deleta

				//******************************************************************
				// Estorna movimentos do processo de liberação de pedido de compra *
				//******************************************************************
								
				PcoIniLan("000055")
				For nX:=1 to Len(aCols)
	
					If aCols[nX][Len(aHeader)] >0

						dbSelectArea("SC7")
						MsGoto(aCols[nX][Len(aHeader)])
						PcoDetLan('000055','01','MATA097',.T.)
					
					EndIf
				
				Next
				
				//******************************************************************
				// Estorna movimentos do processo de liberação de pedido de compra *
				//******************************************************************
				
				If aCols[1][Len(aHeader)] >0
					dbSelectArea("SC7")
					MsGoto(aCols[1][Len(aHeader)])
					PcoDetLan('000055','02','MATA097',.T.)
				EndIf
				
			EndIf
				
			If lGrade
				If !l120Inclui .Or. lCopia
					aColsBkp := aClone(acols)
					aCols    := aColsGrade(oGrade, aCols, aHeader, "C7_PRODUTO", "C7_ITEM", "C7_ITEMGRD")
				Endif

				MaFisEnd()
				MaFisIni(ca120Forn,ca120Loj,"F","N",Nil,aRefImpos,,.T.,,,,,,,)

				For nX := 1 to Len(aCols)
					MaFisIniLoad(nX,,.T.)
					For nY	:= 1 To Len(aHeader)
						cValid	:= AllTrim(UPPER(aHeader[nY][6]))
						cRefCols := MaFisGetRf(cValid)[1]
						If !Empty(cRefCols) .AND. MaFisFound("IT",nX)
							MaFisLoad(cRefCols,aCols[nX][nY],nX)
						EndIf
					Next nY
					MaFisEndLoad(nX,1)
				Next nX

				MaFisAlt("NF_FRETE",avalores[FRETE])
				MaFisAlt("NF_DESPESA",avalores[VALDESP])
				MaFisAlt("NF_SEGURO",avalores[SEGURO])
				MaFisAlt("NF_DESCONTO",avalores[VALDESC])
				
				If cPaisLoc == "PTG"                     
					MaFisAlt("NF_DESNTRIB",avalores[NTRIB])
					MaFisAlt("NF_TARA",avalores[TARA])
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa a gravacao dos lancamentos do SIGAPCO            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nTipoPed != 2
				PcoIniLan("000052")
			Else
				PcoIniLan("000053")
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tratamentos para Rotina automatica.                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l120Auto

				If nOpcX <> 5
					aValidGet := {}
					If nOpcX == 3
						AADD(aValidGet,{"cA120Num"   ,If(Empty(aAutoCab[ProcH("C7_NUM"),2]), cA120Num, aAutoCab[ProcH("C7_NUM"),2]), "CheckSX3('C7_NUM',cA120Num) .And. !ChkChaveSC7(cA120Num,.T.)", .T.})
						AADD(aValidGet,{"dA120Emis"  ,aAutoCab[ProcH("C7_EMISSAO"),2],"CheckSX3('C7_EMISSAO',dA120Emis)" + If(cPaisLoc == "ARG"," .and. EmisProPC()","") ,.T.})
						AADD(aValidGet,{"cA120Forn"  ,aAutoCab[ProcH("C7_FORNECE"),2],"CheckSX3('C7_FORNECE',cA120Forn)" + If(cPaisLoc == "ARG"," .and. a120ProEnt()",""),.T.})
						AADD(aValidGet,{"cA120Loj"    ,aAutoCab[ProcH("C7_LOJA"   ),2],"A120Forn(cA120Forn,cA120Loj,@aInfForn) .And. CheckSX3('C7_LOJA',cA120Loj)",.T.})
					EndIf
					AADD(aValidGet,{"cCondicao"       ,aAutoCab[ProcH("C7_COND"   ),2],"CheckSX3('C7_COND',cCondicao)"           ,.T.})
					AADD(aValidGet,{"cContato"        ,aAutoCab[ProcH("C7_CONTATO"),2],"CheckSX3('C7_CONTATO',cContato)"         ,.F.})
					AADD(aValidGet,{"cFilialEnt"      ,aAutoCab[ProcH("C7_FILENT" ),2],"CheckSX3('C7_FILENT',cFilialEnt)",.T.})
					If ProcH("C7_MOEDA")<>0
						AADD(aValidGet,{"nMoedaPed"   ,aAutoCab[ProcH("C7_MOEDA"  ),2],"CheckSX3('C7_MOEDA',nMoedaPed)",.T.})
						AADD(aValidGet,{"nTxMoeda"    ,aAutoCab[ProcH("C7_TXMOEDA"),2],"CheckSX3('C7_TXMOEDA',nTxMoeda)" + IIf(cPaisLoc$"PER",".And. MaFisRef('NF_TXMOEDA','MT120',nTxMoeda)",""),.T.})
					EndIf
					If lNaturez .And. ProcH("C7_NATUREZ")<>0
						Aadd(aValidGet,{"cCodNatu"    ,aAutoCab[ProcH("C7_NATUREZ"),2],"ExistCpo('SED')",.T.})
					EndIf			
					If lProvEnt .And. ProcH("C7_PROVENT")<>0
//						AADD(aValidGet,{"cA120ProvEnt" ,aAutoCab[ProcH("C7_PROVENT" ),2],"ProvEntPC() .And. CheckSX3('C7_PROVENT',cA120ProvEnt)",.T.})
						AADD(aValidGet,{"cA120ProvEnt" ,aAutoCab[ProcH("C7_PROVENT" ),2],"ProvEntPC()",.T.})
					EndIf

					If !lWhenGet
						nOpcA := 1
					Endif	

					If ! SC7->(MsVldGAuto(aValidGet)) // consiste os gets
						nOpcA := 0
					EndIf
					If nOpcA == 0 .Or.!A120CabOk(@oCond,@oca120Forn,@oca120Loj,aRefImpos)
						nOpcA := 0
					EndIf

					If ( nOpcA == 1 .Or. lWhenGet ) .And. l120Inclui
						MaFisIni(ca120Forn,ca120Loj,"F","N",Nil,aRefImpos,,.T.)
						If cPaisLoc == 'ARG'
							SA2->(DbSetOrder(1))
							SA2->(MsSeek(xFilial("SA2")+ca120Forn+ca120Loj))
							MaFisAlt('NF_SERIENF',LocXTipSer('SA2',MVNOTAFIS))
						Endif
					EndIf

					If nOpcA <> 0 .Or. lWhenGet
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica o preenchimento do campo C7_ITEM                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cItem := StrZero(1,Len(SC7->C7_ITEM))
						For nX := 1 To Len(aAutoItens)
							nY := aScan(aAutoItens[nX],{|x| AllTrim(x[1])=="C7_ITEM"})
							If nY == 0
								aadd(aAutoItens[nX],{"C7_ITEM",cItem,Nil})
							EndIf
							cItem := Soma1(cItem)
						Next nX

						If !MsGetDAuto(aAutoItens,"A120LinOk",{|| A120TudOk()},aAutoCab,aRotina[nOpcx][4])
							nOpcA := 0
						EndIf
					EndIf

					If nOpcA <> 0
						aValidGet := {}
						If ProcH("C7_FRETE")<>0
							AADD(aValidGet,{"aValores[3]" ,aAutoCab[ProcH("C7_FRETE"  ),2],"A120VFold('NF_FRETE',aValores[3])"                                    ,.F.})
						EndIf
						If ProcH("C7_DESPESA")<>0
							AADD(aValidGet,{"aValores[4]" ,aAutoCab[ProcH("C7_DESPESA"),2],'A120VFold("NF_DESPESA",aValores[4])'                                ,.F.})
						EndIf
						If ProcH("C7_SEGURO")<>0
							AADD(aValidGet,{"aValores[7]" ,aAutoCab[ProcH("C7_SEGURO" ),2],'A120VFold("NF_SEGURO",aValores[7])'                                  ,.F.})
						EndIf
						If ProcH("C7_DESC1")<>0
							AADD(aValidGet,{"nDesc1"      ,aAutoCab[ProcH("C7_DESC1"  ),2],"A120VDesc(@nDesc1,@nDesc2,@nDesc3,@aValores)"                         ,.F.})
						EndIf
						If ProcH("C7_DESC2")<>0
							AADD(aValidGet,{"nDesc2"      ,aAutoCab[ProcH("C7_DESC2"  ),2],"A120VDesc(@nDesc1,@nDesc2,@nDesc3,@aValores)"                         ,.F.})
						EndIf
						If ProcH("C7_DESC3")<>0
							AADD(aValidGet,{"nDesc3"      ,aAutoCab[ProcH("C7_DESC3"  ),2],"A120VDesc(@nDesc1,@nDesc2,@nDesc3,@aValores)"                         ,.F.})
						EndIf
						If ProcH("C7_MSG")<>0
							AADD(aValidGet,{"cMsg"        ,aAutoCab[ProcH("C7_MSG"    ),2],"CheckSX3('C7_MSG',cMsg).And.A120FormDesc(cMsg,@cDescMsg)"                       ,.F.})
						EndIf
						If ProcH("C7_REAJUST")<>0
							AADD(aValidGet,{"cReajuste"   ,aAutoCab[ProcH("C7_REAJUST"),2],"CheckSX3('C7_REAJUST',cReajuste).And.A120FormReaj(cReajuste,@cDescFor)",.F.})
						EndIf
						If lNaturez .And. ProcH("C7_NATUREZ")<>0
							Aadd(aValidGet,{"cCodNatu",aAutoCab[ProcH("C7_NATUREZ"),2],"ExistCpo('SED')",.T.})
						EndIf 
						If cPaisLoc == "PTG"
							If ProcH("C7_DESNTRB")<>0
								AADD(aValidGet,{"aValores[10]" ,aAutoCab[ProcH("C7_DESNTRB"  ),2],"A120VFold('NF_DESNTRB',aValores[10])"                                 ,.F.})
							Endif                    
							If ProcH("C7_TARA")<>0
								AADD(aValidGet,{"aValores[11]" ,aAutoCab[ProcH("C7_TARA"     ),2],"A120VFold('NF_TARA',aValores[11])"                                    ,.F.})
							EndIf
						Endif
						If !Empty(aValidGet) .And. !SC7->(MsVldGAuto(aValidGet))
							nOpcA := 0
						EndIf
					EndIf
				Else
					nOpcA := 1
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando a lWhenGet for .T. neste ponto e desligada a Roti ³
				//³na automatica l120Auto .F. para a Apresentacao da Dialog.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lWhenGet
					l120Auto := .F.
				EndIf		
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio da Construcao da Dialog do Pedido de Compras / AE    ³
			//³-------------------------------------------------------------³
			//³                          ATENCAO !!!                        ³
			//³                                                             ³
			//³Quando for feita manutencao em alguma VALIDACAO dos GETs,    ³
			//³atualize as funcoes que se encontram no array aValidGet      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !l120Auto .Or. lWhenGet

				aObjects := {}  
				AAdd( aObjects, { 0,    65, .T., .F. } )				
				AAdd( aObjects, { 100, 100, .T., .T. } )
				AAdd( aObjects, { 0,    75, .T., .F. } )
				aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
				aPosObj := MsObjSize( aInfo, aObjects )
				aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,;
					{{10,40,105,140,200,234,275,200,225,260,285,265},;
					If(cPaisLoc<>"PTG",{10,40,105,140,200,234,63},{10,40,101,120,175,205,63,250,270}),;
					Iif(cPaisLoc<>"PTG",{5,70,160,205,295},{5,50,120,145,205,245,293}),;
					{6,34,200,215},;
					{6,34,80,113,160,185},;
					{6,34,245,268,260},;
					{10,50,150,190},;
					{273,130,190},;
					{8,45,80,103,139,173,200,235,270},;
					{133,190,144,190,289,293},;
					{142,293,140},;
					{9,47,188,148,9,146} } )
				lWhenCond := If( !Empty( cWhenCond ), &( cWhenCond ), .T. ) .And. Eval( bWhenCond )
				lWhenMoed := If( !Empty( cWhenMoed ), &( cWhenMoed ), .T. ) .And. Eval( bWhenMoed )

				DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de Entrada Disnibiliza  cordenadas da Dialog.           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lMt120Get
					aPosObj := If(ValType(aPosObjPE:=ExecBlock("MT120GET",.F.,.F.,{aPosObj,nOpcx}))== "A",aPosObjPE,aPosObj)
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Definicao dos MsGETS do Cabecalho do Pedido de Compras        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				@ aPosObj[1][1],aPosObj[1][2] TO aPosObj[1][3]-16,aPosObj[1][4] LABEL '' OF oDlg PIXEL

				@ aPosObj[1][1]+5,aPosGet[1,1] SAY   "Numero" OF oDlg PIXEL SIZE 031,006               // "Numero"
				@ aPosObj[1][1]+4,aPosGet[1,2] MSGET cA120Num ;
				PICTURE PesqPict('SC7','C7_NUM') F3 CpoRetF3('C7_NUM');
				WHEN    l120Inclui .And. VisualSX3('C7_NUM') ;
				VALID   CheckSX3('C7_NUM',cA120Num)  .And. !ChkChaveSC7(cA120Num,.T.) OF oDlg PIXEL SIZE 031,006

				@ aPosObj[1][1]+5,aPosGet[1,3] SAY   "Data de Emissao" OF oDlg PIXEL SIZE 050,006               // "Data de Emissao"
				@ aPosObj[1][1]+4,aPosGet[1,4] MSGET dA120Emis ;
				PICTURE PesqPict('SC7','C7_EMISSAO') F3 CpoRetF3('C7_EMISSAO');
				WHEN    l120Inclui .And. VisualSX3('C7_EMISSAO') ;
				VALID   CheckSX3('C7_EMISSAO',dA120Emis) .And. If(cPaisLoc == "ARG",EmisProPC(),.T.) OF oDlg PIXEL SIZE 048,006 HASBUTTON

				@ aPosObj[1][1]+5,aPosGet[1,5] SAY   "Fornecedor"    OF oDlg PIXEL SIZE 036,006            // "Fornecedor"
				@ aPosObj[1][1]+4,aPosGet[1,6] MSGET oca120Forn VAR cA120Forn;
				PICTURE PesqPict('SC7','C7_FORNECE') F3 CpoRetF3('C7_FORNECE');
				WHEN    l120Inclui .And. VisualSX3('C7_FORNECE') ;
				VALID   A120Forn(cA120Forn,@cA120Loj,@aInfForn,IIF(lWhenGet,.F.,.T.),lCopia) .And. CheckSX3('C7_FORNECE',cA120Forn) .And. If(cPaisLoc == "ARG",a120ProEnt(),.T.) .And. A120VFold('NF_CODCLIFOR',ca120Forn) OF oDlg PIXEL SIZE 040,006 HASBUTTON

				@ aPosObj[1][1]+5,aPosGet[1,12] SAY OemToAnsi("Loja") OF oDlg PIXEL SIZE 019,006	   // "Loja"
				@ aPosObj[1][1]+4,aPosGet[1,7] MSGET oca120Loj VAR cA120Loj;  
				PICTURE PesqPict('SC7','C7_LOJA')  F3 CpoRetF3('C7_LOJA');
				WHEN    l120Inclui.And. VisualSX3('C7_LOJA');
				VALID   A120Forn(cA120Forn,@cA120Loj,@aInfForn,IIF(lWhenGet,.F.,.T.),lCopia) .And. CheckSX3('C7_LOJA',cA120Loj) .And. A120VFold('NF_LOJA',ca120Loj) OF oDlg PIXEL SIZE 019,006

				@ aPosObj[1][1]+17,aPosGet[2,1] SAY  "Cond. Pagto" OF oDlg PIXEL SIZE 030,006               // "Cond. Pagto"
				@ aPosObj[1][1]+16,aPosGet[2,2] MSGET oCond   VAR cCondicao  ;
				PICTURE PesqPict('SC7','C7_COND') F3 CpoRetF3('C7_COND');
				VALID   CheckSX3('C7_COND',cCondicao) .And. A120DescCnd(cCondicao,@oDescCond,@cDescCond,oGetDados) .And. A120ValCond(cCondicao);
				WHEN    lWhenCond  .And. !lMt120Ped OF oDlg PIXEL SIZE 025,006 HASBUTTON

				@ aPosObj[1][1]+17,aPosGet[2,3] SAY   "Contato" OF oDlg PIXEL SIZE 038,006               // "Contato"
				@ aPosObj[1][1]+16,aPosGet[2,4] MSGET cContato  ;
				PICTURE PesqPict('SC7','C7_CONTATO') F3 CpoRetF3('C7_CONTATO');
				WHEN    !l120Visual .And. VisualSX3('C7_CONTATO')  .And. !lMt120Ped ;
				VALID   CheckSX3('C7_CONTATO',cContato) OF oDlg PIXEL SIZE 074,006

				@ aPosObj[1][1]+16,aPosGet[2,7] MSGET oDescCond VAR cDescCond PICTURE PesqPict('SE4','E4_DESCRI') WHEN .F. OF oDlg PIXEL SIZE 055,006
        
				@ aPosObj[1][1]+17,aPosGet[2,5] SAY   "Filial p/ Entrega" OF oDlg PIXEL SIZE 050,006               // "Filial p/ Entrega"
				@ aPosObj[1][1]+16,aPosGet[2,6] MSGET cFilialEnt  ;
				PICTURE PesqPict('SC7','C7_FILENT') F3 CpoRetF3('C7_FILENT');
				WHEN    l120Visual .And. !lMt120Ped ;
				VALID   CheckSX3('C7_FILENT',cFilialEnt).And.	Eval(bGDRefresh) OF oDlg PIXEL SIZE 019,006 HASBUTTON                                                   
				
				@ aPosObj[1][1]+29,aPosGet[2,1] SAY   "Moeda"   OF oDlg PIXEL SIZE 030,006             // "Moeda"
				@ aPosObj[1][1]+28,aPosGet[2,2] MSGET oGetMoeda VAR nMoedaPed ;
				PICTURE PesqPict("SC7","C7_MOEDA") ;
				VALID   M->NMOEDAPED <= MoedFin().And. M->NMOEDAPED <> 0 .And. A120DescMoed(nMoedaPed,@oDescMoed,@cDescMoed,@nTxMoeda,aObj) ;
				WHEN    lWhenMoed .And. !lMt120Ped PIXEL SIZE 25,06 OF oDlg

				@ aPosObj[1][1]+28,aPosGet[2,7] MSGET oDescMoed VAR cDescMoed  WHEN .F. OF oDlg PIXEL SIZE 055,006

				@ aPosObj[1][1]+29,aPosGet[2,3] SAY   "Taxa da Moeda" OF oDlg PIXEL SIZE 030,006               // "Taxa da Moeda"
				@ aPosObj[1][1]+28,aposget[2,4] MSGET nTxMoeda OF oDlg ;
				PICTURE PesqPict("SC7","C7_TXMOEDA",11) F3 CpoRetF3('C7_TXMOEDA');
				WHEN    !l120Visual .And. VisualSX3('C7_TXMOEDA') .And. !lMt120Ped ;
				VALID   (CheckSX3('C7_TXMOEDA',nMoedaped) .And. Iif (cPaisLoc $ "PER",MaFisRef("NF_TXMOEDA","MT120",nTxMoeda),.T.)) PIXEL SIZE 074,006 HASBUTTON
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gets especificos para Versao Localizada Testa os Campos.      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lNaturez .And. cPaisLoc <> "PTG"
					@ aPosObj[1][1]+29,aPosGet[1,8] SAY Alltrim(RetTitle("C7_NATUREZ"))	     OF oDlg PIXEL SIZE 45,10	//"&Cod. Comprador"
					@ aPosObj[1][1]+28,aPosGet[1,9] MSGET cCodNatu F3 CpoRetF3("C7_NATUREZ") PICTURE PesqPict("SC7","C7_NATUREZ");
					WHEN !l120Visual .And. VisualSX3("C7_NATUREZ") VALID Vazio() .Or. ExistCpo("SED") OF oDlg PIXEL SIZE 45,006 HASBUTTON
				EndIf

				If cPaisLoc == "PTG"
					@ aPosObj[1][1]+29,aPosGet[2,5] SAY Alltrim(RetTitle("C7_NATUREZ"))	     OF oDlg PIXEL SIZE 45,10	//"&Cod. Comprador"
					@ aPosObj[1][1]+28,aPosGet[2,6] MSGET cCodNatu F3 CpoRetF3("C7_NATUREZ") PICTURE PesqPict("SC7","C7_NATUREZ");
					WHEN !l120Visual .And. VisualSX3("C7_NATUREZ") VALID Vazio() .Or. ExistCpo("SED") OF oDlg PIXEL SIZE 45,006 HASBUTTON

					@ aPosObj[1][1]+29,aPosGet[2,8] SAY   Alltrim(RetTitle("C7_LIQIMP"))    OF oDlg PIXEL SIZE 045,10 // Liq. Importacao
					@ aPosObj[1][1]+28,aPosGet[2,9] MSGET c120LiqImp PICTURE PesqPict('SC7','C7_LIQIMP');
					WHEN !l120Visual .And. IIf(&(cWhenLiq),.T.,.F.) OF oDlg PIXEL SIZE 45,006 HASBUTTON
				EndIf                                                                             

				If lProvEnt .And. cPaisLoc <> "PTG"
					@ aPosObj[1][1]+29,If(lNaturez,aPosGet[1,10],aPosGet[1,5]) SAY   Alltrim(RetTitle("C7_PROVENT"))    OF oDlg PIXEL SIZE 045,10 // Prov. Entrega
					@ aPosObj[1][1]+28,If(lNaturez,aPosGet[1,11],aPosGet[1,6]) MSGET oca120PrVE VAR cA120ProvEnt         PICTURE PesqPict('SC7','C7_PROVENT') F3 CpoRetF3('C7_PROVENT');
					WHEN l120Inclui.And. VisualSX3('C7_PROVENT')  Valid  ProvEntPC() OF oDlg PIXEL SIZE 019,006  HASBUTTON  // .AND.   MafisRef("NF_UFDEST","M100",cA120ProvEnt) OF oDlg PIXEL SIZE 019,006
//					WHEN l120Inclui.And. VisualSX3('C7_PROVENT')   VALID CheckSX3('C7_PROVENT',cA120ProvEnt) OF oDlg PIXEL SIZE 019,006  HASBUTTON  // .AND.   MafisRef("NF_UFDEST","M100",cA120ProvEnt) OF oDlg PIXEL SIZE 019,006
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de Entrada Disnibiliza o Objeto da Dialog e cordenadas  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lMt120TEL
					ExecBlock("MT120TEL",.F.,.F.,{@oDlg, aPosGet, aObj, nOpcx, nReg} )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Criacao da Area da MsGetDados do PC                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If l120Visual .and. lGrade
					oGetdados := msGetDados():New(aPosObj[2,1]-20,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],4,,,"",,{"C7_QUANT","C7_QTSEGUM","C7_DATPRF"},,,,,,,,,)
				Else
					if lMt120Ped
						oGetDados := MSGetDados():New(aPosObj[2,1]-20,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcX,'A120LinOk','A120TudOk','+C7_ITEM',!l120Visual,aCPed1,,,Len(aCols),'A120FldOk()',,,'A120Del')
					Else
						oGetDados := MSGetDados():New(aPosObj[2,1]-20,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcX,'A120LinOk','A120TudOk','+C7_ITEM',!l120Visual,,,,MAXGETDAD,'A120FldOk()',,,'A120Del')
					EndIf
				EndIf
				oGetDados:oBrowse:bGotFocus	:= {||A120CabOk(@oCond,@oca120Forn,@oca120Loj,aRefImpos) }

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Criacao dos Folders da Area do Rodape do PC                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitles,{"HEADER"},oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1],)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³acerto no folder para nao perder o foco                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 to Len(oFolder:aDialogs)
					DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nX]
				Next nX

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³MsGets do Folder dos totais                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[1]:oFont := oDlg:oFont 
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de Entrada para Incluir Folders no Rodape P.E. usado em ³
				//³conjunto com o P.E. MT120Tel e a variavel aTitles.            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("MT120FOL")
					ExecBlock("MT120FOL",.F.,.F.,{nOpcx,aPosGet})
				EndIf		
				  
				If cPaisLoc <> "PTG"
					@ 006,aPosGet[3,1] SAY   "Valor da Mercadoria"  OF  oFolder:aDialogs[1] PIXEL SIZE 055,009 // "Valor da Mercadoria"
					@ 005,aPosGet[3,2] MSGET aObj[01] VAR aValores[VALMERC]   PICTURE    PesqPict('SC7','C7_TOTAL',17,nMoedaPed)   OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
					@ 006,aPosGet[3,3] SAY   "Descontos"  OF  oFolder:aDialogs[1] PIXEL SIZE 049,009 // "Descontos"
					@ 005,aPosGet[3,4] MSGET aObj[02] VAR aValores[VALDESC]   PICTURE    PesqPict('SC7','C7_VLDESC',17,nMoedaPed)  OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
					@ 020,aPosGet[3,1] SAY   "Frete"  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Frete"
					@ 019,aPosGet[3,2] MSGET aObj[03] VAR aValores[FRETE]     PICTURE    PesqPict('SC7','C7_FRETE',17,nMoedaPed)   OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
					@ 020,aPosGet[3,3] SAY   "Despesas"  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Despesas"
					@ 019,aPosGet[3,4] MSGET aObj[22] VAR aValores[VALDESP]   PICTURE    PesqPict('SC7','C7_DESPESA',17,nMoedaPed) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
					@ 034,aPosGet[3,3] SAY   "Seguro"  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Seguro"
					@ 033,aPosGet[3,4] MSGET aObj[23] VAR aValores[SEGURO]    PICTURE    PesqPict('SC7','C7_DESPESA',17,nMoedaPed) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
					@ 051,aPosGet[3,3] SAY   "Total do Pedido"  OF  oFolder:aDialogs[1] PIXEL SIZE 058,009 // "Total do Pedido"
					@ 049,aPosGet[3,4] MSGET aObj[04] VAR aValores[TOTPED]    PICTURE    PesqPict('SC7','C7_TOTAL',17,nMoedaPed)   OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
					@ 043,003 TO 46 ,aPosGet[3,5] LABEL '' OF oFolder:aDialogs[1] PIXEL
				Else 
					@ 005,aPosGet[3,1] SAY   "Valor da Mercadoria"  OF  oFolder:aDialogs[1] PIXEL SIZE 055,009 // "Valor da Mercadoria"
					@ 004,aPosGet[3,2] MSGET aObj[01] VAR aValores[VALMERC]   PICTURE    PesqPict('SC7','C7_TOTAL',17,nMoedaPed)   OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
					@ 005,aPosGet[3,3] SAY   "Descontos"  OF  oFolder:aDialogs[1] PIXEL SIZE 049,009 // "Descontos"
					@ 004,aPosGet[3,4] MSGET aObj[02] VAR aValores[VALDESC]   PICTURE    PesqPict('SC7','C7_VLDESC',17,nMoedaPed)  OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
					@ 005,aPosGet[3,5] SAY   "Frete"  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Frete"
					@ 004,aPosGet[3,6] MSGET aObj[03] VAR aValores[FRETE]     PICTURE    PesqPict('SC7','C7_FRETE',17,nMoedaPed)   OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
					@ 019,aPosGet[3,1] SAY   "Seguro"  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Seguro"
					@ 018,aPosGet[3,2] MSGET aObj[23] VAR aValores[SEGURO]    PICTURE    PesqPict('SC7','C7_DESPESA',17,nMoedaPed) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
					@ 019,aPosGet[3,3] SAY   "Despesas"  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Despesas"
					@ 018,aPosGet[3,4] MSGET aObj[22] VAR aValores[VALDESP]   PICTURE    PesqPict('SC7','C7_SEGURO',17,nMoedaPed) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
					@ 019,aPosGet[3,5] SAY   "Despesas não trib."  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Despesas não trib."
					@ 018,aPosGet[3,6] MSGET aObj[25] VAR aValores[NTRIB]     PICTURE    PesqPict('SC7','C7_DESNTRB',17,nMoedaPed) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
					@ 033,aPosGet[3,1] SAY   "Tara"  OF  oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Tara"
					@ 032,aPosGet[3,2] MSGET aObj[26] VAR aValores[TARA]      PICTURE    PesqPict('SC7','C7_TARA',17,nMoedaPed) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
					@ 051,aPosGet[3,5] SAY   "Total do Pedido"  OF  oFolder:aDialogs[1] PIXEL SIZE 058,009 // "Total do Pedido"
					@ 049,aPosGet[3,6] MSGET aObj[04] VAR aValores[TOTPED]    PICTURE    PesqPict('SC7','C7_TOTAL',17,nMoedaPed)   OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
					@ 046,aPosGet[3,1] TO 047,aPosGet[3,7] LABEL '' OF oFolder:aDialogs[1] PIXEL
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³MsGets do Folder com as informacoes do fornecedor             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[2]:oFont := oDlg:oFont
				@ 006,aPosGet[4,1] SAY "Nome"    OF   oFolder:aDialogs[2] PIXEL SIZE 037,009 // "Nome"
				@ 005,aPosGet[4,2] MSGET aObj[5]  VAR  aInfForn[1]         PICTURE PesqPict('SA2','A2_NOME')   WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 159,009
				@ 006,aPosGet[4,3] SAY "Tel."    OF   oFolder:aDialogs[2] PIXEL SIZE 023,009 // "Tel."
				@ 005,aPosGet[4,4] MSGET aObj[6]  VAR  aInfForn[2]                                             WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 074,009
				@ 043,aPosGet[5,1] SAY "1a Compra"    OF   oFolder:aDialogs[2] PIXEL SIZE 032,009 // "1a Compra"
				@ 042,aPosGet[5,2] MSGET aObj[7]  VAR  aInfForn[3]         PICTURE PesqPict('SA2','A2_PRICOM') WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 040,009
				@ 043,aPosGet[5,3] SAY "Ult. Compra"    OF   oFolder:aDialogs[2] PIXEL SIZE 036,009 // "Ult. Compra"
				@ 042,aPosGet[5,4] MSGET aObj[8]  VAR  aInfForn[4]         PICTURE PesqPict('SA2','A2_ULTCOM') WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 040,009
				@ 043,aPosGet[5,5] SAY RTrim(RetTitle("A2_CGC")) OF oFolder:aDialogs[2] PIXEL SIZE 31 ,009 // "CNPJ / CPF"
				@ 042,aPosGet[5,6] MSGET aObj[21] VAR  aInfForn[7]         PICTURE PesqPict('SA2','A2_CGC')    WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 76 ,009
				@ 024,aPosGet[6,1] SAY "Endereco"    OF   oFolder:aDialogs[2] PIXEL SIZE 049,009 // "Endereco"
				@ 023,aPosGet[6,2] MSGET aObj[9]  VAR  aInfForn[5]         PICTURE PesqPict('SA2','A2_END')    WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 205,009
				@ 024,aPosGet[6,3] SAY "Estado"    OF   oFolder:aDialogs[2] PIXEL SIZE 032,009 // "Estado"
				@ 023,aPosGet[6,4] MSGET aObj[10] VAR  aInfForn[6]         PICTURE PesqPict('SA2','A2_EST')    WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 021,009
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inclusão da função IsInCallStack para não ocorrer recursividade  ³
				//³de telas visualização do pedido de compras a partir  			³
				//³da consulta Posição Fornecedores  								³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !IsInCallStack("FINC030")
					@ 042,aPosGet[6,5] BUTTON "Mais Inf." SIZE 030,010  FONT oDlg:oFont ACTION A120ToFC030()  OF oFolder:aDialogs[2] PIXEL // "Mais Inf."
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³MsGets do Folder das despesas acessorias                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[3]:oFont := oDlg:oFont 
				If cPaisLoc <> "PTG"
					@ 009,aPosGet[7,1] SAY "Tp. Frete"    OF  oFolder:aDialogs[3] PIXEL SIZE 035,009 // "Tp. Frete"
					@ 008,aPosGet[7,2] MSCOMBOBOX aObj[11] VAR cTpFrete       ITEMS      aCombo ON CHANGE A120VldCombo(cTpFrete,@aValores) .And. A120VFold("NF_FRETE",aValores[FRETE]) WHEN !l120Visual .And. !lMt120Ped SIZE 065,050 OF oFolder:aDialogs[3] PIXEL
					@ 009,aPosGet[7,3] SAY "Valor do Frete"    OF  oFolder:aDialogs[3] PIXEL SIZE 035,009 //"Valor do Frete"
					@ 008,aPosGet[7,4] MSGET aObj[12] VAR aValores[FRETE]     PICTURE    PesqPict('SC7','C7_FRETE',14,nMoedaPed) OF oFolder:aDialogs[3] PIXEL WHEN !l120Visual .And. cTpFrete=="C-CIF" .And. !lMt120Ped VALID A120VFold("NF_FRETE",aValores[FRETE]) SIZE 080,009 HASBUTTON
					@ 026,aPosGet[7,1] SAY "Despesas"    OF  oFolder:aDialogs[3] PIXEL SIZE 042,009 // "Despesas"
					@ 025,aPosGet[7,2] MSGET aObj[13] VAR aValores[VALDESP]   PICTURE    PesqPict('SC7','C7_FRETE',14,nMoedaPed) OF oFolder:aDialogs[3] PIXEL WHEN !l120Visual .And. !lMt120Ped VALID A120VFold("NF_DESPESA",aValores[VALDESP]) SIZE 080,009 HASBUTTON
					@ 026,aPosGet[7,3] SAY "Seguro"    OF  oFolder:aDialogs[3] PIXEL SIZE 035,009 // "Seguro"
					@ 025,aPosGet[7,4] MSGET aObj[14] VAR aValores[SEGURO]    PICTURE    PesqPict('SC7','C7_FRETE',14,nMoedaPed) OF oFolder:aDialogs[3] PIXEL WHEN !l120Visual .And. !lMt120Ped VALID A120VFold("NF_SEGURO",aValores[SEGURO]) SIZE 080,009 HASBUTTON
					@ 038,011 TO 40 ,aPosGet[8,1] LABEL '' OF oFolder:aDialogs[3] PIXEL
					@ 048,aPosGet[8,2] SAY "Total ( Frete+Despesas)"    OF  oFolder:aDialogs[3] PIXEL SIZE 060,009 // "Total ( Frete+Despesas)"
					@ 047,aPosGet[8,3] MSGET aObj[24] VAR aValores[TOTF3]     PICTURE    PesqPict('SC7','C7_FRETE',14,nMoedaPed) OF oFolder:aDialogs[3] PIXEL WHEN .F. .And. !lMt120Ped SIZE 080,009 HASBUTTON
				Else 
					@ 005,aPosGet[7,1] SAY "Tp. Frete"    OF  oFolder:aDialogs[3] PIXEL SIZE 035,009 // "Tp. Frete"
					@ 004,aPosGet[7,2] MSCOMBOBOX aObj[11] VAR cTpFrete       ITEMS      aCombo ON CHANGE A120VldCombo(cTpFrete,@aValores) .And. A120VFold("NF_FRETE",aValores[FRETE]) WHEN !l120Visual .And. !lMt120Ped SIZE 065,050 OF oFolder:aDialogs[3] PIXEL
					@ 005,aPosGet[7,3] SAY "Valor do Frete"    OF  oFolder:aDialogs[3] PIXEL SIZE 035,009 //"Valor do Frete"
					@ 004,aPosGet[7,4] MSGET aObj[12] VAR aValores[FRETE]     PICTURE    PesqPict('SC7','C7_FRETE',14,nMoedaPed) OF oFolder:aDialogs[3] PIXEL WHEN !l120Visual .And. cTpFrete=="C-CIF" .And. !lMt120Ped VALID A120VFold("NF_FRETE",aValores[FRETE]) SIZE 080,009 HASBUTTON
					@ 019,aPosGet[7,1] SAY "Seguro"    OF  oFolder:aDialogs[3] PIXEL SIZE 035,009 // "Seguro"
					@ 018,aPosGet[7,2] MSGET aObj[14] VAR aValores[SEGURO]    PICTURE    PesqPict('SC7','C7_FRETE',14,nMoedaPed) OF oFolder:aDialogs[3] PIXEL WHEN !l120Visual .And. !lMt120Ped VALID A120VFold("NF_SEGURO",aValores[SEGURO]) SIZE 080,009 HASBUTTON
					@ 019,aPosGet[7,3] SAY "Despesas"    OF  oFolder:aDialogs[3] PIXEL SIZE 042,009 // "Despesas"
					@ 018,aPosGet[7,4] MSGET aObj[13] VAR aValores[VALDESP]   PICTURE    PesqPict('SC7','C7_FRETE',14,nMoedaPed) OF oFolder:aDialogs[3] PIXEL WHEN !l120Visual .And. !lMt120Ped VALID A120VFold("NF_DESPESA",aValores[VALDESP]) SIZE 080,009 HASBUTTON
					@ 033,aPosGet[7,1] SAY "Despesas não trib."    OF  oFolder:aDialogs[3] PIXEL SIZE 050,009 // "Despesas não trib."
					@ 032,aPosGet[7,2] MSGET aObj[27] VAR aValores[NTRIB]     PICTURE    PesqPict('SC7','C7_DESNTRB',14,nMoedaPed) OF oFolder:aDialogs[3] PIXEL WHEN !l120Visual .And. !lMt120Ped VALID A120VFold("NF_DESNTRB",aValores[NTRIB]) SIZE 080,009 HASBUTTON
					@ 033,aPosGet[7,3] SAY "Tara"    OF  oFolder:aDialogs[3] PIXEL SIZE 042,009 // "Tara"
					@ 032,aPosGet[7,4] MSGET aObj[28] VAR aValores[TARA]     PICTURE    PesqPict('SC7','C7_TARA',14,nMoedaPed) OF oFolder:aDialogs[3] PIXEL WHEN !l120Visual .And. !lMt120Ped VALID A120VFold("NF_TARA",aValores[TARA]) SIZE 080,009 HASBUTTON
					@ 046,011 TO 47 ,aPosGet[8,1] LABEL '' OF oFolder:aDialogs[3] PIXEL
					@ 051,aPosGet[7,3] SAY  "Total ( Frete+Despesas)"    OF  oFolder:aDialogs[3] PIXEL SIZE 060,009 // "Total ( Frete+Despesas)"
					@ 050,aPosGet[7,4] MSGET aObj[24] VAR aValores[TOTF3]     PICTURE    PesqPict('SC7','C7_FRETE',14,nMoedaPed) OF oFolder:aDialogs[3] PIXEL WHEN .F. .And. !lMt120Ped SIZE 080,009 HASBUTTON
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³MsGets do Folder dos Descontos de rodape                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[4]:oFont := oDlg:oFont
				@ 009,aPosGet[09,1] SAY "Desconto 1"    OF  oFolder:aDialogs[4] PIXEL SIZE 040,009 // "Desconto 1"
				@ 008,aPosGet[09,2] MSGET aObj[15] VAR nDesc1              PICTURE    PesqPict('SC7','C7_DESC1',,nMoedaPed) OF oFolder:aDialogs[4] PIXEL WHEN !l120Visual .And. MaFisFound("NF") .And. !lMt120Ped VALID A120VDesc(@nDesc1,@nDesc2,@nDesc3,@aValores) .And. Positivo() SIZE 030,009 HASBUTTON
				@ 009,aPosGet[09,3] SAY '%'        OF  oFolder:aDialogs[4] PIXEL SIZE 011,009
				@ 009,aPosGet[09,4] SAY "Desconto 2"    OF  oFolder:aDialogs[4] PIXEL SIZE 036,009 // "Desconto 2"
				@ 008,aPosGet[09,5] MSGET aObj[16] VAR nDesc2              PICTURE    PesqPict('SC7','C7_DESC2',,nMoedaPed) OF oFolder:aDialogs[4] PIXEL WHEN !l120Visual .And. MaFisFound("NF") .And. !lMt120Ped VALID A120VDesc(@nDesc1,@nDesc2,@nDesc3,@aValores) .And. Positivo() SIZE 030,009 HASBUTTON
				@ 009,aPosGet[09,6] SAY '%'        OF  oFolder:aDialogs[4] PIXEL SIZE 009,009
				@ 009,aPosGet[09,7] SAY "Desconto 3"    OF  oFolder:aDialogs[4] PIXEL SIZE 042,009 // "Desconto 3"
				@ 008,aPosGet[09,8] MSGET aObj[17] VAR nDesc3              PICTURE    PesqPict('SC7','C7_DESC3',,nMoedaPed) OF oFolder:aDialogs[4] PIXEL WHEN !l120Visual .And. MaFisFound("NF") .And. !lMt120Ped VALID A120VDesc(@nDesc1,@nDesc2,@nDesc3,@aValores) .And. Positivo() SIZE 030,009 HASBUTTON
				@ 009,aPosGet[09,9] SAY '%'        OF  oFolder:aDialogs[4] PIXEL SIZE 012,009
				@ 027,aPosGet[10,1] SAY "Valor do Desconto"    OF  oFolder:aDialogs[4] PIXEL SIZE 048,009 //"Valor do Desconto"
				@ 026,aPosGet[10,2] MSGET aObj[18] VAR aValores[VALDESC]   PICTURE    PesqPict('SC7','C7_VLDESC',14,nMoedaPed) OF oFolder:aDialogs[4] PIXEL WHEN !l120Visual .And. MaFisFound("NF") .And.(nDesc1+nDesc2+nDesc3==0) .And. !lMt120Ped VALID A120VFold("NF_DESCONTO",aValores[VALDESC]) SIZE 075,009 HASBUTTON
				@ 049,aPosGet[10,3] SAY "Total do Pedido"    OF  oFolder:aDialogs[4] PIXEL SIZE 043,009 // "Total do Pedido"
				@ 048,aPosGet[10,4] MSGET aObj[19] VAR aValores[TOTPED]    PICTURE    PesqPict('SC7','C7_TOTAL',14,nMoedaPed) OF oFolder:aDialogs[4] PIXEL WHEN .F. SIZE 075,009 HASBUTTON
				@ 038,005 TO 040,aPosGet[10,5] LABEL '' OF oFolder:aDialogs[4] PIXEL

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³MsGets do Folder do Resumo de Impostos                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[5]:oFont := oDlg:oFont
				If !lMt120Ped
				aObj[20] := MaFisRodape(nTpRodape,oFolder:aDialogs[5],,{5,3,aPosGet[10,6],53},bListRefresh,l120Visual)
				else
					aObj[20] := MaFisRodape(nTpRodape,oFolder:aDialogs[5],,{5,3,aPosGet[10,6],53},bListRefresh,.T.)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³MsGets do Folder de Menssagem e Reajuste                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[6]:oFont := oDlg:oFont
				@ 005,aPosGet[11,1] TO 055,aPosGet[11,2] LABEL "Reajuste" OF oFolder:aDialogs[6] PIXEL //"Reajuste"
				@ 005,003 TO 055,aPosGet[11,3] LABEL "Mensagem" OF oFolder:aDialogs[6] PIXEL // "Mensagem"
				@ 015,aPosGet[12,1] SAY   "Cod. Formula"   OF oFolder:aDialogs[6] PIXEL SIZE 040,009 // "Cod. Formula"
				@ 014,aPosGet[12,2] MSGET cMsg      PICTURE PesqPict('SC7','C7_MSG')     F3 CpoRetF3('C7_MSG')     WHEN !l120Visual .And.VisualSX3('C7_MSG') .And. !lMt120Ped  VALID CheckSX3('C7_MSG',cMsg).And.A120FormDesc(cMsg,@cDescMsg) .And. A120FRefresh(aObj2) OF oFolder:aDialogs[6] PIXEL SIZE 023,009 HASBUTTON
				@ 014,aPosGet[12,3] MSGET cReajuste PICTURE PesqPict('SC7','C7_REAJUST') F3 CpoRetF3('C7_REAJUST') WHEN !l120Visual .And.VisualSX3('C7_REAJUST') .And. !lMt120Ped VALID CheckSX3('C7_REAJUST',cReajuste).And.A120FormReaj(cReajuste,@cDescFor) .And. A120FRefresh(aObj2) OF oFolder:aDialogs[6] PIXEL SIZE 023,009 HASBUTTON
				@ 015,aPosGet[12,4] SAY   "Cod.Formula"   OF oFolder:aDialogs[6] PIXEL SIZE 040,009 // "Cod.Formula"
				@ 032,aPosGet[12,5] MSGET aObj2[1]  VAR cDescMsg  PICTURE "@!" OF oFolder:aDialogs[6] WHEN .F. PIXEL SIZE 124,009
				@ 031,aPosGet[12,6] MSGET aObj2[2]  VAR cDescFor  PICTURE "@!" OF oFolder:aDialogs[6] WHEN .F. PIXEL SIZE 140,009

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de Entrada que disponibiliza o Objeto da Dialog - oDlg  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lMt120Scr
					ExecBlock("MT120SCR",.F.,.F.,@oDlg)
				EndIf	

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Execucao de Refresh necessario para Rotina automatica lWhenGet³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lWhenGet
					Eval(bRefresh)
				EndIf
				ACTIVATE MSDIALOG oDlg ON INIT (IIf(lWhenGet,oGetDados:oBrowse:Refresh(),Nil),EnchoiceBar(oDlg,{||If(oGetDados:TudoOk() .And. A120aColsRa(aColsBKPRat,nOpcx,aColsSCH),(nOpcA:=1 , oDlg:End()),(nOpcA:=0,oGetDados:oBrowse:SetFocus()))},{|| oDlg:End()},,aButtons))

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de Entrada para Continuar ou nao a Exclusao             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l120Deleta .And. ExistBlock("MTA120E")
				lMta120E := ExecBlock("MTA120E",.f.,.f.,{nOpcA,cA120Num})
				If ValType( lMta120E ) == "L" .And. !lMta120E
					nOpcA := 0
				EndIf
			EndIf

			If nOpcA == 1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executa a chamada a função A120PvTran e A120PedAglut ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aL120PvTran   := A120PvTran(cA120Num,l120deleta)
				If aL120PvTran[1] 
					aL120PedAglut := A120PedAglut(cA120Num,l120deleta)
					If !aL120PedAglut[1]
						l120Inclui := .F.
						l120Altera := .F.
						l120Deleta := .F.
					EndIf
				Else
					l120Inclui := .F.
					l120Altera := .F.
					l120Deleta := .F.
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de Entrada para Continuar ou nao Inclusao/Alteracao.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (l120Inclui .Or. l120Altera .Or. l120Deleta) .And. ExistTemplate("MT120GRV")
					lMt120GRV := ExecTemplate("MT120GRV",.F.,.F.,{cA120Num,l120Inclui,l120Altera,l120Deleta })
					If ValType( lMt120GRV ) == "L" .And. !lMt120GRV
						l120Inclui := .F.
						l120Altera := .F.
						l120Deleta := .F.
					EndIf
				EndIf

				If (l120Inclui .Or. l120Altera .Or. l120Deleta) .And. ExistBlock("MT120GRV")
					lMt120GRV := Execblock("MT120GRV",.F.,.F.,{cA120Num,l120Inclui,l120Altera,l120Deleta })
					If ValType( lMt120GRV ) == "L" .And. !lMt120GRV
						l120Inclui := .F.
						l120Altera := .F.
						l120Deleta := .F.
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inicio para chamada da A120Grava() para Manutencao do PC / AE³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If l120Inclui .Or. l120Altera .Or. l120Deleta
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicializa a gravacao atraves das funcoes MATXFIS       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MaFisWrite(1)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Prepara a contabilizacao On-Line                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lCtbOnLine

						dbSelectArea("SX5")
						dbSetOrder(1)
						If MsSeek(xFilial()+"09COM")         			// Verifica o numero do lote contabil
							cLoteCtb := AllTrim(X5Descri())
						Else
							cLoteCtb := "COM "
						EndIf		

						If At(UPPER("EXEC"),X5Descri()) > 0  			// Executa um execblock
							cLoteCtb := &(X5Descri())
						EndIf				

						nHdlPrv:=HeadProva(cLoteCtb,"MATA120",Subs(cUsuario,7,6),@cArqCtb) // Inicializa o arquivo de contabilizacao
						If nHdlPrv <= 0
							HELP(" ",1,"SEM_LANC")
							lCtbOnLine := .F.
						EndIf

						If lCtbOnLine
							bCtbOnLine := {|x| nTotalCtb += IIf(x==1,DetProva(nHdlPrv,"652","MATA120",cLoteCtb,,,,,@c652,@aCT5),;
								IIf( (!Empty(SC7->C7_DTLANC)) .OR. (lMV_COEXCPC .And. l120Deleta),DetProva(nHdlPrv,"657","MATA120",cLoteCtb,,,,,@c657,@aCT5),0)),;
								SC7->C7_DTLANC := dDataBase}
						EndIf

					EndIF

					If !l120Inclui

						Begin Transaction

							A120Grava(l120Deleta,cReajuste,nDesc1,nDesc2,nDesc3,cMsg,Substr(cTpFrete,1,1),bCtbOnLine,lCopia,NIL,aL120PvTran,aL120PedAglut,aHeadSCH,aColsSCH)

							If SA2->(FieldPos("A2_IMPIP")) # 0 .And. !l120Deleta
								If (SA2->A2_IMPIP == '1') .Or. (SA2->A2_IMPIP $ '03 ' .And. SuperGetMV('MV_IMPIP',.F.,'3') == '1' )
									If FindFunction("ACDI10PD")
										ACDI10PD(cA120Num,.T.)
									ElseIf FindFunction("T_ACDI10PD")
										T_ACDI10PD(cA120Num,.T.)
								    EndIf
								EndIf
							EndIf

							EvalTrigger()

							While ( GetSX8Len() > nSaveSX8 )
								ConFirmSX8()
							EndDo

						End Transaction

					Else

						lGravaOk := A120Grava(l120Deleta,cReajuste,nDesc1,nDesc2,nDesc3,cMsg,Substr(cTpFrete,1,1),bCtbOnLine,lCopia,aRecnoSE2RA,aL120PvTran,aL120PedAglut,aHeadSCH,aColsSCH)

						If SA2->(FieldPos("A2_IMPIP")) # 0 .and. !l120Deleta
							If (SA2->A2_IMPIP == '1') .or. (SA2->A2_IMPIP $ '03 ' .and. SuperGetMV('MV_IMPIP',.F.,'3') == '1' )
								If SuperGetMV('MV_IMPAUT',.F.,"1") <>  "0" .Or. !l120auto
								  	If FindFunction("ACDI10PD")
										ACDI10PD(cA120Num,.T.,l120auto .And. SuperGetMV('MV_IMPAUT',.F.,'1') == '2')
								  	ElseIf FindFunction("T_ACDI10PD")
										T_ACDI10PD(cA120Num,.T.,l120auto .And.SuperGetMV('MV_IMPAUT',.F.,'1') == '2')
								    EndIf
								EndIf
							EndIf
						EndIf

						If !lGravaOk

							Help(" ",1,"A120NAOREG")
							While ( GetSX8Len() > nSaveSX8 )
								RollBackSX8()
							EndDo

						Else

							EvalTrigger()

							While ( GetSX8Len() > nSaveSX8 )
								ConFirmSX8()
							EndDo

						EndIf

					EndIf

					If ExistBlock("MT120GOK")
						Execblock("MT120GOK",.F.,.F.,{cA120Num,l120Inclui,l120Altera,l120Deleta})
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Envia os dados para o modulo contabil             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lCtbOnLine
						RodaProva(nHdlPrv,nTotalCtb)
						If nTotalCtb > 0
							If ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() )
								cCodDiario := CTBAVerDia() 
								aCtbDia := {{"SC7",SC7->(RECNO()),cCodDiario,"C7_NODIA","C7_DIACTB"}}
							Else
							    aCtbDia := {}
							EndIf    
							cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,,,aCtbDia)
						EndIf
					EndIf

				EndIf	
			
			ElseIf l120Altera .or. l120Deleta

				//******************************
				// Recriar aprovação do pedido *
				//******************************
								
				PcoIniLan("000055")
				For nX:=1 to Len(aCols)
	
					If aCols[nX][Len(aHeader)] >0

						dbSelectArea("SC7")
						MsGoto(aCols[nX][Len(aHeader)])
						If SC7->C7_CONAPRO=="L"
							PcoDetLan('000055','01','MATA097')
						EndIf
					
					EndIf
				
				Next
				
				//******************************
				// Recriar aprovação do pedido *
				//******************************
				
				If aCols[1][Len(aHeader)] >0
					dbSelectArea("SC7")
					MsGoto(aCols[1][Len(aHeader)])
					If SC7->C7_CONAPRO=="L"
						PcoDetLan('000055','02','MATA097')
					EndIf
				EndIf
					
			EndIf
            	 	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nTipoPed != 2
				PcoFinLan("000052")
			Else
				PcoFinLan("000053")
			EndIf
			If l120Altera .or. l120Deleta
				PcoFinLan("000055")
			EndIf
		EndIf
	EndIf

    If cPaisLoc $ "BRA|ANG|MEX" .and. nOpcA==0 .and. cCondPAdt="1" .and. nOpcx <> 4         
       FPedAdtGrv("P", 2, cA120Num , aRecnoSE2RA,,,,aAdtPC,nOpcAdt)
    Endif
	SetKey( VK_F4,Nil )
	SetKey( VK_F5,Nil )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Libera os bloqueios do SIGAPCO que nao foram efetivados   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipoPed != 2
		PcoFreeBlq("000052",,,,,(l120Altera.And.nOpca!=1)/*lCancela*/)	
	Else
		PcoFreeBlq("000053",,,,,(l120Altera.And.nOpca!=1)/*lCancela*/)	
	EndIf
	
	PcoFreeBlq("000055",,,,,(l120Altera.And.nOpca!=1)/*lCancela*/)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Destrava os registros na aletaracao e exclusao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ( GetSX8Len() > nSaveSX8 )
		RollBackSX8()
	EndDo

	MsUnLockAll()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Destrava os registros utilizados na funcao A120PID        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(aA120PID) == "A" .And. Len(aA120PID) > 0
		For nX := 1 to Len(aA120PID)			
			If nTipoPed != 2
				SC1->(MsGoto(aA120PID[nx]))
				If SimpleLock("SC1")		
					SC1->(MsRUnlock())
				Endif
			Else
				SC3->(MsGoto(aA120PID[nx]))
				If SimpleLock("SC3")		
					SC3->(MsRUnlock())
				Endif				
			Endif	
		Next nX
	Endif	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza o uso das funcoes MATXFIS                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisEnd()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Libera chaves obtidas por FreeForUse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQuery .And. Type( "bFiltraBRW" ) == "B" .And. Empty( SC7->( dbFilter() ) )
		Eval( bFiltraBRW )
		SC7->( dbSetOrder( 1 ) )
	EndIf

	FreeUsedCode()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto no final da rotina, para o usuario completar algum processo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("MT120FIM")
		Execblock("MT120FIM",.F.,.F.,{aRotina[nOpcX,4], cA120Num,nOpcA})
	EndIf

EndIf 

RestArea(aArea)
RestArea(aAreaSM0)    

Return(nOpcA) 


