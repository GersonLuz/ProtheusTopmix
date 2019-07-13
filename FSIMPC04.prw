#Include "Protheus.ch"
#Include "Rwmake.ch"
#INCLUDE "TBICONN.CH"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSIMPC04
Função para Importar fornecedores entre Empresas (Top Mix e Flapa)
          
@author 	.iNi Sistemas
@since 		15/01/2014
@version 	P11.5
@obs  
Projeto 	2014003TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------         
User Function FSIMPC04()                                     

Local cCgcFor	:= AllTrim(SA2->A2_CGC)
Local cCodFor	:= AllTrim(SA2->A2_COD)
Local cLojFor	:=  AllTrim(SA2->A2_LOJA)

If U_FSXVlFoE(cCgcFor,cCodFor,cLojFor) //-- Valida se fornecedor existe nas empresas que serão replicadas
	FSIncFor() //-- Realizar importação de fornecedores para as demais empresas
	fSendMail(AllTrim(SA2->A2_CGC)) //-- Envia e-mail
EndIf
             
Return(Nil)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSXVlFoE
Função para validar se fornecedor existe nas outras empresas
          
@author 	.iNi Sistemas
@since 		15/01/2014
@version 	P11.5
@obs  
Projeto 	2014003TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------  
User Function FSXVlFoE(cCgcFor,cCodFor,cLojFor)

Local cQryFor := ""
Local cEmpAux := ""
Local lRetVld := .T.
Local cEmpres	:= GetMv("FS_EMPIMPP",,"01,02") //-- Empresas que terão integração.
Local aArrEmp	:= StrTokArr(cEmpres,",") 

For nXi := 1 To Len(aArrEmp)

	cEmpAux := AllTrim(aArrEmp[nXi])

	If !(cEmpAux == cEmpAnt) //-- Não verifica para empresa corrente.
		
		If !Empty(cQryFor)
			cQryFor += Chr(13) + " UNION "
		EndIf

		cQryFor += Chr(13) + "SELECT '"+cEmpAux+"' AS A2_EMP, A2.A2_FILIAL, A2.A2_CGC "
		cQryFor += Chr(13) + "FROM SA2"+cEmpAux+"0 A2 "
		cQryFor += Chr(13) + "WHERE A2.D_E_L_E_T_ <> '*' "
		cQryFor += Chr(13) + "AND (A2.A2_CGC = '"+cCgcFor+"' "
		cQryFor += Chr(13) + "OR (A2.A2_COD = '"+cCodFor+"' AND A2.A2_LOJA = '"+cLojFor+"'))"
    EndIf
    
Next nXi

If Select("QSA2VL") > 0
	QSA2VL->(dbCloseArea())
EndIf

If TcSqlExec(cQryFor) <> 0
	Aviso(OemToAnsi("Atenção"),"ERRO SQL "+TCSqlError(),{"Ok"},2)
	lRetVld := .F.
Else
	//Cria o arquivo de trabalho da query posicionada
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryFor),"QSA2VL",.F.,.T.)
	QSA2VL->(dbGoTop())
	//Valida se exitem informacoes no arquivo gerado.
	If QSA2VL->(!Eof())
	//	lRetVld := .F.
	 //	Alert("Encontrado fornecedor cadastrado com o mesmo cnpj ou mesmo código e loja para outra empresa! Entre em contato com o Administrador.")
	EndIf 
	
	QSA2VL->(dbCloseArea())
EndIf

Return(lRetVld)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSIncFor
Função para incluir fornecedor nas empresas
          
@author 	.iNi Sistemas
@since 		15/01/2014
@version 	P11.5
@obs  
Projeto 	2014003TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------  
Static Function FSIncFor()

Local cEmpAux		:= ""
Local cNovVal		:= ""
Local nRecNewA2		:= 0
Local cDirLay		:= GetMv("FS_NMDIRLAY",,"\Layouts\Integração")
Local cArqLay 		:= cDirLay+"\FSIMPC04.LAY"
Local aArrLay		:= {}
Local cEmpres		:= GetMv("FS_EMPIMPP",,"01,02") //-- Empresas que terão integração.
Local aArrEmp		:= StrTokArr(cEmpres,",") 
                       
