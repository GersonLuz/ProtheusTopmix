#Include "Totvs.ch"
#Include "rwmake.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINP25
Processo de atualização de data de vencimento de clintes inativos
         
@author Fernando dos Santos Ferreira
@since 		08/03/2013
@version 	P11 
@return     Nil 
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------- 
User Function FSFINP25()
Local		cAlias	:= GetNextAlias()
Local		nDias		:= SuperGetMv("TM_DIAVCRE", .F., 0)
Local		cMsgUsu	:= ""
Local		cMsgRet	:= ""

cMsgUsu += "Essa rotina realiza a alteração da data de vencimento dos clientes que estão sem realizar compras a mais de "
cMsgUsu += cValToChar(nDias) + " dias." +CHR(10)+CHR(13)
cMsgUsu += "Deseja continuar o processo?"

If MsgBox(cMsgUsu, ".:: Manutenção de Crédito ::.", "YESNO")

	BeginSql Alias cAlias
		COLUMN E1_EMISSAO AS DATE
		
		SELECT SE1.E1_CLIENTE, SE1.E1_LOJA, SA1.A1_VENCLC, MAX(SE1.E1_EMISSAO) E1_EMISSAO
		FROM %table:SE1% SE1, %table:SA1% SA1
		WHERE SE1.%notDel%
		AND SE1.%notDel%
		AND SE1.E1_FILIAL = %Exp:xFilial("SE1")%
		AND SA1.A1_FILIAL = %Exp:xFilial("SA1")%		
		AND SE1.E1_CLIENTE = SA1.A1_COD		
		AND SE1.E1_LOJA = SA1.A1_LOJA
		AND SA1.A1_VENCLC >= %Exp:DToS(Date())%
		GROUP BY SE1.E1_CLIENTE, SE1.E1_LOJA, SA1.A1_VENCLC
		ORDER BY SE1.E1_CLIENTE, SE1.E1_LOJA
	EndSql
	
	MsgRun("Atualizando Vencimento do Limite de crédito dos clientes encontrados...",".:: Manutenção de Crédito ::.",{|| cMsgRet	:= FSaveSa1(cAlias, nDias) })
	
	If Empty(cMsgRet)
		MsgBox("Clientes atualizados com sucesso!", ".:: Manutenção de Crédito ::.", "INFO")
	Else
		MsgBox("Ocorreu problemas ao atualizar os clientes" + cMsgRet , ".:: Manutenção de Crédito ::.", "ALERT")
	EndIf
	
	(cAlias)->(dbCloseArea())
	
EndIf

Return 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSaveSa1
Salva as informações na tabela de clientes
         
@author Fernando dos Santos Ferreira
@since 		08/03/2013
@version 	P11 
@return     Nil 
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------- 
Static Function FSaveSa1(cAlias, nDias)
Local		cReturn	:= ""
Local		aAreOld	:= {SA1->(GetArea()), GetArea()}
Local		dDtaPrc	:= Date() - nDias

// A1_FILIAL+A1_COD+A1_LOJA
SA1->(dbSetOrder(01))

While (cAlias)->(!Eof())
	If (cAlias)->E1_EMISSAO <= dDtaPrc
		If SA1->(dbSeek(xFilial("SA1")+(cAlias)->E1_CLIENTE+(cAlias)->E1_LOJA))
			If SA1->(RecLock("SA1", .F.))
				SA1->A1_VENCLC := Date()
				SA1->(MsUnLock())
			Else
				cReturn += "Cliente: "+(cAlias)->E1_CLIENTE + " Loja: " + (cAlias)->E1_LOJA + "Não foi atualizado, registro reservado."				
			EndIf		
		Else
			cReturn += "Cliente: "+(cAlias)->E1_CLIENTE + " Loja: " + (cAlias)->E1_LOJA + "Não Encontrado."
		EndIf	
	EndIf
	(cAlias)->(dbSkip())
EndDo

aEval(aAreOld, {|xAux| RestArea(xAux)})
	
Return cReturn
                                          

