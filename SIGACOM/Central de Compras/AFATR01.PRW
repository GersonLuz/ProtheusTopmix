//Impressao do pedido de compra
//20/02/2014

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RWMAKE.CH"    
                                                                                                                                          
#DEFINE VBOX      080  //080
#DEFINE VSPACE    008  
#DEFINE HSPACE    010
#DEFINE SAYVSPACE 008
#DEFINE SAYHSPACE 008
#DEFINE HMARGEM   040 
#DEFINE VMARGEM   010 
#DEFINE MAXITEM   010 //30
#DEFINE MAXITEMP2 018
#DEFINE MAXITEMP3 055
#DEFINE MAXMENLIN 070   
#DEFINE MAXITEMC  046                                               // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMSG    007                                                // Máximo de dados adicionais por página
#DEFINE MAXBOXH   800                                                // Tamanho maximo do box Horizontal
#DEFINE MAXBOXV   600
#DEFINE VBOXI     800 
//#DEFINE RODAPE    2600

******************************************
User Function AFATR01(cXXNumPed)
******************************************  

Local aAliasOLD := GetArea()
Private nRodape := Val(GetNewPar("MV_RODAPC","2600")) 
 

If "MATA12" $FunName()
	cXXNumPed := SC7->(Recno())
EndIf

if Empty(cXXNumPed)
	ApMsgInfo("Não existe Pedido de Compra a ser impresso !!!")
	return
endif   

fFATR01(cXXNumPed)

RestArea(aAliasOLD)

Return()

Static  Function fFATR01(pReg)

Local oOrdCompra
Local aArea     := GetArea()
Local cPerg     :="AFAR01"   

If pReg= NIL
	CriaPerg(cPerg)        
	IF !Pergunte(cPerg,.T.)       // Pergunta no SX1A
	   Return
	EndIf         
Endif
oOrdCompra:= TMSPrinter():New("ORDEM DE COMPRA")
oOrdCompra:Setup()
oOrdCompra:SetPortrait() //Seta Como Retrato     

//oOrdCompra:SetLandscape() //Seta Como Paisagem

Private PixelX := oOrdCompra:nLogPixelX()
Private PixelY := oOrdCompra:nLogPixelY()
Private lCabec := .T. 
	
RptStatus({|lEnd| OrdCompra(@oOrdCompra,@lEnd,pReg)},"Imprimindo...")

oOrdCompra:Preview()//Visualiza antes de imprimir    
//oOrdCompra:Print()//Imprimir direto


RestArea(aArea)
Return(.T.)
         

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OrdCompra    ³ Autor ³ Jose Antonio      ³ Data ³19.02.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rdmake de exemplo para impressão da ordem de produçao       ³±±
±±³          ³ Formato retrato                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function OrdCompra(oOrdCompra,lEnd,pReg)
Local aArea      := GetArea()      

ImpDet(@oOrdCompra,pReg)
          
RestArea(aArea)
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpDet   ³ Autor ³ Jose Antonio         ³ Data ³19.02.2013³ ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpDet(oOrdCompra,pReg)
PRIVATE oFont06    := TFontEx():New(oOrdCompra,"Arial",07,07,.F.,.T.,.F.)
PRIVATE oFont06N   := TFontEx():New(oOrdCompra,"Arial",07,07,.T.,.T.,.F.)
PRIVATE oFont10n   := TFontEx():New(oOrdCompra,"Arial",10,10,.T.,.T.,.F.)
PRIVATE oFont08    := TFontEx():New(oOrdCompra,"Arial",08,08,.F.,.T.,.F.)
PRIVATE oFont08N   := TFontEx():New(oOrdCompra,"Arial",08,08,.T.,.T.,.F.)
PRIVATE oFont07    := TFontEx():New(oOrdCompra,"Arial",07,07,.F.,.T.,.F.) 
PRIVATE oFont07N   := TFontEx():New(oOrdCompra,"Arial",08,08,.T.,.T.,.F.)
PRIVATE oFont10    := TFontEx():New(oOrdCompra,"Arial",10,10,.F.,.T.,.F.)
PRIVATE oFont11    := TFontEx():New(oOrdCompra,"Arial",11,11,.F.,.T.,.F.)
PRIVATE oFont11N   := TFontEx():New(oOrdCompra,"Arial",13,09,.T.,.T.,.F.)
PRIVATE oFont12    := TFontEx():New(oOrdCompra,"Arial",12,10,.F.,.T.,.F.)
PRIVATE oFont12N   := TFontEx():New(oOrdCompra,"Arial",14,09,.T.,.T.,.F.)
PRIVATE oFont17N   := TFontEx():New(oOrdCompra,"Arial",17,17,.T.,.T.,.F.)
PRIVATE oFont18N   := TFontEx():New(oOrdCompra,"Arial",18,18,.T.,.T.,.F.)
PRIVATE oFont13N   := TFontEx():New(oOrdCompra,"Arial",08,08,.T.,.T.,.F.)
PRIVATE oFont14    := TFontEx():New(oOrdCompra,"Arial",09,09,.F.,.T.,.F.)
PRIVATE oFont14N   := TFontEx():New(oOrdCompra,"Arial",16,14,.T.,.T.,.F.)

PrtOrCompra(@oOrdCompra,pReg)

Return (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrtOrCompra ³ Autor ³Jose Antonio      ³ Data ³19/02/2013   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do formulario de Ordem de Produçao                ³±±
±±³          ³laytout no formato retrato                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
*/

Static Function PrtOrCompra(oOrdCompra,pReg)
Local aTamanho   := {}
Local aAux       := {}      
Local nHPage     := 0 
Local nVPage     := 0 
Local nPosV      := 0
Local nPosVOld   := 0
Local nPosH      := 0
Local nPosHOld   := 0
Local nAuxH      := 0
Local nX         := 0
Local nY         := 0
Local nTamanho   := 0
Local nItem      := 0
Local lPreview   := .F. 
Local cLogoR     := Iif(cEmpAnt=="01","\Imagens\TopMix_Totvs_Rel.png","\Imagens\Flapa_Totvs_Rel.png")
Local nLimite    :=150  
Local nLinCalc   :=0
Local cAux       := ""
Local cZOBSPED   := Alltrim(GetNewPar("MV_ZOBSPED","É OBRIGATÓRIO A IDENTIFICAÇÃO DO PEDIDO NA NF, PARA GARANTIR SEU PGTO."))// 
Local cZOBSNFE   := Alltrim(GetNewPar("MV_ZOBSNFE","MENSAGEM DA NOTA FISCAL."))// 
Local cZOBSNFC   := Alltrim(GetNewPar("MV_ZOBSNFC","MENSAGEM DA NOTA FISCAL."))// 
Local nLinSCR    :=0   
Local nLinSZ4    :=0
Private cAliasTRB:= GetNextAlias()
Private cItem   
Private nFolha   := 1
Private nFolhas  := 0
Private aItens   :={}     
Private aDetProd :=Array(6)   
Private aDadCont :=Array(20) 

Private lLiber   := .T.

aDetProd[1] := 0  
aDetProd[2] := 0  
aDetProd[3] := 0  
aDetProd[4] := ""
aDetProd[5] := 0 
aDetProd[6] := 0 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao do vetor do itens                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
dbSelectArea("SC7") 
dbGoto(pReg)   

cFilAux:=SC7->C7_FILIAL
cNum   :=SC7->C7_NUM                                                               

SA2->(DbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))

