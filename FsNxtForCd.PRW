#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FSNxtForCd
Obtem próximo sequêncial numérico do fornecedor

@author        .iNi Sistemas
@since         13/08/2014

/*/
//-------------------------------------------------------------------
User Function FSNxtForCd(nTipo)

Local aArea	  := GetArea("SYA")
Local	cCod	  := iIf(nTipo == 1,"",M->A2_COD)
Local cLoja	  := iIf(nTipo == 1,"",M->A2_LOJA)
Local cQuery  := ""

If nTipo == 2
	//-- Verifica se já existe código de fornecedor para CNPJ                                                        
	cQuery := "SELECT A2_COD AS CODIGO, A2_LOJA AS LOJA FROM "+RetSqlName("SA2")+" WHERE D_E_L_E_T_ <> '*' "
	cQuery += "AND A2_CGC <> '' AND SUBSTRING(A2_CGC,1,8) = '"+SubStr(M->A2_CGC,1,8)+"' AND LEN(A2_CGC) > 11 ORDER BY A2_COD, A2_LOJA"
	                                            
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQRY",.F.,.F.)  
					
	If !TMPQRY->(Eof())
		cLoja := SubStr(M->A2_CGC,11,2)
		cCod := ALLTRIM(TMPQRY->CODIGO)
		lExist := .F.
		TMPQRY->(dbEval({||lExist := .T.},{|| TMPQRY->LOJA == SubStr(M->A2_CGC,11,2)}))
		TMPQRY->(dbGotop())
		If lExist
			lAchou := .F.
		    nLoja := 0
		    Do While !lAchou
	            If StrZero(nLoja,2) <> TMPQRY->LOJA
			    	cLoja := StrZero(nLoja,2) 
					lAchou := .T.
				EndIf
				nLoja++
				TMPQRY->(dbSkip())
			EndDo
		EndIf
		//-- Grava novos valores.       
		M->A2_COD := cCod
		M->A2_LOJA := cLoja
	Else
		M->A2_LOJA := IIf(Len(Alltrim(M->A2_CGC)) == 14,SubStr(M->A2_CGC,11,2),"00")
	EndIf
	TMPQRY->(dbCloseArea())
EndIf

If nTipo == 1

	cQuery := " SELECT MAX(A2_COD) AS CODIGO FROM SA2010 WHERE "
	cQuery += " A2_COD LIKE '1%' AND LEN(RTRIM(A2_COD)) = 6"
	cQuery += " UNION "	                                                    
	cQuery += " SELECT MAX(A2_COD) AS CODIGO FROM SA2020 WHERE "
	cQuery += " A2_COD LIKE '1%' AND LEN(RTRIM(A2_COD)) = 6"
	cQuery += " ORDER BY CODIGO DESC "
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQRY",.F.,.F.)  
		
	cCod := ALLTRIM(TMPQRY->CODIGO)
	
	If Mod(Val(SubStr(cCod,Len(cCod)-1,1)),2) > 0 
		cCod := StrZero(Val(cCod)+2,6)
	Else
		cCod := StrZero(Val(cCod)+1,6)
	EndIf
			
	Do While !MayIUseCode(cCod)
		cCod := StrZero(Val(cCod)+2,6)
	Enddo                         
	
	TMPQRY->(dbCloseArea())
EndIf

RestArea(aArea)
		
Return(cCod)