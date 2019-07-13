#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"     
#include "TopConn.ch"    
//-------------------------------------------------------------------
/*/{Protheus.doc} MCCOMR01

@protected
@author    Rodrigo Carvalho
@since     20/03/2015
@obs       Relação de pedidos de compras;

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 

User Function MCCOMR01() 

Private cPerg      := Padr("MCCOMR01",10)   
Private wnrel      := Padr("MCCOMR01",10) 
Private aPerg      := {}
Private aReturn    := { OemToAnsi("Zebrado"), 1 ,OemToAnsi("Administracao"), 2, 2, 1, "" ,1 } //aReturn[4] == 2 : Paisagem , 1 : retrato	/
Private cTitulo    := OemToAnsi("Relação de Pedidos de Compras")
Private cDesc1     := OemToAnsi("")
Private cDesc2     := OemToAnsi("")
Private cDesc3     := OemToAnsi("")
Private cTamanho   := "G"  //P = pequeno, G = grande
Private cString    := "SC7"
Private nTipo      := IIF(aReturn[4]==1,15,18)
Private nPag       := 1
Private nQtdReg    := 0
Private lRetQry    := .T.
Private aStrQry    := {}
Private aCabec     := {}  
Private aItens     := {}
Private lCsv       := .F. // exportar em CSV = .T. , exportar em XML = .F.
Private cArquivo   := "Pedidos_Compras.XML"
Private nTamTipo   := TamSx3("CR_TIPO")[1]
Private nLimCol    := 215                   
Private lCtrAprov  := SuperGetMv("MC_CTRAPRO",,.T.) // somente pedidos com controle de aprovação (tabela SCR)

If lCtrAprov
   Aviso("AVISO","Somente os pedidos com controle de aprovação ativado serão impressos!",{"Ok"}) 
Else
   Aviso("AVISO","Sem considerar o controle de aprovação de pedidos",{"Ok"})    
Endif

aAdd(aPerg,{cPerg,"Filial de          ","C",06,0,"G","","SM0",""})
aAdd(aPerg,{cPerg,"Filial até         ","C",06,0,"G","","SM0",""})
Aadd(aPerg,{cPerg,"Data Emissão de    ","D",08,0,"G","","",""})
Aadd(aPerg,{cPerg,"Data Emissão até   ","D",08,0,"G","","",""})
aAdd(aPerg,{cPerg,"Pedido de          ","C",06,0,"G","","SC7",""})
aAdd(aPerg,{cPerg,"Pedido até         ","C",06,0,"G","","SC7",""})
aAdd(aPerg,{cPerg,"Comprador de       ","C",06,0,"G","","SAJ",""})
aAdd(aPerg,{cPerg,"Comprador até      ","C",06,0,"G","","SAJ",""})
aAdd(aPerg,{cPerg,"Grupo Aprovação de ","C",06,0,"G","","SAL",""})
aAdd(aPerg,{cPerg,"Grupo Aprovação até","C",06,0,"G","","SAL",""})
aAdd(aPerg,{cPerg,"Aprovador de       ","C",06,0,"G","","SAK",""}) // controle de aprovação
aAdd(aPerg,{cPerg,"Aprovador até      ","C",06,0,"G","","SAK",""}) // controle de aprovação
Aadd(aPerg,{cPerg,"Data Aprovação de  ","D",08,0,"G","","",""})    // controle de aprovação
Aadd(aPerg,{cPerg,"Data Aprovação até ","D",08,0,"G","","",""})    // controle de aprovação
aAdd(aPerg,{cPerg,"Imprime Aprovadores","N",01,0,"C","","","Sim","Não","","",""}) // controle de aprovação

U_TestaSX1(cPerg,aPerg)

Pergunte(cPerg,.F.)   

wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,cTamanho)

If (nLastKey == 27)
   Return
EndIf 

cArquivo  := StrTran(Upper(cArquivo),".XML","_") + DtoS(MV_PAR03) +"_"+ DtoS(MV_PAR04)+".XML"

If Empty(MV_PAR13) .And. Empty(MV_PAR14)
//   Aviso("AVISO","Não será considerado o filtro pela data de aprovação!",{"Ok"}) 
Endif

MsgRun("Aguarde... Selecionando dados... "  ,,{|| CursorWait() , FQryDB()  , CursorArrow()})                    

If lRetQry
   MsgRun("Aguarde... Imprimindo dados... " ,,{|| CursorWait() , FImprime(), CursorArrow()})                    
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

Private oExcel     := FWMSEXCEL():New()
Private cPlan1     := "Lista_Pedidos"
Private cPlan2     := "Aprovadores"
Private cPasta     := "C:\Relatorios_Protheus\"
Private nCusto     := 0           
Private cTitulo2   := "Lista dos Aprovadores por Pedido de Compra"

Private cCabec1    := ""
Private li         := 99
Private m_Pag      := 0
Private nCol       := 1
Private nEspaco    := 1
Private nLinMax    := 65

MakeDir(cPasta)

oExcel:AddworkSheet(cPlan1)
oExcel:AddTable(cPlan1,cTitulo)
oExcel:SetFontSize(12)
For nXy := 1 To Len(aCabec)
    oExcel:AddColumn(cPlan1,cTitulo, aCabec[nXy][1],1,1)
Next

If MV_PAR15 == 1 // aprovadores
   oExcel:AddworkSheet(cPlan2)
   oExcel:AddTable(cPlan2,cTitulo2)
   oExcel:SetFontSize(12)
   oExcel:AddColumn(cPlan2,cTitulo2, "Filial"     ,1,1)
   oExcel:AddColumn(cPlan2,cTitulo2, "Pedido"     ,1,1)   
   oExcel:AddColumn(cPlan2,cTitulo2, "Data Lib."  ,1,1)
   oExcel:AddColumn(cPlan2,cTitulo2, "Nivel"      ,1,1)
   oExcel:AddColumn(cPlan2,cTitulo2, "Aprovador"  ,1,1)
   oExcel:AddColumn(cPlan2,cTitulo2, "Status"     ,1,1)
   oExcel:AddColumn(cPlan2,cTitulo2, "Cod. ID Usr",1,1)
   oExcel:AddColumn(cPlan2,cTitulo2, "Observação" ,1,1)
Endif

cCabec1 := FMTCabec()

SetDefault(aReturn,cString)

DbSelectArea("QRY1")
DbGotop()

cQuebra := QRY1->( C7_FILIAL + C7_TIPO + Space(nTamTipo - Len(QRY1->C7_TIPO)) + C7_NUM)

Do While ! Eof()
   
   IF li > nLinMax
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

       If cCampo $ "C7_USER"
          Infor := Left(Capital(UsrFullName(Infor)),10)
       Endif   

       If nCol <= nLimCol
          @ li,nCol PSay Infor Picture cPicture
       Endif                      
       
       AAdd(aItemSql,Infor)              

       nCol    += (nTamCmp + nEspaco)
   Next       

   If lCsv
      Aadd(aItens,aItemSql)  
   Else
      oExcel:AddRow(cPlan1,cTitulo,aItemSql)
   Endif

   DbSelectArea("QRY1")
   DbSkip()
   
   If MV_PAR15 == 1 // imprime aprovadores
      If cQuebra <> QRY1->(C7_FILIAL + C7_TIPO + Space(nTamTipo - Len(QRY1->C7_TIPO)) + C7_NUM)
         FImpAprov( cQuebra ) // Imprime os aprovadores
         cQuebra := QRY1->(C7_FILIAL + C7_TIPO + Space(nTamTipo - Len(QRY1->C7_TIPO)) + C7_NUM)
      Endif   
   Endif
   
   li++
      
Enddo

dbSelectArea("QRY1")
dbCloseArea() 

li++
@ li,001 PSAY __PrtThinLine()
   
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

Local lLeStrCab := .f. // Imprime o cabecalho pela estrutura do arquivo
Local cCabec := " Fl     Numero DT Emissao Produto   Descrição                      Un    Quantidade      Prc Unitario         Vlr Total    "
cCabec += "Razão Social         N.Soli N.Cota Solicitante Comprador  Ctr Aprov  C.Custo   Gr.Cmp Gr.Apr"

If lLeStrCab
   cCabec := " "
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

       cCabec   += IIf(nCol <= nlimCol , SubStr(aCabec[nX][1] + Space(nTamCmp),1,(nTamCmp)) + Space(nEspaco) ,"") 
       nCol     += (nTamCmp + nEspaco)
   Next       
Endif

Return(cCabec)





//-------------------------------------------------------------------
/*/{Protheus.doc} FImpAprov

