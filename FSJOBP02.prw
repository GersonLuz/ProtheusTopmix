#Include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FSJOBP02
Integracao da Posicao do Cliente

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
User Function FSJOBP02

Local nOpca 	:= 0			 // Flag de confirmacao para OK ou CANCELA
Local	aSays		:= {} 		 // Array com as mensagens explicativas da rotina
Local	aButtons	:= {}			 // Array com as perguntas (parametros) da rotina
Local	cCadastro:= "Integração Posição de Cliente"                                            	

Local	bBlock, bErro //Tratamento de erro
Local lManual 	:= .T.    
Local lPrim 	:= .T. 

Private 	cNomRot	:= "FSJOBP02" //Define o nome da rotina principal para controle
Private 	cMensErr	:= ""  //Tratamento de erro
Private 	bMensCons	:= {|X,Y| "["+Iif(lManual,"MAN","JOB")+"]["+cNomRot+"]["+DTOC(DATE())+" "+TIME()+"] "+Iif(!Empty(X),"Empresa "+X+" - ","")+Y}

AADD(aSays, "Este programa tem como objetivo efetuar Integração com KP da.")
AADD(aSays, "posição do Cliente.")
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
		  	Processa( {|| FExeProces(lManual, @lPrim) }, "Aguarde...", "Exportando registros...",.F.)
	End Sequence 
	
	//Tratamento de Erro
	ErrorBlock(bBlock)
	
	//Caso ocorra um erro é enviado um e-mail de alerta.
	If !Empty(cMensErr)
		Conout(cMensErr)
		//U_FSMaiAvi("Processo de Integracao Posicao de Cliente")
		Return Final("Sistema abortado pela geração do erro.")
	EndIf	
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FSLOJW02
Job de Integracao da Posicao do Cliente

@author	   Claudio Luiz da Silva
@since	   10/11/2011
@version	   P11
@obs
Projeto TOPMIX
A rotina automatica integra os dados de todas as empresas existentes no SIGAMAT.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       	Programador     		Motivo    
30/01/2012  Fernando Ferreira    Validação por empresa usando o Parametro FS_GRPEMP
/*/
//------------------------------------------------------------------- 
User Function FSLOJW02()

Local	 	bBlock, bErro //Tratamento de erro    
Local 	aRecnoSM0	:= {}
   
Local 	lOpen			:= .F.
Local		lEmpAutJob	:=	.F.
Local 	lManual 		:= .F. 
Local 	lPrim		 	:= .T.

Local 	nI				:= 0

Private 	cNomRot   	:= "FSJOBP02" //Define o nome da rotina principal para controle
Private 	cMensErr	   := ""  //Tratamento de erro
Private 	bMensCons	:= {|X,Y| "["+Iif(lManual,"MAN","JOB")+"]["+cNomRot+"]["+DTOC(DATE())+" "+TIME()+"] "+Iif(!Empty(X),"Empresa "+X+" - ","")+Y}

ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
ConOut(Eval(bMensCons,"","Iniciado Integracao Posicao de Cliente"))

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
						FExeProces(lManual, @lPrim) 
					EndIf
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
ConOut(Eval(bMensCons,"","Finalizado Integracao Posicao de Cliente"))

//Caso ocorra erro é enviando um e-mail de alerta.
If (!Empty(cMensErr))
	Conout(cMensErr)
	//U_FSMaiAvi("Processo de Integracao Posicao de Cliente")
EndIf

Return Nil 


//-------------------------------------------------------------------
/*/{Protheus.doc} FExeProces
Executa o processo de cancelamento de Pré-Orçamentos

