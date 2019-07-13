#Include "Protheus.ch"
#Include "Rwmake.ch"
#INCLUDE "TBICONN.CH"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSIMPC03
Função para Importar Aplicações entre Empresas (Top Mix e Flapa)
          
@author 	.iNi Sistemas
@since 		07/08/2014
@version 	P11.5
@obs  
Projeto 	2014002TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------         
User Function FSIMPC03()                                     

Local cCodApl	:= AllTrim(M->P09_CODAPL)
Local lcodApli := .F.

If lcodApli := U_FSXVlApE(cCodApl) //-- Valida se grupo de produto existe nas empresas que serão replicadas
	FSIncApl() //-- Realizar importação de grupo de produto para as demais empresas
	fSendMail(AllTrim(M->P09_CODAPL)) //-- Envia e-mail
EndIf

Return(lcodApli)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSXVlApE
Função para validar se aplicação existe nas outras empresas
          
@author 	.iNi Sistemas
@since 		07/08/2014
@version 	P11.5
@obs  
Projeto 	2014002TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------  
User Function FSXVlApE(cCodApl)

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
		
		cQryPrd += Chr(13) + "SELECT '"+cEmpAux+"' AS P09_EMP, P09.P09_FILIAL, P09.P09_CODAPL "
		cQryPrd += Chr(13) + "FROM P09"+cEmpAux+"0 P09 "
		cQryPrd += Chr(13) + "WHERE P09.D_E_L_E_T_ <> '*' "
		cQryPrd += Chr(13) + "AND P09.P09_CODAPL = '"+cCodApl+"' "
	
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
		Alert("Encontrado aplicação cadastrada com o mesmo código para outra empresa! Entre em contato com o Administrador.")
	EndIf 
	
	QSBMVL->(dbCloseArea())
EndIf

Return(lRetVld)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSIncApl
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
Static Function FSIncApl()

Local cQryPrd		:= ""
Local cEmpAux		:= ""
Local nRecNewP09	:= 0
Local cDirLay		:= GetMv("FS_NMDIRLAY",,"\Layouts\Integração")
Local cArqLay 		:= cDirLay+"\FSIMPC03.LAY"
Local aArrLay		:= {}
Local cEmpres	:= GetMv("FS_EMPIMPP",,"01,02") //-- Empresas que terão integração.
Local aArrEmp	:= StrTokArr(cEmpres,",") 
                       
If FSCarLay(cArqLay, aArrLay) //-- Carrega arquivo de Layout

	For nXi := 1 To Len(aArrEmp)
	
		If aArrEmp[nXi] <> (cEmpAnt) 
		
			cEmpAux := AllTrim(aArrEmp[nXi])
		
			nRecNewP09 := FSRecPrd(cEmpAux)
	
			If nRecNewP09 > 0
		
				cQuery1 := "INSERT INTO P09"+cEmpAux+"0 ("
				
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
	     		  		cQuery1 += Eval(&(aArrLay[nXT][2]), &("M->"+aArrLay[nXT][1]))+","
	     		  	ElseIf ValType(&("M->"+aArrLay[nXT][1])) == "N"
						cQuery1 += AllTrim(Str(&("M->"+aArrLay[nXT][1])))+","
		    		ElseIf ValType(&("M->"+aArrLay[nXT][1])) == "D"
						cQuery1 += "'"+DToS(&("M->"+aArrLay[nXT][1]))+"',"
		       		Else
						cQuery1 += "'"+&("M->"+aArrLay[nXT][1])+"',"
					EndIf
				Next nXT
	            
	            //-- Ultima posição é o RECNO
				cQuery1 += AllTrim(Str(nRecNewP09))+","
				
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

cQryPrd += Chr(13) + "SELECT MAX(R_E_C_N_O_) + 1 AS P09_RECNO"
cQryPrd += Chr(13) + "FROM P09"+cEmpAux+"0 P09 "

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
		If QBMREC->P09_RECNO > 0
			nRetVld := QBMREC->P09_RECNO
		EndIf
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
Static Function fSendMail(cCodApl)

Local cServer     := AllTrim(GetMv("MV_RELSERV"))
Local cAccount    := AllTrim(GetMv("MV_RELACNT"))
Local cPassword   := AllTrim(GetMv("MV_RELPSW"))
Local cFrom       := AllTrim(GetMv("MV_RELFROM"))
Local cTo		  := AllTrim(GETMV("FS_EMINCAP",,"jean.santos@topmix.com.br"))
Local cSubject	  := ""
Local cBody		  := ""
Local cCodgHtml   := ""          
Local cAttachment := ""
Local _cMailError := ""
Local lConnect    := .F.
Local lEnviou     := .F.
Local lRet        := .T.         

cSubject := "Nova Aplicação Cadastrada. Origem: Empresa "+cEmpAnt

cSubject := cSubject+" - "+DtoC(dDataBase)

cBody := fGerHtO(cCodApl)
	
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
Static Function fGerHtO(cCodApl)

Local cCodgHtml := ""

cCodgHtml := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"> '
cCodgHtml += '<html>'
cCodgHtml += '<head>   '
cCodgHtml += '	<title>Nova Aplicação Cadastrada - Empresa Origem: '+cEmpAnt+'</title>  '
cCodgHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">  '
cCodgHtml += '</head>'
cCodgHtml += '<body>'
cCodgHtml += '<div style="text-align: center;"> '
cCodgHtml += '	<div style="text-align: center;">'
cCodgHtml += '	<font face="Verdana">&nbsp;<span style="font-weight: bold;">  '
cCodgHtml += '	<span style="text-decoration: underline;">Nova Aplicação Cadastrada - Empresa Origem: '+cEmpAnt+'</span></span></font></div> '
cCodgHtml += '</div>  
cCodgHtml += '<p><font face="Arial"><b><font size="2">Prezado(a), </font></b></font></p>'
cCodgHtml += '<p><font face="Arial"><b><font size="2">Uma nova aplicação ('+AllTrim(cCodApl)+') foi cadastrada. Origem do cadastro: Empresa '+cEmpAnt+'.'
cCodgHtml += ' Favor verificar. </font></b></font></p>'
		
cCodgHtml += '<p><font face="Arial" size="1"><span style="font-weight: bold;">E-mail Automático, favor não responder.</span></font></p>'
cCodgHtml += '<p><span style="color: rgb(255, 0, 0); font-family: Arial;"><span style="font-weight: bold;">'
cCodgHtml += '<font size="1">Dúvidas, favor entrar em contato com o setor responsável.</font></span></span></p>'
cCodgHtml += '</body>'
cCodgHtml += '</html>'

Return(cCodgHtml)