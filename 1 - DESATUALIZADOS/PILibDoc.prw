#include "PROTHEUS.CH"  
#include "TBICONN.CH"
#include "TBICODE.CH" 
STATIC __cPrgNom
//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} PILibDoc
Rotina utilizada para realizar liberação de documento Multipla.
Usuário terá opçao para liberar varios documentos.

@author		.iNi Sistemas
@since     	01/01/15
@version  	P.11              
@param 		
@return    	
@obs        

Alterações Realizadas desde a Estruturação Inicial
/*/
//---------------------------------------------------------------------------------------
User Function PILibDoc(cRet)

Local   cMsgProble	:= ''//Variavel de mensagem de problema
Local   cMsgSoluca	:= ''//Variavel de mensagem de solução

Private cCadastro 	:= "Liberação de documentos"//Titulo da tela                                                                
Private aRotina		:= {}
Private oMark			:= GetMarkBrow()//Objeto para marcar  
Private aArraySCR		:= {}
Private aCampos 	   := {}
Private aCpos		   := {} 
Private nTotReg	   := 0
Private cArqTrab     := ""
Private cIndOrdPag   := ""
Private nRecnoSCR    := 0
Private cSeek        := ""
Private cFiltraSCR   := ""
Private cFilQry      := ""
 
/* Mensagem de problema*/
cMsgProble	+= OemToAnsi('Usuário não está cadastrado como aprovador. O acesso desta rotina é destinada apenas aos ')
cMsgProble	+= OemToAnsi('usuários envolvidos no processo de aprovação de pedido de compras definido')
/* Mensagem de solução*/
cMsgSoluca  += OemToAnsi('Verifique se o usuário deveria estar envolvido no processo de aprovação, através do grupo de aprovadores')

/* Valida se usuario é um aprovador*/	
/*
DbSelectArea("SAK")
SAK->(dbSetOrder(02))
If ! SAK->(Dbseek(xFilial('SAK')+__CUSERID))
   ShowHelpDlg("Liberação Documento",{cMsgProble},5,{cMsgSoluca},5)
 	Return(.F.)
EndIf
*/
FStrTela() // cria a estrutura da tabela para ser apresentado na tela da rotina.
/*Chama rotina para criar menu da tela */
FMenu()
                                 
//FFiltro()

/*Função utilizada para buscar os dados*/
FBusDados()                   
	
If nTotReg == 0 .AND. Empty(cRet)
 	MsgAlert(OemTOAnsi('Não existem dados a serem exibidos!!'))
 	Return .T.
Elseif !(Empty(cRet))
Return .T.
Endif

/* Cria tela para usuario selecionar quais documento deseja liberar*/
MarkBrow("TRB","OK",,aCpos,,,"U_PIMarkTud()",,,,"U_DuplClik()")
	
Return(Nil)

//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} FBusDados
Função utilizada para buscar os dados do aprovador

@author		.iNi Sistemas
@since     	01/01/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

/*/
//---------------------------------------------------------------------------------------
Static Function FBusDados()
	
Local cQuery := ''
Local cTabDoc:= GetNextAlias()
Local nVlrLiq:= 0
Local cClassi:= ''   

DbSelectArea("TRB")
TRB->(__DBZAP()) // Limpa a tabela temporaria.

aArraySCR:={}     

/*cQuery += Chr(13)+" SELECT CR_FILIAL AS FILIAL, CR_NUM AS NUM, CR_USER AS USUARIO, CR_TIPO AS TIPO, CR_TOTAL AS TOTAL FROM "+RetSqlName("SCR")+"  "	
cQuery += Chr(13)+" WHERE D_E_L_E_T_ <> '*' "
If Empty(cFilQry)   
   cQuery += Chr(13)+" AND CR_USER = '"+__CUSERID+"' "
   cQuery += Chr(13)+" AND CR_STATUS IN ('02') "	   
Else
   cQuery += Chr(13)+"AND "+cFilQry
Endif
cQuery += Chr(13)+" ORDER BY 1,2 " */
cQuery += Chr(13)+" SELECT DISTINCT CR_FILIAL AS FILIAL, CR_NUM AS NUM, CR_USER AS USUARIO, CR_TIPO AS TIPO, CR_TOTAL AS TOTAL FROM "+RetSqlName("SCR")+" SCR "	
cQuery += Chr(13)+" INNER JOIN " + RetSqlName("SC7") + " SC7 ON C7_FILIAL = CR_FILIAL AND C7_NUM = CR_NUM AND SC7.D_E_L_E_T_ = '' "                                      
cQuery += Chr(13)+" WHERE SCR.D_E_L_E_T_ <> '*' "
cQuery += Chr(13)+" AND CR_USER = '"+__CUSERID+"' "
cQuery += Chr(13)+" AND CR_STATUS IN ('02') "
cQuery += Chr(13)+" AND C7_CONAPRO = 'B' "
cQuery += Chr(13)+" AND C7_ENCER <> 'E' "	
cQuery += Chr(13)+" ORDER BY 1,2 "
	
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabDoc,.F.,.F.)  

