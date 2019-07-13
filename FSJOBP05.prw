#Include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FSJOBP05
Requisito 09 - Envio de cotação

@author	   Giulliano Santos
@since	   16/11/2011
@version	   P11
@obs
Projeto TOPMIX
A rotina manual integra somente os dados da empresa corrente.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//------------------------------------------------------------------- 
User Function FSJOBP05

Local nOpca 	:= 0			 // Flag de confirmacao para OK ou CANCELA
Local	aSays		:= {} 		 // Array com as mensagens explicativas da rotina
Local	aButtons	:= {}			 // Array com as perguntas (parametros) da rotina
Local	cCadastro:= "Envio de cotação"

Local	bBlock, bErro //Tratamento de erro
Local lManual 	:= .T.  

Private 	cNomRot	:= "FSJOBP05" //Define o nome da rotina principal para controle
Private 	cMensErr	:= ""  //Tratamento de erro
Private 	bMensCons:= {|X,Y| "["+Iif(lManual,"MAN","JOB")+"]["+cNomRot+"]["+DTOC(DATE())+" "+TIME()+"] "+Iif(!Empty(X),"Empresa "+X+" - ","")+Y}

AADD(aSays, "Este programa tem como objetivo efetuar Integração com KP.")
AADD(aSays, "Envio de cotação.")
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
		//U_FSMaiAvi("Processo de envio")
		Return Final("Sistema abortado pela geração do erro.")
	EndIf	
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FSLOJW05
Requisito 09 - Envio de cotação
@author	   Giulliano Santos
@since	   16/11/2011
@version	   P11
@obs
Projeto TOPMIX
A rotina manual integra somente os dados da empresa corrente.

Data       	Programador     		Motivo    
30/01/2012  Fernando Ferreira    Validação por empresa usando o Parametro FS_GRPEMP
/*/
//------------------------------------------------------------------- 
User Function FSLOJW05

Local bBlock, bErro //Tratamento de erro
Local lManual 		:= .F. 
Local	lEmpAutJob	:=	.F.
Local aRecnoSM0	:= {}   
Local lOpen			:= .F.
Local nI				:= 0

Private 	cNomRot	:= "FSJOBP05" //Define o nome da rotina principal para controle
Private 	cMensErr	:= ""  //Tratamento de erro
Private 	bMensCons:= {|X,Y| "["+Iif(lManual,"MAN","JOB")+"]["+cNomRot+"]["+DTOC(DATE())+" "+TIME()+"] "+Iif(!Empty(X),"Empresa "+X+" - ","")+Y}

ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
ConOut(Eval(bMensCons,"","Iniciado Integracao Envio de Cotação"))

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
ConOut(Eval(bMensCons,"","Finalizado Integração"))

//Caso ocorra erro é enviando um e-mail de alerta.
If (!Empty(cMensErr))
	Conout(cMensErr)
	//U_FSMaiAvi("Processo de Envio de cotação")
EndIf

Return Nil 


//-------------------------------------------------------------------
/*/{Protheus.doc} FExeProces
Executa o processo do job