dbSelectArea("SC7")
dbSetOrder(1)
dbGoTop() 
dbSeek(cFilAux+cNum,.T.)  
aDadCont[01]:=Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME")
aDadCont[02]:=Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_CGC")
aDadCont[19]:=Alltrim(SA2->A2_END) + "/" + Alltrim(SA2->A2_BAIRRO)
aDadCont[20]:="("+SA2->A2_DDD+") " + Alltrim(Transform(SA2->A2_TEL,"@R !!!!-!!!!!!!"))
aDadCont[03]:=SC7->C7_NUMCOT
aDadCont[04]:=SC7->C7_USER 
aDadCont[05]:=SC7->C7_NUMSC 
aDadCont[09]:=""//"TOPMIX"
aDadCont[10]:="" //DIMENSÕES
aDadCont[11]:=""//"PESO"
aDadCont[12]:=""//"TIPO DE EMBALAGEM"
aDadCont[16]:=""
aDadCont[17]:=SC7->C7_TPFRETE
aDadCont[18]:=SC7->C7_COND

dbSelectArea("SC8")
dbSetOrder(1)
IF dbSeek(xFilial("SC8")+aDadCont[03],.F.)
//    aDadCont[04]:=SC8->C8_NUM 
    aDadCont[08]:=SC8->C8_PRAZO
Else
    aDadCont[08]:=0
//    aDadCont[04]:=""   
Endif	
dbSelectArea("SC1")
dbSetOrder(1)        
//IF dbSeek(xFilial("SC1")+aDadCont[05],.T.)  
IF dbSeek(SC7->C7_FILIAL + aDadCont[05],.T.)
	aDadCont[06]:=SC1->C1_ZAPLIC 
	aDadCont[07]:=SC1->C1_SOLICIT
  	aDadCont[13]:=SC1->C1_ZFILFAT
  	aDadCont[14]:=IIf(Empty(SC7->C7_FILENT),SC1->C1_FILENT,SC7->C7_FILENT)
Else
	aDadCont[06]:=""//SC1->C1_APLIC 
	aDadCont[07]:=""// SC1->C1_NOMSOLI
  	aDadCont[13]:=xFilial("SC7")
  	aDadCont[14]:=IIf(Empty(SC7->C7_FILENT),xFilial("SC7"),SC7->C7_FILENT)
Endif

If Empty(aDadCont[06]) .Or. Empty(aDadCont[07]) .Or. Empty(aDadCont[13]) .Or. Empty(aDadCont[14])
   cQueryC1 := "SELECT DISTINCT C1_ZAPLIC,C1_SOLICIT,C1_ZFILFAT,C1_FILENT FROM "+RetSqlName("SC1")+" WHERE C1_NUM = '"+aDadCont[05]+"' AND C1_FILIAL = '"+SC7->C7_FILIAL+"' AND D_E_L_E_T_ <> '*'"
   dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQueryC1) , cAliasTRB , .T. , .F.)
   DbSelectArea(cAliasTRB)
	aDadCont[06] := (cAliasTRB)->C1_ZAPLIC
	aDadCont[07] := (cAliasTRB)->C1_SOLICIT
	aDadCont[13] := (cAliasTRB)->C1_ZFILFAT
	aDadCont[14] := IIf(Empty(SC7->C7_FILENT),(cAliasTRB)->C1_FILENT,SC7->C7_FILENT)
   DbCloseArea()	    
Endif

dbSelectArea("SC8")
dbSetOrder(3)

dbSelectArea("SC7")
dbSetOrder(1)
dbGoTop() 
dbSeek(cFilAux+cNum,.T.) 

While !SC7->(Eof()) .And. SC7->C7_FILIAL  == cFilAux;
				    .And. SC7->C7_NUM     == cNum 	 
	 cAux := ""
	 
	 dbSelectArea("SB1")
	 dbSeek(xFilial("SB1")+SC7->C7_PRODUTO)
	 
	 //busca dados adicionais na impressão da OC / Ale
	 dbSelectArea("SC8")
	 dbSeek(SC7->C7_FILIAL + SC7->C7_NUMCOT + SC7->C7_PRODUTO + SC7->C7_FORNECE + SC7->C7_LOJA)
    If !Empty(SC8->C8_ZPRDSUB)
	   //	SB1->(MsSeek(xFilial("SB1")+SC8->C8_ZPRDSUB))
    	cAux := " (" + Alltrim(SB1->B1_FABRIC) +"/" + Alltrim(SB1->B1_ZREF2) + ")" 
	 ElseIf !Empty(SB1->B1_FABRIC) .Or. !Empty(SB1->B1_ZREF1)   
    	cAux := " (" + Alltrim(SB1->B1_FABRIC) +"/" + Alltrim(SB1->B1_ZREF1) + ")" 
	 EndIf   
	 cDescri:=Alltrim(SC7->C7_DESCRI)
	 
	 dbSelectArea("SC1")
	 If !dbSeek(SC8->C8_FILIAL + SC8->C8_NUMSC + SC8->C8_ITEMSC)
	 	dbSeek(SC8->C8_FILIAL + SC8->C8_NUMSC)
	 EndIF
	 
	 cAux := cDescri + " " +cAux +  " " + Alltrim(SC7->C7_ZOBSADI)
	 
	 aDescri:={}          
	 nTam:=50
	 aDescri := fQuebraTxt(cAux,nTam)

	 cItem:="" 

  	 cItem:=SC7->C7_ITEM

	 For x1:=1 to Len(aDescri)
			 
		If x1==1			 
			 Aadd(aItens,{cItem,;
		 	 			  SC7->C7_PRODUTO,;
			 			  aDescri[x1],;
			   		      SC7->C7_UM,;        
			 			  Transform(SC7->C7_QUANT,"@E 999,999,999.99"),;
			 			  Transform(SC7->C7_PRECO,"@E 999,999,999.99"),;
		 	 			  Transform(SC7->C7_TOTAL,"@E 99,999,999,999.99"),;         //  "",;
			 			  Transform(SC7->C7_VLDESC,"@E 99,999,999,999.99"),;
			 			  dtoc(SC7->C7_DATPRF),;
			 			  SC7->C7_ZAPLIC,;
			 			  SC7->C7_CC,;
			 			  Alltrim(SB1->B1_ZREF1)})  
    	Else

			 Aadd(aItens,{cItem,;
		 	 			  space(10),;
			 			  aDescri[x1],;
			   		  space(2),;        
			 			  space(10),;
			 			  space(10),;
		 	 			  space(10),;//  "",;
			 			  space(10),;
			 			  space(10),;
			 			  space(10),;
			 			  space(10),;
			 			  space(10)})  
		EndIf
	 Next	 	 			  
		 aDetProd[1] += SC7->C7_TOTAL 
		 aDetProd[2] += SC7->C7_VALFRE
		 aDetProd[3] += SC7->C7_VLDESC 
		 aDetProd[4] := SC7->C7_COND 
		 aDetProd[5] += SC7->C7_VALIPI 
		 aDetProd[6] += SC7->C7_VALICM  
		 
	if Alltrim(SC7->C7_CONAPRO) == "B"
		lLiber := .F.
	endif		 
		  
	dbselectArea("SC7")
	dbSkip()
Enddo                                               

//aSort( aItens,,, { |x,y| x[1] < y[1] } )

                     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do numero de folhas                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nFolhas := 1
nLenItens := Len(aItens)
nLen := nLenItens 
If nLen > MAXITEM 
	nFolhas += Int(nLen / MAXITEM)
	If Mod(nLen, MAXITEM) > 0
		nFolhas++
	EndIf
EndIf           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao do objeto grafico                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oOrdCompra == Nil
	lPreview := .T.
	oOrdCompra 	:= TMSPrinter():New("ORDEM DE COMPRA")
	oOrdCompra:SetLandscape() //Seta Como Paisagem
	oOrdCompra:Setup()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao da pagina do objeto grafico                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oOrdCompra:StartPage()
