#Include "PROTHEUS.CH"   
#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
//--------------------------------------------------------------
/*/{Protheus.doc} AFATR02
Description  
//Envia e-mail para fornecedor
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Jose Antonio                                              
@since 26/02/2013                                                   
/*/                                                                 
    
//--------------------------------------------------------------
***************************************
User Function AFATR02(poWBrowse)       
***************************************
                 
Local oBitmap1                         
Local oBitmap2
Local oGroup1
Local oGroup2
Local oGroup3
Local oSay1
Local oSay2
Local oSay3
Local oSButton1
Local oSButton2   
Local cPerg:="AFATR02"
Local cCotacao   := aWBrowse2[oWBrowse2:nAt,3]
Private aWBrowR02:={} 
Private oWBrowR02
Private oFont1 := TFont():New("Arial",,020,,.T.,,,,,.F.,.F.)
Private oFont2 := TFont():New("Arial",,018,,.T.,,,,,.F.,.F.)
Private oFont3 := TFont():New("Arial",,016,,.F.,,,,,.F.,.F.)
Static oDlg   

CriaPerg(cPerg)                   

IF !Pergunte(cPerg,.T.)       // Pergunta no SX1
   Return
EndIf

If (Alltrim(MV_PAR01) == '000000' .AND. Alltrim(MV_PAR02) == '999999')
MV_PAR01 := cCotacao
MV_PAR02 := cCotacao
Endif                    


  DEFINE MSDIALOG oDlg TITLE "Geração de Cotações" FROM 000, 000  TO 460, 1050 COLORS 0, 16777215 PIXEL

    @ 003, 116 SAY oSay1 PROMPT "Cotações para Envio de e-mail ao Fornecedor" SIZE 200, 011 OF oDlg FONT oFont1 COLORS 32768, 16777215 PIXEL
    @ 016, 002 GROUP oGroup1 TO 230, 524 OF oDlg COLOR 0, 16777215 PIXEL
    aWBrowAux:=fWBrowR02(aWBrowR02)
    DEFINE SBUTTON oSButton1 FROM 214, 251 TYPE 01 ACTION fConfirma(aWBrowAux) OF oDlg ENABLE
    oSButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 
    DEFINE SBUTTON oSButton2 FROM 214, 283 TYPE 02  ACTION oDlg:End() OF oDlg ENABLE
    oSButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 12px; border: 1px solid #585858; } " ) 

  ACTIVATE MSDIALOG oDlg CENTERED

Return

//------------------------------------------------ 
//* Marcas as cotaçoes que sera enviadas para 
// Cotaçao
//------------------------------------------------ 

Static Function fConfirma(aBrow1) //
For x:=1 to Len(aBrow1)          
    If  aBrow1[x,1]
		MsAguarde( {|lEnd|u_AFATR03(aBrow1[x,2],aBrow1[x,3],aBrow1[x,4])},"Aguarde","Enviando e-mail para o fornecedor: "+aBrow1[x,5],.T.)
	Endif	
Next

oDlg:End()

Return(.T.) 


//------------------------------------------------ 
Static Function fWBrowR02(poWBrowse)
//------------------------------------------------ 
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")
	
	aWBrowR02:=fSelecao1()

    If Len(aWBrowR02)=0 
		Aadd(aWBrowR02,{.F.,"","","","","","",""})
    Endif      
    @ 020, 007 LISTBOX oWBrowR02 Fields HEADER "","Cotação","Fornecedor", "Loja Fornec", "Nome Fornec","Email Fornec", "Comprador","Cot Enviada" SIZE 520, 175 OF oDlg FONT oFont3 PIXEL ColSizes 50,50
    oWBrowR02:SetArray(aWBrowR02)
    oWBrowR02:bLine := {|| {;
      If(aWBrowR02[oWBrowR02:nAT,1],oOk,oNo),;
      aWBrowR02[oWBrowR02:nAt,2],;	//Numero Cotacao       2
      aWBrowR02[oWBrowR02:nAt,3],;	//Codigo do fornecedor 3
      aWBrowR02[oWBrowR02:nAt,4],;  //Loja
      aWBrowR02[oWBrowR02:nAt,5],;  //Nome dor fornecedor  5
      aWBrowR02[oWBrowR02:nAt,6];   //Email
    }}
    // DoubleClick event
   	 oWBrowR02:bLDblClick := {|| U_AFAR01(), aWBrowR02[oWBrowR02:nAt,1] := !aWBrowR02[oWBrowR02:nAt,1],oWBrowR02:DrawSelect()} 
   	 //oWBrowR02:Refresh()  // Evento de duplo click na celula