@protected
@author	   Giulliano Santos
@since	   10/11/2011
@version	   P11
/*/
//-------------------------------------------------------------------  
Static Function FExeProces(lManual)

Local nHdlLock := -1
Local nTotReg	:= 0
Local nCtdReg	:= 0
Local cSD1REC	:= ""
Local cSD1CTR	:= ""
Local cQry	   := ""   
Local aArray	:= {} 
Local cFiltro  := "" 
Local aAreas 	:= {SD1->(GetArea()),GetArea()} //Salva todas as areas num array
Local lRetFun  := .T.
Local nQtdProd := 0

ConOut(Eval(bMensCons,SM0->M0_CODIGO,"Iniciando Processo na Empresa."))

//Verifica se a rotina ja esta sendo executada travando-a para nao ser executada mais de uma vez
If U_FSTraExe(@nHdlLock, cNomRot, .T., lManual)
	ConOut(Eval(bMensCons,SM0->M0_CODIGO,"Rotina já está em execucao"))
	Return(Nil)
EndIf

//Monta Arquivo de trabalho
FArqTrab()
cSD1REC := FMntQuery(1,lManual)

cQry+=CHR(13)+"SELECT SD1.D1_FILIAL AS CODIGOCENTRAL, SD1.D1_FORNECE AS CODIGOFORNECEDOR , SD1.D1_DOC, SD1.D1_SERIE ,SD1.D1_COD  AS CODIGOMATERIAL, SD1.D1_DTDIGIT AS DATACOTACAO , " 
cQry+=CHR(13)+"SD1.D1_LOJA AS LOJAFORNECEDOR, SD1.D1_SEGUM AS UNIDADECOM, "
//cQry+=CHR(13)+"SUM(D1_CUSTO) CUSTO, SUM(ISNULL(NULLIF (D1_QUANT,0),1)) QUANT , "
//cQry+=CHR(13)+"(SUM(D1_CUSTO) / SUM(ISNULL(NULLIF (D1_QUANT,0),1)) ) AS VALORUNITARIO "
cQry+=CHR(13)+"SUM(D1_CUSTO) CUSTO, SUM(ISNULL(NULLIF (D1_QTSEGUM,0),1)) QUANT , "
cQry+=CHR(13)+"(SUM(D1_CUSTO) / SUM(ISNULL(NULLIF (D1_QTSEGUM,0),1)) ) AS VALORUNITARIO "
cQry+=CHR(13)+"FROM " + RetSqlName("SD1") + " SD1,( "
cQry+=CHR(13)+"					 SELECT D1_DTDIGIT , D1_FILIAL, D1_FORNECE, D1_LOJA, D1_DOC, D1_SERIE ,D1_COD "
cQry+=CHR(13)+" 				    FROM " + RetSqlName("SD1") + " 
cQry+=CHR(13)+"				    WHERE R_E_C_N_O_ IN ("+cSD1REC+")   "
cQry+=CHR(13)+" 	   			 )AS TEMP "
cQry+=CHR(13)+"WHERE TEMP.D1_FILIAL = 	SD1.D1_FILIAL "
cQry+=CHR(13)+"AND TEMP.D1_FORNECE  = 	SD1.D1_FORNECE "
cQry+=CHR(13)+"AND TEMP.D1_LOJA     = 	SD1.D1_LOJA "
cQry+=CHR(13)+"AND TEMP.D1_DOC      = 	SD1.D1_DOC "
cQry+=CHR(13)+"AND TEMP.D1_SERIE    =  SD1.D1_SERIE "
cQry+=CHR(13)+"AND TEMP.D1_COD      = 	SD1.D1_COD "
cQry+=CHR(13)+"GROUP BY SD1.D1_FILIAL, SD1.D1_DTDIGIT, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_SEGUM, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_COD " 

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TRBCOT", .F., .T.)  

If (lManual) // Se a função for chamada via Mnu
	TRBCOT->(dbEval({||nTotReg++}))
	ProcRegua(nTotReg)
EndIf

TRBCOT->(dbGoTop())	
While (TRBCOT->(!Eof()))
	If (lManual) // Se a função for chamada via Mnu
		nCtdReg++
		IncProc("Processando: " + Strzero(nCtdReg,9) + " de " + Strzero(nTotReg,9))
	EndIf  
		
	dbSelectArea("TRBSD1")
	TRBSD1->(RecLock("TRBSD1", .T.))
	TRBSD1->CODIGOCENT := TRBCOT->CODIGOCENTRAL
	TRBSD1->CODIGOFORN := TRBCOT->CODIGOFORNECEDOR 
	TRBSD1->LOJAFORNEC := TRBCOT->LOJAFORNECEDOR 
	TRBSD1->D1_DOC     := TRBCOT->D1_DOC 
	TRBSD1->D1_SERIE   := TRBCOT->D1_SERIE  
	TRBSD1->UNIDADECOM := TRBCOT->UNIDADECOM  
	TRBSD1->CODIGOMATE := TRBCOT->CODIGOMATERIAL 
	TRBSD1->DATACOTACA := StoD(TRBCOT->DATACOTACAO) 
	
	TRBSD1->CUSTOORIGE := TRBCOT->CUSTO 
	TRBSD1->QUANTORIGE := TRBCOT->QUANT 
	
	nQtdProd := Iif((TRBSD1->QUANTORIGE == 0), 1, TRBSD1->QUANTORIGE)
	TRBSD1->VALORIGEM  := TRBCOT->VALORUNITARIO
	
	//Pega o custo do frete	
	TRBSD1->CUSTOFRETE := FGetFrete(TRBSD1->D1_DOC , TRBSD1->D1_SERIE, TRBSD1->CODIGOFORN, TRBSD1->LOJAFORNEC ,TRBSD1->CODIGOMATE, nQtdProd)     
	
	
	If TRBSD1->CUSTOFRETE == 0 //Nao teve frete
		TRBSD1->VALFIM  := TRBCOT->VALORUNITARIO
	Else // teve frete
		TRBSD1->VALFIM  :=  TRBSD1->CUSTOFRETE + TRBCOT->VALORUNITARIO
	EndIf 
	
	
	TRBSD1->(MsUnLock())		
	TRBCOT->(dbSkip()) 
EndDo 

TRBSD1->(dbGoTop())	

//Grava o arquivo de trabalho na tabela de integracao
While(TRBSD1->(!Eof()))
	If (lManual) // Se a função for chamada via Mnu
		nCtdReg++
		IncProc("Processando: " + Strzero(nCtdReg,9) + " de " + Strzero(nTotReg,9))
	EndIf  
		
	lRetFun := U_FSPutTab("TRBSD1","I") 
	TRBSD1->(dbSkip()) 
EndDo 

U_FSFecAre({"TRBSD1" , "TRBCOT"}) 
FFinProc()

//Destrava a rotina
U_FSTraExe(@nHdlLock, cNomRot)

ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
ConOut(Eval(bMensCons,SM0->M0_CODIGO,"Finalizando Processo na Empresa."))
aEval(aAreas, {|x| RestArea(x) }) //Restaura todas as areas dentro do array.
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FMntQuery
Monta query

@protected
@author	   Giulliano Santos
@since	   10/11/2011
@version	   P11
@params	   cFil 1 - Filtra somente SD1 2 - Filtra somente Frete    
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     		Motivo 
16/02/2012	Fernando Ferreira    Retira do filtro por filial 

/*/
//-------------------------------------------------------------------  
Static Function FMntQuery(cFiltro,lManual)

