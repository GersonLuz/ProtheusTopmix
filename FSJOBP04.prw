#Include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FSJOBP04
Integracao Manual de Apuracao do Custo Medio

@author	   Claudio Luiz da Silva
@since	   10/11/2011
@version	   P11
@obs
Projeto TOPMIX
A rotina manual integra somente os dados da empresa corrente.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//------------------------------------------------------------------- 
User Function FSJOBP04()

Local nOpca 	:= 0			 // Flag de confirmacao para OK ou CANCELA
Local	aSays		:= {} 		 // Array com as mensagens explicativas da rotina
Local	aButtons	:= {}			 // Array com as perguntas (parametros) da rotina
Local	cCadastro:= "Integração Apuração do Custo Médio"

Local	bBlock, bErro //Tratamento de erro
Local lManual 	:= .T.  

Private 	cNomRot	:= "FSJOBP04" //Define o nome da rotina principal para controle
Private 	cMensErr	:= ""  //Tratamento de erro
Private 	bMensCons:= {|X,Y| "["+Iif(lManual,"MAN","JOB")+"]["+cNomRot+"]["+DTOC(DATE())+" "+TIME()+"] "+Iif(!Empty(X),"Empresa "+X+" - ","")+Y}
Private	oMainWnd	:= Nil

AADD(aSays, "Este programa tem como objetivo efetuar Integração com KP da.")
AADD(aSays, "Apuração do Custo Médio.")
AADD(aSays, "ATENÇÃO: NA EXECUCAO MANUAL É ENVIADO SOMENTE OS REGISTROS")
AADD(aSays, "DA EMPRESA CORRENTE.")

