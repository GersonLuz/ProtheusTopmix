#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"

/*
+----------+-----------+----------+-------------------------+------+-----------+
|Auteracao | RPT0009   | Autor    | Max Rocha               |Data  |30.10.2012 |     
+----------+-----------+----------+-------------------------+------+-----------+
|Descricao | Relatório para Conferencia de Notas Fiscais de Entrada            |                    |
+----------+-----------+-------------------------------------------------------+
|Autor     | Data      | Descricao                                             |
+----------+-----------+-------------------------------------------------------+
|          |           |MAX ROCHA                                              |
+----------+-----------+-------------------------------------------------------+
*/

User Function rpt009()
****************************************************************************************
* Monta Tela Padrão de Impressões
*
*****

//Define Variaveis                                                        
Local cTitulo := "Relatório para Conferencia de Notas Fiscais"
Local cDesc1  := OemToAnsi("Ser  impresso de acordo com os parametros solicitados pelo")
Local cDesc2  := OemToAnsi("usuario.") 
Local cDesc3  := OemToAnsi("") 
Local cString := ""  	// Alias utilizado na Filtragem
Local lDic    := .F. 		// Habilita/Desabilita Dicionario
Local lComp   := .T. 		// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro := .F. 		// Habilita/Desabilita o Filtro
Local wnrel   := "RPT009CONF"  // Nome do Arquivo utilizado no Spool
Local nomeprog:= "RPT009CONF" // Nome do programa
Local aPerg   := {}			// Array contendo as Variaveis do Dicionario de Perguntas

Private Tamanho := "M" 		// P/M/G
Private Limite  := 132   	// 80/132/220
Private aOrdem  := {}  		// Ordem do Relatorio
Private cPerg   := "RPT009CONF"	// Pergunta do Relatorio
Private aReturn := { "Zebrado", 1,"Administracao", 1, 1, 2, "",1 }
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

aAdd(aPerg,{cPerg,"Digitação     de   ?","D",08,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Digitação     até  ?","D",08,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Fornecedor    de   ?","C",06,0,"G","","SA2","","","","",""})
aAdd(aPerg,{cPerg,"Fornecedor    até  ?","C",06,0,"G","","SA2","","","","",""})
aAdd(aPerg,{cPerg,"Loja          de   ?","C",02,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Loja          até  ?","C",02,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Grupo         de   ?","C",04,0,"G","","SBM","","","","",""})
aAdd(aPerg,{cPerg,"Grupo         até  ?","C",04,0,"G","","SBM","","","","",""})
aAdd(aPerg,{cPerg,"Produto       de   ?","C",08,0,"G","","SB1","","","","",""})
aAdd(aPerg,{cPerg,"Produto       até  ?","C",08,0,"G","","SB1","","","","",""})
aAdd(aPerg,{cPerg,"Usuário    	de   ?","C",06,0,"G","","USR","","","","",""})
aAdd(aPerg,{cPerg,"Usuário    	até  ?","C",06,0,"G","","USR","","","","",""})

U_TestaSX1(cPerg,aPerg)

// Verifica as Perguntas Seleciondas
Pergunte(cPerg,.F.)

//Envia para a SetPrinter                                                 
        
wnrel:= SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)

If ( nLastKey==27 )
	Return(Nil)
Endif

SetDefault(aReturn,cString)

If ( nLastKey==27 )
	Return(Nil)
Endif

RptStatus({|lEnd| MontaTab()},"Montando Tabelas Temporárias")
RptStatus({|lEnd| ImprRel(@lEnd,wnRel,cString,nomeprog,cTitulo)},cTitulo)

   //Fechar Tabelas Temporarias
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

Local dDigIni        := ""
Local dDigFim        := ""    
Local cForIni        := ""
Local cForFin        := ""
Local cLojIni        := ""
Local cLojFin        := ""
Local cGruIni        := ""
Local cGruFin        := ""
Local cProIni        := ""
Local cProFin        := ""
Local	cCodUsrIni		:= ""
Local	cCodUsrFim		:= ""


