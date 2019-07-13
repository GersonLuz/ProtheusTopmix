#Include "Protheus.ch"   
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSLib003

Função criada para efeitos de compatibilidade evitando que seja criada uma função com o 
nome deste prw.

@author        Fernando Ferreira
@since         08/08/2011
@version       P11
/*/
//---------------------------------------------------------------------------------------
User Function FSLIB003()
Return Nil        

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSCalPar
Realiza a conversão de parcelas Letra Alfabeto para Numero

@author Fernando Ferreira
@since 24/06/2010 
@param cPar			String
@param nTamCar		Numero de Zeros que será incluido no cPar 
@return cPar
/*/
//---------------------------------------------------------------------------------------
User Function FSCalPar(cPar, nTamCar)
Default	cPar		:= ""
Default	nTamCar	:= 1

If Empty(cPar)
	cPar := "0"
ElseIf Upper(Alltrim(cPar)) $ "A/B/C/D/E/F/G/H/I/J/L/M/N/O/P/Q/R/S/T/U/V/X/Z/Y/W" 
	cPar := StrZero(ASC(Upper(cPar)) - 64, nTamCar)
	cPar := IIF(Val(cPar) >= 0,cPar,"0")
Else
	cPar := StrZero(Val(cPar),nTamCar)
EndIf

Return cPar

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSGetIns
Função que retorna um array de 3 posições com as instruções do banco

@author Fernando Ferreira
@since 24/06/2010 
@param nBco			1 = Itau, 2 Santander e 3 Bradesco
@return aBolTxt	Array com as Instruções preenchidas.
/*/
//---------------------------------------------------------------------------------------
User Function FSGetIns(nBco)
Local aBolTxt	:= {}	

Default nBco	:= 0

Do Case
	Case nBco == 1
		AAdd(aBolTxt,SuperGetMV("FS_ITAU1", .F.))
		AAdd(aBolTxt,SuperGetMV("FS_ITAU2", .F.))
		AAdd(aBolTxt,SuperGetMV("FS_ITAU3", .F.))
	Case nBco == 2	   
		AAdd(aBolTxt,SuperGetMV("FS_SANTAN1", .F.))                                          
		AAdd(aBolTxt,SuperGetMV("FS_SANTAN2", .F.))
		AAdd(aBolTxt,SuperGetMV("FS_SANTAN3", .F.))
	Case nBco == 3	   
		AAdd(aBolTxt,SuperGetMV("FS_BRADES1", .F.))
		AAdd(aBolTxt,SuperGetMV("FS_BRADES2", .F.))
		AAdd(aBolTxt,SuperGetMV("FS_BRADES3", .F.))		
	Otherwise
		aBolTxt	:= {}
EndCase		

Return AClone(aBolTxt)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSGetSca
Função que retorna as informações sobre o cliente para impressão
	
@author 	Fernando Ferreira
@since 		05/10/2011 
@param 		cCodSac			Código do cliente
@param 		cLojSac			Loja do cliente
@param		lGetLabSa1		Se true coloca o label CNPJ ou CPF
@return 	aDatSac		Array com as informações do cliente/Sacado.
/*/
//---------------------------------------------------------------------------------------
User Function FSGetSca(cCodSac, cLojSac, cNumTitRec, cPrfTitRec)
Local		aAreSA1	:=	GetArea("SA1") 
Local		aAreSC5	:=	GetArea("SC5")
Local		aAreSC6	:=	GetArea("SC6") 
Local		aAreCC2	:=	GetArea("CC2")

Local		aDatSac	:= {}

Local 	cTipSac	:=	""            

Local		lChkEpy	:=	.T.

Default	cCodSac		:=	Space(TamSx3 ("A1_COD")[1])
Default	cLojSac		:=	Space(TamSx3 ("A1_LOJA")[1])
Default	cNumTitRec	:= SE1->E1_NUM
Default	cPrfTitRec	:= SE1->E1_PREFIXO

//Posiciona o SA1 (Cliente)
SA1->(DbSetOrder(1)) // Filial+Código+Loja
SA1->(DbSeek(xFilial("SA1") + cCodSac + cLojSac))

SC6->(DbSetOrder(4)) // Filial+Doc+Serie
SC6->(DbSeek(xFilial("SC6") + cNumTitRec + cPrfTitRec))

