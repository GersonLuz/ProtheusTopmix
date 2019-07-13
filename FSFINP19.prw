#Include "protheus.ch"     
#Include "TBICONN.ch"     
#include "fileio.ch"

#Define _CRLF CHR(13) + CHR(10)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSFINP19
Recebimento de Arquivos RedeCard EEFI

@author        Giulliano
@since         20/03/2012
@version       P11
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo

/*/
//---------------------------------------------------------------------------------------
User Function FSFINP19

Local nXI	  := 0
Local cTitWin := "Processamento de arquivo de retorno RedeCard" 
Local cDescr  := "" 
Local cFunImp := "FSGETP19" //Função que será chamada pelo Wizard. 
Local cSemaf  := "FSGETP19" //Semáforo para a rotina não ser executada simultanamente na mesma empresa 

cDescr  := "Este programa irá baixar os titulos recebidos pela redecard, " 
cDescr  += "arquivo EEFI."

U_FSWizImp(cFunImp,cSemaf,cTitWin,cDescr,1) 

Return  Nil                                


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSFINP19
Função para processar os arquivos textos

@author        Giulliano
@since         20/03/2012
@version       P11
@obs

A função FSGETP19 é executada através deste comando, dentro do wizard padrao
aLogs := ExecBlock(cFunImport,.F.,.F., {oWizard,oReg,aFile} )

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo

/*/
//---------------------------------------------------------------------------------------
User Function FSGETP19()   

Local cMsgErr := ""
Local oWizard := PARAMIXB[01] //Objeto do wizard, caso seja preciso manipulá-lo
Local oReg 	  := PARAMIXB[02] //Barra de progresso
Local aFile   := PARAMIXB[03] //Nome do arquivo que o usuário escolheu
Local nHandle := 0
Local nQtdLin := Max(U_FsFileLin(aFile[1]),1) //Contando as linhas do arquivo

Local lErro   := .F.
Local aReg	  := {}  
Local aDados  := {}         


//030 - Header de arquivo
Local aHeader 	 := {3,8,8,34,22,6,9,15,20}

//034 - Creditos
Local aCreditos := {3,9,11,8,15,1,3,6,11,8,9,8,1,1,15,15,5,2,9}

//035 - Ajustes net / desagendamentos
Local aAjustes :=  {3,9,9,8,15,1,2,28,16,8,9,15,8,6,9,8,15,1,8,15,15,15,15,12,6,1,11,15,15}

Local nPrc		:= 0  
Local nReg		:= 0
Local aLog		:= {}    
Local lRet		:= .T.   
Local	nValParc := 0
Local	cParc    := ""
Local	cNsuDoc	:= ""  
Local cPv		:= ""
Local cRV		:= ""

nHandle := fOpen(aFile[01] , FO_READWRITE + FO_SHARED ) //Abrindo o arquivo

Aadd(aLog,"##-------------------------------------------------------------------------------##")
Aadd(aLog,"	  Processamentos de Retorno RedeCard - EEFI - TopMix")
Aadd(aLog,"   Data : " + DTOC(Date()))
Aadd(aLog,"   Hora : " + Time())
Aadd(aLog,"   Protheus - Totvs")
Aadd(aLog,"##-------------------------------------------------------------------------------##")

