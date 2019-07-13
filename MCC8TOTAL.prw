#Include "rwmake.ch"
#include "protheus.ch"
//-------------------------------------------------------------------
/* {Protheus.doc} MCC8TOTAL

@protected
@author    Rodrigo Carvalho
@since     24/03/2016
@obs       Criar gatilho com o contra dominio C8_TOTAL e regra:
           IIf(ExistBlock( "MCC8TOTAL" ) , ;
           ExecBlock( "MCC8TOTAL", .F., .F. ) , M->C8_TOTAL   )                

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function MCC8TOTAL()

//Local nPreco  := M->C8_PRECO 
Local nTotSc8 

     nTotSc8 := Round( aCols[n][aScan( aHeader,{|x| AllTrim(x[2])=="C8_QUANT"})] /** nPreco*/ , 2 )

If FunName() $ "FPNLCOM/MATA150"  

   aCols[n][aScan( aHeader,{|x| AllTrim(x[2])=="C8_TOTAL"})] := nTotSc8

   M->C8_TOTAL := nTotSc8

   A150Total(M->C8_TOTAL) //.And. MaFisRef("IT_VALMERC","MT150",M->C8_TOTAL)

   SysRefresh()

Endif

Return( nTotSc8 )