SC5->(DbSetOrder(1)) // Filial+Num
SC5->(DbSeek(xFilial("SC5") + SC6->C6_NUM))


If	SC5->(!Eof()) .And. SC5->C5_FILIAL == xFilial("SC5") .And. ;
							SC5->C5_CLIENTE == cCodSac .And. ;
							SC5->C5_LOJAENT == cLojSac .And. ;
							FValEptFil()

	AAdd(aDatSac,	AllTrim(SA1->A1_NREDUZ))																	                          // [1] Razão Social
	
	If Empty(SC5->C5_ZENDNUM)
		AAdd(aDatSac,	AllTrim(SC5->C5_ZENDCOB)+" "+AllTrim(SC5->C5_ZCOMPLE)+" - "+AllTrim(SC5->C5_ZBAIROC))	                          // [2] Endereço
	Else
		AAdd(aDatSac,	AllTrim(SC5->C5_ZENDCOB)+","+AllTrim(SC5->C5_ZENDNUM)+" "+AllTrim(SC5->C5_ZCOMPLE)+" - "+AllTrim(SC5->C5_ZBAIROC))// [2] Endereço	
	End If
	
	AAdd(aDatSac,	AllTrim(U_FSRetMun(TRBCABEC->C5_ZEST , TRBCABEC->C5_ZMUN)))							// [3] Municipio
	AAdd(aDatSac,	SC5->C5_ZEST)																		// [4] Estado
	AAdd(aDatSac,	SC5->C5_ZCEP)		     															// [5] CEP
	AAdd(aDatSac,	Transform(SA1->A1_CGC,PicPesFJ(IIf(Len(AllTrim(SA1->A1_CGC))<14,"F","J"))))	        // [6] CGC	
	AAdd(aDatSac,	IIF(Len(AllTrim(SA1->A1_CGC))<14,"C.P.F.: ","C.N.P.J: "))							// [7] Tipo do Cliente J = Juridica ou F = Fisica
	
Else
    
   // Caso não encontre ou não venha do KP
	AAdd(aDatSac,	SubStr(AllTrim(SA1->A1_NOME), 1, 46))															// [1] Razão Social
	AAdd(aDatSac,	AllTrim(SA1->A1_ENDCOB)+" - "+AllTrim(SA1->A1_BAIRROC))     							// [2] Endereço	
	AAdd(aDatSac,	AllTrim(SA1->A1_MUNC))																					// [3] Municipio
	AAdd(aDatSac,	SA1->A1_ESTC)																									// [4] Estado
	AAdd(aDatSac,	SA1->A1_CEPC)																									// [5] CEP	
	AAdd(aDatSac,	Transform(SA1->A1_CGC,PicPesFJ(IIf(Len(AllTrim(SA1->A1_CGC))<14,"F","J"))))	// [6] CGC
	AAdd(aDatSac,	IIF(Len(AllTrim(SA1->A1_CGC))<14,"C.P.F.: ","C.N.P.J: "))								// [7] Tipo do Cliente J = Juridica ou F = Fisica
	
EndIf            

AAdd(aDatSac,	SA1->A1_INSCR)																									// [8] Inscrição Estadual
AAdd(aDatSac,SA1->A1_INSCRM)																									// [9] Inscrição Municipal
AAdd(aDatSac,AllTrim(SA1->A1_ENDCOB))																					// [10] Endereco de cobranca
AAdd(aDatSac,AllTrim(SA1->A1_BAIRROC))																					// [11] Bairro de cobrança
AAdd(aDatSac,AllTrim(SA1->A1_CGC))																							// [12] CGC sem Formatação

RestArea(aAreSA1) 
RestArea(aAreSC5)
RestArea(aAreSC6) 
RestArea(aAreCC2)

Return AClone(aDatSac) 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FValEptFil()
Verifica se os  campos endereços estão vazios no Pedido de Venda.


@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FValEptFil()
Local aFilSc5  := {}
Local lRet		:= .T.

AAdd(aFilSc5, AllTrim(SC5->C5_ZENDCOB))
AAdd(aFilSc5, AllTrim(SC5->C5_ZBAIROC))
AAdd(aFilSc5, AllTrim(SC5->C5_ZMUN))
AAdd(aFilSc5, AllTrim(SC5->C5_ZEST))
AAdd(aFilSc5, AllTrim(SC5->C5_ZCEP))

