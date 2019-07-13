#Include "Protheus.ch"

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MT010INC()
Ponto de entrada após a inclusão do produto.
        
@author Rafael Almeida
@since 09/11/11
@return Nil
@obs
Função utiliza a função FSINTP05.
/*/
//---------------------------------------------------------------------------------------
User Function MT010INC()   

//Integração Protheus X KP
U_FSINTP05("I",SB1->B1_COD)

Return Nil


