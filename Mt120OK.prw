//------------------------------------------------------------------- 
/*/{Protheus.doc} Mt120OK
Ponto de entrada na confirmação da alteração do pedido de compra.
     
@author	Rodrigo Carvalho
@since 21/09/2015
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
11/06/2013 Felipe Andrews  Filial do Parametro vinha com espacos
/*/ 
//------------------------------------------------------------------ 

User Function Mt120OK()

Local lOk := .T.        

lOk := U_Mt120LOK()

Return lOk