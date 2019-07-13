#Include "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} AFATP08
Description gera as ordens de compra
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Jose Antonio (AMM)                                              
@since 17/12/2012                                                   
/*/                                                             
//-------------------------------------------------------------- 
***********************************
User Function AFATP08(pCotacao, cFil)    
***********************************
                    
Local oBitmap1
Local oBitmap2
Local oFont1 := TFont():New("Arial",,020,,.T.,,,,,.F.,.F.)
Local oFont2 := TFont():New("Arial",,018,,.T.,,,,,.F.,.F.)
Local oFont3 := TFont():New("Arial",,016,,.T.,,,,,.F.,.F.)
Local oFont4 := TFont():New("Arial",,016,,.F.,,,,,.F.,.F.)
Local oGroup1
Local oGroup2
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSButton1

Private cCotacao :=pCotacao             

Private oWBrowse18
Private aWBrowse18 := {}
Private cFilC8     :=cFil`
Private aAUx	   := {}
Private aResolu    := getScreenRes() 

//if oWBrowAux == Nil
//	Alert("Cotação bloqueada !" )
//    Return()
//Endif 


If  Empty(pCotacao)
	Alert("Cotação número não existe !" )
	Return()
Endif

Static oDlg

  aSize := MsAdvSize(.F.)
 /*
 MsAdvSize (http://tdn.totvs.com/display/public/mp/MsAdvSize+-+Dimensionamento+de+Janelas)
 aSize[1] = 1 -> Linha inicial área trabalho.
 aSize[2] = 2 -> Coluna inicial área trabalho.
 aSize[3] = 3 -> Linha final área trabalho.
 aSize[4] = 4 -> Coluna final área trabalho.
 aSize[5] = 5 -> Coluna final dialog (janela).
 aSize[6] = 6 -> Linha final dialog (janela).
 aSize[7] = 7 -> Linha inicial dialog (janela).  */   

  
  
  DEFINE MSDIALOG oDlg TITLE "Pedido de Compras" FROM aSize[7],0 TO aSize[6],aSize[5] COLORS 0, 16777215 PIXEL
  oWBrowAux:=fWBrowse1(pCotacao)
  If Len(aAUx)==0
  Alert("Cotação não disponível para geração de Pedido de Compras.")
  oDlg:End()
  Endif
  
   IF(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080 
    @ 002, 051 SAY oSay1 PROMPT "Gerar Ordem de Compras" SIZE 121, 010 OF oDlg FONT oFont1 COLORS 32768, 16777215 PIXEL 
    
	@ 420,530 Button "&Todos" Size C(037),C(012) Action fTodos() PIXEL OF oDlg
	@ 420,580 Button "&Desmarca" Size C(037),C(012) Action fDesmarca() PIXEL OF oDlg
	@ 420,630 Button "&Confirmar" Size C(037),C(012) Action fConfirma(oWBrowAux) PIXEL OF oDlg
	@ 420,680 Button "&Fechar" Size C(037),C(012) Action oDlg:End() PIXEL OF oDlg    
   Else
    @ 002, 051 SAY oSay1 PROMPT "Gerar Ordem de Compras" SIZE 121, 010 OF oDlg FONT oFont1 COLORS 32768, 16777215 PIXEL 
    
	@ 277,330 Button "&Todos" Size C(037),C(012) Action fTodos() PIXEL OF oDlg
	@ 277,380 Button "&Desmarca" Size C(037),C(012) Action fDesmarca() PIXEL OF oDlg
	@ 277,430 Button "&Confirmar" Size C(037),C(012) Action fConfirma(oWBrowAux) PIXEL OF oDlg
	@ 277,480 Button "&Fechar" Size C(037),C(012) Action oDlg:End() PIXEL OF oDlg
   Endif
  ACTIVATE MSDIALOG oDlg CENTERED

Return
/*
Confirma gravaçao
*/

Static Function fConfirma(poWBrowAux)

MsAguarde( {|lEnd|FMontaSC7(poWBrowAux)},"Aguarde","Gerando Pedido de Compras...",.T.)

oDlg:End()
Return 

//------------------------------------------------ 
Static Function fWBrowse1(pCotacao)
//------------------------------------------------ 
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")
Local nreg      :=1

    // Insert items here   
    
    aAUx:=fSelecao1(pCotacao) 
    
    If Len(aAUx)==0 
    	return()
    Endif
 
    If Len(aAUx)==0 
		Aadd(aWBrowse18,{.F.,oFlagVERMELHO,"","","","","","","","","","","","",""})
    ElSe
		aWBrowse18:=Aclone(aAUx)
    Endif        
    // Insert items here
    IF(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080 
	    @ 015, 000 LISTBOX oWBrowse18 Fields HEADER "Flag","Num. Cotação","Fornecedor","Loja","Nome do Fornecedor","Produto","Descrição do Produto",;
	    		"Quantidade",;
	    		"Preço",;
	    		"Total",;
	    		"Cond Pgto",;
	    		"Prazo",;
	   			"Desconto",;
	   			"Frete",;
	  			"Desconto %", SIZE 955, 395 OF oDlg PIXEL ColSizes 50,50         
	    oWBrowse18:SetArray(aWBrowse18)
	    oWBrowse18:bLine := {|| {;
	     If(aWBrowse18[oWBrowse18:nAT,1],oOk,oNo),;
	      aWBrowse18[oWBrowse18:nAt,02],;
	      aWBrowse18[oWBrowse18:nAt,03],;
	      aWBrowse18[oWBrowse18:nAt,04],;
	      aWBrowse18[oWBrowse18:nAt,05],;
	      aWBrowse18[oWBrowse18:nAt,06],;
	      aWBrowse18[oWBrowse18:nAt,07],;
	      Transform(aWBrowse18[oWBrowse18:nAt,08],"@E 999,999.99"),;
	      Transform(aWBrowse18[oWBrowse18:nAt,09],"@E 999,999,999.99"),;
	      aWBrowse18[oWBrowse18:nAt,10],;
	      aWBrowse18[oWBrowse18:nAt,11],;
	      aWBrowse18[oWBrowse18:nAt,12],;
	      aWBrowse18[oWBrowse18:nAt,13],;
	      aWBrowse18[oWBrowse18:nAt,14],;
	      aWBrowse18[oWBrowse18:nAt,15];
	    }}
	ELSE
	
	@ 015, 000 LISTBOX oWBrowse18 Fields HEADER "Flag","Num. Cotação","Fornecedor","Loja","Nome do Fornecedor","Produto","Descrição do Produto",;
    		"Quantidade",;
    		"Preço",;
    		"Total",;
    		"Cond Pgto",;
    		"Prazo",;
   			"Desconto",;
   			"Frete",;
  			"Desconto %", SIZE 678, 260 OF oDlg PIXEL ColSizes 50,50         
    oWBrowse18:SetArray(aWBrowse18)
    oWBrowse18:bLine := {|| {;
     If(aWBrowse18[oWBrowse18:nAT,1],oOk,oNo),;
      aWBrowse18[oWBrowse18:nAt,02],;
      aWBrowse18[oWBrowse18:nAt,03],;
      aWBrowse18[oWBrowse18:nAt,04],;
      aWBrowse18[oWBrowse18:nAt,05],;
      aWBrowse18[oWBrowse18:nAt,06],;
      aWBrowse18[oWBrowse18:nAt,07],;
      Transform(aWBrowse18[oWBrowse18:nAt,08],"@E 999,999.99"),;
      Transform(aWBrowse18[oWBrowse18:nAt,09],"@E 999,999,999.99"),;
      aWBrowse18[oWBrowse18:nAt,10],;
      aWBrowse18[oWBrowse18:nAt,11],;
      aWBrowse18[oWBrowse18:nAt,12],;
      aWBrowse18[oWBrowse18:nAt,13],;
      aWBrowse18[oWBrowse18:nAt,14],;
      aWBrowse18[oWBrowse18:nAt,15];
    }}
	
	ENDIF 
    // DoubleClick event                                                             
    oWBrowse18:bLDblClick := {|| aWBrowse18[oWBrowse18:nAt,1] := !aWBrowse18[oWBrowse18:nAt,1],;
    oWBrowse18:DrawSelect()}

   
Return(oWBrowse18)               
//------------------------------------------------ 
Static Function fSelecao1(pCotocao)
//------------------------------------------------ 

Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()                                                                                
Local cCodUser  := RetCodUsr() 
Local aWBrowAux := {}     
Local cSql      :=""

	BeginSql Alias cAliasQry

	 	SELECT C8_NUM, C8_ITEM,C8_FORNECE,C8_LOJA,A2_NOME,C8_PRODUTO, C8_ZDESCRI,C8_NUMSC,C8_ITEMSC,C8_QUANT,C8_PRECO,;
	 	       C8_TOTAL,C8_COND,C8_PRAZO,C8_VALFRE,C8_DESC,C8_VLDESC ,C8_ZTODESC,C8_ZFILFAT,C8_FILENT,SC8.R_E_C_N_O_ AS RECSC8,C8_ZPRDSUB
		FROM %table:SC8% SC8                                                 
		INNER JOIN %table:SA2% SA2 ON SC8.C8_FORNECE = SA2.A2_COD AND SC8.C8_LOJA = SA2.A2_LOJA AND SA2.%notDel%   
		WHERE SC8.%notDel% 	AND            
 	 	SC8.C8_NUM = %Exp:pCotocao%  AND
  		SC8.C8_ZSTATUS  IN (%Exp:'3'%)    AND
  		SC8.C8_ZGANHAD  IN (%Exp:'S'%)
      	ORDER BY C8_PRODUTO,C8_FORNECE                		
  	EndSql   
	(cAliasQry)->( DbGoTop() )
 	While !(cAliasQry)->(EOF())  
        Aadd(aWBrowAux,{.F.,;  						//Flag     		       1
        	(cAliasQry)->C8_NUM,;  				    //Numero Cotacao       2
        	(cAliasQry)->C8_FORNECE,;  				//Codigo do fornecedor 3 
        	(cAliasQry)->C8_LOJA,;     				//Loja  			   4
        	(cAliasQry)->A2_NOME,;     				//Nome dor fornecedor  5
        	(cAliasQry)->C8_PRODUTO,;//Produto    	       6   	
        	Iif(!Empty((cAliasQry)->C8_ZPRDSUB),Alltrim((cAliasQry)->C8_ZPRDSUB) + " - " + Posicione("SB1",1,xFilial("SB1")+(cAliasQry)->C8_ZPRDSUB,"B1_DESC"),(cAliasQry)->C8_ZDESCRI),;//Descricao do Produto 7
        	(cAliasQry)->C8_QUANT,; 			 	//Quantidade 8         
        	(cAliasQry)->C8_PRECO ,;  									//Preco 	 9         
        	Transform( (cAliasQry)->C8_TOTAL,"@E 999,999,999.99"),;  	//Total 	10         
        	(cAliasQry)->C8_COND,; 										//Condicao de pagamento 11
        	Transform( (cAliasQry)->C8_PRAZO,"@E 9999"),; 				//Prazo 12
        	Transform( (cAliasQry)->C8_VLDESC,"@E 999,999,999.99"),;  	//Valor desconto valor 13         
        	Transform( (cAliasQry)->C8_VALFRE,"@E 999,999,999.99"),;  	//Valor do Frete 14         
        	Transform( (cAliasQry)->C8_DESC,"@E 999.99"),;  		  	//Desconto % 15        
        	(cAliasQry)->C8_ITEM,; 										//Item da cotaçao 16
        	(cAliasQry)->C8_NUMSC,;                                     //Solicitacao de compras 17
        	(cAliasQry)->C8_ITEMSC,; 									//Item da solicitacao 18
        	(cAliasQry)->C8_ZFILFAT,;                                   //Filial de fatura  19
        	(cAliasQry)->C8_FILENT,;                                    //Filial entrega    20 
        	(cAliasQry)->RECSC8,;                                       //Recno    21
        	Iif(!Empty((cAliasQry)->C8_ZPRDSUB),(cAliasQry)->C8_ZPRDSUB,(cAliasQry)->C8_PRODUTO),;//Produto Substituto 22
        	})                  
        (cAliasQry)->(dbskip())  
	EndDo

	(cAliasQry)->(dbCloseArea())
RestArea(aAliasOLD)
Return(aWBrowAux)  
                           
//------------------------------------------------ 
//* Grava na tabela SC7 Pedido de compras   
//------------------------------------------------ 
Static Function FMontaSC7(poWBrowAux)
Local x1:=0
Local aWBrowGru := {}  
Local aAuxGru   := {}    
Local lRet	 	:=.F.
Local nConReg   := 0  
Local cCodPed   :=RetCodUsr()
Local aReg	    := {}     
Local cNumero   := CriaVar("C7_NUM",.T.)
Local cItem     := "0"
Local cNumSC    := ""
Local cFornece  := ""                               
Local nQuantPed := 0
Local aTabSC1   := {}
Local aWBrowAux :=Aclone(poWBrowAux:aArray)  
Local aItem     := {}
Local aCab      := {}  
Local cKey      :=""
Local lFlagSC7  :=.F.
Local nRegSC1   :=0
Local cUsrPed   :=""
Local cCodAprov := ""

Private aSolicit:= {}

cCodAprov := Posicione("SY1",3,xFilial("SY1")+cCodPed,"Y1_GRAPROV")  
cUsrPed   := UsrRetName(cCodPed)
                         
		aSolicit:=fSeleSC1(cCotacao)                                  

 		For nX:= 1 To Len(aSolicit)  
 			cProduto:=aSolicit[nx,6]
            nPos:=aScan( aWBrowAux, { |x| x[6] == cProduto } ) 
            If Empty(nPos) .or. !aWBrowAux[nPos,1]   
			   loop
            Endif 
            
            aSolicit[nx,10]:=aWBrowAux[nPos,03]
            aSolicit[nx,11]:=aWBrowAux[nPos,04]
            aSolicit[nx,12]:=aWBrowAux[nPos,11]                           
            aSolicit[nx,13]:=aWBrowAux[nPos,21]  // Recno no SC8                         
            
            aSolicit[nx,Len(aSolicit[nx])]:=.T.    
            If aSolicit[nx,07] > aWBrowAux[nPos,8] 
               aSolicit[nx,07]:=aWBrowAux[nPos,8]
            Endif 
        Next
               
		aSort(aSolicit,,, { |x,y| x[1]+x[3]+x[10]+x[11] < y[1]+y[3]+y[10]+y[11] } )
       
 		For nX := 1 To Len(aSolicit)   
 			If aSolicit[nx,Len(aSolicit[nx])]                               
				nRegSC1:=aSolicit[nx,Len(aSolicit[nx])-1] 
				If cKey <> aSolicit[nX,1]+aSolicit[nX,3]+aSolicit[nX,10]+aSolicit[nX,11]
					If !Empty(cKey)                                                            
					                                         // Registro da SC1
						FGravaSC7(aCab,aItem,aTabSC1,cNumero,nRegSC1) 
					Endif
			        //     Empresa      Filial fatura   Fornecedor      Loja
			        cKey:=aSolicit[nX,1]+aSolicit[nX,3]+aSolicit[nX,10]+aSolicit[nX,11]
				    cItem:="0" 
				    aItem:= {}            
				    lFlagSC7:=.T.
				    cNumero:=GetSxENum("SC7","C7_NUM")
    				ConfirmSX8()
    				cNumero := GETNUMSC7()
					aCab:={ {"C7_ZEMP"    ,aSolicit[nx,1]     ,Nil},; //Empresa
							{"C7_NUM"     ,cNumero  	      ,Nil},; // Numero do Pedido
							{"C7_EMISSAO" ,dDataBase  	      ,Nil},; // Data de Emissao
							{"C7_FORNECE" ,aSolicit[nX,10]    ,Nil},; // Fornecedor
							{"C7_LOJA"    ,aSolicit[nX,11]    ,Nil},; // Loja do Fornecedor
							{"C7_COND"    ,aSolicit[nX,12]    ,Nil},; // Condicao de pagamento
							{"C7_TIPO"    ,1                  ,Nil},;  // Tipo      
							{"C7_FILIAL"  ,aSolicit[nx,3]     ,Nil}} // Filial para o Pedido
				Endif    
				
				dbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				SB1->(MsSeek(xFilial("SB1")+aSolicit[nX,6]))
				cItem := StrZero(val(Soma1(cItem,Len(SC7->C7_ITEM))),Len(SC7->C7_ITEM))
				dbSelectArea("SC8")
				dbGoto(aSolicit[nx,13])       
				
				cObsPed := ""
				
				If !Empty(SC8->C8_ZPRDSUB)
					dbSelectArea("SB1")
					SB1->(DbSetOrder(1))
					SB1->(MsSeek(xFilial("SB1")+SC8->C8_ZPRDSUB))
					
					If SB1->B1_ZRORIG <> '1'
						cObsPed := Alltrim(SB1->B1_FABRIC)  + "/" + Alltrim(SB1->B1_ZREF2)
					Else
						cObsPed := Alltrim(SB1->B1_FABRIC)  + "/" + Alltrim(SB1->B1_ZREF1) 
					EndIf   
					
					dbSelectArea("SB1")				
					SB1->(MsSeek(xFilial("SB1")+aSolicit[nX,6]))	
				Else
					If SB1->B1_ZRORIG <> '1'
						cObsPed := Alltrim(SB1->B1_FABRIC)  + "/" + Alltrim(SB1->B1_ZREF2)
					Else
						cObsPed := Alltrim(SB1->B1_FABRIC)  + "/" + Alltrim(SB1->B1_ZREF1) 
					EndIf
				EndIf
								
				aadd(aItem,{{"C7_FILIAL" ,aSolicit[nx,3]   ,Nil},; //Filial fatura
							{"C7_ITEM"   ,cItem            ,Nil},; //Numero do Item
							{"C7_PRODUTO",Iif(!Empty(SC8->C8_ZPRDSUB),SC8->C8_ZPRDSUB,aSolicit[nx,6])   ,Nil},; //Codigo do Produto
							{"C7_DESCRI" ,Iif(!Empty(SC8->C8_ZPRDSUB),Posicione("SB1",1,xFilial("SB1")+SC8->C8_ZPRDSUB,"B1_DESC"),SC8->C8_ZDESCRI),Nil},; //Descricao do produto
							{"C7_UM"     ,SB1->B1_UM 	   ,Nil},; //Unidade de Medida
							{"C7_QUANT"  ,aSolicit[nx,07]  ,Nil},; //Quantidade
							{"C7_PRECO"  ,SC8->C8_PRECO    ,Nil},; //Preco
							{"C7_TOTAL"  ,SC8->C8_PRECO * aSolicit[nx,07] ,Nil},; //Total
							{"C7_DATPRF" ,SC8->C8_DATPRF   ,Nil},; //Data De Entrega
							{"C7_FLUXO"  ,"S"			   ,Nil},; //Fluxo de Caixa (S/N)
							{"C7_CONAPRO","B"			   ,Nil},; //Bloqueia pedido
							{"C7_NUMCOT" ,SC8->C8_NUM      ,Nil},; //Numero da cotacao
							{"C7_NUMSC"  ,aSolicit[nx,5]   ,Nil},; //Numero solicitacao
							{"C7_ITEMSC" ,aSolicit[nx,8]   ,Nil},; //Item da solicitacao
							{"C7_FILENT" ,aSolicit[nx,4]   ,Nil},; //Filial de entrada
							{"C7_USER"   ,cCodPed          ,Nil},; //Codigo do Usuario
							{"C7_VALFRE" ,SC8->C8_VALFRE   ,Nil},; //Valor do frete
							{"C7_TPFRETE",SC8->C8_TPFRETE  ,Nil},; //Tipo do frete
							{"C7_CC"     ,aSolicit[nx,9]   ,Nil},; //Centro de custo//
							{"C7_ZMARCOD",cObsPed          ,Nil},; // Marca/Cod Referencia  {"C7_OBS"    ,cObsPed          ,Nil},; // Observação JSANTOS - 20150310 - Alteracao para liberar campo observação
		   					{"C7_LOCAL"  ,RetFldProd(SB1->B1_COD,"B1_LOCPAD"),Nil},;
		   					{"C7_FILORI" ,aSolicit[nx,2]   ,Nil},;
		   			   		{"C7_ZREF1",aSolicit[nx,6]   ,Nil},;//Codigo do Produto Original
		   			   		{"C7_ZAPLIC" ,aSolicit[nx,16]  ,Nil},;//Codigo da Aplicação
		   			   		{"C7_DESC"   ,SC8->C8_DESC	   ,Nil},;//Desconto %
		   					{"C7_VLDESC" ,SC8->C8_VLDESC / Iif(Alltrim(SC8->C8_ITEMSC)='999',SC8->C8_QUANT,1),Nil},;//Valor do desconto
		   					{"C7_IPI"    ,SC8->C8_ALIIPI   											,Nil},;//Aliq. IPI 
		   			   		{"C7_VALIPI" ,((SC8->C8_PRECO * aSolicit[nx,07])/100)*(SC8->C8_ALIIPI)  ,Nil},;//Valor. IPI 
		   			   		{"C7_BASEIPI",SC8->C8_PRECO * aSolicit[nx,07] 							,Nil},;//Base. IPI 
		   			   		{"C7_PICM"   ,SC8->C8_PICM	   											,Nil},;
		   			   		{"C7_VALICM" ,((SC8->C8_PRECO * aSolicit[nx,07])/100)*(SC8->C8_PICM)    ,Nil},;//Valor. ICMS 
		   			   		{"C7_BASEICM",SC8->C8_PRECO * aSolicit[nx,07] 							,Nil},;//Base. ICMS 		   					
		   			   		{"C7_APROV"  ,cCodAprov						 							,Nil},;//Grupo de aprovação
						   	{"C7_ZOBSADI",SC8->C8_ZOBSADI  ,Nil},; //Observacao adicional do Produto
						   	{"C7_OBS",SC8->C8_OBS  ,Nil}}) //Observacao do Solicitante
			Endif
			
        Next            
//		{"C7_ZTODESC",SC8->C8_C8_ZTODESC  ,Nil},; //Valor do desconto

        IF lFlagSC7
				FGravaSC7(aCab,aItem,aTabSC1,cNumero,nRegSC1)
        Endif
Return()
			  
//------------------------------------------------ 
//* Grava na tabela SC7 Pedido de compras   
//------------------------------------------------ 
/*
Static Function aFGravaSC7(paCab,paItem,paTabSC1,pNumero) 
Local lRet:=.T.
Local aAliasOLD := GetArea()
			    
	Begin Transaction           
 			
	lMsErroAuto := .f.
	
	MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,paCab,paItem,3)
	IF  lMSErroAuto
	 	MostraErro()
		lRet:=.F.  
		Aviso('ERRO', 'Não gravou registros', {'Ok'}) 
		DisarmTransaction()
		Break    
	Else  
		For xZ:=1 to Len(paTabSC1) 
		    dbSelectArea("SC1")
		    dbGoto(paTabSC1[xz])
			IF RecLock("SC1",.F.)
				SC1->C1_COTACAO :=pNumero  
				//SC1->C1_ITEMOC:=
				SC1->(MsUnlock())
			Endif	
			//Gravar Pedido na solicitacao 
			
			ApMsgInfo("Pedido de Compras " + pNumero + " gerado com sucesso !!!")			
			
		Next  
		
		 
		lRet:=.T.
	EndIF
	End Transaction 
RestArea(aAliasOLD)
Return(lRet)  
*/
//------------------------------------------------ 
//* Grava na tabela SC7 Pedido de compras   
//------------------------------------------------ 
Static Function FGravaSC7(paCab,paItem,paTabSC1,pNumero) 
Local lRet:=.T.
Local aAliasOLD := GetArea()
Local cUsrPed   :=UsrRetName(RetCodUsr())
Local cCodPed   :=RetCodUsr()    
Local nRegSM0 	:= SM0->(Recno())    
Local cPedido   := SC7->C7_NUM 
Local cItemPed  := SC7->C7_ITEM 
Local cPRODUTO  := SC7->C7_PRODUTO
Local cITEMSC   := SC7->C7_ITEMSC  
Local cNumSC    :=""
Local cEmp      :="" 
Local nRegSC7   :=0 
Local nTotPed   := 0       
Local aSCE      := {}

IF paCab[1,2] == SM0->M0_CODIGO
	dbSelectArea("SM0")
	SM0->(MsSeek(paCab[1,2]))  
	Begin Transaction                  
		For xx:=1 To Len(paItem)
		    dbSelectArea("SC7")
		    dbSetOrder(1)     
	   		RecLock("SC7",.T.)                
			For nJ := 1 To Len(paCab)
				FieldPut( FieldPos( paCab[nJ,1]), paCab[nj,2] )
			Next nJ 
			
			For nJ := 1 To Len(paItem[xx])
				if (Alltrim(paItem[xx,nJ,1]) <> "C7_FILORI") .And. Alltrim(paItem[xx,nJ,1]) <> "C7_ZREF1"
					FieldPut( FieldPos( paItem[xx,nJ,1]), paItem[xx,nJ,2] )
				endif
				
				if Alltrim(paItem[xx,nJ,1]) == "C7_TOTAL"
					nTotPed := nTotPed +  paItem[xx,nJ,2]
				endif				
			Next nJ
			SC7->(MsUnlock())    
			 
			cPedido   := SC7->C7_NUM 
			cItemPed  := SC7->C7_ITEM 			
            cPRODUTO  := SC7->C7_PRODUTO
            cPROOri   := paItem[xx,23,2]
            cNUMSC    := SC7->C7_NUMSC
            cITEMSC   := SC7->C7_ITEMSC 
            cFilCota  := SC7->C7_FILIAL 
            cNUMCOT   := SC7->C7_NUMCOT
            cFORNECE  := SC7->C7_FORNECE
            cLoja     := SC7->C7_LOJA 
            cEmp      := SC7->C7_ZEMP
            nQuantPed := SC7->C7_QUANT
 
         fGravSb2(SC7->C7_FILIAL,SC7->C7_PRODUTO,SC7->C7_LOCAL,SC7->C7_QUANT,SC7->C7_ZEMP) //Atualiza tabela SB2  B2_SALPEDI  
     
			//fUPDSC1(paCab[1,2],SC7->C7_FILIAL ,cNUMCOT,SC7->C7_PRODUTO,cPedido,cItemPed,paItem[xx,02,2],cNUMSC,cITEMSC) // Atualiza a tabela de solicitaçao de compras
			//fUPDSC1(paCab[1,2],paCab[9,2] ,cNUMCOT,SC7->C7_PRODUTO,cPedido,cItemPed,paItem[xx,02,2],cNUMSC,cITEMSC) // Atualiza a tabela de solicitaçao de compras
			fUPDSC1(paCab[1,2],paItem[xx,22,2] ,cNUMCOT,SC7->C7_PRODUTO,cPedido,cItemPed,nQuantPed,cNUMSC,cITEMSC,SC7->C7_FORNECE,SC7->C7_LOJA) // Atualiza a tabela de solicitaçao de compras
	        
			dbSelectArea("SM0")
			SM0->(dbGoto(nRegSM0))	
          
			dbSelectArea("SC8")   // Grava na tabela de cotação o numero do pedido de compra   
			dbSetOrder(3)      
			//dbSeek(xFilial("SC8")+cNUMCOT+cPRODUTO,.T.)//+cFORNECE+cLoja,.T.) 
			if dbSeek(cFilCota+cNUMCOT+SubStr(cPROOri,1,15))//+cFORNECE+cLoja,.T.) 	
				While !Eof() .And. SC8->C8_FILIAL == cFilCota .And. SC8->C8_NUM == cNUMCOT .And. SC8->C8_PRODUTO == cPROOri //.And. SC8->C8_FORNECE=cFORNECE .And. SC8->C8_LOJA = cLoja
				    If  SC8->C8_ZGANHAD='S'  //.And. Empty(SC8->C8_NUMOC)                                                                                                  
					  	IF RecLock("SC8",.F.)
							SC8->C8_ZSTATUS := "5"
							SC8->C8_NUMPED  := cPedido 
							SC8->C8_ITEMPED := cITEMPed 
							SC8->(MsUnlock())
						Endif 
						
						Aadd(aSCE,{SC8->C8_FILIAL,; //filial
					  				  SC8->C8_NUM,; //numero cotacao
					              SC8->C8_ITEM,; //item cot
					              SC8->C8_PRODUTO,; //produto
					              SC8->C8_FORNECE,; //fornece
					              SC8->C8_LOJA,; //loja
					              SC8->C8_NUMPRO,; //numpro
					              SC8->C8_QUANT,; //quantidade
					              SC8->C8_DATPRF; //data entrega
           					    })
					  
					 else
					  	IF RecLock("SC8",.F.)
							SC8->C8_ZSTATUS := "5"
							SC8->C8_NUMPED  := "XXXXXX" 
							SC8->C8_ITEMPED := "XXXX" 
							SC8->(MsUnlock())
						Endif 				
					Endif 
					dbSkip()	
		        Enddo
		    endif
			aCab:={ {"Z2_CODIGO"  ,"004"  	      ,Nil},; // Codigo da ocorrencias
					{"Z2_FILIAL"  ,cFilCota       ,Nil},; //Filial
					{"Z2_NUMSC"   ,cNUMSC         ,Nil},; // Numero da solicitacao
					{"Z2_ITEMSC"  ,cITEMSC        ,Nil},; // Item da solicitacao
					{"Z2_NUMCOT"  ,cNUMCOT        ,Nil},; // Numero da contacao
					{"Z2_PRODUTO" ,cPRODUTO       ,Nil},; // Produto
					{"Z2_EMP"     ,cEmp           ,Nil},; // Empresa
					{"Z2_CODUSR"  ,cCodPed   	  ,Nil},; // Condicao do usuario
					{"Z2_NOMEUSR" ,cUsrPed  	  ,Nil},; // Nome do usuario
					{"Z2_MOTIVO"  ,"PEDIDO GERADO",Nil},; // Motivo
					{"Z2_DATA"    ,DATE()		  ,Nil},; // Data 
					{"Z2_HORA"    ,Time() 		  ,Nil},; // Hora 
					{"Z2_EMAIL1"  ,""   		  ,Nil},; // Email 
					{"Z2_EMAIL2"  ,""   	      ,Nil},; // Email 
					{"Z2_EMAIL3"  ,""   		  ,Nil},; // Email 
		   			{"Z2_EMAIL4"  ,""   		  ,Nil},; // Email 
					{"Z2_EMAIL5"  ,""   		  ,Nil}}  // Email 
 		    fGravSZ2(aCab) 
			dbSelectArea("SM0")
			SM0->(MsSeek(paCab[1,2]))  
        Next
        
	End Transaction    
	
	dbSelectArea("SM0")
	SM0->(dbGoto(nRegSM0))	
	
	ApMsgInfo("Pedido de compras " + SC7->C7_NUM + " incluído com sucesso !!!")	   
	
	//Fausto Neto
	//Grava tabela SCR - Aprovadores do pedido
	fGravaSCR("1",paCab[1,2],SC7->C7_FILIAL,SC7->C7_NUM,nTotPed,SC7->C7_EMISSAO)	
//           cTipo,cEmpSCR,cFilSCR,cNumSCR,nTotSCR,dEmiSCR)	
	fGravaSCE(aSCE)
	
	//distribui os itens rateando o desconto e frete
	fDescFrete(SC7->C7_FILIAL,SC7->C7_NUMCOT)	                             
	
	//permite a rastreabilidade via tracker no pedido de vendas
	fAcertaIdent(SC7->C7_FILIAL,SC7->C7_NUMCOT)

//	MsAguarde( {|lEnd|fForSC8()},"Aguarde","Gravando Registros na Cotação...",.T.)
	
Else    
 
	cCGC:=Posicione("SA2",1,xFilial("SA2")+paCab[4,2]+paCab[5,2],'A2_CGC')
  
	cCod:=fGravSA2(paCab[1,2],paCab[4,2],paCab[5,2],cCGC,paCab[8,2])
                                                  
    If Len(cCod)> 6
 		lFlag:=fGravSC7(paCab,paItem,paTabSC1,pNumero,substr(cCod,1,6),substr(cCod,7,2)) 
 	Else	
		lFlag:=fGravSC7(paCab,paItem,paTabSC1,pNumero,cCod,paCab[5,2])
    Endif
Endif	      

RestArea(aAliasOLD)
Return(lRet)  


//------------------------------------------------ 
//* Grava na tabela SB2    
//------------------------------------------------ 
Static Function fGravSb2(pFilial,pProduto,pLocal,pQtd,pEmp) 
Local lRet:=.T.
Local aAliasOLD := GetArea()

dbSelectArea("SB2")
dbSetOrder(1)
If dbSeek(pFilial+pProduto+pLocal)
	IF RecLock("SB2",.F.)
		SB2->B2_SALPEDI :=SB2->B2_SALPEDI + pQtd 
		SB2->(MsUnlock())
	Endif		    
Else
	IF RecLock("SB2",.T.)
 		SB2->B2_FILIAL  :=pFilial
 		SB2->B2_COD     :=pProduto
 		SB2->B2_LOCAL   :=pLocal
		SB2->B2_SALPEDI :=pQtd 
		SB2->(MsUnlock())
	Endif		    
Endif

RestArea(aAliasOLD)
Return(lRet)  

//------------------------------------------------ 
//* Grava na tabela SC1 gravar Pedido   
//------------------------------------------------ 
Static Function fGravSC1(pFilial,pNumSC,pProduto,pItemSC,pPedido,pItemPed) 
Local lRet:=.T.
Local aAliasOLD := GetArea()
dbSelectArea("SC1")
dbSetOrder(2)  
If dbSeek(pFilial+pProduto+pNumSC+pItemSC,.T.)
	IF RecLock("SC1",.F.)        
		SC1->C1_PEDIDO  := pPedido  
		SC1->C1_ITEMPED := pItemPed
		SC1->C1_ZSTATUS := '5'
		SC1->(MsUnlock())
	Endif		    
Else
	dbSeek(pFilial+pProduto+pNumSC,.T.)
 	While !Eof() .And. SC1->C1_FILIAL=xFilial("SC1") .And. SC1->C1_NUM=pNumSC .And. SC1->C1_PRODUTO=pProduto
		If  Empty(C1_COTACAO)
			IF RecLock("SC1",.F.)        
				SC1->C1_PEDIDO  := pPedido  
				SC1->C1_ITEMPED := pItemPed
				SC1->C1_ZSTATUS := '5'
				SC1->(MsUnlock()) 
			Endif
		Endif
		dbSkip()		    
    Enddo
Endif

RestArea(aAliasOLD)
Return(lRet)  
                 

//---------------------------------- 
//* Grava na tabela SZ2 ocorrencias  
//--------------------------------- 
Static Function fGravSZ2(paCab) 
Local lRet:=.T.
Local aAliasOLD := GetArea()
dbSelectArea("SZ2") 
cNumOcor:= GetSxENum("SZ2","Z2_NUMERO") 
ConfirmSX8()
dbSelectArea("SZ2")
dbSetOrder(1)     
RecLock("SZ2",.T.)
	SZ2->Z2_FILIAL :=cFilial
	SZ2->Z2_NUMERO :=cNumOcor
	For nJ := 1 To Len(paCab)
		FieldPut( FieldPos( paCab[nJ,1]), paCab[nj,2] )
	Next nJ 
SZ2->(MsUnlock())
RestArea(aAliasOLD)
Return(lRet)  

//---------------------------------- 
//* Grava/Deletar na tabela SC8 o status
//  de fornecedores nao ganhos
//--------------------------------- 
Static Function fForSC8()  
Local aAliasOLD := GetArea()

If TCCanOpen(RetSqlName("SC8"))			
  TCSQLExec("UPDATE "+ RetSqlName("SC8") + " SET C8_ZSTATUS = '5' WHERE C8_ZGANHAD<>'S' AND C8_NUM='" + cCotacao+ "'")   
// TCSQLExec("DELETE FROM "+ RetSqlName("SC8") + " WHERE C8_ZGANHAD<>'S' AND C8_NUM='" + cCotacao+ "'")   
Endif 

RestArea(aAliasOLD)

Return(.T.) 


//------------------------------------------------ 
Static Function fSeleSC1(pCotacao)
// Rotina para buscar todos as solicitações 
// referente a uma cotação
//------------------------------------------------ 

Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()      
Local aWBrowAux := {}              
Local aEmpresa  := {}  
Local nRegSM0 	:= SM0->(Recno())
Local xE        := 0                
Local cFromSC1  := ""

aEmpresa:=u_fSIGAMAT()// Funcao para buscar as empresas

For xE:=1 to Len(aEmpresa)                                     

  	cEmpAux  := aEmpresa[xE,1]+"0"	
	cFromSC1 := "%"+"SC1"+cEmpAux+"%"
	cAliasQry := GetNextAlias()  

	BeginSql Alias cAliasQry
        
 		SELECT C1_ZEMP,C1_FILIAL,C1_FILENT,C1_ZFILFAT,C1_NUM,C1_PRODUTO,C1_QUANT,C1_ITEM,C1_CC,SC1.R_E_C_N_O_ AS RECSC1,C1_ZAPLIC
		FROM %Exp:cFromSC1% SC1                                                 
    		WHERE SC1.%notDel% 	AND   
			SC1.C1_ZSTATUS  IN (%Exp:'3'%)    AND
  			SC1.C1_COTACAO  IN (%Exp:pCotacao%) 
      	ORDER BY C1_ZFILFAT,C1_PRODUTO   
      	              		
  	EndSql   
 	(cAliasQry)->( DbGoTop() )
 	While !(cAliasQry)->(EOF())  
       Aadd(aWBrowAux,{;
        	(cAliasQry)->C1_ZEMP,;  			   // Empresa   	  1
        	(cAliasQry)->C1_FILIAL,;  				// Filial   	  2
        	(cAliasQry)->C1_ZFILFAT,;  			// Filial fatura  3
        	(cAliasQry)->C1_FILENT,;  				// Filial entrega 4
        	(cAliasQry)->C1_NUM,;     				// Numero SC  	  5
        	(cAliasQry)->C1_PRODUTO,;     		// Produto  	  6
        	(cAliasQry)->C1_QUANT,;     		   // Quantidade     7
        	(cAliasQry)->C1_ITEM,;     		   // Item           8
        	(cAliasQry)->C1_CC,;     		    	// Centro custo   9
        	Space(TamSX3("C8_FORNECE")[1]),;   	// Fornecedor     10
        	Space(TamSX3("C8_LOJA")[1]),;     	// Loja           11
        	Space(TamSX3("C8_COND")[1]),;     	// Condiçao pgto  12
        	0,;   										// Recno SC8      13
        	(cAliasQry)->RECSC1,;  				   // Recno          14
        	.F.,;     							  		// Flag           15
        	(cAliasQry)->C1_ZAPLIC,;				// Aplicação      16
        	 })
        (cAliasQry)->(dbskip())  
	EndDo
	
	(cAliasQry)->(dbCloseArea())

Next

RestArea(aAliasOLD)
Return(aWBrowAux)  


//------------------------------------------------ 
Static Function fGravsc7(paCab,paItem,paTabSC1,pNumero,pCod,pLoja)
// Rotina para grava o SC7 em outra filial
//------------------------------------------------ 
Local lRet      := .T.
Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()      
Local cQuery    := ""  
Local cFromSC7  := "" 
Local cFromSB2  := "" 
Local cRegno    := 0               
Local cUsrPed   := UsrRetName(RetCodUsr())
Local cCodPed   := RetCodUsr() 
Local nTotPed   := 0
   
pEmp:=paCab[1,2]+"0"      
                       
cFromSC7:="%"+"SC7"+pEmp+"%"


Begin Transaction   
	BeginSql Alias cAliasQry
  		SELECT isNull(max(R_E_C_N_O_),0) + 1  AS C7_NUMERO FROM %Exp:cFromSC7% SC7                                                  
	EndSql                                      
	cPedido:= STRZERO((cAliasQry)->C7_NUMERO,Len(SC7->C7_NUM))
	(cAliasQry)->(dbCloseArea())
 
	For xx:=1 To Len(paItem)
	         
		cITEMPed := StrZero(xx,Len(SC7->C7_ITEM))
		
	    // Cabeçalho
 		cQuery:="INSERT INTO SC7"+pEmp     
		cQuery+=" (C7_NUM,C7_EMISSAO,C7_FORNECE,C7_LOJA,C7_COND,C7_TIPO,"
		
	    // Itens
		cQuery+="C7_FILIAL,C7_ITEM,C7_PRODUTO,C7_DESCRI,C7_UM,C7_QUANT,"
		cQuery+="C7_PRECO,C7_TOTAL,C7_DATPRF,C7_FLUXO,C7_CONAPRO,"
		cQuery+="C7_NUMCOT,C7_NUMSC,C7_ITEMSC,C7_FILENT,C7_USER,C7_VALFRE,"
		cQuery+="C7_TPFRETE,C7_CC,C7_ZMARCOD,C7_LOCAL,C7_ZAPLIC,C7_VLDESC," //JSANTOS - 20150310 - Substituicao do campo C7_OBS pelo C7_ZMARCOD afim de liberar o campo OBS para receber de fato observação
		cQuery+="C7_IPI, C7_VALIPI, C7_BASEIPI, C7_PICM, C7_VALICM, C7_BASEICM, C7_APROV, C7_ZOBSADI, C7_OBS, R_E_C_N_O_)" //JSANTOS - 20150310 - Adicionado os campos C7_ZOBSADI e C7_OBS
		cQuery+=" values ( "    
	    
	    // Cabeçalho    
	    
		cQuery+="'"+cPedido+"','"+DTOS(paCab[3,2])+"','"+pCod+"','"+pLoja+"','"+paCab[6,2]+"','"+Alltrim(str(paCab[7,2]))+"','"
	    // Itens
		cQuery+=paItem[xx,01,2]+"','"+cITEMPed+"','"+paItem[xx,03,2]+"','"+paItem[xx,04,2]+"','"+paItem[xx,05,2]+"','"+Alltrim(str(paItem[xx,06,2]))+"','"
		cQuery+=Alltrim(STR(paItem[xx,07,2]))+"','"+Alltrim(STR(paItem[xx,08,2]))+"','"+DTOS(paItem[xx,09,2])+"','"+paItem[xx,10,2]+"','"+paItem[xx,11,2]+"','"
		cQuery+=paItem[xx,12,2]+"','"+paItem[xx,13,2]+"','"+paItem[xx,14,2]+"','"+paItem[xx,15,2]+"','"+paItem[xx,16,2]+"','"+Alltrim(STR(paItem[xx,17,2]))+"','"
		cQuery+=paItem[xx,18,2]+"','"+paItem[xx,19,2]+"','"+paItem[xx,20,2]+"','"+paItem[xx,21,2]+"','"+paItem[xx,24,2]+"','"+Alltrim(STR(paItem[xx,26,2]))+"','"
		cQuery+=Alltrim(STR(paItem[xx,27,2]))+"','"+Alltrim(STR(paItem[xx,28,2]))+"','"+Alltrim(STR(paItem[xx,29,2]))+"','"
		cQuery+=Alltrim(STR(paItem[xx,30,2]))+"','"+Alltrim(STR(paItem[xx,31,2]))+"','"+Alltrim(STR(paItem[xx,32,2]))+"','"+paItem[xx,33,2]+"','"+paItem[xx,34,2]+"','"+paItem[xx,35,2]+"',"				
		cQuery+="(SELECT isNull(max(R_E_C_N_O_),0) + 1 " 
		cQuery+=" FROM SC7"+pEmp+"))"
		TCREFRESH("SC7"+pEmp)
//		memowrite("C:\TEMP\cquerySC7.sql",cQuery)
		nRet:=TCSQLExec(cQuery)      
		
		IF nRet<> 0
			msgstop("Ocorreu um erro com codigo "+Alltrim(str(nret))+" Inclusão da tabela SC7.")
			erro:=.T.
			lRet:=.F.
		//else
		   //	ApMsgInfo("Pedido de Compras " + cPedido + " gerado com sucesso !!!")
		endif 
		
		nTotPed := nTotPed + paItem[xx,08,2]      
                                                      
 		IF Empty(fSeleSB2(paCab[1,2],paItem[xx,01,2],paItem[xx,03,2],paItem[xx,21,2],paItem[xx,06,2]) )
            fINSSb2(paCab[1,2],paItem[xx,01,2],paItem[xx,03,2],paItem[xx,21,2],paItem[xx,06,2]) //Atualiza tabela SB2  B2_SALPEDI
 		Else       
        	fUPDSb2(paCab[1,2],paItem[xx,01,2],paItem[xx,03,2],paItem[xx,21,2],paItem[xx,06,2]) //Atualiza tabela SB2  B2_SALPEDI 
        Endif	
        
		//fUPDSC1(paCab[1,2],paItem[xx,01,2],paItem[xx,12,2],paItem[xx,03,2],cPedido,cITEMPed,paItem[xx,02,2],paItem[xx,13,2],paItem[xx,14,2]) // Atualiza a tabela de solicitaçao de compras
		//fUPDSC1(paCab[1,2],paCab[9,2],paItem[xx,12,2],paItem[xx,03,2],cPedido,cITEMPed,paItem[xx,02,2],paItem[xx,13,2],paItem[xx,14,2]) // Atualiza a tabela de solicitaçao de compras
		fUPDSC1(paCab[1,2],paItem[xx,22,2],paItem[xx,12,2],paItem[xx,03,2],cPedido,cITEMPed,paItem[xx,06,2],paItem[xx,13,2],paItem[xx,14,2]) // Atualiza a tabela de solicitaçao de compras
		
		//RECEBIMENTO
		//fUPDSC1(pEmp,pFili,pCotacao,pProduto,pPedido,pItemPed,pQtd,pNumSC,pItemSC) 
		
 
		dbSelectArea("SC8")   // Grava na tabela de cotação o numero do pedido de compra   
		dbSetOrder(3)      
		dbSeek(xFilial("SC8")+paItem[xx,12,2]+paItem[xx,03,2]+paCab[4,2]+paCab[5,2],.T.) 
		While !Eof() .And. SC8->C8_NUM=paItem[xx,12,2] .And. SC8->C8_PRODUTO=paItem[xx,03,2] .And. SC8->C8_FORNECE=paCab[4,2] .And. SC8->C8_LOJA = paCab[5,2]
			If  SC8->C8_ZGANHAD='S'  //.And. Empty(SC8->C8_NUMOC)                                                                                                  
			  	IF RecLock("SC8",.F.)
					SC8->C8_ZSTATUS := "5"
					SC8->C8_NUMPED  := cPedido 
					SC8->C8_ITEMPED := cITEMPed 
					SC8->(MsUnlock())
				Endif 
			Endif 
			dbSkip()	
	    Enddo

		aCab:={     {"Z2_CODIGO"  ,"004"  	      ,Nil},; // Codigo da ocorrencias
					{"Z2_NUMSC"   ,paItem[xx,01,2],Nil},; // Numero da solicitacao
					{"Z2_ITEMSC"  ,paItem[xx,14,2],Nil},; // Item da solicitacao
					{"Z2_NUMCOT"  ,cCotacao       ,Nil},; // Numero da cotacao
					{"Z2_PRODUTO" ,paItem[xx,13,2],Nil},; // Produto
					{"Z2_EMP"     ,paItem[xx,06,2],Nil},; // Empresa
					{"Z2_CODUSR"  ,cCodPed   	  ,Nil},; // Condicao do usuario
					{"Z2_NOMEUSR" ,cUsrPed  	  ,Nil},; // Nome do usuario
					{"Z2_MOTIVO"  ,"PEDIDO GERADO",Nil},; // Motivo
					{"Z2_DATA"    ,DATE()		  ,Nil},; // Data 
					{"Z2_HORA"    ,Time() 		  ,Nil},; // Hora 
					{"Z2_EMAIL1"  ,""   		  ,Nil},; // Email 
					{"Z2_EMAIL2"  ,""   	      ,Nil},; // Email 
					{"Z2_EMAIL3"  ,""   		  ,Nil},; // Email 
		   			{"Z2_EMAIL4"  ,""   		  ,Nil},; // Email 
					{"Z2_EMAIL5"  ,""   		  ,Nil}}  // Email 
 	 //	fGravSZ2(aCab) 
    Next
	
//MsgStop("teste1")
//	MsAguarde( {|lEnd|fForSC8()},"Aguarde","Gravando Registros na Cotação...",.T.)
	
	ApMsgInfo("Pedido de compras " + cPedido + " incluído com sucesso !!!")	   

	//Fausto Neto
	//Grava tabela SCR - Aprovadores do pedido
	fGravaSCR("2",pEmp,paCab[8,2],cPedido,nTotPed,paCab[3,2])		

End Transaction 

RestArea(aAliasOLD)
Return(lRet)
          
//---------------------------------- 
//* Grava na tabela SB2 o status
//  de fornecedores nao ganhos
//--------------------------------- 
//fGravSb2(SC7->C7_ZEMP,SC7->C7_FILIAL,SC7->C7_PRODUTO,SC7->C7_LOCAL,SC7->C7_QUANT) //Atualiza tabela SB2  B2_SALPEDI

Static Function fUPDSB2(pEmp,pFili,pProduto,pLocal,pQtd)  

Local aAliasOLD := GetArea()  
Local _cSql :="" 
cEmpres	:=pEmp+"0" 
pProduto:=Alltrim(pProduto)
Begin Transaction             
	  _cSql := "UPDATE SB2" + cEmpres + " SET B2_SALPEDI = B2_SALPEDI +  '"+Alltrim(str(pQtd))+"' WHERE D_E_L_E_T_= '' AND  B2_FILIAL = '" + pFili + "' AND B2_COD = '" + Alltrim(pProduto) + "' AND B2_LOCAL = '" + Alltrim(pLocal) + "'"  
//		memowrite("C:\TEMP\cSqlSB2.sql",_cSql)
	  _Retorno := TCSQLExec(_cSql)
End Transaction	      

If _Retorno < 0 
	_GetErroTop := TCSQLError()							
	MsgStop("Error ocorreram na execucao da Query no banco de dados"+_cSql,"Erro","Alert")
Endif 

RestArea(aAliasOLD)

Return(.T.) 

//---------------------------------- 
//* Grava na tabela SC1 o status
//  de fornecedores nao ganhos
//--------------------------------- 
//fGravSC1(SC7->C7_FILIAL,SC7->C7_PRODUTO,SC7->C7_LOCAL,SC7->C7_QUANT,SC7->C7_ZEMP) //Atualiza tabela SB2  B2_SALPEDI
Static Function fUPDSC1(pEmp,pFili,pCotacao,pProduto,pPedido,pItemPed,pQtd,pNumSC,pItemSC,pFornece,pLoja)  

Local aAliasOLD := GetArea()  
Local _cSql :=""              
Local cIdent := Space(4)

cEmpres	:=pEmp+"0" 
pProduto:=Alltrim(pProduto)
Begin Transaction             
	  //_cSql := "UPDATE SC1" + cEmpres + " SET C1_PEDIDO =  '"+pPedido+"', C1_ITEMPED =  '"+pItemPed+"', C1_ZSTATUS =  '5'  WHERE D_E_L_E_T_= '' AND  C1_FILIAL = '" + pFili + "' AND C1_PRODUTO = '" + Alltrim(pProduto) + "' AND C1_COTACAO = '" + Alltrim(pCotacao) + "'"      
	  //_cSql := "UPDATE SC1" + cEmpres + " SET C1_PEDIDO =  '"+pPedido+"', C1_ITEMPED =  '"+pItemPed+"', C1_ZSTATUS =  '5'  WHERE D_E_L_E_T_= '' AND  C1_FILIAL = '" + pFili + "' AND C1_NUM = '" + Alltrim(pNumSC) + "' AND C1_ITEM = '" + Alltrim(pItemSC) + "'"// AND C1_COTACAO = '" + Alltrim(pCotacao) + "'"      
	  _cSql := "UPDATE SC1" + cEmpres + " SET C1_FORNECE = '" + pFornece + "', C1_LOJA = '" + pLoja + "', C1_PEDIDO =  '"+pPedido+"', C1_ITEMPED =  '"+pItemPed+"', C1_ZSTATUS =  '5', C1_QUJE = '" + Alltrim(Str(pQtd)) + "' WHERE D_E_L_E_T_= '' AND  C1_FILIAL = '" + pFili + "' AND C1_NUM = '" + Alltrim(pNumSC) + "' AND C1_ITEM = '" + Alltrim(pItemSC) + "'"// AND C1_COTACAO = '" + Alltrim(pCotacao) + "'"      	  
	  //memowrite("C:\TEMP\cSqlSC1.sql",_cSql)
	  _Retorno := TCSQLExec(_cSql)
End Transaction	      

If _Retorno < 0 
	_GetErroTop := TCSQLError()							
	MsgStop("Error ocorreram na execucao da Query no banco de dados"+_cSql,"Erro","Alert")
Endif 
      
RestArea(aAliasOLD)

Return(.T.) 
             
//------------------------------------------------ 
Static Function fGravSA2(pEmp,pCOD,pLoja,pCGC,pFilFat)
// Rotina para grava o SA2 em outra filial
//------------------------------------------------ 
Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()      
Local cQuery    :=""  
Local cFromSA2  :="" 
Local cCOD      :=""          
pEmp:=pEmp+"0" 
                        
	cFromSA2:="%"+"SA2"+pEmp+"%"
	BeginSql Alias cAliasQry
  		SELECT A2_COD,A2_LOJA 
  		FROM %Exp:cFromSA2% SA2
 		WHERE SA2.%notDel% 	AND   
			SA2.A2_CGC  IN (%Exp:pCGC%) 
	EndSql 
	cCOD:= (cAliasQry)->A2_COD+(cAliasQry)->A2_LOJA
	(cAliasQry)->(dbCloseArea())
	
    If Empty(cCOD)
    	cAliasQry := GetNextAlias()      
	 	BeginSql Alias cAliasQry
	  		SELECT max(A2_COD)   AS A2_CODIGO
	 		FROM %Exp:cFromSA2%  SA2
			WHERE SA2.%notDel% 	AND   
			SUBSTRING(SA2.A2_COD,1,1) IN (%Exp:'1'%,%Exp:'2'%,%Exp:'3'%,%Exp:'4'%,%Exp:'5'%,%Exp:'6'%,%Exp:'7'%,%Exp:'8'%,%Exp:'9'%,%Exp:'0'%) 
		EndSql 
		cCOD:= strzero(Val((cAliasQry)->A2_CODIGO) +1,6)
		(cAliasQry)->(dbCloseArea())   
		Begin Transaction   

		 	cQuery:="INSERT INTO SA2"+pEmp     
			cQuery+="(A2_FILIAL,A2_COD,A2_LOJA,A2_CGC,A2_NOME,A2_NATUREZ,A2_END,A2_NR_END,A2_BAIRRO,A2_EST,"
			cQuery+="A2_CODMUN,A2_ESTADO,A2_MUN,A2_CEP,A2_TIPO,A2_PFISICA,A2_DDI,A2_DDD,A2_TEL,A2_FAX,"
			cQuery+="A2_INSCR,A2_CONTATO,A2_BANCO,A2_AGENCIA,A2_COND,A2_PAIS,A2_EMAIL,A2_HPAGE,A2_CODPAIS,"
			cQuery+="A2_MSBLQL,A2_RECPIS,A2_RECCOFI,A2_RECCSLL,R_E_C_N_O_) "    
			cQuery+=" SELECT '"+SubStr(pFilFat,1,4)+"','"
			cQuery+=cCOD           +"','"+SA2->A2_LOJA   +"','"+SA2->A2_CGC    +"','"+SA2->A2_NOME   +"','"+SA2->A2_NATUREZ+"','"+SA2->A2_END    +"','"+SA2->A2_NR_END+"','"+SA2->A2_BAIRRO+"','"+SA2->A2_EST    +"','"
			cQuery+=SA2->A2_CODMUN +"','"+SA2->A2_ESTADO +"','"+SA2->A2_MUN    +"','"+SA2->A2_CEP    +"','"+SA2->A2_TIPO   +"','"+SA2->A2_PFISICA+"','"+SA2->A2_DDI   +"','"+SA2->A2_DDD   +"','"+SA2->A2_TEL    +"','"
			cQuery+=SA2->A2_FAX    +"','"+SA2->A2_INSCR  +"','"+SA2->A2_CONTATO+"','"+SA2->A2_BANCO  +"','"+SA2->A2_AGENCIA+"','"+SA2->A2_COND   +"','"+SA2->A2_PAIS   +"','"+SA2->A2_EMAIL +"','"+SA2->A2_HPAGE +"','"
			cQuery+=SA2->A2_CODPAIS+"','"+SA2->A2_MSBLQL +"','"+SA2->A2_RECPIS +"','"+SA2->A2_RECCOFI+"','"+SA2->A2_RECCSLL+"',"
			cQuery+="(SELECT isNull(max(R_E_C_N_O_),0) + 1" 
			cQuery+=" FROM SA2"+pEmp+" SA21 )"
			cQuery+=" FROM "+RetSqlName("SA2")+" SA2"
			cQuery+=" WHERE A2_COD  = '"+pCOD+"'"  
			cQuery+=" AND   A2_LOJA = '"+pLoja+"'"
			TCREFRESH("SA2"+pEmp)
			memowrite("C:\temp\cquerySA2.sql",cQuery)
			nRet:=TCSQLExec(cQuery)
			IF nRet<> 0
				msgstop("Ocorreu um erro com codigo "+Alltrim(str(nret))+" na copia do Fornecedor SA2, não foi feita.")
				erro:=.T.
			Endif
		End Transaction 
	Endif
		

RestArea(aAliasOLD)
Return(cCOD)
//------------------------------------------------ 
Static Function fSeleSB2(pEmp,pFilFat,pProduto,pLocal)
//------------------------------------------------ 
Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()      
Local cFromSB2  :="%"+"SB2"+pEmp+"0%"    
Local cCOD      :=""
   cAliasQry := GetNextAlias()      
 	BeginSql Alias cAliasQry
 		SELECT B2_COD  
 		FROM %Exp:cFromSB2% SB2  
 		WHERE SB2.%notDel% 	AND   
			SB2.B2_FILIAL = (%Exp:pFilFat%)  AND
			SB2.B2_COD    = (%Exp:pProduto%) AND
			SB2.B2_LOCAL  = (%Exp:pLocal%)   
	EndSql   
 	cCOD:= (cAliasQry)->B2_COD
	(cAliasQry)->(dbCloseArea())
Return(cCOD)   


//---------------------------------- 
//* Grava na tabela SB2 INCLUSAO EMPRESA
//--------------------------------- 

Static Function fINSSB2(pEmp,pFili,pProduto,pLocal,pQtd)  

Local aAliasOLD := GetArea()  
Local _cSql :="" 
cEmpres	:=pEmp+"0" 
pProduto:=Alltrim(pProduto)
Begin Transaction             
		cQuery:="INSERT INTO SB2"+cEmpres     
		cQuery+=" (B2_FILIAL,B2_COD,B2_LOCAL,B2_SALPEDI,R_E_C_N_O_)"
		cQuery+="values( '"    
		cQuery+=pFili+"','"+pProduto +"','"+pLocal+"','"+Alltrim(STR(pQtd,12,5))+"',(SELECT isNull(max(R_E_C_N_O_),0) + 1 " 
		cQuery+=" FROM SB2"+cEmpres+"))"
		TCREFRESH("SB2"+cEmpres)
		memowrite("C:\TEMP\cquerySB2.sql",cQuery)
		nRet:=TCSQLExec(cQuery)
		IF nRet<> 0
			msgstop("Ocorreu um erro com codigo "+Alltrim(str(nret))+" Inclusão da tabela SB2.")
			erro:=.T.
			lRet:=.F.
		endif       
End Transaction	      

RestArea(aAliasOLD)

Return(.T.) 

************************************
Static Function fGravaSCR(cTipo,cEmpSCR,cFilSCR,cNumSCR,nTotSCR,dEmiSCR)
************************************
* Grava os aprovadores do PC
* 

Local cQuerySY1 := ""                          
Local cQuerySAL := ""
Local cQuerySCR := ""
Local cCodAUsr  := RetCodUsr()

if cTipo == "1" // Empresa Local
	//Pega o grupo de aprovador pelo comprador corrente
	dbSelectArea("SY1")
	dbSetOrder(3)
	if dbSeek(SubStr(cFilSCR,1,4)+Space(2)+cCodAUsr)
		cGrpAprov := ""
		cGrpAprov := SY1->Y1_GRAPROV
		dbSelectArea("SAL")
		dbSetOrder(1)
		//if dbSeek(cFilSCR+cGrpAprov)
		if dbSeek(xFilial("SAL")+cGrpAprov)
			//While !Eof("SAL") .And. Alltrim(cFilSCR) == Alltrim(SAL->AL_FILIAL) .And. Alltrim(SAL->AL_COD) == Alltrim(cGrpAprov)
			While !Eof("SAL") .And. xFilial("SAL") == SAL->AL_FILIAL .And. Alltrim(SAL->AL_COD) == Alltrim(cGrpAprov)
				
				//Verifica se o limite do aprovador esta dentro do limite do pedido
				dbSelectArea("SAK")
				dbSetOrder(1)
				if dbSeek(cFilSCR+SAL->AL_APROV)
					if nTotSCR < SAK->AK_LIMMIN .And. nTotSCR > SAK->AK_LIMMAX
						dbSelectArea("SAL")
						dbSkip()
						Loop
					endif
				endif
				
				if RecLock("SCR",.T.)
					Replace SCR->CR_FILIAL  With cFilSCR
					Replace SCR->CR_NUM     With cNumSCR
					Replace SCR->CR_TIPO    With "PC"
					Replace SCR->CR_USER    With SAL->AL_USER
					Replace SCR->CR_APROV   With SAL->AL_APROV
					Replace SCR->CR_NIVEL   With SAL->AL_NIVEL
					Replace SCR->CR_STATUS  With Iif(SAL->AL_NIVEL=="01","02","01")				
					Replace SCR->CR_TOTAL   With nTotSCR
					Replace SCR->CR_EMISSAO With dEmiSCR
					Replace SCR->CR_MOEDA   With 1
					Replace SCR->CR_TXMOEDA With 1
					MsUnLock()
				endif            
				
				dbSelectArea("SAL")
				dbSkip()
				
			enddo
		endif
	endif
elseif cTipo == "2" // Empresa outra

   	//cQuerySY1 := ""
	//cQuerySY1 := "SELECT * FROM SY1" + cEmpSCR + " SY1 "
	//cQuerySY1 += " WHERE Y1_FILIAL = '" + cFilSCR+ "' AND Y1_USER = '" + cCodAUsr + "'"
	//cQuerySY1 += " AND D_E_L_E_T_ <> '*'"
	
	//cQuerySY1 := ChangeQuery(cQuerySY1)
	
	//dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySY1),"TRBSY1",.T.,.T.) 	
	                
   	//dbSelectArea("TRBSY1")
	//dbGoTop()
	
   //	if !Eof("TRBSY1")     
	
		//cGrpAprov := ""
	   //	cGrpAprov := TRBSY1->Y1_GRAPROV   
		
		cQuerySAL := ""
		cQuerySAL += "SELECT * FROM SAL" + cEmpSCR + " SAL, SAK" + cEmpSCR + " SAK"
		cQuerySAL += " WHERE AK_FILIAL = AL_FILIAL AND AL_APROV = AK_COD AND AK_USER = AL_USER"		
		//cQuerySAL += " AND AL_FILIAL = '" + SubStr(cFilSCR,1,4) + "'"
		cQuerySAL += " AND AL_FILIAL = '" + xFilial("SAL") + "'"
		//cQuerySAL += " AND AL_FILIAL = '" + cFilSCR+ "' AND AL_COD = '" + cGrpAprov + "'"
		cQuerySAL += " AND '" + Alltrim(Str(nTotSCR)) + "' >= AK_LIMMIN AND '" + Alltrim(Str(nTotSCR)) + "' <= AK_LIMMAX"
		cQuerySAL += " AND SAL.D_E_L_E_T_ <> '*' AND SAK.D_E_L_E_T_ <> '*'"
		cQuerySAL += " ORDER BY AL_ITEM"
		
		cQuerySAL := ChangeQuery(cQuerySAL)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySAL),"TRBSAL",.T.,.T.) 		
		
		dbSelectArea("TRBSAL")
		dbGoTop()
		if !Eof("TRBSAL")
			While !Eof("TRBSAL")
			
				Begin Transaction             
				
				cQuerySCR := "INSERT INTO SCR"+cEmpSCR     
				cQuerySCR += " (CR_FILIAL,CR_NUM,CR_TIPO,CR_USER,CR_APROV,CR_NIVEL,CR_STATUS,CR_TOTAL,CR_EMISSAO,CR_MOEDA,CR_TXMOEDA,R_E_C_N_O_)"
				cQuerySCR += " VALUES( '"    
				cQuerySCR += cFilSCR+"','"+cNumSCR +"','PC','"+TRBSAL->AL_USER+"','"+TRBSAL->AL_APROV+"','"+TRBSAL->AL_NIVEL+"','02','"+Alltrim(STR(nTotSCR,12,5))+"','"+dTos(dEmiSCR)+"','"+Alltrim(STR(1))+"','"+Alltrim(STR(1))+"',(SELECT isNull(max(R_E_C_N_O_),0) + 1 FROM SCR"+cEmpSCR+"))" 
				
				TCREFRESH("SB2"+cEmpSCR)
				