// Recebe Parametros      
dDigIni        := mv_par01
dDigFim        := mv_par02
cForIni        := mv_par03
cForFin        := mv_par04
cLojIni        := mv_par05
cLojFin        := mv_par06
cGruIni        := mv_par07
cGruFin        := mv_par08
cProIni        := mv_par09
cProFin        := mv_par10
cCodUsrIni		:= mv_par11
cCodUsrFim		:= mv_par12

cQuery := " SELECT 	F1_FILIAL, F1_DOC, F1_SERIE, F1_ESPECIE, F1_EMISSAO, F1_DTDIGIT, F1_TIPO, F1_FORNECE, F1_LOJA, A2_NOME, A2_CGC, F1_COND, "
cQuery += "          F1_ISS, F1_IRRF, F1_VALPIS, F1_VALCOFI, F1_VALCSLL, F1_VALICM, F1_INSS, F1_FRETE, "
cQuery += "          D1_COD, B1_DESC, D1_CF, D1_TES, D1_LOCAL, D1_ALIQISS, D1_VALICM, D1_VALIPI, D1_QUANT, D1_VUNIT, D1_TOTAL, F1_VALICM, F1_VALIPI,  F1_FRETE, F1_DESPESA, F1_DESCONT, F1_VALBRUT, F1_USERLGI "
cQuery += " FROM "+RetSqlName("SF1") +" JOIN "+RetSqlName("SA2") +" ON (F1_FORNECE=A2_COD AND F1_LOJA=A2_LOJA) "
cQuery += "                             JOIN "+RetSqlName("SD1") +" ON (F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_FORNECE=D1_FORNECE AND F1_LOJA=D1_LOJA) "
cQuery += "                             JOIN "+RetSqlName("SB1") +" ON (D1_COD = B1_COD) "

cQuery += "  WHERE  "+RetSqlName("SF1")+".D_E_L_E_T_ <> '*' AND "
cQuery += "  		  "+RetSqlName("SD1")+".D_E_L_E_T_ <> '*' AND "
cQuery += "  		  "+RetSqlName("SB1")+".D_E_L_E_T_ <> '*' AND "
cQuery += "  		  "+RetSqlName("SA2")+".D_E_L_E_T_ <> '*' AND "

cQuery += "         F1_FILIAL  =  '"+cFilAnt+"' AND "
cQuery += "         F1_DTDIGIT BETWEEN '" + DtoS(dDigIni) + "' AND '" +DtoS(dDigFim)+ "' AND "

cQuery += "         F1_FORNECE BETWEEN '" + cForIni + "' AND '" + cForFin + "' AND "
cQuery += "         F1_LOJA    BETWEEN '" + cLojIni + "' AND '" + cLojFin + "' AND "
cQuery += "         B1_GRUPO   BETWEEN '" + cGruIni + "' AND '" + cGruFin + "' AND "
cQuery += "         B1_COD     BETWEEN '" + cProIni + "' AND '" + cProFin + "'     "

cQuery += "  ORDER BY F1_FILIAL, F1_DOC, F1_SERIE "

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
Local cImpGrupo     := ""
Local cVenctos      := ""

    
DbSelectArea("TMP1")
dbGoTop()


nLi := Cabec(cTitulo,cCabec1,"","",Tamanho,nComp)

nLi++              
@ nLi, 000 PSay "Período: "+DtoC(mv_par01) + " - " + DtoC(mv_par02)
nLi++
nLi++ 
  

cImpGrupo  := TMP1->F1_DOC+TMP1->F1_SERIE

