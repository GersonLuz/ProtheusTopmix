#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"  
#include "MSGRAPHI.CH"
#Define CRLF  Chr(13)+Chr(10)
//-------------------------------------------------------------------
/*/{Protheus.doc} MCFATP01()
Verifica pendencias no faturamento x recebimento.

@protected
@author    Rodrigo Carvalho
@since     29/01/2015
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function MCFATP01()

Local   oDlgMain    
Local   aArea        := GetArea()

Private lBetomix     := PswID() $ SuperGetMV("MC_USRPFAT",,"000000/")

Private dDataI       := CtoD("01" + SubStr(DtoC(LastDay(Date()-5,1)),3,8))
Private dDataF       := LastDay(Date()-5)

Private cFileDB01    := ""
Private aStr001      := {}
Private aBrw001      := {}

Private cFileDB11    := ""
Private aStr011      := {}
Private aBrw011      := {}

Private cFileDB02    := ""
Private aStr002      := {}
Private aBrw002      := {}

Private cFileDB03    := ""
Private aStr003      := {}
Private aBrw003      := {}

Private cFileDB04    := ""
Private aStr004      := {}
Private aBrw004      := {}

Private cFileDB05    := ""
Private aStr005      := {}
Private aBrw005      := {}

Private cFileDB06    := ""
Private aStr006      := {}
Private aBrw006      := {}

Private cPict        := "@E 999,999,999.99"
Private cPesquisa    := Space(25)

Private nTotFat1     := 0
Private nTotSal1     := 0
Private nTotAtras1   := 0
Private nTotFat2     := 0
Private nTotSal2     := 0
Private nTotPen3     := 0
Private nASemInt5    := 0
Private nCSemInt5    := 0
Private aDados       := {}
Private aAbas        := {}
Private lInterface   := .T.

Define FONT oBold   NAME "Arial" Size 0, -14 BOLD
Define FONT oBold2  NAME "Arial" Size 0, -20 BOLD
Define FONT oBold3  NAME "Arial" Size 0, -80 BOLD

aAdd(aAbas,"Faturamento e Saldo do Periodo")
aAdd(aAbas,"Saldo em Aberto Analítico")
aAdd(aAbas,"Pendentes Faturamento")   
aAdd(aAbas,"Previsão Recebimento")   
aAdd(aAbas,"Pedidos Não Integrados")   
aAdd(aAbas,"Pedidos na Interface")   
aAdd(aAbas,"Grafico")   

Do While .T.
   If ! FFiltroIni() // filtra a data 
      Return .t.
   Endif   

   Processa({|| FCriaDBTmp() })  // cria as tabelas temporarias
                
   Define Msdialog oDlgMain Title "Painel de Pedidos Faturados / Pedidos Pendentes / Saldo em Aberto" OF oMainWnd Pixel From 040,040 TO 650,1300

   @ 010,005 FOLDER oFolder OF oDlgMain PROMPT aAbas[1],aAbas[2],aAbas[3],aAbas[4],aAbas[5],aAbas[6],aAbas[7] Pixel Size 622,270
   /***************************************************************************************************/
   // FOLDER: 01
   /***************************************************************************************************/
   DbSelectArea("DBTMP01")
   DbGoTop()
   @ 001,001  SAY  "Faturamento diário com o Saldo em aberto" Pixel OF oFolder:aDialogs[1]
   oObjFld01 := BrGetDDB():New( 010,1,300,240,,,, oFolder:aDialogs[1] ,,,,,,,,,,,,.F.,"DBTMP01",.T.,,.F.,,, ) 

   For nXy := 1 To Len(aBrw001)
       bColumn := &("{|| DBTMP01->"+aBrw001[nXy][1]+" }")
       nTamPix := aStr001[nXy][3] * IIf(aStr001 [nXy][2]=="D",4,4) // alterado para 4 provisorio.
       nTamPix := IIf(nTamPix <= 0,Len(aBrw001[nXy][2]),nTamPix)
       cPosInf := IIf(aStr001 [nXy][2]=="C","LEFT","RIGHT")
       oObjFld01:AddColumn(TCColumn():New( aBrw001[nXy][2] , bColumn ,aBrw001[nXy][4],,, cPosInf , nTamPix ,.F.,.F.,,,,.F.,))
   Next

   DbSelectArea("DBTMP11")
   DbGoTop()

   @ 001,310  SAY  "Saldo em aberto por filial" Pixel OF oFolder:aDialogs[1]
   oObjFld11 := BrGetDDB():New( 010,305,310,140,,,, oFolder:aDialogs[1] ,,,,,,,,,,,,.F.,"DBTMP11",.T.,,.F.,,, ) 

   For nXy := 1 To Len(aBrw011)
       bColumn := &("{|| DBTMP11->"+aBrw011[nXy][1]+" }")
       nTamPix := aStr011[nXy][3] * IIf(aStr011 [nXy][2]=="D",4,4)
       nTamPix := IIf(nTamPix <= 0,Len(aBrw011[nXy][2]),nTamPix)
       cPosInf := IIf(aStr011 [nXy][2]=="C","LEFT","RIGHT")
       oObjFld11:AddColumn(TCColumn():New( aBrw011[nXy][2] , bColumn ,aBrw011[nXy][4],,, cPosInf , nTamPix ,.F.,.F.,,,,.F.,))
   Next
   @ 160,310  SAY  "Valor Total Faturado R$" Size 100,10 Pixel OF oFolder:aDialogs[1] FONT oBold 
   @ 160,410  MSGET oTotal1 VAR nTotFat1   Picture "999,999,999.99" Size 080,10 Pixel OF oFolder:aDialogs[1] When .f. FONT oBold 
   @ 180,310  SAY  "Saldo a Vencer       R$" Size 100,10 Pixel OF oFolder:aDialogs[1] FONT oBold 
   @ 180,410  MSGET oSaldo1 VAR nTotSal1   Picture "99,999,999.99" Size 080,10 Pixel OF oFolder:aDialogs[1] When .f. FONT oBold 
   @ 200,310  SAY  "Saldo Vencido        R$" Size 100,10 Pixel OF oFolder:aDialogs[1] FONT oBold 
   @ 200,410  MSGET oAtras1 VAR nTotAtras1 Picture "99,999,999.99" Size 080,10 Pixel OF oFolder:aDialogs[1] When .f. FONT oBold 
   @ 220,310  SAY  "Percentual em Atraso % " Size 100,10 Pixel OF oFolder:aDialogs[1] FONT oBold 
   @ 220,410  MSGET oPerce1 VAR Round(nTotAtras1 * 100/nTotFat1,2) Size 50,10 Picture "@r  999.99 %" Pixel OF oFolder:aDialogs[1] When .f. FONT oBold 
   /***************************************************************************************************/
   // FOLDER: 02
   /***************************************************************************************************/
   DbSelectArea("DBTMP02")
   DbGoTop()

   oObjFld02 := BrGetDDB():New( 1,1,615,230,,,, oFolder:aDialogs[2] ,,,,,,,,,,,,.F.,"DBTMP02",.T.,,.F.,,, ) 

   For nXy := 1 To Len(aBrw002)
       bColumn := &("{|| DBTMP02->"+aBrw002[nXy][1]+" }")
       nTamPix := aStr002[nXy][3] * IIf(aStr002 [nXy][2]=="D",4,4) 
       nTamPix := IIf(nTamPix <= 0,Len(aBrw002[nXy][2]),nTamPix)
       cPosInf := IIf(aStr002 [nXy][2]=="C","LEFT","RIGHT")
       oObjFld02:AddColumn(TCColumn():New( aBrw002[nXy][2] , bColumn ,aBrw002[nXy][4],,, cPosInf , nTamPix ,.F.,.F.,,,,.F.,))
   Next
   /***************************************************************************************************/
   // FOLDER: 03
   /***************************************************************************************************/
   DbSelectArea("DBTMP03")
   DbGoTop()

   oObjFld03 := BrGetDDB():New( 1,1,615,230,,,, oFolder:aDialogs[3] ,,,,,,,,,,,,.F.,"DBTMP03",.T.,,.F.,,, ) 

   For nXy := 1 To Len(aBrw003)
       bColumn := &("{|| DBTMP03->"+aBrw003[nXy][1]+" }")
       nTamPix := aStr003[nXy][3] * IIf(aStr003 [nXy][2]=="D",4,4) 
       nTamPix := IIf(nTamPix <= 0,Len(aBrw003[nXy][2]),nTamPix)
       cPosInf := IIf(aStr003 [nXy][2]=="C","LEFT","RIGHT")
       oObjFld03:AddColumn(TCColumn():New( aBrw003[nXy][2] , bColumn ,aBrw003[nXy][4],,, cPosInf , nTamPix ,.F.,.F.,,,,.F.,))
   Next

   @ 240,318  SAY  "Valor Pendente       R$" Size 100,10 Pixel OF oFolder:aDialogs[3] FONT oBold 
   @ 240,418  MSGET oPendente VAR nTotPen3 Picture "99,999,999.99" Size 080,10 Pixel OF oFolder:aDialogs[3] When .f. FONT oBold 
   /***************************************************************************************************/
   // FOLDER: 04
   /***************************************************************************************************/
   DbSelectArea("DBTMP04")
   DbGoTop()

   oObjFld04 := BrGetDDB():New( 1,1,615,230,,,, oFolder:aDialogs[4] ,,,,,,,,,,,,.F.,"DBTMP04",.T.,,.F.,,, ) 

   For nXy := 1 To Len(aBrw004)
       bColumn := &("{|| DBTMP04->"+aBrw004[nXy][1]+" }")
       nTamPix := aStr004[nXy][3] * IIf(aStr004 [nXy][2]=="D",4,4) 
       nTamPix := IIf(nTamPix <= 0,Len(aBrw004[nXy][2]),nTamPix)
       cPosInf := IIf(aStr004 [nXy][2]=="C","LEFT","RIGHT")
       oObjFld04:AddColumn(TCColumn():New( aBrw004[nXy][2] , bColumn ,aBrw004[nXy][4],,, cPosInf , nTamPix ,.F.,.F.,,,,.F.,))
   Next
   /***************************************************************************************************/
   // FOLDER: 05
   /***************************************************************************************************/
   If lBetomix
   DbSelectArea("DBTMP05")
   DbGoTop()

   oObjFld05 := BrGetDDB():New( 1,1,615,230,,,, oFolder:aDialogs[5] ,,,,,,,,,,,,.F.,"DBTMP05",.T.,,.F.,,, ) 

   For nXy := 1 To Len(aBrw005)
       bColumn := &("{|| DBTMP05->"+aBrw005[nXy][1]+" }")
       nTamPix := aStr005[nXy][3] * IIf(aStr005 [nXy][2]=="D",4,4) 
       nTamPix := IIf(nTamPix <= 0,Len(aBrw005[nXy][2]),nTamPix)
       cPosInf := IIf(aStr005 [nXy][2]=="C","LEFT","RIGHT")
       oObjFld05:AddColumn(TCColumn():New( aBrw005[nXy][2] , bColumn ,aBrw005[nXy][4],,, cPosInf , nTamPix ,.F.,.F.,,,,.F.,))
   Next

   @ 240,001  SAY  "Vr. Ativo não integrado R$" Size 120,10 Pixel OF oFolder:aDialogs[5] FONT oBold 
   @ 240,110  MSGET oASemIntr VAR nASemInt5 Picture "99,999,999.99" Size 080,10 Pixel OF oFolder:aDialogs[5] When .f. FONT oBold 
   @ 240,201  SAY  "Vr. Cancelado não integrado R$" Size 120,10 Pixel OF oFolder:aDialogs[5] FONT oBold 
   @ 240,320  MSGET oCSemIntr VAR nCSemInt5 Picture "99,999,999.99" Size 080,10 Pixel OF oFolder:aDialogs[5] When .f. FONT oBold 
   Else
   @ 001,001  SAY  "OBS: Dados liberados apenas para o administrador do sistema" Pixel OF oFolder:aDialogs[5]
   Endif
   /***************************************************************************************************/
   // FOLDER: 06
   /***************************************************************************************************/
   If lBetomix
   DbSelectArea("DBTMP06")
   DbGoTop()

   oObjFld06 := BrGetDDB():New( 1,1,615,230,,,, oFolder:aDialogs[6] ,,,,,,,,,,,,.F.,"DBTMP06",.T.,,.F.,,, ) 

   For nXy := 1 To Len(aBrw006)
       bColumn := &("{|| DBTMP06->"+aBrw006[nXy][1]+" }")
       nTamPix := aStr006[nXy][3] * IIf(aStr006 [nXy][2]=="D",4,4) 
       nTamPix := IIf(nTamPix <= 0,Len(aBrw006[nXy][2]),nTamPix)
       cPosInf := IIf(aStr006 [nXy][2]=="C","LEFT","RIGHT")
       oObjFld06:AddColumn(TCColumn():New( aBrw006[nXy][2] , bColumn ,aBrw006[nXy][4],,, cPosInf , nTamPix ,.F.,.F.,,,,.F.,))
   Next
   Else
   @ 001,001  SAY  "OBS: Dados liberados apenas para o administrador do sistema" Pixel OF oFolder:aDialogs[6]
   Endif
   /***************************************************************************************************/
   // FOLDER: 07
   /***************************************************************************************************/
   Grafico(7)  
   oFolder:SetOption(7)
   /***************************************************************************************************/
   // tela principal
   /***************************************************************************************************/   

   oTMsgBar   := TMsgBar():New(oDlgMain,"©Topmix",.F.,.F.,.F.,.F., RGB(116,116,116),,,.F.)      
   oTMsgItem3 := TMsgItem():New( oTMsgBar,MsDate(), 100,,,,.T., {||} ) 

   @ 235,520 BUTTON "&Exporta" Size 036,16 ACTION Processa({||fExpExcel(aDados)})Pixel OF oFolder:aDialogs[1]
   @ 257,570 BUTTON "&Sair"    Size 036,16 ACTION oDlgMain:End()  Pixel OF oDlgMain //oFolder:aDialogs[1]

   Activate Msdialog oDlgMain Centered 

   FLimpaTMP() // apagar as tabelas temporarias 

