#Include "protheus.ch"     
#Include "TBICONN.ch"     
#include "fileio.ch"

#Define _DATDEP 2 // Data do deposito
#Define _ID  	6 // ID de Recebimento
#Define _VLRDIN 7 // Dinheiro
#Define _VLRCH  8 // Cheque
#Define _VLRTOT 9 // Total  
#Define _CTAB CHR(9) 

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSFINP50
Recebimento de Arquivos GetNet

@author        .iNi Sistemas
@since         20/12/2015
@version       P11
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo

/*/
//---------------------------------------------------------------------------------------
User Function FSFINP50

Local nXI	:= 0
Local cTitWin := "Processamento de arquivo de retorno GetNet" 
Local cDescr  := "Este programa irá processar o arquivo de retorno da GetNet." 
Local cFunImp := "FSGETP50" //Função que será chamada pelo Wizard. 
Local cSemaf  := "FSGETP50" //Semáforo para a rotina não ser executada simultanamente na mesma empresa 

Private aFil := {}
FMntArray()

U_FSWizImp(cFunImp,cSemaf,cTitWin,cDescr,1) 

Return  Nil                                


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSGETP50
Função para processar os arquivos textos

@author        .iNi Sistemas
@since         20/12/2015
@version       P11
@obs

A função FSGETP50 é executada através deste comando, dentro do wizard padrao
aLogs := ExecBlock(cFunImport,.F.,.F., {oWizard,oReg,aFile} )

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo

/*/
//---------------------------------------------------------------------------------------
User Function FSGETP50()   

Local cMsgErr := ""
Local oWizard := PARAMIXB[01] //Objeto do wizard, caso seja preciso manipulá-lo
Local oReg 	  := PARAMIXB[02] //Barra de progresso
Local aFile   := PARAMIXB[03] //Nome do arquivo que o usuário escolheu
Local nHandle := 0
Local nQtdLin := Max(U_FsFileLin(aFile[1]),1) //Contando as linhas do arquivo

Local lErro   := .F.
Local aReg	  := {}  
Local aDados  := {}         

Local aHeader := {1,8,6,8,8,15,14,20,9,2,25,284} //Array com as posições do arquivo do Header -- Inicio com "0"

Local aCabec  := {1,15,2,3,9,8,8,3,6,11,9,9,12,12,12,12,12,12,12,2,2,2,15,15,8,12,12,18,12,15,3,1,1,114} //Array com as posições do arquivo do banco -- Inicio com "1"
						
Local aDetal  := {1,15,9,12,8,6,19,12,12,12,2,2,12,8,10,3,1,15,8,3,1,1,228} //Array com as posições do arquivo do banco -- Inicio com "2"

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
			If AllTrim(aReg[8]) <> "GETNET S.A." //"GETNET TECN.CAP/PROC" //-- Valida se o arquivo é da GetNet
				aDados := {}
				Exit
			EndIf
		Else
			Aadd(aLog,"Linha não está conforme layout header: "+cLinha)
			aDados := {}
			Exit
		EndIf                               
	EndIf	         
	
	//Validar Cabeçalho
	If U_FStartWith(cLinha, "1")
		aReg := U_FSSepara(cLinha,aCabec)	
		If aReg != Nil 
			Aadd(aDados,aReg) 
		Else
			Aadd(aLog,"Linha não está conforme layout detalhes: " + cLinha)
			aDados := {}
			Exit
		EndIf
	EndIf	                               	
	
	//Detalhes do arquivo
	If U_FStartWith(cLinha, "2")
		aReg := U_FSSepara(cLinha,aDetal)			
		If aReg != Nil 
			Aadd(aDados,aReg) 
		Else
			Aadd(aLog,"Linha não está conforme layout detalhes: " + cLinha)
			aDados := {}
			Exit
		EndIf		        
	EndIf	                               		
EndDo

FClose(nHandle) //-- Fechando o arquivo 

