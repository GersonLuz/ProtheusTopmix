#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSINTP04() 
Grava a chave da NF-e no cabeçalho da nota gerada e na tabela de livros
fiscais (SFT)

@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSINTP04()    
// Grava Chave no SF2
FGrvChvSf2()
// Grava Chave no SFT - Livros fiscais dos Itens
FGrvChvSft()
Return Nil  

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGrvChvSf2() 
Grava a chave da NF-e no cabeçalho da nota gerada

@protected
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FGrvChvSf2()
Local aAreOld			:= GetArea()

RecLock("SF2", .F.)
SF2->F2_CHVNFE	:=	SC5->C5_ZCHVNFE
SF2->F2_FIMP	:=	"S"
SF2->(MsUnLock())		

RestArea(aAreOld)
Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} FGrvChvSft() 
Grava a chave da NF-e na tabela de livros
fiscais de itens (SFT)

@protected
@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FGrvChvSft()
Local aAreOld			:= GetArea()
Local cTipMov			:=	"S"

SFT->(dbSetOrder(1)) // Tipo Mov. + Serie NF + Doc. Fiscal + Cli/Forn. + Codigo loja + Codigo 
SFT->(dbSeek(xFilial("SFT")+cTipMov+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA))

While SFT->(!Eof());
		.And. SFT->FT_FILIAL		==	xFilial("SFT");
		.And. SFT->FT_TIPOMOV	==	cTipMov;
		.And. SFT->FT_SERIE		==	SF2->F2_SERIE;
		.And. SFT->FT_NFISCAL	==	SF2->F2_DOC;
		.And. SFT->FT_CLIEFOR	==	SF2->F2_CLIENTE;
		.And. SFT->FT_LOJA		==	SF2->F2_LOJA    
	RecLock("SFT", .F.)					
	SFT->FT_CHVNFE	:=	SF2->F2_CHVNFE
	SFT->(MsUnLock())
	
	SFT->(dbSkip())
EndDo

RestArea(aAreOld)
Return Nil
          

