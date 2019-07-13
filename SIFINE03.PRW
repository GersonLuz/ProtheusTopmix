#include "protheus.ch" 

//------------------------------------------------------------------- 
/*/{Protheus.doc} SIFINE03() 
Encampsulamento da rotina FINA300

@protected	
@author		Ederson Colen
@since		21/06/2012
@version 	P11
@obs			Desenvolvimento Atendimento Pontual
				Encapsulamento da Rotina FINA300 para criação de mais uma pargunta ao grupo
				de perguntas FIN240 e criação da variável cFilBord que será utilizada nos
				seguintes programas F240ARQ e F240FILTC.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 

User Function SIFINE03()
                                                                                                                 
Local cVldPerg := PADR('FIN240',10)
Local lExistPe := .F.
Local aHelpPor := {}
Local nContPer := 0


Private cFilBord := "" 
Private cCanTelFil := ""

//Verifica se existe o Item ou busca qual é o numero de perguntas para adiconar no final.
SX1->(dbseek(cVldPerg))

While SX1->(! Eof()) .And. SX1->X1_GRUPO == cVldPerg

   If AllTrim(SX1->X1_PERGUNT) == "Data Pagamento Bordero?"
		lExistPe := .T.
		EXIT
	EndIf
	nContPer += 1

	SX1->(dbSkip())

EndDo

nContPer += 1

//Adiciona o Item caso não exista.
If ! lExistPe
	PutSx1(cVldPerg,StrZero(nContPer,2),"Data Pagamento Bordero?","Data Pagamento Bordero?","Data Pagamento Bordero?","mv_ch"+AllTrim(Str(nContPer)),"D",8,0,0,"G","","","","","mv_par"+StrZero(nContPer,2),"","","","","","","","","","","","","","","","",,,,"."+cVldPerg+StrZero(nContPer,2)+".")
	
	aHelpPor := {}
	Aadd(aHelpPor,"Data de Pagamento do Bordero." )
	PutSX1Help("P."+cVldPerg+StrZero(nContPer,2)+".",aHelpPor,aHelpPor,aHelpPor)
EndIf

FINA300()

Return ()