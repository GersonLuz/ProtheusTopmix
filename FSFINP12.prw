#Include "Protheus.ch"
#Define _CRLF CHR(13) + CHR(10)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINP12
Chamado ponto de entrada FA040GRV

@author Giulliano Santos
@since  19/03/2012 
@version P11
@obs  

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFINP12()

FMntDado()

Return Nil


//------------------------------------------------------------------- 
/*/{Protheus.doc} FMntDado()
Função para preparar os dados

@author Giulliano Santos
@since  19/03/2012 
@version P11
@obs  

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FMntDado()

Local dDataEmis := SE1->E1_EMISSAO
Local nValor 	 := SE1->E1_VALOR
Local nVezes	 := val(SE1->E1_ZNVEZES)
Local nTaxa 	 := SE1->E1_ZTAXA
Local cOp 		 := SE1->E1_ZOP
Local nVenPad	 := 0
Local nVenFin	 := 0
Local cOperad	 := ""
Local cLoja		 := ""   
Local	cTipo   	 := "" 	
Local lErro 	 := .F.

P05->(dbSetOrder(1))//P05_FILIAL, P05_REFOPE, P05_CODOPE, P05_LOJA, R_E_C_N_O_, D_E_L_E_T_
                                                                   
If P05->(dbSeek(xFilial("P05") + cOp))
	nVenPad := P05->P05_VENPAD
	nVenFin := P05->P05_VENFIN 
   cOperad := P05->P05_CODOPE
   cLoja	  := P05->P05_LOJA 
   cTipo	  := P05->P05_TIPO  
   cOper	  := P05->P05_TIPOP
EndIf

aVezes := aClone(FCondicao(dDataEmis,nValor,nVezes,nTaxa,nVenPad,nVenFin,cTipo,cOper,))

MsgRun("Efetuando lançamento dos tipos RCT","Por favor, Aguarde....",{|| lErro := FGeraSE1(aVezes,cOperad,cLoja,nTaxa)})

If lErro
	MsgAlert("A rotina apresentou erros, entre em contato com administrador do sistema!")
EndIf


Return Nil


//------------------------------------------------------------------- 
/*/{Protheus.doc} FCondicao()
Calcula a condição de pagamento

@author Giulliano Santos
@since  19/03/2012 
@version P11
@obs  

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FCondicao(dDataEmis,nValor,nVezes,nTaxa,nVenPad,nVenFin,cTipo,cOper)

Local aArrFim 		:= {}
Local nX		   := 0 // Contador
Local nValFim  := 0                 
Local nValAux  := 0  
Local nVal		:= 0 
Local nPos		:= 0    
Local lLoop		:= .T.        
Local cParc	 	:= PadL("0" , TamSx3("E1_PARCELA")[1] , "0")
Local nValPgt  := 0
Local nValParc := 0      
Local nValTx  	:= 0
Local nValTxP 	:= 0 
Local nTxSE1 	:= 0 
Local aArrP   	:= {} 

If cOper == "C" // Cielo
	
	nTxSE1 := (nValor * (nTaxa / 100))  / nVezes
	
	nValPgt  := Round(nValor - (nValor * ((nTaxa / 100))),2)
  	nValParc := nValPgt / nVezes 
	
	For nX := 1 To nVezes
		//If nVezes > 1 // 20160607 - Pedido do Diego.
			cParc := Soma1(cParc)
		//EndIf
		nValFim := noRound(nValParc,2)
		Aadd(aArrFim, {cParc , nValFim , dDataEmis , Date(), nX , nTxSE1})
	Next nX
	
	AEVal(aArrFim , { |x|  nValAux += x[2] })
	
	//Deve se jogar o valor na primeira parcela
	If nValAux != nValPgt
		
		//Valor total do pgto - o somatorio das parcelas
		nVal := (nValPgt - nValAux)
		
		nPos := aScan(aArrFim , {|x| x[5] == 1})
		If nPos <> 0 
			//Ajuste o valor da primeira parcela
			aArrFim[nPos][2] += nVal
		EndIf
	EndIf    

