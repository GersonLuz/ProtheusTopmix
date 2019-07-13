#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"

/*
+----------+-----------+----------+-------------------------+------+-----------+
|Programa  | RPT0007   | Autor    | Max Rocha               |Data  |13.07.2012 |
+----------+-----------+----------+-------------------------+------+-----------+
|Descricao | Protocolo de Entrega                                              |
+----------+-------------------------------------------------------------------+
| USO      | Exclusivo da TOPMIX Engenharia                                    |
+----------+-------------------------------------------------------------------+
|Autor     | Data      | Descricao                                             |
+----------+-----------+-------------------------------------------------------+
*/

User Function RPT007()
****************************************************************************************
* Monta Tela Padrão de Impressões
*
*****

//Define Variaveis                                                        
Local cTitulo := "Protoco de Entregas - Notas Fiscais"
Local cDesc1  := OemToAnsi("Ser  impresso de acordo com os parametros solicitados pelo")
Local cDesc2  := OemToAnsi("usuario.") 
Local cDesc3  := OemToAnsi("") 
Local cString := "SF2"  	// Alias utilizado na Filtragem
Local lDic    := .F. 		// Habilita/Desabilita Dicionario
Local lComp   := .T. 		// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro := .F. 		// Habilita/Desabilita o Filtro
Local wnrel   := "RPT0007"  // Nome do Arquivo utilizado no Spool
Local nomeprog:= "RPT0007" // Nome do programa
Local aPerg   := {}			// Array contendo as Variaveis do Dicionario de Perguntas

