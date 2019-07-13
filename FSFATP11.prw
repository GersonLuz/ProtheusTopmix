#Include "Totvs.ch"
#Include "Fileio.ch"
#Include "rwmake.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFATP11
Processo de alteração do XML
     
@since 	26/03/2013
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
19/06/2013 Roney Oliveira  Finalizar desenvolvimento do Programa.
                           Programa com versao de 18/06/2013 nao gerava arquivo xml.
                           Arquivo \system\gissconfig.tpx contem a estrutura para 
                           substituicao de valores referente ao Cliente da Remessa.
                           NAO PODEM EXISTIR LINHAS EM BRANCO A PARTIR DO ULTIMO REGISTRO.
                           O ULTIMO REGISTRO TEM QUE SER A ULTIMA LINHA DO ARQUIVO.
/*/ 
//------------------------------------------------------------------ 
User Function FSFATP11()
Local		cNewFile		:= ""
Local		cArquivo 	:= ""
Local		hArquivo		:= -1
Local		cString		:= ""
Local		aXml		:= {}
Local		nXi 			:= 1	
Local		aTags		:= FGetTagChg()

cArquivo := cGetFile("Arquivos XML|*.XML","Abrir Arquivo XML para Adequação",1,,.T.)

If !Empty(cArquivo) .And. File(cArquivo) .And. !Empty(aTags)

	//Realizo o processamento do arquivo
	MsgRun("Realizando a leitura do Arquivo...","Top Mix", {|| aXml := FProcess(cArquivo, aTags) })
	
	cNewFile	:= cGetFile("Arquivos XML|*.XML","Informe o Diretório para o novo XML",,,.F.)
	
	If !Empty(cNewFile)
		If(!".xml"$cNewFile)
			cNewFile += ".xml"
		EndIf
		
		If(File ( cNewFile ) )
			If(MessageBox("O arquivo já existe, deseja substituí-lo?","",4)==6)
				FErase ( cNewFile ) 
				hArquivo := FCreate (cNewFile,FC_NORMAL)	
			EndIf
		Else
			hArquivo := FCreate (cNewFile,FC_NORMAL)	
		EndIf
		 
		For nXi := 1 To Len(aXml)
			FWrite( hArquivo, aXml[nXi] )
		Next
		
		FClose( hArquivo )
		
		If Len(aXml) > 0
			MsgBox("Arquivo Gerado com sucesso", "Top Mix", "INFO")
		Else
			MsgBox("Arquivo Gerado vazio", "Top Mix", "ALERT")
		EndIf
	EndIf	
EndIf

Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FProcess
Realiza o processamento do arquivo xml gerado pelo TOTVS
     
@since 	26/03/2013
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo        
/*/ 
//------------------------------------------------------------------ 
Static Function FProcess( cArquivo, aTags )
Local		cString	:= ""
Local		aXml		:= {}
Local		cDia  	:= ""
Local		cMes		:= ""
Local		cAno		:= ""
Local		cNota		:= ""
Local		cObra		:= ""
Local		cDtaNfe	:= ""
Local		cLine		:= ""
Local		cTagName	:= ""
Local		cTagValue:= ""
Local		nPosTag	:= 0
Local		xValue	:= ""
Local		nHandle	:= 0
Local		cCommand	:= ""

nHandle	:=  FT_FUse( cArquivo )

If nHandle == -1
	 MsgStop("Erro de abertura : FERROR "+Str(ferror(),4))
Else
	// C5_FILIAL+DTOS(C5_EMISSAO)+C5_NOTA+C5_SERIE
	SC5->(dbOrderNickName("TPSC500001"))
		
	// Seto o topo do arquivo
	FT_FGoTop()

	While !FT_FEof()
		If AllTrim(cTagName) == "NFS"
			cDia		:= ""
			cMes		:= ""                                   
			cAno		:= ""
			cNota		:= ""
			cObra		:= ""
			cDtaNfe	:= ""
		EndIf
						
		cLine			:=	FT_FReadLn()
		cTagName		:= FGetTagNam( cLine )
		cTagValue	:=	FGetTagVal( cLine )
		
		If Empty(cTagValue)     
         //Nao e TAG do arquivo GISSCONFIG.tpx, entao adiciona a linha 
			AAdd(aXml, cLine + CHR(13) + CHR(10))			
			FT_FSkip()
			Loop		
		EndIf
		
		// Monto a data da nota para realizar a pesquisa
		FGetDatNfs( @cDia, @cMes, @cAno, @cDtaNfe, cTagName, cTagValue )
		
		// Pego as informações na Nota
		FGetInfNfs( @cNota, @cObra, cTagName, cTagValue )
		
		// Verifico se tenho que sobrepor os valores da tag
		// de acordo com aTags
		nPosTag := aScan(aTags, {|x| AllTrim(x[1]) == AllTrim(cTagName)})
		
		If nPosTag > 0
			If "xValue" $ aTags[nPosTag][2]
				cTagValue := "'"+cTagValue+"'"
				cCommand	:= StrTran(aTags[nPosTag][2], "xValue", cTagValue)
				FExecBloco(cCommand, @cLine, @aXml)
			Else
				cNota := AvKey(cNota, "C5_NOTA")
				cObra	:= AvKey(cObra, "C5_OBRA")
				If SC5->(dbSeek(xFilial("SC5")+cDtaNfe+cNota))				
					If SC5->C5_ZTIPO == "1" 
						SA1->(dbSetOrder(01))
						If SA1->(dbSeek(xFilial("SA1")+SC5->C5_CLIOBRA+SC5->C5_LOJOBRA)) 
							 FExecBloco(aTags[nPosTag][2], @cLine, @aXml)								
						EndIf
					EndIf
				EndIf				
			EndIf
		Else //Nao e TAG do arquivo GISSCONFIG.tpx, entao adiciona a linha
			AAdd(aXml, cLine + CHR(13) + CHR(10))	
		EndIf
		
		FT_FSkip()
	EndDo

	FT_FUse()
	
	nPosTag := aScan(aTags, {|x| AllTrim(x[1]) == "NF_ABATIMENTOS_FIM" })
	If nPosTag > 0
		FExecBloco(aTags[nPosTag][2], @cLine, @aXml)			
	EndIf	
	
