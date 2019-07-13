#Include "Protheus.ch"
#include "rwmake.ch"     
#include "topconn.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} MT120APV
Altera o grupo de aprovadores na inclusão/alteracao do pedido de compras

@protected
@author    Rodrigo Carvalho
@since     19/07/2016
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 
User Function MT120APV()

Local aArea 	  := GetArea()
Local nPosAprov  := aScan( aHeader, { |x| Alltrim(x[2]) == "C7_APROV"	} )
Local cFilPC	  := SC7->C7_FILIAL
Local cNumPC	  := SC7->C7_NUM 
Local cCCusto    := ""
Local cGrAprvGer := IIf(nPosAprov > 0 , aCols[1][nPosAprov] , SC7->C7_APROV )
Local nRegSC7    := SC7->(Recno())  
Local aRegsSC7   := {} // lista dos recnos do pc.

SC7->(DbCommit()) 
SC7->(MsUnLockAll())

If Empty(cGrAprvGer)
   cGrAprvGer := SuperGetMv("MV_PCAPROV",,"000005")
   dbSelectArea("SY1")
   dbSetOrder(3)
   If dbSeek(xFilial("SY1")+RetCodUsr())
      cGrAprvGer := If(!Empty(SY1->Y1_GRAPROV),SY1->Y1_GRAPROV,cGrAprvGer)
   Else
      Aviso("Controle de Aprovação","Não foi localizado o controle de aprovação! - Usuário: ["+RetCodUsr()+"]",{"Ok"})    
   Endif   
EndIf

If Empty(cNumPC)
   If Empty(cGrAprvGer)
      cGrAprvGer := SuperGetMv("MV_PCAPROV",,"000005")
   Endif
   Return( cGrAprvGer )
Endif
                    
aRegsSC7 := FRecnoSC7(cFilPC,cNumPC) // lista dos registros do pedido.

If Len(aRegsSC7) == 0
   Aviso("Controle de Aprovação","Pedido não encontrado! - Pedido: ["+cFilPC + cNumPC+"]",{"Ok"})    
   SC7->(DbGoto(nRegSC7))
   Return( cGrAprvGer )      
Endif

DbSelectArea("SC7")
DbSetOrder(1)
SC7->(DbGoTo( aRegsSC7[1] ))

cGrAprvGer := IIf(Empty(SC7->C7_APROV),cGrAprvGer,SC7->C7_APROV)

Do While SC7->(!Eof()) .And. SC7->(C7_FILIAL + C7_NUM) == cFilPC + cNumPC
   cCCusto := SC7->C7_CC
   If ! Empty(cCCusto)
      DbSelectArea("CTT")
      If DbSeek(xFilial("CTT") + cCCusto ) .And. ! Empty(CTT->CTT_ZGRPAP)
         cGrAprvGer := CTT->CTT_ZGRPAP
         Exit // busca o primeiro grupo especifico e atribui a todos os registros do PC.
      Endif
   Endif   
	SC7->(DbSkip()) 
End		

DbSelectArea("SC7")
DbSetOrder(1)
SC7->(DbGoTo( aRegsSC7[1] )) // primeiro registro do pedido de compras.

Do While SC7->(!Eof()) .And. SC7->(C7_FILIAL + C7_NUM) == cFilPC + cNumPC

   RecLock("SC7",.F.)
   SC7->C7_APROV   := IIf(! Empty(cGrAprvGer),cGrAprvGer,IIf(Empty(SC7->C7_APROV),SuperGetMv("MV_PCAPROV",,"000005"),SC7->C7_APROV))
   SC7->C7_CONAPRO := IIf(Empty(SC7->C7_APROV)," ","B")
   SC7->(MsUnlock())

   SC7->(DbSkip())

End

SC7->(DbGoto(nRegSC7))   
   
RestArea(aArea)

Return( cGrAprvGer )





//-------------------------------------------------------------------
/*/{Protheus.doc} FRecnoSC7

@protected
@author    Rodrigo Carvalho
@since     19/07/2016
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 
Static Function FRecnoSC7(cFilPC,cNumPC)

Local aRegistros := {}
Local cQryC7     := ""

cQryC7 := "SELECT R_E_C_N_O_ RECNOC7,C7_ITEM,C7_SEQUEN"
cQryC7 += " FROM "+RetSqlName("SC7")+" (NOLOCK) WHERE C7_FILIAL='"+cFilPC+"' AND C7_NUM='"+cNumPC+"' AND D_E_L_E_T_ <> '*' ORDER BY C7_ITEM,C7_SEQUEN"

TCQuery cQryC7 Alias "TMPSC7" New	

DbSelectArea("TMPSC7")
Do While ! TMPSC7->(Eof()) 
   aAdd(aRegistros,TMPSC7->RECNOC7)
   TMPSC7->(DbSkip())
Enddo   
DbCloseArea("TMPSC7")

Return(aRegistros)