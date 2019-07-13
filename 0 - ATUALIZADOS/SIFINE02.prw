#include "protheus.ch" 
#include "msole.ch" 

//------------------------------------------------------------------- 
/*/{Protheus.doc} SIFINE02() 
Encampsulamento da rotina FINA240

@protected	
@author		Ederson Colen
@since		21/06/2012
@version 	P11
@obs			Desenvolvimento Atendimento Pontual.
				Este encapsulamento foi necessário para criar a pergunta de Data de Pagamento
				e a variável Private de data que será utilizada em outros pontos de entrada
				ja que a chamada do pergunte estava tornando o processo lento.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 

*********************************
User Function SIFINE02()
*********************************

//Local cRetFil  := ""
Local aAreas   := {GetArea(),SE2->(GetArea()),SEA->(GetArea())}
Local aPergs   := {}
Local aPergAux := {}
Local aHelpPor := {}
Local nXX      := 0
Local nXT      := 0
Local cValPeg	:= "SIFINE02" //Pergunta SX1 

// Variável que será utilizada nos pontos de entrada F240TIT e F241MARK
//Private dDtPgtBor	:= CToD("")  

// 1 - Texto Pergunta
// 2 - Tipo Campo (C,N,D,etc)
// 3 - Tamanho Campo
// 4 - Tamanho Decimal
// 5 - Tipo Get (G) ou (C) Choice
// 6 - F3
// 7 - Validação Campo
// 8 a 12 Opções.
// 13 - Texto do Help Tamanho Linha                                       '1234567890123456789012345678901234567890' )
//             1                        2   3 4 5   6  7  8  9  10 11 12  13
Aadd(aPergAux,{"Data Pagament. Bordero","D",8,0,"G","","","","","","","","Informe a Data de Pagamento Bordero"})

//Alimenta os arrays de Pergunta e Help.
For nXT := 1 To Len(aPergAux)
	 Aadd(aPergs,{aPergAux[nXT,01],aPergAux[nXT,01],aPergAux[nXT,01],"mv_ch"+AllTrim(Str(nXT)),;
					aPergAux[nXT,02],aPergAux[nXT,03],aPergAux[nXT,04],0,aPergAux[nXT,05],;
					aPergAux[nXT,07],"MV_PAR"+StrZero(nXT,2),;
					aPergAux[nXT,08],aPergAux[nXT,08],aPergAux[nXT,08],"","",;
					aPergAux[nXT,09],aPergAux[nXT,09],aPergAux[nXT,09],"","",;
					aPergAux[nXT,10],aPergAux[nXT,10],aPergAux[nXT,10],"","",;
					aPergAux[nXT,11],aPergAux[nXT,11],aPergAux[nXT,11],"","",;
					aPergAux[nXT,12],aPergAux[nXT,12],aPergAux[nXT,12],"",aPergAux[nXT,06],"","",""})
	 Aadd(aHelpPor,{aPergAux[nXT,13]})
Next nXT

//Cria perguntas (padrao)
//AjustaSx1(cValPeg,aPergs)

//Help das perguntas
For nXX := 1 To Len(aHelpPor)
    PutSX1Help("P."+cValPeg+StrZero(nXX,2),aHelpPor[nXX],aHelpPor[nXX],aHelpPor[nXX])
Next nXX

//Chamada das perguntas
Pergunte(cValPeg,.F.)

//Parametros Selecionados pelo usuario
//dDtPgtBor := MV_PAR01


FINA241()

AEval(aAreas,{|x| RestArea(x)})

Return Nil


return()