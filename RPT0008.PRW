#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"

User Function rpt008()
****************************************************************************************
* Monta Tela Padrão de Impressões
*
*****

//Define Variaveis                                                        
Local cTitulo := "Balancete Topmix - Modelo 1 - por  Filial Origem"
Local cDesc1  := OemToAnsi("Ser  impresso de acordo com os parametros solicitados pelo")
Local cDesc2  := OemToAnsi("usuario.") 
Local cDesc3  := OemToAnsi("") 
Local cString := ""  	// Alias utilizado na Filtragem
Local lDic    := .F. 		// Habilita/Desabilita Dicionario
Local lComp   := .T. 		// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro := .F. 		// Habilita/Desabilita o Filtro
Local wnrel   := "rpt008"  // Nome do Arquivo utilizado no Spool
Local nomeprog:= "rpt008" // Nome do programa
Local aPerg   := {}			// Array contendo as Variaveis do Dicionario de Perguntas

Private Tamanho := "P" 		// P/M/G
Private Limite  := 80  		// 80/132/220
Private aOrdem  := {}  		// Ordem do Relatorio
Private cPerg   := "rpt008"	// Pergunta do Relatorio
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
						//[1] Reservado para Formulario
						//[2] Reservado para N§ de Vias
						//[3] Destinatario
						//[4] Formato => 1-Comprimido 2-Normal
						//[5] Midia   => 1-Disco 2-Impressora
						//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
						//[7] Expressao do Filtro
						//[8] Ordem a ser selecionada
						//[9]..[10]..[n] Campos a Processar (se houver)
Private lEnd    := .F. // Controle de cancelamento do relatorio
Private m_pag   := 1   // Contador de Paginas
Private nLastKey:= 0   // Controla o cancelamento da SetPrint e SetDefault

// Variaveis de Controle do Relatório
aAdd(aPerg,{cPerg,"Período Ini      ?","D",08,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Período Fin      ?","D",08,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Conta   Ini      ?","C",20,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Conta   Fin      ?","C",20,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Fil.Origem Ini   ?","C",06,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Fil.Origem Fin   ?","C",06,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Sinteticas (S/N) ?","C",01,0,"G","","","","","","",""})

U_TestaSX1(cPerg,aPerg)

// Verifica as Perguntas Seleciondas
Pergunte(cPerg,.F.)

//Envia para a SetPrinter                                                 
wnrel:=SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)

If ( nLastKey==27 )
	Return(Nil)
Endif

SetDefault(aReturn,cString)

If ( nLastKey==27 )
	Return(Nil)
Endif

RptStatus({|lEnd| MontaTab()},"Montando Tabelas Temporarias")
RptStatus({|lEnd| ImprRel(@lEnd,wnRel,cString,nomeprog,cTitulo)},cTitulo)

// Fechar Tabelas Temporarias
	dbSelectArea("TMP1")
	dbCloseArea("TMP1")
Return(.T.)



Static Function MontaTab()
****************************************************************************************
* Monta Tabela Temporária para Impressão
*
*****

// Declaração das Variáveis
Local cQuery         := ""    
Local dDtIni         := ""
Local dDtFin         := ""             
Local cContaIni      := ""
Local cContaFin      := ""
Local cFilIni        := ""
Local cFilFin        := ""
Local cSintetica     := ""

// Recebe Parametros      
dDtIni         := mv_par01
dDtFin         := mv_par02
cContaIni      := mv_par03
cContaFin      := mv_par04
cFilIni        := mv_par05
cFilFin        := mv_par06
cSintetica     := mv_par07

cQuery := " SELECT CT2_FILIAL AS FILIAL, "
cQuery += "        RTRIM(CT2_DEBITO) AS CONTA, "
cQuery += "        CT1_DESC01 AS DESCRICAO, "
cQuery += "        SUM(CT2_VALOR) AS VALOR "
cQuery += " FROM   "+RetSqlName("CT2") +" JOIN "+RetSqlName("CT1") + " ON (RTRIM(CT1_CONTA) = RTRIM(CT2_DEBITO)) "
cQuery += " WHERE  CT2_DC IN ('1','3') AND "
cQuery += "        CT2_DATA   BETWEEN '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFin) + "' AND "
cQuery += "        CT2_FILORI BETWEEN '" + cFilIni + "' AND '" + cFilFin + "' AND "   
cQuery += "        CT2_DEBITO BETWEEN '" + cContaIni + "' AND '" + cContaFin + "' AND "
cQuery += "        CT2010.D_E_L_E_T_ <> '*' AND CT2_MOEDLC = '01' AND "
cQuery += "        CT1010.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY CT2_FILIAL, "
cQuery += "          CT1_DESC01, "
cQuery += "          RTRIM(CT2_DEBITO) "
cQuery += " UNION   "
         
//SOMENTE CREDITOS
cQuery += " SELECT CT2_FILIAL AS FILIAL, "
cQuery += "        RTRIM(CT2_CREDIT) AS CONTA,  "
cQuery += "        CT1_DESC01 AS DESCRICAO, "
cQuery += "        SUM(CT2_VALOR * -1) AS VALOR "
cQuery += " FROM    "+RetSqlName("CT2") +" JOIN "+RetSqlName("CT1") + "  ON (RTRIM(CT1_CONTA) = RTRIM(CT2_CREDIT)) "  
cQuery += " WHERE CT2_DC IN ('2','3') AND "
cQuery += "       CT2_DATA   BETWEEN '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFin) + "' AND "
cQuery += "       CT2_FILORI BETWEEN '" + cFilIni   + "' AND '" + cFilFin + "' AND "
cQuery += "       CT2_CREDIT BETWEEN '" + cContaIni + "' AND '" + cContaFin + "' AND "
cQuery += "       CT2010.D_E_L_E_T_ <> '*' AND CT2_MOEDLC = '01' AND "
cQuery += "       CT1010.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY CT2_FILIAL , "
cQuery += "          CT1_DESC01,   "
cQuery += "          RTRIM(CT2_CREDIT)"
cQuery += " ORDER BY FILIAL, CONTA "