Else //Redecard
   
   /*Na redecard o processo para gerar as parcelas é diferente da cielo, na redecard se divide a taxa e depois subtrai o valor 
     nas parcelas */
     
   nTxSE1 := (nValor * (nTaxa / 100)) / nVezes
   
   nValTx  	:= Round(nValor * (nTaxa / 100),2) 
   
   nValParc := (nValor / nVezes)
   nValTxP 	:= (nValTx / nVezes)
   
  	For nX := 1 To nVezes
		Aadd(aArrP, {noRound(nValParc,2) , noRound(nValTxP,2),nX})
	Next nX	
		
	//Ajusta as parcelas
	For nX := 1 To 2
		nValAux := 0
		
		//Somatorio das taxa de desconto
		AEVal(aArrP , { |x|  nValAux += x[nX] })		
		
		If nX == 1
		
			//Deve se jogar o valor na primeira parcela
			If nValor != nValAux		
				//Valor total do pgto - o somatorio das parcelas
				nVal := (nValor - nValAux)		
				nPos := aScan(aArrP , {|x| x[3] == 1})
				If nPos <> 0 
					//Ajuste o valor da primeira parcela
					aArrP[nPos][nX] += nVal
				EndIf	
			EndIf    			
		
		Else			
			
			//Deve se jogar o valor na primeira parcela
			If nValTx != nValAux		
				//Valor total do pgto - o somatorio das parcelas
				nVal := (nValTx - nValAux)		
				nPos := aScan(aArrP , {|x| x[3] == 1})
				If nPos <> 0 
					//Ajuste o valor da primeira parcela
					aArrP[nPos][nX] += nVal
				EndIf	
			EndIf    
			
		EndIf	
	
	Next nX
	
	For nX := 1 To nVezes
		//If nVezes > 1 // 20160607 - Pedido do Diego.
			cParc := Soma1(cParc)
		//EndIf
		//nValFim := noRound(nValParc,2)
		Aadd(aArrFim, {cParc , aArrP[nX][1] - aArrP[nX][2] , dDataEmis , Date(), nX, nTxSE1})
	Next nX

EndIf	

nPos := aScan(aArrFim , {|x| x[5] == 1})
If nPos <> 0 
	//Ajuste o valor da primeira parcela
	dData := aArrFim[nPos][3] //Data Emissao
EndIf


If AllTrim(cTipo) == "CC"

	//Prioriza vencimento padrao
	If nVenPad != 0 
	
		//Ultimo dia do mes
		If nVenPad == 31 
		  	For  nX := 1 To Len(aArrFim)
	  		  	dData := MonthSum(dData , 1) 
		   	aArrFim[nX][4] := lastday(dData, 3)
		   Next nX
		Else    
		   cAux  := DtoC(dData) 
			If Month(dData) == 2    //juliana                                                   
		  	dData := cToD(IIF(cValToChar(nVenPad)>"28","28",cValToChar(nVenPad)) + "/" + SubStr(cAux,4,2) + "/" + SubStr(cAux,7,4)) //juliana 
			else     //juliana
			dData := cToD(cValToChar(nVenPad) + "/" + SubStr(cAux,4,2) + "/" + SubStr(cAux,7,4))   
			endif
			For  nX := 1 To Len(aArrFim)
	  		  	
	  		  	If lLoop 
	  		  		dData := MonthSum(dData , 1)
				EndIf  		  		
	  		  	
	  		  	aArrFim[nX][4] := DataValida(dData,.T.)
	  		  	
	  		  	If Month(dData) == 2
	  				dData := MonthSum(dData , 1)
	  				cAux  := DtoC(dData) 
					//dData := DataValida(cToD(cValToChar(nVenPad) + "/" + SubStr(cAux,4,2) + "/" + SubStr(cAux,7,4)),.T.) //padrao
					/* lastday
                  0 ou Branco - Último dia do mês em Pauta;        
                  1 - Primeiro dia útil do mês;               
                  2 - Último dia útil do mês;                 
                  3 - Próximo dia útil após a data informada (Se a data informada for útil, a função retorna a própria data).
               */					
					//dData := ((Lastday(dData,3) + "/" + SubStr(cAux,4,2) + "/" + SubStr(cAux,7,4)),.T.)  //juliana
					dData := Lastday(dData,2)
					lLoop := .F. 
				Else
		  			lLoop := .T.			
				EndIf
			
			Next nX
			
		EndIf
		
	ElseIf nVenFin != 0 
			
		For  nX := 1 To Len(aArrFim)
	 		dData := dData + nVenFin
		   aArrFim[nX][4] := DataValida(dData, .T.)
		Next nX
	
	//Padrao de 03 em 30 dias 
	Else 
		
		For  nX := 1 To Len(aArrFim)
	 		dData := dData + 30
		   aArrFim[nX][4] := DataValida(dData, .T.)
		Next nX
		
	EndIf

