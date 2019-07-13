#include "protheus.ch"

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSLIB004
Função criada para efeitos de compatibilidade evitando que seja criada uma função com o 
nome deste prw.
         
@author 		Luciano M. Pinto
@since 		25/10/2011
@version 	P11

/*/ 
//---------------------------------------------------------------------------------------
User Function FSLIB004()

Return Nil   


//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSGetCmp
Retorna os campos que serão utilizados na integração Proteus x KP
         
@author 		Luciano M. Pinto
@since 		23/08/2011
@version 	P11
@param		cAlias	Opção que define de qual tabela sera os campos retornados 
@return		aRetCmp 	Array com os campos

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo
17/11/2011 Fernando Ferreira  Foi incluido os dados da integração de Fornecedore e Vendedores

/*/ 
//---------------------------------------------------------------------------------------
User Function FSGetCmp(cAlias)

Local 	aRetCmp	:= {}

Local 	cDescVei := ""
Local 	cDescFor := ""
Local    nTamDesc := SuperGetMv("ES_TMXDESC",,50) // tamanho maximo da descricao do produto no betomix. 20160823

Default 	cAlias 	:= ""

Do Case
   Case cAlias == "SA1" // Clientes

						//NOME CAMPO KP			VALOR CAMPO PROTHEUS		NOME CAMPO PROTHEUS	
		aAdd(aRetCmp,{"FILIAL"						,xFilial("SA1")		,"A1_FILIAL"})
		aAdd(aRetCmp,{"CODIGOCLIENTE"				,SA1->A1_COD			,"A1_COD"})
		aAdd(aRetCmp,{"LOJA"							,SA1->A1_LOJA			,"A1_LOJA"})
		aAdd(aRetCmp,{"IDENTIFICA"					,SA1->A1_ZIDENT		,"A1_ZIDENT"})		
		aAdd(aRetCmp,{"GRUPOCREDITOID"			,0,})
		aAdd(aRetCmp,{"DESCRICAOGRUPOCREDITO"	,Space(1),})
		//aAdd(aRetCmp,{"TIPOBLOQUEIOID"			,IIf(!U_FSAvCli(SA1->A1_COD, SA1->A1_LOJA, .F.),"1", "2" ) ,"A1_MSBLQL"})  //MAX: 14-06-2012 nao usar bloqueio do cadastro do cliente, usar 1 para devedor e 2 normal  ,SA1->A1_MSBLQL		,"A1_MSBLQL"})
		aAdd(aRetCmp,{"TIPOBLOQUEIOID"			,SA1->A1_MSBLQL		,"A1_MSBLQL"})
		aAdd(aRetCmp,{"RAZAOSOCIAL"				,SA1->A1_NOME			,"A1_NOME"})
		aAdd(aRetCmp,{"NOMEFANTASIA"				,SA1->A1_NREDUZ		,"A1_NREDUZ"})
		aAdd(aRetCmp,{"CODIGOEXECUTIVOVENDA"	,SA1->A1_VEND			,"A1_VEND"})
		aAdd(aRetCmp,{"TIPOPESSOA"					,SA1->A1_PESSOA		,"A1_PESSOA"})
		aAdd(aRetCmp,{"CNPJCPF"						,SA1->A1_CGC			,"A1_CGC"})
		aAdd(aRetCmp,{"RG"							,SA1->A1_PFISICA		,"A1_PFISICA"})
		aAdd(aRetCmp,{"INSCRESTADUAL"				,SA1->A1_INSCR			,"A1_INSCR"})
		aAdd(aRetCmp,{"INSCRMUNICIPAL"			,SA1->A1_INSCRM		,"A1_INSCRM"})
		aAdd(aRetCmp,{"DDDFAX"						,SA1->A1_DDD			,"A1_DDD"})
		aAdd(aRetCmp,{"FAX"							,SA1->A1_FAX			,"A1_FAX"})
		aAdd(aRetCmp,{"DDDTEL"						,SA1->A1_DDD			,"A1_DDD"})
		aAdd(aRetCmp,{"TELEFONE"					,SA1->A1_TEL			,"A1_TEL"})
		aAdd(aRetCmp,{"WEBSITE"						,SA1->A1_HPAGE			,"A1_HPAGE"})
		aAdd(aRetCmp,{"RETERTRIBUTOS"				,'N',})
		aAdd(aRetCmp,{"ORGAOPUBLICO"				,'N',})
		aAdd(aRetCmp,{"LIMITECREDITO"				,SA1->A1_LC 			,"A1_LC"})
		aAdd(aRetCmp,{"CREDITOPADRAO"				,'N',})
		aAdd(aRetCmp,{"TIPOCLIENTE"				,999,})
		aAdd(aRetCmp,{"DESCRICAOTIPOCLIENTE"	,'OUTROS',})
		aAdd(aRetCmp,{"SEGMENTOID"					,999,})
		aAdd(aRetCmp,{"DESCRICAOSEGMENTO"		,'OUTROS',})
		aAdd(aRetCmp,{"ENDFISCALLOGRADOURO"		,FisGetEnd(SA1->A1_END)[1],"A1_END"})
		aAdd(aRetCmp,{"ENDFISCALNUMERO"			,Iif(FisGetEnd(SA1->A1_END)[2] <> 0,FisGetEnd(SA1->A1_END)[3],"SN"),})
		aAdd(aRetCmp,{"ENDFISCALCOMPLEMENTO"	,SA1->A1_COMPLEM	,"A1_COMPLEM"})
		aAdd(aRetCmp,{"ENDFISCALBAIRRO"			,SA1->A1_BAIRRO	,"A1_BAIRRO"})
		aAdd(aRetCmp,{"ENDFISCALMUNICIOPIOID"	,Iif(Empty(SA1->A1_COD_MUN),0,SA1->A1_COD_MUN),"A1_COD_MUN"})
		aAdd(aRetCmp,{"ENDFISCALMUNICIOPIONOME",SA1->A1_MUN		,"A1_MUN"})
		aAdd(aRetCmp,{"ENDFISCALESTADOSIGLA"	,SA1->A1_EST		,"A1_EST"})
		aAdd(aRetCmp,{"ENDFISCALCEP"				,SA1->A1_CEP		,"A1_CEP"})

   Case cAlias == "P01" // Endereços		
		aAdd(aRetCmp,{"Z1_FILIAL"					,P01->P01_FILIAL	,"P01_FILIAL"})
		aAdd(aRetCmp,{"Z1_COD"						,P01->P01_COD		,"P01_COD"	})
		aAdd(aRetCmp,{"Z1_LOJA"					   ,P01->P01_LOJA		,"P01_LOJA"	})
		aAdd(aRetCmp,{"Z1_ITEM"					   ,P01->P01_ITEM		,"P01_ITEM"	})
		aAdd(aRetCmp,{"Z1_END"						,P01->P01_END		,"P01_END"	})
		aAdd(aRetCmp,{"Z1_COMPLE"					,P01->P01_COMPLE	,"P01_COMPLE"})
		aAdd(aRetCmp,{"Z1_BAIRRO"					,P01->P01_BAIRRO	,"P01_BAIRRO"})
		aAdd(aRetCmp,{"Z1_CODMUN"					,P01->P01_CODMUN	,"P01_CODMUN"})
		aAdd(aRetCmp,{"Z1_MUN"						,P01->P01_MUN		,"P01_MUN"	})
		aAdd(aRetCmp,{"Z1_EST"						,P01->P01_EST		,"P01_EST"	})
		aAdd(aRetCmp,{"Z1_CEP"						,P01->P01_CEP		,"P01_CEP"	})

   Case cAlias == "SA2"
						//NOME CAMPO KP			VALOR CAMPO PROTHEUS		NOME CAMPO PROTHEUS	
		aAdd(aRetCmp,{"CENTRAL"					,SA2->A2_FILIAL				,"A2_FILIAL"	})
		aAdd(aRetCmp,{"CODIGOFORNECEDOR"		,SA2->A2_COD					,"A2_COD"		})
		aAdd(aRetCmp,{"LOJA"						,SA2->A2_LOJA					,"A2_LOJA"	})
		aAdd(aRetCmp,{"RAZAOSOCIAL"			,SA2->A2_NOME					,"A2_NOME"	})
		aAdd(aRetCmp,{"CNPJ"						,SA2->A2_CGC					,"A2_CGC"		})
		aAdd(aRetCmp,{"A2_KPID"					,SA2->A2_KPID					,"A2_KPID"		})
		
   Case cAlias == "SA3"
						//NOME CAMPO KP			VALOR CAMPO PROTHEUS		NOME CAMPO PROTHEUS	
		aAdd(aRetCmp,{"CENTRAL"					,SA3->A3_FILIAL				,"A3_FILIAL"	})
		aAdd(aRetCmp,{"CODIGOVENDEDOR"		,SA3->A3_COD					,"A3_COD"		})
		aAdd(aRetCmp,{"NOMEVENDEDOR"			,SA3->A3_NOME					,"A3_LOJA"	})
		aAdd(aRetCmp,{"A3_KPID"					,SA3->A3_KPID					,"A3_KPID"	})

		
   Case cAlias == "DA3"
   
	   cDescVei := Posicione("DUT",1,xFilial("DUT") + DA3->DA3_TIPVEI,'DUT_DESCRI ')
		cDescFor := Posicione("SA2",1,xFilial("SA2") + DA3->DA3_CODFOR + DA3->DA3_LOJFOR,'A2_NOME')

						//NOME CAMPO KP			VALOR CAMPO PROTHEUS									NOME CAMPO PROTHEUS	
		aAdd(aRetCmp,{"CODIGOCENTRAL"			,xFilial("DA3")										,"DA3_FILIAL"})
		aAdd(aRetCmp,{"CODIGOVEICULO"			,DA3->DA3_COD											,"DA3_COD"})
		aAdd(aRetCmp,{"IDENTIFICA"				,DA3->DA3_ZIDENT										,"DA3_ZIDENT"})
		aAdd(aRetCmp,{"DESCRICAO"				,DA3->DA3_DESC											,"DA3_DESC"})
		aAdd(aRetCmp,{"CODIGOTIPOVEICULO"	,Iif(Empty(DA3->DA3_TIPVEI),0,DA3->DA3_TIPVEI),"DA3_TIPVEI"})
		aAdd(aRetCmp,{"DESCRICAOTIPO"			,cDescVei												,}) // M->DA3_DESTIP})
		aAdd(aRetCmp,{"CODIGOFORNECEDOR"		,DA3->DA3_CODFOR										,"DA3_CODFOR"})
		aAdd(aRetCmp,{"LOJACORNECEDOR"		,DA3->DA3_LOJFOR										,"DA3_LOJFOR"})
		aAdd(aRetCmp,{"DESCRICAOFORNECEDOR"	,cDescFor												,}) // M->DA3_DESCFO})
		aAdd(aRetCmp,{"PLACA"					,Replace(DA3->DA3_PLACA,"-","")					,"DA3_PLACA"})
		aAdd(aRetCmp,{"STATUS"					,Iif(DA3->DA3_ATIVO  == '1','A','I')			,"DA3_ATIVO"})
		aAdd(aRetCmp,{"CAPACIDADE"				,Int(DA3->DA3_CAPACM)								,"DA3_CAPACM"})
		aAdd(aRetCmp,{"PESOVEICULO"			,Int(DA3->DA3_TARA)									,"DA3_TARA"})
		aAdd(aRetCmp,{"TERCEIRO"				,Iif(DA3->DA3_FROVEI == '2','S','N')			,"DA3_FROVEI"})
		
   Case cAlias == "DA4"		

						//NOME CAMPO KP			VALOR CAMPO PROTHEUS						NOME CAMPO PROTHEUS	   
		aAdd(aRetCmp,{"CODIGOCENTRAL"			,xFilial("DA4")							,"DA4_FILIAL"})
		aAdd(aRetCmp,{"CODIGOMOTORISTA"		,DA4->DA4_COD								,"DA4_COD"})
		aAdd(aRetCmp,{"NOME"						,DA4->DA4_NOME								,"DA4_NOME"})
		aAdd(aRetCmp,{"CODIGOHABILITACAO"	,DA4->DA4_REGCNH							,"DA4_REGCNH"})
		aAdd(aRetCmp,{"VALIDADEHABILITACAO"	,IIF(Empty(AllTrim(StrTran(dToC(DA4->DA4_DTVCNH), "/"))),"NULL",DToC(DA4->DA4_DTVCNH)),	"DA4_DTVCNH"})
		aAdd(aRetCmp,{"STATUS"					,Iif(DA4->DA4_BLQMOT == '1','I','A'),"DA4_BLQMOT"})
		aAdd(aRetCmp,{"DA4_KPID"				,DA4->DA4_KPID								,"DA4_KPID"})				

   Case cAlias == "SF4"
						//NOME CAMPO KP			VALOR CAMPO PROTHEUS						NOME CAMPO PROTHEUS	   
		aAdd(aRetCmp,{"F4_FILIAL"				,xFilial("SF4")							,"F4_FILIAL"})
		aAdd(aRetCmp,{"F4_CODIGO"				,SF4->F4_CODIGO							,"F4_CODIGO"})
		aAdd(aRetCmp,{"F4_TEXTO"				,SF4->F4_TEXTO								,"F4_TEXTO"})
		aAdd(aRetCmp,{"F4_FINALID"				,SF4->F4_FINALID							,"F4_FINALID"})
		aAdd(aRetCmp,{"F4_MSBLQL"				,SF4->F4_MSBLQL							,"F4_MSBLQL"})

   Case cAlias == "CTT"
						//NOME CAMPO KP			VALOR CAMPO PROTHEUS						NOME CAMPO PROTHEUS	   
		aAdd(aRetCmp,{"CTT_FILIAL"				,xFilial("CTT")							,"CTT_FILIAL"})
		aAdd(aRetCmp,{"CTT_CUSTO"				,CTT->CTT_CUSTO 							,"CTT_CUSTO"})
		aAdd(aRetCmp,{"CTT_DESC01"				,CTT->CTT_DESC01							,"CTT_DESC01"})
		aAdd(aRetCmp,{"CTT_CEI"					,CTT->CTT_CEI     						,"CTT_CEI"})
		aAdd(aRetCmp,{"CTT_BLOQ"				,CTT->CTT_BLOQ  							,"CTT_BLOQ"})

	Case cAlias	== "SB1"
	                                                                                                
						//NOME CAMPO KP			VALOR CAMPO PROTHEUS						NOME CAMPO PROTHEUS	   
		aAdd(aRetCmp,{"B1_FILIAL"				,xFilial("SB1")							,"B1_FILIAL"})
		aAdd(aRetCmp,{"B1_COD"					,SB1->B1_COD								,"B1_COD"})
		aAdd(aRetCmp,{"B1_DESC"					,Left(SB1->B1_DESC,nTamDesc)			,"B1_DESC"})
		aAdd(aRetCmp,{"B1_TIPO"					,SB1->B1_TIPO								,"B1_TIPO"})
		aAdd(aRetCmp,{"B1_GRUPO"				,SB1->B1_GRUPO								,"B1_GRUPO"})
		aAdd(aRetCmp,{"B1_CODISS"				,SB1->B1_CODISS							,"B1_CODISS"})
		aAdd(aRetCmp,{"B1_ALIQISS"				,SB1->B1_ALIQISS							,"B1_ALIQISS"})
		aAdd(aRetCmp,{"B1_MSBLQL"				,SB1->B1_MSBLQL							,"B1_MSBLQL"})

   Case cAlias == "POSCLI" //Posicao do cliente
						//NOME CAMPO KP			VALOR CAMPO PROTHEUS						NOME CAMPO PROTHEUS	   
		aAdd(aRetCmp,{"CODIGOCENTRAL"			,(cAlias)->E1_FILIAL						,"E1_FILIAL"})
		aAdd(aRetCmp,{"CODIGOCLIENTE"			,(cAlias)->E1_CLIENTE					,"E1_CLIENTE"})
		aAdd(aRetCmp,{"LOJACLIENTE"			,(cAlias)->E1_LOJA						,"E1_LOJA"})
		aAdd(aRetCmp,{"VALOR",FValVlrInt((cAlias)->E1_SALDO,(cAlias)->E1_CLIENTE,(cAlias)->E1_LOJA,(cAlias)->DEBITO,(cAlias)->CREDITO),"E1_SALDO"})


   Case cAlias == "CUSMED" //Apuracao Custo Medio
						//NOME CAMPO KP			VALOR CAMPO PROTHEUS						NOME CAMPO PROTHEUS	   
		aAdd(aRetCmp,{"CODIGOCENTRAL"			,(cAlias)->DA1_FILIAL					,"DA1_FILIAL"})
		aAdd(aRetCmp,{"CODIGOMATERIAL"		,(cAlias)->DA1_CODPRO					,"DA1_CODPRO"})
		aAdd(aRetCmp,{"UNIDADE"					,(cAlias)->DA1_UM							,"DA1_UM"})
		aAdd(aRetCmp,{"CUSTOMEDIO"				,(cAlias)->DA1_PRCVEN					,"DA1_PRCVEN"})
		/* Incluido por Felipe Andrews - 11/06/2013 - Informa o Armazem */
		aAdd(aRetCmp,{"ARMAZEM" 				,(cAlias)->DA1_CODTAB					,"DA1_CODTAB"})
		
	Case cAlias == "TRBSD1"
						//NOME CAMPO KP			VALOR CAMPO PROTHEUS						NOME CAMPO PROTHEUS	
		aAdd(aRetCmp,{"CODIGOCENTRAL"			,(cAlias)->CODIGOCENT					,"D1_FILIAL"})
		aAdd(aRetCmp,{"CODIGOFORNECEDOR"		,(cAlias)->CODIGOFORN				   ,"D1_FORNECE"})
		aAdd(aRetCmp,{"LOJAFORNECEDOR"		,(cAlias)->LOJAFORNEC				   ,"D1_LOJA"	})
		aAdd(aRetCmp,{"CODIGOMATERIAL"		,(cAlias)->CODIGOMATE				   ,"D1_COD"  	})
		aAdd(aRetCmp,{"UNIDADECOMPRA"			,(cAlias)->UNIDADECOM				   ,"D1_SEGUM"	})
	   aAdd(aRetCmp,{"DATACOTACAO"			,DtoC((cAlias)->DATACOTACA)		   ,"D1_DTDIGIT"})
		aAdd(aRetCmp,{"VALORUNITARIO"			,(cAlias)->VALFIM				         ,"D1_TOTAL"	})  
			   
