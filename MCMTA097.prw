#INCLUDE "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} MCMTA097
Liberar pedido de compras

Controle de Aprovacao : CR_STATUS -->                
01 - Bloqueado p/ sistema (aguardando outros niveis) 
02 - Aguardando Liberacao do usuario                 
03 - Pedido Liberado pelo usuario                    
04 - Pedido Bloqueado pelo usuario                   
05 - Pedido Bloqueado por outro usuario              

@param  
@author Rodrigo Carvalho
@since  02/02/2016
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
User Function MCMTA097(cAlias, nRegSCR , nOpcX , par01 , par02 , par03 , par04 )

Local aAliasOLD    := GetArea()
Local ca097User
Local cFiltraSCR
Local cFitroUs     := ""
local lFiltroUs1   :=.T. 
Local aCoresUsr    := {}
Local cFilQuery    := "" 
Local cFilQry      := "" 
Local lAtvFiltro   := .F.
Local lSai
Local aCores       := {{ 'CR_STATUS== "01"', 'BR_AZUL' },;   //Bloqueado p/ sistema (aguardando outros niveis)
						     { 'CR_STATUS== "02"', 'DISABLE' },;   //Aguardando Liberacao do usuario
   					     { 'CR_STATUS== "03"', 'ENABLE'  },;   //Pedido Liberado pelo usuario
  						     { 'CR_STATUS== "04"', 'BR_PRETO'},;   //Pedido Bloqueado pelo usuario
  						     { 'CR_STATUS== "05"', 'BR_CINZA'} }   //Pedido Bloqueado por outro usuario

Private bFilSCRBrw := {|| Nil}
Private cCadastro  := OemToAnsi("Liberação de Pedido de Compra") // 
Private cXFiltraSCR

ca097User := RetCodUsr()    

dbSelectArea("SAK")
dbSetOrder(2)

If ! MsSeek(xFilial("SAK") + ca097User)

	Help(" ",1,"A097APROV")
	dbSelectArea("SCR")
	dbSetOrder(1)
	
Else

	If lAtvFiltro
      FFiltroC8(@cFiltraSCR,@cFilQry)
   EndIf             

   aRegSCR := {}
   
   If nOpcX == 3 // liberar registros

    	dbSelectArea("SCR")
      dbCommit()
      FListaRegs(@aRegSCR)
    	dbSelectArea("SCR")
    	
   Else
      
      aAdd(aRegSCR,nRegSCR)      
      
   Endif
   
   For nXy := 1 To Len(aRegSCR)

       nRegSCR := aRegSCR[nXy]  
       DbSelectArea("SCR")
       DbGoto(nRegSCR)
   
       If ! Empty(SCR->CR_NUM)
          DbSelectArea("SC7")
          DbSetOrder(1)
          DbSeek(xFilial("SC7") + Alltrim(SCR->CR_NUM))
      Endif

      If ! Empty(SC7->C7_NUMCOT)
         DbSelectArea("SC8")
         DbSetOrder(1)
         DbSeek(xFilial("SC8") + SC7->(C7_NUMCOT + C7_FORNECE + C7_LOJA) , .T.)
      Endif
   
      If ! Empty(SC7->C7_NUMSC)
         DbSelectArea("SC1")
         DbSetOrder(1)
         DbSeek(xFilial("SC1") + SC7->C7_NUMSC , .T. )
      Endif
   
      cFilOld := cFilAnt
      cFilAnt := SCR->CR_FILIAL
   
      Do Case
         Case nOpcX == 1
              A097Consulta("SCR",nRegSCR,2)           
         Case nOpcX == 2  

              //oBrwSC1:SetFilter Default( "SC1->C1_NUM == SC7->C7_NUMSC" )
              //oBrwSC1:ChangeTopBot(.T.)
              
              DbSelectArea("SC1")
              cAuxFilter := "(SC1->C1_NUM == SC7->C7_NUMSC)" 
              aIndexSC1  := {}
              bFiltraBrw := {|| FilBrowse("SC1",@aIndexSC1,@cAuxFilter) }
              Eval(bFiltraBrw)   
              SET FILTER TO &(cAuxFilter)   

              //oBrwSC8:SetFilter Default( "SC8->C8_NUM == SC7->C7_NUMCOT" )
              //oBrwSC8:ChangeTopBot(.T.)

              DbSelectArea("SC8")
              cAuxFilter := "(SC8->C8_NUM == SC7->C7_NUMCOT)" 
              aIndexSC8  := {}
              bFiltraBrw := {|| FilBrowse("SC8",@aIndexSC8,@cAuxFilter) }
              Eval(bFiltraBrw)   
              SET FILTER TO &(cAuxFilter)   

              cFilOld := cFilAnt
              cFilAnt := SC7->C7_FILIAL
   
              A097Visual("SCR",nRegSCR,2)
           
              cFilAnt := cFilOld 
             	
              //oBrwSC1:SetFilter Default( cFilterSC1 )
              //oBrwSC1:ChangeTopBot(.T.)
              
              DbSelectArea("SC1")
              cAuxFilter := "("+cFilterSC1+")" 
              aIndexSC1  := {}
              bFiltraBrw := {|| FilBrowse("SC1",@aIndexSC1,@cAuxFilter) }
              Eval(bFiltraBrw)   
              SET FILTER TO &(cAuxFilter)

              //oBrwSC8:SetFilter Default( cFilterCT )
              //oBrwSC8:ChangeTopBot(.T.)

              DbSelectArea("SC8")
              cAuxFilter := "("+cFilterCT+")" 
              aIndexSC8  := {}
              bFiltraBrw := {|| FilBrowse("SC8",@aIndexSC8,@cAuxFilter) }
              Eval(bFiltraBrw)   
              SET FILTER TO &(cAuxFilter)

              DbSelectArea("SCR")
              DbGoto(nRegSCR)
           
         Case nOpcX == 3
              A097Libera("SCR",nRegSCR,4)
         Case nOpcX == 4
              A097Superi("SCR",nRegSCR,4)
         Case nOpcX == 5
              A097Transf("SCR",nRegSCR,4)
         Case nOpcX == 6
              A097Ausente("SCR",nRegSCR,3)
         Case nOpcX == 7
              A097Estorna("SCR",nRegSCR,4)
         Case nOpcX == 8
              A097Legend()
      EndCase
   
   Next
   
   DbSelectArea("SCR")
   If Len(aRegSCR) > 0
      DbGoto(aRegSCR[1]) 
   Endif
      
   cFilAnt := cFilOld
	
