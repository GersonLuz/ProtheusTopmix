#INCLUDE "protheus.CH"

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINR04
Emissao de Boletos Banco Bradesco..
         
@author 	Luciano M. Pinto
@since 		26/09/2011
@version	P11
@param		aDados Array com os dados do Banco

/*/ 
User Function FSFINR04(aDados)
/**********************************************************************************
* FSFMod10 <==> CDGMD10                                             
* FSFMod11 <==> CDGMD11ce
* FSFMod11 <==> CalcDigM11
*
****/
Private nAltLin      := 065  // altura padrão da linha
Private nPosY        := 100  // inicio da impressao no eixo Y
private nPosX        := 100  // inicio da impressao no eixo Y
Private nQuantMin    := 000
Private nRangMin     := 000
Private nRangMax     := 000 
Private nNossoNum    := 000  

Private oBoleto  
Private oFntNormal   := TFont():New( "Courier New",,09,,.F.,,,,,.f. )
Private oDescCampo   := TFont():New( "Courier New",,05,,.F.,,,,,.f. )
Private oFntNeg08    := TFont():New( "Courier New",,07,,.F.,,,,,.f. )
Private oFntNeg10    := TFont():New( "Courier New",,09,,.t.,,,,,.f. )
Private oFntFix10    := TFont():New( "Courier New",,13,,.t.,,,,,.f. )
Private oFntSacado   := TFont():New( "Courier New",,09,,.t.,,,,,.f. )

Private cNossoNum    := "" 
Private cNumForma    := ""
Private cLinha       := ""
Private cCarteira    := ""
Private cBanco       := ""
Private cAgencia     := ""
Private cDigAge      := ""
Private cConta       := ""
Private cDigCon      := ""
Private cDigAge      := ""
Private cCedente     := ""
Private cNBolFil	   := ""
Private cNomCliFor   := ""
Private cEndeClFo    := ""
Private cCEPCliFo    := ""
Private cMuniClFo 	:= ""
Private cEstaClFo    := ""

Private lReimp			:= .F.	

Processa({|| FImprRel(aDados) },"Imprimindo Boleto...")

Return Nil


//------------------------------------------------------------------- 
/*/{Protheus.doc} FImprRel
Montagem e Impressao de boleto Grafico do Banco Bradesco

@protected                   
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FImprRel(aBanco)
/*************************************************************************************************
*
*
*
****/
Local aDatSac	:= {}
							  														  		
SE1->(dbGotop())

oBoleto:=TMSPrinter():New()
oBoleto:Setup()
oBoleto:setPortrait()
oBoleto:setPaperSize(9)

cBanco    := aBanco[1]
cNomeBco  := aBanco[2]
cAgencia  := aBanco[3]
cConta    := StrZero(Val(aBanco[4]),7)

cCarteira := aBanco[5]

cDigAge   := AllTrim(aBanco[7])
cDigCon   := aBanco[6]

cCedente  := SubStr(Alltrim(cAgencia),1,4)+"-"+cDigAge+ "/" + SubStr(Alltrim(cConta),1,7) + "-"+ Alltrim(cDigCon)

SA6->(dbSetOrder(1))
SA6->(dbSeek(xFilial("SA6") + cBanco + cAgencia))

nQuantMin := SA6->A6_ZQTDMIN
nRangMin  := Val(SA6->A6_ZRANMIN)
nRangMax  := Val(SA6->A6_ZRANMAX)

ProcRegua(SE1->(RecCount()))  