If FSCarLay(cArqLay, aArrLay) //-- Carrega arquivo de Layout

	For nXi := 1 To Len(aArrEmp)
	
		If aArrEmp[nXi] <> (cEmpAnt) 
		
			cEmpAux := AllTrim(aArrEmp[nXi])
		
			nRecNewA2 := FSRecFor(cEmpAux)
	
			If nRecNewA2 > 0
		
				cQuery1 := "INSERT INTO SA2"+cEmpAux+"0 ("
				
				For nXT := 1 To Len(aArrLay)
					cQuery1 += aArrLay[nXT][1]+","
				Next nXT
	
	            //-- Ultima posição é o RECNO			
				cQuery1 += "R_E_C_N_O_"+","
									
				If Right(cQuery1,1) == ","
					cQuery1 := SubStr(cQuery1,1,Len(cQuery1)-1)
				EndIf
				cQuery1 += ") VALUES ("
	
				For nXT := 1 To Len(aArrLay)                                      
	     		  	If !Empty(aArrLay[nXT][2]) //-- Verifica se tem bloco de código no layout.
	     		  		cNovVal := Eval(&(aArrLay[nXT][2]), &("SA2->"+aArrLay[nXT][1]))
	     		  		If 	ValType(&("SA2->"+aArrLay[nXT][1])) == "N"
	     		  			cQuery1 += cNovVal+","
	     		  	    Else
	     		  			cQuery1 += "'"+cNovVal+"',"	     		  	    
	     		  	    EndIf
	     		  	ElseIf ValType(&("SA2->"+aArrLay[nXT][1])) == "N"
						cQuery1 += AllTrim(Str(&("SA2->"+aArrLay[nXT][1])))+","
		    		ElseIf ValType(&("SA2->"+aArrLay[nXT][1])) == "D"
						cQuery1 += "'"+DToS(&("SA2->"+aArrLay[nXT][1]))+"',"
		       		Else
						cQuery1 += "'"+&("SA2->"+aArrLay[nXT][1])+"',"
					EndIf
				Next nXT
	            
	            //-- Ultima posição é o RECNO
				cQuery1 += AllTrim(Str(nRecNewA2))+","
				
				If Right(cQuery1,1) == ","
					cQuery1 := SubStr(cQuery1,1,Len(cQuery1)-1)
				EndIf
				cQuery1 += ")"
	
				If TcSqlExec(cQuery1) <> 0
					Aviso(OemToAnsi("Atenção"),"ERRO SQL "+TCSqlError(),{"Ok"},2)
				EndIf
			
			EndIf
		EndIf
	
	Next nXi
EndIf

Return()


//------------------------------------------------------------------- 
/*/{Protheus.doc} FSRecFor
Função para buscar último RECNO da Empresa Destino
          
@author 	.iNi Sistemas
@since 		15/01/2015
@version 	P11.5
@obs  
Projeto 	2014003TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------  
Static Function FSRecFor(cEmpAux)

Local nRetVld := 1
Local cQryFor := ""

cQryFor += Chr(13) + "SELECT MAX(R_E_C_N_O_) + 1 AS A2_RECNO"
cQryFor += Chr(13) + "FROM SA2"+cEmpAux+"0 A2 "

If Select("QA2REC") > 0
	QA2REC->(dbCloseArea())
EndIf

If TcSqlExec(cQryFor) <> 0
	Aviso(OemToAnsi("Atenção"),"ERRO SQL "+TCSqlError(),{"Ok"},2)
Else
	//Cria o arquivo de trabalho da query posicionada
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryFor),"QA2REC",.F.,.T.)
	QA2REC->(dbGoTop())
	//Valida se exitem informacoes no arquivo gerado.
	If QA2REC->(!Eof())
		nRetVld := QA2REC->A2_RECNO
	EndIf  
	QA2REC->(dbCloseArea())
EndIf

Return(nRetVld) 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSCarLay
Função para carregar layout
          
@author 	.iNi Sistemas
@since 		15/01/2015
@version 	P11.5
@obs  
Projeto 	2014003TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------  
Static Function FSCarLay(cArqLay, aLayout)

Local cLinAtu 	:= ""
Local aLinAtu 	:= {}
Local nHandle	:= 0

If !File(cArqLay)       
	Alert("Não encontrado arquivo de Layout. Informe ao administrador!")
	Return(.F.)
EndIf

nHandle:= FT_fUse(cArqLay)
FT_fGoTop()

Do While ! FT_fEOF()
      
   cLinAtu := "{" + FT_fReadLn() + "}"
   aLinAtu := &(cLinAtu)
   
	aAdd(aLayout, aClone(aLinAtu))

   FT_fSkip()

EndDo

//Fecha arquivo
FClose(nHandle)

Return(.T.)    

//-------------------------------------------------------------------
/*/{Protheus.doc} fSendMail