nRecnoSCR := SCR->(Reccount())

(cTabDoc)->(DbGoTop())                                   
	
Do While (cTabDoc)->(!Eof())
		
	nVlrLiq:= FbusVlq((cTabDoc)->FILIAL,(cTabDoc)->NUM)
		
	SC7->(DbSetorder(01))
	SC7->(DbSeek((cTabDoc)->FILIAL+AvKey((cTabDoc)->NUM,'C7_NUM')))
	SC1->(DbSetOrder(01))
	SC1->(DbSeek((cTabDoc)->FILIAL+SC7->C7_NUMSC+SC7->C7_ITEMSC))
	SY1->(DbSetorder(03))
	SY1->(DbSeek(xFilial('SY1')+AvKey(SC7->C7_USER,'Y1_USER')))						
		
	/*Valida classificação da SC*/
	If SC1->C1_ZCLASSI == '1'
		cClassi:='Equipamento Parado'
	ElseIf SC1->C1_ZCLASSI == '2'
		cClassi:='Manutencao Corretiva'
	ElseIf SC1->C1_ZCLASSI == '3'
		cClassi:='Manutencao Preventiva'
	ElseIf SC1->C1_ZCLASSI == '4'
		cClassi:='Compra para Estoque'
	ElseIf SC1->C1_ZCLASSI == '5'
		cClassi:='Uso e Consumo'	
	Endif		

   nTotReg ++		
      
	Reclock('TRB',.T.)
	Replace OK           With Space(02),;
           FILIAL       With (cTabDoc)->FILIAL,;
           NOMEFIL      With FWFilialName(,(cTabDoc)->FILIAL,2),;
           SOLICIT      With SC7->C7_NUMSC,;
           COTACAO      With SC7->C7_NUMCOT,;
           NUMERO		   With (cTabDoc)->NUM,;
           NOME_COMP 	With SY1->Y1_NOME,;
           CLASSIF	   With cClassi,;					
           OBS			   With SC7->C7_OBS,;
           TIPO			With (cTabDoc)->TIPO,;
           USUARIO 		With (cTabDoc)->USUARIO,;
           VALOR			With nVlrLiq
	TRB->(MsUnLock())		                

	cClassi:= ''
   (cTabDoc)->(DbSkip())

EndDo   

DbSelectArea("TRB")
DbSetOrder(1)
If ! Empty(cSeek)
   DbSeek(Left(cSeek,6),.T.)
   If Eof()
      TRB->(DbGotop())
   Endif
Endif   

Return(Nil)                           


//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} DuplClik
Função valida duplo click no registro