//-- Processando os registros
If (!Empty(aDados))
	
	SplitPath( aFile[1], "", "",  @cNome, @cExt )
	
	Aadd(aLog,"")
	Aadd(aLog,"Processamentos de Retorno GetNet TopMix")
	Aadd(aLog,"Data : " + DTOC(Date()))
	Aadd(aLog,"Hora : " + Time())
	Aadd(aLog,"Arquivo : " +  AllTrim(cNome) + AllTrim(cExt))
	Aadd(aLog,"Operadora : GetNet")
	Aadd(aLog,"Protheus - TOTVS")
	
	Aadd(aLog,"")
	Aadd(aLog,  PadR("FILIAL"		,27) + _CTAB  +;
				PadR("CLIENTE"		,25) + _CTAB +;
				PadR("DATA VENDA"	,18) + _CTAB +;
				PadR("OCORRENCIA" 	,25) + _CTAB+;
				PadR("NSU"  		,15) + _CTAB +;
				PadR("PARC" 		,05) + _CTAB +;
				PadR("AUT"  		,15) + _CTAB +;
				PadR("VALOR"  		,TamSX3("D2_TOTAL")[1]) + _CTAB +;
				PadR("VALOR COMIS"  ,TamSX3("D2_TOTAL")[1]) + _CTAB +;
				PadR("DT.LANCAM."	,18) + _CTAB )
	
	Aadd(aLog,  PadR("------"		,27, "-") + _CTAB  +;
				PadR("-------"		,25, "-") + _CTAB +;
				PadR("----------"	,18, "-") + _CTAB +;
				PadR("----------" 	,25, "-") + _CTAB+;
				PadR("---"  		,15, "-") + _CTAB +;
				PadR("----" 		,05, "-") + _CTAB +;
				PadR("---"  		,15, "-") + _CTAB +;
				PadR("-----"  		,TamSX3("D2_TOTAL")[1], "-") + _CTAB +;
				PadR("-----------"  ,TamSX3("D2_TOTAL")[1], "-") + _CTAB +;
				PadR("----------"	,18, "-") + _CTAB )
	
	SE1->(dbOrderNickName("FSIND00006")) // E1_FILIAL, E1_TIPO, E1_ZNUMTID, E1_PARCELA, R_E_C_N_O_, D_E_L_E_T_
								  
	cTpPag := ""	
	cFil := cFilAnt
	
	For  nX := 1 To Len(aDados) //Começa a processar a partir da segunda linha, pois a primeira é o header
		
		oSay6:CCAPTION := "Efetuando lançamentos . . . "
		oReg:Set(nX / nQtdLin * 100)
		
		If AllTrim(aDados[nX][1]) == "1"
			If AllTrim(aDados[nX][33]) == "+"
				dDataPg 		:= aDados[nX][07]
				cBanco 		:= aDados[nX][08]
				cAgencia		:= aDados[nX][09]
				cConta		:= aDados[nX][10]
				fBusBan(@cBanco,@cAgencia,@cConta)
				cTpPag		:= aDados[nX][20]
				//cFil		:= FPesArr(aDados[nX][02])
				//nValTx		:= Iif(Empty(aDados[nX][36]),0,Val(aDados[nX][36]) / 100)
			Else
				cTpPag := ""				
			EndIf			
		ElseIf cTpPag $ "PG|AC" .And. AllTrim(aDados[nX][1]) == "2"

			If AllTrim(aDados[nX][17]) == "C" .And. AllTrim(aDados[nX][22]) == "+" //-- Só trata transações com status de autorizada e de crédito

				nValParc := Val(aDados[nX][8])/100  //Valor da compra
				nValTx	:= Iif(Empty(aDados[nX][10]),0,Val(aDados[nX][10])/100)
				cParc    := aDados[nX][12] // Parcela
				cNsuDoc	:= AllTrim(aDados[nX][4]) // Chave da transação
				cNsu     := AllTrim(aDados[nX][3])
				cAut	 	:=	AllTrim(aDados[nX][15])
				cNumCar	:= AllTrim(aDados[nX][7]) // Numero do cartao
				dDataEmi := aDados[nX][05]
				
				If SE1->(dbSeek(xFilial("SE1")+"RCT"+PadR(SubStr(cAut,Len(cAut)-5,6),TamSx3("E1_ZNUMTID")[1])+PadL(cParc,TamSx3("E1_PARCELA")[1],"0")))
					
					cNumCar := u_FSGetCli(SE1->E1_CLIENTE, SE1->E1_LOJA,cNumCar)
					
					//Se o pré recebimento estiver pendente
					If Empty(SE1->E1_BAIXA)
						
						If (SE1->E1_VALOR+SE1->E1_ZTXOPER) == nValParc
							
							nReg := SE1->(recno())
							lErro := u_FGeraSE5(nReg,dDataPg,@cMsgErr,cAut,cBanco,cAgencia,cConta)
							
							If lErro
								Aadd(aLog, cNsuDoc + " - GEROU INCONSISTêNCIA AO TENTAR SER REGISTRADO.")
								Aadd(aLog, cNsuDoc + " - LOG DE INCONSISTêNCIA.")
								Aadd(aLog, cMsgErr)
							Else
								Aadd(aLog,  	PadR(cFIL,    27) + _CTAB  +;
								PadR(cNumCar ,25) + _CTAB +;
								PadR(dDataEmi, 18) + _CTAB +;
								PadR("DOC. BAIXADO" , 25) + _CTAB+;
								PadR(cNsu  , 15) + _CTAB +;
								PadR(cParc , 05) + _CTAB +;
								PadR(cAut  , 15) + _CTAB +;
								Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + _CTAB +;
								Transform(nValParc * (nValTx/100) , PesqPict("SD2","D2_TOTAL")) + _CTAB +;
								PadR(dDataPg, 18) + _CTAB )
							EndIf
							
						Else
							Aadd(aLog,  	PadR(cFIL,    27) + _CTAB  +;
							PadR(cNumCar ,25) + _CTAB +;
							PadR(dDataEmi, 18) + _CTAB +;
							PadR("DOC. VALOR DIFERENTE" , 25) + _CTAB+;
							PadR(cNsu  , 15) + _CTAB +;
							PadR(cParc , 05) + _CTAB +;
							PadR(cAut  , 15) + _CTAB +;
							Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + _CTAB +;
							Transform(nValParc * (nValTx/100) , PesqPict("SD2","D2_TOTAL")) + _CTAB +;
							PadR(dDataPg, 18) + _CTAB )
						EndIf
						
						//Titulo ja baixado
					Else
						Aadd(aLog,  	PadR(cFIL,    27) + _CTAB  +;
						PadR(cNumCar ,25) + _CTAB +;
						PadR(dDataEmi, 18) + _CTAB +;
						PadR("DOC. JA RECEBIDO" , 25) + _CTAB+;
						PadR(cNsu  , 15) + _CTAB +;
						PadR(cParc , 05) + _CTAB +;
						PadR(cAut  , 15) + _CTAB +;
						Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + _CTAB +;
						Transform(nValParc * (nValTx/100) , PesqPict("SD2","D2_TOTAL")) + _CTAB +;
						PadR(dDataPg, 18) + _CTAB )
					EndIf
					
					//Caso o NSU nao for encontrado
				Else
					Aadd(aLog,  PadR(cFIL,    27) + _CTAB  +;
					PadR(cNumCar ,25) + _CTAB +;
					PadR((dDataEmi), 18) + _CTAB +;
					PadR("DOC. NAO ENCONTRADO" , 25) + _CTAB+;
					PadR(cNsu  , 15) + _CTAB +;
					PadR(cParc , 05) + _CTAB +;
					PadR(cAut  , 15) + _CTAB +;
					Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + _CTAB +;
					Transform(nValParc * (nValTx/100) , PesqPict("SD2","D2_TOTAL")) + _CTAB +;
					PadR(dDataPg, 18) + _CTAB )
				EndIf
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

