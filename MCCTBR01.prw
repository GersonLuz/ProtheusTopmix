#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"     
#include "TopConn.ch"    
//-------------------------------------------------------------------
/*/{Protheus.doc} MCCTBR01

@protected
@author    Rodrigo Carvalho
@since     20/03/2015
@obs       Relatório Balancete com Centro de Custo e Contas TOPMIX.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 

User Function MCCTBR01() 

Private cPerg      := Padr("MCCTBR01",10)   
Private wnrel      := Padr("MCCTBR01",10) 
Private aPerg      := {}
Private aReturn    := { OemToAnsi("Zebrado"), 1 ,OemToAnsi("Administracao"), 2, 2, 1, "" ,1 } //aReturn[4] == 2 : Paisagem , 1 : retrato	/
Private cTitulo    := OemToAnsi("Relatório Balancete com Centro de Custo e Contas")
Private cDesc1     := OemToAnsi("")
Private cDesc2     := OemToAnsi("")
Private cDesc3     := OemToAnsi("")
Private cTamanho   := "G"  //P = pequeno, G = grande
Private cString    := "CT1"
Private nTipo      := IIF(aReturn[4]==1,15,18)
Private nPag       := 1
Private nQtdReg    := 0

Private lRetQry    := .T.
Private aStrQry    := {}
Private aCabec     := {}  
Private aItens     := {}
Private lCsv       := .F. // exportar em CSV = .T. , exportar em XML = .F.
Private cArquivo   := "Balancete.XML"

aAdd(aPerg,{cPerg,"Filial de          ","C",06,0,"G","","SM0",""})
aAdd(aPerg,{cPerg,"Filial até         ","C",06,0,"G","","SM0",""})
Aadd(aPerg,{cPerg,"Data Inicial       ","D",08,0,"G","","",""})
Aadd(aPerg,{cPerg,"Data Final         ","D",08,0,"G","","",""})
Aadd(aPerg,{cPerg,"Tipo do Relatorio? ","N",01,0,"C","","","Conta Contábil ","Conta e C.Custo","",""})
Aadd(aPerg,{cPerg,"Filial a Considerar","N",01,0,"C","","","Filial         ","Filial Origem  ","",""})

U_TestaSX1(cPerg,aPerg)

Pergunte(cPerg,.F.)   

wnrel   := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,cTamanho)
If (nLastKey == 27)
   Return
EndIf 
cTitulo   := IIf(MV_PAR05==1,"Balancete por Conta Contabil","Balancete por Conta Contabil e Centro de Custo")
cArquivo  := StrTran(Upper(cArquivo),".XML","_") + DtoS(MV_PAR03) +"_"+ DtoS(MV_PAR04)+IIf(MV_PAR05==1,"","_CC")+".XML"

MsgRun("Aguarde... Selecionando dados... " ,,{|| CursorWait() , FQryDB() ,CursorArrow()})                    

If lRetQry
   MsgRun("Aguarde... Imprimindo dados... " ,,{|| CursorWait() , FImprime() ,CursorArrow()})                    
Endif

Return .T.
        



//-------------------------------------------------------------------
/*/{Protheus.doc} FImprime

@protected
@author    Rodrigo Carvalho
@since     20/03/2015
@obs       Relatório Balancete com Centro de Custo e Contas 

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 
Static Function FImprime()

Local   oExcel     := FWMSEXCEL():New()
Local   cPlan	   := "Balancete_"
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

cCabec1 := FMTCabec()

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
@since     20/03/2015
@obs       Query para selecao dos dados.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//-------------------------------------------------------------------
Static Function FQryDB()

Local cQuery  := "" 
Local cCmpFil := IIf(MV_PAR06==1,"CT2_FILIAL","CT2_FILORI")