Else
	aArrFim[nPos][4] := DataValida(dData + 1, .T.)
EndIf

Return aArrFim
	

//------------------------------------------------------------------- 
/*/{Protheus.doc} FProxDUtil()
Função para retornar o dia util

@author Giulliano Santos
@since  19/03/2012 
@version P11
@param	nTipo = 1 Vencimento Padrao
			nTipo = 2 Vencimento Financiado
			nTipo = 3 Default 30 em 30
@obs  
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FProxDUtil(aArrFim,dDate)

Return dDate


//------------------------------------------------------------------- 
/*/{Protheus.doc} FGeraSE1
Gera os dados no SE1

@author Giulliano Santos
@since  19/03/2012 
@version P11
@obs  
Alteracoes Realizadas desde a Estruturacao Inicial 

Data       Programador      Motivo 
28/06/2012 Giulliano Santos Gravar a taxa da administradora no cartao
/*/ 
//------------------------------------------------------------------ 
Static Function FGeraSE1(aVezes,cOperad,cLoja,nTaxa)

Local aAreas  	:= {SE1->(GetArea()),GetArea()}
Local nX			:= 0	 
Local cNaturez := GetNewPar("FS_RCTNATU", "10199")					
Local cMsgErr  := ""    
Local cNsuDoc  := SE1->E1_ZNUMTID   
Local cOp 	   := SE1->E1_ZOP

Private lMsErroAuto := .F.

Begin Transaction 

cMsgErr += "Log do processo TopMix" + _CRLF

For nX := 1 To Len(aVezes)
		
		aSE1  := {{"E1_FILIAL"	,xFilial("SE1")  			,Nil},;
		 			 {"E1_PREFIXO"	,SE1->E1_PREFIXO 			,Nil},;
					 {"E1_NUM"	  	,SE1->E1_NUM  	  			,Nil},;
					 {"E1_PARCELA"	,aVezes[nX][1]  			,Nil},;
					 {"E1_TIPO"	 	,"RCT"			  			,Nil},;
					 {"E1_NATUREZ"	,cNaturez		  			,Nil},;
					 {"E1_CLIENTE"	,cOperad		 			 	,Nil},;
					 {"E1_LOJA"	  	,cLoja	  		 		 	,Nil},;
					 {"E1_EMISSAO"	,SE1->E1_EMISSAO		  	,Nil},;
					 {"E1_VENCTO" 	,aVezes[nX][4] 			,Nil},;  
					 {"E1_VENCREA"	,aVezes[nX][4]   			,Nil},;  
					 {"E1_CCD"   	,SE1->E1_CCD	  			,Nil},;
					 {"E1_MOEDA" 	,1					  			,Nil},;
					 {"E1_ORIGEM"	,"FINA040"		  			,Nil},;
					 {"E1_FLUXO"	,"S"				  			,Nil},;
					 {"E1_VALOR"  	,aVezes[nX][2]  			,Nil},;
					 {"E1_VLRREAL" ,aVezes[nX][2]  			,Nil},;
					 {"E1_HIST"		,SE1->E1_HIST				,Nil},;
					 {"E1_ZBOLETO"	,"N"				  		  	,Nil}}
	  
		aSE1 := U_FSAceArr(aSE1,"SE1")	
		MSExecAuto({|x,y| Fina040(x,y)},aSE1, 3) //Inclusao
		
		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			cMsgErr := MemoRead(NomeAutoLog())
			Ferase(NomeAutoLog())
		EndIf	
	
		//Grava data da emissao do titulo
		If !lMsErroAuto
			SE1->(RecLock("SE1",.F.))				
			SE1->E1_ZTAXA := nTaxa
			SE1->E1_ZNUMTID := cNsuDoc  
			SE1->E1_ZOP := cOp
			SE1->E1_ZTXOPER := aVezes[nX][6] //Alterado GS - 28/06/2012
			SE1->(MsUnlock())		
			cMsgErr += "Título Prefixo: " + SE1->E1_PREFIXO + " Numero: " + SE1->E1_NUM + " Parcela: " + SE1->E1_PARCELA + _CRLF
		EndIf

Next nX


End Transaction				 

cMsgErr += "Titulos gerados com SUCESSO!"
MsgInfo(cMsgErr)

aEval(aAreas, {|x| RestArea(x)})

Return lMsErroAuto  