While ! TMP1->(Eof())
		If !(SubStr(Embaralha(TMP1->F1_USERLGI,1), 3, 6) >= MV_PAR11 .And. SubStr(Embaralha(TMP1->F1_USERLGI,1), 3, 6) <= MV_PAR12)
			TMP1->(dbSkip())
			
			/* Felipe Andrews - 10/06/2013 - Implementada correção para impressão correta do cabec. */
			cImpGrupo  := TMP1->F1_DOC+TMP1->F1_SERIE
			Loop
		EndIf
		
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
-------------------------------------------------------------------------------------------------------------------------------------
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
NF/SER: 999999999/999 ESP: 12345 EMISSAO: 99/99/9999 DT.DIG: 99/99/9999 TIPO: N FORN: 999999/99 1234567890123456789012345678901234567890  CNPJ: 22.333.444/0001-99   DIGITADOR: XXXXXXXXXXXXXXXX  
PRODUTO   DESCRICAO                                CFOP TES VAL.ICMS    VAL.IPI LOC QUANTIDADE   VAL.UNIT    VALOR TOTAL
99999999  1234567890123456789012345678901234567890 1234 999 99.999.99 99.999,99 01  999.999,99 999.999,99 999.999.999,99

*/
	        @ nLi, 000 PSay "NF/SER: "  + LEFT(TMP1->F1_DOC,9)+"/"+left(TMP1->F1_SERIE, 3)
	        @ nLi, 022 PSay "ESP: "     + LEFT(TMP1->F1_ESPECIE,5)
	 		  @ nLi, 033 PSay "EMISSAO: " + dToC(StoD(TMP1->F1_EMISSAO) )
			  @ nLi, 053 PSay "DT.DIG:"   + dToC(StoD(TMP1->F1_DTDIGIT))
			  @ nLi, 072 PSay "TIPO: "    + TMP1->F1_TIPO
			  nLi++
			  @ nLi, 000 PSay "FORN: "    + left(TMP1->F1_FORNECE, 6)+"/"+left(TMP1->F1_LOJA, 2)+"-"+LEFT(TMP1->A2_NOME, 35) 
	     	  @ nLi, 055 PSay "CNPJ: "    + TRANSFORM(TMP1->A2_CGC, "@R 99.999.999/9999-99")
	     	  @ nLi, 085 PSay "DIGITADOR: "+ UsrRetName( SubStr( Embaralha( TMP1->F1_USERLGI, 1 ), 3, 6 ) )
	     	  nLi ++
	     	  //TOTAL DA NOTA
	     	  @ nLi, 000 PSay "COND.PAGTO: "  + TMP1->F1_COND+ " -> " + LEFT(POSICIONE("SE4",1,xFilial("SE4")+TMP1->F1_COND,"E4_DESCRI"),20)                                                   
 	        @ nLi, 042 PSay "TOTAL DA NOTA: "+ Transform(TMP1->F1_VALBRUT, "@E 999,999,999.99")
                      
	 		  DBSelectArea("SE2")
	 		  DbSetOrder(6)
	 		  If DBSeek( xFilial("SE2") + TMP1->F1_FORNECE + TMP1->F1_LOJA + TMP1->F1_SERIE + TMP1->F1_DOC )
	 		     cVenctos = ""
	 		     While SE2->E2_NUM = TMP1->F1_DOC .AND. SE2->E2_PREFIXO = TMP1->F1_SERIE .AND. SE2->E2_FORNECE=TMP1->F1_FORNECE .AND. SE2->E2_LOJA=TMP1->F1_LOJA
	 		         cVenctos += DtoC(SE2->E2_VENCTO) +" - "
	 		         DbSkip()
	 		     EndDo
	 		     @ nLi, 075 PSay "VENCTOS: " + cVenctos
	 		  EndIF
			  nLi++
	 		  DBSelectArea("TMP1")
			  @ nLi, 000 PSay "IMPOSTOS ISS: "+ Transform(TMP1->F1_ISS, "@E 999,999.99")
           @ nLi, 030 PSay "PIS: "+ Transform(TMP1->F1_VALPIS,       "@E 999,999.99")
           @ nLi, 050 PSay "COFINS: "+ Transform(TMP1->F1_VALCOFI,   "@E 999,999.99")
           @ nLi, 070 PSay "CSLL: "+ Transform(TMP1->F1_VALCSLL,     "@E 999,999.99")
           @ nLi, 090 PSay "IRRF: "+ Transform(TMP1->F1_IRRF,        "@E 999,999.99")
           @ nLi, 110 PSay "INSS: "+ Transform(TMP1->F1_INSS,        "@E 999,999.99")           
         
           
		  	  If TMP1->F1_FRETE > 0 
		  	     nLi++
		  	     @ nLi, 000 PSay "FRETE INTERNO: "+ Transform(TMP1->F1_FRETE, "@E 999,999.99")
		  	  EndIF
		  	   
		  	  DBSelectArea("SF8") 
		  	  DBSetOrder(2)
		  	  if DBSeek(TMP1->F1_FILIAL+TMP1->F1_DOC+TMP1->F1_SERIE+TMP1->F1_FORNECE+TMP1->F1_LOJA)
	 	        nLi ++
		  	     @ nLi, 000 PSay "FRETE EXTERNO -> NOTA: "+ SF8->F8_NFDIFRE+"/"+SF8->F8_SEDIFRE    
			  	  DBSelectArea("SF1") 
			  	  DBSetOrder(1)
			  	  If DBSeek(xfilial("SF1")+SF8->F8_NFDIFRE+SF8->F8_SEDIFRE+SF8->F8_TRANSP+SF8->F8_LOJTRAN)
			  	     @ nLi, 040 PSay "VALOR: "+ Transform(SF1->F1_VALBRUT, "@E 999,999.99")          
			  	     @ nLi, 060 PSay "TRANSPORTADORA: "+SF8->F8_TRANSP+"/"+SF8->F8_LOJTRAN  +" - " +LEFT(POSICIONE("SA2",1,xFilial("SA2")+SF8->F8_TRANSP+SF8->F8_LOJTRAN,"A2_NOME"),40)                                                   
			  	  EndIF
		  	  EndIF
		  	  DBSelectArea("TMP1")   
  	     
	  	     nLi++
           @ nLi, 000 Psay "PRODUTO   DESCRICAO                                CFOP TES VAL.ICMS    VAL.IPI LOC QUANTIDADE   VAL.UNIT    VALOR TOTAL"
	        nLi++
	        
		     While cImpGrupo  = TMP1->F1_DOC+TMP1->F1_SERIE .AND. ! TMP1->(Eof())
		        @ nLi, 000 PSay LEFT(TMP1->D1_COD, 8)
		        @ nLi, 010 pSay LEFT(TMP1->B1_DESC, 40)
		        @ nLi, 051 pSay LEFT(TMP1->D1_CF, 4)
		        @ nLi, 056 pSay LEFT(TMP1->D1_TES, 3)
		        @ nLi, 060 pSay TMP1->D1_VALICM PICTURE "@E 99,999.99"
		        @ nLi, 070 pSay TMP1->D1_VALIPI PICTURE "@E 99,999.99"
		        @ nLi, 080 pSay LEFT(TMP1->D1_LOCAL, 2)
		        @ nLi, 085 pSay TMP1->D1_QUANT  PICTURE "@E 999,999.99"
	           @ nLi, 095 pSay TMP1->D1_VUNIT  PICTURE "@E 999,999.99"
              @ nLi, 106 pSay TMP1->D1_TOTAL  PICTURE "@E 999,999,999.99"	        
              nLi++
     		  	  DBSelectArea("TMP1")   
		        DBSkip()
		     EndDo                                   
           cImpGrupo  = TMP1->F1_DOC+TMP1->F1_SERIE
           
		     @ nLi, 000 Psay "-------------------------------------------------------------------------------------------------------------------------------------"
           nLi++
           
   		  DBSelectArea("TMP1")           
End
        
// Total Geral                                          
nLi++

//@ nLi, 126 PSay "Total Geral:"
//@ nli, 141 PSay nTotalGeral        Picture "@E 999,999,999.99"
//@ nLi, 183 PSay nTotLiqGeral       Picture "@E 999,999,999.99"

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
