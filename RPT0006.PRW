#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"

/*
+----------+-----------+----------+-------------------------+------+-----------+
|Auteracao | RPT0006   | Autor    | Max Rocha               |Data  |03.07.2012 |     
+----------+-----------+----------+-------------------------+------+-----------+
|Descricao | Relatório Titulos a Pagar por filial Origem/Grupos de Natureza/Nat.                    |
+----------+-----------+-------------------------------------------------------+
|Autor     | Data      | Descricao                                             |
+----------+-----------+-------------------------------------------------------+
|          |           |MAX ROCHA                                              |
+----------+-----------+-------------------------------------------------------+
*/

User Function rpt0006()
****************************************************************************************
* Monta Tela Padrão de Impressões
*
*****

//Define Variaveis                                                        
Local cTitulo := "Títulos a Pagar por Filial Origem"
Local cDesc1  := OemToAnsi("Ser  impresso de acordo com os parametros solicitados pelo")
Local cDesc2  := OemToAnsi("usuario.") 
Local cDesc3  := OemToAnsi("") 
Local cString := ""  	// Alias utilizado na Filtragem
Local lDic    := .F. 		// Habilita/Desabilita Dicionario
Local lComp   := .T. 		// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro := .F. 		// Habilita/Desabilita o Filtro
Local wnrel   := "rpt006"  // Nome do Arquivo utilizado no Spool
Local nomeprog:= "rpt006" // Nome do programa
Local aPerg   := {}			// Array contendo as Variaveis do Dicionario de Perguntas

