#Include "rwmake.ch"
#include "protheus.ch"
//-------------------------------------------------------------------
/* {Protheus.doc} MCPRCTAB

@protected
@author    Rodrigo Carvalho
@since     24/03/2016
@obs       Verifica o preco da tabela na atualizacao do preco
           IIf(ExistBlock( "MCPRCTAB" ) , ExecBlock( "MCPRCTAB", .F., .F. ) , .T. )                

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function MCPRCTAB()

Local aAreaSC8  := GetArea("SC8")
Local aArea     := GetArea()      
Local cForSC8   := ""
Local cLojSC8   := ""
Local cVigencia := " - Não informado."
Local lRet      := .T.
Local cTabPrc   := ""
Local lAchou    := .F.
Local cPrdSC8   := ""
Local nFreteSC8 := 0
Local nQtdeSC8  := 0
Local nVldDesc  := 0
Local nPosPrd   := 0
Local nPosFrt   := 0
Local nPosQtd   := 0
Local nPosDes   := 0

If Type("aCols") <> "A" .Or. Type("aHeader") <> "A" .Or. Len(aHeader) == 0 .Or. Type("N") <> "N" .Or. N <= 0 .Or. Type("CA150FORN") == "U"
   Return .T.
Endif   

nPosPrd := aScan( aHeader,{|x| AllTrim(x[2])=="C8_PRODUTO"})
nPosFrt := aScan( aHeader,{|x| AllTrim(x[2])=="C8_VALFRE" })
nPosQtd := aScan( aHeader,{|x| AllTrim(x[2])=="C8_QUANT"}) 
nPosDes := aScan( aHeader,{|x| AllTrim(x[2])=="C8_VLDESC"})
cForSC8 := CA150FORN
cLojSC8 := CA150LOJ  

If nPosPrd == 0 .Or. nPosFrt == 0 .Or. nPosQtd == 0 .Or. nPosDes == 0
   Aviso("Tabela de Preços","Campo não localizado: "+;
   IIf(nPosPrd == 0,"Campo Produto,","")+IIf(nPosFrt == 0,"Campo Frete,","")+IIf(nPosQtd == 0,"Campo Quantidade,","")+IIf(nPosDes == 0,"Campo Desconto",""),;
   {"OK"},3)
   Return .T.
Endif   

cPrdSC8   := aCols[n][nPosPrd]
nFreteSC8 := aCols[n][nPosFrt]
nQtdeSC8  := aCols[n][nPosQtd]
nVldDesc  := aCols[n][nPosDes]

DBSelectArea("AIA")
DbSetOrder(1)
DBSeek(xFilial("AIA") + cForSC8 + cLojSC8, .T.) 

Do While ! AIA->(Eof()) .And. xFilial("AIA") + cForSC8 + cLojSC8 == AIA->(AIA_FILIAL + AIA_CODFOR + AIA_LOJFOR)

   If Empty(AIA->AIA_DATDE) .And. Empty(AIA->AIA_DATATE) 
      cTabPrc := AIA->AIA_CODTAB
      Exit
   Endif 
     
   If AIA->AIA_DATDE <= Date() .And. (AIA->AIA_DATATE >= Date() .Or. Empty(AIA->AIA_DATATE))
      cTabPrc := AIA->AIA_CODTAB     
      cVigencia := "De: "+DtoC(AIA->AIA_DATDE)+" Até: "+DtoC(AIA->AIA_DATATE)
      Exit
   Endif          

   DBSelectArea("AIA")
   AIA->(DbSkip())
   
Enddo 

If ! Empty(cTabPrc) 

   DBSelectArea("AIB")
   DbOrderNickName("AIBUSR1") //AIB_FILIAL+AIB_CODPRO+AIB_CODFOR+AIB_LOJFOR+AIB_CODTAB

   If DBSeek(xFilial("AIB") + cPrdSC8 + cForSC8 + cLojSC8 + cTabPrc , .T.)

      Do While ! AIB->(Eof()) .And. xFilial("AIB") + cPrdSC8 + cForSC8 + cLojSC8 + cTabPrc == AIB->(AIB_FILIAL+AIB_CODPRO+AIB_CODFOR+AIB_LOJFOR+AIB_CODTAB)
         If AIB->AIB_DATVIG >= Date() .Or. Empty(AIB->AIB_DATVIG)
            lAchou = .T.
            Exit
         Endif 
         AIB->(DbSkip())
      Enddo

      If lAchou

         DbSelectArea("SB1")
         DbSetOrder(1)
         DbSeek(xFilial("SB1") + cPrdSC8 , .T. )

         //avaliar se o preço unitario da nota esta dentro do valor minimo e maximo de aceite.
         nValUnit   := Round((Round(nQtdeSC8 * M->C8_PRECO,2) - nVldDesc) / nQtdeSC8,2) 
         nVlrMinPrc := Round(Round(AIB->AIB_PRCCOM,5) * ( 1 - (SuperGetMv("TM_TMINPRC",,10) / 100 )),5) // valor minimo do preco com 5 decimais
         nVlrMaxPrc := Round(Round(AIB->AIB_PRCCOM,5) * ( 1 + (SuperGetMv("TM_TMAXPRC",,10) / 100 )),5) // valor maximo do preco com 5 decimais
         nVlrMinFrt := Round(Round(AIB->AIB_FRETE ,5) * ( 1 - (SuperGetMv("TM_TMINFRT",, 3) / 100 )),5) // valor minimo do frete com 5 decimais
         nVlrMaxFrt := Round(Round(AIB->AIB_FRETE ,5) * ( 1 + (SuperGetMv("TM_TMAXFRT",, 3) / 100 )),5) // valor maximo do frete com 5 decimais

         If nValUnit < nVlrMinPrc .Or. nValUnit > nVlrMaxPrc

   	     Aviso("Contrato Fornecedor",;
                 "Valor informado diferente da tabela de preços para esse fornecedor."+CRLF+;
                 "Tabela: "+cTabPrc+" - Vigência: "+cVigencia+CRLF+;
                 "Produto: "+Alltrim(SB1->B1_COD)+ " " +Alltrim(SB1->B1_DESC)+" - vigência: "+DtoC(AIB->AIB_DATVIG)+CRLF+;
                 "Valor Unit Informado: "+Transform(nValUnit,"@E 999,999.999999")  +CRLF +;
                 "Valor minimo Aceito: "+Transform(nVlrMinPrc,"@E 999,999.999999") +CRLF+;			           	
                 "Valor maximo Aceito: "+Transform(nVlrMaxPrc,"@E 999,999.999999"),{"OK"},3)
                 lRet := .F.

         Endif

   	   If nFreteSC8 > 0 // verificar além do preço unitario, também o valor do frete.
   	      If AIB->AIB_FRETE <= 0
   	         ApMsgAlert("O valor do frete foi informado na NOTA mas não consta o valor do frete na tabela de preços. Campo: AIB_FRETE!")  
   	         lRet := .F.
            Endif
	         If ! (Round(nFreteSC8/nQtdeSC8,5) >= nVlrMinFrt .And. Round(nFreteSC8/nQtdeSC8,5) <= nVlrMaxFrt)// se o FRETE não estiver entre o minimo e o maximo (frete/qtde)
                 Aviso("Cálculo do Frete","Foram encontradas inconformidades no VALOR DO FRETE: "           +CRLF +;
                       "Tabela: "+cTabPrc+" - Vigência: "+cVigencia+CRLF+;              
                       "Produto: "+Alltrim(SB1->B1_COD)+ " " +Alltrim(SB1->B1_DESC)+" - vigência: "+DtoC(AIB->AIB_DATVIG)+CRLF +;
                       "Frete/Qtde Informado: "+Transform(Round(nFreteSC8/nQtdeSC8,5),"@E 999,999.999999")  +CRLF +;
                       "Valor minimo Aceito: " +Transform(nVlrMinFrt,"@E 999,999.999999") +" "+;			           	
                       "Valor maximo Aceito: " +Transform(nVlrMaxFrt,"@E 999,999.999999"),{"OK"},3)
			        lRet := .F.           
            Endif              
   	   EndIf		      		
      Else
         Aviso("Tabela de Preços","Não há tabela de preços vigente para esse produto/fornecedor na tabela: "+cTabPrc,{"OK"},3)
      Endif		   	
  Endif

Endif

RestArea(aArea)
RestArea(aAreaSC8)

Return( lRet )