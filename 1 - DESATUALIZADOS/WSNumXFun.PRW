 //______________________________________________________________________________________________________________________________________             
/*/{Protheus.doc} FSGetNumWS
Função que irá chamar o Ws de numeração de notas e retornar o número para a função de faturamento do protheus.

@return cNum Número da nota a ser faturada.

@author  Waldir de Oliveira
@since   14/10/2011
/*/
//______________________________________________________________________________________________________________________________________  
User Function FSGetNumWS()
	Local cNum := ""
	Local oService := Nil
	Local aAreas := {GetArea()}

	oService := WSService1():New()
   
	If(oService:proximoDocumento(GetMv("FS_USRWSKP",,"kp"),GetMv("FS_PSSWSKP",,"kp!betonmix") ) )
			cNum := cVAlToChar(oService:OWSPROXIMODOCUMENTORESULT:NNUMERODOCUMENTO)
	EndIf
	              
	Alert('O número da nota será atualizado para o número'+chr(13)+' gerado pelo WebService KP: ' + cNum )	
	
	cErr := GetWSCError() 		
	If (!Empty(cErr))
		//Se houver erro
		lRet := .F.
		cSoapFCode  := IIf(GetWSCError(2) != Nil, GetWSCError(2), "")		// Soap Fault Code
		cSoapFDescr := IIf(GetWSCError(3) != Nil, GetWSCError(3), "")		// Soap Fault Description				
		Final("Erro ao acessar Numeração de Nfs BentoMix" + chr(13) + cErr + "-" + cSoapFCode +"-"+  cSoapFDescr)
	Endif

	AEval(aAreas, {|x| restArea(x)})
Return cNum  

//______________________________________________________________________________________________________________________________________             
/*/{Protheus.doc} FSVerWS
Função que verificará se o WS de numeração de notas está disponível. Caso contrário a nota não poderá ser incluída.
@return		lRet SE o Ws está disponível ou não.
@author  	Waldir de Oliveira
@since   	14/10/2011
/*/
//______________________________________________________________________________________________________________________________________  
User Function FSVerWS() //Não há método no wsdl da topmix para executar esse teste
	Local lRet := .T.
	/*Local cErr := "" 
	Local lAtivo := .F.   
	Local oService := Nil
	 

	oService := WSWSNEXTDOC():New()

	lAtivo := oService:MntAtivo()
	
	cErr := GetWSCError() 		
	If (!Empty(cErr))
		//Se houver erro
		lRet := .F.
		cSoapFCode  := IIf(GetWSCError(2) != Nil, GetWSCError(2), "")		// Soap Fault Code
		cSoapFDescr := IIf(GetWSCError(3) != Nil, GetWSCError(3), "")		// Soap Fault Description				
		Alert("Erro ao acessar WS de Numeração de Nfs BentoMix" + chr(13) + cErr + "-" + cSoapFCode +"-"+  cSoapFDescr)
	Endif
    
	lRet := lRet .And. lAtivo == .T.
	*/

Return lRet 

//______________________________________________________________________________________________________________________________________             
/*/{Protheus.doc} FTstTipo
Função para verificar o tipo dos itens marcados na tela de faturamento para a geração de nota.

@Return nTipo	1 == pedido normal, tipo 2 == Pedido a ser faturado pelo WS, tipo 3 == misturado

@author  Waldir de Oliveira
@since   14/10/2011
/*/
//______________________________________________________________________________________________________________________________________  
User Function FTstTipo() //Tipo 1 == pedido normal, tipo 2 == Pedido a ser faturado pelo WS, tipo 3 == misturado
	Local nTipo := 0
	Local aAreas := {SC5->(GetArea()),SC9->(GetArea()),GetArea()}
	Local cFilter := SC9->(dbFilter())        
	Local cMark := ThisMark()
	
	SC9->(dbSetFilter( {|| C9_OK == cMark },  "C9_OK == " + cMark  )) 	
	SC5->(dbSetOrder(1))	
	SC9->(dbGoTop())    
	
	While(SC9->(!Eof()))
    	SC5->(dbSeek(XFilial('SC5') + SC9->C9_PEDIDO ))
    	If(Empty(SC5->C5_ZORIGEM) .And. SC5->C5_ZTIPO <> '2')
    		If(nTipo == 0)
    			nTipo := 2
    		ElseIf(nTipo == 1)
    			nTipo := 3
    		EndIf
    	Else
			If(nTipo == 0)
				nTipo := 1
			ElseIf(nTipo == 2)
				nTipo := 3
			EndIf
    	EndIf
		SC9->(dbSkip())
	EndDo
	    
	SC9->(dbSetFilter( &("{|| " + cFilter + "  }"),  cFilter  )) 	
	
AEval(aAreas,{|x| restArea(x) })	
Return nTipo