#INCLUDE "PROTHEUS.CH"
#Include "Rwmake.ch"
#Include "TopConn.ch"

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                   
---------------------------------------------------------------------------------------- 
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 20/08/2017    - 
---------------------------------------------------------------------------------------- 
                                   PROGRAMA: TPGPE002                                  -
---------------------------------------------------------------------------------------- 
                      FUNÇÃO PARA INFORMAR MATRICULA FUNCIONARIO                       - 
---------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------*/ 

*************************************
User Function TPGPE002()
*************************************

Local nTamFil := TamSX3("RA_MAT")[1]                  		
Private cQuery, cMaxNum, cNumMat

//Busca maior numero de pedido da empresa
cQuery := "SELECT MAX(RA_MAT) AS RA_MAT "
cQuery += "FROM " + RetSqlName("SRA") + " SRA "
cQuery += "WHERE SRA.D_E_L_E_T_ = ''"

TcQuery cQuery Alias TMP New
DbSelectArea("TMP")
DbGotop()

cMaxNum := ++ Val(TMP->RA_MAT)
	
	if (cMaxNum < 10)
	  cMaxNum	:= "00000" + CVALTOCHAR(cMaxNum) // Entre número 1 ao 9
	else
	 if (cMaxNum < 100) 
	   cMaxNum	:= "0000" + CVALTOCHAR(cMaxNum)  // Entre número 10 ao 99
	 else
	  if (cMaxNum < 1000)  
	    cMaxNum	:= "000" + CVALTOCHAR(cMaxNum)   // Entre número 100 ao 999
	  else
	   if (cMaxNum < 10000)  
	     cMaxNum	:= "00" + CVALTOCHAR(cMaxNum)    // Entre número 1000 ao 9999
	   else
	    if (cMaxNum < 100000)  
	      cMaxNum	:= "0" + CVALTOCHAR(cMaxNum)     // Entre número 10000 ao 99999
	    else
	      cMaxNum	:= CVALTOCHAR(cMaxNum)          // Maior que 100000 
	    endif  
	   endif
	  endif 
	 endif
	endif
		
		TMP->(DbCloseArea())
		
			RollBackSXE()
		
			DbUseArea(.T., __LocalDriver, "SXE", "SXE_MAT", .T.,.F.)                                                      •
		
			DbSelectArea("SXE_MAT")
			DbGoTop()
			While !Eof()
				If RTrim(XE_FILIAL) == Space(nTamFil)+"\MAT01"
		
					RecLock("SXE_MAT",.F.)
		   	       SXE_MAT->XE_NUMERO := cMaxNum
			       MsUnlock()
		
					Exit
		
				EndIf
		
				DbSelectArea("SXE_MAT")
				DbSkip()
			End
		
			SXE_MAT->(DbCloseArea()) 
			
			cNumMat := cMaxNum

Return(cNumMat)