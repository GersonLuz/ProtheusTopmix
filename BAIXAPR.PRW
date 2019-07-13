#Include "Protheus.ch"   
#Define cEol Chr(13)+Chr(10)

//------------------------------------------------------------------- 
/*/{Protheus.doc} BAIXAPR()
Processo que realiza a exclusão dos titulos provisorios referente ao
faturamento de Pedidos de Fatura fazendo uma busca em todo o sistema
          
@author MAX ROCHA	
@since 09/10/2012 
@version P11
@obs  
       
/*/ 
//------------------------------------------------------------------ 
User Function BAIXAPR()     
// Variaveis Locais da Funcao
Local cEdit1	 := Space(25)
Local cEdit2	 := Space(25)
Local cEdit3	 := Space(25)
Local cEdit4	 := Space(25)
Local cEdit5	 := Space(25)
Private oEdit1
Private oEdit2
Private oEdit3
Private oEdit4
Private oEdit5                                                         

Private _oDlg				// Dialog Principal

DEFINE MSDIALOG _oDlg TITLE "Baixa Títulos Provisórios..." FROM C(245),C(251) TO C(353),C(785) PIXEL

	// Cria Componentes Padroes do Sistema
	@ C(003),C(001) Say "Filial:" Size C(013),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(003),C(068) Say "Documento:" Size C(031),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(003),C(133) Say "Prefixo" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(003),C(198) Say "Valor" Size C(014),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(012),C(000) MsGet oEdit1 Var cEdit1 Size C(060),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(012),C(068) MsGet oEdit2 Var cEdit2 Size C(060),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(012),C(133) MsGet oEdit3 Var cEdit3 Size C(060),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(012),C(198) MsGet oEdit4 Var cEdit4 Size C(060),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(038),C(198) MsGet oEdit5 Var cEdit5 Size C(060),C(009) COLOR CLR_BLACK PIXEL OF _oDlg                                                                                            
	@ C(038),C(111) Button "Iniciar" Size C(037),C(012) PIXEL OF _oDlg  Action(U_fInicia())


oEdit1:lReadOnly := .T.
oEdit2:lReadOnly := .T.
oEdit3:lReadOnly := .T.
oEdit4:lReadOnly := .T.
oEdit5:lReadOnly := .T.

ACTIVATE MSDIALOG _oDlg CENTERED 


Return(.t.)


//Funcao para Iniciar processo.                                                                                   
User Function fInicia()
Local 	aAreOld	:=	{GetArea()}
Local		aDadTit	:=	{}

Local		cQry		:=	""
Local		cAli		:=	GetNextAlias()
Local		cFilNfs	:=	""
Local		cSerNfs	:=	""
Local		cNumRem	:=	""
Local		cMsgErr	:=	""             
Local		cRotPrc	:= "Fat X Rem"

Local		dDtaPrc	 :=	dDataBase
Local    cPrefixo  := ""
Local    nTitulos  := 0
private	lMsErroAuto	:= .F.


cQry	+= "SELECT"
cQry	+= cEol + "		P2.P02_FILIAL, P2.P02_SERIE2, P2.P02_NUM2, P2.P02_ID, P2.P02_BXPRV "
cQry	+= cEol + "FROM "
cQry	+= cEol + 	RetSqlName("P02")+" P2"
cQry	+= cEol + "WHERE "
cQry	+= cEol + "		P2.P02_BXPRV	= ''  AND"
cQry	+= cEol + "		P2.D_E_L_E_T_ <> '*' "
cQry	+= cEol + "ORDER BY P2.P02_ID     "
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAli, .F., .T.)
dbSelectArea(cAli)
dbGoTop()

While (cAli)->(!Eof())

		cFilNfs	:=	(cAli)->P02_FILIAL
		cSerNfs	:=	(cAli)->P02_SERIE2
		cNumRem	:=	(cAli)->P02_NUM2
		cPrefixo := SUBSTR((cAli)->P02_FILIAL, 5, 2)
		oEdit5:cText := Transform((cAli)->P02_ID, "@E 9999999")  
     	oEdit5:Refresh() 					
     	
		SE1->(dbOrderNickName("FSIND00004"))
		if SE1->(dbSeek(xFilial("SE1")+cPrefixo+cNumRem))
		
			oEdit1:cText   := SE1->E1_FILORIG
			oEdit2:cText   := SE1->E1_NUM   
			oEdit3:cText   := SE1->E1_PREFIXO
			oEdit4:cText   := Transform(SE1->E1_VALOR, "@E 999,999,999.99" )
	     	oEdit1:Refresh() 
   	  	oEdit2:Refresh() 
     		oEdit3:Refresh() 
	     	oEdit4:Refresh() 

			lMsErroAuto	:=	.F.						
			aDadTit	:=	U_FArrSigAut("SE1", "E1")
			Begin Transaction                              	
				// Inclusão dos do Título via Siga Auto
				MSExecAuto({|x,y| Fina040(x,y)}, aDadTit, 5)

				If lMsErroAuto
					cMsgErr	:=	MemoRead(NomeAutoLog())
					U_FSSETERR(xFilial("P00"), dDtaPrc, Time(), SE1->E1_ZREMES, cRotPrc, cMsgErr)	
					Ferase(NomeAutoLog())
				ELSE
		   		cUpdate := " UPDATE  " +RetSqlName("P02")
					cUpdate += " SET P02_BXPRV = '"+DtoS(dDatabase) +"'"
					cUpdate += " WHERE P02_ID  = '"+(cAli)->P02_ID  +"'"
					If !Empty(cUpdate)
						TCSQLExec(cUpdate)
					EndIf
				EndIf	
			End Transaction	
      EndIF

     	
 	   (cAli)->(dbSkip())							
EndDo						

U_FSCloAre(cAli)
aEval(aAreOld, {|xAux| RestArea(xAux)})
Return Nil