TCQuery cQuery Alias "TMP1" New	


Return()                            



Static Function ImprRel(lEnd,wnrel,cString,nomeprog,cTitulo)
****************************************************************************************
* Imprime Relatório
*
*****

Local nLi     	:= 100 	// Contador de Linhas
Local lImp    	:= .F. 	// Indica se algo foi impresso
Local cbCont  	:= 0   	// Numero de Registros Processados
Local cbText  	:= "TOPMIX - Dpto. Tecnologia da Informação"  // Mensagem do Rodape
Local cCabec1 	:= ""	// Cabeçalho 1
Local cCabec2 	:= ""	// Cabeçalho 2
Local nComp		:= If(aReturn[4]==1,15,18)	// Condensado ou Normal
Local cTipoNF	:= "" 	// Topo da NF

Local nTotal      := 0
Local nTotalGeral := 0
Local nDebitos    := 0    
Local nCreditos   := 0
Local cImpFilial  := ""
Local cConta      := ""
Local nTotConta   := 0


cCabec1 := "Fil.Origem  Conta           Descrição                                Debito         Credito       Movimento Tp                   "
DbSelectArea("TMP1")
dbGoTop()

                                     
 DBSelectArea("SM0")
 DBSetOrder(1)
 DBSeek(cEmpAnt+TMP1->FILIAL)
			 
 nLi++              
 @ nLi, 000 PSay 'FILIAL -->> ' + TMP1->FILIAL + " - " + left(SM0->M0_FILIAL,40) +"  Período: "+DtoC(mv_par01) + " - " + DtoC(mv_par02)

 DbSelectArea("TMP1")
 dbGoTop()

cImpFilial := TMP1->FILIAL
cConta := TMP1->CONTA

While !Eof()
		lImp := .T.
	
		If LastKey() = 286
			lEnd := .T.
		EndIf
		
		If lEnd
			@ Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
			Exit
		EndIf
		
		If ( nLi > 70 )
			nLi := Cabec(cTitulo,cCabec1,"","",Tamanho,nComp)
			nLi++
		Endif
/*        
Fil.Origem  Conta           Descrição                                Debito         Credito       Movimento Tp                  
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
010106      3.1.01.01.0001  0123456789012345678901234567890  999,999,999.99  999,999,999.99  999,999,999.99 DC
                                                             =================================================
*/

      If TMP1->CONTA = cConta
  		   @ nLi, 000 PSay TMP1->FILIAL  
 		   @ nLi, 012 PSay transform(TMP1->CONTA, '@R 9.9.99.99.9999'  )
		   @ nLi, 028 PSay LEFT(TMP1->DESCRICAO, 30)
		   
         If TMP1->VALOR >= 0
  		      @ nLi, 061 PSay TMP1->VALOR picture "@E 999,999,999.99"
  		      nTotConta += TMP1->VALOR
  		      nDebitos  += TMP1->VALOR
  		      
         EndIF
      
        If TMP1->VALOR < 0
  		     @ nLi, 077 PSay TMP1->VALOR picture "@E 999,999,999.99"
  		     nTotConta += TMP1->VALOR 
		     nCreditos += TMP1->VALOR  		     
        EndIF
      EndIF                     

   	dbSkip()
      If TMP1->CONTA <> cConta
         //imprime resultado anterior                              
         @ nLi, 093 PSay nTotConta  picture "@E 999,999,999.99"
         nLi++
         nTotal      += nTotConta
         nTotalGeral += nTotConta
         cConta := TMP1->CONTA         
         nTotConta := 0
      EndIF   

      If TMP1->FILIAL <> cImpFilial
         //imprime resultado da filial
 
			 DBSelectArea("SM0")
			 DBSetOrder(1)
			 DBSeek(cEmpAnt+cImpFilial)
						 

			DbSelectArea("TMP1")
			@ nLi, 000 Psay "                                                             ================================================="
			nLi++
         @ nLi, 000 PSay "Total da Filial: " + cImpFilial + " - " + left(SM0->M0_FILIAL,25)
	      @ nLi, 061 PSay nDebitos   picture "@E 999,999,999.99"
  	      @ nLi, 077 PSay nCreditos  picture "@E 999,999,999.99"	      
         @ nli, 093 PSay nTotal     Picture "@E 999,999,999.99"


         nLi += 3
         nTotalGeral += nTotConta
         cConta := TMP1->CONTA         
         cImpFilial := TMP1->FILIAL
         nTotConta := 0
         nTotal      := 0
         nDebitos    := 0    
         nCreditos   := 0
         
      EndIF   

        
End
        
// Total Geral
nLi++
@ nLi, 070 PSay "Total Geral:"
@ nli, 093 PSay nTotalGeral    Picture "@E 999,999,999.99"


If (lImp)
	Roda(cbCont,cbText,Tamanho)
EndIf

If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return()


/*
+----------+-----------+----------+-------------------------+------+-----------+
|Programa  | RPT0008   | Autor    | Max Rocha               |Data  |16.08.2012 |
+----------+-----------+----------+-------------------------+------+-----------+
|Descricao | Balancete por Filial de Origem                                    |
+----------+-------------------------------------------------------------------+
| USO      | Exclusivo da TOPMIX                                               |
+----------+-------------------------------------------------------------------+
|Autor     | Data      | Descricao                                             |
+----------+-----------+-------------------------------------------------------+
|          |           |                                                       |
+----------+-----------+-------------------------------------------------------+
*/

