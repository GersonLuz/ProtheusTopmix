#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFATP19   ºAutor  ³Fausto Neto         º Data ³  03/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclusão de novo fornecedor.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
************************************
User Function AFATP19()
************************************
*
*
// Variaveis Locais da Funcao

// Variaveis da Funcao de Controle e GertArea/RestArea
Local _aArea   		:= {}
Local _aAlias  		:= {}
// Variaveis Private da Funcao
Private oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        
// Privates das NewGetDados
Private oGetDados1
// Privates das ListBoxes
Private aListBox1 := {}
Private oListBox1    

Private oOk 	 := LoadBitmap( GetResources(), "LBOK"       )
Private oNo 	 := LoadBitmap( GetResources(), "LBNO"       )   

Private cZNumCot  := aWBrowse2[oWBrowse2:nAt,3]           
Private cZFilAux  := aWBrowse2[oWBrowse2:nAt,9]
Private cXXCodUsr := RetCodUsr()
Private aResolu   := getScreenRes()

if Empty(cZNumCot)
	ApMsgInfo("Não existe cotação a ser selecionada !!!")
	return
endif 

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

DEFINE MSDIALOG oDlg TITLE "Fornecedores" FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL

// Defina aqui a chamada dos Aliases para o GetArea
//CtrlArea(1,@_aArea,@_aAlias,{"SA1","SA2"}) // GetArea
  IF(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080
	// Cria as Groups do Sistema
	@ C(002),C(002) TO C(238),C(745) LABEL "Produtos" PIXEL OF oDlg
	@ C(241),C(002) TO C(325),C(745) LABEL "Fornecedores" PIXEL OF oDlg

	// Cria Componentes Padroes do Sistema
	@ C(330),C(486) Button "&Desmarca"  Size C(037),C(012) Action fDesmarca() PIXEL OF oDlg
	@ C(330),C(526) Button "&Todos"     Size C(037),C(012) Action fTodos() PIXEL OF oDlg
	@ C(330),C(566) Button "&Confirmar" Size C(037),C(012) Action fConf() PIXEL OF oDlg
	@ C(330),C(606) Button "&Fechar"    Size C(037),C(012) Action oDlg:End() PIXEL OF oDlg		
  Else
  	// Cria as Groups do Sistema
	@ C(002),C(002) TO C(130),C(528) LABEL "Produtos" PIXEL OF oDlg
	@ C(130),C(002) TO C(214),C(528) LABEL "Fornecedores" PIXEL OF oDlg

	// Cria Componentes Padroes do Sistema
	@ C(216),C(286) Button "&Desmarca"  Size C(037),C(012) Action fDesmarca() PIXEL OF oDlg
	@ C(216),C(326) Button "&Todos"     Size C(037),C(012) Action fTodos() PIXEL OF oDlg
	@ C(216),C(366) Button "&Confirmar" Size C(037),C(012) Action fConf() PIXEL OF oDlg
	@ C(216),C(406) Button "&Fechar"    Size C(037),C(012) Action oDlg:End() PIXEL OF oDlg
  Endif
	// Cria ExecBlocks dos Componentes Padroes do Sistema                             

	// Chamadas das ListBox do Sistema
	fListBox1()                                                           	
	fCarrega()
	
	// Chamadas das GetDados do Sistema
	fGetDados1()	
	

//CtrlArea(2,_aArea,_aAlias) // RestArea

ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fGetDados1()³ Autor ³ Fausto Neto               ³ Data ³03/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da GetDados                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao ³ O Objeto oGetDados1 foi criado como Private no inicio do Fonte   ³±±
±±³           ³ desta forma voce podera trata-lo em qualquer parte do            ³±±
±±³           ³ seu programa:                                                    ³±±
±±³           ³                                                                  ³±±
±±³           ³ Para acessar o aCols desta MsNewGetDados: oGetDados1:aCols[nX,nY]³±±
±±³           ³ Para acessar o aHeader: oGetDados1:aHeader[nX,nY]                ³±±
±±³           ³ Para acessar o "n"    : oGetDados1:nAT                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGetDados1()
// Variaveis deste Form                                                                                                         
Local nX			:= 0                                                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Vetor responsavel pela montagem da aHeader
Local aCpoGDa       := {"C7_FORNECE","C7_LOJA","A2_NOME","A2_EMAIL"}           
// Vetor com os campos que poderao ser alterados                                                                                
Local aAlter       	:= {"C7_FORNECE","A2_EMAIL"}
Local nSuperior    	
Local nEsquerda    
Local nInferior    
Local nDireita     
// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local nOpc         	:= GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                         // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                         // segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 999              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
Local cSuperDel     := ""              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk        := "AllwaysTrue"   // Funcao executada para validar a exclusao de uma linha do aCols                   
// Objeto no qual a MsNewGetDados sera criada                                      
Local oWnd          := oDlg                                                                                                  
Local aHead        	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Local aCol         	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols                      
                                                                                                                                
// Carrega aHead                                                                                                                
DbSelectArea("SX3")                                                                                                             
SX3->(DbSetOrder(2)) // Campo                                                                                                   
For nX := 1 to Len(aCpoGDa)                                                                                                     
	If SX3->(DbSeek(aCpoGDa[nX]))                                                                                                 
		Aadd(aHead,{ AllTrim(X3Titulo()),;                                                                                         
			SX3->X3_CAMPO	  ,;                                                                                                       
			SX3->X3_PICTURE   ,;                                                                                                       
			SX3->X3_TAMANHO   ,;                                                                                                       
			SX3->X3_DECIMAL   ,;                                                                                                       
			SX3->X3_VALID	  ,;                                                                                                       
			SX3->X3_USADO	  ,;                                                                                                       
			SX3->X3_TIPO	  ,;                                                                                                       
			SX3->X3_F3 		  ,;                                                                                                       
			SX3->X3_CONTEXT   ,;                                                                                                       
			SX3->X3_CBOX	  ,;                                                                                                       
			SX3->X3_RELACAO})                                                                                                       
	Endif                                                                                                                         
Next nX                                                                                                                         
// Carregue aqui a Montagem da sua aCol                                                                                         
aAux := {}                                                                              
For nX := 1 to Len(aCpoGDa)         
	If DbSeek(aCpoGDa[nX])             
		Aadd(aAux,CriaVar(SX3->X3_CAMPO))
	Endif                              
Next nX                             
Aadd(aAux,.F.)                      
Aadd(aCol,aAux)                     

IF(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080
nSuperior    	:= C(249)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
nEsquerda    	:= C(004)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
nInferior    	:= C(323)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
nDireita     	:= C(743)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
  oGetDados1:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;                               
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)
Else
nSuperior    	:= C(137)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
nEsquerda    	:= C(004)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
nInferior    	:= C(213)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
nDireita     	:= C(527)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
  oGetDados1:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;                               
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)
Endif                                                                

