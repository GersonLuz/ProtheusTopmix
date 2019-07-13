#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} MA040DAL 
Este ponto de entrada pertence à rotina de manutenção do cadastro de 
vendedores, MATA040. Ele é executado na rotina de alteração (MA040ALT), 
após a gravação dos dados do vendedor.
     
@author Fernando dos Santos Ferreira 
@since 16/11/2011
@version P11
@obs  
Esse ponto de entrada utiliza a função FSINTP10 para alteração de vendedores.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function MA040DAL()
U_FSINTP10("A", SA3->A3_COD)
Return Nil   