EndIf

SysRefresh()
RestArea(aAliasOLD)

Return Nil






//--------------------------------------------------------------
/*/{Protheus.doc} FFiltroC8

@param  
@author Rodrigo Carvalho
@since  24/03/2016
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
Static Function FListaRegs(aRegSCR)

Local cQuery := "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("SCR")+" WHERE CR_OK = '"+cMarkSCR+"' ORDER BY CR_NUM"
Local aArea  := GetArea()

cQuery := ChangeQuery(cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , "SCRMARK" , .T. , .F.)

DbSelectArea("SCRMARK")
DbGotop()

Do While ! SCRMARK->(Eof())
   aAdd(aRegSCR,SCRMARK->(RECNO))
   SCRMARK->(DbSkip())
Enddo 
  
DbSelectArea("SCRMARK")
DbCloseArea()
RestArea(aArea)

Return .T.






//--------------------------------------------------------------
/*/{Protheus.doc} FFiltroC8

@param  
@author Rodrigo Carvalho
@since  24/03/2016
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
Static Function FFiltroC8(cFiltraSCR,cFilQry)

		dbSelectArea("SCR")
		dbSetOrder(1)   

 		if cFiltraSCR==nil
 		   cFiltraSCR  := 'CR_FILIAL=="'+xFilial("SCR")+'"'+'.And.CR_USER=="'+ca097User
 		   cFilQry     := " CR_FILIAL='"+xFilial("SCR")+"' AND CR_USER='"+ca097User+"'"
   	endIf		
   	    
   	Do Case
			Case mv_par01 == 1
				cFiltraSCR += '".And.CR_STATUS=="02"'
				cFilQry    += " AND CR_STATUS='02' "
			Case mv_par01 == 2
				cFiltraSCR += '".And.(CR_STATUS=="03".OR.CR_STATUS=="05")'
				cFilQry    += " AND (CR_STATUS='03' OR CR_STATUS='05') "
			Case mv_par01 == 3
				cFiltraSCR += '"'
				cFilQry    += " "
			OtherWise
				cFiltraSCR += '".And.(CR_STATUS=="01".OR.CR_STATUS=="04")'
				cFilQry    += " AND (CR_STATUS='01' OR CR_STATUS='04' ) "
		EndCase
	
		If ExistBlock("MT097FIL" )
			If ValType( cFiltroUs := ExecBlock( "MT097FIL", .f., .f. ) ) == "C"
				cFiltraSCR += " .And. " + cFiltroUs
			EndIf
		EndIf		
	
		If ExistBlock("MT097QRY")
			cFilQuery := AllTrim(ExecBlock("MT097QRY",.F.,.F.))
			If Valtype(cFilQuery) <> "C"
				cFilQuery := cFilQry
			Else
				cFilQuery:=cFilQry+" "+cFilQuery							
			EndIf                    
		Else
			bFilSCRBrw 	:= {|| FilBrowse("SCR",@aIndexSCR,@cFiltraSCR) }
			Eval(bFilSCRBrw)
		EndIf					

Return .T.