#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWSMALLAPPLICATION.CH"

/*--------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                   	
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 26/07/2018    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TCOM001                                   -
----------------------------------------------------------------------------------------
                    FUNÇÃO PARA GERAÇÃO DO RELATÓRIO DO SUPRIMENTOS                    - 
----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------*/ 

*********************************                                                                     
User Function TCOM001()
*********************************

Private oOK := LoadBitmap(GetResources(),'BR_VERDE')
Private oNO := LoadBitmap(GetResources(),'BR_VERMELHO')
Private aGrava := {}
Private aList  := {}
Private oList, oData, oMarkL, oMarkP, oBmpVerde, oBmpVerme, oBtn 
Private Lanc, cEnt, cInfo, cLegVem, cLegVer
Private oFont1 := TFont():New("Arial",07,15,,.T.,,,,.T.,.F.)
Private cLanc  := 0 // SEM FLAG MARCADO
Private cFlag, cMarkL, cMarkP
Private cMark := 'N'
Private cStartPath    

***************************
** VARIÁVEIS DA PERGUNTA **
***************************
Private cPerg 	  := "TCOM001"
Private cFilde	  := ""
Private cFilAte	  := "" 
Private dDataIni                                                                                                                                                
Private dDataFin

************************************
** MONTA A RÉGUA DE PROCESSAMENTO **
************************************

CreateSX1(cPerg)
If Pergunte(cPerg,.T.)
	                                                                                  
	cFilDe		:= MV_PAR01
	cFilAte		:= MV_PAR02
	dDataIni	:= MV_PAR03
	dDataFin	:= MV_PAR04
	
	//-- Verifica se o arquivo sera gerado em Remote Linux
	cStartPath := GetTempPath(.T.)
	cStartPath    := GetSrvProfString("Startpath", "")  
    cLegVer       := cStartPath + "LegendaVerde.jpg"
    cLegVem       := cStartPath + "LegendaVermelha.jpg"
    
      aSize := MsAdvSize(.F.)
	 /*
	 MsAdvSize (http://tdn.totvs.com/display/public/mp/MsAdvSize+-+Dimensionamento+de+Janelas)
	 aSize[1] = 1 -> Linha inicial área trabalho.
	 aSize[2] = 2 -> Coluna inicial área trabalho.
	 aSize[3] = 3 -> Linha final área trabalho.
	 aSize[4] = 4 -> Coluna final área trabalho.
	 aSize[5] = 5 -> Coluna final dialog (janela).
	 aSize[6] = 6 -> Linha final dialog (janela).
	 aSize[7] = 7 -> Linha inicial dialog (janela).  */  
 
    DEFINE DIALOG oDlg TITLE "Suprimentos" FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL
                                                 
        // Cria Browse
        oList := TCBrowse():New( 050,000, aSize[3], aSize[4] - 55 ,,{"","Filial","SC - Compras","Emissao","Solicitante","Aprovador","Data Aprovacao","Situacao",;
        "Cotacao","Emissao","OC","Emissao","Data Aprovacao","Situacao" },,oDlg,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,,.T.,.T. ) 
        
        oBmpVerde := TBitmap():New(18,537,50,10,,cLegVer,.T.,oDlg,,,.F.,.F.,,,.F.,,.T.,,.F.)
        oBmpVerme := TBitmap():New(28,537,50,10,,cLegVem,.T.,oDlg,,,.F.,.F.,,,.F.,,.T.,,.F.)
     
        TButton():New( 030, 070, "Excel", oDlg,{|| TCOM03()},40,015,,oFont1,.T.,.T.,.F.,,.F.,,,.F. )         
        TButton():New( 030, 020, "Sair" , oDlg,{|| oDlg:End() },40,015,,oFont1,.T.,.T.,.F.,,.F.,,,.F. )
        //oBtn:=TButton():New( 030, 020, "Salvar" , oDlg,{|| TCOM04()}, 40, 015,,oFont1,.T.,.T.,.F.,,.F.,,,.F.)
        //oBtn:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #009ACD; } " )        
        //TButton():New( 030, 120, "Legenda", oDlg,{|| U_TCOM05()},40,015,,oFont1,.T.,.T.,.F.,,.F.,,,.F. )
        @ 020,530 CheckBox oMarkL Var cMarkL Prompt SPACE(6)+'SC Liberada'  Size 75,10 OF oDlg Pixel On Click Processa( {|| TCOM01(cMark:= "L") },"Filtrando SC..." ) 
        @ 030,530 CheckBox oMarkP Var cMarkP Prompt SPACE(6)+'SC Pendente' Size 75,10 OF oDlg Pixel On Click Processa( {|| TCOM01(cMark:= "B") },"Filtrando SC ..." )       
        
        Processa( {|| TCOM01() },"Relacionando SC x Cotação x Pedido..." )   
                                                                                   
    If (valtype(oDlg) =='O')  // SOMENTE SE O OBJETO EXISTIR
     ACTIVATE DIALOG oDlg CENTERED
    Endif 