cQuery := "SELECT "+cCmpFil+", CT1_CONTA,"+IIf(MV_PAR05==1,"","CC CTT_CUSTO,")+"CT1_DESC01, SUM(CT2_VALOR) CT2_VALOR "+ CRLF
cQuery += "FROM ("+ CRLF
cQuery += "SELECT "+cCmpFil+","              + CRLF
cQuery += " RTRIM(CT2_DEBITO) CT1_CONTA,"        + CRLF
cQuery += IIf(MV_PAR05==1,""," RTRIM(CT2_CCD) CC,"+ CRLF)
cQuery += "       CT1_DESC01,"               + CRLF
cQuery += "   SUM(CT2_VALOR) CT2_VALOR"      + CRLF
cQuery += "  FROM "+RetSqlName("CT2")+" CT2" + CRLF
cQuery += "  JOIN "+RetSqlName("CT1")+" CT1" + CRLF
cQuery += "    ON (RTRIM(CT1_CONTA) = RTRIM(CT2_DEBITO))" + CRLF
cQuery += " WHERE CT2_DC         IN ('1', '3')"           + CRLF
cQuery += "   AND "+cCmpFil+"    BETWEEN '"+MV_PAR01      +"' AND '"+     MV_PAR02 +"'" + CRLF
cQuery += "   AND CT2_DATA       BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"'" + CRLF
cQuery += "   AND CT2_DEBITO     >= '3'"     + CRLF
cQuery += "   AND CT2.D_E_L_E_T_ <> '*'"     + CRLF
cQuery += "   AND CT1.D_E_L_E_T_ <> '*'"     + CRLF
cQuery += "   AND CT2_MOEDLC     = '01'"     + CRLF
cQuery += "  GROUP BY "+cCmpFil+", CT1_DESC01, RTRIM(CT2_DEBITO)"
cQuery += IIf(MV_PAR05==1,"",",RTRIM(CT2_CCD) ")+ CRLF
cQuery += "  UNION "            + CRLF
cQuery += "SELECT "+cCmpFil+"," + CRLF
cQuery += " RTRIM(CT2_CREDIT) CT1_CONTA,"        + CRLF
cQuery += IIf(MV_PAR05==1,"","RTRIM(CT2_CCC) CC,"+ CRLF)
cQuery += "       CT1_DESC01,"               + CRLF
cQuery += "   SUM(CT2_VALOR * -1) CT2_VALOR" + CRLF
cQuery += "  FROM "+RetSqlName("CT2")+" CT2" + CRLF
cQuery += "  JOIN "+RetSqlName("CT1")+" CT1" + CRLF
cQuery += "    ON (RTRIM(CT1_CONTA) = RTRIM(CT2_CREDIT))" + CRLF
cQuery += " WHERE CT2_DC         IN ('2', '3')" + CRLF
cQuery += "   AND "+cCmpFil+"    BETWEEN '"+     MV_PAR01 +"' AND '"+     MV_PAR02 +"'" + CRLF
cQuery += "   AND CT2_DATA       BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"'" + CRLF
cQuery += "   AND CT2_CREDIT     >= '3'" + CRLF
cQuery += "   AND CT2.D_E_L_E_T_ <> '*'" + CRLF
cQuery += "   AND CT1.D_E_L_E_T_ <> '*'" + CRLF
cQuery += "   AND CT2_MOEDLC     = '01'" + CRLF
cQuery += " GROUP BY "+cCmpFil+",CT1_DESC01,RTRIM(CT2_CREDIT)"
cQuery += IIf(MV_PAR05==1,"",",RTRIM(CT2_CCC)") + CRLF 
cQuery += ") MOVIMENTO"+ CRLF
cQuery += "GROUP BY "+cCmpFil+", CT1_CONTA,"+IIf(MV_PAR05==1,"","CC,")+"CT1_DESC01"+ CRLF
cQuery += "ORDER BY "+cCmpFil+", CT1_CONTA"+IIf(MV_PAR05==1,"",",CC")+ CRLF

dbUseArea( .T., "TOPCONN", "QRY1", TcGenQry( ,,cQuery ), .F., .T. )
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
   Aviso("ATENÇÃO","Não há ocorrencias com essa seleção!",{"Ok"}) 
Endif
                      
Return( lRetQry )





//-------------------------------------------------------------------
/*/{Protheus.doc} FMTCabec

@protected
@author    Rodrigo Carvalho
@since     20/03/2015
@obs       Monta o Cabecalho.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 
Static Function FMTCabec()

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