@protected
@author	   Claudio Luiz da Silva
@since	   10/11/2011
@version	   P11
/*/
//-------------------------------------------------------------------  
Static Function FExeProces(lManual, lPrim)

Local cAliTmp	   := "POSCLI"  //GetNextAlias() - Devido a demais rotinas do processo o alias nao pode ser aleatorio
Local nHdlLock    := -1
Local nTotReg	   := 0
Local nCtdReg 	   := 0
Local cWhere   	:= ""   
Local lAtPosCli   := (TIME() >= "08:00" .And. Time() <= "22:00")  // atualiza a posicao de clientes do betomix (somente clientes que sofreram alteracao na data de hoje)
Local nDiasAnt    := 1
Default lPrim 	   := .T.

ConOut(Eval(bMensCons,SM0->M0_CODIGO,"Iniciando Processo na Empresa."))

//Verifica se a rotina ja esta sendo executada travando-a para nao ser executada mais de uma vez
If U_FSTraExe(@nHdlLock, cNomRot, .T., lManual)
	ConOut(Eval(bMensCons,SM0->M0_CODIGO,"Rotina já está em execucao"))
	Return(Nil)
EndIf

//Nao é necessario filtrar a filial pois sera integrado todas as filiais
//De acordo com especificacao foi efetuado o seguinte processo na query:
//1. Criacao de uma query para buscar os titulos em aberto credito (tipo diferente de NCC e RA)
//2. Criacao de uma query para buscar os titulos em aberto debito (tipo igual a NCC e RA)
//3. Foi efetuado um join entre as duas querys e tratado o saldo (comprometimento do cliente)

//Avalio se o SA1 é compartilhado ou nao
If (Len(AllTrim(xFilial("SA1"))) == 6) .And. (Len(AllTrim(xFilial("SE1"))) == 6)
	cWhere := " AND SA1.A1_FILIAL = SE1.E1_FILIAL "
EndIf

cQuery := "SELECT * FROM (" + CRLF
cQuery += "	SELECT " + CRLF
cQuery += "		E1_FILIAL	=	CASE WHEN RECEBER.E1_FILIAL  IS NULL THEN PAGAR.E1_FILIAL  ELSE RECEBER.E1_FILIAL  END, " + CRLF
cQuery += "		E1_CLIENTE	=	CASE WHEN RECEBER.E1_CLIENTE IS NULL THEN PAGAR.E1_CLIENTE ELSE RECEBER.E1_CLIENTE END, " + CRLF
cQuery += "		E1_LOJA		=	CASE WHEN RECEBER.E1_LOJA    IS NULL THEN PAGAR.E1_LOJA    ELSE RECEBER.E1_LOJA    END, " + CRLF
cQuery += "		ISNULL(DEBITO,0) - ISNULL(CREDITO,0) E1_SALDO," + CRLF
cQuery += "		ISNULL(DEBITO,0)  DEBITO," + CRLF
cQuery += "		ISNULL(CREDITO,0) CREDITO" + CRLF
cQuery += "	FROM " + CRLF
cQuery += "	(SELECT E1_FILIAL,E1_CLIENTE, E1_LOJA, SUM(E1_SALDO) DEBITO" + CRLF
cQuery += "	   FROM " + RetSqlName("SE1") + " SE1," + RetSqlName("SA1") + " SA1" + CRLF
cQuery += "     WHERE SE1.E1_TIPO NOT IN ('NCC','RA','AB-', 'CF-', 'CS-', 'FU-', 'IN-', 'IR-', 'IS-', 'PI-', 'FE-', 'COF', 'CSL', 'PIS')" + CRLF
cQuery += "	      AND SE1.E1_CLIENTE  = SA1.A1_COD" + CRLF
cQuery += "	      AND SE1.E1_LOJA     = SA1.A1_LOJA" + CRLF
cQuery += "		   AND SE1.D_E_L_E_T_ <> '*' " + CRLF
cQuery += "		   AND SA1.D_E_L_E_T_ <> '*'" + CRLF
cQuery += "		   AND SA1.A1_ZTIPO    = 'S'" + CRLF
cQuery += "		   "+ cWhere + CRLF
cQuery += "	 GROUP BY  SE1.E1_FILIAL,SE1.E1_CLIENTE, SE1.E1_LOJA" + CRLF
cQuery += "	) RECEBER " + CRLF
cQuery += "	" + CRLF
cQuery += "	FULL JOIN" + CRLF
cQuery += "	" + CRLF
cQuery += "	(SELECT E1_FILIAL,E1_CLIENTE, E1_LOJA, SUM(E1_SALDO) CREDITO" + CRLF
cQuery += "	   FROM " + RetSqlName("SE1") + " SE1," + RetSqlName("SA1") + " SA1" + CRLF
cQuery += "	  WHERE SE1.E1_TIPO IN ('NCC','RA')" + CRLF
cQuery += "	    AND SE1.E1_CLIENTE  = SA1.A1_COD" + CRLF
cQuery += "		 AND SE1.E1_LOJA     = SA1.A1_LOJA" + CRLF
cQuery += "		 AND SE1.D_E_L_E_T_ <> '*' " + CRLF
cQuery += "		 AND SA1.D_E_L_E_T_ <> '*' " + CRLF
cQuery += "		 AND SA1.A1_ZTIPO   = 'S'" + CRLF
cQuery += "		 "+ cWhere +CRLF
cQuery += "	  GROUP BY  SE1.E1_FILIAL,SE1.E1_CLIENTE, SE1.E1_LOJA" + CRLF
cQuery += "	) PAGAR" + CRLF
cQuery += "	" + CRLF
cQuery += "	ON  RECEBER.E1_FILIAL  = PAGAR.E1_FILIAL" + CRLF
cQuery += "	AND RECEBER.E1_CLIENTE = PAGAR.E1_CLIENTE" + CRLF
cQuery += "	AND RECEBER.E1_LOJA    = PAGAR.E1_LOJA" + CRLF
cQuery += ") POSCLI" + CRLF
If lAtPosCli
   cQuery += " WHERE E1_CLIENTE IN (SELECT E1_CLIENTE FROM "+RetSqlName("SE1")+" WHERE E1_EMIS1 >= '"+DtoS(Date()-nDiasAnt)+"' AND D_E_L_E_T_ <> '*'" + CRLF
   cQuery += "                      UNION" + CRLF
   cQuery += "                      SELECT E5_CLIFOR  FROM "+RetSqlName("SE5")+" WHERE E5_DATA  >= '"+DtoS(Date()-nDiasAnt)+"' AND D_E_L_E_T_ <> '*')" + CRLF
Endif
cQuery += "ORDER BY E1_FILIAL, E1_CLIENTE, E1_LOJA" + CRLF

cQuery := ChangeQuery(cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliTmp , .T. , .F.)

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
		U_FSPutTab(cAliTmp, "I" , .F. , @lPrim , @lAtPosCli)
		
		(cAliTmp)->(dbSkip()) 
		   
	EndDo
		
EndIf

(cAliTmp)->(dbCloseArea())	

//Destrava a rotina
U_FSTraExe(@nHdlLock, cNomRot)

ConOut(Eval(bMensCons,SM0->M0_CODIGO,"Finalizando Processo na Empresa."))

Return Nil
          