Else
return()           
Endif
Return

/*--------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                   
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 26/07/2018    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TCOM01                                    -
----------------------------------------------------------------------------------------
                  BUSCA DAS INFORMAÇÕES DOS PEDIDOS/COTAÇÃO/SOLICITAÇÃO                - 
----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------*/ 

***********************************
Static Function TCOM01() 
***********************************
*  

Local cStatus	:= ""  
Private cQuery  := 	""

aList   := {}
 	
cQuery :=" SELECT DISTINCT C1_FILIAL, M0_FILIAL AS FILIAL,CONVERT(varchar, CONVERT(DATETIME, C1_EMISSAO), 103) AS EMISSAO_SC,C1_NUM AS SOLICITACAO, C1_SOLICIT AS SOLICITANTE,"
cQuery +=" CASE C1_APROV WHEN 'L' THEN 'SC LIBERADA' ELSE 'SC PENDENTE' END AS SITUACAO,C1_NOMAPRO AS APROVADOR, CONVERT(varchar, CONVERT(DATETIME, C1_ZDTAPRO), 103)AS DT_SC,"
cQuery +=" CONVERT(varchar, CONVERT(DATETIME, C8_EMISSAO), 103)AS DATA_COTACAO,C8_NUM AS COTACAO, C7_NUM AS PEDIDO," 
cQuery +=" CONVERT(varchar, CONVERT(DATETIME, C7_EMISSAO), 103)AS EMISSAO_PE, CASE C7_CONAPRO WHEN 'L' THEN 'OC APROVADA' ELSE 'OC BLOQUEADA' END AS STATUS_PC "
cQuery +=" FROM "  + retSqlName("SC1") +  " SC1 "
cQuery +=" LEFT JOIN "+ retSqlName("SC8") +  " SC8 ON C1_FILIAL = C8_FILIAL AND C1_COTACAO = C8_NUM  AND C1_ITEM = C8_ITEMSC AND SC8.D_E_L_E_T_ = '' "
cQuery +=" LEFT JOIN "+ retSqlName("SC7") +  " SC7 ON C8_FILIAL = C7_FILIAL AND C8_NUM = C7_NUMCOT AND SC7.D_E_L_E_T_ = ''"
cQuery +=" INNER JOIN SIGAMAT ON M0_CODFIL = C1_FILIAL AND SIGAMAT.D_E_L_E_T_ = '' "
if (Empty(cFilDe)  .AND. (cFilAte = 'ZZ' .OR. cFilAte = 'zz')) // Parâmetros Branco a ZZZZZZ                    
else
cQuery +=" WHERE C1_FILIAL BETWEEN '"+cFilDe+"'   AND '"+cFilAte+"'"
endif
cQuery +=" AND C1_EMISSAO BETWEEN   '"+dtos(dDataIni)+"' AND '"+dtos(dDataFin)+"' "
if (cMark == "B") .AND. (cMarkL <> cMarkP)
cQuery +=" AND ((C1_APROV = 'B') OR (C1_APROV <> 'B' AND C1_COTACAO = '')) "  
elseif (cMark == "L") .AND. (cMarkL <> cMarkP)
cQuery +=" AND (C7_CONAPRO IN ('L','B')) "
//cQuery +=" AND C1_APROV = 'L' " 
endif 
cQuery +=" AND C1_APROV = 'L' "   
cQuery +=" AND SC1.D_E_L_E_T_ = '' "
cQuery +=" ORDER BY 1,4,9,10 "	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.F.,.T.)    
 
  TMP->(dbGoTop())
  While !TMP->(EoF())                            	
                    // CONSULTA POSSUI INFORMAÇÕES
                       cInfo := 'S'
                                                     
         // Vetor com elementos do Browse
    AADD(aList, {  " "                                                      ,;    
                   Alltrim(TMP->(FILIAL))                    		        ,;
                   Alltrim(TMP->(SOLICITACAO))         		   	    		,;                   
                   Alltrim(TMP->(EMISSAO_SC))        						,;
                   Alltrim(TMP->(SOLICITANTE))                              ,;
                   Alltrim(TMP->(APROVADOR))      						    ,;
                   Alltrim(TMP->(DT_SC))                                    ,;
                   TMP->(SITUACAO)                                          ,;
                   TMP->(COTACAO)                                           ,;
                   Alltrim(TMP->(DATA_COTACAO))      					    ,;
                   TMP->(PEDIDO)                                            ,;
                   Alltrim(TMP->(EMISSAO_PE))      						    ,;
                   Posicione("SCR",3,Alltrim(TMP->(C1_FILIAL))+'PC'+Alltrim(TMP->(PEDIDO))+space(44)+'000008','CR_DATALIB') ,;
                   TMP->(STATUS_PC)      								    })
  TMP->(dbskip())
  EndDo
  
  IF (cInfo == 'S') // POSSUI INFORMAÇÕES PARA O BROWSER
	  // Seta vetor para a browse          
	  oList:SetArray(aList)
	  
	  // Monta a linha a ser exibina no Browse 
	 
