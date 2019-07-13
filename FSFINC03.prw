#Include "protheus.ch"          
#Define DMPAPER_A4 9 // A4 210 x 297 mm  

//-------------------------------------------------------------------
/*/{Protheus.doc} FSFINC03
Cadastro de Pre Recebimento

@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11
@obs	      Cadastro de Pre Recebimento
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSFINC03

Local aCores    	:= {	{ 'P06_STATUS=="P"','ENABLE' 		 },;//Pendente
								{ 'P06_STATUS=="I"','BR_AMARELO'  },;//Integrados
								{ 'P06_STATUS=="E"','BR_VIOLETA'  },;//Integrados em compensação
								{ 'P06_STATUS=="D"','BR_BRANCO'  },; //Cheque devolvido
								{ 'P06_STATUS=="C"','DISABLE'		 }} //Cancelado


Private cCadastro := "Cadastro de Pré - Recebimento"
Private aRotina	:= {}
Private cAlias		:= "P06"        
                    
AaDD(aRotina, {"Pesquisar", 				 "AxPesqui"   , 0 , 1})  	 	 	
AaDD(aRotina, {"Visualizar",				 "AxVisual"	  , 0 , 2})  	 	 	
AaDD(aRotina, {"Incluir", 	 				 "AxInclui"	  , 0 , 3})  	 	 	
AaDD(aRotina, {"Alterar",   				 "U_FSC03MNT" , 0 , 4})  	 	 	
AaDD(aRotina, {"Excluir",   				 "U_FSC03MNT" , 0 , 5})  	 	 	
AaDD(aRotina, {"Registrar Compensação", "U_FSC03MNT" , 0 , 6})  	 	 	
AaDD(aRotina, {"Gerar Relatorio ID",  	 "U_FSRELID"  , 0 , 7})  	 	 	
AaDD(aRotina, {"Cancelar",  				 "U_FSC03MNT" , 0 , 8})  
AaDD(aRotina, {"Cheque Devolvido", 		 "U_FSCheqDe" , 0 , 9})  
AaDD(aRotina, {"Legenda",  				 "U_FSP06Leg" , 0 , 9})  


dbSelectArea("P06")
dbSetOrder(1)//P06_FILIAL, P06_ID, R_E_C_N_O_, D_E_L_E_T_
dbGotop()

mBrowse(6,1,22,75,"P06",,,,,,aCores)

Return Nil    


//-------------------------------------------------------------------
/*/{Protheus.doc} FSP06Leg
Legenda

@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11
@obs	      Cadastro de Pre Recebimento
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSP06Leg    

Local aLegenda := {}

aAdd(aLegenda, {"ENABLE"    	,"Pendente"})
aAdd(aLegenda, {"BR_AMARELO"	,"Integrados"})
aAdd(aLegenda, {"BR_VIOLETA" 	,"Integrados sem compensação"})
aAdd(aLegenda, {"DISABLE"   	,"Cancelado"})
aAdd(aLegenda, {"BR_BRANCO" 	,"Cheque devolvido"})
BrwLegenda(cCadastro,"Legenda" ,aLegenda)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FSCriaID
Função responsavel por gerar o código do ID

@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11
@obs	      Cadastro de Pre Recebimento
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSCriaID()                                     
Local aAreas  := {P06->(GetArea()),GetArea()}
Local cChave := FGetChav()
Local lloop  := .T.

P06->(dbSetOrder(1)) // P06_FILIAL, P06_ID
While lloop
	If P06->(dbSeek(xFilial("P06") + cChave)) 
		cChave := FGetChav() // Chamo a chave de novo
	Else
		If MayIUseCode(cChave)
			lloop := .F.
		Else
			cChave := FGetChav() // Chamo a chave de novo
		EndIf
	EndIf
EndDo

Return cChave