oOrdCompra:SetPaperSize(Val(GetProfString(GetPrinterSession(),"PAPERSIZE","1",.T.)))
nHPage := oOrdCompra:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oOrdCompra:nVertRes() 
nVPage *= (300/PixelY)
nVPage -= VBOX
nPosHOld := VMARGEM

nPosV    += (VBOX/2)
nPosV    := OrdCab(oOrdCompra,nPosV,@nFolha,nFolhas)

nPosV:= fImpProd(oOrdCompra,nPosV)
               
nLinCalc:= nPosV+15                                                               

If nPosV  >  (nVPage - 120)          
	oOrdCompra:EndPage()
	oOrdCompra:StartPage()
	nPosV:=OrdCab(oOrdCompra,nPosV,@nFolha,nFolhas)
	nLinCalc:=nPosV
Endif          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//  FINAL DE PEDIDO
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 

	aPos:={{nPosHOld,0400},{0400,0800},{0800,1200},{1200,1600},{1600,2000},{2000,nHPage}}
	                                                       
	oOrdCompra:Box(nLinCalc+2 ,aPos[1,1],nLinCalc+120,aPos[1,2])
	oOrdCompra:Say(nLinCalc+10,aPos[1,1]+5,"TOTAL PEDIDO",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+60,aPos[1,1]+70,Transform(aDetProd[01],"@E 999,999,999.99"),oFont08:oFont)

	oOrdCompra:Box(nLinCalc+2 ,aPos[2,1],nLinCalc+120,aPos[2,2])
	oOrdCompra:Say(nLinCalc+10,aPos[2,1]+5,"FRETE",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+60,aPos[2,1]+70,Transform(aDetProd[02],"@E 999,999,999.99"),oFont08:oFont)

	oOrdCompra:Box(nLinCalc+2 ,aPos[3,1],nLinCalc+120,aPos[3,2])
	oOrdCompra:Say(nLinCalc+10,aPos[3,1]+5,"DESCONTO",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+60,aPos[3,1]+70,Transform(aDetProd[03],"@E 999,999,999.99"),oFont08:oFont)

	oOrdCompra:Box(nLinCalc+2 ,aPos[4,1],nLinCalc+120,aPos[4,2])
	oOrdCompra:Say(nLinCalc+10,aPos[4,1]+5,"IPI",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+60,aPos[4,1]+70,Transform(aDetProd[05],"@E 999,999,999.99"),oFont08:oFont)
	
	oOrdCompra:Box(nLinCalc+2 ,aPos[5,1],nLinCalc+120,aPos[5,2])
	oOrdCompra:Say(nLinCalc+10,aPos[5,1]+5,"ICMS",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+60,aPos[5,1]+70,Transform(aDetProd[06],"@E 999,999,999.99"),oFont08:oFont)	

	oOrdCompra:Box(nLinCalc+2 ,aPos[6,1],nLinCalc+120,aPos[6,2])
	oOrdCompra:Say(nLinCalc+10,aPos[6,1]+5,"TOTAL LÍQUIDO",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+60,aPos[6,1]+80,Transform(aDetProd[01]+aDetProd[2]-aDetProd[3]+aDetProd[5] ,"@E 999,999,999.99"),oFont08:oFont)

	nLinCalc+=120  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//                                                                      60
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	aPos:={{nPosHOld,nHPage}}

 	nLinSCR  :=0
	dbSelectArea("SCR")
	dbSetOrder(1)
	if dbSeek(cFilAux+"PC"+cNum+Space(44) , .T.)
			While !Eof("SCR") .And. SCR->CR_FILIAL == cFilAux .And. Alltrim(SCR->CR_TIPO) == "PC" .And. Alltrim(cNum) == Alltrim(SCR->CR_NUM)
				nLinSCR+= 50
				dbSelectArea("SCR")
				dbSkip()
			enddo
	endif                                
		
	nLinSZ4 := 0
	dbSelectArea("SZ4")
	dbSetOrder(1)
	cDescri:=""
	If dbSeek(cFilAux+cNum)
			cDescri:=SZ4->Z4_OBS
	endif 
	nTam:=70 // Tamanho da linha  
	For J := 1 To MlCount(cDescri,nTam)
			If !Empty(MemoLine(cDescri,nTam,J))
	  			nLinSZ4+= 50
	        Endif        
	Next                      
	nLinNFE:=0
	For J := 1 To MlCount(cZOBSNFE,nTam)
			If !Empty(MemoLine(cZOBSNFE,nTam,J))
	  			nLinNFE+= 50
	      Endif        
	Next                      
	nLinZ :=	120  //P E D I D O / O B S E R V A Ç Õ E S
	nLinZ +=	100  // APROVADOR(ES)
	   
   //	80 MENSAGEM DE NOTA FISCAL CAB
	If nLinCalc > nRODAPE
		oOrdCompra:EndPage()
		oOrdCompra:StartPage()
		nPosV:=OrdCab0(oOrdCompra,nPosV,@nFolha,nFolhas)
		nLinCalc:=nPosV
 	Endif

 
	aPos:={{nPosHOld,700},{0700,nHPage}}  
	
	nLinCalc:=nRODAPE   // RODAPE FIXO 17/04/2015 JOSE ANTONIO JEAM
	
	if lLiber
		oOrdCompra :Say(nLinCalc+50,aPos[1,1]+160,"P E D I D O   L I B E R A D O",oFont11N:oFont)
	else                                                                                                                                                          
		oOrdCompra :Say(nLinCalc+50,aPos[1,1]+160,"P E D I D O   B L O Q U E A D O",oFont11N:oFont)
	endif
	
	oOrdCompra :Say(nLinCalc+50,aPos[2,1]+460,"O B S E R V A Ç Õ E S",oFont11N:oFont)

	oOrdCompra:Box(nLinCalc,aPos[1,1], nLinCalc+120,aPos[1,2]) 
	oOrdCompra:Box(nLinCalc,aPos[2,1], nLinCalc+120,aPos[2,2]) 
	
	nLinCalc+= 90

  	oOrdCompra:Box(nLinCalc,aPos[1,2], nVPage,aPos[1,2]) 

	nLinAux:=nLinCalc +50
	oOrdCompra :Say(nLinCalc+50,aPos[1,1]+15,"APROVADOR(ES)",oFont11N:oFont)
	nLinCalc+= 100  
	
	cQueryCR := "SELECT CR_USER,CR_LIBAPRO,CR_DATALIB FROM "+RetSqlName("SCR")+" WHERE D_E_L_E_T_ <> '*' AND CR_NUM = '"+cNum+"' AND CR_TIPO = 'PC' ORDER BY CR_NIVEL,CR_APROV"
   dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQueryCR) , cAliasTRB , .T. , .F.)
   DbSelectArea(cAliasTRB)
	While ! (cAliasTRB)->(Eof())
        oOrdCompra :Say(nLinCalc,aPos[1,1]+20,UsrFullName((cAliasTRB)->CR_USER)+Iif(!Empty((cAliasTRB)->CR_LIBAPRO)," - [OK] - "+dtoc(Stod((cAliasTRB)->CR_DATALIB)),"[??]"),oFont08:oFont)	
		  nLinCalc+= 50
        dbSelectArea(cAliasTRB)
		  (cAliasTRB)->(dbSkip())
	enddo
   (cAliasTRB)->(DbCloseArea())
   
	nLinCalc+= 100  
	
	nLinCalc:=nLinAux

	oOrdCompra :Say(nLinCalc,aPos[2,1]+20,cZOBSPED,oFont08N:oFont)	
 	nLinCalc+= 40
  	oOrdCompra:Box(nLinCalc,aPos[2,1], nLinCalc,aPos[2,2]) 
 	nLinCalc+= 25  

	dbSelectArea("SZ4")
	dbSetOrder(1)
	cDescri:=Space(180)
	If dbSeek(cFilAux+cNum)
			cDescri:=Alltrim(SZ4->Z4_OBS)
	endif    
	aDescri:={}          
	nTam:=100
	aDescri := fQuebraTxt(cDescri,nTam)
 	If len(aDescri)>0
 		cDesAux := "MENSAGEM DO PEDIDO: "
		oOrdCompra :Say(nLinCalc,aPos[2,1]+20,cDesAux ,oFont08N:oFont)	
		nLinCalc+= 35 
	Endif
	For J := 1 To Len(aDescri)
	 	cDesAux:=aDescri[J]
		oOrdCompra :Say(nLinCalc,aPos[2,1]+20,cDesAux ,oFont08:oFont)	
 		nLinCalc+= 35
    Next                      

  	nLinCalc+= 20
  	oOrdCompra:Box(nLinCalc,aPos[2,1], nLinCalc,aPos[2,2]) 
   cDesAux := "MENSAGEM NOTA FISCAL: "
	oOrdCompra :Say(nLinCalc,aPos[2,1]+20,cDesAux ,oFont08N:oFont)	
	nLinCalc+= 35 
	
	cZOBSNFE:=cZOBSNFE+" "+cZOBSNFC
	aDescri:={}          
	nTam:=120
	aDescri := fQuebraTxt(cZOBSNFE,nTam)

	For J := 1 To Len(aDescri)
	 	cDesAux:=aDescri[J]
		oOrdCompra :Say(nLinCalc,aPos[2,1]+20,cDesAux ,oFont08:oFont)	
 		nLinCalc+= 35
   Next                      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finaliza a Impressão                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oOrdCompra:EndPage()


