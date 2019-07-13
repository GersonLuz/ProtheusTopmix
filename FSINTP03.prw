#Include "Protheus.ch"              
#Define cEol Chr(13)+Chr(10)                                         

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSINTP03()
Processo de Importação de Pedidos de Remessa da BetonMix.
       
@author Fernando Ferreira
@since 25/10/2011 
@version P11
@obs  
Parâmentros Utilizados:
FS_INTDBAM : Parâmetro onde é informado o ambiente de integração configurado no Top Connect
FS_INTDBIP : Parêmetro utilizado para informar o IP do servidor da base de integração
FS_LACCTAB : Parametro que informa lancto contabil utilizado na integração
FS_AGTLACC :
FS_CTBLINE : Informa se contabilização será on-line
FS_PEDCART : Informa se o pedido será em carteira
FS_CONDREM : Condição de pagamento para pedidos de remessa
FS_TESREM  : TES utiliza nos pedidos de remessa.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSINTP03()
FPrcPedRem()
Return Nil  

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FPrcPedRem
Função realiza a inclusão das NF de Saída da base de integração para a 
base protheus.

@protected         
@author Fernando Ferreira
@since 25/10/2011 
@version P11
@obs  
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     		Motivo      
23/02/2012  Fenando Ferreira     Alteração no processo de Inclusão e Exclusão de Pedidos de Remessa.
16/03/2012  Fernando Ferreira		Alteração no reposicionamento do SC5 no siga auto.

