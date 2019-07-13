#Include "PROTHEUS.CH" 
#include "TopConn.ch"   
#include "TOTVS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWSMALLAPPLICATION.CH"                                     
#define BMP_COT				

/*------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                          -                                                    
--------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 13/02/2019  - 
--------------------------------------------------------------------------------------
                                   PROGRAMA: AFATP02                                 -
--------------------------------------------------------------------------------------
                       FUNÇÃO PARA MONTAGEM DO PAINEL DE COMPRAS                     -
-------------------------------------------------------------------------------------*/

*********************************       
User Function AFATP02()          
*********************************

Local oBitmap1
Local oBitmap2
Local oButton1
Local oButton2
Local oButton3
Local oButton4
Local oButton5
Local oButton6
Local oButton7
Local oButton8
Local oButton9
Local oComboBo1
Local oGet1
Local cGet1 := Space(6)
Local oComboBo2
Local oGet2
Local cGet2 := Space(6)
Local oComboBo3
Local oGet3
Local cGet3 := Space(6)
Local oComboBo4
Local oGet4
Local cGet4 := Space(6)
Local oGroup1
Local oSay1
Local oSay2
Local oSButton1 
Local oSButton2
Local nComboBo1 :="Solicitação"
Local nComboBo2 :="Cotação"
Local nComboBo3 :="Pedido"
Local nComboBo4 :="Pedido"
Private nRegSC8 :=0
Private oFolder1
Private oFont1  := TFont():New("Arial",,020,,.T.,,,,,.F.,.F.)
Private oFont2  := TFont():New("Arial",,018,,.T.,,,,,.F.,.F.)
Private oFont3  := TFont():New("Arial",,016,,.T.,,,,,.F.,.F.)
Private oFont4  := TFont():New("Arial",,018,,.T.,,,,,.F.,.F.)

Private oFlagVERMELHO 	:= LoadBitMap(GetResources(),"BR_VERMELHO")
Private oFlagVERDE    	:= LoadBitMap(GetResources(),"BR_VERDE")
Private oFlagPRETO  	:= LoadBitMap(GetResources(),"BR_PRETO")
Private oFlagAMARELO  	:= LoadBitMap(GetResources(),"BR_AMARELO")
Private oFlagLARANJA  	:= LoadBitMap(GetResources(),"BR_LARANJA")
Private oFlagCINZA 		:= LoadBitMap(GetResources(),"BR_CINZA")
Private oFlagPINK 		:= LoadBitMap(GetResources(),"BR_PINK")
Private oFlagAZUL 		:= LoadBitMap(GetResources(),"BR_AZUL")
Private oFlagMARRON  	:= LoadBitMap(GetResources(),"BR_MARRON")
Private oFlagBRANCO  	:= LoadBitMap(GetResources(),"BR_BRANCO")
Private aRotina         := {}

Private oOk := LoadBitmap( GetResources(), "LBOK")
Private oNo := LoadBitmap( GetResources(), "LBNO")

Private oWBrowse1
Private aWBrowse1 := {}
Private oWBrowse2
Private aWBrowse2 := {}
Private oWBrowse3
Private aWBrowse3 := {}
Private oWBrowse4
Private aWBrowse4 := {}  
Private oWBrowse5    
Private oButton0
Private aWBrowse5  := {}  
Private lWBrowse1  :=.T.
Private lWBrowse2  :=.T.
Private lWBrowse3  :=.T.
Private lWBrowse4  :=.T.
Private lWBrowse5  :=.F.
Private cCodUser   :=RetCodUsr()
Private aWBrowAux1 := {}
Private aWBrowAux2 := {}
Private aWBrowAux3 := {}
Private aWBrowAux4 := {}
Private aWBrowAux5 := {}
Static oDlg            

Private aFilCla	 := {"1=Equipamento Parado","2=Manutencao Corretiva","3=Manutencao Preventiva","4=Compra para Estoque","5=Uso e Consumo","Todos"}
Private oFilCla
Private nFilCla	 := 0
Private nContSCs    := 0
Private cGrpB1	    := Space(4)
Private cFilB1	    := Space(6)
Private cSCB1	    := Space(6)
Private oFilB1
Private oSCB1 
Private oGrpB1
Private cFilB2	    := Space(6)
Private cSCB2	    := Space(6)
Private oFilB2
Private oSCB2
Private cFilB3	    := Space(6)
Private cSCB3	    := Space(6)
Private oFilB3
Private oSCB3
Private cFilB4	    := Space(6)
Private cSCB4	    := Space(6)
Private oFilB4
Private oSCB4
     

Private cGrpPrd := "999999-Todos os Grupos"
Private aGrpPrd := "999999-Todos os Grupos" //MCGRPCOM()


//Usuário que estiver neste parametro podera ver tudo.
//Caso não esteja, verá somente o que é seu.
Private cUsuMst  := SuperGetMv("MV_ZUSUPCO",,"000000")
Private lPainel5 := SuperGetMv("MV_ZPNLPND",,.F.) // Exibe painel pendente.
Private lChkNew  := .T.  // Atualiza as abas com os dados on-line.
Private lChkOld  := .T.                                                                                                                            
Private n        := 0
Private aResolu  := getScreenRes()

SetKey( VK_F12, { || fConsulta() })
SetKey( VK_F10, { || fConSolic() })
SetKey( VK_F9,  { || fConsulta() })

