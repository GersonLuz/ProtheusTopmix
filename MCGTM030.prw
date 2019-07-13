#include "Rwmake.ch"   
#include "protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} MCGTM030() 
Carrega os dados do cliente caso já exista na base de dados.

@protected
@author    Rodrigo Carvalho
@since     02/06/2015
@obs       IIf(ExistBlock("MCGTM030"),U_MCGTM030(),.T.) 

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------          
User Function MCGTM030

Local aArea := GetArea()

If ! Empty(M->A1_CGC) .And. M->A1_PESSOA == "J" .And. Inclui
   
   DbSelectArea("SA1")
   DbSetOrder(3)
   DbSeek( xFilial("SA1") + Left(M->A1_CGC,8) , .T.)
   
   If ! Eof() .And. Left(SA1->A1_CGC,8) == Left(M->A1_CGC,8) .And. INCLUI

      M->A1_COD     := SA1->A1_COD
      M->A1_LOJA    := SubStr(M->A1_CGC,11,2)
      M->A1_NOME    := SA1->A1_NOME
      M->A1_NREDUZ  := SA1->A1_NREDUZ
      M->A1_EMAIL   := SA1->A1_EMAIL
      M->A1_HPAGE   := SA1->A1_HPAGE      
      M->A1_TIPO    := SA1->A1_TIPO
      M->A1_DTNASC  := SA1->A1_DTNASC
      M->A1_ENDCOB  := SA1->A1_ENDCOB
      M->A1_BAIRROC := SA1->A1_BAIRROC
      M->A1_CEPC    := SA1->A1_CEPC
      M->A1_ESTC    := SA1->A1_ESTC
      M->A1_CODMUNC := SA1->A1_CODMUNC
      M->A1_MUNC    := SA1->A1_MUNC
      M->A1_ATIVIDA := SA1->A1_ATIVIDA
      M->A1_NATUREZ := SA1->A1_NATUREZ
      M->A1_CONTA   := SA1->A1_CONTA
      M->A1_GRPTRIB := SA1->A1_GRPTRIB
      M->A1_CONTATO := SA1->A1_CONTATO
      M->A1_ALIQIR  := SA1->A1_ALIQIR
      
      M->A1_ZFIADOR := SA1->A1_ZFIADOR
      M->A1_ZPESSOA := SA1->A1_ZPESSOA
      M->A1_ZCGCFIA := SA1->A1_ZCGCFIA
      M->A1_ZTELFIA := SA1->A1_ZTELFIA
      
      SysRefresh()
      
      DbSelectArea("SA1")
      DbSetOrder(1)
      If DbSeek( xFilial("SA1") + M->A1_COD + M->A1_LOJA )
         DbSeek( xFilial("SA1") + M->A1_COD + Replicate("Z",Len(M->A1_LOJA)) , .T.)
         DbSkip(-1)
         cLojaOld   := M->A1_LOJA
         M->A1_LOJA := IIf(M->A1_COD == SA1->A1_COD , Soma1( SA1->A1_LOJA , Len(M->A1_LOJA) ),M->A1_LOJA)
         
  	   	MsgInfo("O Código da Loja já foi utilizado anteriormente. A sequência foi alterada "+Chr(13)+Chr(10)+"de: "+cLojaOld+" para "+M->A1_LOJA, "Aviso")		 
      Endif   
                           
      
   Endif
Endif

RestArea(aArea)

Return( M->A1_COD )