//-------------------------------------------------------------------
/*/{Protheus.doc} FGetChav
Retorna a chave

@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11
@obs	      Cadastro de Pre Recebimento
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FGetChav()

Local cHora	 := ""

cQuery := "SELECT CONVERT(VARCHAR(23), SYSDATETIME(), 126) HORAATUAL"

dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBQRY",.F.,.T.)

If (TRBQRY->(!Eof())) 
	cHora := TRBQRY->HORAATUAL
	TRBQRY->(dbCloseArea())
EndIf

cHoras := SubStr(cHora,12)

//cChave := PadL(AllTrim(SubStr(FWCodFil(),5,2)), 3 , "0")				// Filial que estou logado 
cChave := PadL(AllTrim(SubStr(SM0->M0_CODFIL,4,3)), 3 )				// Filial que estou logado
//cChave += AllTrim(SubStr(cValToChar(Year(dDataBase)),3,2))  		// Ano corrente 
cChave += AllTrim(SubStr(cValToChar(Year(Date())),3,2))  		// Ano corrente
cChave += AllTrim(SubStr(cHoras,10,2))                       		// Décimos de segundos
//cChave += AllTrim(cValToChar(Day(dDataBase)))   						// Dia da data corrente
cChave += AllTrim(cValToChar(SUBS(DTOS(Date()),7,2)))   						// Dia da data corrente
cChave += AllTrim(SubStr(cHoras,1,2))                       		// Hora do sistena
//cChave += AllTrim(Padl(cValToChar(Month(dDataBase)),  2 , "0"))   // Mês da data corrente 
cChave += AllTrim(Padl(cValToChar(Month(Date())),  2 , "0"))   // Mês da data corrente
cChave += AllTrim(SubStr(cHoras,4,2))                       		// Minuto da hora do sistema
cChave += AllTrim(SubStr(cHoras,7,2))                       		// Segundos da hora do sistema
cChave += u_FSFMod11(cChave, 1, 9)	 		                   		// Modulo11

Return AllTrim(cChave) 


//-------------------------------------------------------------------
/*/{Protheus.doc} FSP06NUM
Retorna o proximo campo

@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11
@obs	      Cadastro de Pre Recebimento
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSP06NUM(cPreFix)     

Local lRetFun := .T.
Local aAreas  := {P06->(GetArea()),SE1->(GetArea()),GetArea()}
Local	cCodFin  := ""
Local	cQuery 	:= ""	
Local	nTotal 	:= 0
Local cCampo 	:= "P06_NUM"
Local cAlias	:= "P06" 
Local nTamSeq	:= 9   
Local lloop		:= .T.

If (Select("TMPQRY")!= 0)
   TMPQRY->(dbCloseArea())
EndIf

cQuery := CHR(13) + "SELECT MAX("+cCampo+") AS CODIGO " 
cQuery += CHR(13) + "FROM " + RetSqlName(cAlias) + " 
cQuery += CHR(13) + "WHERE D_E_L_E_T_ <> '*' "
cQuery += CHR(13) + "AND P06_PREFIX = '" + cPreFix + "'"  
cQuery += CHR(13) + "HAVING MAX(P06_NUM) <> NULL "

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TMPQRY",.F.,.T.) 
TMPQRY->(dbGoTop())

cCodFin := AllTrim(TMPQRY->CODIGO)

SE1->(dbSetOrder(1))  //E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_D_E_L_
P06->(dbSetOrder(3))  //P06_FILIAL, P06_PREFIX, P06_NUM, R_E_C_N_O_, D_E_L_E_T_

If !TMPQRY->(Eof())
   cCodFin := Soma1(cCodFin)
Else
	cCodFin := StrZero(1,nTamSeq)
Endif

While lloop
	//Se existe o código na SE1 ou na P06
	If SE1->(dbSeek(xFilial("SE1") + cPreFix + cCodFin) .Or. P06->(dbSeek(xFilial("P06") + cPreFix + cCodFin))) 
		cCodFin := Soma1(cCodFin)
	Else
		If MayIUseCode(cCodFin)
			lloop := .F.
		Else
		   cCodFin := Soma1(cCodFin)
		EndIf
	EndIf	
EndDo

M->P06_NUM = cCodFin 

aEval(aAreas, {|x| RestArea(x) }) 

Return lRetFun      