For nXi := 1 To Len(aFilSc5)
	If Empty(aFilSc5[nXi])
		lRet	:= .F.	
	EndIf
Next

Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSPrcNum
Realiza o incremento do nosso numero e realiza a alterações no titulo na tabela SE1. 
Retorna o ultimo nosso numero da tabela SA6.

@author 	Fernando Ferreira
@since 	05/10/2011 
@param 	aBco			Informações sobre o banco
@return 	cNosNum		Nosso número do banco.
/*/
//---------------------------------------------------------------------------------------
User Function FSPrcNum(aBco)
Local cNosNum :=  ""

Default aBco  :=  {	Space(TamSx3 ("A6_COD")[1]) 		,;		// Código do banco
							Space(TamSx3 ("A6_NOME")[1])		,;		// Nome do banco
							Space(TamSx3 ("A6_AGENCIA")[1])	,;		// Agência do banco
							Space(TamSx3 ("A6_NUMCON")[1])	,;		// Número da conta corrente
							Space(TamSx3 ("A6_CARTEIR")[1])}			// Carteira utilizada 

If Empty(SE1->E1_NUMBCO) .And. Empty(SE1->E1_ZBANCO)
	SA6->(RecLock("SA6",.F.))
	If aBco[1] == "033"
		cNosNum :=  StrZero(Val(SA6->A6_ZNOSSON) + 1, 07)
	Else
		cNosNum :=  StrZero(Val(SA6->A6_ZNOSSON) + 1, 11)
	EndIf
	SA6->A6_ZNOSSON :=	cNosNum
	SA6->(MsUnlock())
Else
  If Alltrim(SE1->E1_ZBANCO) == aBco[1]   
  	cNosNum	:=	Alltrim(SE1->E1_NUMBCO)
  EndIf 	            	
EndIf

Return cNosNum 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFMod10
Faz a verificacao e geracao do digto Verificador no Modulo 10


@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@param	cData	Caracteres que utilizados como base na geração do digito.
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 

User Function FSFMod10(cData)
Local L		:=	0
Local	D		:=	0
Local	P 		:= 0
Local B     := .F.

L := Len(cData)
B := .T.
D := 0
While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		End
	End
	D := D + P
	L := L - 1
	B := !B
End
D := 10 - (Mod(D,10))
If D = 10
	D := 0
End

D	:= Str(D, 1, 0)

Return(D)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFMod11()
Faz a verificacao e geracao do digito Verificador no Modulo 11.


@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@param	cData	Caracteres que utilizados como base na geração do digito.
@param	nTip	Define o retorno do digito gerado. 1: Itau, 2:Santander, 3:Bradesco.
@param	nBase	Base que será usada na geração do digito
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFMod11(cData, nTip, nBase)

Local L	:=	0
Local	D	:=	0
Local	P 	:= 0

Default	cData	:= ""
Default	nTip	:=	1
Default	nBase	:= 9

L := Len(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D += (Val(SubStr(cData, L, 1)) * P)
	If P = nBase
		P := 1
	End
	L := L - 1
End

D := 11 - (mod(D,11))

If nTip == 1    // Itaú
	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	End
EndIf	  

If nTip == 2 	// Nosso Numero Santander
	If D == 10 .Or. D == 11
		D := 0	
	EndIf		
EndIf

If nBase == 7 // Nosso Numero Bradesco
	Do Case
		Case 	D = 11
			D := "0"
		Case 	D = 10
			D := "P"
		Otherwise
			D := STR( D, 1, 0 )
	EndCase
EndIf

If ValType(D) == "N"
	D	:= Str(D, 1, 0)
End If

Return(D)



//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSFatVenc
Função que Retorna o Fator de Vencimento utilizado nos Boletos Bancarios

@author	Luciano M Pinto
@since 	07/10/2011 
@param 	dVencRea	Data de Vencimento Real E1_VENCREA
@return cRetFun		Fator de Vencimento
/*/
//---------------------------------------------------------------------------------------
User Function FSFatVenc( dVencRea ) 
/***********************************************************************
* Chamada inicial da Função
*
*
***/
Local 	cRetFun := ""
Default dVencRea:= CtoD("07/10/1997")

//}cRetFun	:= Alltrim(Str(dVencRea - CtoD("07/10/1997"))) // acha a diferenca em dias para o fator de vencimento
cRetFun	:= Alltrim(Str(SE1->E1_VENCREA - CtoD("07/10/1997"))) // acha a diferenca em dias para o fator de vencimento

