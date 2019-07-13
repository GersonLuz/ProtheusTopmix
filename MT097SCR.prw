#Include "Protheus.ch"
#include "rwmake.ch"     
//-------------------------------------------------------------------
/*/{Protheus.doc} MT097SCR
Alteração dos botoes da tela de liberacao de pedido de compra.

@protected
@author    Rodrigo Carvalho
@since     02/02/2016
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 


User Function MT097SCR()

Local oDlg := ParamIXB[1] //Customização do usuário 

If FunName() == "FPNLCOM"
   oDlg:Acontrols[29]:cCaption := "Consulta Ped."
   oDlg:Acontrols[29]:cTitle   := oDlg:Acontrols[29]:cCaption
Endif

Return Nil
