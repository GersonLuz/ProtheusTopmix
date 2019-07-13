#include "rwmake.ch"     
#include "TopConn.ch"    
//-------------------------------------------------------------------
/*/{Protheus.doc} MCFINR01

@protected
@author    Rodrigo Carvalho
@since     03/11/2015
@obs       Relatorio de contas a receber para calculo de comissão.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 

User Function MCFINR01() 

Private cPerg      := Padr("MCFINR01",10)   
Private wnrel      := Padr("MCFINR01",10) 
Private aPerg      := {}
Private aReturn    := { OemToAnsi("Zebrado"), 1 ,OemToAnsi("Administracao"), 2, 2, 1, "" ,1 } //aReturn[4] == 2 : Paisagem , 1 : retrato	/
Private cTitulo    := OemToAnsi("Relatório de Contas a Receber Para Cálculo de Comissão")
Private cDesc1     := OemToAnsi("")
Private cDesc2     := OemToAnsi("")
Private cDesc3     := OemToAnsi("")
Private cTamanho   := "G"  //P = pequeno, G = grande
Private cString    := "SE1"
Private nTipo      := IIF(aReturn[4]==1,15,18)
Private nPag       := 1
Private nQtdReg    := 0
Private aTotais1   := {}
Private aStrQry1   := {}

Private aCabec1    := {}  

Private lRetQry    := .T.
Private aItens     := {}
Private lCsv       := .F. // exportar em CSV = .T. , exportar em XML = .F.
Private cArquivo   := "CalculoComissao.XML"

aAdd(aPerg,{cPerg,"Filial de         ","C",06,0,"G","","SM0",""})
aAdd(aPerg,{cPerg,"Filial até        ","C",06,0,"G","","SM0",""})
aAdd(aPerg,{cPerg,"Emissão de        ","D",08,0,"G","","",""})
aAdd(aPerg,{cPerg,"Emissão até       ","D",08,0,"G","","",""})

U_TestaSX1(cPerg,aPerg)

Pergunte(cPerg,.F.)   

wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,cTamanho)

If (nLastKey == 27)
   Return
EndIf 

cArquivo := StrTran(Upper(cArquivo),".XML","_") + DtoS(Date()) +".XML"

MsgRun("Aguarde... Selecionando dados... " ,,{|| CursorWait() , FQryDB() ,CursorArrow()})                    

If lRetQry
   MsgRun("Aguarde... Imprimindo dados... " ,,{|| CursorWait() , FProcessa() ,CursorArrow()})                    
Else
   MsgStop("Não há ocorrências com essa seleção!!" )
Endif

Return .T.
        



//-------------------------------------------------------------------
/*/{Protheus.doc} FProcessa

@protected
@author    Rodrigo Carvalho
@since     03/11/2015
@obs       Gera o relatorio e carrega para o objeto excel.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 
Static Function FProcessa()

Local   cPasta     := "C:\Relatorios_Protheus\"
Private cCabec1    := ""

Private oExcel     := FWMSEXCEL():New()
Private li         := 99
Private m_Pag      := 1
Private nCol       := 1
Private nEspaco    := 1
Private aFolder    := {}
Private cPeriodo   := " EMISSÃO DE: "+DtoC(MV_PAR03)+" ATÉ: "+DtoC(MV_PAR04)
                   
aAdd(aFolder,{"Titulos","Contas a Receber - "+cPeriodo})

MakeDir(cPasta)

For nX1 := 1 To Len(aFolder)
    oExcel:AddworkSheet(aFolder[nX1][1]) // Plan
    oExcel:AddTable( aFolder[nX1][1] , aFolder[nX1][2] ) // Plan,Titulo
    aCabec := "aCabec" + Alltrim(Str(nX1))  // campos
    For nX2 := 1 To Len(&aCabec)  // insert campos
        oExcel:AddColumn( aFolder[nX1][1] , aFolder[nX1][2] , &aCabec[nX2][1] ,1,1 )
    Next
Next

oExcel:SetFontSize(12)
SetDefault(aReturn,cString)

nCol     := 1
cCabec1  := MCCabec(aStrQry1,aCabec1,"QRY1")
cPlan1   := aFolder[1][1]
cTitulo1 := aFolder[1][2]

FImprime("QRY1",aStrQry1,cPlan1,cTitulo1,cCabec1,aCabec1)

dbSelectArea("QRY1")
dbCloseArea() 