Return(nPosV)
                   
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao do Cabecalho do documento                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function OrdCab0(oOrdCompra,nPosV,nFolha,nFolhas,pPag)

Local aTamanho   := {}
Local nHPage     := 0
Local nVPage     := 0 
Local nPosVOld   := 0
Local nPosH      := 0
Local nPosHOld   := 0
Local nAuxV      := 0
Local nAuxH      := 0
Local nLinCalc   :=0     
//Local cLogo    := "CABTOPMIX.jpg"  // FisxLogo("4") 
Local cStartPath:= GetSrvProfString("StartPath","")
//Local cLogo 	:= cStartPath + "FlpTop_V1.bmp"//cStartPath + "lgrl"+cEmpAnt+".bmp" 	//Logo
Local cLogo 	:= Iif(cEmpAnt=="01","\Imagens\TopMix_Totvs_Rel.png","\Imagens\Flapa_Totvs_Rel.png")
 
nHPage := oOrdCompra:nHorzRes() // 2418
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oOrdCompra:nVertRes() 
nVPage *= (300/PixelY)
nVPage -= VBOX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 1                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosVOld := 50    //nPosV
nPosV    := 400  
nPosHOld1:= VMARGEM
nPosH    := 500  //350   

	oOrdCompra:Box(nPosVOld,nPosHOld1,nVPage,nHPage)
	
 //oOrdCompra:Box(nPosVOld,nPosHOld1,nPosV,nPosH)   // Primeiro quadro

	oOrdCompra:SayBitmap(nPosVOld+5,nPosHOld1+5,cLogo,430,350)
	
	nAuxV := nPosVOld  + SAYVSPACE
	nAuxH := nPosHOld1 + SAYHSPACE+440 //490
   
	oOrdCompra:Box(nPosVOld,nPosHOld1,nPosV,nPosH+1400) //Segundo quando no PEDIDO  
	
	oOrdCompra:Box(nPosVOld,nPosHOld1,nPosV,nHPage) 
	oOrdCompra:Say(nAuxV,nAuxH+5,Alltrim(SM0->M0_NOMECOM), oFont17N:oFont)

	oOrdCompra:Say(nAuxV+070,nPosH+1570,"PEDIDO",oFont14N:oFont) 
	oOrdCompra:Say(nAuxV+080,nAuxH+5,SM0->M0_ENDCOB, oFont12N:oFont)
	oOrdCompra:Say(nAuxV+125,nAuxH+5,Transform(SM0->M0_CEPCOB,"@R 99.999-999")+" - "+Alltrim(SM0->M0_CIDCOB)+" - "+SM0->M0_ESTCOB, oFont12N:oFont)
	oOrdCompra:Say(nAuxV+130,nPosH+1420," ",oFont12N:oFont) 
	oOrdCompra:Say(nAuxV+170,nAuxH+5,Transform(StrTran(SM0->M0_TEL,"-",""),"@R 99(99)9999-9999")+" FAX: "+Transform(StrTran(SM0->M0_TEL,"-",""),"@R 99(99)9999-9999"), oFont12N:oFont)
	oOrdCompra:Say(nAuxV+180,nPosH+1570,cNUM,oFont14N:oFont) 
	
	if cEmpAnt == "01"
		oOrdCompra:Say(nAuxV+215,nAuxH+5,"www.topmix.com.br", oFont12N:oFont)
	else                                                                     
		oOrdCompra:Say(nAuxV+215,nAuxH+5,"www.flapa.com.br", oFont12N:oFont)
	end
	//oOrdCompra:Say(nAuxV+250,nPosH+1460,"DATA  "+DTOC(ddatabase),oFont14N:oFont) 
	
	//if cEmpAnt == "01"//TopMix
	//	oOrdCompra:Say(nAuxV+260,nAuxH+5,"topmix@topmix.com.br", oFont12N:oFont)
	//else                                                                        
	//	oOrdCompra:Say(nAuxV+260,nAuxH+5,"topmix@topmix.com.br", oFont12N:oFont)
	//endif
	
	oOrdCompra:Say(nAuxV+300,nAuxH+5,"CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")+" INSC. EST.: "+Transform(SM0->M0_INSC,"@R 999.999.999.9999"), oFont12N:oFont)
    
	MSBAR3("CODE128",1.8*(300/PixelY),11.65*(299/PixelX),cNUM	,oOrdCompra,/*lCheck*/,/*Color*/,/*lHorz*/,.02960,0.9,/*lBanner*/,/*cFont*/,"C",.F.)
 
	nPosV    := 400
	nFolha++    
	  
Return(nPosV)

 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao do Cabecalho do documento                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function OrdCab(oOrdCompra,nPosV,nFolha,nFolhas,pPag)

