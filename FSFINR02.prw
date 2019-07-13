#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"                                                                                                                    
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINR02
Rotina que gera, imprime e reimprime Boleto Banco Santander
          
@author Fernando Ferreira
@since 11/11/2011 
@param aDadBco Informações do cadastro de bancos
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFINR02(aDadBco)
Default	 aDadBco :=	{	Space(TamSx3 ("A6_COD")[1]) 		,;		// Código do banco
								Space(TamSx3 ("A6_NOME")[1])		,;		// Nome do banco
								Space(TamSx3 ("A6_AGENCIA")[1])	,;		// Agência do banco
								Space(TamSx3 ("A6_ZCONVEN")[1])	,;		// Número da conta corrente
								Space(TamSx3 ("A6_CARTEIR")[1])	,;		// Carteira utilizada  
								Space(TamSx3 ("A6_DVCTA")[1])}         // Código da Conta corrente
								
Processa( {||FMntBol(aDadBco)}, "Aguarde...", "Montando Boleto(s) Banco Santander...",.F.)
Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FMntBol
Prepara Dados Para a Impressao do Boleto
          
@protected
@author Fernando Ferreira
@since 11/11/2011 
@param aDadBco Informações do cadastro de bancos
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 

Static Function FMntBol(aDadBco)
Local	oPrint			:= Nil

Local	lRet				:= .T.

Local	cNumDoc			:= "" 
Local	cFatVen			:= "" 
Local	cFatVal		  	:= ""
Local	cIdCeden			:= ""
Local	cNosNum			:= ""
Local	cIof				:= "0"  
Local	cMoeda			:= "9"
Local	cCmpFix			:= "9" 
Local cParc				:= ""

Local	nX 				:= 0 
Local	nVlrAbat			:= 0
Local	nI        		:= 1

Local	aDadTit			:= {}
Local	aDatSac			:= {}
Local	aDadEmp			:= {}
									
oPrint:= TMSPrinter():New( "Boleto Santander" )
oPrint:Setup()
oPrint:SetPortrait() 
oPrint:StartPage()

SE1->(dbGoTop())
ProcRegua(RecCount())

