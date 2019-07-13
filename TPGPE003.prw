#INCLUDE "PROTHEUS.CH"
#Include "Rwmake.ch"
#Include "TopConn.ch"


/*************************************************************************************** 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            *                                                   
****************************************************************************************
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ***          DATA: 28/02/2018    * 
****************************************************************************************
                                   PROGRAMA: TPGPE003                                  *
****************************************************************************************
                    FUNÇÃO PARA GERAÇÃO DO RELATÓRIO ESPELHO DE PONTO                  * 
***************************************************************************************/ 

*************************************************
User Function TPGPE003()
*************************************************

Private aCabec 	:= {}
Private aDados 	:= {}
Private cObs      := ""
Private cPerg     := "TPGPE003"
Private cFilDe		:= ""
Private cFilAte	:= ""
Private cMatIni   := ""
Private cMatFim   := ""                                                                         
Private dDataIni  := ""                                                                         
Private dDataFin 	:= ""
Private nMarc 
Private ultDt := " "
  	 
Private tpMarq 	:= "E" 
Private ultUsu 	:= "000000"
Private ultNum :=1 
Private marcacao := ""

CreateSX1(cPerg)
If Pergunte(cPerg,.T.)
	                                                                                  
	cFilDe		:= MV_PAR01
	cFilAte		:= MV_PAR02
    cMatIni     := MV_PAR03
	cMatFim     := MV_PAR04                                                                         
    dDataIni    := MV_PAR05                                                                         
	dDataFin  	:= MV_PAR06
	nMarc       := MV_PAR07

 preparaDados()

 RptStatus({|lFim| TPGPE003A()}, "Carregando Marcações do Espelho de Ponto","Processando...")
Endif

return()


/*************************************************************************************** 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            *                                                   
****************************************************************************************
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ***          DATA: 28/02/2018    * 
****************************************************************************************
****************************************************************************************
****************************************************************************************
                                   PROGRAMA: TPGPE003A                                 *
****************************************************************************************
                 FUNÇÃO PARA CARREGAR DADOS DO RELATÓRIO ESPELHO DE PONTO              * 
****************************************************************************************
****************************************************************************************
****************************************************************************************
***************************************************************************************/ 

*************************************************
Static Function TPGPE003A()
*************************************************

// variavel (array) Matriz que recebe o CABEÇALHO dos dados que serão exportados para EXCEL.

aCabec := {"FILIAL", "MATRICULA", "FUNCIONÁRIO", "DATA", "MARCAÇÃO", "TIPO MARCAÇÃO", "OBSERVAÇÃO"}

TMP->(dbGoTop()) 
While(!TMP->(EOF()))
  
  //Reseta o numero sequencia ao mudar de Matricula 
  If(TMP->DATAMARC <> ultDt)
  	ultNum := 1
  	ultUsu := TMP->P8_MAT
  	tpMarq := "E" 
  	ultDt := TMP->DATAMARC 
  EndIf
  
  If(tpMarq == "E")
  	marcacao := cValToChar(ultNum)+"E"
  	tpMarq := "S"
  Else 
  	marcacao := cValToChar(ultNum)+"S"
    tpMarq := "E"
    ultNum := ultNum+1
  Endif
  	
  	  
   
  If(TMP->P8_TIPOREG == 'I')
   cObs  := "MARCAÇÃO MANUAL"
   cHora := CVALTOCHAR(TMP->P8_HORA) + "**"
  Else
   cObs  := "MARCAÇÃO AUTOMÁTICA"
   cHora := TMP->P8_HORA
  Endif           
  
 
  
  AAdd(aDados, {CAPITALACE(TMP->FILIAL), chr(160)+TMP->P8_MAT, CAPITALACE(TMP->RA_NOME) + chr(160), TMP->DATAMARC, cHora, marcacao, CAPITALACE(cObs)})       

