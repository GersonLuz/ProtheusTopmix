#Include "Protheus.ch"
#Include "Rwmake.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} MA020TOK
Função para Validar Inclusão e Alteração de Fornecedores
          
@author 	.iNi Sistemas
@since 		07/08/2014
@version 	P11.5
@obs  
Projeto 	2014002TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------         
User Function MA020TOK()                            

Local cCodFor	:= AllTrim(M->A2_COD)
Local cLojFor	:= AllTrim(M->A2_LOJA)
Local cCNPJFo	:= AllTrim(M->A2_CGC)
Local lOk 		:= .T.

//Chama fun��es...
if ! U_FCNPJSA2()
	Return(.F.)
endIF 
    
If INCLUI
	If !U_FSXVlFoE(cCNPJFo,cCodFor,cCNPJFo)
		lOk := .F.
	Else
		SLEEP(1000)
		If !U_FSXVlFoE(cCNPJFo,cCodFor,cCNPJFo)
			lOk := .F.
		EndIf
	EndIf
EndIf

Return(lOk) 

