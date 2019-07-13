#INCLUDE "PROTHEUS.CH"                                                

//------------------------------------------------------------------- 
/*/{Protheus.doc} FC010BTN
Ponto de entrada para permitir a exibi��o e acionamento de um bot�o 
customizado, na tela de consulta de posi��o de clientes.

@author Fernando dos Santos Ferreira 
@since 19/04/2013
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FC010BTN() 
If Paramixb[1] == 1// Deve retornar o nome a ser exibido no bot�o 
	Return "Posi��o do Cliente" 
ElseIf Paramixb[1] == 3// Deve retornar a mensagem do bot�o 
	Return U_FSFINP17(SA1->A1_COD, SA1->A1_LOJA)
Else 
	Return 
Endif                      