//Todos os acessos dos usuarios                                                                                
//Private aXXUsers := AllUsers()

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
 
  DEFINE MSDIALOG oDlg TITLE "COMPRAS" FROM aSize[7],0 TO aSize[6],aSize[5] COLORS 0, 16777215 PIXEL

  IF(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080    
  
    @ 003, 410 SAY oSay1 PROMPT "CENTRAL DE COMPRAS" SIZE 1065, 411 OF oDlg FONT oFont1 COLORS 200, 16757683 PIXEL
    @ 019, 004 FOLDER oFolder1 SIZE 950, 414 OF oDlg ITEMS "Solicitações Pendentes","Cotações","Ordem de Compras - Aguardando Aprovação",;
    "Ordem de Compras" COLORS 128, 16757683 PIXEL
    
    oFolder1:bSetOption := {|nAtu| fWBrowse(nAtu)} 

    //MsAguarde({|| CursorWait(), fWBrowse1() ,CursorArrow()},"Carregando Solicitações pendentes... ",,)  // aba 01
    
    fWBrowse1()
      
    @ 360, 335 BUTTON oButton1 PROMPT "Visualizar"    SIZE 045, 010 OF oFolder1:aDialogs[1] FONT oFont3 ACTION Eval({||u_AFATP22("1")}) PIXEL
    oButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 
    
    @ 360, 383 BUTTON oButton1 PROMPT "Marcar Todos"  SIZE 056, 010 OF oFolder1:aDialogs[1] FONT oFont3 ACTION Eval({||fMarcaT(aWBrowse1)}) PIXEL
    oButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 
    
    @ 360, 442 BUTTON oButton1 PROMPT "Desmarcar Todos"  SIZE 060, 010 OF oFolder1:aDialogs[1] FONT oFont3 ACTION Eval({||fDesMarT(aWBrowse1)}) PIXEL
    oButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )    
    
    @ 360, 505 BUTTON oButton1 PROMPT "Gerar Cotação" SIZE 056, 010 OF oFolder1:aDialogs[1] FONT oFont3 ACTION Eval({||u_AFATP03(aWBrowse1),fWBrowse1()}) PIXEL
    oButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 

	@ C(271),C(135) Say "Grupo de Compradores" Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oFolder1:aDialogs[1] 
	@ C(282),C(135) MsGet oGrpPrd VAR cGrpPrd Size C(080),C(007) WHEN .F. PIXEL OF oFolder1:aDialogs[1]  
     
     fWBrowse3()     

     @ 360, 349 BUTTON oButton6 PROMPT "Excluir"  SIZE 050, 010 OF oFolder1:aDialogs[3] FONT oFont3 ACTION Eval({||U_AFATP20("3"),oWBrowse3:Gotop(),fWBrowse1(),fWBrowse2(),fWBrowse3(),fWBrowse4()}) PIXEL
	 oButton6:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
	 
	 @ 360, 402 BUTTON oButton6 PROMPT "Visualizar" SIZE 076, 010 OF oFolder1:aDialogs[3] FONT oFont3 ACTION Eval({||u_AFATP09(2),fWBrowse3()}) PIXEL    
     oButton6:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 
     
     @ 360, 481 BUTTON oButton6 PROMPT "Alterar" SIZE 076, 010 OF oFolder1:aDialogs[3] FONT oFont3 ACTION Eval({||u_AFATP09(4),fWBrowse3()}) PIXEL    
     oButton6:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 
    
     @ 360, 560 BUTTON oButton6 PROMPT "Incluir" SIZE 076, 010 OF oFolder1:aDialogs[3] FONT oFont3 ACTION Eval({||u_AFATP09(3),fWBrowse3()}) PIXEL    
     oButton6:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
           
      fWBrowse4()
                                            	
      fWBrowse5()
     
     @ 360, 486 BUTTON oButton6 PROMPT "Alterar CNPJ"    SIZE 050, 010 OF oFolder1:aDialogs[4] FONT oFont3 ACTION Eval({||U_TPCOM002(),fWBrowse4()}) PIXEL
     oButton6:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
     
     DbSelectArea("SAL")
     SAL->(DbSetorder(04))
	 If (DbSeek(xFilial("SAL")+'000005'+__CUSERID))
     @ 360, 541 BUTTON oButton6 PROMPT "Aprovar"     SIZE 050, 010 OF oFolder1:aDialogs[4] FONT oFont3 ACTION Eval({||U_TPCOM004(),fWBrowse4()}) PIXEL
     oButton6:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
     Endif
     
     @ 360, 297 BUTTON oButton6 PROMPT "Excluir OC." SIZE 050, 010 OF oFolder1:aDialogs[4] FONT oFont3 ACTION Eval({||U_AFATP20("4"),fWBrowse2(),fWBrowse3(),oWBrowse4:Gotop(),fWBrowse4()}) PIXEL
     oButton6:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    //Aguardando aprovação
     @ 360, 300 BUTTON oButton8 PROMPT "Imprimir OC" SIZE 046, 010 OF oFolder1:aDialogs[3] FONT oFont3  ACTION  Eval({||u_AFATR01(aWBrowse3[oWBrowse3:nAt,12])}) PIXEL
     oButton8:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    //Liberados
     @ 360, 350 BUTTON oButton8 PROMPT "Imprimir OC" SIZE 046, 010 OF oFolder1:aDialogs[4] FONT oFont3  ACTION  Eval({||u_AFATR01(aWBrowse4[oWBrowse4:nAt,13])}) PIXEL    
     oButton8:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 
    //Pendentes
    If lPainel5
     @ 360, 350 BUTTON oButton8 PROMPT "Imprimir OC" SIZE 046, 010 OF oFolder1:aDialogs[5] FONT oFont3  ACTION  Eval({||u_AFATR01(aWBrowse5[oWBrowse5:nAt,11])}) PIXEL
     oButton8:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    Endif
   
     @ 360, 398 BUTTON oButton7 PROMPT "Sinalizar Processo Finalizado" SIZE 085, 010 OF oFolder1:aDialogs[4] FONT oFont3 ACTION Eval({||u_AFATP11(),fWBrowse4()}) PIXEL
     oButton7:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    //Aguardando aprovação   
  
    @ 360, 251 BUTTON oButton8 PROMPT "Mensagem PC" SIZE 046, 010 OF oFolder1:aDialogs[3] FONT oFont3  ACTION  Eval({||u_AFATT01(aWBrowse3[oWBrowse3:nAt,12])}) PIXEL
    oButton8:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    //Liberados
    @ 360, 247 BUTTON oButton8 PROMPT "Mensagem PC" SIZE 046, 010 OF oFolder1:aDialogs[4] FONT oFont3  ACTION  Eval({||u_AFATT01(aWBrowse4[oWBrowse4:nAt,13])}) PIXEL
    oButton8:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )   
    
    @ 360, 195 BUTTON oButton8 PROMPT "Obs.Aprovação" SIZE 052, 010 OF oFolder1:aDialogs[3] FONT oFont3  ACTION  Eval({||AFATP1(aWBrowse3[oWBrowse3:nAt,2],aWBrowse3[oWBrowse3:nAt,10])}) PIXEL
    oButton8:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )

    @ 360, 185 BUTTON oButton0 PROMPT "E-mail" SIZE 040, 010 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_MCMAILCOT(),fWBrowse2()}) PIXEL    
    oButton0:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
    @ 360, 230 BUTTON oButton0 PROMPT "Excluir Cot"             SIZE 040, 010 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_AFATP17(),oWBrowse2:Gotop(),fWBrowse1(),fWBrowse2()}) PIXEL        
    oButton0:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
    @ 360, 275 BUTTON oButton0 PROMPT "Excluir For"             SIZE 040, 010 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_AFATP18(),fWBrowse2()}) PIXEL            
    oButton0:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
	@ 360, 320 BUTTON oButton2 PROMPT "Atualizar"          SIZE 040, 010 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||IIF(!Empty(aWBrowse2[oWBrowse2:nAt,4]),u_AFATP05(aWBrowse2[oWBrowse2:nAt,3],aWBrowse2[oWBrowse2:nAt,9],aWBrowse2[oWBrowse2:nAt,4],aWBrowse2[oWBrowse2:nAt,5]),),fWBrowse2()}) PIXEL
    oButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
    @ 360, 365 BUTTON oButton9 PROMPT "Incluir For"		       SIZE 040, 010 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_AFATP19(),fWBrowse2()}) PIXEL        
    oButton9:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
    @ 360, 410 BUTTON oButton9 PROMPT "Visualizar SC."          SIZE 040, 010 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_AFATP04(),fWBrowse2()}) PIXEL        
    oButton9:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
    @ 360, 455 BUTTON oButton2 PROMPT "Analisar"           SIZE 040, 010 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({|| IIF(!Empty(aWBrowse2[oWBrowse2:nAt,3]),U_MCMTA160(),),fWBrowse3(),oFolder1:SetOption(3)}) PIXEL
    oButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
    // BROWSER 1 SOLICITAÇÃO
    
    @ C(271),C(005) Say "Pesquisar:" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oFolder1:aDialogs[1]
    @ 360, 005 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS {"Filial","Solicitação"} SIZE 065, 011 OF oFolder1:aDialogs[1] COLORS 0, 16777215 FONT oFont3 PIXEL
    @ 360, 077 MSGET oGet1 VAR cGet1 SIZE 045, 008  OF oFolder1:aDialogs[1] COLORS 0, 16777215 FONT oFont3 PIXEL
   
    DEFINE SBUTTON oSButton2 FROM 360, 126 TYPE 17 ACTION fPesquisa(nComboBo1,cGet1,1) OF oFolder1:aDialogs[1] ENABLE
    oSButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    
     // BROWSER 2 COTAÇÃO
    
    @ C(271),C(005) Say "Pesquisar:" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oFolder1:aDialogs[2]
    @ 360, 005 MSCOMBOBOX oComboBo2 VAR nComboBo2 ITEMS {"Filial","Solicitação","Cotação"} SIZE 065, 011 OF oFolder1:aDialogs[2] COLORS 0, 16777215 FONT oFont3 PIXEL
    @ 360, 077 MSGET oGet2 VAR cGet2 SIZE 045, 008  OF oFolder1:aDialogs[2] COLORS 0, 16777215 FONT oFont3 PIXEL
   
    DEFINE SBUTTON oSButton2 FROM 360, 126 TYPE 17 ACTION fPesquisa(nComboBo2,cGet2,2) OF oFolder1:aDialogs[2] ENABLE
    oSButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    
    // BROWSER 3 PEDIDO DE COMPRAS
    
    @ C(271),C(005) Say "Pesquisar:" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oFolder1:aDialogs[3]
    @ 360, 005 MSCOMBOBOX oComboBo3 VAR nComboBo3 ITEMS {"Filial","Pedido"} SIZE 065, 011 OF oFolder1:aDialogs[3] COLORS 0, 16777215 FONT oFont3 PIXEL
    @ 360, 077 MSGET oGet3 VAR cGet3 SIZE 045, 008  OF oFolder1:aDialogs[3] COLORS 0, 16777215 FONT oFont3 PIXEL
   
    DEFINE SBUTTON oSButton2 FROM 360, 126 TYPE 17 ACTION fPesquisa(nComboBo3,cGet3,3) OF oFolder1:aDialogs[3] ENABLE
    oSButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    
    // BROWSER 4 PEDIDO DE COMPRAS
    
    @ C(271),C(005) Say "Pesquisar:" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oFolder1:aDialogs[4]
    @ 360, 005 MSCOMBOBOX oComboBo4 VAR nComboBo4 ITEMS {"Cotação","Filial","Pedido","Solicitação"} SIZE 065, 011 OF oFolder1:aDialogs[4] COLORS 0, 16777215 FONT oFont3 PIXEL
    @ 360, 077 MSGET oGet4 VAR cGet4 SIZE 045, 008  OF oFolder1:aDialogs[4] COLORS 0, 16777215 FONT oFont3 PIXEL
   
    DEFINE SBUTTON oSButton2 FROM 360, 126 TYPE 17 ACTION fPesquisa(nComboBo4,cGet4,4) OF oFolder1:aDialogs[4] ENABLE
    oSButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    
    fWBrowse2()    
    
    DEFINE SBUTTON oSButton1 FROM 403, 750 TYPE 01 ACTION fConfirma() OF oDlg ENABLE
    oSButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
    @ 443,002 CheckBox oChkMar Var lChkNew Prompt "Atualiza Dados On-Line?" Message Size 80, 007 Pixel OF oDlg ON CLICK FMsgAviso() 
   
    @ 002, 890 BITMAP oBitmap2 SIZE 050, 027 OF oDlg FILENAME "\Imagens\TopMix_Totvs.png" NOBORDER PIXEL   
    
    
       ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Else // OUTRAS RESOLUÇÕES
       ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////   
       
       
    @ 003, 290 SAY oSay1 PROMPT "CENTRAL DE COMPRAS" SIZE 865, 411 OF oDlg FONT oFont1 COLORS 200, 16757683 PIXEL
    @ 019, 004 FOLDER oFolder1 SIZE 670, 254 OF oDlg ITEMS "Solicitações Pendentes","Cotações","Ordem de Compras - Aguardando Aprovação",;
    "Ordem de Compras" COLORS 128, 16757683 PIXEL
    
    oFolder1:bSetOption := {|nAtu| fWBrowse(nAtu)} 

    //MsAguarde({|| CursorWait(), fWBrowse1() ,CursorArrow()},"Carregando Solicitações pendentes... ",,)  // aba 01
    
    fWBrowse1()
      
    @ 217, 315 BUTTON oButton1 PROMPT "Visualizar"    SIZE 045, 010 OF oFolder1:aDialogs[1] FONT oFont3 ACTION Eval({||u_AFATP22("1")}) PIXEL
    oButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 
    
    @ 217, 363 BUTTON oButton1 PROMPT "Marcar Todos"  SIZE 056, 010 OF oFolder1:aDialogs[1] FONT oFont3 ACTION Eval({||fMarcaT(aWBrowse1)}) PIXEL
    oButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 
    
    @ 217, 422 BUTTON oButton1 PROMPT "Desmarcar Todos"  SIZE 060, 010 OF oFolder1:aDialogs[1] FONT oFont3 ACTION Eval({||fDesMarT(aWBrowse1)}) PIXEL
    oButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )    
    
    @ 217, 485 BUTTON oButton1 PROMPT "Gerar Cotação" SIZE 056, 010 OF oFolder1:aDialogs[1] FONT oFont3 ACTION Eval({||u_AFATP03(aWBrowse1),fWBrowse1()}) PIXEL
    oButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 
    
    @ 217, 544 BUTTON oButton1 PROMPT "SC Geral - Tracker" SIZE 063, 010 OF oFolder1:aDialogs[1] FONT oFont3 ACTION Eval({||MATA110()}) PIXEL
    oButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 

	 @ C(161),C(135) Say "Grupo de Compradores" Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oFolder1:aDialogs[1] 
	 @ C(171),C(136) MsGet oGrpPrd VAR cGrpPrd Size C(080),C(007) WHEN .F. PIXEL OF oFolder1:aDialogs[1]  
     
     fWBrowse3()     

     @ 217, 349 BUTTON oButton6 PROMPT "Excluir"  SIZE 050, 010 OF oFolder1:aDialogs[3] FONT oFont3 ACTION Eval({||U_AFATP20("3"),oWBrowse3:Gotop(),fWBrowse1(),fWBrowse2(),fWBrowse3(),fWBrowse4()}) PIXEL
	 oButton6:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 
	 
	 @ 217, 402 BUTTON oButton6 PROMPT "Visualizar" SIZE 076, 010 OF oFolder1:aDialogs[3] FONT oFont3 ACTION Eval({||u_AFATP09(2),fWBrowse3()}) PIXEL    
     oButton6:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 
     
     @ 217, 481 BUTTON oButton6 PROMPT "Alterar" SIZE 076, 010 OF oFolder1:aDialogs[3] FONT oFont3 ACTION Eval({||u_AFATP09(4),fWBrowse3()}) PIXEL    
     oButton6:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 
    
     @ 217, 560 BUTTON oButton6 PROMPT "Incluir" SIZE 076, 010 OF oFolder1:aDialogs[3] FONT oFont3 ACTION Eval({||u_AFATP09(3),fWBrowse3()}) PIXEL    
     oButton6:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
       
      fWBrowse4()
           
      fWBrowse5()
     
     @ 217, 486 BUTTON oButton6 PROMPT "Alterar CNPJ"             SIZE 050, 010 OF oFolder1:aDialogs[4] FONT oFont3 ACTION Eval({||U_TPCOM002(),fWBrowse4()}) PIXEL
     oButton6:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
     
     DbSelectArea("SAL")
     SAL->(DbSetorder(04))
	 If (DbSeek(xFilial("SAL")+'000005'+__CUSERID))
     @ 217, 539 BUTTON oButton6 PROMPT "Aprovar"         SIZE 050, 010 OF oFolder1:aDialogs[4] FONT oFont3 ACTION Eval({||U_TPCOM004(),fWBrowse4()}) PIXEL
     oButton6:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
     Endif
     
     @ 217, 297 BUTTON oButton6 PROMPT "Excluir OC."             SIZE 050, 010 OF oFolder1:aDialogs[4] FONT oFont3 ACTION Eval({||U_AFATP20("4"),fWBrowse2(),fWBrowse3(),oWBrowse4:Gotop(),fWBrowse4()}) PIXEL
     oButton6:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    //Aguardando aprovação
     @ 217, 300 BUTTON oButton8 PROMPT "Imprimir OC" SIZE 046, 010 OF oFolder1:aDialogs[3] FONT oFont3  ACTION  Eval({||u_AFATR01(aWBrowse3[oWBrowse3:nAt,12])}) PIXEL
     oButton8:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    //Liberados
     @ 217, 350 BUTTON oButton8 PROMPT "Imprimir OC" SIZE 046, 010 OF oFolder1:aDialogs[4] FONT oFont3  ACTION  Eval({||u_AFATR01(aWBrowse4[oWBrowse4:nAt,13])}) PIXEL    
     oButton8:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 
    //Pendentes
    If lPainel5
     @ 217, 350 BUTTON oButton8 PROMPT "Imprimir OC" SIZE 046, 010 OF oFolder1:aDialogs[5] FONT oFont3  ACTION  Eval({||u_AFATR01(aWBrowse5[oWBrowse5:nAt,11])}) PIXEL
     oButton8:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    Endif
    
     @ 217, 398 BUTTON oButton7 PROMPT "Sinalizar Processo Finalizado" SIZE 085, 010 OF oFolder1:aDialogs[4] FONT oFont3 ACTION Eval({||u_AFATP11(),fWBrowse4()}) PIXEL
     oButton7:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    //Aguardando aprovação 
  
    @ 217, 251 BUTTON oButton8 PROMPT "Mensagem PC" SIZE 046, 010 OF oFolder1:aDialogs[3] FONT oFont3  ACTION  Eval({||u_AFATT01(aWBrowse3[oWBrowse3:nAt,12])}) PIXEL
    oButton8:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    //Liberados
    @ 217, 247 BUTTON oButton8 PROMPT "Mensagem PC" SIZE 046, 010 OF oFolder1:aDialogs[4] FONT oFont3  ACTION  Eval({||u_AFATT01(aWBrowse4[oWBrowse4:nAt,13])}) PIXEL
    oButton8:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )   
    
    @ 217, 195 BUTTON oButton8 PROMPT "Obs.Aprovação" SIZE 052, 010 OF oFolder1:aDialogs[3] FONT oFont3  ACTION  Eval({||AFATP1(aWBrowse3[oWBrowse3:nAt,2],aWBrowse3[oWBrowse3:nAt,10])}) PIXEL
    oButton8:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )

    @ 217, 205 BUTTON oButton0 PROMPT "E-mail" SIZE 040, 010 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_MCMAILCOT(),fWBrowse2()}) PIXEL    
    oButton0:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
    @ 217, 250 BUTTON oButton0 PROMPT "Excluir Cot"             SIZE 040, 010 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_AFATP17(),oWBrowse2:Gotop(),fWBrowse1(),,fWBrowse2()}) PIXEL        
    oButton0:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
    @ 217, 295 BUTTON oButton0 PROMPT "Excluir For"             SIZE 040, 010 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_AFATP18(),fWBrowse2()}) PIXEL            
    oButton0:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
    @ 217, 340 BUTTON oButton2 PROMPT "Atualizar"          SIZE 040, 010 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||IIF(!Empty(aWBrowse2[oWBrowse2:nAt,3]),u_AFATP05(aWBrowse2[oWBrowse2:nAt,3],aWBrowse2[oWBrowse2:nAt,9],aWBrowse2[oWBrowse2:nAt,4],aWBrowse2[oWBrowse2:nAt,5]),),fWBrowse2()}) PIXEL
    oButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
    @ 217, 385 BUTTON oButton9 PROMPT "Incluir For"		       SIZE 040, 010 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_AFATP19(),fWBrowse2()}) PIXEL        
    oButton9:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
    @ 217, 430 BUTTON oButton9 PROMPT "Visualizar SC."          SIZE 040, 010 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({||U_AFATP04(),fWBrowse2()}) PIXEL        
    oButton9:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
                                                                                                                                                                                  
    @ 217, 475 BUTTON oButton2 PROMPT "Analisar"           SIZE 040, 010 OF oFolder1:aDialogs[2] FONT oFont3 ACTION Eval({|| IIF(!Empty(aWBrowse2[oWBrowse2:nAt,3]),U_MCMTA160(),),fWBrowse3(),oFolder1:SetOption(3)}) PIXEL
    oButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
     
    // BROWSER 1 SOLICITAÇÃO
    
    @ C(161),C(005) Say "Pesquisar:" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oFolder1:aDialogs[1]
    @ 218, 005 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS {"Filial","Solicitação"} SIZE 065, 011 OF oFolder1:aDialogs[1] COLORS 0, 16777215 FONT oFont3 PIXEL
    @ 218, 077 MSGET oGet1 VAR cGet1 SIZE 045, 008  OF oFolder1:aDialogs[1] COLORS 0, 16777215 FONT oFont3 PIXEL
   
    DEFINE SBUTTON oSButton2 FROM 218, 126 TYPE 17 ACTION fPesquisa(nComboBo1,cGet1,1) OF oFolder1:aDialogs[1] ENABLE
    oSButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    
     // BROWSER 2 COTAÇÃO
    
    @ C(161),C(005) Say "Pesquisar:" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oFolder1:aDialogs[2]
    @ 218, 005 MSCOMBOBOX oComboBo2 VAR nComboBo2 ITEMS {"Filial","Solicitação","Cotação"} SIZE 065, 011 OF oFolder1:aDialogs[2] COLORS 0, 16777215 FONT oFont3 PIXEL
    @ 218, 077 MSGET oGet2 VAR cGet2 SIZE 045, 008  OF oFolder1:aDialogs[2] COLORS 0, 16777215 FONT oFont3 PIXEL
   
    DEFINE SBUTTON oSButton2 FROM 218, 126 TYPE 17 ACTION fPesquisa(nComboBo2,cGet2,2) OF oFolder1:aDialogs[2] ENABLE
    oSButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    
    // BROWSER 3 PEDIDO DE COMPRAS
    
    @ C(161),C(005) Say "Pesquisar:" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oFolder1:aDialogs[3]
    @ 218, 005 MSCOMBOBOX oComboBo3 VAR nComboBo3 ITEMS {"Filial","Pedido"} SIZE 065, 011 OF oFolder1:aDialogs[3] COLORS 0, 16777215 FONT oFont3 PIXEL
    @ 218, 077 MSGET oGet3 VAR cGet3 SIZE 045, 008  OF oFolder1:aDialogs[3] COLORS 0, 16777215 FONT oFont3 PIXEL
   
    DEFINE SBUTTON oSButton2 FROM 218, 126 TYPE 17 ACTION fPesquisa(nComboBo3,cGet3,3) OF oFolder1:aDialogs[3] ENABLE
    oSButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    
    // BROWSER 4 PEDIDO DE COMPRAS
    
    @ C(161),C(005) Say "Pesquisar:" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oFolder1:aDialogs[4]
    @ 218, 005 MSCOMBOBOX oComboBo4 VAR nComboBo4 ITEMS {"Cotação","Filial","Pedido","Solicitação"} SIZE 065, 011 OF oFolder1:aDialogs[4] COLORS 0, 16777215 FONT oFont3 PIXEL
    @ 218, 077 MSGET oGet4 VAR cGet4 SIZE 045, 008  OF oFolder1:aDialogs[4] COLORS 0, 16777215 FONT oFont3 PIXEL
   
    DEFINE SBUTTON oSButton2 FROM 218, 126 TYPE 17 ACTION fPesquisa(nComboBo4,cGet4,4) OF oFolder1:aDialogs[4] ENABLE
    oSButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )
    
    DEFINE SBUTTON oSButton1 FROM 283, 498 TYPE 01 ACTION fConfirma() OF oDlg ENABLE
    oSButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
    //MsAguarde({|| CursorWait(), fWBrowse2() ,CursorArrow()},"Carregando SC - Em Cotação... ",,)  // aba 02
    
    fWBrowse2()    

    @ 405, 002 SAY oSay2 PROMPT "Pesquisar Por:" SIZE 052, 009 OF oFolder1:aDialogs[2] FONT oFont2 COLORS 128, 16777215 PIXEL
    @ 663, 050 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS {"Cotação","Filial","Solicitação"} SIZE 077, 011 OF oFolder1:aDialogs[2] COLORS 0, 16777215 FONT oFont3 PIXEL
    @ 663, 129 MSGET oGet1 VAR cGet1 SIZE 045, 009  OF oFolder1:aDialogs[2] COLORS 0, 16777215 FONT oFont3 PIXEL
  
    DEFINE SBUTTON oSButton2 FROM 283, 178 TYPE 17 ACTION fPesquisa(nComboBo1,cGet1) OF oFolder1:aDialogs[2] ENABLE
    oSButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
    DEFINE SBUTTON oSButton1 FROM 283, 498 TYPE 01 ACTION fConfirma() OF oDlg ENABLE
    oSButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )  
    
    @ 283,002 CheckBox oChkMar Var lChkNew Prompt "Atualiza Dados On-Line?" Message Size 80, 007 Pixel OF oDlg ON CLICK FMsgAviso() 
   
    @ 002, 610 BITMAP oBitmap2 SIZE 050, 027 OF oDlg FILENAME "\Imagens\TopMix_Totvs.png" NOBORDER PIXEL
  
  Endif
                                                            
  ACTIVATE MSDIALOG oDlg CENTERED
                                     
