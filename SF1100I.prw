#Include "RwMake.ch"
#Include "Colors.ch"
#Include "TopConn.ch"

/*
+------------------------+----------------+-------------------+-------+---------------+
| Programa  | SF1100I    | Desenvolvedor  | Juliana           | Data  | 05/11/2008    |
+-----------+------------+----------------+-------------------+-------+---------------+
| Descricao | Ponto de entrada para gravacao de dados adicionais no cabecalho da nota.|
|           |                                                                         |
+-----------+-------------------------------------------------------------------------+
| Uso       | Exclusivo Topmix                                                        |
+-----------+-------------------------------------------------------------------------+
| Data      |Programador| Descricao                                                   |
+-----------+-----------+-------------------------------------------------------------+

*/
User Function SF1100I()
Local lRetIss :=.F.                              
dbSelectArea("SF1")                 
                       
// Validar se existe TES com ISS sim        

For nXi := 1 To Len(ACols)   
		If ( !aCols[nXi][Len(aHeader)+1] )  
		   IF Posicione("SF4",1,xFilial("SF4")+aCols[nXi][GDFieldPos("D1_TES",aHeader)],"F4_ISS") == "S" 
       		  lRetIss:=.T. 
		   Endif
		Endif	    
Next nXi   

IF (lRetIss  .And. SF1->F1_FILIAL=="010100") .OR. (lRetIss ==.T.  .And. SF1->F1_FILIAL=="010106")
	fTSf11()               
ENDIF


Return     
***************************

* Chama tela DESBH 
*
*************************

Static Function fTSf11()
Local aArea      := GetArea() 
Local oDlgTel
Local oDocBH
Local oModNF
Local oMunBH  
Local oUFBH
//Private cDocBH   :=Space(TamSX3("F1_DOCDES")[1]) 
Private cModNF   :=Space(TamSX3("F1_MODNF")[1])
Private cSerieDS :=Space(TamSX3("F1_SERIEDS")[1])
Private cMunBH   :=SA2->A2_MUN       
Private cUFBH    :=SA2->A2_EST 
     
        Do  Case 
       		Case  Alltrim(SF1->F1_ESPECIE) $ "S/SF"
        	      cSerieDS:="2"
        	Case  Alltrim(SF1->F1_ESPECIE)=="S"
            	  cSerieDS:="1"
	        Case  Alltrim(SF1->F1_ESPECIE) $ "SF"
    	          cSerieDS:="1"          
        	Case  Alltrim(SF1->F1_ESPECIE) $ "NFA/SE/OM"
            	  cSerieDS:="0"          
        	Otherwise 
            	  cSerieDS:=" "
         EndCase   	
      
         Do  Case 
       		Case  ALLTRIM(SF1->F1_SERIE) $ "A/U" .AND. Alltrim(SF1->F1_ESPECIE) == "S"
        	      cModNF := "1"     //Left(SF1->F1_SERIE,2)
        	      cDocBH := Left(SF1->F1_SERIE,2) 
        	   Case  ALLTRIM(SF1->F1_SERIE) $ "A/U" .AND. Alltrim(SF1->F1_ESPECIE) == "SF"
        	      cModNF := "2"     //Left(SF1->F1_SERIE,2)
        	      cDocBH := Left(SF1->F1_SERIE,2)   
        	   Case  Alltrim(SF1->F1_ESPECIE) == "NFA"
        	      cModNF := "3"     //Left(SF1->F1_SERIE,2)
        	      cDocBH := Left(SF1->F1_SERIE,2) 
        	   Case  Alltrim(SF1->F1_ESPECIE) == "SE"
        	      cModNF := "5"     //Left(SF1->F1_SERIE,2)
        	      cDocBH := Left(SF1->F1_SERIE,2)    
            Case  Alltrim(SF1->F1_ESPECIE) == "OM"
        	      cModNF := "16"     //Left(SF1->F1_SERIE,2)
        	      cDocBH := Left(SF1->F1_SERIE,2)          
   	   	 	Otherwise 
            	   cModNF   :=" " 
            	// cSerieDS :=" " 
            	   cDocBH   :=" "     
         EndCase   	

	DEFINE MSDIALOG oDlgTel FROM 000,000 TO 300,350 PIXEL TITLE OemToAnsi("Dados Nota Fiscal DES-BH")
	TBitMap():New(000,000,300,350,"ProjetoAP",,.t.,oDlgTel,,,,,,,,,.T.)
 	TSay():New(020,010, {|| OemToAnsi("Serie DesBH..: ") },oDlgTel,,,,,,.T.,CLR_BLACK,CLR_BLUE,050,20)
 	oSerieDS:=TGet():New(020,040, {|U| If(PCount()>0,cSerieDS:=u,cSerieDS )} ,oDlgTel  ,050,010,PesqPict ("SF1","F1_SERIEDS") ,,,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F.,,(cSerieDS))
  	
  	TSay():New(040,010, {|| OemToAnsi("Modelo NF..: ") },oDlgTel,,,,,,.T.,CLR_BLACK,CLR_BLUE,050,20)
	oModNF:=TGet():New(040,040, {|U| IIf(PCount()==0,cModNF,cModNF:=U )} ,oDlgTel   ,050,010,PesqPict ("SF1","F1_MODNF"),,,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F.,"SX5Z4",(cModNF))
		
	//TSay():New(060,010, {|| OemToAnsi("Doc DS: ") },oDlgTel,,,,,,.T.,CLR_BLACK,CLR_BLUE,050,20)
	//oDocBH:=TGet():New(060,040, {|U| IIf(PCount()==0,cDocBH,cDocBH:=U )} ,oDlgTel   ,050,010, PesqPict("SF1","F1_DOCDES"),,,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F.,,(cDocBH))
	
	TSay():New(060,010, {|| OemToAnsi("Municipio..: ") },oDlgTel,,,,,,.T.,CLR_BLACK,CLR_BLUE,050,20)                                                     
	oMunBH:=TGet():New(060,040, {|U| IIf(PCount()==0,cMunBH,cMunBH:=U )} ,oDlgTel ,050,010, PesqPict("SF1","F1_CDDESBH"),,,,,,,.T.,,,,,,,,,"CC2DES",(cMunBH))
	
	TSay():New(080,010, {|| OemToAnsi("Estado: ") }     ,oDlgTel,,,,,,.T.,CLR_BLACK,CLR_BLUE,050,20)
	oUFBH:=TGet():New(080,040, {|U| IIf(PCount()==0,cUFBH,cUFBH:=U )} ,oDlgTel   ,050,010,  PesqPict("SF1","F1_UFDESBH"),,,,,,,.T.,,,,,,,,,,(cUFBH))
	Activate MsDialog oDlgTel Center on Init  EnchoiceBar(oDlgTel ,{||IF(fConf(),oDlgTel:End(),oDlgTel:End()) } , {||oDlgTel:End()} )
 
RestArea(aArea)
Return(.T.) 
  
Static  Function FConf()
***************************
* Grava SF1 
*
*************************

Local cRet := .T. 
    dbSelectArea("SF1")
	If RecLock("SF1",.F.)           
        SF1->F1_MODNF   :=cModNF            
     //   SF1->F1_DOCDES  :=cDocBH
        SF1->F1_SERIEDS :=cSerieDS                        
		SF1->F1_CDDESBH :=cMunBH
		SF1->F1_UFDESBH :=cUFBH
		MsUnlock()  
	Endif          
Return(cRet)

Static  Function fDocBH()
***************************
* Pesquisa documentos
*
*************************
Local lRet:=.T.
Return(lret)