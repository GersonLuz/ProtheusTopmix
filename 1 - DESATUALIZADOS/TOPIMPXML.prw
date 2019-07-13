// #########################################################################################
// Projeto:
// Modulo :
// Fonte  : TOPIMPXML
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor       | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 16/06/17 | CRISTIANO FERREIRA DE OLIVEIRA - TOTVS | Developer Studio | Importação XML
// ---------+-------------------+-----------------------------------------------------------

#include "RWMAKE.CH"
#include "PROTHEUS.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} novo
Permite a manutenção de dados armazenados em .

@author    TOTVS | Developer Studio - Gerado pelo Assistente de Código
@version   1.xx
@since     16.06.2017
/*/ 
//------------------------------------------------------------------------------------------
User Function TOPIMPXML()
  
Local nOpc	       := GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_MULTISELECT  //GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE 
Local cEdtArq	    := SPACE(200)
Local nRGrpTipNF	 := 1
Local oEdtArq                                                                                     	
Local oRGrpTipNF
Local oBitmap

Private _oDlg				
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        

DEFINE MSDIALOG _oDlg TITLE "Importacao XML NFE2" FROM C(276),C(473) TO C(545),C(909) PIXEL

	// Cria Componentes Padroes do Sistema
	@ C(015),C(040) MsGet oEdtArq Var cEdtArq Size C(162),C(008) COLOR CLR_BLACK PIXEL OF _oDlg 
	@ C(015),C(203) Button "XML" Size C(014),C(010) PIXEL OF _oDlg Action( cEdtArq:= cGetFile('Arquivo XML |*.xml ','Selecione Caminho onde estão os Xmls',,GETMV("MV_TOPXML"),,nOpc,) )
	@ C(016),C(015) Say "Arquivo" Size C(020),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(038),C(014) TO C(072),C(107) LABEL "Tipo Nota Fiscal" PIXEL OF _oDlg
	@ C(045),C(017) Radio oRGrpTipNF Var nRGrpTipNF Items "Normal","Devolucao","Beneficiamento" 3D Size C(056),C(010) PIXEL OF _oDlg
	@ C(038),C(132) BITMAP oBitmap SIZE 075, 050 OF _oDlg FILENAME "\system\lgrl.bmp" NOBORDER PIXEL
	@ C(105),C(113) Button "Importa" Size C(037),C(012) PIXEL OF _oDlg Action( GeraPreNota(Alltrim(cEdtArq),nRGrpTipNF ) )
	@ C(105),C(165) Button "Cancela" Size C(037),C(012) PIXEL OF _oDlg Action _oDlg:End()

ACTIVATE MSDIALOG _oDlg CENTERED 

Return(.T.)

//--------------------------------------------------------------------------------------------------------------
Static Function GeraPreNota(cFile,nTipoNF)

Local 	cAviso 	:= ""
Local 	cErro  	:= ""
Local 	nBtLidos := 0
Local 	cBuffer  := ""
Local    nTamFile := 0
Local    cErro    := ""
//Local		aArea := GetArea()
//Local 	aAreaM0 := SM0->(GetArea()) 
Local		eTransf := .F.
Local aEmpresas := FWLoadSM0()

Private nHdl    	:= 0
Private oNF 
Private oNFE
Private oEmitente  
Private oIdent     
Private oDestino   
Private oTotal     
Private oTransp    
Private oDet         
Private oICM		  := Nil
Private oIMP
Private aCabec      := {}
Private aItens 	  := {}
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T. 
Private cversao     := ""
Private cProdNF     := ""
Private aFile       := ""
Private nY          := 0
Private cUnid1, cUnid2




aFile := Separa(Alltrim(cFile),'|',.F.) 

 For nY:=1 To Len(aFile)// IMPORTAR MAIS DE UM XML POR IMPORTAÇÃO
   cFile:= ALLTRIM(aFile[nY]) 
	If File(cFile) 
	
		nHdl    := fOpen(cFile,0)
	   aCabec  := {} // LIMPAR ARRAY PARA IMPORTAÇÃO DOS XMLs
      aItens  := {} // LIMPAR ARRAY PARA IMPORTAÇÃO DOS XMLs
		If nHdl == -1 
		
			If !Empty(cFile)
				MsgAlert("O arquivo de nome "+cFile+" nao pode ser aberto! Verifique os parametros.","Atencao!")
			Endif
			Return
		Else	
		
			nTamFile := fSeek(nHdl,0,2)
			fSeek(nHdl,0,0)
			cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
			nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
			fClose(nHdl)
			
			cAviso := ""
			cErro  := ""
			oNfe := XmlParser(cBuffer,"_",@cAviso,@cErro)

			If Type("oNFe:_NfeProc")<> "U"
				oNF := oNFe:_NFeProc:_NFe
			Else
				oNF := oNFe:_NFe
			Endif
			cversao    := oNF:_InfNfe:_VERSAO:TEXT  // Tratamento 3.10
			oEmitente  := oNF:_InfNfe:_Emit
			oIdent     := oNF:_InfNfe:_IDE
			oDestino   := oNF:_InfNfe:_Dest
			oTotal     := oNF:_InfNfe:_Total
			oTransp    := oNF:_InfNfe:_Transp
			oDet       := oNF:_InfNfe:_Det
			
			if Type("oDet") != "A"
				oTmp := oDet
				oDet := {}
				aadd(oDet,oTmp)
			Endif	
			
			cChave     := Substr(Alltrim(oNF:_INFNFE:_ID:Text),4)
			cCnpjDest  := AllTrim(IIf(Type("oDestino:_CPF")=="U",oDestino:_CNPJ:TEXT,oDestino:_CPF:TEXT))
			
			If !NFEValidDV(cChave)
				MsgAlert("Chave do XML é invalida")
				Return
			Endif	
				
			
			IF Alltrim(SM0->M0_CGC) != Alltrim(cCnpjDest)
				MsgAlert("Esta NF não pertence a filial: "+SM0->M0_FILIAL)
				Return			
			Endif	  
			
			
			
									
			
	    	nVlDescNF  := Val(oTotal:_ICMSTOT:_VDESC:Text)
	    	nVlSegNF   := 0
	    	nVlFrtNF   := Val(oTotal:_ICMSTOT:_VFRETE:Text)
			nVPis      := Val(oTotal:_ICMSTOT:_VPIS:Text)
			nVCofins	  := Val(oTotal:_ICMSTOT:_VCOFINS:Text)
	    
			If Type("oNF:_InfNfe:_ICMS")<> "U"
				oICM       := oNF:_InfNfe:_ICMS
			Else
				oICM		:= nil
			Endif
			
			// Validações -------------------------------
			// -- CNPJ da NOTA = CNPJ do CLIENTE ? oEmitente:_CNPJ
			If nTipoNF = 1
				cTipo := "N"
			ElseIF nTipoNF = 2
				cTipo := "B"
			ElseIF nTipoNF = 3
				cTipo := "D"
			Endif
		
			// CNPJ ou CPF
			cCgc := AllTrim(IIf(Type("oEmitente:_CPF")=="U",oEmitente:_CNPJ:TEXT,oEmitente:_CPF:TEXT))
			
			// Rotina para verificar se a Nota é uma transferencia, adicionada por Lucas Borges em 19/10/17 
			eTransf := .F.
			For i := 1 to Len(aEmpresas)
				If cCgc == aEmpresas[i][18]
	               eTransf := .T.
	               Exit
	  			EndIf
          Next		
			
			
			
		
		  
			
			  // !-- Fim teste NFe de transferencia
			If nTipoNF = 1 // Nota Normal Fornecedor
				SA2->(dbSetOrder(3))
				If !SA2->(dbSeek(xFilial("SA2")+cCgc))
					MsgAlert("CNPJ Origem Não Localizado - Verifique " + cCgc)
					Return
				Endif
			Else
				SA1->(dbSetOrder(3))
				If !SA1->(dbSeek(xFilial("SA1")+cCgc))
					MsgAlert("CNPJ Origem Não Localizado - Verifique " + cCgc)
					Return
				Endif
			Endif
			
		  /*	If !TestaProduto(nTipoNF)    RETIRADO 21.06.2017
				If nTipoNF = 1
					MsgAlert("Faltam informacao no cadastro de vinculo produtoXfornecedor")
					Return
				Else	
					MsgAlert("Faltam informacao no cadastro de vinculo produtoXcliente")
					Return
				Endif	
			Endif	*/                                                     
	
			// Verifica se Nota Fiscal ja foi importada
			If SF1->(DbSeek(xFilial("SF1")+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+Padr(OIdent:_serie:TEXT,3)+SA2->A2_COD+SA2->A2_LOJA))
				If nTipoNF = 1
					MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Fornec. "+SA2->A2_COD+"/"+SA2->A2_LOJA+" Ja Existe. A Importacao sera interrompida")
				Else
					MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do Cliente "+SA1->A1_COD+"/"+SA1->A1_LOJA+" Ja Existe. A Importacao sera interrompida")
				Endif
				Return  
			EndIf
	
			aadd(aCabec,{"F1_TIPO"   ,cTipo,Nil,Nil})
			aadd(aCabec,{"F1_FORMUL" ,"N",Nil,Nil})
			aadd(aCabec,{"F1_DOC"    ,Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9),Nil,Nil})
			aadd(aCabec,{"F1_SERIE"  ,Right("000"+Alltrim(OIdent:_serie:TEXT),3),Nil,Nil})
			if cversao == "3.10" .Or. cversao == "4.00" 
				cData:=left(Alltrim(OIdent:_dhEmi:TEXT),10) 
			Else 
		    	cData:=Alltrim(OIdent:_dEmi:TEXT)
			endIf  
			dData:=CTOD(Right(cData,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))
			aadd(aCabec,{"F1_EMISSAO",dData,Nil,Nil})
			aadd(aCabec,{"F1_FORNECE",If(nTipoNF=1,SA2->A2_COD,SA1->A1_COD),Nil,Nil})
			aadd(aCabec,{"F1_LOJA"   ,If(nTipoNF=1,SA2->A2_LOJA,SA1->A1_LOJA),Nil,Nil})
			aadd(aCabec,{"F1_ESPECIE","SPED",Nil,Nil})
			aadd(aCabec,{"F1_CHVNFE",cChave,Nil,Nil})
			aadd(aCabec,{"F1_IMPORTD",.T.,Nil,Nil})
			For nX := 1 To Len(oDet)
				aLinha := {}
				cProduto	:=	oDet[nX]:_Prod:_cProd:TEXT//Right(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),TamSX3("B1_COD")[1])
				cNCM		:=	IIF(Type("oDet[nX]:_Prod:_NCM")=="U",space(12),oDet[nX]:_Prod:_NCM:TEXT)
			   
			   If eTransf
			   	cProdNF:= oDet[nX]:_Prod:_cProd:TEXT
				Elseif nTipoNF = 1
					SA5->(DbSetOrder(14))   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
					SA5->(dbSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA+cProduto))
					SB1->(dbSetOrder(1) , IIF (!dbSeek(xFilial("SB1")+SA5->A5_PRODUTO),cProdNF:= GETMV("MV_TOPPROD"), cProdNF:= SB1->B1_COD))
				Else
					SA7->(DbSetOrder(3))
					SA7->(dbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+cProduto))
					SB1->(dbSetOrder(1) , IIF (!dbSeek(xFilial("SB1")+SA7->A7_PRODUTO),cProdNF:= GETMV("MV_TOPPROD"), cProdNF:= SB1->B1_COD))
				Endif
				 
				aadd(aLinha,{"D1_COD",cProdNF,Nil,Nil}) //Emerson Holanda   
				
					If(xFilial("SF1") == '010101') // O CENTRO DE CUSTO DA MATRIZ NÃO SEGUE PADRÃO DAS OUTRAS FILIAIS
						aadd(aLinha,{"D1_CC",'00'+SUBSTR(xFilial("SF1"),5,6)+'190',Nil,Nil}) //CRISTIANO FERREIRA - INFORMAR CENTRO DE CUSTO DA FILIAL LOGADA 23.06.2017
					Else
						aadd(aLinha,{"D1_CC",'0001080',Nil,Nil}) //CRISTIANO FERREIRA - INFORMAR CENTRO DE CUSTO DA FILIAL LOGADA 23.06.2017
					Endif
				
				cUnid1 := (Posicione("SB1",1,xFilial("SB1") + cProdNF ,"B1_UM"))
				cUnid2 := (Posicione("SB1",1,xFilial("SB1") + cProdNF ,"B1_SEGUM")) 
				
				aadd(aLinha,{"D1_UM",  cUnid1,Nil,Nil})     // UNIDADE DE MEDIDA É INFORMADA PELO CADASTRO DE PRODUTO
				aadd(aLinha,{"D1_SEGUM",  cUnid2,Nil,Nil}) // UNIDADE DE MEDIDA É INFORMADA PELO CADASTRO DE PRODUTO
			
				If Val(oDet[nX]:_Prod:_qTrib:TEXT) != 0
				  If (cUnid1 = cUnid2) .OR. Empty(cUnid2) // PRIMEIRA UNIDADE IGUAL A SEGUNDA UNIDADE NÃO HAVERÁ CONVERSÃO DE VALORES - CRISTIANO FERREIRA 21.07.2017 
					aadd(aLinha,{"D1_QUANT",Val(oDet[nX]:_Prod:_qTrib:TEXT),Nil,Nil})
					aadd(aLinha,{"D1_VUNIT",Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qTrib:TEXT),6),Nil,Nil})
				  Else
				   aadd(aLinha,{"D1_QUANT",(Val(oDet[nX]:_Prod:_qTrib:TEXT)*1000),Nil,Nil})
				   aadd(aLinha,{"D1_VUNIT",Round((Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qTrib:TEXT)/1000),6),Nil,Nil})
				  Endif									  
				Else
				  If(cUnid1 = cUnid2) .OR. Empty(cUnid2)  // PRIMEIRA UNIDADE IGUAL A SEGUNDA UNIDADE NÃO HAVERÁ CONVERSÃO DE VALORES - CRISTIANO FERREIRA 21.07.2017 
					aadd(aLinha,{"D1_QUANT",Val(oDet[nX]:_Prod:_qCom:TEXT),Nil,Nil})
				  Else
				   aadd(aLinha,{"D1_QUANT",(Val(oDet[nX]:_Prod:_qTrib:TEXT)*1000),Nil,Nil})
				  Endif
					aadd(aLinha,{"D1_VUNIT",Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qCom:TEXT),6),Nil,Nil})
				Endif
				aadd(aLinha,{"D1_TOTAL",Val(oDet[nX]:_Prod:_vProd:TEXT),Nil,Nil})
				_cfop:=oDet[nX]:_Prod:_CFOP:TEXT
				If Left(Alltrim(_cfop),1)="5"
					_cfop:=Stuff(_cfop,1,1,"1")
				Else
					_cfop:=Stuff(_cfop,1,1,"2")
				Endif
				If Type("oDet[nX]:_Prod:_vDesc")<> "U"
					aadd(aLinha,{"D1_VALDESC",Val(oDet[nX]:_Prod:_vDesc:TEXT),Nil,Nil})
				Endif
				Do Case
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS00") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS00
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS10") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS10
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS20") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS20
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS30") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS30
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS40") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS40
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS51") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS51
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS60")<> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS60
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS70")<> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS70
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS90")<> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS90
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMSSN102")<> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMSSN102
					OtherWise
						oICM := Nil							
				EndCase	
				
				if oICM != Nil
					oOrg1 := XmlChildEx(oICM,"_ORIG")
					oOrg2 := XmlChildEx(oICM,"_CST")

					CST_Aux:=iif(oOrg1 != Nil,Alltrim(oOrg1:TEXT),"")+iif(oOrg2 != Nil,Alltrim(oOrg2:TEXT),"")
					aadd(aLinha,{"D1_CLASFIS",CST_Aux,Nil,Nil})
				Endif	
				aadd(aItens,aLinha)
			Next nX
			
			If Len(aItens) > 0
				Private lMsErroAuto := .F.
				Private lMsHelpAuto := .T.
		
				SB1->( dbSetOrder(1) )
				SA2->( dbSetOrder(1) )
		
			   nModulo := 4  //ESTOQUE
				MSExecAuto({|x,y,z|Mata140(x,y,z)},aCabec,aItens,3)
		
				If lMsErroAuto
			
					//xFile := STRTRAN(Upper(cFile),"XMLNFE\", "XMLNFE\ERRO\")			
					//COPY FILE &cFile TO &xFile			
					//FErase(cFile)
			
					MSGALERT("ERRO NO PROCESSO")
					MostraErro()
					cErro := 'S' // OCORREU ERRO
				Else				  
				   FErase(cFile)
				Endif	
			Endif
		Endif	
	Endif		
 Next nY
  If(	cErro <> 'S')
    MSGALERT("IMPORTAÇÃO REALIZADA COM SUCESSO")
  Endif  