// Cria ExecBlocks da GetDados

Return Nil                                                                                                                      

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fListBox1() ³ Autor ³ Fausto Neto           ³ Data ³03/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da ListBox                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fListBox1()


	// Para editar os Campos da ListBox inclua a linha abaixo          
	// na opcao de DuploClick da mesma, ou onde for mais conveniente   
	// lembre-se de mudar a picture respeitando a coluna a ser editada 
	// PS: Para habilitar o DuploClick selecione a opção MarkBrowse da 
	//     ListBox para SIM.                                           
	// lEditCell( aListBox, oListBox, "@!", oListBox:ColPos )          

	// Carrege aqui sua array da Listbox
	Aadd(aListBox1,{.F.,"","","","","","","",""})
    
    IF(aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080
	@ C(008),C(004) ListBox oListBox1 Fields ;
		HEADER "","Empresa","Filial","Num.SC","Cod.Protheus","Produto","Descrição","Marca","Item Cot";
		Size C(739),C(228) Of oDlg Pixel;
		ColSizes 10,20,20,50,40,40,100,100;                                 
	On DBLCLICK ( aListBox1[oListBox1:nAt,1] := !(aListBox1[oListBox1:nAt,1]), oListBox1:Refresh() )
	oListBox1:SetArray(aListBox1)
	Else
		@ C(008),C(004) ListBox oListBox1 Fields ;
		HEADER "","Empresa","Filial","Num.SC","Cod.Protheus","Produto","Descrição","Marca","Item Cot";
		Size C(522),C(120) Of oDlg Pixel;
		ColSizes 10,20,20,50,40,40,100,100;                                 
	On DBLCLICK ( aListBox1[oListBox1:nAt,1] := !(aListBox1[oListBox1:nAt,1]), oListBox1:Refresh() )
	oListBox1:SetArray(aListBox1)
    Endif
	// Cria ExecBlocks das ListBoxes
	oListBox1:bLine 		:= {|| {;                                           
	If(aListBox1[oListBox1:nAT,1],oOk,oNo),;
		aListBox1[oListBox1:nAT,02],;
		aListBox1[oListBox1:nAT,03],;
		aListBox1[oListBox1:nAT,04],;
		aListBox1[oListBox1:nAT,05],;
		aListBox1[oListBox1:nAT,06],;
		aListBox1[oListBox1:nAT,07],;
		aListBox1[oListBox1:nAT,08],;
		aListBox1[oListBox1:nAt,11]}} 
		
Return Nil                                                                                                                      

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)                                                         
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)                                                                

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CtrlArea º Autor ³Ricardo Mansano     º Data ³ 18/05/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºLocacao   ³ Fab.Tradicional  ³Contato ³ mansano@microsiga.com.br       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Static Function auxiliar no GetArea e ResArea retornando   º±±
±±º          ³ o ponteiro nos Aliases descritos na chamada da Funcao.     º±±
±±º          ³ Exemplo:                                                   º±±
±±º          ³ Local _aArea  := {} // Array que contera o GetArea         º±±
±±º          ³ Local _aAlias := {} // Array que contera o                 º±±
±±º          ³                     // Alias(), IndexOrd(), Recno()        º±±
±±º          ³                                                            º±±
±±º          ³ // Chama a Funcao como GetArea                             º±±
±±º          ³ P_CtrlArea(1,@_aArea,@_aAlias,{"SL1","SL2","SL4"})         º±±
±±º          ³                                                            º±±
±±º          ³ // Chama a Funcao como RestArea                            º±±
±±º          ³ P_CtrlArea(2,_aArea,_aAlias)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nTipo   = 1=GetArea / 2=RestArea                           º±±
±±º          ³ _aArea  = Array passado por referencia que contera GetArea º±±
±±º          ³ _aAlias = Array passado por referencia que contera         º±±
±±º          ³           {Alias(), IndexOrd(), Recno()}                   º±±
±±º          ³ _aArqs  = Array com Aliases que se deseja Salvar o GetArea º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAplicacao ³ Generica.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CtrlArea(_nTipo,_aArea,_aAlias,_aArqs)                       
Local _nN                                                                    
	// Tipo 1 = GetArea()                                                      
	If _nTipo == 1                                                             
		_aArea   := GetArea()                                                    
		For _nN  := 1 To Len(_aArqs)                                             
			DbSelectArea(_aArqs[_nN])                                              
			AAdd(_aAlias,{ Alias(), IndexOrd(), Recno()})                          
		Next                                                                     
	// Tipo 2 = RestArea()                                                     
	Else                                                                       
		For _nN := 1 To Len(_aAlias)                                             
			DbSelectArea(_aAlias[_nN,1])                                           
			DbSetOrder(_aAlias[_nN,2])                                             
			DbGoto(_aAlias[_nN,3])                                                 
		Next                                                                     
		RestArea(_aArea)                                                         
	Endif                                                                      
