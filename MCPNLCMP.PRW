#Include "RwMake.ch"
#Include "Protheus.ch"
//-------------------------------------------------------------------
/* {Protheus.doc} MCPNLCMP() 

@protected
@author    Rodrigo Carvalho
@since     13/10/2015
@obs       Painel de compras.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function MCPNLCMP()

Local   oDlgMain
Local   lOk        := .f.

Local   aObjects   := {}
Local   aPosObj    := {}

Local   aSize      := MsAdvSize(.T.,.F.,300) //(lEnchoiceBar,lTelaPadrao,ntamanho_linhas)
Local   aInfo      := { aSize[1] , aSize[2] , aSize[3] , aSize[4] , 3 , 3}
Local   oFont      := TFont():New( "Arial",,16,,.T.,,,,.F.,.F. )
Private cPict      := "@E 9,999,999.99"
Private cFileDB01  := ""
Private aStr001    := {}
Private aBrw001    := {}
Private aAbas      := {}
Private aDados     := {}
Private aPerg      := {}
Private cPerg      := "MCPNLCMP01" 
Private dDataI     := Ctod("")
Private dDataF     := Ctod("")

aAdd(aAbas,"Posição dos Pedidos de Compra")

aAdd(aPerg,{cPerg,"Filial de ?                   ","C",06,0,"G","","SM0",""})
aAdd(aPerg,{cPerg,"Filial até ?                  ","C",06,0,"G","","SM0",""})
aAdd(aPerg,{cPerg,"Emissão de ?                  ","D",08,0,"G","","",""})
aAdd(aPerg,{cPerg,"Emissão até ?                 ","D",08,0,"G","","",""})
aAdd(aPerg,{cPerg,"Produto de ?                  ","C",15,0,"G","","SB1",""})
aAdd(aPerg,{cPerg,"Produto até ?                 ","C",15,0,"G","","SB1",""})
aAdd(aPerg,{cPerg,"Centro de Custo de ?          ","C",09,0,"G","","CTT",""})
aAdd(aPerg,{cPerg,"Centro de Custo até ?         ","C",09,0,"G","","CTT",""})
aAdd(aPerg,{cPerg,"Liberados de ?                ","D",08,0,"G","","",""})
aAdd(aPerg,{cPerg,"Liberados até ?               ","D",08,0,"G","","",""})

U_TestaSX1(cPerg,aPerg)

Pergunte(cPerg,.T.)
dDataI := MV_PAR03
dDataF := MV_PAR04

FQueryCMP()

AADD(aObjects,{100,100,.T.,.T.})  //{TamX,TamY,DimX,DimY,lDimensaoXeY}

aPosObj := MsObjSize(aInfo,aObjects)

oDlgMain := MSDialog():New(aSize[7],0,aSize[6],aSize[5],OemToAnsi("Painel de Pedidos de Compras"),,,,,,,,,.t.)
oDlgMain:lEscClose  := .F. 
oDlgMain:lMaximized := .T.

@ 010,005 FOLDER oFolder OF oDlgMain PROMPT aAbas[1] Pixel Size aPosObj[1][4]-5 , aPosObj[1][3]

DbSelectArea("DBTMP01")
DbGoTop()

oObjFld01 := BrGetDDB():New(aPosObj[1][1]+5 , aPosObj[1][2]+5 , aPosObj[1][4]-20 , aPosObj[1][3]-50  ,,,, oFolder:aDialogs[1] ,,,,,,,,,,,,.F.,"DBTMP01",.T.,,.F.,,,) 
oObjFld01:bLDblClick := {|| CursorWait() ,  U_FVPEDIDO() ,CursorArrow() }   

For nXy := 1 To Len(aBrw001)
    bColumn := &("{|| DBTMP01->"+aBrw001[nXy][1]+" }")
    nTamPix := aStr001[nXy][3] * IIf(aStr001 [nXy][2]=="D",4,4) // alterado para 4 provisorio.
    nTamPix := IIf(nTamPix <= 0,Len(aBrw001[nXy][2]),nTamPix)
    cPosInf := IIf(aStr001 [nXy][2]=="C","LEFT","RIGHT")
    oObjFld01:AddColumn(TCColumn():New( aBrw001[nXy][2] , bColumn ,aBrw001[nXy][4],,, cPosInf , nTamPix ,.F.,.F.,,,,.F.,))
Next

@ 1,1 Button "&Exporta" Size 036,16 Action Processa({||fExpExcel(aDados)})Pixel OF oDlgMain

oDlgMain:Activate(,,,.t.,,EnchoiceBar(oDlgMain,{|| Iif( lOk := .T. , oDlgMain:End() , lOk:=.F. ) } , {||oDlgMain:End()},,{}))

FLimpaTMP() // apagar as tabelas temporarias 

Return .T.




//-------------------------------------------------------------------
/* {Protheus.doc} FQueryCMP()

@protected
@author    Rodrigo Carvalho
@since     13/10/2015
@obs       Painel de compras.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function FQueryCMP()

Local cQuery := ""

cQuery := "SELECT * FROM "+CRLF
cQuery += "        (SELECT C7_FILIAL," +CRLF
cQuery += "                CAST(C7_EMISSAO AS SMALLDATETIME) C7_EMISSAO,"+CRLF
cQuery += "                C7_NUM,"    +CRLF
cQuery += "                C7_CC,"     +CRLF
cQuery += "                C7_ZAPLIC," +CRLF
cQuery += "                ROUND(SUM(C7_TOTAL),2) C7_TOTAL,"+CRLF
cQuery += "                ROUND(SUM(C7_QUJE * C7_PRECO),2) ENTREGUES,"+CRLF
cQuery += "                ROUND(ROUND(SUM(C7_TOTAL),2) -  ROUND(SUM(C7_QUJE * C7_PRECO),2),2) ABERTO,"+CRLF
cQuery += "                C7_CONAPRO,"+CRLF
cQuery += "                CAST(CR_DATALIB AS SMALLDATETIME) CR_DATALIB"+CRLF
cQuery += "           FROM "+RetSqlName("SC7")+" C7"+CRLF
cQuery += "                LEFT OUTER JOIN (SELECT CR_FILIAL," +CRLF
cQuery += "                                        CR_NUM,"    +CRLF
cQuery += "                                        CR_TOTAL,"  +CRLF
cQuery += "                                        CR_EMISSAO,"+CRLF
cQuery += "                                    MIN(CR_DATALIB) CR_DATALIB"+CRLF
cQuery += "                                  FROM "+RetSqlName("SCR")+CRLF
cQuery += "                                 WHERE CR_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"+CRLF
cQuery += "                                   AND CR_TIPO    = 'PC'" +CRLF           
If ! Empty(MV_PAR09) .Or. ! Empty(MV_PAR10)
cQuery += "                                   AND CR_DATALIB BETWEEN '"+DtoS(MV_PAR09)+"' AND '"+DtoS(MV_PAR10)+"'"+CRLF
Endif
cQuery += "                                   AND D_E_L_E_T_ <> '*'"+CRLF
cQuery += "                                 GROUP BY CR_FILIAL, CR_NUM, CR_TOTAL, CR_EMISSAO) APROVACOES "+CRLF
cQuery += "                ON CR_FILIAL = C7_FILIAL "+CRLF
cQuery += "               AND CR_NUM    = C7_NUM" +CRLF
cQuery += "         WHERE C7_FILIAL  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"+CRLF
cQuery += "           AND C7_EMISSAO BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"'"+CRLF
cQuery += "           AND C7.D_E_L_E_T_ <> '*' "  +CRLF
cQuery += "           AND C7_PRODUTO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"+CRLF
cQuery += "           AND C7_CC      BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'"+CRLF
cQuery += "         GROUP BY C7_FILIAL,C7_NUM,C7_CONAPRO,CR_DATALIB,C7_EMISSAO,C7_ZAPLIC,C7_CC) PEDCOMPRAS "+CRLF
If ! Empty(MV_PAR09) .Or. ! Empty(MV_PAR10)
cQuery += "WHERE CR_DATALIB BETWEEN '"+DtoS(MV_PAR09)+"' AND '"+DtoS(MV_PAR10)+"'"+CRLF
Endif
cQuery += "ORDER BY 1,2,3"+CRLF
                                                     
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QTMP01",.F.,.T.) 
cFileDB01 := U_TRQUERY("QTMP01","DBTMP01")   
      
DbSelectArea("DBTMP01") 
DbGoTop()
Do While ! Eof()                   
   RecLock("DBTMP01",.F.)
   If CR_DATALIB < Ctod("01/01/1990")
      Replace CR_DATALIB With Ctod("")
   Endif
   DBTMP01->(MsUnlock())
   DbSkip()
Enddo
DbGotop()

aStr001 := DbStruct() 
aBrw001 := fAtuaStrDB( aStr001 )
FLinhaTotal("DBTMP01",aStr001)

aDados := {}
aAdd(aDados,{"DBTMP01",aAbas[1],aStr001,aBrw001})

Return .t.





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
Static Function FAtuaStrDB( aStrTMP )

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
    
    IF aStrTMP[nXy,1] == "XXX"  
       aBrwTmp[Len(aBrwTmp)][2] := "A Vencer" // customizado
       aBrwTmp[Len(aBrwTmp)][3] := "A Vencer" // customizado
    Endif

Next    

Return(aBrwTmp)




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

Return .T.




//-------------------------------------------------------------------
/* {Protheus.doc} FEXPEXCEL()

@protected
@author    Rodrigo Carvalho
@since     13/10/2015
@obs       Exportar para excel.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
Static Function fExpExcel(aDados)

Local   oExcel     := FWMSEXCEL():New()
Local   cPlan	    := "Pedidos"
Local   cTitulo	 := "Posição dos Pedidos de Compras Emissão de: "+DtoC(dDataI)+" até "+DtoC(dDataF)
Local   cPasta     := "C:\Relatorios_Protheus\"
Local   cArquivo   := "PedidoCompras_"+DtoS(dDataI)+"_"+DtoS(dDataF)+"_Em_"+DtoS(date())+".XML"
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






//-------------------------------------------------------------------
/* {Protheus.doc} FVPedido()

@protected
@author    Rodrigo Carvalho
@since     13/10/2015
@obs       Consulta pedido de compra.

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function FVPedido()

Local    aArea     := GetArea()

Local aFixe        := {{"Numero do PC","C7_NUM"},{"Emissão","C7_EMISSAO"},{"Fornecedor","C7_FORNECE"}} 
Local aGrupo 	    := {}
Local aCores       := {}
Local aCoresUsr    := {}
Local cFiltro	    := ""
Local cFilQuery	 := ""  
Local cMt120Fil    := ""
Local nOrderSC7    := 0
Local nPos		    := 0
Local nX    	    := 0
Local bBlock                                         
Local uMt120Dft   
Local cFilOld 

PRIVATE aBackSC7   := {}
PRIVATE aRatCTBPC  := {}
PRIVATE aAdtPC     := {}
PRIVATE aRatProj   := {}

PRIVATE nAutoAdt   := 0
PRIVATE nTipoPed   := 1
PRIVATE cCadastro  := "Pedidos de Compra"
PRIVATE l120Auto   := .f.
PRIVATE lPedido    := .T.
PRIVATE lGatilha   := .T.                          
PRIVATE lVldHead   := GetNewPar( "MV_VLDHEAD",.T. )
PRIVATE nFAltRat	 := 0
PRIVATE nFAltRat2	 := 0 
Private aRotina    := {}

LIntGC     := .F.
lWhenGet   := .F.
l120Inclui := .F.
aAutoCab   := {}
INCLUI     := .F.

If Empty(DBTMP01->C7_NUM)
   Return .T.
Endif   

aAdd(aRotina,{"Pesquisar","PesqBrw"    , 0, 1, 0, .F. }) //"Pesquisar"
aAdd(aRotina,{"Visualizar","A120Pedido", 0, 2, 0, Nil }) //"Visualizar"
                  
DbSelectArea("SC7")
DbSetOrder(1)

If DbSeek( DBTMP01->(C7_FILIAL + C7_NUM) )
   cFilOld := cFilAnt
   cFilAnt := SC7->C7_FILIAL
   A120Pedido( Alias() , SC7->(Recno()) , 2 , "" , .f. , lWhenGet , {} )
   cFilAnt := cFilOld
Endif

RestArea(aArea)        
DbSelectArea("DBTMP01")

Return .t.