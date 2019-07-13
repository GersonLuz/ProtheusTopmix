#Include "Protheus.ch"     
#Include "TBICONN.ch"     
#include "Fileio.ch"

#Define _CTAB CHR(9) 
#Define _CRLF CHR(13) + CHR(10)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSFINP16
Recebimento de Arquivos RedeCard EEVC

@author        Giulliano
@since         20/03/2012
@version       P11
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo

/*/
//---------------------------------------------------------------------------------------
User Function FSFINP16

Local nXI	  := 0
Local cTitWin := "Processamento de arquivo de retorno RedeCard" 
Local cDescr  := "" 
Local cFunImp := "FSGETP16" //Função que será chamada pelo Wizard. 
Local cSemaf  := "FSGETP16" //Semáforo para a rotina não ser executada simultanamente na mesma empresa 

Private aFil := {}

cDescr  := "Este programa irá gravar o número do PV + RV nos titulos a receber, " 
cDescr  += "Para depois ser baixado pelo arquivo EEFI."

u_FSMntArr()

U_FSWizImp(cFunImp,cSemaf,cTitWin,cDescr,1) 

Return  Nil                                


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSGETP16
Função para processar os arquivos textos

@author        Giulliano
@since         20/03/2012
@version       P11
@obs

A função FSGETP09 é executada através deste comando, dentro do wizard padrao
aLogs := ExecBlock(cFunImport,.F.,.F., {oWizard,oReg,aFile} )

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo

/*/
//---------------------------------------------------------------------------------------
User Function FSGETP16()   

Local cMsgErr := ""
Local oWizard := PARAMIXB[01] //Objeto do wizard, caso seja preciso manipulá-lo
Local oReg 	  := PARAMIXB[02] //Barra de progresso

Local nHandle := 0
Local nQtdLin := 0 //Contando as linhas do arquivo

Local lErro   := .F.
Local aReg	  := {}  
Local aDados  := {}         

//006 - RV Rotativo
Local aRvRotaH	:=	{3,9,9,3,5,11,8,5,15,15,15,15,15,8,1}

//008 - CV / NSU Rotativo Pagamento crédito a vista
Local aRvRotaD  := {3,9,9,8,8,15,15,16,3,12,13,15,6,6,16,16,16,16,1,15,8,3,5} 

//010 - RV Parcelado sem juros
Local aRVHeader := {3,9,9,3,5,11,8,5,15,15,15,15,15,8,1}

//012 - CV / NSU parcelado sem juros - Header
Local aRvParcH  := {3,9,9,8,8,15,15,16,3,2,12,13,15,6,6,16,16,16,16,1,15,15,15,8,3,5} 