Return Nil   

************************************
Static Function fCarrega()
************************************
*
*

Local cQuery := ""

aListBox1 := {}

cQuery := " SELECT C8_FILIAL, C8_PRODUTO, C8_QUANT, C8_NUMSC, C8_ITEMSC, C8_ZTIPOPR, B1_ZREF1, B1_DESC, C8_ITEM, C8_CC, C8_FILENT, C8_ZAPLIC,  "
cQuery += " C8_ZMARCA, C8_NUMPRO, C8_VALIDA, C8_MOEDA, C8_ZFILFAT, C8_ZTODESC, C8_ZSOLIC, C8_TPDOC, C8_ZDENTRE, C8_ZOBSADI, C8_ZUSER "
cQuery += " FROM " + RetSqlName("SC8") + " SC8, " + RetSqlName("SB1") + " SB1 " 
cQuery += " WHERE C8_PRODUTO = B1_COD" 
cQuery += " AND C8_FILIAL = '" + cZFilAux + "'"
cQuery += " AND C8_NUM = '" + cZNumCot + "'"
cQuery += " AND SC8.D_E_L_E_T_ <> '*'"
cQuery += " AND SB1.D_E_L_E_T_ <> '*'"
cQuery += " GROUP BY C8_FILIAL,C8_PRODUTO,C8_QUANT,C8_NUMSC,C8_ITEM,C8_ITEMSC,C8_ZTIPOPR,B1_ZREF1,B1_DESC,C8_CC,C8_FILENT,C8_ZAPLIC,C8_ZMARCA,C8_NUMPRO,
cQuery += " C8_VALIDA,C8_MOEDA,C8_ZFILFAT,C8_ZTODESC,C8_ZSOLIC,C8_TPDOC,C8_ZDENTRE,C8_ZOBSADI,C8_ZUSER " 
cQuery += " ORDER BY C8_PRODUTO"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBFOR",.T.,.T.) 