@author		.iNi Sistemas
@since     	01/01/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
User Function DuplClik() 
    
	Local aAreaAll	:= {SCR->(GetArea()),GetArea()}
	/* Caso usuario esteja selecionando um registro que está marcado, nesse caso ele está desmarcando*/
	If !Empty(TRB->OK)
		RecLock("TRB",.F.)
		Replace TRB->OK With "  "
		TRB->(MsUnLock())	
	Else		
		/* Caso nao tenha problema de saldo ou alçada deve-se preencher o campo */
		RecLock("TRB",.F.)
		Replace TRB->OK With ThisMark()
		TRB->(MsUnLock())					
	Endif
	
	SCR->(DbSetorder(02))
	If SCR->(DbSeek(TRB->FILIAL+TRB->TIPO+Avkey(TRB->NUMERO,'CR_NUM')+TRB->USUARIO))
		/*Realizando a marcação do registro*/
		If !Empty(TRB->OK)
			/* Verifico se registro ja foi add no array*/
			nPosReg := aScan( aArraySCR , {|x| x[1] == SCR->(Recno())})
			If nPosReg == 0
				/* Add Recno SCR*/
				AADD(aArraySCR,{SCR->(Recno()),TRB->FILIAL, TRB->TIPO})
			EndIf		
		Else
			nPosReg := aScan( aArraySCR , {|x| x[1] == SCR->(Recno())})
			If nPosReg <> 0
				/* Deleta a posiçao do array*/
				ADEL(aArraySCR, nPosReg)
				/* Redimensiona tamanho do array, sempre depois que deleta necessario redimensionar para nao ficar com posição Null no array*/
				ASIZE(aArraySCR,Len(aArraySCR)-1)
			EndIf	
		Endif
    Endif
    
    AEval(aAreaAll,{|nLem|RestArea(nLem)})
    
Return(Nil)        





//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} FVisPCom
Função utilizada para visualizar pedido de compras ou NF

@author		.iNi Sistemas
@since     	01/01/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
User Function FVisPCom()   

	Local aAreaOld		:= {SC7->(GetArea()),GetArea()}
	Local cPedSCR		:= TRB->NUMERO
	Local cTipPed		:= TRB->TIPO
	Local cFilDoc		:= TRB->FILIAL
	Local cFilAux		:= cFilAnt
	Private nTipoPed 	:= 1   //Define o tipo de pedido
	Private l120Auto 	:= .F. //Informa a rotina de pedidos que processo não é automatico
	Private aBackSC7  := {}
	
	cFilAnt:=cFilDoc 
	/* Verifica se documento é PC ou Nota Fiscal*/
	If cTipPed == 'PC'
		/* Posiciona no pedido de compra*/	
	    SC7->(DbSetOrder(01))
	    If SC7->(DbSeek(cFilDoc+Avkey(cPedSCR,'C7_NUM')))    	    
		   INCLUI := .F.
			ALTERA := .F.    
			LINTGC := .F. // acrescentado 20150901
			A120Pedido( 'SC7', SC7->(Recno()), 2 )
		EndIf
		/*Sempre apos visualizar limpar o campo flag*/
		FLimpTab()
	ElseIf cTipPed == 'NF'
		SF1->(DbSetorder(01))
		If SF1->(DbSeek(cFilDoc+Substr(cPedSCR,1,Len(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))))
		   INCLUI := .F.
			ALTERA := .F.    
			Pergunte("MTA103",.F.)
			A103NFISCAL('SF1',SF1->(Recno()),2)
		Endif            
		/*Sempre apos visualizar limpar o campo fleg*/
		FLimpTab()
	Endif 
	/* Restaura as areas*/                 
	AEval(aAreaOld,{|x|RestArea(x)}) 
	
	cFilAnt:= cFilAux

If nRecnoSCR <> SCR->(Reccount())
MsgRun("Aguarde... Filtrando dados... " ,,{|| CursorWait() , FBusDados() , CursorArrow()})                    
Endif

Return(Nil)

           



//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} FLibDoc
Função utilizada para realizar liberação dos documentos

@author		.iNi Sistemas
@since     	01/01/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+------'---------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
User Function FBlqDoc() 
	
If Len(aArraySCR)>0
	If MsgYesNo("Deseja realizar o Bloqueio do(s) : "+cValToChar(Len(aArraySCR))+' documento(s) selecionado(s)?')
		Processa( {|| PIBlqDocs()}, "Bloqueio documentos", "Aguarde...",.F.)
		Processa( {|| FBusDados()}, "Filtrando documentos", "Aguarde...",.F.)		
	EndIf