//				memowrite("C:\cquerySCR.sql",cQuerySCR)
				
				nRet := TCSQLExec(cQuerySCR)
				
				if nRet <> 0
					msgstop("Ocorreu um erro com codigo "+Alltrim(str(nret))+" Inclusão da tabela SCR.")
					erro:=.T.
					lRet:=.F.
				endif       
				
				End Transaction
				
				dbSelectArea("TRBSAL")
				dbSkip()
			enddo
			
		endif

		dbSelectArea("TRBSAL")
		dbCloseArea("TRBSAL")
					
	
	//endif 
	
	//dbSelectArea("TRBSY1")
	//dbCloseArea("TRBSY1")

endif                    

return

************************************
Static Function fTodos()
************************************
*
* 
Local nTodos := 1

For nTodos := 1 to Len(aWBrowse18)
	aWBrowse18[nTodos,1] := .T.
Next                            

return

************************************
Static Function fDesmarca()
************************************
*
* 
Local nTodos := 1                                            

For nTodos := 1 to Len(aWBrowse18)
	aWBrowse18[nTodos,1] := .F.
Next                            

return



************************************
Static Function fGravaSCE(aSCE)
************************************
* Grava cotações encerradas
*    

Local aArea := GetArea()
Local k := 0
Local lModoUpd := .F.
Local aAreaSC8 := SC8->(GetArea())

