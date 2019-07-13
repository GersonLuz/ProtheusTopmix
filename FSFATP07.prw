#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFATP07
Realiza a amarração do entre notas de fatura com notas de remessa GISISS

@author	Fernando dos Santos Ferreira 
@since 	13/03/2012
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFATP07(cFilPrc)
Local		cAlias	:= GetNextAlias()
Local		aAreOld	:= {SD2->(GetArea()), P02->(GetArea()), GetArea()}
Local		cPedido	:= ""
Local		cMark		:= ""
Local		lContinua:= .T. 
Local		cPedido	:= ""

Default	cFilPrc	:= xFilial("SC5")

// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
SD2->(dbSetOrder(03))
// P02_FILIAL+P02_NUM1+P02_SERIE2+P02_NUM2
P02->(dbSetOrder(03))

BeginSql Alias cAlias
	SELECT  
		SC5.C5_FILIAL FILIAL,
		SC5.C5_ZPEDIDO PEDFATURA, 
		NOTAS.P02_SERIE1 SFATURA,
		SC5.C5_NOTA NFATURA,
		SC5.C5_SERIE SFATURA, 
		SC5.C5_OBRA OBRAFAT, 
		SC5.C5_MUNPRES MUNFAT,
		NOTAS.C5_OBRA OBRAREM, 
		NOTAS.C5_MUNPRES MUNREM, 
		NOTAS.P02_DTEMI1 DATAEMIS,
		NOTAS.C5_NOTA NREMESSA,
		NOTAS.C5_SERIE SREMESSA, 
		NOTAS.C5_CLIENTE CLIREMES,
		NOTAS.C5_LOJACLI LOJREMES,
		NOTAS.R_E_C_N_O_ P02RECNO
	FROM %table:SC5%  SC5, 
	(
		SELECT	
				SC5.C5_FILIAL, 
				SC5.C5_OBRA, 
				SC5.C5_MUNPRES, 
				SC5.C5_NOTA, 
				SC5.C5_SERIE, 
				SC5.C5_CLIENTE,
				SC5.C5_LOJACLI,
				P02.P02_DTEMI1,
				P02.P02_NUM1,
				P02.P02_SERIE1,
				P02.R_E_C_N_O_
		FROM %table:P02% P02, %table:SC5% SC5
		WHERE P02.%notdel%
		AND SC5.%notdel%
		AND SC5.C5_ZTIPO =  '1'
		AND SC5.C5_MUNPRES <> ' '
		AND P02.P02_OK = ' '
		AND SC5.C5_FILIAL = P02.P02_FILIAL
		AND SC5.C5_NOTA = SUBSTRING(P02.P02_NUM2, 1, %exp:TamSx3("C5_NOTA")[01]%)
		AND SC5.C5_SERIE = SUBSTRING(P02.P02_SERIE2, 1, %exp:TamSx3("C5_SERIE")[01]%)
		AND SC5.C5_EMISSAO = P02.P02_DTEMI2
	) NOTAS
	WHERE SC5.%notdel%
	AND	SC5.C5_FILIAL = %exp:cFilPrc%
	AND	SC5.C5_ZTIPO = '2'
	AND 	SC5.C5_MUNPRES <> ' '
	AND	SC5.C5_ZPEDIDO = NOTAS.P02_NUM1	
	AND	SC5.C5_OBRA = NOTAS.C5_OBRA
	AND	SC5.C5_MUNPRES = NOTAS.C5_MUNPRES
	ORDER BY SC5.C5_FILIAL, SC5.C5_ZPEDIDO
EndSql

(cAlias)->(dbGoTop())

While (cAlias)->(!Eof())
	If cPedido != (cAlias)->PEDFATURA
		cPedido	:= (cAlias)->PEDFATURA
		cMark		:= FGetMark( cFilPrc, (cAlias)->PEDFATURA, (cAlias)->SFATURA )
	EndIf
	
	// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	If SD2->(dbSeek(xFilial("SD2")+AvKey((cAlias)->NREMESSA, "C5_NOTA")+AvKey((cAlias)->SREMESSA, "C5_SERIE")+(cAlias)->CLIREMES+(cAlias)->LOJREMES))
		While SD2->(!Eof()) .And. SD2->D2_FILIAL == xFilial("SD2") .And. SD2->D2_DOC == AvKey((cAlias)->NREMESSA, "C5_NOTA") ;
									.And. SD2->D2_SERIE == AvKey((cAlias)->SREMESSA, "C5_SERIE") .And. SD2->D2_CLIENTE == (cAlias)->CLIREMES ;
									 .And. SD2->D2_LOJA == (cAlias)->LOJREMES									 
			BeginTran()									 
				If SD2->(RecLock("SD2", .F.))
					SD2->D2_OKISS := cMark
					SD2->(MsUnLock())
					If P02->(dbSeek(xFilial("P02")+cPedido+AvKey((cAlias)->SREMESSA, "P02_SERIE1")+AvKey((cAlias)->NREMESSA, "P02_NUM1")))
						If P02->(RecLock("P02",.F.))
							P02->P02_OK :=	cMark
							P02->(MsUnLock())
						Else
							DisarmTransaction()							
						EndIf
					Else
						DisarmTransaction()
					EndIf
				Else
					DisarmTransaction()					
				EndIf
			EndTran()
			
			SD2->(dbSkip())
		EndDo
	EndIf
	
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

aEval(aAreOld, {|x| RestArea(x)})

Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetMark
Retorna o get da para amarração

@author	Fernando dos Santos Ferreira 
@since 	13/03/2012
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FGetMark(cFilOri, cNumFat, cSerFat)
Local		cReturn		:= ""
Local		aAreOld		:= {P02->(GetArea())}

Default	cFilOri		:= ""
Default	cNumFat		:= ""
Default	cSerFat		:= ""

// P02_FILIAL+P02_NUM1+P02_SERIE2+P02_NUM2
P02->(dbSetOrder(03))

If P02->(dbSeek(xFilial("P02")+cNumFat))
	If Empty(P02->P02_OK) 
		cReturn := GetMark()	
	Else
		cReturn := P02->P02_OK
	EndIf
EndIf

aEval(aAreOld, {|x| RestArea(x)})

Return cReturn

