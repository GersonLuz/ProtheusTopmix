#Include "RwMake.ch" 
#Include "TopConn.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} MCLOTCT2
Relatorio de Diferenças entre os lotes contabilizados na tabela CT2.

@protected
@author    Rodrigo Artur de Carvalho
@since     26/02/2014
@obs       Será criada uma view para o MSSQL 

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//------------------------------------------------------------------- 

User Function MCLOTCT2()
**********************************************************************************************************************************
* Relatorio de conferencia de lotes CT2
****
Private aPerg     := {}
Private cPerg     := PADR("MCLOTECT2",10)

Private nLastKey  := 0
Private nLinha    := 0
Private nPag      := 0
Private WnRel     := PADR("MCLOTECT2",10)
Private aReturn   := { OemToAnsi("Zebrado"), 1,OemToAnsi("Administracao"), 4, 2, 1, "",1 }
Private cString   := "CT2"
Private cTitulo   := OemToAnsi("Conferencia de lote das contabilizações")
Private cDesc1    := OemToAnsi("")
Private cDesc2    := OemToAnsi("")
Private cDesc3    := OemToAnsi("")
Private cTamanho  := "P"
Private cNomeView := "LOTESCT2_" + Alltrim(SM0->M0_CODFIL)  +"_" +Alltrim(RetCodUsr())

Private cFilialI  := ""
Private cFilialF  := ""
Private dDataI    := Ctod("")
Private dDataF    := Ctod("")
Private cLoteI    := ""
Private cLoteF    := ""
Private cDocI     := ""
Private cDocF     := ""
Private cMoeda    := ""
Private cTpSaldo  := ""
Private nQtdeRegi := 0