return	

//---------------------------------------------------------------------------------------------
Static Function TestaProduto(nTipoNF)
Local lRet        := .T.
Local cCodPrd		:= ""
Local cDescPrd	   := ""
Local cTipoPrd	   := ""
Local cArmPrd		:= ""
Local cUnidPrd	   := ""
Local cNCMPrd   	:= ""
Local cPrdFlapa   := ""
Local cOrigem     := ""
Local aSaveArea 	:= GetArea()
Local oICM        := Nil
Local lOk         := .T.

Local cTipoTeste  := GetNewPar("MV_TESTNFE","1")

	If cTipoTeste == "1"
		
		If nTipoNF == 1
			For nX := 1 To Len(oDet)
			
				Do Case
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS00") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS00
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS10") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS10
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS20") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS20
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS30") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS30
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS40") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS40
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS51") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS51
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS60") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS60
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS70") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS70
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS90") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS90
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMSSN102") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMSSN102							
					OTherWise
						oICM:= Nil		
						
				EndCase		
			
				cCodPrd	:= Right(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),TamSX3("B1_COD")[1])
				SA5->(DbOrderNickName("FORPROD"))   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
				If !SA5->(dbSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA+cCodPrd))
					DbSelectArea("SB1")
					DbSetOrder(1)			
					cNCMPrd 	:= IIF(Type("oDet[nX]:_Prod:_NCM")=="U",space(12),oDet[nX]:_Prod:_NCM:TEXT)
					cUnidPrd	:= Alltrim(oDet[nX]:_Prod:_uTrib:TEXT)
					cDescPrd	:= Alltrim(oDet[nX]:_Prod:_xProd:TEXT)
					if oICM != Nil
						oOrg1 := XmlChildEx(oICM,"_ORIG")
						If oOrg1 != Nil
							cOrigem   := Alltrim(oOrg1:TEXT)
						Else
							cOrigem   := ""
						Endif			
					Else
						cOrigem      := ""	
					Endif
					//cPrdFlapa 	:= GETSX8NUM("SB1","B1_COD")
					cPrdFlapa 	:= U_MACODSB1("9999")
					RecLock("SB1",.T.)
					Replace B1_FILIAL 	With xFilial("SB1")
					Replace B1_COD  		With cPrdFlapa
					Replace B1_DESC		With cDescPrd
					Replace B1_GRUPO     With "9999"	
					Replace B1_LOCPAD    With "01"
					Replace B1_ZRORIG    With "2"
					Replace B1_TIPO   	With "MC"
					Replace B1_POSIPI  	With cNCMPrd
					Replace B1_UM		  	With cUnidPrd
					Replace B1_ORIGEM  	With cOrigem
					SB1->(MsUnlock())
					//ConfirmSx8()
	
					DbSelectArea("SA5")
					DbSetOrder(1)			
					RecLock("SA5",.T.)
					Replace A5_FILIAL		With xFilial("SA5")
					Replace A5_FORNECE	With SA2->A2_COD
					Replace A5_LOJA		With SA2->A2_LOJA
					Replace A5_PRODUTO	With cPrdFlapa
					Replace A5_CODPRF		With cCodPrd
					SA5->(MsUnlock())
				Endif
			Next
		Else	
			For nX := 1 To Len(oDet)
			
				Do Case
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS00") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS00
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS10") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS10
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS20") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS20
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS30") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS30
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS40") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS40
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS51") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS51
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS60") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS60
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS70") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS70
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS90") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMS90
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMSSN102") <> "U"
						oICM:= oDet[nX]:_Imposto:_ICMS:_ICMSSN102							
					OtherWise
						oICM:= Nil	
				EndCase		
			
				cCodPrd	:= Right(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),TamSX3("B1_COD")[1])
				SA7->(DbOrderNickName("CLIPROD"))   // FILIAL + CLIENTE + LOJA + CODIGO PRODUTO DO CLIENTE
				If !SA7->(dbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+cCodPrd))
					DbSelectArea("SB1")
					DbSetOrder(1)			
					cNCMPrd 	:= IIF(Type("oDet[nX]:_Prod:_NCM")=="U",space(12),oDet[nX]:_Prod:_NCM:TEXT)
					cUnidPrd	:= Alltrim(oDet[nX]:_Prod:_uTrib:TEXT)
					cDescPrd	:= Alltrim(oDet[nX]:_Prod:_xProd:TEXT)
					if oICM != Nil
						oOrg1  := XmlChildEx(oICM,"_ORIG")
						If oOrg1 != Nil
							cOrigem   := Alltrim(oOrg1:TEXT)
						Else
							cOrigem   := ""
						Endif			
					Else
						cOrigem   := ""	
					Endif
					
					//cPrdFlapa 	:= GETSX8NUM("SB1","B1_COD")
					cPrdFlapa 	:= U_MACODSB1("9999")
					RecLock("SB1",.T.)
					Replace B1_FILIAL 	With xFilial("SB1")
					Replace B1_COD  		With cPrdFlapa
					Replace B1_DESC		With cDescPrd
					Replace B1_GRUPO     With "9999"	
					Replace B1_LOCPAD    With "01"
					Replace B1_ZRORIG    With "2"
					Replace B1_TIPO   	With "MC"
					Replace B1_POSIPI  	With cNCMPrd
					Replace B1_UM		  	With cUnidPrd
					Replace B1_ORIGEM  	With cOrigem
					SB1->(MsUnlock())
					//ConfirmSx8()
	
					DbSelectArea("SA7")
					DbSetOrder(1)			
					RecLock("SA7",.T.)
					Replace SA7->A7_FILIAL 		With xFilial("SA7")
					Replace SA7->A7_CLIENTE		With SA1->A1_COD
					Replace SA7->A7_LOJA			With SA1->A1_LOJA
					Replace SA7->A7_DESCCLI 	With oDet[nX]:_Prod:_xProd:TEXT
					Replace SA7->A7_PRODUTO		With SB1->B1_COD
					Replace SA7->A7_CODCLI		With cCodPrd
					SA7->(MsUnlock())
				Endif
			Next		
		Endif	
	Else
		If cTipoTeste == "2" // Verifica e possibilita cadastrar produto x fornecedor 	
			CadPrdForn(nTipoNF)
		Endif	
	Endif
	
	// Verifica se existem todos os produtos do XMl na Base de Produto Fornecedor ou Produto Cliente
	lOk := .T.
	If nTipoNF == 1
		For nX := 1 To Len(oDet)
			cCodPrd	:= Right(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),TamSX3("B1_COD")[1])
			SA5->(DbOrderNickName("FORPROD"))   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
			If !SA5->(dbSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA+cCodPrd))
				lOk := .F.
			Endif
		Next
	Else		
		For nX := 1 To Len(oDet)
			cCodPrd	:= Right(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),TamSX3("B1_COD")[1])
			SA7->(DbOrderNickName("CLIPROD"))   // FILIAL + CLIENTE + LOJA + CODIGO PRODUTO DO CLIENTE
			If !SA7->(dbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+cCodPrd))
				lOk := .F.
			Endif
		Next
	Endif		
	
	RestArea(aSaveArea)
		
