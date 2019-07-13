#Include "Protheus.ch"

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MT010ALT()
Ponto de entrada na ap�s a altera��o do produto.
        
@author Rafael Almeida
@since 09/11/11       
@return Nil
@obs
Ponto de Entrada utiliza a fun��o FSINTP05.
/*/
//---------------------------------------------------------------------------------------
User Function MT010ALT()   

//Integra��o Protheus X KP
U_FSINTP05("A",SB1->B1_COD)

Return Nil       


