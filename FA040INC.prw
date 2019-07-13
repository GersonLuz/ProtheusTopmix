#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FA040INC
Valida a inclusão do titulo

@author Giulliano Santos
@since  19/03/2012 
@version P11
@obs  

        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FA040INC()

Local lRetFun := .T.    
//campos acrescentados Juliana
Local cGrupPro   :=GetMv("MV_GRUPRA")
Local lGrupPro   :=fUserGpr(cGrupPro)                

Local lRetUsu    :=lRetRA

//If IsInCallStack("FINA040")  
If FunName()=="FINA040" 
	//funcao validacao do grupo do usuario Juliana.
	/*If  Len(UsrRetGrp()) == 0   
		   MsgStop("A inclusão do (RA) deverá ser realizada somente pela rotina de PRE-RECEBIMENTO!!!")  
	      lRetFun :=.F.   
	Endif
   */
	IF !lRetUsu .And. lRetFun .And. ALLTRIM(M->E1_TIPO)=="RA"
	     MsgStop("Tipo RA (recebimento antecipado)somente pela rotina PRE - RECEBIMENTO")  
        lRetFun :=.F.
        Return lRetFun        
   EndIf
   
EndIf

lRetFun := u_FSFINP11() //alterado em 20/03. Rodrigo Carvalho. (executava somente para o funcoes do contas a receber)


Return lRetFun

************************************************
* Pesquisa de grupo de usuario validar liberacao
***        
Static Function fUserGpr(pGrupo)
Static lRetRA:=.F.
 
For x:=1 to Len(USRRETGRP())     
  If USRRETGRP()[x] $ pGrupo
 	  cGrupUse :=USRRETGRP()[x] 
      lRetRA:=.T.
   Endif
Next   
                            
Return(lRetRA)
