#Include "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} AFATP01
Description                                                     
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Jose Antonio (AMM)                                            
@since 05/12/2012                                                   
/*/                                                             
***************************************************
User Function AFATP01(cAlias, nReg, nOpc)          
***************************************************

Local oAplic
Local oCC
Local oClassific
Local oDescCC
Local cDescCC := CriaVar("CTT_DESC01")
Local oDtNecess
Local oEmissao
Local oFilEnt
Local oFilFat
Local oFont1 := TFont():New("Arial",,016,,.T.,,,,,.F.,.F.)
Local oFont2 := TFont():New("Arial",,017,,.F.,,,,,.F.,.F.)
Local oFont3 := TFont():New("Arial",,022,,.T.,,,,,.F.,.F.)
Local oGroup1
Local oGroup2
Local oNumero
Local oObs
Local oSay1
Local oSay10
Local oSay11
Local oSay12
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
Local oSolicit
Private cSolicit:= CriaVar("C1_SOLICIT")
Private cAplic  := CriaVar("C1_ZAPLIC")
Private cNumero := CriaVar("C1_NUM")
Private cFilSC1 := CriaVar("C1_FILIAL")
Private cObs    := CriaVar("C1_OBS")
Private cCC     := CriaVar("C1_CC")
Private cFilFat := CriaVar("C1_ZFILFAT")
Private cFilEnt := CriaVar("C1_FILENT") 
Private cStatus := CriaVar("C1_ZSTATUS")
Private cNumCot := CriaVar("C1_COTACAO")
Private dDtNecess  := Date()
Private dEmissao   := Date()
Private nClassific := "1"  
Private aRegistro  :={}
Private nOpcao     :=nOpc 

PRIVATE lGatilha   	:= .T.  // Para preencher aCols em funcoes chamadas da validacao (X3_VALID)    
PRIVATE l110Auto   	:= .T. //(xAutoCab <> Nil .and. xAutoItens <> Nil)
PRIVATE aAutoCab	:= {}
PRIVATE aAutoItens	:= {}  
PRIVATE lGrade      := .F.  
PRIVATE aRatAFG     := {}
Private aHdrAFG		:= {}
Private aResolu     := getScreenRes()

Static oDlg    



If nOpcao == 3                         
  //	cNumero := GetSxENum("SC1","C1_NUM") 
	//cNumero:= Soma1(cNumero)
	//cSolicit:=UsrRetName(RetCodUsr())      
	
	cFilFat := xFilial("SC1")
	cFilEnt := xFilial("SC1")	
	
	
Else 
 	cNumero   := SC1->C1_NUM
 	cFilSC1   := SC1->C1_FILIAL
	cSolicit  := SC1->C1_SOLICIT  
	dEmissao  := SC1->C1_EMISSAO 
	cFilFat   := SC1->C1_ZFILFAT
	cFilEnt   := SC1->C1_FILENT
	cCC       := SC1->C1_CC 
	cDescCC   := Posicione("CTT",1,xFilial("CTT")+cCC,"CTT_DESC01")
	dDtNecess := SC1->C1_DATPRF
	cAplic    := SC1->C1_ZAPLIC
	cObs      := SC1->C1_OBS
   nClassific:= SC1->C1_ZCLASSI   
   cStatus   := SC1->C1_ZSTATUS      
   cNumCot   := SC1->C1_COTACAO
Endif     
             
If !(SC1->C1_ZSTATUS  $'124') .And. nOpcao == 4
	//MsgAlert("Solicitação de Compra não pode ser Alterada!!!","Atenção")
	Help("",1,"GETOBG",,"Solicitação de Compra não pode ser Alterada!!!",2) 
	Return 
ElseIf SC1->C1_ZSTATUS <>'1' .And. nOpcao == 5
	//MsgAlert("Solicitação de Compra não pode ser Excluida!!!","Atenção")
	Help("",1,"GETOBG",,"Solicitação de Compra não pode ser Excluida!!!",2) 
	Return 
Endif 

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

  DEFINE MSDIALOG oDlg TITLE "Solicitações de Compras " FROM aSize[7],0 TO aSize[6],aSize[5] COLORS 200, 16777215 PIXEL
  
  If(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080
    @ 001, 433 SAY oSay7 PROMPT "Solicitação de Compras" SIZE 099, 011 OF oDlg FONT oFont3 COLORS 32768, 16757683 PIXEL
    @ 013, 002 GROUP oGroup1 TO 067, 955 OF oDlg COLOR 0, 16757683 PIXEL 
    @ 082, 002 GROUP oGroup2 TO 420, 955 OF oDlg COLOR 0, 16777215 PIXEL 
     DEFINE SBUTTON oSButton2 FROM 425, 865 TYPE 02 ACTION oDlg:END() OF oDlg ENABLE
    oSButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )    
  Else
    @ 001, 257 SAY oSay7 PROMPT "Solicitação de Compras" SIZE 099, 011 OF oDlg FONT oFont3 COLORS 32768, 16757683 PIXEL
    @ 013, 002 GROUP oGroup1 TO 067, 675 OF oDlg COLOR 0, 16757683 PIXEL
    @ 082, 002 GROUP oGroup2 TO 256, 676 OF oDlg COLOR 0, 16777215 PIXEL
     DEFINE SBUTTON oSButton2 FROM 266, 615 TYPE 02 ACTION oDlg:END() OF oDlg ENABLE
    oSButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )    
  Endif                                                 
    
    @ 022, 033 SAY oSay1 PROMPT "Número" SIZE 025, 007 OF oDlg FONT oFont1 COLORS 8388608, 16777215 PIXEL 
    @ 020, 060 MSGET oNumero VAR cNumero SIZE 042, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 READONLY PIXEL 
    
    @ 022, 120 SAY oSay2 PROMPT "Solicitante" SIZE 032, 007 OF oDlg FONT oFont1 COLORS 8388608, 16777215 PIXEL
    @ 020, 155 MSGET oSolicit VAR cSolicit SIZE 095, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 READONLY PIXEL    
    
    @ 022, 258 SAY oSay3 PROMPT "Data Solicitação" SIZE 047, 007 OF oDlg FONT oFont1 COLORS 8388608, 16777215 PIXEL
    @ 020, 309 MSGET oEmissao VAR dEmissao SIZE 042, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 READONLY PIXEL  VALID !Empty(dEmissao)
    
    @ 022, 358 SAY oSay8 PROMPT "Data Necessidade" SIZE 055, 007 OF oDlg FONT oFont1 COLORS 8388608, 16777215 PIXEL
    @ 020, 415 MSGET oDtNecess VAR dDtNecess SIZE 048, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL VALID !Empty(dDtNecess)

    @ 037, 010 SAY oSay4 PROMPT "Filial Solicitante" SIZE 052, 007 OF oDlg FONT oFont1 COLORS 8388608, 16777215 PIXEL
    @ 035, 060 MSGET oFilFat VAR cFilFat SIZE 043, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 F3 "SM0" PIXEL VALID !Empty(cFilFat)
    
    @ 037, 106 SAY oSay6 PROMPT "Filial de Entrega" SIZE 047, 007 OF oDlg FONT oFont1 COLORS 8388608, 16777215 PIXEL
    @ 035, 155 MSGET oFilEnt VAR cFilEnt SIZE 043, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 F3 "SM0" PIXEL   VALID !Empty(cFilEnt) .And. A110FilEnt(cFilEnt)

    @ 037, 265 SAY oSay12 PROMPT "Classificação" SIZE 045, 007 OF oDlg FONT oFont1 COLORS 8388608, 16777215 PIXEL
    @ 035, 309 MSCOMBOBOX oClassific VAR nClassific ITEMS {"1=Equip. Parado","2=Man. Corretiva","3=Man. Preventiva","4=Compra para Estoque","5=Uso e Consumo"} SIZE 091, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
 
    @ 052, 020 SAY oSay10 PROMPT "Observação" SIZE 034, 007 OF oDlg FONT oFont1 COLORS 8388608, 16777215 PIXEL
    @ 050, 060 MSGET oObs VAR cObs SIZE 310, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL

    @ 070, 004 SAY oSay11 PROMPT "Itens da Solicitação" SIZE 076, 010 OF oDlg FONT oFont3 COLORS 32768, 16777215 PIXEL
    fMSNewGe1()       
    
  aAdd(aRotina,{"Pesquisar"   	,"U_AFATP01",0,1})
  aAdd(aRotina,{"Visualizar"  	,"U_AFATP01",0,2})
  aAdd(aRotina,{"Incluir"     	,"U_AFATP01",0,3})
  aAdd(aRotina,{"Alterar"     	,"U_AFATP01",0,4})
  aAdd(aRotina,{"Excluir"     	,"U_AFATP01",0,5}) 
  aAdd(aRotina,{"Legenda"       ,"U_FLegenda",0,6})    

oFilFat:Disable()
oFilEnt:Enable()


    
	//So aparece quando não for visualizar
	If nOpcao <> 2                                                 
	    DEFINE SBUTTON oSButton1 FROM 266, 582 TYPE 01 ACTION fConfirma() OF oDlg ENABLE
	    oSButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " )    
	endif
                                                                                          
  ACTIVATE MSDIALOG oDlg CENTERED

Return

//------------------------------------------------ 
Static Function fMSNewGe1()
//------------------------------------------------ 
Local nX
Local aFieldFill   := {}
Local aFields      := {"C1_ITEM","B1_ZREF1","C1_PRODUTO","C1_DESCRI","C1_UM","C1_QUANT","C1_ZMARCA","C1_ZTIPOPR","C1_ZOBSADI","C1_ZAPLIC","C1_CC","B1_FABRIC","C1_ZDTAPRO"}
Local aAlterFields := {"C1_PRODUTO","C1_DESCRI","C1_UM","C1_QUANT","C1_ZMARCA","C1_ZTIPOPR","C1_ZOBSADI","C1_ZAPLIC","C1_CC"}
Local aHeaderEx    := {}
Local aColsEx      := {}
Static oMSNewGe1         

Local nPosFabric   := aScan(aFields,{|x| AllTrim(x) == "B1_FABRIC"})
Local nPosZRef1    := aScan(aFields,{|x| AllTrim(x) == "B1_ZREF1"})

DbSelectArea("SX3")
SX3->(DbSetOrder(2))
For nX := 1 to Len(aFields)
	If SX3->(DbSeek(aFields[nX]))
		if SubStr(aFields[nX],1,2) == "C1"
	    	Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"",;
    	                   SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
  		else
	    	Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
    	                   SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		endif    	                  		
    Endif
Next nX   
  
If nOpcao == 3
	For nX := 1 to Len(aFields)
		If DbSeek(aFields[nX])
			Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		Endif
	Next nX      
	Aadd(aFieldFill, .F.) // Flag de exclusão
	Aadd(aColsEx, aFieldFill) 
	aColsEx[1,1] := StrZero(1,TamSx3("C1_ITEM")[1])  
Endif
           
dbSelectArea("SC1")
dbSetOrder(1)
dbSeek(cFilSC1+cNumero,.T.)
While !Eof() .And. SC1->C1_FILIAL+SC1->C1_NUM=cFilSC1+cNumero

	If nOpcao <> 2 
	    //Se for alterar, so altera o que nao esta em cotação ou ja gerou pedido
		if nOpcao == 2 
			if !Empty(SC1->C1_COTACAO) .Or. !Empty(SC1->C1_PEDIDO)
				dbSelectArea("SC1")
				dbSkip()	
			endif
		endif
	endif
		
	//aadd(aColsEx,Array(Len(aHeaderEx)+2)) // comentado
	aadd(aColsEx,Array(Len(aHeaderEx)+1))	
	For nX := 1 To Len(aHeaderEx)
		aColsEx[Len(aColsEx)][nX] :=  SC1->(FieldGet(FieldPos(aHeaderEx[nx,2]) )) 
	Next nX                          
    
    //aColsEx[Len(aColsEx)][1]:=StrZero(Len(aColsEx),4)
	//aColsEx[Len(aColsEx)][Len(aHeaderEx)+1] := Recno()	

	//aColsEx[Len(aColsEx)][Len(aHeaderEx)+2] := .F. comentado
	aColsEx[Len(aColsEx)][Len(aHeaderEx)+1] := .F.
			
	aColsEx[Len(aColsEx),nPosFabric] := Posicione("SB1",1,xFilial("SB1")+SC1->C1_PRODUTO,"B1_FABRIC")
	aColsEx[Len(aColsEx),nPosZRef1]  := Posicione("SB1",1,xFilial("SB1")+SC1->C1_PRODUTO,"B1_ZREF1")
			
	aadd(aRegistro,Recno())
	dbSelectArea("SC1")
	dbSkip()
EndDo   
If(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080
oMSNewGe1 := MsNewGetDados():New( 086, 005, 419, 954, GD_INSERT+GD_DELETE+GD_UPDATE,"u_FTP01LOK()","U_FTP01TOK()", "+C1_ITEM", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
Else
oMSNewGe1 := MsNewGetDados():New( 086, 005, 253, 675, GD_INSERT+GD_DELETE+GD_UPDATE,"u_FTP01LOK()","U_FTP01TOK()", "+C1_ITEM", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
Endif

oMSNewGe1:ForceRefresh()

Return
/*
Confirma gravaçao
*/

