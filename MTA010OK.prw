#Include "Protheus.ch"

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MTA010OK()
Ponto de entrada na confirmação da tela do cadastro de produto.
        
@author Rafael Almeida
@return lRet	Ser for verdadeiro permite a inclusão do produto.
@since 09/11/11                                                 
@obs
Ponto de Entrada utiliza a função FSINTP05.
/*/
//---------------------------------------------------------------------------------------
User Function MTA010OK()   

Local lRet := .T.
//Integração Protheus X KP
If !Inclui .And. !Altera
	lRet := U_FSINTP05("E",SB1->B1_COD)
EndIf

Return lRet       


