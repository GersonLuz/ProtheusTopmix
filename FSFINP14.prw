#Include "protheus.ch"     
#Include "TBICONN.ch"     
#include "fileio.ch"

#Define _DATDEP 2 // Data do deposito
#Define _ID 	 6 // ID de Recebimento
#Define _VLRDIN 7 // Dinheiro
#Define _VLRCH  8 // Cheque
#Define _VLRTOT 9 // Total  
#Define _CTAB CHR(9) 

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSFINP14
Recebimento de Arquivos Cielo

@author        Giulliano
@since         20/03/2012
@version       P11
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo

/*/
//---------------------------------------------------------------------------------------
User Function FSFINP14

Local nXI	:= 0
Local cTitWin := "Processamento de arquivo de retorno cielo" 
Local cDescr  := "Este programa irá processar o arquivo de retorno da cielo." 
Local cFunImp := "FSGETP10" //Função que será chamada pelo Wizard. 
Local cSemaf  := "FSGETP10" //Semáforo para a rotina não ser executada simultanamente na mesma empresa 

Private aFil := {}
FMntArray()

U_FSWizImp(cFunImp,cSemaf,cTitWin,cDescr,1) 

Return  Nil                                


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSGETP10
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
User Function FSGETP10()   

Local cMsgErr := ""
Local oWizard := PARAMIXB[01] //Objeto do wizard, caso seja preciso manipulá-lo
Local oReg 	  := PARAMIXB[02] //Barra de progresso
Local aFile   := PARAMIXB[03] //Nome do arquivo que o usuário escolheu
Local nHandle := 0
Local nQtdLin := Max(U_FsFileLin(aFile[1]),1) //Contando as linhas do arquivo

Local lErro   := .F.
Local aReg	  := {}  
Local aDados  := {}         

Local aHeader := {1,10,8,8,8,7,5,2,1,20,3,177}//Array com as posições do arquivo do Header

Local aCabec  := {1,10,7,2,1,2,2,6,6,6,1,13,1,;
						13,1,13,1,13,4,5,14,2,6,2,6,;
						1,6,2,13,1,9,1,13,3,22,4,5,4,;
						2,8,18}//Array com as posições do arquivo do banco
						
Local aDetal  := {1,10,7,19,8,1,13,2,2,3,6,20,;
						6,13,02,13,13,9,4,8,2,20,6,;
						29,1,32}//Array com as posições do arquivo do banco

Local nPrc		:= 0  
Local nReg		:= 0
Local aLog		:= {}     

Local cBanco 	:= ""
Local cAgencia	:= ""
Local cConta	:= ""           
Local cNome		:= ""
Local cExt 		:= ""


nHandle := fopen(aFile[01] , FO_READWRITE + FO_SHARED ) //Abrindo o arquivo

//Enquanto houver linhas no arquivo, eu as leio
While((cLinha := u_FSRedLin(nHandle)) != Nil ) 
	
	oReg:Set(nPrc++ / nQtdLin * 100) 
	
	//Validar o Header
	If U_FStartWith(cLinha, "0")
		aReg := U_FSSepara(cLinha,aHeader)	  
		If aReg != Nil 
			If aReg[8] == "04" //Opção de extrado 
				Aadd(aDados,aReg) 
			Else
				Aadd(aLog," Opção de extrato diferente de 04 (pagamento com CV) " + cLinha)
				aDados := {}
				Exit
			EndIf
		Else
			Aadd(aLog,"Linha não está conforme layOut header: " + cLinha)
			aDados := {}
			Exit
		EndIf                               
	EndIf	         
	
	//Pegar a data de pgto
	If U_FStartWith(cLinha, "1")
		
		aReg := U_FSSepara(cLinha,aCabec)	
		
		If aReg != Nil 
			aReg[9] :=  cToD( AllTrim(SubStr(aReg[9] , 5 , 2)  + "/" + SubStr(aReg[9] , 3 , 2)  + "/" + SubStr(aReg[9] , 1, 2)) )
			Aadd(aDados,aReg) 
		Else
			Aadd(aLog,"Linha não está conforme layOut detalhes: " + cLinha)
			aDados := {}
			Exit
		EndIf
		        
	EndIf	                               	
	
	//Detalhes do arquivo
	If U_FStartWith(cLinha, "2")
		
		aReg := U_FSSepara(cLinha,aDetal)	
		
		aReg[5] :=  cToD( AllTrim(SubStr(aReg[5] , 7 , 8)  + "/" + SubStr(aReg[5] , 5 , 2)  + "/" + SubStr(aReg[5] , 1, 4)) )
		If aReg != Nil 
			Aadd(aDados,aReg) 
		Else
			Aadd(aLog,"Linha não está conforme layOut detalhes: " + cLinha)
			aDados := {}
			Exit
		EndIf
		        
	EndIf	                               	
	
EndDo

FClose (nHandle) //Fechando o arquivo 

// Processando os registros
If (!Empty(aDados))
	
	SplitPath ( aFile[1], "", "",  @cNome, @cExt )
	
	//dDataPg  := SToD(aDados[1][3])
	Aadd(aLog,"")
	Aadd(aLog,"Processamentos de Retorno Cielo TopMix")
	Aadd(aLog,"Data : " + DTOC(Date()))
	Aadd(aLog,"Hora : " + Time())
	Aadd(aLog,"Arquivo : " +  AllTrim(cNome) + AllTrim(cExt))	
	Aadd(aLog,"Operadora : CIELO")	
	Aadd(aLog,"Protheus - TOTVS")	
		 
	Aadd(aLog,"")
	Aadd(aLog,  PadR("FILIAL",    27) + _CTAB  +; 
				   PadR("CLIENTE",25) + _CTAB +;
				   PadR("DATA VENDA", 18) + _CTAB +;
				   PadR("OCORRENCIA" , 25) + _CTAB+; 
				  	PadR("AUT"  , 15) + _CTAB +;
				   PadR("PARC" , 05) + _CTAB +; 
				   PadR("NSU"  , 15) + _CTAB +;
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
		   
	
	SE1->(dbOrderNickName("FSIND00006")) // E1_FILIAL, E1_TIPO, E1_ZNUMTID, E1_PARCELA, R_E_C_N_O_, D_E_L_E_T_
  	  					
	For  nX := 2 To Len(aDados) //Começa a processar a partir da segunda linha, pois a primeira é o header
		
		oSay6:CCAPTION := "Efetuando lançamentos . . . "
   	oReg:Set(nX / nQtdLin * 100)      
   	
   	If AllTrim(aDados[nX][1]) == "1"

   		dDataPg 	:= aDados[nX][09]   	
		 	cBanco 	:= AllTrim(GetMv("FS_BCCIELO"))
			cAgencia	:= AllTrim(GetMv("FS_AGCIELO"))
			cConta	:= AllTrim(GetMv("FS_CCCIELO"))
			cFil		:= FPesArr(aDados[nX][02])   
	   	nValTx	:= Iif(Empty(aDados[nX][36]),0,Val(aDados[nX][36]) / 100)    	   
		
   	Else //Somente Cvs  	
   	
   		nValParc := (Val(aDados[nX][7]) / 100 ) //Valor da compra
	   	cParc    := aDados[nX][8] // Parcela   
	   	cNsuDoc	:= AllTrim(aDados[nX][11]) + AllTrim(aDados[nX][13]) // Chave da transação
	   	cNsu     := AllTrim(aDados[nX][11])
	   	cAut		:=	AllTrim(aDados[nX][13])
	   	cNumCar	:= AllTrim(aDados[nX][4]) // Numero do cartao
   		dDataEmi := aDados[nX][05]   	
	   	   	
	   	If SE1->(dbSeek(xFilial("SE1") + "RCT" + PadR(cNsuDoc  , TamSx3("E1_ZNUMTID")[1] ) + PadL(cParc , TamSx3("E1_PARCELA")[1] , "0") ))						   
			    
			    cNumCar := u_FSGetCli(SE1->E1_CLIENTE, SE1->E1_LOJA,cNumCar)
			    
				//Se o pré recebimento estiver pendente
				If Empty(SE1->E1_BAIXA)
					
					nValParc * (nValTx/100)
							
					If SE1->E1_VALOR == noRound((nValParc - (nValParc * (nValTx/100))),2) //Deduz o valor da taxa
					 		
						nReg := SE1->(recno())
						lErro := u_FGeraSE5(nReg,dDataPg,@cMsgErr,cNsuDoc,cBanco,cAgencia,cConta) 
					 	
					 	If lErro
					 		Aadd(aLog, cNsuDoc + " - GEROU INCONSISTêNCIA AO TENTAR SER REGISTRADO.")
					 		Aadd(aLog, cNsuDoc + " - LOG DE INCONSISTêNCIA.")  
				 			Aadd(aLog, cMsgErr)
					 	Else
					 		Aadd(aLog,  	PadR(cFIL,    27) + _CTAB  +; 
			 	 			   PadR(cNumCar ,25) + _CTAB +;
			 	 			   PadR(dToc(dDataEmi), 18) + _CTAB +;
			 	 			   PadR("DOC. BAIXADO" , 25) + _CTAB+; 
			 	 			   PadR(cNsu  , 15) + _CTAB +;
			 	 			   PadR(cParc , 05) + _CTAB +; 
			 	 			   PadR(cAut  , 15) + _CTAB +;
			 	 			   Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
 			 	 			   Transform(nValParc * (nValTx/100) , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
  			 	 			   PadR(dToc(dDataPg), 18) + _CTAB )
					 	EndIf
					 		
					Else
						Aadd(aLog,  	PadR(cFIL,    27) + _CTAB  +; 
			 	 			   PadR(cNumCar ,25) + _CTAB +;
			 	 			   PadR(dToc(dDataEmi), 18) + _CTAB +;
			 	 			   PadR("DOC. VALOR DIFERENTE" , 25) + _CTAB+; 
			 	 			   PadR(cNsu  , 15) + _CTAB +;
			 	 			   PadR(cParc , 05) + _CTAB +; 
			 	 			   PadR(cAut  , 15) + _CTAB +;
			 	 			   Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
 			 	 			   Transform(nValParc * (nValTx/100) , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
  			 	 			   PadR(dToc(dDataPg), 18) + _CTAB )
					EndIf 
				
				//Titulo ja baixado
				Else 
				Aadd(aLog,  	PadR(cFIL,    27) + _CTAB  +; 
			 	 				   PadR(cNumCar ,25) + _CTAB +;
			 	 				   PadR(dToc(dDataEmi), 18) + _CTAB +;
			 	 				   PadR("DOC. JA RECEBIDO" , 25) + _CTAB+; 
			 	 				   PadR(cNsu  , 15) + _CTAB +;
			 	 				   PadR(cParc , 05) + _CTAB +; 
			 	 				   PadR(cAut  , 15) + _CTAB +;
			 	 				   Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
 			 	 				   Transform(nValParc * (nValTx/100) , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
  			 	 				   PadR(dToc(dDataPg), 18) + _CTAB )
				EndIf
			
			//Caso o NSU nao for encontrado
			Else                                             
					Aadd(aLog,  PadR(cFIL,    27) + _CTAB  +; 
			 	 				   PadR(cNumCar ,25) + _CTAB +;
			 	 				   PadR(dToc(dDataEmi), 18) + _CTAB +;
			 	 				   PadR("DOC. NAO ENCONTRADO" , 25) + _CTAB+; 
			 	 				   PadR(cNsu  , 15) + _CTAB +;
			 	 				   PadR(cParc , 05) + _CTAB +; 
			 	 				   PadR(cAut  , 15) + _CTAB +;
			 	 				   Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
 			 	 				   Transform(nValParc * (nValTx/100) , PesqPict("SD2","D2_TOTAL")) + _CTAB +; 
  			 	 				   PadR(dToc(dDataPg), 18) + _CTAB )
			EndIf  
	    
		EndIf
		
	Next nX

Else
	Aadd(aLog,"NENHUM ARQUIVO PROCESSADO.")
EndIf

Return aLog        



//-------------------------------------------------------------------
/*/{Protheus.doc} FMntArray
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
Static Function FMntArray()
				