While !SE1->(Eof())
	
	If ! AllTrim(SE1->E1_OK) == cMarca
		SE1->(dbSkip())
		Loop
	End If
	
	If Empty(SE1->E1_NUMBCO) .And. Empty(SE1->E1_ZBANCO)
		
		nNossoNum := Val(SA6->A6_ZNOSSON) + 1
		
		If nNossoNum > nRangMax .Or. nNossoNum < nRangMin
			MsgInfo(OemToAnsi("Numero do Boleto excedeu ao Range disponivel. Favor contactar o Setor Finaceiro!",OemToAnsi("Stop")))
			Return Nil
		End IF
		
		If (nRangMax - nNossoNum) < nQuantMin
			MsgInfo(OemToAnsi("Numero do Boleto excedeu ao Range Minino disponivel. Favor contactar o Setor Finaceiro!",OemToAnsi("Stop")))
		End IF
		
		SA6->(RecLock("SA6", .F. ))
		SA6->A6_ZNOSSON := StrZero(nNossoNum,11)
		SA6->(Msunlock())
		
		
		cNossoNum	:= AllTrim(SA6->A6_ZNOSSON)	
		
	Else
		
		lReimp		:= .T.
		cNossoNum	:= AllTrim(SE1->E1_NUMBCO)
		
	End IF

		
	cNumForma := ""
	cNumForma := FNossoN() //Nosso numero formatado e Gravo no SE1->E1_NUMBCO

	
	cNBolFil := ""
	If Empty(SE1->E1_PARCELA)
		cNBolFil := AllTrim(SE1->E1_NUM)
	Else
		cNBolFil := AllTrim(SE1->E1_NUM)+"/"+ AllTrim(SE1->E1_NUM) + "/" + U_FSCalPar(AllTrim(SE1->E1_PARCELA), 2)
	End If

	// Busca informações do sacado através da Use function FSGetSca
	aDatSac	:=	U_FSGetSca()

	If !Empty(aDatSac)
		cNomCliFor := aDatSac[1]
		cEndeClFo  := aDatSac[2]
		cMuniClFo  := aDatSac[3]
		cEstaClFo  := aDatSac[4]
		cCEPCliFo  := TransForm(aDatSac[5],PesqPict("SA1","A1_CEP"))		
	End If
	
	oBoleto:startPage()
	
	cLinha    := LinhaBr()
	
	//recEntrega()
	recSacado()
	
	oBoleto:Line(nPosY,100,nPosY,2400) // segunda dobra
	
	nPosY+=nAltLin
	recSacado(cLinha)
	oBoleto:EndPage()
	
	SE1->(dbSkip())
	
	nPosY := 100 // inicio da impressao no eixo Y
	nPosX := 100 // inicio da impressao no eixo Y
	
EndDo
		
oBoleto:Preview()
oBoleto:End()
	
Return Nil       


//------------------------------------------------------------------- 
/*/{Protheus.doc} recEntrega
Imprime o recibo de entrega.

@protected                   
@author Luciano Mariano
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function recEntrega()
/*************************************************************************************************
*
*
*
****/

oBoleto:Box(nPosY,1200,nPosY+nAltLin,1520) // 1 da 1 // 1 divisão de 1ª linha
oBoleto:SayBitmap(nPosY+1,1200+5,cLogoBco + "\bradesco.bmp",nAltLin-2,nAltLin-2 ) //logotipo do banco
impLeft(1210+nAltLin,cNomeBco,oFntNeg08,.T.) 
oBoleto:Box(nPosY,1520,nPosY+nAltLin,1800) // 2 da 1 
impCentral(1520, 1800, "237-2", oFntFix10,.t.)  

oBoleto:Box(nPosY,1800,nPosY+nAltLin,2380) // 3 da 1                                 
impRight(2390, "Recibo de Entrega",oFntFix10,.T.)   

//fim primeira linha   

nPosY+=nAltLin  // a posição da linha será sempre a posição anterior mais a altura da ultima linha
oBoleto:Box(nPosY,1200,nPosY+nAltLin,1450) // 1 da 2    
impDescCampo(1200,"Vencimento")
impCentral(1200,1450, SE1->E1_VENCREA,oFntNormal) // 1450

oBoleto:Box(nPosY,1450,nPosY+nAltLin,1870) // 2 da 2
impDescCampo(1450,"Ponto de Venda/Cod. do Cedente")
impCentral(1500,1800, cCedente,oFntNormal)
oBoleto:Box(nPosY,1870,nPosY+nAltLin,1950) // 3 da 2
impDescCampo(1890,"Esp.")
impCentral(1800,2020, "DM",oFntNormal)
oBoleto:Box(nPosY,1950,nPosY+nAltLin,2380) // 4 da 2
impDescCampo(1955,"Quantidade")
impCentral(2100,2400, "",oFntNormal)
	
nPosY+=nAltLin
oBoleto:Box(nPosY,1200,nPosY+nAltLin,1950) // 1 da 3
impDescCampo(1200,"Valor do Documento")     

impCentral(1200,1950,Transform(U_FSPrcVal(SE1->E1_SALDO), PesqPict("SE1","E1_VALOR")),oFntNormal)
	
oBoleto:Box(nPosY,1950,nPosY+nAltLin,2380) // 2 da 3
impDescCampo(1950,"Nosso Número")
impCentral(2050,2300,cNumForma,oFntNormal) 
	       