Enddo
RestArea(aArea)        
Return(.T.)



//-------------------------------------------------------------------
/*/{Protheus.doc} FCriaDBTmp()
Monta a query e executa

@protected
@author    Rodrigo Carvalho
@since     29/01/2015
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FCriaDBTmp()

Local cQuery1  := ""
Local cQuery11 := ""
Local cQuery2  := ""
Local cQuery3  := ""
Local cQuery4  := ""
Local cQuery41 := ""
Local cQuery42 := ""
Local cQuery5  := ""
Local cCmpsAlias := ""
Local cCmps := ""

ProcRegua(9)

cQuery1 :=  "SELECT M0_FILIAL FILIAL,"  +CRLF
cQuery1 +=  "       F2_EMISSAO,"        +CRLF
cQuery1 +=  "   SUM(D2_TOTAL) D2_TOTAL,"+CRLF
cQuery1 +=  "   SUM(VENCIDO) VENCIDO, " +CRLF
cQuery1 +=  "   SUM(E1_SALDO) E1_SALDO,"+CRLF
cQuery1 +=  "       F2_FILIAL"+CRLF
cQuery1 +=  "FROM ("+CRLF
cQuery1 +=  "SELECT *,"+CRLF
cQuery1 +=  "       ISNULL((SELECT SUM(E1_SALDO)"+CRLF
cQuery1 +=  "                FROM "+RetSqlName("SE1")+" E1 (nolock)"+CRLF
cQuery1 +=  "               WHERE E1_FILORIG = F2_FILIAL"+CRLF
cQuery1 +=  "                 AND E1_PREFIXO = F2_PREFIXO"+CRLF
cQuery1 +=  "                 AND E1_SERIE   = D2_SERIE"+CRLF
cQuery1 +=  "                 AND E1_NUM     = F2_DOC"+CRLF
cQuery1 +=  "                 AND F2_CLIENTE = E1_CLIENTE"+CRLF
cQuery1 +=  "                 AND E1_LOJA    = F2_LOJA"+CRLF
cQuery1 +=  "                 AND E1_VENCREA < '"+DtoS(Date())+"'"+CRLF
cQuery1 +=  "                 AND E1.D_E_L_E_T_ <> '*'), 0) VENCIDO,"+CRLF
cQuery1 +=  "       ISNULL((SELECT SUM(E1_SALDO)"+CRLF
cQuery1 +=  "                FROM "+RetSqlName("SE1")+" E1 (nolock)"+CRLF
cQuery1 +=  "               WHERE E1_FILORIG = F2_FILIAL"+CRLF
cQuery1 +=  "                 AND E1_PREFIXO = F2_PREFIXO"+CRLF
cQuery1 +=  "                 AND E1_SERIE   = D2_SERIE"+CRLF
cQuery1 +=  "                 AND E1_NUM     = F2_DOC"+CRLF
cQuery1 +=  "                 AND F2_CLIENTE = E1_CLIENTE"+CRLF
cQuery1 +=  "                 AND E1_LOJA    = F2_LOJA"+CRLF
cQuery1 +=  "                 AND E1_VENCREA >= '"+DtoS(Date())+"'"+CRLF
cQuery1 +=  "                 AND E1.D_E_L_E_T_ <> '*'), 0) E1_SALDO"+CRLF
cQuery1 +=  " FROM "+CRLF
cQuery1 +=  "(SELECT F2_FILIAL,"+CRLF
cQuery1 +=  "        D2_SERIE,"+CRLF
cQuery1 +=  "        F2_PREFIXO,"+CRLF
cQuery1 +=  "   CAST(F2_EMISSAO AS SMALLDATETIME) F2_EMISSAO,"+CRLF
cQuery1 +=  "        F2_TIPO,"+CRLF
cQuery1 +=  "        F2_DOC,"+CRLF
cQuery1 +=  "        F2_CLIENTE,"+CRLF
cQuery1 +=  "        F2_LOJA,"+CRLF
cQuery1 +=  "    SUM(D2_TOTAL - D2_DESCON) D2_TOTAL,"+CRLF
cQuery1 +=  "        D2_PEDIDO"+CRLF
cQuery1 +=  "   FROM "+RetSqlName("SD2")+" D2 (nolock) "+CRLF
cQuery1 +=  " INNER JOIN "+RetSqlName("SF2")+" F2 ON F2_FILIAL  = D2_FILIAL"+CRLF
cQuery1 +=  "                     AND F2_DOC     = D2_DOC"+CRLF
cQuery1 +=  "                     AND F2_SERIE   = D2_SERIE"+CRLF
cQuery1 +=  "                     AND F2_CLIENTE = D2_CLIENTE"+CRLF
cQuery1 +=  "                     AND F2_LOJA    = D2_LOJA"+CRLF
cQuery1 +=  "                     AND F2.D_E_L_E_T_ <> '*'"+CRLF
cQuery1 +=  " WHERE D2_TIPO    <> 'D'"+CRLF
cQuery1 +=  "   AND D2_EMISSAO BETWEEN '"+DtoS(dDatai)+"' AND '"+DtoS(dDataf)+"'"+ CRLF
cQuery1 +=  "   AND D2_TES IN (SELECT F4_CODIGO"+CRLF
cQuery1 +=  "                    FROM "+RetSqlName("SF4")+" F4 (nolock) "+CRLF
cQuery1 +=  "                   WHERE F4_DUPLIC = 'S'"+CRLF
cQuery1 +=  "                     AND F4_CODIGO >= '500'"+CRLF
cQuery1 +=  "                     AND F4.D_E_L_E_T_ <> '*')"+CRLF
cQuery1 +=  "   AND D2.D_E_L_E_T_ <> '*'"+CRLF
cQuery1 +=  "GROUP BY F2_FILIAL,"+CRLF
cQuery1 +=  "         D2_SERIE,"+CRLF
cQuery1 +=  "         F2_PREFIXO,"+CRLF
cQuery1 +=  "         F2_TIPO,"+CRLF
cQuery1 +=  "         F2_DOC,"+CRLF
cQuery1 +=  "         F2_CLIENTE,"+CRLF
cQuery1 +=  "         F2_LOJA,"+CRLF
cQuery1 +=  "         F2_EMISSAO,"+CRLF
cQuery1 +=  "         D2_PEDIDO) FATURAMENTO "+CRLF
cQuery1 +=  ") PERIODO "+CRLF
cQuery1 +=  " LEFT OUTER JOIN SIGAMAT ON M0_CODFIL = F2_FILIAL AND SIGAMAT.D_E_L_E_T_ <> '*'"+ CRLF
cQuery1 +=  "GROUP BY M0_FILIAL,F2_FILIAL,F2_EMISSAO"+CRLF
cQuery1 +=  "ORDER BY F2_FILIAL,F2_EMISSAO"+CRLF

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery1),"QTMP01",.F.,.T.) 
IncProc()
cFileDB01 := U_TRQUERY("QTMP01","DBTMP01")   
       
DbSelectArea("DBTMP01") 
DbGoTop()
nTotFat1   := 0
nTotSal1   := 0
nTotAtras1 := 0
Do While ! Eof()
   nTotFat1   += DBTMP01->D2_TOTAL
   nTotSal1   += DBTMP01->E1_SALDO
   nTotAtras1 += DBTMP01->VENCIDO
   DbSkip()
Enddo    
IncProc()
DbGoTop()

aStr001 := DbStruct() 
aBrw001 := U_fAtuaStrDB( aStr001 )

cQuery11 :=  "SELECT M0_FILIAL FILIAL,"+CRLF
cQuery11 +=  "   SUM(D2_TOTAL) D2_TOTAL,"+CRLF
cQuery11 +=  "   SUM(VENCIDO)  VENCIDO,"+CRLF
cQuery11 +=  "   SUM(E1_SALDO) E1_SALDO,"+CRLF
cQuery11 +=  "   ROUND(SUM(E1_SALDO + VENCIDO) * 100 / SUM(D2_TOTAL),3) PERCENTUAL  "+CRLF
cQuery11 +=  "FROM ("+CRLF
cQuery11 +=  "SELECT *,"+CRLF
cQuery11 +=  "       ISNULL((SELECT SUM(E1_SALDO)"+CRLF
cQuery11 +=  "                FROM "+RetSqlName("SE1")+" E1 (nolock)"+CRLF
cQuery11 +=  "               WHERE E1_FILORIG = F2_FILIAL"+CRLF
cQuery11 +=  "                 AND E1_PREFIXO = F2_PREFIXO"+CRLF
cQuery11 +=  "                 AND E1_SERIE   = D2_SERIE"+CRLF
cQuery11 +=  "                 AND E1_NUM     = F2_DOC"+CRLF
cQuery11 +=  "                 AND F2_CLIENTE = E1_CLIENTE"+CRLF
cQuery11 +=  "                 AND E1_LOJA    = F2_LOJA"+CRLF
cQuery11 +=  "                 AND E1_VENCREA < '"+DtoS(Date())+"'"+CRLF
cQuery11 +=  "                 AND E1.D_E_L_E_T_ <> '*'), 0) VENCIDO,"+CRLF
cQuery11 +=  "       ISNULL((SELECT SUM(E1_SALDO)"+CRLF
cQuery11 +=  "                FROM "+RetSqlName("SE1")+" E1 (nolock)"+CRLF
cQuery11 +=  "               WHERE E1_FILORIG = F2_FILIAL"+CRLF
cQuery11 +=  "                 AND E1_PREFIXO = F2_PREFIXO"+CRLF
cQuery11 +=  "                 AND E1_SERIE   = D2_SERIE"+CRLF
cQuery11 +=  "                 AND E1_NUM     = F2_DOC"+CRLF
cQuery11 +=  "                 AND F2_CLIENTE = E1_CLIENTE"+CRLF
cQuery11 +=  "                 AND E1_LOJA    = F2_LOJA"+CRLF
cQuery11 +=  "                 AND E1_VENCREA >= '"+DtoS(Date())+"'"+CRLF
cQuery11 +=  "                 AND E1.D_E_L_E_T_ <> '*'), 0) E1_SALDO"+CRLF
cQuery11 +=  " FROM "+CRLF
cQuery11 +=  "(SELECT F2_FILIAL,"+CRLF
cQuery11 +=  "        D2_SERIE,"+CRLF
cQuery11 +=  "        F2_PREFIXO,"+CRLF
cQuery11 +=  "   CAST(F2_EMISSAO AS SMALLDATETIME) F2_EMISSAO,"+CRLF
cQuery11 +=  "        F2_TIPO,"+CRLF
cQuery11 +=  "        F2_DOC,"+CRLF
cQuery11 +=  "        F2_CLIENTE,"+CRLF
cQuery11 +=  "        F2_LOJA,"+CRLF
cQuery11 +=  "    SUM(D2_TOTAL - D2_DESCON) D2_TOTAL,"+CRLF
cQuery11 +=  "        D2_PEDIDO"+CRLF
cQuery11 +=  "   FROM "+RetSqlName("SD2")+" D2 (nolock) "+CRLF
cQuery11 +=  " INNER JOIN "+RetSqlName("SF2")+" F2 "+CRLF
cQuery11 +=  "                      ON F2_FILIAL  = D2_FILIAL"+CRLF
cQuery11 +=  "                     AND F2_DOC     = D2_DOC"+CRLF
cQuery11 +=  "                     AND F2_SERIE   = D2_SERIE"+CRLF
cQuery11 +=  "                     AND F2_CLIENTE = D2_CLIENTE"+CRLF
cQuery11 +=  "                     AND F2_LOJA    = D2_LOJA"+CRLF
cQuery11 +=  "                     AND F2.D_E_L_E_T_ <> '*'"+CRLF
cQuery11 +=  " WHERE D2_TIPO    <> 'D'"+CRLF
cQuery11 +=  "   AND D2_EMISSAO BETWEEN '"+DtoS(dDatai)+"' AND '"+DtoS(dDataf)+"'"+ CRLF
cQuery11 +=  "   AND D2_TES IN (SELECT F4_CODIGO"+CRLF
cQuery11 +=  "                    FROM "+RetSqlName("SF4")+" F4 (nolock) "+CRLF
cQuery11 +=  "                   WHERE F4_DUPLIC = 'S'"+CRLF
cQuery11 +=  "                     AND F4_CODIGO >= '500'"+CRLF
cQuery11 +=  "                     AND F4.D_E_L_E_T_ <> '*')"+CRLF
cQuery11 +=  "   AND D2.D_E_L_E_T_ <> '*'"+CRLF
cQuery11 +=  "GROUP BY F2_FILIAL,"+CRLF
cQuery11 +=  "         D2_SERIE,"+CRLF
cQuery11 +=  "         F2_PREFIXO,"+CRLF
cQuery11 +=  "         F2_TIPO,"+CRLF
cQuery11 +=  "         F2_DOC,"+CRLF
cQuery11 +=  "         F2_CLIENTE,"+CRLF
cQuery11 +=  "         F2_LOJA,"+CRLF
cQuery11 +=  "         F2_EMISSAO,"+CRLF
cQuery11 +=  "         D2_PEDIDO) FATURAMENTO "+CRLF
cQuery11 +=  ") PERIODO "+CRLF
cQuery11 +=  " LEFT OUTER JOIN SIGAMAT ON M0_CODFIL = F2_FILIAL AND SIGAMAT.D_E_L_E_T_ <> '*'"+ CRLF
cQuery11 +=  "GROUP BY M0_FILIAL"+CRLF
cQuery11 +=  "ORDER BY 3 desc"+CRLF

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery11),"QTMP11",.F.,.T.) 
IncProc()
cFileDB01 := U_TRQUERY("QTMP11","DBTMP11")   
       
DbSelectArea("DBTMP11") 

aStr011 := DbStruct() 
aBrw011 := U_fAtuaStrDB( aStr011 )

cQuery2 :=  "SELECT M0_FILIAL FILIAL,"+CRLF
cQuery2 +=  "       F2_FILIAL,"+CRLF
cQuery2 +=  "       F2_EMISSAO,"+CRLF
cQuery2 +=  "       F2_PREFIXO,"+CRLF
cQuery2 +=  "       F2_DOC,"+CRLF
cQuery2 +=  "       A1_NOME,"+CRLF  
cQuery2 +=  "       D2_PEDIDO,"+CRLF
cQuery2 +=  "   SUM(D2_TOTAL) D2_TOTAL,"+CRLF
cQuery2 +=  "   SUM(VENCIDO)  VENCIDO, "+CRLF
cQuery2 +=  "   SUM(E1_SALDO) E1_SALDO,"+CRLF
cQuery2 +=  "       F2_CLIENTE,"+CRLF
cQuery2 +=  "       F2_LOJA"+CRLF  
cQuery2 +=  "FROM ("+CRLF
cQuery2 +=  "SELECT *,"+CRLF
cQuery2 +=  "       ISNULL((SELECT SUM(E1_SALDO)"+CRLF
cQuery2 +=  "                FROM "+RetSqlName("SE1")+" E1 (nolock)"+CRLF
cQuery2 +=  "               WHERE E1_FILORIG = F2_FILIAL"+CRLF
cQuery2 +=  "                 AND E1_PREFIXO = F2_PREFIXO"+CRLF
cQuery2 +=  "                 AND E1_SERIE   = D2_SERIE"+CRLF
cQuery2 +=  "                 AND E1_NUM     = F2_DOC"+CRLF
cQuery2 +=  "                 AND F2_CLIENTE = E1_CLIENTE"+CRLF
cQuery2 +=  "                 AND E1_LOJA    = F2_LOJA"+CRLF
cQuery2 +=  "                 AND E1_VENCREA < '"+DtoS(Date())+"'"+CRLF
cQuery2 +=  "                 AND E1.D_E_L_E_T_ <> '*'), 0) VENCIDO,"+CRLF
cQuery2 +=  "       ISNULL((SELECT SUM(E1_SALDO)"+CRLF
cQuery2 +=  "                FROM "+RetSqlName("SE1")+" E1 (nolock)"+CRLF
cQuery2 +=  "               WHERE E1_FILORIG = F2_FILIAL"+CRLF
cQuery2 +=  "                 AND E1_PREFIXO = F2_PREFIXO"+CRLF
cQuery2 +=  "                 AND E1_SERIE   = D2_SERIE"+CRLF
cQuery2 +=  "                 AND E1_NUM     = F2_DOC"+CRLF
cQuery2 +=  "                 AND F2_CLIENTE = E1_CLIENTE"+CRLF
cQuery2 +=  "                 AND E1_LOJA    = F2_LOJA"+CRLF
cQuery2 +=  "                 AND E1_VENCREA >= '"+DtoS(Date())+"'"+CRLF
cQuery2 +=  "                 AND E1.D_E_L_E_T_ <> '*'), 0) E1_SALDO"+CRLF
cQuery2 +=  " FROM "+CRLF
cQuery2 +=  "(SELECT F2_FILIAL,"+CRLF
cQuery2 +=  "        D2_SERIE,"+CRLF
cQuery2 +=  "        F2_PREFIXO,"+CRLF
cQuery2 +=  "   CAST(F2_EMISSAO AS SMALLDATETIME) F2_EMISSAO,"+CRLF
cQuery2 +=  "        F2_TIPO,"+CRLF
cQuery2 +=  "        F2_DOC,"+CRLF
cQuery2 +=  "        F2_CLIENTE,"+CRLF
cQuery2 +=  "        F2_LOJA,"+CRLF
cQuery2 +=  "    SUM(D2_TOTAL - D2_DESCON) D2_TOTAL,"+CRLF
cQuery2 +=  "        D2_PEDIDO"+CRLF
cQuery2 +=  "   FROM "+RetSqlName("SD2")+" D2 (nolock) "+CRLF
cQuery2 +=  " INNER JOIN "+RetSqlName("SF2")+" F2 ON F2_FILIAL  = D2_FILIAL"+CRLF
cQuery2 +=  "                     AND F2_DOC     = D2_DOC"+CRLF
cQuery2 +=  "                     AND F2_SERIE   = D2_SERIE"+CRLF
cQuery2 +=  "                     AND F2_CLIENTE = D2_CLIENTE"+CRLF
cQuery2 +=  "                     AND F2_LOJA    = D2_LOJA"+CRLF
cQuery2 +=  "                     AND F2.D_E_L_E_T_ <> '*'"+CRLF
cQuery2 +=  " WHERE D2_TIPO    <> 'D'"+CRLF
cQuery2 +=  "   AND D2_EMISSAO BETWEEN '"+DtoS(dDatai)+"' AND '"+DtoS(dDataf)+"'"+ CRLF
cQuery2 +=  "   AND D2_TES IN (SELECT F4_CODIGO"+CRLF
cQuery2 +=  "                    FROM "+RetSqlName("SF4")+" F4 (nolock) "+CRLF
cQuery2 +=  "                   WHERE F4_DUPLIC = 'S'"+CRLF
cQuery2 +=  "                     AND F4_CODIGO >= '500'"+CRLF
cQuery2 +=  "                     AND F4.D_E_L_E_T_ <> '*')"+CRLF
cQuery2 +=  "   AND D2.D_E_L_E_T_ <> '*'"+CRLF
cQuery2 +=  "GROUP BY F2_FILIAL,"+CRLF
cQuery2 +=  "         D2_SERIE,"+CRLF
cQuery2 +=  "         F2_PREFIXO,"+CRLF
cQuery2 +=  "         F2_TIPO,"+CRLF
cQuery2 +=  "         F2_DOC,"+CRLF
cQuery2 +=  "         F2_CLIENTE,"+CRLF
cQuery2 +=  "         F2_LOJA,"+CRLF
cQuery2 +=  "         F2_EMISSAO,"+CRLF
cQuery2 +=  "         D2_PEDIDO) FATURAMENTO "+CRLF
cQuery2 +=  ") PERIODO "+CRLF
cQuery2 +=  " LEFT OUTER JOIN SIGAMAT ON M0_CODFIL = F2_FILIAL AND SIGAMAT.D_E_L_E_T_ <> '*'"+ CRLF
cQuery2 +=  " LEFT OUTER JOIN "+RetSqlName("SA1")+" A1 (nolock) ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA AND A1.D_E_L_E_T_ <> '*' "+CRLF
cQuery2 +=  " WHERE ( E1_SALDO > 0 OR VENCIDO > 0 ) "+CRLF
cQuery2 +=  " GROUP BY M0_FILIAL,F2_FILIAL,F2_EMISSAO,F2_PREFIXO,F2_DOC,F2_CLIENTE,A1_NOME,F2_LOJA,D2_PEDIDO"+CRLF
cQuery2 +=  "ORDER BY F2_FILIAL,F2_EMISSAO"+CRLF

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery2),"QTMP02",.F.,.T.) 
IncProc()
cFileDB02 := U_TRQUERY("QTMP02","DBTMP02")   
       
DbSelectArea("DBTMP02")
DbGoTop()
nTotFat2 := 0
nTotSal2 := 0
Do While ! Eof()
   nTotFat2 += DBTMP02->D2_TOTAL
   nTotSal2 += DBTMP02->(E1_SALDO + VENCIDO)
   DbSkip()
Enddo
DbGoTop()

aStr002 := DbStruct() 
aBrw002 := U_fAtuaStrDB( aStr002 )

cQuery3 :=  "SELECT"+    CRLF   
cQuery3 +=  "   M0_FILIAL FILIAL,"+CRLF
cQuery3 +=  "   PED.*,"+CRLF
cQuery3 +=  "   CAST(F2_EMISSAO AS SMALLDATETIME) F2_EMISSAO,"+ CRLF
cQuery3 +=  "   F2_CHVNFE"+      CRLF
cQuery3 +=  "   FROM ("+         CRLF
cQuery3 +=  "        SELECT C5_FILIAL,"+  CRLF
cQuery3 +=  "               C5_NUM,"+     CRLF
cQuery3 +=  "               CAST(C5_EMISSAO AS SMALLDATETIME) C5_EMISSAO,"+ CRLF
cQuery3 +=  "               C5_CLIENTE,"+ CRLF
cQuery3 +=  "               C5_LOJACLI,"+ CRLF
cQuery3 +=  "               A1_NOME,"+    CRLF
cQuery3 +=  "               A1_NREDUZ,"+  CRLF
cQuery3 +=  "           SUM(C6_VALOR) C6_VALOR,"+ CRLF
cQuery3 +=  "               C5_NOTA,"+  CRLF
cQuery3 +=  "               C5_SERIE,"+ CRLF
cQuery3 +=  "         RTRIM(C5_ZPEDIDO) C5_ZPEDIDO"+ CRLF
cQuery3 +=  "          FROM "+RetSqlName("SC5")+" C5 (nolock),"+CRLF
cQuery3 +=  "               "+RetSqlName("SC6")+" C6 (nolock),"+CRLF
cQuery3 +=  "               "+RetSqlName("SA1")+" A1 (nolock),"+CRLF
cQuery3 +=  "               "+RetSqlName("SF4")+" F4 (nolock)" +CRLF
cQuery3 +=  "         WHERE C5_FILIAL  = C6_FILIAL "+ CRLF
cQuery3 +=  "           AND C5_NUM     = C6_NUM"+     CRLF
cQuery3 +=  "           AND C5_CLIENTE = A1_COD "+    CRLF
cQuery3 +=  "           AND C5_LOJACLI = A1_LOJA"+    CRLF
cQuery3 +=  "           AND C6_TES     = F4_CODIGO"+  CRLF
cQuery3 +=  "           AND F4_DUPLIC  = 'S'"+ CRLF
cQuery3 +=  "           AND C5.D_E_L_E_T_ <> '*'"+ CRLF
cQuery3 +=  "           AND C6.D_E_L_E_T_ <> '*'"+ CRLF
cQuery3 +=  "           AND A1.D_E_L_E_T_ <> '*'"+ CRLF
cQuery3 +=  "           AND F4.D_E_L_E_T_ <> '*'"+ CRLF
cQuery3 +=  "           AND C5_NOTA = ' '"+ CRLF  // Acrescentado para listar apenas pendente de faturamento. (sql abaixo trata SF2 provisorio)
cQuery3 +=  "           AND C5_EMISSAO BETWEEN '"+DtoS(dDatai)+"' AND '"+DtoS(dDataf)+"'"+ CRLF
cQuery3 +=  "         GROUP BY C5_FILIAL,"+    CRLF
cQuery3 +=  "                  C5_ZPEDIDO,"+   CRLF
cQuery3 +=  "                  C5_NUM,"+       CRLF
cQuery3 +=  "                  C5_EMISSAO,"+   CRLF
cQuery3 +=  "                  C5_CLIENTE,"+   CRLF
cQuery3 +=  "                  C5_LOJACLI,"+   CRLF
cQuery3 +=  "                  A1_NOME,"+      CRLF
cQuery3 +=  "                  A1_NREDUZ,"+    CRLF
cQuery3 +=  "                  C5_NOTA,"+      CRLF
cQuery3 +=  "                  C5_SERIE) PED"+ CRLF
cQuery3 +=  " LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 ON F2_FILIAL  = C5_FILIAL "+  CRLF
cQuery3 +=  "                           AND F2_DOC     = C5_NOTA "+    CRLF
cQuery3 +=  "                           AND F2_SERIE   = C5_SERIE "+   CRLF
cQuery3 +=  "                           AND F2_CLIENTE = C5_CLIENTE"+  CRLF
cQuery3 +=  "                           AND SF2.D_E_L_E_T_ <> '*'   "+ CRLF
cQuery3 +=  " LEFT OUTER JOIN SIGAMAT ON M0_CODFIL = C5_FILIAL AND SIGAMAT.D_E_L_E_T_ <> '*'"+ CRLF
cQuery3 +=  " ORDER BY C5_FILIAL, C5_EMISSAO,A1_NOME "+CRLF
       
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery3),"QTMP03",.F.,.T.) 
IncProc()
cFileDB03 := U_TRQUERY("QTMP03","DBTMP03")   
       
DbSelectArea("DBTMP03")    
DbGoTop()
nTotPen3  := 0
Do While ! Eof()
   nTotPen3 += DBTMP03->C6_VALOR
   DbSkip()
Enddo
DbGoTop()

aStr003 := DbStruct() 
aBrw003 := U_fAtuaStrDB( aStr003 )
FLinhaTotal("DBTMP03",aStr003)

cQuery4  :=  "SELECT "+CRLF
cQuery4  +=  "     LEFT(E1_EMIS1,6)   EMISSAO,"  +CRLF
cQuery4  +=  "     (CASE WHEN LEFT(E1_BAIXA,6) = ' ' THEN LEFT(E1_VENCREA,6) ELSE LEFT(E1_BAIXA,6) END) VENCREAL," +CRLF
cQuery4  +=  " ROUND(SUM(E1_VALOR),2) E1_VALOR"  +CRLF
cQuery4  +=  " FROM "+RetSqlName("SE1")+" E1  (nolock) "+CRLF
cQuery4  +=  " INNER JOIN "+RetSqlName("SF2")+" F2  (nolock) "+CRLF
cQuery4  +=  "                      ON F2_FILIAL  = E1_FILORIG "+CRLF
cQuery4  +=  "                     AND F2_SERIE   = E1_SERIE"+   CRLF
cQuery4  +=  "                     AND F2_PREFIXO = E1_PREFIXO"+ CRLF
cQuery4  +=  "                     AND F2_DOC     = E1_NUM "+    CRLF
cQuery4  +=  "                     AND F2_CLIENTE = E1_CLIENTE"+ CRLF
cQuery4  +=  "                     AND F2_LOJA    = E1_LOJA"+    CRLF
cQuery4  +=  "                     AND F2.D_E_L_E_T_ <> '*'"+    CRLF
cQuery4  +=  "                     AND F2_EMISSAO BETWEEN '"+DtoS(dDatai)+"' AND '"+DtoS(dDataf)+"'"+ CRLF
cQuery4  +=  "WHERE E1.D_E_L_E_T_ <> '*' "+CRLF
cQuery4  +=  " GROUP BY "+CRLF
cQuery4  +=  "     LEFT(E1_EMIS1,6),"+CRLF
cQuery4  +=  "     LEFT(E1_BAIXA,6),"+CRLF
cQuery4  +=  "     LEFT(E1_VENCREA,6)"+CRLF
cQuery41 :=  " ORDER BY 2,1"

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery4+cQuery41),"QTMP04",.F.,.T.) 
IncProc()
       
DbSelectArea("QTMP04")
DbGoTop()
cCmpsAlias := ""
cCmps      := ""
cCmpsSUM   := ""
Do While ! Eof()                                  
   If ! Alltrim(QTMP04->VENCREAL) $ cCmps
      cCmpsAlias += "ISNULL([" + Alltrim(QTMP04->VENCREAL) + "],0) AAMM"+Alltrim(QTMP04->VENCREAL)+","
      cCmps      += "[" + Alltrim(QTMP04->VENCREAL) + "] ,"                                           
      cCmpsSUM  += "ISNULL([" + Alltrim(QTMP04->VENCREAL) + "],0)+"
   Endif   
   DbSkip()
Enddo
DbCloseArea("QTMP04")
                                   
cCmpsAlias := SubStr(cCmpsAlias,1,Len(cCmpsAlias)-1)
cCmps      := SubStr(cCmps,1,Len(cCmps)-1)
cCmpsSUM   := "("+SubStr(cCmpsSUM,1,Len(cCmpsSUM)-1)+") Total"

cQuery42 :=  " SELECT EMISSAO,"+cCmpsAlias+CRLF
cQuery42 +=  " ,"+cCmpsSUM+CRLF
cQuery42 +=  "   FROM "+CRLF
cQuery42 +=  "("+cQuery4+") FLUXO "+CRLF
cQuery42 +=  " PIVOT (SUM(E1_VALOR) FOR VENCREAL IN ("+cCmps+")) INVERTIDO "+CRLF
cQuery42 +=  "ORDER BY 1"
    
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery42),"QTMP04",.F.,.T.) 
IncProc()
cFileDB04 := U_TRQUERY("QTMP04","DBTMP04")   

DbSelectArea("DBTMP04")
aStr004 := DBTMP04->(DbStruct())
aBrw004 := U_fAtuaStrDB( aStr004 )
FLinhaTotal("DBTMP04",aStr004)

aDados := {}
aAdd(aDados,{"DBTMP01",aAbas[1],aStr001,aBrw001})
aAdd(aDados,{"DBTMP11","Faturamento Filial",aStr011,aBrw011})
aAdd(aDados,{"DBTMP02",aAbas[2],aStr002,aBrw002})
aAdd(aDados,{"DBTMP03",aAbas[3],aStr003,aBrw003})
aAdd(aDados,{"DBTMP04",aAbas[4],aStr004,aBrw004})

FLeBetomix() // carrega os dados pendentes do betomix

Return .T.




//-------------------------------------------------------------------
/*/{Protheus.doc} fFiltroINI
Periodo de Apuração

