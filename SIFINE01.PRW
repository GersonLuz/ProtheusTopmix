#include "protheus.ch" 

//------------------------------------------------------------------- 
/*/{Protheus.doc} SIFINE01() 
Encampsulamento da rotina FINA420 Arquivo de Pagamentos

@protected	
@author		Ederson Colen
@since		21/06/2012
@version 	P11
@obs			Desenvolvimento Atendimento Pontual
				Criado este encapsulamento para adicionar mais um item de Data de Pagamento
				ao Grupo de perguntas AFI420.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 

User Function SIFINE01()

Local cVldPerg := PADR('AFI420',10)
Local lExistPe := .F.
Local aHelpPor := {}
Local nContPer := 0

Private cFilBord := ""

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

If ! lExistPe
	PutSx1(cVldPerg,StrZero(nContPer,2),"Data Pagamento Bordero?","Data Pagamento Bordero?","Data Pagamento Bordero?","mv_ch"+AllTrim(Str(nContPer)),"D",8,0,0,"G","","","","","mv_par"+StrZero(nContPer,2),"","","","","","","","","","","","","","","","",,,,"."+cVldPerg+StrZero(nContPer,2)+".")
	
	aHelpPor := {}
	Aadd(aHelpPor,"Data de Pagamento do Bordero." )
	PutSX1Help("P."+cVldPerg+StrZero(nContPer,2)+".",aHelpPor,aHelpPor,aHelpPor)
EndIf

FINA420()

Return ()