Else
	MsgAlert('Favor selecionar no minimo 1 registro!!')
Endif	

aArraySCR := {} // limpa o array dos pedidos a serem liberados.
SysRefresh()

Return(Nil)





//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} FLibDoc
Função utilizada para realizar liberação dos documentos

@author		.iNi Sistemas
@since     	01/01/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+------'---------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
User Function FLibDoc() 
	
If Len(aArraySCR)>0
	If MsgYesNo("Deseja realizar liberação do(s) : "+cValToChar(Len(aArraySCR))+' documento(s) selecionado(s)?')
		Processa( {|| PILibDocs()}, "Liberando documentos", "Aguarde...",.F.)
		Processa( {|| FBusDados()}, "Filtrando documentos", "Aguarde...",.F.)		
	EndIf
Else
	MsgAlert('Favor selecionar no minimo 1 registro!!')
Endif	

aArraySCR := {} // limpa o array dos pedidos a serem liberados.
SysRefresh()

Return(Nil)

//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} PILibDocs
Função utilizada para processar liberação dos documentos
                                  
@author		.iNi Sistemas
@since     	05/09/14
@version  	P.11
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//--------------------------------------------------------------------------------------- 
Static Function PILibDocs()
	
Local nRegSCR	:= Len(aArraySCR)//Variavel recebe quantidade registros existentes no array
Local nCont	   := 1  
Local lRetAprov:= .F. //Variavel recebe retorno caso documento tenha sido totalmente liberado
Local cQuery	:= ''
Local lErro		:= .T. 
Local cCodUsrApr:= ''
Local cFilAux	:= cFilAnt

