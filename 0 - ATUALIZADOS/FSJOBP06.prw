#Include "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FSJOBP06
Importaçao de Movimentação de produção

@author	   Giulliano Santos
@since	   21/11/2010
@version	   P11
@obs
Projeto TOPMIX
A rotina manual integra somente os dados da empresa corrente.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
******************************
User Function FSJOBP06        
******************************

Local   nOpca      	:= 0			 // Flag de confirmacao para OK ou CANCELA
Local	aSays		:= {} 		 // Array com as mensagens explicativas da rotina
Local	aButtons	:= {}			 // Array com as perguntas (parametros) da rotina
Local	cCadastro:= "Importaçao de Movimentação de produção"

Local	bBlock, bErro //Tratamento de erro
Local   lManual 	:= .T.  

Private 	cNomRot	  := "FSJOBP06" //Define o nome da rotina principal para controle
Private 	cMensErr  := ""  //Tratamento de erro
Private 	bMensCons := {|X,Y| "["+Iif(lManual,"MAN","JOB")+"]["+cNomRot+"]["+DTOC(DATE())+" "+TIME()+"] "+Iif(!Empty(X),"Empresa "+X+" - ","")+Y}

AADD(aSays, "Este programa tem como objetivo efetuar Integração com KP da.")
AADD(aSays, "Importaçao de Movimentação de produção.")
//AADD(aSays, "ATENÇÃO: NA EXECUCAO MANUAL É ENVIADO SOMENTE OS REGISTROS")
//AADD(aSays, "Da EMPRESA CORRENTE.")

