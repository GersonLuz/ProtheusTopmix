#Include "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} AFATP15
Description atualiza precos das cotações                                                    
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author TelaFrete - rodrigo.hollerbach@gmail.com                                              
@since 13/12/2012                                                   
/*/                                                             
//--------------------------------------------------------------
User Function AFATP15(pCod)                        
Local oBitmap1
Local oBitmap2
Local oComboBo1     
Local oFont1 := TFont():New("Calibri",,022,,.T.,,,,,.F.,.F.)
Local oFont2 := TFont():New("Calibri",,020,,.T.,,,,,.F.,.F.)
Local oFont3 := TFont():New("Calibri",,018,,.T.,,,,,.F.,.F.)
Local oFont4 := TFont():New("Calibri",,018,,.F.,,,,,.F.,.F.)
Local oGet1
Local oGet2
Local dGet2 := Date()
Local oGet3
Local oGet4
Local cGet4 := Criavar("E4_DESCRI")
Local oGet7
Local nGet7 := 0
Local oGet8
Local nGet8 := 0
Local oGroup1
Local oGroup2
Local oGroup3
Local oSay1
Local oSay10
Local oSay11
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Local oSButton1
Local oSButton2    
Private aSizeAut	 := MsAdvSize(,.F.)
Private aObjects	 := {}
Private aInfo 	 := {}
Private aPosObj	 := {}
Private oValMerc
Private nValMerc := 0
Private oValFrete 
Private nValFrete :=Criavar("Z4_VALFRE")
Private oValDesc
Private nValDesc  :=Criavar("Z4_VALDESC")                   
Private oTotalCot
Private nTotalCot :=Criavar("Z4_TOTAL")        
Private cCondPgto :=Criavar("Z4_COND")
Private cCotacao  :=pCod   
Private aFornece  :={}
Private nComboBo1 :=1
Private oMSNewGeP05
Private oMSNewGeFor 

Static oDlg                                 
If  Empty(pCod)
	Alert("Cotação Numero não Existe" )
    Return()
Endif
AAdd( aObjects, { 000, 070, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo  := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj:= MsObjSize( aInfo, aObjects )                                    
FFornece() // Busca fornecedores.

 // DEFINE MSDIALOG oDlg TITLE "Atualização Preços da Cotação" FROM 000, 000  TO 550, 750 COLORS 0, 16777215 PIXEL
  DEFINE MSDIALOG oDlg TITLE "Atualização Preços da Cotação" From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

    @ 004, 129 SAY oSay1 PROMPT "ATUALIZAÇÃO DE COTAÇÕES" SIZE 123, 010 OF oDlg FONT oFont1 COLORS 32768, 16777215 PIXEL
    @ 001, 286 BITMAP oBitmap1 SIZE 041, 015 OF oDlg FILENAME "\Imagens\Flapa_Totvs.png" NOBORDER PIXEL
    @ 001, 330 BITMAP oBitmap2 SIZE 041, 015 OF oDlg FILENAME "\Imagens\TopMix_Totvs.png" NOBORDER PIXEL
    
  //  @ 016, 002 GROUP oGroup1 TO 258, 372 OF oDlg COLOR 0, 16777215 PIXEL
    @ 021, 004 SAY oSay2 PROMPT "Informações Principais" SIZE 099, 009 OF oDlg FONT oFont2 COLORS 128, 16777215 PIXEL
    
    @ 030, 004 GROUP oGroup2 TO 072, 700 OF oDlg COLOR 0, 16777215 PIXEL
    @ 040, 007 SAY oSay3 PROMPT "Numero da Cotação:" SIZE 081, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL 
    @ 040, 113 SAY oSay4 PROMPT "Data de Emissão:" SIZE 052, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
    @ 040, 221 SAY oSay5 PROMPT "Fornecedor:" SIZE 040, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
    @ 057, 007 SAY oSay6 PROMPT "Condição de Pagamento:" SIZE 090, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
    @ 037, 070 MSGET oGet1 VAR cCotacao SIZE 042, 011 OF oDlg COLORS 0, 16777215 FONT oFont4 READONLY PIXEL WHEN .F.
    @ 037, 167 MSGET oGet2 VAR dGet2 SIZE 042, 011 OF oDlg COLORS 0, 16777215 FONT oFont4 PIXEL
    @ 037, 261 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS aFornece SIZE 103, 011 OF oDlg COLORS 0, 16777215 FONT oFont4 PIXEL ON CHANGE (nComboBo1:=oComboBo1:nAt,fMSNewGe1(cCotacao,aFornece[nComboBo1]) )
    @ 055, 084 MSGET oGet3 VAR cCondPgto SIZE 026, 011 OF oDlg COLORS 0, 16777215 FONT oFont4 F3 "SE4" PIXEL
    @ 055, 118 MSGET oGet4 VAR cGet4 SIZE 095, 011 OF oDlg COLORS 0, 16777215 FONT oFont4 PIXEL WHEN .F.
    @ 077, 004 SAY oSay7 PROMPT "Dados dos Itens" SIZE 081, 008 OF oDlg FONT oFont2 COLORS 128, 16777215 PIXEL

//   @ 275, 002 GROUP oGroup1 TO 525, 700 OF oDlg COLOR 0, 16777215 PIXEL
//    @ 086, 004 GROUP oGroup3 TO 214, 369 OF oDlg COLOR 0, 16777215 PIXEL
//    @ 290, 005 SAY oSay8 PROMPT "1) Fornecedor " SIZE 060, 007 OF oDlg FONT oFont4 COLORS 0, 16777215 PIXEL
//    @ 300, 005 SAY oSay9 PROMPT "2) Fornecedor " SIZE 050, 007 OF oDlg FONT oFont4 COLORS 0, 16777215 PIXEL
   // @ 290, 082 MSGET oValFor1  VAR nValFor1 SIZE 060, 011 PICTURE "@E 999,999,999.99" OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL WHEN .F.
    //@ 300, 082 MSGET oValFor2  VAR nValFor2 SIZE 060, 011 PICTURE "@E 999,999,999.99" OF oDlg COLORS 0, 16777215 FONT oFont3 PIXEL WHEN .F.
  	fMSNewGe1(cCotacao,aFornece[nComboBo1])
    DEFINE SBUTTON oSButton1 FROM 280,466 TYPE 01 ACTION fConfirma() OF oDlg ENABLE
    DEFINE SBUTTON oSButton2 FROM 280,496 TYPE 02 ACTION oDlg:End() OF oDlg ENABLE
    
  ACTIVATE MSDIALOG oDlg CENTERED

Return

/*
Confirma gravaçao
*/

