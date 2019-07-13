#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} A410EXC() 
Ponto de entrada para validar a exclusão do pedido de venda.

@protect          
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
Ponto de Entrada utiliza a função FSFATP03.           
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function A410EXC()
Local lRet	:=	.T.

lRet	:=	U_FSFATP03()

Return lRet