cQuery +=" AND C1_APROV = 'L' " 
	  
	  oList:bLine := {||{ If(((ALLTRIM(aList[oList:nAt,14]) == 'OC BLOQUEADA' .OR. ALLTRIM(aList[oList:nAt,14]) == 'OC APROVADA');
	   .AND. ((ALLTRIM(aList[oList:nAt,8]) == 'SC LIBERADA' ))),oOK,oNO)  ,;
	                        aList[oList:nAt,02] + space(10) ,;
	                        aList[oList:nAt,03] ,;                        
	                        aList[oList:nAt,04] ,;
	                        aList[oList:nAt,05] ,;                         
	                        aList[oList:nAt,06] ,;
	                        aList[oList:nAt,07] ,;
	                        aList[oList:nAt,08] ,;
	                        aList[oList:nAt,09] ,;
	                        aList[oList:nAt,10] ,;
	                        aList[oList:nAt,11] ,;
	                        aList[oList:nAt,12] ,;
	                        aList[oList:nAt,13] ,;
	                        aList[oList:nAt,14] }}
	                               
	     						  
	  oList:Refresh()   
	  TMP->(dbCloseArea())
  
  ELSE
   MsgInfo("Não há dados.")
   TMP->(dbCloseArea())
  ENDIF
  
  oList:enable()       

  oList:blDblClick:= {|| RTMS02(@aList)}// PERMITE ALTERAR O CONTEUDO DA LINHA.

  //oDlg:Activate(,,,.T.)                                  

Return

/*--------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                   
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 26/07/2017    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TCOM02                                    -                                 
----------------------------------------------------------------------------------------
                         FUNÇÃO ATIVADA NA EDICAO DO CAMPO                             - 
----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------*/  
/*
***********************************
Static Function TCOM02() 
***********************************  

// EDITAR SOMENTE CAMPO DATA DE ENTREGA E USUARIOS DO PARAMETRO MV_PWENTRE

 If (oList:ColPos() == 8) .AND. (__cUserID $ GetMv("MV_PWENTRE") )
 lEditCell(@aList,oList,"",oList:ColPos()) 
  If (SUBSTR(aList[oList:nAt,08],1,2)  <= '31' .AND. SUBSTR(aList[oList:nAt,08],4,2)  <= '12' .AND. SUBSTR(aList[oList:nAt,08],7,4)  <= SUBSTR(CVALTOCHAR(ddatabase),7,4)) .AND. Len(Alltrim(SUBSTR(aList[oList:nAt,08],7,4))) = 4
   aadd(aGrava,{aList[oList:nAt,09],aList[oList:nAt,03],aList[oList:nAt,06],aList[oList:nAt,08]})  // ARRAY COM CTE's ALTERADOS 
  Else 
   MsgStop("Data Inválida.")
   aList[oList:nAt,08] := ''                                                              
  Endif
 Endif
	 if LEN(ALLTRIM(aList[oList:nAt,08])) = 10 // STATUS NÃO ENTREGUE O COMPROVANTE  (10 CARACTERES COMPÕE A DATA COMPLETA)
	   aList[oList:nAt,01] := .T.
	   aList[oList:nAt,07] := "Sim"
	   oList:Refresh() // ATUALIZAR STATUS
	 else  // STATUS ENTREGUE O COMPROVANTE
	   aList[oList:nAt,01] := .F.
	   aList[oList:nAt,07] := "Nao"                                                	
	   oList:Refresh()
	 endif

return 
          */

