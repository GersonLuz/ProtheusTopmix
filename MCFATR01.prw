#include "rwmake.ch"     
#include "TopConn.ch"    
//-------------------------------------------------------------------
/*/{Protheus.doc} MCFATR01

@protected
@author    Rodrigo Carvalho
@since     27/08/2015
@obs       Relatorio de conferencia de faturamento TOPMIX.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 

User Function MCFATR01() 

Private cPerg      := Padr("MCFATR01",10)   
Private wnrel      := Padr("MCFATR01",10) 
Private aPerg      := {}
Private aReturn    := { OemToAnsi("Zebrado"), 1 ,OemToAnsi("Administracao"), 2, 2, 1, "" ,1 } //aReturn[4] == 2 : Paisagem , 1 : retrato	/
Private cTitulo    := OemToAnsi("Conferência de dados pendentes de faturamento / recebimento")
Private cDesc1     := OemToAnsi("")
Private cDesc2     := OemToAnsi("")
Private cDesc3     := OemToAnsi("")
Private cTamanho   := "G"  //P = pequeno, G = grande
Private cString    := "SC5"
Private nTipo      := IIF(aReturn[4]==1,15,18)
Private nPag       := 1
Private nQtdReg    := 0

Private lRetQry    := .T.
Private aStrQry    := {}
Private aCabec     := {}  
Private aItens     := {}
Private lCsv       := .F. // exportar em CSV = .T. , exportar em XML = .F.
Private cArquivo   := "Conferencia_Faturamento.XML"

aAdd(aPerg,{cPerg,"Filial de         ","C",04,0,"G","","SM0",""})
aAdd(aPerg,{cPerg,"Filial até        ","C",04,0,"G","","SM0",""})
aAdd(aPerg,{cPerg,"Emissão de        ","D",08,0,"G","","",""})
aAdd(aPerg,{cPerg,"Emissão até       ","D",08,0,"G","","",""})

U_TestSX1(cPerg,aPerg)

Pergunte(cPerg,.F.)   

wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,cTamanho)

If (nLastKey == 27)
   Return
EndIf 

cArquivo  := StrTran(Upper(cArquivo),".XML","_") + DtoS(Date()) +".XML"

MsgRun("Aguarde... Selecionando dados... " ,,{|| CursorWait() , FQryDB() ,CursorArrow()})                    

If lRetQry
   MsgRun("Aguarde... Imprimindo dados... " ,,{|| CursorWait() , FImprime() ,CursorArrow()})                    
Else
   MsgStop("Não há ocorrências com essa seleção!!" )
Endif

Return .T.
        



//-------------------------------------------------------------------
/*/{Protheus.doc} FImprime

@protected
@author    Rodrigo Carvalho
@since     16/05/2015
@obs       Relatorio de conferencia de faturamento Customizado TOPMIX

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 
Static Function FImprime()

Local   oExcel     := FWMSEXCEL():New()
Local   cPlan	   := "Faturamento"
Local   cPasta     := "C:\Relatorios_Protheus\"
Local   nCusto     := 0

Private cCabec1    := ""
Private li         := 99
Private m_Pag      := 0
Private nCol       := 1
Private nEspaco    := 1

MakeDir(cPasta)

oExcel:AddworkSheet(cPlan)
oExcel:AddTable(cPlan,cTitulo)
oExcel:SetFontSize(12)

For nXy := 1 To Len(aCabec)
    oExcel:AddColumn(cPlan,cTitulo, aCabec[nXy][1],1,1)
Next

cCabec1 := McCabec()

SetDefault(aReturn,cString)

DbSelectArea("QRY1")
DbGotop()

Do While ! Eof()

   IF li > 58
      cabec(cTitulo,cCabec1,"",cPerg,cTamanho,nTipo)
   EndIF
   
   aItemSql := {}
   nCol     := 1

   For nX := 1 To len(aStrQry)

       cCampo := aStrQry[nX][1] 
       
       If aCabec[nX][2] == "D"
          Infor    := IIf(StoD(QRY1->&cCampo)==Ctod(""),"",StoD(QRY1->&cCampo))
          cPicture := "@D 99/99/9999"
          nTamCmp  := 10
       Else
          Infor    := QRY1->&cCampo
          cPicture := aCabec[nX][5]
          nTamCmp  := IIf(acabec[nX][3] > Len(cPicture),acabec[nX][3],Len(cPicture))
       Endif        

       AAdd(aItemSql,Infor)       
       If nCol < 205
          @ li,nCol PSay Infor Picture cPicture
       Endif

       nCol    += (nTamCmp + nEspaco)
   Next       

   If lCsv
      Aadd(aItens,aItemSql)  
   Else
      oExcel:AddRow(cPlan,cTitulo,aItemSql)
   Endif

   li++
   DbSelectArea("QRY1")
   DbSkip()

