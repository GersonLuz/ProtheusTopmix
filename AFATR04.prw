#Include "PROTHEUS.CH"   
#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"  

//--------------------------------------------------------------
/*/{Protheus.doc} AFATR04
Description  
//Envia e-mail para solicitantes
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Jose Antonio                                              
@since 26/04/2013                                                   
/*/                                                                 
    
//--------------------------------------------------------------
/*
Rotina de envio de e-mail
*/
User Function AFATR04(aTabSC1)
Local aAliasOLD := GetArea()
Local cCodProcesso, cCodStatus, cHtmlModelo, cMailID
Local cUsuarioProtheus, cTexto, cAssunto
Local oProcess 
Local cServer   :="smtp.flapa.com.br:587"// Alltrim(GetNewPar("MV_WFBRWSR","smtp.flapa.com.br:587")) //smtp.flapa.com.br:587 //192.168.0.28:81/wf
Local cWFPath	:= AllTrim(SuperGetMV( 'FS_WFDIRE',,'\Workflow\modelos\' )) 
   cHtmlModelo := cWFPath+"ocorrencia.htm" 
		cNomeUsr  :=UsrRetName(RetCodUsr(aTabSC1[6])) 
		cEmailComp:=UsrRetMail(RetCodUsr(aTabSC1[6])) 

		oProcess := TWFProcess():New( "000001", "OCORRENCIA EM PRODUTO" )
		oProcess :NewTask( "Ocorrencia na cotação", "\Workflow\modelos\OCORRENCIA.HTM" )
		oHtml    := oProcess:oHTML
		oHtml:ValByName( "C1_NUMSC"   , substr(aTabSC1[2],1,6) )
		oHtml:ValByName( "C1_PRODUTO" , aTabSC1[4] )
		oHtml:ValByName( "C1_DESCRI"  , aTabSC1[5] )
		oHtml:ValByName( "Z2_NOMEUSR" , cNomeUsr )
		oHtml:ValByName( "Z2_DATA"    , ddatabase )
		oHtml:ValByName( "Z2_HORA"    ,  Time() )
		oHtml:ValByName( "Z2_MOTIVO"  ,aTabSC1[7] )   
  		cEmail:=aTabSC1[8]
  		If ! Empty(cEmail)
	  		C1_WFID := oProcess:fProcessID     
	  		oProcess:cTo :=cEmail//cEmailComp+";"+cEmail  //cEmailComp +";"+aTabSC1[6]  
	  		oProcess:cSubject := "Processo de ocorrencia de cotação de Preços "
	  		oProcess:Start()      
	  		WFSendMail()
	    Endif
	    
Return (Nil)  