AADD(AFIL,{"1003763089", "00 - TOPMIX"}) 
AADD(AFIL,{"1016188380", "07 - BETIM"})
AADD(AFIL,{"1016503366", "11 - BRASíLIA"})
AADD(AFIL,{"1016503455", "18 - ITAQUERA"})
AADD(AFIL,{"1023738071", "02 - SERRA"})
AADD(AFIL,{"1026739583", "14 - TEIXEIRA DE FREITAS"})
AADD(AFIL,{"1026739699", "08 - JUIZ DE FORA"})
AADD(AFIL,{"1026739818", "15 - CARUARU"})
AADD(AFIL,{"1029178779", "02 - CAJU"})
AADD(AFIL,{"1029178809", "04 - NITERóI"})
AADD(AFIL,{"1029178833", "09 - SãO JOSE DOS CAMPOS"})
AADD(AFIL,{"1029178914", "13 - GUARATINGUETA"})
AADD(AFIL,{"1029179031", "16 - PARA DE MINAS"})
AADD(AFIL,{"1029179163", "10 - JACAREPAGUA"})
AADD(AFIL,{"1029179260", "20 - CAMAÇARI"})
AADD(AFIL,{"1029179333", "25 - BOM DESPACHO"})
AADD(AFIL,{"1029179422", "12 - SALVADOR"})
AADD(AFIL,{"1049179538", "06 - OLHOS D AGUA"})
AADD(AFIL,{"1029179740", "27 - CAMPO GRANDE"})
AADD(AFIL,{"1029179791", "23 - SEROPEDICA"})

Return Nil  


//-------------------------------------------------------------------
/*/{Protheus.doc} FPesArr
Pesquisa filial

@author        Giulliano Santos
@since         13/11/2011
@version       P11 
@obs				


Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador      Motivo

/*/
//-------------------------------------------------------------------
Static Function FPesArr(cPos)
Local nPosArr := 0
Local cFil    := ""

If (nPosArr := ASCan(aFil, {|x| AllTrim(x[1]) == AllTrim(cPos)})) > 0 
	cFil := aFil[nPosArr][2] 
EndIf

Return cFil