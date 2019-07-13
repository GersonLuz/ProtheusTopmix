#Include "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"                                                                                                                    
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} FSJOBP06
Importaçao de Movimentação de produção

@author	   Cristiano Ferreira
@since	   07/06/2019
@version	   P12
@obs
Projeto TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
******************************
User Function FSJOBP06        
******************************

Local   nOpca      	:= 0			 // Flag de confirmacao para OK ou CANCELA
Local	aSays		:= {} 		     // Array com as mensagens explicativas da rotina
Local	aButtons	:= {}			 // Array com as perguntas (parametros) da rotina
Local	cCadastro:= "Importaçao de Movimentação de produção"
Local	bBlock, bErro //Tratamento de erro
Local   lManual 	:= .T.  

Private 	cNomRot	  := "FSJOBP06" //Define o nome da rotina principal para controle
Private 	cMensErr  := ""         //Tratamento de erro
Private 	bMensCons := {|X,Y| "["+Iif(lManual,"MAN","JOB")+"]["+cNomRot+"]["+DTOC(DATE())+" "+TIME()+"] "+Iif(!Empty(X),"Empresa "+X+" - ","")+Y}
Private     cEmpAnt   := '01
Private     cFilInt   := '010100'

PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilInt MODULO "EST"

	AADD(aSays, "Este programa tem como objetivo efetuar Integração com KP da.")
	AADD(aSays, "Importaçao de Movimentação de produção.")
	AADD(aButtons, { 1,.T.,{|o| nOpca := 1 , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	
   	Begin Sequence 
	  	Processa( {|| FExeProces(lManual) }, "Aguarde...", "Importante registros...",.F.)
	  	ConOut("Processando Gravação Tabela [SD3]... - FSJOBP06/FExeProces")
    End Sequence 
	   
RESET ENVIRONMENT   

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
Local cUndProd  := CriaVar("B1_UM" , .F.)
Local cTmSd3    := CriaVar("D3_TM" , .F.)
Local cUnSd3    := ""
Local cUnSegd3  := ""
Local cDatInt	:= ""
Local cQry		:= ""

Local	cHdlInt	:=	GetNewPar("FS_INTDBAM"," ")  // Parâmetro utilizado para o ambiente da base de integração
Local	cEndIp	:=	GetNewPar("FS_INTDBIP"," ")	// Parêmetro utilizado para informar o IP do servidor da base de integração

Local	nHdlInt   :=	-1//TcLink(cHdlInt,cEndIp)  	
Local	nHdlErp	  :=	AdvConnection()
Local   lValoriz  := .F. // Se o tipo de movimentação é valorizado ou não. Default falso.
Private lMsErroAuto  := .F.
Private nVlrPrc	  := 0
Private nVlrPrc2  := 0             

If !Empty(cHdlInt) .Or. !Empty(cEndIp)
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
	
	//Abre a conexao com a base intermediaria
	cAliTmp := FOpenSD3() 
		
	If ((cAliTmp)->(!Eof()))

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

					aArrSD3		   := {}
					lMsErroAuto    := .F.
					
				   If (Select("TMPSD3") <> 0)
	                   DBSelectArea("TMPSD3")
	   				   DbCloseArea()
				   EndIF
						//MAX: 20-06-2012 - Verifica Armazem Padrao
					  cQuery := " SELECT D3_ZNOTA "
				      cQuery += " FROM  "+RetSqlName("SD3")
				      cQuery += " WHERE "+RetSqlName("SD3")+".D_E_L_E_T_ <> '*' AND "
				      cQuery += "       RTRIM(D3_FILIAL) = '"+rTrim((cAliTmp)->D3_FILIAL) + "' AND "
				      cQuery += "       RTRIM(D3_ZNOTA)  = '"+rTrim((cAliTmp)->D3_ZNOTA)  + "' AND "			      
	  			      cQuery += "       RTRIM(D3_ZSERIE) = '"+rTrim((cAliTmp)->D3_ZSERIE) + "'  "

					TCQuery cQuery Alias "TMPSD3" New	

                    DbSelectArea("TMPSD3")
					DbGoTop()
					
					// Realizo as conversões
					
				  //nVlrPrc	    := FPrcUndMed((cAliTmp)->D3_UM, AllTrim((cAliTmp)->D3_COD), (cAliTmp)->D3_QUANT)
					nVlrPrc		:= (cAliTmp)->D3_QUANT
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
				   
				  If((cAliTmp)->D3_UM <> (Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_UM")))     
				     cUnSd3   := (Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_UM"))
				     cUnSegd3 := (Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_SEGUM"))
				  
				   If ((Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_TIPCONV") == 'M'))  
				     nVlrPrc := (IIF(Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_CONV") == 0,;
				     nVlrPrc * 1, nVlrPrc / Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_CONV")))
				  
				   Elseif (Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_TIPCONV") == 'D')
				     nVlrPrc := (IIF(Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_CONV") == 0,;
				     nVlrPrc / 1, nVlrPrc * Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_CONV")))  
				   Endif   				  
				  Endif
				  
				  ///SEGUNDA UNIDADE///
				     cUnSd3   := (Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_UM"))
				     cUnSegd3 := (Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_SEGUM"))

	                 If (cUnSd3 <> cUnSegd3)
	                  If (Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_TIPCONV") == 'D')
	                   nVlrPrc2 := nVlrPrc / Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_CONV")
	                  Elseif (Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_TIPCONV") == 'M')
	                   nVlrPrc2 := nVlrPrc * Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_CONV")
	                  Endif 
	                 Else
	                   nVlrPrc2 := nVlrPrc
	                 Endif
				             If Empty(Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_COD"))
					  		  Conout("O Produto"+' '+(cAliTmp)->D3_COD+' '+"não possui cadastro no Protheus")
					  		 Else
					  		   //if Empty((RTrim(TMPSD3->D3_ZNOTA))) // NÃO EXISTE NA TABELA SD3 DO PROTHEUS
					  			RecLock("SD3", .T.)   
								Replace D3_FILIAL With  (cAliTmp)->D3_FILIAL         //C
			                    Replace D3_CUSTO1 With  1       					 //C
								Replace D3_COD    With	(cAliTmp)->D3_COD           //C
							    Replace D3_LOCAL  With   cLocPadPrd 		        //C  
				           	    Replace D3_TM	  With	 cTmSd3                     //C
						 		Replace D3_UM     With   cUnSd3	                    //C
							  	Replace D3_SEGUM  With   Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_SEGUM")//C
							  	Replace D3_TIPO   With   Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_TIPO")//C
						    	Replace D3_QUANT  With   nVlrPrc                     //N      
								//MAX: Corrige CC sintéticos.
								If Len(rtrim((cAliTmp)->D3_CC)) = 7
							 	 Replace D3_CC    With (cAliTmp)->D3_CC             //C
							 	Else
							 	 Replace D3_CC    With	"00"+substr((cAliTmp)->D3_FILIAL,3,2)+"080" //C
							 	Endif   
								Replace D3_ZTM     With		(cAliTmp)->D3_ZTM			//C
								Replace D3_ZNOTA   With		(cAliTmp)->D3_ZNOTA			//C
								Replace D3_ZSERIE  With		(cAliTmp)->D3_ZSERIE		//C
								Replace D3_CHAVE   With		"E0"		//C
								Replace D3_GARANTI With		"N"		    //C
								Replace D3_STSERV  With		"1"		    //C
								Replace D3_CF      With		"RE6"	    //C
								Replace D3_MSFIL   With     (cAliTmp)->D3_FILIAL //C
								Replace D3_GRUPO   With		Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_GRUPO")	 //C
							   	Replace D3_CONTA   With		Posicione("SB1",1,xFilial("SB1")+(cAliTmp)->D3_COD ,"B1_CONTA")  //C
			                    Replace D3_QTSEGUM With		nVlrPrc2	//C 
								If SuperGetMv("TM_CUSTOKP",, .F. ) //MAX: Forçar gravacao do custo correto                      
								Replace D3_CUSTO1  With     (cAliTmp)->D3_ZCUSKP                                                 
								Endif   
								Replace D3_ZCUSTKP With     (cAliTmp)->D3_ZCUSKP
								Replace D3_EMISSAO With     cDatInt
								Replace D3_DOC     With     TRIM((cAliTmp)->D3_ZNOTA ) + "/" + TRIM((cAliTmp)->D3_ZSERIE )
								Replace D3_ZORIGEM With 	"BETONMIX"
								ConOut(Dtoc(Date())+" as "+Time()+" Hrs")
				                ConOut("Gravando Corretamente. Rotina: FSJOBP06/FExeProces")
				                ConOut("Importando registro da nota..."+Alltrim((cAliTmp)->D3_ZNOTA) +" / "+Alltrim((cAliTmp)->D3_ZSERIE)+" / "+Alltrim((cAliTmp)->D3_COD)+" / " + Transform((cAliTmp)->D3_ZCUSKP,"999,999.99") + " - FSJOBP06/FExeProces"   ) //max: 10-07-2012					
								lGravou := .T.
								MsUnlock()
							   //Else
							   // ConOut("Registro já importado..."+Alltrim((cAliTmp)->D3_ZNOTA) +" / "+Alltrim((cAliTmp)->D3_ZSERIE)+" / "+Alltrim((cAliTmp)->D3_COD)+" / " + Transform((cAliTmp)->D3_ZCUSKP,"999,999.99") + " - FSJOBP06/FExeProces"   ) //max: 10-07-2012					
							   //Endif
							 Endif									
									TCSetConn(nHdlInt)
												
									If(lGravou == .T.)
										// NOVA ORDEM DA GRAVAÇÃO DO CAMPO DATA INTERFACE DA INTEGRAÇÃO - CRISTIANO FERREIRA 07.06.2019
										cQry := CHR(13)+CHR(10) + "UPDATE SD3 SET DATAINTERFACE = GETDATE() " 
										cQry += CHR(13)+CHR(10) + "WHERE D3_FILIAL = '"+(cAliTmp)->D3_FILIAL+"'" 
										cQry += CHR(13)+CHR(10) + "AND D3_ZNOTA = '"+(cAliTmp)->D3_ZNOTA+"'" 
										cQry += CHR(13)+CHR(10) + "AND D3_ZSERIE = '"+(cAliTmp)->D3_ZSERIE+"'" 
										cQry += CHR(13)+CHR(10) + "AND D3_COD = '"+(cAliTmp)->D3_COD+"'" 
										cQry += CHR(13)+CHR(10) + "AND D3_ZTM = '"+(cAliTmp)->D3_ZTM+"'" 
										If TCSQLExec(cQry) < 0
										ConOut("FIM - Gravando DataInterface na [SD3]... - FSJOBP06/FExeProces") 
										Endif
									Endif
								
						
									TCSetConn(nHdlErp)
					   
			    EndIf
		    Endif	
		(cAliTmp)->(dbSkip()) 
		EndDo
	    ConOut("Gravando Tabela [SD3]... - FSJOBP06/FExeProces")		
	EndIf

ConOut("FIM - FIM - FIM Gravação Tabela [SD3]... - FSJOBP06/FExeProces")
(cAliTmp)->(dbCloseArea())
TcUnlink(nHdlInt)
Endif
//Destrava a rotina
U_FSTraExe(@nHdlLock, cNomRot)

ConOut(Dtoc(Date())+" as "+Time()+" Hrs")

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
@return	lRet	- Se a unidade informada for a primeira ou segunda unidade retorna .T.
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
		nQtdPrc:= nQtdMov
	
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})  

Return nQtdPrc