Do While !SE1->(EOF())	
		
	If !AllTrim(SE1->E1_OK) == cMarca
		SE1->(dbSkip())
		Loop
	End If 
	
	aDadTit	:=	{}
	aDadEmp	:= {}
		
	// Formata a pacela caso a parcela seja informada como letra.	  		 
	cParc 	:= U_FSCalPar(SE1->E1_PARCELA, 2)
	
	// Get nas informações da empresa
	aDadEmp	:= U_FSGetSm0(cEmpAnt, SE1->E1_FILORIG)
	
	// Número do documento mais parcela	   	
	cNumDoc	:= SE1->E1_PREFIXO +"/"+SE1->E1_NUM+"/"+cParc   
	
	If Empty(SE1->E1_NUMBCO)
		// Busca o último número do Cadastro de bancos
		cNosNum	:=	U_FSPrcNum(aDadBco)
		cNosNum	:=	cNosNum+Alltrim(U_FSFMod11(StrZero(Val(cNosNum),12),2))
		cNosNum	:=	StrZero(Val(cNosNum), 08)	
		
		// Grava o nosso numero no SE1	
		SE1->(RecLock("SE1",.F.))
		SE1->E1_NUMBCO		:=	cNosNum
		SE1->E1_ZBANCO		:= aDadBco[1]
		SE1->(MsUnlock())
	Else
		// Busca o último número do Cadastro de bancos
		cNosNum	:=	AllTrim(U_FSPrcNum(aDadBco))
	EndIF
	
	// Calcula o Fator de Venciamento
	cFatVen	:= U_FSFatVenc(SE1->E1_VENCREA) 
	cFatVal	:= StrZero(U_FSPrcVal(SE1->E1_SALDO)*100,10)           
	
	// Get nos dados do sacado (Cliente)	
	aDatSac	:=	U_FSGetSca(SE1->E1_CLIENTE, SE1->E1_LOJA)	
		
	//1º.Campo : Composto pelo código do banco, código da moda, campo fixo "9",
	//4 primeiras posições do código do cedente e dígito verificador deste campo
	cParte1	:=	Alltrim(aDadBco[1])+cMoeda+cCmpFix+SubStr(Alltrim(aDadBco[4]),1,4)
	cDig1		:= Alltrim(U_FSFMod10( cParte1 )) 
	
	//2º Campo: Composto pelas 3 últimas posições restante do código do cedente,
	//nosso numero(N/N) com as 07 primeiras posições e dígito verificador dete campo.
	cParte2:=SubStr(Alltrim(aDadBco[4]),5,3)+SubStr(StrZero(Val(cNosNum),13),1,7)
	cDig2	:= Alltrim(U_FSFMod10(cParte2))
	
	//3º Campo: Composto pelas 6 ultimas posições restante do N/N,01 posição referente
	//ao IOS, 03 posições referente ao tipo de modalidade ("101 - Cob. Simples -Com registro")
	//mais o dígito verificador deste campo.
	cParte3:=SubStr(Alltrim(StrZero(Val(cNosNum),13)),8,6)+cIof+Alltrim(aDadBco[5])
	cDig3		:= Alltrim(U_FSFMod10( cParte3 ))
	cBarra	:=	Alltrim(aDadBco[1])+cMoeda+cFatVen+cFatVal+cCmpFix+SubStr(Alltrim(aDadBco[4]), 1, 7)+StrZero(Val(cNosNum),13)+cIOF+Alltrim(aDadBco[5])   
	cDigCB	:= Alltrim(U_FSFMod11(cBarra,1)) 	// Digito CODIGO DE BARRAS   
	cBarra	:= SubStr(cBarra, 1, 4) + cDigCB + SubStr(cBarra, 5, 40)
	
	//4º Campo: Dígito verificador do código de barra(DAC)	
	cParte4:=cDigCB                 
	
	//5º Campo; Composto pelas 04 primeiras posições do fator vencimento(*) e as 10
	//últimas com o valor nominal do documento, com indicação de zeros a esquerda e sem ponto e vírgula.
	cParte5		:=	cFatVen+cFatVal	
	
	// Calcula a linha digitável		
	cLinhaDig	:= substr(cParte1,1,5)+"."+substr(cparte1,6,4)+cDig1+" "+;
						substr(cParte2,1,5)+"."+substr(cparte2,6,5)+cDig2+" "+;
						substr(cParte3,1,5)+"."+substr(cparte3,6,5)+cDig3+" "+;
		   			" " + cParte4+ " "+cParte5
	
	// Get nos dados do Título		   			
	AAdd(aDadTit,	AllTrim(SE1->E1_NUM)+ AllTrim(SE1->E1_PARCELA))	// [1] Número do título
	AAdd(aDadTit,	SE1->E1_VENCREA)											// [2] Data da Vencimento do Título
	AAdd(aDadTit,	SE1->E1_VENCTO)											// [3] Data do vencimento
	AAdd(aDadTit,	U_FSPrcVal(SE1->E1_SALDO))								// [4] Valor do título
	AAdd(aDadTit,	cNosNum)														// [5] Nosso número (Ver fórmula para calculo)
	AAdd(aDadTit,	SE1->E1_PREFIXO)											// [6] Prefixo da NF
	AAdd(aDadTit,	date())														// [7] Data da emissão de processamento
	AAdd(aDadTit,	SE1->E1_EMISSAO)											// [8] Data da emissão de processamento
	
	// Imprime as informações do boleto		
	FImpBol(oPrint, aDadEmp, aDadTit, aDadBco, aDatSac, aTxtBol, cBarra, Alltrim(aDadBco[4]), cLinhaDig, cNumDoc)
	
	nX++
	
	SE1->(dbSkip())
	
	SE1->(IncProc())
	
	nI++

EndDo 

oPrint:EndPage()     // Finaliza a página
oPrint:Preview()     // Visualiza antes de imprimir	 

Return nil



//-------------------------------------------------------------------
/*/{Protheus.doc} FImpBol
Função qmonta o Layte do Boleto

@protected
@author	   Fernando Ferreira
@since	   09/05/2011 

@param 		oPrint  	Objeto de Impressao
@param 		aDadEmp   Array unidimensional com os Dados da Empresa
@param 		aDadTit   Array unidimensional com os Dados do Titulo
@param 		aDadBco		Array unidimensional com os Dados do Banco
@param 		aDatSac		Array unidimensional com os Dados do Sacado
@param 		aTxtBol   	Array unidimensional com os Dados das Linhas de Instrução
@param 		cBarra   	Codigo de Barras do Produto
@param 		cIdCeden  	Codigo de Cedente
@param 		cLinhaDig   Linha Digitavel
@param 		cNumDoc   	Numero do Documento

/*/
//-------------------------------------------------------------------
Static Function FImpBol(oPrint,aDadEmp,aDadTit,aDadBco,aDatSac,aTxtBol,cBarra,cIdCeden,cLinhaDig,cNumDoc)
Local	oFont8n
Local	oFont11c
Local	oFont8
Local	oFont14
Local	oFont16n
Local	oFont15
Local	oFont14n
Local	oFont24
Local	nI 		:= 0
Local	nIncMsg	:=	0
Local	cMsgBco	:=	aTxtBol[1] + " " + aTxtBol[2] + " " + aTxtBol[3]
Local	aMsgFrt	:= {}                        

