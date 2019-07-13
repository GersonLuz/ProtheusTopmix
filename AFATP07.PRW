#Include "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} AFATP07
Description Acompanha as ocorrências da cotação                                                  
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Jose Antonio (AMM)                                             
@since 17/12/2012                                                   
/*/                                                             
//--------------------------------------------------------------
User Function AFATP07(pCotacao)                        
Local oBitmap1
Local oBitmap2
Local oFont1 := TFont():New("Calibri",,022,,.T.,,,,,.F.,.F.)
Local oFont2 := TFont():New("Calibri",,020,,.T.,,,,,.F.,.F.)
Local oFont3 := TFont():New("Calibri",,018,,.T.,,,,,.F.,.F.)
Local oFont4 := TFont():New("Calibri",,018,,.F.,,,,,.F.,.F.)
Local oGroup1
Local oGroup2
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSButton1 
Static oDlg
If  Empty(pCotacao)
	Alert("Cotação Numero não Existe" )
    Return()
Endif

  DEFINE MSDIALOG oDlg TITLE "Acompanhamento Ocorrencias" FROM 000, 000  TO 405, 500 COLORS 0, 16777215 PIXEL

    @ 002, 051 SAY oSay1 PROMPT "OCORRÊNCIAS REGISTRADAS" SIZE 121, 010 OF oDlg FONT oFont1 COLORS 32768, 16777215 PIXEL
    @ 000, 174 BITMAP oBitmap1 SIZE 041, 015 OF oDlg FILENAME "\Imagens\Flapa_Totvs.png" NOBORDER PIXEL
    @ 000, 216 BITMAP oBitmap2 SIZE 032, 015 OF oDlg FILENAME "\Imagens\TopMix_Totvs.png" NOBORDER PIXEL
    @ 016, 001 GROUP oGroup1 TO 187, 248 OF oDlg COLOR 0, 16777215 PIXEL
    @ 022, 157 SAY oSay2 PROMPT "Número da Cotação" SIZE 077, 009 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
    @ 023, 219 SAY oSay3 PROMPT pCotacao SIZE 024, 007 OF oDlg FONT oFont4 COLORS 0, 16777215 PIXEL
    @ 022, 004 SAY oSay4 PROMPT "Listagem das Ocorrências" SIZE 109, 010 OF oDlg FONT oFont2 COLORS 128, 16777215 PIXEL
    @ 031, 004 GROUP oGroup2 TO 181, 244 OF oDlg COLOR 0, 16777215 PIXEL
    fWBrowse1(pCotacao)
    DEFINE SBUTTON oSButton1 FROM 189, 221 TYPE 01 ACTION oDlg:End() OF oDlg ENABLE

  ACTIVATE MSDIALOG oDlg CENTERED

Return

//------------------------------------------------ 
Static Function fWBrowse1(pCotacao)
//------------------------------------------------ 
Local oWBrowse17
Local aWBrowse17 := {}

    // Insert items here 
    aAUx:=fSelecao1(pCotacao)    

    If Len(aAUx)=0 
		Aadd(aWBrowse17,{"","","","","",""})
    ElSe
		aWBrowse17:=Aclone(aAUx)
    Endif 

    // Insert items here 
  //  Aadd(aWBrowse17,{"Filial","Numero da SC","Descrição","Data Ocorrencia","Hora Ocorrencia"})
    @ 036, 007 LISTBOX oWBrowse17 Fields HEADER "Filial","No da Solicitação","Descrição","Data Ocorrencia","Hora Ocorrencia","Solicitante" SIZE 235, 141 OF oDlg PIXEL ColSizes 50,50
    oWBrowse17:SetArray(aWBrowse17)
    oWBrowse17:bLine := {|| {;
      aWBrowse17[oWBrowse17:nAT,1],;
      aWBrowse17[oWBrowse17:nAt,2],;
      aWBrowse17[oWBrowse17:nAt,3],;
      aWBrowse17[oWBrowse17:nAt,4],;
      aWBrowse17[oWBrowse17:nAt,5],;
      aWBrowse17[oWBrowse17:nAt,6];
    }}                            
Return
//------------------------------------------------ 
Static Function fSelecao1(pCotacao)
//------------------------------------------------ 

Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()      
Local cCodUser  := RetCodUsr() 
Local aWBrowse17 := {}    
	BeginSql Alias cAliasQry    
		COLUMN Z2_DATA AS DATE
	 	SELECT DISTINCT Z2_FILIAL, Z2_NUMSC,Z2_NOMEUSR,Z2_CODIGO,Z3_DESC, Z2_DATA, 
	 	(SELECT MAX(Z2_HORA) AS HORA FROM %table:SZ2% Z2 WHERE SZ2.Z2_FILIAL=Z2.Z2_FILIAL AND SZ2.Z2_NUMCOT=Z2.Z2_NUMCOT AND SZ2.Z2_CODIGO=Z2.Z2_CODIGO AND SZ2.Z2_DATA=Z2.Z2_DATA AND Z2.%notDel%) AS Z2_HORA
		FROM %table:SZ2% SZ2                                                 
		LEFT JOIN %table:SZ3% SZ3 ON SZ2.Z2_CODIGO = SZ3.Z3_CODIGO AND SZ3.%notDel%   
		WHERE SZ2.%notDel% 	AND            
    	SZ2.Z2_NUMCOT  = %Exp:pCotacao% 
      	ORDER BY Z2_FILIAL,Z2_DATA,Z2_HORA DESC  
      	              		
  	EndSql   
	(cAliasQry)->( DbGoTop() )
 	While !(cAliasQry)->(EOF())  

        Aadd(aWBrowse17,{;
        	(cAliasQry)->Z2_FILIAL,;  				// Filial   		1
        	(cAliasQry)->Z2_NUMSC,;     			// Numero SC  		2
        	(cAliasQry)->Z3_DESC,; 					// Descricao da ocorrencia 3
        	(cAliasQry)->Z2_DATA,;  				// Data da ocorrencia  4
        	(cAliasQry)->Z2_HORA,;                  // Hora da ocorrencia  5     
        	(cAliasQry)->Z2_NOMEUSR;                // Nome do usuario  6
        	 })
        (cAliasQry)->(dbskip())  
	EndDo
	
	(cAliasQry)->(dbCloseArea())

RestArea(aAliasOLD)
Return(aWBrowse17)  
                                           
         
 
