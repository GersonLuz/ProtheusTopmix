#Include "Protheus.ch"
#Define _CRLF CHR(13) + CHR(10)
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINP13
Exclusão de titulos no SE1

@author Giulliano Santos
@since  19/03/2012 
@version P11
@obs  

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFINP13()
Local lExclui := .F.

//Liga processo customizado
U_FSPutVal("lExcSE1",.T.)

MsgRun("Efetuando Exclusão dos tipos RCT","Por favor, Aguarde....",{|| lExclui := FExcDados()})

//Desliga processo customizado
U_FSPutVal("lExcSE1",.F.)

Return lExclui


//------------------------------------------------------------------- 
/*/{Protheus.doc} FExcDados
Exclusão de titulos no SE1

@author Giulliano Santos
@since  19/03/2012 
@version P11
@obs  

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FExcDados()

Local aAreas	 := {SE1->(GetArea()),GetArea()}
Local cPrefix	 := SE1->E1_PREFIXO
Local cNumero	 := SE1->E1_NUM
Local cTipo		 := "RCT"
Local	cAliasSE1 := GetNextAlias()
Local lExclui	 := .T.  
Local cMsgErr 	 := ""   
Local	lErro		 := .F.						


BeginSql Alias cAliasSE1
	
	SELECT
		R_E_C_N_O_ nRecno
	FROM
	  %Table:SE1% SE1
	WHERE
		E1_FILIAL = %xFilial:SE1%
		AND E1_PREFIXO = %Exp:cPrefix%
		AND E1_NUM = %Exp:cNumero%
		AND E1_TIPO = %Exp:cTipo%
		AND SE1.%NotDel% 
	ORDER BY	R_E_C_N_O_
	
EndSql

While (cAliasSE1)->(!Eof())
	SE1->(dbGoTo((cAliasSE1)->nRecno))
	If !Empty(SE1->E1_BAIXA)
		lExclui := .F.
		cMsgErr += "Título Prefixo: " + SE1->E1_PREFIXO + " Numero: " + SE1->E1_NUM + " Parcela: " + SE1->E1_PARCELA + _CRLF  
		cMsgErr += "Não poderá ser excluido pois já foi baixado!"
		MsgAlert(cMsgErr)
		Exit
	EndIf  
	(cAliasSE1)->(dbSkip())
EndDo

(cAliasSE1)->(dbGoTop())

If lExclui
	Begin Transaction 
	
		While (cAliasSE1)->(!Eof())
	
			SE1->(dbGoTo((cAliasSE1)->nRecno))
			lErro := FExcSE1(@cMsgErr)
			If lErro
				lExclui := .F.
				Exit
			EndIf	
			(cAliasSE1)->(dbSkip())
			
		EndDo
	   cMsgErr += "Foram excluidos com sucesso!"
	   MsgAlert(cMsgErr)
	End Transaction
EndIf	

aEval(aAreas, {|x| restArea(x) })

Return lExclui	 


//------------------------------------------------------------------- 
/*/{Protheus.doc} FExcSE1
Exclui os dados no SE1

@author Giulliano Santos
@since  19/03/2012 
@version P11
@obs  

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FExcSE1(cMsgErr)

Local aAreas  	:= {SE1->(GetArea()),GetArea()}
Local nX			:= 0	 
Local aSE1 		:= {}

Private lMsErroAuto := .F.

aSE1  := {{"E1_FILIAL"	,xFilial("SE1")  	    ,Nil},;
 			 {"E1_PREFIXO"	,SE1->E1_PREFIXO 		 ,Nil},;
			 {"E1_NUM"	  	,SE1->E1_NUM  	  		 ,Nil},;
			 {"E1_PARCELA"	,SE1->E1_PARCELA	 	 ,Nil},;
			 {"E1_TIPO"	 	,SE1->E1_TIPO			 ,Nil},;
			 {"E1_NATUREZ"	,SE1->E1_NATUREZ		 ,Nil},;
			 {"E1_CLIENTE"	,SE1->E1_CLIENTE	 	 ,Nil},;
			 {"E1_LOJA"	  	,SE1->E1_LOJA	  		 ,Nil},;
			 {"E1_EMISSAO"	,SE1->E1_EMISSAO 		 ,Nil},;
			 {"E1_VENCTO" 	,SE1->E1_VENCTO 		 ,Nil},;
			 {"E1_VENCREA"	,SE1->E1_VENCREA	  	 ,Nil},;
			 {"E1_MOEDA" 	,SE1->E1_MOEDA			 ,Nil},;
			 {"E1_ORIGEM"	,SE1->E1_ORIGEM		 ,Nil},;
			 {"E1_FLUXO"	,SE1->E1_FLUXO			 ,Nil},;
			 {"E1_VALOR"  	,SE1->E1_VALOR  		 ,Nil},;
			 {"E1_HIST"		,SE1->E1_HIST			 ,Nil},;
			 {"E1_ZBOLETO"	,SE1->E1_ZBOLETO		 ,Nil}}
	  
aSE1 := U_FSAceArr(aSE1,"SE1")	
MSExecAuto({|x,y| Fina040(x,y)},aSE1, 5) //5 - Exclusão
		
If lMsErroAuto
	DisarmTransaction()
	MostraErro()
	cMsgErr := "Título Prefixo: " + SE1->E1_PREFIXO + " Numero: " + SE1->E1_NUM + " Parcela: " + SE1->E1_PARCELA + _CRLF  	
	cMsgErr += "Apresentou problemas ao ser excluido!" + _CRLF  	
EndIf	

If !lMsErroAuto
	cMsgErr += "Título Prefixo: " + SE1->E1_PREFIXO + " Numero: " + SE1->E1_NUM + " Parcela: " + SE1->E1_PARCELA + _CRLF  	
EndIf	

aEval(aAreas, {|x| RestArea(x)})

Return lMsErroAuto          