#Include "protheus.ch"     
#include "fileio.ch"

#Define _DATDEP 2 // Data do deposito
#Define _ID 	 6 // ID de Recebimento
#Define _VLRDIN 7 // Dinheiro
#Define _VLRCH  8 // Cheque
#Define _VLRTOT 9 // Total

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSFINP09
Função para processar os arquivos textos

@author        Giulliano
@since         20/03/2012
@version       P11
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo

/*/
//---------------------------------------------------------------------------------------
User Function FSFINP09

Local nXI	:= 0
Local cTitWin := "Processamento de Retorno Bancário" 
Local cDescr  := "Este programa irá processar o arquivo de retorno bancário." 
Local cFunImp := "FSGETP09" //Função que será chamada pelo Wizard. 
Local cSemaf  := "FSGETP09" //Semáforo para a rotina não ser executada simultanamente na mesma empresa 

U_FSWizImp(cFunImp,cSemaf,cTitWin,cDescr,1) 

Return  Nil                                


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSGETP09
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
User Function FSGETP09()   

Local cMsgErr := ""
Local oWizard := PARAMIXB[01] //Objeto do wizard, caso seja preciso manipulá-lo
Local oReg 	  := PARAMIXB[02] //Barra de progresso
Local aFile   := PARAMIXB[03] //Nome do arquivo que o usuário escolheu
Local nHandle := 0
Local nQtdLin := Max(U_FsFileLin(aFile[1]),1) //Contando as linhas do arquivo

Local lErro   := .F.
Local aReg	  := {}  
Local aDados  := {}         

Local aEstArq:= {1,8,5,1,6,40,15,15,15,8,2,117,7}//Array com as posições do arquivo do banco

Local nPrc		:= 0  
Local nReg		:= 0
Local aLog		:= {}

nHandle := fopen(aFile[01] , FO_READWRITE + FO_SHARED ) //Abrindo o arquivo

Aadd(aLog,"##-------------------------------------------------------------------------------##")
Aadd(aLog,"   Processamentos de Retorno Bancário TopMix")
Aadd(aLog,"   Data : " + DTOC(Date()))
Aadd(aLog,"   Hora : " + Time())
Aadd(aLog,"   Protheus - Totvs")
Aadd(aLog,"##-------------------------------------------------------------------------------##")

//Enquanto houver linhas no arquivo, eu as leio
While((cLinha := u_FSRedLin(nHandle)) != Nil ) 
	
	oReg:Set(nPrc++ / nQtdLin * 100) 
	
	//Somente os detalhes do arquivo
	If U_FStartWith(cLinha, "1")
		
		aReg := U_FSSepara(cLinha,aEstArq)	
		
		If aReg != Nil 
			Aadd(aDados,aReg) 
		Else
			Aadd(aLog,"Linha não está conforme layOut: " + cLinha)
			aDados := {}
			Exit
		EndIf
		        
	EndIf	                               	
	
EndDo

FClose (nHandle) //Fechando o arquivo 

// Processando os registros
If (!Empty(aDados))
	For  nX := 1 To Len(aDados) 
		
		oSay6:CCAPTION := "Efetuando lançamentos . . . "
   	oReg:Set(nX / nQtdLin * 100) 
		
		//O banco retorna com um caractere a mais a esquerda
		cID 	  := SubStr(aDados[nX][_ID], 2)  		
		
		dDate   := cToD(Transform(aDados[nX][_DATDEP],"@R 99/99/9999"))
		
		//Os dois valores finais sao casas decimais
		nVlrDin := Val(aDados[nX][_VLRDIN]) / 100
	   nVlrChq := Val(aDados[nX][_VLRCH])  / 100			
		
		P06->(dbSetOrder(1)) //P06_FILIAL, P06_ID 
		If P06->(dbSeek(xFilial("P06") + cID))			
			
			//Se o pré recebimento estiver pendente
			If P06->P06_STATUS == "P"  
						
				//Somente se pendente
				If nVlrDin > 0 .And. nVlrChq > 0
					Aadd(aLog,  cID + " - Contém valores de dinheiro e cheque.")
				
				ElseIf AllTrim(P06->P06_TIPO) == "R$"    
				
					If P06->P06_VALOR == nVlrDin
				 		nReg := P06->(recno())
				 		lErro := u_FGeraSE1(nReg,dDate,@cMsgErr,.F.) 
				 		
				 		If lErro
				 			Aadd(aLog,  cID + " - Gerou inconsistência ao tentar ser integrado.")
				 			Aadd(aLog,  cID + " - Log de inconsistência.")  
			 				Aadd(aLog,  cMsgErr)
				 		Else
				 			Aadd(aLog,  cID + " - Integrado com sucesso.")
				 		EndIf
				 		
					Else
						Aadd(aLog,  cID + " - Valor do pré recebimento é diferente do total recebido.")
					EndIf 
				
				
				ElseIf AllTrim(P06->P06_TIPO) == "CH"    
				
				
					If P06->P06_VALOR == nVlrChq  
						
						//Somente realiza Integrado sem compensação
						P06->(RecLock("P06",.F.))				
						P06->P06_STATUS := "E" 
						P06->P06_DEPOSI := dDate
						P06->(MsUnlock())	
						Aadd(aLog,  cID + " - Integrado sem compensação.")	
					Else
						Aadd(aLog,  cID + " - Valor do pré recebimento é diferente do total recebido.")
					EndIf 
				
				
				EndIf
		 		
		 	//Se o pré recebimento estiver cancelado
			ElseIf P06->P06_STATUS == "C"  
				Aadd(aLog,  cID + " - ID está cancelado no Pré-Recebimento.")
			
			//Se o pré recebimento estiver integrado			
			ElseIf P06->P06_STATUS == "I"  
				Aadd(aLog,  cID + " - ID já integrado pela rotina.")
			
			EndIf
		
		Else
			Aadd(aLog,cID + " - ID não encontrado." )
		EndIf
		
	Next nX

Else
	Aadd(aLog,"Não foi processado nenhum registro." )
EndIf

Return aLog