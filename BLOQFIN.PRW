#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"          
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"   
/*
+-----------------------------------------------------------------------+
|Programa  |Par Fin|    Autor |Juliana                | Data |03.12.2010|
|----------|------------------------------------------------------------|
|Descricao |Parametro para bloqueio da datafim.                         |
|          |Atualiza o parametro: MV_DATAFIM                            |
|----------+------------------------------------------------------------|
| Uso      | Especifico TOPMIX                                          |
|-----------------------------------------------------------------------|
|************************** ALTERAÇÕES *********************************|
|-----------------------------------------------------------------------|
|PROGRAMADOR | DATA   | MOTIVO DA ALTERACAO                             |
|------------|--------|-------------------------------------------------|
|            |        |                                                 |
+-----------------------------------------------------------------------+
*/         

User Function BloqFin()
/************************************************************************
* Formulario para atualização das msg
*                       
*****/                                 

Local aArrayBtn := {}

Local oTMensBar, oTMsgItem

Private lFormular := .T.
Private cBloqFin  := Space(08)
Private oDlg, oBloqFin 

While(lFormular)
	Define MsDialog oDlg Title "Data Bloqueio Financeiro ANOMESDIA Ex:AAAAMMDD" From C(214),C(213) To C(430),C(654) Pixel
//	@ C(014),C(004) TO C(110),C(220) LABEL " Dados adicionais do boleto Itaú " Pixel Of oDlg
	@ C(025),C(008) Say "Data Bloqueio ANOMESDIA:" Size C(053),C(008) COLOR CLR_HBLUE Pixel Of oDlg
	@ C(035),C(008) MsGet oBloqFin Var cBloqFin Size C(200),C(009) COLOR CLR_BLACK Picture "@!" Pixel Of oDlg

	If(Len(AllTrim(GetMv("MV_DATAFIN"))) == 8)
		@ C(050),C(008) Say "Data Atual: "+Left(AllTrim(GetMv("MV_DATAFIN")),75) Size C(250),C(020) COLOR CLR_HRED Pixel Of oDlg 
		@ C(055),C(008) Say SubStr(AllTrim(GetMv("MV_DATAFIN")),76,120) Size C(250),C(020) COLOR CLR_HRED Pixel Of oDlg
    Else
	   @ C(050),C(008) Say "Data Atual: "+AllTrim(DToS(GetMv("MV_DATAFIN"))) Size C(250),C(020) COLOR CLR_HRED Pixel Of oDlg 
   	EndIf                                                                                                                          
  

	oTMensBar := TMsgBar():New(oDlg,"® Topmix - todos os direitos reservados",.F.,.F.,.F.,.F., RGB(116,116,116),,,.F.)      
	oTMsgItem := TMsgItem():New(oTMensBar,"VERSÃO: 1.0", 100,,,,.T., {||} ) 
	Activate MsDialog oDlg Centered  On Init EnchoiceBar(oDlg, {||AtualizPar()},{||SaiForm()},,aArrayBtn)
EndDo

Return
                                      

Static Function AtualizPar()
/************************************************************************
* Atualiza os parametros MV_DATAFIN
*
*****/

Local := lAtualiza := .F. 
  
If(MsgYesNo("Deseja atualizar a data?"))
	PutMv("MV_DATAFIN",cBloqFin)
	lAtualiza := .T.
EndIf

If(lAtualiza)  
	Aviso("Atenção", "Data alterada com sucesso...!",{"Ok"},,"Data Bloqueio") 
	SaiForm()
EndIf

Return



Static Function SaiForm()
/************************************************************************
* Rotina para fechar o formulario 
*
*****/

oDlg:End()
lFormular := .F.

Return    



Static Function C(nTam)
/************************************************************************ 
*Funcao responsavel por manter o Layout independente da resolucao horizon
*tal do Monitor do Usuario.                         
*****/         
                                                         
Local nHRes	:=	oMainWnd:nClientWidth	//Resolucao horizontal do monitor     

If(nHRes == 640) //Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
	nTam *= 0.8                                                                
ElseIf((nHRes == 798).Or.(nHRes == 800)) //Resolucao 800x600                
	nTam *= 1                                                                  	
Else //Resolucao 1024x768 e acima                                           
	nTam *= 1.28 
	If("P10" $ oApp:cVersion)                                                      
		If((Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild())                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                
EndIf                                                                                                                                               
  
Return Int(nTam)                      