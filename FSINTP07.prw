#Include "Protheus.ch"              
#Define cEol Chr(13)+Chr(10)

//-------------------------------------------------------------------                                                 
/*/{Protheus.doc} FSINTP07()
Processo de Importação de Pedidos de Fatura
          
@author Fernando Ferreira     7
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
FS_CONDFAT : Condição de pagamento para pedidos de fatura
FS_GRPPRD  : Grupo de produtos para geração do pedido de fatura.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSINTP07()
FPrcPedFat()
Return Nil  

//------------------------------------------------------------------- 
/*/{Protheus.doc} FPrcPedFat
Função inclui pedidos de vendas de faturameno da base integração do 
KP.

@protected       
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
FS_CONDFAT : Condição de pagamento para pedidos de fatura
FS_GRPPRD  : Grupo de produtos para geração do pedido de fatura.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     		Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FPrcPedFat()
Local		aDadNts		:=	{}
Local		aPedInt		:= {}			// Dados da Cabeçalho do Pedido de Venda	
Local		aNot			:=	{}
                                                                  
Local		cHdlInt		:=	SuperGetMv( "FS_INTDBAM" , .F., " " )  // Parâmetro utilizado para o ambiente da base de integração
Local		cEndIp		:=	SuperGetMv( "FS_INTDBIP" , .F., " " )	// Parâmetro utilizado para informar o IP do servidor da base de integração
Local		cFil			:=	""  
Local		cPed			:=	""
Local		cChvIss		:= ""
Local 	cMsgErr		:= ""

Local		lMstCot		:=	SuperGetMv( "FS_LACCTAB", .F.)
Local		lAglCot		:=	SuperGetMv( "FS_AGTLACC", .F.)
Local		lCont			:=	SuperGetMv( "FS_CTBLINE", .F.)
Local		lCar			:=	SuperGetMv( "FS_PEDCART", .F.)

Local		nXi			:=	1

Private  cNumPed     := ""

Private 	nHdlInt		:=	-1//TcLink(cHdlInt,cEndIp)
Private 	nHdlErp		:=	AdvConnection()
//MAX: 28-11-2012 -> Corrigir problema do CFOP fora do Estado
Private  cTip			:= ""
Private  cEstCli     := ""
Private  cEmpEst     := ""

If !Empty(cHdlInt) .Or. !Empty(cEndIp)
	nHdlInt		:=	TcLink(cHdlInt,cEndIp,7990)
EndIf

If nHdlInt < 0 
	ConOut("Nao foi possivel realizar conexao com banco de dados de integracao. " + DtoC(Date())+" - "+Time())

Else
	// Cria arquivo de trabalho
	cAli	:=	U_FSTblDtb("SC5",2)

	// Realiza a leitura do arquivo de trabalho	
	While (cAli)->(!Eof())
		cFil		:=	(cAli)->C5_FILIAL  
		cPed		:=	(cAli)->C5_ZPEDIDO
		cTip		:=	(cAli)->C5_ZTIPO

		cChvIss	:=	" Código do ISS: " + AllTrim((cAli)->C6_ZCODIS) 
		cChvIss	+= " Aliquota: " 	    + Str((cAli)->C6_ZALIQIS)
		cChvIss	+= " CNAE: " 			 + AllTrim((cAli)->C6_ZCNAE)
		cChvIss	+= " Trib. Munic.: "  + AllTrim((cAli)->C6_ZTRIBMU)

		If Empty((cAli)->C5_ZEXCLUI).Or.(cAli)->C5_ZEXCLUI == 'N'
			If cTip == "1" .And. Empty(AllTrim(GetMv("MV_CLIDANF")))
				cMsgErr	:= "Parâmetro MV_CLIDANF não esta preenchido para esta Filial pedido:" + cPed
				U_FSSETERR(xFilial("SC5"), dDataBase, Time(), cPed, "Ped. Fat", cMsgErr)
			Else
				// Inclui dados do Pedido
				aPedInt	:=	FGetPedFat(cAli) 
				// Se array estiver vazio é por causa de código iss diferentes nos itens.
				If !Empty(aPedInt)
					//Executa siga auto
					U_FSPrcSig(aPedInt[1], aPedInt[2], 3	, cFil, cPed, cTip)
				Else  
					cMsgErr := "Os códigos de serviços informados itens não são iguais ou Produto não foi encontrado (Chave:"
					cMsgErr += cChvIss
					cMsgErr +="),  gentileza corrigir."
					// Grava Mensagem de Erro devido CODISS diferentes nos itens.
					U_FSSETERR(xFilial("SC5"), dDataBase, Time(), cPed, "Ped. Fat", cMsgErr)
				EndIf
			EndIf
		ElseIf (cAli)->C5_ZEXCLUI == "S"
			If FVldExcPed(xFilial("SC5"), cPed)
				// Inclui dados do Pedido
				aPedInt	:=	U_FSGetDad(xFilial("SC5"), cPed)
				//Executa siga auto para exclusão do pedido
				U_FSPrcSig(aPedInt[1], aPedInt[2], 5	, cFil, cPed, cTip)
				(cAli)->(dbSkip(Len(aPedInt[2])))
			Else
				U_FSSETERR(xFilial("SC5"), dDataBase, Time(), cPed, "Ped. Fat", "Existe Notas Fiscais Geradas para esse pedido, gentileza verificar.")
				(cAli)->(dbSkip(Len(aPedInt[2])))
			EndIf
		EndIf


	EndDo
	U_FSCloAre(cAli)
	TcUnLink(nHdlInt)