@protected
@author    Rodrigo Carvalho
@since     24/03/2015
@obs       Imprime a lista de aprovadores

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/                
//------------------------------------------------------------------- 
Static Function FImpAprov(cChave)

Local cStatus    := "Aguardando Lib."
Local cAprovador := ""

DbSelectArea("SCR")
DbSetOrder(1) // CR_FILIAL + CR_TIPO + CR_NUM + CR_NIVEL 

If ! DbSeek( cChave , .T.)  
   Return .T.
Endif   
       
li += 2   
@ li,001 Psay "Data Lib.  Nv  Aprovador           Status          Id/Org Observação"
li++
@ li,001 Psay Replicate("=",90) 

Do While !Eof() .And. SCR->(CR_FILIAL + Rtrim(CR_TIPO) + Rtrim(CR_NUM)) == cChave
   
   cAprovador := Left(Capital(UsrFullName( IIf(Empty(SCR->CR_DATALIB),SCR->CR_APROV,SCR->CR_USERLIB)  )) + Space(20),20)
   cAprovador := Left(IIf(Empty(cAprovador),IIf(Empty(SCR->CR_DATALIB),SCR->CR_APROV,SCR->CR_USERLIB),cAprovador) + Replicate(" ",20),20)

   Do Case
		Case SCR->CR_STATUS == "03" //Liberado
			 cStatus := "Liberado       " 
		Case SCR->CR_STATUS == "04" //Bloqueado
			 cStatus := "Bloqueado      "
		Case SCR->CR_STATUS == "05" //Nivel Liberado
			 cStatus := "Nivel Liberado "
		OtherWise                 //Aguar.Lib
			 cStatus := "Aguardando Lib."
   EndCase 
   li++
   IF li > nLinMax
      cabec(cTitulo,cCabec1,"",cPerg,cTamanho,nTipo)
   EndIF

   @ li,001 Psay SCR->(DtoC(CR_DATALIB)+ " " + CR_NIVEL + " " + cAprovador + " " + cStatus +" "+ CR_USERORI + " " +CR_OBS)
   aItemApr := {}   

   AAdd(aItemApr,CR_FILIAL)   
   AAdd(aItemApr,Rtrim(CR_NUM))      
   AAdd(aItemApr,IIf(Empty(CR_DATALIB),"",DtoC(CR_DATALIB)))
   AAdd(aItemApr,CR_NIVEL)   
   AAdd(aItemApr,cAprovador)   
   AAdd(aItemApr,cStatus)   
   AAdd(aItemApr,CR_USERORI)            
   AAdd(aItemApr,CR_OBS)               
          
   oExcel:AddRow(cPlan2,cTitulo2,aItemApr)
            
   dbSelectArea("SCR")
   dbSkip()
