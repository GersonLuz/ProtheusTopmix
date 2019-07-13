#Include "Protheus.ch"
//-------------------------------------------------------------------
/* {Protheus.doc} MT120GOk
PE apos a gravação do pedido de compra;

@protected
@author    Rodrigo Carvalho
@since     20/09/2016
@obs        
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function MT120GOk()

Local aAreOld	  := GetArea()
Local aAreSC7	  := SC7->(GetArea()) 

Local cNumPed	  := PARAMIXB[1] 
Local lAltSc7	  := PARAMIXB[3]
Local lIncSc7	  := PARAMIXB[2] 
Local lDelSc7	  := PARAMIXB[4]

Local cFilPC	  := SC7->C7_FILIAL
Local cNumPC	  := SC7->C7_NUM
Local cGrAprvGer := SuperGetMv("MV_PCAPROV",,"000005")
Local nRegSC7    := SC7->(Recno())

If lDelSc7
   Return .T.
Endif   

SC7->(DbCommit())

dbSelectArea("SY1")
dbSetOrder(3)
If dbSeek(xFilial("SY1")+RetCodUsr())
   cGrAprvGer := If(!Empty(SY1->Y1_GRAPROV),SY1->Y1_GRAPROV,cGrAprvGer)
Else
   Aviso("Controle de Compradores","Não foi localizado o usuário como comprador! - Tabela SY1 -  Usuário: ["+RetCodUsr()+"]",{"Ok"})    
Endif   

DbSelectArea("SC7")	
SC7->(dbSetOrder(1))
If SC7->(dbSeek( cFilPC + cNumPC ))    

   // grupo de aprovação do centro de custo especifico.   
   Do While SC7->(!Eof()) .And. SC7->(C7_FILIAL + C7_NUM) == cFilPC + cNumPC
       RecLock("SC7",.F.)
       SC7->C7_APROV := IIf(Empty(SC7->C7_APROV),cGrAprvGer,SC7->C7_APROV)
       SC7->(MsUnlock())
       SC7->(DbSkip())
   End

Else
   Aviso("Controle de Aprovação","Pedido não encontrado! - Pedido: ["+cFilPC + cNumPC+"]",{"Ok"})    
Endif   

DbSelectArea("SC7")
SC7->(DbGoto(nRegSC7))

RestArea(aAreSC7)
RestArea(aAreOld)

Return Nil


