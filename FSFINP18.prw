#Include "protheus.ch"     
#Define _CRLF CHR(13) + CHR(10)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSFINP18
Menu de opções de importação

@author        Giulliano
@since         20/03/2012
@version       P11
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo

/*/
//---------------------------------------------------------------------------------------
User Function FSFINP18

Local oBitmap1 := Nil
Local oButton1	:= Nil
Local oButton2 := Nil
Local oButton3	:= Nil
Local oButton4 := Nil
Local oGroup1	:= Nil
Local oSay1		:= Nil
Local oDlg		:= Nil
Local cTexto 	:= ""

cTexto := "Importar os arquivos das operadoras de cartão."  + _CRLF
cTexto += "Selecione abaixo qual processo será iniciado."                     	

DEFINE MSDIALOG oDlg TITLE "Microsiga Protheus" FROM 000, 000  TO 190, 398  PIXEL
	
  	@ 032, 002 GROUP oGroup1 TO 076, 199 PROMPT "Importação de Arquivos" OF oDlg PIXEL
   @ 079, 002 BUTTON oButton1 PROMPT "Cielo"  ACTION (u_FSFINP14()) SIZE 037, 012 OF oDlg PIXEL
   @ 079, 042 BUTTON oButton2 PROMPT "RedeCard-EEVD" ACTION (u_FSFINP20()) SIZE 050, 012 OF oDlg PIXEL
   @ 079, 097 BUTTON oButton3 PROMPT "RedeCard-EEVC" ACTION (u_FSFINP16()) SIZE 050, 012 OF oDlg PIXEL
   @ 079, 150 BUTTON oButton4 PROMPT "Retorno Banco" ACTION (u_FSFINP09()) SIZE 050, 012 OF oDlg PIXEL
   @ 042, 005 SAY oSay1 PROMPT cTexto SIZE 226, 035 OF oDlg PIXEL      
   @ 000, 000 BITMAP oBitmap1 SIZE 244, 030 OF oDlg  FILENAME "openclosing" NOBORDER  PIXEL
   
ACTIVATE MSDIALOG oDlg CENTERED
Return  Nil      