nPosY+=nAltLin
oBoleto:Box(nPosY,1200,nPosY+nAltLin,1950) // 1 da 4
impDescCampo(1200,"Sacado")
impCentral(1200,2100,cNomCliFor,oFntNormal)   
             
oBoleto:Box(nPosY,1950,nPosY+nAltLin,2380) // 2 da 4
impDescCampo(2050,"Nº do Documento")                
impCentral(2050,2250,cNBolFil,oFntNormal) 

nPosY+=nAltLin
oBoleto:Box(nPosY,1200,nPosY+nAltLin,1650) // 1 da 4
impDescCampo(1200,"Nota Fiscal")
impCentral(1200,1350,SE1->E1_NUM,oFntNormal)  

oBoleto:Box(nPosY,1650,nPosY+nAltLin,1950) // 1 da 4
impDescCampo(1650,"Série")
impCentral(1650,1800,SE1->E1_PREFIXO,oFntNormal)   
             
oBoleto:Box(nPosY,1950,nPosY+nAltLin,2380) // 2 da 4
//impDescCampo(1950,"Relação")                
//impCentral(2100,2350,SE1->E1_VEND1,oFntNormal)

nPosY+=nAltLin
oBoleto:Box(nPosY,1200,nPosY+nAltLin,1950) // 1 da 5
impDescCampo(1200,"Asssinatura Fornecedor")                
oBoleto:Box(nPosY,1950,nPosY+nAltLin,2380) // 2 da 5
impDescCampo(1950,"Guia de Entrega")   
nPosY+=nAltLin
nPosY+=nAltLin
	
oBoleto:Line(nPosY,100,nPosY,2400) // primeira dobra 
nPosY+=nAltLin
	                    
Return Nil


//------------------------------------------------------------------- 
/*/{Protheus.doc} recSacado
Imprime as informações do sacado

@protected                   
@author Luciano Mariano
@since 27/09/2011 
@version P11
@param cTitulo - Titulo a ser processado
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function recSacado(cTitulo)
/*************************************************************************************************
*
*
*
****/

Local	nIncMsg	:=	0
Local	cMsgBco	:=	aTxtBol[1] + " " + aTxtBol[2] + " " + aTxtBol[3]
Local	cDadCed	:= ""
Local	aMsgFrt	:= {}                              

// Carrego os dados da empresa de origem do título
Local	aDadEmp	:= U_FSGetSm0(cEmpAnt, SE1->E1_FILORIG)

aMsgFrt	:=	U_FSQbrStr(SubStr(cMsgBco, 1, 249),83, Space(1))

If Len(aMsgFrt) == 1
	AAdd(aMsgFrt, Space(83))
	AAdd(aMsgFrt, Space(83))	
ElseIf Len(aMsgFrt) == 2
	AAdd(aMsgFrt, Space(83))
EndIf

oBoleto:Box(nPosY,100,nPosY+nAltLin,400) // 1 da 1 // 1 divisão de 1ª linha
oBoleto:SayBitmap(nPosY+2,105,cLogoBco + "\bradesco.bmp",nAltLin-2,nAltLin-2 ) 
impLeft(100+nAltLin+5,cNomeBco,oFntNeg08,.T.) 
oBoleto:Box(nPosY,400,nPosY+nAltLin,700) // 2 da 1  
impCentral(400, 700, "237-2", oFntFix10,.t.)

oBoleto:Box(nPosY,700,nPosY+nAltLin,2380) // 3 da 1                                 
If(empty(cTitulo))
	impRight(2390, "Recibo do Sacado",oFntFix10,.T.)
Else
	impRight(2280, cTitulo,oFntFix10,.T.)
EndIf                 
	
nPosY+=nAltLin
	
oBoleto:Box(nPosY,100,nPosY+nAltLin,1800) // 1 da 2
impDescCampo(100,"Local do Pagamento") 
impLeft(100, "PAGAVEL PREFERENCIALMENTE NA REDE BRADESCO OU BRADESCO EXPRESSO.",oFntNormal)
oBoleto:Box(nPosY,1800,nPosY+nAltLin,2380) // 2 da 2
impDescCampo(1800,"Vencimento")                

impRight(2300,SE1->E1_VENCREA,oFntNormal)//2380

nPosY+=nAltLin

cDadCed	:= cDadCed	:= aDadEmp[1] + aDadEmp[6]
	