/*/
//---------------------------------------------------------------------------------------
Static Function FPrcPedRem()
Local		aDadNts		:=	{}
Local		aPedInt		:= {}			// Dados da Cabeçalho do Pedido de Venda	
Local		aNot			:=	{}
Local		aAreOld		:= {GetArea()}
Local 	aAreaSC5		:= {}
Local		aCmp			:= {}
Local		aWhr			:= {}
                                                                  
Local		cHdlInt		:=	GetNewPar("FS_INTDBAM"," ")  // Parâmetro utilizado para o ambiente da base de integração
Local		cEndIp		:=	GetNewPar("FS_INTDBIP"," ")	// Parêmetro utilizado para informar o IP do servidor da base de integração
Local		cFil			:=	""  
Local		cPed			:=	""
Local		cTip			:= ""
Local		cNumNot		:= ""
Local		cSerNot		:= space(3)
Local		cMsgErr		:= ""
Local		cPedExc		:= ""
Local		cDta			:= DToS(dDataBase)
Local		cNumNotRet	:= ""

Local		lMstCot		:=	SuperGetMv( "FS_LACCTAB", .F.)
Local		lAglCot		:=	SuperGetMv( "FS_AGTLACC", .F.)
Local		lCont			:=	SuperGetMv( "FS_CTBLINE", .F.)
Local		lCar			:=	SuperGetMv( "FS_PEDCART", .F.)
Local		lNtfExt		:= .F.
Local		dDatOld		:= dDataBase

Local		nXi			:=	1

Private 	nHdlInt		:=	-1//TcLink(cHdlInt,cEndIp)  	
Private 	nHdlErp		:=	AdvConnection()
Private	dDatBtnTop	:= CriaVar("C5_EMISSAO")
Private	dDatExcBkp	:= CriaVar("C5_DTEXCNF")
Private  dUlMes      := GetMv("MV_ULMES")

If !Empty(cHdlInt) .Or. !Empty(cEndIp)
	nHdlInt		:=	TcLink(cHdlInt,cEndIp,7990)
EndIf

If nHdlInt < 0 
	ConOut("Nao foi possivel realizar conexao com banco de dados de integracao. " + DtoC(Date())+" - "+Time())
Else
	// Cria arquivo de trabalho
	cAli	:=	U_FSTblDtb("SC5")                   
	
	// Realiza a ordenação por SC5->C5_FILIAL+SC5->C5_ZPEDIDO
	SC5->(dbOrderNickName("FSIND00002"))
	aAreaSC5		:= SC5->(GetArea())		
	// Realiza a leitura do arquivo de trabalho	
	While (cAli)->(!Eof())
		aCmp	:= {}
		aWhr	:= {}
		cFil			:=	AllTrim((cAli)->C5_FILIAL)
		cPed			:=	(cAli)->C5_ZPEDIDO
		cTip			:=	(cAli)->C5_ZTIPO
		cNumNot   	:= (cAli)->C5_NOTA
		cSerNot		:= (cAli)->C5_SERIE
		cPedExc		:= AllTrim((cAli)->C5_ZEXCLUI)
		lNtfExt		:= .F.                            
		dDatBtnTop	:=	SToD((cAli)->C5_EMISSAO)
		dDatExcBkp	:= SToD((cAli)->C5_DTEXCNF)
		
		If dDatBtnTop <= dUlMes // Validar se o periodo ja foi fechado, o que poderá impossibilitar de gerar a nota fiscal - 20151020
		   ConOut(Replicate("*",100))
         ConOut("Tentativa de emitir NF: "+cNumNot+" referente a um periodo fechado("+DtoC(dUlMes)+") - "+ DtoC(Date())+" - "+Time())
		   ConOut(Replicate("*",100) )
         Do While ! Eof() .And. (cFil + cPed) == (AllTrim((cAli)->C5_FILIAL) + (cAli)->C5_ZPEDIDO)
		      (cAli)->(DbSkip())
		   Enddo   
		   Loop
      Endif
      
		If cTip == "1" .And. Empty(AllTrim(GetMv("MV_CLIDANF")))
			cMsgErr	:= "Parâmetro MV_CLIDANF não está preenchido para esta Filial pedido:" + cPed
			U_FSSETERR(xFilial("P00"), dDataBase, Time(), cPed, "Ped. Rem", cMsgErr)
		Else
			SC5->(dbSeek(cFil+cPed))
		
			// Validação do Pedido de Venda
			If !(SC5->(!Eof()).And. cFil == SC5->C5_FILIAL .And. cPed == SC5->C5_ZPEDIDO)
				// Inclui dados do Pedido 
				aPedInt	:=	FExeIncDad(cAli)
		
				If !Empty(aPedInt)
					//Executa siga auto                   		
					If U_FSPrcSig(aPedInt[1], aPedInt[2], 3	, cFil, cPed, cTip, dDatOld)
						// Realiza a ordenação por SC5->C5_FILIAL+SC5->C5_ZPEDIDO
						SC5->(dbOrderNickName("FSIND00002"))
						// Realizo o reposicionamento do pedido Gravado
						If SC5->(dbSeek(cFil+cPed)) .And. SC5->(!Eof())			
							// Paliativo até a Totvs Verificar.
							FAtuCfoPed() // Verifica se o CFOP esta correto para fora do estado
							// Geras Notas Fiscas de remessa
							cNumNotRet := U_FSGerNot(SC5->C5_NUM, cNumNot, cSerNot)
							If !Empty(AllTrim(cNumNotRet))
								// Atualiza a base de integração
								FUptPedRem(cDta, cFil, cPed)
							Else
								cMsgErr	:= "Não foi possivel gerar a nota para o pedido:" + cPed
								U_FSSETERR(xFilial("P00"), dDataBase, Time(), cPed, "Ped. Rem", cMsgErr)
							EndIf					
						EndIf
					Else
						(cAli)->(dbSkip(Len(aPedInt[2])))	
					EndIf
				Else
					cMsgErr	:= "Número da Nota já existe na base ou Chave NF-e não informado. Gentileza verificar."
					U_FSSETERR(xFilial("P00"), dDataBase, Time(), cPed, "Ped. Rem", cMsgErr)
				EndIf			
			Else
				lNtfExt	:= .T.
				If Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_SERIE) .And. (cPedExc <> "S")
					// Paliativo até a Totvs Verificar.
					FAtuCfoPed() // ajusta o CFOP se for fora do estado.
					// Geras Notas Fiscas de remessa
					cNumNotRet := U_FSGerNot(SC5->C5_NUM, cNumNot, cSerNot)
				Else
					cNumNotRet := IIf(Empty(cNumNotRet),SC5->C5_NOTA,cNumNotRet)
				EndIf
			EndIf
		EndIf
		
		If (cPedExc == "S")
		
			aPedInt	:=	U_FSGetDad(cFil, cPed)
			// Prepara as notas para exclusão
			If !Empty(aPedInt)
				aDadNts	:=	U_FSPrpExc(aPedInt[2])
				If !Empty(aDadNts)
					// Realiza as Exclusão das notas
					U_FSExcNfs(aDadNts) 
					// Exclui os Pedidos de Venda
					If U_FSPrcSig(aPedInt[1], aPedInt[2], 5	, cFil, cPed, cTip)
						// Realiza a ordenação por SC5->C5_FILIAL+SC5->C5_ZPEDIDO
						SC5->(dbOrderNickName("FSIND00002"))
						// Atualiza a base de integração
						FUptPedRem(cDta, cFil, cPed)					
					EndIf
				Else
					cMsgErr	:= "Não foi possivel excluir o Pedido: " + cPed + ". Existe pendências no Protheus que está impedindo a exclusão da nota, gentileza verificar."
					U_FSSETERR(xFilial("P00"), dDataBase, Time(), cPed, "Ped. Rem", cMsgErr)						
				EndIf
				If lNtfExt
					(cAli)->(dbSkip(Len(aPedInt[2])))
				EndIf
			Else
				ConOut("Pedido não existe na base de dados do Protheus." + DtoC(Date())+" - "+Time())				
			EndIf
		
		ElseIf cPedExc == "N" .And. lNtfExt
		
			aPedInt	:=	U_FSGetDad(cFil, cPed)
			If !Empty(AllTrim(cNumNotRet))
				// Atualiza a base de integração
				FUptPedRem(cDta, cFil, cPed)
			Else
				cMsgErr	:= "Não foi possivel gerar a nota para  o pedido:" + cPed
				U_FSSETERR(xFilial("P00"), dDataBase, Time(), cPed, "Ped. Rem", cMsgErr)						
			EndIf
			(cAli)->(dbSkip(Len(aPedInt[2])))
		EndIf		
	EndDo	
	U_FSCloAre(cAli)
	aEval(aAreOld, {|xAux| RestArea(xAux)})
	dDataBase := dDatOld
EndIf
TcUnLink(nHdlInt)
Return Nil  

//------------------------------------------------------------------- 
/*/{Protheus.doc} FExeIncDad
Carregas os dados do cabeçalho do pedido de venda

