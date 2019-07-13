#Include "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} AFATP13
Description analise de cotações
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Jose Antonio (AMM)                                            
@since 31/01/2013                                                   
/*/                                                             
//--------------------------------------------------------------
********************************************
User Function AFATP13(pCod,pFilCota)        
********************************************
                
Local aButtons := {}
Local oBitmap1
Local oBitmap2
Local oDtCot
Local dDtCot := Date()
Local oDtEntrega
Local oDtSol
Local dDtSol := Date()
Local oFont1 := TFont():New("Arial",,020,,.T.,,,,,.F.,.F.)
Local oFont2 := TFont():New("Arial",,017,,.T.,,,,,.F.,.F.)
Local oFont3 := TFont():New("Arial",,016,,.F.,,,,,.F.,.F.)
Local oFont4 := TFont():New("Arial",,017,,.T.,,,,,.F.,.F.)
Local oFont5 := TFont():New("Arial",,017,,.T.,,,,,.F.,.F.)
Local oGroup1
Local oGroup2
Local oGroup3
Local oNumCot
Local oNumSol
Local cNumSol := "Define variable value"
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSolicit
Local cSolicit    		:= "Define variable value"      
Private cCotacao  		:=pCod
Private cFilCota  		:=pFilCota 
Private aProduto  		:={}  
Private dDtEntrega:= 0  
Private aSizeAut	 := MsAdvSize(,.F.)
Private aObjects	 := {}
Private aInfo 	     := {}
Private aPosObj	     := {}
Private aSizeAut	 := MsAdvSize(,.F.)
Private aObjects	 := {}
Private aInfo 	   := {}
Private aPosObj	   := {}  
Private aColsExAux :={}

Private aColsAux   := {}
Private aResolu    := getScreenRes()

Static oDlg
AAdd( aObjects, { 000, 070, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo  := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj:= MsObjSize( aInfo, aObjects )                                    

If  Empty(pCod)
	Alert("Cotação não existe !!!" )
    Return()
Endif   

dbSelectArea("SC8")
dbGoTop()
dbSetOrder(1)
If !dbSeek(cFilCota+cCotacao,.T.) 
	Alert("Cotação não existe !!!" )
    Return()
Endif
dDtCot    := SC8->C8_EMISSAO   
cNumSol   := SC8->C8_NUMSC  
dDtEntrega:= SC8->C8_ZDENTR
aSolicit  := fLerSolic(cCotacao) 

If Len(aSolicit)>0
	cNumSol  := aSolicit[1,1]
	dDtSol   := aSolicit[1,2]    
    cSolicit := aSolicit[1,3]
Endif
           
 
//  DEFINE MSDIALOG oDlg TITLE "Analise de Cotações" FROM 000, 000  TO 560, 1100 COLORS 0, 16777215 PIXEL
  DEFINE MSDIALOG oDlg TITLE "Analise de Cotações" FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5]  COLORS 0, 16777215 PIXEL

    @ 033, 005 GROUP oGroup1 TO 081, aPosObj[1,4]-3 OF oDlg COLOR 0, 16777215 PIXEL
    @ 035, 008 GROUP oGroup2 TO 078, aPosObj[1,4]-6 OF oDlg COLOR 0, 16777215 PIXEL
    @ 040, 010 SAY oSay2 PROMPT "Num. Cotação:" SIZE 048, 009 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
    @ 037, 065 MSGET oNumCot VAR cCotacao SIZE 045, 011 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL
    @ 040, 227 SAY oSay3 PROMPT "Data Cotação:" SIZE 047, 007 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
    @ 037, 274 MSGET oDtCot VAR dDtCot SIZE 043, 011 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL
    @ 040, 434 SAY oSay4 PROMPT "Num. Solicitação:" SIZE 057, 007 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
    @ 037, 494 MSGET oNumSol VAR cNumSol SIZE 043, 011 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL
    @ 060, 434 SAY oSay5 PROMPT "Data Solicitação:" SIZE 058, 007 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
    @ 057, 494 MSGET oDtSol VAR dDtSol SIZE 043, 011 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL
    @ 060, 010 SAY oSay6 PROMPT "Entrega Dias:" SIZE 053, 008 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
    @ 057, 065 MSGET oDtEntrega VAR dDtEntrega SIZE 043, 011 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL
    @ 060, 227 SAY oSay7 PROMPT "Solicitante:" SIZE 040, 007 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
    @ 057, 274 MSGET oSolicit VAR cSolicit SIZE 070, 011 OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL
    @ 085, 009 SAY oSay8 PROMPT "Dados da Cotação:" SIZE 070, 009 OF oDlg FONT oFont4 COLORS 8388608, 16777215 PIXEL
    IF(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080 
	 @ 094, 005 GROUP oGroup3 TO 438, aPosObj[1,4	]-3 OF oDlg COLOR 0, 16777215 PIXEL
	ELSE
	 @ 094, 005 GROUP oGroup3 TO 288, aPosObj[1,4	]-3 OF oDlg COLOR 0, 16777215 PIXEL
	ENDIF    
	    Aadd(aButtons, {"SIMULACAO", {||fHistorico()}, "Histórico Produto"})
	    EnchoiceBar(oDlg, {||fConfirmar()}, {||fCancelar()},,aButtons)
	    fMSNewGe1()

  ACTIVATE MSDIALOG oDlg CENTERED

Return

//------------------------------------------------ 
Static Function fMSNewGe1()
//------------------------------------------------ 
Local nX
Local aHeaderEx    := {}
Local aHeaderEx1   := {}
Local aColsEx      := {}
Local aFieldFill   := {}
Local aFields      := {"C8_ZGANHAD"}
Local aAlterFields := {}
Local aFormece     :={}  
Local cProduto  
Local cFornece     :=""
Local nTotal       :=0
Local nPreco       :=0 
Local aFormece     :={} 
Local lFrete       := .T.
Local lTemPreco    := .F.
Static oMSNewGe1

aFormece  := fLerFornece()
aColsProd := fSelCotProd()

If len(aColsProd)=0
	Alert("Cotação sem preço !!!")
    Return()
Endif       
                        
For k:=1 To Len(aColsProd)
	If !lTemPreco
		If aColsProd[k,3] > 0 //valida se tem algum preco informado
			lTemPreco := .T.
		EndIf
	EndIf
Next    

If !lTemPreco
	Alert("É obrigatório que pelo menos 1 item da cotação possua preco !")
	Return()
EndIf
	  // Define field properties   
	  
	  Aadd(aHeaderEx,{"Descrição"+CRLF+"Produto","C8_ZDESCRI",PesqPict("SC8","C8_ZDESCRI"),25,0,"","û","C"," ","V" } )	
	  Aadd(aHeaderEx,{"Qtde.","C8_QUANT",PesqPict("SC8","C8_QUANT"),5,0,"","û","C"," ","V" } )	
	  nCont:=0    
	  For nX := 1 To Len(aFormece)    
	  		cNome   :=Alltrim(Substr(aFormece[nX,3],1,35))
	    	cFornece:=Alltrim(aFormece[nX,1])
// 	  		Aadd(aHeaderEx,{cNome+CRLF+Alltrim(aFormece[nX,6]),"A2_NOME"+Alltrim(str(nX,5)),PesqPict("SA2","A2_NOME") ,10, 0,"","û","N"," ","V" } )	
 	  		Aadd(aHeaderEx,{cNome,"A2_NOME"+Alltrim(str(nX,5)),PesqPict("SA2","A2_NOME") ,10, 0,"","û","N"," ","V" } )	
 	  		
	  		aFormece[nx,4]:=Len(aHeaderEx)
	 	 	Aadd(aHeaderEx,{"","C8_QUANT"+Alltrim(str(nX,5)) ,PesqPict("SC8","C8_ZGANHAD") ,6  ,0  ,"","û","N"," ","V" } )	
	  	    Aadd(aHeaderEx,{"Ganhador"+Alltrim(str(nX,5)),"C8_GANHAD"+Alltrim(str(nX,5)),PesqPict("SC8","C8_ZGANHAD"),TamSx3("C8_ZGANHAD")[1] ,TamSx3("C8_ZGANHAD")[2],/* Valid */ , /* Usado */ , TamSX3('C8_ZGANHAD')[3], /* F3 */, 'R', "S=Sim;N=Nao", /*Relacao*/, '.T.' , /* Visual */, /* Vld User */, /* PictVar */, /* Obrigatorio */})	
            //Aadd(aHeaderEx,{"Ganhador"+Alltrim(str(nX,5)),"C8_GANHAD"+Alltrim(str(nX,5)),PesqPict("SC8","C8_ZGANHAD"),TamSx3("C8_ZGANHAD")[1] ,TamSx3("C8_ZGANHAD")[2],/* Valid */ , /* Usado */ , TamSX3('C8_ZGANHAD')[3], /* F3 */, 'R', "S=Sim;N=Nao", /*Relacao*/, '.T.' , /* Visual */, /* Vld User */, /* PictVar */, /* Obrigatorio */})		  		
	   		Aadd(aAlterFields,"C8_GANHAD"+Alltrim(str(nX,5)))
  	  Next nX  
 	
	  // Define field values       
  	  cProduto:=Criavar("C8_PRODUTO")                                             
      nPos0:=GDFieldPos("A2_NOME1",aHeaderEx)   
      nCont:=0
      
		/*
		Verifica se a Cotação tem algum produto substituto
		*/    
		lTemProSu := .F.
		dbSelectArea("SC8")
		dbSetOrder(3)
		dbSeek(cFilCota+cCotacao,.T.) 
		While !Eof() .And. SC8->C8_FILIAL+SC8->C8_NUM=cFilCota+cCotacao
			if !Empty(SC8->C8_ZPRDSUB)
				lTemProSu := .T.      
			endif
			dbSelectArea("SC8")
			dbSkip()
		enddo      
      
      
      
	  dbSelectArea("SC8")
	  dbSetOrder(3)
	  dbSeek(cFilCota+cCotacao,.T.) 
	  While !Eof() .And. SC8->C8_FILIAL+SC8->C8_NUM=cFilCota+cCotacao
	
			nPos:= aScan( aFormece, {|x| x[1] == SC8->C8_FORNECE  } )
			
   		If Empty(nPos)  
     	       dbSkip()
     	       Loop
     	    Endif   
     	    
			if !Empty(SC8->C8_NUMPED)
				dbSelectArea("SC8")
				dbSkip()                                          
				Loop
			endif     	    

            nPos1 := nPos0 + ( 2 * nPos) 
            
            nXXRecno := 0
            nXXRecno := SC8->(Recno())

				//nPosX:=aScan( aColsProd, {|x| x[1]+x[2] == SC8->C8_PRODUTO+SC8->C8_FORNECE  } )
				nPosX:=aScan( aColsProd, {|x| x[1]+x[2] == Iif(!Empty(SC8->C8_ZPRDSUB),SC8->C8_ZPRDSUB,SC8->C8_PRODUTO)+SC8->C8_FORNECE  } )
            //If SC8->C8_PRODUTO <> cProduto    
   			If Iif(!Empty(SC8->C8_ZPRDSUB),SC8->C8_ZPRDSUB,SC8->C8_PRODUTO) <> cProduto 
               If !Empty(cProduto)
                   aadd(aColsEx,Array(Len(aHeaderEx)+2))  
                   aColsEx[Len(aColsEx)][Len(aHeaderEx)+1] :=SC8->(Recno())	
				   aColsEx[Len(aColsEx)][Len(aHeaderEx)+2] := .F.	   
				   
    		       aadd(aColsAux,Array(Len(aHeaderEx)+2))
		  	   	   aColsAux[Len(aColsAux)][nPos1+1] := SC8->(Recno())	
    		       aColsAux[Len(aColsAux)][nPos1+2] := ""    
    		       
				   For x:=1 to Len(aFormece)  
				   		nPosXX:=aFormece[x,4] 
				 		aColsEx[Len(aColsEx)][nPosXX+2]  := ""
				 		aColsAux[Len(aColsEx)][nPosXX+2] := ""
				   Next      		
				   
	    		  	if lTemProSu
						For xX2 := 4 To Len(aColsAux[1]) step 3
					   		if xX2 < Len(aColsAux[1])
								if aColsAux[Len(aColsAux)][xX2] == Nil
									aColsAux[Len(aColsAux)][xX2] := nXXRecno
								 endif
							endif
						Next
					endif				         	    		      	  
				   
 			   Endif 
 			   
 	           cProduto:= Iif(!Empty(SC8->C8_ZPRDSUB),SC8->C8_ZPRDSUB,SC8->C8_PRODUTO)
               
             	aadd(aColsEx,Array(Len(aHeaderEx)+2))     
               nPos1:=aFormece[nPos,4] 
		  			aColsEx[Len(aColsEx)][Len(aHeaderEx)+1] := SC8->(Recno())
					aColsEx[Len(aColsEx)][Len(aHeaderEx)+2] := .F.	
               nCont:=Len(aColsEx) 
                        
               if SC8->C8_ALIIPI > 0
                 	nTotal := (((SC8->C8_PRECO * SC8->C8_QUANT)/100) * (100+SC8->C8_ALIIPI)) - SC8->C8_VLDESC + SC8->C8_VALFRE    
               else                                                                                                          
                 	nTotal := (SC8->C8_PRECO * SC8->C8_QUANT) - SC8->C8_VLDESC + SC8->C8_VALFRE    
	     			Endif
	     				
                        //nTotal:=nTotal * 1+(nTotal * SC8->C8_ALIIPI/100)
                        nPreco:=nTotal/SC8->C8_QUANT 
                        aFormece[nPos,5]+=nTotal
  				  		aColsEx[Len(aColsEx)][1]       := Iif(!Empty(SC8->C8_ZPRDSUB),Alltrim(Left(SC8->C8_ZDESCRI,30)+'/'+SC8->C8_PRODUTO),Alltrim(Left(SC8->C8_ZDESCRI,30)+'/'+SC8->C8_PRODUTO)) 
  				  		//aColsEx[Len(aColsEx)][1]       := Iif(!Empty(SC8->C8_ZPRDSUB),Alltrim(Left(Posicione("SB1",1,xFilial("SB1")+SC8->C8_ZPRDSUB,"B1_DESC"),30)),Alltrim(Left(SC8->C8_ZDESCRI,30)))
  				  		aColsEx[Len(aColsEx)][2]       := SC8->C8_QUANT
 			   			aColsEx[Len(aColsEx)][nPos1]   := Transform(nPreco,"@E 9,999,999.99")
			      		aColsEx[Len(aColsEx)][nPos1+1] := Transform(nTotal,"@E 9,999,999.99")
    		      		aColsEx[Len(aColsEx)][nPos1+2] := SC8->C8_ZGANHAD 
              
              aadd(aColsEx,Array(Len(aHeaderEx)+2))
		  				aColsEx[Len(aColsEx)][Len(aHeaderEx)+1] := SC8->(Recno())
						aColsEx[Len(aColsEx)][Len(aHeaderEx)+2] := .F.	
 			      		aColsEx[Len(aColsEx)][1]	   := Posicione("SB1",1,xFilial("SB1")+Iif(!Empty(SC8->C8_ZPRDSUB),SC8->C8_ZPRDSUB,SC8->C8_PRODUTO),"B1_FABRIC")//Fabricante
 			      		aColsEx[Len(aColsEx)][nPos1]   := Posicione("SC1",1,SC8->C8_FILIAL+SC8->C8_NUMSC+SC8->C8_ITEMSC,"C1_ZTIPOPR")//Original Sim/Nao
    		      		aColsEx[Len(aColsEx)][nPos1+1] := SC8->C8_ZDENTR
    		      		aColsEx[Len(aColsEx)][nPos1+2] := ""
    		      		 
    		  //aadd(aColsAux,Array(Len(aHeaderEx)+2))
		  	  // 		aColsAux[Len(aColsAux)][nPos1+1] := SC8->(Recno())	
		  	  // 		aColsAux[Len(aColsAux)][nPos1+2] := ""	
    		      	
    		  aadd(aColsAux,Array(Len(aHeaderEx)+2))
		  	   		aColsAux[Len(aColsAux)][nPos1+1] := SC8->(Recno())	
		  	   		aColsAux[Len(aColsAux)][nPos1+2] := ""	

    		  	if lTemProSu
					For xX2 := 4 To Len(aColsAux[1]) step 3
				   		if xX2 < Len(aColsAux[1])
							if aColsAux[Len(aColsAux)][xX2] == Nil
								aColsAux[Len(aColsAux)][xX2] := nXXRecno
							 endif
						endif
					Next
				endif

				aadd(aColsAux,Array(Len(aHeaderEx)+2))
		  	   		aColsAux[Len(aColsAux)][nPos1+1] := SC8->(Recno())
		  	   		aColsAux[Len(aColsAux)][nPos1+2] := ""		

    		  	if lTemProSu
					For xX2 := 4 To Len(aColsAux[1]) step 3
				   		if xX2 < Len(aColsAux[1])
							if aColsAux[Len(aColsAux)][xX2] == Nil
								aColsAux[Len(aColsAux)][xX2] := nXXRecno
							 endif
						endif
					Next
				endif
    		  
    		      		    		  
           Else
	       				nPos1:=aFormece[nPos,4]
                        nTotal:=(SC8->C8_PRECO * SC8->C8_QUANT)  - SC8->C8_VLDESC + SC8->C8_VALFRE   
                        //nTotal:=nTotal * 1-(nTotal * SC8->C8_DESC/100)
                        nTotal:=nTotal * 1+(nTotal * C8_ALIIPI/100) 
                        nPreco:=nTotal/SC8->C8_QUANT 
                        aFormece[nPos,5]+=nTotal            
                        
				   		aColsEx[nCont][nPos1]     	   := Transform(nPreco,"@E 9,999,999.99")
			      		aColsEx[nCont][nPos1+1]   	   := Transform(nTotal,"@E 9,999,999.99")//IIF(Empty(nPosX),"",aColsProd[nPosX,7])
     		      	 	aColsEx[nCont][nPos1+2]        := SC8->C8_ZGANHAD 
  			      		aColsEx[nCont+1][nPos1]        := Posicione("SC1",1,SC8->C8_FILIAL+SC8->C8_NUMSC+SC8->C8_ITEMSC,"C1_ZTIPOPR")//Original Sim/Nao
  			      		aColsEx[nCont+1][nPos1+1]      := SC8->C8_ZDENTR
  			      		aColsEx[nCont+1][nPos1+2] 	   := "" 
				  	    
				  	    aColsAux[nCont][nPos1+1]      := SC8->(Recno())
				  						  			
	     Endif

         dbSelectArea("SC8")
		 dbSkip()
		 
	  EndDo   
      aadd(aColsEx,Array(Len(aHeaderEx)+2))               
  	  aColsEx[Len(aColsEx)][Len(aHeaderEx)+2] := .F.
  	  
	  For x:=1 to Len(aFormece)  
		  dbSelectArea("SC8")
		  dbSetOrder(1) 
		  dbSeek(cFilCota+cCotacao+aFormece[x,1]+aFormece[x,2],.T.)
    	  nPos:=aFormece[x,4] 
 		  aColsEx[Len(aColsEx)][nPos+2] := ""
      Next  

      aadd(aColsEx,Array(Len(aHeaderEx)+2))               
	  aColsEx[Len(aColsEx)][1]       := 'TOTAL FORNECEDOR'
  	  aColsEx[Len(aColsEx)][Len(aHeaderEx)+2] := .F.	
      For x:=1 to Len(aFormece)  
		  dbSelectArea("SC8")
		  dbSetOrder(1) 
		  dbSeek(cFilCota+cCotacao+aFormece[x,1]+aFormece[x,2],.T.)
          nPos:=aFormece[x,4] 
 		  //aColsEx[Len(aColsEx)][nPos]   := Transform(aFormece[x,5] + SC8->C8_VALFRE - SC8->C8_ZTODESC,"@E 9,999,999.99")
 		  aColsEx[Len(aColsEx)][nPos]   := Transform(aFormece[x,5],"@E 9,999,999.99")
 	   	  aColsEx[Len(aColsEx)][nPos+2] := ""
     Next  
           
	aColsExAux:=aClone(aColsEx)
	   
	For x1:=1 To Len(aColsEx) step 4
		If x1+4 >Len(aColsEx)
			exit
		Endif
		For xa:=4 To Len(aColsEx[x1]) step 3
			///AAAaColsEx[x1+2][xa-1]:=""          

			/*
			Preenche o Recno, Ganhador.
			*/

			//if (xa+1) < Len(aColsEx[x1])
			//	if(aColsEx[x1][xa+1]) == Nil
			//		aColsEx[x1][xa+1] := ""
			//	endif	
		   //	endif

		Next
		        
	Next        
	
	For x1:=1 To Len(aColsEx)
		For xa:=4 To Len(aColsEx[x1]) step 3
			if (xa+1) < Len(aColsEx[x1])
				if(aColsEx[x1][xa+1]) == Nil
					aColsEx[x1][xa+1] := ""
				endif	
			endif
		Next
	Next    	
	
