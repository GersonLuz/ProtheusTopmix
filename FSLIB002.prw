#include "protheus.ch"

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSLIB002
Fun��o criada para efeitos de compatibilidade evitando que seja criada uma fun��o com o 
nome deste prw.
         
@author 	Luciano M. Pinto
@since 		23/08/2011
@version 	P11

/*/ 
//---------------------------------------------------------------------------------------
User Function FSLIB002()
/****************************************************************************************
* Fun��o criada para efeitos de compatibilidade evitando que seja criada uma fun��o com o 
* nome deste prw.
*
***/
Return Nil   

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} FSVldPrc
Fun��o respons�vel por fazer a valida��o do campo RV_ZORPREC - Ordem de Precedencia 
Projeto do Ponto Eletronico

@author 	Luciano M. Pinto
@since 	23/08/2011
@version P11
@return	lRetFun		Verdadeiro ou Falso

/*/ 
//---------------------------------------------------------------------------------------
User Function FSVldPrc(nTipo)
/****************************************************************************************
*
*
*
***/
Local lRetFun	:= .T.
Local aArea		:=	GetArea()


If (M->RV_ZCSCOMP == "N") .OR. (M->RV_TIPOCOD == "2")
	
	If nTipo == 2 //Campo Considera Compensa��o Zera order de Precedencia
		M->RV_ZORPREC := CriaVar("RV_ZORPREC")
	End If
	
	lRetFun := .T.
	
Else
	
	If Empty(M->RV_ZORPREC)
				
		Alert("O campo Preced�ncia n�o poder� ser vazio !")
		lRetFun := .F.
		
	Else
		
		dbSelectArea("SRV")
		dbOrderNickName("FSINDSRV")
		dbSeek(xFilial("SRV") + M->RV_ZCSCOMP + M->RV_ZORPREC)
		
		If SRV->(!Eof()) .And. (SRV->RV_TIPOCOD == '1') .And. (SRV->RV_COD <> M->RV_COD)
			
			Alert("Ja existe um registro com esta Preced�ncia !")
			lRetFun	:= .F.
			
		End If
		
	End If
	
End If
	
RestArea(aArea)

Return(lRetFun)