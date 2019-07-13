#Include "TOTVS.CH"
#Include "RWMAKE.CH" 
#XCOMMAND IF <nVar> BETWEEN <nVal1> AND <nVal2> => IF <nVar> >= <nVal1> .And. <nVar> <= <nVal2>

Static __aNotas	:= {}   

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSCOMP01          
Realiza a validação na geração da nota de conhecimento de frete.

@author 	Fernando dos Santos Ferreira 
@since 	13/08/2013
@version P11
@obs  
	
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSCOMP01()   
Local 	aAreaOld		:= {SF1->(GetArea()), SD1->(GetArea()), AIB->(GetArea()), GetArea()}
Local		aItensNot	:= { }
Local		cMessage		:= ""
Local		lReturn		:= .T.
Local		nXi			:= 0
Local		nOldN			:= 0
Local		nPosPrd		:= 0
Local		nVlrMax		:= 0
Local		nVlrMin		:= 0
Local		nTMTMAXFRT	:= GetMv("TM_TMAXFRT") / 100
Local		nTMTMINFRT	:= GetMv("TM_TMINFRT") / 100

// Preservo a posição da Variavel N
nOldN := N

// D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
SD1->(dbSetOrder(01))
For nXi := 1 To Len(__aNotas)
	If SD1->(MsSeek(xFilial("SD1")+__aNotas[nXi][01]+__aNotas[nXi][02]+__aNotas[nXi][03]+__aNotas[nXi][04]))
		While(SD1->(!Eof()))	.And. SD1->D1_FILIAL == xFilial("SD1") ;
									.And. SD1->D1_DOC == __aNotas[nXi][01] ;
									.And. SD1->D1_SERIE == __aNotas[nXi][02] ;
									.And. SD1->D1_FORNECE == __aNotas[nXi][03] ;
									.And. SD1->D1_LOJA == __aNotas[nXi][04]
			If Empty(aItensNot) .Or. (nPosPrd := aScan( aItensNot, {|x| x[1] == SD1->D1_COD } )) == 0
				AAdd( aItensNot, {;	
											SD1->D1_COD, ;   		// [01] Código do Produto
											SD1->D1_TABFOR, ;		// [02] Tabela do Fornecedor
											SD1->D1_FORNECE, ;	// [03] Código do Fornecedor
											SD1->D1_LOJA, ;		// [04] Loja do Fornecedor
											SD1->D1_QUANT, ;		// [05] Quantidade do Fornecedor
											 0, ;						// [06] Total do Frete
											  0 ;						// [07] Valor Unitário do Frete
											  } )
			Else
				aItensNot[nPosPrd][05] += SD1->D1_QUANT
			EndIf
			SD1->(dbSkip())									
		EndDo
	EndIf
Next

// Preencho o valor do frete dos itens
For nXi := 1 To Len(aCols)
	N := nXi
	If !GDDeleted()
		If (nPosPrd := aScan( aItensNot, {|x| x[01] == aCols[nXi][GDFieldPos("D1_COD")] } )) > 0
			aItensNot[nPosPrd][06] += aCols[nXi][GDFieldPos("D1_TOTAL")]
		EndIf
	EndIf
Next

// Realizo a divisão do valor do frete pela quantidade dos produtos
aEval( aItensNot, { |x| x[07] := x[06] / x[05] } )

// Verifico se o valor unitário do frete encontrado é 
// igual ao valor do frete unitário definido na AIB
AIB->(dbOrderNickName("AIBUSR1"))
For nXi := 1 To Len(aItensNot)
	If AIB->(MsSeek(xFilial("AIB") + aItensNot[nXi][01] + aItensNot[nXi][03] + aItensNot[nXi][04] + aItensNot[nXi][02] ))
		nVlrMax	:= AIB->AIB_FRETE + ( AIB->AIB_FRETE * nTMTMAXFRT )
		nVlrMin	:= AIB->AIB_FRETE - ( AIB->AIB_FRETE * nTMTMINFRT )
		
		 //If aItensNot[nXi][05] Between nVlrMin And nVlrMax
		 If (aItensNot[nXi][06]/aItensNot[nXi][05]) Between nVlrMin And nVlrMax
			lReturn := .T.
		 Else
			cMessage += "Produto: " + aItensNot[nXi][01] + " " +Posicione("SB1", 1, xFilial("SB1")+aItensNot[nXi][01], "B1_DESC") + Chr(13)+Chr(10) + ;
						  	"Valor do Produto na Tabela: " + Transform(AIB->AIB_PRCCOM,"@E 999,999.999999") + Chr(13)+Chr(10) +;
						   "Valor do Frete na Tabela: " + Transform(AIB->AIB_FRETE,"@E 999,999.999999") + Chr(13)+Chr(10)+;
						   "Valor do Frete Unitario: " + Transform(Round(aItensNot[nXi][06]/aItensNot[nXi][05], TamSx3("AIB_FRETE")[2]),"@E 999,999.999999") + Chr(13)+Chr(10) +;
						   "Valor Total do Frete: " + Transform(aItensNot[nXi][06],"@E 999,999.999999") + Chr(13)+Chr(10)
						    // "Valor Frete Encontrado: " + Transform(Round(aItensNot[nXi][05], TamSx3("AIB_FRETE")[2]),"@E 999,999.999999") + Chr(13)+Chr(10)
			lReturn := .F.
			Exit
		EndIf
	EndIf
Next

If !lReturn
	MSGBOX( "Valor informado, diverge do valor cadastrado na Tabela de Preços de Fornecedores... ", "Atenção: Contacte o Dpto.Tecnológico!", "STOP"  )
	MSGBOX( cMessage, "Atenção: Contacte o Dpto.Tecnológico!", "STOP"  )
Else
	__aNotas	:= {}   
EndIf

aEval( aAreaOld, {|x| RestArea(x) } )
// Volto o posicionamento da variavel N
N := nOldN

Return lReturn

//------------------------------------------------------------------- 
/*/{Protheus.doc} FPutNotas
Inclui a chave do sd1 na variavel static para realizara a validação

@author 	Fernando dos Santos Ferreira 
@since 	13/08/2013
@version P11
@obs  
	
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FPutNotas( cDocument, cSerie, cFornece, cLoja )
AAdd(__aNotas, { cDocument, cSerie, cFornece, cLoja } )
Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FDelNotas
Retira todas as notas do array estático

@author 	Fernando dos Santos Ferreira 
@since 	13/08/2013
@version P11
@obs  
	
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FDelNotas(cDocument, cSerie, cFornece, cLoja)
Local		nPos		:= 0
Local		nXi		:= 0
Local		aAuxil	:= {}

nPos := aScan(__aNotas, {|x| x[01]== cDocument .And. x[02]== cSerie .And. x[03]== cFornece .And. x[04]== cLoja } )

If nPos > 0
	For nXi := 1 To Len(__aNotas)
		If nXi != nPos
			AAdd(aAuxil, __aNotas[nXi])
		EndIf
	Next
EndIf

__aNotas := aAuxil

Return 
