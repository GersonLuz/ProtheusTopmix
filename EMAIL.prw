#INCLUDE "PROTHEUS.CH"
#Include "Rwmake.ch"
#Include "TopConn.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "ap5mail.ch"

/*************************************************************************************** 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            *                                                   
****************************************************************************************
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ***          DATA: 12/12/2017    * 
****************************************************************************************
****************************************************************************************
****************************************************************************************
                                   PROGRAMA: EMAIL                                     *
****************************************************************************************
                   FUNÇÃO GERAR SEQUENCIAL NO CADASTRO DE FORNECEDOR                   * 
****************************************************************************************
****************************************************************************************
****************************************************************************************
***************************************************************************************/ 

*************************************
User Function EMAIL()
*************************************

Local cMailServer := Alltrim(GetNewPar("MV_ZZSMTP","smtp.topmix.com.br:587"))
Local cMailCtaAut := Alltrim(GetNewPar("MV_ZZMAIL","ti@flapa.com.br"))
Local cFrom       := Alltrim(GetNewPar("MV_ZZFROM","Workflow Cotacao"))
Local cPws        := Alltrim(GetNewPar("MV_ZZPWS","top45102"))
Local cTo         := ""
Local cSubJect    := "Solicitação de Cotação " 
Local lEnviado    := .F.  
Local lSmtpAuth   := .T.
Local lOk         := .F.
Local cRecebe     := "tiago.borges@flapa.com.br"
Local cEnvia      := "nfe@topmix.com.br"
Local cPedido     := "teste"
Local cBody       := ""
Local cLinkNew    := "teste"


cMailCtaAut := "nfe@topmix.com.br"//Alltrim(SY1->Y1_EMAIL)
cPws        := "Tpx45102"//Alltrim(SY1->Y1_ZSENHA)


CONNECT SMTP SERVER cMailServer ACCOUNT cMailCtaAut PASSWORD cPws RESULT lOk
	
If lSmtpAuth
	if lOk
		lAutOk := MailAuth(cMailCtaAut,cPws)
		Get Mail Error cErrorMsg
		Help("",1,"AVG0001056",,"Error: "+cErrorMsg,2,0)
	EndIf 
Endif
	
//If !lOk .Or. !lAutOk
	//MsgStop("Nao foi possivel conectar no servidor smtp ...")
   	//Return


	cBody := '<html>'
	cBody += '<head>'
	cBody += '<title> Aprovação de Pedido de Compras </title>'
	cBody += '</head>'
	cBody += '<font size="2" face="Arial">Pedido de Compras ' +cPedido+ ' ,pendente para aprovação. </font><br><br>'
	cBody += '<font size="2" face="Arial">Clique no link abaixo para Aprovar/Reprovar o pedido.</font><br>'
	cBody += '<font size="2" face="Arial">' + '<a href=' +cLinkNew+'>Clique Aqui</a>' + ' </font><br><br>'
	cBody += '<font size="2" face="Arial"><strong>Mensagem automática, favor não responder este e-mail.</strong></font></b><br><br>'
	cBody += '<img src="http://chicofood.com.br/Transpes.bmp">'
	cBody += '</body></html>'
 
	lAutOk := MailAuth(cMailCtaAut,cPws)
 
	If lOk  .AND. lAutOk
 
		SEND MAIL FROM cEnvia TO cRecebe SUBJECT 'Aprovação de Pedido de Compras'+ ' ' +cPedido BODY cBody RESULT lEnviado

	Else
 
		SEND MAIL FROM cEnvia TO cRecebe SUBJECT 'Aprovação de Pedido de Compras'+ ' ' +cPedido BODY cBody RESULT lEnviado
 
	Endif   	
//Else   	
//EndIF

return()