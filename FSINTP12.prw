#include "protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSINTP12
Processo de exclusão Endereços relacionados ao cliente
          
@author Fernando Ferreira
@since 25/10/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSINTP12(cEndFil, cCliCod, cCliLoj)
Local		aAreOld	:=	{P01->(GetArea())}
Local		lRet	:= .T.  

Default	cEndFil	:=	""
Default	cCliCod	:=	""
Default	cCliLoj	:=	""

P01->(dbSetOrder(1))
P01->(dbSeek(cEndFil+cCliCod+cCliLoj))

While P01->(!Eof())	.And. P01->P01_FILIAL	==	cEndFil;
							.And. P01->P01_COD		== cCliCod;
							.And.	P01->P01_LOJA		== cCliLoj 
							
	RecLock("P01",P01->(Eof()))
	P01->(dbDelete())
	P01->(MsUnlock())	
	U_FSEndInt("E")								
	P01->(dbSkip())							
EndDo							
           
aEval(aAreOld, {|xAux| RestArea(xAux)})
Return lRet                            


