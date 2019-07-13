#INCLUDE "PROTHEUS.CH"
#Include "Rwmake.ch"
#Include "TopConn.ch"

/*-------------------------------------------------------------------------------------- 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            -                                                   
---------------------------------------------------------------------------------------- 
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ---          DATA: 22/09/2017    - 
---------------------------------------------------------------------------------------- 
                                   PROGRAMA: TPFIS001                                  -
---------------------------------------------------------------------------------------- 
                FUNÇÃO PARA INFORMAR DADOS DO CLIENTE OBRA A PARTIR DA REMESSA         - 
---------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------*/ 

*************************************
User Function TPFIS001(nCampo)
*************************************  

/*
1 - SA1->A1_INSCRM
2 - SA1->A1_INSCR
3 - SA1->A1_NOME
4 - SA1->A1_PESSOA
5 - SA1->A1_CGC
6 - SA1->A1_END
7 - SA1->A1_BAIRRO
8 - SA1->A1_CEP
9 - SA1->A1_COD_MUN
*/
                                                                        
Local cNota    := SF3->F3_NFISCAL
Local cDtaNfe  := DTOS(SF3->F3_ENTRADA)
Private cCampo := ""
   
	dbSelectArea("SC5")
	// C5_FILIAL+DTOS(C5_EMISSAO)+C5_NOTA+C5_SERIE
	SC5->(dbOrderNickName("TPSC500001"))
	If SC5->(dbSeek(xFilial("SC5")+cDtaNfe+cNota))
	 SA1->(dbSetOrder(01))
	 If SA1->(dbSeek(xFilial("SA1")+SC5->C5_CLIOBRA+SC5->C5_LOJOBRA)) 
		 If (nCampo == 1)
		  cCampo := SA1->A1_INSCRM
		   if Empty(cCampo)
		   cCampo := '0'
		   endif
		 	Elseif (nCampo == 2)
		  	 cCampo := SA1->A1_INSCR
		  	 if Empty(cCampo)
		    cCampo := '0'
		    endif
		 	  Elseif (nCampo == 3)
		      cCampo := SA1->A1_NOME
		       Elseif (nCampo == 4)
		        cCampo := SA1->A1_PESSOA
		         Elseif (nCampo == 5)
		          cCampo := SA1->A1_CGC
		           Elseif (nCampo == 6)
		            cCampo := SA1->A1_END
		             Elseif (nCampo == 7)
		              cCampo := SA1->A1_BAIRRO
		               Elseif (nCampo == 8)
		                cCampo := SA1->A1_CEP
		                 Elseif (nCampo == 9)
		                  cCampo := SA1->A1_COD_MUN
		                  cCampo := IIF(cCampo == SUBSTR(SM0->M0_CODMUN,3,7) ,"S","N")
		                   Elseif (nCampo == 10)
                          cCampo := SC5->C5_OBRA
	    Endif	 
	 Endif
	Endif

return(cCampo)