IF(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080		           
  oMSNewGe1 := MsNewGetDados():New( 099,007,aPosObj[1,3]+330,aPosObj[1,4]-5, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
ELSE
  oMSNewGe1 := MsNewGetDados():New( 099,007,aPosObj[1,3]+180,aPosObj[1,4]-5, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
ENDIF
  oMSNewGe1:Refresh()    //Atualiza o browse 

  //fMudaGet()
   	
Return    

Static Function fMudaGet()
******************************************
*** Realiza criação do Layout do GetDados
******************
	oMSNewGe1:oBrowse:SetBlkBackColor({|| GETDCLR(oMSNewGe1:nAt)})
Return


 Static Function SFMudaCor(nIOpcao)
Private _cCor := ""

    if nIOpcao == 1 // Cor da Fonte
       _cCor := CLR_WHITE
    else // Cor do Fundo
       _cCor := CLR_RED
    endif
    
Return _cCor
 
 
Static Function GETDCLR(nLinha)
Local nCor2 := 16776960 // Ciano - RGB(0,255,255)
Local nCor3 := 16777215 // Branco - RGB(255,255,255)
Local nRet  := 16777215          
 //	APMsgAlert(nLinha)   
 If Strzero(nLinha,2) $ "04/08/12/16/20/24/28"
	if (nLinha/2) == 0 //neste exemplo, se tiver conteudo na 3ª coluna pinte de cinza
	     nRet := 32768 //6579300
	Else
	     nRet := 32768 //16777215
	Endif
Endif	
Return nRet //32768
//------------------------------------------------ 
Static Function fLerSolic()
// Funcao mostrar as solicitacao data e solicitante
//------------------------------------------------ 

Local aAliasOLD    := GetArea()
Local cAliasQry    := GetNextAlias() 
Local aSolicit     := {}
	BeginSql Alias cAliasQry    
		COLUMN C1_EMISSAO AS DATE         
		SELECT C1_NUM,C1_EMISSAO,C1_SOLICIT
		FROM %table:SC1% SC1   
		WHERE SC1.%notDel% 	AND    
		SC1.C1_FILIAL = %Exp:cFilCota% AND
		SC1.C1_COTACAO = %Exp:cCotacao%          
 	EndSql 
 	dbEval({||Aadd(aSolicit,{(cAliasQry)->C1_NUM,(cAliasQry)->C1_EMISSAO,(cAliasQry)->C1_SOLICIT} )  });(cAliasQry)->(dbGotop())                      
	(cAliasQry)->(dbCloseArea())

RestArea(aAliasOLD)
Return(aSolicit)  


//------------------------------------------------ 
Static Function fSelCotProd()
// Funcao para mostrar os produtos em  analise de
// Cotação agrupado por produto e menor preco
//------------------------------------------------ 

Local aAliasOLD    := GetArea()
Local cAliasQry    := GetNextAlias() 
Local aColsProd    :={} 
Local cProduto     :=""
Local cFornece     :=""
Local nCont        :=0   

Local aXXFor       := fLerFornece()
//  		SC8.C8_PRECO NOT IN (%Exp:'0'%)   AND


	BeginSql Alias cAliasQry
		SELECT DISTINCT C8_PRODUTO,C8_PRECO,C8_FORNECE,C8_LOJA,C8_QUANT,C8_COND,C8_ZMARCA,C8_PRAZO,C8_TOTAL,C8_ZPRDSUB,    
		(SELECT MAX(C1_ZMARCA) FROM %table:SC1% SC1 WHERE  SC8.C8_NUMSC=SC1.C1_NUM AND SC1.%notDel%) AS C1_ZMARCA
		FROM %table:SC8% SC8                                                 
		WHERE SC8.%notDel% 	AND   
		SC8.C8_FILIAL = %Exp:cFilCota% AND  
		SC8.C8_NUM  = %Exp:cCotacao%      AND         
  		SC8.C8_ZSTATUS   IN (%Exp:'3'%) 
  		ORDER BY C8_PRODUTO,C8_PRECO,C8_FORNECE,C8_LOJA,C8_COND,C8_PRAZO
   	EndSql 
	(cAliasQry)->( DbGoTop() )
 	While !(cAliasQry)->(EOF())   
             //If (cAliasQry)->C8_PRODUTO<>cProduto              
             
             /*
             If Iif(!Empty((cAliasQry)->C8_ZPRDSUB),(cAliasQry)->C8_ZPRDSUB,(cAliasQry)->C8_PRODUTO) <> cProduto             
             
                 //cProduto:=(cAliasQry)->C8_PRODUTO            
                 cProduto:=Iif(!Empty((cAliasQry)->C8_ZPRDSUB),(cAliasQry)->C8_ZPRDSUB,(cAliasQry)->C8_PRODUTO)           
                 cFornece:=(cAliasQry)->C8_FORNECE
                 nCont:=1
  	         Endif 
             aadd(aColsProd,{ Iif(!Empty((cAliasQry)->C8_ZPRDSUB),(cAliasQry)->C8_ZPRDSUB,(cAliasQry)->C8_PRODUTO),; 
  	         				  (cAliasQry)->C8_FORNECE,;
 	           	              (cAliasQry)->C8_PRECO,;
 	               	          (cAliasQry)->C8_TOTAL,;
 	                   	      (cAliasQry)->C1_ZMARCA,;
 	                      	  (cAliasQry)->C8_ZMARCA,;
 	                       	  Alltrim(str(nCont,2))+"°",;
 	                       	  Iif(!Empty((cAliasQry)->C8_ZPRDSUB),(cAliasQry)->C8_ZPRDSUB,(cAliasQry)->C8_PRODUTO) })  
 	         */
 	         
        aadd(aColsProd,{(cAliasQry)->C8_PRODUTO,; 
  	    			    (cAliasQry)->C8_FORNECE,;
 	                    (cAliasQry)->C8_PRECO,;
 	       	            (cAliasQry)->C8_TOTAL,;
 	           	        (cAliasQry)->C1_ZMARCA,;
 	               	    (cAliasQry)->C8_ZMARCA,;
 	               	    Alltrim(str(nCont,2))+"°",;
 	               	    (cAliasQry)->C8_PRODUTO }) 
 	         
 	         nCont++
        	(cAliasQry)->(dbskip())  
	EndDo
	
	(cAliasQry)->(dbCloseArea())

RestArea(aAliasOLD)
Return(aColsProd)  

//------------------------------------------------ 
Static Function fLerFornece()
// Funcao para mostrar os produtos em  analise de
// Cotação agrupado por produto e menor preco
//------------------------------------------------ 

Local aAliasOLD    := GetArea()
Local cAliasQry    := GetNextAlias() 
Local aFornece     :={} 

//  		SC8.C8_PRECO NOT IN (%Exp:'0'%)  AND

	BeginSql Alias cAliasQry
		SELECT C8_FORNECE, C8_LOJA,A2_NOME,E4_DESCRI  
		FROM %table:SC8% SC8   
		INNER JOIN %table:SA2% SA2 ON( SC8.C8_FORNECE=SA2.A2_COD AND SC8.C8_LOJA=SA2.A2_LOJA AND SA2.%notDel%)
		LEFT  JOIN %table:SE4% SE4 ON( SC8.C8_COND = SE4.E4_CODIGO AND SE4.%notDel%)
		WHERE SC8.%notDel% 	AND    
		SC8.C8_FILIAL = %Exp:cFilCota% AND
		SC8.C8_NUM  = %Exp:cCotacao% AND         
  		SC8.C8_ZSTATUS   IN (%Exp:'3'%) 
 		GROUP BY C8_FORNECE, C8_LOJA,A2_NOME,E4_DESCRI
 	EndSql                       
	dbEval({||Aadd(aFornece,{(cAliasQry)->C8_FORNECE,(cAliasQry)->C8_LOJA,Alltrim((cAliasQry)->A2_NOME),0,0,Alltrim((cAliasQry)->E4_DESCRI)} ) });(cAliasQry)->(dbGotop()) 
	(cAliasQry)->(dbCloseArea())

RestArea(aAliasOLD)
Return(aFornece)        

//------------------------------------------------ 
Static Function fHistorico()
// Funcao para mostrar os historico dos produtos 
// Cotação agrupado por produto e menor preco
//------------------------------------------------ 
Local aFields   := {"C7_PRODUTO"}    
Local cProduto  
 
If valtype(oMSNewGe1:aCols[oMSNewGe1:nAt][1] ) == 'C'
 cProduto := Alltrim(substr(oMSNewGe1:aCols[oMSNewGe1:nAt][1],(AT( "/", oMSNewGe1:aCols[oMSNewGe1:nAt][1] ) + 1),42))
  U_MaComView(cProduto)
Endif
 
Return()

//------------------------------------------------ 
Static Function fConfirmar()
// Funcao para mostrar os historico dos produtos 
// Cotação agrupado por produto e menor preco
//------------------------------------------------ 
Local aProd:={}
/*
For x1:=1 To Len(oMSNewGe1:aCols) step 4   
    nFlag:=0 
	For xa:=5 To Len(oMSNewGe1:aCols[x1]) step 3      
    	If oMSNewGe1:aCols[x1][xa]='S' 
	       dbSelectArea("SC8")   
	       //dbGoto(aColsExAux[x1+2][xa-1])
	       dbGoto(aColsAux[x1+2][xa-1])
   			nPosX:=aScan( aProd, {|x| x[1] == SC8->C8_PRODUTO  } )
  	        If Empty(nPosX) 
				Aadd(aProd,{SC8->C8_PRODUTO,SC8->C8_QUANT})  
			Else
			   aProd[nPosX,2]+= SC8->C8_QUANT     
			   IF aProd[nPosX,2] > SC8->C8_ZQUANTI 
					Alert("Existe produto marcado para mais de um fornecedor !!!" )
					Return()
			   Endif
			Endif
				
 		Endif	
 	Next        
Next
*/                                     

lJaTemA := .F.

For x1:=1 To Len(oMSNewGe1:aCols) step 3   
	lJaTemA := .F.
	nFlag   := 0 
	For xa:=5 To Len(oMSNewGe1:aCols[x1]) step 3      
    	If oMSNewGe1:aCols[x1][xa]=='S'
    		if lJaTemA
				Alert("Existe produto marcado para mais de um fornecedor !!!" )
				Return()
			else
				lJaTemA := .T.
			endif   
			
			//valida se o fornecedor marcado possui preco para a cotação  
			If Val(StrTran(oMSNewGe1:aCols[x1][xa-1],",","."))<=0
				Alert("Fornecedor selecionado nao possui preco informado para a cotação !" + oMSNewGe1:aCols[x1][xa-1])
				Return()
			EndIf
		endif
    		
    		/*
    		if aColsAux[x1][xa-1] <> Nil
		     	dbSelectArea("SC8")   
		      	dbGoto(aColsAux[x1][xa-1])
		   		//nPosX:=aScan( aProd, {|x| x[1] == SC8->C8_PRODUTO  } )
	   			nPosX:=aScan( aProd, {|x| x[1] == Iif(!Empty(SC8->C8_ZPRDSUB),SC8->C8_ZPRDSUB,SC8->C8_PRODUTO)  } )   			
	  	        If Empty(nPosX) 
					//Aadd(aProd,{SC8->C8_PRODUTO,SC8->C8_QUANT})  
					Aadd(aProd,{Iif(!Empty(SC8->C8_ZPRDSUB),SC8->C8_ZPRDSUB,SC8->C8_PRODUTO),SC8->C8_QUANT})  
				Else
					aProd[nPosX,2]+= SC8->C8_QUANT     
					IF aProd[nPosX,2] > SC8->C8_ZQUANTI 
						Alert("Existe produto marcado para mais de um fornecedor !!!" )
						Return()
				   	Endif
				Endif
			endif				
			*/
			
 		//Endif	
 	Next        
Next  

x1 := 0
xa := 0  
         
/*
For x1:=1 To Len(oMSNewGe1:aCols) step 4   
    nFlag:=0 
	For xa:=4 To Len(oMSNewGe1:aCols[x1]) step 3      
    	If oMSNewGe1:aCols[x1][xa]='S' 
	       dbSelectArea("SC8")
	       dbGoto(aColsExAux[x1+2][xa-1])
	  		 	IF RecLock("SC8", .F.) 
	  		 	   SC8->C8_ZGANHADO:="S"
	  		 	   SC8->C8_ZDENTR:=dDtEntrega
				   MsUnLock()
				Endif	   
			Endif	
	 	Next
Next  
*/

For x1:=1 To Len(oMSNewGe1:aCols) step 3   
	nFlag:=0 
	For xa:=5 To Len(oMSNewGe1:aCols[x1]) step 3
	  
		cXXAprov := oMSNewGe1:aCols[x1][xa]
    	If oMSNewGe1:aCols[x1][1] <> "TOTAL FORNECEDOR" .And. !Empty(cXXAprov)
	    	dbSelectArea("SC8")
	       	dbGoto(aColsAux[x1][xa-1])
  		 	if RecLock("SC8", .F.) 
	  			SC8->C8_ZGANHADO := Iif(cXXAprov=="S","S","N")
				MsUnLock()
			Endif			
		Endif	
	Next
Next


oDlg:End()
Return()
                                      

//------------------------------------------------ 
Static Function fCancelar()
// Funcao para mostrar os historico dos produtos 
// Cotação agrupado por produto e menor preco
//------------------------------------------------ 
/*
 Funçao de validar a linha ok
*/
oDlg:End()
               
Return()     
//------------------------------------------------ 
Static Function fLerSC1(pSc,pProd)
// Funcao pega a marca solicitada
//------------------------------------------------ 
Local aAliasOLD    := GetArea()
Local cRet:="" 

dbSelectArea("SC1")
dbSetOrder(1)
dbSeek(xFilial("SC1")+pSc+pProd,.T.)  
cRet:=SC1->C1_ZMARCA 
RestArea(aAliasOLD)

Return(cRet)