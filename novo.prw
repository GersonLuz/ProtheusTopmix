#Include "Protheus.ch"
#Include "Rwmake.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} A010TOK
Função para Validar Inclusão e Alteração de Produto
          
@author 	.iNi Sistemas
@since 		07/08/2014
@version 	P11.5
@obs  
Projeto 	2014002TOPM
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------         
User Function A010TOK()                            

Local cCodPrd	:= AllTrim(M->B1_COD)
Local lRet     := .T.

If  M->B1_TIPO=="CC"
		MsgStop("CUIDADO!!! Esse tipo de Produto só pode ser cadastrado pelo Laboratório Tecnológico, favor encerrar seu cadastro")
    /*If fUserGpr("000012")
       lRet := .T.     
    Else  
       MsgStop("Você não tem permissão para movimentar produtos pertencente a este grupo!!!!")
	    lRet := .F.
    EndIf*/
EndIf
                   
If lRet //-- .iNi Sistemas - Valida existencia do produto em outras empresas.
	If INCLUI
		If !(M->B1_GRUPO == '9999')
			If !U_FSXVlPrE(cCodPrd)
				lRet := .F.
			Else
				SLEEP(1000)
	           	If !U_FSXVlPrE(cCodPrd)
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet) 

/*
+-----------+------------+----------------+-------------------+-------+---------------+
| Programa  |            | Desenvolvedor  | Max Rocha         | Data  | 17/01/2012    |
+-----------+------------+----------------+-------------------+-------+---------------+
| Descricao | valida inclusao do produto                                              |
+-----------+-------------------------------------------------------------------------+
|                  Modificacoes desde a construcao inicial                            |
+----------+-------------+------------------------------------------------------------+
| DATA     | PROGRAMADOR | MOTIVO                                                     |
+----------+-------------+------------------------------------------------------------+
+----------+-------------+------------------------------------------------------------+
*/
Static Function fUserGpr(pGrupo)  
Local  	lRet:=.F.
 
For x:=1 to Len(USRRETGRP())     
  If USRRETGRP()[x] $ pGrupo
      lRet:=.T.
  EndIf
Next   
                            
Return(lRet)