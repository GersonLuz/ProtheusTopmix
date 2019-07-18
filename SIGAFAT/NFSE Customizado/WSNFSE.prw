#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    \tmptdslucas-pc\NFSESERV.wsdl
Gerado em        05/01/19 14:12:10
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _TVMOJNE ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSNFSESERV
------------------------------------------------------------------------------- */

WSCLIENT WSNFSESERV

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Envio

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cDados                    AS string
	WSDATA   cEnvioResult              AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSNFSESERV
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180827 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSNFSESERV
Return

WSMETHOD RESET WSCLIENT WSNFSESERV
	::cDados             := NIL 
	::cEnvioResult       := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSNFSESERV
Local oClone := WSNFSESERV():New()
	oClone:_URL          := ::_URL 
	oClone:cDados        := ::cDados
	oClone:cEnvioResult  := ::cEnvioResult 
Return oClone

// WSDL Method Envio of Service WSNFSESERV

WSMETHOD Envio WSSEND cDados WSRECEIVE cEnvioResult WSCLIENT WSNFSESERV
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Envio xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("Dados", ::cDados, cDados , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Envio>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/Envio",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://localhost:30548/NFSESERV.asmx")

::Init()
::cEnvioResult       :=  WSAdvValue( oXmlRet,"_ENVIORESPONSE:_ENVIORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



