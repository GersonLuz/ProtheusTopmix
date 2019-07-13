#Include "Protheus.ch"
#Include "Rwmake.ch"
#INCLUDE "TBICONN.CH"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSIMPC02
Função para Importar grupo de produto entre Empresas (Top Mix e Flapa)
          
@author 	.iNi Sistemas
@since 		07/08/2014
@version 	P11.5
@obs  
Projeto 	2014002TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------         
User Function FSIMPC02()                                     

Local cCodGrp	:= AllTrim(SBM->BM_GRUPO)

If U_FSXVlGrE(cCodGrp) //-- Valida se grupo de produto existe nas empresas que serão replicadas
	FSIncGrp() //-- Realizar importação de grupo de produto para as demais empresas
	fSendMail(AllTrim(SBM->BM_GRUPO)) //-- Envia e-mail
Else
   U_FLogFile("FALHA na Validação grupo de produto existe nas empresas que serão replicadas")	
EndIf

Return(Nil)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSXVlGrE
Função para validar se grupo de produto existe nas outras empresas
          
@author 	.iNi Sistemas
@since 		07/08/2014
@version 	P11.5
@obs  
Projeto 	2014002TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------  
User Function FSXVlGrE(cCodGrp)

Local cQryPrd := ""
Local cEmpAux := ""
Local lRetVld := .T.
Local cEmpres	:= GetMv("FS_EMPIMPP",,"01,02") //-- Empresas que terão integração.
Local aArrEmp	:= StrTokArr(cEmpres,",") 

For nXi := 1 To Len(aArrEmp)

	cEmpAux := AllTrim(aArrEmp[nXi])

	If !(cEmpAux == cEmpAnt) //-- Não verifica para empresa corrente.

		If !Empty(cQryPrd)
			cQryPrd += Chr(13) + " UNION "
		EndIf
		
		cQryPrd += Chr(13) + "SELECT '"+cEmpAux+"' AS BM_EMP, BM.BM_FILIAL, BM.BM_GRUPO "
		cQryPrd += Chr(13) + "FROM SBM"+cEmpAux+"0 BM "
		cQryPrd += Chr(13) + "WHERE BM.D_E_L_E_T_ <> '*' "
		cQryPrd += Chr(13) + "AND BM.BM_GRUPO = '"+cCodGrp+"' "
	
    EndIf
    
Next nXi

If Select("QSBMVL") > 0
	QSBMVL->(dbCloseArea())
EndIf

If TcSqlExec(cQryPrd) <> 0
	Aviso(OemToAnsi("Atenção"),"ERRO SQL "+TCSqlError(),{"Ok"},2)
	lRetVld := .F.
Else
	//Cria o arquivo de trabalho da query posicionada
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryPrd),"QSBMVL",.F.,.T.)
	QSBMVL->(dbGoTop())
	//Valida se exitem informacoes no arquivo gerado.
	If QSBMVL->(!Eof())
		lRetVld := .F.
		Alert("Encontrado grupo de produto cadastrado com o mesmo código para outra empresa! Entre em contato com o Administrador.")
	EndIf 
	
	QSBMVL->(dbCloseArea())
EndIf

Return(lRetVld)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSIncGrp
Função para incluir grupo de produto nas empresas
          
@author 	.iNi Sistemas
@since 		07/08/2014
@version 	P11.5
@obs  
Projeto 	2014002TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------  
Static Function FSIncGrp()

Local cQryPrd		:= ""
Local cEmpAux		:= ""
Local nRecNewBM		:= 0
Local cDirLay		:= GetMv("FS_NMDIRLAY",,"\Layouts\Integração")
Local cArqLay 		:= cDirLay+"\FSIMPC02.LAY"
Local aArrLay		:= {}
Local cEmpres	:= GetMv("FS_EMPIMPP",,"01,02") //-- Empresas que terão integração.
Local aArrEmp	:= StrTokArr(cEmpres,",") 
                       
If FSCarLay(cArqLay, aArrLay) //-- Carrega arquivo de Layout

	For nXi := 1 To Len(aArrEmp)
	
		If aArrEmp[nXi] <> (cEmpAnt) 
		
			cEmpAux := AllTrim(aArrEmp[nXi])
		
			nRecNewBM := FSRecPrd(cEmpAux)
	
			If nRecNewBM > 0
		
				cQuery1 := "INSERT INTO SBM"+cEmpAux+"0 ("
				
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
	     		  		cQuery1 += Eval(&(aArrLay[nXT][2]), &("SBM->"+aArrLay[nXT][1]))+","
	     		  	ElseIf ValType(&("SBM->"+aArrLay[nXT][1])) == "N"
						cQuery1 += AllTrim(Str(&("SBM->"+aArrLay[nXT][1])))+","
		    		ElseIf ValType(&("SBM->"+aArrLay[nXT][1])) == "D"
						cQuery1 += "'"+DToS(&("SBM->"+aArrLay[nXT][1]))+"',"
		       	Else
						cQuery1 += "'"+&("SBM->"+aArrLay[nXT][1])+"',"
					EndIf
				Next nXT
	            
	            //-- Ultima posição é o RECNO
				cQuery1 += AllTrim(Str(nRecNewBM))+","
				
				If Right(cQuery1,1) == ","
					cQuery1 := SubStr(cQuery1,1,Len(cQuery1)-1)
				EndIf
				cQuery1 += ")"
				
				If TcSqlExec(cQuery1) <> 0
    		      U_FLogFile("FALHA no Insert grupo de produtos: "+cQuery1)					
					Aviso(OemToAnsi("Atenção"),"ERRO SQL "+TCSqlError(),{"Ok"},2)    		      
				Else
    		      U_FLogFile("SUCESSO no Insert grupo de produtos: "+cQuery1)					
				EndIf
			Else
    			U_FLogFile("Insert grupo de produtos FALHOU. Motivo: nRecNewBM = 0 ")		      
			EndIf
		EndIf
	
	Next nXi
