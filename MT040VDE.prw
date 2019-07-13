#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} MT040VDE 
Este ponto de entrada é executado durante a validação da exclusão de 
um vendedor. Ele somente será chamado caso as validações do sistema 
permitam a exclusão do vendedor, sendo um complemento a elas.
      
@author Fernando dos Santos Ferreira 
@since 16/11/2011
@version P11
@return	lRet	Ser verdadeiro irá permetir a exclusão de um vendedor.
@obs  
Processo Utiliza a função FSINTP10
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function MT040VDE()
Local 	lRet	:=	.T.

lRet	:=	U_FSINTP10("E", SA3->A3_COD)

Return lRet