#Include "Protheus.ch"  
#include "fileio.ch"
#Define  _CRLF  	CHR(13)+CHR(10)
#Define  _LIMSTR 	1048576

Static __aOrdSE1		:= {}  
Static __lProSE1		:= .F.
Static __lExcSE1		:= .F.
Static __lAltSE1		:= .F.

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSLibReb
Lib Especifica para o projeto de Compensação

Função criada para efeitos de compatibilidade evitando que seja criada uma função com o 
nome deste prw.

@author        Giulliano Santos
@since         14/03/2012
@version       P11
/*/
//---------------------------------------------------------------------------------------
User Function FSLibReb() 

Return Nil               


//-------------------------------------------------------------------
/*/{Protheus.doc} FSValQry
Verifica quantos registros existem na tabela com o codigo passado em parametro

@author	   Cláudio Luiz da Silva
@since	   

@param 		cTabela    alias da tabela. Exemplo: "SB1"
@param 		aFiltro    array com campo e valor: Exemplo: "B1_LOCAL","01"

@return     lRet       .T. se foi localizado registros  

@obs        A rotina ja filtra filial, nao precisando informar esse campo.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
14/03/12   Giulliano Santos	Alteração Projeto Recb
/*/
//-------------------------------------------------------------------
User Function FSValQry(cTabela, aFiltro)

Local aArea  := GetArea()
Local cTipo  := Iif(Left(cTabela,1)=="S",SubStr(cTabela,2),cTabela)
Local lRet   := .T.
Local cQuery := ""

cQuery := "SELECT COUNT(*) NRECS FROM " + RetSqlName(cTabela) + " "
cQuery += "WHERE D_E_L_E_T_ = ' ' AND "
cQuery += cTipo+"_FILIAL = '"+ xFilial(cTabela)+"' AND "

																																																																								For nXi:= 1 To Len(aFiltro)
	If ValType(aFiltro[nXi,2])=="C"
		cQuery += Alltrim(aFiltro[nXi,1])+ " = '"+ Alltrim(aFiltro[nXi,2]) + "' "
	ElseIf ValType(aFiltro[nXi,2])=="N"
		cQuery += Alltrim(aFiltro[nXi,1])+ " =  "+ Alltrim(Str(aFiltro[nXi,2])) + " "
	EndIf

	//Se tiver mais de um filtro e nao for o ultimo filtro, adiciona o "AND"
	If (Len(aFiltro)>1) .And. (Len(aFiltro)<>nXi)
		cQuery+= " AND "
	EndIf
Next nXi
	
cQuery := ChangeQuery(cQuery)

dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBQRY",.F.,.T.)

If TRBQRY->NRECS > 0
	Help(" ",1,"NAOPODE",,"Registro esta relacionado na tabela "+cTabela+"!",2)
   lRet:= .F.
Endif                                    

dbCloseArea()

RestArea(aArea)

Return(lRet)        


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FsPutVal()
Atualiza os valores das variáveis estáticas de acordo com os parâmetros. 
O primeiro parâmetro corresponde a uma string indicando qual variável deve ser atualizada.
O segundo parâmetro corresponde ao valor que a variável deverá receber.

@author        Rafael Almeida
@since         02/04/2010
@version       P11
@obs
Exemplo: 		U_FSPutVal("aReg",aReg)

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
19/03/12   Giulliano Santos	Adequação para uso na TopMix
/*/
//---------------------------------------------------------------------------------------
User Function FsPutVal(cVarAux,xValAux)

Default cVarAux := ""               
Default xValAux := ""

Do Case
	Case Upper(cVarAux) == Upper("aOrdSE1")
		__aOrdSE1		:= xValAux
	Case Upper(cVarAux) == Upper("lProSE1")
		__lProSE1		:= xValAux
	Case Upper(cVarAux) == Upper("lExcSE1")
		__lExcSE1		:= xValAux
	Case Upper(cVarAux) == Upper("lAltSE1")
		__lAltSE1		:= xValAux
EndCase

Return Nil   


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FsRebVal
Retorna os valores de cada uma das variáveis static criadas neste PRW.
O parâmetro passado corresponde ao nome da variável da qual você deseja o valor.
O retorno da função é o valor da variável.

