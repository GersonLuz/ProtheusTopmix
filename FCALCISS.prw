#Include "RwMake.ch" 
#Include "TopConn.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} FCALCISS

@protected
@author    Rodrigo Carvalho
@since     01/04/2015
@obs       
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo                                            '
/*/
//------------------------------------------------------------------- 

User Function FCALCISS()

nAliq    := aCols[n][GDFieldPos("D1_ALIQISS")]
nVrBase  := aCols[n][GDFieldPos("D1_BASEISS")]     
nVrIss   := Round(nVrBase * nAliq / 100,2)

aCols[n][GDFieldPos("D1_VALISS")] := nVrIss

Return( nVrIss ) 