Private Tamanho := "G" 		// P/M/G
Private Limite  := 220 		// 80/132/220
Private aOrdem  := {}  		// Ordem do Relatorio
Private cPerg   := "rpt006"	// Pergunta do Relatorio
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
aAdd(aPerg,{cPerg,"Emissao de         ?","D",08,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Emissao até        ?","D",08,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Filial Origem de   ?","C",06,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Filial Origem até  ?","C",06,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Faturas/Títulos    ?","C",01,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Pagos/aBertos/Ambos?","C",01,0,"G","","","","","","",""})

aAdd(aPerg,{cPerg,"Fornecedor    de   ?","C",06,0,"G","","SA2","","","","",""})
aAdd(aPerg,{cPerg,"Loja          de   ?","C",02,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Fornecedor    até  ?","C",06,0,"G","","SA2","","","","",""})
aAdd(aPerg,{cPerg,"Loja          até  ?","C",02,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Venc.Real     de   ?","D",08,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Venc.Real     até  ?","D",08,0,"G","","","","","","",""})

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
Local cQuery         := ""    
Local dEmisIni       := ""
Local dVencFim       := ""    
Local cFilIni        := ""
Local cFilFim        := ""         
Local cNatDesc      := ""
Local cFatura        := ""
Local cStatus        := ""
Local cForIni        := ""
Local cLojIni        := ""
Local cForFin        := ""
Local cLojFin        := ""
Local dVencIni       := ""
Local dVencFin       := ""

// Recebe Parametros      
dEmisIni       := mv_par01
dEmisFim       := mv_par02
cFilIni        := mv_par03
cFilFim        := mv_par04
cFatura        := mv_par05
cStatus        := mv_par06
cForIni        := mv_par07
cLojIni        := mv_par08
cForFin        := mv_par09
cLojFin        := mv_par10
dVencIni       := mv_par11
dVencFin       := mv_par12

cQuery := " SELECT  E2_NATUREZ, ED_DESCRIC,  E2_FILORIG, E2_FORNECE, E2_LOJA, A2_NOME, E2_PREFIXO, E2_NUM, E2_FATURA, "
cQuery += "         E2_PARCELA, E2_TIPO, E2_NATUREZ, E2_EMISSAO, E2_VENCTO, E2_VENCREA, E2_BAIXA, E2_VALOR, E2_DESCONT, E2_DECRESC, E2_ACRESC, E2_SALDO, E2_HIST "
cQuery += " FROM "+RetSqlName("SE2")+", "+RetSqlName("SA2")+", "+RetSqlName("SED")
cQuery += "  WHERE (E2_FORNECE=A2_COD) AND (E2_LOJA=A2_LOJA) AND "
cQuery += "        (E2_NATUREZ = ED_CODIGO) AND "
cQuery += "        (E2_TIPO <> 'PA') AND "    
If cFatura == "F"
   cQuery += "     (E2_FATURA = 'NOTFAT') AND "
else
   cQuery += "     (E2_FATURA <> 'NOTFAT') AND "      
EndIF    

If     cStatus = "B"
       cQuery += "     (E2_SALDO > 0 ) AND " 
Elseif cStatus == "P"      
       cQuery += "     (E2_SALDO = 0 ) AND " 
EndIf

cQuery += "        (E2_EMISSAO BETWEEN '" + DtoS(dEmisIni) + "' AND '" +DtoS(dEmisFim)+ "') AND "
cQuery += "        (E2_VENCREA BETWEEN '" + DtoS(dVencIni) + "' AND '" +DtoS(dVencFin)+ "') AND "

cQuery += "        (E2_FILORIG BETWEEN '" + cFilIni + "' AND '" + cFilFim + "') AND "
cQuery += "        (E2_FORNECE BETWEEN '" + cForIni + "' AND '" + cForFin + "') AND "
cQuery += "        (E2_LOJA    BETWEEN '" + cLojIni + "' AND '" + cLojFin + "') AND "

cQuery += RetSqlName("SE2")+".D_E_L_E_T_ <> '*' AND "
cQuery += RetSqlName("SED")+".D_E_L_E_T_ <> '*' AND "
cQuery += RetSqlName("SA2")+".D_E_L_E_T_ <> '*'  "
cQuery += "  ORDER BY E2_FILORIG, E2_VENCREA, A2_NOME, E2_NUM, E2_PARCELA "

TCQuery cQuery Alias "TMP1" New	


Return()                            



Static Function ImprRel(lEnd,wnrel,cString,nomeprog,cTitulo)
****************************************************************************************
* Imprime Relatório
*
*****

Local nLi     	:= 0 	// Contador de Linhas
Local lImp    	:= .F. 	// Indica se algo foi impresso
Local cbCont  	:= 0   	// Numero de Registros Processados
Local cbText  	:= "Dpto. Tecnologia da Informação - Topmix Engenharia e Tecnologia de Concreto S/A."  // Mensagem do Rodape
Local cCabec1 	:= ""	// Cabeçalho 1
Local cCabec2 	:= ""	// Cabeçalho 2
Local nComp		:= If(aReturn[4]==1,15,18)	// Condensado ou Normal
Local cTipoNF	:= "" 	// Topo da NF

Local nTotal        := 0
Local nTotalGeral   := 0
Local nTotalLiquido := 0          
Local nTotLiqGeral  := 0
Local cImpGrupo   := ""

cCabec1 := "Filial  Natureza                        Fornecedor                                 Prf Numero    Par  Tp   Emissao   Venc.Real    Dt.Baixa     Valor   Desconto Decrescimo  Acrescimo          Saldo Fatura   "

      
DbSelectArea("TMP1")
dbGoTop()

/* Felipe Andrews - Efetuada novamente a impress"ao do Cabec para gerar corretamente o relatorio */
nLi := Cabec(cTitulo,cCabec1,"","",Tamanho,nComp)

nLi++              
@ nLi, 000 PSay "Período: "+DtoC(mv_par01) + " - " + DtoC(mv_par02)
nLi++              

cImpGrupo  := TMP1->E2_FILORIG

While !Eof()
		lImp := .T.
	
		If LastKey() = 286
			lEnd := .T.
		EndIf
		
		If lEnd
			@ Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
			Exit
		EndIf
		
		If ( nLi > 58 )
			nLi := Cabec(cTitulo,cCabec1,"","",Tamanho,nComp)
			nLi++
		Endif
        @ nLi, 000 PSay left(TMP1->E2_FILORIG,06)
        @ nLi, 008 PSay left(TMP1->E2_NATUREZ,10)+'-'+Left(ED_DESCRIC,20)
 		  @ nLi, 040 PSay TMP1->E2_FORNECE+"/"+TMP1->E2_LOJA
		  @ nLi, 051 PSay LEFT(TMP1->A2_NOME,30)
		  @ nLi, 083 PSay TMP1->E2_PREFIXO
		  @ nLi, 087 PSay left(TMP1->E2_NUM, 9)
		  @ nLi, 097 PSay TMP1->E2_PARCELA  	 
		  @ nLi, 101 PSay TMP1->E2_TIPO 	
/*        
Filial  Natureza                        Fornecedor                                 Prf Numero    Par  Tp   Emissao   Venc.Real    Dt.Baixa     Valor   Desconto Decrescimo  Acrescimo          Saldo Fatura   "
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
010101 01234567890-012345678901234567890 999999/99 x123456789x123456789x123456789x 123 999999999 999 999 99/99/9999 99/99/9999# 99/99/9999 999,999.99 999,999.99 999,999.99 999,999.99 999,999,999.99 x123456789x
                                                                                                                                       999,999,999.99
*/
		 
        @ nLi, 105 PSay StoD(TMP1->E2_EMISSAO)
        @ nLi, 116 PSay StoD(TMP1->E2_VENCREA)
        If TMP1->E2_VENCTO <> TMP1->E2_VENCREA
           @ nLi, 126 PSay "#"
        EndIF   
        If ! Empty(TMP1->E2_BAIXA)
           @ nLi, 128 PSay StoD(TMP1->E2_BAIXA)
        EndIF        
		@ nLi, 139 PSay TMP1->E2_VALOR   picture "@E 999,999.99"
		@ nLi, 150 PSay TMP1->E2_DESCONT picture "@E 999,999.99"
		@ nLi, 161 PSay TMP1->E2_DECRESC picture "@E 999,999.99"                                    
		@ nLi, 172 PSay TMP1->E2_ACRESC  picture "@E 999,999.99"  

		@ nLi, 183 PSay ((TMP1->E2_SALDO-(TMP1->E2_DESCONT+TMP1->E2_DECRESC))+TMP1->E2_ACRESC)    picture "@E 999,999,999.99"  
		

		@ nLi, 198 PSay LEFT(TMP1->E2_FATURA, 12)

    	nLi++
        //nTotDecresc  := nTotDecresc +  TMP1->E1_DECRESC
        nTotal             := nTotal             +  TMP1->E2_VALOR
        nTotalGeral        := nTotalGeral        +  TMP1->E2_VALOR
        nTotalLiquido      := nTotalLiquido      +  (TMP1->E2_SALDO-(TMP1->E2_DESCONT+TMP1->E2_DECRESC)+TMP1->E2_ACRESC) 
        nTotLiqGeral       := nTotLiqGeral       +  (TMP1->E2_SALDO-(TMP1->E2_DESCONT+TMP1->E2_DECRESC)+TMP1->E2_ACRESC)  
        //cNatDesc := Z7_DESC
		DBSkip()
		
		If TMP1->E2_FILORIG   <> cImpGrupo  
		   nLi++
		                                                                                

           @ nLi, 0  PSay "SubTotal para Filial Origem: "+cImpGrupo //+'-'+ cNatDesc		   
           DBSelectArea("TMP1")
   		   @ nLi, 135 PSay nTotal 		   picture "@E 999,999,999.99"
   		   @ nLi, 189 PSay nTotalLiquido picture "@E 999,999,999.99"
   		   nTotal := 0
   		   nTotalLiquido := 0
   		   nLi++
   		   nLi++
		EndIf
      cImpGrupo  := TMP1->E2_FILORIG
        
End
        
// Total Geral
nLi++

@ nLi, 126 PSay "Total Geral:"
@ nli, 141 PSay nTotalGeral        Picture "@E 999,999,999.99"
@ nLi, 183 PSay nTotLiqGeral       Picture "@E 999,999,999.99"

nLi++
nLi++
@ nLi, 00  PSay "*** Fim ***"
		
If (lImp)
	Roda(cbCont,cbText,Tamanho)
EndIf

If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return()