@protected
@author Fernando Ferreira
@param cAli - Alias do pedido de venda.
@since 25/10/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FExeIncDad(cAli)
Local		cFil		:= ""
Local		cPed		:=	""     
Local		cTesRem	:=	""
Local		cChvNfe	:= ""
Local		cSerPed	:= space(3)
Local 	cConPgt	:=	AllTrim(SuperGetMv( "FS_CONDREM" , .F. ," "))

Local		aDadCab	:=	{}
Local		aDadIte	:= {}
Local		aRet		:=	{}

Local		nIdt		:=	0
Local		nXi		:= 1                       
Local		cNumPed	:= ""

Local		lExtSf2	:= .F.

Default	cAli		:=	""

aDadCab	:= {}
aDadIte	:= {}                        
nXi		:=	1   

cFil		:= (cAli)->C5_FILIAL
cPed		:=	(cAli)->C5_ZPEDIDO
nIdt		:=	(cAli)->ID
cChvNfe	:= AllTrim((cAli)->C5_ZCHVNFE)
cSerPed	:= AllTrim(Upper((cAli)->C5_SERIE))

If (cSerPed == "R") .or. (cSerPed == "R2") .or. (cSerPed == "R3") .or. (cSerPed == "R4") .or. (cSerPed == "R5") //JSANTOS: 10-12-2014 acrescentado R3 e R4. 28-03-2017 acrescentando R5
	cTesRem	:= AllTrim(SuperGetMv( "FS_TESROM"  , .F. ,""))
