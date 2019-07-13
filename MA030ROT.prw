#Include "Totvs.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} MA030ROT
INCLUS�O DE NOVAS ROTINAS
Ap�s a cria��o do aRotina, para adicionar novas rotinas ao programa.
Para adicionar mais rotinas, adicionar mais subarrays ao array. No advanced este n�mero � limitado. 
Deve se retornar um array onde cada subarray � uma linha a ser adicionada ao aRotina padr�o.
        
@author 		Fernando dos Santos Ferreira 
@since 		26/02/2013
@version 	P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     		Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function MA030ROT()
Local		aRetorno := {}

AAdd( aRetorno, { "Aprova��o de Cr�dito", "U_FSFINC05", 4, 0 } )

Return( aRetorno )
