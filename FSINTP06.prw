#Include "protheus.ch"          

Static aCabEnd := {}
Static aDadEnd := {}

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSINTP06()
Tela de Cadastro de Endereços de Cobrança do Cliente
        
@author 	Luciano M. Pinto
@since 	31/10/2011 
@return 	Nil

/*/
//---------------------------------------------------------------------------------------
User Function FSINTP06()
/****************************************************************************************
* 
*
*
***/ 
//Private nOpc := 0
If INCLUI
	nOpc := 3 
ElseIf ALTERA
	nOpc := 4
Else
 	nOpc := 2
End If 

FSP01mnt("P01", nOpc)

Return( aDadEnd )


//-------------------------------------------------------------------
/*/{Protheus.doc} FSP01mnt
Manutenção registros modelo 2 Monta a tela

@protected
@author	   Giulliano Santos Silva
@since	   08/07/2011
@version	   P11
@obs	      Cadastro de Convenios x Agrupamentos
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data      	 Programador     		Motivo
15/03/2012   Fernando Ferreira   Inclusão da variavel private nPosCodMun
/*/
//-------------------------------------------------------------------
Static Function FSP01mnt(cAlias, nOpc)

Local aButtons  := {} // Vetor de funções disponiveis no EnchoiceBar

//Componentes graficos
Private oDlgP01
Private oGetP01
Private oTP1P01
Private oTP2P01
 
//Variaveis de controle

Private cCodP01 	:= AllTrim(SA1->A1_COD) + " / " + AllTrim(SA1->A1_LOJA) // Pega o tamanho dos campos no SX3
Private cDesP01 	:= AllTrim(SA1->A1_NOME)

Private aHeader 		:= {} 
Private aCols 	 		:= {} 
Private aReg 	 		:= {}  
Private aSizFrm 		:= {}
Private nPosEst		:= 5

If nOpc == 3
	cCodP01 := AllTrim(M->A1_COD) + " / " + AllTrim(M->A1_LOJA) // Pega o tamanho dos campos no SX3
	cDesP01 := AllTrim(M->A1_NOME)
EndIf 

P01->(dbSetOrder(1))//Z1_FILIAL+Z1_CODCONV      
P01->(dbGoTop())

//Montar a aHeader
FMod2aHeader(cAlias)

//Montar a aCols
FMod2aCols(cAlias,nOpc)  

nPosEst 		:= Ascan(aHeader,{|x| Alltrim(x[2])== "P01_EST"})

//Monta Tela	
aSizFrm := MsAdvSize()  

//Tamanho padrão 800 x 600 de acordo com a resolução do monitor
DEFINE MSDIALOG oDlgP01 TITLE cCadastro FROM 000, 000  TO aSizFrm[6]*80/100 ,aSizFrm[5]*80/100 COLORS 0, 15658734 PIXEL 
oDlgP01:lMaximized := .T.     
	oTP1P01 := TPanel():New(00,00,"",oDlgP01,NIL,.T.,.F.,NIL,NIL,20,30,.T.,.F.)  

	@ 010, 025 SAY "Codigo:"  SIZE 50,7 PIXEL OF oDlgP01 
  	@ 010, 070 MSGET cCodP01 When .F. SIZE 50,7 PIXEL OF oDlgP01 //Cod

   @ 010, 170 SAY "Descrição:" SIZE 50,7 PIXEL OF oDlgP01 
   @ 010, 210 MSGET cDesP01 When .F. SIZE 140,7 PIXEL OF oDlgP01 //Descrição
 
  	oGetP01	:= MsNewGetDados():New(0,0,0,0,nOpc,"U_FSP01LOK","U_FSP01TOK","+P01_ITEM",/*aAlterGDa*/,,,"U_FSP01VAL",,,oDlgP01,aHeader,@aCols,,)
	   
   //Bloco de código para validar se pode deletar dados no MsNewGetDados
	//  	oGetP01:BDELOK	:= {|| FSDelOk() }
  
  	//Ajusta MsNewGetDados
  	If nOpc == 4 //Alteração 
		oGetP01:lUpdate  := Iif(nOpc==4,.T.,oGetP01:lUpdate) 
		oGetP01:lInsert  := .T.
   ElseIf nOpc == 3 //Inclusão
   	oGetP01:ldelete  := .T.
   ElseIf nOpc == 2 .Or. nOpc == 5 //Visualização  ou Exclusão
   	oGetP01:lUpdate  := .F.
		oGetP01:lInsert  := .F.
		oGetP01:ldelete  := .F.
	EndIf
   
   //Alinhar os componentes
  	oTP1P01:Align := CONTROL_ALIGN_TOP
  	oGetP01:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT 
  	
