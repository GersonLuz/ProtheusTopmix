#Include "protheus.ch"
#Define  _CRLF  CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} FSFINC02
Cadastro de Operadoras de cartao

@author	   Giulliano Santos Silva
@since	   14/03/2012
@version	   P11
@obs	      
Projeto
PneuSola FSWPD005464

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FSFINC02

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "P05"

dbSelectArea("P05")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Operadoras de Cartão","U_FP05DEL()",cVldAlt)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FP05DEL
Valida se pode excluir a operadora de cartao

@author	   Giulliano Santos Silva
@since	   14/03/2012
@version	   P11
@obs	      
Projeto
                                          		
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FP05DEL()

Local lRetFun	:= .T. // Retorno
Local aTabVal	:= {}  // Tabelas a serem validadas
Local nXi     	:= 0   // Contador


Aadd(aTabVal, {"SE1",{{"E1_CLIENTE",P05_CODOPE},;
							 {"E1_LOJA", 	P05_LOJA}}})  

For nXi:= 1 To Len(aTabVal)
	lRetFun	:= U_FSValQry(aTabVal[nXi][1], aTabVal[nXi][2])
	If !lRetFun
		Exit
	EndIf
Next nXi

Return(lRetFun)