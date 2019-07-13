#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³fChave    ³ Autor ³ Max Rocha             ³ Data ³28/08/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ TOPMIX           ³Contato ³ max.rocha@topmix.com.br        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza Chave nas tabelas SF1/SF3/STF                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function fChave()
// Variaveis Locais da Funcao
Local coGETChave	 := Space(44)
Local coGETCnpj	 := Space(20)
Local coGETCod	 := Space(6)
Local coGETDoc	 := Space(10)
Local coGETEspec	 := Space(10)
Local coGETLoja	 := Space(02)
Local coGETRazao	 := Space(50)
Local coGetSerie	 := Space(03)
Local coGETValor	 := Space(25)
// Variaveis da Funcao de Controle e GertArea/RestArea
Local _aArea   		:= {}
Local _aAlias  		:= {}

private ooGETChave
private ooGETCnpj
private ooGETCod
private ooGETDoc
private ooGETEspec
private ooGETLoja
private ooGETRazao
private ooGetSerie
private ooGETValor
// Variaveis Private da Funcao
Private _oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        

Private cChave := space(44)
Private cCNPJ  := space(14)
Private cDOC   := space(9)
Private cSERIE := space(3)
Private cCodFor:= ""
Private cLojFor:= ""


DEFINE MSDIALOG _oDlg TITLE "Chave NF-e/CT-e" FROM C(246),C(225) TO C(454),C(786) PIXEL

// Defina aqui a chamada dos Aliases para o GetArea
CtrlArea(1,@_aArea,@_aAlias,{"SF1","SA2"}) // GetArea

	// Cria as Groups do Sistema
	@ C(029),C(005) TO C(096),C(275) LABEL "" PIXEL OF _oDlg

	// Cria Componentes Padroes do Sistema
	@ C(004),C(004) Say "Chave:" Size C(019),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
   @ C(011),C(005) MsGet ooGETChave Var coGETChave Size C(228),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(010),C(234) Button "Pesquisa" Size C(037),C(011) PIXEL OF _oDlg Action(U_fPesq(coGETChave))
	
	@ C(032),C(007) Say "Documento" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(032),C(070) Say "Serie" Size C(014),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(032),C(102) Say "Espécie" Size C(021),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(032),C(135) Say "Valor" Size C(014),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	//@ C(037),C(233) Button "Salvar" Size C(037),C(012) PIXEL OF _oDlg Action(fSalva())
	@ C(041),C(007) MsGet ooGETDoc Var coGETDoc Size C(060),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(041),C(070) MsGet ooGETSerie Var coGETSerie Size C(030),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(041),C(102) MsGet ooGETEspec Var coGETEspec Size C(030),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(041),C(135) MsGet ooGETValor Var coGETValor Size C(060),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(052),C(007) Say "Código" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(052),C(070) Say "Loja" Size C(012),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(052),C(102) Say "Cnpj" Size C(012),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(058),C(233) Button "Limpar" Size C(037),C(012) PIXEL OF _oDlg Action(u_fLimpar())
	@ C(060),C(007) MsGet ooGETCod Var coGETCod Size C(060),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(060),C(070) MsGet ooGETLoja Var coGETLoja Size C(030),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(060),C(102) MsGet ooGETCnpj Var coGETCnpj Size C(093),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(072),C(007) Say "Razão Social" Size C(033),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(078),C(233) Button "Sair" Size C(037),C(012) PIXEL OF _oDlg Action(_oDlg:End())
	@ C(081),C(007) MsGet ooGETRazao Var coGETRazao Size C(222),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
                                          
ooGETCnpj:lReadOnly := .T.
ooGETCod:lReadOnly := .T.
ooGETDoc:lReadOnly := .T.
ooGETEspec:lReadOnly := .T.
ooGETLoja:lReadOnly := .T.
ooGETRazao:lReadOnly := .T.
ooGetSerie:lReadOnly := .T.
ooGETValor:lReadOnly := .T.

CtrlArea(2,_aArea,_aAlias) // RestArea

ACTIVATE MSDIALOG _oDlg CENTERED 

Return(.T.)                     

//FUNCAO LOCALIZA NOTAS
User Function fPesq ( coGETChave )


cChave := ooGETChave:cText 
cCNPJ  := substr(cChave, 7, 14)  
cSERIE := substr(cChave, 23, 3)  
cDOC   := substr(cChave, 26, 9)
cCodFor := ""
cLojFor := ""


//Localiza fornecedor codigo e loja
DbSelectArea("SA2") 
DbSetOrder(3)                      
dbGoTop()                         


If ! DBSeek(xFilial("SA2") + cCNPJ )
   Alert("Erro: CNPJ de Fornecedor não encontrado...")
   
else
		IF DBSeek(xFilial("SA2") + cCNPJ) 
			While SA2->(!Eof()) .And. SA2->A2_FILIAL == XFILIAL("SA2") .AND. SA2->A2_CGC == CCNPJ
				If SA2->A2_MSBLQL == "1"
					SA2->(dbSkip())
				  	Loop				  
				Else
	    			cCodFor := SA2->A2_COD
	   			cLojFor := SA2->A2_LOJA
	   			Exit			
				EndIf
				SA2->(dbSkip())
			EndDo 
     	Endif	