Enddo

dbSelectArea("QRY1")
dbCloseArea() 

@ li,001 PSAY __PrtThinLine()
li++  
   
If lCsv
   DlgToExcel({{"ARRAY",cTitulo + DToC( MV_PAR03)+" Até: "+DToC( MV_PAR04 ),aCabec[1],aItens}})
Else
   oExcel:Activate() //gravando arquivo em disco
   oExcel:GetXMLFile(Alltrim(cPasta)+cArquivo)                                                        
   ShellExecute("Open","EXCEL.EXE",Alltrim(cPasta)+cArquivo,"C:\",1)   
   MsgInfo("Arquivo gerado com sucesso! "+chr(13)+Upper(Alltrim(cPasta)+cArquivo),"Gravacao arquivo" )
Endif

If aReturn[5] = 1
   Set Printer To
   dbCommitAll()
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} FQryDB()

@protected
@author    Rodrigo Carvalho
@since     16/05/2015
@obs       Seleção dos dados

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//-------------------------------------------------------------------
Static Function FQryDB()

Local cQuery := "" 
Local CRLF   := chr(13) + chr(10)

// Apresentar os dados da tabela SRF se o campo RF_DATABAS NAO tiver na tabela SRH, ou seja se a ultima data do RH_DATABAS <RF_DATABAS 

cQuery := "SELECT ," + CRLF
cQuery += "  FROM "+RetSqlName("SRA")+" SRA"+ CRLF
cQuery += " WHERE 

dbUseArea( .T., "	TOPCONN", "QRY1", TcGenQry( ,,cQuery ), .F., .T. )
lRetQry := .T.

DbSelectArea("QRY1")

DbGoTop()
DbEval({|| nQtdReg++})
DbGoTop()

If nQtdReg > 0      
   DbSelectArea("QRY1")  
   aStrQry := QRY1->(dbStruct())
   For nX := 1 To len(aStrQry)
      dbSelectArea("SX3")
	  dbSetOrder(2)

	  cCampo := Alltrim(aStrQry [nX][1])
	  cCampo := IIf( SubStr(cCampo,1,Len(cCampo)-1) $ "RH_DBASEA" , "RH_DBASEAT" , cCampo ) // tratamento do campo duplicado.
	  
	  If DbSeek( cCampo )
         aadd(aCabec,{AllTrim(X3Titulo()),TAMSX3(cCampo)[03],TAMSX3(cCampo)[01],TAMSX3(cCampo)[02],Alltrim(X3_Picture)})	      
	  Else
         aadd(aCabec,{cCampo,aStrQry [nX][2],aStrQry [nX][3],aStrQry [nX][4],""})  	     
	  Endif   
   Next nX 
Else
   dbSelectArea("QRY1")
   dbCloseArea() 
   lRetQry := .F.
Endif

// Ajusta Cabecalho de acordo com a necessidade do cliente;
aCabec [08][1] := "teste"
                      
Return( lRetQry )





//-------------------------------------------------------------------
/*/{Protheus.doc} McCabec

@protected
@author    Rodrigo Carvalho
@since     27/08/2015
@obs       Monta o Cabecalho.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 
Static Function McCabec()

Local cCabec := " "

For nX := 1 To len(aStrQry)
    cCampo := aStrQry[nX][1] 
    If aCabec[nX][2] == "D"
       Infor    := IIf(StoD(QRY1->&cCampo)==Ctod(""),"",StoD(QRY1->&cCampo))
       cPicture := "@D 99/99/9999"
       nTamCmp  := 10
    Else
       Infor    := QRY1->&cCampo
       cPicture := aCabec[nX][5]
       nTamCmp  := IIf(acabec[nX][3] > Len(cPicture),acabec[nX][3],Len(cPicture))
    Endif        
 
    cCabec   += IIf(nCol < 205 , SubStr(aCabec[nX][1] + Space(nTamCmp),1,(nTamCmp)) + Space(nEspaco) ,"") 
    nCol     += (nTamCmp + nEspaco)

Next       

Return(cCabec)