Static Function fConfirma()
Local lFlag:=.F.
If !U_FTP01TOK()
	Return 
Endif
MsAguarde( {|lEnd|lFlag:=FGravaSC1()},"Aguarde","Gravando Registros...",.T.)
If !lFlag
	Help("",1,"GETOBG",,"Solicitação de Compra Inconsistente!!!",2) 
	Return 
Endif
oDlg:End()
Return 
/*
Grava o registro no arquivo SC1
*/

Static Function FGravaSC1()
Local lRet:=.F.
Local nConReg := 0  
Local cSolicit:=UsrRetName(RetCodUsr())
Local cCodSoli:=RetCodUsr() 
Local cEmp    := Alltrim(GetNewPar("MV_EMPCOMP","02"))
 
/*
Local cEmlUsr := ''
PswOrder(1)
If (PswSeek(cCodSoli))
	EmlUsr := Alltrim(PswRet()[1,14])
EndIf
*/

aHeader:=Aclone(oMSNewGe1:aHeader)

Begin Transaction          
	For nX := 1 to Len(oMSNewGe1:aCols)
		If !oMSNewGe1:aCols[nX,Len(oMSNewGe1:aCols[nX])] .And. !Empty(oMSNewGe1:aCols[nX,GDFieldPos("C1_PRODUTO")]) 
			dbSelectArea("SC1")  
			IF nOpcao=3
			 	RecLock("SC1", .T.)
				SC1->C1_Filial  := xFilial("SC1") 
				SC1->C1_ZEMP    :=SM0->M0_CODIGO
				SC1->C1_NUM     := cNumero
				SC1->C1_APROV   := "B"
			Else 
			    If  nX <=Len(aRegistro)
   		        	dbGoto(aRegistro[nX])  
			 		RecLock("SC1", .F.)
			 	Else
			 		RecLock("SC1", .T.)
					SC1->C1_Filial  := xFilial("SC1") 
					SC1->C1_NUM     := cNumero
					SC1->C1_APROV   := "B"
			 	Endif	
			Endif 	 
			
			For nY := 1 to Len(oMSNewGe1:aHeader)
				If ( oMSNewGe1:aHeader[nY][10] <> "V" )
					SC1->(FieldPut(FieldPos(Trim(oMSNewGe1:aHeader[nY][2])),oMSNewGe1:aCols[nX][nY]))
				EndIf                                              
			Next nY 
 			SC1->C1_USER    := cCodSoli 
			SC1->C1_SOLICIT := cSolicit 
			SC1->C1_EMISSAO := dEmissao 
			SC1->C1_ZFILFAT := cFilFat  
			SC1->C1_FILENT  := cFilEnt   
			//SC1->C1_CC      := cCC       
			SC1->C1_DATPRF  := dDtNecess  
			//SC1->C1_ZAPLIC  := cAplic    
			SC1->C1_OBS     := cObs      
    		SC1->C1_ZCLASSI := nClassific   
    		SC1->C1_ZSTATUS := IIF(nOpcao =4 .And. cStatus ="4","3","1") // 1) Liberador 2) Bloqueado  
    		SC1->C1_ZEMP    :=SM0->M0_CODIGO
    		   
    		If nOpcao=5  // Exclusao         
    			dbDelete()   
    		Endif  	
				
			MsUnLock()  
				
			lRet:=.T.   

 		Else  // Posiciona no registro para exclusao
 			   If  nX <=Len(aRegistro)
   		        	dbGoto(aRegistro[nX])  
  		 	   		IF RecLock("SC1", .F.)
						dbDelete()
						MsUnLock()
				    	lRet:=.T.   
			   		Endif	
 		       Endif 
		Endif	    
	Next nX	  
	IF cStatus="4"  // Opcao para voltar a cotaçao em modo em cotaçao
		dbSelectArea("SZ2") 
		cNumOcor:= GetSxENum("SZ2","Z2_NUMERO") 
		ConfirmSX8()
		dbSelectArea("SZ2")   
		If RecLock("SZ2", .T.)    
				 SZ2->Z2_FILIAL :=   cFilSC1
		        SZ2->Z2_NUMERO   := cNumOcor
		 	    SZ2->Z2_CODIGO   := '005'
		    	SZ2->Z2_NUMSC    := cNumero 
	    		//SZ2->Z2_ITEMSC := 
			   	SZ2->Z2_NUMCOT   := cNumCot
			   	//SZ2->Z2_PRODUTO  := SC1->C1_PRODUTO
			   	SZ2->Z2_CODUSR   := cCodSoli
			   	SZ2->Z2_NOMEUSR  := cSolicit
			   	SZ2->Z2_DATA     := DATE()
			   	SZ2->Z2_HORA     := TIME()
			   	SZ2->Z2_MOTIVO   := "ACERTO CORRIGIDO"
			   	SZ2->Z2_EMAIL1   :=""
			   	SZ2->Z2_EMAIL2   :=""
			   	SZ2->Z2_EMAIL3   :=""
			   	SZ2->Z2_EMAIL4   :=""
			   	SZ2->Z2_EMAIL5   :=""
				MsUnLock()  
		Endif 
		cStatus:="3" 
		If TCCanOpen(RetSqlName("SC8"))	 
			_Retorno :=TCSQLExec("UPDATE SC8"+cEmp + "0 SET C8_ZSTATUS = '"+cStatus+"' WHERE C8_NUM='" + cNumCot+ "'")                      
		Endif     
		//u_AFATR07({cNumero,SZ2->Z2_MOTIVO,pMail})
	Endif
	