dbSelectArea("TRBFOR")
dbgoTop()

if !Eof("TRBFOR")
    
	While !Eof("TRBFOR") 
	  //If (cProduto <> TRBFOR->C8_PRODUTO)
	   // cProduto := TRBFOR->C8_PRODUTO
		Aadd(aListBox1,{.F.,"","","","","","","","",0,"","","","","","","","","","","","","","",""})
		
		//"Empresa","Filial","Num.SC","Cod.Protheus","Produto","Descrição","Marca","Aplicação","Classificação";
		
		aListBox1[Len(aListBox1),01] := .F.
		aListBox1[Len(aListBox1),02] := "01"
		aListBox1[Len(aListBox1),03] := TRBFOR->C8_FILIAL
		aListBox1[Len(aListBox1),04] := TRBFOR->C8_NUMSC
		aListBox1[Len(aListBox1),05] := TRBFOR->C8_PRODUTO
		aListBox1[Len(aListBox1),06] := TRBFOR->B1_ZREF1
		aListBox1[Len(aListBox1),07] := TRBFOR->B1_DESC
		aListBox1[Len(aListBox1),08] := TRBFOR->C8_ZTIPOPR 
		aListBox1[Len(aListBox1),09] := TRBFOR->C8_ITEMSC
		aListBox1[Len(aListBox1),10] := TRBFOR->C8_QUANT
		aListBox1[Len(aListBox1),11] := TRBFOR->C8_ITEM
		aListBox1[Len(aListBox1),12] := TRBFOR->C8_CC
		aListBox1[Len(aListBox1),13] := TRBFOR->C8_FILENT
		aListBox1[Len(aListBox1),14] := TRBFOR->C8_ZAPLIC
		aListBox1[Len(aListBox1),15] := TRBFOR->C8_ZMARCA
		aListBox1[Len(aListBox1),16] := TRBFOR->C8_NUMPRO
		aListBox1[Len(aListBox1),17] := STOD(TRBFOR->C8_VALIDA) 
		aListBox1[Len(aListBox1),18] := TRBFOR->C8_MOEDA
		aListBox1[Len(aListBox1),19] := TRBFOR->C8_ZFILFAT
		aListBox1[Len(aListBox1),20] := TRBFOR->C8_ZTODESC
		aListBox1[Len(aListBox1),21] := TRBFOR->C8_ZSOLIC 
		aListBox1[Len(aListBox1),22] := TRBFOR->C8_TPDOC
		aListBox1[Len(aListBox1),23] := STOD(TRBFOR->C8_ZDENTRE)
		aListBox1[Len(aListBox1),24] := TRBFOR->C8_ZOBSADI
		aListBox1[Len(aListBox1),25] := TRBFOR->C8_ZUSER
	 // Endif	
		
		dbSelectArea("TRBFOR")
		dbSkip()
	
	enddo  