Return lOk
		
//---------------------------------------------------------------------------------------------		
Static Function CadPrdForn(nTipoNF)
Local nX          := 0

Private _oDlgPForn				
Private VISUAL 	:= .F.                        
Private INCLUI 	:= .F.                        
Private ALTERA 	:= .F.                        
Private DELETA 	:= .F.                        
Private oGetDados1
Private aCol 		:= {}  

If nTipoNF == 1
	For nX := 1 To Len(oDet)
		cDescPrd	:= Alltrim(oDet[nX]:_Prod:_xProd:TEXT)
		cCodPrd	:= Right(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),TamSX3("B1_COD")[1])
		SA5->(DbOrderNickName("FORPROD"))   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
		If !SA5->(dbSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA+cCodPrd))
			Aadd(aCol,{cCodPrd,cDescPrd,space(TamSX3("B1_COD")[1]),.f.})
		Endif
	Next
Else		
	For nX := 1 To Len(oDet)
		cDescPrd	:= Alltrim(oDet[nX]:_Prod:_xProd:TEXT)
		cCodPrd	:= Right(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),TamSX3("B1_COD")[1])
		SA7->(DbOrderNickName("CLIPROD"))   // FILIAL + CLIENTE + LOJA + CODIGO PRODUTO DO CLIENTE
		If !SA7->(dbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+cCodPrd))
			Aadd(aCol,{cCodPrd,cDescPrd,space(TamSX3("B1_COD")[1]),.f.})
		Endif
	Next