Local cSD1QRY := ""
Local cString := ""

cSD1QRY += CHR(13) +	"SELECT Max(R_E_C_N_O_) AS RECNOSD1"  
cSD1QRY += CHR(13) +	"FROM " + RetSqlName("SD1") + " AS SD1" 
cSD1QRY += CHR(13) +	"WHERE SD1.D1_ZFLAG = 'N'  " 
cSD1QRY += CHR(13) +	"		AND SD1.D1_TP = 'CC' "

If cFiltro == 1 // Notas do tipo normal
	cSD1QRY += CHR(13) +	"	AND SD1.D1_TIPO  = 'N'  "
	cSD1QRY += CHR(13) +	"	AND SD1.D1_ORIGLAN <>'FR' "
Else  // Notas dos tipo complemento de frete
	cSD1QRY += CHR(13) +	"	AND SD1.D1_TIPO  = 'C'  "
	cSD1QRY += CHR(13) +	"	AND SD1.D1_ORIGLAN = 'FR' "
EndIf

cSD1QRY += CHR(13) +	"		AND SD1.D_E_L_E_T_  <> '*' "
cSD1QRY += CHR(13) +	"GROUP BY D1_FILIAL , D1_COD , D1_FORNECE , D1_LOJA "
cSD1QRY += CHR(13) +	"ORDER BY D1_FILIAL , D1_COD , D1_FORNECE , D1_LOJA "

dbUseArea(.T., "TOPCONN", TCGenQry(,,cSD1QRY), "TRBRECS", .F., .T.)  

If (TRBRECS ->(Eof()))
	If (lManual)// Se a função for chamada via Mnu
		ApMsgAlert("Não existe registros para Integrar na Empresa:  " + SM0->M0_CODIGO + " !")
	Else
		ConOut(Eval(bMensCons,SM0->M0_CODIGO,"Não existe registros para Integrar."))
	EndIf  
	cString := "''"
Else
	While TRBRECS->(!Eof()) 
	   cString += cValToChar(TRBRECS->RECNOSD1) + ","
		TRBRECS->(dbSkip())
	EndDo
	cString := SubStr(cString, 1, Len(cString) - 1)
EndIf

TRBRECS->(dbCloseArea())

Return cString  

//-------------------------------------------------------------------
/*/{Protheus.doc} FFinProc
Encerrerar os campos

@protected
@author	   Giulliano Santos
@since	   10/11/2011
@version	   P11
@params	   cFil 1 - Filtra somente SD1 2 - Filtra somente Frete

/*/
//-------------------------------------------------------------------  
Static Function FFinProc()

Local cAliTmp := GetNextAlias()

BeginSql alias cAliTmp
	SELECT R_E_C_N_O_ AS RECNOO
	FROM %table:SD1% SD1,
	WHERE SD1.%notDel% 
	AND SD1.D1_FILIAL = %xfilial:SD1%
	AND SD1.D1_ZFLAG  = 'N'  
EndSql

SD1->(dbSetOrder(1))
While ((cAliTmp)->(!Eof()))
	SD1->(dbgoTo((cAliTmp)->RECNOO))
	SD1->(RecLock("SD1", .F.))
	SD1->D1_ZFLAG := 'S'
	SD1->(MsUnlock())			
	(cAliTmp)->(dbSkip())
EndDo 

(cAliTmp)->(dbCloseArea())
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FArqTrab
Monta Arquivo de Trabalho

@protected
@author	   Giulliano Santos
@since	   10/11/2011
@version	   P11
@params	   cFil 1 - Filtra somente SD1 2 - Filtra somente Frete

/*/
//-------------------------------------------------------------------  
Static Function FArqTrab()
/*************************************************************************************
* Cria os arquivos de trabalho
*
*******/
Local aTempStru := {}

