#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "fileio.ch"
#INCLUDE 'TOPCONN.CH'

/*/{Protheus.doc} NFSTPX001
//TODO Descrição auto-gerada.
@author lucas.borges
@since 25/01/2019
@version 1.0

@type function
/*/
User Function NFSTPX01()

	Local aPerg     := {}
	Local cParBrw   := SM0->M0_CODIGO+SM0->M0_CODFIL+"Fisa022TPX"
	Private cMun		:= SM0->M0_CODMUN
	Private cCodMun		:= SM0->M0_CODMUN
	Private aCodTrib	:= u_NFSTLIB1(cMun)
	Private oBrowse 	:= Nil
	Private cCadastro 	:= "Documentos de saida NFSE"
	Private cCondicao := ""
	Private cAlias

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem das perguntas                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aPerg,{1,"Serie: ",PadR("",Len(SF2->F2_SERIE)),"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"
	aadd(aPerg,{2,"Filtra: ",PadR("",Len("5-Não Transmitidas")),{"1-Autorizadas","2-Sem filtro","3-Não Autorizadas","4-Transmitidas","5-Não Transmitidas"},120,".T.",.T.,".T."}) //"Filtra"###"1-Autorizadas"###"2-Sem filtro"###"3-Não Autorizadas"###"4-Transmitidas"###"5-Não Transmitidas"

	//	aParam[01] := ParamLoad(cParBrw,aPerg,1,aParam[01])
	//	aParam[02] := ParamLoad(cParBrw,aPerg,2,aParam[02])
	//	aParam[03] := ParamLoad(cParBrw,aPerg,3,aParam[03])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o serviço foi configurado - Somente o Adm pode configurar   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ParamBox(aPerg,"NFS-e",,,,,,,,cParBrw,.T.,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a Filtragem                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCondicao := "F2_FILIAL=='"+xFilial("SF2")+"' "
	If !Empty(MV_PAR01)
		cCondicao += ".AND. F2_SERIE$'"+MV_PAR01+"'  "
	EndIf

	If SubStr(MV_PAR02,1,1) == "1" 			//"1-NF Autorizada"
		cCondicao += ".AND. F2_FIMP$'S' "
	ElseIf SubStr(MV_PAR02,1,1) == "3" 		//"3-Não Autorizadas"
		cCondicao += ".AND. F2_FIMP$'N' "
	ElseIf SubStr(MV_PAR02,1,1) == "4" 		//"4-Transmitidas"
		cCondicao +=  ".AND. F2_FIMP$'T' "
	ElseIf SubStr(MV_PAR02,1,1) == "5" 		//"5-Não Transmitidas"
		cCondicao += ".AND.  F2_FIMP$' ' "
	EndIf
	//	cCondicao += ".AND. F2_ESPECIE$'"+AllTrim(cTipoNfd)+"'"

	SF2->(DbSetfilter({|| &(cCondicao)}, cCondicao))

	SF2->(dbGoTOP())

	//Agora iremos usar a classe FWMarkBrowse
	oBrowse:= FWMarkBrowse():New()
	oBrowse:SetDescription(cCadastro) //Titulo da Janela

	oBrowse:SetAlias("SF2") //Indica o alias da tabela que será utilizada no Browse
	oBrowse:SetFieldMark("F2_OK") //Indica o campo que deverá ser atualizado com a marca no registro
	oBrowse:oBrowse:SetDBFFilter(.T.)
	oBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
	oBrowse:oBrowse:SetFixedBrowse(.T.)
	//Permite adicionar legendas no Browse
	oBrowse:AddLegend("F2_FIMP=='S'","GREEN" 	,"Autorizada")
	oBrowse:AddLegend("F2_FIMP==' '","BLACK"   	,"Não Transmitida")
	oBrowse:AddLegend("F2_FIMP=='N'","RED"   	,"Não autorizado")
	oBrowse:AddLegend("F2_FIMP=='T'","BLUE"   	,"Transmitido")

	oBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse

	//Adiciona botoes na janela
	//oBrowse:AddButton("Enviar Mensagem"	, { || U_MCFG006M()},,,, .F., 2 )
	//oBrowse:AddButton("Detalhes"		, { || MsgRun('Coletando dados de usuário(s)','Relatório',{|| U_RCFG0005() }) },,,, .F., 2 )
	//oBrowse:AddButton("Legenda"			, { || MCFG006LEG()},,,, .F., 2 )

	if(Len(aCodTrib) > 0)
		oBrowse:AddButton("Transmitir NFEs"	, {|| NFSETR01() },,,)
	End if

	oBrowse:AddButton("Atualizar"	, { || processa( {|| oBrowse:Refresh(.T.) }, "NFSE", "Buscando dados...", .f.)},,,)
	oBrowse:AddButton("Status"	, {|| TSay() },,,)
	//Método de ativação da classe
	oBrowse:Activate()

	oBrowse:oBrowse:Setfocus() //Seta o foco na grade

Return

Static Function MenuDef()
	Local aRot := {}
	ADD OPTION aRot TITLE "Visualiza Doc." ACTION "Fisa022Vis"  OPERATION 6 ACCESS 0
Return(Aclone(aRot))

static Function NFSETR01()

	Local aArea		:= GetArea()
	Local aPerg		:= {}
	Local cString := ""
	Local cParTrans	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"Fisa022Rem"
	Local dDataIni	:= CToD('  /  /  ')
	Local dDataFim  := CToD('  /  /  ')
	LOCAL dData	 	:= Date()
	Local cRetorno := ""
	Local cLote := ""
	Local aDados := {}
	Local cUniNfe := GETNEWPAR("MV_CUNINFE", "C:\Unimake\UniNFe")

	aParam	:= {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),"",1,dData,dData,""}

	MV_PAR01:=cSerie   := aParam[01] := PadR(ParamLoad(cParTrans,aPerg,1,aParam[01]),Len(SF2->F2_SERIE))
	MV_PAR02:=cNotaini := aParam[02] := PadR(ParamLoad(cParTrans,aPerg,2,aParam[02]),Len(SF2->F2_DOC))
	MV_PAR03:=cNotaFin := aParam[03] := PadR(ParamLoad(cParTrans,aPerg,3,aParam[03]),Len(SF2->F2_DOC))
	MV_PAR04:=""
	MV_PAR05:=""
	MV_PAR06:= dData
	MV_PAR07:= dData
	MV_PAR08:= aParam[08] := PadR(ParamLoad(cParTrans,aPerg,8,aParam[08]),100)

	aadd(aPerg,{1,"Serie",aParam[01],"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"
	aadd(aPerg,{1,"Nf Inicial",aParam[02],"",".T.","",".T.",30,.T.})	//"Nota fiscal inicial"
	aadd(aPerg,{1,"Nf Final",aParam[03],"",".T.","",".T.",30,.T.}) //"Nota fiscal final"
	if(ParamBox(aPerg," NFS-e",,,,,,,,cParTrans,.T.,.T.))

		cCondicao := "F2_FILIAL=='"+xFilial("SF2")+"' "
		If (!Empty(MV_PAR01) .AND. !Empty(MV_PAR02) .AND. !Empty(MV_PAR03))
			cCondicao += ".AND.  F2_SERIE$'"+MV_PAR01+"' .AND. F2_DOC >= '"+MV_PAR02+"' .AND. F2_DOC <= '"+MV_PAR03+"'  "

			dbSelectArea("SF2")
			dbSetOrder(1)
			SF2->(DbSetfilter({|| &(cCondicao)}, cCondicao))

			SF2->(dbGoTOP())

			WHILE SF2->(!EOF())
				RecLock("ZZ1",.T.)
				ZZ1->ZZ1_FILIAL := xFilial("ZZ1")
				ZZ1->ZZ1_DOC := SF2->F2_DOC
				ZZ1->ZZ1_SERIE := SF2->F2_SERIE
				ZZ1->ZZ1_COD := Str(SF2->(Recno()),0,0)
				ZZ1->(MsUnlock())
				cLote := "_" + cValToChar(ZZ1->(Recno()))

				if(xFilial("ZZ1") == "010133")
					cRetorno = u_xmlGoveDigital(ZZ1->(Recno()), 'envio')
				elseif(xFilial("ZZ1") == "010104")
					cRetorno = u_xmlTiplan(ZZ1->(Recno()), 'envio')
				elseif(xFilial("ZZ1") == "010108" .OR. xFilial("ZZ1") == "010131")
					cRetorno = u_xmlPortalFacil(ZZ1->(Recno()), 'envio')
				elseif(xFilial("ZZ1") == "010103" )
					cRetorno = u_xmlSmarapd(ZZ1->(Recno()), 'envio')
				endif

				if(!Empty(cRetorno))
					// Abre o arquivo
					nHandle := FCREATE(cUniNfe +u_ToXml(SM0->M0_CGC)+ "\Envio\" +u_ToXml(SM0->M0_CGC)+ cLote+ "-env-loterps.xml")
					If nHandle == -1
						MsgStop('Erro de abertura : FERROR '+str(ferror(),4))
					Else
						FSeek(nHandle, 0, FS_END)         // Posiciona no fim do arquivo
						FWrite(nHandle, cRetorno) // Insere texto no arquivo
						fclose(nHandle)                  // Fecha arquivo
						RecLock("SF2",.F.)
						SF2->F2_FIMP := "T"
						MsUnlock()
					Endif
				EndIf
				SF2->(dbSkip())
			ENDDO
			MsgInfo("RPS transmitido"," RPS")
		EndIf
		oBrowse:Refresh(.T.)
	Else
		MsgInfo("Processo cancelado"," RPS")
	EndIf
Return

Static Function TSay()

	Local cTexto := ""

	dbSelectArea("ZZ1")
	dbSetOrder(2)
	dbSeek(xFilial("ZZ1")+str(SF2->(Recno())))

	if(Empty(SF2->F2_FIMP))
		cTexto := "RPS: "+ SF2->F2_DOC +" Não transmitido."
	ElseIF(SF2->F2_FIMP == "T")
		cTexto := "RPS: "+ SF2->F2_DOC +" Aguardando retorno."
	ElseIF(SF2->F2_FIMP == "S")
		cTexto := "RPS: "+ SF2->F2_DOC +" Autorizado"+ Chr(13) + Chr(10) +"NFSe: "+F2_NFELETR
	ElseIF(SF2->F2_FIMP == "N")
		cTexto := "RPS: "+ SF2->F2_DOC +" Não autorizado"+ Chr(13) + Chr(10) +"Erros: "+ Chr(13) + Chr(10)
		WHILE ZZ1->(!EOF())
			cTexto += ZZ1->ZZ1_XML
			ZZ1->(dbSkip())
		EndDo
	EndIf

	DEFINE DIALOG oDlg TITLE "Retono NFE" FROM 180,180 TO 550,700 PIXEL

	// Cria Fonte para visualização
	oFont := TFont():New('Courier new',,-18,.T.)

	// Usando o método New
	oSay1:= TSay():New(01,01,{||'Status NFSE'},oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)

	// Usando o método Create
	oSay:= TSay():Create(oDlg,{||'Status NFSE'},20,01,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)

	// Métodos
	oSay:CtrlRefresh()

	oSay:SetText( cTexto)

	// Propriedades
	oSay:lTransparent = .T.

	oSay:lWordWrap = .F.

	ACTIVATE DIALOG oDlg CENTERED
Return