EndIF

//Procura por nota fiscal na filial:
DbSelectArea("SF1") 
DbSetOrder(2)
dbGoTop()  


If ! DBSeek(xFilial("SF1") + cCodFor + cLojFor + cDOC )
   Alert("Erro: Não encontrado nenhuma Nota Fiscal/CT-e com Chave de pesquisa. Verifique o lançamento da Nota. " )
Else
	ooGETDoc:cText     := SF1->F1_DOC
	ooGETSerie:cText   := SF1->F1_SERIE
	ooGETEspec:cText   := SF1->F1_ESPECIE
	ooGETValor:cText   := Transform(SF1->F1_VALBRUT, "@E 999,999,999.99" )

	ooGETDoc:cText        := cDOC
	ooGETSerie:cText      := cSerie
	ooGETCnpj:cText       := transform(cCNPJ, "@R 99.999.999/9999-99")

	ooGETCod:cText   := SA2->A2_COD 
   ooGETLoja:cText  := SA2->A2_LOJA
	ooGETRazao:cText := SA2->A2_NOME
	
	ooGETDoc:Refresh()
	ooGETSerie:Refresh()    
	ooGETCnpj:Refresh() 
	
	ooGETCod:Refresh()
	ooGETLoja:Refresh()
	ooGETRazao:Refresh()
		          
	//Gravar dados...
	If Empty(Rtrim(SF1->F1_CHVNFE)) 
		If MsgYesNo( "Confirma a atualização da Nota Fiscal/Livros Fiscais?", "ATENÇÃO:" )
	    	//SF1
	 		cQrySF1 := " UPDATE "+RetSQLName("SF1")
	 		cQrySF1 += " SET F1_CHVNFE = '"+cChave + "'"
	 		cQrySF1 += " WHERE F1_FILIAL      = '" + xFilial("SF1")  + "'" 
			cQrySF1 += "       AND F1_DOC     = '" + SF1->F1_DOC     + "'" 
			cQrySF1 += "       AND F1_SERIE   = '" + SF1->F1_SERIE   + "'" 
			cQrySF1 += "       AND F1_FORNECE = '" + SF1->F1_FORNECE + "'" 
			cQrySF1 += "       AND F1_LOJA    = '" + SF1->F1_LOJA    + "'" 
			TCSQLExec(cQrySF1)
	
	    	//SF3
	 		cQrySF3 := " UPDATE "+RetSQLName("SF3")
	 		cQrySF3 += " SET F3_CHVNFE = '"+cChave + "'"
	 		cQrySF3 += " WHERE F3_FILIAL      = '" + xFilial("SF3")  + "'" 
			cQrySF3 += "       AND F3_NFISCAL = '" + SF1->F1_DOC     + "'" 
			cQrySF3 += "       AND F3_SERIE   = '" + SF1->F1_SERIE   + "'" 
			cQrySF3 += "       AND F3_CLIEFOR = '" + SF1->F1_FORNECE + "'" 
			cQrySF3 += "       AND F3_LOJA    = '" + SF1->F1_LOJA    + "'" 
			TCSQLExec(cQrySF3)
	
	    	//SFT
	 		cQrySFT := " UPDATE "+RetSQLName("SFT")
	 		cQrySFT += " SET FT_CHVNFE = '"+cChave + "'"
	 		cQrySFT += " WHERE FT_FILIAL      = '" + xFilial("SF3")  + "'" 
			cQrySFT += "       AND FT_NFISCAL = '" + SF1->F1_DOC     + "'" 
			cQrySFT += "       AND FT_SERIE   = '" + SF1->F1_SERIE   + "'" 
			cQrySFT += "       AND FT_CLIEFOR = '" + SF1->F1_FORNECE + "'" 
			cQrySFT += "       AND FT_LOJA    = '" + SF1->F1_LOJA    + "'" 
			TCSQLExec(cQrySFT)
			
			ooGETDoc:cText     := ""
			ooGETSerie:cText   := ""
			ooGETEspec:cText   := ""
			ooGETValor:cText   := ""

			ooGETDoc:cText     := ""
			ooGETSerie:cText   := ""
			ooGETCnpj:cText    := ""

			ooGETChave:cText   := SPACE(44)
   		
			ooGETCod:cText     := ""
			ooGETLoja:cText    := ""
			ooGETRazao:cText   := ""
         ooGETChave:SetFocus()
      Else
         ooGETChave:SetFocus()
	   EndIF
	EndIF
	
EndIF

Return (.t.)

User Function  fLimpar()
	ooGETDoc:cText     := ""
	ooGETSerie:cText   := ""
	ooGETEspec:cText   := ""
	ooGETValor:cText   := ""

	ooGETDoc:cText     := ""
	ooGETSerie:cText   := ""
	ooGETCnpj:cText    := ""

	ooGETChave:cText   := SPACE(44)
   		
	ooGETCod:cText     := ""
	ooGETLoja:cText    := ""
	ooGETRazao:cText   := ""
   ooGETChave:SetFocus()
Return (.t.)



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