Static Function fConfirma()
                                                        
MsAguarde( {|lEnd|FGravaSZ4()},"Aguarde","Gravando Registros...",.T.)
IF  nComboBo1 < len(aFornece)    
	If MsgYesNo( "Atualizar mais fornecedor?" ) 
    	nComboBo1+=1
		fMSNewGe1(cCotacao,aFornece[nComboBo1])  
		Return
	Else
		oDlg:End() 
	Endif	
Else
	oDlg:End() 
Endif    
Return 
                                                   

//------------------------------------------------ 
Static Function fMSNewGe1()
//------------------------------------------------ 
Local nX
Local aFields      := {"Z4_ITEM","Z4_PRODUTO","Z4_DESC","Z4_UM","Z4_MARCA","Z4_FORGANH","Z4_QUANT","Z4_PRECO","Z4_TOTAL","Z4_OBSADIC"}
Local aAlterFields := {"Z4_FORGANH","Z4_MARCA","Z4_PRAZO","Z4_COND","Z4_PRECO","Z4_GANHADO"}
Private aHeaderEx  := {}
Private aColsEx    := {}

Static oMSNewGe1
//1) Z4_FILIAL+Z4_COTACAO+Z4_FORNECE+Z4_LOJA+Z4_PRODUTO 
//2) Z4_FILIAL+Z4_COTACAO+Z4_PRODUTO    

  // Define field properties
  DbSelectArea("SX3")
  SX3->(DbSetOrder(2))
  For nX := 1 to Len(aFields)
    If SX3->(DbSeek(aFields[nX]))
      Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
                       SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
    Endif
  Next nX          
  For nX := 1 To Len(aFornece) 
  		cNome:=aFornece[nX]
  		Aadd(aHeaderEx,{cNome,"Z4_QUANT"+Alltrim(str(nx,5)),PesqPict("SZ4","Z4_QUANT"),TamSx3("Z4_QUANT")[1]  ,TamSx3("Z4_QUANT")[2],"","û","N"," ","V" } )	
  		Aadd(aHeaderEx,{AllTrim(RetTitle("Z4_COND")),"Z4_COND" +Alltrim(str(nx,5)),PesqPict("SZ4","Z4_COND")  ,TamSx3("Z4_COND")[1] ,0,"","û","N"," ","V" } )	
  		Aadd(aHeaderEx,{AllTrim(RetTitle("Z4_MARCA")),"Z4_MARCA"+Alltrim(str(nx,5)),PesqPict("SZ4","Z4_MARCA"),TamSx3("Z4_MARCA")[1],0,"","û","N"," ","V" } )	
  		Aadd(aHeaderEx,{AllTrim(RetTitle("Z4_PRAZO")),"Z4_PRAZO"+Alltrim(str(nx,5)),PesqPict("SZ4","Z4_PRAZO"),TamSx3("Z4_PRAZO")[1],0,"","û","N"," ","V" } )	
  Next nX  
  
 //aHeaderEx[nX,11]:=aFornece
  aHeaderEx[nX,9]:="   "
                        
  

  // Define field values
  	 
  	 fSelCotFor() // Busca dados do fornecedor
  	                        
  	 
  	 cProduto:=Criavar("Z4_PRODUTO")                                             
     nPos0:=GDFieldPos("Z4_QUANT1",aHeaderEx) - 1  
     
     fSelCotProd()