//-------------------------------------------------------------------
/*/{Protheus.doc} fBusBan
Pesquisa Banco

@author        .iNi
@since         13/01/2016
@version       P11 
@obs				


Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador      Motivo

/*/
//-------------------------------------------------------------------
Static Function fBusBan(cBanco,cAgencia,cConta)
        
Local cQuery := ""

cQuery := "SELECT A6_COD, A6_AGENCIA, A6_NUMCON FROM "+RetSqlName("SA6")
cQuery += "WHERE D_E_L_E_T_ = ' ' AND "
cQuery += "A6_COD = '"+cBanco+"' AND "
cQuery += "REPLICATE('0',6-LEN(LTRIM(A6_AGENCIA)))+LTRIM(A6_AGENCIA) = '"+cAgencia+"' AND "
cQuery += "REPLICATE('0',11-LEN(LTRIM(A6_NUMCON)))+LTRIM(A6_NUMCON) = '"+cConta+"' "
                                                    
cQuery := ChangeQuery(cQuery)

dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBQRY",.F.,.T.)
                                   
If !TRBQRY->(Eof())
	cBanco := TRBQRY->A6_COD
	cAgencia := TRBQRY->A6_AGENCIA
	cConta := TRBQRY->A6_NUMCON
EndIf

TRBQRY->(dbCloseArea())

Return()