//014 - Parcelas parceladas sem juros - Detalhes
Local aRvParcD  := {3,9,9,8,8,2,15,15,15,8} 

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
	If !U_FStartWith(cLinha, "002") .And. lRet
		Aadd(aLog,"Arquivo inválido, este arquivo não é o EEVC" + cLinha)
		aDados := {}
		Exit
	EndIf
	
	lRet := .F.
	
	//006 - RV Rotativo
	If U_FStartWith(cLinha, "006")
		
		aReg := U_FSSepara(cLinha,aRvRotaH)	
		
		If aReg != Nil 
			Aadd(aDados,aReg) 
		Else
			Aadd(aLog,"Linha não está conforme layOut detalhes: " + cLinha)
			aDados := {}
			Exit
		EndIf	
		        
	EndIf	   
		
	//008 - CV / NSU Rotativo Pagamento crédito a vista
	If U_FStartWith(cLinha, "008")
		
		aReg := U_FSSepara(cLinha,aRvRotaD)	
		
		If aReg != Nil 
			Aadd(aDados,aReg) 
		Else
			Aadd(aLog,"Linha não está conforme layOut detalhes: " + cLinha)
			aDados := {}
			Exit
		EndIf	
		        
	EndIf	     
	
	//010 - RV Parcelado sem Juros - Header
	If U_FStartWith(cLinha, "010")
		
		aReg := U_FSSepara(cLinha,aRVHeader)	
		
		If aReg != Nil 
			Aadd(aDados,aReg) 
		Else
			Aadd(aLog,"Linha não está conforme layOut detalhes: " + cLinha)
			aDados := {}
			Exit
		EndIf	
		        
	EndIf	                               	
	
	//012 - CV / NSU parcelado sem juros - Header
	If U_FStartWith(cLinha, "012")
		
		aReg := U_FSSepara(cLinha,aRvParcH)	
		
		If aReg != Nil 
			Aadd(aDados,aReg) 
		Else
			Aadd(aLog,"Linha não está conforme layOut detalhes: " + cLinha)
			aDados := {}
			Exit
		EndIf	
		        
	EndIf	                               	
	
	//014 - Parcelas parceladas sem juros - Detalhes
	If U_FStartWith(cLinha, "014")
		
		aReg := U_FSSepara(cLinha,aRvParcD)	
		
		If aReg != Nil 
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
	Aadd(aLog,"Processamentos de Retorno REDECARD - EEVC TopMix")
	Aadd(aLog,"Data : " + DTOC(Date()))
	Aadd(aLog,"Hora : " + Time())
	Aadd(aLog,"Arquivo : " +  AllTrim(cNome) + AllTrim(cExt))	
	Aadd(aLog,"Operadora : REDECARD - EEVC")	
	Aadd(aLog,"Protheus - TOTVS")	
		 
	Aadd(aLog,"")
	Aadd(aLog,  PadR("FILIAL",    27) + _CTAB  +; 
				   PadR("CLIENTE",25) + _CTAB +;
				   PadR("DATA VENDA", 18) + _CTAB +;
				   PadR("OCORRENCIA" , 25) + _CTAB+; 
				   PadR("NSU"  , 19) + _CTAB +;
				   PadR("PARC" , 05) + _CTAB +; 
				   PadR("AUT"  , 15) + _CTAB +;
				   PadR("VALOR"  , TamSX3("D2_TOTAL")[1]) + _CTAB +; 
 				   PadR("VALOR COMIS"  , TamSX3("D2_TOTAL")[1]) + _CTAB +; 
  			 	   PadR("DT.LANCAM."	, 18) + _CTAB )
					   
	Aadd(aLog,  PadR("------",    27 , "-") + _CTAB  +; 
				   PadR("-------",25, "-") + _CTAB +;
				   PadR("----------", 18, "-") + _CTAB +;
				   PadR("----------" , 25, "-") + _CTAB+; 
				   PadR("---"  , 19, "-") + _CTAB +;
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
		If aDados[nX][1] == "006"
			
			dDataPg  :=  u_FSAjustDt(aDados[nX][14], 1)
			cBanco	:= GetMv("FS_BCOREDE")
			cAgencia := GetMv("FS_AGREDE")
			cConta 	:= GetMv("FS_CCREDE")
			nValParc := 0
	   	cParc 	:= ""  
	    
	   ElseIf aDados[nX][1] == "008"
			
			cNsuDoc	:= AllTrim(aDados[nX][10]) + AllTrim(aDados[nX][13]) //Chave da transação CV/NSU + Nº AUTORIZAÇÃO
			cNSU 		:= AllTrim(aDados[nX][10])
			cAut 		:= AllTrim(aDados[nX][13])
			nValParc := Val(aDados[nX][20]) / 100  							  //Valor da compra
			cParc    := PadL(cParc , TamSx3("E1_PARCELA")[1] , "0") 		  //Parcela    
			cPv		:= AllTrim(aDados[nX][2])
			cRV		:= AllTrim(aDados[nX][3])
			cFIL		:= u_FSPesArr(aDados[nX][2]) 
			cNumCar	:= AllTrim(aDados[nX][8])  
			nValTx	:= Val(aDados[nX][12]) / 100  							  //Desconto          
		 	dDataEmi :=  u_FSAjustDt(aDados[nX][04], 1)
			
			FSetTit(cNsuDoc,nValParc,dDataPg,aLog,cPv,cRV,cNsuDoc,cBanco,cAgencia,cConta,dDataEmi,cFIL,nValTx,cNumCar,cNSU,cAut,cParc) 
		EndIf		

		//Parcelamento sem Juros
		If aDados[nX][1] == "010"
			
			cBanco	:= AllTrim(aDados[nX][4])
			cAgencia := AllTrim(aDados[nX][5])
			cConta 	:= AllTrim(aDados[nX][6])
	   
	   ElseIf aDados[nX][1] == "012"
  			cNsuDoc	:= AllTrim(aDados[nX][11]) + AllTrim(aDados[nX][14]) 	//Chave da transação CV/NSU + Nº AUTORIZAÇÃO
			cNSU 		:= AllTrim(aDados[nX][11])
			cAut 		:= AllTrim(aDados[nX][14])			
			cNumCar	:= AllTrim(aDados[nX][8])
			nValParc := 0
	   	cParc 	:= ""
		 	dDataEmi :=  u_FSAjustDt(aDados[nX][04], 1)
		 	
	   ElseIf aDados[nX][1] == "014"
			nValParc := Val(aDados[nX][9]) / 100  									//Valor da compra
			cParc    := aDados[nX][6] 	           									//Parcela 
			dDataPg  := u_FSAjustDt(aDados[nX][10], 1)   
			cPv		:= AllTrim(aDados[nX][2])
			cRV		:= AllTrim(aDados[nX][3])
			cFIL		:= u_FSPesArr(aDados[nX][2])
			nValTx	:= Val(aDados[nX][08]) / 100  							  //Desconto
			FSetTit(cNsuDoc,nValParc,dDataPg,aLog,cPv,cRV,cNsuDoc,cBanco,cAgencia,cConta,dDataEmi,cFIL,nValTx,cNumCar,cNSU,cAut,cParc)  
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
Static Function FSetTit(cNsuDoc,nValParc,dDataPg,aLog,cPv,cRV,cNsuDoc,cBanco,cAgencia,cConta,dDataEmi,cFIL,nValTx,cNumCar,cNSU,cAut,cParc)  

Local cMsgErr := ""

If SE1->(dbSeek(xFilial("SE1") + "RCT" + PadR(cNsuDoc  , TamSx3("E1_ZNUMTID")[1] ) + PadL(cParc , TamSx3("E1_PARCELA")[1] , "0") ))			

	//Verifica se ainda nao houve baixa
	If Empty(SE1->E1_BAIXA)
		
		cNumCar := u_FSGetCli(SE1->E1_CLIENTE, SE1->E1_LOJA,cNumCar)
				
		If SE1->E1_VALOR == nValParc
		 	
		 	If Empty(SE1->E1_ZPV) .Or. Empty(SE1->E1_ZRV)
	  	     
		 		nReg := SE1->(recno())
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
		 				   PadR(cNsuDoc  , 19) + _CTAB +;
						   PadR(cParc , 05) + _CTAB +; 
		 				   PadR(cAut  , 15) + _CTAB +;
		 				   Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
						   Transform(nValTx   , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
						   PadR(dToc(dDataPg), 18) + _CTAB )
			 	EndIf
			
			Else
					Aadd(aLog,  PadR(cFIL,    27) + _CTAB  +; 
	 				   PadR(cNumCar ,25) + _CTAB +;
	 				   PadR(dToc(dDataEmi), 18) + _CTAB +;
	 				   PadR("DOC. JÁ PROCESSADO" , 25) + _CTAB+; 
	 				   PadR(cNsuDoc  , 19) + _CTAB +;
					   PadR(cParc , 05) + _CTAB +; 
	 				   PadR(cAut  , 15) + _CTAB +;
	 				   Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
					   Transform(nValTx   , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
					   PadR(dToc(dDataPg), 18) + _CTAB )
			EndIf
			 	
		 		
		Else
			Aadd(aLog,  PadR(cFIL,    27) + _CTAB  +; 
 				   PadR(cNumCar ,25) + _CTAB +;
 				   PadR(dToc(dDataEmi), 18) + _CTAB +;
 				   PadR("DOC. VALOR DIFERENTE" , 25) + _CTAB+; 
 				   PadR(cNsuDoc  , 19) + _CTAB +;
				   PadR(cParc , 05) + _CTAB +; 
 				   PadR(cAut  , 15) + _CTAB +;
 				   Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
				   Transform(nValTx   , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
				   PadR(dToc(dDataPg), 18) + _CTAB )
		EndIf 
	
	//Titulo ja baixado
	Else 
		Aadd(aLog,  PadR(cFIL,    27) + _CTAB  +; 
 				   PadR(cNumCar ,25) + _CTAB +;
 				   PadR(dToc(dDataEmi), 18) + _CTAB +;
 				   PadR("DOC. JÁ BAIXADO" , 25) + _CTAB+; 
 				   PadR(cNsuDoc  , 19) + _CTAB +;
				   PadR(cParc , 05) + _CTAB +; 
 				   PadR(cAut  , 15) + _CTAB +;
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
 				   PadR(cNsuDoc  , 19) + _CTAB +;
				   PadR(cParc , 05) + _CTAB +; 
 				   PadR(cAut  , 15) + _CTAB +;
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