/*      
	  dbSelectArea("SZ4")
	  dbSetOrder(2)
	  dbSeek(xFilial("SZ4")+cCotacao,.T.)
	  While !Eof() .And. SZ4->Z4_FILIAL+SZ4->Z4_COTACAO=xFilial("SZ4")+cCotacao
	
            If SZ4->Z4_PRODUTO <> cProduto    
               cProduto:=SZ4->Z4_PRODUTO
               aadd(aColsEx,Array(Len(aHeaderEx)+2))
				For nX := 1 To Len(aHeaderEx)
		  			aColsEx[Len(aColsEx)][nX] :=  SZ4->(FieldGet(FieldPos(aHeaderEx[nx,2]) )) 
				Next nX            
            Endif
			cNome:=Left(Posicione("SA2",1,xFilial("SA2")+SZ4->Z4_FORNECE,"A2_NOME"),30)                                                                                                        
			nPos:=aScan( aFornece, {|x| x == SZ4->Z4_FORNECE+SZ4->Z4_LOJA+"-"+cNome  } )
			
			cCondPgto := SZ4->Z4_COND 
			nValdesc  := SZ4->Z4_VALDESC
			nValFrete := SZ4->Z4_VALFRE  
			nValdesc  := SZ4->Z4_VALDESC  
			
			
            nPos1:=nPos0 + ( 4 * nPos) 
             
			aColsEx[Len(aColsEx)][nPos1 -3] := SZ4->Z4_PRECO
			aColsEx[Len(aColsEx)][nPos1 -2] := SZ4->Z4_COND
			aColsEx[Len(aColsEx)][nPos1 -1] := SZ4->Z4_MARCA    
			aColsEx[Len(aColsEx)][nPos1]    := SZ4->Z4_PRAZO   

		  	aColsEx[Len(aColsEx)][Len(aHeaderEx)+1] := Recno()	
			aColsEx[Len(aColsEx)][Len(aHeaderEx)+2] := .F.	
			dbSelectArea("SZ4")
			dbSkip()
	  EndDo   
 */	                     

    oMSNewGeP05 := MsNewGetDados():New( aPosObj[1,1],aPosObj[1,2],aPosObj[1,3]+130,aPosObj[1,4]+5, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Z4_ITEM", aAlterFields,, Len(aColsEx), "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
	oMSNewGeP05:oBrowse:oWnd

    oMSNewGeFor := MsNewGetDados():New( aPosObj[1,1]+210,aPosObj[1,2],aPosObj[1,3]+240,aPosObj[1,4]-400, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Z4_ITEM", aAlterFields,, Len(aColsEx), "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
		
   //	oMSNewGeP05:oBrowse:BSETGET := {||nTotalCot :=aFSATUCAB(oMSNewGeP05:aCols[oMSNewGeP05:nAt][7]),oTotalCot:Refresh()}//atualiza saldo no cabeçalho de acordo com o saldo no acols.
 	oMSNewGeFor:oBrowse:Refresh()

Return
     
Static Function AFSATUCAB(pValor)     
Local nValor:=0

	For nI := 1 To Len(oMSNewGeP05:aCols)
		If !oMSNewGeP05:aCols[oMSNewGeP05:nAt,Len(oMSNewGeP05:aCols[oMSNewGeP05:nAt])] 
			nValor += oMSNewGeP05:aCols[ni][7]    
		Else
			nValor -= oMSNewGeP05:aCols[ni][7]   
		Endif
		
	Next nI
	nValMerc:= nValor
	nValor  += nValFrete - nValDesc
//	oValDesc:Refresh()      
Return(nValor) 
//------------------------------------------------ 
//* Grava na tabela SZ4 cotaçao   
//------------------------------------------------ 
Static Function FGravaSZ4()
Local x1:=0
Local aWBrowGru := {}  
Local aAuxGru   := {}    
Local lRet:=.F.
Local nConReg := 0  
Local cUsrCot :=UsrRetName(RetCodUsr())
Local cCodCot :=RetCodUsr()
Local aReg	  :={}
     
aHeader:=Aclone(oMSNewGeP05:aHeader)

	Begin Transaction   
		For nX := 1 To Len(oMSNewGeP05:aCols)
			If !oMSNewGeP05:aCols[oMSNewGeP05:nAt,Len(oMSNewGeP05:aCols[oMSNewGeP05:nAt])] 
				dbSelectArea("SZ4") 
				dbGoto(oMSNewGeP05:aCols[nX,Len(oMSNewGeP05:aCols[nX])-1])	 
				RecLock("SZ4", .F.)
	            	SZ4->Z4_PRECO   :=oMSNewGeP05:aCols[nx,GDFieldPos("Z4_PRECO")]
	            	SZ4->Z4_QUANT   :=oMSNewGeP05:aCols[nx,GDFieldPos("Z4_QUANT")]
	            	SZ4->Z4_TOTAL   :=oMSNewGeP05:aCols[nx,GDFieldPos("Z4_TOTAL")] 
	            	SZ4->Z4_GANHADO :=oMSNewGeP05:aCols[nx,GDFieldPos("Z4_GANHADO")] 
	            	SZ4->Z4_DATA    := DATE()
	            	SZ4->Z4_HORA    := TIME()
		    		SZ4->Z4_VALDESC := nValdesc
		    		SZ4->Z4_VALFRE  := nValFrete
		    		SZ4->Z4_VALDESC := nValdesc 
		    		SZ4->Z4_COND    := cCondPgto 
				MsUnLock()  
			  	//FGravaSZ1(nReg,aReg)
			Endif	
			dbSelectArea("SZ2") 
			cNumero := GetSxENum("SZ2","Z2_NUMERO") 
			ConfirmSX8()
  
			If RecLock("SZ2", .T.) 
   			SZ2->Z2_FILIAL   := SZ4->Z4_FILIAL
   			SZ2->Z2_NUMERO   :=cNumero
			    SZ2->Z2_CODIGO   := "003" 
			   	SZ2->Z2_NUMSC    := SZ4->Z4_NUMSC
			   	SZ2->Z2_NUMCOT   := SZ4->Z4_COTACAO
			   	SZ2->Z2_PRODUTO  := SZ4->Z4_PRODUTO
			   	SZ2->Z2_ITEMSC   := SZ4->Z4_ITEMSC
			   	SZ2->Z2_CODUSR   := cCodCot
			   	SZ2->Z2_NOMEUSR  := cUsrCot
			  	SZ2->Z2_MOTIVO   := "ATUALIZAÇÃO DE PREÇO"   
			   	SZ2->Z2_DATA     := DATE()
			   	SZ2->Z2_HORA     := TIME()
			   	SZ2->Z2_MOTIVO   := "ATUALIZA COTAÇÃO"
			   	SZ2->Z2_EMAIL1   :=""
			   	SZ2->Z2_EMAIL2   :=""
			   	SZ2->Z2_EMAIL3   :=""
			   	SZ2->Z2_EMAIL4   :=""
			   	SZ2->Z2_EMAIL5   :=""
				MsUnLock()  
		Endif	  

		Next
	End Transaction 
Return(lRet)  
//------------------------------------------------ 
//* Verificar fornecedores
//------------------------------------------------ 
Static Function FFornece()
  dbSelectArea("SZ4")
  dbSetOrder(1)
  dbSeek(xFilial("SZ4")+cCotacao,.T.)
  While !Eof() .And. SZ4->Z4_FILIAL+SZ4->Z4_COTACAO=xFilial("SZ4")+cCotacao 
                         
		cNome:=Left(Posicione("SA2",1,xFilial("SA2")+SZ4->Z4_FORNECE+SZ4->Z4_LOJA,"A2_NOME"),30)
		                                                                                                        
		nPos:=aScan( aFornece, {|x| x == SZ4->Z4_FORNECE+SZ4->Z4_LOJA+"-"+cNome  } )
		If Empty(nPos)
			aadd(aFornece,SZ4->Z4_FORNECE+SZ4->Z4_LOJA+"-"+cNome )
		Endif    
		nValFrete :=SZ4->Z4_VALFRE
		nValDesc  :=SZ4->Z4_VALDESC                   
		nTotalCot +=SZ4->Z4_TOTAL        
		cCondPgto :=SZ4->Z4_COND
		nValMerc  +=SZ4->Z4_TOTAL 
		dbSelectArea("SZ4")
		dbSkip()
  EndDo  
           
 nTotalCot +=(nValFrete - nValDesc)       

Return()  

//------------------------------------------------ 
Static Function fSelCotProd()
// Funcao para mostrar os produtos em  analise de
// Cotação agrupado por produto e menor preco
//------------------------------------------------ 

Local aAliasOLD    := GetArea()
Local cAliasQry    := GetNextAlias()                                                                                
Local aFields      := {"Z4_ITEM" ,"Z4_PRODUTO","Z4_DESC","Z4_UM","Z4_MARCA","Z4_FORGANH","Z4_QUANT","Z4_PRECO","Z4_TOTAL","Z4_OBSADIC"}
Local aAlterFields := {"Z4_FORGANH","Z4_MARCA","Z4_PRAZO","Z4_COND","Z4_PRECO","Z4_GANHADO"}

	BeginSql Alias cAliasQry
		SELECT DISTINCT Z4_PRODUTO,Z4_ITEM,Z4_PRECO,Z4_FORNECE,Z4_LOJA,Z4_QUANT,Z4_TIPO,Z4_COND,Z4_MARCA,Z4_PRAZO,SZ4.R_E_C_N_O_ AS RECNOSZ4
		FROM %table:SZ4% SZ4                                                 
		WHERE SZ4.%notDel% 	AND    
		SZ4.Z4_COTACAO  = %Exp:cCotacao% AND         
  		SZ4.Z4_PRECO NOT IN (%Exp:'0'%)  AND
  		SZ4.Z4_STATUS    IN (%Exp:'3'%)         
  		ORDER BY Z4_PRODUTO,Z4_PRECO,Z4_TIPO,Z4_FORNECE,Z4_LOJA,Z4_COND,Z4_PRAZO
  	EndSql                       
 
  	 cProduto:=Criavar("Z4_PRODUTO")                                             
     nPos0:=GDFieldPos("Z4_QUANT1",aHeaderEx) - 1  
 
	(cAliasQry)->( DbGoTop() )
 	While !(cAliasQry)->(EOF())   
  			cNome:=Left(Posicione("SA2",1,xFilial("SA2")+(cAliasQry)->Z4_FORNECE+(cAliasQry)->Z4_LOJA,"A2_NOME"),30)

 	        If (cAliasQry)->Z4_PRODUTO <> cProduto    
               cProduto:=(cAliasQry)->Z4_PRODUTO
               aadd(aColsEx,Array(Len(aHeaderEx)+2))
				For nX := 1 To Len(aHeaderEx)
		  			aColsEx[Len(aColsEx)][nX] :=  (cAliasQry)->(FieldGet(FieldPos(aHeaderEx[nx,2]) )) 
				Next nX            
            Endif
			cNome:=Left(Posicione("SA2",1,xFilial("SA2")+(cAliasQry)->Z4_FORNECE+(cAliasQry)->Z4_LOJA,"A2_NOME"),30)                                                                                                        
			nPos:=aScan( aFornece, {|x| x == (cAliasQry)->Z4_FORNECE+(cAliasQry)->Z4_LOJA+"-"+cNome  } )
            
	        nPos1:=nPos0 + ( 4 * nPos) 
	
			aColsEx[Len(aColsEx)][nPos1 -3] := (cAliasQry)->Z4_PRECO
			aColsEx[Len(aColsEx)][nPos1 -2] := (cAliasQry)->Z4_COND
			aColsEx[Len(aColsEx)][nPos1 -1] := (cAliasQry)->Z4_MARCA    
			aColsEx[Len(aColsEx)][nPos1]    := (cAliasQry)->Z4_PRAZO  
											 
		  	aColsEx[Len(aColsEx)][Len(aHeaderEx)+1] := Recno()	
			aColsEx[Len(aColsEx)][Len(aHeaderEx)+2] := .F.	
 	
        (cAliasQry)->(dbskip())  
	EndDo
	
	(cAliasQry)->(dbCloseArea())

RestArea(aAliasOLD)
Return()  


//------------------------------------------------ 
Static Function fSelCotFor()
// Funcao para mostrar total de fornecedor por
// Cotação 
//------------------------------------------------ 
Local aAliasOLD    := GetArea()
Local cAliasQry    := GetNextAlias()                                                                                
Local aHeaderFor := {}
Local aColsFor   := {}
Local aFields      := {"Z4_COTACAO","Z4_FORNECE","Z4_LOJA","A2_NOME","Z4_COND","Z4_PRAZO","Z4_TOTAL"}
Local aAlterFields := {""} 
aFornece:={}

  // Define field properties
  DbSelectArea("SX3")
  SX3->(DbSetOrder(2))
  For nX := 1 to Len(aFields)
    If SX3->(DbSeek(aFields[nX]))
      	Aadd(aHeaderFor, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
                          SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
    Endif
  Next nX          

	BeginSql Alias cAliasQry 
		SELECT Z4_COTACAO,Z4_FORNECE,Z4_LOJA,Z4_COND,Z4_PRAZO, SUM(Z4_TOTAL) AS Z4_TOTAL 
		FROM %table:SZ4% SZ4                                                 
		WHERE SZ4.%notDel% 	AND    
		SZ4.Z4_COTACAO  = %Exp:cCotacao% AND         
  		SZ4.Z4_PRECO NOT IN (%Exp:'0'%)  AND
  		SZ4.Z4_STATUS    IN (%Exp:'3'%)
  	   	GROUP BY Z4_COTACAO,Z4_FORNECE,Z4_LOJA,Z4_COND,Z4_PRAZO  
		ORDER BY Z4_COTACAO,Z4_FORNECE,Z4_TOTAL,Z4_COND,Z4_PRAZO         
  	EndSql                       

	(cAliasQry)->( DbGoTop() )
 	While !(cAliasQry)->(EOF())   
  	
  			cNome:=Left(Posicione("SA2",1,xFilial("SA2")+(cAliasQry)->Z4_FORNECE+(cAliasQry)->Z4_LOJA,"A2_NOME"),30)
			
			nPos:=aScan( aFornece, {|x| x == (cAliasQry)->Z4_FORNECE+(cAliasQry)->Z4_LOJA+"-"+cNome  } )
			If Empty(nPos)
				aadd(aFornece,(cAliasQry)->Z4_FORNECE+(cAliasQry)->Z4_LOJA+"-"+cNome )
			Endif    
		                                                                                                        
            aadd(aColsFor,Array(Len(aHeaderFor)))
            
			For nX := 1 To Len(aHeaderFor)
		  			aColsFor[Len(aColsFor)][nX] :=  (cAliasQry)->(FieldGet(FieldPos(aHeaderFor[nx,2]) )) 
			Next nX            
            
		  	aColsFor[Len(aColsFor)][4] := cNome     //GDFieldPos("A2_NOME")
	
        (cAliasQry)->(dbskip())  
	EndDo
	
	(cAliasQry)->(dbCloseArea())

RestArea(aAliasOLD)
Return()  


  