ACTIVATE MSDIALOG oDlgP01 CENTERED ON INIT (EnchoiceBar(oDlgP01, {|| Iif( (U_FSP01TOK()) , (FMod2Act(nOpc),oDlgP01:End()), .F.)}, {||oDlgP01:End()},,aButtons))

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FMod2Act
Ações do formulario

@protected
@author	   Giulliano Santos Silva
@since	   08/07/2011
@version	   P11
@obs	      Cadastro de Convenios x Agrupamentos
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FMod2Act(nOpc)
RptStatus({|| FMod2CRUD(nOpc)},"Atualizando Registros","Processando...")
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FMod2aHeader
Monta a aHeader

@protected
@author	   Giulliano Santos Silva
@since	   08/07/2011
@version	   P11
@obs	      Cadastro de Convenios x Agrupamentos
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FMod2aHeader(cAlias)

Local aArea := GetArea()

Local aCpoExc := {"P01_COD","P01_LOJA"}  // Campos que serão excluidos na montagem no aHeader
                             
SX3->(dbSetOrder(1))  
SX3->(dbSeek(cAlias)) 

While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == cAlias 
  
  If SX3->(X3Uso(SX3->X3_USADO)) .And. cNivel >= SX3->X3_NIVEL .And. ASCAN(aCpoExc,AllTrim(SX3->X3_CAMPO)) <= 0 
   	AADD( aHeader, {SX3->X3_TITULO,; 
   		SX3->X3_CAMPO,;    
	  		SX3->X3_PICTURE,;
	  		SX3->X3_TAMANHO,;
	  		SX3->X3_DECIMAL,;
	  		SX3->X3_VALID,;
	  		SX3->X3_USADO,;
	  		SX3->X3_TIPO,;
	  		SX3->X3_F3,;
	  		SX3->X3_CONTEXT,;
	  		SX3->X3_CBOX,;
	  		SX3->X3_RELACAO,;
	  		SX3->X3_WHEN,;
	  		SX3->X3_VISUAL,;
	  		SX3->X3_VLDUSER,;
	  		SX3->X3_PICTVAR,;
	  		SX3->X3_OBRIGAT})
  Endif 
  SX3->(dbSkip()) 
EndDo   

RestArea(aArea)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FMod2aCols
Monta aCols

@protected
@author	   Giulliano Santos Silva
@since	   08/07/2011
@version	   P11
@obs	      Cadastro de Convenios x Agrupamentos
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FMod2aCols(cAlias,nOpc)

Local aArea   := GetArea() 
Local cCodReg := SA1->A1_COD + SA1->A1_LOJA
Local nI 	  := 0 

If	nOpc <> 3 .And. Empty(aDadEnd) // se Diferente de inclusão e não tiver dados na memoria.
	
	P01->(dbSetOrder(1))
	P01->(dbSeek(xFilial("P01") + cCodReg))  
	
	While P01->(!Eof()) .And. P01->P01_FILIAL == xFilial("P01") .And. P01->P01_COD ==  SA1->A1_COD .And. P01->P01_LOJA ==  SA1->A1_LOJA
		
		Aadd(aReg, P01->(Recno())) 				 // Adiciona o campo R_E_C_N_O_ para manipulação dentro do vetor aReg
		Aadd(aCols, Array(Len(aHeader) + 1)) 	 // Monta o aCols no tamanho do meu aHeader
	  	aCols[Len(aCols),Len(aHeader)+1] := .F. // Seta o ultimo campo do aCols como .F. para validar a se está deletado
		
		For nI := 1 to Len (aHeader) 
			If aHeader[nI,10] == "V" // Verifica se o campo é virtual, se sim cria variavel na memoria
				aCols[len(aCols), nI] := CriaVar(aHeader[nI,2],.T.)
			Else
				aCols[len(aCols), nI] := P01->(FieldGet(P01->(FieldPos(aHeader[nI,2]))))
			EndIf		
		Next 
	
	P01->(dbSkip())
	EndDo	
ElseIf !Empty(aDadEnd)   // se Diferente de inclusão e tiver dados na memoria.
	aCols := aClone(aDadEnd)