Set Key VK_F12	To

Return                        

 

//------------------------------------------------ 
//* Grava cotaçao de pedido de compras   
// SC - Pendentes
//------------------------------------------------ 

**************************************
Static Function fWBrowse(pop) //      
**************************************

Do Case
	Case pop=1
//		AutoGrLog("1"+Time())
    	fWBrowse1()  	//SC - Pendentes 
  	Case pop=2
//		AutoGrLog("2"+Time())
 		fWBrowse2() 	//SC - Em Cotação
 	Case pop=3
//		AutoGrLog("3"+Time())
    	fWBrowse3() 	//OC - Aguardando Aprovação
	Case pop=4
//		AutoGrLog("4"+Time())
    	fWBrowse4() 	//OC - Liberados
	Case pop=5
//		AutoGrLog("5"+Time())
        fWBrowse5() 	//OC - Entrega Pendente"
 	Case pop=6 
	Otherwise                               
EndCase 

Return(.T.) 

//------------------------------------------------ 
//* Grava cotaçao de pedido de compras   
// SC - Pendentes
//------------------------------------------------ 

****************************************************
Static Function fConfirma(aBrow1,oMSNewGe1) //      
****************************************************

	oDlg:End()

//MostraErro()
Return(.T.) 

***************************************************
Static Function fWBrowse1()
***************************************************