EndIf   

Return Nil       

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetPedFat(cAli)
Carregas os dados do cabeçalho do pedido de venda de faturamento

@protected       
@author Fernando Ferreira
@since 25/10/2011 
@version P11
@param cAli - Alias da tabela da base de integração
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     		Motivo 
23/02/2012  Fernando Ferreira    Inclusão de mensagens padrão.
20/03/2012	Fernando Ferreira		Inclusão do Campo C5_MUNPRES
/*/ 
//------------------------------------------------------------------ 
Static Function FGetPedFat(cAli)
Local		cFil			:= ""
Local		cPed			:=	""     
Local		cCodPrd		:=	""
Local   	cConPgt		:=	AllTrim(SuperGetMv( "FS_CONDFAT" , .F., " " ))
Local		cMenNota	:= AllTrim(SuperGetMv( "FS_MENNOTA" , .F., " " ))
Local		cNatFat		:= AllTrim(SuperGetMv( "FS_NATUREZ" , .F., " " ))


Local		aDadCab		:=	{}
Local		aDadIte		:=  {}
Local		aRet		:=	{}
Local		aCodIss		:=	{}
Local		aMsgPdr		:=  {}

Local		nIdt		:=	0 
Local		nPosAbt		:=  0
Local		nPosMun		:=	0 
Local		nPosEst		:=  0

Local		lVal		:= .F.

Default	cAli			:=	""

aDadCab	:= {}
aDadIte	:= {}                        

cFil		:= (cAli)->C5_FILIAL
cPed		:=	(cAli)->C5_ZPEDIDO 
nIdt		:=	(cAli)->ID  

// Busco as mensagens padrão.
aMsgPdr	:= ASort(FGetMsgPdr())

// Get no código do produto
cCodPrd  :=	FGetPrdPth((cAli)->C6_ZCODIS, (cAli)->C6_ZALIQIS, (cAli)->C6_ZCNAE, (cAli)->C6_ZTRIBMU)

aCabPed	:=	U_FArrSigAut(cAli, "C5")
AAdd(aCabPed, {"C5_TIPO"       	  ,"N"         					,Nil})
AAdd(aCabPed, {"C5_CONDPAG"      ,cConPgt       				,Nil})
AAdd(aCabPed, {"C5_ZORIGEM"      ,"KP"       					,Nil})
AAdd(aCabPed, {"C5_MENNOTA"      ,cMenNota     					,Nil})
AAdd(aCabPed, {"C5_NATUREZ"      ,cNatFat     					,Nil})
AAdd(aCabPed, {"C5_ZDESCPG"      ,(cAli)->C5_ZDESCPG     	,Nil})  //MAX: 05-06-2012
AAdd(aCabPed, {"C5_ZNUMFAT"      ,(cAli)->C5_ZNUMFAT     	,Nil})  //MAX: 05-06-2012 --> SEGUINDO EMAIL JULIANA/FERNANDO


AAdd(aCabPed, {"C5_LOJACLI"		,"01"       	,Nil})
AAdd(aCabPed, {"C5_LIBEROK"		,"S"        	,Nil})
AAdd(aCabPed, {"C5_MENPAD1"		,"001"			,Nil})
AAdd(aCabPed, {"C5_MENPAD2"		,"002"			,Nil})
AAdd(aCabPed, {"C5_MENPAD3"		,"003"			,Nil})
AAdd(aCabPed, {"C5_MENPAD4"		,"004"			,Nil})

nPosMun	:= aScan( aCabPed,{ |x| Alltrim(x[1]) == "C5_MUNPRES" } )
nPosEst	:= aScan( aCabPed,{ |x| Alltrim(x[1]) == "C5_ZESTOB"  } )

If nPosMun >  0 .And. nPosEst > 0	
	AAdd(aCabPed, {"C5_DESCMUN", FGetDesMun(AllTrim(aCabPed[nPosEst][2]), AllTrim(aCabPed[nPosMun][2])), Nil})
	aCabPed[nPosMun][2] := FGetCodEst(AllTrim(aCabPed[nPosEst][2])) + AllTrim(aCabPed[nPosMun][2])
EndIf                                                                                            

cNumPed := aCabPed[nPosMun][2] //MAX: 12-11-2012 Captura numero do município do pedido.

// Realiza a ordenação do Array de Cabeçalho do Pedido
// de acordo com o SX3		
aCabPed	:=	U_FSAceArr(aCabPed, "SC5")

While (cAli)->(!Eof());
	.And.	cFil	== (cAli)->C5_FILIAL;
	.And.	cPed	==	(cAli)->C5_ZPEDIDO;
	.And.	nIdt	==	(cAli)->ID
	
	AAdd(aCodIss,(cAli)->C6_ZCODIS)

 	// Adiciona as informações no array de Itens que será utilizado no Siga Auto
	AAdd(aDadIte,U_FArrSigAut(cAli,"C6"))

	(cAli)->(dbSkip())
EndDo

// Realiza a ordenação do Array de itens do Pedido
// de acordo com o SX3				
aDadIte	:=	U_FSAceIte(aDadIte, "SC6")

// Passa o array de itens por referencia onde é realizada a troca dos produtos
FSetPrdPht(@aDadIte, cCodPrd)

// Substitui os código do produto KP pelo código produto Protheus.
If FValCodIss(aCodIss) .And. !Empty(AllTrim(cCodPrd))
	AAdd(aRet, aCabPed)
	AAdd(aRet, aDadIte)
EndIf

Return AClone(aRet)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FValCodIss
Retorna Verdadeiro se todos os códigos do array forem iguais ou 
falso caso contrário.

@protected
@author Fernando Ferreira
@since 25/10/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FValCodIss(aCod)
Local 	lRet	:= .T.
Local		cCod	:=	""

Default	aCod	:=	{}
                    
If !Empty(aCod)
	cCod	:=	aCod[1]		
	For nXi	:= 2 To Len(aCod)
		If cCod != aCod[nXi]
			lRet	:= .F.
		EndIf
	Next
Else
	lRet	:= .F.		
EndIf
Return lRet

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetPrdPth
Retorna Verdadeiro se todos os códigos do array forem iguais ou 
falso caso contrário.

@protected
@author Fernando Ferreira
@since 25/10/2011 
@param	cCodIss	- Código ISS do produto da base de integração
@param	nAlqIss	- Aliquota de iss do produto de integração
@param	cCnae		- CNAE do produto
@param	cTribMun - Código do municipio
@return	cCodPrd	- Código do produto
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FGetPrdPth(cCodIss, nAlqIss, cCnae, cTribMun)
Local		cQry		:=	""            
Local		cCodPrd	:=	""
Local		cAli		:=	GetNextAlias()
Local 	cGrpPrd	:=	AllTrim(SuperGetMv( "FS_GRPPRD" , .F. ))

Default	cCodIss	:=	""
Default 	nAlqIss	:= 0                                     
Default	cCnae := ""
Default	cTribMun:= ""


cQry	+= cEol + "SELECT TOP 1 "
cQry	+= cEol + "B1.B1_COD"
cQry	+= cEol + "FROM "
cQry	+= cEol +	RetSqlName("SB1")+" B1"
cQry	+= cEol + "WHERE"
cQry	+= cEol + "	B1.B1_GRUPO 	= '" + cGrpPrd		 +	"' AND"
cQry	+= cEol + "	B1.B1_CODISS	= '" + cCodIss		 +	"' AND"
cQry	+= cEol + "	B1.B1_ALIQISS	= "  + Str(nAlqIss)+	" AND" 
cQry	+= cEol + "	B1.B1_CNAE		= '" + cCnae +	"' AND"
cQry	+= cEol + "	B1.B1_TRIBMUN   =  '" + cTribMun +	"' AND"
cQry	+= cEol + "	B1.B1_MSBLQL <> '1' AND"
cQry	+= cEol + "	B1.D_E_L_E_T_	<> '*' AND"
cQry	+= cEol + "	B1.B1_FILIAL 	= '"+xFilial("SB1")+"'"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAli, .F., .T.)
cCodPrd	:=	(cAli)->B1_COD    
//if (cCodPrd == .F.) 
	conout("PRODUTO NÃO ENCONTRADO: GRUPO"+cGrpPrd+" CODISS: "+cCodIss+" ALIQISS:"+Str(nAlqIss)+" CNAE:"+cCnae+" TRIBMUN: "+cTribMun)  
		conout(cCodPrd)
//endif
U_FSCloAre(cAli)

Return cCodPrd

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSetPrdPht
Substitui o produto da base de integração pelo o seu produto 
respectivo no Protheus.

@protected       
@author Fernando Ferreira
@since 25/10/2011 
@param	aItePdv	- Itens do pedido de venda
@param	cCodPrdPth	- Código do produto no protheus
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FSetPrdPht(aItePdv, cCodPrdPth)
Local		aItePrc		:= {}
Local		nPosPrd		:=	0 
Local		nPosAbt		:= 0
Local		nPosIten		:= 0  
Local    nPosCF      := 0

//MAX: 11-09-2012  Desabilitado abatimento por Filial   Local		cEmpAbtMat	:= AllTrim(SuperGetMv("FS_EMPABAT", .T., ""))
Local    cMunAbt2    := RTrim(SuperGetMv("FS_MUNABT2", .T., ""))


Default	aItePdv		:=	{}
Default	cCodPrdPth  :=	""


If !Empty(aItePdv) .And. !Empty(cCodPrdPth)
	nPosPrd	:=	aScan( aItePdv[1],{ |x| Alltrim(x[1]) == "C6_PRODUTO" } ) 
	nPosAbt	:= aScan( aItePdv[1],{ |x| Alltrim(x[1]) == "C6_ABATMAT" } ) 
	nPosIten	:= aScan( aItePdv[1],{ |x| Alltrim(x[1]) == "C6_ITEM" } ) 
	nPosCF  	:= aScan( aItePdv[1],{ |x| Alltrim(x[1]) == "C6_CF" } )  //MAX: Verificar CFOP
			
	For nXi	:= 1 To Len(aItePdv)
		aItePdv[nXi][nPosPrd][2]	:=	cCodPrdPth
		aItePdv[nXi][nPosIten][2]	:=	StrZero(nXi, 2)

		IF cTip == "1"
		   aItePdv[nXi][nPosCF][2]  :=	"5949" //MAX: Força CFOP correto
		EndIF   
		
		//IF cTip == "2" .AND. (cEstCli <> cEmpEst)
		//   aItePdv[nXi][nPosCF][2]   	:=	iif(substr(aItePdv[nXi][nPosCF][2], 1, 1)="6", "5"+substr(aItePdv[nXi][nPosCF][2], 2, 3), aItePdv[nXi][nPosCF][2])   //MAX: Força CFOP correto
		//EndIF   

	
		If (cNumPed $ cMunAbt2) //MAX: Abatimento será por município // Desabilitado abatimento por filial  (cFilAnt $ cEmpAbtMat)
			aItePdv[nXi][nPosAbt][1] := "C6_ABTMAT2"			
		EndIf
	Next
EndIf


Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FVldExcPed
Valida se o Pedido gerado pelo KP pode ser excluido da base Protheus.

@protected       
@author Fernando Ferreira
@since 25/10/2011 
@param	cFil	- Filial Corrente
@param	cNumPedInt	- Número do Pedido no KP
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FVldExcPed(cFil, cNumPedInt)
Local 	aAreSc5		:=	GetArea("SC5")
Local		lret			:=	.F.

Default	cFil			:= xFilial("SC6")
Default	cNumPedInt  :=	""

SC5->(dbOrderNickName("FSIND00002"))

SC5->(dbSeek(cFil+cNumPedInt))

If SC5->(!Eof())
	lRet := SC5->C5_ZTIPO == "2" .And. Empty(SC5->C5_NOTA)
EndIf

RestArea(aAreSc5)

Return lRet

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetMsgPdr
Valida as mensagens padrão cadastradas na SM4

@protected       
@author Fernando Ferreira
@since 23/02/2012
@return	aMsgVld	- Códigos Validados
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FGetMsgPdr()
Local		aMsgVld	:= {}
Local 	aAreOld	:= {GetArea("SM4")}
Local		aMsgPdr	:= StrToKarr(AllTrim(SuperGetMv( "FS_MSGPDR" , .F., "001,002,003,004" )),",")

// M4_FILIAL+M4_CODIGO
SM4->(dbSetOrder(1))
For nXi := 1 To Len(aMsgPdr)
	SM4->(dbSeek(xFilial("SM4")+aMsgPdr[nXi]))
	If SM4->(!Eof()) 	.And. SM4->M4_FILIAL == xFilial("SM4");
							.And. SM4->M4_CODIGO == aMsgPdr[nXi]
		AAdd(aMsgVld, aMsgPdr[nXi])
	Else
		AAdd(aMsgVld, CriaVar("SM4->M4_CODIGO"))	
	EndIf
Next nXi

aEval(aAreOld, {|xAux| RestArea(xAux)})
Return AClone(aMsgVld)

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetCodEst
Retorna o código do estado 

@protected       
@author Fernando Ferreira
@since 20/03/2012
@param	cSigEst	- Sigla do Estado 
@return	cCod		- Código do Estado
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FGetCodEst(cSigEst)
Local		cCod		:= ""   
Local		nPosEst	:= 0

Local		aUF		:= {}
Default	cSigEst  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenchimento do Array de UF                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"EX","99"})

If !Empty(AllTrim(cSigEst))
	nPosEst	:= aScan( aUF,{ |x| Alltrim(x[1]) == cSigEst } )
	If nPosEst > 0
		cCod := 	aUF[nPosEst][2]
	EndIf
EndIf

Return cCod

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGetDesMun
Retorna o código do estado 

@protected       
@author Fernando Ferreira
@since 20/03/2012
@param	cEst		- Sigla do Estado 
@param	cCodMun	- Código do Municipio 
@return	cDesMun	- Descrição do Municipio
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------
Static Function FGetDesMun(cEst, cCodMun)
Local		aAreOld	:= {CC2->(GetArea())}
Local		cDesMun	:= ""

Default	cEst		:= ""
Default	cCodMun	:= ""

// CC2_FILIAL+CC2_EST+CC2_CODMUN
CC2->(dbSetOrder(1))

CC2->(dbSeek(xFilial("CC2")+cEst+cCodMun))

If CC2->(!Eof()) 	.And. CC2->CC2_FILIAL  	== xFilial("CC2");
						.And.	CC2->CC2_EST		== cEst;
						.And.	CC2->CC2_CODMUN	== cCodMun
	cDesMun	:= CC2->CC2_MUN	
EndIf
aEval(aAreOld, {|xAux| RestArea(xAux)})
Return cDesMun
                   
              
                                                                                                                                                                              