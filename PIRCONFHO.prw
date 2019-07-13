#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

User Function PIRCONFHO()

	Local cCaminho	:= ''
	Local cNomArq 	:= ''
	Local cCamArqTxt:= ''
    
    /*Diretorio para escolher arquivo*/
	cCaminho  := cGetFile("*.RET",OemToAnsi("Abrir Arquivo..."))

	If UPPER(Right(cCaminho,3)) != "RET"
		MsgAlert("Erro!!! Selecione uma arquivo de importação do tipo RET.")
		Return()
	Else
		Processa({||FReadArq(cCaminho)})
	EndIf

Return(Nil)

Static Function FReadArq(cCamArqTxt)

	Local oReport		:= Nil
	Local cLinha		:= ''
	Local aArrayInf	:= {}
	Local nLidos		:= 1
	Local nQuant		:= 0
	Local cCodMsgE		:= ''
	Local cMesEmpr		:= ''
	Local cCodMsgF		:= ''

	ft_fuse(cCamArqTxt)	
	
	nQuant:= FT_FLASTREC()   
	
	ProcRegua(nQuant)//QTOS REGISTROS LER
	
	Do While !ft_feof()
		
		IncProc('Aguarde...Processando Registros. ' + ltrim(Str(nLidos)) + "  de " + Alltrim(Str(nQuant)))
		
		cLinha:= ft_freadln()
		
		If Left(cLinha,1) == '0'//Informação referente a geraçaõ do arquivo
			cCodMsgE:= SubStr(cLinha,234,3)
			cMesgEmp:= FBusMsg(cCodMsgE)			
			cMesEmpr:= 'REMESSA HPAG - MENSAGEM DE RETORNO [ '+ cMesgEmp + ' ]'
		ElseIf Left(cLinha,1) == '1'// Informaçoes do funcionario
			aDadFunc:= FDadosFunc(SubStr(cLinha,44,11))
			cCodMsgF:= FBusMsg(SubStr(cLinha,237,3)) 
			If !Empty(aDadFunc)
				AAdd(aArrayInf,{aDadFunc[1][1],aDadFunc[1][2],aDadFunc[1][3], cCodMsgF})
			EndIf
		EndIf
		aDadFunc:={}
		cCodMsgF:=''
		ft_fskip()
		cLinha:= ''
		nLidos++	
		aDadFunc:={}
	EndDo
	
	ft_fuse()
	//--Geração do relatorio
	oReport:= FExeQuery(aArrayInf,oReport, cMesgEmp)
	oReport:PrintDialog()
			
Return(Nil)   

Static Function FExeQuery(aArrayInf, oReport, cMesgEmp)
	
	Local oSection1	:= Nil
	Local oSection2	:= Nil
	Local oReport		:= NIl
		
	oReport:=TReport():New(FunName(),OemToAnsi("RELATORIO CONFERENCIA HOLERITE"),,{|oReport| FSImpr(aArrayInf, oReport, cMesgEmp)},OemToAnsi("RELATORIO CONFERENCIA HOLERITE"))
	oReport:HideParamPage() //Não mostrar parametros
	oReport:HideHeader(.T.)	//Não mostrar cabeçalho
	oReport:HideFooter(.T.)	//Não mostrar rodapé
	oReport:nDevice:= 4  // Impressão Planilha Default
	
	oSection1 := TRSection():New(oReport,OemToAnsi("RELATORIO CONFERENCIA HOLERITE"),{},,,,,,,.F.,.F.,.F.,,.F.)
	TRCell():New(oSection1,OemToAnsi("FILIAL"		  ),,,,TamSx3("RA_FILIAL")[1],,,"CENTER",,"CENTER",,,,,,.T.)
	TRCell():New(oSection1,OemToAnsi("CPF"	  		  ),,,,TamSx3("RA_CIC")[1],,,,,"CENTER",,,,,,.T.)
	TRCell():New(oSection1,OemToAnsi("NOME"	  	  ),,,,TamSx3("RA_NOME")[1],,,,,"CENTER",,,,,,.T.)
	TRCell():New(oSection1,OemToAnsi("MENSAGEM"	  ),,,,TamSx3("EB_DESCRI")[1],,,,,"CENTER",,,,,,.T.)
	oSection1:lHeaderSection := .T.
	
	oSection2 := TRSection():New(oReport,OemToAnsi("RELATORIO CONFERENCIA HOLERITE"),{},,,,,,,.F.,.F.,.F.,,.F.)
	TRCell():New(oSection2,OemToAnsi("MENSAGEM_EMPRESA"	  ),,,,TamSx3("EB_DESCRI")[1],,,,,"CENTER",,,,,,.T.)
	oSection2:lHeaderSection := .T.
	