Private Tamanho := "M" 		// P/M/G
Private Limite  := 132 		// 80/132/220
Private aOrdem  := {}  		// Ordem do Relatorio
Private cPerg   := "RPT007"	// Pergunta do Relatorio
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
aAdd(aPerg,{cPerg,"Nota  Inicial    ?","C",09,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Serie Inicial    ?","C",03,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Nota  Final      ?","C",09,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Serie Final      ?","C",03,0,"G","","","","","","",""})

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
Local cNotIni   := ""
Local cNotFin   := ""
Local cSerIni   := ""
Local cSerFin   := ""
Local cMunCc2   := ""
// Recebe Parametros
cNotIni  := mv_par01
cSerIni  := mv_par02
cNotFin  := mv_par03
cSerFin  := mv_par04



cQuery := " SELECT DISTINCT F2_FILIAL, F2_DOC, F2_SERIE, F2_EMISSAO, D2_PEDIDO, "
cQuery += "        F2_CLIENTE, F2_LOJA, "
cQuery += "        A1_NOME,        C5_ZENDCOB, C5_ZENDNUM, C5_ZBAIROC, C5_ZCOMPLE, C5_ZEST, C5_ZMUN,  C5_ZEST, C5_ZMUN, CC2_MUN, C5_RECISS "
cQuery += " FROM "+RetSQLName("SF2")+ " JOIN "+RetSQLName("SA1")+ " ON (F2_CLIENTE=A1_COD AND F2_LOJA=A1_LOJA) "
cQuery += "                             JOIN "+RetSQLName("SD2")+ " ON (D2_FILIAL=F2_FILIAL AND D2_DOC=F2_DOC AND D2_SERIE=F2_SERIE ) "
cQuery += "                             JOIN "+RetSQLName("SC5")+ " ON (D2_FILIAL=C5_FILIAL AND D2_PEDIDO=C5_NUM) "
cQuery += "                             JOIN "+RetSQLName("CC2")+ " ON (C5_ZEST = CC2_EST AND C5_ZMUN = CC2_CODMUN ) "
cQuery += " WHERE "+RetSQLName("SF2")+".D_E_L_E_T_ <> '*' AND "
cQuery += "       "+RetSQLName("SA1")+".D_E_L_E_T_ <> '*' AND "
cQuery += "       "+RetSQLName("SD2")+".D_E_L_E_T_ <> '*' AND "
cQuery += "       "+RetSQLName("CC2")+".D_E_L_E_T_ <> '*' AND "     
cQuery += "       "+RetSQLName("SC5")+".D_E_L_E_T_ <> '*' AND "     
cQuery += "       F2_FILIAL ='"+ xFilial("SF2")+"' AND "
cQuery += "       F2_DOC	BETWEEN '"+ cNotIni +"' AND '"+ cNotFin + "' AND "
cQuery += "       F2_SERIE	BETWEEN '"+ cSerIni +"'	AND '"+ cSerFin + "'"
cQuery += " ORDER BY F2_DOC "     


TCQuery cQuery Alias "TMP1" New	
	

	
Return()


*********************************************************************
Static Function ImprRel(lEnd,wnrel,cString,nomeprog,cTitulo)
*********************************************************************
* Imprime Relatório
*
*****

Local nLi     	:= 0 	// Contador de Linhas
Local lImp    	:= .F. 	// Indica se algo foi impresso
Local cbCont  	:= 0   	// Numero de Registros Processados
Local cbText  	:= "Dpto. Tecnologia da Informação - Topmix Engenharia e Tecnologia de Concretos SA."  // Mensagem do Rodape
Local cCabec1 	:= ""	// Cabeçalho 1
Local cCabec2 	:= ""	// Cabeçalho 2
Local nComp		:= If(aReturn[4]==1,15,18)	// Condensado ou Normal
Local cTipoNF	:= "" 	// Topo da NF


Local nTotalGeral    := 0 
Local nTotalFilial   := 0
Local cFilImp        := ""
Local nRegSM0        := 0
Local cCliente       := ""
Local cMunCc2 := ""

DbSelectArea("TMP1")
dbGoTop()

cFilImp := TMP1->F2_FILIAL
Cabec(cTitulo,cCabec1,"","",Tamanho,nComp)
nLi := 10
	
While !Eof()
		lImp := .T.
	
		If LastKey() = 286
			lEnd := .T.
		EndIf
		
		If lEnd
			@ Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
			Exit
		EndIf
		
	   

   While (cFilImp = TMP1->F2_FILIAL)
		If ( nLi > 70 )
			nLi := Cabec(cTitulo,cCabec1,"","",Tamanho,nComp)
			nLi++
		Endif
		

		
		cEndCob  := AllTrim(TMP1->C5_ZENDCOB) + " , " + AllTrim(TMP1->C5_ZENDNUM) + " , " + AllTrim(TMP1->C5_ZBAIROC) + " , " + AllTrim(TMP1->C5_ZCOMPLE) + " , " +	TMP1->CC2_MUN
	
		
		@ nLi++,00 PSAY SM0->M0_NOMECOM
		@ nLi++,00 PSAY "MOTOBOY          : _________________________________________________________"
		@ nLi++,00 PSAY "DESTINATARIO     : " + TMP1->A1_NOME
		@ nLi++,00 PSAY "ENDERECO         : " + cEndCob 
		@ nLi++,00 PSAY "NUMERO DA FATURA : " + TMP1->F2_DOC + '/'+TMP1->F2_SERIE 

		SE1->(dbSetOrder(1))
	   (SE1->(dbSeek(xFilial("SE1") + SUBSTR(TMP1->F2_FILIAL, 5, 2) + SUBSTR(TMP1->F2_SERIE, 1, 1) + TMP1->F2_DOC )))
		
		@ nLi++,00 PSAY "VENCIMENTO       : " + dTOc(SE1->E1_VENCTO) + " / "+ SE1->E1_PARCELA
		@ nLi++,00 PSAY "DATA EMISSAO     : " + dTOc(SE1->E1_EMISSAO)
	
		@ nLi++,00 PSAY "OBS              : " + Iif(TMP1->C5_RECISS=="1", "RETEM ISS", "NAO RETEM ISS")
		@ nLi++,00 PSAY "DATA DA ENTREGA  : ____/____/_________"
		
		nLi += 2
		
		@ nLi++,00 PSAY "_________________________________________________"
		@ nLi++,00 PSAY "         ASSINATURA COM NOME LEGIVEL             "
		
  		nLi += 2

      @ nLi++,00 PSAY "Corte aqui....................................................................................................................................................."


      nLi += 2
		
        
	   dbSelectArea("TMP1")
		DbSkip()			
   End   
	// Total da Filial
   nLi++
End
nLi++
		
If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()       


Return()