If lCsv
   DlgToExcel({{"ARRAY",cTitulo + DToC( MV_PAR03)+" Até: "+DToC( MV_PAR04 ),aCabec1[1],aItens}})
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
@since     03/11/2015
@obs       Query 

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//-------------------------------------------------------------------
Static Function FQryDB()

Local cQuery1 := "" 
Local CRLF    := chr(13) + chr(10)
      
cQuery1 := "SELECT "+CRLF
cQuery1 += "       M0_FILIAL FILIAL,"+CRLF
cQuery1 += "       E1_PREFIXO,"+CRLF
cQuery1 += "       E1_NUM,"+CRLF
cQuery1 += "       E1_PARCELA,"+CRLF
cQuery1 += "       E1_TIPO,"+CRLF
cQuery1 += "       E1_CLIENTE,"+CRLF
cQuery1 += "       E1_LOJA,"+CRLF
cQuery1 += "       E1_NOMCLI,"+CRLF
cQuery1 += "       LEFT(A3_NOME,35) A3_NOME,"+CRLF
cQuery1 += "       E1_EMISSAO,"+CRLF
cQuery1 += "       E1_VENCREA,"+CRLF
cQuery1 += "       C6_UM,"+CRLF
cQuery1 += "   SUM(C6_QTDVEN) AS C6_QTDVEN,"+CRLF
cQuery1 += "       E1_VALOR,"+CRLF
cQuery1 += "	SUM(C6_ABATMAT) AS C6_ABATMAT,"+CRLF				//Jean Santos - 26/04/2017
cQuery1 += "		 E1_VALOR-SUM(C6_ABATMAT) AS Base_Calculo,"+CRLF	//Jean Santos - 26/04/2017
cQuery1 += "       E1_ISS,"+CRLF
cQuery1 += "       E1_BAIXA,"+CRLF
cQuery1 += "       E1_SALDO,"+CRLF
cQuery1 += "       E1_ZBANCO,"+CRLF
cQuery1 += "       E1_ZBOLETO,"+CRLF
cQuery1 += " RTRIM(C5_ZPEDIDO) AS C5_ZPEDIDO,"+CRLF
cQuery1 += "       C5_ZBOLETO,"+CRLF
cQuery1 += "       C5_NUM,"+CRLF
cQuery1 += "       E1_ORIGEM,"+CRLF
cQuery1 += "       E1_HIST,"+CRLF
cQuery1 += "       E1_NUMBOR,"+CRLF
cQuery1 += "       E1_DATABOR,"+CRLF
cQuery1 += "       E1_SERIE,"+CRLF
cQuery1 += "       E1_VEND1,"+CRLF
cQuery1 += "       E1_MSFIL"+CRLF
cQuery1 += "  FROM "+RetSqlName("SE1")+" E1"+CRLF
cQuery1 += " INNER JOIN SIGAMAT ON (E1_MSFIL = M0_CODFIL AND SIGAMAT.D_E_L_E_T_ <> '*')"+CRLF
cQuery1 += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON (E1_CLIENTE = A1_COD  AND E1_LOJA   = A1_LOJA AND SA1.D_E_L_E_T_ <> '*')"+CRLF
cQuery1 += " INNER JOIN "+RetSqlName("SC5")+" SC5 ON (E1_MSFIL = C5_FILIAL AND E1_PEDIDO = C5_NUM AND SC5.D_E_L_E_T_ <> '*')"+CRLF
cQuery1 += " INNER JOIN "+RetSqlName("SA3")+" SA3 ON (E1_VEND1 = A3_COD    AND SA3.D_E_L_E_T_ <> '*')"+CRLF
cQuery1 += " INNER JOIN "+RetSqlName("SC6")+" SC6 ON (E1_MSFIL = C6_FILIAL AND E1_PEDIDO = C6_NUM AND E1_CLIENTE = C6_CLI AND E1_LOJA = C6_LOJA "
cQuery1 += "   AND SC6.D_E_L_E_T_ <> '*')"+CRLF
cQuery1 += "WHERE E1.D_E_L_E_T_ <> '*'"+CRLF
cQuery1 += "  AND E1_MSFIL   BETWEEN '"+     MV_PAR01 +"' AND '"+     MV_PAR02 +"'"+CRLF
cQuery1 += "  AND E1_EMISSAO BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"'"+CRLF
cQuery1 += " GROUP BY E1_MSFIL,"+CRLF
cQuery1 += "          M0_FILIAL,"+CRLF
cQuery1 += "          E1_PREFIXO,"+CRLF
cQuery1 += "          E1_NUM,"+CRLF
cQuery1 += "          E1_SERIE,"+CRLF
cQuery1 += "          E1_PARCELA,"+CRLF
cQuery1 += "          E1_TIPO,"+CRLF
cQuery1 += "          E1_CLIENTE,"+CRLF
cQuery1 += "          E1_LOJA,"+CRLF
cQuery1 += "          E1_NOMCLI,"+CRLF
cQuery1 += "          E1_VEND1,"+CRLF
cQuery1 += "          A3_NOME,"+CRLF
cQuery1 += "          E1_EMISSAO,"+CRLF
cQuery1 += "          E1_VENCREA,"+CRLF
cQuery1 += "          C6_UM,"+CRLF
cQuery1 += "          E1_VALOR,"+CRLF
cQuery1 += "          E1_ISS,"+CRLF
cQuery1 += "          E1_BAIXA,"+CRLF
cQuery1 += "          E1_SALDO,"+CRLF
cQuery1 += "          E1_NUMBOR,"+CRLF
cQuery1 += "          E1_DATABOR,"+CRLF
cQuery1 += "          E1_ZBANCO,"+CRLF
cQuery1 += "          E1_ZBOLETO,"+CRLF
cQuery1 += "          E1_HIST,"+CRLF
cQuery1 += "          E1_ORIGEM,"+CRLF
cQuery1 += "          C5_NUM,"+CRLF
cQuery1 += "          C5_ZPEDIDO,"+CRLF
cQuery1 += "          C5_ZBOLETO"+CRLF
cQuery1 += " ORDER BY E1_MSFIL , E1_PREFIXO, E1_NUM, E1_PARCELA"+CRLF
            