Endif			
			
If len(aCol) > 0		                      
	DEFINE MSDIALOG _oDlgPForn TITLE "Produto X Fornecedor" FROM C(239),C(258) TO C(449),C(626) PIXEL

		@ C(082),C(137) Button "Confirma" Size C(037),C(012) PIXEL OF _oDlgPForn  Action (GravaSA5SA7(nTipoNF),_oDlgPForn:End())
		fGetDados1(nTipoNF)

	ACTIVATE MSDIALOG _oDlgPForn CENTERED
Endif 

Return(.T.)


//---------------------------------------------------------------------------------------------
Static Function fGetDados1(nTipoNF)
// Variaveis deste Form                                                                                                         
Local nX				   := 0                                                                                                              
Local aCpoGDa       	:= {"A5_CODPRF","B1_DESC","D1_COD"}                                                                                                 
Local aAlter       	:= {"D1_COD"}
Local nSuperior    	:= C(009)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= C(007)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= C(069)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= C(176)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
Local nOpc         	:= GD_UPDATE                                                                            
Local cLinhaOk     	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                         // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                         // segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 999              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cCampoOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
Local cSuperApagar 	:= ""               // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cApagaOk     	:= "AllwaysTrue"    // Funcao executada para validar a exclusao de uma linha do aCols                   
Local oWnd          	:= _oDlgPForn                                                                                                  
Local aHead        	:= {}  