cSeek	:= ""

    /* Definição de Regua*/
	ProcRegua(nRegSCR)
	
	Begin Transaction 
	
		For nX:= 1 To Len(aArraySCR)
		    /* Regua do processo*/
			IncProc("Processando Registro: "+ AllTrim(str(nCont)) +' de: '+Alltrim(Str(nRegSCR)))
			/*Atualiza a filial de acordo com o registro*/
			cFilAnt := aArraySCR[nX][2]
			/*Necessario posicionar via Recno, pois existe a possibilidade de pedidos antigos*/ 
			SCR->(dbGoTo(aArraySCR[nX][1]))
			If !SCR->(Eof())
		    	/* Seek do pedido de compra*/
		    	cSeek:=SCR->CR_FILIAL+AvKey(SCR->CR_NUM,'C7_NUM')
				/* Bloco 1 */
				If aArraySCR[nX][3] == 'PC' .Or. aArraySCR[nX][3] == 'AE'
					SC7->(DbSetOrder(01))
					SC7->(DbSeek(cSeek))
					cCodUsrApr:= SC7->C7_APROV
				ElseIf aArraySCR[nX][3] == 'NF'
					SF1->(DbSetOrder(01))
					SF1->(DbSeek(Substr(cSeek,1,Len(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))))
					cCodUsrApr:= SF1->F1_APROV
				Endif	
				/* Realiza liberação do documento*/
				lRetAprov:= MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,,cCodUsrApr,,,,,},dDatabase,4)                									
			EndIf			 
			/* Se variavel lRetAprov = .T. documento foi totalmente liberado*/
			/* Realiza liberação do pedido de compra ou Pre-Nota*/
		   	If SCR->CR_TIPO == 'PC'  //lRetAprov .And. 
				SC7->(dbSetorder(01))
				If SC7->(dbSeek(cSeek))
					Do While SC7->(!Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == SCR->(CR_FILIAL+AllTrim(CR_NUM))
						If Reclock("SC7",.F.)
							Replace	SC7->C7_CONAPRO With "L"
							SC7->(MsUnlock())
						Endif
						SC7->(dbSkip())
					EndDo	
			 	Endif	
			ElseIf lRetAprov .And. SCR->CR_TIPO == 'NF'
				SF1->(DbSetOrder(01))
				If SF1->(DbSeek(xFilial("SF1")+Substr(SCR->CR_NUM,1,Len(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))))
					If RecLock('SF1',.F.)
						Replace SF1->F1_STATUS With If(SF1->F1_STATUS =="B"," ",SF1->F1_STATUS)
						SF1->(MsUnLock())
					EndIf
				EndIf				
			EndIf
		/*Atualiza variavel para nao carregar lixo*/
		lRetAprov:=.F.
		Next nX	
						
	End Transaction	
	/*Retorna a variavel da filial corrente*/
	cFilAnt:= cFilAux	
			
Return(Nil)




//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} PIBlqDocs
Função utilizada para processar liberação dos documentos
                                  
@author		.iNi Sistemas
@since     	05/09/14
@version  	P.11
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//--------------------------------------------------------------------------------------- 
Static Function PIBlqDocs()
	
Local nRegSCR	:= Len(aArraySCR)//Variavel recebe quantidade registros existentes no array
Local nCont	   := 1  
Local lRetAprov:= .F. //Variavel recebe retorno caso documento tenha sido totalmente liberado
Local cQuery	:= ''
Local lErro		:= .T. 
Local cCodUsrApr:= ''
Local cFilAux	:= cFilAnt

cSeek	:= ""

ProcRegua(nRegSCR)
	
	Begin Transaction 
	
		For nX:= 1 To Len(aArraySCR)
		    /* Regua do processo*/
			IncProc("Processando Registro: "+ AllTrim(str(nCont)) +' de: '+Alltrim(Str(nRegSCR)))
			/*Atualiza a filial de acordo com o registro*/
			cFilAnt := aArraySCR[nX][2]
			/*Necessario posicionar via Recno, pois existe a possibilidade de pedidos antigos*/ 
			SCR->(dbGoTo(aArraySCR[nX][1]))
			If !SCR->(Eof())
		    	/* Seek do pedido de compra*/
		    	cSeek:=SCR->CR_FILIAL+AvKey(SCR->CR_NUM,'C7_NUM')
				/* Bloco 1 */
				If aArraySCR[nX][3] == 'PC' .Or. aArraySCR[nX][3] == 'AE'
					SC7->(DbSetOrder(01))
					SC7->(DbSeek(cSeek))
					cCodUsrApr:= SC7->C7_APROV
				ElseIf aArraySCR[nX][3] == 'NF'
					SF1->(DbSetOrder(01))
					SF1->(DbSeek(Substr(cSeek,1,Len(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))))
					cCodUsrApr:= SF1->F1_APROV
				Endif	
				/* Realiza liberação do documento*/
				lRetAprov:= MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,,cCodUsrApr,,,,,},dDatabase,6)
			EndIf			 
		   
		   lRetAprov:=.F.
		
		Next nX	
						
	End Transaction	

cFilAnt:= cFilAux	
			
Return(Nil)






//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} PIMarkAll
Função acionada no momento em que usuario tenta usar objeto do markbrow para marcar
todos os registros.
Seu retorno será Nil, faz-se necessario para desabilitar essa opçao.

@author		.iNi Sistemas
@since     	01/01/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------	
User Function PIMarkTud()     
Return(Nil)





//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} FbusVlq
Função utilizada para buscar o valor liquido do pedido de compra

@author		.iNi Sistemas
@since     	03/03/15
@version  	P.11              
@param 		cFilPC - Filial do Pedido de compra
@param 		cNumPC - Numero do pedido de compra
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------	
Static Function FbusVlq(cFilPC, cNumPC)

	Local nVlPedLiq	:= 0  
	Local cQuery	:= ''
	Local aPrefSom	:= GetNextAlias()
	
	cQuery+="SELECT SUM((C7_TOTAL+C7_VALFRE+C7_VALIPI ) - C7_VLDESC) AS TOTAL "
	cQuery+="FROM "+RetSqlName('SC7')+ " "
	cQuery+="WHERE C7_FILIAL = '"+cFilPC+"' "
	cQuery+="AND C7_NUM = '"+AllTrim(cNumPC)+"' "
	cQuery+="AND D_E_L_E_T_ <> '*'  "
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),aPrefSom,.F.,.F.) 
	
	(aPrefSom)->(DbGoTop())
	/*Recebe o valor total do PC*/
	nVlPedLiq:= (aPrefSom)->TOTAL
	/*Fecha tabela temporaria*/
	(aPrefSom)->(DbCloseArea())
		                         