@author        Rafael Almeida
@since         02/04/2010
@version       P11
@obs
aReg  := aClone(U_FsRebVal("aReg"))                                   

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
14/02/12   Giulliano Santos	Alteração Projeto TopMix
/*/
//---------------------------------------------------------------------------------------
User Function FsRebVal(cVarAux)

Local	xValAux   := ""
Default cVarAux := ""               

Do Case
	Case Upper(cVarAux) == Upper("aOrdSE1")
		xValAux := __aOrdSE1	
	Case Upper(cVarAux) == Upper("lProSE1")
		xValAux := __lProSE1	
	Case Upper(cVarAux) == Upper("lExcSE1")
		xValAux := __lExcSE1	
	Case Upper(cVarAux) == Upper("lAltSE1")
		xValAux := __lAltSE1
EndCase

Return xValAux     


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSValArq
Função que valida os campos no SX3

@author        Waldir
@since         14/02/12 
@version       P11
@obs


Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
14/02/12   Giulliano Santos	Alteração Projeto TopMix
/*/
//---------------------------------------------------------------------------------------
User Function FSValArq(aAuxCpos,cAlias)
	Local aLogs := {} 
	Local nX := 0
	For nX := 1 to Len(aAuxCpos)
		If( Empty(TamSx3(aAuxCpos[nX]) ))
		  	aAdd(aLogs,"Erro 001 - O campo "+aAuxCpos[nX]+" não existe na tabela "+cAlias+" ")
		EndIF
	Next
Return aLogs


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSRedLin
Le um Arquivo Texto

@author        Waldir
@since         14/02/12 
@version       P11
@obs


Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
14/02/12   Giulliano Santos	Alteração Projeto TopMix
/*/
//---------------------------------------------------------------------------------------    
User Function FSRedLin(nHandle) 

Local cLinha 	:= ""
Local cAux 		:= ""
Local nQtdRed 	:= 0

//Varre cada byte do arquivo	                                   
While((nQtdRed := FRead (nHandle, cAux, 1 ))  > 0)
	If(cAux == chr(13))		
		exit	
	EndIf	
	cLinha += cAux
EndDo

If(nQtdRed <= 0)
	cLinha := Nil
Else
	cLinha := StrTran(cLinha,chr(10),"")
EndIf

Return cLinha
      

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSWizImp
Wizzard de importação

@author        Waldir
@since         14/02/12 
@version       P11
@obs


Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
14/02/12   Giulliano Santos	Alteração Projeto TopMix
/*/
//---------------------------------------------------------------------------------------    
//
User Function FSWizImp(cFunImport,cRotina,cTitWin,cDescr,nQtdArq) 
Local cLog		:= ""
Local cDesc2	:= ""   
Local nReg		:= 0
Local oReg		:= Nil //Objeto da barra de progresso
Local oWizard	:= Nil //Objeto do Wizard
Local oParFile	:= Nil   
Local cGetFile := ""
Local aLogs		:= {}
Local nX			:= 0
Local aFile		:= {}
Local aObj		:= {}

Default cRotina:= ""     
Default nQtdArq := 1

aFile := Array(nQtdArq)
aObj  := Array(nQtdArq,3)

AFill(aFile,Space(255) )
	
