#Include "protheus.ch"     
#Include "TBICONN.ch"     
#include "fileio.ch"
#Define _CTAB CHR(9) 

#Define _CRLF CHR(13) + CHR(10)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSFINP20
Recebimento de Arquivos RedeCard EEVD

@author        Giulliano
@since         20/03/2012
@version       P11
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo

/*/
//---------------------------------------------------------------------------------------
User Function FSFINP20

Local nXI	  := 0
Local cTitWin := "Processamento de arquivo de retorno RedeCard" 
Local cDescr  := "" 
Local cFunImp := "FSGETP20" //Função que será chamada pelo Wizard. 
Local cSemaf  := "FSGETP20" //Semáforo para a rotina não ser executada simultanamente na mesma empresa 

Private aFil := {}

cDescr  := "Este programa irá receber os arquivos de cartão de debito" 
cDescr  += "Arquivo EEVD"

u_FSMntArr()

u_FSWizImp(cFunImp,cSemaf,cTitWin,cDescr,1) 

Return  Nil                                


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSGETP20
Função para processar os arquivos textos

@author        Giulliano
@since         20/03/2012
@version       P11
@obs

A função FSGETP20 é executada através deste comando, dentro do wizard padrao
aLogs := ExecBlock(cFunImport,.F.,.F., {oWizard,oReg,aFile} )

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo

/*/
//---------------------------------------------------------------------------------------
User Function FSGETP20()   

Local cMsgErr := ""
Local oWizard := PARAMIXB[01] //Objeto do wizard, caso seja preciso manipulá-lo
Local oReg 	  := PARAMIXB[02] //Barra de progresso
Local nHandle := 0
Local nQtdLin := 0 //Contando as linhas do arquivo
Local lErro   := .F.
Local aReg	  := {}  
Local aDados  := {}         
Local nPrc		:= 0  
Local nReg		:= 0
Local aLog		:= {}    
Local lRet		:= .T.   
Local	nValParc := 0
Local	cParc    := ""
Local	cNsuDoc	:= ""  
Local cPv		:= ""
Local cRV		:= ""    
Local cBanco	:= ""
Local cAgencia := ""
Local cConta 	:= ""     
Local cNome := "" 
Local cExt 	:= "" 

Private aFile   := PARAMIXB[03] //Nome do arquivo que o usuário escolheu

nHandle := fOpen(aFile[01] , FO_READWRITE + FO_SHARED ) //Abrindo o arquivo

nQtdLin := Max(U_FsFileLin(aFile[1]),1) //Contando as linhas do arquivo

//Enquanto houver linhas no arquivo, eu as leio
While((cLinha := u_FSRedLin(nHandle)) != Nil ) 
	
	oReg:Set(nPrc++ / nQtdLin * 100) 
	
	//Somente os detalhes do arquivo
	If !U_FStartWith(cLinha, "00") .And. lRet
		
		aReg := StrTokArr(cLinha , ",")
		
		If Len(aReg) <> 10
			Aadd(aLog,"Arquivo inválido, este arquivo não é o EEVD" + cLinha)
			aDados := {}
			Exit
		EndIf
	
	EndIf
	
	lRet := .F.   	
		
	//01 - Resumo de vendas
	If U_FStartWith(cLinha, "01")
		
		aReg := StrTokArr(cLinha , ",")
		
		If Len(aReg) >= 1 
			Aadd(aDados,aReg) 
		Else
			Aadd(aLog,"Linha não está conforme layOut detalhes: " + cLinha)
			aDados := {}
			Exit
		EndIf	
		        
	EndIf	     
	
	//05 - Resumo de vendas
	If U_FStartWith(cLinha, "05")
		
		aReg := StrTokArr(cLinha , ",")
		
		If Len(aReg) >= 1 
			Aadd(aDados,aReg) 
		Else
			Aadd(aLog,"Linha não está conforme layOut detalhes: " + cLinha)
			aDados := {}
			Exit
		EndIf	
		        
	EndIf	     
	                             	                            	
	
EndDo

FClose(nHandle) // Fechando o arquivo 

