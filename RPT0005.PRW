#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"

/*
+----------+-----------+----------+-------------------------+------+-----------+
|Programa  | RPT0005   | Autor    | Max Rocha               |Data  |02.07.2012 |
+----------+-----------+----------+-------------------------+------+-----------+
|Descricao | Relatório Notas Fiscais com Abatimento                            |
+----------+-------------------------------------------------------------------+
| USO      | Exclusivo da TOPMIX                                               |
+----------+-------------------------------------------------------------------+
|Autor     | Data      | Descricao                                             |
+----------+-----------+-------------------------------------------------------+
|          |           |                                                       |
+----------+-----------+-------------------------------------------------------+
*/

User Function RPT005()
****************************************************************************************
* Monta Tela Padrão de Impressões
*
*****

//Define Variaveis                                                        
Local cTitulo := "Relatório Notas Fiscais x Abatimento"
Local cDesc1  := OemToAnsi("Ser  impresso de acordo com os parametros solicitados pelo")
Local cDesc2  := OemToAnsi("usuario.") 
Local cDesc3  := OemToAnsi("") 
Local cString := "SF2"  	// Alias utilizado na Filtragem
Local lDic    := .F. 		// Habilita/Desabilita Dicionario
Local lComp   := .T. 		// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro := .F. 		// Habilita/Desabilita o Filtro
Local wnrel   := "RPT0005"  // Nome do Arquivo utilizado no Spool
Local nomeprog:= "RPT0005" // Nome do programa
Local aPerg   := {}			// Array contendo as Variaveis do Dicionario de Perguntas

Private Tamanho := "M" 		// P/M/G
Private Limite  := 132 		// 80/132/220
Private aOrdem  := {}  		// Ordem do Relatorio
Private cPerg   := "RPT005"	// Pergunta do Relatorio
Private aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
						//[1] Reservado para Formulario
						//[2] Reservado para N§ de Vias
						//[3] Destinatario
						//[4] Formato => 1-Comprimido 2-Normal
						//[5] Midia   => 1-Disco 2-Impressora
						//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
						//[7] Expressao do Filtro
						//[8] Ordem a ser selecionada
						//[9]..[10]..[n] Campos a Processar (se houver)
Private lEnd    := .F.// Controle de cancelamento do relatorio
Private m_pag   := 1  // Contador de Paginas
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault

