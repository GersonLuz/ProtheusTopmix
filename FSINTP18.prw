#Include "Protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSINTP18
Atribui o numero da nota e a serie para notas tipo remessa
          
@author Fernando Ferreira
@since 18/01/2012 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSINTP18(cNumNot, cSerNot)
Default	cNumNot	:= ""
Default	cSerNot	:=	""

// Utilizo as variaveis private do ponto de entrada M460NUM
// Atribuindo os valores da tabela de integração SC5
cNumero	:= cNumNot
cSerie	:=	cSerNot

Return Nil
          