Private aF3cCpo   := {""      , ""        ,"SB1" }
Private aVldcCpo  := { '.T.' ,;  
						  '.T.' ,;
	                   'ExistCpo("SB1", M->D1_COD)' }

If nTipoNF == 1
	aCpoGDa      	:= {"A5_CODPRF","B1_DESC","D1_COD"}                                                                                                 
	aAlter       	:= {"D1_COD"}
Else	
	aCpoGDa      	:= {"A7_CODCLI","B1_DESC","D1_COD"}                                                                                                 
	aAlter       	:= {"D1_COD"}
Endif                    

DbSelectArea("SX3")                                                                                                             
SX3->(DbSetOrder(2)) // Campo                                                                                                   
For nX := 1 to Len(aCpoGDa)                                                                                                     
	If SX3->(DbSeek(aCpoGDa[nX]))                                                                                                 
		Aadd(aHead,{ AllTrim(X3Titulo()),;                                                                                         
			SX3->X3_CAMPO	 ,;                                                                                                       
			SX3->X3_PICTURE ,;                                                                                                       
			SX3->X3_TAMANHO ,;                                                                                                       
			SX3->X3_DECIMAL ,;                                                                                                       
			aVldcCpo[nX]	 ,;                                                                                                      
			SX3->X3_USADO	 ,;                                                                                                       
			SX3->X3_TIPO	 ,;                                                                                                       
			aF3cCpo[nX]     ,;                                                                                                       
			SX3->X3_CONTEXT ,;                                                                                                       
			SX3->X3_CBOX	 ,;                                                                                                       
			SX3->X3_RELACAO })                                                                                                       
	Endif                                                                                                                         