aMsgFrt	:=	U_FSQbrStr(SubStr(cMsgBco, 1, 450),103, Space(1))

oFont8	:= TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)  
oFont8n 	:= TFont():New("Arial",9,8,.T.,.T.,5,.T.,5,.T.,.F.)  
oFont11c := TFont():New("Courier New",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  := TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n := TFont():New("Arial",8,13,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.) 
oPrint:StartPage()

/*****************/
/* PRIMEIRA PARTE */
/*****************/

nRow2 := 0
oPrint:Line (nRow2+0250,100,nRow2+0250,2300)
oPrint:Line (nRow2+0250,690,nRow2+0170, 690)
oPrint:Line (nRow2+0250,900,nRow2+0170, 900)

oPrint:SayBitmap(nRow2+0140,100,cLogoBco+"\santander.bmp",300,100 ) 
oPrint:Say  (nRow2+0175,720,aDadBco[1]+"-7"	,oFont21 )
oPrint:Say  (nRow2+0184,1800,"Recibo do Sacado",oFont11) 

nRow2:=nRow2-300
   

oPrint:Line (nRow2+0710,100,nRow2+0710,2300)        

//linhas horizontais
oPrint:Line (nRow2+0810,100,nRow2+0810,2300 )
oPrint:Line (nRow2+0910,100,nRow2+0910,2300 )
//Linhas verticais
oPrint:Line (nRow2+0810,1000,nRow2+0910,1000)
oPrint:Line (nRow2+0810,1395,nRow2+0910,1395)

oPrint:Say  (nRow2+0710,100 ,"Cedente",oFont8n)
oPrint:Say  (nRow2+0765,100 ,aDadEmp[1]+" - "+aDadEmp[6],oFont8)

oPrint:Say  (nRow2+0710,1810,"Vencimento"                                     ,oFont8n)
cString	:= StrZero(Day(aDadTit[2]),2) +"/"+ StrZero(Month(aDadTit[2]),2) +"/"+ Right(Str(Year(aDadTit[2])),4)
nCol 		:= 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0750,nCol,cString,oFont8)

oPrint:Say  (nRow2+0810,100 ,"Sacado"                                        	,oFont8n)
oPrint:Say  (nRow2+0850,100 ,aDatSac[1]							   					,oFont8)   

oPrint:Say  (nRow2+0810,1005,"Numero do Documento"                            ,oFont8n)
oPrint:Say  (nRow2+0850,1050,cNumDoc										  				,oFont8)   

oPrint:Say  (nRow2+0810,1400,"Nosso Numero"                                   ,oFont8n) 
cString 	:= TRANSFORM(Substr(aDadTit[5],1),"@R 9999999-!")
oPrint:Say  (nRow2+0850,1445,cString,oFont8)  

oPrint:Say  (nRow2+0810,1810,"Valor do Documento",oFont8n)
cString 	:= "R$ "+Alltrim(Transform(aDadTit[4],"@E 99,999,999.99"))
nCol 		:= 1850+(374-(len(cString)*22))
oPrint:Say  (nRow2+0860,nCol,cString,oFont8)

oPrint:Say  (nRow2+910,100 ,"Instruções (Termo de responsabilidade do cedente)",oFont11)

For nXi := 1 To Len(aMsgFrt)
	oPrint:Say  (nRow2+1080 + nIncMsg,100 ,aMsgFrt[nXi]							 	,oFont8)
	nIncMsg	+=	50
Next

oPrint:Line (nRow2+0710,1800,nRow2+910,1800)

nRow2:=nRow2+200
oPrint:Say  (nRow2+1430,100 ,aDatSac[1]            							,oFont8) 

oPrint:Say  (nRow2+1605, 1750, aDatSac[7]+aDatSac[6]							,oFont8) // CGC