//-------------------------------------------------------------------
/*/{Protheus.doc} FSRELID
Gera relatorio ID

@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11
@obs	      Cadastro de Pre Recebimento
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSRELID(cAlias, nReg, nOpc)

Local aAreas  := {P06->(GetArea()),SA1->(GetArea()),SA6->(GetArea()),GetArea()}
Local oPrint := Nil  
Local nAltAtu := 0

P06->(dbGoTo(nReg))  

If MsgYesNo("Deseja realmente imprimir o Relatório ID? Uma vez impresso o Pré-Recebimento não poderá ser alterado ou excluido!")

	//Posiciona SA1 - Clientes 
	SA1->(dbSetOrder(1)) // Filial + Cliente + Loja
	SA1->(dbSeek(xFilial("SA1") + P06->P06_CODCLI + P06->P06_LOJA))     
	
	//Posiciona SA6 - Bancos
	SA6->(dbSetOrder(1)) // A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON, R_E_C_D_E_L_
	If ! SA6->(dbSeek(xFilial("SA6") + P06->P06_BANCO + P06->P06_AGENCI + P06->P06_NUMCON))     
		MsgAlert("Conta não cadastrada na tabela de bancos - SA6", "Aviso")		 	     
	   Return .F.
	Endif
	
	//ExistChav("SA6",M->A6_COD + M->A6_AGENCIA + M->A6_NUMCON)            
	
	// Monta objeto para impressão
	oPrint := TMSPrinter():New("Relatório de Código de Identificação de Depósito")
	oPrint:SetPortrait()
	oPrint:Setup()   
	oPrint:setPaperSize(DMPAPER_A4)
	  
	oPrint:StartPage()            
		    
	// Cabeçalhos
	oFont1 := TFont():New( 'Arial', 10, 18,, .T.)
	
	//Itens
	oFont2 := TFont():New( 'Arial', 10, 12,, .T.)
	
	nAltAtu := FCriaBox(oPrint,oFont1, 0 ,100,nAltAtu, 10, "CÓDIGO DE IDENTIFICAÇÃO DO DEPOSITANTE",.T.,.T.)
	nAltAtu := FCriaBox(oPrint,oFont1, 0 ,100,nAltAtu, 08, "DEPOSITANTE",.T.,.T.)
	
	FCriaBox(oPrint,oFont2, 0 ,30,nAltAtu, 03, "Código de Identificação",.F.,.F.)
	nAltAtu := FCriaBox(oPrint,oFont2, 30,70,nAltAtu, 03, P06->P06_ID,.F.,.F.)
	                                                                                                      
	FCriaBox(oPrint,oFont2, 0 ,30,nAltAtu, 03, "CPF/CNPJ do Cliente:",.F.,.F.)
	nAltAtu := FCriaBox(oPrint,oFont2, 30,70,nAltAtu, 03,Iif((SA1->A1_PESSOA == 'F') ,;
																			   Transform(SA1->A1_CGC , "@R 999.999.999-99") , ;
																			 	Transform(SA1->A1_CGC , "@R 99.999.999/9999-99") ),.F.,.F.)
	
	FCriaBox(oPrint,oFont2, 0 ,30,nAltAtu, 03, "Nome do Cliente",.F.,.F.)
	nAltAtu := FCriaBox(oPrint,oFont2, 30,70,nAltAtu, 03, SA1->A1_NOME  ,.F.,.F.)
	                                                                                                  
	FCriaBox(oPrint,oFont2, 0 ,30,nAltAtu, 03, "Endereço",.F.,.F.)
	nAltAtu := FCriaBox(oPrint,oFont2, 30,70,nAltAtu, 03, SA1->A1_END,.F.,.F.)
	
	FCriaBox(oPrint,oFont2, 0 ,30,nAltAtu, 03, "Bairro",.F.,.F.)
	nAltAtu := FCriaBox(oPrint,oFont2, 30,70,nAltAtu, 03, SA1->A1_BAIRRO,.F.,.F.)
	
	FCriaBox(oPrint,oFont2, 0 ,30,nAltAtu, 03, "Cidade",.F.,.F.)
	nAltAtu := FCriaBox(oPrint,oFont2, 30,70,nAltAtu, 03, SA1->A1_MUN,.F.,.F.)
	
	FCriaBox(oPrint,oFont2, 0 ,30,nAltAtu, 03, "Estado",.F.,.F.)
	nAltAtu := FCriaBox(oPrint,oFont2, 30,70,nAltAtu, 03, SA1->A1_EST,.F.,.F.)
	
	FCriaBox(oPrint,oFont2, 0 ,30,nAltAtu, 03, "Fone",.F.,.F.)
	nAltAtu := FCriaBox(oPrint,oFont2, 30,70,nAltAtu, 03, "(" + SA1->A1_DDD + ") " + Transform(SA1->A1_TEL,PesqPict("SA1","A1_TEL")),.F.,.F.)
	
	nAltAtu := FCriaBox(oPrint,oFont1, 0 ,100,nAltAtu, 08, "FAVORECIDO",.T.,.T.)
	
	FCriaBox(oPrint,oFont2, 0 ,30,nAltAtu, 03, "Razão Social",.F.,.F.)
	
	nAltAtu := FCriaBox(oPrint,oFont2, 30,70,nAltAtu, 03, GetNewPar("FS_RSOCIAL", "TopMix Engenharia e Tecnologia de concreto S/A"),.F.,.F.) 
	
	FCriaBox(oPrint,oFont2, 0 ,30,nAltAtu, 03, "Banco",.F.,.F.)
	nAltAtu := FCriaBox(oPrint,oFont2, 30,70,nAltAtu, 03, P06->P06_BANCO + " - " + SA6->A6_NOME ,.F.,.F.)
	
	FCriaBox(oPrint,oFont2, 0 ,30,nAltAtu, 03, "Agencia",.F.,.F.)
	nAltAtu := FCriaBox(oPrint,oFont2, 30,70,nAltAtu, 03, P06->P06_AGENCI + " - " + SA6->A6_DVAGE ,.F.,.F.)
	
	FCriaBox(oPrint,oFont2, 0 ,30,nAltAtu, 03, "Numero da conta",.F.,.F.)
	nAltAtu := FCriaBox(oPrint,oFont2, 30,70,nAltAtu, 03, P06->P06_NUMCON + " - " + SA6->A6_DVCTA ,.F.,.F.)
	
	FCriaBox(oPrint,oFont2, 0 ,30,nAltAtu, 03, "Valor",.F.,.F.)
	nAltAtu := FCriaBox(oPrint,oFont2, 30,70,nAltAtu, 03, "R$ " + AllTrim(Transform(P06->P06_VALOR,PesqPict("P06","P06_VALOR"))),.F.,.F.)

	FCriaBox(oPrint,oFont2, 0 ,30,nAltAtu, 03, "CNPJ",.F.,.F.)
	nAltAtu := FCriaBox(oPrint,oFont2, 30,70,nAltAtu, 03,Transform(SA6->A6_CGC , "@R 99.999.999/9999-99") ,.F.,.F.)
	
	// Visualiza a impressão
	oPrint:EndPage()     
	oPrint:Preview()      
	
	If Empty(P06->P06_DIMPRE)
		P06->(RecLock("P06",.F.))
		P06->P06_DIMPRE := dDataBase
		P06->(MsUnlock())		
	EndIf

EndIf
	
aEval(aAreas, {|x| RestArea(x) }) 

Return Nil       


//-------------------------------------------------------------------
/*/{Protheus.doc} FCriaBox
Função para imprimir box

