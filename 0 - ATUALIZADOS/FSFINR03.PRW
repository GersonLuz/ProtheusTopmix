#include "rwmake.ch"
#include "protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINR03 
Programa especifico para reemissão da impressão do boleto de
cobrança do banco Itaú,  um formato gráfico a ser emitido
juntamento com a nota fiscal ou fatura ou cupom fiscal
desde que a forma de pagamento assim o justifique.
        
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFINR03(aDadBco)
Default	 aDadBco :=	{	Space(TamSx3 ("A6_COD")[1]) 		,;		// Código do banco
								Space(TamSx3 ("A6_NOME")[1])		,;		// Nome do banco
								Space(TamSx3 ("A6_AGENCIA")[1])	,;		// Agência do banco
								Space(TamSx3 ("A6_NUMCON")[1])	,;		// Número da conta corrente
								Space(TamSx3 ("A6_CARTEIR")[1])	,;		// Carteira utilizada 
								Space(TamSx3 ("A6_DVCTA")[1])}         // Código da Conta corrente
														
								
Processa( {||FMntBol(aDadBco)}, "Aguarde...", "Montando Boleto(s) Banco Itaú...",.F.)								

Return Nil
     
//------------------------------------------------------------------- 
/*/{Protheus.doc} FMntBol()
Montagem e Impressao de boleto Grafico do Banco Itau. 

@protected                   
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 

Static Function FMntBol(aBco)
Local			aDadTit		:= {}
Local			aDadBco		:= {}
Local			aDatSac 		:= {}
Local			aCB_RN_NN	:= {}
Local			aDadEmp 		:= {}

Local			cParc			:= ""
Local			cNosNum		:= ""
Local			cBitMap		:= ""

Local			nXj			:= 0
Local			nXi 			:= 0
Local			nRec			:= 0
Local			nVlrAbat		:= 0
Local       nVlrBoleto  := 0
Local			oPrint		:= Nil

cBitMap	:= cLogoBco + "\ITAU.BMP"

// Carrega os dados do Banco
AAdd(aDadBco, AllTrim(aBco[1]))  																					// Código do banco
AAdd(aDadBco, AllTrim(aBco[2]))                                                                 // Nome do banco
AAdd(aDadBco, AllTrim(aBco[3]))																						// Agência do banco
AAdd(aDadBco, AllTrim(SubStr(aBco[4],1,5)))																		// Número da conta corrente
AAdd(aDadBco, AllTrim(AllTrim(aBco[6])))    																		// Digito da Conta Corrente
AAdd(aDadBco, AllTrim(aBco[5]))																						// Carteira utilizada

oPrint:= TMSPrinter():New( "Boleto Itau" )
oPrint:Setup()
oPrint:SetPortrait() 																									// ou SetLandscape()
oPrint:StartPage()  

SE1->(dbGoTop())
ProcRegua(RecCount())

Do While !SE1->(EOF())

	aDadTit	:=	{}
	aDadEmp	:= {}
	
	If !AllTrim(SE1->E1_OK) == cMarca
		SE1->(dbSkip())
		Loop
	End If
	
	// Carrega os dados da empresa.
	aDadEmp	:= U_FSGetSm0(cEmpAnt, SE1->E1_FILORIG)

	// Formata a pacela caso a parcela seja informada como letra.	  		 	
	cParc 	:= U_FSCalPar(SE1->E1_PARCELA, 1)
		
	// Busca informações do sacado através da Use function FSGetSca
	aDatSac		:=	U_FSGetSca(SE1->E1_CLIENTE, SE1->E1_LOJA)
	
	// Passa para o Array as informações de linha Digitável, código de barras
	nVlrBoleto  := U_FSPrcVal(Round(SE1->E1_SALDO,2))
	aCB_RN_NN	:= FGerCodLin(aBco,nVlrBoleto,Datavalida(SE1->E1_VENCTO,.T.), cParc)
	
	// Get os dados do Título
	AAdd(aDadTit,	AllTrim(SE1->E1_NUM)+"/"+AllTrim(cParc))								// [1] Número do título
	AAdd(aDadTit,	SE1->E1_EMISSAO)																// [2] Data da emissão do título
	AAdd(aDadTit,	Date())																			// [3] Data da emissão do boleto
	AAdd(aDadTit,	SE1->E1_VENCREA)											// [4] Data do vencimento
	AAdd(aDadTit,	nVlrBoleto)                       										// [5] Valor do título
	AAdd(aDadTit,	aCB_RN_NN[3])																	// [6] Nosso número (Ver fórmula para calculo)
	AAdd(aDadTit,	SE1->E1_PREFIXO)														 		// [7] Prefixo da NF
	AAdd(aDadTit,	SE1->E1_TIPO)																	// [8] Tipo do Titulo
   
   DbSelectArea("SF2")
   DBSetOrder(1)
   DBSeek(SE1->E1_FILORIG+SE1->E1_NUM+SUBSTR(SE1->E1_PREFIXO, 3, 1) )
   AAdd(aDadTit,	SF2->F2_NFELETR)																// [9] MAX: Nota Fiscal Eletronica
	DbSelectArea("SE1")
	
	// Executa a função de impressão do boleto.
	FImpBol(oPrint,cBitMap,aDadEmp,aDadTit,aDadBco,aDatSac,U_FSGetIns(1),aCB_RN_NN)
	
	nXi++
	
	SE1->(dbSkip())
	SE1->(IncProc())
	
	nXj++
	
EndDo

oPrint:EndPage()     // Finaliza a página
oPrint:Preview()     // Visualiza antes de imprimir
Return nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FImpBol()
Impressao de Boleto Grafico do Banco Itau. 

@protected                   
@author Fernando dos Santos Ferreira 
@since 27/09/2011
@param	oPrint		- Objeto de Impressão
@param	cBitMap		- Bitmap do banco
@param	aDadEmp		- Dados da empresa
@param	aDadTit		- Informações do Título
@param	aDadBanco	- Informações do banco
@param	aDatSac		- Dados do Sacado
@param	aTxtBol		- Textos opcionais 
@param	aCB_RN_NN	- Array contendo Código de barras, Linha digitável e o nosso número.
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FImpBol(oPrint,cBitMap,aDadEmp,aDadTit,aDadBanco,aDatSac,aTxtBol,aCB_RN_NN)

Local	aBmp 			:= ""
Local	aBmp2 		:= ""

Local nTxper    	:= 0
Local nXi       	:= 0
Local	nIncMsg		:=	0

Local oFont2n   	:= Nil
Local oFont8    	:= Nil
Local oFont9    	:= Nil
Local oFont10   	:= Nil
Local oFont15n  	:= Nil
Local oFont16   	:= Nil
Local oFont16n  	:= Nil
Local oFont14n  	:= Nil
Local oFont24   	:= Nil
Local	oBrush    	:= Nil 

Local	nCb1Lin		:= 14.5
Local	nCb2Lin		:= 26.1
Local	nCbaCol		:= 1.3
Local	nCbaLag		:= 0.0280
Local	nCbaAlt		:= 1.4

Local	cMsgBco		:=	aTxtBol[1] + " " + aTxtBol[2] + " " + aTxtBol[3]

Local	aMsgFrt		:= {}                        

aBmp 		:= cLogoBco + "\ITAU.BMP"
aBmp2 	:= cLogoBco + "\LOGO.BMP"
                                   
aMsgFrt	:=	U_FSQbrStr(SubStr(cMsgBco, 1, 350),83, Space(1))

nTxper	:=	GETMV("MV_TXPER")

nCb1Lin	:= 14.5
nCb2Lin	:= 26.1
nCbaCol	:= 1.3
nCbaLag	:= 0.0280
nCbaAlt	:= 1.4

//Parâmetros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont2n := TFont():New("Times New Roman",,10,,.T.,,,,,.F. )
oFont8  := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont9  := TFont():New("Arial",9,9 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14n:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15n:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oBrush := TBrush():New("",5)//4

oPrint:StartPage()   // Inicia uma nova página

// LOGOTIPO
If File(aBmp2)
	oPrint:SayBitmap( 0040,0100,aBmp2,0175,0100 )
Else
	oPrint:Say  (0084,100,"Banco Itaú SA",oFont15n )	// [2]Nome do Banco
EndIf

oPrint:Say  (0084,1860,"Comprovante de Entrega",oFont10)
oPrint:Line (0150,100,0150,2300)
oPrint:Say  (0150,100 ,"Beneficiario"                                        		,oFont8)
oPrint:Say  (0200,100 ,aDadEmp[1]                                 				,oFont10)	//	Nome + CNPJ
oPrint:Say  (0150,1060,"Agência/Código Beneficiario"                      		,oFont8)
oPrint:Say  (0200,1060,aDadBanco[3]+"/"+aDadBanco[4]+"-"+aDadBanco[5]			,oFont10)
oPrint:Say  (0150,1510,"Nro.Documento"                                  		,oFont8)
oPrint:Say  (0200,1510,aDadTit[7]+"/"+aDadTit[1]											,oFont10)	//	Numero+Parcela
oPrint:Say  (0250,100 ,"Pagador"                                         		,oFont8)
oPrint:Say  (0300,100 ,aDatSac[1]                                    			,oFont10)	//	Nome
oPrint:Say  (0250,1060,"Vencimento"                                     		,oFont8)
oPrint:Say  (0300,1060,DTOC(SE1->E1_VENCREA)                              		,oFont10)
oPrint:Say  (0250,1510,"Valor do Documento"                          			,oFont8)
oPrint:Say  (0300,1550,AllTrim(Transform(aDadTit[5],"@E 999,999,999.99"))   	,oFont10)
If cFilant == "06" .or. cFilant == "18"
	oPrint:Say  (0370,0100,"Recebi(emos) o bloqueto/título com"  					,oFont10)
	oPrint:Say  (0410,0100,"as características acima."             				,oFont10)
	oPrint:Say  (0450,0100,"Favor devolver assinado juntamente"  					,oFont10)
	oPrint:Say  (0490,0100,"com o canhoto da Nota Fiscal." 							,oFont10)
Else
	oPrint:Say  (0400,0100,"Recebi(emos) o bloqueto/título"                 	,oFont10)
	oPrint:Say  (0450,0100,"com as características acima."             			,oFont10)
EndIf                                                              
oPrint:Say  (0350,1060,"Data"                                           		,oFont8)
oPrint:Say  (0350,1410,"Assinatura"                                 				,oFont8)
oPrint:Say  (0450,1060,"Data"                                           		,oFont8)
oPrint:Say  (0450,1410,"Entregador"                                 				,oFont8)

oPrint:Line (0250, 100,0250,1900 )
oPrint:Line (0350, 100,0350,1900 )
oPrint:Line (0450,1050,0450,1900 )
oPrint:Line (0550, 100,0550,2300 )

oPrint:Line (0550,1050,0150,1050 )
oPrint:Line (0550,1400,0350,1400 )
oPrint:Line (0350,1500,0150,1500 )
oPrint:Line (0550,1900,0150,1900 )

oPrint:Say  (0165,1910,"(  ) Mudou-se"                                 			,oFont8)
oPrint:Say  (0205,1910,"(  ) Ausente"                                    		,oFont8)
oPrint:Say  (0245,1910,"(  ) Não existe nº indicado"                  			,oFont8)
oPrint:Say  (0285,1910,"(  ) Recusado"                                			,oFont8)
oPrint:Say  (0325,1910,"(  ) Não procurado"                              		,oFont8)
oPrint:Say  (0365,1910,"(  ) Endereço insuficiente"                  			,oFont8)
oPrint:Say  (0405,1910,"(  ) Desconhecido"                            			,oFont8)
oPrint:Say  (0445,1910,"(  ) Falecido"                                   		,oFont8)
oPrint:Say  (0485,1910,"(  ) Outros(anotar no verso)"                  			,oFont8)

For nXi := 100 to 2300 step 50
	oPrint:Line( 0590, nXi, 0590, nXi+30)
Next nXi

oPrint:Line (0710,100,0710,2300)
oPrint:Line (0710,550,0610, 550)
oPrint:Line (0710,800,0610, 800)

// LOGOTIPO
If File(aBmp)
	oPrint:SayBitmap( 0600,0100,aBmp,0100,0100 )
	oPrint:Say  (0640,240,"Banco Itaú SA",oFont10 )	// [2]Nome do Banco
Else
	oPrint:Say  (0644,100,aDadBanco[2],oFont15n )	// [2]Nome do Banco
EndIf

oPrint:Say  (0618,569,"341-7",oFont24 )				// [1]Numero do Banco
//oPrint:Say  (0644,820,aCB_RN_NN[2],oFont14n)		//	Linha Digitavel do Codigo de Barras   1934

oPrint:Line (0810,100,0810,2300 )
oPrint:Line (0910,100,0910,2300 )
oPrint:Line (0980,100,0980,2300 )
oPrint:Line (1050,100,1050,2300 )

oPrint:Line (0910,500,1050,500)
oPrint:Line (0980,750,1050,750)
oPrint:Line (0910,1000,1050,1000)
oPrint:Line (0910,1350,0980,1350)
oPrint:Line (0910,1550,1050,1550)

oPrint:Say  (0710,100 ,"Local de Pagamento"                             			,oFont8)
oPrint:Say  (0730,400 ,"ATE O VENCIMENTO PAGUE PREFERENCIALMENTE NO ITAU"     	,oFont9)
oPrint:Say  (0770,400 ,"APÓS O VENCIMENTO PAGUE SOMENTE NO ITAU"        			,oFont9)

oPrint:Say  (0710,1910,"Vencimento"                                     			,oFont8)
oPrint:Say  (0750,2010,DTOC(SE1->E1_VENCREA)                               				,oFont10)

oPrint:Say  (0810,100 ,"Beneficiario"                                     			,oFont8)
oPrint:Say  (0850,100 ,aDadEmp[1]+"                  - "+aDadEmp[6]					,oFont10) //Nome + CNPJ

oPrint:Say  (0810,1910,"Agência/Código Beneficiario"                      			,oFont8)
oPrint:Say  (0850,2010,aDadBanco[3]+"/"+aDadBanco[4]+"-"+aDadBanco[5]				,oFont10)

oPrint:Say  (0910,100 ,"Data do Documento"                              			,oFont8)
oPrint:Say  (0940,100 ,DTOC(aDadTit[2])                               				,oFont10) // Emissao do Titulo (E1_EMISSAO)

oPrint:Say  (0910,505 ,"Nro.Documento"                                  			,oFont8)
oPrint:Say  (0940,605 ,aDadTit[7]+"/"+aDadTit[1]												,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (0910,1005,"Espécie Doc."                                   			,oFont8)
oPrint:Say  (0940,1050,aDadTit[8]																,oFont10) //Tipo do Titulo

oPrint:Say  (0910,1355,"Aceite"                                         			,oFont8)
oPrint:Say  (0940,1455,"N"                                             				,oFont10)

oPrint:Say  (0910,1555,"Data do Processamento"                          			,oFont8)
oPrint:Say  (0940,1655,DTOC(aDadTit[3])                               				,oFont10) // Data impressao

oPrint:Say  (0910,1910,"Nosso Número"                                   			,oFont8)
oPrint:Say  (0940,2010,Substr(aDadTit[6],1,3)+"/"+Substr(aDadTit[6],4,8)+"-"+Substr(aDadTit[6],12,1)			,oFont10)

oPrint:Say  (0980,100 ,"Uso do Banco"                                   			,oFont8)

oPrint:Say  (0980,505 ,"Carteira"                                       			,oFont8)
oPrint:Say  (1010,555 ,aDadBanco[6]                                  				,oFont10)

oPrint:Say  (0980,755 ,"Espécie"                                        			,oFont8)
oPrint:Say  (1010,805 ,"R$"                                             			,oFont10)

oPrint:Say  (0980,1005,"Quantidade"                                     			,oFont8)
oPrint:Say  (0980,1555,"Valor"                                          			,oFont8)

oPrint:Say  (0980,1910,"Valor do Documento"                          				,oFont8)
oPrint:Say  (1010,2010,AllTrim(Transform(aDadTit[5],"@E 999,999,999.99"))			,oFont10)

oPrint:Say  (1050,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiario)",oFont8)
For nXi := 1 To Len(aMsgFrt)
	oPrint:Say  (1150+nIncMsg,100 , aMsgFrt[nXi]                                 ,oFont10) 
	nIncMsg	+=	50
Next

oPrint:Say  (1050,1910,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (1120,1910,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (1190,1910,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (1260,1910,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (1330,1910,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (1400,100 ,"Pagador"                                        ,oFont8)
oPrint:Say  (1430,400 ,aDatSac[1]                                 		,oFont10)
oPrint:Say  (1430,1850,"NFe: "+ aDadTit[9]                              ,oFont10) //MAX: Nota Fiscal Eletronica

oPrint:Say  (1483,400 ,aDatSac[2]                                    	,oFont10)
oPrint:Say  (1536,400 ,Subs(aDatSac[5],1,5)+"-"+Subs(aDatSac[5],6,3)+"    "+aDatSac[3]+" - "+aDatSac[4]		,oFont10) // CEP+Cidade+Estado
oPrint:Say  (1589,400 ,aDatSac[7]+aDatSac[6]										,oFont10) // CGC

oPrint:Say  (1589,1850,Substr(aDadTit[6],1,3)+"/"+Substr(aDadTit[6],4,8)+Substr(aDadTit[6],13,1)  ,oFont10)

oPrint:Say  (1605,100 ,"Pagador/Avalista"                               ,oFont8)
oPrint:Say  (1645,1500,"Autenticação Mecânica -"                        ,oFont8)
oPrint:Say  (1645,1900,"Recibo do Pagador"										,oFont10)

oPrint:Line (0710,1900,1400,1900 )
oPrint:Line (1120,1900,1120,2300 )
oPrint:Line (1190,1900,1190,2300 )
oPrint:Line (1260,1900,1260,2300 )
oPrint:Line (1330,1900,1330,2300 )
oPrint:Line (1400,100 ,1400,2300 )
oPrint:Line (1640,100 ,1640,2300 )

For nXi := 100 to 2300 step 50
	oPrint:Line( 1930, nXi, 1930, nXi+30)	// 1850
Next nXi

oPrint:Line (2080,100,2080,2300)	//   2000
oPrint:Line (2080,550,1980, 550)	//   2000 - 1900
oPrint:Line (2080,800,1980, 800) //   2000 - 1900

// LOGOTIPO
If File(aBmp)
	oPrint:SayBitmap( 1970,0100,aBmp,0100,0100 )
	oPrint:Say  (2010,240,"Banco Itaú SA",oFont10 )	// [2]Nome do Banco
Else
	oPrint:Say  (2014,100,aDadBanco[2],oFont15n )	// [2]Nome do Banco                     1934
EndIf

oPrint:Say  (1988,569,"341-7",oFont24 )			// [1]Numero do Banco                       1912
oPrint:Say  (2014,820,aCB_RN_NN[2],oFont14n)		//Linha Digitavel do Codigo de Barras   1934

oPrint:Line (2180,100,2180,2300 )
oPrint:Line (2280,100,2280,2300 )
oPrint:Line (2350,100,2350,2300 )
oPrint:Line (2420,100,2420,2300 )

oPrint:Line (2280, 500,2420,500)
oPrint:Line (2350, 750,2420,750)
oPrint:Line (2280,1000,2420,1000)
oPrint:Line (2280,1350,2350,1350)
oPrint:Line (2280,1550,2420,1550)

oPrint:Say  (2080,100 ,"Local de Pagamento"                             		,oFont8)
oPrint:Say  (2100,400 ,"Pagável em qualquer Banco até o Vencimento."        	,oFont9)
oPrint:Say  (2140,400 ,"Após o Vencimento pague somente no Banco Itaú."       ,oFont9)

oPrint:Say  (2080,1910,"Vencimento"                                     		,oFont8)
oPrint:Say  (2120,2010,DTOC(aDadTit[4])                               			,oFont10)

oPrint:Say  (2180,100 ,"Beneficiario"                                     		,oFont8)
oPrint:Say  (2220,100 ,aDadEmp[1]+"                  - "+aDadEmp[6]				,oFont10) //Nome + CNPJ

oPrint:Say  (2180,1910,"Agência/Código Beneficiario"                      		,oFont8)
oPrint:Say  (2220,2010,aDadBanco[3]+"/"+aDadBanco[4]+"-"+aDadBanco[5]			,oFont10)

oPrint:Say  (2280,100 ,"Data do Documento"                              		,oFont8)
oPrint:Say  (2310,100 ,DTOC(SE1->E1_VENCREA)                           			,oFont10) // Emissao do Titulo (E1_EMISSAO)

oPrint:Say  (2280,505 ,"Nro.Documento"                                  		,oFont8)
oPrint:Say  (2310,605 ,aDadTit[7]+"/"+aDadTit[1]											,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (2280,1005,"Espécie Doc."                                   		,oFont8)
oPrint:Say  (2310,1050,aDadTit[8]															,oFont10) //Tipo do Titulo

oPrint:Say  (2280,1355,"Aceite"                                         		,oFont8)  
oPrint:Say  (2310,1455,"N"                                             			,oFont10) 

oPrint:Say  (2280,1555,"Data do Processamento"                          		,oFont8)  
oPrint:Say  (2310,1655,DTOC(aDadTit[3])                               			,oFont10) // Data impressao  

oPrint:Say  (2280,1910,"Nosso Número"                                   		,oFont8)   
oPrint:Say  (2310,2010,Substr(aDadTit[6],1,3)+"/"+Substr(aDadTit[6],4, 8)+"-"+Substr(aDadTit[6],12, 1)			,oFont10)  

oPrint:Say  (2350,100 ,"Uso do Banco"                                   		,oFont8)   

oPrint:Say  (2350,505 ,"Carteira"                                       		,oFont8)   
oPrint:Say  (2380,555 ,aDadBanco[6]                                  			,oFont10)  

oPrint:Say  (2350,755 ,"Espécie"                                        		,oFont8)   
oPrint:Say  (2380,805 ,"R$"                                             		,oFont10)  

oPrint:Say  (2350,1005,"Quantidade"                                     		,oFont8)   
oPrint:Say  (2350,1555,"Valor"                                          		,oFont8)   

oPrint:Say  (2350,1910,"Valor do Documento"                          			,oFont8)   
oPrint:Say  (2380,2010,AllTrim(Transform(aDadTit[5],"@E 999,999,999.99"))		,oFont10)  

oPrint:Say  (2420,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiario)",oFont8) 
nIncMsg	:= 0
For nXi := 1 To Len(aMsgFrt)
	oPrint:Say  (2520 + nIncMsg,100 ,aMsgFrt[nXi]                                 ,oFont10) 
	nIncMsg	+=	50
Next  

oPrint:Say  (2420,1910,"(-)Desconto/Abatimento"                         ,oFont8)      
oPrint:Say  (2490,1910,"(-)Outras Deduções"                             ,oFont8)      
oPrint:Say  (2560,1910,"(+)Mora/Multa"                                  ,oFont8)      
oPrint:Say  (2630,1910,"(+)Outros Acréscimos"                           ,oFont8)      
oPrint:Say  (2700,1910,"(=)Valor Cobrado"                               ,oFont8)      

oPrint:Say  (2770,100 ,"Pagador"                                        ,oFont8)
oPrint:Say  (2800,400 ,aDatSac[1]                                 		,oFont10)
oPrint:Say  (2800,1850,"NFe: "+ aDadTit[9]                              ,oFont10) //MAX: Nota fiscal Eletronica

oPrint:Say  (2853,400 ,aDatSac[2]                                    	,oFont10)   
oPrint:Say  (2906,400 ,Subs(aDatSac[5],1,5)+"-"+Subs(aDatSac[5],6,3)+"    "+aDatSac[3]+" - "+aDatSac[4]		,oFont10)			// CEP+Cidade+Estado
oPrint:Say  (2959,400 ,aDatSac[7]+aDatSac[6]										,oFont10)

oPrint:Say  (2959,1850,Substr(aDadTit[6],1,3)+"/"+Substr(aDadTit[6],4,8)+Substr(aDadTit[6],13,1)  ,oFont10)         

oPrint:Say  (2975,100 ,"Pagador/Avalista"                               ,oFont8)
oPrint:Say  (3015,1500,"Autenticação Mecânica -"                        ,oFont8)
oPrint:Say  (3015,1850,"Ficha de Compensação"                           ,oFont10)      

oPrint:Line (2080,1900,2770,1900 )
oPrint:Line (2490,1900,2490,2300 )
oPrint:Line (2560,1900,2560,2300 )
oPrint:Line (2630,1900,2630,2300 )
oPrint:Line (2700,1900,2700,2300 )
oPrint:Line (2770,100 ,2770,2300 )

oPrint:Line (3010,100 ,3010,2300 )

nCb1Lin	:= 14.5
nCb2Lin	:= 26.1
nCbaCol	:= 1.3
nCbaLag	:= 0.0280
nCbaAlt	:= 1.4

//MsBar3("INT25"  ,nCb1Lin,nCbaCol,aCB_RN_NN[1]  ,oPrint,.F.,,,nCbaLag,nCbaAlt,,,,.F.)
MsBar3("INT25"  ,nCb2Lin,nCBaCol,aCB_RN_NN[1]  ,oPrint,.F.,,,nCbaLag,nCbaAlt,,,,.F.)


oPrint:EndPage() // Finaliza a página

Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGerCodLin()
Gera a codificacao da Linha digitável gerando o codigo de barras.
Retorna os strings para inpressão do Boleto
CB = String para o cód.barras, RN = String com o número digitável
Cobrança não identificada, número do boleto = Título + Parcela

@protected                   
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@param	aDadBco	- Informações do banco
@param	nValor	- Valor do título
@param	dVencto	- Data de Vencimento
@param	cParc		- Parcela.
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FGerCodLin(aDadBco,nValor, dVencto, cParc)
Local 	nDvNn         	:= 0
Local 	nDvCb         	:= 0
Local 	nDv           	:= 0

Local 	cNN           	:= ""
Local 	cRN           	:= ""
Local 	cCB           	:= ""
Local 	cStr          	:= ""
Local 	cFator      	:= U_FSFatVenc(dVencto)
Local 	cDocNuFin 		:= ""
Local 	cValFin 			:= StrZero((nValor*100),10) //MAX: Removido a funcção INT(nValor*100)
Local		cBanco			:=	Subs(aDadBco[1],1,3)+"9" 
Local 	cAgencia			:=	AllTrim(aDadBco[3])
Local		cConta			:=	AllTrim(SubStr(aDadBco[4],1,5))
Local		cDacCC			:=	AllTrim(aDadBco[6])
Local		cCart				:=	AllTrim(aDadBco[5])

cDocNuFin	:= AllTrim(U_FSPrcNum(aDadBco))

If !Empty(SE1->E1_NUMBCO)
	nDvNn			:=	Val(SubStr(cDocNuFin, 9, 1))
	cDocNuFin	:=	SubStr(cDocNuFin,1, 8)              
	cNN   		:= cCart + cDocNuFin + AllTrim(Str(nDvNn))
Else
	//Composicao Filial + SA6->A6_ZNOSSON + Parcela
	cDocNuFin := StrZero(Val(cDocNuFin),8) // cDocNuFin := cFilAnt + SubStr((StrZero(Val(cDocNuFin),6)),2,5) + cParc
	
	//	Definicao do NOSSO NUMERO
	cStr    	:=  cAgencia + cConta + cCart + cDocNuFin
	nDvNn 	:= Val(U_FSFMod10(cStr)) // digit	o verifacador Agencia + Conta + Carteira + Nosso Num
	cNN   	:= cCart + cDocNuFin + AllTrim(Str(nDvNn))
	
	// Grava o nosso numero no SE1	
	SE1->(RecLock("SE1",.F.))
	SE1->E1_NUMBCO		:=	cDocNuFin + AllTrim(Str(nDvNn))
	SE1->E1_ZBANCO		:= aDadBco[1]
	SE1->(MsUnlock())
EndIf

//	Definicao do CODIGO DE BARRAS
cStr    := cBanco + cFator + cValFin + cCart + cDocNuFin + AllTrim(Str(nDvNn)) + cAgencia + cConta + cDacCC + '000'
nDvCb 	:= Val(U_FSFMod11(cStr))
cCB   	:= SubStr(cStr, 1, 4) + AllTrim(Str(nDvCb)) + SubStr(cStr,5)

//	Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCDDX		DDDDD.DEFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV
//
// CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	  B 	= Codigo da moeda, sempre 9
//	CCC 	= Codigo da Carteira de Cobranca
//	 DD 	= Dois primeiros digitos no nosso numero
//	  X 	= DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cStr    	:= cBanco + cCart + SubStr(cDocNuFin,1,2)
nDv   	:= Val(U_FSFMod10(cStr))
cRN   	:= SubStr(cStr, 1, 5) + '.' + SubStr(cStr, 6, 4) + AllTrim(Str(nDv)) + '  '

// 	CAMPO 2:
//	DDDDDD = Restante do Nosso Numero
//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
//	   FFF = Tres primeiros numeros que identificam a agencia
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cStr    	:= SubStr(cDocNuFin, 3, 6) + AllTrim(Str(nDvNn)) + SubStr(cAgencia, 1, 3)
nDv   	:= Val(U_FSFMod10(cStr))
cRN   	:= cRN + SubStr(cStr, 1, 5) + '.' + SubStr(cStr, 6, 5) + AllTrim(Str(nDv)) + '  '

// 	CAMPO 3:
//	     F = Restante do numero que identifica a agencia
//	GGGGGG = Numero da Conta + DAC da mesma
//	   HHH = Zeros (Nao utilizado)
//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cStr    := SubStr(cAgencia, 4, 1) + cConta + cDacCC + '000'
nDv   	:= Val(U_FSFMod10(cStr))
cRN   	:= cRN + SubStr(cStr, 1, 5) + '.' + SubStr(cStr, 6, 5) + AllTrim(Str(nDv)) + '  '

// 	CAMPO 4:
//	     K = DAC do Codigo de Barras
cRN   := cRN + AllTrim(Str(nDvCb)) + '  '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cRN   := cRN + cFator + StrZero((nValor * 100),14-Len(cFator)) //MAX: Removido a função INT(nValor*100)

Return({cCB,cRN,cNN})