@protected
@author    Rodrigo Carvalho
@since     27/08/2015
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function fFiltroINI()

Local lRet       := .F.
Local oFont1     := TFont():New( "Verdana",0,-13,,.F.,0,,400,.F.,.F.,,,,,, )
Local oDlg1,oDataI,oDataF,oBtn2,oSay4

oDlg1      := MSDialog():New( 100,250,300,700,"Informe o Periodo",,,.F.,,,,,,.T.,,oFont1,.T. )
oSay4      := TSay():New( 010,010,{||"Periodo Inicial:"} ,,,oFont1,,,,.T.,CLR_BLUE,CLR_WHITE,099,008)
oSay4      := TSay():New( 035,010,{||"Periodo Final:"}   ,,,oFont1,,,,.T.,CLR_BLUE,CLR_WHITE,099,008)   
@ 10,120 MSGET oDataI VAR dDataI  Picture "@e"   Size 060,10 Pixel OF oDlg1 Color CLR_HRED Font oFont1
@ 35,120 MSGET oDataF VAR dDataF  Picture "@e"   Size 060,10 Pixel OF oDlg1 Color CLR_HRED Font oFont1
oBtn2      := TButton():New( 070,085,"Confirmar",oDlg1,{ || lRet := .T. , oDlg1:End() },050,016,,oFont1,,.T.)
oBtn1      := TButton():New( 070,140,"Cancelar" ,oDlg1,{ || lRet := .F. , oDlg1:End() },050,016,,oFont1,,.T.)
oDlg1:Activate(,,,.T.)      