@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11
@obs	      Cadastro de Pre Recebimento
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FCriaBox(oPrint,oFont, nPerX,nPercLarg,nPercY,nPercAlt, cTexto,lCenterH,lCenterV)

Local nMargem := 100
Local nHorSize	:= oprint:NHORZRES() - nMargem * 2
Local nVertSize:= oprint:NVERTRES() - nMargem * 2
Local nRetY := 0 
Default lCenterH := .F.
Default lCenterV := .F.

nRetY := nPercY  + nPercAlt

//Passando os valores informados de percentual para coordenadas físicas
nPerX		:= nMargem + nPerX	* nHorSize / 100
nPercLarg:= nPercLarg * nHorSize / 100
nPercY	:=	nMargem + nPercY * nVertSize / 100
nPercAlt	:= nPercAlt * nVertSize / 100

oPrint:Box(nPercY,nPerX, nPercY + nPercAlt,nPerX + nPercLarg)

If(!Empty(cTexto))

	If(lCenterH)
		nPerX := nMargem/2 + nPercLarg/2 - oPrint:GetTextWidth(cTexto,oFont) / 2                                                             
	Else
		nPerX+= 20 //Dando uma distáncia da margem
	EndIf     
	
	If(lCenterV)
      nPercY += nMargem/2  +  nPercAlt/ 2  - oPrint:GetTextHeight(cTexto,oFont) 
 	Else
	 	nPercY+= 20//Dando uma distáncia da margem
	EndIf     
	
	oPrint:Say(nPercY,nPerX,cTexto ,oFont,nPercLarg)
	