Else
	cTesRem	:= AllTrim(SuperGetMv( "FS_TESREM"  , .F. ,""))
EndIf 

lExtSf2	:=	FCkeNumNot((cAli)->C5_NOTA, (cAli)->C5_SERIE, (cAli)->C5_CLIENTE, (cAli)->C5_LOJACLI, " ", "N")

aCabPed	:=	U_FArrSigAut(cAli, "C5")
cNumPed 	:= FNextPdv()
AAdd(aCabPed, {"C5_TIPO"       	,"N"           ,Nil})
AAdd(aCabPed, {"C5_CONDPAG"      ,cConPgt       ,Nil})
AAdd(aCabPed, {"C5_ZORIGEM"      ,"KP"       	,Nil})
AAdd(aCabPed, {"C5_NUM"      		,cNumPed      	,Nil})

// Realiza a ordenação do Array de Cabeçalho do Pedido
// de acordo com o SX3		
aCabPed	:=	U_FSAceArr(aCabPed, "SC5")

While (cAli)->(!Eof());
	.And.	cFil	== (cAli)->C5_FILIAL;
	.And.	cPed	==	(cAli)->C5_ZPEDIDO;
	.And.	nIdt	==	(cAli)->ID
	
 	// Adiciona as informações no array de Itens que será utilizado no Siga Auto
	AAdd(aDadIte,U_FArrSigAut(cAli,"C6"))
	AAdd(aDadIte[nXi], {"C6_TES"       ,cTesRem          ,Nil})					
	AAdd(aDadIte[nXi], {"C6_NUM"       ,cNumPed      	  ,Nil})	
	// Realiza a ordenação do Array de itens do Pedido
	// de acordo com o SX3				
	aDadIte	:=	U_FSAceIte(aDadIte, "SC6")
							
	(cAli)->(dbSkip())
	nXi++
EndDo

If !lExtSf2 .And. !Empty(cChvNfe)
	AAdd(aRet, aCabPed)
	AAdd(aRet, aDadIte)
ElseIf Empty(cChvNfe) .And. (cSerPed == "R" .or. cSerPed == "R2" .Or. cSerPed == "2" .or. cSerPed == "R3" .or. cSerPed == "R4" .or. cSerPed == "R5")     //JSANTOS: 15-12-2014 acrescentado R3 e R4. 28/03/2017 acrescentando R5
	AAdd(aRet, aCabPed)
	AAdd(aRet, aDadIte)
EndIf
                                                                                      
Return AClone(aRet)                                                                    

//------------------------------------------------------------------- 
/*/{Protheus.doc} FNextPdv
Gera o próximo número do pedido de venda

@protected
@author Fernando Ferreira
@since 25/10/2011 
@version P11
@Return cNumPed - Novo Número do pedido
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FNextPdv()
Local aAreOld 	:= GetArea()
Local cNumPed	:= GetSXENum("SC5","C5_NUM")

SC5->(dbSetOrder(1))

While .T.           
	SC5->(dbSeek(xFilial("SC5")+cNumPed))
	If SC5->(Eof())
		Exit
	Else 
		ConfirmSx8()                                   
		cNumPed	:= GetSXENum("SC5","C5_NUM")
	EndIf
	
EndDo

ConfirmSx8()

RestArea(aAreOld)

Return cNumPed

//------------------------------------------------------------------- 
/*/{Protheus.doc} FCkeNumNot
Verifica se a nota a ser gerada pelo pedido de venda já existe na base
Protheus.

