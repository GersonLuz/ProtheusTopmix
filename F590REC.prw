#Include "Protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} F590REC
Ponto de entrada onde realiza o filtros adicionais na rotina de borderô

@author Fernando dos Santos Ferreira 
@since 13/02/2012 
@version P11
@obs  
Ponto de Entrada utiliza a função FSFINP04.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function F590REC()
// Adiciona filtros para E1_ZBANCO
U_FSFINP04()
Return Nil