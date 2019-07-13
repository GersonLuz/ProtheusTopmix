#INCLUDE "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} MCMTA130

Chamadas das rotinas padrões do protheus para o compras

@param  
@author Rodrigo Carvalho
@since  26/01/2016
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------

User Function MCMTA130(cAlias, nRegSC1 , nOpcX )

Local aAliasOLD   := GetArea()
Local aCores      := {}
Local aCoresNew   := {}
Local aGrupo	   := {}
                  
Local cGrupComp   := ""
Local cFiltroSC1  := ""
Local cQueryGrp   := ""
Local cAuxFil     := "" 
Local cFilQry     := "" 
Local ca130User   := RetCodUsr()
                  
Local nCntFor	   := 0
Local nX          := 0    

Local lFiltra	   := .F.
Local lContinua   := .T.
Local lFiltro     := IIf(Type("lChk") == "U",.F.,lChk)
Local aFiltra     := {}

Local lPrjCni     := .F. //FindFunction("ValidaCNI") .And. ValidaCNI()
Local cTpCto      := IIf( lPrjCni, GETMV("MV_TPSCCT"), '')

Private aRotina   := MenuDef()
Private aRecMark  := {}
Private cCadastro := "Solicitações de Compra"
Private cMarca    := GetMark()
Private lInverte  := .F.
Private lMultCot  := GetNewPar("MV_MULTCOT",.F.) // Ativa o Uso da Cotacao MultUsuario permitindo que mais de um usuario utilize a rotina simultaneamente
Private cQuerySC1 := ""

Private aRotina	:= {{ "Pesquisar"   ,"PesqBrw"    ,0,1,0,.F.},;
						    { "Visualiza"   ,"A130VisuSC" ,0,2,0,NIL},;
						    { "Gera Cotacao","A130Gera"   ,0,4,0,nil},;
						    { "Legenda"     ,"A130Legenda",0,5,0,.F.}}
lTrm := .F.  

cFilOld := cFilAnt
cFilAnt := SC1->C1_FILIAL

DbSelectArea("SC1")
DbGoto(nRegSC1)

DbSelectArea("SA5")
DbCloseArea()

aAdd(aCores,{'C1_FLAGGCT=="1"' , 'LIGHTBLU'})	//SC Totalmente Atendida pelo SIGAGCT
aAdd(aCores,{'!Empty(C1_RESIDUO)'													             ,'BR_PRETO'  })//SC Eliminada por Residuo
aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV$" ,L"'	 ,'ENABLE'	  })//SC em Aberto
aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV="R"' 	 ,'BR_LARANJA'})//SC Rejeitada
aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV="B"' 	 ,'BR_CINZA'  })//SC Bloqueada
aAdd(aCores,{'C1_QUJE==C1_QUANT'													                ,'DISABLE'	  })//SC com Pedido Colocado
aAdd(aCores,{'C1_QUJE>0'															                ,'BR_AMARELO'})//SC com Pedido Colocado Parcial
aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)).And. C1_IMPORT <>"S"','BR_AZUL'	  })//SC em Processo de Cotacao
aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)).And. C1_IMPORT =="S"','BR_PINK'	  })//SC com Produto Importado

Pergunte("MTA130",.f.)

If lFiltro
   lContinua := ( Pergunte("MTA130",.T.) )                                                             
   If lContinua
      lFiltra := ( MV_PAR05==1 .Or. MV_PAR01==1 .Or. !Empty(cFiltroSC1) .Or. !Empty(cGrupComp) .Or. lTrm )
   Endif
Endif 