@protected       
@author Fernando Ferreira
@since 25/10/2011 
@version P11      
@param cNumNotBet - Número da nota
@param cSerNotBet - Série da nota fiscal
@param cCliNotBet - Cliente da nota fiscal
@param cLojNotBet - Loja do cliente da nota
@param cForNotBet - Formulário Proprio
@param cTipNotBet - Tipo da Nota fiscal
@obs 
Função Utiliza o indice 1 da SF2
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FCkeNumNot(cNumNotBet, cSerNotBet, cCliNotBet, cLojNotBet, cForNotBet, cTipNotBet)
Local		cFilCrt	:= xFilial("SF2")

Local 	lRet		:= .F.

Local		aAreSf2  :=	SF2->(GetArea())
Local		aAreOld	:= GetArea()

Default	cNumNotBet	:= ""
Default	cSerNotBet	:= ""
Default	cCliNotBet	:= ""
Default	cLojNotBet	:= ""
Default	cForNotBet	:= " "
Default	cTipNotBet	:= "N"
    
// Numero + Serie Docto. + Cliente + Loja + Form. Prop. + Tipo da nota
// F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
SF2->(dbSetOrder(1))
SF2->(dbSeek(cFilCrt+cNumNotBet+cSerNotBet+cCliNotBet+cLojNotBet+cForNotBet+cTipNotBet))

If SF2->(!Eof())	.And.	cFilCrt	  == SF2->F2_FILIAL;
					 	.And. cNumNotBet == SF2->F2_DOC;
						.And. cSerNotBet == SF2->F2_SERIE;
						.And. cCliNotBet == SF2->F2_CLIENTE;
						.And. cLojNotBet == SF2->F2_LOJA;
						.And. cForNotBet == SF2->F2_FORMUL;
						.And. cTipNotBet == SF2->F2_TIPO
	lRet	:= .T.
EndIf

RestArea(aAreSf2)
RestArea(aAreOld)
Return lRet                                                          

//------------------------------------------------------------------- 
/*/{Protheus.doc} FUptPedRem
Atualiza a base de interface

@protected       
@author Fernando Ferreira
@since 25/10/2011 
@version P11      
@param cDta - Data da atualização
@param cFil - Filial do Pedido
@param cPed - Pedido do KP
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FUptPedRem(cDta, cFil, cPed)
Local 	aCmp := {}
Local		aWhr := {}

Default 	cDta := DToC(dDataBase)
Default	cFil := xFilial("SC5")
Default  cPed := ""

AAdd(aCmp,{"DATAINTERFACE_PR",cDta })
AAdd(aWhr, {"C5_FILIAL", 	cFil, "="})
AAdd(aWhr, {"C5_ZPEDIDO", 	cPed, "="}) 

ConOut("Preparando.. FSQryUpd - "+Funname())
U_FSQryUpd(aCmp,"SC5",aWhr)

Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FAtuCfoPed
Se o Cfop do pedido de venda estiver para fora do estado essa função 
realiza a correção do processo.

@protected       
@author Fernando Ferreira
@since 08/01/2013 
@version P11      
@obs 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FAtuCfoPed()
Local	cMvEstado 	:= AllTrim(GetMv("MV_ESTADO"))
Local	cCfop		 	:= ""
Local	aAreOld		:= {SC6->(GetArea()), SF4->(GetArea()), SA1->(GetArea()),GetArea()}

SA1->(dbSetOrder(1))
SC6->(dbSetOrder(1))
SF4->(dbSetOrder(1))

If SA1->(dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
	If SA1->A1_EST == cMvEstado
		If SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
			While SC6->(!Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM
				If SF4->(dbSeek(xFilial("SF4")+SC6->C6_TES))	
					If SC6->C6_CF != SF4->F4_CF
						If RecLock("SC6", .F.)
							SC6->C6_CF := SF4->F4_CF
							SC6->(MsUnLock())
						EndIf
					EndIf
				EndIf
				SC6->(dbSkip())
			EndDo
		EndIf
	EndIf
EndIf

AEval(aAreOld, {|x| RestArea(x)})

Return Nil


