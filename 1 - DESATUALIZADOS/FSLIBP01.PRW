#INCLUDE "protheus.ch" 
#INCLUDE "fileio.ch"
#INCLUDE "tbiconn.ch"

/*
PRW Destinado para pequenas funcões de uso genérico
Funcoes Inclusas:
-FSConVal   : Converte os valores do arquivo *.csv de acordo com o tipo do SX3 do arquivo aberto
-FSValFil   : Valida se a filial exite na tabela SM0         
-FSgetAllEmp: Retorna a lista de filiais para cada empresa.
-FDupWzp    : Verifica se existe duplicidade de arquivos selecionados nos campos do apwizard 
-FCloseArea : Fecha arquivo de trabalho aberto 
-FCalDat    : Montar a data inicial e final de um determinado mes 
-FSCriaBox  : Cria um box do TMS Printer
-FS2CriBox  : Versão mais nova Cria Box.
-FQrbTxt    : Quebra o texto contido em uma string
-FSValTel   : Mes que poderao ser informados para geracao do arquivo SIAF e SICOP
-FForQIn    : Funcao para formatar as condicoes no padrao da clausula IN do SQL
-FSWizIp2   : Tela padrão de importação (2º versao)
-FExistFile : Validacao do campo de importacao (1º versao))
-FExtFl2    : Validacao do campo de importacao (2º versao))
-FArrumTx   : Arruma Texto em arrey quebrando nos espacos em branco.
-FGerArq    : Gera o arquivo no formato xls e grava-lo no diretorio informado pelo usuario
-FDirArq    : Funcao para quebrar o diretorio informado no Wizard
-FStrFil    : Funcao que retorna uma string ou valida as filiais cadastradas para o usuário corrente.
*/
//-------------------------------------------------------------------       
User Function FSConVal(cCampo,cValor,cTipo)

Local xValCon := ""
Local aCfgCpo := TamSX3(cCampo)                                          

If(Empty(aCfgCpo))
	aCfgCpo:= {Nil,Nil,cTipo }
EndIf

Do Case
	//Converte para Numerico
	Case (aCfgCpo[3] == "N")
		xValCon := Val(cValor)
	//Converte para Data
   Case (aCfgCpo[3] == "D")
      xValCon := SToD(cValor) 
   Otherwise
   	xValCon := cValor
EndCase	

Return (xValCon)


//-------------------------------------------------------------------       
User Function FSValFil(cFilPos)

Local lRetFun := .T.
Local aAreas  := {SM0->(GetArea()),GetArea()}

SM0->(dbSetOrder(1))
If (SM0->(dbSeek(cEmpAnt+cFilPos))) 
	lRetFun := .T.
Else
	lRetFun := .F.
EndIf

//Restaura a area padrao da SM0
AEval(aAreas,{|x| restArea(x)})

Return (lRetFun)


                                                                   
//__________________________________________________________________________________________________________________________      
//Wizard de Importação. 2º versao
User Function FSWizIp2(nTipWzd,cFunImp,cRotina,cTitWin,cDescr,nQtdArq,cExtArq,cDesArq,cFunPer,cPerWzd) 
						
Local cLog			:= ""
Local cDesc2		:= ""   
Local nReg			:= 0
Local oReg			:= Nil //Objeto da barra de progresso
Local oWizard		:= Nil //Objeto do Wizard
Local oParFile	:= Nil  
Local cGetFile 	:= ""
local oBtnPar		:= Nil
Local aLogs		:= {}
Local nX			:= 0
Local aFile		:= {}
Local aObj			:= {}
Local aDadWzd		:= {}
Local lCmpEsp		:= .F.

Default nTipWzd 	:= 1
Default cRotina 	:= ""     
Default nQtdArq 	:= 1 
Default cExtArq 	:= "CSV |*.csv| "
Default cDesArq 	:= "Arquivos Csv"

aFile := Array(nQtdArq)
aObj := Array(nQtdArq,3)

AFill(aFile,Space(255) )
	