dbUseArea( .T., "TOPCONN", "QRY1", TcGenQry( ,,cQuery1 ), .F., .T. )
lRetQry := .T.

DbSelectArea("QRY1")
nQtdReg := 0

DbGoTop()
Do While ! Eof()
   nQtdReg++
   DbSelectArea("QRY1")
   DbSkip()
Enddo
DbGoTop()

If nQtdReg > 0      
   DbSelectArea("QRY1")  
   aStrQry1 := QRY1->(dbStruct())
   aCabec1  := MCStrCabec(aStrQry1)
Else
   dbSelectArea("QRY1")
   dbCloseArea() 
   lRetQry := .F.
Endif

Return( lRetQry )





//-------------------------------------------------------------------
/*/{Protheus.doc} MCCabec

@protected
@author    Rodrigo Carvalho
@since     03/11/2015
@obs       Monta o Cabecalho.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 
Static Function MCCabec(aStrQry,aCabec,cAliasQry)
Local nMargem := 0
Local cCabec  := " "

For nX := 1 To len(aStrQry)
    cCampo := aStrQry[nX][1] 
    If aCabec[nX][2] == "D"
       Infor    := IIf(StoD((cAliasQry)->&cCampo)==Ctod(""),"",StoD((cAliasQry)->&cCampo))
       cPicture := "@D 99/99/9999"
       nTamCmp  := 10
    Else
       Infor    := (cAliasQry)->&cCampo
       cPicture := Alltrim(aCabec[nX][5])
       If (Alltrim(aCabec[nX][2]) == 'N' .AND. Len(cPicture) < acabec[nX][3])  // VARIAVEL NUMERICA NAO PODE POSSUIR MASCARA MENOR QUE acabec[nX][3] - CRISTIANO FERREIRA
       cPicture := "@E 99,999,999,999.99"
       Endif
       nTamCmp  := IIf( Len(cPicture) > acabec[nX][3] , Len(cPicture) ,  IIf( Len(Infor) < acabec[nX][3] , Len(Infor) , acabec[nX][3] ))
    Endif              
    nMargem := (nTamCmp -  Len(aCabec[nX][1])) / 2
    If nTamCmp > Len(aCabec[nX][1]) .And. aCabec[nX][2] == "N"
       //cCabec   += IIf(nCol < 205 ,  Space(Int(nMargem)) + aCabec[nX][1] + Space(Round(nMargem,0)) + Space(nEspaco) ,"") 
       cCabec   += IIf(nCol < 205 , SubStr( Space(nTamCmp-Len(aCabec[nX][1])-1) + aCabec[nX][1] ,1,nTamCmp) + Space(nEspaco) ,"")        
    Else
       cCabec   += IIf(nCol < 205 , SubStr(aCabec[nX][1] + Space(nTamCmp),1,nTamCmp) + Space(nEspaco) ,"") 
    Endif
    nCol     += (nTamCmp + nEspaco)
Next       

Return(cCabec)



//-------------------------------------------------------------------
/*/{Protheus.doc} MCStrCabec

