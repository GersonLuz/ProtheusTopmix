#Include "Totvs.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} MA030ROT
INCLUSÃO DE NOVAS ROTINAS
Após a criação do aRotina, para adicionar novas rotinas ao programa.
Para adicionar mais rotinas, adicionar mais subarrays ao array. No advanced este número é limitado. 
Deve se retornar um array onde cada subarray é uma linha a ser adicionada ao aRotina padrão.
        
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

AAdd( aRetorno, { "Aprovação de Crédito", "U_FSFINC05", 4, 0 } )

Return( aRetorno )
