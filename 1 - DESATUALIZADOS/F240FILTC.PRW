#include "protheus.ch" 
#include "msole.ch" 

//------------------------------------------------------------------- 
/*/{Protheus.doc} F240FILTC() 
Ponto de Entrada da Rotina FINA240 valida o registro que esta sendo gravado no arquivo.

@protected	
@author		Ederson Colen
@since		21/06/2012
@version 	P11
@obs			Desenvolvimento Atendimento Pontual
				Retorna a validação dos Borderos que serão enviados ao Banco.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//----------------------------------------------------------------- 

User Function F240FILTC()

Local cRetFil := ""                          

If (Type('cFilBord') = "U" .Or. cFilBord = Nil)
   //	Aviso("A T E N C A O","Ha Rotina FINA300 foi encapsulada e o menu não esta configurado corretamente. Favor entrar em contato com a TI e solicitar que o menu seja corrigido chamando a Rotina SIFINE03.",{"OK"})
   	cFilBord := ""
	cRetFil := ""
Else
	cRetFil := " SEA->EA_NUMBOR $ "+Iif(Empty(cFilBord),'""',cFilBord)
EndIf

Return (cRetFil)