#Include "Totvs.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSCOMP10
Processo de atualização do custo médio dos produtos na tabela de preços.
     
@author	Fernando dos Santos Ferreira 
@since 	13/03/2013
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
11/06/2013 Felipe Andrews  Filial do Parametro vinha com espacos
/*/ 
//------------------------------------------------------------------ 
User Function FSCOMP10(cFilPrc)
Local		cAlias	:= GetNextAlias()
Local		aAreOld	:= {DA0->(GetArea()), DA1->(GetArea()), GetArea()}
Local		cArmazem	:= ""

Default	cFilPrc	:= xFilial("DA0")

/* Incluso por Felipe Andrews - 11/06/2013
 * Filial do Parametro vinha com espacos */
cFilPrc := Alltrim(cFilPrc)

// DA0_FILIAL+DA0_CODTAB
DA0->(dbSetOrder(01))

// DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
DA1->(dbSetOrder(01))

If DA0->(dbSeek(cFilPrc))
	While DA0->(!Eof()) .And. DA0->DA0_FILIAL == cFilPrc
		// Se estiver inativo pula o registro
		If DA0->DA0_ATIVO == "2"
			DA0->(dbSkip())
			Loop
		EndIf
		
		// Pego o armazem de acordo com a codificação da tabela
		// as duas últimas posições do código da tabela tabela
		cArmazem	:= SubStr(DA0->DA0_CODTAB, 2, 2)

		If Select(cAlias) > 0
			(cAlias)->(dbCloseArea())
		EndIf
		
		BeginSql Alias cAlias
			SELECT SB2.B2_FILIAL, SB2.B2_COD, SB2.B2_CM1
			FROM %table:SB2% SB2, %table:SB1% SB1
			WHERE SB1.%notDel% 
			AND SB2.%notDel% 
			AND SB2.B2_LOCAL = %exp:cArmazem%
			AND SB1.B1_TIPO = 'CC'
			AND SB1.B1_FILIAL = %Exp:xFilial("SB1")%
			AND SB2.B2_FILIAL = %Exp:xFilial("SB2")%
			AND SB2.B2_COD = SB1.B1_COD
			ORDER BY SB2.B2_FILIAL, SB2.B2_COD
		EndSql
		
		While (cAlias)->(!Eof())
			If DA1->(dbSeek(cFilPrc+DA0->DA0_CODTAB+(cAlias)->B2_COD)) // Atualiza o valor
				If DA1->(RecLock("DA1", .F.))
					DA1->DA1_ZOLDPR	:= DA1->DA1_PRCVEN
					DA1->DA1_ZDTALT	:= Date()
					DA1->DA1_ZHRALT	:= Time()
					DA1->DA1_PRCVEN	:= (cAlias)->B2_CM1
					DA1->(MsUnLock())
				EndIF
			Else
				// Salvo as informações na DAI
				FSaveDa1(DA0->DA0_CODTAB, (cAlias)->B2_COD, (cAlias)->B2_CM1)
			EndIf
			(cAlias)->(dbSkip())
		EndDo		
		
		DA0->(dbSkip())
	EndDo
	
	If Select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	EndIf
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FMod2aHeader
Monta a aHeader

@author	   Fernando Ferreira
@since	   11/06/2012
@version    P11
@param		cAlias 	Alias da tabela
@param		aHeader	Header do processo.
@obs	      

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo

/*/
//------------------------------------------------------------------- 
Static Function FMod2aHeader(cAlias, aHeader)

SX3->(dbSetOrder(1)) 
SX3->(dbGoTop())
SX3->(dbSeek(cAlias)) 

While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == cAlias 
  
  If SX3->(X3Uso(SX3->X3_USADO)) .And. cNivel >= SX3->X3_NIVEL .And. cNivel >= SX3->X3_NIVEL
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
	  		SX3->X3_BROWSE,;
	  		SX3->X3_OBRIGAT})
  Endif 
  SX3->(dbSkip()) 
EndDo   

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FMod2aCols
Monta aCols

@author	   Fernando Ferreira
@since	   11/06/2012
@version    P11
@param		cAlias	Alias do processo
@param		nReg		Número de registros	
@param		nOpc		Opção a ser executada.
@obs	      

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//------------------------------------------------------------------- 
Static Function FMod2aCols(aReg, nReg,nOpc)

Local nI	:= 0
Private INCLUI := IIF(nOpc == 3,.T.,.F.) /* Criada variavel INCLUI manualmente para funcionamento da rotina via JOB */