dbSelectArea("SC8")
dbSetOrder(3)

dbSelectArea("SCE")
dbSetOrder(1)

For k := 1 To Len(aSCE)
	
   dbSelectArea("SC8")
   dbSeek(aSCE[k,1] + aSCE[k,2] + aSCE[k,4] + aSCE[k,5] + aSCE[k,6])
   
	dbSelectArea("SCE")
	dbSeek(aSCE[k,1] + aSCE[k,2] + aSCE[K,3] + aSCE[k,4] )
	If Found()
		lModoUpd := .F.
	Else
		lModoUpd := .T.
	EndIf
	
	RecLock("SCE",lModoUpd)
	
	If lModoUpd	
		SCE->CE_FILIAL := Left(aSCE[k,1],6) //JSANTOS - 02/03/2015 - ALTERANDO PARA GRAVAR CAMPO FILIAL EXCLUSIVO
		SCE->CE_NUMCOT := aSCE[k,2]
		SCE->CE_ITEMCOT := SC8->C8_ITEM
		SCE->CE_PRODUTO := aSCE[k,4]
		SCE->CE_FORNECE := aSCE[k,5]
		SCE->CE_LOJA    := aSCE[k,6]
	EndIf
	
	SCE->CE_NUMPRO  := aSCE[k,7]
	SCE->CE_QUANT   := aSCE[k,8]
	SCE->CE_ENTREGA := aSCE[k,9]                          
	
	MsUnlock()