//Itens da nota 
Aadd(aTempStru,{"CODIGOCENT","C",TamSx3("D1_FORNECE")[1],0})
Aadd(aTempStru,{"CODIGOFORN","C",TamSx3("D1_FORNECE")[1],0})	    
Aadd(aTempStru,{"LOJAFORNEC","C",TamSx3("D1_LOJA")[1],0})	    
Aadd(aTempStru,{"D1_DOC",    "C",TamSx3("D1_DOC")[1],0})
Aadd(aTempStru,{"D1_SERIE",  "C",TamSx3("D1_SERIE")[1],0})	    	    
Aadd(aTempStru,{"CODIGOMATE","C",TamSx3("D1_COD")[1],0})	    	    
Aadd(aTempStru,{"DATACOTACA","D",TamSx3("D1_DTDIGIT")[1]})
Aadd(aTempStru,{"CUSTOORIGE","N",TamSx3("D1_CUSTO")[1],TamSx3("D1_CUSTO")[2]})	
Aadd(aTempStru,{"UNIDADECOM","C",TamSx3("D1_SEGUM")[1],TamSx3("D1_SEGUM")[2]})	
Aadd(aTempStru,{"QUANTORIGE","N",TamSx3("D1_QUANT")[1],TamSx3("D1_QUANT")[2]})	
Aadd(aTempStru,{"VALORIGEM", "N",TamSx3("D1_CUSTO")[1],TamSx3("D1_CUSTO")[2]})	
Aadd(aTempStru,{"CUSTOFRETE","N",TamSx3("D1_CUSTO")[1],TamSx3("D1_CUSTO")[2]})	
Aadd(aTempStru,{"QUANTFRETE","N",TamSx3("D1_QUANT")[1],TamSx3("D1_QUANT")[2]})	
Aadd(aTempStru,{"VALFRETE",  "N",TamSx3("D1_CUSTO")[1],TamSx3("D1_CUSTO")[2]})	
Aadd(aTempStru,{"VALFIM",    "N",TamSx3("D1_CUSTO")[1],TamSx3("D1_CUSTO")[2]})	

cArqTrab := CriaTrab(aTempStru,.T.)

dbUseArea( .T.,, cArqTrab, "TRBSD1",.F.,.F.)
IndRegua("TRBSD1",cArqTrab,"CODIGOCENT+CODIGOFORNECEDOR+LOJAFORNECEDOR+D1_DOC+D1_SERIE",,,"Selecionando Registros...")

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FGetFrete
Pegar o frete para o produto

@protected
@author	   Giulliano Santos
@since	   10/11/2011
@version	   P11

/*/
//-------------------------------------------------------------------  
Static Function FGetFrete(cDocOri, cSerieOri, cForOri, cLojOri ,cCodProd, nQtdItens)
Local	aAreas := {SF8->(GetArea()),GetArea()} //Salva todas as areas num array
Local cDocFrt := CriaVar("F8_NFDIFRE" , .F.)
Local cSerFrt := CriaVar("F8_SEDIFRE" , .F.)
Local cForFrt := CriaVar("F8_FORNECE" , .F.)
Local cLojFrt := CriaVar("F8_LOJA"    , .F.)
Local cSunCus := 0 //Soma do Custo 
Local nCntAglFrt := 0 //Contador se os itens forem aglutinados


SF8->(dbSetOrder(2)) //F8_FILIAL, F8_NFORIG, F8_SERORIG, F8_FORNECE, F8_LOJA, R_E_C_N_O_, D_E_L_E_T_

If SF8->(dbSeek(xFilial("SF8") + cDocOri + cSerieOri + cForOri + cLojOri))
	
	cDocFrt := SF8->F8_NFDIFRE
	cSerFrt := SF8->F8_SEDIFRE 
	cForFrt := SF8->F8_FORNECE 
	cLojFrt := SF8->F8_LOJA 
	
	SD1->(dbSetOrder(1)) //D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, R_E_C_N_O_, D_E_L_E_T_
	If SD1->(dbSeek(xFilial("SD1") + cDocFrt + cSerFrt + cForFrt + cLojFrt + cCodProd)) 
		//While necessario caso o frete não esteja aglutinado
		While(SD1->(!Eof()) .And. SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD) == ; 
		                               (xFilial("SD1") + cDocFrt + cSerFrt + cForFrt + cLojFrt + cCodProd)) 
		      //Soma o valor do custo da nota de frete                         
		      cSunCus += SD1->D1_CUSTO 
		      nCntAglFrt++                          
		      SD1->(dbSkip())                         
		EndDo
  		If nCntAglFrt > 1
  		  //	cSunCus := cSunCus / nQtdItens
  		EndIf
	EndIf
EndIf


aEval(aAreas, {|x| RestArea(x) }) //Restaura todas as areas dentro do array.
Return cSunCus
          