If ! lChkNew 
   If Empty(cFilB1) .And. Empty(cGrpB1) .And. Empty(cSCB1) // .F. = não atualiza o browse 
      Return .T.
   Else
      lChkNew := .T.
      oChkMar:Refresh()
   Endif
Endif   
                   
    // Insert items here 
    Processa( {|| fSelecao1() }, "Aguarde...", "Carregando Solicitações...",.F.) 
    
    If Len(aWBrowse1)==0
        aWBrowse1 := {}
		Aadd(aWBrowse1,{.F.,oFlagVERMELHO,"","","","","",0,"","","","","","",""})
    Endif

    If lWBrowse1 
    	lWBrowse1 :=.F. 
    	
    If(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080	                                     
    //                                             1   2     3               4               5           6            7             8            9            
		@ 000, 000 LISTBOX oWBrowse1 Fields HEADER "","","Empresa","Filial","C.Custo","SC","Descrição","Quantidade","Classificação",;
		"Observação","Grupo","Produto","Item SC" SIZE 948, 325 OF oFolder1:aDialogs[1] PIXEL ColSizes 50,50    	
    //    10            11            12        13
    Else
     //                                             1   2     3               4               5           6            7             8            9            
		@ 000, 000 LISTBOX oWBrowse1 Fields HEADER "","","Empresa","Filial","C.Custo","SC","Descrição","Quantidade","Classificação",;
		"Observação","Grupo","Produto","Item SC", "Filial" SIZE 668, 205 OF oFolder1:aDialogs[1] PIXEL ColSizes 50,50    	
    //    10            11            12        13    
    Endif
    
    
    Endif 
                                                          	
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
      aWBrowse1[oWBrowse1:nAt,13],;
      aWBrowse1[oWBrowse1:nAt,14]}}         

    // DoubleClick event
    oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],;
    oWBrowse1:DrawSelect()}
    oWBrowse1:Refresh()
  
