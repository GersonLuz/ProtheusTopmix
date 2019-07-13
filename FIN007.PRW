#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"

/*
+----------+-----------+----------+-------------------------+------+-----------+
|Auteracao | FIN007    | Autor    | Max Rocha               |Data  |23.04.2012 |     
+----------+-----------+----------+-------------------------+------+-----------+
|Descricao | Relatório Titulos a Receber EMITIDOS por Filial de Origem...      |
+----------+-------------------------------------------------------------------+
|Autor     | Data      | Descricao                                             |
+----------+-----------+-------------------------------------------------------+
*/

User Function FIN007()
****************************************************************************************
* Monta Tela Padrão de Impressões
*
*****

//Define Variaveis                                                        
Local cTitulo := "Títulos a Receber Emitidos por Filial Origem"
Local cDesc1  := OemToAnsi("Ser  impresso de acordo com os parametros solicitados pelo")
Local cDesc2  := OemToAnsi("usuario.") 
Local cDesc3  := OemToAnsi("") 
Local cString := ""  	// Alias utilizado na Filtragem
Local lDic    := .F. 		// Habilita/Desabilita Dicionario
Local lComp   := .T. 		// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro := .F. 		// Habilita/Desabilita o Filtro
Local wnrel   := "FIN007"  // Nome do Arquivo utilizado no Spool
Local nomeprog:= "FIN007" // Nome do programa
Local aPerg   := {}			// Array contendo as Variaveis do Dicionario de Perguntas

Private Tamanho := "G" 		// P/M/G
Private Limite  := 220 		// 80/132/220
Private aOrdem  := {}  		// Ordem do Relatorio
Private cPerg   := "FIN007"	// Pergunta do Relatorio
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
aAdd(aPerg,{cPerg,"Emissão de       ?","D",08,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Emissão até      ?","D",08,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Venc.Real de     ?","D",08,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Venc.Real até    ?","D",08,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Filial Origem de ?","C",06,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Filial Origem até?","C",06,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Considerar (RA)  ?","C",01,0,"G","","","","","","",""})