Else
   U_FLogFile("Inclusão de Grupos. FALHA ao carregar o arquivo de Layout: "+cArqLay)
EndIf

Return()


//------------------------------------------------------------------- 
/*/{Protheus.doc} FSRecPrd
Função para buscar último RECNO da Empresa Destino
          
@author 	.iNi Sistemas
@since 		07/08/2014
@version 	P11.5
@obs  
Projeto 	2014002TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------  
Static Function FSRecPrd(cEmpAux)

Local nRetVld := 1
Local cQryPrd := ""

cQryPrd += Chr(13) + "SELECT MAX(R_E_C_N_O_) + 1 AS BM_RECNO"
cQryPrd += Chr(13) + "FROM SBM"+cEmpAux+"0 BM "

If Select("QBMREC") > 0
	QBMREC->(dbCloseArea())
EndIf

If TcSqlExec(cQryPrd) <> 0
	Aviso(OemToAnsi("Atenção"),"ERRO SQL "+TCSqlError(),{"Ok"},2)
Else
	//Cria o arquivo de trabalho da query posicionada
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryPrd),"QBMREC",.F.,.T.)
	QBMREC->(dbGoTop())
	//Valida se exitem informacoes no arquivo gerado.
	If QBMREC->(!Eof())
		nRetVld := QBMREC->BM_RECNO
	EndIf  
	QBMREC->(dbCloseArea())
EndIf

Return(nRetVld) 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSCarLay
Função para carregar layout
          
@author 	.iNi Sistemas
@since 		07/08/2014
@version 	P11.5
@obs  
Projeto 	2014002TOPM
        
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

@since		17.03.2014
@version	P11 R5
@param		Nenhum
@return		Nenhum

@Obs:

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------
/*/
Static Function fSendMail(cCodGrp)

Local cServer     := AllTrim(GetMv("MV_RELSERV"))
Local cAccount    := AllTrim(GetMv("MV_RELACNT"))
Local cPassword   := AllTrim(GetMv("MV_RELPSW"))
Local cFrom       := AllTrim(GETMV("MV_RELFROM"))
Local cTo		  := AllTrim(GETMV("FS_EMINCGR",,"jean.santos@topmix.com.br"))
Local cSubject	  := ""
Local cBody		  := ""
Local cCodgHtml   := ""          
Local cAttachment := ""
Local _cMailError := ""
Local lConnect    := .F.
Local lEnviou     := .F.
Local lRet        := .T.         

cSubject := "Novo Grupo de Produto Cadastrado. Origem: Empresa "+cEmpAnt

cSubject := cSubject+" - "+DtoC(dDataBase)

cBody := fGerHtO(cCodGrp)
	
If ! Empty(cServer) .And. ! Empty(cAccount) .And. ! Empty(cTo)

   //Realiza conexao com o Servidor
   CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lConnect

   // Se existe autenticacao para envio valida pela funcao MAILAUTH
   lRet := Mailauth(cAccount,cPassword) 
      
   If lConnect //Se conseguiu Conexao ao Servidor SMTP
      SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody RESULT lEnviou ATTACHMENT cAttachment      

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

@since		19.03.2014
@version	P11 R5
@param		Nenhum
@return		Nenhum

@Obs:

---------------------------------------------------------------------
Programador		Data		Motivo
---------------------------------------------------------------------
/*/
Static Function fGerHtO(cCodGrp)

Local cCodgHtml := ""

cCodgHtml := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"> '
cCodgHtml += '<html>'
cCodgHtml += '<head>   '
cCodgHtml += '	<title>Novo Grupo de Produto Cadastrado - Empresa Origem: '+cEmpAnt+'</title>  '
cCodgHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">  '
cCodgHtml += '</head>'
cCodgHtml += '<body>'
cCodgHtml += '<div style="text-align: center;"> '
cCodgHtml += '	<div style="text-align: center;">'
cCodgHtml += '	<font face="Verdana">&nbsp;<span style="font-weight: bold;">  '
cCodgHtml += '	<span style="text-decoration: underline;">Novo Grupo de Produto Cadastrado - Empresa Origem: '+cEmpAnt+'</span></span></font></div> '
cCodgHtml += '</div>  
cCodgHtml += '<p><font face="Arial"><b><font size="2">Prezado(a), </font></b></font></p>'
cCodgHtml += '<p><font face="Arial"><b><font size="2">Um novo grupo de produto ('+AllTrim(cCodGrp)+') foi cadastrado. Origem do cadastro: Empresa '+cEmpAnt+'.'
cCodgHtml += ' Favor verificar. </font></b></font></p>'
		
cCodgHtml += '<p><font face="Arial" size="1"><span style="font-weight: bold;">E-mail Automático, favor não responder.</span></font></p>'
cCodgHtml += '<p><span style="color: rgb(255, 0, 0); font-family: Arial;"><span style="font-weight: bold;">'
cCodgHtml += '<font size="1">Dúvidas, favor entrar em contato com o setor responsável.</font></span></span></p>'
cCodgHtml += '</body>'
cCodgHtml += '</html>'

Return(cCodgHtml)