// Processando os registros
If (!Empty(aDados)) 

	SplitPath ( aFile[1], "", "",  @cNome, @cExt )
	
	//dDataPg  := SToD(aDados[1][3])
	Aadd(aLog,"")
	Aadd(aLog,"Processamentos de Retorno REDECARD - EEVD TopMix")
	Aadd(aLog,"Data : " + DTOC(Date()))
	Aadd(aLog,"Hora : " + Time())
	Aadd(aLog,"Arquivo : " +  AllTrim(cNome) + AllTrim(cExt))	
	Aadd(aLog,"Operadora : REDECARD - EEVD")	
	Aadd(aLog,"Protheus - TOTVS")	
		 
	Aadd(aLog,"")
	Aadd(aLog,  PadR("FILIAL",    27) + _CTAB  +; 
				   PadR("CLIENTE",25) + _CTAB +;
				   PadR("DATA VENDA", 18) + _CTAB +;
				   PadR("OCORRENCIA" , 25) + _CTAB+; 
				   PadR("NSU"  , 15) + _CTAB +;
				   PadR("PARC" , 05) + _CTAB +; 
				   PadR("AUT"  , 15) + _CTAB +;
				   PadR("VALOR"  , TamSX3("D2_TOTAL")[1]) + _CTAB +; 
 				   PadR("VALOR COMIS"  , TamSX3("D2_TOTAL")[1]) + _CTAB +; 
  			 	   PadR("DT.LANCAM."	, 18) + _CTAB )
					   
	Aadd(aLog,  PadR("------",    27 , "-") + _CTAB  +; 
				   PadR("-------",25, "-") + _CTAB +;
				   PadR("----------", 18, "-") + _CTAB +;
				   PadR("----------" , 25, "-") + _CTAB+; 
				   PadR("---"  , 15, "-") + _CTAB +;
				   PadR("----" , 05, "-") + _CTAB +; 
				   PadR("---"  , 15, "-") + _CTAB +;
				   PadR("-----"  , TamSX3("D2_TOTAL")[1], "-") + _CTAB +; 
 				   PadR("-----------"  ,TamSX3("D2_TOTAL")[1], "-") + _CTAB +; 
  			 	   PadR("----------"	, 18, "-") + _CTAB )			   

	SE1->(dbOrderNickName("FSIND00006")) // E1_FILIAL, E1_TIPO, E1_ZNUMTID, E1_PARCELA 
	
	For nX :=  1 To Len(aDados)
	    
   	oSay6:CCAPTION := "Efetuando lançamentos . . . "
   	oReg:Set(nX / nQtdLin * 100)      
		
		//CV / NSU Rotativo
		If aDados[nX][1] == "01"
		
			cBanco	:= GetMv("FS_BCOREDE")
			cAgencia := GetMv("FS_AGREDE")
			cConta 	:= GetMv("FS_CCREDE")
	   
	   ElseIf aDados[nX][1] == "05"
			
			dDataPg  := u_FSAjustDt(aDados[nX][11])
			dDataEmi := u_FSAjustDt(aDados[nX][4])
			cFIL		:= u_FSPesArr(aDados[nX][2])
			cNsuDoc	:= AllTrim(aDados[nX][10]) 							  //Chave da transação CV/NSU + Nº AUTORIZAÇÃO
			nValParc := Val(aDados[nX][7]) / 100  							  //Valor da compra
			nValTx	:= Val(aDados[nX][6]) / 100
			cNumCar  := AllTrim(aDados[nX][08]) 							  //Numero do cartao
			cPv		:= AllTrim(aDados[nX][02])
			cRV		:= AllTrim(aDados[nX][03])

			FSetTit(cNsuDoc,nValParc,dDataPg,aLog,cPv,cRV,cNsuDoc,cBanco,cAgencia,cConta,dDataEmi,cFIL,nValTx,cNumCar) 

		EndIf		
		
	Next nX	

Else
	Aadd(aLog,"NENHUM ARQUIVO PROCESSADO.")
EndIf

Return aLog        


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSetTit
Valida titulos

@author        Giulliano
@since         20/03/2012
@version       P11
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo

/*/
//---------------------------------------------------------------------------------------
Static Function FSetTit(cNsuDoc,nValParc,dDataPg,aLog,cPv,cRV,cNsuDoc,cBanco,cAgencia,cConta,dDataEmi,cFIL,nValTx,cNumCar)

Local cMsgErr := ""    
Local cParc   := PadL("0" , TamSx3("E1_PARCELA")[1] , "0")

If SE1->(dbSeek(xFilial("SE1") + "RCT" + PadR(cNsuDoc  , TamSx3("E1_ZNUMTID")[1] ) + cParc ))			

	//Verifica se ainda nao houve baixa
	If Empty(SE1->E1_BAIXA)
				
		If SE1->E1_VALOR == nValParc
			
			nReg := SE1->(recno())
			cNumCar := u_FSGetCli(SE1->E1_CLIENTE, SE1->E1_LOJA,cNumCar)
			
			
			lErro := FAltSE1(nReg,dDataPg,@cMsgErr,cPv,cRV,cNsuDoc,cBanco,cAgencia,cConta) 
			
			 		
			If lErro
		 		Aadd(aLog, cNsuDoc + " - GEROU INCONSISTêNCIA AO TENTAR SER REGISTRADO.")
		 		Aadd(aLog, cNsuDoc + " - LOG DE INCONSISTêNCIA.")  
				Aadd(aLog, cMsgErr)
		 	Else
		 			Aadd(aLog,  PadR(cFIL,    27) + _CTAB  +; 
 				   PadR(cNumCar ,25) + _CTAB +;
 				   PadR(dToc(dDataEmi), 18) + _CTAB +;
 				   PadR("DOC. BAIXADO" , 25) + _CTAB+; 
 				   PadR(cNsuDoc  , 15) + _CTAB +;
				   PadR(cParc , 05) + _CTAB +; 
 				   PadR("00"  , 15) + _CTAB +;
 				   Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
				   Transform(nValTx   , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
				   PadR(dToc(dDataPg), 18) + _CTAB )
		 	EndIf	 	
		 		
		Else
		
			Aadd(aLog,  PadR(cFIL,    27) + _CTAB  +; 
 				   PadR(cNumCar ,25) + _CTAB +;
 				   PadR(dToc(dDataEmi), 18) + _CTAB +;
 				   PadR("DOC. VALOR DIFERENTE" , 25) + _CTAB+; 
 				   PadR(cNsuDoc  , 15) + _CTAB +;
				   PadR(cParc , 05) + _CTAB +; 
 				   PadR("00"  , 15) + _CTAB +;
 				   Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
				   Transform(nValTx   , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
				   PadR(dToc(dDataPg), 18) + _CTAB )
		EndIf 
	
	//Titulo ja baixado
	Else 
		Aadd(aLog,  PadR(cFIL,    27) + _CTAB  +; 
 				   PadR(cNumCar ,25) + _CTAB +;
 				   PadR(dToc(dDataEmi), 18) + _CTAB +;
 				   PadR("DOC. JÁ ESTÁ BAIXADO" , 25) + _CTAB+; 
 				   PadR(cNsuDoc  , 15) + _CTAB +;
				   PadR(cParc , 05) + _CTAB +; 
 				   PadR("00"  , 15) + _CTAB +;
 				   Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
				   Transform(nValTx   , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
				   PadR(dToc(dDataPg), 18) + _CTAB )
	EndIf

//Caso o NSU nao for encontrado
Else

	Aadd(aLog,  PadR(cFIL,    27) + _CTAB  +; 
 				   PadR(cNumCar ,25) + _CTAB +;
 				   PadR(dToc(dDataEmi), 18) + _CTAB +;
 				   PadR("DOC. NAO ENCONTRADO" , 25) + _CTAB+; 
 				   PadR(cNsuDoc  , 15) + _CTAB +;
				   PadR(cParc , 05) + _CTAB +; 
 				   PadR("00"  , 15) + _CTAB +;
 				   Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
				   Transform(nValTx   , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
				   PadR(dToc(dDataPg), 18) + _CTAB )
EndIf   

Return Nil    


//--------------------------------------------------------------
/*/{Protheus.doc} FAltSE1
Altera os dados financeiros                                                 
                                                                
@param nReg 	  Recno do registro
@param nGetAcr   Valor de acrescimo
@param nGetDec	  Valor de decrescimo
@param cTipo     Tipo da liberação