oPrint:Say  (nRow2+1483,100 ,aDatSac[2]+"   "+Subs(aDatSac[5],1,5)+"-"+Subs(aDatSac[5],6,3)+"    "+aDatSac[3]+" - "+aDatSac[4] ,oFont8)

oPrint:Say  (nRow2+1605,100 ,"Sacador/Avalista",oFont8n)                                                                              

oPrint:Say  (nRow2+1400,1500,"Autenticação Mecânica",oFont8n)


oPrint:Line (nRow2+1400,100 ,nRow2+1400,2300 )
oPrint:Line (nRow2+1640,100 ,nRow2+1640,2300 ) 

/******************/
/* SEGUNDA PARTE */
/******************/

nRow3 := 0

For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+1880, nI, nRow3+1880, nI+30)
Next nI

oPrint:Line (nRow3+2000,100,nRow3+2000,2300)
oPrint:Line (nRow3+2000,690,nRow3+1920, 690)
oPrint:Line (nRow3+2000,900,nRow3+1920, 900)

oPrint:SayBitmap(nRow3+1890,100,cLogoBco+"\santander.bmp",300,100 ) 
oPrint:Say  (nRow3+1925,720,aDadBco[1]+"-7" 		,oFont21 )
oPrint:Say  (nRow3+1934,920,cLinhaDig				,oFont15n)	

oPrint:Line (nRow3+2100,100,nRow3+2100,2300 )
oPrint:Line (nRow3+2200,100,nRow3+2200,2300 )
oPrint:Line (nRow3+2270,100,nRow3+2270,2300 )
oPrint:Line (nRow3+2340,100,nRow3+2340,2300 )

oPrint:Line (nRow3+2200,500 ,nRow3+2270,500 )
oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
oPrint:Line (nRow3+2200,1000,nRow3+2340,1000)
oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

oPrint:Say  (nRow3+2000,100 ,"Local de Pagamento",oFont8n)
oPrint:Say  (nRow3+2055,100 ,"Pagar preferencialmente no Grupo Santander - GC",oFont8)

oPrint:Say  (nRow3+2000,1810,"Vencimento",oFont8n)
cString	:= StrZero(Day(aDadTit[2]),2) +"/"+ StrZero(Month(aDadTit[2]),2) +"/"+ Right(Str(Year(aDadTit[2])),4)
nCol		:= 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2040,nCol,cString,oFont8)

oPrint:Say  (nRow3+2100,100 ,"Cedente",oFont8n)
oPrint:Say  (nRow3+2140,100 ,aDadEmp[1]+" - "+aDadEmp[6]	,oFont8) 

oPrint:Say  (nRow3+2100,1810,"Agência/Código Cedente",oFont8n)
ncol		:= FCalDig9(aDadBco[3])
cString 	:= Alltrim(aDadBco[3]+" / "+cIdCeden+aDadBco[6])
nCol		:= 1850+(374-(len(cString)*22))
oPrint:Say  (nRow3+2140,nCol,cString ,oFont8)

oPrint:Say  (nRow3+2200,100 ,"Data do Documento"                              ,oFont8n)
oPrint:Say (nRow3+2230,100, StrZero(Day(aDadTit[8]),2) +"/"+ StrZero(Month(aDadTit[8]),2) +"/"+ Right(Str(Year(aDadTit[8])),4), oFont8)

oPrint:Say  (nRow3+2200,505 ,"Nro.Documento"                                  ,oFont8n)
oPrint:Say  (nRow3+2230,605 ,cNumDoc						,oFont8) 

oPrint:Say  (nRow3+2200,1005,"Espécie Doc."                                   ,oFont8n)
oPrint:Say  (nRow3+2230,1050,"DM"													    	,oFont8) 

oPrint:Say  (nRow3+2200,1305,"Aceite"                                         ,oFont8n)
oPrint:Say  (nRow3+2230,1400,"N"                                              ,oFont8)

oPrint:Say  (nRow3+2200,1485,"Data do Processamento"                          ,oFont8n)
oPrint:Say  (nRow3+2230,1550,StrZero(Day(aDadTit[7]),2) +"/"+ StrZero(Month(aDadTit[7]),2) +"/"+ Right(Str(Year(aDadTit[7])),4)                               ,oFont8) // Data impressao

oPrint:Say  (nRow3+2200,1810,"Nosso Número"                                   ,oFont8n)
cString 	:=  TRANSFORM(Substr(aDadTit[5],1),"@R 9999999-!")
nCol 	 	:= 1810+(490-(len(cString)*22))
oPrint:Say  (nRow3+2230,nCol,cString,oFont8)