aAdd(aPerg,{cPerg,"Tipo de          ?","C",03,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Tipo até         ?","C",03,0,"G","","","","","","",""})

aAdd(aPerg,{cPerg,"Situacao de      ?","C",01,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Situacao ate     ?","C",01,0,"G","","","","","","",""})

aAdd(aPerg,{cPerg,"Cliente Inicial  ?","C",06,0,"G","","","","","","",""})                  
aAdd(aPerg,{cPerg,"Loja Inicial     ?","C",02,0,"G","","","","","","",""})                  
aAdd(aPerg,{cPerg,"Cliente Final    ?","C",06,0,"G","","","","","","",""})                  
aAdd(aPerg,{cPerg,"Loja Final       ?","C",02,0,"G","","","","","","",""})                  
aAdd(aPerg,{cPerg,"Baixados?(S/N/A) ?","C",01,0,"G","","","","","","",""})


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
Local dEmisFim       := ""             
Local dVencIni       := ""
Local dVencFim       := ""             
Local cFilIni        := ""
Local cFilFim        := ""
Local cRA            := ""
Local cTipoIni       := ""
Local cTipoFim       := ""
Local cSitIni        := ""
Local cSitFim        := ""
Local cCliIni        := ""
Local cLojIni        := ""
Local cCliFim        := ""
Local cLojFim        := ""
Local cBaixa         := ""

// Recebe Parametros      
dEmisIni       := mv_par01
dEmisFim       := mv_par02
dVencIni       := mv_par03
dVencFim       := mv_par04
cFilIni        := mv_par05
cFilFim        := mv_par06
cRA            := mv_par07
cTipoIni       := mv_par08
cTipoFim       := mv_par09
cSitIni        := mv_par10
cSitFim        := mv_par11
cCliIni        := mv_par12
cLojIni        := mv_par13
cCliFim        := mv_par14
cLojFim        := mv_par15
cBaixado       := mv_par16



cQuery := " SELECT E1_FILORIG, E1_CLIENTE, E1_LOJA, A1_NOME, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_NATUREZ, E1_EMISSAO, E1_VENCTO, E1_VENCREA, E1_BAIXA, E1_VALOR,  E1_DECRESC, E1_ACRESC, E1_SALDO, E1_HIST, E1_SITUACA, E1_CONTRAT, E1_MOVIMEN, E1_VEND1 "
cQuery += " FROM "+RetSqlName("SE1")+", "+RetSqlName("SA1") 
cQuery += " WHERE (E1_CLIENTE=A1_COD) AND (E1_LOJA=A1_LOJA) AND "
//cQuery += "      ((E1_BAIXA='') OR  (E1_BAIXA > '" + DtoS(dDataBase) + "')) AND "
if     cBaixado == "N"
   cQuery += "      (E1_SALDO >  0) AND "
ElseIF cBaixado == "S" 
   cQuery += "      (E1_SALDO <= 0) AND "
EndIF  
cQuery += "      (E1_VENCREA BETWEEN '" + DtoS(dVencIni) + "' AND '" +DtoS(dVencFim)+ "') AND "
cQuery += "      (E1_EMISSAO BETWEEN '" + DtoS(dEmisIni) + "' AND '" +DtoS(dEmisFim)+ "') AND "
cQuery += "      (E1_FILORIG BETWEEN '" + cFilIni + "' AND '" + cFilFim + "') AND "

cQuery += "      (E1_CLIENTE BETWEEN '" + cCliIni + "' AND '" + cCliFim + "') AND "
cQuery += "      (E1_LOJA    BETWEEN '" + cLojIni + "' AND '" + cLojFim + "') AND "

If cRA = "N"
   cQuery += "   (E1_TIPO <> 'RA') AND "
EndIF 
cQuery += "      (E1_TIPO    BETWEEN '" + cTipoIni + "' AND '" + cTipoFim + "') AND "
cQuery += "      (E1_SITUACA BETWEEN '" + cSitIni  + "' AND '" + cSitFim  + "') AND "

cQuery += RetSqlName("SE1")+".D_E_L_E_T_ <> '*' AND "
cQuery += RetSqlName("SA1")+".D_E_L_E_T_ <> '*'     "
cQuery += " ORDER BY E1_FILORIG, E1_VENCREA, A1_NOME, E1_NUM, E1_PARCELA "


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
Local nSaldo      := 0    
Local nSaldoGeral := 0
Local nNCC        := 0
Local nNCCSaldo   := 0
Local cImpFilial  := ""

cCabec1 := "Cliente                                   Prf Numero    Prc Tp  Emissao    Vencto     Venc.Real           Valor          Saldo Dias   Situação                         Contrato     Baixado      Histórico               "
      
DbSelectArea("TMP1")
dbGoTop()

nLi++              
@ nLi, 000 PSay "Período: "+DtoC(mv_par01) + " - " + DtoC(mv_par02)

cImpFilial := TMP1->E1_FILORIG

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
Cliente                                   Prf Numero    Prc Tp  Emissao    Vencto     Venc.Real           Valor          Saldo Dias   Situação                         Contrato     Baixado      Histórico                  
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
999999/99 x123456789x123456789x123456789x 123 999999999 999 999 99/99/9999 99/99/9999 99/99/9999 999,999,999.99 999,999,999.99  9999* 0-Cob Caucao Descontada-Carteira 99999999999  99/99/9999   x123456789x123456789x12345 
                                                                                                                                 ================================
*/

		@ nLi, 000 PSay TMP1->E1_CLIENTE+"/"+TMP1->E1_LOJA
		@ nLi, 010 PSay LEFT(TMP1->A1_NOME,30)
		@ nLi, 042 PSay TMP1->E1_PREFIXO
		@ nLi, 046 PSay TMP1->E1_NUM  
		@ nLi, 056 PSay TMP1->E1_PARCELA  	 
		@ nLi, 060 PSay TMP1->E1_TIPO 	
		 
        @ nLi, 064 PSay StoD(TMP1->E1_EMISSAO)
        @ nLi, 075 PSay StoD(TMP1->E1_VENCTO)
        @ nLi, 086 PSay StoD(TMP1->E1_VENCREA)
                
		@ nLi, 097 PSay IIF(TMP1->E1_TIPO$"RA/NCC",(TMP1->E1_VALOR*-1),TMP1->E1_VALOR)      picture "@E 999,999,999.99"
		@ nLi, 112 PSay IIF(TMP1->E1_TIPO$"RA/NCC",(TMP1->E1_SALDO*-1),TMP1->E1_SALDO)      picture "@E 999,999,999.99"

		//EM ABERTO
		If ((dDataBase - StoD(TMP1->E1_VENCREA)) > 1) .AND. empty(TMP1->E1_BAIXA)
 	       @ nLi, 128 PSay (dDataBase - StoD(TMP1->E1_VENCREA))  picture "@E 9999"
 	   EndIf
 	   //BAIXADOS
 	   If ((StoD(TMP1->E1_BAIXA) - StoD(TMP1->E1_VENCREA)) > 1) .AND. ! empty(TMP1->E1_BAIXA)
 	       @ nLi, 128 PSay (dDataBase - StoD(TMP1->E1_VENCREA))  picture "@E 9999"
 	   EndIf           
 	   
		If ! empty(TMP1->E1_BAIXA) .and. TMP1->E1_SALDO = 0
		   @ nLi, 132 Psay '*'          
		EndIf           
		If ! empty(TMP1->E1_BAIXA) .and. TMP1->E1_SALDO > 0
		   @ nLi, 132 Psay 'P'          
		EndIf           
		
        @ nLi, 134 Psay TMP1->E1_SITUACA            //IIF(TMP1->E1_LOCAL == "B", "Banco", "Carteira")
		If     TMP1->E1_SITUACA == "0"
               @ nLi, 135 Psay "-Carteira/Antecipados"
        elseif TMP1->E1_SITUACA == "1"   
               @ nLi, 135 Psay "-Cobranca Simples/Bordero"
        elseif TMP1->E1_SITUACA == "2"   
               @ nLi, 135 Psay "-Cobranca Descontada"
        elseif TMP1->E1_SITUACA == "3"   
               @ nLi, 135 Psay "-Cobranca Caucionada"
        elseif TMP1->E1_SITUACA == "4"   
               @ nLi, 135 Psay "-Cobranca Vinculada"
        elseif TMP1->E1_SITUACA == "5"   
               @ nLi, 135 Psay "-Cobranca c/Advogado"
        elseif TMP1->E1_SITUACA == "6"   
               @ nLi, 135 Psay "-Cobranca Judicial"
        elseif TMP1->E1_SITUACA == "7"   
               @ nLi, 135 Psay "-Cob Caucao Descontada"
        elseif TMP1->E1_SITUACA == "F"   
               @ nLi, 135 Psay "-Carteira Protesto"
        elseif TMP1->E1_SITUACA == "G"   
               @ nLi, 135 Psay "-Carteira Acordo"
        elseif TMP1->E1_SITUACA == "H"   
               @ nLi, 135 Psay "-Cobranca Cartorio"

        elseif TMP1->E1_SITUACA == "V"   
               @ nLi, 135 Psay "-VISA"  + IIF(TMP1->E1_TIPO="CD ", "DEBITO", "")
        elseif TMP1->E1_SITUACA == "M"   
               @ nLi, 135 Psay "-MASTERCARD" + IIF(TMP1->E1_TIPO="CD ", "DEBITO", "")
        elseif TMP1->E1_SITUACA == "R"   
               @ nLi, 135 Psay "-REDESHOP"
        elseif TMP1->E1_SITUACA == "Z"   
               @ nLi, 135 Psay "-CONSTRUCARD"
        elseif TMP1->E1_SITUACA == "D"   
               @ nLi, 135 Psay "-DINERS"

        End
        @ nLi, 167 Psay TMP1->E1_CONTRATO
        @ nLi, 180 Psay StoD(TMP1->E1_BAIXA )

		
				
		@ nLi, 193 PSay LEFT(TMP1->E1_HIST, 25)
       
    	nLi++
        //nTotDecresc  := nTotDecresc +  TMP1->E1_DECRESC       
        IF TMP1->E1_TIPO <> 'NCC'
           nTotal       := nTotal      + IIF(trim(TMP1->E1_TIPO)$"RA",(TMP1->E1_VALOR*-1),TMP1->E1_VALOR)
           nSaldo       := nSaldo      + IIF(trim(TMP1->E1_TIPO)$"RA",(TMP1->E1_SALDO*-1),TMP1->E1_SALDO)
           nTotalGeral  := nTotalGeral + IIF(trim(TMP1->E1_TIPO)$"RA",(TMP1->E1_VALOR*-1),TMP1->E1_VALOR)
           nSaldoGeral  := nSaldoGeral + IIF(trim(TMP1->E1_TIPO)$"RA",(TMP1->E1_SALDO*-1),TMP1->E1_SALDO)
        Else
           nNCC         := nNCC        + (TMP1->E1_VALOR*-1)
           nNCCSaldo    := nNCCSaldo   + (TMP1->E1_SALDO*-1)
        EndIF
		DBSkip()
		
		If TMP1->E1_FILORIG <> cImpFilial
		   nLi++
		   
           @ nLi, 070 PSay "SubTotal para Filial: "+cImpFilial 		   
   		   @ nLi, 097 PSay nTotal picture "@E 999,999,999.99"
   		   @ nLi, 112 PSay nSaldo picture "@E 999,999,999.99"
   		   nTotal := 0  
   		   nSaldo := 0
   		   nLi++
   		   nLi++
		EndIf
        cImpFilial := TMP1->E1_FILORIG
        
End
        
// Total Geral
nLi++
@ nLi, 070 PSay "Total Geral:"
@ nli, 097 PSay nTotalGeral    Picture "@E 999,999,999.99"
@ nLi, 112 PSay nSaldoGeral    picture "@E 999,999,999.99"

nLi++
@ nLi, 070 PSay "Total NCC:"
@ nli, 097 PSay nNCC           Picture "@E 999,999,999.99"
@ nLi, 112 PSay nNCCSaldo      picture "@E 999,999,999.99"

		
If (lImp)
	Roda(cbCont,cbText,Tamanho)
EndIf

If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return()