Return(cRetFun)

//-------------------------------------------------------------------
/*/{Protheus.doc} FSQbrStr
Quebra uma string de acordo com o tamanho especificado


@author        Fernando Ferreira
@since         03/11/2011
@param	cString 	Caracteres a ser divido
@param	nTamanho	Tamanho que terá a quebra
@param	cQuebra	caracter que identifica a quebra
@return	aString 	Array de string de acordo com as quebras.
@Obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
/*/
//-------------------------------------------------------------------
User Function FSQbrStr(cString,nTamanho, cQuebra)

Local aString := {} 
Local nX 
Local cStrAux

While Len(cString) > 0
	
	cString := AllTrim(cString)
	cStrAux := Subs(cString, 1, nTamanho)
	
	If Len(cString) > 0 .And. Len(cStrAux) >= nTamanho
		nX := nTamanho
		While nX > 0 .And. Subs(cStrAux, Len(cStrAux), 1) != cQuebra
			nX--
			cStrAux := Subs(cStrAux, 1, nX)
		End
	
		If nX > 0
			cString := Subs(cString, nX+1)
		Else
			cStrAux := Subs(cString, 1, nTamanho)	
		   cString := Subs(cString, nTamanho+1)
		EndIf
	Else
		cStrAux := Subs(cString, 1, nTamanho)	
	   cString := Subs(cString, nTamanho+1)
	EndIf	
	aAdd(aString, Padr(cStrAux,nTamanho))
EndDo

Return aString 



//-------------------------------------------------------------------
/*/{Protheus.doc} FSAjuDat
Ajusta data do AAAAMMDD para DDMMAAAA

@protect          
@author Giulliano Santos
@since 31/10/2011 
@version P11
@obs 
Projeto FS005495

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSAjuDat(_dDtOri)

_cDtOri := DTOS(_dDtOri)

Return SubStr(_cDtOri,7,2) + "/" + SubStr(_cDtOri,5,2) + "/" + SubStr(_cDtOri,1,4)    


//------------------------------------------------------------------- 
/*/{Protheus.doc} FSAjusImp() 
Ajusta a impressao na impressora matricial

@protect          
@author Giulliano Santos
@since 31/10/2011 
@version P11
@obs 
Projeto FS005495
 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSAjusImp()

Local nLin:= 0                // Contador de Linhas
Local nLinIni:=0

If aReturn[5]==2
	nOpc       := 1
	#IFNDEF WINDOWS
	cCor       := "B/BG"
   #ENDIF
	While .T.
		SetPrc(0,0)
		dbCommitAll()
		@ nLin ,000 PSAY " "
		@ nLin ,004 PSAY "*"
		@ nLin ,022 PSAY "."
		#IFNDEF WINDOWS
			Set Device to Screen
  			DrawAdvWindow(" Formulario ",10,25,14,56)
			SetColor(cCor)
			@ 12,27 Say "Formulario esta posicionado?"
			nOpc:=Menuh({"Sim","Nao","Cancela Impressao"},14,26,"b/w,w+/n,r/w","SNC","",1)
			Set Device to Print
	   #ELSE
			IF MsgYesNo("Fomulario esta posicionado ? ")
				nOpc := 1
		   ElseIF MsgYesNo("Tenta Novamente ? ")
				nOpc := 2
		   Else
				nOpc := 3
		  Endif
	   #ENDIF
		Do Case
			Case nOpc==1
				lContinua:=.T.
				Exit
		  		Case nOpc==2
		   		Loop
		  		Case nOpc==3
				lContinua:=.F.
				Return
	   	EndCase
   	EndDo
	Endif
Return Nil   


//-------------------------------------------------------------------
/*/{Protheus.doc} FSFecAre
Fecha as areas de trabalho deletando os arquivos temporarios

@protect          
@author Giulliano Santos
@since 31/10/2011 
@version P11
@params Array com os cAlias que serao fechados ex: {"SA1", "SB1" , "SF2"}
@obs 
Projeto FS005495

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSFecAre(aArray)

Local nX := 0

For nX := 1 To Len(aArray)
	If (Select(aArray[nX])!= 0)
	   &(aArray[nX])->(dbCloseArea())
		If File(aArray[nX] + GetDBExtension())
	 	  	FErase(aArray[nX] + GetDBExtension())
	  	EndIf
	EndIf	     
Next nX

Return Nil           

//-------------------------------------------------------------------
/*/{Protheus.doc} FSPrcVal
Retorna o valor do título após processar abatimentos, Acrescimos e 
decrescimos.

