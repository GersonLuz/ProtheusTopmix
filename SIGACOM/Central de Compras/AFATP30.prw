#INCLUDE "RWMAKE.CH"
#include "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH" 

/*------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                          -                                                    
--------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 01/03/2019  - 
--------------------------------------------------------------------------------------
                                   PROGRAMA: AFATP30                                 -
--------------------------------------------------------------------------------------
                   FUNÇÃO PARA MONTAR TELA DE HISTÓRICO DE PRODUTOS                  -
-------------------------------------------------------------------------------------*/ 

********************************
User Function AFATP30()
********************************

Local nPosCod := Ascan(oMSNewGeP05:aHeader,{|x|Alltrim(Upper(x[2]))=="C8_PRODUTO"})
Private cProduto

If !AtIsRotina("MACOMVIEW")
	If !Empty(oMSNewGeP05:aCols[oMSNewGeP05:nAt][nPosCod])
		U_MaComView(oMSNewGeP05:aCols[oMSNewGeP05:nAt][nPosCod])
	EndIf
EndIf

Return

********************************************
User Function MaComView(cProduto)
********************************************

Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local aCpos		:= {}
Local nCntFor
Local nRecSB1
Local oBold
Local oDlg
Local lContCT  := .T.
Local lContPC  := .T.
Local lContNF  := .T.

Private aTELA[0][0],aGETS[0]
Private lRefresh	:= .T.
Private Inclui		:= .F.
Private Altera		:= .F.
Private aViewSC8
Private aViewSC7
Private aViewNF
Private aRecSD1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o cadastro de produtos                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SB1')
dbSetOrder(1)
If MsSeek(xFilial()+cProduto)

	dbSelectArea("SX3")
	dbSetOrder(1)
	If MsSeek("SB1")
		While ( !Eof() .And. SX3->X3_ARQUIVO == "SB1" )
			If X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. !(AllTrim(X3_CAMPO)$"B1_COD/B1_DESC")
				aAdd(aCpos,X3_CAMPO)                                                                
			EndIf                                                      	
			dbSkip()
		Enddo
	   	RegToMemory("SB1", .F., .F. )
		DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	   	DEFINE MSDIALOG oDlg FROM 0,0  TO 140,600 TITLE "Histórico de Compras - TOPMIX" Of oMainWnd PIXEL      //   'Historico de Compras'
        //EnChoice("SB1", nRecSB1, 1, , , , aCpos ,{20,2,150,298} , ,3 )
	  	@ 037 ,10  BUTTON "Ultimos Pedidos" SIZE 45 ,10  FONT oDlg:oFont ACTION MaComViewPC(SB1->B1_COD,lContPC)  OF oDlg PIXEL  //"Ultimos Pedidos"
	  	@ 037 ,56  BUTTON "Ultimas Cotacoes" SIZE 45 ,10  FONT oDlg:oFont ACTION MaComViewCT(SB1->B1_COD,lContCT)  OF oDlg PIXEL  //"Ultimas Cotacoes"
	  	@ 037 ,102 BUTTON "Consumo" SIZE 45 ,10  FONT oDlg:oFont ACTION MaComViewSm(SB1->B1_COD)  OF oDlg PIXEL  //"Consumo"
	  	@ 037 ,148 BUTTON "Ultimas N.Fiscais" SIZE 45 ,10  FONT oDlg:oFont ACTION MaComViewNF(SB1->B1_COD,lContNF)  OF oDlg PIXEL  //"Ultimas N.Fiscais"
	  	@ 037 ,194 BUTTON "Consulta Estoques" SIZE 49 ,10  FONT oDlg:oFont ACTION MaViewSB2(SB1->B1_COD)  OF oDlg PIXEL  //"Consulta Estoques"
		@ 037 ,244 BUTTON "Sair" SIZE 45 ,10  FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL  //"Sair"
		@ 4  ,10   SAY Alltrim(cProduto)+ " - "+SB1->B1_DESC Of oDlg PIXEL SIZE 245 ,9 FONT oBold
	   	@ 13, 4 To 14,302 Label "" of oDlg PIXEL
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
Endif

RestArea(aAreaSX3)
RestArea(aAreaSB1)
RestArea(aArea)
Return Nil