Next                  

RestArea(aAreaSC8)
RestArea(aArea)

Return


************************************
Static Function fAcertaIdent(pFilial,pNumCot)
************************************
* Acerta campo _Ident para rastro do pedido
*    

Local cFilCota := pFilial
Local cCotacao := pNumCot
Local lOk := .T.

dbSelectArea("SC1")
dbSetOrder(1)
	
dbSelectArea("SC8")
dbSetOrder(1)
dbSeek(cFilCota + cCotacao)
	
Do While !Eof() .And. C8_FILIAL = cFilCota .And. C8_NUM = cCotacao
	lOk := SC8->C8_ZGANHAD = 'S'
	
//	If !lOk
//		dbSelectArea("SC8")
//		dbSkip()
//		Loop
//	EndIf	
	
	cFilSc := SC8->C8_FILIAL
	cNumSC := SC8->C8_NUMSC
	cItemSC:= SC8->C8_ITEMSC
		
	If RecLock("SC8",.f.)
		SC8->C8_IDENT := If(Alltrim(SC8->C8_ITEM) = '999','0001',SC8->C8_ITEM)
		SC8->C8_ITEMSC := If(Alltrim(SC8->C8_ITEMSC) = '999','0001',SC8->C8_ITEMSC) 
		MsUnlock()
	EndIf  
		
	dbSelectArea("SC1")
	dbSeek(cFilSC + cNumSC + cItemSC)
		
	If Found()
		If RecLock("SC1",.f.)
			SC1->C1_IDENT := SC8->C8_IDENT  			
			MsUnlock()
		EndIf
	EndIf	
	
	dbSelectArea("SC8")
	dbSkip()