/*--------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                   
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 26/07/2018    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TCOM03                                    -                                 
----------------------------------------------------------------------------------------
                               EXPORTAÇÃO PARA O EXCEL                                 - 
----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------*/  

***********************************
Static Function TCOM03() 
*********************************** 

Local nI
Local aCabec := {} // variavel (array) Matriz que recebe o CABEÇALHO dos dados que serão exportados para EXCEL.
Local aDados := {}

aCabec := {"Filial","SC - Compras","Emissao","Solicitante","Aprovador","Data Aprovacao","Situacao","Cotacao","Emissao","OC","Emissao","Data Aprovacao",;
           "Situacao"}

For nI := 1 To Len(aList)     

	AAdd(aDados, {aList[nI][2],chr(160)+aList[nI][3],aList[nI][4],aList[nI][5],aList[nI][6],aList[nI][7],aList[nI][8],aList[nI][9],chr(160)+aList[nI][10],;
	aList[nI][11],chr(160)+aList[nI][12],aList[nI][13],aList[nI][14]})	           

Next nI

	AAdd(aCabec,aDados)
	DlgToExcel({ {"ARRAY", "Exportacao para o Excel - Suprimentos", aCabec, aDados} }) 
	
return

/*--------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                   
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 26/07/2018    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TCOM04                                    -                                 
----------------------------------------------------------------------------------------
                              FUNÇÃO GRAVACAO DOS DADOS                                - 
----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------*/  
/*
***********************************
Static Function TCOM04() 
***********************************

Local nI, cGrava, cData

For nI := 1 To Len(aGrava) //ARRAY COM INFORMAÇÕE A SEREM GRAVADAS
    
    DbSelectArea("DT6")	//TABELA CTE
    DbSetOrder (1)
	if dbSeek(aGrava[nI][1]+aGrava[nI][1]+aGrava[nI][2])
		RecLock('DT6',.F.)
		DT6->DT6_PWCENT := IIF(LEN(ALLTRIM(aGrava[nI][4])) == 10,'2','1') // CONFIRMAÇÃO DE ENTREGA DO COMPROVANTE
		cData := CTOD(aGrava[nI][4])
		DT6->DT6_PWDTEN := cData // DATA DE ENTREGA DO COMPROVANTE
		cGrava := 'S'
		MsUnLock()
	EndIf

Next nI	

MsgInfo("Os dados foram gravados do sucesso.")

Return()
            */
****************************************
Static Function CreateSX1(cPerg)
****************************************

Local aHelp   
	
	aHelp := {"Informe a Filial Inicial"}
	PutSx1(cPerg,"01","Filial De:"   ,"","","mv_ch1","C",06,0,0,"G","","SM0","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp)
	
	aHelp := {"Informe a Filial Final"}
	PutSx1(cPerg,"02","Filial Ate:"   ,"","","mv_ch2","C",06,0,0,"G","Eval({|| MV_PAR02 >= MV_PAR01})","SM0","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp)
	
	aHelp := {"Informe a Data Inicial"}
	PutSx1(cPerg,"03","Emisao SC De:"   ,"","","mv_ch3","D",08,0,0,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp)
	
	aHelp := {"Informe a Data Final"}
	PutSx1(cPerg,"04","Emissao SC Ate:"   ,"","","mv_ch4","D",08,0,0,"G","Eval({|| MV_PAR04 >= MV_PAR03})","","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp)

Return(Nil) 

/*--------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                   
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 26/07/2018    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TCOM05                                    -                                 
----------------------------------------------------------------------------------------
                       FUNÇÃO PARA MONTAGEM DA LEGENDA DA TELA                         - 
----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------*/  
/*
**********************************
User Function TCOM05()
**********************************

Local aLegenda := Array(0)
Local cTela    := "Pedidos de Compras"

aAdd(aLegenda,{'BR_VERDE'   , "Pedido Liberado" }) 
aAdd(aLegenda,{'BR_VERMELHO', "Pedido Bloqueado" }) 

BrwLegenda(cTela, cTela, aLegenda)

Return()     */