oBoleto:Box(nPosY,100,nPosY+nAltLin,1800) // 1 da 3
impDescCampo(100,"Cedente") 
impLeft(100, cDadCed,oFntNormal)
oBoleto:Box(nPosY,1800,nPosY+nAltLin,2380) // 2 da 3
impDescCampo(1800,"Ponto de Venda/Codigo do Cedente")                
impRight(2150,cCedente,oFntNormal)
	
nPosY+=nAltLin
	
oBoleto:Box(nPosY,100,nPosY+nAltLin,400) // 1 da 4
impDescCampo(100,"Data do Documento") 
impRight(380,SE1->E1_EMISSAO,oFntNormal)
oBoleto:Box(nPosY,400,nPosY+nAltLin,700) // 2 da 4                                                       
impDescCampo(400,"Nº do Documento")                
impCentral(400,635,cNBolFil,oFntNormal)
oBoleto:Box(nPosY,700,nPosY+nAltLin,900) // 3 da 4
impDescCampo(700,"Espécie Doc.")                
impCentral(700,880,"DM",oFntNormal)
oBoleto:Box(nPosY,900,nPosY+nAltLin,1350)// 4 da 4
impDescCampo(900,"Aceite")                
impCentral(900,1350,"N",oFntNormal)
oBoleto:Box(nPosY,1350,nPosY+nAltLin,1800) // 5 da 4
impDescCampo(1350,"Data do Processamento") 
 
impRight(1770,DtoC(Date()),oFntNormal)
oBoleto:Box(nPosY,1800,nPosY+nAltLin,2380) // 6 da 4
impDescCampo(1800,"Nosso Número")                
impRight(2300,cNumForma,oFntNormal)
	
nPosY+=nAltLin  
	
oBoleto:Box(nPosY,100,nPosY+nAltLin,240) // 1 da 5
impDescCampo(100,"Uso do Banco")                
impRight(250,"",oFntNormal)             
	
oBoleto:Box(nPosY,240,nPosY+nAltLin,310) // 2 da 5
impDescCampo(250,"CIP")                
impCentral(250,290,"000",oFntNormal)             
	
oBoleto:Box(nPosY,310,nPosY+nAltLin,500) // 3 da 5
impDescCampo(310,"Cart.")                
impCentral(310,500,cCarteira,oFntNormal)             
	
oBoleto:Box(nPosY,500,nPosY+nAltLin,700) // 4 da 5                                                       
impDescCampo(500,"Espécie")                
impCentral(400,700,"REAL",oFntNormal)
oBoleto:Box(nPosY,700,nPosY+nAltLin,900) // 5 da 5
impDescCampo(700,"Quantidade")                
impCentral(700,900,"",oFntNormal)
oBoleto:Box(nPosY,900,nPosY+nAltLin,1800)// 6 da 5
impDescCampo(900,"Valor")                
//impCentral(900,1800,Transform(SE1->E1_VALOR,PesqPict("SE1","E1_VALOR")),oFntNormal)
oBoleto:Box(nPosY,1800,nPosY+nAltLin,2380) // 7 da 5
impDescCampo(1800,"Valor do Documento")                
impRight(2300,Transform(U_FSPrcVal(SE1->E1_SALDO),PesqPict("SE1","E1_VALOR")),oFntNormal)
	
nPosY+=nAltLin
oBoleto:Box(nPosY,100,nPosY+(nAltLin*4),1800) // 1 da 6
impDescCampo(100,"Instruções") 
impLeft(100, "(Texto de Responsabilidade do Cedente)",oFntNormal)

For nXi := 1 To Len(aMsgFrt)
	nPosY+=oBoleto:GetTextHeight("", oFntNormal )+5
	impLeft(100, PadR(aMsgFrt[nXi], 83),oFntNormal)
	IIF(nXi == 3,nXi := Len(aMsgFrt),nXi := nXi)	
Next

//nPosY+=oBoleto:GetTextHeight("", oFntNormal )+5
//impLeft(100, aTxtBol[2],oFntNormal)

//nPosY+=oBoleto:GetTextHeight("", oFntNormal )+5
//impLeft(100, aTxtBol[3],oFntNormal)

//nPosY+=oBoleto:GetTextHeight("", oFntNormal )+5
//impLeft(100, cCodBr,oFntNormal)
          
