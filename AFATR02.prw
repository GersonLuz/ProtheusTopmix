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
User Function AFATR02(poWBrowse)                        
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
Private aWBrowR02:={} 
Private oWBrowR02
Private oFont1 := TFont():New("Calibri",,022,,.T.,,,,,.F.,.F.)
Private oFont2 := TFont():New("Calibri",,020,,.T.,,,,,.F.,.F.)
Private oFont3 := TFont():New("Calibri",,018,,.F.,,,,,.F.,.F.)
Static oDlg   

CriaPerg(cPerg)                   

IF !Pergunte(cPerg,.T.)       // Pergunta no SX1
   Return
EndIf                    
 

  DEFINE MSDIALOG oDlg TITLE "Geração de Cotações" FROM 000, 000  TO 460, 850 COLORS 0, 16777215 PIXEL

    @ 003, 096 SAY oSay1 PROMPT "COTAÇÕES PARA ENVIO DE E-MAIL AO FORNECEDOR" SIZE 100, 011 OF oDlg FONT oFont1 COLORS 32768, 16777215 PIXEL
    @ 016, 002 GROUP oGroup1 TO 230, 420 OF oDlg COLOR 0, 16777215 PIXEL
    aWBrowAux:=fWBrowR02(aWBrowR02)
    DEFINE SBUTTON oSButton1 FROM 214, 241 TYPE 01 ACTION fConfirma(aWBrowAux) OF oDlg ENABLE
    DEFINE SBUTTON oSButton2 FROM 214, 269 TYPE 02  ACTION oDlg:End() OF oDlg ENABLE
    @ 001, 218 BITMAP oBitmap1 SIZE 041, 015 OF oDlg FILENAME "\Imagens\Flapa_Totvs.png" NOBORDER PIXEL
    @ 001, 262 BITMAP oBitmap2 SIZE 034, 016 OF oDlg FILENAME "\Imagens\TopMix_Totvs.png" NOBORDER PIXEL

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
//Local oWBrowR02
Local aWBrowR02 := Aclone(poWBrowse)
	
	aWBrowR02:=fSelecao1()

    If Len(aWBrowR02)=0 
		Aadd(aWBrowR02,{.F.,"","","","","","",""})
    Endif      
    @ 020, 007 LISTBOX oWBrowR02 Fields HEADER "","Cotação","Fornecedor", "Loja Fornec", "Nome Fornec","Email Fornec", "Comprador","Cot Enviada" SIZE 410, 175 OF oDlg FONT oFont3 PIXEL ColSizes 50,50
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
   	 oWBrowR02:bLDblClick := {|| aWBrowR02[oWBrowR02:nAt,1] := !aWBrowR02[oWBrowR02:nAt,1],oWBrowR02:DrawSelect()} 
   	 oWBrowR02:Refresh()  // Evento de duplo click na celula

Return(aWBrowR02)

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
  			SC8.C8_ZSTATUS  IN (%Exp:'3'%)  AND  
   			SC8.C8_ZUSER    = %Exp:cCodUser%   
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

