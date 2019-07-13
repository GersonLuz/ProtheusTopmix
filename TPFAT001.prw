#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH" 

/*--------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                   	
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 13/07/2017    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPFAT001                                  -
----------------------------------------------------------------------------------------
                     FUNÇÃO PARA GERAÇÃO DO RELATÓRIO DE PAGAMENTO                     -
                                  DOS REPRESENTANTES                                   - 
----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------*/ 

*********************************                                                                     
User Function TPFAT001()
*********************************


***************************
** VARIÁVEIS DA PERGUNTA **
***************************
Private cPerg 	   := "TPFAT001"
Private cFilde	   := ""
Private cFilAte	:= ""
Private cCliente  := ""
Private cLoja     := "" 
Private dDataIni                                                                                                                                                
Private dDataFin

************************************
** MONTA A RÉGUA DE PROCESSAMENTO **
************************************

CreateSX1(cPerg)
If Pergunte(cPerg,.T.)
	                                                                                  
	cFilDe		:= MV_PAR01
	cFilAte		:= MV_PAR02
   dDataIni	   := MV_PAR03
	dDataFin  	:= MV_PAR04
	cVend    	:= MV_PAR05
	cCliente 	:= MV_PAR06
	cLoja    	:= MV_PAR07
	
	TPFAT01()
Endif
 
Return

/*--------------------------------------------------------------------------------------
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                   
----------------------------------------------------------------------------------------
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 13/07/2017    - 
----------------------------------------------------------------------------------------
                                   PROGRAMA: TPFAT01                                   -
----------------------------------------------------------------------------------------
                            BUSCA DAS INFORMAÇÕES DAS REMESSAS                         - 
----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------*/ 

***********************************
Static Function TPFAT01() 
***********************************
* 
 
Local nI
Local aCabec := {} // variavel (array) Matriz que recebe o CABEÇALHO dos dados que serão exportados para EXCEL.
Local aDados := {} 
Private cQuery  := 	""

aList   := {}
 	
cQuery :=" SELECT DISTINCT F2_DOC AS NOTA , P02_NUM2 AS REMESSA, A1_NOME AS CLIENTE , A3_NOME AS VENDEDOR ,CONVERT(varchar, CONVERT(DATETIME, P02_DTEMI2), 103) AS EMISSAO, E1_VALOR AS TOTAL, "
cQuery +=" CASE E1_BAIXA  WHEN '' THEN '' ELSE CONVERT(varchar, CONVERT(DATETIME, E1_BAIXA), 103)END AS PAGAMENTO "
cQuery +=" FROM "  + retSqlName("SF2") +  " SF2 " 
cQuery +=" INNER JOIN "+ retSqlName("SE1") +  " SE1 ON E1_FILORIG  = F2_FILIAL AND E1_CLIENTE = F2_CLIENTE AND E1_LOJA = F2_LOJA AND SE1.D_E_L_E_T_ = '' "
cQuery +=" INNER JOIN "+ retSqlName("SC5") +  " SC5 ON C5_FILIAL = F2_FILIAL AND C5_NOTA = F2_DOC AND C5_SERIE = F2_SERIE AND C5_NUM = E1_PEDIDO AND C5_FILIAL = E1_FILORIG  " 
cQuery +=" AND C5_CLIENTE = E1_CLIENTE AND E1_LOJA = C5_LOJACLI AND SC5.D_E_L_E_T_ = '' "
cQuery +=" INNER JOIN "+ retSqlName("P02") +  " P02 ON P02_FILIAL  = C5_FILIAL AND P02_FILIAL = F2_FILIAL AND P02_FILIAL = E1_FILORIG AND P02_NUM1 = C5_ZPEDIDO AND P02.D_E_L_E_T_ = '' "  
cQuery +=" INNER JOIN "+ retSqlName("SA1") +  " SA1 ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND SA1.D_E_L_E_T_ = ''  " 
cQuery +=" INNER JOIN "+ retSqlName("SA3") +  " SA3 ON A3_COD = F2_VEND1 AND SA3.D_E_L_E_T_ = ''  " 
if (Empty(cFilDe)  .AND. (cFilAte = 'ZZ' .OR. cFilAte = 'zz')) // Parâmetros Branco a ZZZZZZ                    
else
cQuery +=" WHERE F2_FILIAL BETWEEN '"+cFilDe+"'   AND '"+cFilAte+"'"
endif
cQuery +=" AND P02_DTEMI2 BETWEEN   '"+dtos(dDataIni)+"' AND '"+dtos(dDataFin)+"' "   
if !(Empty(cCliente)) // Parâmetros Branco   
cQuery +=" AND F2_CLIENTE = '"+cCliente+"'  "
cQuery +=" AND F2_LOJA = '"+cLoja+"'  "
endif
if !(Empty(cVend)) // Parâmetros Branco  
cQuery +=" AND F2_VEND1 = '"+cVend+"'  "
endif
cQuery +=" AND SF2.D_E_L_E_T_ = ''   "
cQuery +=" ORDER BY 1  "


dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.F.,.T.)    
 
  TMP->(dbGoTop())
  While !TMP->(EoF())                            	
                        
     
         // Vetor com elementos do Browse
    AADD(aList, {  TMP->(NOTA)                                             ,;                       
                   TMP->(REMESSA)         		   					         ,;                   
                   TMP->(CLIENTE)                                          ,;
                   TMP->(VENDEDOR)        								         ,;
                   Alltrim(TMP->(EMISSAO)) 		     					         ,;
                   TMP->(TOTAL)                                            ,;
                   Alltrim(TMP->(PAGAMENTO))})
  TMP->(dbskip())
  EndDo
  
aCabec := {"Nota", "Remessa", "Cliente", "Vendedor", "Emissao" , "Total", "Pagamento"}

For nI := 1 To Len(aList)     

	AAdd(aDados, {chr(160)+aList[nI][1],chr(160)+aList[nI][2],chr(160)+aList[nI][3],aList[nI][4],aList[nI][5],aList[nI][6],aList[nI][7]})	           

Next nI

	AAdd(aCabec,aDados)
	DlgToExcel({ {"ARRAY", "Exportacao para o Excel - Pagamento Representantes", aCabec, aDados} })                             
   TMP->(dbCloseArea())

Return


****************************************
Static Function CreateSX1(cPerg)
****************************************

Local aHelp   
	
	aHelp := {"Informe a Filial Inicial"}
	PutSx1(cPerg,"01","Filial De:"   ,"","","mv_ch1","C",06,0,0,"G","","SM0","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp)
	
	aHelp := {"Informe a Filial Final"}
	PutSx1(cPerg,"02","Filial Ate:"   ,"","","mv_ch2","C",06,0,0,"G","Eval({|| MV_PAR02 >= MV_PAR01})","SM0","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp)
	
	aHelp := {"Informe a Data Inicial"}
	PutSx1(cPerg,"03","Data De:"   ,"","","mv_ch3","D",08,0,0,"G","","","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelp)
	
	aHelp := {"Informe a Data Final"}
	PutSx1(cPerg,"04","Data Ate:"   ,"","","mv_ch4","D",08,0,0,"G","Eval({|| MV_PAR08 >= MV_PAR07})","","","","MV_PAR08","","","","","","","","","","","","","","","","",aHelp)
	
	aHelp := {"Informe o Representante"}
	PutSx1(cPerg,"05","Representante:"   ,"","","mv_ch5","C",06,0,0,"G","","","SA3","","MV_PAR05","","","","","","","","","","","","","","","","",aHelp)
	
	aHelp := {"Informe o Cliente"}
	PutSx1(cPerg,"06","Cliente:"   ,"","","mv_ch6","C",06,0,0,"G","","","SA1","","MV_PAR06","","","","","","","","","","","","","","","","",aHelp) 
	
	aHelp := {"Informe a Loja do Cliente"}
	PutSx1(cPerg,"07","Loja:"   ,"","","mv_ch7","C",02,0,0,"G","","","SA1","","MV_PAR07","","","","","","","","","","","","","","","","",aHelp)

Return(Nil) 

