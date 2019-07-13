#Include "Protheus.ch"
#Include "Rwmake.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} MT010CAN
Ponto de Entrada ap�s Inclus�o, Altera��o e Exclus�o de Produto
          
@author 	.iNi Sistemas (IR)
@since 		07/08/2014
@version 	P11.5
@obs  
Projeto 	2014002TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------         
User Function MT010CAN()

Local nOpc := PARAMIXB[1]           

If nOpc == 1
	If INCLUI
		U_FSIMPC01() //-- Importa��o de Produto entre Empresas
	EndIf
EndIf


Return(Nil)