Next nX                                                                                                                         
                                                                                    
oGetDados1:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinhaOk,cTudoOk,cIniCpos,;                               
                             aAlter,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,oWnd,aHead,aCol)                                   
Return Nil     

//----------------------------------------------------------------------------------------------------
Static Function GravaSA5SA7(nTipoNF)
Local nXi

if nTipoNF == 1
	For nXi := 1 to len(oGetDados1:aCols)
		SA5->(DbOrderNickName("FORPROD"))   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
		If !SA5->(dbSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA+Alltrim(oGetDados1:aCols[nXi,1]) ))	
			RecLock("SA5",.T.)
			Replace A5_FILIAL		With xFilial("SA5")
			Replace A5_FORNECE	With SA2->A2_COD
			Replace A5_LOJA		With SA2->A2_LOJA
			Replace A5_PRODUTO	With Alltrim(oGetDados1:aCols[nXi,3])
			Replace A5_CODPRF		With Alltrim(oGetDados1:aCols[nXi,1])
			SA5->(MsUnlock())
		Endif	
	Next
Else			
	For nXi := 1 to len(oGetDados1:aCols)
		SA7->(DbOrderNickName("CLIPROD"))   // FILIAL + CLIENTE + LOJA + CODIGO PRODUTO DO CLIENTE
		If !SA7->(dbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+Alltrim(oGetDados1:aCols[nXi,1]) ))
			RecLock("SA7",.T.)
			Replace SA7->A7_FILIAL 		With xFilial("SA7")
			Replace SA7->A7_CLIENTE		With SA1->A1_COD
			Replace SA7->A7_LOJA			With SA1->A1_LOJA
			Replace SA7->A7_DESCCLI 	With SA1->A1_NOME
			Replace SA7->A7_PRODUTO		With Alltrim(oGetDados1:aCols[nXi,3])
			Replace SA7->A7_CODCLI		With Alltrim(oGetDados1:aCols[nXi,1])
			SA7->(MsUnlock())
		Endif		                                                                                                                 
	Next
Endif

Return	
	
//----------------------------------------------------------------------------------------------------	
Static Function C(nTam)                                                         
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)                                                                


Static Function NFEValidDV(cChave)
Local lOK    := .T.
Local aPesos := {4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2}
Local aMult  := {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
Local nSoma  := 0 
Local nResul := 0
Local i
Local cChv43 := ""

	If len(Alltrim(cChave)) != 44
		lOk := .f.
	Else          
		cChv43 := Substr(cChave,1,43)
		For i := 43 to 1 Step -1
			aMult[i] := aPesos[i]*Val(Substr(cChv43,i,1))		
		Next     

		nSoma := 0		
		For i := 1 to 43
			nSoma := nSoma+aMult[i]
		Next     
		nResul := 11-Mod(nSoma,11)
		if nResul == 0 .or. nResul >=  10
			nResul := 0
		Endif
		
		if nResul != val(Substr(cChave,44,1))
			lOk := .F.
		Endif		
	Endif	 
	
Return lOk	