else
	Aadd(aListBox1,{.F.,"","","","","","",""})
endif
	
dbSelectArea("TRBFOR")
dbCloseArea("TRBFOR")   

oListBox1:SetArray( aListBox1 )

oListBox1:bLine := {|| { If(aListBox1[oListBox1:nAT,1],oOk,oNo),;
						 aListBox1[oListBox1:nAT,02],;
						 aListBox1[oListBox1:nAT,03],;
						 aListBox1[oListBox1:nAT,04],;
						 aListBox1[oListBox1:nAT,05],;
						 aListBox1[oListBox1:nAT,06],;
						 aListBox1[oListBox1:nAT,07],;
						 aListBox1[oListBox1:nAT,08]}}

oListBox1:Refresh()

return  

************************************
Static Function fConf()
************************************
*
*
Local nProMarc := 0
Local nItem    := 1
Local cLoja    := 'S'

For nX := 1 to Len(oGetDados1:aCols)
   if Empty(oGetDados1:aCols[nX,2])
    cLoja := 'N'
   endif
Next nX

If(cLoja == 'N')
MsgAlert("Favor informar a Loja do Fornecedor.")
return
Endif

For nXXCont := 1 To Len(aListBox1)
	if aListBox1[nXXCont,1]
		nProMarc++
	endif
Next

if nProMarc == 0
	ApMsgInfo("Escolha um produto para incluir...")
	return
endif

