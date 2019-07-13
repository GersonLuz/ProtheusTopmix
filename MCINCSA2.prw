#Include "Protheus.ch"
#Include "Rwmake.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} MCINCSA2()
Inclusao do fornecedor(caso seja prefeitura sera alterado o codigo
do cadastro para o CC2_IDKP.
          
@author 	 Rodrigo Carvalho
@since 	 26/04/2016
@obs      Query utilizada para atualizar o idkp a partir do betomix.
@Valid    Acrescentar na validação do usuario (dicionario de dados)
          A2_NOME		texto() .AND. U_MCINCSA2()
          A2_COD_MUN	U_MCINCSA2()
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------         
User Function MCINCSA2()                         

Local lRet       := .T.
Local aArea      := GetArea() 
Local lPrefeitur := SuperGetMv("MC_CADPREF",,.T.)

If INCLUI .And. lPrefeitur
   If "PREFEITURA" $ UPPER(M->A2_NOME)
      If ! Empty(M->A2_COD_MUN) .And. ! Empty(M->A2_EST)
         DbSelectArea("CC2")
         DbSetOrder(1) // CC2_FILIAL+CC2_EST+CC2_CODMUN
         If DbSeek(xFilial("CC2") + M->A2_EST + M->A2_COD_MUN) .And. Type("CC2->CC2_IDKP") <> "U"
            If ! Empty(CC2->CC2_IDKP)
               M->A2_COD  := Left(CC2->CC2_IDKP,6)
               M->A2_LOJA := "00"
               SysRefresh()                             
               MsgBox("Código do fornecedor será alterado para o IDKP! - "+Left(CC2->CC2_IDKP,6),"Cadastro de Prefeituras","Info")
            Else
               Alert("O código do municipio não possui o IDKP na tabela CC2, informe ao analista! (CC2_IDKP não informado)")
               lRet := .f.
            Endif
         Else
            Alert("Para o cadastro de PREFEITURA é necessário ter o campo CC2_IDKP (ID do municipio no KP)!")
            lRet := .f.
         Endif
      Endif
   Else
      If Val(M->A2_COD) < 100000
         Alert("O código informado está incorreto! Abaixo de 100000 somente [Prefeituras]")
         lRet := .f.
      Endif  
   Endif
Endif

RestArea(aArea)

Return lRet