Enddo

li += 3

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

cQuery := "SELECT * "+ CRLF  
cQuery += "  FROM (SELECT C7_FILIAL," + CRLF
cQuery += "               C7_NUM,"    + CRLF
cQuery += "               C7_EMISSAO,"+ CRLF
cQuery += "               C7_PRODUTO,"+ CRLF
cQuery += "               C7_DESCRI," + CRLF
cQuery += "               C7_UM,"     + CRLF
cQuery += "               C7_QUANT,"  + CRLF
cQuery += "               C7_PRECO,"  + CRLF
cQuery += "               C7_TOTAL,"  + CRLF
cQuery += "          LEFT(A2_NOME,20) A2_NOME,"+ CRLF
cQuery += "        ISNULL(C1_NUM,' ') C1_NUM,"        + CRLF
cQuery += "               C7_NUMCOT," + CRLF
cQuery += "   LEFT(ISNULL(C1_SOLICIT,' '),11) C1_SOLICIT,"+ CRLF
cQuery += "               C7_USER,"   + CRLF // comprador
cQuery += "    (CASE WHEN C7_CONAPRO = 'B' THEN 'Bloqueado' WHEN C7_CONAPRO = 'L' THEN 'Liberado' ELSE C7_CONAPRO END) C7_CONAPRO,"+ CRLF
cQuery += "               C7_CC,"     + CRLF
cQuery += "               C7_GRUPCOM,"+ CRLF
cQuery += "               C7_APROV,"  + CRLF
cQuery += "    (CASE WHEN C7_TIPO = 1 THEN 'PC' WHEN C7_TIPO = 2 THEN 'AE' END) C7_TIPO,"+ CRLF
cQuery += "               C7_ITEM,"   + CRLF
cQuery += "               C7_DATPRF," + CRLF
cQuery += "               C7_VLDESC," + CRLF
cQuery += "        ISNULL(C1_OBS,' ') C1_OBS,"    + CRLF
cQuery += "               C7_OBS,"    + CRLF
cQuery += "               C7_COND,"   + CRLF
cQuery += "               C7_FORNECE,"+ CRLF
cQuery += "               C7_LOJA"    + CRLF
cQuery += "          FROM "+RetSqlName("SC7")+" C7"+ CRLF
cQuery += "          LEFT OUTER JOIN "+RetSqlName("SC1")+" C1"+ CRLF
cQuery += "            ON C1_FILIAL  = C7_FILIAL " + CRLF
cQuery += "           AND C1_NUM     = C7_NUMSC"  + CRLF
cQuery += "           AND C1_ITEM    = C7_ITEMSC" + CRLF
cQuery += "           AND C1_PRODUTO = C7_PRODUTO"+ CRLF
cQuery += "           AND C1.D_E_L_E_T_ <> '*'"+ CRLF
cQuery += "          LEFT OUTER JOIN "+RetSqlName("SA2")+" A2"+ CRLF
cQuery += "            ON A2_FILIAL  = '"+xFilial("SA2")+"'" + CRLF
cQuery += "           AND A2_COD     = C7_FORNECE"+ CRLF
cQuery += "           AND A2_LOJA    = C7_LOJA"   + CRLF
cQuery += "           AND A2.D_E_L_E_T_ <> '*'"+ CRLF
cQuery += "         WHERE C7.D_E_L_E_T_ <> '*'"+ CRLF
cQuery += "           AND C7_FILIAL  BETWEEN '"+     MV_PAR01 +"' AND '" +      MV_PAR02 + "'" + CRLF
cQuery += "           AND C7_EMISSAO BETWEEN '"+DtoS(MV_PAR03)+"' AND '" + DtoS(MV_PAR04)+ "'" + CRLF
cQuery += "           AND C7_NUM     BETWEEN '"+     MV_PAR05 +"' AND '" +      MV_PAR06 + "'" + CRLF 
cQuery += "           AND C7_USER    BETWEEN '"+     MV_PAR07 +"' AND '" +      MV_PAR08 + "'" + CRLF // comprador
cQuery += "           AND C7_APROV   BETWEEN '"+     MV_PAR09 +"' AND '" +      MV_PAR10 + "'" + CRLF // grupo de aprovacao.
cQuery += "           ) PEDIDOS"+ CRLF
If lCtrAprov 
   cQuery += " WHERE EXISTS (SELECT *"+ CRLF
   cQuery += "          FROM "+RetSqlName("SCR")+" CR" + CRLF
   cQuery += "         WHERE CR_FILIAL     = C7_FILIAL"+ CRLF
   cQuery += "           AND RTRIM(CR_NUM) = C7_NUM"   + CRLF
   cQuery += "           AND CR_TIPO LIKE C7_TIPO+'%'" + CRLF
   cQuery += "           AND CR.D_E_L_E_T_ <> '*'"     + CRLF
   cQuery += "           AND CR_LIBAPRO BETWEEN '"+     MV_PAR11 +"' AND '"+     MV_PAR12 +"'" + CRLF 
   cQuery += "           AND CR_DATALIB BETWEEN '"+DtoS(MV_PAR13)+"' AND '"+DtoS(MV_PAR14)+"')"+ CRLF
   If Empty(MV_PAR13) .And. Empty(MV_PAR14)
      cQuery += "           AND Left(C7_CONAPRO,1) = 'B'" + CRLF
   Endif
