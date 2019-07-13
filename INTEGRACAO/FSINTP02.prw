#Include "Protheus.ch"   

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSINTP02()
Realiza a importação de Títulos Provisórios
          
@author Fernando Ferreira
@since 10/11/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSINTP02()
FPrcTitPrv()
Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FPrcTitPrv
Função realiza a inclusão de títulos provisórios da base de integração KP para a 
base protheus.

@protected       
@author Fernando Ferreira
@since 10/11/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FPrcTitPrv()
Local		aAreOld		:=	GetArea("SE1")
Local		aDadTit		:=	{}		// Dados dos Títulos
Local		aCmp			:=	{}
Local		aWhr			:=	{}

Local		cAli			:= ""
Local		cHdlInt		:=	GetNewPar("FS_INTDBAM"," ") // Parâmetro utilizado para o ambiente da base de integração
Local		cEndIp		:=	GetNewPar("FS_INTDBIP"," ") // Parêmetro utilizado para informar o IP do servidor da base
Local		cMsgErr		:=	""
Local		cRotPrc		:= "Tit. Prov"
Local		nPosFil		:= 0
Local		nPos			:= 0

Local		dDtaPrc		:=	dDataBase

Private 	nHdlInt		:=	-1
Private 	nHdlErp		:=	AdvConnection()
Private	lMsErroAuto	:= .F.     

AAdd(aCmp,{"DATAINTERFACE",dDtaPrc })

If !Empty(cHdlInt) .Or.!Empty(cEndIp)
	nHdlInt		:=	TcLink(cHdlInt,cEndIp,7990)
EndIf

If nHdlInt < 0 
	ConOut("Nao foi possivel realizar conexao com banco de dados de integracao. " + DtoC(Date())+" - "+Time())
Else
	// Cria arquivo de trabalho
	cAli	:=	U_FSTblDtb("SE1")	
	// Realiza a leitura do arquivo de trabalho	
	While (cAli)->(!Eof())
		aWhr			:= {} 
		lMsErroAuto	:=	.F.
		// Preenche Array de dados para siga-auto
		aDadTit	:=	U_FArrSigAut(cAli, "E1")
		// Acerta o Array dos de acordo com SX3
		aDadTit	:=	U_FSAceArr(aDadTit, "SE1") 
		nPosFil  :=	aScan(aDadTit,{ |x| Alltrim(x[1]) == "E1_FILIAL" } )
		nPos		:= aScan(aDadTit,{ |x| Alltrim(x[1]) == "E1_PREFIXO" } )
		If nPosFil > 0 .And. nPos > 0
			aDadTit[nPosFil][2] 	:= xFilial("SE1")
			aDadTit[nPos][2] 		:= U_FSGetSre(aDadTit[nPos][2]) 
		EndIf
		
		Begin Transaction                              
			// Inclusão dos do Título via Siga Auto
			
		
			MSExecAuto({|x,y| Fina040(x,y)}, aDadTit, 3)
			If lMsErroAuto
				cMsgErr	:=	MemoRead(NomeAutoLog())
				U_FSSETERR(xFilial("P00"), dDtaPrc, Time(), (cAli)->E1_ZREMES, cRotPrc, cMsgErr)
				Ferase(NomeAutoLog())
			Else                              
				// Atualmente o SE1 está compartilhado. Por esse campo ser chave na base de 
				// integração os filtros serão realizados em cima da filial de origem
				AAdd(aWhr, {"E1_FILIAL", 	(cAli)->E1_FILIAL, "="})				
				AAdd(aWhr, {"E1_PREFIXO", 	(cAli)->E1_PREFIXO, "="})
				AAdd(aWhr, {"E1_NUM", 		(cAli)->E1_NUM		, "="})
				AAdd(aWhr, {"E1_ZREMES", 	(cAli)->E1_ZREMES	, "="})
				AAdd(aWhr, {"E1_PARCELA", 	(cAli)->E1_PARCELA, "="})
            
            ConOut("Preparando.. FSQryUpd - "+Funname())
				U_FSQryUpd(aCmp,"SE1",aWhr)
				
			EndIf
		End Transaction
		
		(cAli)->(dbSkip())
	EndDo	
	U_FSCloAre(cAli)
EndIf	
TcUnLink(nHdlInt)
RestArea(aAreOld)
Return Nil