EndIf

Return aXml

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetTagNam
Retorna o nome da tag da linha
     
@since 	26/03/2013
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FGetTagNam( cLine )
Local		nPosIni	:= 0
Local		nQtdCarc	:= 0
Local		cTagName	:= ""

cLine		:= AllTrim(cLine)

nPosIni 	:= At( "<", cLine ) + 1
nQtdCarc := At( ">", cLine ) - nPosIni
cTagName	:= SubStr(cLine, nPosIni, nQtdCarc)

Return cTagName

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetTagVal
Get no conteudo da Tag
     
@since 	26/03/2013
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------            
Static Function FGetTagVal( cLine )
Local		nPosIni		:= 0
Local		nQtdCarc		:= 0
Local		cTagValue	:= ""

cLine		:= AllTrim(cLine)

nPosIni 	:= At( ">", cLine ) + 1
nQtdCarc := At( "</", cLine ) - nPosIni
cTagValue:= SubStr(cLine, nPosIni, nQtdCarc)

Return cTagValue

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSetTagVal
Set no conteudo da Tag
     
@since 	26/03/2013
@version P11
@param	cLine		Linha contendo a tag passado por referência
@param	cValue	
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------            
Static Function FSetTagVal( cLine, cValue )
Local		nPosIni		:= 0
Local		nQtdCarc		:= 0
Local		cLineAlt		:= ""

nPosIni 	:= At( ">", cLine ) + 1
nQtdCarc := At( "</", cLine ) - nPosIni

cLineAlt	+= SubStr(cLine, 1, nPosIni - 1)
cLineAlt	+= AllTrim(cValue)
cLineAlt	+= SubStr(cLine, nPosIni + nQtdCarc )

cLine := cLineAlt

Return Nil


//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetDatNfs
Set no conteudo da Tag
     
@since 	26/03/2013
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------            
Static Function FGetDatNfs( cDia, cMes, cAno, cData, cTagName, cTagValue )
Do Case			
	Case	cTagName == "NR_DIA_NF"
		cDia	:= AllTrim(cTagValue)
	Case	cTagName == "NR_MES_NF"
		cMes	:= AllTrim(cTagValue)
	Case	cTagName == "NR_ANO_NF"
		cAno	:= AllTrim(cTagValue)
EndCase

If !Empty(cDia) .And. !Empty(cMes) .And. !Empty(cAno)
	cData := cAno + cMes + cDia
EndIf

Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetInfNfs
Get nas infomações da obra
     
@since 	26/03/2013
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------            
Static Function FGetInfNfs( cNota, cObra, cTagName, cTagValue )
Do Case			
	Case	cTagName == "NR_DOC_NF"
		cNota	:= cTagValue
	Case	cTagName == "ID_OBRA"
		cObra	:= cTagValue
EndCase
Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetTagChg
Get nas tags que vão ter seu valores substituidos
     
@since 	26/03/2013
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------            
Static Function FGetTagChg()
Local		aReturn	:= {}
Local		aTags		:= FReadConf()

For nXi := 1 To Len(aTags)
	AAdd(aReturn, StrTokArr(AllTrim(aTags[nXi]),";"))
Next

Return AClone(aReturn)


//------------------------------------------------------------------- 
/*/{Protheus.doc} FReadConf
Busca as informações
     
@since 	26/03/2013
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------            
Static Function FReadConf()
Local		aTags		:= {}
Local		cArquivo	:= "/System/gissconfig.tpx"
Local		cLine		:= ""
Local		nHandle	:= -1

nHandle	:=  FT_FUse( cArquivo )

If nHandle == -1
	 MsgStop("Erro de abertura : FERROR "+Str(ferror(),4))
Else
	// Seto o topo do arquivo
	FT_FGoTop()
	While !FT_FEof()
		cLine	:= AllTrim(FT_FReadLn())
		AAdd(aTags, cLine)
		FT_FSkip()
	EndDo
	
	FT_FUse()
EndIf

Return aTags

//------------------------------------------------------------------- 
/*/{Protheus.doc} FExecBloco
Inclui informações dentro do array xml
     
@since 	26/03/2013
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------                                   
//Static Function FExecBloco(cCommand, aXml)
Static Function FExecBloco(cCommand, cLine, aXml)
Local		cBlock	:= "" 
Local   cValRet   := ""  
Default cCommand	:= ""   
Default cLine		:= "" 
Default 	aXml		:= {}

cBlock :="{|| "
cBlock += cCommand
cBlock += " }"			    
cValRet := EVal(&(cBlock))  

If UPPER(AllTrim(cValRet)) == "ISENTO" 
	cValRet := ""
EndIf      
                     
//Altera o valor na TAG
FSetTagVal( @cLine, cValRet )
AAdd(aXml, cLine + CHR(13) + CHR(10))	

Return Nil
