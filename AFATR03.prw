#Include "PROTHEUS.CH"   
#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
//--------------------------------------------------------------
/*/{Protheus.doc} AFATR02
Description  
//Envia e-mail para fornecedor
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Jose Antonio                                              
@since 26/02/2013                                                   
/*/                                                                 
    
//--------------------------------------------------------------
/*
Rotina de envio de e-mail
*/
User Function AFATR03(pCotacao,pFornece,pLoja,pFilial)
Local aAliasOLD := GetArea()
Local cCodProcesso, cCodStatus, cHtmlModelo, cMailID
Local cUsuarioProtheus, cTexto, cAssunto
Local aCond     := {}
Local aCont     := {}  
Local aIncImp  	:= {"1 - SIM","2 - NAO"} 
Local aTipFret  := {"","C - CIF","F - FOB"}
Local oProcess 
Local cServer   := Alltrim(GetNewPar("MV_WFBRWSR","smtp.flapa.com.br:587"))// 192.168.0.28:81/wf
Local cWFPath	:= AllTrim(SuperGetMV( 'FS_WFDIRE',,'\Workflow\modelos\' ))// 
Local cSeekSC8	:= ""
Local cPara		:= ""           
Local cDesc     := ""   
Local cNum  	:= ""
Local cProd 	:= ""
Local cIdent	:= ""
Local cForn 	:= ""
Local cLoja 	:= ""
Local cCodComp	:= "" 
Local cEmailComp:= ""
Local cTip		:= ""
Local cPrc		:= ""
Local nReg      :=0   
Local cEmail    :=""       
Local cDescProduto := ""
Local lEnvEmail := .T.

cHtmlModelo := cWFPath+"cotacao.htm"     

if !File("\Workflow\modelos\COTACAO.HTM")
	ApMsgInfo("Arquivo modelo de cotação não encontrado !!!")
	return
endif

dbSelectArea("SC8")
dbSetOrder(1)
dbSeek(pFilial+pCotacao+pFornece+pLoja,.T.) 
//C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD                                                                                                
cCotacaoAux:=SC8->C8_NUM
cFornece:=pFornece
cLoja   :=pLoja 
  While !Eof() .And. SC8->C8_FILIAL  = pFilial .And. ;
  					 SC8->C8_NUM     = cCotacaoAux    .And. ;
					 SC8->C8_FORNECE = cFornece       .And. ;
					 SC8->C8_LOJA    = cLoja

		// Assinale novos valores às macros existentes no html:
		SA2->(dbsetOrder(01))
		SA2->(dbSeek(xFilial("SA2")+SC8->C8_FORNECE+SC8->C8_LOJA))     
		
		ApMsgInfo(File("\Workflow\modelos\COTACAO.HTM"))
		
		oProcess := TWFProcess():New( "000001", "Cotação de Preços" )
		oProcess :NewTask( "Fluxo de Compras", "\Workflow\modelos\COTACAO.HTM" )
		oHtml    := oProcess:oHTML

		oHtml:ValByName( "C8_NUM"    , "SC8->C8_NUM"     )
		oHtml:ValByName( "C8_NUM"    , SC8->C8_NUM     )
		oHtml:ValByName( "C8_VALIDA" , SC8->C8_VALIDA  )
		oHtml:ValByName( "C8_FORNECE", SC8->C8_FORNECE )
		oHtml:ValByName( "C8_LOJA"   , SC8->C8_LOJA    )
		cNomeUsr  :=UsrRetName(RetCodUsr(SC8->C8_ZUSER)) 
		cEmailComp:=UsrRetMail(RetCodUsr(SC8->C8_ZUSER)) 
		
		oHtml:ValByName( "A2_NOME"   , SA2->A2_NOME   )
		oHtml:ValByName( "A2_END"    , SA2->A2_END    )
		oHtml:ValByName( "A2_MUN"    , SA2->A2_MUN    )
		oHtml:ValByName( "A2_BAIRRO" , SA2->A2_BAIRRO )
		oHtml:ValByName( "A2_TEL"    , SA2->A2_TEL    )
		oHtml:ValByName( "A2_FAX"    , SA2->A2_FAX    )
		oHtml:ValByName( "C8_CONTATO", SC8->C8_CONTATO  )
		oHtml:ValByName( "Frete"    , {"CIF","FOB"}   )
		oHtml:ValByName( "subtot"   , TRANSFORM( 0 ,'@E 999,999.99' ) )
		oHtml:ValByName( "vldesc"   , TRANSFORM( 0 ,'@E 999,999.99' ) )
		oHtml:ValByName( "aliipi"   , TRANSFORM( 0 ,'@E 999,999.99' ) )
		oHtml:ValByName( "valfre"   , TRANSFORM( 0 ,'@E 999,999.99' ) )
		oHtml:ValByName( "totped"   , TRANSFORM( 0 ,'@E 999,999.99' ) )


		//Condicao de pagamento	
		SE4->(dbSetOrder(1))
		dbSeek(xFilial("SE4")+SC8->C8_COND)
		aAdd(aCond, SE4->E4_Codigo + " - " + SE4->E4_Descri )
		 
		oHtml:ValByName( "C8_CONTATO", SC8->C8_CONTATO  )
		oHtml:ValByName( "Pagamento", aCond    )  
		cEmail:=SC8->C8_ZEMAIL
		If Empty(SC8->C8_ZEMAIL)
			cEmail:="jean.santos@topmix.com.br" //SA1->A1_EMAIL
		Endif		

		dbSelectArea("SC8")
		dbSetOrder(1)  

		While !Eof() .And. SC8->C8_FILIAL  = xFilial("SC8") .And. ;
						   SC8->C8_NUM     = cCotacaoAux    .And. ;
						   SC8->C8_FORNECE = cFornece       .And. ;
						   SC8->C8_LOJA    = cLoja           

               cDescProduto := FDescPrd(SC8->C8_PRODUTO)
	
					aAdd( (oHtml:ValByName( "IT.ITEM"    )), SC8->C8_ITEM    )
					aAdd( (oHtml:ValByName( "IT.PRODUTO" )), SC8->C8_PRODUTO )
					aAdd( (oHtml:ValByName( "IT.DESCRI"  )), cDescProduto   )
					aAdd( (oHtml:ValByName( "IT.QUANT"   )), TRANSFORM( SC8->C8_QUANT,'@E 99,999.99' ) )
					aAdd( (oHtml:ValByName( "IT.UM"      )), SC8->C8_UM      )
					aAdd( (oHtml:ValByName( "IT.PRECO"   )), TRANSFORM( 0.00,'@E 99,999.99' ) )
					aAdd( (oHtml:ValByName( "IT.VALOR"   )), TRANSFORM( 0.00,'@E 99,999.99' ) )
					aAdd( (oHtml:ValByName( "IT.PRAZO"   )), " ")
					aAdd( (oHtml:ValByName( "IT.IPI"     )), TRANSFORM( 0.00,'@E 99,999.99' ) )  
					IF RecLock("SC8", .F.)  
						SC8->C8_ZENVCOT:= "S"
						MsUnLock()  
               Endif
				   SC8->(dbSkip()) 
		Enddo                        
		                       
		
  		C8_WFID := oProcess:fProcessID
  		oProcess:cTo :=cEmail  //

  		oProcess:cSubject := "Processo de geração de Cotação de Preços "
  		oProcess:Start()
  		//RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,"000001",'1003',"Email Enviado Para o Fornecedor:"+SA2->A2_NOME,RetCodUsr())
  	   //	RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,"000001",'1003',"Email Enviado Para o Fornecedor:")
  	   If lEnvEmail
    		WFSendMail()
  		Endif
		dbSelectArea("SC8")
  Enddo 
  
Return (Nil)  






//--------------------------------------------------------------
/*/{Protheus.doc} FDescPrd
//Retorna a descrição completa do produto
                                                                
@param  codigo produto
@return Descricao
@author Rodrigo Carvalho
@since  02/02/2016                                                   
/*/                                                                 
//--------------------------------------------------------------

Static Function FDescPrd(cCodProd)

Local cDescri := ""

dbSelectArea("SB1")                 
DbSetOrder(1)
dbSeek(xFilial("SB1") + cCodProd )

cDescri := Alltrim(SB1->B1_DESC)
	 
If ! Empty(SC8->C8_ZPRDSUB)

	If SB1->(MsSeek(xFilial("SB1")+SC8->C8_ZPRDSUB))
    	cDescri += " (" + Alltrim(SB1->B1_FABRIC) +"/" + Alltrim(SB1->B1_ZREF2) + ")" 
   Endif

ElseIf ! Empty(SB1->B1_FABRIC) .Or. ! Empty(SB1->B1_ZREF1)   

  	cDescri += " (" + Alltrim(SB1->B1_FABRIC) +"/" + Alltrim(SB1->B1_ZREF1) + ")" 

EndIf   

cDescri +=" " + Alltrim(SC8->C8_ZOBSADI)
	 
Return(cDescri)