TMP->(dbskip())                                                               
EndDo

	AAdd(aCabec)
	DlgToExcel({ {"ARRAY", "Exportacao para o Excel - Espelho de Ponto", aCabec, aDados} })
   TMP ->(dbCloseArea())
Return
                                                                                                            
***********************************
Static Function PreparaDados() 
***********************************
*
Private cQuery  := 	""
 	
cQuery+=" SELECT DISTINCT P8_FILIAL+'-'+M0_FILIAL AS FILIAL, P8_MAT, RA_NOME, CONVERT(varchar, CONVERT(DATETIME, P8_DATA), 103) AS DATAMARC, P8_TPMARCA, P8_TIPOREG, P8_HORA "
cQuery+=" FROM "  + retSqlName("SP8") +  " SP8 "
cQuery+=" INNER JOIN "+ retSqlName("SRA") +  " SRA ON (RA_MAT = P8_MAT AND RA_FILIAL = P8_FILIAL AND SRA.D_E_L_E_T_ = '') "
cQuery+=" INNER JOIN SIGAMAT ON (P8_FILIAL = M0_CODFIL AND SIGAMAT.D_E_L_E_T_ = '') "
if (Empty(cFilDe)  .AND. (cFilAte = 'ZZZZZZ' .OR. cFilAte = 'zzzzzz')) // Parâmetros Branco a ZZZZZZ                    
else
cQuery +=" WHERE P8_FILIAL BETWEEN '"+cFilDe+"'   AND '"+cFilAte+"'"
endif
if (Empty(cMatIni)  .AND. (cMatFim = 'ZZZZZZ' .OR. cMatFim = 'zzzzzz')) // Parâmetros Branco a ZZZZZZ
else 
cQuery +=" AND P8_MAT BETWEEN      '"+cMatIni+"'  AND '"+cMatFim+"' "
endif
if (nMarc == 2)
cQuery +=" AND P8_TIPOREG = 'I'                                                               
endif                                                                             
cQuery +=" AND P8_DATA BETWEEN   '"+dtos(dDataIni)+"' AND '"+dtos(dDataFin)+"' "
cQuery +=" AND SP8.D_E_L_E_T_ = ''
  
cQuery+=" ORDER BY 1,2,4,7 "	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.F.,.T.)

return 

****************************************
Static Function CreateSX1(cPerg)
****************************************

Local aHelp   
	
	aHelp := {"Informe a Filial Inicial"}
	PutSx1(cPerg,"01","Filial De:"   ,"","","mv_ch1","C",06,0,0,"G","","SM0","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp)
	
	aHelp := {"Informe a Filial Final"}
	PutSx1(cPerg,"02","Filial Ate:"   ,"","","mv_ch2","C",06,0,0,"G","Eval({|| MV_PAR02 >= MV_PAR01})","SM0","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp)
	
	aHelp := {"Informe a Matricula Inicial"}
	PutSx1(cPerg,"03","Matricula De:"   ,"","","mv_ch3","C",06,0,0,"G","","SRA","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp)
	
	aHelp := {"Informe a Matricula Final"}
	PutSx1(cPerg,"04","Matricula Ate:"   ,"","","mv_ch4","C",06,0,0,"G","Eval({|| MV_PAR04 >= MV_PAR03})","SRA","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp)

	aHelp := {"Informe a Data Inicial"}
	PutSx1(cPerg,"05","Data De:"   ,"","","mv_ch5","D",08,0,0,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelp)
	
	aHelp := {"Informe a Data Final"}
	PutSx1(cPerg,"06","Data Ate:"   ,"","","mv_ch6","D",08,0,0,"G","Eval({|| MV_PAR06 >= MV_PAR05})","","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelp)
	
	aHelp := {"Informe o Tipo de Lançamentos"}
	PutSx1(cPerg,"07","Lançamento:"   ,"","","mv_ch7","N",01,0,0,"C","","","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelp)

Return(Nil) 
