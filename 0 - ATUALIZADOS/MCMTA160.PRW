#INCLUDE "PROTHEUS.CH"

#DEFINE CAB_ARQTMP  01
#DEFINE CAB_POSATU  02
#DEFINE CAB_SAYGET  03
#DEFINE CAB_HFLD1   04
#DEFINE CAB_HFLD2   05
#DEFINE CAB_HFLD3   06
#DEFINE CAB_MARK    07 
#DEFINE CAB_GETDAD  08                     
#DEFINE CAB_COTACAO 09
#DEFINE CAB_MSMGET  10
#DEFINE CAB_ULTFORN 11
#DEFINE CAB_HISTORI 12

//--------------------------------------------------------------
/*/{Protheus.doc} MCMTA160

Chamadas das rotinas padrões do protheus para o compras

@param  
@author Rodrigo Carvalho
@since  04/01/2016
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------

User Function MCMTA160( cAlias, nRegSC8 , nOpcAuto )   

Local aFixe 	:= {{"Dt Validade " , "C8_VALIDA " },;
						 {"Numero      " , "C8_NUM    " },;
						 {"Fornecedor  " , "C8_FORNECE" },;
						 {"Loja Fornec." , "C8_LOJA   " }}
						
Local cCotACC	:= "(SC8->(FieldPos('C8_ACCNUM'))>0 .And. !Empty(SC8->C8_ACCNUM) .And. Empty(SC8->C8_NUMPED))"

Local aCores	:= {{"!" +cCotACC +".And.Empty(C8_NUMPED).And.C8_PRECO<>0.And.!Empty(C8_COND)",'ENABLE' },;	//Cotacao em aberto
					    {"!Empty(C8_NUMPED)",'DISABLE'},;					//Cotacao Baixada
						 {'!' +cCotACC +' .And. C8_PRECO==0 .And. Empty(C8_NUMPED)','BR_AMARELO'},;	//Cotacao nao digitada
						 {cCotACC,'BR_AZUL'}} //Cotação em compra através do portal ACC

Local aAliasOLD    := GetArea()
Local aGrupo	    := UsrGrComp(RetCodUsr())
Local bBlock
Local cFiltraSC8   := ""
Local cFilSC8QRY   := ""
Local cFilUser	    := ""
Local cFilUserQry  := ""
Local lSolic	    := GetMv("MV_RESTCOM")=="S"
Local lFiltra      := .F.
Local lFilUser	    := ExistBlock("MT160FIL")
Local lFilUserQry  := ExistBlock("MT160QRY")
Local nPos
Local nCntFor   	 := 0
Local cAliasSC8    :="SC8"   

Private aCabecCst	 := {} //{"",0,Array(31,2),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil}
Private aListBox   := {}
Private aPOSOBJ3   := {}
Private aColsSC8   := {}
Private aPlanilha  := {}
Private aCotacao   := {}
Private aCpoSC8    := {}

Private aLegenda   := {	{"ENABLE",'Cotação em Aberto'},{"DISABLE",'Cotação Baixada'},{"BR_AMARELO",'Cotação não digitada'} } 
Private cCadastro  := "Analise das Cotações"
Private l160Auto	 := .F.
Private lOnUpdate  := .T.
Private aAutoCab	 := {}
Private aAutoItens := {}
Private aSelManual:= {}
                     
Private lTrm       := .F.
Private xAutoCab   := {}
Private xAutoItens := {}
Private aRotina	 := {{"Pesquisar" , "Pesqbrw"    , 0 , 1, 0, .F.},;
                       {"Visual"    , "A160Analis" , 0 , 2, 0, nil},;
                       {"Analisar"  , "A160Analis" , 0 , 6, 8, nil},;
                       {"Legenda"   , "A160Legenda", 0 , 5, 0, .F.}}

Private lSysTrk    := .F.   

If ! FVerCOTOK(nRegSC8)
   Return .T.
Endif   

If lChk
   Pergunte("MTA160",.T.)
Else
   Pergunte("MTA160",.F.)
Endif
MV_PAR01 := 2

DbSelectArea("SC8")
DbGoto(nRegSC8)

//cFilOld := cFilAnt
//cFilAnt := SC8->C8_FILIAL
	
SetKey( VK_F12 ,{|| Pergunte("MTA160",.T.)})

lSolic  := If(MV_PAR06==1,lSolic,.F.)
lFiltra := MV_PAR07==1
lFiltra := IIF(lSysTrk,.F.,lFiltra)
	
cFilSC8QRY := "C8_FILIAL='"+xFilial("SC8")+"' And "
cFilSC8QRY += "C8_NUM = '"+Space(Len(SC8->C8_NUM))+"'"

nOpcAuto := 6 // analizar cotação.

nPos := Ascan(aRotina,{|x| x[4] == nOpcAuto})
		
If ( nPos # 0 )
  // bBlock := &( "{ |x,y,z,k,m| " + aRotina[ nPos,2 ] + "(x,y,z,k,m) }" )
  // Eval( bBlock,Alias(),nRegSC8,nPos,Nil)
EndIf

If Empty(SC8->C8_NUMPED)
   
   nRegSC1 := SC1->(Recno())
   //oBrwSC1:SetFilter Default( "SC1->C1_COTACAO == "+SC8->C8_NUM+" .And. SC1->C1_FILIAL == "+xFilial("SC1") )
   //oBrwSC1:ChangeTopBot(.T.)
   //oBrwSC1:Refresh()

   DbSelectArea("SC1")
   cAuxFilter := "("+"SC1->C1_COTACAO == '"+SC8->C8_NUM+"' .And. SC1->C1_FILIAL == '"+xFilial("SC1")+"')"   
   aIndexSC1  := {}
   bFiltraBrw := {|| FilBrowse("SC1",@aIndexSC1,@cAuxFilter) }
   Eval(bFiltraBrw)   
   SET FILTER TO &(cAuxFilter) 
   
   //A160Analis("SC8",nRegSC8,nPos) // Chamada da rotina
   MATA160()
   //MONTACOT("SC8",nRegSC8,nPos)
   
   //oBrwSC1:SetFilter Default( cFilterSC1 )
   //oBrwSC1:ChangeTopBot(.T.)
   //oBrwSC1:Refresh()

   DbSelectArea("SC1")
   cAuxFilter := "("+cFilterSC1+")" 
   aIndexSC1  := {}
   bFiltraBrw := {|| FilBrowse("SC1",@aIndexSC1,@cAuxFilter) }
   Eval(bFiltraBrw)   
   SET FILTER TO &(cAuxFilter)
   
   DbSelectArea("SC1")
   DbGoto(nRegSC1)
   
Endif

Set Key VK_F12 TO

DbSelectArea("SC8")
DbGoto(nRegSC8)

//cFilAnt := cFilOld
RestArea(aAliasOLD)

SysRefresh()

Return(.T.)

//--------------------------------------------------------------
/*/{Protheus.doc} FVerCOTOK