nPosY+=oBoleto:GetTextHeight("", oFntNormal )+5
impLeft(100, " ",oFntNormal)
nPosY+=oBoleto:GetTextHeight("", oFntNormal )+5
impLeft(100, " ",oFntNormal)
		
nPosY-=(oBoleto:GetTextHeight("", oFntNormal )+5)*5
oBoleto:Box(nPosY,1800,nPosY+nAltLin,2380) // 1 da 6
impDescCampo(1800,"(-) Desconto / Abatimentos")                
//impRight(2300,transform(SE1->E1_DECRESC,PesqPict("SE1","E1_DECRESC")),oFntNormal)
nPosY+=nAltLin
oBoleto:Box(nPosY,1800,nPosY+nAltLin,2380) // 2 da 6
impDescCampo(1800,"(+) Taxas / Acrescimos")                
//impRight(2300,Transform(SE1->E1_ACRESC,PesqPict("SE1","E1_DECRESC")),oFntNormal)
nPosY+=nAltLin
oBoleto:Box(nPosY,1800,nPosY+nAltLin,2380) // 3 da 6
impDescCampo(1800,"")                
impRight(2400,"",oFntNormal)
nPosY+=nAltLin
oBoleto:Box(nPosY,1800,nPosY+nAltLin,2380) // 4 da 6
impDescCampo(1800,"(=) Valor Cobrado")                
	
nPosY+=nAltLin
oBoleto:Box(nPosY,100,nPosY+(nAltLin*4),2380) // 1 da 7
impDescCampo(100,"Sacado")    

impLeft(100, cNomCliFor,oFntNormal)
nPosY+=oBoleto:GetTextHeight("", oFntNormal )+5
impLeft(100, Alltrim(cEndeClFo),oFntNormal)
nPosY+=oBoleto:GetTextHeight("", oFntNormal )+5
impLeft(100, Alltrim(cMuniClFo)+" "+Alltrim(cEstaClFo),oFntNormal)
nPosY+=oBoleto:GetTextHeight("", oFntNormal )+5
impLeft(100, Alltrim(cCEPCliFo),oFntNormal)  

nPosY+=oBoleto:GetTextHeight("", oFntNormal )+5
impLeft(100, "Sacador/Avalista ",oFntSacador)
impLeft(440, "NF: "+SE1->E1_PREFIXO+Space(3)+Alltrim(SE1->E1_NUM),oFntNormal) 
//impLeft(900, "Relacao: ",oFntNormal)   
//impLeft(1060, SE1->E1_VEND1,oFntNormal)
//impLeft(1400, "Código de Baixa" ,oFntSacador)
//impLeft(1460, " ",oFntNormal)

nPosY-=(oBoleto:GetTextHeight("", oFntNormal )+5)*3  
nPosY+=nAltLin*3
impRight(2110,("Autenticação Mecanica /"),oFntNormal)
nPosY+= oBoleto:GetTextHeight("", oFntNormal )+5
impRight(2110,("Ficha de Compensação"),oFntNormal)
nPosY+=nAltLin*4


Return Nil


//------------------------------------------------------------------- 
/*/{Protheus.doc} impDescCampo
Imprime as descrições do campo

@protected                   
@author Luciano Mariano
@since 27/09/2011 
@version P11
@param nCol 	- Numero da coluna a ser impressa
@param cTexto 	- Texto a ser impresso
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function impDescCampo(nCol, cTexto ) 
/*************************************************************************************************
*
*
*
****/

oBoleto:Say(nPosY ,nCol+5,cTexto, oDescCampo) 
	
Return Nil


//------------------------------------------------------------------- 
/*/{Protheus.doc} impCentral
Impreme aas informações centralizadas

@protected                   
@author Luciano Mariano
@since 27/09/2011 
@version P11
@param nInicio  	- Coluna inicial para impressão
@param nFim		 	- Coluna final para impressão
@param cTexto	 	- Texto a ser impressão
@param oFonte	 	- Fonte que será usadp
@param lCentVert  - 
@param cTexto 	- Texto a ser impresso
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 

Static Function impCentral(nInicio, nFim, cTexto, oFonte, lCentVert)
/*************************************************************************************************
*
*
*
****/
local nAlturaText 	:= 0
local nLarguraText 	:= 0
local nPosX
local nY := 0     

cTexto := IIF(ValType(cTexto) = "C",cTexto,dtoc(cTexto))
nAlturaText:= oBoleto:GetTextHeight(cTexto, oFonte )
nY := nPosY+nAltLin -nAlturaText -2    

