#INCLUDE "RWMAKE.CH"
#include 'topconn.ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���Descri��o � IMPRESSAO DE NOTA DE FATURA EM LASER - MODO GRAFICO       ���
�������������������������������������������������������������������������Ĵ��
��PROGRAMADOR: MAX ROCHA --> TOPMIX -->> 13-04-2012
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                                          


User Function FatGraf()
LOCAL	aPerg 		:= {} 

lEnd     := .F.

dbSelectArea("SM0")
cCodFil := M0_CODFIL

dbSelectArea("SF2")

//
Private cPerg   := "FATGRF"	// Pergunta do Relatorio
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault

// Variaveis de Controle do Relat�rio
aAdd(aPerg,{cPerg,"Nota            	?","C",09,0,"G","","","","","","",""})
aAdd(aPerg,{cPerg,"Serie           	?","C",03,0,"G","","","","","","",""})

U_TestaSX1(cPerg,aPerg)

//Verifica as Perguntas Seleciondas
Pergunte(cPerg,.T.)




RptStatus({ |lend| MontaRel() })


Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���Descri��o � IMPRESSAO NOTA DE FATURA/LOCACAO MODO GRAFICO              ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
/*/

Static Function MontaRel()

LOCAL oPrint
LOCAL n := 0
LOCAL aDadosEmp
LOCAL aDadosTit
LOCAL aDatSacado
LOCAL i         := 1
LOCAL nRec      := 0
LOCAL cNota  := MV_PAR01
LOCAL cSerie := MV_PAR02


DO CASE
CASE LEN(ALLTRIM(SM0->M0_INSC)) == 8
   _Cie := Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"-"+Subs(SM0->M0_INSC,7,2)
CASE LEN(ALLTRIM(SM0->M0_INSC)) == 9
   _Cie := Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+Subs(SM0->M0_INSC,7,3)
CASE LEN(ALLTRIM(SM0->M0_INSC)) == 12
   _Cie := Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)+"."+Subs(SM0->M0_INSC,10,3)
CASE LEN(ALLTRIM(SM0->M0_INSC)) == 14
   _Cie := Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)+"."+Subs(SM0->M0_INSC,10,3)+"-"+Subs(SM0->M0_INSC,13,2)
OTHERWISE
   _Cie := Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)
ENDCASE

aDadosEmp    := {SM0->M0_NOMECOM                                          ,; //[1]Nome da Empresa
SM0->M0_ENDCOB                                                            ,; //[2]Endere�o
AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+             ; //[6]
Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                      ; //[6]
Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
"IE: "+_Cie }  //[7]I.E


oPrint:= TMSPrinter():New( "Nota de Fatura/Loca��o" )
oPrint:SetPortrait() // ou SetLandscape()
oPrint:StartPage()   // Inicia uma nova p�gina
oPrint:SetpaperSize(9) // <==== AJUSTE PARA PAPEL a4

	DbSelectArea("SF2")
   DbSetOrder(1)
   DbSeek(xFilial()+cNota+cSerie,.T.)
   


   //Posiciona o SA1 (Cliente)
   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek(xFilial()+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
   
   DbSelectArea("SF2")
   
   aDadosCliente := {SUBSTR(SA1->A1_NOME,1,40)     ,;      // [1]Raz�o Social
   AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA           ,;      // [2]C�digo
   Iif(Len(AllTrim(SA1->A1_ENDCOB))<5,AllTrim(SA1->A1_END) + " " + AllTrim(SA1->A1_BAIRRO),AllTrim(SA1->A1_ENDCOB)) ,;      // [3]Endere�o
   AllTrim(SA1->A1_MUN )                            ,;      // [4]Cidade
   SA1->A1_EST                                      ,;      // [5]Estado
   SA1->A1_CEP                                      ,;      // [6]CEP
   SA1->A1_CGC                                      ,;      // [7]CGC 
   SA1->A1_TEL                                      }  		// [8]FONE

   
   
   dData   :=  SF2->F2_EMISSAO         // Data de Emissao
   cMes    :=  StrZero(Month(dData))
   cAno    :=  Str(Year(dData))
   cAnoMes :=  cAno+Subs(cMes,2,2)

   nMes    := Month(dData)
   aMes := ""
   DO CASE
   CASE nMes == 01
      aMes := "Janeiro"
   CASE nMes == 02
      aMes := "Fevereiro"
   CASE nMes == 03
      aMes := "Mar�o"
   CASE nMes == 04
      aMes := "Abril"
   CASE nMes == 05
      aMes := "Maio"
   CASE nMes == 06
      aMes := "Junho"
   CASE nMes == 07
      aMes := "Julho"
   CASE nMes == 08
      aMes := "Agosto"
   CASE nMes == 09
      aMes := "Setembro"
   CASE nMes == 10
      aMes := "Outubro"
   CASE nMes == 11
      aMes := "Novembro"
   CASE nMes == 12
      aMes := "Dezembro"
   ENDCASE


   Impress(oPrint,aDadosEmp,aDadosCliente)



oPrint:setup()     // Escolher a impressora
oPrint:Preview()   // Visualiza antes de imprimir

oPrint:End()     // Finaliza Objeto
ms_flush() // desativar impressora

Return nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �  IMPRESS � Autor � Max Rocha             � Data � 13/04/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � IMPRESSAO DA NOTA DE ENTREGA                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para Clientes Microsiga                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosCliente)
LOCAL i := 0
LOCAL cCGC := IIF(SA1->A1_PESSOA == "J",substr(SA1->A1_CGC,1,2) +"."+substr(SA1->A1_CGC,3,3) +"."+ substr(SA1->A1_CGC,6,3) +"/"+ substr(SA1->A1_CGC,9,4) +"-"+substr(SA1->A1_CGC,13,2),substr(SA1->A1_CGC,1,3) +"."+substr(SA1->A1_CGC,4,3) +"."+ substr(SA1->A1_CGC,7,3) +"-"+ substr(SA1->A1_CGC,10,2))
LOCAL nValorTotal := 0
//Par�metros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)

Private  oBrush      := TBrush():New(),;
      	oPen     	:= TPen():New(0,5),;
      	cFileLogo   := GetSrvProfString('Startpath','') + 'lgrl01' + '.bmp',;
      	oFont5      := TFont():New( "Arial",,5,,.F.,,,,,.F. ),;
      	oFont06     := TFont():New( "Arial",,6,,.F.,,,,,.F. ),;
      	oFont06n    := TFont():New( "Arial",,6,,.T.,,,,,.F. ),;
      	oFont06ns   := TFont():New( "Arial",,6,,.T.,,,,,.T. ),;
      	oFont07     := TFont():New('Courier New',07,07,,.F.,,,,.T.,.F.),;
      	oFont07s    := TFont():New('Courier New',07,07,,.F.,,,,.T.,.T.),;
	      oFont07ns   := TFont():New('Courier New',07,07,,.T.,,,,.T.,.T.),;
      	oFont08     := TFont():New('Courier New',08,08,,.F.,,,,.T.,.F.),;
      	oFont08n    := TFont():New('Courier New',08,08,,.T.,,,,.T.,.F.),;
      	oFont08s    := TFont():New('Courier New',08,08,,.F.,,,,.T.,.T.),;
      	oFont08ns   := TFont():New('Courier New',08,08,,.T.,,,,.T.,.T.),;
      	oFont09     := TFont():New('Courier New',09,09,,.T.,,,,.T.,.F.),;
      	oFont10     := TFont():New('Courier New',10,10,,.F.,,,,.T.,.F.),;
      	oFont10n    := TFont():New('Courier New',10,10,,.T.,,,,.T.,.F.),;
      	oFont10a    := TFont():New('Courier New',,10,,.t.,,,,,.f. ),;
      	oFont11     := TFont():New('Courier New',11,11,,.F.,,,,.T.,.F.),;
      	oFont11n    := TFont():New('Courier New',11,11,,.T.,,,,.T.,.F.),;
      	oFont12     := TFont():New('Courier New',12,12,,.F.,,,,.T.,.F.),;
      	oFont12n    := TFont():New('Courier New',12,12,,.T.,,,,.T.,.F.),;
      	oFont13     := TFont():New('Courier New',13,13,,.T.,,,,.T.,.F.),;
      	oFont14     := TFont():New('Courier New',14,14,,.T.,,,,.T.,.F.),;
      	oFont15     := TFont():New('Courier New',15,15,,.T.,,,,.T.,.F.),;
      	oFont18     := TFont():New('Arial',18,18,,.T.,,,,.T.,.T.),;
      	oFont16     := TFont():New('Arial',16,16,,.T.,,,,.T.,.F.),;
      	oFont20     := TFont():New('Arial',20,20,,.F.,,,,.T.,.F.),;
      	oFont22     := TFont():New('Arial',22,22,,.T.,,,,.T.,.F.)

//nLinha      := 3000      	// Controla a linha por extenso
lPrintDesTab:= .f.    		// Imprime a Descricao da tabela (a cada nova pagina)
Private  _nQtdReg := 0      // Numero de registros para intruir a regua
Private _cNomecomp := ""

_nomeuser := substr(cUsuario,7,15)
PswOrder(2)
If PswSeek(_nomeuser,.T.)
   aRetUser := PswRet(1)
   _cNomecomp := aRetUser[1,04]
Endif

//��������������Ŀ
//�Numero/Emissao�
//����������������

nNossoNu := 1

// IMPRIME DUAS VIAS

nLinha      := 50   // Controla a linha

FOR I := 1 TO 1

//���������������������������������Ŀ
//�Imprime o cabecalho da empresa. !�
//�����������������������������������

   oPrint:Box(nLinha,100, nLinha+210,2300)//Box inteiro //oPrint:Box(nLinha,1910,nLinha+220,2300)
   oPrint:Box(nLinha,100, nLinha+310,2300)//Box inteiro //oPrint:Box(nLinha,1910,nLinha+220,2300)

   oPrint:SayBitmap(nLinha+5,110,cFileLogo,480,125)
   
   //Dados Filial  
   nlinha += 055                                       
   oPrint:Say(nLinha,650,AllTrim(Upper(SM0->M0_NOMECOM)) +"  CNPJ: "+ Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+Subs(SM0->M0_CGC,13,2),oFont11n) // Razao Empresa +CGC
   oPrint:Say(nLinha,2030,OemToAnsi('Fatura'),oFont08)
   nLinha += 040
   oPrint:Say(nLinha,650,AllTrim(SM0->M0_ENDENT)     ,oFont11n) // Rua   
   oPrint:Say(nLinha,2000,STRZERO(VAL(SF2->F2_DOC),6),oFont18)  // numero Fatura

   nLinha += 040
   oPrint:Say(nLinha,650,AllTrim(SM0->M0_BAIRCOB)+ ' CEP.: ' + AllTrim(TransForm(SM0->M0_CEPENT,'@R 99.999-999'))        ,oFont11n) // Bairro
   nlinha += 040
   oPrint:Say(nLinha,650,AllTrim(SM0->M0_CIDENT) +'/'+AllTrim(SM0->M0_ESTENT) + '  -  FONE: (' + AllTrim(substr(SM0->M0_TEL,1,2)+') '+ AllTrim(substr(SM0->M0_TEL,3,8)) ),oFont11)
   oPrint:Say(nLinha,2000,Dtoc(SF2->F2_EMISSAO),oFont12)
   nlinha += 055
   oPrint:Say(nLinha,100,"LOCA��O DE EQUIPAMENTOS",oFont12)

   //����������Ŀ
   //�Cliente   �
   //������������
   nLinha += 110
   oPrint:Box(nLinha,100, nLinha+380,2300)//Box inteiro 
   nLinha += 020
   oPrint:Say(nLinha,110, OemToAnsi('Raz�o Social:'),oFont06)
   oPrint:Say(nLinha,1700,OemToAnsi('C�digo:'),oFont06)
   nLinha += 020
   oPrint:Say(nLinha,110, AllTrim(aDadosCliente[1]) , oFont11)
   oPrint:Say(nLinha,1700,AllTrim(aDadosCliente[2]) , oFont11)
   
   nlinha += 050
   oPrint:Say(nLinha,110, OemToAnsi('Local de Entrega/Endere�o da Obra'),oFont06)
   oPrint:Say(nLinha,1700,OemToAnsi('Bairro'),oFont06)
   nlinha += 020
   oPrint:Say(nLinha,110, AllTrim(SA1->A1_END),    oFont11)
   oPrint:Say(nLinha,1700,AllTrim(SA1->A1_BAIRRO), oFont11)                     
      
   nlinha += 050 
   oPrint:Say(nLinha,110,  OemToAnsi('Munic�pio:'),oFont06)
   oPrint:Say(nLinha,1700, OemToAnsi('Telefone:') ,oFont06)
   nlinha += 020
   oPrint:Say(nLinha,110, AllTrim(SA1->A1_MUN), oFont11)
   oPrint:Say(nLinha,1700, AllTrim("("+SA1->A1_DDD+")"+SA1->A1_TEL), oFont11)
   
   
   nlinha += 050 
   oPrint:Say(nLinha,110,  OemToAnsi('CNPJ/CPF:'),oFont06)
   oPrint:Say(nLinha,1700, OemToAnsi('Inscri��o:') ,oFont06)
   nlinha += 020
   oPrint:Say(nLinha,110,  AllTrim(cCGC), oFont11)
   oPrint:Say(nLinha,1700, AllTrim(SA1->A1_INSCR), oFont11)
   
 
   //localiza registros 

	DBSelectArea("SD2")      
	DbSetOrder(3)
	DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)
                    
	DBSelectArea("SC5")      
	DbSetOrder(1)
	DbSeek(xFilial("SD2")+SD2->D2_PEDIDO)


	DBSelectArea("SB1")      
	DbSetOrder(2)
	DbSeek(xFilial("SB1")+SD2->D2_COD)	
 
	
	//Define Variaveis zeradas
	nVALOR     := 0          
	cNF        := ""            
	nQtd       := 0                          
   nValorTOTAL := 0
   
   nLinha += 080
   //BOX DETALHES - PRODUTOS
   oPrint:Box(nLinha,100,  nLinha+2300,290) 
   oPrint:Box(nLinha,290,  nLinha+2300,440)
   oPrint:Box(nLinha,440,  nLinha+2300,590)
   oPrint:Box(nLinha,590,  nLinha+2300,1440)
   oPrint:Box(nLinha,1440, nLinha+2300,1840)
   oPrint:Box(nLinha,1840, nLinha+2300,2300)  

   //BOX OBS
   oPrint:Box(nLinha+2300,100, nLinha+2650,1840) 
   oPrint:Say(nLinha+2310,110, OemToAnsi('OBSERVA��ES:')    ,oFont06n)                                         
   oPrint:Say(nLinha+2335,110, substr(SC5->C5_MENNOTA,001,80),   oFont10)
   oPrint:Say(nLinha+2375,110, substr(SC5->C5_MENNOTA,081,80),   oFont10)	
   oPrint:Say(nLinha+2415,110, substr(SC5->C5_MENNOTA,161,80),   oFont10)	   
   oPrint:Say(nLinha+2455,110, substr(SC5->C5_MENNOTA,241,80),   oFont10)	   
   
   //BOX VALOR TOTAL
   oPrint:Box(nLinha+2300,1840, nLinha+2650,2300)

   nLinha += 020
   oPrint:Say(nLinha,110,   OemToAnsi('Codigo')    ,oFont06)
   oPrint:Say(nLinha,300,   OemToAnsi('Quantidade'),oFont06)
   oPrint:Say(nLinha,450,   OemToAnsi('Unidade')   ,oFont06)
   oPrint:Say(nLinha,600,   OemToAnsi('Descri��o dos produtos')   ,oFont06)
   oPrint:Say(nLinha,1650,  OemToAnsi('Valor Unit�rio')   ,oFont06)
   oPrint:Say(nLinha,2050,  OemToAnsi('Valor Total')      ,oFont06)

	DBSelectArea("SD2")      
	DbSetOrder(1)
   nlinha += 030   

   While (SD2->D2_DOC=SF2->F2_DOC .AND. SD2->D2_SERIE=SF2->F2_SERIE)  .and. ! EOF()
	   //MAX: Imprime produtos
	   oPrint:Say(nLinha,110, AllTrim(SD2->D2_COD), oFont11)
	   oPrint:Say(nLinha,300, TRANSFORM(SD2->D2_QUANT, "@E 999.99"), oFont11)
	   DBSelectArea("SB1")
	   DBSetOrder(1)
	   DbSeek(xFilial("SB1")+SD2->D2_COD)
	   oPrint:Say(nLinha,450, AllTrim(SB1->B1_UM),   oFont11)
	   oPrint:Say(nLinha,600, AllTrim(SB1->B1_DESC), oFont11)                 
	   oPrint:Say(nLinha,1600, TRANSFORM((  SD2->D2_PRCVEN ), "@E 999,999.99"), oFont11)
	   oPrint:Say(nLinha,2000, TRANSFORM((  SD2->D2_TOTAL  ), "@E 999,999.99"), oFont11)
	   nQtd        += SD2->D2_QUANT   
	   nValorTotal += SD2->D2_TOTAL   
	   nlinha += 060    
	   DBSelectArea("SD2")              
	   DBSkip()
	EndDo	

   nlinha := 3120 
    

   oPrint:Say(nLinha,2000, OemToAnsi('Valor Total')    ,oFont06n)
   oPrint:Say(nLinha+60,1950, TRANSFORM((nValorTotal) , "@E 999,999,999.99"), oFont11n)
 
	//Observa��es:

   oPrint:Say(nLinha+140,110, OemToAnsi('COND.PAGTO.: ' + SF2->F2_COND + "-"+ Left(POSICIONE("SE4",1,xfilial("SE4")+SF2->F2_COND,"E4_DESCRI"),30 )  )   ,oFont06)      
   oPrint:Say(nLinha+170,110, OemToAnsi('Com base da Lei Complementar n� 116/2003 o item 3.01, institulado como loca��o de bens m�veis, '  )   ,oFont06)
   oPrint:Say(nLinha+200,110, OemToAnsi('foi vetado, e portanto, n�o � fato gerador do ISS. '  )   ,oFont06)
   //Com base da Lei Complementar n� 116/2003 o item 3.01, institulado como loca��o de bens m�veis, foi vetado, e portanto, n�o � fato gerador do ISS.
    
 //Informa��es Adcionais
 //   oPrint:Say(nLinha+030,110, OemToAnsi('VERIFIQUE COM ATEN��O O TRA�O SOLICITADO, RECLAMA��ES POSTERIORES N�O SER�O ACEITAS')    ,oFont06)
 //   oPrint:Say(nLinha+060,110, OemToAnsi('N�O � PERMITIDO ADI��O DE �GUA AP�S A MISTURA DO CONCRETO, DIMINUINDO SUA RESIST�NCIA')    ,oFont06)
 //   oPrint:Say(nLinha+090,110, OemToAnsi('AUTORIZO A ADI��O DE ') ,oFont06)
 //   oPrint:Say(nLinha+090,380, OemToAnsi( SZ1->Z1_AGUARET )       ,oFont08ns) //PAREI AQUI
 //   oPrint:Say(nLinha+090,550, OemToAnsi('       DE �GUA, ASSUMINDO TODA RESPONSABILIDADE')   ,oFont06)
 //   oPrint:Say(nLinha+120,110, OemToAnsi('SOBRE AS CONSEQU�NCIAS NA RESIST�NCIA E QUALIDADE DO CONCRETO. ')    ,oFont06)
 //   oPrint:Say(nLinha+180,110, OemToAnsi('ASSINATURA DO RESPONS�VEL:________________________________________________________')    ,oFont06)
 
    //cADAOBS := ADA->ADA_OBS
    //oPrint:Say(nLinha+120,110, OemToAnsi(   left(cADAOBS    ,50) )  , oFont06 )
    //oPrint:Say(nLinha+150,110, OemToAnsi( SubStr(cADAOBS,051,50) )  , oFont06 )    
    //oPrint:Say(nLinha+180,110, OemToAnsi( SubStr(cADAOBS,101,50) )  , oFont06 )    
    
  
  
NEXT


oPrint:EndPage() // Finaliza a p�gina

Return Nil