Return(lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaStrDB()

@protected
@author    Rodrigo Carvalho
@since     08/03/2015
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FAtuaStrDB( aStrTMP )

Local aBrwTMP := {}
Local cTitCmp := ""

For nXy := 1 To Len(aStrTMP)

    If aStrTMP[nXy][2] == "N" 
       aStrTMP[nXy][4] := 2 // duas casas decimais
    Endif

    dbSelectArea("SX3")
    dbSetOrder(2)
    If dbSeek(aStrTMP[nXy,1])
       aAdd(aBrwTmp,{ Capital(Alltrim(aStrTMP[nXy,1])) , Capital(Alltrim(X3Titulo())) , Capital(Alltrim(X3Titulo())),IIf(aStrTMP[nXy,2] == "N",cPict,"")})   
       aStrTMP[nXy][2] := SX3->X3_TIPO 
    Else                                                       
        cTitCmp := Capital(Alltrim(aStrTMP[nXy,1]))
       aAdd(aBrwTmp,{Capital(Alltrim(aStrTMP[nXy,1])) , cTitCmp , cTitCmp ,IIf(aStrTMP[nXy,2] == "N",cPict,"")})                    
    Endif
    
    IF aStrTMP[nXy,1] == "E1_SALDO"  
       aBrwTmp[Len(aBrwTmp)][2] := "A Vencer" // customizado
       aBrwTmp[Len(aBrwTmp)][3] := "A Vencer" // customizado
    Endif

    IF Left(aStrTMP[nXy,1],4) $ "AAMM"  
       aBrwTmp[Len(aBrwTmp)][2] := MesExtenso(Val(SubStr(aBrwTmp[Len(aBrwTmp)][2],9,2))) +" "+ SubStr(aBrwTmp[Len(aBrwTmp)][2],5,4)
       aBrwTmp[Len(aBrwTmp)][3] := aBrwTmp[Len(aBrwTmp)][2]
    Endif
    
Next    

Return(aBrwTmp)



//-------------------------------------------------------------------
/*/{Protheus.doc} fExpExcel()

@protected
@author    Rodrigo Carvalho
@since     01/09/2015
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function fExpExcel(aDados)

Local   oExcel     := FWMSEXCEL():New()
Local   cPlan	    := "Faturamento"
Local   cTitulo	 := "Faturamento/Saldo do Periodo de: "+DtoC(dDatai)+" até "+DtoC(dDataF)
Local   cPasta     := "C:\Relatorios_Protheus\"
Local   cArquivo   := "Faturamento_"+DtoS(dDatai)+"_"+DtoS(dDataF)+"_Em_"+DtoS(date())+".XML"
Local   cCampo     := ""
Local   nRegistros := 0
Local   nLinhas    := 0
Local   aItemSql   := {}

nFolder := oFolder:nOption

MakeDir(cPasta)

For nXy := 1 To Len(aDados)
    
    cAliasDB := aDados[nXy][1]
    cPlan    := aDados[nXy][2]
    aStrDb   := aDados[nXy][3]
    aBrwDb   := aDados[nXy][4]
    nLinhas  := 0             
    
    oExcel:AddworkSheet(cPlan)
    oExcel:AddTable(cPlan,cTitulo)
    oExcel:SetFontSize(12)

    DbSelectArea(cAliasDB) 
    nRecno     := Recno()
    nRegistros := Reccount()
    ProcRegua( nRegistros )

    For nXr := 1 To Len(aBrwDb)
        oExcel:AddColumn(cPlan,cTitulo, aBrwDb[nXr][2] ,1,1 )
    Next

    DbGoTop()
    Do While ! Eof()
      
       nLinhas ++
       IncProc("Gerando Planilha..."+Alltrim(Str(nXy)) +" / "+ Alltrim(Str(Round(nLinhas * 100 / nRegistros,0)))+" %" )
       aItemSql := {}
       
       For nX := 1 To len(aStrDB)
           cCampo := aStrDB[nX][1] 
           If aStrDB[nX][2] == "D"
              aAdd(aItemSql,IIf( (cAliasDB)->&cCampo == CtoD(""),"",DtoC((cAliasDB)->&cCampo)) )   
           Else
              aAdd(aItemSql,(cAliasDB)->&cCampo)          
           Endif
       Next       
      
       oExcel:AddRow(cPlan,cTitulo,aItemSql)
       DbSelectArea(cAliasDB)   
       DbSkip()
    Enddo  
        
    DbSelectArea(cAliasDB)
    DbGoTop(nRecno)

Next

oExcel:Activate()
oExcel:GetXMLFile(Alltrim(cPasta)+cArquivo)

ShellExecute("Open","EXCEL.EXE",Alltrim(cPasta)+cArquivo,"C:\",1)   
MsgInfo("Arquivo gerado com sucesso! "+chr(13)+Upper(Alltrim(cPasta)+cArquivo),"Gravacao arquivo" )

Return .t.




//-------------------------------------------------------------------
/*/{Protheus.doc} FLimpaTMP()
Limpa tabelas temporarias.

@author	  Rodrigo Carvalho
@since	  27/08/2015
@version  P11.8
@obs	  

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------   
Static Function FLimpaTMP()

DbSelectArea("DBTMP01")
DbCloseArea()
FErase(cFileDB01 + GetDBExtension())

DbSelectArea("DBTMP11")
DbCloseArea()
FErase(cFileDB11 + GetDBExtension())

DbSelectArea("DBTMP02")
DbCloseArea()
FErase(cFileDB02 + GetDBExtension())

DbSelectArea("DBTMP03")
DbCloseArea()
FErase(cFileDB03 + GetDBExtension())

DbSelectArea("DBTMP04")
DbCloseArea()
FErase(cFileDB04 + GetDBExtension())

DbSelectArea("DBTMP05")
DbCloseArea()
FErase(cFileDB05 + GetDBExtension())

DbSelectArea("DBTMP06")
DbCloseArea()
FErase(cFileDB06 + GetDBExtension())

Return .T.




//-------------------------------------------------------------------
/*/{Protheus.doc} FLeBetomix()
Carrega os pedidos/notas pendentes de integracao no betomix

@author	  Rodrigo Carvalho
@since	  01/09/2015
@version  P11.8
@obs	  

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------   
Static Function FLeBetomix()

Local    cQuery5     := ""
Local    cQuery6     := ""
Local		cHdlInt		:=	SuperGetMv( "FS_INTDBAM" , .F., " " )  // Parâmetro utilizado para o ambiente da base de integração
Local		cEndIp		:=	SuperGetMv( "FS_INTDBIP" , .F., " " )	// Parêmetro utilizado para informar o IP do servidor da base de integração

Private 	nHdlInt		:=	-1
Private 	nHdlErp		:=	AdvConnection()

If Empty(cHdlInt) .Or. Empty(cEndIp)
   Aviso("Integração","Não foi possivel conectar ao ambiente de interface - Sem Parametros",{"Ok"}) 
   lInterface := .F.
   Return .T.
Endif

nHdlInt  :=	TcLink(cHdlInt,cEndIp,7990)

If nHdlInt < 0 
   Aviso("Integração","Não foi possivel conectar ao ambiente de interface - Erro Conexão",{"Ok"}) 
   TcUnLink(nHdlInt) // Desconecta a base de integracao
   Return .T.
Endif

cQuery5 += "SELECT LEFT(UPPER(CEN.NOME),40)                                 FILIAL,"   + CRLF
cQuery5 += "      (CASE WHEN BETOMIX.STATUS='C' THEN 'CANCELADO' ELSE 'ATIVO' END) STATUS,"+ CRLF
cQuery5 += "       CAST(BETOMIX.DOCUMENTOID AS VARCHAR(20))                 C5_ZPEDIDO,"+ CRLF
cQuery5 += "       BETOMIX.TIPODOCUMENTOID                                  TIPO,"      + CRLF
cQuery5 += "       CAST(BETOMIX.DATAEMISSAO AS SMALLDATETIME)               C5_EMISSAO,"+ CRLF
cQuery5 += "       '"+Space(40)+"'                                          NOME,"      + CRLF
cQuery5 += "       BETOMIX.VALORTOTAL                                       VALORTOTAL,"+ CRLF
cQuery5 += "       BETOMIX.VALORMCCTOTAL                                    VALOR_MCC," + CRLF
cQuery5 += "       CAST(ISNULL(BETOMIX.DOCUMENTOIDFATURA,0) AS VARCHAR(20)) DOCUMENTO," + CRLF
cQuery5 += "       CAST(ISNULL(BETOMIX.PEDIDOID,0) AS VARCHAR(20))          PEDIDO_KP," + CRLF
cQuery5 += "       RIGHT('000000000'+NUMERODOCUMENTO,9)                     C5_NOTA,"   + CRLF
cQuery5 += "       ISNULL(BETOMIX.TIPODOCUMENTOIDFATURA,'')                 TP_FATURA," + CRLF
cQuery5 += "       CAST(BETOMIX.OBRAID AS VARCHAR(20))                      ID_OBRA,"   + CRLF
cQuery5 += "       BETOMIX.DATAINTERFACE                                    DATA_KP,"   + CRLF
cQuery5 += "       LEFT(CLI.NOMEFANTASIA,15)                                A1_NREDUZ," + CRLF
cQuery5 += "       LEFT(LTRIM(CLI.CODIGO),6)                                C5_CLIENTE,"+ CRLF
cQuery5 += "       RIGHT(RTRIM(CLI.CODIGO),2)                               C5_LOJA"    + CRLF
cQuery5 += " FROM (SELECT ISNULL(SC5.C5_FILIAL,'XX') NAOINTEGRA,"                       +CRLF
cQuery5 += "              DOC.*"+ CRLF
cQuery5 += "         FROM BETONMIXPRODUCAO.dbo.DOCUMENTO DOC"+ CRLF
cQuery5 += "         LEFT OUTER JOIN BETONMIXINTERFACE.dbo.SC5 SC5 ON C5_ZPEDIDO = DOCUMENTOID "+ CRLF
cQuery5 += "          AND C5_ZTIPO = (CASE WHEN TIPODOCUMENTOID = 'FAT' THEN '2' ELSE '1' END)"+ CRLF
cQuery5 += "        WHERE TIPODOCUMENTOID NOT IN ('BOMBA','PENDE')"+ CRLF
cQuery5 += "          AND CONVERT(VARCHAR(24),DATAEMISSAO,112) BETWEEN '"+DtoS(dDatai)+"' AND '"+DtoS(dDataf)+"') BETOMIX"+ CRLF
cQuery5 += " LEFT OUTER JOIN BETONMIXPRODUCAO.dbo.CENTRAL CEN ON CEN.CENTRALID = BETOMIX.CENTRALID"+ CRLF
cQuery5 += " LEFT OUTER JOIN BETONMIXPRODUCAO.dbo.CLIENTE CLI ON CLI.CLIENTEID = BETOMIX.CLIENTEID"+ CRLF
cQuery5 += " WHERE NAOINTEGRA = 'XX'"+ CRLF
cQuery5 += " ORDER BY 1,6,5"+ CRLF

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery5),"QTMP05",.F.,.T.) 
IncProc()
cFileDB05 := U_TRQUERY("QTMP05","DBTMP05")   

DbSelectArea("DBTMP05")
aStr005 := DbStruct() 
aBrw005 := U_fAtuaStrDB( aStr005 )               
If lBetomix
   aAdd(aDados,{"DBTMP05",aAbas[5],aStr005,aBrw005})
Endif

cQuery6 := "SELECT (CASE WHEN C5_ZTIPO ='1' THEN 'REMESSAS NÃO INTEGRADAS' "+ CRLF
cQuery6 += "             WHEN C5_ZTIPO ='2' THEN 'FATURAS NÃO INTEGRADAS' "+ CRLF
cQuery6 += "             ELSE 'REGISTRO NAO INTEGRADO' END) STATUS,"+ CRLF
cQuery6 += "      C5_ZTIPO," + CRLF
cQuery6 += "      C5_FILIAL,"+ CRLF
cQuery6 += "      CAST(C5_EMISSAO AS SMALLDATETIME) C5_EMISSAO,"+ CRLF
cQuery6 += "      C5_ZPEDIDO," + CRLF
cQuery6 += "      C5_NOTA,"    + CRLF
cQuery6 += "      C5_SERIE,"   + CRLF
cQuery6 += "      C5_PARC1,"   + CRLF
cQuery6 += "      C5_ZEXCLUI," + CRLF
cQuery6 += "      C5_CLIENTE," + CRLF
cQuery6 += "      C5_LOJACLI," + CRLF
cQuery6 += "      C5_ZEXCLUI, "+ CRLF
cQuery6 += "      C5_ZCC,"     + CRLF
cQuery6 += "      C5_ZEST,"    + CRLF
cQuery6 += "      C5_OBRA,"    + CRLF
cQuery6 += "      C5_ZCONT,"   + CRLF
cQuery6 += "      C5_ZCHVNFE " + CRLF
cQuery6 += " FROM BETONMIXINTERFACE.dbo.SC5"+ CRLF
cQuery6 += " WHERE CONVERT(VARCHAR(24),C5_EMISSAO,112) BETWEEN '"+DtoS(dDatai)+"' AND '"+DtoS(dDataf)+"' AND "+ CRLF
cQuery6 += "   ((C5_ZTIPO = '2' AND DATAINTERFACE_PF IS NULL) OR (C5_ZTIPO = '1' AND DATAINTERFACE_PR IS NULL))"+ CRLF
cQuery6 += "ORDER BY 3,4,1 "+ CRLF

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery6),"QTMP06",.F.,.T.) 
IncProc()
cFileDB06 := U_TRQUERY("QTMP06","DBTMP06")

DbSelectArea("DBTMP06")
aStr006 := DbStruct() 
aBrw006 := U_fAtuaStrDB( aStr006 )
If lBetomix
   aAdd(aDados,{"DBTMP06",aAbas[6],aStr006,aBrw006})
Endif

TcUnLink(nHdlInt) // Desconecta a base de integracao

lInterface := .T.
nASemInt5  := 0
nCSemInt5  := 0

DbSelectArea("DBTMP05")
DbGoTop()
Do While ! Eof()
   DbSelectArea("SA1")
   If DbSeek(xFilial("SA1") + DBTMP05->(C5_CLIENTE + C5_LOJA) )
      DbSelectArea("DBTMP05")
      RecLock("DBTMP05", .F. )
      Replace DBTMP05->NOME With SA1->A1_NOME
      DBTMP05->(MsUnlock())  
   Endif
   DbSelectArea("DBTMP05")   
   nASemInt5 += IIf(  "ATIVO" $ DBTMP05->STATUS , DBTMP05->VALORTOTAL , 0)
   nCSemInt5 += IIf(! "ATIVO" $ DBTMP05->STATUS , DBTMP05->VALORTOTAL , 0)
   DbSkip()
Enddo
DbGoTop()

Return .t.




//-------------------------------------------------------------------
/*/{Protheus.doc} Grafico()
Grafico recebido, receber e vencido.

@author	  Rodrigo Carvalho
@since	  02/09/2015
@version  P11.8
@obs	  

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------   
Static Function Grafico(nFld)

oGraphic := TMSGraphic():New( 01,01,oFolder:aDialogs[nFld],,,RGB(239,239,239),500,240)    
    
oGraphic:SetTitle('Faturamento x Financeiro - Periodo', "Periodo: " + dtoc(dDatai) + " até: "+Dtoc(dDataf), CLR_HRED, A_LEFTJUST, GRP_TITLE )
oGraphic:SetMargins(2,6,6,6)
oGraphic:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO, .T.)