Envio de Email.

@author 	.iNi Sistemas

@since		15/01/2015
@version	P11 R5
@param		Nenhum
@return		Nenhum

@Obs:

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------
/*/
Static Function fSendMail(cCgcFor)

Local cServer     := AllTrim(GetMv("MV_RELSERV"))
Local cAccount    := AllTrim(GetMv("MV_RELACNT"))
Local cPassword   := AllTrim(GetMv("MV_RELPSW"))
Local cFrom       := AllTrim(GetMv("MV_RELFROM"))
Local cTo		   := AllTrim(GETMV("FS_EMINCFR",,"jean.santos@topmix.com.br"))
Local cSubject	   := ""
Local cBody		   := ""
Local cCodgHtml   := ""          
Local cAttachment := ""
Local _cMailError := ""
Local lConnect    := .F.
Local lEnviou     := .F.
Local lRet        := .T.         

cSubject := "Novo Fornecedor Cadastrado. Origem: Empresa "+cEmpAnt

cSubject := cSubject+" - "+DtoC(dDataBase)

cBody := fGerHtO(cCgcFor)
	
If ! Empty(cServer) .And. ! Empty(cAccount) .And. ! Empty(cTo)

   //Realiza conexao com o Servidor
   CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lConnect

   // Se existe autenticacao para envio valida pela funcao MAILAUTH
   lRet := Mailauth(cAccount,cPassword) 
      
   If lConnect //Se conseguiu Conexao ao Servidor SMTP
      SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody RESULT lEnviou 
		//ATTACHMENT cAttachment      
      If !lEnviou //Se conseguiu Enviar o e-Mail
         GET MAIL ERROR _cMailError
         Alert(_cMailError)
         lRet:=.f.
      EndIf
   Else
      lRet:=.f.   
   EndIf      
   
   If lRet
      DISCONNECT SMTP SERVER
   EndIf
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} fGerHtO

Gera o HTML do E-mail.

@author 	.iNi Sistemas

@since		15/01/2015
@version	P11 R5
@param		Nenhum
@return		Nenhum

@Obs:

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------
/*/
Static Function fGerHtO(cCgcFor)

Local cCodgHtml := ""

cCodgHtml := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"> '
cCodgHtml += '<html>'
cCodgHtml += '<head>   '
cCodgHtml += '	<title>Novo Fornecedor Cadastrado - Empresa Origem: '+cEmpAnt+'</title>  '
cCodgHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">  '
cCodgHtml += '</head>'
cCodgHtml += '<body>'
cCodgHtml += '<div style="text-align: center;"> '
cCodgHtml += '	<div style="text-align: center;">'
cCodgHtml += '	<font face="Verdana">&nbsp;<span style="font-weight: bold;">  '
cCodgHtml += '	<span style="text-decoration: underline;">Novo Fornecedor Cadastrado - Empresa Origem: '+cEmpAnt+'</span></span></font></div> '
cCodgHtml += '</div>' 
cCodgHtml += '<p><font face="Arial"><b><font size="2">Prezado(a), </font></b></font></p>'
cCodgHtml += '<p><font face="Arial"><b><font size="2">Um novo fornecedor ( CNPJ: '+AllTrim(cCgcFor)+') foi cadastrado como bloqueado. Origem do cadastro: Empresa '+cEmpAnt+'.'
cCodgHtml += ' Favor verificar. </font></b></font></p>'
		
cCodgHtml += '<p><font face="Arial" size="1"><span style="font-weight: bold;">E-mail Automático, favor não responder.</span></font></p>'
cCodgHtml += '<p><span style="color: rgb(255, 0, 0); font-family: Arial;"><span style="font-weight: bold;">'
cCodgHtml += '<font size="1">Dúvidas, favor entrar em contato com o setor responsável.</font></span></span></p>'
cCodgHtml += '</body>'
cCodgHtml += '</html>'

Return(cCodgHtml)