EndCase

Return(aRetCmp)




//-------------------------------------------------------------------
/*/{Protheus.doc} FSAvCLi
Avaliação de credito do cliente para envio na interface.

@author	   Lucas Oliveira Rios
@since	   13/06/2012
@version	   P11
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//------------------------------------------------------------------- 

User Function FSAvCli(cCliente, cLjCli, lFlag)

Local lRet    := .T.
Local cAliTmp := "TITCLI"
Local cDtBase := DtoS(dDatabase)                           
Local nDiasT  := 0
Local aAreaA1 := SA1->(GetArea())
Local aAreaE1 := SE1->(GetArea())

// Garante que o alias não fique aberto
If (Select(cAliTmp) <> 0)
   (cAliTmp)->(dbCloseArea())
EndIf

// Retorna primeiro titulo vencido do cliente.
BeginSql alias cAliTmp
	SELECT TOP 1 E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_VENCREA 
	FROM %table:SE1% SE1,%table:SA1% SA1
		WHERE SE1.E1_FILIAL = %xFilial:SE1%
		AND SA1.A1_FILIAL = %xFilial:SA1%
		AND SE1.E1_VENCREA < %Exp:cDtBase%
		AND SE1.E1_SALDO > 0
		AND SE1.E1_TIPO NOT IN ('PR','NCC','RA','AB-', 'CF-', 'CS-', 'FU-', 'IN-', 'IR-', 'IS-', 'PI-')
		AND SE1.%notDel% 
		AND SE1.E1_CLIENTE = SA1.A1_COD
		AND SE1.E1_LOJA = SA1.A1_LOJA
		AND SA1.A1_ZTIPO = 'S'
		AND SA1.%notDel% 
		AND SA1.A1_COD = %Exp:cCliente%
		AND SA1.A1_LOJA = %Exp:cLjCli%
		AND SE1.E1_SITUACA NOT IN ('2','7')
	ORDER BY E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_VENCREA ASC	  
EndSql 

// Força o posicionamento no primeiro registro              
(cAliTmp)->(dbGoTop())   

// Verifico se foi encontrado algum titulo vencido.
If !((cAliTmp)->(Eof()))   

//	Verifico o numero de dias em relação ao dia atual, e vencimento encontrado
  nDiasT := dDatabase - StoD((cAliTmp)->E1_VENCREA)

   // Posiciono no cliente para saber o risco. 
   // - Risco A Libera. 
   // - Risco B,C,D avalia os dias informados nos parametros. Libera ou Bloqueia
   // - Risco E ou Vazio Bloqueia.
   
	SA1->(dbSelectArea(1))
		// Segundo Max, tem que desconsiderar a loja, se houver uma filial com atraso bloqueia todas.
		If SA1->(dbSeek(xFilial("SA1")+(cAliTmp)->E1_CLIENTE,.T.))
		
			While !SA1->(Eof()) .And. SA1->A1_COD == (cAliTmp)->E1_CLIENTE .And. lRet
				If (SA1->A1_RISCO == "B" .And. nDiasT > GetMV("MV_RISCOB")) .Or.;
					(SA1->A1_RISCO == "C" .And. nDiasT > GetMV("MV_RISCOC")) .Or.;
					(SA1->A1_RISCO == "D" .And. nDiasT > GetMV("MV_RISCOD")) .Or.;
					(SA1->A1_RISCO == "E") .Or. Empty(SA1->A1_RISCO)
	
					// Retorna falso, então será bloqueado.
					lRet := .F.
			 	End If
			 SA1->(dbSkip())
			 End Do	
		End If  
		
		//MAX 14-06-2012: Cliente não poderá ser bloqueado pois caso o cliente esteja bloqueado não sao importados os pedidos e não sao faturados as notas
		//                este tratamento continuará apenas pelo valor Zerado pra o cliente na tabela de TITULOS da interface...
		
		If !lRet .and. lFlag 
				SA1->(dbSelectArea(1))
	  			// Segundo Max, tem que desconsiderar a loja, e bloquear os clientes.
				If SA1->(dbSeek(xFilial("SA1")+(cAliTmp)->E1_CLIENTE,.T.))
					While !SA1->(Eof()) .And. SA1->A1_COD == (cAliTmp)->E1_CLIENTE     
					 	 If Reclock("SA1",.F.)
					 			//Replace A1_MSBLQL With "1"
					 			Replace A1_ZFLAG With ""
					 			MSUnlock()
					    End If
					     						 
						 SA1->(dbSkip())
			 		End Do
			   End If
	    End If		
					
End If
   
//Fecho Alias
(cAliTmp)->(dbCloseArea())   
                                                                
RestArea(aAreaA1)
RestArea(aAreaE1)

// Para o retorno igual a .T., não haverá bloqueio na interface.
 
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} FExeProces
Retorna o valor a se levado para interface

@protected
@author	   Fernando Ferreira
@since	   01/03/2013
@version	   P11
/*/
//-------------------------------------------------------------------
Static Function FValVlrInt(nValor, cCodigo, cLoja , nDebito , nCredito )

Local		nReturn		:= 0
Local		lContinua	:= .T.
Local		aAreOld		:= {SA1->(GetArea()), GetArea()}

Default	nValor	:= 0
Default	cCodigo	:= ""
Default	cLoja		:= ""
Default  nDebito  := 0
Default  nCredito := 0

nReturn	:= nValor

SA1->(dbSetOrder(01)) // 1: A1_FILIAL+A1_COD, A1_LOJA

If SA1->(dbSeek(xFilial("SA1")+cCodigo+cLoja))
	If Date() > SA1->A1_VENCLC 
		lContinua := .F.
		nReturn := SA1->A1_LC
	EndIf
				
	If lContinua
		If SA1->A1_RISCO == "A"
			nReturn := 	nValor
		ElseIf U_FSVerRis(cCodigo, cLoja, SA1->A1_RISCO)
			nReturn := 	nValor	
		Else
			nReturn	:= SA1->A1_LC
		EndIf
	EndIf
EndIf


AEval(aAreOld, {|x| restArea(x) })

Return nReturn


