#INCLUDE "RWMAKE.CH"                                                                                   
#INCLUDE "TOPCONN.CH"                                                                                                                     
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#include "TBICODE.CH"
#include 'Ap5Mail.ch' 

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 12/04/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM004                                  -
----------------------------------------------------------------------------------------
                     FUNÇÃO PARA MONTAGEM DA TELA DE APROVAÇÃO DE PC                   -
--------------------------------------------------------------------------------------*/ 

**************************************
User Function TPCOM004()
**************************************

Local oVerde    := LoadBitmap(GetResources(),'BR_VERDE')    
Local oVermelho := LoadBitmap(GetResources(),'BR_VERMELHO') 
Local oAzul     := LoadBitmap(GetResources(),'BR_AZUL')
Private aResolu := getScreenRes()
Private nTotReg := 0
Private aBrowse := {}
Private nVlMed  := 0
Private oBrowse
Private cUserID := __CUSERID
Private cAprov  := 'S'
Private cGetdados := 'S'
Private aCol      := {}
Private aHead     := {}
Private oGetDados := NIL

 aSize := MsAdvSize(.F.)
 /*
 MsAdvSize (http://tdn.totvs.com/display/public/mp/MsAdvSize+-+Dimensionamento+de+Janelas)
 aSize[1] = 1 -> Linha inicial área trabalho.
 aSize[2] = 2 -> Coluna inicial área trabalho.
 aSize[3] = 3 -> Linha final área trabalho.
 aSize[4] = 4 -> Coluna final área trabalho.
 aSize[5] = 5 -> Coluna final dialog (janela).
 aSize[6] = 6 -> Linha final dialog (janela).
 aSize[7] = 7 -> Linha inicial dialog (janela).  */      
                     
DEFINE MSDIALOG oDlg TITLE "Aprovação de Pedido de Compras" FROM aSize[7],0 TO aSize[6],aSize[5] COLORS 0, 16777215 PIXEL

oDlg:bInit := {||EnchoiceBar(oDlg,{||oDlg:End()},{|| oDlg:End()},,)}