End Transaction 

If nOpcao=3 .And. lRet                                        
	ConfirmSx8()
Endif	
Return(lRet)  
/*
 Funçao de validar TO ok
*/
User Function FTP01TOK()    
Local lRet:=.T.            
Local cGrupo:=""
aHeader:=Aclone(oMSNewGe1:aHeader)
If Len(oMSNewGe1:aCols)=0
	lRet:=.F.
Endif                   

if Empty(cFilFat)                                                          
	Help("",1,"GETOBG",,"Filial de faturamento não pode ficar em branco !!!",2) 
	return
endif

if Empty(cFilEnt)
	Help("",1,"GETOBG",,"Filial de entrega não pode ficar em branco !!!",2) 
	return
endif
	

For nX := 1 to Len(oMSNewGe1:aCols)
	If !oMSNewGe1:aCols[nX,Len(oMSNewGe1:aHeader)+1]  .And. !Empty(oMSNewGe1:aCols[nX][GDFieldPos("C1_PRODUTO")])
//		cCod:=Posicione("SB1",1,xFilial("SB1")+oMSNewGe1:aCols[nX][GDFieldPos("C1_PRODUTO")],'B1_COD')
		If Empty(Posicione("SB1",1,xFilial("SB1")+oMSNewGe1:aCols[nX][GDFieldPos("C1_PRODUTO")],'B1_COD'))
			Help("",1,"GETOBG",,"Não existe produto com este codigo!!!",2) 
			lRet:=.F.
		Endif    
	Endif
	  
	If !oMSNewGe1:aCols[nX,Len(oMSNewGe1:aHeader)+1]  .And. !Empty(oMSNewGe1:aCols[nX][GDFieldPos("C1_PRODUTO")])
	   
	   cMsBlQl := Posicione("SB1",1,xFilial("SB1")+oMSNewGe1:aCols[nX][GDFieldPos("C1_PRODUTO")],'B1_MSBLQL') 
	   
	   If cMsBlQl == "1"
			Help("",1,"GETOBG",,"Produto Bloqueado! - "+SB1->(B1_COD+" "+B1_DESC),2) 
			lRet:=.F.
		Endif    
	   
		If Empty(cGrupo)
			cGrupo:=Posicione("SB1",1,xFilial("SB1")+oMSNewGe1:aCols[nX][GDFieldPos("C1_PRODUTO")],'B1_GRUPO') 
		Else
			If cGrupo<>Posicione("SB1",1,xFilial("SB1")+oMSNewGe1:aCols[nX][GDFieldPos("C1_PRODUTO")],'B1_GRUPO')
				Help("",1,"GETOBG",,"Produto com o grupo diferente do primeiro informado!, Grupo",2) 
				lRet:=.F.
			Endif	     
		Endif	
	Endif                       

	If !oMSNewGe1:aCols[nX,Len(oMSNewGe1:aHeader)+1]  .And. Empty(oMSNewGe1:aCols[nX][GDFieldPos("C1_ZAPLIC")])  
		Help("",1,"GETOBG",,"Aplicação deverá ser obrigatória",2) 
		lRet := .F.
	Else  
	   DbSelectArea("P09")
	   DbSetOrder(1)
	   If DbSeek( xFilial("P09") + oMSNewGe1:aCols[nX][GDFieldPos("C1_ZAPLIC")] )
	      If P09->P09_MSBLQL == "1"
		      Help("",1,"GETOBG",,"Aplicação está bloqueada para uso! - "+P09->P09_CODAPL,2) 
		      lRet := .F.
	      Endif
	   Endif
   EndIf

	If !oMSNewGe1:aCols[nX,Len(oMSNewGe1:aHeader)+1]  .And. Empty(oMSNewGe1:aCols[nX][GDFieldPos("C1_CC")])   
		Help("",1,"GETOBG",,"Centro de Custo obrigatório!",2)
		lRet := .F.
	Else
	   DbSelectArea("CTT")	
	   DbSetOrder(1)
	   If DbSeek( xFilial("CTT") + oMSNewGe1:aCols[nX][GDFieldPos("C1_CC")] )
	      If CTT->CTT_BLOQ == "1"
		      Help("",1,"GETOBG",,"Centro de Custo bloqueado! "+CTT->CTT_CUSTO,2)
	 	      lRet := .F.
	      Endif
	   Endif
	EndIf
	
	If !oMSNewGe1:aCols[nX,Len(oMSNewGe1:aHeader)+1]  .And. oMSNewGe1:aCols[nX][GDFieldPos("C1_QUANT")] <= 0
		Help("",1,"GETOBG",,"Quantidade tem que ser maior que zero!!!",2)
		lRet:=.F.
	Endif 

	If Empty(cObs) //oMSNewGe1:aCols[nX][GDFieldPos("C1_OBS")])
		Help("",1,"GETOBG",,"O Campo Oservação não poderá ficar vazio!!!",2)
		lRet:=.F.
	Endif 

	If !oMSNewGe1:aCols[nX,Len(oMSNewGe1:aHeader)+1]  .And. Empty(oMSNewGe1:aCols[nX][GDFieldPos("C1_ZOBSADI")])
		Help("",1,"GETOBG",,"O Campo Oservação Adicional não poderá ficar vazio!!!",2)
		lRet:=.F.
	Endif 

