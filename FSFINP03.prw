#Include "Protheus.ch"   
#Define cEol Chr(13)+Chr(10)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINP03()
Processo que realiza a exclusão dos titulos provisorios referente ao
faturamento de Pedidos de Fatura.
          
@author Fernando Ferreira
@since 11/11/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo       
21/01/14   Rodrigo Artur   Exportar o LOG do processamento para o EXCEL.
/*/ 
//------------------------------------------------------------------ 
User Function FSFINP03()
Local 	aAreOld	:=	{GetArea()}
Local		aDadTit	:=	{}

Local		cQry		:=	""
Local		cAli		:=	GetNextAlias()
Local		cFilNfs	:=	""
Local		cSerNfs	:=	""
Local		cNumRem	:=	""
Local		cMsgErr	:=	""             
Local		cRotPrc	:= "Fat X Rem"
Local		cSerie	:= SF2->F2_SERIE
Local		cPedido	:= SC5->C5_ZPEDIDO

Local		dDtaPrc	:=	dDataBase
Local    cPrefixo	:= ""
Local    lAchou   := .F.  
Local    nTotReg  := 0

Private  aGravaLog   := {}  
Private  aCabec      := {OemToAnsi("Filial"),OemToAnsi("Prefixo"),OemToAnsi("Numero"),OemToAnsi("Pedido"),OemToAnsi("Hora"),OemToAnsi("Ocorrencia")}
private	lMsErroAuto	:= .F.

cQry	+= "SELECT"
cQry	+= cEol + "	P2.P02_FILIAL, P2.P02_SERIE2, P2.P02_NUM2"
cQry	+= cEol + "FROM "
cQry	+= cEol + 	RetSqlName("P02")+" P2"
cQry	+= cEol + "WHERE "
cQry	+= cEol + "	P2.P02_FILIAL 	= '"	+ xFilial("P02") 	+ 	"' AND"
/* Felipe Andrews - 11/06/2013 - Em comum acordo com a Juliana, tiramos
 * esta clausula da consulta SQL pois alem da chave P02_NUM1 ser unica,
 * a serie esta sendo utilizada incorretamente!
cQry	+= cEol + "		P2.P02_SERIE1 	= '"	+ cSerie	 	+	"'	AND" */
cQry	+= cEol + "		P2.P02_NUM1		= '"	+ cPedido	+	"' AND"
cQry	+= cEol + "		P2.D_E_L_E_T_ <> '*'"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAli, .F., .T.)

(cAli)->(dbGoTop())
(cAli)->(dbEval({|| nTotReg++ }))
(cAli)->(dbGoTop())

If nTotReg == 0 
   aAdd(aGravaLog,{ "'"+SF2->F2_FILIAL ,"'"+SF2->F2_SERIE,"'SEM REMESSA INF.","'"+cPedido,time(),"Registros não encontrado na tabela P02! - (1)" } )		
Endif

SE1->(dbSetOrder(1))
                       
While (cAli)->(!Eof())
	
	cPrefixo := U_FSGetSre(Padr((cAli)->P02_SERIE2, TamSx3("E1_PREFIXO")[01]))
	cNumRem	:=	Padr((cAli)->P02_NUM2 , TamSx3("F2_DOC")[01])
	
	If SE1->(dbSeek(xFilial("SE1") + cPrefixo + cNumRem )) //SE1->(dbSeek(xFilial("SE1") + cPrefixo + cNumRem ))
   
    	lAchou  := .F. // Se encontrou algum registro
	
		While SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_PREFIXO == cPrefixo .And. SE1->E1_NUM == cNumRem
		
			lMsErroAuto	:=	.F.
		
			If SE1->E1_FILORIG <> (cAli)->P02_FILIAL .Or. Alltrim(SE1->E1_TIPO) <> "PR"
				SE1->(dbSkip())
				Loop
			EndIf
			
			aDadTit	:=	U_FArrSigAut("SE1", "E1")
			lAchou   := .T.
	
			Begin Transaction 

            RecLock("SE1",.F.)
            Replace SE1->E1_HIST With "PR EXCLUIR"
            SE1->(MsUnlock())
			   
				// Inclusão dos do Título via Siga Auto
				MSExecAuto({|x,y| Fina040(x,y)}, aDadTit, 5)
				
				If lMsErroAuto  
				   
				   aAdd(aGravaLog,{ "'"+(cAli)->P02_FILIAL ,"'"+cPrefixo,"'"+cNumRem,"'"+cPedido,time(),"Erro na tentativa de exclusão do titulo no financeiro!" } )
					cMsgErr := MemoRead(NomeAutoLog())
					U_FSSETERR(xFilial("P00"), dDtaPrc, Time(), SE1->E1_ZREMES, cRotPrc, cMsgErr)
					Ferase(NomeAutoLog())
					
				EndIf 
				
			End Transaction
			
			DbSelectArea("SE1")
			SE1->(dbSkip())
			
		EndDo

		If ! lAchou
         aAdd(aGravaLog,{ "'"+(cAli)->P02_FILIAL ,"'"+cPrefixo,"'"+cNumRem,"'"+cPedido,time(),"Titulo não encontrado no contas a receber! - (A)" } )		
		Endif

	Else
	   aAdd(aGravaLog,{ "'"+(cAli)->P02_FILIAL ,"'"+cPrefixo,"'"+cNumRem,"'"+cPedido,time(),"Registro não encontrado no contas a receber! - (B)" } )
	EndIf

	DbSelectArea(cAli)
	(cAli)->(dbSkip())

EndDo 

U_FSCloAre(cAli)

If Len(aGravaLog) > 0
   DlgToExcel({{"ARRAY","Titulos PROVISORIOS que não foram excluídos!!!",aCabec,aGravaLog}})
Endif

aEval(aAreOld, {|xAux| RestArea(xAux)})
 

Return Nil