Return()

****************************************
Static Function fWBrowse2()
****************************************
//SC - Em Cotação

                                
Local aAUx		 := {} 
Local nreg       :=1 


If ! lChkNew 
   If Empty(cFilB2) .And. Empty(cGrpB1) .And. Empty(cSCB2) // .F. = não atualiza o browse 
      Return .T.
   Else
      lChkNew := .T.
      oChkMar:Refresh()
   Endif
Endif   

nRegSC8  :=0
//aWBrowse2:={}
   
    // Insert items here   
     
    Processa( {|| fSelecao2() }, "Aguarde...", "Carregando Cotações...",.F.) 
 
    If Len(aWBrowAux2)=0
        aWBrowse2 := {} 
		Aadd(aWBrowse2,{oFlagVERMELHO," "," "," "," "," "," "," "," "})
    ElSe
   		aWBrowse2:=aWBrowAux2
    Endif        
 
    // Insert items here   
    If lWBrowse2  
    	lWBrowse2:=.F.    	
     If(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080     	
   		@ 000, 000 LISTBOX oWBrowse2 Fields HEADER "","Filial","Num. Cotação","Cod.Forn.","Loja","Nome do Fornecedor","Comprador",;
   		"Num. SC.","Filial" SIZE 948, 325 OF oFolder1:aDialogs[2] PIXEL ColSizes 50,50
   	 Else
   	 	@ 000, 000 LISTBOX oWBrowse2 Fields HEADER "","Filial","Num. Cotação","Cod.Forn.","Loja","Nome do Fornecedor","Comprador",;
   		"Num. SC.","Filial" SIZE 668, 205 OF oFolder1:aDialogs[2] PIXEL ColSizes 50,50
   	 Endif		
    Endif
    oWBrowse2:SetArray(aWBrowse2)
    oWBrowse2:bLine := {|| {;
    aWBrowse2[oWBrowse2:nAt,1],;
    aWBrowse2[oWBrowse2:nAt,2]+space(15),;
    aWBrowse2[oWBrowse2:nAt,3],;
    aWBrowse2[oWBrowse2:nAt,4],;
    aWBrowse2[oWBrowse2:nAt,5],;    
    aWBrowse2[oWBrowse2:nAt,6],;          
    aWBrowse2[oWBrowse2:nAt,7],;
    aWBrowse2[oWBrowse2:nAt,8],;              
    aWBrowse2[oWBrowse2:nAt,9]}}    

    // DoubleClick event
    oWBrowse2:bChange  	:= {||nRegSC8:=oWBrowse2:nAt,oWBrowse2:Refresh() }//oBrowse:bSeekChange

    oWBrowse2:Refresh()

Return()               

                              
***************************************** 
Static Function fWBrowse3()
*****************************************
//OC -  Aguardando Aprovação

Local aAUx      :={}                 

If ! lChkNew 
   If Empty(cFilB3) .And. Empty(cGrpB1) .And. Empty(cSCB3) // .F. = não atualiza o browse 
      Return .T.
   Else
      lChkNew := .T.
      oChkMar:Refresh()
   Endif
Endif   

//aWBrowse3 := {}
                               
    Processa( {|| fSelecao3() }, "Aguarde...", "Carregando Ordens Pendentes...",.F.)  

    If Len(aWBrowAux3)=0
        aWBrowse3 := {} 
		Aadd(aWBrowse3,{oFlagAZUL,"","","","","","","","","","",""})
    ElSe
		nRegSC8:=1
		aWBrowse3:=aWBrowAux3
    Endif        
    // Insert items here 
    If lWBrowse3  
    	lWBrowse3:=.F.
      If(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080
        @ 000, 000 LISTBOX oWBrowse3 Fields HEADER "","Filial","Num. OC","Num. SC","Num. Cotação","Fornecedor","Loja","Produto","Descrição","Quantidade",;
   		"Filial" SIZE 948, 325 OF oFolder1:aDialogs[3] PIXEL ColSizes 50,50	
   	  Else
   		@ 000, 000 LISTBOX oWBrowse3 Fields HEADER "","Filial","Num. OC","Num. SC","Num. Cotação","Fornecedor","Loja","Produto","Descrição","Quantidade",;
   		"Filial" SIZE 668, 205 OF oFolder1:aDialogs[3] PIXEL ColSizes 50,50
   	  Endif	
    Endif
    oWBrowse3:SetArray(aWBrowse3)
    oWBrowse3:bLine := {|| {;
      aWBrowse3[oWBrowse3:nAt,1],;
      aWBrowse3[oWBrowse3:nAt,2],;
      aWBrowse3[oWBrowse3:nAt,3],;
      aWBrowse3[oWBrowse3:nAt,4],;
      aWBrowse3[oWBrowse3:nAt,5],;
      aWBrowse3[oWBrowse3:nAt,6],;
      aWBrowse3[oWBrowse3:nAt,7],;
      aWBrowse3[oWBrowse3:nAt,8],;
      aWBrowse3[oWBrowse3:nAt,9],;
      aWBrowse3[oWBrowse3:nAt,10],;
      aWBrowse3[oWBrowse3:nAt,11],;      
    }}
    // DoubleClick event
  oWBrowse3:bChange  	:= {||nRegSC8:=oWBrowse3:nAt,oWBrowse3:Refresh() }//oBrowse:bSeekChange  
  oWBrowse3:Refresh()          
 
Return()

*****************************************
Static Function fWBrowse4() 
*****************************************
//"OC -  Liberados"

If ! lChkNew 
   If Empty(cFilB4) .And. Empty(cGrpB1) .And. Empty(cSCB4) // .F. = não atualiza o browse 
      Return .T.
   Else
      lChkNew := .T.
      oChkMar:Refresh()
   Endif
Endif   

//aWBrowse4 := {}  
nRegSC8   :=1 
                                 
    Processa( {|| fSelecao4() }, "Aguarde...", "Carregando Ordens Aprovadas...",.F.) 
 
    If Len(aWBrowse4)=0
        aWBrowse4 := {} 
		Aadd(aWBrowse4,{oFlagVERDE,"","","","","","","","","","","","",""})
    Endif        

    // Insert items here 
    If lWBrowse4  
    	lWBrowse4:=.F.
      If(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080	
    	@ 000, 000 LISTBOX oWBrowse4 Fields HEADER "","Filial","Num. OC","Emissão","Num. SC","Num. Cotação","Fornecedor","Loja","Produto","Descrição do Produto",;
    	"Quantidade","Filial","Cod.Fornecedor","Id" SIZE 948, 325 OF oFolder1:aDialogs[4] PIXEL ColSizes 50,50
      Else 
        @ 000, 000 LISTBOX oWBrowse4 Fields HEADER "","Filial","Num. OC","Emissão","Num. SC","Num. Cotação","Fornecedor","Loja","Produto","Descrição do Produto",;
    	"Quantidade","Filial","Cod.Fornecedor","Id" SIZE 668, 205 OF oFolder1:aDialogs[4] PIXEL ColSizes 50,50
      Endif	
    Endif
    oWBrowse4:SetArray(aWBrowse4)
    oWBrowse4:bLine := {|| {;
      aWBrowse4[oWBrowse4:nAt,1],;
      aWBrowse4[oWBrowse4:nAt,2],;
      aWBrowse4[oWBrowse4:nAt,3],;
      aWBrowse4[oWBrowse4:nAt,4],;
      aWBrowse4[oWBrowse4:nAt,5],;
      aWBrowse4[oWBrowse4:nAt,6],;
      aWBrowse4[oWBrowse4:nAt,7],;
      aWBrowse4[oWBrowse4:nAt,8],;
      aWBrowse4[oWBrowse4:nAt,9],;
      aWBrowse4[oWBrowse4:nAt,10],;
      aWBrowse4[oWBrowse4:nAt,11],;
      aWBrowse4[oWBrowse4:nAt,12],;
      aWBrowse4[oWBrowse4:nAt,13],;
      aWBrowse4[oWBrowse4:nAt,14] }}
    // DoubleClick event
    oWBrowse4:bChange  	:= {||nRegSC8:=oWBrowse4:nAt,oWBrowse4:Refresh() }//oBrowse:bSeekChange  
    oWBrowse4:Refresh() 

    //oWBrowse4:bLDblClick := {|| aWBrowse4[oWBrowse4:nAt,1] := !aWBrowse4[oWBrowse4:nAt,1],;
    //oWBrowse4:DrawSelect()}
Return()



************************************
Static Function fWBrowse5()    
************************************
//OC - Entrega Pendente
 
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

//aWBrowse5 := {}

    //aAUx:=fSelecao5() 
 
    If Len(aAUx)=0 
		Aadd(aWBrowse5,{oFlagAMARELO,"","","","","","","","",""})
    ElSe
		aWBrowse5:=aWBrowAux5
    Endif        

    // Insert items here 
    If lWBrowse5 .And. lPainel5
    	 lWBrowse5:=.F.
    	 @ 000, 000 LISTBOX oWBrowse5 Fields HEADER "","Num. OC","Num. SC","Num. Cotação","Fornecedor","Loja","Produto","Descrição Produto","Quantidade",;
    	 "Filial" SIZE 668, 205 OF oFolder1:aDialogs[5] PIXEL ColSizes 50,50
    Endif
    oWBrowse5:SetArray(aWBrowse5)
    oWBrowse5:bLine := {|| {;
      aWBrowse5[oWBrowse5:nAt,1],;
      aWBrowse5[oWBrowse5:nAt,2],;
      aWBrowse5[oWBrowse5:nAt,3],;
      aWBrowse5[oWBrowse5:nAt,4],;
      aWBrowse5[oWBrowse5:nAt,5],;
      aWBrowse5[oWBrowse5:nAt,6],;
      aWBrowse5[oWBrowse5:nAt,7],;
      aWBrowse5[oWBrowse5:nAt,8],;
      aWBrowse5[oWBrowse5:nAt,9],;
      aWBrowse5[oWBrowse5:nAt,10];
    }}
    // DoubleClick event
    //oWBrowse5:bLDblClick := {|| aWBrowse5[oWBrowse5:nAt,1] := !aWBrowse5[oWBrowse5:nAt,1],;
    oWBrowse5:DrawSelect()

Return

****************************************
Static Function fSelecao1()
****************************************

Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()                    
Local aClassi   := {}
Local aEmpresa  :={}  
Local xE        :=0
Local cFilAtu 	:= cFilial  
Local cEmpAux   :=""
Local cFromSC1  := "%"+"SC1"+cEmpAux+"%"
Local cFromSB1  := "%"+"SB1"+cEmpAux+"%"
Local cFromSBM  := "%"+"SBM"+cEmpAux+"%" 
Local nX
Local nReg      := 0

fClassi(@aClassi)

aEmpresa:=u_fSIGAMAT()// Funcao para buscar as empresas

      
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
cQuery += "       C1_ZOBSADI,"
cQuery += "       BM_DESC,"
cQuery += "       C1_ZAPLIC,"
cQuery += "       C1_CC,"
cQuery += "       C1_ITEM" 
cQuery += "  FROM "+StrTran(cFromSC1,"%","")+" SC1, "+StrTran(cFromSB1,"%","")+" SB1, "+StrTran(cFromSBM,"%","")+" SBM"
cQuery += " WHERE SC1.C1_ZSTATUS IN ('1','3')"
cQuery += "   AND SC1.C1_APROV   = 'L'"
cQuery += "   AND SC1.D_E_L_E_T_ <> '*'"
cQuery += "   AND C1_QUANT <> C1_QUJE"
cQuery += "   AND SC1.C1_PRODUTO = SB1.B1_COD"
cQuery += "   AND SC1.C1_COTACAO = ' '"
cQuery += "   AND SB1.D_E_L_E_T_ <> '*'"
cQuery += "   AND SB1.B1_GRUPO   = SBM.BM_GRUPO"
cQuery += "   AND SBM.D_E_L_E_T_ <> '*'"                                                                                                         
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
    
    (cAliasQry)->( DbGoTop() )
 	While !(cAliasQry)->(EOF())
 	 nReg := nReg + 1
 	dbskip()
 	EnDdo 
    
    aWBrowse1 := {}
 	(cAliasQry)->( DbGoTop() )
 	If !(cAliasQry)->(EOF())
 	For nX := 1 to nReg   
       Aadd(aWBrowse1,{.F.,;          			// Marca    	1 
        	fGetFlag((cAliasQry)->C1_ZSTATUS),;     // Flag     	2
        	(cAliasQry)->C1_ZEMP,;  			    // Empresa   	3
        	(cAliasQry)->C1_FILIAL+'-'+Substr(FWFilialName(,(cAliasQry)->C1_FILIAL,2),14,Len(FWFilialName(,(cAliasQry)->C1_FILIAL,2))),;  				// Filial   	4
        	(cAliasQry)->C1_CC,;  			     	// Filial   	5
        	(cAliasQry)->C1_NUM,;     				// Numero SC  	6
        	(cAliasQry)->B1_DESC,;  			    // Descrição   	7
        	(cAliasQry)->C1_QUANT,;  			    // Quantidade  	8
        	aClassi[val((cAliasQry)->C1_ZCLASSI)],; // Status     	9 
        	(cAliasQry)->C1_ZOBSADI,; 				// Grupo    	10
        	(cAliasQry)->BM_DESC,;  				// Desc Grupo   11 //        	(cAliasQry)->C1_ZAPLIC,;  				// Aplicação    9        	
        	(cAliasQry)->C1_PRODUTO,;  				// Cod.Produto  12
        	(cAliasQry)->C1_ITEM,;                  //Item SC 13
        	(cAliasQry)->C1_FILIAL,;                // Filial   	14
       	 })              
       	 
        (cAliasQry)->(dbskip())  
	Next nX
	Endif
	
	nContSCs := Len(aWBrowse1) 
	
	(cAliasQry)->(dbCloseArea())

Next    
      
RestArea(aAliasOLD)

Return(aWBrowse1)  
                                                                      
*************************************** 
Static Function fSelecao2()
*************************************** 

Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()                                                                                
Local aWBrowAux := {}     
Local nX
Local nReg      := 0
  	
cQuery := "SELECT DISTINCT C8_FILIAL,"
cQuery += "                C8_NUM,"
cQuery += "                C8_FORNECE,"
cQuery += "                C8_LOJA,"
cQuery += "                A2_NOME,"
cQuery += "                C8_ZSTATUS,"
cQuery += "                C8_NUMSC,"
cQuery += "                C8_ZUSER "
cQuery += "  FROM "+RetSqlName("SC8")+" SC8"
cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2"
cQuery += "    ON SC8.C8_FORNECE = SA2.A2_COD"
cQuery += "   AND SC8.C8_LOJA    = SA2.A2_LOJA"
cQuery += "   AND SA2.D_E_L_E_T_ <> '*'"
cQuery += " WHERE SC8.D_E_L_E_T_ <> '*'"
if ! cCodUser $ cUsuMst
cQuery += "    AND	SC8.C8_ZUSER    = '" + cCodUser + "'"
endif  
cQuery += "   AND SC8.C8_ZSTATUS IN ('1', '3', '4')"
cQuery += "   AND SC8.C8_NUMPED = ' '"
cQuery += " ORDER BY C8_FILIAL, C8_NUM" 


cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	(cAliasQry)->( DbGoTop() )
 	While !(cAliasQry)->(EOF())
 	 nReg := nReg + 1
 	dbskip()
 	EnDdo
 	 
  	aWBrowAux2 := {}
	(cAliasQry)->( DbGoTop() )
 	If !(cAliasQry)->(EOF())
 	For nX := 1 to nReg   
        Aadd(aWBrowAux2,{fGetFlag((cAliasQry)->C8_ZSTATUS),;  	//Flag        1
        	(cAliasQry)->C8_FILIAL+'-'+Substr(FWFilialName(,(cAliasQry)->C8_FILIAL,2),14,Len(FWFilialName(,(cAliasQry)->C8_FILIAL,2))),; 	//Filial  2	
        	(cAliasQry)->C8_NUM,;                               //Numero Cotação   3
        	(cAliasQry)->C8_FORNECE,;  							//Codigo do fornecedor 3 
        	(cAliasQry)->C8_LOJA,;     							//Loja  			   4
        	(cAliasQry)->A2_NOME,;     							//Nome dor fornecedor  5       						
            UsrRetName((cAliasQry)->C8_ZUSER),;    				//ID do usuário; 
            (cAliasQry)->C8_NUMSC ,;       						//Num solic.
            (cAliasQry)->C8_FILIAL})                            //Filial
                     
        (cAliasQry)->(dbskip())  
	Next nX
	Endif
	
	(cAliasQry)->(dbCloseArea())

RestArea(aAliasOLD) 
Return(aWBrowAux2)  

************************************** 
Static Function fSelecao3()
**************************************
//OC -  Aguardando Aprovação


Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()                                                                                
Local aWBrowAux := {}   
Local nX
Local nReg      := 0
	
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
if ! cCodUser $ cUsuMst
	cQuery += "   AND	SC7.C7_USER    = '" + cCodUser + "'"
endif 
cQuery += " ORDER BY C7_FILIAL, C7_NUM, A2_NOME, C7_PRODUTO"
	  	
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    (cAliasQry)->( DbGoTop() )
 	While !(cAliasQry)->(EOF())
 	 nReg := nReg + 1
 	dbskip()
 	EnDdo
    
    aWBrowAux3 := {}
	(cAliasQry)->( DbGoTop() )
 	If !(cAliasQry)->(EOF())
 	For nX := 1 to nReg   
            Aadd(aWBrowAux3,{oFlagAZUL,;  								//Flag     	           1
            (cAliasQry)->C7_FILIAL+'-'+Substr(FWFilialName(,(cAliasQry)->C7_FILIAL,2),14,Len(FWFilialName(,(cAliasQry)->C7_FILIAL,2))),;
        	(cAliasQry)->C7_NUM,;  										//Numero Ordem compra  2
            (cAliasQry)->C7_NUMSC,;  									//Numero Solicitacao   3
        	(cAliasQry)->C7_NUMCOT,;  									//Numero Cotacao       4
        	(cAliasQry)->A2_NOME,;     		     						//Nome dor fornecedor  5
        	(cAliasQry)->C7_LOJA,;     			    					//Loja  			   6
        	(cAliasQry)->C7_PRODUTO,; 									//Produto    	       7
       	    Substr((cAliasQry)->B1_DESC,1,30),; 						//Descricao do Produto 8
        	Transform( (cAliasQry)->C7_QUANT,"@E 999,999,999.99"),;  	//Quantidade 9         
        	(cAliasQry)->C7_FILIAL,;				
        	(cAliasQry)->RECSC7 }) 				   						//Recno() SC7 12    
        	
        (cAliasQry)->(dbskip())  
	Next nX
	Endif
	
	(cAliasQry)->(dbCloseArea())

RestArea(aAliasOLD)
Return(aWBrowAux3)  

**************************************
Static Function fSelecao4()
**************************************
//OC -  Liberados
 

Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()                                                                                
Local cQuery4   := ""
Local nX
Local nReg      := 0

cQuery4 := "SELECT" 
cQuery4 += "       C7_FILIAL,"
cQuery4 += "       C7_NUM,"
cQuery4 += "       C7_EMISSAO,"
cQuery4 += "       C7_NUMSC,"
cQuery4 += "       C7_NUMCOT,"
cQuery4 += "       A2_NOME,"
cQuery4 += "       C7_LOJA,"
cQuery4 += "       C7_PRODUTO,"
cQuery4 += "       B1_DESC,"
cQuery4 += "       C7_QUANT,"
cQuery4 += "       SC7.R_E_C_N_O_ AS RECSC7," 
cQuery4 += "       C7_FORNECE "
cQuery4 += "  FROM "+RetSqlName("SC7")+" SC7"
cQuery4 += " INNER JOIN "+RetSqlName("SA2")+" SA2 ON SC7.C7_FORNECE = SA2.A2_COD AND SC7.C7_LOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_ <> '*'"
cQuery4 += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SC7.C7_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ <> '*'"
cQuery4 += " WHERE SC7.C7_CONAPRO = 'L'"
cQuery4 += "   AND SC7.C7_QUJE    = 0 "
cQuery4 += "   AND SC7.C7_ENCER   = ' '"
cQuery4 += "   AND SC7.C7_EMISSAO >= '"+DTOS(DATE() - 90)+"'"
cQuery4 += "   AND SC7.D_E_L_E_T_ <> '*'"
if ! cCodUser $ cUsuMst 
cQuery4 += "   AND SC7.C7_USER = '"+cCodUser+"'"
Endif
cQuery4 += " ORDER BY C7_FILIAL,C7_NUM, A2_NOME, C7_PRODUTO"

cQuery4 := ChangeQuery(cQuery4)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery4),cAliasQry,.T.,.T.)

    (cAliasQry)->( DbGoTop() )
 	While !(cAliasQry)->(EOF())
 	 nReg := nReg + 1
 	dbskip()
 	EnDdo
     
    aWBrowse4 := {}
	(cAliasQry)->(DbGoTop())
 	If !(cAliasQry)->(EOF())
 	For nX := 1 to nReg  
        Aadd(aWBrowse4,{oFlagVERDE,;  								//Flag  	           1
            (cAliasQry)->C7_FILIAL+'-'+Substr(FWFilialName(,(cAliasQry)->C7_FILIAL,2),14,Len(FWFilialName(,(cAliasQry)->C7_FILIAL,2))),;  // Filial
        	(cAliasQry)->C7_NUM,;  									//Numero Ordem compra  2
        	DtoC(StoD((cAliasQry)->C7_EMISSAO)),;					//EMISSAO
            (cAliasQry)->C7_NUMSC,;  								//Numero Solicitacao   3
        	(cAliasQry)->C7_NUMCOT,;  								//Numero Cotacao       4
        	(cAliasQry)->A2_NOME,;     								//Nome dor fornecedor  5
        	(cAliasQry)->C7_LOJA,;     								//Loja  			   6
        	(cAliasQry)->C7_PRODUTO,; 								//Produto    	       7
	        Substr((cAliasQry)->B1_DESC,1,30),;   					//Descricao do Produto 8
        	Transform((cAliasQry)->C7_QUANT,"@E 999,999,999.99"),;  //Quantidade           9         
        	(cAliasQry)->C7_FILIAL,; 								//Filial SC7           10         
        	(cAliasQry)->RECSC7   ,;								//Recno() SC7          11
        	(cAliasQry)->C7_FORNECE})								//Fornecedor           12
        (cAliasQry)->(dbskip())  
	Next nX
	Endif
	
	(cAliasQry)->(dbCloseArea())
RestArea(aAliasOLD)
Return(aWBrowse4)                                                                                                                                                 

*************************************
Static Function fSelecao5()
*************************************
//OC - Entrega Pendente

Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()                                                                                
Local aWBrowAux := {}
Local nReg      := 0   
  
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
cQuery += " 		AND SC7.D_E_L_E_T_ <> '*'        "             		
cQuery += "      	ORDER BY C7_NUM"         

  
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.) 
	
    (cAliasQry)->( DbGoTop() )
 	While !(cAliasQry)->(EOF())
 	 nReg := nReg + 1
 	dbskip()
 	EnDdo
 	
 	aWBrowAux5 := {}   
	(cAliasQry)->( DbGoTop() )
 	If !(cAliasQry)->(EOF())
 	For nX := 1 to nReg  
        Aadd(aWBrowAux5,{oFlagAMARELO,;  		                     //Flag  	           1
        	(cAliasQry)->C7_NUM,;  					                 //Numero Ordem compra  2
        	(cAliasQry)->C7_NUMSC,;  			        	         //Numero Solicitacao   3
        	(cAliasQry)->C7_NUMCOT,;  				                 //Numero Cotacao       4
        	(cAliasQry)->A2_NOME,;     			                     //Nome dor fornecedor  5
        	(cAliasQry)->C7_LOJA,;     		                         //Loja  			   6
        	(cAliasQry)->C7_PRODUTO,; 				                 //Produto    	       7
	     	(cAliasQry)->B1_DESC,; 					                 //Descricao do Produto 8
        	Transform( (cAliasQry)->C7_QUANT,"@E 999,999,999.99"),;  //Quantidade 9         
        	(cAliasQry)->C7_FILIAL,;  					             //Recno() SC7 10         
        	(cAliasQry)->RECSC7})
        	
        (cAliasQry)->(dbskip())  
	Next nX
	Endif
	
	(cAliasQry)->(dbCloseArea())