If	nOpc <> 3  // se Diferente de inclusão

	DA1->(dbSetOrder(1))

	/* Comentado por Felipe Andrews - Solicitacao da Juliana
   If DA1->(dbSeek(xFilial("DA1") + "000")) */
	If DA1->(dbSeek(xFilial("DA1") + DA0->DA0_CODTAB))
				
		Aadd(aReg, DA1->(Recno())) 				 	// Adiciona o campo R_E_C_N_O_ para manipulação dentro do vetor aReg
		Aadd(aCols, Array(Len(aHeader) + 1)) 	 	// Monta o aCols no tamanho do meu aHeader
		aCols[Len(aCols),Len(aHeader)+1] := .F. 	// Seta o ultimo campo do aCols como .F. para validar a se está deletado
			
		For nI := 1 to Len(aHeader) 
			If aHeader[nI,10] == "V" // Verifica se o campo é virtual, se sim cria variavel na memoria
				aCols[len(aCols),nI] := CriaVar(aHeader[nI,2],.T.)
			Else
				aCols[len(aCols),nI] := DA1->(FieldGet(FieldPos(aHeader[nI,2])))
			EndIf
		Next
	EndIf
EndIf	

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} FMod2aHeader
Monta a aHeader

@author	   Fernando Ferreira
@since	   11/06/2012
@version    P11
@param		aHeader	Header do processo.
@param		aCols		registro a ser salvo
@obs	      

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo

/*/
//-------------------------------------------------------------------
Static Function FSaveDa1(cCodTab, cCodigo, nCusto)
Local		nPos		:= 0
Local		nX 		:= 1
Local		nReg		:= 1
Local		nOpc		:= 4
Local		aReg		:= {}
Local		aAreOld	:=  {DA1->(GetArea()), DA0->(GetArea()) ,GetArea()}

Private	aCols		:= {}
Private	aHeader	:= {}

// Carrega o aHeader da DA1
FMod2aHeader("DA1", @aHeader)
// Carrega o aCols padrão
FMod2aCols(aReg, nReg,nOpc)

// Gravo o item
nPos := aScan(aHeader, {|x| AllTrim(x[02]) ==  "DA1_ITEM"})
aCols[01][nPos] := U_FSGetCod("DA1", "DA1_ITEM", "", TamSx3("DA1_ITEM")[01], "DA1_FILIAL+DA1_CODTAB", xFilial("DAI")+cCodTab)

// Gravo o Produto
nPos := aScan(aHeader, {|x| AllTrim(x[02]) ==  "DA1_CODPRO"})
aCols[01][nPos] := cCodigo

// Gravo o Preço de venda
nPos := aScan(aHeader, {|x| AllTrim(x[02]) ==  "DA1_PRCVEN"})
aCols[01][nPos] := nCusto

// Gravo o valor antigo
nPos := aScan(aHeader, {|x| AllTrim(x[02]) ==  "DA1_ZOLDPR"})
aCols[01][nPos] := nCusto

// Data de alteração
nPos := aScan(aHeader, {|x| AllTrim(x[02]) ==  "DA1_ZDTALT"})
aCols[01][nPos] := Date()

// Hora da alteração
nPos := aScan(aHeader, {|x| AllTrim(x[02]) ==  "DA1_ZHRALT"})
aCols[01][nPos] := Time()

If DA1->(RecLock("DA1",.T.))
	For nX := 1 To Len(aHeader)
		DA1->(FieldPut(FieldPos(aHeader[nX, 2]), aCols[1, nX])) 				// Imputar os campos
	Next nX
	DA1->DA1_FILIAL := xFilial("DA1")
	DA1->DA1_CODTAB := cCodTab
	DA1->(MsUnLock())
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return Nil