EndIf                      

aDadEnd := aClone(aCols)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FMod2CRUD
Realiza o Insert, Update, Delete

@protected
@author	   Giulliano Santos Silva
@since	   08/07/2011
@version	   P11
@obs	      Cadastro de Convenios x Agrupamentos
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FMod2CRUD(nOpc) 

Local aArea := GetArea() 
Local nI := 0 
Local nX := 0

Local nPosCol
Local nPosCam  
Local	cCodAgru	

aCols := aClone(oGetP01:aCols)    

aCabEnd := aClone(aHeader)
aDadEnd := aClone(aCols)

GetDRefresh()
RestArea(aArea) 

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FSP01LOK
Valida Linha Ok

@protected
@author	   Giulliano Santos Silva
@since	   08/07/2011
@version	   P11
@obs	      
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSP01LOK

Local lRetFun	:= .T. 
Local nPosCod	:= 0
/*
//Se o codigo do agrupamento estiver vazio           
If (Empty(GdFieldGet("P01_END"))) 
	Aviso("Microsiga Protheus","O endereço não pode ser vazio!",{"Ok"}) 
	lRetFun	:= .F.
EndIf 
*/

//-- Nao avalia linhas deletadas
lRetFun := !GDdeleted(n) .And. (MaCheckCols(aHeader,aCols,n))

Return lRetFun


//-------------------------------------------------------------------
/*/{Protheus.doc} FSP01VAL
Validar campo agrupamento

@author	   Giulliano Santos Silva
@since	   08/07/2011
@version	   P11

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSP01VAL 

Local lRetFun := .T.
Local cP01Cod := ReadVar() // Pega a variavel editada no getdados. 
Local nPosCod := 0	

//aCols := aClone(oGetP01:aCols) 
	
Return lRetFun


//-------------------------------------------------------------------
/*/{Protheus.doc} FSP01TOK
Valida Tudo Ok

@author	   Giulliano Santos Silva
@since	   08/07/2011
@version	   P11

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSP01TOK()  

Local lRetFun	:= .T.
Local nXi		:= 0 
Local aColsVld := aClone(oGetP01:aCols) 
Local nXy      := 0

If Empty(cDesP01) .Or. Len(aColsVld) == 0 
   Aviso("Microsiga Protheus","Informe o endereço de cobrança!",{"Ok"}) 
   oGetP01:Refresh()
   lRetFun	:= .F.
EndIf  

If Len(aColsVld) > 0                      

   For nXy := 1 To Len(aColsVld)
   
       If Empty(aColsVld[nXy][2])
          Aviso("Microsiga Protheus","O campo Endereço não pode ser Vazio",{"Ok"}) 
          oGetP01:Refresh()
          lRetFun	:= .F.
       Endif   

       If Empty(aColsVld[nXy][4])
          Aviso("Microsiga Protheus","O campo Bairro não pode ser Vazio",{"Ok"}) 
          oGetP01:Refresh()
          lRetFun	:= .F.
       Endif   

       If Empty(aColsVld[nXy][5])
          Aviso("Microsiga Protheus","O campo estado não pode ser Vazio",{"Ok"}) 
          oGetP01:Refresh()
          lRetFun	:= .F.
       Endif   

       If Empty(aColsVld[nXy][6])
          Aviso("Microsiga Protheus","O campo cod. municipio não pode ser Vazio",{"Ok"}) 
          oGetP01:Refresh()
          lRetFun	:= .F.
       Endif   

      If Empty(aColsVld[nXy][7])
         Aviso("Microsiga Protheus","O campo municipio não pode ser Vazio",{"Ok"}) 
         oGetP01:Refresh()
         lRetFun	:= .F.
      Endif   

      If Empty(aColsVld[nXy][8])
         Aviso("Microsiga Protheus","O campo cep não pode ser Vazio",{"Ok"}) 
         oGetP01:Refresh()
         lRetFun	:= .F.
      Endif   
      
   Next
   
EndIf  

//Valida novamente todas as linhas
If (lRetFun)
	For nXi:= 1 To Len(aCols)
	    n:= nXi
		 //Pula as linhas deletadas
		 If !aCols[nXi, Len(aHeader)+1] 
		 	lRetFun := U_FSP01LOK()
		 EndIf
		 If !lRetFun
		 	Return lRetFun
		 EndIf
	Next nXi       