Local aTamanho   := {}
Local nHPage     := 0
Local nVPage     := 0 
Local nPosVOld   := 0
Local nPosH      := 0
Local nPosHOld   := 0
Local nAuxV      := 0
Local nAuxH      := 0
Local nLinCalc   :=0     
//Local cLogo    := "CABTOPMIX.jpg"  // FisxLogo("4") 
Local cStartPath:= GetSrvProfString("StartPath","")
//Local cLogo 	:= cStartPath + "FlpTop_V1.bmp"//cStartPath + "lgrl"+cEmpAnt+".bmp" 	//Logo
Local cLogo 	:= Iif(cEmpAnt=="01","\Imagens\TopMix_Totvs_Rel.png","\Imagens\Flapa_Totvs_Rel.png")


 
nHPage := oOrdCompra:nHorzRes() // 2418
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oOrdCompra:nVertRes() 
nVPage *= (300/PixelY)
nVPage -= VBOX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 1                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosVOld := 50    //nPosV
nPosV    := 400  
nPosHOld1:= VMARGEM
nPosH    := 500  //350   

	oOrdCompra:Box(nPosVOld,nPosHOld1,nVPage,nHPage)
	
	//oOrdCompra:Box(nPosVOld,nPosHOld1,nPosV,nPosH)
	
	oOrdCompra:SayBitmap(nPosVOld+5,nPosHOld1+5,cLogo,430,350)
	
	nAuxV := nPosVOld  + SAYVSPACE
	nAuxH := nPosHOld1 + SAYHSPACE+440 //490
   
	oOrdCompra:Box(nPosVOld,nPosHOld1,nPosV,nPosH+1400) //jose  
	
	oOrdCompra:Box(nPosVOld,nPosHOld1,nPosV,nHPage) 
	oOrdCompra:Say(nAuxV,nAuxH+5,Alltrim(SM0->M0_NOMECOM), oFont17N:oFont)
                                  
   //430
   
	oOrdCompra:Say(nAuxV+070,nPosH+1570,"PEDIDO",oFont14N:oFont) 
	oOrdCompra:Say(nAuxV+080,nAuxH+5,SM0->M0_ENDCOB, oFont12N:oFont)
	oOrdCompra:Say(nAuxV+125,nAuxH+5,Transform(SM0->M0_CEPCOB,"@R 99.999-999")+" - "+Alltrim(SM0->M0_CIDCOB)+" - "+SM0->M0_ESTCOB, oFont12N:oFont)
	oOrdCompra:Say(nAuxV+130,nPosH+1420," ",oFont12N:oFont) 
	oOrdCompra:Say(nAuxV+170,nAuxH+5,Transform(StrTran(SM0->M0_TEL,"-",""),"@R 99(99)9999-9999")+" FAX: "+Transform(StrTran(SM0->M0_TEL,"-",""),"@R 99(99)9999-9999"), oFont12N:oFont)
	oOrdCompra:Say(nAuxV+180,nPosH+1570,cNUM,oFont14N:oFont) 
	
	if cEmpAnt == "01"
		oOrdCompra:Say(nAuxV+215,nAuxH+5,"www.topmix.com.br", oFont12N:oFont)
	else                                                                     
		oOrdCompra:Say(nAuxV+215,nAuxH+5,"www.flapa.com.br", oFont12N:oFont)
	end
	//oOrdCompra:Say(nAuxV+250,nPosH+1460,"DATA  "+DTOC(ddatabase),oFont14N:oFont) 
	
	//if cEmpAnt == "01"//TopMix
	//	oOrdCompra:Say(nAuxV+260,nAuxH+5,"topmix@topmix.com.br", oFont12N:oFont)
	//else                                                                        
	//	oOrdCompra:Say(nAuxV+260,nAuxH+5,"topmix@topmix.com.br", oFont12N:oFont)
	//endif
	
	oOrdCompra:Say(nAuxV+300,nAuxH+5,"CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")+" INSC. EST.: "+Transform(SM0->M0_INSC,"@R 999.999.999.9999"), oFont12N:oFont)
    
	MSBAR3("CODE128",1.8*(300/PixelY),11.65*(299/PixelX),cNUM	,oOrdCompra,/*lCheck*/,/*Color*/,/*lHorz*/,.02960,0.9,/*lBanner*/,/*cFont*/,"C",.F.)

	nPosV    := 400

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³DADOS CONTRATOS                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                
	nLinCalc:=nPosV    
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Contrato                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aPos:={{nPosHOld1,1800},{1800,nHPage}}
    
    //oOrdCompra:Box(nLinCalc+02,aPos[1,1],nLinCalc+100,aPos[1,2])       
	//oOrdCompra:Say(nLinCalc+05,aPos[1,1]+5,"UNIDADE ",oFont08:oFont)
  	//oOrdCompra:Say(nLinCalc+50,aPos[1,1]+5,aDadCont[16],oFont08N:oFont)
    
    //oOrdCompra:Box(nLinCalc+02,aPos[2,1],nLinCalc+100,aPos[2,2])       
	//oOrdCompra:Say(nLinCalc+05,aPos[2,1]+5,"SOLICITANTE",oFont08:oFont)
  	//oOrdCompra:Say(nLinCalc+50,aPos[2,1]+5,aDadCont[07],oFont08N:oFont)
	
	If lCabec	
	oOrdCompra:Say(nLinCalc+05,aPos[1,1]+5,"SOLICITANTE",oFont08:oFont)
  	oOrdCompra:Say(nLinCalc+50,aPos[1,1]+5,aDadCont[07],oFont08N:oFont)

  // ORIGINAL	oOrdCompra:Say(nLinCalc+05,aPos[1,1]+5,"NOME COMPRADOR ",oFont08:oFont)
  //	oOrdCompra:Say(nLinCalc+50,aPos[1,1]+5,UsrRetName(aDadCont[04]),oFont08N:oFont)
	
	aPos:={{nPosHOld1,0800},{0800,2000},{2000,nHPage}}
	
   oOrdCompra:Box(nLinCalc   ,aPos[2,1]+400,nLinCalc+100,aPos[3,2])
	oOrdCompra:Say(nLinCalc+10,aPos[2,1]+405,"NOME COMPRADOR",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[2,1]+410,UsrRetName(aDadCont[04]),oFont08N:oFont)
  	 	
	nLinCalc+=100  
    
   oOrdCompra:Box(nLinCalc,aPos[1,1],nLinCalc+100,aPos[1,2]+400)
	oOrdCompra:Say(nLinCalc+05,aPos[1,1]+5,"FORNECEDOR ",oFont08:oFont)
  	oOrdCompra:Say(nLinCalc+50,aPos[1,1]+5,aDadCont[01],oFont08N:oFont)
                          
