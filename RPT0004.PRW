#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"

/*
+----------+-----------+----------+-------------------------+------+-----------+
|Programa  | RPT0004   | Autor    | Max Rocha               |Data  |15.05.2012 |
+----------+-----------+----------+-------------------------+------+-----------+
|Descricao | Relatório Notas Fiscais Canceladas                                |
+----------+-------------------------------------------------------------------+
| USO      | Exclusivo da TOPMIX                                               |
+----------+-------------------------------------------------------------------+
|Autor     | Data      | Descricao                                             |
+----------+-----------+-------------------------------------------------------+
|          |           |                                                       |
+----------+-----------+-------------------------------------------------------+
*/

User Function RPT004()
****************************************************************************************
* Monta Tela Padrão de Impressões
*
*****

//Define Variaveis                                                        
Local cTitulo := "Relatório Notas Fiscais Canceladas"
Local cDesc1  := OemToAnsi("Ser  impresso de acordo com os parametros solicitados pelo")
Local cDesc2  := OemToAnsi("usuario.") 
Local cDesc3  := OemToAnsi("") 
Local cString := "SF3"  	// Alias utilizado na Filtragem
Local lDic    := .F. 		// Habilita/Desabilita Dicionario
Local lComp   := .T. 		// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro := .F. 		// Habilita/Desabilita o Filtro
Local wnrel   := "RPT0004"  // Nome do Arquivo utilizado no Spool
Local nomeprog:= "RPT0004" // Nome do programa
Local aPerg   := {}			// Array contendo as Variaveis do Dicionario de Perguntas

Private Tamanho := "M" 		// P/M/G
Private Limite  := 132 		// 80/132/220
Private aOrdem  := {}  		// Ordem do Relatorio
Private cPerg   := "RPT004"	// Pergunta do Relatorio
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
aAdd(aPerg,{cPerg,"Cliente Inicial 	?","C",06,0,"G","","SA1","","","","",""})
aAdd(aPerg,{cPerg,"Loja Inicial    	?","C",02,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Cliente Final   	?","C",06,0,"G","","SA1","","","","",""})
aAdd(aPerg,{cPerg,"Loja Final    	?","C",02,0,"G","","","","","","",""})

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

// Recebe Parametros
dDtIni   := mv_par01                                      
dDtFin   := mv_par02
cCliIni  := mv_par03
cLojaIni := mv_par04
cCliFin  := mv_par05
cLojaFin := mv_par06

cQuery := " SELECT F3_EMISSAO, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, F3_CFO, F3_BASEICM, F3_VALICM, F3_VALCONT, F3_VALOBSE,F3_DTCANC "
cQuery += "  FROM " + RetSqlName("SF3")
cQuery += "  WHERE D_E_L_E_T_ = ' ' AND RTRIM(F3_DTCANC) <> '' "
cQuery += "   AND F3_FILIAL = '" + xFilial("SF3") + "' "
cQuery += "   AND F3_DTCANC BETWEEN '" + dtos(dDtIni) + "' AND '" + dtos(dDtFin) + "' "
cQuery += "   AND F3_CLIEFOR + F3_LOJA BETWEEN '" + cCliIni + cLojaIni + "' AND '" + cCliFin + cLojaFin + "' "
cQuery += " ORDER BY F3_EMISSAO, F3_NFISCAL, F3_SERIE "
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

cCabec1 := "Emissao     Núm/Ser NF  Cliente / Loja                                      CFOP  B.Calc.ICMS  Valor ICMS  V.Contabil NF  Data Canc."
/*
Emissao     Núm/Ser NF  Cliente / Loja                                      CFOP  B.Calc.ICMS  Valor ICMS  V.Contabil NF  Data Canc.
99/99/9999  999999/111  999999/99 xxxxxxxxxxxxxxxxxxxxxx 40 xxxxxxxxxxxxxx  9999   999,999.99  999,999.99    999,999.99   99/99/9999
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

		@ nLi, 000 PSay StoD(TMP1->F3_EMISSAO)
		@ nLi, 012 PSay StrZero(Val(TMP1->F3_NFISCAL),6,0)+'/'+Left(TMP1->F3_SERIE,3)
		@ nLi, 024 PSay Left(TMP1->F3_CLIEFOR,6)+'/'+Left(TMP1->F3_LOJA,2)+" "+ ;
		  Left(Posicione("SA1",1,xfilial("SA1")+TMP1->F3_CLIEFOR+TMP1->F3_LOJA,"A1_NOME"),40)
		@ nLi, 076 PSay F3_CFO
		@ nLi, 081 PSay TMP1->F3_BASEICM  Picture "@E 999,999.99"         
		@ nLi, 093 PSay TMP1->F3_VALICM   Picture "@E 999,999.99"  
		IF TMP1->F3_VALCONT<>0 
			@ nLi, 108 PSay TMP1->F3_VALCONT  Picture "@E 999,999.99" 
		ELSE
			@ nLi, 108 PSay TMP1->F3_VALOBSE  Picture "@E 999,999.99"
		ENDIF
		@ nLi, 122 PSay StoD(TMP1->F3_DTCANC)

		// Soma Totais
		IF  TMP1->F3_VALCONT <>0                                        
		nTotVal += TMP1->F3_VALCONT
		ELSE                       
		nTotVal += TMP1->F3_VALOBSE
		ENDIF
      nLi++
        
	   dbSelectArea("TMP1")
		DbSkip()			

End
nLi++
// Total Geral
@ nli, 000 Psay "                                                                            -------------------------------------------------------"
nLi++
@ nLi, 000 PSay "Totais.................: "    
@ nLi, 104 PSay nTotVal	Picture "@E 999,999,999.99"
		
If (lImp)
	Roda(cbCont,cbText,Tamanho)
EndIf

If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return()