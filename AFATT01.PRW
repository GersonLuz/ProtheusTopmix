#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "VKEY.CH" 
#INCLUDE "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} AFATT01

Chamadas das rotinas padrões do protheus para o compras

@param  
@author Jose Antonio (AMM)
@since  22/12/2014
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
User Function AFATT01(pReg)   

Local   aAliasOLD := GetArea() 
Local   oDlg   
Local   oGetDescri  
Local   oFontTel := TFont():New("Arial",10,,,.T.,,,,.F.,.F.)

Private cDescri  :=""          
Private nContSZ4 :=0

If Empty(pReg)
	ApMsgInfo("Não existe Pedido para mensagem !!!")
	Return
Endif   

dbSelectArea("SC7") 
dbGoto(pReg)   

cFilAux:=SC7->C7_FILIAL
cNum   :=SC7->C7_NUM    

dbSelectArea("SZ4") 
dbsetOrder(1)                                                           

IF dbSeek(cFilAux+cNum)   
   cDescri:=SZ4->Z4_OBS  
Endif

DEFINE MSDIALOG oDlg FROM 000,000 TO 200,700 PIXEL TITLE OemToAnsi("Mensagem" )
TGroup():New(010,005,235,347,OemToAnsi("Descrição da Mensagem"),oDlg,CLR_HBLUE,,.T.)
oGetDescri := TMultiGet():New(025,010, {|U| IIf(PCount()==0,cDescri,cDescri:=U )},oDlg,308,050,oFontTel,,,,,.t.,,,,,,)
oGetDescri:SetFocus()

Activate MsDialog oDlg Center On Init EnchoiceBar(oDlg,{||fConfirme(oDlg,pReg)},{||oDlg:End()},,)

RestArea(aAliasOLD)

Return(.T.) 

/* 
Confirmar
*/

Static function fConfirme(oDlg,pReg)   

Local nTam:=60

dbSelectArea("SC7") 
dbGoto(pReg)   

cFilAux:=SC7->C7_FILIAL
cNum   :=SC7->C7_NUM                                                               

dbSelectArea("SZ4")
dbSetOrder(1)                          

If !dbSeek(cFilAux+cNum)

	If RecLock("SZ4",.T.)
		SZ4->Z4_FILIAL :=cFilAux
		SZ4->Z4_PEDIDO	:=cNum 
		SZ4->Z4_OBS    :=cDescri
		MsUnlock()
	EndIf

Else

	If RecLock("SZ4",.F.)
			SZ4->Z4_OBS    :=cDescri
			MsUnlock()
	EndIf

Endif   

oDlg:End()
Return(.T.)         
