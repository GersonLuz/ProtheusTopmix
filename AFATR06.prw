#INCLUDE "PROTHEUS.CH"
#INCLUDE "Fileio.ch"
#INCLUDE "ap5mail.ch"
            
//--------------------------------------------------------------
/*/{Protheus.doc} AFATR06
Description  
//Envia e-mail para usuario solicitantes
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Jose Antonio                                              
@since 30/04/2013                                                   
/*/                                                                 

*************************************
User Function AFATR06(aTabSC1)
*************************************
Local cBody := ""              
Local lCabCot := .T.  
//POP.FLAPA.COM.BR
//SMTP.FLAPA.COM.BR
Local cMailServer := Alltrim(GetNewPar("MV_ZZSMTP","smtp.flapa.com.br:587"))
Local cMailCtaAut := Alltrim(GetNewPar("MV_ZZMAIL","ti@flapa.com.br"))
Local cFrom       := Alltrim(GetNewPar("MV_ZZFROM","Workflow Cotacao"))
Local cPws        := Alltrim(GetNewPar("MV_ZZPWS","top45102"))
Local cTo         := ""
Local cSubJect    := "Ocorrencia em produto " + cNumCot  
Local lEnviado    := .F.  
Local lSmtpAuth   := .T.
Local lOk         := .F. 
cNomeUsr  :=UsrRetName(RetCodUsr(aTabSC1[6])) 
cEmailComp:=UsrRetMail(RetCodUsr(aTabSC1[6])) 

        
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailCtaAut PASSWORD cPws RESULT lOk
	
	If lSmtpAuth
		if lOk
			lAutOk := MailAuth(cMailCtaAut,cPws)
		EndIf 
	Endif
	
	If !lOk .Or. !lAutOk
		MsgStop("Nao foi possivel conectar no servidor smtp ...")
		Return
	EndIF	
	cBody := '<html>'
	cBody += '<head>'
	cBody += '<title> Solicitação de Cotação </title>'
	cBody += '</head>'  
	cBody += '<b><font size="3" face="Arial">Numero da Solicitação: ' + aTabSC1[2] + ' </font></b><br><br>'
	cBody += '<b><font size="2" face="Arial">Motivo: '+aTabSC1[6] +  '</font></b>'
	cBody += '<table border=1>'
	cBody += '<tr><td>' + 'Produto' + '</td><td>'+'Descrição'+'</td></tr>'+'Nome do Usuario'+'</td></tr>'+'Data'+'</td></tr>'+'Hora'+'</td></tr>
	cBody += '<tr><td>' + Alltrim(aTabSC1[4]) + '</td><td>' + aTabSC1[5] + '</td><td>'+ cNomeUsr + '</td></tr>'+ dtoc(ddatabase) + '</td></tr>'+ Time() + '</td></tr>'+ aTabSC1[6] + '</td></tr>'
	            
	cBody += '</table><br>'
	
	cBody += '</body></html>'

	
	//APMsgAlert(cBody)		
	cTo	:=	"jose.antonio@ammconsult.com"
	If lSmtpAuth .And. lOk .And. lAutOk

		SEND MAIL FROM cMailCtaAut TO cTo SUBJECT cSubJect BODY cBody RESULT lEnviado 
		
		If !lEnviado
			GET MAIL ERROR cError
			MsgInfo(cError,"Erro no envio de ocorrencia " + aTabSC1[2] + " para o solicitante.")		
		endif
	Else
		lEnviado := .F.
	
	EndIf 

	If lOk
		DISCONNECT SMTP SERVER
	EndIf 
	
Return


