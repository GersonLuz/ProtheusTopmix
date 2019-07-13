#Include "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} AFATP04
Description mostra a lista de solicitações da cotação                                                    
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Jose Antonio (AMM)                                             
@since 06/12/2012                                                   
/*/                                                             
//--------------------------------------------------------------
*********************************
User Function AFATP04(pCod)      
*********************************
                  
Local oBitmap1
Local oBitmap2
Local oGroup1
Local oGroup2
Local oSay1
Local oSay2
Local oSButton1
Local oSButton2
Local pCod := aWBrowse2[oWBrowse2:nAt,3]

Private oFont1 := TFont():New("Arial",,020,,.T.,,,,,.F.,.F.)
Private oFont2 := TFont():New("Arial",,018,,.T.,,,,,.F.,.F.)
Private oFont3 := TFont():New("Arial",,016,,.F.,,,,,.F.,.F.)
Private axWBrowse1 := {}
Private oxWBrowse1
Private aResolu    := getScreenRes()  

Static oDlg

If  Empty(pCod)
	Alert("Cotação Numero não Existe" )
    Return()
Endif

   aSize := MsAdvSize(.F.)
 /*
 MsAdvSize (http://tdn.totvs.com/display/public/mp/MsAdvSize+-+Dimensionamento+de+Janelas)
 aSize[1] = 1 -> Linha inicial área trabalho.
 aSize[2] = 2 -> Coluna inicial área trabalho.
 aSize[3] = 3 -> Linha final área trabalho.
 aSize[4] = 4 -> Coluna final área trabalho.
 aSize[5] = 5 -> Coluna final dialog (janela).
 aSize[6] = 6 -> Linha final dialog (janela).
 aSize[7] = 7 -> Linha inicial dialog (janela).  */    

  DEFINE MSDIALOG oDlg TITLE "Geração de Cotações" FROM aSize[7],0 TO aSize[6],aSize[5] COLORS 0, 16777215 PIXEL

    @ 002, 089 SAY oSay1 PROMPT "Solicitações de Compras" SIZE 114, 011 OF oDlg FONT oFont1 COLORS 32768, 16777215 PIXEL
    If (aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080
    @ 016, 002 GROUP oGroup1 TO 415, 955 OF oDlg COLOR 0, 16777215 PIXEL
    @ 021, 005 SAY oSay2 PROMPT "Solicitações" SIZE 130, 009 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
    @ 029, 004 GROUP oGroup2 TO 413, 951 OF oDlg COLOR 0, 16777215 PIXEL
    fWBrowse1(pCod)
    DEFINE SBUTTON oSButton1 FROM 420, 742 TYPE 15  ACTION Eval({||u_AFATP22("2")})  OF oDlg ENABLE
    oSButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 10px; border: 1px solid #585858; } " )
    DEFINE SBUTTON oSButton2 FROM 420, 770 TYPE 02  ACTION oDlg:End() OF oDlg ENABLE
    oSButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 10px; border: 1px solid #585858; } " )
    Else
    @ 016, 002 GROUP oGroup1 TO 280, 673 OF oDlg COLOR 0, 16777215 PIXEL
    @ 021, 005 SAY oSay2 PROMPT "Solicitações" SIZE 130, 009 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
    @ 029, 004 GROUP oGroup2 TO 277, 669 OF oDlg COLOR 0, 16777215 PIXEL
    fWBrowse1(pCod)
    DEFINE SBUTTON oSButton1 FROM 282, 542 TYPE 15  ACTION Eval({||u_AFATP22("2")})  OF oDlg ENABLE
    oSButton1:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 10px; border: 1px solid #585858; } " )
    DEFINE SBUTTON oSButton2 FROM 282, 570 TYPE 02  ACTION oDlg:End() OF oDlg ENABLE
    oSButton2:SetCSS(	"QPushButton{ background-color: #009ACD; color: #E0FFFF; font-size: 10px; border: 1px solid #585858; } " )
    Endif

  ACTIVATE MSDIALOG oDlg CENTERED

Return

//------------------------------------------------ 
Static Function fWBrowse1(pCod)
//------------------------------------------------ 
axWBrowse1 := {}
                         
    // Insert items here 
    aAUx:=fSelecao1(pCod)    

    If Len(aAUx)=0 
		Aadd(axWBrowse1,{.F.,oFlagVERMELHO,"","","","","",""})
    ElSe
		axWBrowse1:=Aclone(aAUx)
    Endif 

    // Insert items here 
  If (aResolu[1] == 1920 .AND. aResolu[2] == 1080) // MONITOR RESOLUÇÃO 1920 x 1080
    @ 034, 007 LISTBOX oxWBrowse1 Fields HEADER "Empresa","Filial","Num.SC","Produto","Descrição","Quantidade" SIZE 940, 376 OF oDlg FONT oFont3 PIXEL ColSizes 50,50
    oxWBrowse1:SetArray(axWBrowse1)
    oxWBrowse1:bLine := {|| {;
      axWBrowse1[oxWBrowse1:nAt,1],;
      axWBrowse1[oxWBrowse1:nAt,2],;
      axWBrowse1[oxWBrowse1:nAt,3],;
      axWBrowse1[oxWBrowse1:nAt,4],;
      axWBrowse1[oxWBrowse1:nAt,5],;
      axWBrowse1[oxWBrowse1:nAt,6],;
      axWBrowse1[oxWBrowse1:nAt,7],;
      axWBrowse1[oxWBrowse1:nAt,8];
    }}
  Else
   @ 034, 007 LISTBOX oxWBrowse1 Fields HEADER "Empresa","Filial","Num.SC","Produto","Descrição","Quantidade" SIZE 660, 240 OF oDlg FONT oFont3 PIXEL ColSizes 50,50
    oxWBrowse1:SetArray(axWBrowse1)
    oxWBrowse1:bLine := {|| {;
      axWBrowse1[oxWBrowse1:nAt,1],;
      axWBrowse1[oxWBrowse1:nAt,2],;
      axWBrowse1[oxWBrowse1:nAt,3],;
      axWBrowse1[oxWBrowse1:nAt,4],;
      axWBrowse1[oxWBrowse1:nAt,5],;
      axWBrowse1[oxWBrowse1:nAt,6],;
      axWBrowse1[oxWBrowse1:nAt,7],;
      axWBrowse1[oxWBrowse1:nAt,8];
    }}
  Endif  
    // DoubleClick event
    oxWBrowse1:bLDblClick := {|| axWBrowse1[oxWBrowse1:nAt,1] := !axWBrowse1[oxWBrowse1:nAt,1],;
      oxWBrowse1:DrawSelect()}

Return
//------------------------------------------------ 
Static Function fSelecao1(pCotacao)
//------------------------------------------------ 

Local aAliasOLD := GetArea()
Local cAliasQry := GetNextAlias()      
Local cCodUser  := RetCodUsr() 
Local axWBrowse1 := {}    
Local cEmpAux   :=""
Local cFromSC1  := "%"+"SC1"+cEmpAux+"%"
Local cFromSB1  := "%"+"SB1"+cEmpAux+"%"
Local aEmpresa  :={}  

aEmpresa:=u_fSIGAMAT()// Funcao para buscar as empresas

For xE:=1 to Len(aEmpresa)                                       

	cEmpAux  := aEmpresa[xE,1]+"0"	
	cFromSC1 := "%"+"SC1"+cEmpAux+"%"
	cFromSB1 := "%"+"SB1"+cEmpAux+"%"

	cAliasQry := GetNextAlias()  

	BeginSql Alias cAliasQry
	 	SELECT C1_ZEMP,C1_FILIAL, C1_ZSTATUS,C1_ZCLASSI, C1_NUM,C1_PRODUTO, C1_DESCRI,C1_QUANT,SC1.R_E_C_N_O_ AS RECSC1
		FROM %Exp:cFromSC1% SC1                                                 
		INNER JOIN %Exp:cFromSB1% SB1 ON SC1.C1_PRODUTO = SB1.B1_COD AND SB1.%notDel%   
		WHERE SC1.%notDel% 	AND            
    	SC1.C1_COTACAO  = %Exp:pCotacao% 
      	ORDER BY C1_PRODUTO   
      	              		
  	EndSql   
	(cAliasQry)->( DbGoTop() )
 	While !(cAliasQry)->(EOF())  

        Aadd(axWBrowse1,{(cAliasQry)->C1_ZEMP,;  	// Empresal   	1
        	(cAliasQry)->C1_FILIAL,;  				// Filial   	2
        	(cAliasQry)->C1_NUM,;     				// Numero SC  	3
        	(cAliasQry)->C1_PRODUTO,; 				// Produto    	4
        	(cAliasQry)->C1_DESCRI,;  				// Desc Produto 5
        	Transform( (cAliasQry)->C1_QUANT,"@E 999,999,999.99"),;   //Quantidade 6
        	(cAliasQry)->RECSC1,;                    // Recno   7
         (cAliasQry)->C1_FILIAL;                    // Filial   8
        	 })
        (cAliasQry)->(dbskip())  
	EndDo
	
	(cAliasQry)->(dbCloseArea())
                       
Next

RestArea(aAliasOLD)
Return(axWBrowse1)  
                                           
         
