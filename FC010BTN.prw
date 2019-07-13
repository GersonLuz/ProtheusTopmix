#INCLUDE "PROTHEUS.CH"                                                

//------------------------------------------------------------------- 
/*/{Protheus.doc} FC010BTN
Ponto de entrada para permitir a exibição e acionamento de um botão 
customizado, na tela de consulta de posição de clientes.

@author Fernando dos Santos Ferreira 
@since 19/04/2013
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FC010BTN() 
If Paramixb[1] == 1// Deve retornar o nome a ser exibido no botão 
	Return "Posição do Cliente" 
ElseIf Paramixb[1] == 3// Deve retornar a mensagem do botão 
	Return U_FSFINP17(SA1->A1_COD, SA1->A1_LOJA)
Else 
	Return 
Endif                      