If lContinua

	If ( SuperGetMv("MV_RESTCOM",.F.,"N")=="S")

		aGrupo := UsrGrComp(RetCodUsr())
		
		If ( Ascan(aGrupo,"*") == 0 )
		   
		   cGrupComp  := ".And.(C1_GRUPCOM=='"+Space(Len(SC1->C1_GRUPCOM))+"'"
			cQueryGrp  += " AND (C1_GRUPCOM='" +Space(Len(SC1->C1_GRUPCOM))+"'"
			
			For nCntFor := 1 To Len(aGrupo)
				 If nCntFor == 1
				    cGrupComp += ".Or.C1_GRUPCOM $ '"+aGrupo[nCntFor]+""
					 cQueryGrp += " OR C1_GRUPCOM IN ('"+aGrupo[nCntFor]+"'"	
			    Else
					 cGrupComp += ","+aGrupo[nCntFor]
					 cQueryGrp += ",'"+aGrupo[nCntFor]+"'"					
				 Endif	
			Next nCntFor
			
			If Len(aGrupo) > 0
				cGrupComp  += "'"
				cQueryGrp  += ")"
			Endif
			
			cGrupComp  += ")"
			cQueryGrp  += ")"
			
		EndIf
	EndIf

	
    cFiltroSC1 += ".And.C1_FILIAL=='"+xFilial("SC1")+"'"
	cQuerySC1  += " AND C1_FILIAL='"+xFilial("SC1")+"'"
	
	If ! lFiltro
	   cFiltroSC1 += ".And.C1_NUM == '"+SC1->C1_NUM+"'"
      cQuerySC1  += " AND C1_NUM =  '"+SC1->C1_NUM+"'"
   Else
	   cFiltroSC1 += ".And.C1_NUM >= '"+MV_PAR09+"'"
      cQuerySC1  += " AND C1_NUM >= '"+MV_PAR09+"'"
	   cFiltroSC1 += ".And.C1_NUM <= '"+MV_PAR10+"'"
      cQuerySC1  += " AND C1_NUM <= '"+MV_PAR10+"'"
	Endif
	
	cFiltroSC1 += ".And.C1_COTACAO == '"+Space(Len(SC1->C1_COTACAO))+"' .And.C1_QUJE < C1_QUANT .And. C1_TPOP <> 'P' .And. C1_APROV $ ' ,L'"
	cQuerySC1  += " AND C1_COTACAO =  '"+Space(Len(SC1->C1_COTACAO))+"'  AND C1_QUJE < C1_QUANT  AND  C1_TPOP <> 'P'  AND  C1_APROV IN(' ','L') "
      
	If ( lFiltra .And. lFiltro )
	
		If ( MV_PAR01==1 ) // Filtra por Data
			cFiltroSC1+= ".And.Dtos(C1_EMISSAO) >= '"+Dtos(MV_PAR02)+"'"
			cQuerySC1 += " AND C1_EMISSAO       >= '"+Dtos(MV_PAR02)+"'"
			cFiltroSC1+= ".And.Dtos(C1_EMISSAO) <= '"+Dtos(MV_PAR03)+"'"
			cQuerySC1 += " AND C1_EMISSAO       <= '"+Dtos(MV_PAR03)+"'"
		EndIf    
			
		If ( MV_PAR05==1 )
			//cFiltroSC1+= ".And.C1_COTACAO == '"+Space(Len(SC1->C1_COTACAO))+"' .And.C1_QUJE < C1_QUANT .And. C1_TPOP <> 'P' .And. C1_APROV $ ' ,L'"
			//cQuerySC1 += " AND C1_COTACAO =  '"+Space(Len(SC1->C1_COTACAO))+"'  AND C1_QUJE < C1_QUANT  AND  C1_TPOP <> 'P'  AND  C1_APROV IN(' ','L') "
		EndIf
			
		If !Empty(MV_PAR12)
			cFiltroSC1+= ".And. C1_CC >= '"+MV_PAR12+"'"
			cQuerySC1 += " AND  C1_CC >= '"+MV_PAR12+"'"
		EndIf
			
		If !Empty(MV_PAR13)
			cFiltroSC1+= ".And. C1_CC <= '"+MV_PAR13+"'"
			cQuerySC1 += " AND  C1_CC <= '"+MV_PAR13+"'"
		EndIf
			
		If SC1->(FieldPos("C1_TPSC")) > 0
			cFiltroSC1+= ".And. C1_TPSC <> '2'"
			cQuerySC1 += " AND  C1_TPSC <> '2'"
		EndIf
	
		cFiltroSC1 += cGrupComp
		cQuerySC1  += cQueryGrp
	
		If lTrm
			cFiltroSC1 += ".And. C1_ORIGEM == 'TRM     ' "
			cQuerySC1  += " AND  C1_ORIGEM =  'TRM     ' "
		EndIf                           
			
		If lPrjCni
			cFiltroSC1 += ".And. C1_XTIPOSC <> '"+cTpCto+"' " // TIPO DE SC ADITIVO CONTRATO
			cQuerySC1  += " AND C1_XTIPOSC <> '"+cTpCto+"' " // TIPO DE SC ADITIVO CONTRATO
			If ExistBlock("MT130IFC")
				aFiltra := ExecBlock("MT130IFC",.F.,.F.)
				cFiltroSC1 += aFiltra[1]
				cQuerySC1  += aFiltra[2]
			EndIf

		EndIf
	
	Else
	
		dbSelectArea("SC1")
		MsSeek(xFilial("SC1"))
			
		If lPrjCni
			cFiltroSC1 = "C1_XTIPOSC <> '"+cTpCto+"'" // TIPO DE SC ADITIVO CONTRATO
			cQuerySC1  = "C1_XTIPOSC <> '"+cTpCto+"'" // TIPO DE SC ADITIVO CONTRATO 
		EndIf
			
	EndIf

	cFiltroSc1:=SubStr(cFiltroSC1,6)
	cQuerySc1 :=SubStr(cQuerySC1,6)

	cFiltroSC1 += IIF(Empty(cFiltroSC1),"C1_FLAGGCT <> '1'"," .And. C1_FLAGGCT <> '1'")
	aIndexSC1  := {}
	bFiltraBrw := {|x| IIf(x==Nil,FilBrowse("SC1",@aIndexSC1,@cFiltroSC1),{cFiltroSC1,cQuerySC1,cAuxFil,aIndexSC1}) }
	Eval(bFiltraBrw)
	dbGotop()
				
	If !SC1->(EOF()) .Or. SC1->(FieldPos("C1_COMPRAC")) > 0
		MarkBrow("SC1","C1_OK","(C1_COTACAO+IIf(C1_TPOP=='P'.Or.(C1_APROV$'R,B'),'X',' '))",,lInverte,cMarca,"A130AllMark()",,,,"A130Mark()",,,,aCores)
	Else
		Help(" ",1,"RECNO")
		lContinua := .F.
	EndIf

	EndFilBrw("SC1",aIndexSC1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A rotina a seguir varre o Array aRecMark com os registros locados pela  ³
	//³markbrowse quando o MV_MULTCOT estiver ativo para limpar as marcas reali³
	//³zadas no C1_OK de todos os registros marcados pelo usuario.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("SC1") 
   For nX:=1 To Len(aRecMark) 
		 
		 SC1->( dbGoto( aRecMark[nX] ) )   
		 IF IsInCallStack("FWMARKBROWSE")
		    If IsMark("C1_OK",cMarca)
			    If SimpleLock("SC1",.F.)
				    SC1->C1_OK      := Space(Len(SC1->C1_OK))   
				    If SC1->(FieldPos("C1_USRCODE")) > 0
				       SC1->C1_USRCODE := Space(Len(SC1->C1_USRCODE)) 
				    EndIf
		       MsUnLock()
		       EndIf
	       EndIf
		 EndIf
	Next nX 

	SC1->(dbCommit())					
	
	//dbSelectArea("SC8") 20160216
	//dbClearFilter()
	//RetIndex("SC8")

	If ( RpcCheckTbi() )
		Processa({|| TbiSendCot(,,.T.,StrZero(MV_PAR08,1))})
	EndIf     
	
EndIf

RestArea(aAliasOLD)

DbSelectArea("SC1")

cAuxFilter := "("+cFilterSC1+")" 
aIndexSC1  := {}
bFiltraBrw := {|| FilBrowse("SC1",@aIndexSC1,@cAuxFilter) }
Eval(bFiltraBrw)   
SET FILTER TO &(cAuxFilter)

DbGoto(nRegSC1)
cFilAnt := cFilOld

SysRefresh()

Return(Nil)