Next    

               
Return(lRet)
/*
 Funçao de validar a linha ok
*/
User Function FTP01LOK()    
Local lRet:=.T.                       
Local cGrupo := ""
If ( !oMSNewGe1:aCols[n][Len(oMSNewGe1:aHeader)+1] ) .And. !Empty(oMSNewGe1:aCols[n][GDFieldPos("C1_PRODUTO")])

	If Empty(Posicione("SB1",1,xFilial("SB1")+oMSNewGe1:aCols[n][GDFieldPos("C1_PRODUTO")],'B1_COD'))
		Help("",1,"GETOBG",,"Não existe produto como este codigo!!!",2)
		lRet:=.F.
	Endif    
	If oMSNewGe1:aCols[n][GDFieldPos("C1_QUANT")] < .001 .And. !Empty(oMSNewGe1:aCols[n][GDFieldPos("C1_PRODUTO")])
		Help("",1,"GETOBG",,"Quantidade tem que ser maior que zero!!!",2)
		lRet:=.F.
	Endif   
/*
	If !oMSNewGe1:aCols[n,Len(oMSNewGe1:aHeader)+1]  .And. Empty(oMSNewGe1:aCols[n][GDFieldPos("C1_OBS")])
		Help("",1,"GETOBG",,"O Campo Oservação não poderá ficar vazio!!!",2)
		lRet:=.F.
	Endif 
*/
	If !oMSNewGe1:aCols[n,Len(oMSNewGe1:aHeader)+1]  .And. Empty(oMSNewGe1:aCols[n][GDFieldPos("C1_ZOBSADI")])
		Help("",1,"GETOBG",,"O Campo Oservação Adicional não poderá ficar vazio!!!",2)
		lRet:=.F.
	Endif 	

	For nX := 1 to Len(oMSNewGe1:aCols)
	
		If !oMSNewGe1:aCols[nX,Len(oMSNewGe1:aHeader)+1]  .And. !Empty(oMSNewGe1:aCols[nX][GDFieldPos("C1_PRODUTO")])
		    If Empty(cGrupo)
             cGrupo:=Posicione("SB1",1,xFilial("SB1")+oMSNewGe1:aCols[nX][GDFieldPos("C1_PRODUTO")],'B1_GRUPO')
		    Endif
			 If cGrupo <> Posicione("SB1",1,xFilial("SB1")+oMSNewGe1:aCols[nX][GDFieldPos("C1_PRODUTO")],'B1_GRUPO') 
				 Help("",1,"GETOBG",,"Produto com o grupo diferente, Grupo",2)    
				 lRet:=.F.
			 Endif 

	       cMsBlQl := Posicione("SB1",1,xFilial("SB1")+oMSNewGe1:aCols[nX][GDFieldPos("C1_PRODUTO")],'B1_MSBLQL') 
	   
	       If cMsBlQl == "1"
			    Help("",1,"GETOBG",,"Produto Bloqueado! - "+SB1->(B1_COD+" "+B1_DESC),2) 
			    lRet:=.F.
		    Endif    

	       If !oMSNewGe1:aCols[nX,Len(oMSNewGe1:aHeader)+1]  .And. Empty(oMSNewGe1:aCols[nX][GDFieldPos("C1_ZAPLIC")])  
         		Help("",1,"GETOBG",,"Aplicação deverá ser obrigatória",2) 
         		lRet := .F.
           Else  
         	   DbSelectArea("P09")
         	   DbSetOrder(1)
         	   If DbSeek( xFilial("P09") + oMSNewGe1:aCols[nX][GDFieldPos("C1_ZAPLIC")] )
         	      If P09->P09_MSBLQL == "1"
         		      Help("",1,"GETOBG",,"Aplicação está bloqueada para uso! - "+P09->P09_CODAPL,2) 
         		      lRet := .F.
         	      Endif
         	   Endif
           EndIf

           If !oMSNewGe1:aCols[nX,Len(oMSNewGe1:aHeader)+1]  .And. Empty(oMSNewGe1:aCols[nX][GDFieldPos("C1_CC")])   
         		Help("",1,"GETOBG",,"Centro de Custo obrigatório!",2)
         		lRet := .F.
           Else
          	   DbSelectArea("CTT")	
         	   DbSetOrder(1)
         	   If DbSeek( xFilial("CTT") + oMSNewGe1:aCols[nX][GDFieldPos("C1_CC")] )
         	      If CTT->CTT_BLOQ == "1"
         		      Help("",1,"GETOBG",,"Centro de Custo bloqueado! "+CTT->CTT_CUSTO,2)
         	 	      lRet := .F.
         	      Endif
         	   Endif
           EndIf

		Endif  

		If !oMSNewGe1:aCols[nX,Len(oMSNewGe1:aHeader)+1]  .And. nX <> n .And. oMSNewGe1:aCols[nX][GDFieldPos("C1_PRODUTO")] == oMSNewGe1:aCols[n][GDFieldPos("C1_PRODUTO")];
			.And. oMSNewGe1:aCols[nX][GDFieldPos("C1_ZAPLIC")] == oMSNewGe1:aCols[n][GDFieldPos("C1_ZAPLIC")];
			.And. oMSNewGe1:aCols[nX][GDFieldPos("C1_CC")] == oMSNewGe1:aCols[n][GDFieldPos("C1_CC")]
			Help("",1,"GETOBG",,"Ja existe Produto com este codigo Item ",2)    
			//MsgAlert("Ja existe Produto com este codigo Item: "+strzero(nX,TamSX3("C1_ITEM")[1]),"Atenção")
			lRet:=.F.
		Endif
    Next
    
Endif
               
Return(lRet)   



/*
Static Function fNumSC1(pFilial)
/*********************************************
/*retorna a última cotação                         

Local cAliasQry := "TEMPSC1"
Local aGetArea := GetArea()

BeginSql Alias cAliasQry

	SELECT MAX(C1_NUM) C1_NUM
	FROM %Table:SC1% SC1
	WHERE SC1.C1_FILIAL = %Exp:pFilial% AND SC1.%notDel%
      	              		
EndSql   

cNumSC1 := StrZero( Val((cAliasQry)->C1_NUM) + 1,6,0)

dbSelectArea(cAliasQry)
dbCloseArea()

RestArea(aGetArea)

Return (cNumSC1)

*/