//Garantindo que somente 1 pessoa estará executando a Importação
If(MayIUseCode(cEmpAnt + cRotina))          

	//Inicializando o wizard com o primeiro painel
	oWizard := apwizard():New( cTitWin , "" ,Iif(nTipWzd==1,"Importação","Exportação") ,"", {|| FExtFl2(aFile,.T.,nTipWzd,@aDadWzd) }  ,  ,.T. , "atfimg32" , , .f. , {0,0,350,650} ) 
	@ 05, 15 SAY oSay1 VAR cDescr OF oWizard:oMPanel[1] PIXEL		
	@ 15, 15 SAY oSay2 VAR "Selecione o arquivo para a "+Iif(nTipWzd==1,"Importação","Exportação") OF oWizard:oMPanel[1] PIXEL
   
	@ 20 + 1 * 20, 15 SAY 		aObj[1][1] 	VAR "Arquivo" OF oWizard:oMPanel[1] PIXEL
	@ 20 + 1 * 20, 40 MSGET 	aObj[1][2]  VAR aFile[1]  SIZE 110, 010 OF oWizard:oMPanel[1] valid(FExistFile(aFile[1] ,.F.) .or. Empty( aFile[1]  ) )  PIXEL    
 	@ 20 + 1 * 20, 155 BUTTON	aObj[1][3]  PROMPT "&Buscar" SIZE 037, 012 OF oWizard:oMPanel[1]  ACTION {|| ;
	aFile[1]  := PadR(cGetFile( cExtArq , cDesArq, 1, 'C:\', Iif(nTipWzd == 1,.T.,.F.), GETF_LOCALHARD,.T., .T. ),255),FDupWzp(aFile) } PIXEL
	
	If(nQtdArq >= 2)
		@ 20 + 2 * 20, 15 SAY 		aObj[2][1] VAR "Arquivo" OF oWizard:oMPanel[1] PIXEL
		@ 20 + 2 * 20, 40 MSGET 	aObj[2][2] VAR aFile[2]  SIZE 110, 010 OF oWizard:oMPanel[1] valid(FExistFile(aFile[2] ,.F.) .or. Empty( aFile[2]  ) )  PIXEL    
		@ 20 + 2 * 20, 155 BUTTON	aObj[2][3] PROMPT "&Buscar" SIZE 037, 012 OF oWizard:oMPanel[1]  ACTION {|| ;
		aFile[2]  := PadR(cGetFile( cExtArq , cDesArq, 1, 'C:\', Iif(nTipWzp == 1,.T.,.F.), GETF_LOCALHARD,.T., .T. ),255),FDupWzp(aFile) } PIXEL
	EndIf
 	
 	If(nQtdArq >= 3)
		@ 20 + 3 * 20, 15 SAY 		aObj[3][1] VAR "Arquivo" OF oWizard:oMPanel[1] PIXEL
		@ 20 + 3 * 20, 40 MSGET 	aObj[3][2] VAR aFile[3]  SIZE 110, 010 OF oWizard:oMPanel[1] valid(FExistFile(aFile[3] ,.F.) .or. Empty( aFile[3]  ) )  PIXEL    
		@ 20 + 3 * 20, 155 BUTTON	aObj[3][3] PROMPT "&Buscar" SIZE 037, 012 OF oWizard:oMPanel[1]  ACTION {|| ;
		aFile[3]  := PadR(cGetFile( cExtArq , cDesArq, 1, 'C:\', Iif(nTipWzp == 1,.T.,.F.), GETF_LOCALHARD,.T., .T. ),255,FDupWzp(aFile) ) } PIXEL
	EndIf
	
	If !(Empty(cFunPer) .And. !Empty(cPerWzd))
		@ 95, 280 BUTTON oBtnPar PROMPT "&Parâmetros" SIZE 037, 012 OF oWizard:oMPanel[1]  ACTION {||  ExecBlock(cFunPer,.F.,.F., {cPerWzd} ) } PIXEL
	EndIf
	
	//Segundo  Painel: Confirmar
	oPanel := oWizard:NewPanel ("Confirmar "+Iif(nTipWzd==1,"Importação","Exportação") , "" , {|| .t.} ,{|| .t. }   ,   , .t.  ) 
	@ 05, 15 SAY oSay4 VAR "O Wizard já coletou todas as informações necessárias e executará as etapas da "+Iif(nTipWzd==1,"Importação","Exportação")+" " OF oWizard:oMPanel[2] PIXEL
	@ 15, 15 SAY oSay5 VAR "Pressione Avançar para continuar" OF oWizard:oMPanel[2] PIXEL

	//Terceiro Painel: Importação e status
	oPanel := oWizard:NewPanel ("Processando Solicitação" ,"" , {||, .F.} ,{|| .t. }   , {|| .t. }  , .t. ,{||  oWizard:DisableButtons(),aLogs := ExecBlock(cFunImp,.F.,.F., {oWizard,oReg,aFile,aDadWzd} ), cLog := FGerLog(aLogs,lCmpEsp) , oWizard:SetPanel(4), oWizard:EnableButtons()  } ) 
	@ 30, 10 SAY oSay6 VAR "Progresso Total " OF oWizard:oMPanel[3] PIXEL
	oReg := TMeter():New(45,10,{|u|if(Pcount()>0,nMeter1:=u,nReg)},100,oWizard:oMPanel[3],200,16,,.T.)

    //Quarto  Painel: Termino da Importação e Log Final
	oPanel := oWizard:NewPanel (Iif(nTipWzd==1,"Importação","Exportação") ,"" , {||  .F.} ,{|| .t. }   ,   , .t.  ) 
	@ 01, 01 GET oMemo  VAR cLog MEMO SIZE 325,90 OF  oWizard:oMPanel[4] PIXEL
  	@ 95, 280 BUTTON oBtnBuscar PROMPT "&SalvarLog" SIZE 037, 012 OF oWizard:oMPanel[4]  ACTION {|| cFile := cGetFile( 'Log |*.Log|' , 'Arquivos de Log', 1, 'C:\', .F., GETF_LOCALHARD,.T., .T. ), FSalvaLog(aLogs,cFile) } PIXEL
		
	oWizard:oDlg:lEscClose := .T.
	oWizard:Activate ( .t. ) 
Else 
	MsgAlert("Não foi possivel realizar a tarefa"+chr(13)+ "Outro usuário já está executando a rotina. " + chr(13) + "Tente novamente mais tarde")
EndIf

Leave1Code( cEmpAnt + cRotina )

Return Nil


//________________________________________________________________________________________________________________________________
Static Function FExistFile(aFile,lMensEmpty,nTipWzp,cGetMes,cGetAno,aDadWzd)
	Local lRet 		:= .T.
	Local nX 		:= 0 
	Local cFile 	:= "" 
	
	Default nTipWzp := 1
	Default cGetMes := ""
	Default cGetAno := ""
	Default aDadWzd := {}
	
	Do Case
		Case (nTipWzp == 1)	
				If(ValType(aFile) == "C") 
					aFile := {aFile}
				EndIF
				
				For nX := 1 to Len(aFile) 
					cFile := aFile[nX]
					If !File(cFile)
						lRet := .F.
						If(lMensEmpty .Or. !Empty(cFile))
							MsgStop('O arquivo ' + AllTrim(cFile) + " não foi encontrado. "  )
						EndIf
					EndIf 		
				Next
		Case (nTipWzp == 2)
			If (Empty(aFile[1]))
				MsgStop("informe o caminho para que o arquivo seja salvo" )
				lRet := .F.
			Else
				aDadWzd := {Iif(cGetMes == "00",1,2),cGetMes,cGetAno}  
			EndIf
	EndCase
	
Return lRet


//________________________________________________________________________________________________________________________________
Static Function FExtFl2(aFile,lMensEmpty,nTipWzp,cGetMes,cGetAno,aDadWzd)
	Local lRet 		:= .T.
	Local nX 		:= 0 
	Local cFile 	:= "" 
	
	Default nTipWzp := 1
	Default cGetMes := ""
	Default cGetAno := ""
	Default aDadWzd := {}
	
	SetPrvt("lTelPer")
	
	Do Case
		Case (nTipWzp == 1)	
				If(ValType(aFile) == "C") 
					aFile := {aFile}
				EndIF
				
				For nX := 1 to Len(aFile) 
					cFile := aFile[nX]
					If !File(cFile)
						lRet := .F.
						If(lMensEmpty .Or. !Empty(cFile))
							MsgStop('O arquivo ' + AllTrim(cFile) + " não foi encontrado. "  )
						EndIf
					EndIf 		
				Next
		Case (nTipWzp == 2)
			If (Empty(aFile[1]))
				MsgStop("Informe o caminho para que o arquivo seja salvo" )
				lRet := .F.
			EndIf
			If !(lTelPer)
				MsgStop("Informe os parâmetros da tela" )
				lRet := .F.
			EndIf
	EndCase
	
Return lRet

//________________________________________________________________________________________________________________________________
Static Function FSalvaLog(aLogs,cFile)

	Local nHandle := FCreate (cFile)  
	Local nX := 0
	Local cLin := ""

	For nX:= 1 to Len(aLogs)
		cLin := aLogs[nX] + chr(13) + chr(10)
		FWrite (nHandle,cLin )
	Next
	FClose(nHandle)
	
Return Nil                                                                                                                        

//________________________________________________________________________________________________________________________________
Static Function FGerLog(aLogs,lCmpEsp)
	Local nX := 0
	Local cLin := ""
   Default lCmpEsp := .F.
   
   If !(lCmpEsp)  
		For nX:= 1 to Len(aLogs)
			cLin += aLogs[nX] + chr(13) + chr(10)
			If(Len(cLin) >  50000)
				Exit
			EndIf
		Next
	Else
		cLin := aLogs[1][1]
	EndIf
Return cLin



//______________________________________________________________________________________________________________________________________             
/*/{Protheus.doc} getAllEmp
Busca todas as empresas cadastradas na SM0 - Cadastro de Empresas
@author  Waldir de Oliveira
@since   13/01/2011
@version 10.1.1.4
/*/
//______________________________________________________________________________________________________________________________________             
//Retorna a lista de filiais para cada empresa.
User Function FSgetAllEmp()

    Local aEmpresas := {}
    Local aAreas	:= {}
    
    If(Select("SM0") > 0)
	    aAreas := {SM0->(GetArea()), GetArea()}
	    SM0->(dbGoTop())
		While(SM0->(!Eof()))
			aAdd(aEmpresas,{SM0->M0_CODIGO, SM0->M0_CODFIL,SM0->M0_CGC})
			SM0->(dbSkip())			
		EndDo
    Else
	    aAreas := {GetArea()}
		dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. ) 
		If ( Select("SM0")>0 ) 
			dbSelectArea("SM0")
			//Ignora Registros Deletados ...
			Set Deleted On
			dbSetIndex("SIGAMAT.IND") 
		
			SM0->(dbGoTop())
			While(SM0->(!Eof()))
				aAdd(aEmpresas,{SM0->M0_CODIGO, SM0->M0_CODFIL,SM0->M0_CGC})
				SM0->(dbSkip())			
			EndDo
			
			SM0->(dbCloseArea())
		EndIf
    EndIf

	AEval(aAreas,{|x| RestArea(x)})
Return aEmpresas   
               

//________________________________________________________________________________________________________________________________
Static Function FDupWzp(aFile)

Local lRetFun 	:= .T.
Local nXI	  	:= 0
Local cFileAnt := ""

For nXI := 1 To Len(aFile)
	If (aFile[nXI] == cFileAnt )
		MsgStop("Não é possível selecionar arquivos contendo o mesmo nome.")
		lRetFun := .F.
		aFile[nXI] := ""
		Exit
	EndIf 
	cFileAnt := aFile[nXI]
Next nXI

Return (lRetFun)    
                       

//________________________________________________________________________________________________________________________________
User Function FCloseArea(cArqTrb) 
  
//Fecha o Arquivo de Trabalho 
If (Select(cArqTrb)!= 0)
	(cArqTrb)->(dbCloseArea())
EndIf  

Return Nil
  

//________________________________________________________________________________________________________________________________
User Function FCalDat(nFlag,cMesExt,cAno,cDtLast)  

Local dData 	:= ""
Local aArrMes 	:= {"Janeiro","Fevereiro","Marco","Abril","Maio","Junho",;
       				 "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"} 
Local cPosMes	:= 0

Default cDtLast := ""

If (nFlag == 1)
	cPosMes := Alltrim(StrZero(aScan(aArrMes,{|x|AllTrim(x) == AllTrim(cMesExt)}),2))
	cData := cAno+cPosMes+"01"
Else
	cData := DToS(LastDay(SToD(cDtLast)))
EndIf

Return (cData)      
       

//________________________________________________________________________________________________________________________________
User Function FSCriaBox(oPrint,oFont, nPerX,nPercLarg,nPercY,nPercAlt, cTexto,lCenterH,lCenterV,lShowBox)

Local nMargem := 100
Local nHorSize	:= oprint:NHORZRES() - nMargem * 2
Local nVertSize:= oprint:NVERTRES() - nMargem * 2
Local nRetY := 0 
Local nX :=	0   
Local aTxt := Separa(cTexto,chr(13))
Local nAltFont := 0           
Local nPosY := 0
Local nPosX := 0

Default lCenterH := .F.
Default lCenterV := .F.
Default lShowBox := .T.

nRetY := nPercY  + nPercAlt

//Passando os valores informados de percentual para coordenadas físicas
nPerX		:= nMargem + nPerX	* nHorSize / 100
nPercLarg:= nPercLarg * nHorSize / 100
nPercY	:=	nMargem + nPercY * nVertSize / 100
nPercAlt	:= nPercAlt * nVertSize / 100

If(lShowBox)
	oPrint:Box(nPercY,nPerX, nPercY + nPercAlt,nPerX + nPercLarg)
EndIf

If(!Empty(cTexto))

	nAltFont := oPrint:GetTextHeight(cTexto,oFont) + 2 
	
	For nX := 1 to Len(aTxt)  
	
		If(lCenterH)
			nPosX := nPerX + nPercLarg/2 - oPrint:GetTextWidth(aTxt[nX],oFont) / 2                                                             
		Else
			nPosX := nPerX + 20 //Dando uma distáncia da margem
		EndIf 
	
		If(lCenterV)
	      nPosY := nPercY +  nPercAlt/ 2  - oPrint:GetTextHeight(aTxt[nX],oFont)
 		Else                                                                       	
	 		nPosY := nPercY +  20//Dando uma distáncia da margem
		EndIf     
		oPrint:Say(nPosY + (nX - 1) * nAltFont ,nPosX,aTxt[nX] ,oFont,nPercLarg)
	Next
	
EndIf

Return nRetY    



//------------------------------------------------------------------- 
/*/{Protheus.doc} FS2CriBox
Realiza o desenho em relatórios TMSPrinter.


@author 	Fernando dos Santos Ferreira 
@since 	24/04/2012 
@version P11
@param	oPrint		Objeto de Impressão TMSPrinter,
@param	oFont			Fonte utilizada para impressão
@param 	nPerX			Posicão em percentuais da página no eixo X do início do quadro
@param 	nPercLarg	Largura do quadrado em percentuais da página
@param 	nPerY			Posicão em percentuais da página no eixo Y do início do quadro
@param 	nPercAlt		Altura do quadrado em percentuais da página
@param 	cTexto		Texto a Ser impresso
@param 	nAlignH		Alinhamento na horizontal. 1 = esquerda, 2 = centro, 3 = direita. Se Nil padrao = 1
@param 	nAlignV		Alinhamento na vertical. 1 = topo, 2 = centro, 3 = fundo. Se Nil padrao = 1
@param 	lShowBox		Vizualiza os retangulo. Sim ou não. Se não apenas posicionará o texto. Se Nil padrao = .T.
@param 	nMargem		Largura em pixels da margem da página, Se Nil Padrão = 100
@param 	nEspaco		Distância onde o texto irá ser impresso em relação a margem do retângulo. Se Nil padrao = 20
@param 	nColor		Cor a ser utilizada no preenchimento do Box.
@param 	cCabec		Texto do Cabeçalho do box.                           
@param 	oFntCab		Fonte utilizada na impressão do cabeçalho. Se Nil, arial tamanho 9
@obs  
 
@Return aCoords	 {	Percentual da página em Y onde terminou o retangulo
							Percentual da página em X onde terminou o retangulo
							Posicao em pontos de Y onde comecou o retangulo
							Posicao em pontos de X onde comecou o retangulo
							Posicao em pontos de Y onde Terminou o retangulo
							Posicao em pontos de X onde Terminou o retangulo }
							

Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------
User Function FS2CriBox(oPrint,oFont, nPerX,nPercLarg,nPercY,nPercAlt, cTexto,nAlignH,nAlignV,lShowBox,nMargem,nEspaco,nColor, cCabec, oFntCab)

Local PixelX := 300/oPrint:nLogPixelX()
Local PixelY := 300/oPrint:nLogPixelY()

Local nHorSize	:= oprint:NHORZRES() * PixelX  - nMargem * 2
Local nVertSize:= oprint:NVERTRES() * PixelY - nMargem * 2
Local nRetY := 0 
Local nRetX := 0 
Local nX :=	0   
Local aTxt := Separa(cTexto,chr(13))
Local nAltFont := 0           
Local nPosY := 0
Local nPosX := 0
Local oBrush:=Nil     

Local nNewPerX := nPerX
Local nNewPerY := nPercY          

Local nBegBoxX := 0
Local nBegBoxY := 0
Local nEndBoxX := 0
Local nEndBoxY := 0

Default nMargem := 100
Default nAlignH := 1
Default nAlignV := 1
Default lShowBox := .T.
Default nEspaco  := 10 
Default oFntCab  := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)

nRetY := nPercY  + nPercAlt
nRetX := nPerX   + nPercLarg

//Passando os valores informados de percentual para coordenadas físicas
nNewPerX	:= nMargem + nNewPerX	* nHorSize / 100
nPercLarg:= nPercLarg * nHorSize / 100
nNewPerY	:=	nMargem + nNewPerY * nVertSize / 100
nPercAlt	:= nPercAlt * nVertSize / 100

If(lShowBox)
	If(nColor != Nil )
		oBrush := TBrush():New( , nColor )
		oPrint:FillRect( {nNewPerY, nNewPerX, nNewPerY + nPercAlt, nNewPerX + nPercLarg}, oBrush )
   EndIf
	oPrint:Box(nNewPerY,nNewPerX, nNewPerY + nPercAlt,nNewPerX + nPercLarg)	
	nBegBoxX := nNewPerX
	nBegBoxY := nNewPerY
	nEndBoxX := nNewPerX + nPercLarg
	nEndBoxY := nNewPerY + nPercAlt

EndIf

If(!Empty(cCabec))                         
	oPrint:Say(nNewPerY+05,nNewPerX +15,cCabec ,oFntCab,100)
EndIf

If(!Empty(cTexto))

	nAltFont := oPrint:GetTextHeight("Aa",oFont) * PixelY + 2 

	For nX := 1 to Len(aTxt)  
		If(nAlignH == 3)                                                                                                                         		
			nPosX := nNewPerX + nPercLarg  -  oPrint:GetTextWidth(aTxt[nX],oFont) * PixelX - 10 * PixelX
		ElseIf(nAlignH == 2)
			nPosX := nNewPerX + nPercLarg/2 - oPrint:GetTextWidth(aTxt[nX],oFont) * PixelX / 2                                                             
		ElseIf(nAlignH == 1)
			nPosX := nNewPerX +  nEspaco //Dando uma distáncia da margem
		EndIf 
	                   
		If(nAlignV == 3)                                       
			nPosY := nNewPerY + nPercAlt   -  nAltFont *  Len(aTxt) - 05
		ElseIf(nAlignV == 2)
	      nPosY := nNewPerY +  nPercAlt/ 2  - nAltFont*PixelY / 2
		ElseIf(nAlignV == 1)                                                                       	
	 		nPosY := nNewPerY + 10 //Dando uma distáncia da margem
		EndIf          
	
		oPrint:Say(nPosY + (nX - 1) * nAltFont ,nPosX,aTxt[nX] ,oFont,nPercLarg)
	Next
	
EndIf

Return {nRetY,nRetX,nBegBoxY,nBegBoxX,nEndBoxY,nEndBoxX } 



//________________________________________________________________________________________________________________________________
User Function FSCalcPos(oPrint,nPercY,nPerX,nMargem)
Local nHorSize	:= oprint:NHORZRES() - nMargem * 2
Local nVertSize:= oprint:NVERTRES() - nMargem * 2

//Passando os valores informados de percentual para coordenadas físicas
nPerX		:= 20 + nMargem + nPerX  * nHorSize / 100
nPercY	:=	20 + nMargem + nPercY * nVertSize / 100

Return {nPercY,nPerX} 


//________________________________________________________________________________________________________________________________
User Function FQrbTxt(cTexto,nTamLin,nQtdQrb)

Local nXI 		:= 0
Local cAuxTxt	:= ""
Local nPosTxt	:= 1

For nXI := 1 To nQtdQrb
	cAuxTxt += SubStr(cTexto,nPosTxt,nTamLin)+Chr(13)
	If (Len(cAuxTxt) >= Len(cTexto))
		Exit
	EndIf
	nPosTxt := (nPosTxt + nTamLin) + 1
Next nXI

cTexto := cAuxTxt

Return (cTexto)


//________________________________________________________________________________________________________________________________
Static Function FSValTel(nFlag,cValor,oObj,xVlrCom)

Local lRetFun := .T.

Do Case
	//Validacoes no campo ano 
	Case (nFlag == 1)
			If !(cValor $ xVlrCom)
				MsgStop("Mês inválido, verifique e tente novamente.")
				lRetFun := .F.
				oObj:Refresh()
				oObj:SetFocus()
			EndIf
	//Validacoes no campo ano 
	Case (nFlag == 2)
			If (Val(cValor) == 0 .Or. (Len(AllTrim(cValor))) < 4 )
				MsgStop("Ano inválido, verifique e tente novamente.")
				lRetFun := .F.
				oObj:Refresh()
				oObj:SetFocus() 
			EndIf
EndCase



Return (lRetFun) 


//________________________________________________________________________________________________________________________________
User Function FForQIn(cString)

Local cAuxStr := ""

//Formata a String conforme a clausula IN do SQL
cAuxStr := StrTran(cString,",","','")
cAuxStr := "'"+cAuxStr+"'"

Return(cAuxStr)



//________________________________________________________________________________________________________________________________  
User Function FGerArq(aFile,cProGer,aLogs,cDirNew)

Local lRetFun	:= .F.
Local nRetRen	:= 0
Local aDirArq	:= ""
Local cDirOld	:= ""
Local cDirSys	:= CURDIR()

//Funcao para identificar o diretorio de destino do arquivo gerado
aDirArq := U_FDirArq(@aFile) 

//Funcao para copiar o arquivo para o diretorio informado pelo usuario
//e converte-lo para o formato xls
cDirOld := aDirArq[1] 
If (CpyS2T("\"+cDirSys+"tmpanx\"+cProGer, cDirOld, .T.))
	//Renomeia o arquivo
	cDirOld += cProGer
	cDirNew := aDirArq[1]+aDirArq[2]
	nRetRen := Frename(cDirOld , cDirNew )
	If (nRetRen == 0 )
		lRetFun := .T.
		//Se o arquivo for renomeado, sera apagado o arquivo HTML gerado no servidor
		Ferase("\"+cDirSys+"tmpanx\"+cProGer) 		
	Else
		AAdd(aLogs,"Erro 002 - Não foi possível renomear o arquivo gerado no servidor,"+Chr(13)+;
					 "verifique se você possui permissão para gravação.")
	EndIf
Else
	AAdd(aLogs,"Erro 001 - Não foi possível copiar o arquivo do servidor para a maquina cliente,"+Chr(13)+;
	 			 "verifique se você possui permissão para gravação.")
EndIf    
 
Return (lRetFun)


//________________________________________________________________________________________________________________________________ 
User Function FDirArq(aFile)

Local aDirArq := {}
Local nXI		:= 0
Local cDir		:= ""

//Separa o diretorio
aDirArq := Separa(aFile[1],"\")

//Varre o diretorio quebrado
For nXI := 1 To Len(aDirArq) - 1
	cDir += aDirArq[nXI]+"\" 
Next nXI

//Adiciona o direotio
aDirArq[1] := cDir
//Adiciona o nome do arquivo
aDirArq[2] := AllTrim(aDirArq[Len(aDirArq)])+".xls"

Return (aDirArq) 



//-------------------------------------------------------------------
/*/{Protheus.doc} FArrumTx
Funcao para montar arreys contendo textos para serem utilizados em grids de relatórios.

@protected
@author		Ederson Colen
@since		18/06/2012
@obs		
@param		cDescArr  - Texto que deseja Tratar
				nTamDesc  - Numero de Caracteres por Linha
				nTamMarg  - Tamanho da Margem em caracteres como margem para localizar e acertar os espacos em branco fazendo quebra.
				aRetArrum - Arrey com o Texto Organizado quebrando nos espacos em branco
				nOpcArr   - Posição no Arrey que o Texto será Gravado
				nTamArr   - Tamanho do Arrey que será gerado.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------  
User Function FArrumTx(cDescArr,nTamDesc,nTamMarg,aRetArrum,nOpcArr,nTamArr)

Local cTxtAux	 := ""
Local cTxtAux2	 := ""
Local nXT       := 0
Local nPosArr   := 0
Local cVarAux   := '{'

If Len(AllTrim(cDescArr)) > nTamDesc

   For nXT := 1 To Len(cDescArr)

		 nPosArr += 1

       cTxtAux  := SubStr(cDescArr,nXT,nTamDesc)
       cTxtAux2 := SubStr(cDescArr,nXT,nTamDesc+nTamMarg)

       If AT(" ",Right(cTxtAux,nTamMarg)) <> 0
          nXT += (((nTamDesc-nTamMarg)-1)+AT(" ",Right(cTxtAux,nTamMarg)))
          cTxtAux := Left(cTxtAux,(nTamDesc-nTamMarg)+AT(" ",Right(cTxtAux,nTamMarg)))
       ElseIf AT(" ",Right(cTxtAux2,nTamMarg)) <> 0
          nXT += (((nTamDesc+nTamMarg)-1)+AT(" ",Right(cTxtAux2,nTamMarg)))
          cTxtAux := Left(cTxtAux2,nTamDesc+AT(" ",Right(cTxtAux2,nTamMarg)))
       Else
			 nXT += Len(AllTrim(cTxtAux))
       EndIf

       If Len(aRetArrum) < nPosArr
          cVarAux := '{'
          For nXB := 1 To nTamArr
              cVarAux += '"",'
			 Next
          If Right(cVarAux,1) == ","
             cVarAux := SubStr(cVarAux,1,Len(cVarAux)-1)
          EndIf
			 cVarAux += '}'
	       AADD(aRetArrum,&(cVarAux))
			 aRetArrum[nPosArr,nOpcArr] := cTxtAux
       Else
			 aRetArrum[nPosArr,nOpcArr] := cTxtAux
       EndIf

   Next nXT

Else

	If Len(aRetArrum) < 01
		cVarAux := '{'
		For nXB := 1 To nTamArr
			cVarAux += '"",'
		Next
		If Right(cVarAux,1) == ","
			cVarAux := SubStr(cVarAux,1,Len(cVarAux)-1)
		EndIf
		cVarAux += '}'
		AADD(aRetArrum,&(cVarAux))
		aRetArrum[01,nOpcArr] := cDescArr
   Else
		aRetArrum[01,nOpcArr] := cDescArr
   EndIf

EndIf

Return (aRetArrum)



//-------------------------------------------------------------------
/*/{Protheus.doc} FStrFil
Funcao retorna uma String com as Filiais que o usuário logado tem acesso.

@protected
@author		Ederson Colen
@since		18/06/2012
@obs		
@param		cTipo - V = Validação ou R = Retorno.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------  
User Function FStrFil(cTipo,cContVld)

Local aFilUser := MatFilCalc(.F.)
Local cStrFil := ""
Local xRetFun

For nXX := 1 To Len(aFilUser)
    cStrFil += aFilUser[nXX,2]+"#"
Next nXX

If cTipo == "V"
   If cContVld $ cStrFil
	   xRetFun := .T.
	Else
	   xRetFun := .F.
   EndIf
Else
	xRetFun := cStrFil
EndIf

Return (xRetFun)







//-------------------------------------------------------------------
/*/{Protheus.doc} FLogFile

@author	  Rodrigo Carvalho
@since	  09/06/2015
@version  
@obs	  

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------  
User Function FLogFile( cMsgRet , cArqRet , cLogFile , cPasta)

Local nHDestino
Local nLength    := 0
Local cCrlf      := Chr(13)+Chr(10)

Default cPasta   := "PAINEL_COMPRAS_LOG"
Default cLogFile := GetSrvProfString("Startpath","") + cPasta+"\LogPainelCompras_"+Alltrim(SM0->M0_CodFil) + ".LOG"
Default cArqRet  := ""             
Default cMsgRet  := ""

MakeDir(cPasta)

If ! File(cLogFile)
   nHDestino := FCreate(cLogFile, 2) // Cria o arquivo de destino
Else
   nHDestino := FOpen(cLogFile, 2)
   nLength   := FSEEK(nHDestino, 0, FS_END) //include FILEIO.CH
Endif      

If nHDestino == -1 // Testa a criação do arquivo de destino
	MsgStop("Erro ao Abrir/Gravar o arquivo "+chr(13)+cLogFile,"Erro")
	Return  .F.
EndIf 

FWrite(nHDestino , "Data/Hora: " + Dtoc(Date()) +" "+time() + cCrlf )	
FWrite(nHDestino , "Terminal : " + GetComputerName()   + cCrlf )
FWrite(nHDestino , "Filial   : " + SM0->M0_CodFil      + cCrlf )
FWrite(nHDestino , "Usuario  : " + cUserName + cCrlf )	
FWrite(nHDestino , "DataBase : " + DtoC(dDataBase) + cCrlf )	
FWrite(nHDestino , "Status   : " + cMsgRet + cArqRet + cCrlf )     
FWrite(nHDestino , Replicate('-',100) + cCrlf )                   
FClose(nHDestino)

Return .t.