RestArea(aAliasOLD)
Return(aWBrowAux5)  

//------------------------------------------------ 
//* Flag Retorna a Flag de acordo a regra da legenda
//------------------------------------------------ 

*****************************************
Static Function fGetFlag(pStatus)
*****************************************

Local lRet    := ""
Do 	Case              

	Case pStatus='4'  // SC Liberada para cotaçao
		Return oFlagVermelho
	Case pStatus='1'  // SC Aguardando liberaçao
		Return oFlagVERDE
	Case pStatus='2'  // SC Em processo de contacao
		Return oFlagPRETO
	Case pStatus='3'  // SC Bloqueada por ocorrencia
		Return oFlagAMARELO
	Case pStatus='5'  // SC Ordem de compra gerada
		Return oFlagLARANJA
	Case pStatus='6'  // SC Pedido liberado
		Return oFlagCINZA
	Case pStatus='7'  // SC Pedido liberado ao fornecedor
		Return oFlagPINK
	Case pStatus='8'  // SC Aguardando entrega do fornecedor/ Filial
		Return oFlagBRANCO
	Case pStatus='9'  // SC Aguardando entrega logistica
		Return oFlagMARROM 
	Case pStatus='A'  // SC Entregue
		Return oFlagAZUL 
EndCase
		
Return(lRet)                         