@author Giulliano Santos
@since 02/02/2012  
@obs

                                                 
/*/                                                             
//--------------------------------------------------------------
Static Function FAltSE1(nReg,dDataPg,cMsgErr,cPv,cRV,cNsuDoc,cBanco,cAgencia,cConta) 

Local aAreas  := {SE1->(GetArea()),GetArea()}  
Local lErro   := .F.

// Pegar o nome do arquivo que processou o registro.
Local cFile   := SubStr( aFile[1] , RAT ( "\", aFile[1]) + 1 ) 

Private lMsErroAuto := .F.

//Posiciona do registro que está selecionado
SE1->(dbGoTo(nReg))

RegToMemory("SE1",.T.) //,,.T.) // Cria variáveis do SE1 para chamada da rotina padrão	

Begin Transaction                              	

	//Liga o processo
	u_FSPutVal("lAltSE1", .T.)
	
	aSE1  := {{"E1_FILIAL"	,xFilial("SE1")	,Nil},;
	 			 {"E1_PREFIXO"	,SE1->E1_PREFIXO	,Nil},;
				 {"E1_NUM"	  	,SE1->E1_NUM		,Nil},;
				 {"E1_PARCELA"	,SE1->E1_PARCELA 	,Nil},;
				 {"E1_TIPO"	 	,SE1->E1_TIPO		,Nil},;
				 {"E1_NATUREZ"	,SE1->E1_NATUREZ	,Nil},;
				 {"E1_CLIENTE"	,SE1->E1_CLIENTE	,Nil},;
				 {"E1_LOJA"	  	,SE1->E1_LOJA		,Nil},;
				 {"E1_EMISSAO"	,SE1->E1_EMISSAO	,Nil},;
				 {"E1_VENCTO" 	,SE1->E1_VENCTO	,Nil},;
				 {"E1_VENCREA"	,SE1->E1_VENCREA	,Nil},;
				 {"E1_MOEDA" 	,SE1->E1_MOEDA		,Nil},;
				 {"E1_ORIGEM"	,SE1->E1_ORIGEM	,Nil},;
				 {"E1_FLUXO"	,SE1->E1_FLUXO		,Nil},;
				 {"E1_VALOR"  	,SE1->E1_VALOR		,Nil},;
		 		 {"E1_ZARQ"  	,AllTrim(cFile)	,Nil},;
				 {"E1_ZPV"		,cPv					,Nil},;
		  	    {"E1_ZRV"		,cRV					,Nil}}
	   
	//Ordena o array
	aSE1 := U_FSAceArr(aSE1,"SE1")	
	
	MSExecAuto({|x,y| Fina040(x,y)},aSE1, 4) //Alteração
	
	If lMsErroAuto
		DisarmTransaction()
		cMsgErr := MemoRead(NomeAutoLog())
		Ferase(NomeAutoLog())
	EndIf	
	
	//Desliga o processo
	u_FSPutVal("lAltSE1", .F.)
	
	lErro := u_FGeraSE5(nReg,dDataPg,@cMsgErr,cNsuDoc,cBanco,cAgencia,cConta) 
	
	If lErro
		lMsErroAuto := lErro
	EndIf	

End Transaction	

aEval(aAreas, {|x| RestArea(x) }) 

Return lMsErroAuto    


//-------------------------------------------------------------------
/*/{Protheus.doc} FSMntArr
Monta array natureza

@author        Giulliano Santos
@since         13/11/2011
@version       P11 
@obs				
Projeto PneuSola FSWPD00157

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador      Motivo
13/11/2011 Giulliano Santos Solicitado pelo cliente
/*/
//-------------------------------------------------------------------
User Function FSMntArr()
			   
Aadd(aFil,{"032036442", "02 - CAJU"}) 
Aadd(aFil,{"032036817", "04 - NITERÓI"}) 
Aadd(aFil,{"032036930", "02 - SERRA"}) 
Aadd(aFil,{"032037805", "09 - SÃO JOSE CAMPOS"}) 
Aadd(aFil,{"032037031", "08 - JUIZ DE FORA"}) 
Aadd(aFil,{"032037155", "13 - GUARATINQUENTA"}) 
Aadd(aFil,{"032037201", "15 - CARUARU"}) 
Aadd(aFil,{"032037880", "25 - BOM DESPACHO"}) 
Aadd(aFil,{"032037317", "10 - JACAREPAGUÁ"}) 
Aadd(aFil,{"032037643", "23 - SEROPEDICA"}) 
Aadd(aFil,{"032038097", "12 - SALVADOR"}) 
Aadd(aFil,{"021883343", "18 - ITAQUERA"}) 
Aadd(aFil,{"021612560", "07 - BETIM"})  
Aadd(aFil,{"021883351", "11 - BRASILIA"}) 
Aadd(aFil,{"010744991", "00 - MATRIZ"})  

Return Nil  


//-------------------------------------------------------------------
/*/{Protheus.doc} FSPesArr
Pesquisa filial

@author        Giulliano Santos
@since         13/11/2011
@version       P11 
@obs				


Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador      Motivo

/*/
//-------------------------------------------------------------------
User Function FSPesArr(cPos)
Local nPosArr := 0
Local cFil    := ""

If (nPosArr := ASCan(aFil, {|x| AllTrim(x[1]) == AllTrim(cPos)})) > 0 
	cFil := aFil[nPosArr][2] 
EndIf

Return cFil       