EndIf         
N:=1
Return lRetFun


//-------------------------------------------------------------------
/*/{Protheus.doc} FMod2Cod
Valida codigo

@protected
@author	   Giulliano Santos Silva
@since	   08/07/2011
@version	   P11

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FMod2Cod(cCodP01, cDesP01, nOpc)

Local lRetFun	:= .T.
Local aArea   := GetArea() 

RestArea(aArea)
Return lRetFun 


//-------------------------------------------------------------------
/*/{Protheus.doc} FSDelOk
Valida se pode deletar

@protected
@author	   Giulliano Santos Silva
@since	   08/07/2011
@version	   P11
@obs	      Cadastro de Convenios x Agrupamentos
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------

Static Function FSDelOk()
	
Local lRetFun := .T.
Local CValOld := aCols[oGetP01:nAt][1]
Local cValCpo := 0

If (GDDeleted(oGetP01:nAt))
	//Ultima posição no meu aCols
	cValCpo := ASCan(aCols, {|x| x[1] == CValOld .And. x[Len(x)] == .F.})
	If (cValCpo <> 0)
	    Aviso("Microsiga Protheus","O código de convênio já foi cadastrado, Verifique!",{"Ok"}) 
		 lRetFun	:= .F.
	EndIf
EndIf

Return lRetFun

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuEnd
Realiza a inclusão/Alteração dos dados

@author	   Fernando Ferreira
@since	   08/07/2011
@version	   P11
@obs	      Cadastro de Clientes
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FAtuEnd()

Local aAreOld 		:= {GetArea(),P01->(GetArea())}        
Local cCodCli		:= SA1->A1_COD
Local cLojCli		:= SA1->A1_LOJA
Local nPosIteEnd	:= aScan(aCabEnd,{|x|AllTrim(x[2])=="P01_ITEM"})  

Local	nXi			:= 1  
Local nXj			:= 1

Local	lRet			:=	.T.

If Len(aDadEnd) == 0 
   Return .F.
Endif
   
P01->(dbSetOrder(1))  

If nPosIteEnd > 0

   For nXi := 1 To Len(aDadEnd)      
	    P01->(dbSeek(xFilial("P01") + cCodCli + cLojCli + aDadEnd[nXi][nPosIteEnd]) )  
       If aDadEnd[nXi][Len(aCabEnd)+1] 
		    If P01->(!Eof())
			    //Atualiza o banco de integração.     
			    If U_FSVldExc("P01")				
				    lRet := U_FSEndInt("E")
				    RecLock("P01",P01->(Eof()))
				    P01->(dbDelete())
				    P01->(MsUnlock())
			    Else
				    lRet := .F.				
			    EndIf 
		    EndIf			
	    Else
		    RecLock("P01",P01->(Eof()))
		    P01->P01_FILIAL	:= xFilial("P01")
		    P01->P01_COD		:= cCodCli
		    P01->P01_LOJA		:= cLojCli                     
		    For nXj := 1 To Len(aCabEnd) 
		        &("P01->"+aCabEnd[nXj][2]) := aDadEnd[nXi][nXj]
          Next		
		    P01->(MsUnlock())
		    U_FSEndInt()
	    EndIf
   Next
Else
   Aviso("Microsiga Protheus","Verifique o endereço de cobrança, não pode ser vazio!",{"Ok"}) 
   lRet	:= .F.
Endif

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return lRet




//-------------------------------------------------------------------
/*/{Protheus.doc} FVldEndCob
Valida se existe o endereço de cobrança

@author	   Rodrigo Carvalho
@since	   23/09/2015
@version	   P11
@obs	      Cadastro de Clientes
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FVldEndCob()

Local nPosIteEnd	:= aScan(aCabEnd,{|x|AllTrim(x[2])=="P01_ITEM"})  
Local	lRet			:=	.T.

If Len(aDadEnd) == 0 .Or. nPosIteEnd <= 0
   Aviso("Microsiga Protheus","Verifique o endereço de cobrança, não pode ser vazio!",{"Ok"}) 
   Return .F.
Endif

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} FClrEnd
Função limpa os valores das variáveis estaticas aCabEnd, aDadEnd

@author	   Fernando Ferreira
@since	   08/07/2011
@version	   P11
@obs	      Cadastro de Clientes
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FClrEnd()

aCabEnd := {}
aDadEnd := {}

Return Nil