Endif
cQuery += " ORDER BY C7_FILIAL,C7_NUM,C7_ITEM"+ CRLF

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
	  
 	  If cCampo == "C7_USER"
	     aCabec[Len( aCabec )][1] := "Comprador" 
	     aCabec[Len( aCabec )][3] := 10
	  Endif
 	  If cCampo == "C1_SOLICIT"
	     aCabec[Len( aCabec )][1] := "Solicitante"  
	     aCabec[Len( aCabec )][3] := 11
	  Endif
 	  If cCampo == "C7_PRODUTO"
	     aCabec[Len( aCabec )][1] := "Produto   "      
	     aCabec[Len( aCabec )][3] := 10
        aCabec[Len( aCabec )][5] := Replicate("!",10)
	  Endif      
 	  If cCampo == "C7_DESCRI"
	     aCabec[Len( aCabec )][1] := "Descrição do Produto"      
	     aCabec[Len( aCabec )][3] := 30
        aCabec[Len( aCabec )][5] := Replicate("!",30)
	  Endif      
 	  If cCampo == "A2_NOME"
	     aCabec[Len( aCabec )][3] := 20
	  Endif
 	  If cCampo == "C7_CONAPRO"
	     aCabec[Len( aCabec )][3] := 10 
	  Endif
   
   Next nX 

Else
   dbSelectArea("QRY1")
   dbCloseArea() 
   lRetQry := .F.
   Aviso("ATENÇÃO","Não há ocorrencias com essa seleção!",{"Ok"}) 
Endif
                      
Return( lRetQry )