//	oOrdCompra:Box(nLinCalc   ,aPos[2,1]+400,nLinCalc+100,aPos[2,2]) //OK
	oOrdCompra:Say(nLinCalc+10,aPos[2,1]+405,"TELEFONE",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[2,1]+405,aDadCont[20],oFont08N:oFont)

	oOrdCompra:Box(nLinCalc ,aPos[3,1],nLinCalc+100,aPos[3,2])
	oOrdCompra:Say(nLinCalc+10,aPos[3,1]+5,"CNPJ FORNECEDOR ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[3,1]+5,Transform(aDadCont[02],"@R 99.999.999/9999-99"),oFont08N:oFont)
	
	nLinCalc+=100  
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cliente                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aPos:={{nPosHOld1,2000},{2000,nHPage}}
    
   oOrdCompra:Box(nLinCalc,aPos[1,1],nLinCalc+100,aPos[1,2])

	oOrdCompra:Box(nLinCalc ,aPos[1,1],nLinCalc+100,aPos[1,2])
	oOrdCompra:Say(nLinCalc+10,aPos[1,1]+5,"ENDERECO ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[1,1]+5,aDadCont[19],oFont08N:oFont)
 	
	oOrdCompra:Box(nLinCalc ,aPos[2,1],nLinCalc+100,aPos[2,2])
	oOrdCompra:Say(nLinCalc+10,aPos[2,1]+5,"Nº DA COTAÇÃO",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[2,1]+5,aDadCont[03],oFont08N:oFont)

	nLinCalc+=110  
	                           
	//Dados para o Faturamento
	
	aPos:={{nPosHOld1,1200},{1200,2000},{2000,nHPage}}  
	
//If SM0->M0_CODFIL <> aDadCont[13]
	oOrdCompra:Say(nLinCalc,aPos[1,1]+1000,"DADOS PARA O FATURAMENTO",oFont14N:oFont)
	nLinCalc+=70

	dbSelectArea("SM0")
	nRegSMO:=SM0->(Recno())
	nReg   :=nRegSMO
	dbGoTop()
	While !SM0->( EOF() )
	    If Alltrim(SM0->M0_CODFIL)==aDadCont[13]
		   nReg:=Recno() 
		   exit
		Endif   
		SM0->( dbSkip() )
	End            
	dbGoTo(nReg)

	oOrdCompra:Box(nLinCalc+02,aPos[1,1],nLinCalc+100,aPos[1,2])
	oOrdCompra:Say(nLinCalc+10,aPos[1,1]+5,"NOME ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[1,1]+10,SM0->M0_NOMECOM,oFont08N:oFont)
	
	oOrdCompra:Box(nLinCalc+02 ,aPos[2,1],nLinCalc+100,aPos[2,2])
	oOrdCompra:Say(nLinCalc+10,aPos[2,1]+5,"CNPJ ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[2,1]+10,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),oFont08N:oFont)

	oOrdCompra:Box(nLinCalc+02 ,aPos[3,1],nLinCalc+100,aPos[3,2])
	oOrdCompra:Say(nLinCalc+10,aPos[3,1]+5,"DANFE ",oFont08:oFont)

	if cEmpAnt == "01" // TopMix
		oOrdCompra:Say(nLinCalc+50,aPos[3,1]+10,"fiscal@topmix.com.br",oFont08N:oFont)
	else
		oOrdCompra:Say(nLinCalc+50,aPos[3,1]+10,"nfe@flapa.com.br",oFont08N:oFont)
	endif

	nLinCalc+=100    

	aPos:={{nPosHOld1,1800},{1800,nHPage}}

	oOrdCompra:Box(nLinCalc+02,aPos[1,1],nLinCalc+100,aPos[1,2])
	oOrdCompra:Say(nLinCalc+10,aPos[1,1]+5,"ENDEREÇO ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[1,1]+10,SM0->M0_ENDCOB,oFont08N:oFont)
	
	oOrdCompra:Box(nLinCalc+02 ,aPos[2,1],nLinCalc+100,aPos[2,2])
	oOrdCompra:Say(nLinCalc+10,aPos[2,1]+5,"BAIRRO ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[2,1]+10,SM0->M0_BAIRCOB,oFont08N:oFont)

	nLinCalc+=100               
	
 	aPos:={{nPosHOld1,1200},{1200,1300},{1300,1800},{1800,nHPage}}

	oOrdCompra:Box(nLinCalc+02,aPos[1,1],nLinCalc+100,aPos[1,2])
	oOrdCompra:Say(nLinCalc+10,aPos[1,1]+5,"MUNICIPIO ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[1,1]+10,SM0->M0_CIDCOB,oFont08N:oFont)

	oOrdCompra:Box(nLinCalc+02,aPos[2,1],nLinCalc+100,aPos[2,2])
	oOrdCompra:Say(nLinCalc+10,aPos[2,1]+5,"UF",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[2,1]+10,SM0->M0_ESTCOB,oFont08N:oFont)
	
	oOrdCompra:Box(nLinCalc+02,aPos[3,1],nLinCalc+100,aPos[3,2])
	oOrdCompra:Say(nLinCalc+10,aPos[3,1]+5,"CEP ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[3,1]+10,Transform(SM0->M0_CEPCOB,"@R 99.999.999"),oFont08N:oFont)

	oOrdCompra:Box(nLinCalc+02,aPos[4,1],nLinCalc+100,aPos[4,2])
	oOrdCompra:Say(nLinCalc+10,aPos[4,1]+5,"TELEFONE ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[4,1]+10,Transform(StrTran(SM0->M0_TEL,"-",""),"@R 99(99)9999-9999"),oFont08N:oFont)

	nLinCalc+=110  
	dbSelectArea("SM0")
	SM0->( dbGoTo( nRegSMO ) )
//Endif
	
// Dados da Entrega 
	aPos:={{nPosHOld1,1200},{1200,2000},{2000,nHPage}}
//If SM0->M0_CODFIL<>aDadCont[14]

	oOrdCompra:Say(nLinCalc,aPos[1,1]+1000,"DADOS PARA ENTREGA",oFont14N:oFont)
	nLinCalc+=70
	dbSelectArea("SM0")
	SM0->( dbGoTo( nRegSMO ) )

	dbSelectArea("SM0")
	nRegSMO:=SM0->(Recno())
	nReg   :=nRegSMO
	dbGoTop()
	While !SM0->( EOF() )
	    If SM0->M0_CODFIL = aDadCont[14]
		   nReg:=Recno() 
		   exit
		Endif   
		SM0->( dbSkip() )
	End            
	dbGoTo(nReg)

	oOrdCompra:Box(nLinCalc+02,aPos[1,1],nLinCalc+100,aPos[1,2])
	oOrdCompra:Say(nLinCalc+10,aPos[1,1]+5,"NOME ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[1,1]+10,SM0->M0_NOMECOM,oFont08N:oFont)
	
	oOrdCompra:Box(nLinCalc+02 ,aPos[2,1],nLinCalc+100,aPos[2,2])
	oOrdCompra:Say(nLinCalc+10,aPos[2,1]+5,"CNPJ ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[2,1]+10,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),oFont08N:oFont)

	oOrdCompra:Box(nLinCalc+02 ,aPos[3,1],nLinCalc+100,aPos[3,2])
	oOrdCompra:Say(nLinCalc+10,aPos[3,1]+5,"DANFE ",oFont08:oFont)
	
	if cEmpAnt == "01" // TopMix
		oOrdCompra:Say(nLinCalc+50,aPos[3,1]+10,"fiscal@topmix.com.br",oFont08N:oFont)
	else
		oOrdCompra:Say(nLinCalc+50,aPos[3,1]+10,"nfe@flapa.com.br",oFont08N:oFont)
	endif	
	
	nLinCalc+=100               

	aPos:={{nPosHOld1,1800},{1800,nHPage}}

	oOrdCompra:Box(nLinCalc+02,aPos[1,1],nLinCalc+100,aPos[1,2])
	oOrdCompra:Say(nLinCalc+10,aPos[1,1]+5,"ENDEREÇO ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[1,1]+10,SM0->M0_ENDCOB,oFont08N:oFont)
	
	oOrdCompra:Box(nLinCalc+02 ,aPos[2,1],nLinCalc+100,aPos[2,2])
	oOrdCompra:Say(nLinCalc+10,aPos[2,1]+5,"BAIRRO ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[2,1]+10,SM0->M0_BAIRCOB,oFont08N:oFont)

	nLinCalc+=100               
	
 	aPos:={{nPosHOld1,1200},{1200,1300},{1300,1800},{1800,nHPage}}

	oOrdCompra:Box(nLinCalc+02,aPos[1,1],nLinCalc+100,aPos[1,2])
	oOrdCompra:Say(nLinCalc+10,aPos[1,1]+5,"MUNICIPIO ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[1,1]+10,SM0->M0_CIDCOB,oFont08N:oFont)

	oOrdCompra:Box(nLinCalc+02,aPos[2,1],nLinCalc+100,aPos[2,2])
	oOrdCompra:Say(nLinCalc+10,aPos[2,1]+5,"UF",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[2,1]+10,SM0->M0_ESTCOB,oFont08N:oFont)
	
	oOrdCompra:Box(nLinCalc+02,aPos[3,1],nLinCalc+100,aPos[3,2])
	oOrdCompra:Say(nLinCalc+10,aPos[3,1]+5,"CEP ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[3,1]+10,Transform(SM0->M0_CEPCOB,"@R 99.999.999"),oFont08N:oFont)

	oOrdCompra:Box(nLinCalc+02,aPos[4,1],nLinCalc+100,aPos[4,2])
	oOrdCompra:Say(nLinCalc+10,aPos[4,1]+5,"TELEFONE ",oFont08:oFont)
	oOrdCompra:Say(nLinCalc+50,aPos[4,1]+10,Transform(StrTran(SM0->M0_TEL,"-",""),"@R 99(99)9999-9999"),oFont08N:oFont)
	dbSelectArea("SM0")
	SM0->( dbGoTo( nRegSMO ) )
//Endif

// Dados do Frete


	aPos:={{nPosHOld1,nHPage}}

	nLinCalc+=110               

	oOrdCompra:Line(nLinCalc-20,aPos[1,1]+1150,nLinCalc+170,aPos[1,1]+1150)
	
	
	oOrdCompra:Say(nLinCalc,aPos[1,1]+100 ,"DADOS PARA O FRETE",oFont14N:oFont)
	oOrdCompra:Say(nLinCalc,aPos[1,1]+1200,"COND. PAGAMENTO",oFont14N:oFont)
	nLinCalc+=70

	aPos:={{nPosHOld1,1800},{1800,nHPage}}

	oOrdCompra:Box(nLinCalc+02,aPos[1,1],nLinCalc+100,aPos[2,2])
	oOrdCompra:Say(nLinCalc+10,aPos[1,1]+5,"TIPO DE ENTREGA ",oFont08:oFont)                     
	oOrdCompra:Say(nLinCalc+10,aPos[1,1]+1200,"COND. PAGAMENTO ",oFont08:oFont)                     	
	
	if Alltrim(aDadCont[17]) == "C"
		oOrdCompra:Say(nLinCalc+50,aPos[1,1]+10,"CIF",oFont08N:oFont)
	elseif Alltrim(aDadCont[17]) == "F"                                                             
		oOrdCompra:Say(nLinCalc+50,aPos[1,1]+10,"FOB",oFont08N:oFont)
	else                                                            
		oOrdCompra:Say(nLinCalc+50,aPos[1,1]+10,"NÃO DEFINIDO",oFont08N:oFont)
	endif
	
	oOrdCompra:Say(nLinCalc+50,aPos[1,1]+1200,Alltrim(aDadCont[18]) + " - " + Posicione("SE4",1,xFilial("SE4")+aDadCont[18],"E4_DESCRI"),oFont08N:oFont)
	

	nLinCalc+=100               


	lCabec := .F.
EndIf               

	nPosV := nLinCalc
	
	nFolha++    
	  
Return(nPosV)


*********************************************
* Funcao de produtos 
***                  
Static Function fImpProd(oOrdCompra,nPosV)
Local aPos       :={}
Local lflag      :=.F.
Local cLogoR     := Iif(cEmpAnt=="01","\Imagens\TopMix_Totvs_Rel.png","\Imagens\Flapa_Totvs_Rel.png")
Local nItem1     := MAXITEMP2  
Local nLinAux    :=0
Local nLinInicio :=0
nHPage := oOrdCompra:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oOrdCompra:nVertRes() 
nVPage *= (300/PixelY)
nVPage -= VBOX
nPosHOld := VMARGEM   


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados do produto                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := {{{},{},{},{},{},{},{},{},{},{},{},{}}}

nY := 0
nLenItens :=Len(aItens)

For nX :=1 To nLenItens
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][01])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][02])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][03])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][04])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][05])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][06])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][07])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][08])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][09])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][10])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][11])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][12])
	nY++		                      
	
	If nY >= 8
		nY := 0
	EndIf