aAdd(aPerg,{cPerg,"Filial Inicial      ","C",06,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Filial Final        ","C",06,0,"G","","","","","","",""})
Aadd(aPerg,{cPerg,"Data Inicial        ","D",08,0,"G","","","","","","",""})
Aadd(aPerg,{cPerg,"Data Final          ","D",08,0,"G","","","","","","",""})
Aadd(aPerg,{cPerg,"Lote Inicial        ","C",06,0,"G","","","","","","",""})
Aadd(aPerg,{cPerg,"Lote Final          ","C",06,0,"G","","","","","","",""})
Aadd(aPerg,{cPerg,"Documento Inicial   ","C",06,0,"G","","","","","","",""})
Aadd(aPerg,{cPerg,"Documento Final     ","C",06,0,"G","","","","","","",""})
Aadd(aPerg,{cPerg,"Moeda      (* Todas)","C",02,0,"G","","","","","","",""})
Aadd(aPerg,{cPerg,"Tipo Saldo (* Todos)","C",01,0,"G","","","","","","",""})
Aadd(aPerg,{cPerg,"Tipo de Impressão   ","N",01,00,"C","","","Diferenças","Seleção Acima","",""})

U_TestaSX1(cPerg,aPerg)

Pergunte(cPerg,.F.)

wnrel   := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,cTamanho)

cFilialI  := MV_PAR01
cFilialF  := MV_PAR02
dDataI    := MV_PAR03
dDataF    := MV_PAR04
cLoteI    := MV_PAR05
cLoteF    := MV_PAR06
cDocI     := MV_PAR07
cDocF     := MV_PAR08
cMoeda    := MV_PAR09
cTpSaldo  := MV_PAR10
nTpImpr   := MV_PAR11

If (nLastKey == 27)
   MsgBox("O Relatorio foi CANCELADO!","Atenção","INFO")//STOP/INFO/ALERT/YESNO/RETRYCANCEL	
   Return
EndIf

MsgRun("Aguarde... Pesquisando dados.. ",,{|| CursorWait(), FQueryCT2() ,CursorArrow()})                    

If nQtdeRegi == 0
   DbSelectArea("LOTESCT2")
   DbCloseArea() 
	MsgBox("Não foram encontrados ocorrências com essa seleção!", "Top Mix", "INFO")   
   Return .t.
Endif
SetDefault(aReturn,cString)

FImpCab()

DbSelectArea("LOTESCT2")
DbGoTop()
Do While ! Eof()
   If nLinha >= 58                                                                                              
      eject
      FImpCab()
   EndIf
   
   @ nLinha,001 PSay Stod(LOTESCT2->CT2_DATA)
   @ nLinha,015 PSay LOTESCT2->CT2_LOTE   Picture "@!"
   @ nLinha,025 PSay LOTESCT2->CT2_DOC    Picture "@!"
   @ nLinha,040 PSay LOTESCT2->CT2_TPSALD Picture "@!"
   @ nLinha,054 PSay LOTESCT2->CT2_MOEDLC Picture "@!"
   @ nLinha,070 PSay LOTESCT2->VRDEBITO   Picture "99,999,999.99"
   @ nLinha,085 PSay LOTESCT2->VRCREDITO  Picture "99,999,999.99"
   
   nLinha++
   
   DbSelectArea("LOTESCT2")
   DbSkip()
   
Enddo

@ nLinha,001 PSAY __PrtThinLine()
nLinha++

DbSelectArea("LOTESCT2")
dbCloseArea()

Set Device To Screen
Set Filter To
SetPgEject(.F.)
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
EndIf
MS_FLUSH()                                                                                                               
Return .t.




Static Function FImpCab()
**********************************************************************************************************************************
*//Cabeçalho
****                     
SetPrc(0,0)	
@ PRow(),PCol() PSAY CHR(15)
nPag++	
@ 001,001 PSAY __PrtThinLine()
@ 002,001 PSAY Alltrim(SM0->M0_NOMECOM)+" - "+Alltrim(SM0->M0_FILIAL)
@ 002,137 PSAY "Pagina: " + AllTrim(Str(nPag))
@ 003,001 PSAY "Relatorio de diferenças entre os lotes contabilizados"
@ 003,137 PSAY "Emissao: " + dToc(Date()) 
@ 004,001 PSAY __PrtThinLine()
@ 005,001 PSAY " DATA          LOTE     DOCUMENTO    TIPO SALDO   MOEDA LC.          VALOR DEBITO     VALOR CREDITO"
@ 006,001 PSAY __PrtThinLine()
nLinha := 7
Return



Static Function FQueryCT2()
**********************************************************************************************************************************
*//Cabeçalho
****                     
Local   cCrlf     := Chr(13)+Chr(10)
Local   cQuery    := ""

cQuery := "if exists (select * from sysobjects where name = '" +cNomeView+ "' and xtype = 'V') drop view dbo." +cNomeView
TCSQLExec(cQuery)

cQuery := "CREATE VIEW "+cNomeView+" AS "+ cCrlf 
cQuery += "SELECT CT2_DATA, CT2_LOTE, CT2_DOC, CT2_TPSALD , CT2_MOEDLC , SUM(CT2_VALOR) AS VRDEBITO, 0 AS VRCREDITO "+ cCrlf 
cQuery += "  FROM "+RetSqlName("CT2") + cCrlf 
cQuery += " WHERE D_E_L_E_T_ <> '*'"  + cCrlf 
cQuery += "   AND CT2_FILIAL >= '"+ cFilialI     +"' AND CT2_FILIAL <= '"+ cFilialF     + "'" + cCrlf 
cQuery += "   AND CT2_LOTE   >= '"+ cLoteI       +"' AND CT2_LOTE   <= '"+ cLoteF       + "'" + cCrlf 
cQuery += "   AND CT2_DOC    >= '"+ cDocI        +"' AND CT2_LOTE   <= '"+ cDocF        + "'" + cCrlf 
cQuery += "   AND CT2_DATA   >= '"+ DtoS(dDataI) +"' AND CT2_DATA   <= '"+ DtoS(dDataF) + "'" + cCrlf 
cQuery += "   AND CT2_DEBITO <> ' '" + cCrlf 
cQuery += IIf( Empty(cTpSaldo) .Or. "*" $ cTpSaldo,""," AND CT2_TPSALD = '"+cTpSaldo+"'"+ cCrlf )
cQuery += IIf( Empty(cMoeda)   .Or. "*" $ cMoeda  ,""," AND CT2_MOEDLC = '"+cMoeda+"'"  + cCrlf )
cQuery += " GROUP BY CT2_DATA, CT2_LOTE, CT2_DOC,CT2_TPSALD,CT2_MOEDLC"+ cCrlf 
cQuery += "UNION ALL"+ cCrlf 
cQuery += "SELECT CT2_DATA, CT2_LOTE, CT2_DOC, CT2_TPSALD , CT2_MOEDLC , 0 AS VRDEBITO, SUM(CT2_VALOR * -1) AS VRCREDITO "+ cCrlf 
cQuery += "  FROM "+RetSqlName("CT2") + cCrlf 
cQuery += " WHERE D_E_L_E_T_ <> '*'"  + cCrlf 
cQuery += "   AND CT2_FILIAL >= '"+ cFilialI     +"' AND CT2_FILIAL <= '"+ cFilialF     + "'" + cCrlf 
cQuery += "   AND CT2_LOTE   >= '"+ cLoteI       +"' AND CT2_LOTE   <= '"+ cLoteF       + "'" + cCrlf 
cQuery += "   AND CT2_DOC    >= '"+ cDocI        +"' AND CT2_LOTE   <= '"+ cDocF        + "'" + cCrlf 
cQuery += "   AND CT2_DATA   >= '"+ DtoS(dDataI) +"' AND CT2_DATA   <= '"+ DtoS(dDataF) + "'" + cCrlf 
cQuery += "   AND CT2_CREDIT <> ' '" + cCrlf 
cQuery += IIf( Empty(cTpSaldo) .Or. "*" $ cTpSaldo,""," AND CT2_TPSALD = '"+cTpSaldo+"'"+ cCrlf )
cQuery += IIf( Empty(cMoeda)   .Or. "*" $ cMoeda  ,""," AND CT2_MOEDLC = '"+cMoeda+"'"  + cCrlf )
cQuery += " GROUP BY CT2_DATA, CT2_LOTE, CT2_DOC,CT2_TPSALD,CT2_MOEDLC"+ cCrlf 
TCSQLExec(cQuery)

cQuery := "SELECT CT2_DATA,CT2_LOTE,CT2_DOC,CT2_TPSALD,CT2_MOEDLC, ROUND(SUM(VRDEBITO),2) AS VRDEBITO ,ROUND(SUM(VRCREDITO),2) AS VRCREDITO "+ cCrlf 
cQuery += "FROM "+cNomeView + cCrlf 
cQuery += " GROUP BY CT2_DATA,CT2_LOTE,CT2_DOC,CT2_TPSALD,CT2_MOEDLC"+ cCrlf 
cQuery += IIf(nTpImpr == 1 , " HAVING ROUND(SUM(VRDEBITO),2) - ABS(ROUND(SUM(VRCREDITO),2)) <> 0 "+ cCrlf ,"")
cQuery += " ORDER BY CT2_DATA,CT2_LOTE,CT2_DOC,CT2_TPSALD,CT2_MOEDLC"+ cCrlf 
TCQUERY cQuery NEW ALIAS "LOTESCT2"
 
dbSelectArea("LOTESCT2")
LOTESCT2->(dbGoTop())
LOTESCT2->(dbEval({|| nQtdeRegi ++ },,{|| ! LOTESCT2->(Eof())}))
LOTESCT2->(dbGoTop())
Return .t.