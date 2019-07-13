#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://192.168.0.31/WebServiceERP/Service1.svc?wsdl
Gerado em        02/01/12 15:06:39
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _GIVLQQZ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSService1
------------------------------------------------------------------------------- */

WSCLIENT WSService1

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ProximoNumeroDocumento
	WSMETHOD ProximoDocumento

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   nCentralID                AS long
	WSDATA   cTipoDocumentoID          AS string
	WSDATA   cSerieDocumentoID         AS string
	WSDATA   nProximoNumeroDocumentoResult AS long
	WSDATA   cuser                     AS string
	WSDATA   csenha                    AS string
	WSDATA   oWSProximoDocumentoResult AS Service1_Documento

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSService1
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.101202A-20110919] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSService1
	::oWSProximoDocumentoResult := Service1_DOCUMENTO():New()
Return

WSMETHOD RESET WSCLIENT WSService1
	::nCentralID         := NIL 
	::cTipoDocumentoID   := NIL 
	::cSerieDocumentoID  := NIL 
	::nProximoNumeroDocumentoResult := NIL 
	::cuser              := NIL 
	::csenha             := NIL 
	::oWSProximoDocumentoResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSService1
Local oClone := WSService1():New()
	oClone:_URL          := ::_URL 
	oClone:nCentralID    := ::nCentralID
	oClone:cTipoDocumentoID := ::cTipoDocumentoID
	oClone:cSerieDocumentoID := ::cSerieDocumentoID
	oClone:nProximoNumeroDocumentoResult := ::nProximoNumeroDocumentoResult
	oClone:cuser         := ::cuser
	oClone:csenha        := ::csenha
	oClone:oWSProximoDocumentoResult :=  IIF(::oWSProximoDocumentoResult = NIL , NIL ,::oWSProximoDocumentoResult:Clone() )
Return oClone

// WSDL Method ProximoNumeroDocumento of Service WSService1

WSMETHOD ProximoNumeroDocumento WSSEND nCentralID,cTipoDocumentoID,cSerieDocumentoID WSRECEIVE nProximoNumeroDocumentoResult WSCLIENT WSService1
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ProximoNumeroDocumento xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("CentralID", ::nCentralID, nCentralID , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TipoDocumentoID", ::cTipoDocumentoID, cTipoDocumentoID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("SerieDocumentoID", ::cSerieDocumentoID, cSerieDocumentoID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ProximoNumeroDocumento>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IService1/ProximoNumeroDocumento",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	GetMv("FS_SRVNFKP") )

::Init()
::nProximoNumeroDocumentoResult :=  WSAdvValue( oXmlRet,"_PROXIMONUMERODOCUMENTORESPONSE:_PROXIMONUMERODOCUMENTORESULT:TEXT","long",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ProximoDocumento of Service WSService1

WSMETHOD ProximoDocumento WSSEND cuser,csenha WSRECEIVE oWSProximoDocumentoResult WSCLIENT WSService1
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ProximoDocumento xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("user", ::cuser, cuser , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("senha", ::csenha, csenha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ProximoDocumento>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IService1/ProximoDocumento",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	GetMv("FS_SRVNFKP"))

::Init()
::oWSProximoDocumentoResult:SoapRecv( WSAdvValue( oXmlRet,"_PROXIMODOCUMENTORESPONSE:_PROXIMODOCUMENTORESULT","Documento",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure Documento

WSSTRUCT Service1_Documento
	WSDATA   nNumeroDocumento          AS long OPTIONAL
	WSDATA   cSerieDocumento           AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service1_Documento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service1_Documento
Return

WSMETHOD CLONE WSCLIENT Service1_Documento
	Local oClone := Service1_Documento():NEW()
	oClone:nNumeroDocumento     := ::nNumeroDocumento
	oClone:cSerieDocumento      := ::cSerieDocumento
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service1_Documento
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nNumeroDocumento   :=  WSAdvValue( oResponse,"_NUMERODOCUMENTO","long",NIL,NIL,NIL,"N",NIL,NIL) 
	::cSerieDocumento    :=  WSAdvValue( oResponse,"_SERIEDOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


