#Include "Protheus.ch"

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MT010INC()
Ponto de entrada ap�s a inclus�o do produto.
        
@author Rafael Almeida
@since 09/11/11
@return Nil
@obs
Fun��o utiliza a fun��o FSINTP05.
/*/
//---------------------------------------------------------------------------------------
User Function MT010INC()   

//Integra��o Protheus X KP
U_FSINTP05("I",SB1->B1_COD)

Return Nil