Next nX
                                                                                        
//             Item          Cod.Pro     Cod.Ori     Produto       UM         Qtde        V.Uni      V.Tot       Desc       Dt. Ent     Apli.        CC
//  aPos:={{nPosHOld,0150},{0150,0300},{0300,0550},{0550,1400},{1400,1450},{1450,1550},{1550,1750},{1750,1900},{1900,2050},{2050,2200},{2200,2350},{2350,nHPage}}
    aPos:={{nPosHOld,0100},{0100,0250},{0250,0500},{0500,1300},{1300,1350},{1350,1450},{1450,1600},{1600,1800},{1800,1950},{1950,2100},{2100,2250},{2250,nHPage}}

nLinCalc:=nPosV 
nLinCalc+=20 

oOrdCompra :Say(nLinCalc,aPos[1,1]+1000,"ITENS PARA COMPRAS",oFont14N:oFont)

nLinCalc+=80 

nLinInicio:=nLinCalc

oOrdCompra:Say(nLinCalc+8,aPos[1,1]+5,"ITEM",oFont07:oFont)
oOrdCompra:Say(nLinCalc+8,aPos[2,1]+5,"COD.PRO.",oFont07:oFont)    
oOrdCompra:Say(nLinCalc+8,aPos[3,1]+5,"COD.ORI.",oFont07:oFont)
oOrdCompra:Say(nLinCalc+8,aPos[4,1]+5,"PRODUTO",oFont07:oFont)
oOrdCompra:Say(nLinCalc+8,aPos[5,1]+5,"UM",oFont07:oFont)
oOrdCompra:Say(nLinCalc+8,aPos[6,1]+5,"QTDE.",oFont07:oFont)
oOrdCompra:Say(nLinCalc+8,aPos[7,1]+5,"V.UNIT",oFont07:oFont)
oOrdCompra:Say(nLinCalc+8,aPos[8,1]+5,"V.TOTAL",oFont07:oFont)
oOrdCompra:Say(nLinCalc+8,aPos[9,1]+5,"DESC.",oFont07:oFont)
oOrdCompra:Say(nLinCalc+8,aPos[10,1]+5,"ENTREGA",oFont07:oFont)
oOrdCompra:Say(nLinCalc+8,aPos[11,1]+5,"APLIC.",oFont07:oFont)
oOrdCompra:Say(nLinCalc+8,aPos[12,1]+5,"C.CUSTO",oFont07:oFont)

oOrdCompra:Box(nLinCalc+60,aPos[1,1],nLinCalc+60,aPos[12,2])

nPosV:=nLinCalc+600
nLinCalc+=70

nLinha    :=nLinCalc+17
nL:=0

For nY := 1 To nLenItens
	nL:= nL +1
	If nLinCalc +100 > nVPage
			 oOrdCompra:Box(nLinInicio+2,aPos[1,1],nVPage,aPos[1,2])
		    oOrdCompra:Box(nLinInicio+2,aPos[2,1],nVPage,aPos[2,2])
		    oOrdCompra:Box(nLinInicio+2,aPos[3,1],nVPage,aPos[3,2])
		    oOrdCompra:Box(nLinInicio+2,aPos[4,1],nVPage,aPos[4,2])
		    oOrdCompra:Box(nLinInicio+2,aPos[5,1],nVPage,aPos[5,2])
		    oOrdCompra:Box(nLinInicio+2,aPos[6,1],nVPage,aPos[6,2])
 		    oOrdCompra:Box(nLinInicio+2,aPos[7,1],nVPage,aPos[7,2])
		    oOrdCompra:Box(nLinInicio+2,aPos[8,1],nVPage,aPos[8,2])
		    oOrdCompra:Box(nLinInicio+2,aPos[9,1],nVPage,aPos[9,2])
		    oOrdCompra:Box(nLinInicio+2,aPos[10,1],nVPage,aPos[10,2])
		    oOrdCompra:Box(nLinInicio+2,aPos[11,1],nVPage,aPos[11,2])
		    oOrdCompra:Box(nLinInicio+2,aPos[12,1],nVPage,aPos[12,2])
			
			//oOrdCompra:SayBitmap(3050,HMARGEM+5,cLogoR,nHPage-50,100)
			oOrdCompra:EndPage()
			oOrdCompra:StartPage()
	   	nPosV:=OrdCab0(oOrdCompra,nPosV,@nFolha,nFolhas)
			nLinCalc:=nPosV   
			nLinInicio:=nLinCalc