Return(aWBrowR02)

//------------------------------------------------
User Function AFAR01()
//------------------------------------------------

If(oWBrowR02:ColPos() == 6)
 // aWBrowR02[oWBrowR02:nAt,oWBrowR02:ColPos()] := 'sdfd'
 If Len(aWBrowR02) > 0
  lEditCell(@aWBrowR02,oWBrowR02,"",oWBrowR02:ColPos())
 Endif
Elseif Empty(aWBrowR02[oWBrowR02:nAt,1])
  aWBrowR02[oWBrowR02:nAt,1] := oWBrowR02:DrawSelect()  
Endif   
  oWBrowR02:Refresh()

return

//------------------------------------------------ 
Static Function fSelecao1()
//------------------------------------------------ 

Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()                                                                                
Local aWBrowAux := {}     
Local cCodUser  :=RetCodUsr()

	BeginSql Alias cAliasQry
		
		SELECT DISTINCT C8_NUM, C8_FORNECE,C8_LOJA,A2_NOME,C8_ZEMAIL
		FROM %table:SC8% SC8                                                 
		INNER JOIN %table:SA2% SA2 ON SC8.C8_FORNECE = SA2.A2_COD AND SC8.C8_LOJA = SA2.A2_LOJA AND SA2.%notDel%   
		WHERE SC8.%notDel% 	AND            
 	 		SC8.C8_NUM     BETWEEN  %Exp:MV_PAR01%  AND %Exp:MV_PAR02% AND
 	 		SC8.C8_EMISSAO BETWEEN  %Exp:MV_PAR03%  AND %Exp:MV_PAR04% AND	 	  
   			SC8.C8_ZUSER    = %Exp:cCodUser% 	AND   
  			(SC8.C8_ZSTATUS  IN (%Exp:'3'%) OR SC8.C8_ZSTATUS  IN (%Exp:'1'%) ) 
      	ORDER BY C8_NUM,C8_FORNECE                		
  	EndSql   
	(cAliasQry)->( DbGoTop() )
 	While !(cAliasQry)->(EOF())  
        Aadd(aWBrowAux,{.F.,;  						//Flag     		       1
        	(cAliasQry)->C8_NUM,;  				    //Numero Cotacao       2
        	(cAliasQry)->C8_FORNECE,;  				//Codigo do fornecedor 3 
        	(cAliasQry)->C8_LOJA,;     				//Loja  			   4
        	(cAliasQry)->A2_NOME,;     				//Nome dor fornecedor  5
        	(cAliasQry)->C8_ZEMAIL,;   				//Email dor fornecedor 6
        	})                  
        (cAliasQry)->(dbskip())  
	EndDo
	(cAliasQry)->(dbCloseArea())
RestArea(aAliasOLD)
Return(aWBrowAux)  


****************
* Valida pergunta
***
Static Function CriaPerg(cPerg)

Local _sAlias := Alias()
Local aRegs := {}
Local i,j
dbSelectArea("SX1")
dbSetOrder(1)     

aAdd(aRegs,{cPerg,"01","Cotação De   	  ?","","","mv_ch1"  ,"C",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SC8"}) 
aAdd(aRegs,{cPerg,"02","Cotação Até       ?","","","mv_ch2"  ,"C",8,0,0,"G","Eval({||(MV_PAR01<=MV_PAR02)})","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SC8"}) 
aAdd(aRegs,{cPerg,"03","Data Emissão De   ?","","","mv_ch3"  ,"D",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""}) 
aAdd(aRegs,{cPerg,"04","Data Emissão Até  ?","","","mv_ch4"  ,"D",8,0,0,"G","Eval({||(MV_PAR03<=MV_PAR04)})","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""}) 

For i:=1 to Len(aRegs) 
    If SX1->( !MsSeek(padr(cPerg,10)+aRegs[i,2]) )
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
//dbSelectArea(_sAlias)  

Return