@param  
@author Rodrigo Carvalho
@since  04/03/2016
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
Static Function FVerCOTOK(nRegSC8)

Local lRetSC8   := .T.
Local cQuery    := ""
Local cAliasTRB := GetNextAlias() 
Local cMensagem := ""
Local aArea     := GetArea()

cQuery  := "SELECT C8_PRODUTO, C8_FORNECE, C8_LOJA"
cQuery  += "  FROM "+RetSqlName("SC8")
cQuery  += " INNER JOIN (SELECT C8_FILIAL FILIAL, C8_NUM COTACAO"
cQuery  += "               FROM "+RetSqlName("SC8")
cQuery  += "              WHERE R_E_C_N_O_ = "+Alltrim(Str(nRegSC8))
cQuery  += "                AND D_E_L_E_T_ <> '*') FILTRO "
cQuery  += "    ON C8_FILIAL = FILIAL"
cQuery  += "   AND C8_NUM    = COTACAO"
cQuery  += "   AND (C8_PRECO = 0 OR C8_TOTAL = 0)"
cQuery  += " WHERE D_E_L_E_T_ <> '*'"

cQuery := ChangeQuery(cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasTRB , .T. , .F.)

DbSelectArea(cAliasTRB)
Do While (cAliasTRB)->(!EOF())
   cMensagem += (cAliasTRB)->("Produto: "+Alltrim(C8_PRODUTO)+" do Fornecedor: "+C8_FORNECE+"/"+C8_LOJA)+CRLF
   lRetSC8 := .F.      
   (cAliasTRB)->(DbSkip())
Enddo   

DbSelectArea(cAliasTRB)
DbCloseArea()
RestArea(aArea)
 
If ! lRetSC8       
   Aviso("Atenção","Os produtos da cotação: "+SC8->C8_NUM+" ainda não foram atualizados!"+CRLF+cMensagem,{"OK"},3)
 	If MsgYesNo("Deseja continuar assim mesmo S/N?")
    	lRetSC8 := .t.
 	Endif
Endif

Return( lRetSC8 )  