//         aPos:={{nPosHOld,0150},{0150,0300},{0300,0550},{0550,1400},{1400,1450},{1450,1550},{1550,1750},{1750,1900},{1900,2050},{2050,2200},{2200,2350},{2350,nHPage}}
    		aPos:={{nPosHOld,0100},{0100,0250},{0250,0500},{0500,1300},{1300,1350},{1350,1450},{1450,1600},{1600,1800},{1800,1950},{1950,2100},{2100,2250},{2250,nHPage}}
     
			oOrdCompra:Box(nLinCalc+60,aPos[1,1],nLinCalc+60,aPos[12,2])
			oOrdCompra:Say(nLinCalc+8,aPos[1,1]+5,"ITEM",oFont07:oFont)
			oOrdCompra:Say(nLinCalc+8,aPos[2,1]+5,"COD.PRO.",oFont07:oFont)    
			oOrdCompra:Say(nLinCalc+8,aPos[3,1]+5,"COD.ORI.",oFont07:oFont)
			oOrdCompra:Say(nLinCalc+8,aPos[4,1]+5,"PRODUTO",oFont07:oFont)
			oOrdCompra:Say(nLinCalc+8,aPos[5,1]+5,"UM",oFont07:oFont)
			oOrdCompra:Say(nLinCalc+8,aPos[6,1]+5,"QTDE.",oFont07:oFont)
			oOrdCompra:Say(nLinCalc+8,aPos[7,1]+5,"V.UNIT",oFont07:oFont)
			oOrdCompra:Say(nLinCalc+8,aPos[8,1]+5,"V.TOTAL",oFont07:oFont)
			oOrdCompra:Say(nLinCalc+8,aPos[9,1]+5,"DESCONT",oFont07:oFont)
			oOrdCompra:Say(nLinCalc+8,aPos[10,1]+5,"ENTREGA",oFont07:oFont)
			oOrdCompra:Say(nLinCalc+8,aPos[11,1]+5,"APLIC.",oFont07:oFont)
			oOrdCompra:Say(nLinCalc+8,aPos[12,1]+5,"C.CUSTO",oFont07:oFont)
			nPosV:=nLinCalc+600
			nLinCalc+=70
			nLinha  :=nLinCalc+17
			nL:=0
  	Endif      
  
   If !Empty(aAux[1][2][nY])
		oOrdCompra:Say(nLinCalc,aPos[01,1]+010,aAux[1][1][nY],oFont07:oFont ) // ITENS
   Endif
 	
	oOrdCompra:Say(nLinCalc,aPos[02,1]+010,aAux[1][2][nY],oFont07:oFont)  // COD PRODUTO
	oOrdCompra:Say(nLinCalc,aPos[03,1]+010,aAux[1][12][nY],oFont07:oFont)  // COD ORIGINAL
	oOrdCompra:Say(nLinCalc,aPos[04,1]+010,aAux[1][3][nY],oFont07:oFont,) // DESCRICAO DO PRODUTO    
	oOrdCompra:Say(nLinCalc,aPos[05,2]-10 ,aAux[1][4][nY],oFont07:oFont,30, 10, ,1,) // UNIDADE
	oOrdCompra:Say(nLinCalc,aPos[06,2]-10 ,aAux[1][5][nY],oFont07:oFont,50, 10, ,1,) // QUANTIDADE
	oOrdCompra:Say(nLinCalc,aPos[07,2]-20 ,aAux[1][6][nY],oFont07:oFont,50, 10, ,1,) // PREÇO 
	oOrdCompra:Say(nLinCalc,aPos[08,2]-20 ,aAux[1][7][nY],oFont07:oFont,50, 10, ,1,) // PREÇO TOTAL
	oOrdCompra:Say(nLinCalc,aPos[09,2]-20 ,aAux[1][8][nY],oFont07:oFont,50, 10, ,1,) // DESCONTO

	oOrdCompra:Say(nLinCalc,aPos[10,1]+05 ,aAux[1][9][nY],oFont07:oFont) // DT. ENTREGA
	oOrdCompra:Say(nLinCalc,aPos[11,1]+05 ,aAux[1][10][nY],oFont07:oFont) // APLICAÇÃO
	oOrdCompra:Say(nLinCalc,aPos[12,1]+05 ,aAux[1][11][nY],oFont07:oFont) // C.CUSTO

	If nY<>nLenItens 
  	   lFlag:=aAux[1][1][nY] = aAux[1][1][nY+1]
	   If  !lFlag
			 nLinCalc:=nLinCalc + 60   
			 If nLinCalc +100 < nVPage   
				oOrdCompra:Box(nLinCalc-20,aPos[1,1],nLinCalc-20,aPos[12,2]) 
			 Endif	 
	   Else 
	    	nLinCalc:=nLinCalc + 45
	   Endif		
    Endif                                                                          

Next nY

oOrdCompra:Box(nLinInicio+2,aPos[1,1],nLinCalc+50,aPos[1,2])
oOrdCompra:Box(nLinInicio+2,aPos[2,1],nLinCalc+50,aPos[2,2])
oOrdCompra:Box(nLinInicio+2,aPos[3,1],nLinCalc+50,aPos[3,2])
oOrdCompra:Box(nLinInicio+2,aPos[4,1],nLinCalc+50,aPos[4,2])
oOrdCompra:Box(nLinInicio+2,aPos[5,1],nLinCalc+50,aPos[5,2])
oOrdCompra:Box(nLinInicio+2,aPos[6,1],nLinCalc+50,aPos[6,2])
oOrdCompra:Box(nLinInicio+2,aPos[7,1],nLinCalc+50,aPos[7,2])
oOrdCompra:Box(nLinInicio+2,aPos[8,1],nLinCalc+50,aPos[8,2])
oOrdCompra:Box(nLinInicio+2,aPos[9,1],nLinCalc+50,aPos[9,2])
oOrdCompra:Box(nLinInicio+2,aPos[10,1],nLinCalc+50,aPos[10,2])
oOrdCompra:Box(nLinInicio+2,aPos[11,1],nLinCalc+50,aPos[11,2])
oOrdCompra:Box(nLinInicio+2,aPos[12,1],nLinCalc+50,aPos[12,2])
 
nLinCalc+=50 // Por motivo de preencher ate o final

Return(nLinCalc)  


Static Function fQuebraTxt(pStr,pTam)
*********************************************
*quebra string conforme a necessidade
*********************************************
Local cStr := Alltrim(pStr)
Local nTam := pTam
Local k := 0
Local cTxt := ""
Local cW   := ""
Local aW   :={}
Local lFlag:=.F.

For k:=1 to Len(cStr)
	cLetra := SubStr(cStr,k,1)
	cW   += cLetra
	
	If " " $cLetra .Or. "/" $cLetra .Or. k=Len(cStr) 
		lFlag := .F.
		If Len(cTxt+cW) <= nTam 
			cTxt += cW 
			cW := ""
			lFlag := .T.			
		EndIf			
		
//		cTxt += cW
		If Len(cTxt+cW) > nTam .Or. k=Len(cStr)
			Aadd(aW,cTxt)
			cTxt := ""
		EndIf 
		If !lFlag
			cTxt += cW
			If k=Len(cStr)
				Aadd(aW,cTxt)
				cTxt := ""			
			EndIf
		EndIf 
		cW := ""	
	EndIf
Next

//If !Empty(cW) 
//	cTxt += cW
//	Aadd(aW,cTxt)
//EndIf        

Return(aW)