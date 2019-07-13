#Include "Protheus.ch"
#Include "Rwmake.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} MT20FOPOS
Ponto de Entrada após Inclusão de Fornecedores
          
@author 	.iNi Sistemas (IR)
@since 		20/01/2015
@version 	P11.5
@obs  
Projeto 	2014003TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------         
User Function MT20FOPOS()

Local nOpcA :=PARAMIXB[1]

If nOpcA == 3
	U_FSIMPC04() //-- Importação de Fornecedores entre Empresas
EndIf

Return()