@protected
@author    Rodrigo Carvalho
@since     03/11/2015
@obs       Monta o Cabecalho.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 
Static Function MCStrCabec(aStrQry)

Local aCabec := {}

For nX := 1 To len(aStrQry)

    dbSelectArea("SX3")
    dbSetOrder(2)
    
    cCampo := Alltrim(aStrQry[nX][1])
    
    If DbSeek( cCampo )
       aadd(aCabec,{Capital(AllTrim(IIf(TAMSX3(cCampo)[01] < 30,X3Titulo(),X3DESCRIC()))),TAMSX3(cCampo)[03],TAMSX3(cCampo)[01],TAMSX3(cCampo)[02],;
       Alltrim(X3_Picture)})	      
    Else
       If aStrQry [nX][2] == "N"
          aadd(aCabec , {cCampo , aStrQry [nX][2] , aStrQry [nX][3] , aStrQry [nX][4] , "9,999,999.99"})  	            
       Else
          aadd(aCabec , {cCampo , aStrQry [nX][2] , aStrQry [nX][3] , aStrQry [nX][4] , ""})  	     
       Endif
    Endif           

    If aStrQry [nX][2] == "N"
       aAdd(aTotais1,{ cCampo , X3DESCRIC() , 0 })
    Endif
        
Next nX 

Return( aCabec )





//-------------------------------------------------------------------
/*/{Protheus.doc} FImprime

@protected
@author    Rodrigo Carvalho
@since     03/11/2015
@obs       Imprime os dados carregados.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 
Static Function FImprime(cAliasQry,aStrQry,cPlan,cTitulo,cCabec,aCabec)

Local nPos1 := 0

DbSelectArea(cAliasQry)
DbGotop()

Do While ! Eof()

   IF li > 58
      cabec(cTitulo,cCabec:=strtran(cCabec,"BASE_CALCULO","Base. Calculo"),"",cPerg,cTamanho,nTipo)
   EndIF
   
   aItemSql := {}
   nCol     := 1

   For nX := 1 To len(aStrQry)

       cCampo := aStrQry[nX][1] 
       
       If aCabec[nX][2] == "D"
          Infor    := IIf(StoD(QRY1->&cCampo)==Ctod(""),"",StoD((cAliasQry)->&cCampo))
          cPicture := "@D 99/99/9999"
          nTamCmp  := 10
       Else                   
          Infor    := (cAliasQry)->&cCampo
          cPicture := Alltrim(aCabec[nX][5])
          If (Alltrim(aCabec[nX][2]) == 'N' .AND. Len(cPicture) < acabec[nX][3])  // VARIAVEL NUMERICA NAO PODE POSSUIR MASCARA MENOR QUE acabec[nX][3] - CRISTIANO FERREIRA
          cPicture := "@E 99,999,999,999.99"
          Endif
          nTamCmp  := IIf( Len(cPicture) > acabec[nX][3] , Len(cPicture) ,  IIf( Len(Infor) < acabec[nX][3] , Len(Infor) , acabec[nX][3] ))
  
          
          If aCabec[nX][2] == "N" 
             nPos1 := aScan(aTotais1,{|x| x[1] == cCampo}) 
             If nPos1 > 0
                aTotais1[nPos1][3] += Infor
             Endif
          Endif
          
       Endif        

       AAdd(aItemSql,Infor)       
       If nCol < 205
          @ li,nCol PSay Infor Picture cPicture
       Endif

       nCol += (nTamCmp + nEspaco)
   Next       

   If lCsv
      Aadd(aItens,aItemSql)  
   Else
      oExcel:AddRow(cPlan,cTitulo,aItemSql)
   Endif

   li++
   DbSelectArea(cAliasQry)
   
   DbSkip()

Enddo
@ li,001 PSAY __PrtThinLine()
li++  

IF li > (58 - Len(aTotais1))
   cabec(cTitulo,cCabec:=strtran(cCabec,"BASE_CALCULO","Base. Calculo"),"",cPerg,cTamanho,nTipo)
Else
   For nXy := 1 To Len(aTotais1)   
       @ li,001 PSay OemToAnsi("Total "+StrTran(aTotais1[nXy][2]," ",".") +": "+ Transform(aTotais1[nXy][3],"999,999,999.99"))
       li++
   Next
   @ li,001 PSAY __PrtThinLine()
EndIF

Return .T.
