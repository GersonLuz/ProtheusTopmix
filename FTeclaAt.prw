#include "Protheus.ch"
#include "Rwmake.ch"         
//--------------------------------------------------------------
/*/{Protheus.doc} FTeclaAt

Ativa/desativa as teclas de atalho

@param  
@author Rodrigo Carvalho
@since  29/03/2016
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
User Function FTeclaAt(nFolder , lAtiva )

If nFolder < 10 // desativado.
   Return .T.
Endif   

SetKey( VK_F4  ,Nil)
SetKey( VK_F5  ,Nil)
SetKey( VK_F6  ,Nil)
SetKey( VK_F7  ,Nil)
SetKey( VK_F8  ,Nil)
SetKey( VK_F9  ,Nil)
SetKey( VK_F10 ,Nil)

If lAtiva

   Do Case
      Case nFolder == 2  
      
           SetKey( VK_F4 , { || U_MCMTA150("SC8" , SC8->(Recno()) , 2 ) })        
           SetKey( VK_F5 , { || U_MCMTA150("SC8" , SC8->(Recno()) , 3 ) })
           SetKey( VK_F6 , { || U_MCMTA150("SC8" , SC8->(Recno()) , 4 ) })
           SetKey( VK_F7 , { || A150TOTAIS("SC8" , SC8->(Recno()) , 2 ) })
           SetKey( VK_F8 , { || U_MCMTA160("SC8" , SC8->(Recno()) , 7 ) })                

   EndCase
  
Endif


Return .T.