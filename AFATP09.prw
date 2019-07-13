#Include "PROTHEUS.CH"  
#include "PROTHEUS.CH"
#include "TOPCONN.ch"
#INCLUDE "RWMAKE.CH"  

//--------------------------------------------------------------
/*/{Protheus.doc} AFATP09
Description  visualiza a ordem de compra                                                  
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Jose Antonio (AMM)                                              
@since 17/12/2012                                                   
/*/                                                             
//--------------------------------------------------------------
User Function AFATP09()                        
Local aAliasOLD   := GetArea()   
Local cFiltro                              

Local bFilSC7Brw  := {|| Nil} //Variavel para Filtro
Local nRegSM0 	:= SM0->(Recno()) 

if Empty(aWBrowse3[oWBrowse3:nAt,2])
	ApMsgInfo("Não existe ordem de compras !!!")
	return
endif   
   

PRIVATE l120Auto  :=.F. 
Private nTipoPed   
Private aRotina	  := MenuDef()
Private cCadastro := "Consulta de pedido de compras"   

cFil1:=cFilAnt    
   
dbSelectArea("SC7")
dbGoto(aWBrowse3[oWBrowse3:nAt,11])         
cFilANT:=SC7->C7_FILIAL
 
Mata120(NIL,NIL,NIL,2)
/*
dbSelectArea("SC7")
dbSetOrder(1)
if dbSeek(cFILAUX+cNum)
    A 120Pedido("SC7",SC7->(RecNo()),2)
endif 
*/
cFilAnt:=cFil1
RestArea(aAliasOLD)
Return()   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Vendas Cliente        ³ Data ³18/12/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef() 
Local aRotina
               
aRotina		:= {{"Pesquisar" ,"AxPesqui"   ,0,1 },;	// 	"Pesquisar" //"Pesquisar"
				{"Visualizar","A120Pedido" ,0,2 }} 	// 	"Visualizar" //"Visualizar"
Return(aRotina)
            
                                           
         
 