If(oFonte==oFntNormal .AND. len(cTexto)<15 )
	nLarguraText:= oBoleto:GetTextWidth(cTexto, oFonte ) - 5*len(cTexto) 
Else
	nLarguraText:= oBoleto:GetTextWidth(cTexto, oFonte ) - 2*len(cTexto) 
EndIF 

nPosX:=nInicio + (nFim-nInicio)/2-(nLarguraText/2)
	
If(lCentVert)
	nY:=nPosY+nAltLin/2-(nAlturaText/2)  
EndIf
oBoleto:Say(nY ,nPosX,cTexto, oFonte) 

Return     


//------------------------------------------------------------------- 
/*/{Protheus.doc} impLeft
Imprime as informações a esquerda.

@protected                   
@author Luciano Mariano
@since 27/09/2011 
@version P11
@param nInicio  	- Coluna inicial para impressão
@param nFim		 	- Coluna final para impressão
@param cTexto	 	- Texto a ser impressão
@param oFonte	 	- Fonte que será usadp
@param lCentVert  - 
@param cTexto 	- Texto a ser impresso
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function impLeft(nInicio,cTexto,oFonte,lCentVert) 
/*************************************************************************************************
*
*
*
****/
local nAlturaText := 0
local nLarguraText := 0
local nPosX:=nInicio +5
local nY := 0
cTexto := IIF(ValType(cTexto) = "C",cTexto,AllTrim(str(cTexto)))
nLarguraText:= oBoleto:GetTextWidth(cTexto, oFonte )
nAlturaText:= oBoleto:GetTextHeight(cTexto, oFonte ) 
nY := nPosY+nAltLin -nAlturaText -2
If(lCentVert)
	nY:=nPosY+nAltLin/2-(nAlturaText/2)
EndIf                  
oBoleto:Say(nY ,nPosX,cTexto, oFonte)

Return 


//------------------------------------------------------------------- 
/*/{Protheus.doc} impLeft1
Imprime as informações a esquerda.

@protected                   
@author Luciano Mariano
@since 27/09/2011 
@version P11
@param nInicio  	- Coluna inicial para impressão
@param nFim		 	- Coluna final para impressão
@param cTexto	 	- Texto a ser impressão
@param oFonte	 	- Fonte que será usadp
@param lCentVert  - 
@param cTexto 	- Texto a ser impresso
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function impLeft1(nInicio,cTexto,oFonte,lCentVert) 
/*************************************************************************************************
*
*
*
****/
local nAlturaText := 0
local nLarguraText := 0
local nPosX:=nInicio +5
local nY := 0
cTexto := IIF(ValType(cTexto) = "C",cTexto,AllTrim(Str(cTexto)))
nLarguraText:= oBoleto:GetTextWidth(cTexto, oFonte )
nAlturaText:= oBoleto:GetTextHeight(cTexto, oFonte ) 
nY := nPosY+nAltLin -nAlturaText -2
If(lCentVert)
	nY:=nPosY+nAltLin/2-(nAlturaText/2)
EndIf     
nYb := nY +2595             
oBoleto:Say(nYb ,nPosX,cTexto, oFonte)

Return  

      
//------------------------------------------------------------------- 
/*/{Protheus.doc} impRight
Imprime as informações a esquerda.

@protected                   
@author Luciano Mariano
@since 27/09/2011 
@version P11
@param nInicio  	- Coluna inicial para impressão
@param nFim		 	- Coluna final para impressão
@param cTexto	 	- Texto a ser impressão
@param oFonte	 	- Fonte que será usadp
@param lCentVert  - 
@param cTexto 	- Texto a ser impresso
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function impRight(nFim,cTexto,oFonte,lCentVert)  
/*************************************************************************************************
*
*
*
****/
local nAlturaText := 0
local nLarguraText := 0
local nPosX
local nY := 0
cTexto := IIF(ValType(cTexto) = "C",cTexto,AllTrim(dtoc(cTexto)))
nAlturaText:= oBoleto:GetTextHeight(cTexto, oFonte )
nY := nPosY+nAltLin -nAlturaText -2
If(oFonte==oFntNormal)
	nLarguraText:= oBoleto:GetTextWidth(cTexto, oFonte ) - 5*len(cTexto) 