//Garantindo que somente 1 pessoa estará executando a Importação
If(MayIUseCode(cEmpAnt + cRotina))          

	//Inicializando o wizard com o primeiro painel
	oWizard := apwizard():New( cTitWin , "" ,cTitWin ,"", {|| FExistFile(aFile,.T.) }  ,  ,.T. , "troco" , , .f. , {0,0,350,650} ) 
	@ 05, 15 SAY oSay1 VAR cDescr OF oWizard:oMPanel[1] PIXEL		
	@ 15, 15 SAY oSay2 VAR "Selecione o arquivo para a Importação" OF oWizard:oMPanel[1] PIXEL

	@ 20 + 1 * 20, 15 SAY 		aObj[1][1] 	VAR "Arquivo" OF oWizard:oMPanel[1] PIXEL
	@ 20 + 1 * 20, 40 MSGET 	aObj[1][2]  VAR aFile[1]  When .F. SIZE 110, 010 OF oWizard:oMPanel[1] valid(FExistFile(aFile[1] ,.F.) .or. Empty( aFile[1]  ) )  PIXEL    

	@ 20 + 1 * 20, 155 BUTTON	aObj[1][3]  PROMPT "&Buscar" SIZE 037, 012 OF oWizard:oMPanel[1]  ACTION {|| ;
	aFile[1]  := PadR(cGetFile( 'RET |*.RET| TXT |*.TXT|' , 'Arquivos RET / TXT', 1, 'C:\', .T., GETF_LOCALHARD,.T., .T. ),255) } PIXEL

	If(nQtdArq >= 2)
		@ 20 + 2 * 20, 15 SAY 		aObj[2][1] 	VAR "Arquivo" OF oWizard:oMPanel[1] PIXEL
		@ 20 + 2 * 20, 40 MSGET 	aObj[2][2]  VAR aFile[2]  SIZE 110, 010 OF oWizard:oMPanel[1] valid(FExistFile(aFile[2] ,.F.) .or. Empty( aFile[2]  ) )  PIXEL    
		@ 20 + 2 * 20, 155 BUTTON	aObj[2][3]  PROMPT "&Buscar" SIZE 037, 012 OF oWizard:oMPanel[1]  ACTION {|| ;
		aFile[2]  := PadR(cGetFile( 'RET |*.RET| TXT |*.TXT|' , 'Arquivos RET / TXT', 1, 'C:\', .T., GETF_LOCALHARD,.T., .T. ),255) } PIXEL
	EndIf
   
  	If(nQtdArq >= 3)
		@ 20 + 3 * 20, 15 SAY 		aObj[3][1] 	VAR "Arquivo" OF oWizard:oMPanel[1] PIXEL
		@ 20 + 3 * 20, 40 MSGET 	aObj[3][2]  VAR aFile[3]  SIZE 110, 010 OF oWizard:oMPanel[1] valid(FExistFile(aFile[3] ,.F.) .or. Empty( aFile[3]  ) )  PIXEL    
		@ 20 + 3 * 20, 155 BUTTON	aObj[3][3]  PROMPT "&Buscar" SIZE 037, 012 OF oWizard:oMPanel[1]  ACTION {|| ;
		aFile[3]  := PadR(cGetFile( 'RET |*.RET|' , 'Arquivos RET', 1, 'C:\', .T., GETF_LOCALHARD,.T., .T. ),255) } PIXEL
	EndIf
	
	//Segundo Painel: Confirmar
	oPanel := oWizard:NewPanel ("Confirmar Importação" , "" , {|| .t.} ,{|| .t. }   ,   , .t.  ) 
	
	@ 05, 15 SAY oSay4 VAR "O Wizard iniciará o processo..." OF oWizard:oMPanel[2] PIXEL
	@ 15, 15 SAY oSay5 VAR "Pressione Avançar para continuar" OF oWizard:oMPanel[2] PIXEL

	//Terceiro Painel: Importação e status
	oPanel := oWizard:NewPanel ("Processando Solicitação" ,"" , {||, .F.} ,{|| .t. }   , {|| .t. }  , .t. ,{||  oWizard:DisableButtons(),aLogs := ExecBlock(cFunImport,.F.,.F., {oWizard,oReg,aFile} ), cLog := FGerLog(aLogs) , oWizard:SetPanel(4), oWizard:EnableButtons()  } ) 
	@ 30, 10 SAY oSay6 VAR "Progresso Total " OF oWizard:oMPanel[3] PIXEL
	oReg := TMeter():New(45,10,{|u|if(Pcount()>0,nMeter1:=u,nReg)},100,oWizard:oMPanel[3],200,16,,.T.)

   //Quarto Painel: Termino da Importação e Log Final
	oPanel := oWizard:NewPanel ("Importação Concluída" ,"" , {||  .F.} ,{|| .t. }   ,   , .t.  ) 
	//@ 01, 01 GET oMemo  VAR cLog MEMO SIZE 325,90 OF  oWizard:oMPanel[4] PIXEL
   
   @ 01, 01 GET oMemo VAR cLog OF oWizard:oMPanel[4] MULTILINE SIZE 325,90 READONLY HSCROLL NO VSCROLL PIXEL 
   oFont := TFont():New('Courier new',,12,.T.)
   oMemo:oFont := oFont
   oMemo:lWordWrap := .F.
   
   @ 95, 280 BUTTON oBtnBuscar PROMPT "&SalvarLog" SIZE 037, 012 OF oWizard:oMPanel[4]  ACTION {|| cFile := cGetFile( 'Log |*.Log|' , 'Arquivos de Log', 1, 'C:\', .F., GETF_LOCALHARD,.T., .T. ), FSalvaLog(aLogs,cFile) } PIXEL
		
	oWizard:oDlg:lEscClose := .T.
	oWizard:Activate ( .t. ) 
Else 
	MsgAlert("Não foi possivel realizar a tarefa"+chr(13)+ "Outro usuário já está executando a rotina. " + chr(13) + "Tente novamente mais tarde")
EndIf

Leave1Code( cEmpAnt + cRotina )

Return Nil


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FExistFile
Wizzard de importação

@author        Waldir
@since         14/02/12 
@version       P11
@obs


Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
14/02/12   Giulliano Santos	Alteração Projeto TopMix
/*/
//---------------------------------------------------------------------------------------
Static Function FExistFile(aFile,lMensEmpty)
Local lRet := .T.
Local nX := 0 
Local cFile := "" 
	
If(ValType(aFile) == "C") 
	aFile := {aFile}
EndIF
	
For nX := 1 to Len(aFile) 
	cFile := aFile[nX]
	If !File(cFile)
		lRet := .F.
		If(lMensEmpty .Or. !Empty(cFile))
			MsgStop('O arquivo ' + AllTrim(cFile) + " não foi encontrado. "  )
		EndIf
	EndIf
Next

Return lRet


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSalvaLog
Salvar o arquivo de log

@author        Waldir
@since         14/02/12 
@version       P11
@obs


Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
14/02/12   Giulliano Santos	Alteração Projeto TopMix
/*/
//---------------------------------------------------------------------------------------
Static Function FSalvaLog(aLogs,cFile)

	Local nHandle := FCreate (cFile)  
	Local nX := 0
	Local cLin := ""
   
	For nX:= 1 to Len(aLogs)
		cLin := aLogs[nX] + chr(13) + chr(10)
		FWrite (nHandle,cLin )
	Next
	
	FClose(nHandle)
	
Return Nil                                                                                                                        


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FGerLog
Gerar arquivo de log

@author        Waldir
@since         14/02/12 
@version       P11
@obs


Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
14/02/12   Giulliano Santos	Alteração Projeto TopMix
/*/
//---------------------------------------------------------------------------------------
Static Function FGerLog(aLogs)
Local nX := 0
Local cLin := ""
   
For nX:= 1 to Len(aLogs)
	cLin += aLogs[nX] + chr(13) + chr(10)
	If(Len(cLin) > 50000)
		Exit
	EndIf
Next
Return cLin


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FsFileLin
Gerar arquivo de log

@author        Waldir
@since         14/02/12 
@version       P11
@obs
Conta quantas linhas há em um arquivo


Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
14/02/12   Giulliano Santos	Alteração Projeto TopMix
/*/
//---------------------------------------------------------------------------------------
User Function FsFileLin(cFile) 
Local nQtdReg	:= 0

//Abre o arquivo a ser importado
ft_FUse(AllTrim(cFile))
//Conta quantas linha têm  
nQtdReg := FT_FLastRec()
//Fecha o arquivo 
ft_FUse()

Return nQtdReg                                                                           


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSSepara
Separa o array

@author        Giulliano
@since         14/02/12 
@version       P11
@obs
Conta quantas linhas há em um arquivo


Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
14/02/12   Giulliano Santos	Alteração Projeto TopMix
/*/
//---------------------------------------------------------------------------------------
User Function FSSepara(cLinha,aTam)	
Local aReg    := {}
Local nTamTot := 0
Local nLido   := 0
Local cAux	  := ""
Local nX		  := 0

AEval(aTam,{|x| nTamTot += x})

If(Len(cLinha) != nTamTot) 
	aReg := Nil
Else
	For nX := 1 to Len(aTam)
		cAux := AllTrim(Substr(cLinha,nLido + 1,aTam[nX]))
		nLido += aTam[nX]
		AAdd(aReg,cAux)
	Next		
EndIF
Return aReg   


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FStartWith
Busca se o texto esta contido no dentro da string

@author        Giulliano
@since         14/02/12 
@version       P11
@obs
Conta quantas linhas há em um arquivo


Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
14/02/12   Giulliano Santos	Alteração Projeto TopMix
/*/
//---------------------------------------------------------------------------------------
User Function FStartWith(cTexto, cInicio)

Local lRet := .F.

lRet := Empty(cInicio) .Or. Substr(Upper(cTexto),1, Len(AllTrim(cInicio)))== AllTrim(Upper(cInicio))
                               
Return  lRet                  


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSAjustDt
Busca se o texto esta contido no dentro da string

@author        Giulliano
@since         14/02/12 
@version       P11
@obs

@params nOpc = 1 Converte de DDMMAAAA formato caracter para DD/MM/AAAA formato data
		  nOpc = 2 Converte 
 		  nOpc = 3 Converte 

@Returm 			Data formatada

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
14/02/12   Giulliano Santos	Alteração Projeto TopMix
/*/
//---------------------------------------------------------------------------------------
User Function FSAjustDt(cData, nOpc)

Local dDate := Date()

If nOpc == 1
	cData :=	SubStr(cData , 1 , 2 )  + "/" + SubStr(cData , 3 , 2 )  +  "/" + SubStr(cData , 5 , 4 )      
	dDate := cToD(cData)
EndIf

Return dDate          


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FGeraSE5
Gerar SE5

@author        Giulliano
@since         20/03/2012
@version       P11
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo

/*/
//---------------------------------------------------------------------------------------
User Function FGeraSE5(nReg,dDataPg,cMsgErr,cNsuDoc,cBanco,cAgencia,cConta)    			

Local aAreas  	:= {SE1->(GetArea()),GetArea()}
Local nX			:= 0	 
Local aSE5 		:= {}

Private lMsErroAuto := .F.    

RegToMemory("SE1",.T.) //,,.T.) // Cria variáveis do SE1 para chamada da rotina padrão	

aAdd( aSE5, {"E1_PREFIXO"  , SE1->E1_PREFIXO					,Nil})	
aAdd( aSE5, {"E1_NUM"      , SE1->E1_NUM		 			  	,Nil})	
aAdd( aSE5, {"E1_PARCELA"  , SE1->E1_PARCELA					,Nil})	
aAdd( aSE5, {"E1_TIPO"     , SE1->E1_TIPO						,Nil})	
aAdd( aSE5, {"E1_CLIENTE"  , SE1->E1_CLIENTE					,Nil})	
aAdd( aSE5, {"E1_LOJA"     , SE1->E1_LOJA				   	,Nil})	
aAdd( aSE5, {"AUTBANCO"  	, cBanco							  , Nil})	
aAdd( aSE5, {"AUTAGENCIA"  , cAgencia						  , Nil})	
aAdd( aSE5, {"AUTCONTA"  	, cConta							  , Nil}) 
aAdd( aSE5, {"AUTDTBAIXA"  , dDataBase							,Nil})
//aAdd( aSE5, {"AUTDTCREDITO", dDataPg							,Nil})
aAdd( aSE5, {"AUTHIST"     , "Cartao TopMix " + cNsuDoc 	,Nil})
aAdd( aSE5, {"AUTVALREC"   , SE1->E1_VALOR 				   ,Nil})	

MSExecAuto({|x,y| Fina070(x,y)},aSE5,3)

If lMsErroAuto
	DisarmTransaction()
	cMsgErr := MemoRead(NomeAutoLog())
	Ferase(NomeAutoLog())
EndIf	

aEval(aAreas, {|x| RestArea(x)})
Return lMsErroAuto    


//-------------------------------------------------------------------
/*/{Protheus.doc} FSGetCli
Pega o cliente do titulo NCC

@author        Giulliano Santos
@since         13/11/2011
@version       P11 
@obs				


Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador      Motivo

/*/
//-------------------------------------------------------------------
User Function FSGetCli(cCliente, cLoja,cNumCar)
Local aAreas  	 := {SE1->(GetArea()),GetArea()}
Local cNome   	 := ""
Local cAliasSE1 := GetNextAlias()  

Local cNum := SE1->E1_NUM
Local cPrefix := SE1->E1_PREFIXO


BeginSql alias cAliasSE1
SELECT
	SA1.A1_NREDUZ 
FROM

	SE1010 AS SE1 
	INNER JOIN
	SA1010 AS SA1 ON SA1.A1_FILIAL = %xfilial:SA1% 
	AND SA1.A1_COD = SE1.E1_CLIENTE 
	AND SA1.A1_LOJA = SE1.E1_LOJA 
	AND SA1.%NotDel%

WHERE
	SE1.E1_FILIAL = %xfilial:SE1%
	AND SE1.E1_NUM = %exp:cNum%    
	AND SE1.E1_PREFIXO = %exp:cPrefix%    
	AND SE1.E1_TIPO = 'NCC' 
	AND SE1.E1_CLIENTE = %exp:cCliente%    
	AND SE1.E1_LOJA = %exp:cLoja%    
	AND SE1.%NotDel%
	
EndSql	

//Verifica se a query retornou vazia, caso sim, sera exibido uma mensagem informando ao usuario
If !((cAliasSE1)->(Eof()))
	cNome := (cAliasSE1)->A1_NREDUZ 
Else
	cNome := cNumCar
EndIf
	
(cAliasSE1)->(dbCloseArea())

aEval(aAreas, {|x| RestArea(x)})
Return cNome                           