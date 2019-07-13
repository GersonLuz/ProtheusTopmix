#include "protheus.ch" 
#include "msole.ch" 

//------------------------------------------------------------------- 
/*/{Protheus.doc} F420FIL() 
Ponto de Entrada da Rotina FINA420 retorna Filtro dos Borderos.

@protected	
@author		Ederson Colen
@since		21/06/2012
@version 	P11
@obs			Desenvolvimento Atendimento Pontual
				Este ponto de entrada irá chamar a tela para seleção dos Borderos e
				Filtro dos mesmo na Geração do arquivo CNAB
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 

User Function F420FIL()

Local cRetFil := ""
Local aAreas  := {GetArea(),SE2->(GetArea()),SEA->(GetArea())}
Local cVldPerg := PADR('AFI420',10)
Local lExistPe := .F.
Local nContPer := 0

//Buscando o parâmetro de Data de Pagamento Bordero Criado ao entrar na rotina SIFINE01
SX1->(dbseek(cVldPerg))

While SX1->(! Eof()) .And. SX1->X1_GRUPO == cVldPerg

   If AllTrim(SX1->X1_PERGUNT) == "Data Pagamento Bordero?"
      nContPer := Val(Right(AllTrim(SX1->X1_VAR01),2))-1
		lExistPe := .T.
		EXIT
	EndIf
	nContPer += 1

	SX1->(dbSkip())

EndDo

nContPer += 1

//Chamada da Tela de Filro e retorno do parâmetro.
cRetFil := U_SIFINP01("FINA420",MV_PAR01,MV_PAR02,MV_PAR05,&("MV_PAR"+StrZero(nContPer,2)))

AEval(aAreas,{|x| RestArea(x)})

Return (cRetFil)