nPFat := Round( (nTotFat1 - (nTotAtras1 + nTotSal1)) * 100 / nTotFat1,2)
nPAtr := Round( nTotAtras1 * 100 / nTotFat1,2)
nPSal := Round( nTotSal1 * 100 / nTotFat1,2)

nSerie := oGraphic:CreateSerie( IIf(nPFat < 5 .Or. nPAtr < 5 .Or. nPSal < 5 , GRP_BAR , GRP_PIE )  )
 
oGraphic:Add( nSerie , nPFat  , 'Baixados'   , CLR_HGREEN )  
oGraphic:Add( nSerie , nPAtr  , 'Vencidos'   , CLR_HRED)
oGraphic:Add( nSerie , nPSal  , 'A Vencer'   , CLR_YELLOW )
    
Return .t.



//-------------------------------------------------------------------
/*/{Protheus.doc} FLinhaTotal

@protected
@author    Rodrigo Carvalho
@since     08/09/2015
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FLinhaTotal(cTabela,aStrTmp)

Local aTotal := {}
Local nXy    := 0
Local cCampo := ""

DbSelectArea(cTabela)
DbGotop()    
If (cTabela)->(Reccount()) > 1
   Do While ! Eof()      
      For nXy := 1 To Len(aStrTmp)   
          cCampo := aStrTmp[nXy][1]
          IF aStrTmp[nXy][2] == "N"
             nPos := aScan(aTotal,{ |x| Alltrim(x[1]) == cCampo } )
             If nPos == 0
                aAdd(aTotal,{cCampo,0})
                nPos := Len(aTotal)
             Endif
             aTotal[nPos][2] += (cTabela)->&(cCampo)
          Endif
      Next    
      (cTabela)->(DbSkip())
   Enddo  

   RecLock(cTabela,.T.) 
   If aStrTmp[1][2] == "C"       
      cCampo := aStrTmp[1][1]
      Replace (cTabela)->&(cCampo) With "TOTAL"
   Endif
   For nXy := 1 To Len(aTotal)
       cCampo := aTotal[nXy][1]
       Replace (cTabela)->&(cCampo) With aTotal[nXy][2]
   Next
   (cTabela)->(MsUnlock())
   DbGotop()
Endif
Return .T.