@protect          
@author Fernando Ferreira
@since 04/01/2012
@version P11
@params nValTit Valor do Titulo a processar
@obs    O Título tem que estar posicionado

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSPrcVal(nValTit)

Local		nValPrc	:= 0		// Valor Processado
Local		nValAbt	:= 0		// Valor do Abatimento
Local		nValAcr	:=	0		// Valor do Acrescimo
Local		nValDcr	:= 0		// Valor do Descrescimo

Local    cMsgRet  := "Tit: "+SE1->(E1_PREFIXO+"-"+E1_NUM+"-"+E1_PARCELA)
Local    cPasta   := "GERACAO_BOLETO_LOG"
Local    cLogFile := GetSrvProfString("Startpath","") + cPasta+"\LogImpBoleto_"+Left(DtoS(date()),6)+"_"+Alltrim(SM0->M0_CodFil) + ".LOG"

Default	nValTit	:= 0		

cMsgRet += IIf(nValTit > 0,+", Valor: "+Alltrim(Transform(nValTit,"9,999,999.99")),"")
	
If nValTit >= 0
	// Utilizo a função SomaAbat para retornar os valor dos abatimentos
	nValAbt	:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA)
	
	If SE1->E1_VALOR == SE1->E1_SALDO
		// Pego o valor de Acrescimo.
		nValAcr	:= SE1->E1_SDACRES
		// Pego o valor do Decrescimo.
		nValDcr	:= SE1->E1_SDDECRE	
	EndIf
   
	// Processo o valor do Título
	nValPrc := nValTit + nValAcr - nValDcr - nValAbt                   
	
	cMsgRet += IIf(nValAcr > 0,", Acrescimo: " +Alltrim(Transform(nValAcr,"99,999.99")),"")
	cMsgRet += IIf(nValDcr > 0,", Decrescimo: "+Alltrim(Transform(nValDcr,"99,999.99")),"")
	cMsgRet += IIf(nValAbt > 0,", Abatimento: "+Alltrim(Transform(nValAbt,"99,999.99")),"")
	cMsgRet += IIf(nValAbt > 0,", Liquido: "   +Alltrim(Transform(nValPrc,"99,999.99")),"")
EndIf

U_FLogFile( cMsgRet , "" , cLogFile , cPasta)

Return nValPrc

//-------------------------------------------------------------------
/*/{Protheus.doc} FSGetSm0
Retorna as informações da filial passada no parâmetro

@protect          
@author Fernando Ferreira
@since 05/01/2012
@version P11
@params cCodEmp Código da Empresa corrente.
@params cCodFil Código da Filial a ser pesquisado
@return aDadFil Array contendo as informações da filial com campos já formatados

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSGetSm0(cCodEmp, cCodFil)
Local		aDadEmp	:= {}
Local		aAreSm0 	:= {}

Default	cCodEmp	:= cEmpAnt
Default	cCodFil	:= cFilAnt

aAreSm0	:= SM0->(GetArea())

SM0->(dbSetOrder(1))
SM0->(dbSeek(cCodEmp+cCodFil))

If SM0->(!Eof())
	AAdd(aDadEmp,	AllTrim(SM0->M0_NOMECOM))																			//[1]Nome da Empresa
	AAdd(aDadEmp,	SM0->M0_ENDCOB)                      		 												 	//[2]Endereço
	AAdd(aDadEmp,	AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB)			//[3]Complemento
	AAdd(aDadEmp,	"CEP: "+TransForm(SM0->M0_CEPCOB,PesqPict("SA1","A1_CEP"))) 							//[4]CEP
	AAdd(aDadEmp,	"PABX/FAX: "+SM0->M0_TEL)																			//[5]Telefones
	AAdd(aDadEmp,	" CNPJ:" + Transform(SM0->M0_CGC,PesqPict("SA1", "A1_CGC")))							//[6]CGC
	AAdd(aDadEmp,	"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+     	; 				//[7]
						Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)) 										//[7]I.E
EndIf

RestArea(aAreSm0)
Return AClone(aDadEmp)

                      
