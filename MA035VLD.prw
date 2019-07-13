#Include "Protheus.ch"
#Include "Rwmake.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} MA035VLD
Função para Validar Inclusão e Alteração de Grupo de Produto
          
@author 	.iNi Sistemas
@since 		07/08/2014
@version 	P11.5
@obs  
Projeto 	2014002TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------         
User Function MA035VLD()                            

Local nOpc 		:= PARAMIXB[1] 
Local cCodGrp	:= AllTrim(M->BM_GRUPO)
Local lOk 		:= .T.

If nOpc == 3
	If !U_FSXVlGrE(cCodGrp)
		lOk := .F.
	Else
		SLEEP(1000)
		If !U_FSXVlGrE(cCodGrp)
			lOk := .F.
		EndIf
	EndIf
EndIf

Return(lOk) 