Else
	nLarguraText:= oBoleto:GetTextWidth(cTexto, oFonte ) - 2*len(cTexto) 
 EndIF
nPosX:=nFim -nLarguraText -50
   
If(lCentVert)
	nY:=nPosY+nAltLin/2-(nAlturaText/2)
EndIf                  
	
oBoleto:Say(nY ,nPosX,cTexto, oFonte) 

Return  


//------------------------------------------------------------------- 
/*/{Protheus.doc} impRight1
Imprime as informações a esquerda.

@protected                   
@author Luciano Mariano
@since 27/09/2011 
@version P11
@param nInicio  	- Coluna inicial para impressão
@param nFim		 	- Coluna final para impressão
@param cTexto	 	- Texto a ser impressão
@param oFonte	 	- Fonte que será usadp
@param lCentVert  - 
@param cTexto 	- Texto a ser impresso
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function impRight1(nFim,cTexto,oFonte,lCentVert)  
/*************************************************************************************************
*
*
*
****/
local nAlturaText := 0
local nLarguraText := 0
local nPosX
local nY := 0
cTexto := IIF(ValType(cTexto) = "C",cTexto,AllTrim(dtoc(cTexto)))
nAlturaText:= oBoleto:GetTextHeight(cTexto, oFonte )
nY := nPosY+nAltLin -nAlturaText -2
If(oFonte==oFntNormal)
	nLarguraText:= oBoleto:GetTextWidth(cTexto, oFonte ) - 5*len(cTexto) 
Else
	nLarguraText:= oBoleto:GetTextWidth(cTexto, oFonte ) - 2*len(cTexto) 
 EndIF
nPosX:=nFim -nLarguraText -50
   
If(lCentVert)
	nY:=nPosY+nAltLin/2-(nAlturaText/2)
EndIf                  
nYc := nY +2595  	
oBoleto:Say(nYc ,nPosX,cTexto, oFonte) 

Return


//------------------------------------------------------------------- 
/*/{Protheus.doc} FNossoN
Busca o nosso número.

@protected                   
@author Luciano Mariano
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------  
Static Function FNossoN()
/*************************************************************************************************
* Calculo digito do nosso numero
* 
*
****/
Local cNosso := ""
Local cCartA6:= Left(cCarteira,2)

If lReimp

	cNosso := cCartA6 + "/" + SubStr(AllTrim(SE1->E1_NUMBCO), 1, Len(AllTrim(SE1->E1_NUMBCO)) - 1) + "-" + SubStr(AllTrim(SE1->E1_NUMBCO), Len(AllTrim(SE1->E1_NUMBCO)), 1)

Else

	cNosso := cNossoNum + U_FSFMod11(cCartA6 + Substr(cNossoNum,1,11),3,7)

	SE1->(RecLock("SE1", .F. ))
		SE1->E1_NUMBCO := cNosso
		SE1->E1_ZBANCO := "237"
	SE1->(Msunlock())
	
	cNosso := cCartA6 + "/" + SubStr(cNosso, 1, Len(AllTrim(cNosso)) - 1) + "-" + SubStr(cNosso, Len(cNosso), 1)
	
End If

Return(cNosso)
                         

//------------------------------------------------------------------- 
/*/{Protheus.doc} LinhaBr
Calcula a linha digitável

@protected                   
@author Luciano Mariano
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------  
Static Function LinhaBr()
/*************************************************************************************************
*
*
*
****/
/*
nDataBase 	:= CtoD("07/10/1997") // data base para calculo do fator
cFatorVen	:= Alltrim(Str(SE1->E1_VENCREA - nDataBase)) // acha a diferenca em dias para o fator de vencimento
*/

cFatorVen	:= U_FSFatVenc(SE1->E1_VENCREA) // Retorna o Fator de Vencimento
cBancoM 	:= Left(Alltrim(cBanco),3)+"9"  //banco e moeda 9
cAgenci 	:= Left(Alltrim(cAgencia),4)
cCartei 	:= Left(Alltrim(cCarteira),2)
cContac 	:= Strzero(Val(SubStr(Alltrim(cConta),1,7)),7)
cNumDig10   := space(10)
cDigVerif   := "0"