oPrint:Say  (nRow3+2270,100 ,"Carteira"                                   		,oFont8n)
oPrint:Say  (nRow3+2300,105 ,aDadBco[5]+"-Rápida com Registro"         			,oFont8)

oPrint:Say  (nRow3+2270,755 ,"Espécie"                                        ,oFont8n)
oPrint:Say  (nRow3+2300,805 ,"R$"                                             ,oFont8)

oPrint:Say  (nRow3+2270,1005,"Quantidade"                                     ,oFont8n)
oPrint:Say  (nRow3+2270,1485,"Valor"                                          ,oFont8n)

oPrint:Say  (nRow3+2270,1810,"(=) Valor do Documento"                         ,oFont8n)
cString 	:= "R$ "+Alltrim(Transform(aDadTit[4],"@E 99,999,999.99"))
nCol 	 	:= 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2300,nCol,cString,oFont8)

oPrint:Say  (nRow3+2340,100 ,"Instruções (Termo de responsabilidade do cedente)"	,oFont11)
nIncMsg	:=	0
For nXi := 1 To Len(aMsgFrt)
	oPrint:Say  (nRow3+2440 + nIncMsg,100 ,aMsgFrt[nXi]							 	,oFont8)
	nIncMsg	+=	50
Next

oPrint:Say  (nRow3+2340,1810,"(-)Desconto"			   								,oFont8n)
oPrint:Say  (nRow3+2410,1810,"(-)Abatimento"												,oFont8n)
oPrint:Say  (nRow3+2480,1810,"(+)Mora"														,oFont8n)
oPrint:Say  (nRow3+2550,1810,"(+)Outros Acréscimos"									,oFont8n)
oPrint:Say  (nRow3+2620,1810,"(=)Valor Cobrado"											,oFont8n)

oPrint:Say  (nRow3+2690,100 ,"Sacado"														,oFont8n)
oPrint:Say  (nRow3+2700,250 ,aDatSac[1]													,oFont8)

oPrint:Say  (nRow3+2815,1750,aDatSac[7]+aDatSac[6]										,oFont8) 

oPrint:Say  (nRow3+2753,250 ,aDatSac[2]+"    "+Subs(aDatSac[5],1,5)+"-"+Subs(aDatSac[5],6,3)+"    "+aDatSac[3]+" - "+aDatSac[4]  ,oFont8)

oPrint:Say  (nRow3+2815,100 ,"Sacador/Avalista"                            ,oFont8)
//oPrint:Line (nRow3+2870,1500,nRow3+2870,1750 )                                     
oPrint:Say  (nRow3+2855,1790,"Autenticação Mecânica"                       ,oFont8)
//oPrint:Line (nRow3+2870,2040,nRow3+2870,2300 )                                     
oPrint:Say  (nRow3+3200,1900,"Ficha de Compensação"                        ,oFont8n)
oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
oPrint:Line (nRow3+2410,1800,nRow3+2410,2300 )
oPrint:Line (nRow3+2480,1800,nRow3+2480,2300 )
oPrint:Line (nRow3+2550,1800,nRow3+2550,2300 )
oPrint:Line (nRow3+2620,1800,nRow3+2620,2300 )
oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300 )
oPrint:Line (nRow3+2850,100,nRow3+2850,2300  )

MsBar3("INT25"  ,24.5,1.2,cBarra  ,oPrint, .F.,,,0.0280,1.4,,,,.F.)
//MsBar("INT25"  ,24.5,1.2,cBarra  ,oPrint, .F.,,,0.0280,1.4,,,,.F.)
oPrint:EndPage() 

Return Nil 


//-------------------------------------------------------------------
/*/{Protheus.doc} FCalDig9
Funçao que gera digito da linha digitavel

@protected
@author	   Jane Mariano Duval
@since	   16/05/2011 

@param 		cVariavel   Codigo de Barras do Produto
@return		auxi        Array   

/*/
//-------------------------------------------------------------------
Static Function FCalDig9(cVariavel)
Local	Auxi 		:= 0
Local	sumdig 	:= 0

cbase		:= cVariavel
lbase		:= LEN(cBase)
base		:= 9
iDig		:= lBase

While iDig >= 1
	If base == 1
		base := 9
	EndIf
	
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base - 1
	iDig   := iDig-1	
EndDo

auxi := mod(Sumdig,11)

If auxi == 10
	auxi := "X"
Else
	auxi := str(auxi,1,0)
EndIf

Return(auxi)
 