IF(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1280
oBrowse := TCBrowse():New( 30 , 2, aSize[5] - 951, aSize[6] - 487,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
ELSE
oBrowse := TCBrowse():New( 30 , 2, aSize[5] - 674, aSize[6] - 329,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
ENDIF
	
	Processa( {|| U_TPCOM4C()}, "Carregando Pedidos", "Aguarde...",.F.) // SELEÇÃO PEDIDO DE COMPRAS 
                      
// DUPLO CLIQUE 

 oBrowse:bLDblClick := {|| U_TPCOM4A()}
 oBrowse:Refresh()  // Evento de duplo click na celula 
 
 // MUDAR A COR DA LINHA DO BROWSER  

oBrowse:lUseDefaultColors := .F.
//bColor := GETDCLR(oBrowse:nAt)
oBrowse:SetBlkBackColor({|| IIF(aBrowse[oBrowse:nAt,10] == 'Sim', CLR_YELLOW, NIL)})                       

oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
ACTIVATE MSDIALOG oDlg CENTERED


return

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 15/04/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM4A                                   -
----------------------------------------------------------------------------------------
                     FUNÇÃO PARA MONTAGEM DA TELA DOS ITENS DO PC                      -
--------------------------------------------------------------------------------------*/ 

**************************************
User Function TPCOM4A()
**************************************

Local _cTotalNF   := '' 
Private oDlg1		
Private _cTotalNF := 0
Private oButton1, oButton2, oButton3, oButton4, oButton5, oButton6
Private oFont3    := TFont():New("Arial",,016,,.T.,,,,,.F.,.F.)
Private cPedido   := ''
Private oFont14n  := TFont():New("Arial",,014,.T.,.T.,,.T.,,.T.,.F.)
Private oFont18n  := TFont():New("Arial",,018,.T.,.T.,,.T.,,.T.,.F.)
Private oFont24n  := TFont():New("Arial",,024,.T.,.T.,,.T.,,.T.,.F.)
Private cObs      := 'N'
Private nAy       := 0
Private lFecha    := .F.
Private lHistorico := .F.  

If Type('oGetDados') == 'O'
 nAy := oGetDados:nAt
Else
 nAy := 1
Endif   

If(aBrowse[oBrowse:nAt,10] == 'Sim')
TPCOM4J(cObs := 'S')
Endif

    IF(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1280
    DEFINE MSDIALOG oDlg1 TITLE "Itens do Pedido de Compras" FROM C(350),C(100) TO C(890),C(1250)  PIXEL Style DS_MODALFRAME 
    ELSE
    DEFINE MSDIALOG oDlg1 TITLE "Itens do Pedido de Compras" FROM C(350),C(100) TO C(808),C(1140)  PIXEL Style DS_MODALFRAME 
    ENDIF
    
    IF(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080
    @ C(001)  ,C(008) SAY    "PEDIDO:"  SIZE 060,010 OF oDlg1 PIXEL Font oFont18n
    @ C(001)  ,C(035) SAY    aBrowse[oBrowse:nAt,03]  SIZE 060,010 Picture "@!" OF oDlg1 PIXEL Font oFont18n
    @ C(001)  ,C(062) SAY    "FILIAL:"  SIZE 060,010 OF oDlg1 PIXEL Font oFont18n
    @ C(001)  ,C(083) SAY    Alltrim(Substr(aBrowse[oBrowse:nAt,02],14,Len(aBrowse[oBrowse:nAt,02])))  SIZE 100,010 Picture "@!" OF oDlg1 PIXEL Font oFont18n
    @ C(005)  ,C(442) SAY    "TOTAL:"   SIZE 060,010 OF oDlg1 PIXEL Font oFont18n
    @ C(005)  ,C(458) SAY    aBrowse[oBrowse:nAt,04]  SIZE 060,010 Picture "@E 999,999,999.99" OF oDlg1 PIXEL Font oFont18n
    @ C(005)  ,C(499) SAY    "EMISSÃO:"   SIZE 060,010 OF oDlg1 PIXEL Font oFont18n
    @ C(005)  ,C(528) SAY    aBrowse[oBrowse:nAt,11]  SIZE 060,010  OF oDlg1 PIXEL Font oFont18n
    @ C(009)  ,C(008) SAY    "COMPRADOR:"   SIZE 060,010 OF oDlg1 PIXEL Font oFont18n
    @ C(009)  ,C(048) SAY    aBrowse[oBrowse:nAt,12]  SIZE 075,010  OF oDlg1 PIXEL Font oFont18n
    
    
    @ 154, 654 BUTTON oButton1 PROMPT "APROVAR" SIZE 034, 010 OF oDlg1 FONT oFont3 ACTION Eval({|| TPCOM4F(), TPCOM4B(oDlg1,IIF(oBrowse:nAt < Len(aBrowse),;
    oBrowse:nAt:= oBrowse:nAt + 1,Close(oDlg1))),IIF((cAprov == 'S'),TPCOM4E(oDlg1, acolIT := {}),),IIF((cAprov == 'S'),TPCOM4G(),U_TPCOM4C()),oBrowse:Refresh()}) PIXEL
    oButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    @ 154, 691 BUTTON oButton1 PROMPT "PROXIMO" SIZE 034, 010 OF oDlg1 FONT oFont3 ACTION Eval({|| U_TPCOM4Q(lFecha := .T.)})  PIXEL
    oButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
	@ 170, 672 BUTTON oButton2 PROMPT "EXCLUIR" SIZE 034, 010 OF oDlg1 FONT oFont3 ACTION Eval({||TPCOM4I(), U_TPCOM4C(), ;
	IIF(Len(aBrowse) > 0 ,TPCOM4B(oDlg1,IIF(oBrowse:nAt < Len(aBrowse),oBrowse:nAt:= oBrowse:nAt,Close(oDlg1))),NIL),;
	TPCOM4E(oDlg1, acolIT := {}),TPCOM4G(),oBrowse:Refresh(),oBrowse:Gotop()}) PIXEL
	oButton2:SetCSS(	"QPushButton{ background-color: #1E90FF; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
	@ 185, 672 BUTTON oButton3 PROMPT "REVISÃO" SIZE 034, 010 OF oDlg1 FONT oFont3 ACTION Eval({||TPCOM4J()}) PIXEL
	oButton3:SetCSS(	"QPushButton{ background-color: #1E90FF; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
	@ 200, 669 BUTTON oButton4 PROMPT "APROVADOS" SIZE 038, 010 OF oDlg1 FONT oFont3 ACTION Eval({||TPCOM4L()}) PIXEL
	oButton4:SetCSS(	"QPushButton{ background-color: #1E90FF; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
	@ 215, 672 BUTTON oButton5 PROMPT "COTAÇÃO" SIZE 034, 010 OF oDlg1 FONT oFont3 ACTION Eval({||U_TPCOM005(), oBrowse:Refresh()}) PIXEL
	oButton5:SetCSS(	"QPushButton{ background-color: #1E90FF; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
	@ 230, 672 BUTTON oButton6 PROMPT "SAIR" SIZE 034, 010 OF oDlg1 FONT oFont3 ACTION Eval({|| Close(oDlg1), U_TPCOM4C(), oBrowse:Refresh()}) PIXEL
	oButton6:SetCSS(	"QPushButton{ background-color: #CD3300; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    
    ELSE
    @ C(005)  ,C(008) SAY    "PEDIDO:"  SIZE 060,010 OF oDlg1 PIXEL Font oFont18n
    @ C(005)  ,C(035) SAY    aBrowse[oBrowse:nAt,03]  SIZE 060,010 Picture "@!" OF oDlg1 PIXEL Font oFont18n
    @ C(005)  ,C(062) SAY    "FILIAL:"  SIZE 060,010 OF oDlg1 PIXEL Font oFont18n
    @ C(005)  ,C(083) SAY    Alltrim(Substr(aBrowse[oBrowse:nAt,02],14,Len(aBrowse[oBrowse:nAt,02])))  SIZE 100,010 Picture "@!" OF oDlg1 PIXEL Font oFont18n
    @ C(005)  ,C(392) SAY    "TOTAL:"   SIZE 060,010 OF oDlg1 PIXEL Font oFont18n
    @ C(005)  ,C(408) SAY    aBrowse[oBrowse:nAt,04]  SIZE 060,010 Picture "@E 999,999,999.99" OF oDlg1 PIXEL Font oFont18n
    @ C(005)  ,C(449) SAY    "EMISSÃO:"   SIZE 060,010 OF oDlg1 PIXEL Font oFont18n
    @ C(005)  ,C(478) SAY    aBrowse[oBrowse:nAt,11]  SIZE 060,010  OF oDlg1 PIXEL Font oFont18n 
    @ C(005)  ,C(143) SAY    "COMPRADOR:"   SIZE 060,010 OF oDlg1 PIXEL Font oFont18n
    @ C(005)  ,C(185) SAY    aBrowse[oBrowse:nAt,12]  SIZE 075,010  OF oDlg1 PIXEL Font oFont18n
       
	@ 154, 589 BUTTON oButton1 PROMPT "APROVAR" SIZE 034, 010 OF oDlg1 FONT oFont3 ACTION Eval({|| TPCOM4F(), TPCOM4B(oDlg1,IIF(oBrowse:nAt < Len(aBrowse),;
    oBrowse:nAt:= oBrowse:nAt + 1,Close(oDlg1))),IIF((cAprov == 'S'),TPCOM4E(oDlg1, acolIT := {}),),IIF((cAprov == 'S'),TPCOM4G(),U_TPCOM4C()),oBrowse:Refresh()}) PIXEL
    oButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    @ 154, 626 BUTTON oButton1 PROMPT "PROXIMO" SIZE 034, 010 OF oDlg1 FONT oFont3 ACTION Eval({|| U_TPCOM4Q(lFecha := .T.)}) PIXEL
    oButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
	@ 170, 607 BUTTON oButton2 PROMPT "EXCLUIR" SIZE 034, 010 OF oDlg1 FONT oFont3 ACTION Eval({||TPCOM4I(), U_TPCOM4C(), ;
	IIF(Len(aBrowse) > 0 ,TPCOM4B(oDlg1,IIF(oBrowse:nAt < Len(aBrowse),oBrowse:nAt:= oBrowse:nAt,Close(oDlg1))),NIL),;
	TPCOM4E(oDlg1, acolIT := {}),TPCOM4G(),oBrowse:Refresh(),oBrowse:Gotop()}) PIXEL
	oButton2:SetCSS(	"QPushButton{ background-color: #1E90FF; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
	@ 185, 607 BUTTON oButton3 PROMPT "REVISÃO" SIZE 034, 010 OF oDlg1 FONT oFont3 ACTION Eval({||TPCOM4J()}) PIXEL
	oButton3:SetCSS(	"QPushButton{ background-color: #1E90FF; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
	@ 200, 604 BUTTON oButton4 PROMPT "APROVADOS" SIZE 038, 010 OF oDlg1 FONT oFont3 ACTION Eval({||TPCOM4L()}) PIXEL
	oButton4:SetCSS(	"QPushButton{ background-color: #1E90FF; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
	@ 215, 607 BUTTON oButton5 PROMPT "COTAÇÃO" SIZE 034, 010 OF oDlg1 FONT oFont3 ACTION Eval({||U_TPCOM005(), oBrowse:Refresh()}) PIXEL
	oButton5:SetCSS(	"QPushButton{ background-color: #1E90FF; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
	@ 230, 607 BUTTON oButton6 PROMPT "SAIR" SIZE 034, 010 OF oDlg1 FONT oFont3 ACTION Eval({|| Close(oDlg1), U_TPCOM4C(), oBrowse:Refresh()}) PIXEL
	oButton6:SetCSS(	"QPushButton{ background-color: #CD3300; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    ENDIF

  	@ C(111)  ,C(008) SAY    "***Últimas Compras***" SIZE 060,010 OF oDlg1 PIXEL Font oFont14n    
	
		// Chamadas das GetDados do Sistema

	TPCOM4B(oDlg1,oBrowse:nAt)
   	TPCOM4E(oDlg1)
   	TPCOM4G()
	
ACTIVATE MSDIALOG oDlg1 CENTERED
If(lFecha == .T.)
 If(lHistorico == .T.) .And. oBrowse:nAt <= Len(aBrowse)
 U_TPCOM4A(IIF (oBrowse:nAt < Len(aBrowse),oBrowse:nAt:= oBrowse:nAt ,)) 
 Else
  if (oBrowse:nAt < Len(aBrowse))
  U_TPCOM4A(IIF (oBrowse:nAt < Len(aBrowse),oBrowse:nAt:= oBrowse:nAt + 1 ,))
  endif
 Endif
Endif
oBrowse:Refresh()
Return()      

****************************************
Static  Function TPCOM4B(oDlg1,nN)
****************************************
// Variaveis deste Form                                                                                                         
Local nX			:= 0
Local cItem         := 00                                                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Vetor responsavel pela montagem da aHeader
Local aCpoGDa      	:= {}                                                                                                 
// Vetor com os campos que poderao ser alterados                                                                                      
Local nSuperior    	:= C(004)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= C(004)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= C(047)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= C(215)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
                                                                                                   
// Objeto no qual a MsNewGetDados sera criada                                      
Local oWnd         	:= oDlg1                                                                                                                      

Local _area      := getarea()

aCol      := {}
aHead     := {}
oGetdados := NIL                                                                       

aCpoGDa    := {"C7_ITEM","C7_PRODUTO","C7_DESCRI","C7_ZMARCOD","C7_ZAPLIC","C7_QUANT","C7_PRECO","C7_TOTAL","A2_NOME","C7_ZOBSADI","C7_OBS","C7_UM","C7_NUMCOT"}
                                                                                                                                
// Carrega aHead                                                                                                                
DbSelectArea("SX3")                                                                                                             
SX3->(DbSetOrder(2)) // Campo                                                                                                   
For nX := 1 to Len(aCpoGDa)                                                                                                     
	If SX3->(DbSeek(aCpoGDa[nX]))                                                                                                 
		Aadd(aHead,{ IIF(AllTrim(X3Titulo()) == 'Razão Social',"Fornecedor",AllTrim(X3Titulo())),;                                                                                         
			SX3->X3_CAMPO	,;                                                                                                       
			SX3->X3_PICTURE ,;                                                                                                       
			IIF(aCpoGDa[nX] == 'C7_DESCRI',35,IIF(aCpoGDa[nX] == 'C7_PRODUTO' .OR. aCpoGDa[nX] == 'C7_ZMARCOD' .OR. aCpoGDa[nX] == 'C7_ZAPLIC',3,SX3->X3_TAMANHO)) ,;                                                                                                       
			SX3->X3_DECIMAL ,;                                                                                                       
			SX3->X3_VALID   ,;                                                                                                       
			SX3->X3_USADO	,;                                                                                                       
			SX3->X3_TIPO	,;                                                                                                       
			SX3->X3_F3 		,;                                                                                                       
			SX3->X3_CONTEXT})  
			                                                                                                   
	Endif                                                                                                                         
Next nX                                                                                                                         


// Carregue aqui a Montagem da sua aCol                                                                                         
aAux := {}                          
For nX := 1 to Len(aCpoGDa)         
	If DbSeek(aCpoGDa[nX])             
	   	Aadd(aAux,CriaVar(SX3->X3_CAMPO))
	Endif                              
Next nX 

cQuery := " SELECT C7_ITEM, B1_COD, B1_DESC, C7_ZMARCOD, C7_ZAPLIC, C7_UM, C7_QUANT, C7_PRECO, C7_TOTAL, C7_ZOBSADI, C7_OBS, A2_NOME, C7_NUMCOT  " 
cQuery += "  FROM " + RetSqlName("SC7") + " SC7 "
cQuery += "   INNER JOIN  " + RetSqlName('SA2') + " SA2  ON A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.D_E_L_E_T_ = '' " 
cQuery += "   INNER JOIN  " + RetSqlName('SB1') + " SB1  ON B1_COD = C7_PRODUTO AND SB1.D_E_L_E_T_ = '' " 
cQuery += "    WHERE C7_FILIAL  = '"+IIF(oBrowse:nAt > Len(aBrowse),aBrowse[oBrowse:nAt-1,01],aBrowse[oBrowse:nAt,01])+"' "
cQuery += "     AND   C7_NUM    = '"+IIF(oBrowse:nAt > Len(aBrowse),aBrowse[oBrowse:nAt-1,03],aBrowse[oBrowse:nAt,03])+"' "
cQuery += "     AND   C7_CONAPRO    = 'B' "
cQuery += "      AND SC7.D_E_L_E_T_ = '' " 
cQuery += "       ORDER BY C7_ITEM "                          

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP", .T., .T.) 

If(TMP->(EOF())) 
MsgInfo("Aprovação finalizada")
Close(oDlg1) 
cAprov := 'N'
TMP ->(dbCloseArea())
return .T.
Endif  

TMP->(dbGoTop()) 
While(!TMP->(EOF())) 

  	AAdd(aCol, {TMP->C7_ITEM, TMP->B1_COD, Alltrim(TMP->B1_DESC),Alltrim(TMP->C7_ZMARCOD), Alltrim(TMP->C7_ZAPLIC),TMP->C7_QUANT, TMP->C7_PRECO, TMP->C7_TOTAL, TMP->A2_NOME,TMP->C7_ZOBSADI, TMP->C7_OBS, TMP->C7_UM, TMP->C7_NUMCOT ,.F.})	           

  	TMP->(dbskip())
  	
EndDo                                                                                                               

TMP ->(dbCloseArea())

restArea(_area)
                                                                       
IF(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1280
oGetDados  := MsNewGetDados():New(20,00,140,739,,,,,,,9999,,,,oWnd,aHead, aCol)  // ITENS PEDIDO DE COMPRAS 
ELSE
oGetDados  := MsNewGetDados():New(20,00,140,669,,,,,,,9999,,,,oWnd,aHead, aCol)  // ITENS PEDIDO DE COMPRAS 
ENDIF
//oGetDados:oBrowse:nAt := 1
oGetDados:oBrowse:bLDblClick := {|| U_TPCOM4Q(lFecha := .T.,acolIT := {}, lHistorico := .T.),TPCOM4G()}
oGetDados:refresh()
                                                                                                             
Return Nil

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 17/04/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM4C                                   -
----------------------------------------------------------------------------------------
                    FUNÇÃO PARA SELEÇÃO DO PEDIDO DE COMPRAS PENDENTE                   -
--------------------------------------------------------------------------------------*/ 

**************************************
User Function TPCOM4C()
**************************************

Local cQuery   := ''
Local cTabDoc  := GetNextAlias()
Local cUser    
Local cCompra                           

aBrowse := {}
//DbSelectArea("TRB")
//TRB->(__DBZAP()) // Limpa a tabela temporaria.

cQuery += Chr(13)+" SELECT DISTINCT CR_FILIAL AS FILIAL, CR_NUM AS NUM, CR_USER AS USUARIO, CR_TIPO AS TIPO, CR_TOTAL AS TOTAL " 
cQuery += Chr(13)+" FROM "+RetSqlName("SCR")+" SCR "	
cQuery += Chr(13)+" INNER JOIN " + RetSqlName("SC7") + " SC7 ON C7_FILIAL = CR_FILIAL AND C7_NUM = CR_NUM AND SC7.D_E_L_E_T_ = '' "                                      
cQuery += Chr(13)+" WHERE SCR.D_E_L_E_T_ <> '*' "
cQuery += Chr(13)+" AND CR_USER = '"+cUserID+"' "
cQuery += Chr(13)+" AND CR_STATUS IN ('02') "
cQuery += Chr(13)+" AND C7_CONAPRO = 'B' "
cQuery += Chr(13)+" AND C7_ENCER <> 'E' "	
cQuery += Chr(13)+" ORDER BY 1,2 "     
	
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabDoc,.F.,.F.)

(cTabDoc)->(DbGoTop())

If((cTabDoc)->(EOF())) 
aAdd(aBrowse, {'','','',0,'','','','','', 'Nao','',''})
Endif                                   
	
Do While (cTabDoc)->(!Eof())
		
   	nVlrLiq:= TPCOM4D((cTabDoc)->FILIAL,(cTabDoc)->NUM)
		
	SC7->(DbSetorder(01))
	SC7->(DbSeek((cTabDoc)->FILIAL+AvKey((cTabDoc)->NUM,'C7_NUM')))
	SC1->(DbSetOrder(01))
	SC1->(DbSeek((cTabDoc)->FILIAL+SC7->C7_NUMSC+SC7->C7_ITEMSC))
	SY1->(DbSetorder(03))
	SY1->(DbSeek(xFilial('SY1')+AvKey(SC7->C7_USER,'Y1_USER')))						
		
	/*Valida classificação da SC*/
	If SC1->C1_ZCLASSI == '1'
		cClassi:='Equipamento Parado'
	ElseIf SC1->C1_ZCLASSI == '2'
		cClassi:='Manutencao Corretiva'
	ElseIf SC1->C1_ZCLASSI == '3'
		cClassi:='Manutencao Preventiva'
	ElseIf SC1->C1_ZCLASSI == '4'
		cClassi:='Compra para Estoque'
	ElseIf SC1->C1_ZCLASSI == '5'
		cClassi:='Uso e Consumo'	
	Endif				
    
    nTotReg ++
    cUser    := Posicione("SC7",1,(cTabDoc)->FILIAL+Alltrim((cTabDoc)->NUM),"C7_USER")
    cCompra  := UsrRetName(cUser)
    aAdd(aBrowse, {(cTabDoc)->FILIAL,FWFilialName(,(cTabDoc)->FILIAL,2),Alltrim((cTabDoc)->NUM),nVlrLiq,SC7->C7_NUMSC,SC7->C7_NUMCOT,SY1->Y1_NOME, cClassi,;
     SC7->C7_ZOBSADI, IIF(Posicione("SC7",1,(cTabDoc)->FILIAL+Alltrim((cTabDoc)->NUM),"C7_TPOKMSG") == '2','Sim','Nao'), SC7->C7_EMISSAO,cCompra}) 

   (cTabDoc)->(DbSkip())

EndDo 

   (cTabDoc)->(DbCloseArea())
   
   	If nTotReg == 0 
	 	MsgAlert(OemTOAnsi('Não existem pedidos a serem exibidos!!'))
	 	Return .T.
 	Endif
   
   	U_TPCOM4H() // MONTAGEM COLUNAS TCBROWSE
     
Return()

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 17/04/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM4D                                   -
----------------------------------------------------------------------------------------
                            FUNÇÃO PARA BUSCAR TOTAL DO PC                             -
--------------------------------------------------------------------------------------*/  

*****************************************************
Static Function TPCOM4D(cFilPC, cNumPC)
*****************************************************

Local nVlPedLiq	:= 0  
Local cQuery	:= ''
Local aPrefSom	:= GetNextAlias()
	
	cQuery+="SELECT SUM((C7_TOTAL+C7_VALFRE+C7_VALIPI ) - C7_VLDESC) AS TOTAL "
	cQuery+="FROM "+RetSqlName('SC7')+ " "
	cQuery+="WHERE C7_FILIAL = '"+cFilPC+"' "
	cQuery+="AND C7_NUM = '"+AllTrim(cNumPC)+"' "
	cQuery+="AND D_E_L_E_T_ <> '*'  "
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),aPrefSom,.F.,.F.) 
	
	(aPrefSom)->(DbGoTop())
	/*Recebe o valor total do PC*/
	nVlPedLiq:= (aPrefSom)->TOTAL
	/*Fecha tabela temporaria*/
	(aPrefSom)->(DbCloseArea())
		                         
Return(nVlPedLiq)
   
****************************************
Static  Function TPCOM4E(oDlg1)
****************************************
// Variaveis deste Form                                                                                                         
Local nX			:= 0
Local cItem         := 00                                                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Vetor responsavel pela montagem da aHeader
Local aCpoGDa      	:= {}                                                                                                 
// Vetor com os campos que poderao ser alterados                                                                                      
Local nSuperior    	:= C(004)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= C(004)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= C(047)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= C(215)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
Local _area         := getarea()
Private oWnd        := oDlg1
Private acolIT      := {}
Private aHeadIT     := {}
Private oGetDados2                                                                                    

// Objeto no qual a MsNewGetDados sera criada
oTFont := TFont():New('Courier new',,16,.T.)
oPanel:= TPanel():New(500,300,"Histórico de Compras",oDlg1,oTFont,.T.,,,,100,100)                                                                                                                                                          
                                                                      
aCpoGDa    := {"C7_NUM","C7_PRODUTO","A2_NOME","C7_ZMARCOD","C7_ZAPLIC","C7_QUANT","C7_PRECO","C7_TOTAL","C7_EMISSAO","C7_USER","C7_ZOBSADI","C7_OBS"}
                                                                                                                                
// Carrega aHeadIT                                                                                                                
DbSelectArea("SX3")                                                                                                             
SX3->(DbSetOrder(2)) // Campo                                                                                                   
For nX := 1 to Len(aCpoGDa)                                                                                                     
	If SX3->(DbSeek(aCpoGDa[nX]))                                                                                                 
		Aadd(aHeadIT,{ IIF(AllTrim(X3Titulo()) == 'Cod. Usuario',"Comprador",IIF(AllTrim(X3Titulo()) == 'Razão Social',"Fornecedor",AllTrim(X3Titulo()))),;                                                                                         
			SX3->X3_CAMPO	,;                                                                                                       
			SX3->X3_PICTURE ,;
			IIF (AllTrim(X3Titulo()) == 'Razão Social',32,(IIF (AllTrim(X3Titulo()) == 'Aplicacao' .OR. AllTrim(X3Titulo()) == 'Marca/Codigo' .OR. AllTrim(X3Titulo()) == 'Produto' .OR. AllTrim(X3Titulo()) == 'Comprador',10,SX3->X3_TAMANHO))),;	                                                                                                                                                                                                            
			SX3->X3_DECIMAL ,;                                                                                                       
			SX3->X3_VALID   ,;                                                                                                       
			SX3->X3_USADO	,;                                                                                                       
			SX3->X3_TIPO	,;                                                                                                       
			SX3->X3_F3 		,;                                                                                                       
			SX3->X3_CONTEXT})  
			                                                                                                   
	Endif                                                                                                                         
Next nX                                                                                                                         

// Carregue aqui a Montagem da sua aCol                                                                                         
aAux := {}                          
For nX := 1 to Len(aCpoGDa)         
	If DbSeek(aCpoGDa[nX])             
	   	Aadd(aAux,CriaVar(SX3->X3_CAMPO))
	Endif                              
Next nX 

cQuery := " SELECT TOP(25) C7_NUM, C7_PRODUTO, A2_NOME, C7_ZMARCOD, C7_ZAPLIC, C7_QUANT, C7_PRECO, C7_TOTAL, CONVERT(varchar, CONVERT(DATETIME, C7_EMISSAO), 103) AS EMISSAO,"
cQuery += " C7_USER, C7_ZOBSADI, C7_OBS  " 
cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
cQuery += " INNER JOIN  " + RetSqlName('SA2') + " SA2 ON A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.D_E_L_E_T_ = '' " 
cQuery += " WHERE C7_PRODUTO = '"+IIF(Len(aCol) > 0,aCol[nAy][2],'')+"' " 
cQuery += " AND C7_NUM <> '"+IIF(oBrowse:nAt > Len(aBrowse),aBrowse[oBrowse:nAt-1,03],aBrowse[oBrowse:nAt,03])+"' " 
cQuery += " AND C7_FILIAL = '"+IIF(oBrowse:nAt > Len(aBrowse),aBrowse[oBrowse:nAt-1,01],aBrowse[oBrowse:nAt,01])+"' " 
cQuery += " AND SC7.D_E_L_E_T_ = '' " 
cQuery += " ORDER BY C7_EMISSAO DESC "                          

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP", .T., .T.)

If(TMP->(EOF()))
AAdd(aColIT, {'', '', '','','',0, 0, 0, '','','','',.F.})
Endif    
acolIT     := {}
oGetDados2 := NIL

TMP->(dbGoTop()) 
While(!TMP->(EOF())) 

	AAdd(aColIT, {TMP->C7_NUM, TMP->C7_PRODUTO, TMP->A2_NOME, TMP->C7_ZMARCOD, TMP->C7_ZAPLIC, TMP->C7_QUANT, TMP->C7_PRECO, TMP->C7_TOTAL, TMP->EMISSAO,;
  	UsrRetName(TMP->C7_USER), TMP->C7_ZOBSADI, TMP->C7_OBS,.F.})
    nVlMed := (nVlMed + TMP->C7_PRECO)
    TMP->(dbskip())
EndDo                                                                                                                
   nVlMed := nVlMed / Len(aColIT) // PREÇO MÉDIO
    
TMP ->(dbCloseArea())

restArea(_area)

IF(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1280
oGetDados2  := MsNewGetDados():New(150,00,345,640,,,,,,,9999,,,,oWnd,aHeadIT, aColIT )  // HISTORICO PRODUTOS
ELSE
oGetDados2  := MsNewGetDados():New(150,00,292,580,,,,,,,9999,,,,oWnd,aHeadIT, aColIT )  // HISTORICO PRODUTOS
ENDIF
oGetDados2:oBrowse:nAt := 1
oGetDados2:refresh()
                                                                                                           
Return Nil

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 26/04/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM4F                                   -
----------------------------------------------------------------------------------------
                       FUNÇÃO PARA APROVAÇÃO DO PEDIDO DE COMPRAS                      -
--------------------------------------------------------------------------------------*/ 

*********************************
Static Function TPCOM4F()
*********************************

Local cFilPed := IIF(oBrowse:nAt > Len(aBrowse),aBrowse[oBrowse:nAt-1,01],aBrowse[oBrowse:nAt,01])
Local cNumPed := IIF(oBrowse:nAt > Len(aBrowse),aBrowse[oBrowse:nAt-1,03],aBrowse[oBrowse:nAt,03])
Local cLock   := 'N'

	dbSelectArea("SC7") // APROVAR PEDIDO DE COMPRAS SC7
	dbSetOrder(1)
	dbSeek(cFilPed+cNumPed)
	 While !Eof() .And. SC7->C7_FILIAL+SC7->C7_NUM == cFilPed+cNumPed
	  If RLock( recno() )
		  RecLock("SC7",.F.)   
		   SC7->C7_CONAPRO := "L"
		  MsUnlock()
		  cLock := 'S'
	  Endif	  
	  SC7->(dbSkip())
	 EndDo
	 
	 ///////////////TABELA SCR DE APROVAÇÃO//////////////
	  If (cLock == 'S')  
	 	dbSelectArea("SCR")
	 	dbSetOrder(1)
		dbSeek(cFilPed+'PC'+cNumPed)
		While !Eof() .And. (SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == cFilPed+cNumPed)
			Reclock("SCR",.F.)
				CR_STATUS	:= If(SCR->CR_USER == __CUSERID,"03","05")
				CR_DATALIB	:= date()
				CR_USERLIB	:= __CUSERID
				CR_LIBAPRO	:= If(SCR->CR_USER == __CUSERID,Posicione("SAK",2,Substr(cFilPed,1,4)+SPACE(02)+__CUSERID,"AK_COD"),'')
				CR_VALLIB	:= If(SCR->CR_USER == __CUSERID,SCR->CR_TOTAL,0)
				CR_TIPOLIM	:= If(SCR->CR_USER == __CUSERID,"D"," ")
			MsUnlock()	  
	     SCR->(dbSkip())
	    EndDo	
	  Else	 
		MsgInfo("O Pedido"+' '+cNumPed+' '+"está sendo alterado pelo Comprador e não poderá ser aprovado.", "TOPMIX")
	  Endif		   
return

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 25/04/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM4G                                   -
----------------------------------------------------------------------------------------
                          FUNÇÃO PARA ALTERAR OBJETO DE PREÇO                          -
--------------------------------------------------------------------------------------*/ 

*********************************
Static Function TPCOM4G()
*********************************

Local _cTotalNF := ''

 _cTotalNF := IIF(Len(aCol) > 0, aCol[nAy][8], 0)

If (_cTotalNF <= nVlMed)
@ C(004)  ,C(250) SAY    "PREÇO:"   SIZE 060,010 COLOR CLR_HBLUE OF oDlg1 PIXEL Font oFont18n  
Else
@ C(004)  ,C(250) SAY    "PREÇO:"   SIZE 060,010 COLOR CLR_HRED OF oDlg1 PIXEL Font oFont18n  
Endif
@ C(004)  ,C(277) MSGET  _cTotalNF  SIZE 070,08 Picture "@E 999,999,999.99" OF oDlg1 PIXEL Font oFont18n
nVlMed := 0

return

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 26/04/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM4H                                   -
----------------------------------------------------------------------------------------
                      FUNÇÃO PARA MONTAGEM DAS COLUNAS NO TCBROWSE                     -
--------------------------------------------------------------------------------------*/ 

*********************************
User Function TPCOM4H()
*********************************

If (len(aBrowse) == 0)
Close(oDlg)
return()
Endif
oBrowse:nAt := 1
oBrowse:SetArray(aBrowse)

 // Cria colunas 
 oBrowse:AddColumn(TCColumn():New("Filial" ,       {||aBrowse[oBrowse:nAt,01] },,,,"LEFT",,.F.,.F.,,,,,)) 
 oBrowse:AddColumn(TCColumn():New("Nome Filial" ,  {||Substr(aBrowse[oBrowse:nAt,02],6,Len(aBrowse[oBrowse:nAt,02])) },,,,"LEFT",,.F.,.F.,,,,,))
 oBrowse:AddColumn(TCColumn():New("Pedido",        {||aBrowse[oBrowse:nAt,03] },,,,"LEFT",,.F.,.F.,,,,,)) 
 oBrowse:AddColumn(TCColumn():New("Total" ,        {||aBrowse[oBrowse:nAt,04] },"@E 99,999,999.99",,,"LEFT",,.F.,.F.,,,,,)) 
 oBrowse:AddColumn(TCColumn():New("Solicitação" ,  {||aBrowse[oBrowse:nAt,05] },,,,"LEFT",,.F.,.F.,,,,,))
 oBrowse:AddColumn(TCColumn():New("Cotação"   ,    {||aBrowse[oBrowse:nAt,06] },,,,"LEFT",,.F.,.F.,,,,,)) 
 oBrowse:AddColumn(TCColumn():New("Nome Comprador",{||aBrowse[oBrowse:nAt,07] },,,,"LEFT",,.F.,.F.,,,,,)) 
 oBrowse:AddColumn(TCColumn():New("Classificação" ,{||aBrowse[oBrowse:nAt,08] },,,,"LEFT",,.F.,.F.,,,,,))
 oBrowse:AddColumn(TCColumn():New("Observação" ,   {||aBrowse[oBrowse:nAt,09] },,,,"LEFT",,.F.,.F.,,,,,))
 oBrowse:AddColumn(TCColumn():New("Possui Msg" ,   {||aBrowse[oBrowse:nAt,10] },,,,"LEFT",,.F.,.F.,,,,,))
 oBrowse:AddColumn(TCColumn():New("Emissão" ,      {||aBrowse[oBrowse:nAt,11] },,,,,,.F.,.F.,,,,,))
 
Return

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 26/04/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM4I                                   -
----------------------------------------------------------------------------------------
                       FUNÇÃO PARA EXCLUSÃO DO PEDIDO DE COMPRAS                       -
--------------------------------------------------------------------------------------*/ 

*********************************
Static Function TPCOM4I()
*********************************

Local cFilPed   := IIF(oBrowse:nAt > Len(aBrowse),aBrowse[oBrowse:nAt-1,01],aBrowse[oBrowse:nAt,01])
Local cLock     := 'N'
Private cNumPed := IIF(oBrowse:nAt > Len(aBrowse),aBrowse[oBrowse:nAt-1,03],aBrowse[oBrowse:nAt,03])
Private cUser 
  
  If (MSGYESNO( "Deseja excluir o pedido"+' '+cNumPed+' '+"?", "EXCLUSÃO" ))
	dbSelectArea("SC7") // APROVAR PEDIDO DE COMPRAS SC7
	dbSetOrder(1)
	dbSeek(cFilPed+cNumPed)
	cUser := SC7->C7_USER
	TPCOM4O(cUser,cNumPed)
		 While !Eof() .And. SC7->C7_FILIAL+SC7->C7_NUM == cFilPed+cNumPed
		  If RLock( recno() )
			  RecLock("SC7",.F.)   
			   dbdelete()
			  MsUnlock()
			  cLock   := 'S'
		  Endif	  
		  SC7->(dbSkip())
		 EndDo

	 ///////////////TABELA SCR DE APROVAÇÃO//////////////
	  If(cLock == 'S') 
	 	dbSelectArea("SCR")
	 	dbSetOrder(1)
		dbSeek(cFilPed+'PC'+cNumPed)
		While !Eof() .And. (SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == cFilPed+cNumPed)
			Reclock("SCR",.F.)
	        dbdelete()
			MsUnlock()	  
	     SCR->(dbSkip())
	    EndDo
	    MsgInfo("O Pedido"+' '+cNumPed+' '+" foi excluído.","TOPMIX")  
      Elseif (cLock == 'N') 
       	MsgInfo("O Pedido"+' '+cNumPed+' '+"está sendo alterado pelo Comprador e não poderá ser excluído.","TOPMIX")
      Endif
  Endif
  
//ENVIAR EMAIL()

return 

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 26/04/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM4J                                   -
----------------------------------------------------------------------------------------
                     FUNÇÃO PARA ENVIO DE EMAIL AO COMPRADOR DO PC                 -
--------------------------------------------------------------------------------------*/ 

*********************************
Static Function TPCOM4J()
*********************************

Local aAliasOLD   := GetArea() 
Local oDlg   
Local oGetDescri  
Local oFontTel    := TFont():New("Arial",10,,,.T.,,,,.F.,.F.)
Local cFilPed     := IIF(oBrowse:nAt > Len(aBrowse),aBrowse[oBrowse:nAt-1,01],aBrowse[oBrowse:nAt,01])
Local cNumPed     := IIF(oBrowse:nAt > Len(aBrowse),aBrowse[oBrowse:nAt-1,03],aBrowse[oBrowse:nAt,03])
Private cDescri   := ""
          
If(cObs == 'S')
cDescri := Posicione("SC7",1,cFilPed+Alltrim(cNumPed),"C7_TPMSG")
Endif  
   //Montagem da Tela
   DEFINE MSDIALOG oDlg FROM 000,000 TO 400,700 PIXEL TITLE OemToAnsi("Esclarecimentos - Pedido"+'-'+cNumPed+"." )
   TGroup():New(030,005,195,347,OemToAnsi("Descrição da Mensagem"),oDlg,CLR_HBLUE,,.T.)
   oGetDescri := TMultiGet():New(040,010, {|U| IIf(PCount()==0,cDescri,cDescri:=U )},oDlg,332,150,oFontTel,,,,,.t.,,,,,,)
   oGetDescri:SetFocus()

   Activate MsDialog oDlg Center On Init EnchoiceBar(oDlg,{||fConfirme(oDlg,cDescri)},{||oDlg:End()},,)

RestArea(aAliasOLD)
Return(.T.) 

/* 
Confirmar
*/

*********************************************
Static function fConfirme(oDlg,cDescri) 
*********************************************

Local cNumPed   := aBrowse[oBrowse:nAt,03]
Local cFilPed   := aBrowse[oBrowse:nAt,01]
    
oDlg:End()
If(cObs <> 'S')
 TPCOM4P(cDescri)
 MsgInfo("Email enviado ao Comprador"+' '+aBrowse[oBrowse:nAt,07]+' '+' '+"solicitando esclarecimentos sobre o Pedido de Compras.","TOPMIX")
Else
 	DbSelectArea("SC7")
 	SC7->(DbSetorder(1))
	If SC7->(DbSeek(cFilPed+cNumPed))	// LOCALIZAR RECNO
	    While !Eof() .And. SC7->C7_FILIAL+SC7->C7_NUM == cFilPed+cNumPed
		  If RLock( recno() )
			  RecLock("SC7",.F.)   
			   SC7->C7_TPOKMSG := '1'
			   SC7->C7_TPMSG   := ' '
			  MsUnlock()
		  Else
		  MsgInfo("O Pedido está sendo alterado. Por isso a mensagem continuará ativa.")
		  Endif	  
	    SC7->(dbSkip())
	    EndDo
    Endif
U_TPCOM4C()
oBrowse:Refresh()     
Endif 
Return(.T.)         

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 26/04/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM4L                                   -
----------------------------------------------------------------------------------------
                        FUNÇÃO PARA EXCLUIR PEDIDOS APROVADOS                          -
--------------------------------------------------------------------------------------*/ 

*********************************
Static Function TPCOM4L()
*********************************

Private oDlg1		
Private oGetDados3   
Private aHead  := {}
Private aCol   := {}

DEFINE MSDIALOG oDlg1 TITLE "Pedidos Aprovados"+'-'+DTOC(DATE()) FROM C(510),C(300) TO C(736),C(837) OF oMainWnd PIXEL //Style DS_MODALFRAME 

	@ C(100) ,C(123) Button "Ok" Action Close(oDlg1) Size C(022),C(010) PIXEL OF oDlg1
	
		// Chamadas das GetDados do Sistema
	TPCOM4M(oDlg1)
	
ACTIVATE MSDIALOG oDlg1 CENTERED 

Return()      

****************************************
Static  Function TPCOM4M(oDlg1)
****************************************
// Variaveis deste Form                                                                                                         
Local nX			:= 0
Local cItem         := 00                                                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Vetor responsavel pela montagem da aHeader
Local aCpoGDa      	:= {}                                                                                                 
// Vetor com os campos que poderao ser alterados                                                                                      
Local nSuperior    	:= C(004)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= C(004)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= C(047)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= C(215)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
                                                                                                   
// Objeto no qual a MsNewGetDados sera criada                                      
Local oWnd         	:= oDlg1 

Local _areaSY1      := SY1->(getarea()) 
Local _areaSC7      := SC7->(getarea())                                                                                                                                                                                         

aCpoGDa    := {"C7_FILIAL","A2_NOME","C7_NUM","C7_TOTAL","Y1_NOME"}

                                                                                                                                
// Carrega aHead                                                                                                                
DbSelectArea("SX3")                                                                                                             
SX3->(DbSetOrder(2)) // Campo                                                                                                   
For nX := 1 to Len(aCpoGDa)                                                                                                     
	If SX3->(DbSeek(aCpoGDa[nX]))                                                                                                 
		Aadd(aHead,{ IIF(aCpoGDa[nX] == 'Y1_NOME',"Comprador",AllTrim(X3Titulo())),;                                                                                         
			SX3->X3_CAMPO	,;                                                                                                       
			SX3->X3_PICTURE ,;                                                                                                       
			IIF(aCpoGDa[nX] == 'A2_NOME',10,SX3->X3_TAMANHO) ,;                                                                                                       
			SX3->X3_DECIMAL ,;                                                                                                       
			SX3->X3_VALID   ,;                                                                                                       
			SX3->X3_USADO	,;                                                                                                       
			SX3->X3_TIPO	,;                                                                                                       
			SX3->X3_F3 		,;                                                                                                       
			SX3->X3_CONTEXT})  
			                                                                                                   
	Endif                                                                                                                         
Next nX                                                                                                                         


// Carregue aqui a Montagem da sua aCol                                                                                         
aAux := {}                          
For nX := 1 to Len(aCpoGDa)         
	If DbSeek(aCpoGDa[nX])             
	   	Aadd(aAux,CriaVar(SX3->X3_CAMPO))
	Endif                              
Next nX 

cQuery := " SELECT CR_FILIAL, CR_NUM, CR_TOTAL  " 
cQuery += " FROM " + RetSqlName("SCR") + " SCR "
cQuery += " WHERE CR_DATALIB = '"+DTOS(DATE())+"' "
cQuery += " AND CR_LIBAPRO = '"+Posicione("SAK",2,Substr(aBrowse[oBrowse:nAt,01],1,4)+SPACE(02)+__CUSERID,"AK_COD")+"' "
cQuery += " AND CR_STATUS = '03' "
cQuery += " AND SCR.D_E_L_E_T_ = '' " 
cQuery += " ORDER BY 1,2,3 "                          

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP", .T., .T.) 

TMP->(dbGoTop()) 
While(!TMP->(EOF()))
 	
 	DbSelectArea("SC7")
 	SC7->(DbSetorder(1))
	If SC7->(DbSeek(TMP->CR_FILIAL+Alltrim(TMP->CR_NUM)))	
 	 cUser := SC7->C7_USER
 	Endif
 	
 	DbSelectArea("SY1")
 	SY1->(DbSetorder(3))
	If SY1->(DbSeek(Substr(TMP->CR_FILIAL,1,4)+SPACE(02)+cUser))	
 	 cUser := SY1->Y1_NOME
 	Endif
	AAdd(aCol, {TMP->CR_FILIAL, Alltrim(FWFilialName(,TMP->CR_FILIAL,2)) , TMP->CR_NUM, TMP->CR_TOTAL, cUser ,.F.})	           
  	TMP->(dbskip())
  	
EndDo                                                                                                                

TMP ->(dbCloseArea())

restArea(_areaSC7)
restArea(_areaSY1)                                                                         

oGetDados3:= MsNewGetDados():New(00,00,120,347,,,,,,,9999,,,,oWnd,aHead, aCol )
oGetDados3:oBrowse:nAt := 1
oGetDados3:refresh()

If Len(aCol) > 0
oGetDados3:oBrowse:bLDblClick := {|| TPCOM4N()}
Endif
oBrowse:refresh()
                                                                                                              
return

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 26/04/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM4N                                   -
----------------------------------------------------------------------------------------
                       FUNÇÃO PARA VISUALIZAÇÃO DO PEDIDO APROVADO                     -
--------------------------------------------------------------------------------------*/ 

*********************************
Static Function TPCOM4N()
*********************************

Local cTipPed
Local cLock     := 'N'
Local cNumPed   := Alltrim(acol[oGetDados:oBrowse:nAt][3])
Local cFilPed   := Alltrim(acol[oGetDados:oBrowse:nAt][1])
Local lAprova   := 'N' 
Private aRotina	:= {}
Private cEmpAnt

/*Monta o Menu*/
aAdd(aRotina,{"Pesquisar"   ,"PesqBrw"   , 0, 1, 0, .F. }) //
aAdd(aRotina,{"Visualizar"  ,"A120Pedido", 0, 2, 0, Nil }) //

Private nTipoPed  := 2
Private CCADASTRO := "Pedido de Compras - TOPMIX"
    
	RESET ENVIRONMENT
	cEmpAnt := '01'
	PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilPed MODULO "COM" TABLES "SXE","SXF","SX2","SX3"
	DbSelectArea("SC7")
 	SC7->(DbSetorder(1))
	If SC7->(DbSeek(cFilPed+cNumPed))	// LOCALIZAR RECNO
	 INCLUI := .F.
	 ALTERA := .F. 
 	 A120Pedido('SC7',SC7->(recno()),2)
 	 If (MSGYESNO( "Deseja cancelar a aprovação?", "APROVAÇÃO" ))
        lAprova := 'S'
	    While !Eof() .And. SC7->C7_FILIAL+SC7->C7_NUM == cFilPed+cNumPed
		  If RLock( recno() )
			  RecLock("SC7",.F.)   
			   SC7->C7_CONAPRO := "B"
			  MsUnlock()
			  cLock := 'S'
		  Endif	  
	    SC7->(dbSkip())
	    EndDo
	 Endif
	 
	 ///////////////TABELA SCR DE APROVAÇÃO//////////////
	 
	  If (cLock == 'S')  
	 	dbSelectArea("SCR")
	 	dbSetOrder(1)
		dbSeek(cFilPed+'PC'+cNumPed)
		While !Eof() .And. (SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == cFilPed+cNumPed)
			Reclock("SCR",.F.)
				CR_STATUS	:= '02'
				CR_DATALIB	:= CTOD('//')
				CR_USERLIB	:= ' '
				CR_LIBAPRO	:= ' '
				CR_VALLIB	:= 0
				CR_TIPOLIM	:= ' '
			MsUnlock()	  
	     SCR->(dbSkip())
	    EndDo
	    MsgInfo("Aprovação Cancelada.")	
 	  Elseif(cLock == 'N' .AND. lAprova == 'S')
 	   	MsgInfo("O Pedido"+' '+cNumPed+' '+"está sendo alterado pelo Comprador e não poderá ter a aprovação cancelada.", "TOPMIX")
 	  Endif 
    Endif
    oBrowse:Refresh() 

return()    

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 03/05/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM4O                                   -
----------------------------------------------------------------------------------------
                             FUNÇÃO PARA ENVIO DE EMAIL                                -
--------------------------------------------------------------------------------------*/ 

*********************************
Static Function TPCOM4O(cUser)
*********************************    
*
*
/*
* Envia e-mail - Com autenticao no server
* cConta   : Conta de autenticacao de envio
* cPws     : Senha da conta de autenticacao de envio 
* cFrom    : E-mail de quem esta enviado
* cTo      : E-mail de quem recebera a mensagem
* cSubjetct: Assunto da mensagem
* cBody    : Corpo da mensagem
***/


Local cServer 		:= AllTrim(SuperGetMv("MV_RELSERV"))
Local cAccount 	    := AllTrim(SuperGetMv("MV_RELACNT"))                                                                                                                                     "
Local cEnvia 		:= AllTrim(SuperGetMv("MV_RELACNT"))                                                                                                                                     "
Local cPassword 	:= AllTrim(SuperGetMv("MV_RELPSW"))
Local cMensagem 	:= 'Erro ao enviar o email'
Local lOk 			:= .F.
Local cBody  		:= ""
Local lEnviado      := .T.                          

cRecebe := Posicione("SY1",3,Substr(aBrowse[oBrowse:nAt,01],1,4)+SPACE(02)+cUser,"Y1_EMAIL")
 
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk //realiza conexão com o servidor de internet

	cBody := '<html>'
	cBody += '<head>'
	cBody += '<title> Exclusão de Pedido de Compras </title>'
	cBody += '</head>'
	cBody += '<font size="2" face="Arial">O Pedido de Compras ' +Alltrim(cNumPed)+ ' foi excluído. </font><br><br>'
	cBody += '<font size="2" face="Arial"><strong>Aprovador:'+' '+CUSERNAME+ '</strong></font></b><br><br>'
	cBody += '<font size="2" face="Arial"><strong></strong></font></b><br><br>' 
	cBody += '<font size="2" face="Arial"><strong>Mensagem automática, favor não responder este e-mail.</strong></font></b><br><br>'
    cBody += '<img src="http://topmix.com.br/wp-content/uploads/2017/12/logo-topmix.png">'
	cBody += '</body></html>'
 
	lAutOk := MailAuth(cAccount,cPassword)
 
	If lOk  .AND. lAutOk
 
		SEND MAIL FROM cEnvia TO cRecebe SUBJECT 'Exclusão de Pedido de Compras' BODY cBody RESULT lEnviado

	Else
 
		SEND MAIL FROM cEnvia TO cRecebe SUBJECT 'Exclusão de Pedido de Compras' BODY cBody RESULT lEnviado
 
	Endif
				                                                                 
	DISCONNECT SMTP SERVER
 
 return 
 
 /*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 03/05/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM4O                                   -
----------------------------------------------------------------------------------------
                             FUNÇÃO PARA ENVIO DE EMAIL                                -
--------------------------------------------------------------------------------------*/ 

*********************************
Static Function TPCOM4P(cDescri)
*********************************    
*
*
/*
* Envia e-mail - Com autenticao no server
* cConta   : Conta de autenticacao de envio
* cPws     : Senha da conta de autenticacao de envio 
* cFrom    : E-mail de quem esta enviado
* cTo      : E-mail de quem recebera a mensagem
* cSubjetct: Assunto da mensagem
* cBody    : Corpo da mensagem
***/


Local cServer 		:= AllTrim(SuperGetMv("MV_RELSERV"))
Local cAccount 	    := AllTrim(SuperGetMv("MV_RELACNT"))                                                                                                                                     
Local cEnvia 		:= AllTrim(SuperGetMv("MV_RELACNT"))                                                                                                                                   
Local cPassword 	:= AllTrim(SuperGetMv("MV_RELPSW"))
Local cMensagem 	:= 'Erro ao enviar o email'
Local lOk 			:= .F.
Local cBody  		:= ""
Local lEnviado      := .T.  
Local cFilPed       := IIF(oBrowse:nAt > Len(aBrowse),aBrowse[oBrowse:nAt-1,01],aBrowse[oBrowse:nAt,01])
Local cNumPed       := IIF(oBrowse:nAt > Len(aBrowse),aBrowse[oBrowse:nAt-1,03],aBrowse[oBrowse:nAt,03])
Local cUser         := Posicione("SC7",1,cFilPed+Alltrim(cNumPed),"C7_USER")                          

cRecebe := Posicione("SY1",3,Substr(aBrowse[oBrowse:nAt,01],1,4)+SPACE(02)+cUser,"Y1_EMAIL")
 
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk //realiza conexão com o servidor de internet

	cBody := '<html>'
	cBody += '<head>'
	cBody += '<title> Esclarecimentos sobre Pedido de Compras </title>'
	cBody += '</head>'
	cBody += '<font size="2" face="Arial">' +Alltrim(cDescri)+ '. </font><br><br>'
	cBody += '<font size="2" face="Arial"><strong>Aprovador:'+' '+CUSERNAME+ '</strong></font></b><br><br>'
	cBody += '<font size="2" face="Arial"><strong></strong></font></b><br><br>' 
	cBody += '<font size="2" face="Arial"><strong>Mensagem automática, favor não responder este e-mail.</strong></font></b><br><br>'
    cBody += '<img src="http://topmix.com.br/wp-content/uploads/2017/12/logo-topmix.png">'
	cBody += '</body></html>'
 
	lAutOk := MailAuth(cAccount,cPassword)
 
	If lOk  .AND. lAutOk
 
		SEND MAIL FROM cEnvia TO cRecebe SUBJECT 'Esclarecimentos sobre o Pedido de Compras'+cNumPed+'.' BODY cBody RESULT lEnviado

	Else
 
		SEND MAIL FROM cEnvia TO cRecebe SUBJECT 'Esclarecimentos sobre o Pedido de Compras'+cNumPed+'.' BODY cBody RESULT lEnviado
 
	Endif
				                                                                 
	DISCONNECT SMTP SERVER
 
 return 
 

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                    
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 05/06/2019    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPCOM4Q                                   -
----------------------------------------------------------------------------------------
                            FUNÇÃO FECHAR OBJETO MSDIALOG                              -
--------------------------------------------------------------------------------------*/ 

**************************************
User Function TPCOM4Q()
**************************************
 

oDlg1:end()          


Return       
 