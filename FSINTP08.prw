#Include "Protheus.ch"   

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSINTP08()
Processo que realiza importação das informações dos titulos provisórios que serão
excluidos.
          
@author Fernando Ferreira
@since 11/11/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSINTP08()
FSetCtrFat()
Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSetCtrFat()
Processo realiza a gravação do Controles da base integração para base 
protheus.
          
@protected
@author Fernando Ferreira
@since 11/11/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FSetCtrFat()
Local		aDadCtr		:=	{}

Local		cHdlInt		:=	SuperGetMv( "FS_INTDBAM" , .F., " " )  // Parâmetro utilizado para o ambiente da base de integração
Local		cEndIp		:=	SuperGetMv( "FS_INTDBIP" , .F., " " )	// Parêmetro utilizado para informar o IP do servidor da base de integração
Local		cAliTbl		:= ""
Local		cQry			:= ""

Local		cDta			:=	DtoC(Date())

Private 	nHdlInt		:=	-1
Private 	nHdlErp		:=	AdvConnection()

If !Empty(cHdlInt).And.!Empty(cEndIp)
 	nHdlInt		:=	TcLink(cHdlInt,cEndIp,7990)
EndIf

If nHdlInt < 0 
	ConOut("Nao foi possivel realizar conexao com banco de dados de integracao. " + DtoC(Date())+" - "+Time())
Else     

	// Cria arquivo de trabalho
	cAli	:=	U_FSTblDtb("P02") // select com registros pendentes de importação para o protheus.

	ConOut("******************************************************************************")   
   ConOut("Importando tabela P02 para o protheus.")
	ConOut("******************************************************************************")
   
	// Realiza a leitura do arquivo de trabalho	
	While (cAli)->(!Eof())
		
		   RecLock("P02", .T.)
			P02->P02_ID			:=	(cAli)->P02_ID
			P02->P02_FILIAL	:=	xFilial("P02")
			P02->P02_FLORI1	:=	(cAli)->P02_FLORI1
			P02->P02_DTEMI1	:=	StoD((cAli)->P02_DTEMI1)
			P02->P02_NUM1		:=	(cAli)->P02_NUM1
			P02->P02_SERIE1	:=	(cAli)->P02_SERIE1
			P02->P02_FLORI2	:=	(cAli)->P02_FLORI2
			P02->P02_DTEMI2	:=	StoD((cAli)->P02_DTEMI2)
			P02->P02_NUM2		:=	(cAli)->P02_NUM2
			P02->P02_SERIE2	:=	(cAli)->P02_SERIE2
	      (cAli)->(MsUnlock())
		   TCSetConn(nHdlInt)

			ConOut("Importacao registro P02. ID: "+Alltrim(P02->P02_ID)+" Titulo: "+Alltrim(P02->P02_NUM2)+" Serie: "+P02->P02_SERIE2+" Data: "+DtoC(Date())+" "+Time())

	      // Marca que o registro foi processado na integracao.	
			cQry := " UPDATE dbo.P02 "
			cQry += " SET DATAINTERFACE = '"+cDta+"'"
			cQry += " WHERE P02_ID     = '" + (cAli)->P02_ID     +"'"			
			cQry += "   AND P02_FILIAL = '" + (cAli)->P02_FILIAL +"'"
			cQry += "   AND P02_FLORI1 = '" + (cAli)->P02_FLORI1 +"'"
			TCSQLExec(cQry)
			TCSetConn(nHdlErp) 
			
 	   (cAli)->(dbSkip())
 		   
	EndDo	          
	
	U_FSCloAre(cAli)
	
EndIf
TcUnLink(nHdlInt)
Return Nil