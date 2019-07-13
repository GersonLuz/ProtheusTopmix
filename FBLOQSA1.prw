#INCLUDE "rwmake.ch"
/*
+-----------------------------------------------------------------------+
¦Programa  ¦FBLOQSA1 ¦ Autor ¦ Max Rocha              ¦ Data ¦17.01.2012¦
+----------+------------------------------------------------------------¦
¦Descriào  ¦ BLOQUEIA SA1, QUANDO CLIENTE ALTERADO E NAO TEM LIMITE DE 
+----------+------------------------------------------------------------¦
¦ CREDITO LIBERADO                                                      ¦
+-----------------------------------------------------------------------¦
¦           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ¦
+-----------------------------------------------------------------------¦
¦PROGRAMADOR ¦ DATA   ¦ MOTIVO DA ALTERACAO                             ¦
+------------+--------+-------------------------------------------------¦
|            |        |                                                 |
+-----------------------------------------------------------------------+*/
User Function FBLOQSA1()

Local lRet   := .T.
     //If M->A1_LIBCRED = CTOD("  /  /  ")   .AND. M->A1_MSBLQL <> "1" .AND. M->A1_LC > 6000
        MsgBox("Favor solicitar a aprovacao do credito.","...ATENÇÃO...","Info")
        
        /* IF RecLock("SA1",.F.)
           REPLACE SA1->A1_MSBLQL WITH  "1" 
          // Alert("Status do cliente = " +SA1->A1_COD+ "/"+SA1->A1_LOJA+" -> "+ SA1->A1_MSBLQL    )
           MsUnLock()
        EndIF*/
     //   lRet := .F.     
     //EndIF
Return (lRet)