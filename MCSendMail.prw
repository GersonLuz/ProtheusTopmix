#Include "rwmake.ch"
#include "protheus.ch"
#include "ap5mail.ch"     
#include "TopConn.ch"    
//-------------------------------------------------------------------
/* {Protheus.doc} FSendEMail: Enviar e-mail 

@protected
@author    Rodrigo Carvalho
@since     29/12/2015
@obs       MCSendMail("Assunto",{"E-mail teste"},"Titulo Corpo",{},maildestino) 
Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function MCSendMail(cAssunto,aMsgCorpo,cTexto,cHtml,aAnexos,cMailDest,cUsuMail,cCtaEmail,cPswEmail,cServer,lSmtpAuth)

Local   cAnexos    := ""
Local   lEnviaMsg  := .f.
Local   nXy        := 0
Local   cMensAnexo := ""        
Local   cMsgResp   := SuperGetMv("MC_MSGRESP",,"Mensagem Automática, não responder.")

Default cUsuMail   := GetMV("MV_RELACNT") // Conta de e-mail
Default cCtaEmail  := GetMV("MV_RELACNT") // Conta de e-mail
Default cPswEmail  := GetMV("MV_RELPSW")  // Senha
Default cServer    := GetMV("MV_RELSERV") // Servidor
Default lSmtpAuth  := .T. //GetMv("MV_RELAUTH",,.F.)

Default cAssunto   := ""
Default aMsgCorpo  := {}
Default cTexto     := ""
Default aAnexos    := {}
Default cMailDest  := ""

If Empty(cMailDest) .Or. Empty(cUsuMail) .Or. Empty(cCtaEmail) .Or. Empty(cServer)
   // ApMsgAlert("Informações incompletas - Usuário/Email Destino/Conta de Email ou Servidor de Conexão!")
   Return .F.
Endif   

cMensAnexo += cHtml

If ! Empty(cTexto) .Or. Len(aMsgCorpo) > 0
   cMensAnexo += "<body><table border=0 cellpadding=2 width=100%>"
   cMensAnexo += "<tr><td width=100%></td></tr>"
   cMensAnexo += "<tr><td width=100%><font face=Arial size=2><b>"+cTexto+"</b></font></td>"
   For nXy := 1 To Len(aMsgCorpo)
       cMensAnexo += "<tr><td width=100%><font face=Arial size=2><b>"+aMsgCorpo[nXy]+"<br>&nbsp; </b></font></td>"
   Next
   cMensAnexo += "</tr><tr><td width=100%></td></tr><tr>"
   cMensAnexo += "<td width=100%><font face=Arial size=1>*"+cMsgResp+"</font></td> </tr>"
   cMensAnexo += "</table></body>"
Endif

For nXy :=1 to Len(aAnexos)
	cAnexos += Alltrim(aAnexos[nXy])+","
Next

Connect SMTP Server cServer Account cUsuMail Password cPswEmail Result lConServ   // Conecta no servidor SMTP

If lConServ // Se a conexao com o SMPT esta ok
   If lSmtpAuth 	// Se existe autenticacao para envio valida pela funcao MAILAUTH
      lAutOk := Mailauth(cUsuMail,cPswEmail)
   Else
      lAutOk := .T.
   Endif
   If lAutOk 
      Send Mail From cCtaEmail To cMailDest Subject cAssunto Body cMensAnexo Attachment cAnexos Result lEnviaMsg  
      If ! lEnviaMsg
         GET MAIL ERROR cError
         ApMsgAlert("01 - Atenção: "+cError +CRLF+ cCtaEmail+CRLF+"Destino: "+cMailDest)
      Endif
   Else
      GET MAIL ERROR cError
       ApMsgAlert("01 - Atenção: "+cError +CRLF+ cCtaEmail+CRLF+"Destino: "+cMailDest)
   Endif                                               
	DISCONNECT SMTP SERVER
Else
	GET MAIL ERROR cError
	ApMsgAlert("03 - Atenção: "+cError)
Endif

Return(lEnviaMsg)