Return(nVlPedLiq)





//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} FLimpTab
Função utilizada para desmarcar todos os itens da tabela e limpar array com os pedidos
selecionados para aprovação

@author		.iNi Sistemas
@since     	03/03/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum

Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+---------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                    
------------+-----------------+---------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------	
Static Function FLimpTab()

		/*Sempre apos visualizar limpar o campo fleg*/
		TRB->(DbGoTop())
		Do While TRB->(!Eof())			
			RecLock("TRB",.F.)
			Replace TRB->OK With "  "
			TRB->(MsUnLock())
		TRB->(DbSkip())	
		EndDo
		
		/*Limpa array que contem os registros selecionados*/
		aArraySCR:={}			

Return(Nil)






//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} PILibDoc
Rotina utilizada para realizar liberação de documento Multipla.
Usuário terá opçao para liberar varios documentos.

@author		.iNi Sistemas
@since     	01/01/15
@version  	P.11              
@param 		
@return    	
@obs        

Alterações Realizadas desde a Estruturação Inicial
/*/
//---------------------------------------------------------------------------------------
Static Function FStrTela()

aCpos := {}

AADD(aCpos,{ "OK" 	   	     , "","" 					})
AADD(aCpos,{ "FILIAL"  		 , "", "Filial"			,"@!"})
AADD(aCpos,{ "NOMEFIL" 		 , "", "Nome Filial"	,"@!"})
AADD(aCpos,{ "SOLICIT"       , "", "Solicitacao"	,"@!"})
AADD(aCpos,{ "COTACAO" 		 , "", "Cotacao"		,"@!"})
AADD(aCpos,{ "NUMERO"  		 , "", "Numero"			,"@!"})
AADD(aCpos,{ "NOME_COMP" 	 , "", "Nome Comprador"	,"@!"})
AADD(aCpos,{ "CLASSIF"		 , "", "Classificacao"	,"@!"})
AADD(aCpos,{ "OBS" 			 , "", "Observacao"		,"@!"})
AADD(aCpos,{ "TIPO"	   	     , "", "Tipo Doc"		,"@!"})
AADD(aCpos,{ "USUARIO"	     , "", "Usuario"		,"@!"})
AADD(aCpos,{ "VALOR"   		 , "", "Valor"			,"@E 999,999,999.99"})                          

aCampos := {}
          
AADD(aCampos,{ "OK"    		 , "C", 2, 0 })                    
AADD(aCampos,{ "FILIAL"   	 , "C", TamSx3( "CR_FILIAL" )[1], 0 })
AADD(aCampos,{ "NOMEFIL"    , "C", 30, 0 })                    
AADD(aCampos,{ "SOLICIT"  	 , "C", TamSx3( "C1_NUM"  )[1], 0 })
AADD(aCampos,{ "COTACAO"    , "C", TamSx3( "C8_NUM"  )[1], 0 })
AADD(aCampos,{ "NUMERO"   	 , "C", TamSx3( "CR_NUM"  )[1], 0 })
AADD(aCampos,{ "NOME_COMP"	 , "C", TamSx3( "Y1_NOME" )[1], 0 })
AADD(aCampos,{ "CLASSIF"    , "C", 25, 0 })
AADD(aCampos,{ "OBS"			 , "C", TamSx3( "C7_OBS" )[1], 0 })
AADD(aCampos,{ "TIPO" 		 , "C", TamSx3( "CR_TIPO" )[1], 0 })
AADD(aCampos,{ "USUARIO" 	 , "C", TamSx3( "CR_USER" )[1], 0 })
AADD(aCampos,{ "VALOR"		 , "N", TamSx3( "C7_TOTAL")[1], 2 })

cArqTrab  := CriaTrab(aCampos,.T.) 
cIndOrdPag:= CriaTrab(Nil,.F.)
	
If Select('TRB')>0
   TRB->(DbCloseArea())
Endif

dbUseArea(.T.,, cArqTrab,"TRB",.F.,.F.) // DbUseArea(lNovo, cDriver, cArquivo, cAlias, lComparilhado,lSoLeitura)    
IndRegua("TRB",cIndOrdPag,"FILIAL+NUMERO",,,"Selecionando Registro") //"Selecionando Registros..."

Return .t.





//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} FMenu
Função utilizada para definir Menu da rotina

@author		.iNi Sistemas
@since     	01/01/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum
/*/
//---------------------------------------------------------------------------------------
Static Function FMenu()   