For nXXCont := 1 To Len(aListBox1)

	if aListBox1[nXXCont,1] 
	
		nItem := 1

		For XYYCont := 1 To Len(oGetDados1:aCols)
		
			if !oGetDados1:aCols[XYYCont,Len(oGetDados1:aCols[XYYCont])]  
			
				dbSelectArea("SC8")    
				if RecLock("SC8", .T.)
	   			SC8->C8_FORNECE := oGetDados1:aCols[XYYCont,1]
	            SC8->C8_LOJA    := oGetDados1:aCols[XYYCont,2] 
	            SC8->C8_ZHORA   := SubStr(Time(),1,5)
				SC8->C8_FILIAL  := aListBox1[nXXCont,3] 
				SC8->C8_NUM     := cZNumCot
		 		SC8->C8_ZUSER   := aListBox1[nXXCont,25]//cXXCodUsr 
				SC8->C8_EMISSAO := dDataBase 
				SC8->C8_PRODUTO := aListBox1[nXXCont,5]
				SC8->C8_ITEM    := aListBox1[nXXCont,11] 
				SC8->C8_IDENT   := aListBox1[nXXCont,11]//StrZero(nItem,4)  
				SC8->C8_QUANT   := aListBox1[nXXCont,10]
				SC8->C8_ZQUANTIN:= aListBox1[nXXCont,10]
				SC8->C8_NUMSC   := aListBox1[nXXCont,4]    
				SC8->C8_ITEMSC  := aListBox1[nXXCont,09]    
				SC8->C8_ZTIPOPR := aListBox1[nXXCont,08]    
				SC8->C8_ZDESCRI := Posicione("SB1",1,xFilial("SB1")+aListBox1[nXXCont,5],"B1_DESC") 
				SC8->C8_UM      := Posicione("SB1",1,xFilial("SB1")+aListBox1[nXXCont,5],"B1_UM")   
	    		SC8->C8_ZSTATUS := "3"    
	    		SC8->C8_ZEMP    := aListBox1[nXXCont,2]
	    		SC8->C8_CC      := aListBox1[nXXCont,12]
	    		SC8->C8_FILENT  := aListBox1[nXXCont,13]
	    		SC8->C8_ZAPLIC  := aListBox1[nXXCont,14]
	    		SC8->C8_ZMARCA  := aListBox1[nXXCont,15]
	    		SC8->C8_NUMPRO  := aListBox1[nXXCont,16]
	    		SC8->C8_VALIDA  := aListBox1[nXXCont,17]
	    		SC8->C8_MOEDA   := aListBox1[nXXCont,18]
	    		SC8->C8_ZFILFAT := aListBox1[nXXCont,19]
	    		SC8->C8_ZTODESC := aListBox1[nXXCont,20]
	    		SC8->C8_ZSOLIC  := aListBox1[nXXCont,21]
	    		SC8->C8_TPDOC   := aListBox1[nXXCont,22]
	    		SC8->C8_FORNOME := Posicione("SA2",1,xFilial("SA2")+oGetDados1:aCols[XYYCont,1]+oGetDados1:aCols[XYYCont,2],"A2_NOME")
	    		SC8->C8_ZDENTRE := aListBox1[nXXCont,23]
	    		SC8->C8_ZOBSADI := aListBox1[nXXCont,24]
					MsUnLock() 			
				endif 
				
				nItem := nItem + 1   
				
				dbSelectArea("SZ2") 
				cNumOcor := ""
				cNumOcor := GetSxENum("SZ2","Z2_NUMERO") 
				ConfirmSX8()
				
	 			dbSelectArea("SZ2")   
	 			
				if RecLock("SZ2", .T.)      
					SZ2->Z2_FILIAL   := aListBox1[nXXCont,3] 
					SZ2->Z2_NUMERO   := cNumOcor
					SZ2->Z2_CODIGO   := '002'
					SZ2->Z2_NUMSC    := aListBox1[nXXCont,4] 
					SZ2->Z2_ITEMSC   := aListBox1[nXXCont,09]
					SZ2->Z2_NUMCOT   := cZNumCot
					SZ2->Z2_PRODUTO  := aListBox1[nXXCont,5]
					SZ2->Z2_CODUSR   := cXXCodUsr
					SZ2->Z2_NOMEUSR  := UsrRetName(cXXCodUsr)
					SZ2->Z2_DATA     := DATE()
					SZ2->Z2_HORA     := TIME()
			    	SZ2->Z2_MOTIVO   := "GERA COTAÇÃO"
			    	SZ2->Z2_EMAIL1   := ""
			    	SZ2->Z2_EMAIL2   := ""
			    	SZ2->Z2_EMAIL3   := ""
			    	SZ2->Z2_EMAIL4   := ""
			    	SZ2->Z2_EMAIL5   := ""
			 		MsUnLock()  
				Endif				    
			
			endif					
		
		Next
	
	endif

Next  

//Envia e-mail para cadas fornecedor com o endereço informado
For nX := 1 to Len(oGetDados1:aCols)    
		
	If !oGetDados1:aCols[nX,Len(oGetDados1:aCols[nX])]        .And. ;
	   !Empty(oGetDados1:aCols[nX,1]) .And. ;
	   !Empty(oGetDados1:aCols[nX,2]) .And. ;
	   !Empty(oGetDados1:aCols[nX,4]) 
	
		MsAguarde( {|lEnd|u_AFATR05(cZNumCot,;
			oGetDados1:aCols[nX,1],;
			oGetDados1:aCols[nX,2],;
			Alltrim(oGetDados1:aCols[nX,4]),cZFilAux)},"Aguarde","Enviando e-mail... Aguarde... ",.T.)
	Endif
Next

oDlg:End()

return  

************************************
Static Function fTodos()
************************************
*
* 
Local nTodos := 1

For nTodos := 1 to Len(aListBox1)
	aListBox1[nTodos,1] := .T.
Next                            

return

************************************
Static Function fDesmarca()
************************************
*
* 
Local nTodos := 1

For nTodos := 1 to Len(aListBox1)
	aListBox1[nTodos,1] := .F.
Next                            

return