EndIf

Return nRetY    


//-------------------------------------------------------------------
/*/{Protheus.doc} FSC03MNT
Manutenção na tela de pré recebimento

@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11
@obs	      Cadastro de Pre Recebimento
@params 		nOpc - 4  - Alterar
				nOpc - 5  - Excluir
				nOpc - 6  - Registrar compensação
				nOpc - 8  - Cancelar
Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSC03MNT(cAlias, nReg, nOpc)
Local nOpca := 0

Local dDate := cTod("  /  /  ") 

Local lErro := .F.


If nOpc == 4 .Or. nOpc == 5 .Or. nOpc == 8 
	//Se Pendente é o Relatorio de ID ainda não tenha sido gerado
	If P06->P06_STATUS == "P" .And. Empty(P06->P06_DIMPRE)
		
		//Tramento para alteração
		If (nOpc == 4)
			FAltera(cAlias, nReg, nOpc)
		//Tramento para exclusao
		ElseIf (nOpc == 5)
			FExclui(cAlias, nReg, nOpc)
		Else
			MsgAlert("Este registro somente pode ser Alterado ou Excluido!", "Aviso")		 
		EndIf
		
	
	//Se Pendente e o Relatorio de ID tenha sido gerado
	ElseIf P06->P06_STATUS == "P" .And. !Empty(P06->P06_DIMPRE)
		
		If P06->P06_STATUS == "P"
	   	
	   	If (nOpc == 8)
		   	FCancela(cAlias, nReg, nOpc)
	   	Else
	   		MsgInfo("Este registro somente pode ser Cancelado!", "Aviso")		 
	   	EndIf
	   
	   Else
	   	MsgInfo("Titulo já integrado nenhuma ação pode ser realizada!", "Aviso")		 
	   EndIf
	
	ElseIf P06->P06_STATUS == "E" 
	    
		If (nOpc == 8)
		  	FCancela(cAlias, nReg, nOpc)
	   Else
	   	MsgInfo("Este registro somente pode ser Cancelado!", "Aviso")		 
	   EndIf
	   
	Else
		
		If P06->P06_STATUS == "C"
			MsgInfo("Titulo já cancelado nenhuma ação pode ser realizada!", "Aviso")		 
		EndIf
		
		If P06->P06_STATUS == "I"
			MsgAlert("Titulo já integrado nenhuma ação pode ser realizada!", "Aviso")		 
		EndIf
	
	EndIf

ElseIf P06->P06_STATUS <> "C"
	
	//Se pendente ou integrado com compensação
	If P06->P06_STATUS == "P" .Or. P06->P06_STATUS == "E"
      
    	If MsgYesNo("Deseja Registrar a compensação?")
		   
		   //Pendente 
		   If P06->P06_STATUS == "P"
		   	If FGetDate(@dDate)
		   		MsgRun("Efetuando lançamento de Titulos!","Por favor, Aguarde....",{|| lErro :=	u_FGeraSE1(nReg,dDate)})	
	   			If !lErro
	   				MsgInfo("Compensação registrada com SUCESSO!", "Aviso")		
	   			Else
	   				MsgAlert("O processo não executado, entre em contado com administrador do sistema!", "Aviso")		
	   			EndIf
		   	EndIf
		   EndIf	
		   
		   //Integrado parcialmente
		   If P06->P06_STATUS == "E"
		   	
		   	dDate := P06->P06_DEPOSI
		   	
		   	If FGetDate(@dDate)
		   		MsgRun("Efetuando lançamento de Titulos!","Por favor, Aguarde....",{|| lErro :=	u_FGeraSE1(nReg,dDate)})	
	   			If !lErro
	   				MsgInfo("Compensação registrada com SUCESSO!", "Aviso")		
	   			Else
	   				MsgAlert("O processo não executado, entre em contado com administrador do sistema!", "Aviso")		
	   			EndIf
		   	EndIf
		   
		   EndIf	
		   
		EndIf			
		
		//Reliza lançamento de titulos
	Else
	 	
	 	If P06->P06_STATUS == "I"
			MsgAlert("Titulo já integrado nenhuma ação pode ser realizada!", "Aviso")		 
		EndIf
		
	EndIf
	
Else
	If P06->P06_STATUS == "C"
		MsgInfo("Titulo já cancelado nenhuma ação pode ser realizada!", "Aviso")		 
	EndIf
		
	If P06->P06_STATUS == "I"
		MsgAlert("Titulo já integrado nenhuma ação pode ser realizada!", "Aviso")		 
	EndIf
	
	If P06->P06_STATUS == "D"
		MsgAlert("Cheque devolvido nenhuma operação é permitida!", "Aviso")		 
	EndIf
EndIf

Return Nil    


//-------------------------------------------------------------------
/*/{Protheus.doc} FAltera
Manutenção na tela de pré recebimento