//Enquanto houver linhas no arquivo, eu as leio
While((cLinha := u_FSRedLin(nHandle)) != Nil ) 
	
	oReg:Set(nPrc++ / nQtdLin * 100) 
	
	//Somente os detalhes do arquivo
	If !U_FStartWith(cLinha, "030") .And. lRet
		Aadd(aLog,"Arquivo inválido, este arquivo não é o EEFI" + cLinha)
		aDados := {}
		Exit
	EndIf
	
	lRet := .F.
	
	//034 - Creditos
	If U_FStartWith(cLinha, "034")
		
		aReg := U_FSSepara(cLinha,aCreditos)	
		
		If aReg != Nil 
			Aadd(aDados,aReg) 
		Else
			Aadd(aLog,"Linha não está conforme layOut detalhes: " + cLinha)
			aDados := {}
			Exit
		EndIf	
		        
	EndIf	   
		
	
	//035 - Creditos
	If U_FStartWith(cLinha, "035")
		
		aReg := U_FSSepara(cLinha,aAjustes)	
		
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
	
	SE1->(dbOrderNickName("FSIND00007")) //E1_FILIAL, E1_ZPV, E1_ZRV, E1_PARCELA, E1_VENCTO, R_E_C_N_O_, D_E_L_E_T_
	
	For nX :=  1 To Len(aDados)
	
		oSay6:CCAPTION := "Efetuando lançamentos . . . "
   	oReg:Set(nX / nQtdLin * 100)        	
	   
		//034 - Créditos
		If aDados[nX][1] == "034"
			dDataPg  := u_FSAjustDt(aDados[nX][12], 1) //Data da RV origem
			dDataLan := u_FSAjustDt(aDados[nX][04], 1) //Data do pagamento
			nValParc := (Val(aDados[nX][5]) / 100)
	   	cParc 	:= SubStr(aDados[nX][17],1,2)
			cStatus  := aDados[nX][18]                                                 	
			cRV		:= aDados[nX][11] 
			cPV		:= aDados[nX][19] 			
			FSetTit(dDataPg,dDataLan,nValParc,cParc,cStatus,cRV,cPV,@aLog)
		EndIf		

		//035 - Ajustes
		If aDados[nX][1] == "035"
			cMotAjust  := aDados[nX][7] + Space(2) + aDados[nX][8]
			Aadd(aLog,  "035 - Ponto de Venda:    " + cPV + " Resumo Venda: " + cRV + " Parcela: " + cParc + " Data de pgto: " + dtoc(dDataPg) )
			Aadd(aLog,  "035 - Motivo do ajuste:  " + cMotAjust)
			Aadd(aLog,  "035 - Valor após ajuste: " + Transform(nValParc , PesqPict("SD2","D2_TOTAL"))) 
		EndIf		

  		Aadd(aLog,  "") 	
	Next nX	

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
Static Function FSetTit (dDataPg,dDataLan,nValParc,cParc,cStatus,cRV,cPV,aLog)

Local cMsgErr := ""
Local cNsuDoc := xFilial("SE1") + cPV + cRV + PadL(cParc , TamSx3("E1_PARCELA")[1] , "0") + dtoC(dDataPg)

If SE1->(dbSeek(xFilial("SE1") + cPV + cRV + PadL(cParc , TamSx3("E1_PARCELA")[1] , "0") ))			
   
	//Verifica se ainda nao houve baixa
	If Empty(SE1->E1_BAIXA)
				
		If SE1->E1_VALOR == nValParc
		 	
		 	If cStatus $ ('00#01#02#03#04#05#06#07#08')
			 	
			 	nReg := SE1->(recno())
				lErro := u_FGeraSE5(nReg,dDataLan,@cMsgErr,cNsuDoc)    
				
				If lErro
					Aadd(aLog, cNsuDoc + " - Gerou inconsistência ao tentar ser registrado.")
					Aadd(aLog, cNsuDoc + " - Log de inconsistência.")  
			 		Aadd(aLog, cMsgErr)
				Else
					Aadd(aLog,  cNsuDoc + " - Baixado com sucesso.")
				EndIf
			
			Else
				
				Aadd(aLog,  cNsuDoc + " - Status de pgto invalido verifique. " + cStatus)
			
			EndIf	
		
		Else
			Aadd(aLog,  cNsuDoc + " - Valor recebido não é o valor da parcela.")
		EndIf 
	
	//Titulo ja baixado
	Else 
		Aadd(aLog,  cNsuDoc + " - PV/RV se encontra baixado.")
	EndIf

//Caso o NSU nao for encontrado
Else
	Aadd(aLog, cNsuDoc + " - PV/RV não existente  ( Tipo: " + "  RCT" + Space(1) + "DtPgto: " + dToc(dDataPg) + ;
									Space(1) + "Parc: " + cParc +   ;
								 	" Val R$ " + Transform(nValParc , PesqPict("SD2","D2_TOTAL")) + ")." )
EndIf   

Return Nil    