aRotina := {}
/*Monta o Menu*/
AAdd (aRotina,{"Pesquisar"     ,"U_FPesqDoc()"  ,0,1})
AAdd (aRotina,{"Consulta Doc"  ,"U_FVisPCom()"  ,0,2})
AAdd (aRotina,{"Liberar Doc"   ,"U_FLibDoc()"   ,0,3})
AAdd (aRotina,{"Bloquear Doc"  ,"U_FblqDoc()"   ,0,3})

Return(aRotina)




//--------------------------------------------------------------------------------------
/*/
{Protheus.doc} FFiltro

@author		.iNi Sistemas
@since     	01/01/15
@version  	P.11              
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum
/*/
//---------------------------------------------------------------------------------------
Static Function FFiltro()

	If Pergunte("MTA097",.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle de Aprovacao : CR_STATUS -->                ³
		//³ 01 - Bloqueado p/ sistema (aguardando outros niveis) ³
		//³ 02 - Aguardando Liberacao do usuario                 ³
		//³ 03 - Pedido Liberado pelo usuario                    ³
		//³ 04 - Pedido Bloqueado pelo usuario                   ³
		//³ 05 - Pedido Liberado por outro usuario               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicaliza a funcao FilBrowse para filtrar a mBrowse          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SCR")
		dbSetOrder(1)   
		
       cFiltraSCR  := ' CR_USER == "'+__CUSERID
	   cFilQry     := " CR_USER = '"+__CUSERID+"' AND CR_EMISSAO >= '" +DtoS(dDataBase-180)+ "'"
 	    
  		Do Case
			Case mv_par01 == 1
				cFiltraSCR += '".And.CR_STATUS=="02"'
				cFilQry    += " AND CR_STATUS='02' "
			Case mv_par01 == 2
				cFiltraSCR += '".And.(CR_STATUS=="03".OR.CR_STATUS=="05")'
				cFilQry    += " AND (CR_STATUS='03' OR CR_STATUS='05') "
			Case mv_par01 == 3
				cFiltraSCR += '"'
				cFilQry    += " "
			OtherWise
				cFiltraSCR += '".And.(CR_STATUS=="01".OR.CR_STATUS=="04")'
				cFilQry    += " AND (CR_STATUS='01' OR CR_STATUS='04' ) "
		EndCase
	
	
		//bFilSCRBrw 	:= {|| FilBrowse("SCR",@aIndexSCR,@cFiltraSCR)}
		//Eval(bFilSCRBrw)
	
	Endif
/*
CR_STATUS== "01"', 'BR_AZUL' },;//Bloqueado p/ sistema(aguardando outros niveis)
CR_STATUS== "02"', 'DISABLE' },;//Aguardando Liberacao do usuario
CR_STATUS== "03"', 'ENABLE' } ,;//Pedido Liberado pelo usuario
CR_STATUS== "04"', 'BR_PRETO'},;//Pedido Bloqueado pelo usuario
CR_STATUS== "05"', 'BR_CINZA'} }//Pedido Liberado por outro usuario
*/	
Return .T.