//------------------------------------------------ 
//* Funcao do browsse para a tela de grupos 
// SC - Pendentes
//------------------------------------------------ 
**********************************************
Static Function  fWBrowseG(oBrow1) // SAIR
**********************************************

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
	      aWBrowGru[oWBrowGru:nAt,4];
	    }}
	    // DoubleClick event
	    oWBrowGru:bLDblClick := {|| aWBrowGru[oWBrowGru:nAt,1] := !aWBrowGru[oWBrowGru:nAt,1],;
	    oWBrowGru:DrawSelect()}     
	Else
		MsgAlert("Não existe registros marcados!!!","Atenção")
	Endif    
Return                    
//------------------------------------------------ 
//* Funcao do browsse para a tela de grupos 
// SC - Pendentes
//------------------------------------------------
************************************************* 
Static Function fPesquisa(pComboBo,pCod,p)         
*************************************************

If (pComboBo == "Solicitação" .AND. p = 1)
	nPos := Ascan(aWBrowse1, {|e| e[6]  == pCod})  //"Numero da Solicitação"
Elseif (pComboBo =="Filial" .AND. p = 1)                                                      
    nPos := Ascan(aWBrowse1, {|e| e[14]  == pCod}) //"Filial"
Elseif (pComboBo =="Filial" .AND. p = 2)                                                      
    nPos := Ascan(aWBrowse2, {|e| e[9]  == pCod}) //"Filial"