AADD(aButtons, { 1,.T.,{|o| nOpca := 1 , o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

FormBatch(cCadastro,aSays,aButtons)

If(nOpca == 1)
	//Tratamento de Erro
	bBlock:=ErrorBlock()
	bErro:=ErrorBlock({|e| U_FSChkBug(e, lManual)})
	
	Begin Sequence 
		  	Processa( {|| FExeProces(lManual) }, "Aguarde...", "Exportando registros...",.F.)
	End Sequence 
	
	//Tratamento de Erro
	ErrorBlock(bBlock)
	
	//Caso ocorra um erro é enviado um e-mail de alerta.
	If !Empty(cMensErr)
		Conout(cMensErr)
		//U_FSMaiAvi(cCadastro)
		Return Final("Sistema abortado pela geração do erro.")
	EndIf	
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FSLOJW04
Job de Integracao de Apuracao do Custo Medio

@author	   Claudio Luiz da Silva
@since	   11/11/2011
@version	   P11
@obs
Projeto TOPMIX
A rotina automatica integra os dados de todas as empresas existentes no SIGAMAT.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       	Programador     		Motivo    
30/01/2012  Fernando Ferreira    Validação por empresa usando o Parametro FS_GRPEMP
/*/
//------------------------------------------------------------------- 
User Function FSLOJW04

Local bBlock, bErro //Tratamento de erro
Local lManual 		:= .F.    
Local	lEmpAutJob	:=	.F.
Local aRecnoSM0	:= {}   
Local lOpen			:= .F.
Local nI				:= 0
Local	cCadastro	:= "Integração Apuração do Custo Médio"

Private 	cNomRot	:= "FSJOBP04" //Define o nome da rotina principal para controle
Private 	cMensErr	:= ""  //Tratamento de erro
Private 	bMensCons:= {|X,Y| "["+Iif(lManual,"MAN","JOB")+"]["+cNomRot+"]["+DTOC(DATE())+" "+TIME()+"] "+Iif(!Empty(X),"Empresa "+X+" - ","")+Y}

ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
ConOut(Eval(bMensCons,"","Iniciado "+cCadastro))

//Tratamento de Erro
bBlock:=ErrorBlock()
bErro:=ErrorBlock({|e| U_FSChkBug(e, lManual)})

Begin Sequence
	
	If(lOpen := U_FSAbrSM0())
	
		//Busca somente as empresas
		aRecnoSM0:= U_FSEmpInt()
		SM0->(dbGoto(aRecnoSM0[1,1]))

		If(lOpen := U_FSAbrSM0())

  			For nI := 1 To Len(aRecnoSM0)  
  				//Abertura do Ambiente da Empresa
				SM0->(dbGoto(aRecnoSM0[nI,1]))
							
				RpcSetType(3) //Não consumir licença
				RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
     			
     			lEmpAutJob	:= SuperGetMV("FS_GRPEMP", .T., .F.)
     			If lEmpAutJob
					If (Emprok(SM0->M0_CODIGO + SM0->M0_CODFIL)) // Valida se a empresa está liberada pela Totvs
						FExeProces(lManual) 
					EndIF
				Else
					ConOut("Empresa " + SM0->M0_CODIGO + ". Nao Tem autorizacao para executar o processo. Verifique o parametro FS_GRPEMP.")
				EndIf

				//Restaura o ambiente
				RpcClearEnv()
			
				//Reabre tabela SM0
				If !(lOpen := U_FSAbrSM0())
					Exit 
				EndIf 
		
			Next nI

		EndIf
	EndIf

End Sequence 

ErrorBlock(bBlock)

ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
ConOut(Eval(bMensCons,"","Finalizado "+cCadastro))

//Caso ocorra erro é enviando um e-mail de alerta.
If (!Empty(cMensErr))
	Conout(cMensErr)
	//U_FSMaiAvi(cCadastro)
EndIf

Return Nil 


//-------------------------------------------------------------------
/*/{Protheus.doc} FExeProces
Executa o processo 

@protected
@author	   Claudio Luiz da Silva
@since	   11/11/2011

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
21/02/2014 Rodrigo Artur   Não levar valores negativos para o CUSTOMEDIO.

Alteração na Cláusula where do SQL:
Where : ABS(100-(NOVO*100/VELHO)) <= 10%

Comando anterior: cWhere	:= "%1=1%"
 

/*/
//-------------------------------------------------------------------  
Static Function FExeProces(lManual)

Local cAliTmp	:= "CUSMED"  //GetNextAlias() - Devido a demais rotinas do processo o alias nao pode ser aleatorio
Local nHdlLock := -1
Local nTotReg	:= 0
Local nCtdReg	:= 0
Local cWhere	:= "%DA1_ZOLDPR > 0 AND DA1_PRCVEN > 0 AND ABS(100 - (DA1_PRCVEN*100/(CASE WHEN DA1_ZOLDPR = 0 THEN 1 ELSE DA1_ZOLDPR END))) <= 10%" // Alterado Rodrigo - 21/02/2014

Local cTipPrd  := GetNewPar("FS_TIPPRD","CC")
/*Local cTabPrc	:= GetNewPar("FS_TABPRC","000")  Retirado a pedido da Juliana - Felipe Andrews */

ConOut(Eval(bMensCons,SM0->M0_CODIGO,"Iniciando Processo na Empresa."))

//Verifica se a rotina ja esta sendo executada travando-a para nao ser executada mais de uma vez
If U_FSTraExe(@nHdlLock, cNomRot, .T., lManual)
	ConOut(Eval(bMensCons,SM0->M0_CODIGO,"Rotina já está em execucao"))
	Return(Nil)
EndIf

//Avalio se o SB1 é compartilhado ou nao Verificar novos tratamentos filial.
//If !Empty(xFilial("SB1")) .And. !Empty(xFilial("DA1"))
//	cWhere := "%SB1.B1_FILIAL=DA1.DA1_FILIAL%"
//EndIf

//Nao é necessario filtrar a filial pois sera integrado todas as filiais
BeginSql alias cAliTmp

	SELECT DA1_FILIAL, DA1_CODPRO, DA1_UM, DA1_PRCVEN, SUBSTRING(DA1_CODTAB,02,02) AS DA1_CODTAB
	FROM %table:DA1% DA1, %table:SB1% SB1
	WHERE  DA1.%notDel% 
		AND SB1.%notDel% 
		AND SB1.B1_TIPO    = %exp:cTipPrd%
		/* AND DA1.DA1_CODTAB = %exp:cTabPrc%  Retirado a pedido da Juliana - Felipe Andrews */
		AND DA1.DA1_CODPRO = SB1.B1_COD
		AND %Exp:cWhere%
	ORDER BY DA1_FILIAL, DA1_CODPRO
			
EndSql 

If ((cAliTmp)->(Eof()))
	
	If (lManual)// Se a função for chamada via Mnu
		ApMsgAlert("Não existe registros para Integrar na Empresa:  " + SM0->M0_CODIGO + " !")
	Else
		ConOut(Eval(bMensCons,SM0->M0_CODIGO,"Não existe registros para Integrar."))
	EndIf
		
Else

	If (lManual) // Se a função for chamada via Mnu
		(cAliTmp)->(dbEval({||nTotReg++}))
		ProcRegua(nTotReg)
	EndIf
	
	(cAliTmp)->(dbGotop())
	While ((cAliTmp)->(!Eof()))
		
		If (lManual) // Se a função for chamada via Mnu
			nCtdReg++
			IncProc("Processando: " + Strzero(nCtdReg,9) + " de " + Strzero(nTotReg,9))
		EndIf  
			
		//Efetua a integracao do registro com o KP
		//A cada execucao é incluido novo registro na tabela de integracao
		U_FSPutTab(cAliTmp,"I")
		  	
		(cAliTmp)->(dbSkip()) 
		   
	EndDo
		
EndIf

(cAliTmp)->(dbCloseArea())	

//Destrava a rotina
U_FSTraExe(@nHdlLock, cNomRot)

ConOut(Eval(bMensCons,SM0->M0_CODIGO,"Finalizando Processo na Empresa."))

Return Nil


