#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} MT040VDE 
Este ponto de entrada � executado durante a valida��o da exclus�o de 
um vendedor. Ele somente ser� chamado caso as valida��es do sistema 
permitam a exclus�o do vendedor, sendo um complemento a elas.
      
@author Fernando dos Santos Ferreira 
@since 16/11/2011
@version P11
@return	lRet	Ser verdadeiro ir� permetir a exclus�o de um vendedor.
@obs  
Processo Utiliza a fun��o FSINTP10
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function MT040VDE()
Local 	lRet	:=	.T.

lRet	:=	U_FSINTP10("E", SA3->A3_COD)

Return lRet