// Variaveis de Controle do Relatório
aAdd(aPerg,{cPerg,"Data Inicial     ?","D",08,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Data Final       ?","D",08,0,"G","","","","","","",""})
//aAdd(aPerg,{cPerg,"Municipio Inicial?","C",06,0,"G","","CC2","","","","",""})
//aAdd(aPerg,{cPerg,"Municipio Final  ?","C",06,0,"G","","CC2","","","","",""})
aAdd(aPerg,{cPerg,"Nota Inicial     ?","C",09,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Nota Final       ?","C",09,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Serie Inicial     ?","C",03,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Serie Final       ?","C",03,0,"G","","","","","","",""})



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

RptStatus({|lEnd| MontaTab()},"Montando Tabelas Temporárias")
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
Local cQuery 	:= ""
Local dDeData   := CToD("")
Local dAteData  := CToD("")             
Local cNotaIni := ""
Local cNotaFin := ""
Local cSerIni  := ""
Local cSerFin  := ""

// Recebe Parametros
dDtIni   := mv_par01                                      
dDtFin   := mv_par02
cNotaIni := mv_par03
cNotaFin := mv_par04
cSerIni  := mv_par05
cSerFin  := mv_par06                    

cQuery := " SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, SUM(D2_TOTAL) AS D2_TOTAL,  SUM(C6_ABATMAT) AS C6_ABATMAT,  SUM(C6_ABTMAT2) AS C6_ABTMAT2 "
cQuery += " FROM "+ RetSqlName("SF2") + " JOIN "+ RetSqlName("SD2") + " ON (F2_FILIAL=D2_FILIAL AND F2_DOC=D2_DOC AND F2_SERIE=D2_SERIE ) "
cQuery += " 										JOIN "+ RetSqlName("SC6") + " ON (D2_FILIAL=C6_FILIAL AND D2_PEDIDO=C6_NUM  AND D2_COD=C6_PRODUTO) "
cQuery += " WHERE F2_FILIAL='" + cFilAnt +"' AND " + RetSqlName("SF2")+".D_E_L_E_T_ <> '*' AND  " + RetSqlName("SD2")+".D_E_L_E_T_ <> '*' AND " +RetSqlName("SC6")+".D_E_L_E_T_ <> '*' "
cQuery += "      AND F2_EMISSAO BETWEEN '" + dtos(dDtIni) + "' AND '" + dtos(dDtFin) + "' "
cQuery += "      AND RTRIM(F2_DOC)   between '"+cNotaIni+"' AND '"+cNotaFin+"'  "
cQuery += "      AND RTRIM(F2_SERIE) between '"+cSerIni +"' AND '"+cSerFin +"'  "
cQuery += " GROUP BY F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO "
cQuery += " ORDER BY F2_FILIAL, F2_DOC, F2_SERIE "


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
Local cbText  	:= "Dpto. Tecnologia da Informação - Topmix"  // Mensagem do Rodape
Local cCabec1 	:= ""	// Cabeçalho 1
Local cCabec2 	:= ""	// Cabeçalho 2
Local nComp		:= If(aReturn[4]==1,15,18)	// Condensado ou Normal
Local cTipoNF	:= "" 	// Topo da NF


Local nTotVal  := 0
Local nTotAbat := 0 
Local nTotAbt2 := 0


cCabec1 := "Emissao     Número/Ser NF  Cliente   Razao                                          Total  Abatimento  Abatimento2"              
/*
Emissao     Número/Ser NF  Cliente   Razao                                          Total  Abatimento  Abatimento2              
99/99/9999  999999999/111  999999/99 1234567890123456789012345678901234567890  999,999.99  999,999.99   999,999.99              
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
          1         2         3         4         5         6         7         8         9        10        11        12        13
*/

DbSelectArea("TMP1")
dbGoTop()
	
While !Eof()
		lImp := .T.
	
		If LastKey() = 286
			lEnd := .T.
		EndIf
		
		If lEnd
			@ Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
			Exit
		EndIf
		
		If ( nLi > 60 )
			nLi := Cabec(cTitulo,cCabec1,"","",Tamanho,nComp)
			nLi++
		Endif
/*
Emissao     Número/Ser NF  Cliente   Razao                                          Total  Abatimento  Abatimento2              
99/99/9999  999999999/111  999999/99 1234567890123456789012345678901234567890  999,999.99  999,999.99   999,999.99              
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
          1         2         3         4         5         6         7         8         9        10        11        12        13
*/

		@ nLi, 000 PSay StoD(TMP1->F2_EMISSAO)
		@ nLi, 012 PSay StrZero(Val(TMP1->F2_DOC),9,0)+'/'+Left(TMP1->F2_SERIE,3)
		@ nLi, 027 PSay Left(TMP1->F2_CLIENTE,6)+'/'+Left(TMP1->F2_LOJA,2) 
		@ nLi, 037 Psay Left(Posicione("SA1",1,xfilial("SA1")+TMP1->F2_CLIENTE+TMP1->F2_LOJA,"A1_NOME"),40)

		@ nLi, 079 PSay TMP1->D2_TOTAL    Picture "@E 999,999.99"
		@ nLi, 091 PSay TMP1->C6_ABATMAT  Picture "@E 999,999.99"
		@ nLi, 104 PSay TMP1->C6_ABTMAT2  Picture "@E 999,999.99"

		// Soma Totais 
		nTotVal  += TMP1->D2_TOTAL  
		nTotAbat += TMP1->C6_ABATMAT
		nTotAbt2 += TMP1->C6_ABTMAT2
      nLi++
        
	   dbSelectArea("TMP1")
		DbSkip()			

End
nLi++
// Total Geral
@ nli, 000 Psay "                                                                            -------------------------------------------------------"
nLi++
@ nLi, 000 PSay "Totais.................: "    
@ nLi, 079 PSay nTotVal	   Picture "@E 999,999.99"
@ nLi, 091 PSay nTotAbat	Picture "@E 999,999.99"
@ nLi, 104 PSay nTotAbt2	Picture "@E 999,999.99"

		
If (lImp)
	Roda(cbCont,cbText,Tamanho)
EndIf

If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()


Return()