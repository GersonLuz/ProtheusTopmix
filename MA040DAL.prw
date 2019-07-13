#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} MA040DAL 
Este ponto de entrada pertence � rotina de manuten��o do cadastro de 
vendedores, MATA040. Ele � executado na rotina de altera��o (MA040ALT), 
ap�s a grava��o dos dados do vendedor.
     
@author Fernando dos Santos Ferreira 
@since 16/11/2011
@version P11
@obs  
Esse ponto de entrada utiliza a fun��o FSINTP10 para altera��o de vendedores.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function MA040DAL()
U_FSINTP10("A", SA3->A3_COD)
Return Nil   