AADD(aButtons, { 1,.T.,{|o| nOpca := 1 , o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

FormBatch(cCadastro,aSays,aButtons)

/* If(nOpca == 1)
	//Tratamento de Erro
	bBlock:=ErrorBlock()
	bErro:=ErrorBlock({|e| U_FSChkBug(e, lManual)})*/
	
   	Begin Sequence 
	  	Processa( {|| FExeProces(lManual) }, "Aguarde...", "Importante registros...",.F.)
	  	ConOut("Processando Gravação Tabela [SD3]... - FSJOBP06/FExeProces")
    End Sequence 
	
	//Tratamento de Erro
   //	ErrorBlock(bBlock)
	
	//Caso ocorra um erro é enviado um e-mail de alerta.
  /*	If !Empty(cMensErr)
		Conout(cMensErr)
		//U_FSMaiAvi(cCadastro)
		Return Final("Sistema abortado pela geração do erro.")
	EndIf	
EndIf */

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FSLOJW06
Job de importação de pedidos de produção

@author	   Giulliano Santos
@since	   21/11/2010
@version	   P11
@obs
Projeto TOPMIX
A rotina manual integra somente os dados da empresa corrente.

Data       	Programador     		Motivo    
30/01/2012  Fernando Ferreira    Validação por empresa usando o Parametro FS_GRPEMP
/*/
//-------------------------------------------------------------------
******************************** 
User Function FSLOJW06
********************************

Local  bBlock, bErro //Tratamento de erro
Local  lManual 		:= .F.  
Local  lEmpAutJob	:=	.F.  
Local  aRecnoSM0	:= {}   
Local  lOpen		:= .F.
Local  nI			:= 0
Local  cCodEmp		:= ""
Local  cCodFil		:= ""
Local  cCadastro	:= "Importaçao de Movimentação de produção"

Private 	cNomRot	  := "FSJOBP06" //Define o nome da rotina principal para controle
Private 	cMensErr  := ""  //Tratamento de erro
Private 	bMensCons := {|X,Y| "["+Iif(lManual,"MAN","JOB")+"]["+cNomRot+"]["+DTOC(DATE())+" "+TIME()+"] "+Iif(!Empty(X),"Empresa "+X+" - ","")+Y}

ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
ConOut(Eval(bMensCons,"","Iniciado "+cCadastro))

//Tratamento de Erro
bBlock:=ErrorBlock()
bErro:=ErrorBlock({|e| U_FSChkBug(e, lManual)})
Begin Sequence

	//Abertura do Sigamat e ambientes
   /*	If (U_FSAbrSM0())
		
		dbSelectArea("SM0")    
		dbSetOrder(1)
		While SM0->(!Eof())                                                                          
		
			cCodEmp	:= SM0->M0_CODIGO
			cCodFil	:= SM0->M0_CODFIL
					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Abertura de ambiente                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			aAreSm0 := SM0->(GetArea())			
			RpcSetType(3)			
			RpcSetEnv(cCodEmp, cCodFil,,)                        									
			nModulo := 12 	   			      
			
			lEmpAutJob	:= SuperGetMV("FS_GRPEMP", .T., .F.)
			If lEmpAutJob			
    			ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
				ConOut("******************************************************************************")
				ConOut("* Empresa: "+cCodEmp)
				ConOut("* Filial: "+cCodFil)
				ConOut("* Importacao de Movimentos SD3")
				ConOut("******************************************************************************")
				If (Emprok(SM0->M0_CODIGO + SM0->M0_CODFIL)) // Valida se a empresa está liberada pela Totvs
					FExeProces(lManual) 
				EndIF
			Else
				ConOut("Empresa " + cCodEmp + ". Nao Tem autorizacao para executar o processo. Verifique o parametro FS_GRPEMP.")			
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Fecha ambiente                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			RpcClearEnv()
			
			//Reabre tabela SM0
			If !( U_FSAbrSM0() )
				Exit 
			EndIf               
			RestArea(aAreSm0)
			dbSelectArea("SM0")	
			dbSkip()
		EndDo			
	EndIf 
  */
End Sequence 

ErrorBlock(bBlock)

ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
ConOut(Eval(bMensCons,"","Finalizado "+cCadastro))

//Caso ocorra erro é enviando um e-mail de alerta.
If (!Empty(cMensErr))
	Conout(cMensErr)
	//U_FSMaiAvi(cCadastro)
EndIf

Return Nil 


//-------------------------------------------------------------------
/*/{Protheus.doc} FExeProces
Executa o processo 

@protected
@author	   Giulliano Santos
@since	   21/12/2011
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       	Programador     			Motivo 
23/02/2012 	Fernando Ferreira     	Alteração no update do banco de integração.  
13/04/2012	Fernando Ferreira		 	Informar valor .F. para a variavel lMsErroAuto.
24/05/2012	Fernando Ferreira			Inclusão do campo D3_LOCAL no array do sigaauto.
/*/
//-------------------------------------------------------------------

*********************************************  
Static Function FExeProces(lManual) 
*********************************************

Local nHdlLock  := -1
Local nTotReg	:= 0
Local nCtdReg	:= 0
Local aArrSD3	:= {} 
Local aCmp		:= {}
Local aWhr		:= {}
Local nVlrPrc	:= 0
Local cUndProd  := CriaVar("B1_UM" , .F.)
Local cTmSd3    := CriaVar("D3_TM" , .F.)
Local cDatInt	:= ""
Local cQry		:= ""

Local	cHdlInt	:=	GetNewPar("FS_INTDBAM"," ")  // Parâmetro utilizado para o ambiente da base de integração
Local	cEndIp	:=	GetNewPar("FS_INTDBIP"," ")	// Parêmetro utilizado para informar o IP do servidor da base de integração

Local	nHdlInt   :=	-1//TcLink(cHdlInt,cEndIp)  	
Local	nHdlErp	  :=	AdvConnection()
Local   lValoriz  := .F. // Se o tipo de movimentação é valorizado ou não. Default falso.
Private lMsErroAuto := .F.             

/*If !Empty(cHdlInt) .Or. !Empty(cEndIp)
	nHdlInt		:=	TcLink(cHdlInt,cEndIp,7990)
EndIf

ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
If nHdlInt < 0
	ConOut("Rotina: FSJOBP06/FExeProces - Nao foi possivel realizar conexao com banco de dados de integracao. " + DtoC(Date())+" - "+Time())
Else
	ConOut(Eval(bMensCons,SM0->M0_CODIGO,"Iniciando Processo na Empresa - FSJOBP06/FExeProces."))
	
	//Verifica se a rotina ja esta sendo executada travando-a para nao ser executada mais de uma vez
	If U_FSTraExe(@nHdlLock, cNomRot, .T., lManual)
		ConOut(Eval(bMensCons,SM0->M0_CODIGO,"Rotina já está em execucao - FSJOBP06/FExeProces."))
		Return(Nil)
	EndIf
	           */
	//Abre a conexao com a base intermediaria
	cAliTmp := FOpenSD3() 
	
	If ((cAliTmp)->(Eof()))
		
	   /*	If (lManual)// Se a função for chamada via Mnu
			ApMsgAlert("Não existe registros para Integrar na Empresa:  " + SM0->M0_CODIGO + " !")
		Else
			ConOut(Eval(bMensCons,SM0->M0_CODIGO,"Não existe registros para Integrar - FSJOBP06/FExeProces."))
		EndIf*/
			
	Else
	
		If (lManual) // Se a função for chamada via Mnu
			(cAliTmp)->(dbEval({||nTotReg++}))
			ProcRegua(nTotReg)
		EndIf
		
		(cAliTmp)->(dbGotop())
		While ((cAliTmp)->(!Eof()))
						
			If (lManual) // Se a função for chamada via Mnu
				nCtdReg++
				IncProc("Processando: " + Strzero(nCtdReg,9) + " de " + Strzero(nTotReg,9))
			EndIf  
				
			//Efetua a integracao do registro com o KP
			//A cada execucao é incluido novo registro na tabela de integracao
			
										
			
			If ( ExistCpo("SB1", (cAliTmp)->D3_COD ))
				cUndProd := Posicione("SB1",1,xFilial("SB1") + AllTrim((cAliTmp)->D3_COD) ,"B1_UM")  
				
				// Valido a unidade de Medida.
				If FVldUndPrd((cAliTmp)->D3_COD, (cAliTmp)->D3_UM)
				   cTmSd3 	:= (cAliTmp)->D3_ZTM
				   
				   DbSelectArea("SF5")
				   DbSetOrder(1)
				   If DbSeek( xFilial("SF5") + cTmSd3 )
				      lValoriz := SF5->F5_VAL == "S" // S = A movimentação deverá ser Valorizada, ou seja devera informar o valor.
					Endif

					aArrSD3			:= {}
					lMsErroAuto    := .F.
					
					// Realizo as conversões
					
					nVlrPrc		:= FPrcUndMed((cAliTmp)->D3_UM, AllTrim((cAliTmp)->D3_COD), (cAliTmp)->D3_QUANT)
					cDatInt		:= SToD((cAliTmp)->D3_EMISSAO)
					cLocPadPrd	:= Posicione("SB1",1,xFilial("SB1") + AllTrim((cAliTmp)->D3_COD) ,"B1_LOCPAD")
				    
				   If (Select("TMPSB2") <> 0)
	                   DBSelectArea("TMPSB2")
	   				   DbCloseArea()
				   EndIF
						//MAX: 20-06-2012 - Verifica Armazem Padrao
					  cQuery := " SELECT B2_FILIAL, B2_COD, B2_LOCAL "
				      cQuery += " FROM  "+RetSqlName("SB2")
				      cQuery += " WHERE "+RetSqlName("SB2")+".D_E_L_E_T_ <> '*' AND "
				      cQuery += "       RTRIM(B2_FILIAL) = '"+rTrim((cAliTmp)->D3_FILIAL) + "' AND "
				      cQuery += "       RTRIM(B2_COD)    = '"+rTrim((cAliTmp)->D3_COD)    + "' AND "			      
	  			      cQuery += "       RTRIM(B2_LOCAL)  = '"+rTrim(cLocPadPrd)           + "'  "

					TCQuery cQuery Alias "TMPSB2" New	

                    DbSelectArea("TMPSB2")
					DbGoTop()
					
						If (RTrim(TMPSB2->B2_FILIAL)+RTrim(TMPSB2->B2_COD)+RTrim(TMPSB2->B2_LOCAL))  <>  (RTrim((cAliTmp)->D3_FILIAL) + RTrim((cAliTmp)->D3_COD) + RTrim(cLocPadPrd))
						   DBSelectArea("SB2")
				   		   RecLock("SB2",.T.)
	                        Replace B2_FILIAL with  (cAliTmp)->D3_FILIAL
	                        Replace B2_COD    with  (cAliTmp)->D3_COD
	                        Replace B2_LOCAL  with  cLocPadPrd
						   MsUnLock()
						Endif	
	                DBSelectArea("TMPSB2")
   			        DbCloseArea()

				   //MAX: Fim das alterações  
				   // CRISTIANO FERREIRA 07.06.2019  
				   
				  If(cTmSd3 <> (Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_UM")))     
				     cTmSd3 := (Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_UM")
				   If ((Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_TIPCONV") == 'M')  
				     nVlrPrc := nVlrPrc / (IIF(Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_CONV") == 0,;
				     nVlrPrc, nVlrPrc * Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_CONV"))))
				   Elseif ((Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_TIPCONV") == 'D')
				     nVlrPrc := nVlrPrc / (IIF(Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_CONV") == 0,;
				     nVlrPrc, nVlrPrc / Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_CONV")))  
				   endif   
				  Endif
				   
		  			ConOut((cAliTmp)->D3_ZCUSKP)   
					Aadd(aArrSD3,{"D3_FILIAL" 		,(cAliTmp)->D3_FILIAL,  		})//C
               Aadd(aArrSD3,{"D3_CUSTO1"		,1,})//N           					
					Aadd(aArrSD3,{"D3_COD"  		,(cAliTmp)->D3_COD,				})//C
				 /*Aadd(aArrSD3,{"D3_LOCAL"  		,cLocPadPrd,						})//C  Comentado por Felipe Andrews - 11/06/2013 -  Comentado Juliana 09/07/13 */
					Aadd(aArrSD3,{"D3_LOCAL"  		,(cAliTmp)->D3_ARMAZEM, 		})//C /* Felipe Andrews - Armazem que vem da KP - retirado o comentario Juliana 09/07/13*/
	           	Aadd(aArrSD3,{"D3_TM"			,cTmSd3,								})//C
			 		Aadd(aArrSD3,{"D3_UM"			,(cAliTmp)->D3_UM,				})//C
				  //	Aadd(aArrSD3,{"D3_EMISSAO"		,cDatInt,							})//D
					Aadd(aArrSD3,{"D3_QUANT"		,nVlrPrc,							})//N
					Aadd(aArrSD3,{"D3_ZCUSKP"		,(cAliTmp)->D3_ZCUSKP,			})//N    //MAX: Gravar custo no campo para kardex        
					//MAX: Corrige CC sintéticos.
					If Len(rtrim((cAliTmp)->D3_CC)) = 7
				 	   Aadd(aArrSD3,{"D3_CC"	   	,(cAliTmp)->D3_CC,				})//C
				 	Else
				 	   Aadd(aArrSD3,{"D3_CC"	   	,"00"+substr((cAliTmp)->D3_FILIAL,3,2)+"080",	})//C
				 	EndIF   
					Aadd(aArrSD3,{"D3_ZTM"  		,(cAliTmp)->D3_ZTM,				})//C
					Aadd(aArrSD3,{"D3_ZNOTA"		,(cAliTmp)->D3_ZNOTA,			})//C
					Aadd(aArrSD3,{"D3_ZSERIE" 		,(cAliTmp)->D3_ZSERIE,			})//C
					Aadd(aArrSD3,{"D3_CONTA" 		,SB1->B1_CONTA,					})//C  MAX/ANTONIO BARCANTE
					Aadd(aArrSD3,{"D3_ZORIGEM" 	,"BETONMIX",						})
					//aArrSD3 := U_FSAceArr(aArrSD3,"SD3")	  MAX
               
               ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
					ConOut("Importando registro da nota..."+Alltrim((cAliTmp)->D3_ZNOTA) +" / "+Alltrim((cAliTmp)->D3_ZSERIE)+" / "+Alltrim((cAliTmp)->D3_COD)+" / " + Transform((cAliTmp)->D3_ZCUSKP,"999,999.99") + " - FSJOBP06/FExeProces"   ) //max: 10-07-2012
					
                                        __lNoErro := .T. // Inicio Alteração feita em 20151014
                                        CheckSeque()
                                        Do While ! __lNoErro
                                           CheckSeque()
                                        Enddo
                                        // fim Alteração feita em 20151014
              
               	//U_zArrToTxt(aArrSD3, .T., "D:\LOGS_FATURAS\SD3_"+(cAliTmp)->D3_ZNOTA+".txt")
					MSExecAuto({|x,y| mata240(x,y)},aArrSD3,3)

					If ! lMsErroAuto
   
                  ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
                  ConOut("FIM - ExecAuto Mata240. Rotina: FSJOBP06/FExeProces")
                  
			    	   RecLock("SD3", .F.)
					   If SuperGetMv("TM_CUSTOKP",, .F. ) //MAX: Forçar gravacao do custo correto                      
					      replace D3_CUSTO1  with (cAliTmp)->D3_ZCUSKP                                                 
					   Endif   
					   replace D3_ZCUSTKP with (cAliTmp)->D3_ZCUSKP
					   replace D3_EMISSAO with cDatInt
					   replace D3_DOC     with TRIM((cAliTmp)->D3_ZNOTA ) + "/" + TRIM((cAliTmp)->D3_ZSERIE )
					   MsUnlock()

						aCmp	:= {}
						aWhr	:= {}												
                   // ALTERADO A ORDEM DE GRAVAÇÃO DA TABELA DE INTEGRAÇÃO A DATAINTERFACE SÓ SERÁ GRAVADA SENÃO POSSUIR ERRO
                   // CRISTIANO FERREIRA 07.06.2019
				   /*		cQry := CHR(13)+CHR(10) + "UPDATE SD3 SET DATAINTERFACE = GETDATE() " 
						cQry += CHR(13)+CHR(10) + "WHERE D3_FILIAL = '"+(cAliTmp)->D3_FILIAL+"'" 
						cQry += CHR(13)+CHR(10) + "AND D3_ZNOTA = '"+(cAliTmp)->D3_ZNOTA+"'" 
						cQry += CHR(13)+CHR(10) + "AND D3_ZSERIE = '"+(cAliTmp)->D3_ZSERIE+"'" 
						cQry += CHR(13)+CHR(10) + "AND D3_COD = '"+(cAliTmp)->D3_COD+"'" 
						cQry += CHR(13)+CHR(10) + "AND D3_ZTM = '"+(cAliTmp)->D3_ZTM+"'"  */
									
						TCSetConn(nHdlInt)

						ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
						ConOut("INICIO - Gravando DataInterface na [SD3]... - FSJOBP06/FExeProces")
						If TCSQLExec(cQry) < 0
							cMsgErr	:=	TCSQLError()
							U_FSSETERR(xFilial("P00"), date(), Time(), cValToChar((cAliTmp)->ID) , "Mata240", cMsgErr)
                     ConOut("ERRO - Gravando DataInterface na [SD3]... FSJOBP06/FExeProces")
						Else
						// NOVA ORDEM DA GRAVAÇÃO DO CAMPO DATA INTERFACE DA INTEGRAÇÃO - CRISTIANO FERREIRA 07.06.2019
						cQry := CHR(13)+CHR(10) + "UPDATE SD3 SET DATAINTERFACE = GETDATE() " 
						cQry += CHR(13)+CHR(10) + "WHERE D3_FILIAL = '"+(cAliTmp)->D3_FILIAL+"'" 
						cQry += CHR(13)+CHR(10) + "AND D3_ZNOTA = '"+(cAliTmp)->D3_ZNOTA+"'" 
						cQry += CHR(13)+CHR(10) + "AND D3_ZSERIE = '"+(cAliTmp)->D3_ZSERIE+"'" 
						cQry += CHR(13)+CHR(10) + "AND D3_COD = '"+(cAliTmp)->D3_COD+"'" 
						cQry += CHR(13)+CHR(10) + "AND D3_ZTM = '"+(cAliTmp)->D3_ZTM+"'"  
                     ConOut("FIM - Gravando DataInterface na [SD3]... - FSJOBP06/FExeProces")
						EndIf
						TCSetConn(nHdlErp)
					Else   
					
						cMsgErr	:=	MemoRead(NomeAutoLog())
						ConOut(cMsgErr)
						U_FSSETERR(xFilial("P00"), date(), Time(), cValToChar((cAliTmp)->ID) , "Mata240", cMsgErr)
						Ferase(NomeAutoLog())
						ConOut("PASSANDO4")	
					EndIf
				
				Else
					cMsgErr	:=	"A unidade do produto no KP é diferente unidade do produto no Protheus. Código do Produto: " + (cAliTmp)->D3_COD + ", UM: " + (cAliTmp)->D3_UM 
					U_FSSETERR(xFilial("P00"), date(), Time(), (cAliTmp)->ID , "Mata240", cMsgErr)
				EndIf
				
			Else
				cMsgErr	:=	"Produto no KP não existe no Protheus"
				U_FSSETERR(xFilial("P00"), date(), Time(), (cAliTmp)->ID , "Mata240", cMsgErr)
			EndIf
			(cAliTmp)->(dbSkip()) 
		EndDo
	ConOut("Gravando Tabela [SD3]... - FSJOBP06/FExeProces")		
	EndIf
EndIf
ConOut("FIM - FIM - FIM Gravação Tabela [SD3]... - FSJOBP06/FExeProces")
(cAliTmp)->(dbCloseArea())
TcUnlink(nHdlInt)

//Destrava a rotina
U_FSTraExe(@nHdlLock, cNomRot)

ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
ConOut(Eval(bMensCons,SM0->M0_CODIGO,"Finalizando Processo na Empresa - FSJOBP06/FExeProces"))

Return Nil  

//-------------------------------------------------------------------
/*/{Protheus.doc} FOpenSD3
Carrega dados das tabelas inter

@protected
@author	   Giulliano Santos
@since	   21/12/2011
/*/
//------------------------------------------------------------------- 
****************************** 
Static Function FOpenSD3
******************************

Local	cHdlInt := SuperGetMv("FS_INTDBAM",.F.," ")  // Parâmetro utilizado para o ambiente da base de integração
Local	cEndIp  := SuperGetMv("FS_INTDBIP",.F.," ")  // Parêmetro utilizado para informar o IP do servidor da base de integração
Local   cAlias  := GetNextAlias()
Local   cQrySD3 := ""

Private 	nHdlInt		:=	-1
Private 	nHdlErp		:=	AdvConnection()

If !Empty(cHdlInt).And.!Empty(cEndIp)
 	nHdlInt		:=	TcLink(cHdlInt,cEndIp)
EndIf

If nHdlInt < 0 
   ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
	ConOut("Nao foi possivel realizar conexao com banco de dados de integracao. " + DtoC(Date())+" - "+Time())
Else

	//Seta a conexao para base intermediaria
	TcSetConn(nHdlInt)

	cQrySD3+=CHR(13)+ "SELECT D3_FILIAL "
	cQrySD3+=CHR(13)+ "      ,D3_COD "
	cQrySD3+=CHR(13)+ "      ,D3_ZTM "
	cQrySD3+=CHR(13)+ "      ,D3_UM "
	cQrySD3+=CHR(13)+ "      ,D3_CC "
	cQrySD3+=CHR(13)+ "      ,ID "
	cQrySD3+=CHR(13)+ "      ,SUBSTRING(REPLACE(CONVERT(CHAR(10), D3_EMISSAO,102), '.' , ''), 1,8) As D3_EMISSAO"
	cQrySD3+=CHR(13)+ "      ,D3_QUANT "
	cQrySD3+=CHR(13)+ "      ,D3_ZCUSKP "
	cQrySD3+=CHR(13)+ "      ,D3_ZNOTA "
	cQrySD3+=CHR(13)+ "      ,D3_ZSERIE "
	cQrySD3+=CHR(13)+ "      ,D3_ARMAZEM " /* Felipe Andrews - Armazem que vem da KP */
	cQrySD3+=CHR(13)+ "      ,DATAINTERFACE "
	cQrySD3+=CHR(13)+ "		 ,CONVERT(CHAR(8), D3_EMISSAO,108) D3_HORA "
	cQrySD3+=CHR(13)+ "FROM SD3 "
	cQrySD3+=CHR(13)+ "WHERE DATAINTERFACE IS NULL "   
	//cQrySD3+=CHR(13)+ "AND D3_FILIAL = '"+cFilAnt+"'"	

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQrySD3), cAlias, .F., .T.) 

EndIf

TcSetConn(nHdlErp)

Return cAlias

//------------------------------------------------------------------- 
/*/{Protheus.doc} FVldUndPrd
Valida se a unidade do produto informada é a primeira ou segunda medida

@protected       
@author Fernando Ferreira
@since 23/02/2012
@param	cUndPrd	- Unidade do Produto
@param	cCodPrd	- Código do produto
@return	lRet		- Se a unidade informada for a primeira ou segunda unidade retorna .T.
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
***************************************************
Static Function FVldUndPrd(cCodPrd, cUndPrd)
***************************************************

Local 	aAreOld	:= {GetArea("SB1")}       
Local	lRet	:= .F.

Default	cUndPrd 	:= ""
Default cCodPrd	    := ""

SB1->(dbSetOrder(1))

If SB1->(dbSeek(xFilial("SB1")+cCodPrd))
	If (SB1->B1_UM == cUndPrd) .Or. (SB1->B1_SEGUM == cUndPrd)
		lRet := .T.	
	EndIf
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return lRet

//------------------------------------------------------------------- 
/*/{Protheus.doc} FPrcUndMed
Realiza o processo de conversão das unidades de medida.

@protected       
@author Fernando Ferreira
@since 23/02/2012
@param	cUndPrd	- Unidade do Produto
@param	cCodPrd	- Código do produto
@param	nVlrCst	- Valor do custo
@return	aVlrCov	- Array de duas posições a primeira é a quantidade e a segunda é o valor
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
*************************************************************
Static Function FPrcUndMed(cUndPrd, cCodPrd, nQtdMov) 
*************************************************************

Local	aVlrCov		:= {}
Local 	aAreOld		:= {GetArea("SB1")}
Local	nQtdPrc		:= 0

Default	cUndPrd		:= ""
Default cCodPrd		:= "" 
Default	nQtdMov		:= 0

SB1->(dbSetOrder(1))

If SB1->(dbSeek(xFilial("SB1")+cCodPrd))
	// Verifica se é a segunda unidade de medida.
		//nQtdPrc	:= nQtdMov
		nQtdPrc:=nQtdMov
	
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})  

Return nQtdPrc