Return(oReport)

Static Function FSImpr(aArrayInf, oReport, cMesgEmp)

	Local oSec1 := oReport:Section(1)
	Local oSec2 := oReport:Section(2)
	Local xI	:= 1   
	
	oSec2:Init()
	oSec2:Cell(1):SetBlock({|| cMesgEmp })	
	//oSec2:Cell(OemToAnsi('MENSAGEM_EMPRESA')):SetTitle(cMesgEmp)	 
	oSec2:PrintLine(,,.T.)
	oSec2:Finish()
	
	oSec1:Init()		
	For xI := 1 To Len(aArrayInf)
		If oReport:Cancel()
			Exit
		EndIf		
		oSec1:Cell(1):SetBlock({|| aArrayInf[xI][1]})
		oSec1:Cell(2):SetBlock({|| aArrayInf[xI][2]})
		oSec1:Cell(3):SetBlock({|| aArrayInf[xI][3]})
		oSec1:Cell(4):SetBlock({|| aArrayInf[xI][4]})			
		oSec1:PrintLine(,,.T.)
	Next xI
	//--Fecha Objeto
	oSec1:Finish()
	
Return(Nil)	

Static Function FBusMsg(cCodMsgE) 

	Local cMesg			:= ''
	Local cBancoAux	:= '237'
	Local cQuery		:= ''
	Local cAlias		:= GetNextAlias()
	
	cQuery+=Chr(13)+Chr(10)+" SELECT EB_DESCRI AS MSG "
	cQuery+=Chr(13)+Chr(10)+" FROM "+RetSqlName('SEB')+"  "
	cQuery+=Chr(13)+Chr(10)+" WHERE EB_FILIAL = '0101' "
	cQuery+=Chr(13)+Chr(10)+" AND EB_BANCO = '"+cBancoAux+"' "
	cQuery+=Chr(13)+Chr(10)+" AND EB_REFBAN = '"+AllTrim(cCodMsgE)+"' "
	cQuery+=Chr(13)+Chr(10)+" AND D_E_L_E_T_ <> '*' "
	
	//--Cria uma tabela temporária com as informações da query						
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
	
	(cAlias)->(DbGoTop())
	//--Retorna Codigo
	cMesg:=(cAlias)->MSG
	//--Fecha tabela temporaria
	(cAlias)->(DbCloseArea())
	
Return(cMesg)	

Static Function FDadosFunc(cCocCIC)

	Local cQuery		:= ''
	Local cAliasSRA	:= GetNextAlias()
	Local aInf			:= {}
	
	cQuery+=Chr(13)+Chr(10)+" SELECT RA_FILIAL AS FILIAL, RA_CIC AS CPF, RA_NOME AS NOME "
	cQuery+=Chr(13)+Chr(10)+" FROM "+RetSqlName('SRA')+"  "
	cQuery+=Chr(13)+Chr(10)+" WHERE RA_CIC = '"+cCocCIC+"' "
	cQuery+=Chr(13)+Chr(10)+" AND D_E_L_E_T_ <> '*' "
	
	//--Cria uma tabela temporária com as informações da query						
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRA,.F.,.T.)
	
	(cAliasSRA)->(DbGoTop())
	(cAliasSRA)->(dbEval({|| AADD(aInf,{ (cAliasSRA)->FILIAL, (cAliasSRA)->CPF, (cAliasSRA)->NOME })}))
	//--Fecha tabela temporaria
	(cAliasSRA)->(DbCloseArea())

Return(aInf)