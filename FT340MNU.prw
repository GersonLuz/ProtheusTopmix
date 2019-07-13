#include "Protheus.ch"
#Include "rwmake.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} FT340MNU

@protected
@author    Rodrigo Carvalho
@since     10/03/2015
@obs       Filtro para a base de conhecimento.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//------------------------------------------------------------------- 
User Function FT340MNU()

Local aGrupos  := UsrRetGrp ( __cUserId )  
Local nXy      := 1
Local lVerGrp  := .F. // falso -> Valida pelo Modulo Corrente x ACB_TIPO , verdadeiro valida: (Modulos do grupo de acessos do usu�rio) x ACB_TIPO
Local cNomeGrp := "" 
Local lAviso   := FunName() == "FATA340" 

If Len(aGrupos) == 0 .And. lVerGrp //Retorna se usuario nao tiver grupo. 
   Return
EndIf 

DbSelectArea("ACB")

If lVerGrp  
   // faz as valida��es pelo grupo de usu�rios cadastrado no login;
   For nXy := 1 To Len( aGrupos )
       cNomeGrp += SubStr(GRPRetName( aGrupos [nXy] ),8,3)+"/"
   Next
   Set Filter TO ACB->ACB_TIPO $ cNomeGrp
   If lAviso
      ApMsgInfo("Lista dispon�vel referente ao cadastro de grupos do usu�rio!") 
   Endif
Else
   // faz as valida��es pelo m�dulo que o usu�rio se encontra.
   Set Filter TO ACB->ACB_TIPO $ Upper(SubStr(cModulo,1,3)) 
   If lAviso
      ApMsgInfo("Somente os registros desse m�dulo estar�o dispon�veis!") 
   Endif      
Endif

Return .T.