@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11
@obs	      Cadastro de Pre Recebimento

Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FAltera(cAlias, nReg, nOpc)

AxAltera(cAlias,nReg,4)		

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FExclui
Manutenção na tela de pré recebimento

@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11
@obs	      Cadastro de Pre Recebimento

Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FExclui(cAlias, nReg, nOpc)

Local nOpca := AxAltera(cAlias,nReg,5)
//Usuário clicou em ok
If (nOpca == 1) 
	P06->(RecLock("P06",.F.))
	P06->(dbDelete())
	P06->(MsUnlock())		
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FCancela
Manutenção na tela de pré recebimento

@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11
@obs	      Cadastro de Pre Recebimento

Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FCancela(cAlias, nReg, nOpc)

If MsgYesNo("Deseja realmente realizar o cancelamento do Título?")
	P06->(RecLock("P06",.F.))
	P06->P06_STATUS := "C"
	P06->(MsUnlock())		
EndIf 
	
Return Nil                                                             


//-------------------------------------------------------------------
/*/{Protheus.doc} FGERASE1
Gera SE1

@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11
@obs	      Gera SE1

Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function  FGERASE1(nReg, dDate,cMsgErr,lManual)    

Local aAreas  := {P06->(GetArea()),GetArea()}

Default cMsgErr := ""     
Default lManual := .T.

P06->(dbGoTo(nReg))  

RegToMemory("SE1", .T.)

Private lMsErroAuto := .F.

Begin Transaction 

   
	aSE1  := {{"E1_FILIAL"	,xFilial("SE1")								,Nil},;
	 			 {"E1_PREFIXO"	,P06->P06_PREFIX								,Nil},;
				 {"E1_NUM"	  	,P06->P06_NUM  								,Nil},;
				 {"E1_PARCELA"	,"01"		 										,Nil},;
				 {"E1_TIPO"	 	,"RA"												,Nil},;
				 {"E1_NATUREZ"	,P06->P06_NATURE								,Nil},;
				 {"E1_CLIENTE"	,P06->P06_CODCLI								,Nil},;
				 {"E1_LOJA"	  	,P06->P06_LOJA	   							,Nil},;
   		    {"E1_PORTADO"	,P06->P06_BANCO   							,Nil},;
			    {"E1_AGEDEP" 	,P06->P06_AGENCI 								,Nil},;
			    {"E1_CONTA" 	,P06->P06_NUMCON 								,Nil},;
  			    {"E1_EMISSAO"	,dDate											,Nil},;
				 {"E1_VENCTO" 	,dDate											,Nil},;
				 {"E1_VENCREA"	,dDate											,Nil},;
				 {"E1_MOEDA" 	,1													,Nil},;
				 {"E1_CCD" 		,P06->P06_CCD	 								,Nil},;
				 {"E1_CCC" 		,P06->P06_CCD	 								,Nil},;				 
				 {"E1_ORIGEM"	,"FINA040"										,Nil},;
				 {"E1_FLUXO"	,"S"												,Nil},;
				 {"E1_VALOR"  	,P06->P06_VALOR								,Nil},;
				 {"E1_VLRREAL" ,P06->P06_VALOR								,Nil},;
				 {"E1_HIST"		,P06->P06_HISTOR								,Nil},;
				 {"E1_ZBOLETO"	,"N"												,Nil}}
   
	aSE1 := U_FSAceArr(aSE1,"SE1")	
	MSExecAuto({|x,y| Fina040(x,y)},aSE1, 3) //Inclusao
	
	If lMsErroAuto
		DisarmTransaction()
		If lManual
			MostraErro()
		Else
		cMsgErr := MemoRead(NomeAutoLog())
		Ferase(NomeAutoLog())
		EndIf
		
	EndIf   
	
	//Grava data da emissao do titulo
	If !lMsErroAuto
		P06->(RecLock("P06",.F.))				
		P06->P06_STATUS := "I" 
		P06->P06_DEPOSI := dDate
		P06->(MsUnlock())		
	EndIf

End Transaction				 

aEval(aAreas, {|x| RestArea(x)})

Return lMsErroAuto             


//-------------------------------------------------------------------
/*/{Protheus.doc} FGetDate
Get data digitada pele usuário