//---------------> CALCULO DOS GRUPOS PARA O IPTE
/*
1o Grupo
999 -> BANCO
9   -> MOEDA
9999-> AGENCIA
9   -> 1o Campo da Carteira
9   -> DIGITO VERIFICADOR
*/
//CALCULO DIGITO 1o GRUPO
cNumDig10 := cBancoM+cAgenci+substr(cCartei,1,1)
cDigVerif := U_FSFMod10(cNumDig10)//Calculo modulo 10, RETORNA O DIGITO VERIF.
cPriGrupo := cNumDig10 + cDigVerif //RETORNA 10 POSICOES
/*
2o Grupo
9  -> 2o Campo da CARTEIRA
999999999 -> 9 DIGITOS DO NOSSO NUMERO
9  -> DIGITO VERIFICADOR
*/
//CALCULO DIGITO 2o GRUPO           //04472
cNumDig10 := Substr(cCartei,2,1)+ Substr(cNossoNum,1,9)
cDigVerif := U_FSFMod10(cNumDig10)//Claculo modulo 10, RETORNA O DIGITO VERIF.
cSegGrupo := cNumDig10 + cDigVerif //RETORNA 11 POSICOES
/*
3o Grupo
99 -> 2 ULTIMOS POSICOES DO NOSSO NUMERO
9999999 -> NRO DA CONTA
0  -> VALOR FIXO 0
9  -> DIGITO VERIFICADOR
*/
//CALCULO DIGITO 3o GRUPO
cNumDig10 := Substr(cNossoNum,10,2)+cContac+"0"
cDigVerif := U_FSFMod10(cNumDig10)//Claculo modulo 10, RETORNA O DIGITO VERIF.
cTerGrupo := cNumDig10+cDigVerif

cValor := STRZERO(U_FSPrcVal(SE1->E1_SALDO),14,2)

cNewValor := ""
nZeros := 0
for i:=1 to len(cValor)
	if Substr(cValor,i,1) # "." .and. Substr(cValor,i,1) # ","
		cNewValor += Substr(cValor,i,1)
	ELSE
		nZeros ++
	endif
next
cValor := ""
For i:=1 to nZeros
	cValor += "0"
next
cValor += Substr(Alltrim(cNewValor),5,10)

//----> DIGITO VERIF. DO COD BARRAS
cNumDig10 := cBancoM+cFatorVen + cValor + cAgenci + cCartei + Substr(cNossoNum,1,11) + cContac + "0"
cDigVerif := U_FSFMod11(cNumDig10)//Calculo modulo 11, RETORNA O DIGITO VERIF.
cQuaGrupo := cDigVerif

//---->MONTAGEM DO LAYOUT DA LINHA DIGITAVEL
cLinhaDig := cPriGrupo + cSegGrupo + cTerGrupo + cQuaGrupo + cFatorVen + cValor
cLinhaDigImp := substr(cLinhaDig,1,5)+"."+substr(cLinhaDig,6,5)+"  "+;
substr(cLinhaDig,11,5)+"."+substr(cLinhaDig,16,6)+"  "+;
substr(cLinhaDig,22,5)+"."+substr(cLinhaDig,27,6)+"  "+substr(cLinhaDig,33,1)+"  "+substr(cLinhaDig,34,14)

//----> MONTAGEM CODIGO DE BARRAS PARA SER IMPRESSO
//	cCodBarAPT 	:= cLinhaDig
cCodBarAPT 	:= cBancoM + cDigVerif + cFatorVen  + cValor
cCodBarAPT 	+= cAgenci + cCartei + SubStr(cNossoNum,1,11) + cContac + "0"

codBarr(cCodBarAPT)

//Variavel criada apenas para imprimir o Codigo de Barras
//cCodBr := cCodBarAPT

/*
cComImp := "Linha Digitavel := " + cLinhaDig + "////"
cComImp += "Codigo de Barras:= " + cCodBarAPT

memowrite("c:\cCodBar.txt",cComImp)
*/
Return(cLinhaDigImp)


//------------------------------------------------------------------- 
/*/{Protheus.doc} codBarr
Calcula o código de barras do boleto bradesco.

@protected                   
@author Luciano Mariano
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------  
Static Function codBarr(cNumero)   
/*************************************************************************************************
*
*
*
****/

Local nPosY	:=	19.2
Local	nPosX	:=	1.25
  	
MsBar3("INT25"  ,nPosY,nPosX,cNumero  ,oBoleto,.F.,,.T.,0.024,1.25,,,,.F.)

nPosY-=nAltLin+20
nPosY-=nAltLin+100
nPosY+=150
nPosY+=nAltLin
nP := nPosY + 2600   
 
Return                                        