Elseif (pComboBo =="Solicitação" .AND. p = 2)                                                      
    nPos := Ascan(aWBrowse2, {|e| e[8]  == pCod}) //"Numero da Solicitação"
Elseif (pComboBo =="Cotação" .AND. p = 2)                                                      
    nPos := Ascan(aWBrowse2, {|e| e[3]  == pCod}) //"Numero da Cotação"
Elseif (pComboBo =="Filial" .AND. p = 3)                                                      
    nPos := Ascan(aWBrowse3, {|e| e[11]  == pCod}) //"Numero da Filial"
Elseif (pComboBo =="Pedido" .AND. p = 3)                                                      
    nPos := Ascan(aWBrowse3, {|e| e[3]  == pCod}) //"Numero da Ordem de Compra"
Elseif (pComboBo =="Filial" .AND. p = 4)                                                      
    nPos := Ascan(aWBrowse4, {|e| e[12]  == pCod}) //"Numero da Filial"
Elseif (pComboBo =="Pedido" .AND. p = 4)                                                      
    nPos := Ascan(aWBrowse4, {|e| e[3]  == pCod}) //"Numero da Ordem de Compra"
Elseif (pComboBo =="Cotação" .AND. p = 4)                                                      
    nPos := Ascan(aWBrowse4, {|e| e[6]  == pCod}) //"Numero da Cotação"
Elseif (pComboBo =="Solicitação" .AND. p = 4)                                                      
    nPos := Ascan(aWBrowse4, {|e| e[5]  == pCod}) //"Numero da Solicitação"
Endif
		
If Empty(nPos) 
	Aviso('Atenção', 'Não encontrou registros com este codigo', {'Ok'}) 
Elseif (p = 1)      
	oWBrowse1:nAT := nPos
Elseif (p = 2)      
	oWBrowse2:nAT := nPos
Elseif (p = 3)      
	oWBrowse3:nAT := nPos
Elseif (p = 4)      
	oWBrowse4:nAT := nPos	
Endif  
                                                   
Return()  
//------------------------------------------------ 
//* Funcao para buscar a empresa no banco
// SIGAMAT
//------------------------------------------------ 
******************************
User Function fSIGAMAT()      
******************************

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


****************************************************
Static Function fFilBrw01 
****************************************************
*
*
Local aClassi := {}
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")


aWBrowse1 := {} 
                     
//if Len(aWBrowse1) == 0 
//	Aadd(aWBrowse1,{.F.,oFlagVERMELHO,"","","","","","",""})
//endif   

aEmpresa:=u_fSIGAMAT()// Funcao para buscar as empresas   

fClassi(@aClassi)

For xE:=1 to Len(aEmpresa)   
    
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
      aWBrowse1[oWBrowse1:nAt,13];
    }}
    // DoubleClick event
    oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],;
    oWBrowse1:DrawSelect()}   
    oWBrowse1:Refresh()	

Next    
      
return .T.

*******************************************
Static Function fMarcaT                    
*******************************************
*
*

For nXXCont := 1 To Len(aWBrowse1)
	aWBrowse1[nXXCont,1] := .T.
Next

return 

*******************************************
Static Function fDesMarT                    
*******************************************
*
*

For nXXCont := 1 To Len(aWBrowse1)
	aWBrowse1[nXXCont,1] := .F.
Next

return



*******************************************
Static Function fClassi(aClassi)
*******************************************
*
*

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
***********************************
Static Function FMsgAviso()        
***********************************
                     
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
*************************************************************
Static Function fConsulta(cFilialCon,cPrdConsulta)           
*************************************************************

Local   aArea     := GetArea()
Local   cFilOld   := ""

Private cCadastro := "Historico do Produto" 
Private aRotina   := {{"P&esquisar" ,'AxPesqui'  ,0,1},;
						    {"V&isualizar",'MC050Con()',0,2}}
						
Private nOpcA     := 0
Private cA110Num

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
              cFilialCon   := aWBrowse2[oWBrowse2:nAt,9]
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
   
   Set Key VK_F9	To
   
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
   SetKey( VK_F9, { || fConsulta() })

Endif

Return .t.


*************************************************************
Static Function fConSolic(cFilialCon,cSol)           
*************************************************************

Local   aArea     := GetArea()
Local   cFilOld   := ""

Private cCadastro := "Historico do Produto" 
Private aRotina   := {{"P&esquisar" ,'AxPesqui'  ,0,1},;
						    {"V&isualizar",'MC050Con()',0,2}}
						
Private nOpcA     := 0
Private cA110Num

Default cSol         := ""           
Default cFilialCon   := ""
  
If Empty(cSol) 

Do Case
      Case oFolder1:nOption == 1
           cSol := aWBrowse1[oWBrowse1:nAt,6] 
           cFilialCon   := aWBrowse1[oWBrowse1:nAt,4]                        
      Case oFolder1:nOption == 2                 
              cSol := aWBrowse2[oWBrowse2:nAt,8]
              cFilialCon   := aWBrowse2[oWBrowse2:nAt,6]
      Case oFolder1:nOption == 3
           cSol := aWBrowse3[oWBrowse3:nAt,3 ]      
           cFilialCon   := aWBrowse3[oWBrowse3:nAt,10]
                      
      Case oFolder1:nOption == 4                      
           cSol := aWBrowse4[oWBrowse4:nAt,4 ]      
           cFilialCon   := aWBrowse4[oWBrowse4:nAt,11]
                      
   EndCase   
Endif            

If ! Empty(cSol)

Set Key VK_F10	To
   
   DbSelectArea("SC1")
   DbSetOrder(1)
   If DbSeek(xFilial("SC1") + cSol)

      cFilOld  := cFilAnt
      cFilAnt  := cFilialCon
   
      MsgRun("Carregando informações...",,{|| CursorWait() , U_A110Track(SC1->C1_NUM) ,CursorArrow()})          
             
      cFilAnt := cFilOld
    
   Endif
   RestArea(aArea)
   SetKey( VK_F10, { || fConSolic() })
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
***************************************        
Static Function MCGRPCOM()             
***************************************

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

*************************************
User Function A110Track(cSolic)
*************************************

Local aEnt     := {}
Local cKey     := xFilial("SC1") + cSolic
Local nPosItem := 13//Ascan(oMSNewGeP05:aHeader,{|x|Alltrim(Upper(x[2]))=="C8_PRODUTO"})
Local nLoop    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os itens para rastreamento          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nLoop := 1 To Len(oWBrowse1:aarray)
	AAdd( aEnt, { "SC1", cKey + oWBrowse1:aarray[ nLoop, nPosItem ] } )
Next nLoop

MaTrkShow( aEnt )

Return( .T. )

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
Static Function AFATP1(cNumPed,cFilPed)
*********************************

Local aAliasOLD   := GetArea() 
Local oDlg   
Local oGetDescri  
Local oFontTel    := TFont():New("Arial",10,,,.T.,,,,.F.,.F.)
Private cDescri   := ""
          

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

 	DbSelectArea("SC7")
 	SC7->(DbSetorder(1))
	If SC7->(DbSeek(aWBrowse3[oWBrowse3:nAt,11]+aWBrowse3[oWBrowse3:nAt,3]))	// LOCALIZAR RECNO
	    While !Eof() .And. SC7->C7_FILIAL+SC7->C7_NUM == aWBrowse3[oWBrowse3:nAt,11]+aWBrowse3[oWBrowse3:nAt,3]
			  RecLock("SC7",.F.)   
			   SC7->C7_TPMSG   := cDescri
			   SC7->C7_TPOKMSG := '2'
			  MsUnlock()	  
	    SC7->(dbSkip())
	    EndDo
    Endif

MsgInfo("Observação anexada ao Pedido.")    
oDlg:End()    
 
Return(.T.)    
	                                                                                                                                            