@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11
@params 	   dDate - Data a ser confirmada
@return     lRetFun - Se o usuário confirmou ou cancelou a operação

@obs	      Cadastro de Pre Recebimento

Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------   
Static Function FGetDate(dDate)

//Local cParam	:= "FSFINC03"

Local aParam   := {}
Local aPergs	:= {}
Local lRetFun 	:= .F.

Default dDate := cTod("  /  /  ")

aAdd( aPergs ,{1,'Data de Depósito:' , dDate ,"",'.T.',,'.T.',50,.T.})
                       
//Se confirmou leio o valor
If (ParamBox(aPergs ,"Parametros",@aParam,Nil,Nil,.T.) )
	dDate := aParam[1]
	lRetFun := .T.
EndIf
	
Return lRetFun          


//-------------------------------------------------------------------
/*/{Protheus.doc} FSGETP06


@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11

@obs	      Cadastro de Pre Recebimento

Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------  
User Function FSGETP06
Local aAreas  := {P06->(GetArea()),SE1->(GetArea()),GetArea()}
Local aOrdSE1 := {}

Aadd(aOrdSE1, SE1->E1_PREFIXO)
Aadd(aOrdSE1, SE1->E1_NUM)

If AllTrim(SE1->E1_TIPO) == "RA"
	U_FSPutVal("aOrdSE1",aOrdSE1)
EndIf	

aEval(aAreas, {|x| RestArea(x)})
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FSEXCP06


@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11

@obs	      Cadastro de Pre Recebimento

Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------                       
User Function FSEXCP06()
Local aAreas  := {P06->(GetArea()),SE1->(GetArea()),GetArea()}    
Local aOrdSE1 := {}

If AllTrim(SE1->E1_TIPO) == "RA"
	aOrdSE1 := aClone(U_FsRebVal("aOrdSE1"))    
EndIf

If Len(aOrdSE1) >= 1 
	P06->(dbSetOrder(3)) // P06_FILIAL, P06_PREFIX, P06_NUM, R_E_C_N_O_, D_E_L_E_T_
	If P06->(dbSeek(xFilial("P06") + aOrdSE1[1] + aOrdSE1[2]))
		P06->(RecLock("P06",.F.))
		P06->P06_STATUS := "P" 
		P06->(MsUnlock())		
		MsgInfo("Pré-Recebimento estornado com sucesso!", "Aviso")		
	EndIf                   
EndIf	
	
aEval(aAreas, {|x| RestArea(x)})

Return Nil       


//-------------------------------------------------------------------
/*/{Protheus.doc} FSCheqDe

Trata status de devolução de cheque

@author	   Giulliano Santos Silva
@since	   15/03/2012
@version	   P11

@obs	      Cadastro de Pre Recebimento

Projeto

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------  
User Function FSCheqDe(cAlias, nReg, nOpc)

If P06->P06_STATUS == "E"
	If MsgYesNo("Deseja realmente passar o status para cheque devolvido?")
		P06->(RecLock("P06",.F.))
		P06->P06_STATUS := "D"
		P06->(MsUnlock())		
	EndIf 
Else
	MsgInfo("Operação não permitida para este Pre-Recebimento!", "Aviso")	
EndIf

Return Nil