EndDo
		
Return


************************************
Static Function fDescFrete(pFilial,pNumCot)
************************************
* modifica o frete e desconto caso tenham sido aglutinado
*    

Local cFilCota := pFilial
Local cCotacao := pNumCot
Local lOk := .T.  
Local aAreaSC7 := SC7->(GetArea())

dbSelectArea("SC1")
dbSetOrder(1)

dbSelectArea("SC7")
dbSetOrder(4)
	
dbSelectArea("SC8")
dbSetOrder(1)
dbSeek(cFilCota + cCotacao)
	
Do While !Eof() .And. C8_FILIAL = cFilCota .And. C8_NUM = cCotacao
	lOk := SC8->C8_ZGANHAD = 'S'
//	lOk := lOk .And. Alltrim(SC8->C8_ITEM) = '999'  //Houve aglutinação

	If !lOk
		dbSelectArea("SC8")
		dbSkip()
		Loop
	EndIf	

	cProduto:= SC8->C8_PRODUTO
	cFilPed := SC8->C8_FILIAL                    
	cNumPed := SC8->C8_NUMPED

	dbSelectArea("SC7")
	dbSeek(cFilPed + cProduto + cNumPed)
	Do While !Eof() .And. SC7->C7_FILIAL == cFilPed .And. SC7->C7_PRODUTO == cProduto .And. SC7->C7_NUM == cNumPed                                 

		dbSelectArea("SC1")
		dbSeek(SC7->C7_FILIAL + SC7->C7_NUMSC + SC7->C7_ITEMSC)
		If Found()
			If RecLock("SC7",.F.)
				SC7->C7_ZOBSADI := SC1->C1_ZOBSADI
				MsUnlock()
			EndIf		
		EndIf
		
		dbSelectArea("SC7")
		dbSkip()
	EndDo


	lOk := (SC8->C8_VLDESC <> 0 .OR. SC8->C8_VALFRE <> 0)
	
	If !lOk
		dbSelectArea("SC8")
		dbSkip()
		Loop
	EndIf	

	nFrete  := SC8->C8_VALFRE
	nVlDesc := SC8->C8_VLDESC
	nCont   := 0	
	nTotPed := 0
	
	dbSelectArea("SC7")
	dbSeek(cFilPed + cProduto + cNumPed)                                                                                    
	Do While !Eof() .And. SC7->C7_FILIAL == cFilPed .And. SC7->C7_PRODUTO == cProduto .And. SC7->C7_NUM == cNumPed                                 
		nCont ++ 
		
		nTotPed += SC7->C7_TOTAL

		dbSelectArea("SC7")
		dbSkip()
	EndDo
	
	nTotDesc := 0            
	nTotFret := 0
	nUltReg  := 0
	
	dbSelectArea("SC7")
	dbSeek(cFilPed + cProduto + cNumPed)                                                                                    
	Do While !Eof() .And. SC7->C7_FILIAL == cFilPed .And. SC7->C7_PRODUTO == cProduto .And. SC7->C7_NUM == cNumPed                                 
		nPercent := SC7->C7_TOTAL / nTotPed
		nDescItem := Round(nPercent * nVlDesc,2)
		nFretItem := Round(nPercent * nFrete ,2)
		
		nTotDesc  += nDescItem
		nTotFret  += nFretItem
		
		If RecLock("SC7",.F.)
			SC7->C7_VLDESC := nDescItem
			SC7->C7_VALFRE := nFretItem
			MsUnlock()
		EndIf
		
		nUltReg := Recno()
		
		dbSelectArea("SC1")
		dbSeek(SC7->C7_FILIAL + SC7->C7_NUMSC + SC7->C7_ITEMSC)
		If Found()
			If RecLock("SC7",.F.)
				SC7->C7_ZOBSADI := SC1->C1_ZOBSADI
				MsUnlock()
			EndIf		
		EndIf
		
		dbSelectArea("SC7")
		dbSkip()
	EndDo
	
	nDifDesc := nVlDesc - nTotDesc
	nDifFret := nFrete - nTotFret
		
	If nDifDesc <> 0 .Or. nDifFret <> 0
		dbGoTo(nUltReg)

		If RecLock("SC7",.F.)
			SC7->C7_VLDESC := SC7->C7_VLDESC + nDifDesc
			SC7->C7_VALFRE := SC7->C7_VALFRE + nDifFret
			MsUnlock()
		EndIf
	EndIf
	
	dbSelectArea("SC8")
	dbSkip()
EndDo
		
RestArea(aAreaSC7)

Return
