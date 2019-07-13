#Include "Protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINP01
Função chamada pelo ponto de entrada M460FIM para atualização do 
SE1->E1_ZBOLETO


@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFINP01()      
                                   
Local aAreOld	:=	{GetArea("SC5"), GetArea("SD2"), GetArea("SF2")}
Local	cGerBol	:= ""

SC5->(dbSetOrder(1))//Filial+Pedido		
SC5->(dbSeek(xFilial("SC5")+SD2->D2_PEDIDO))		
If SC5->(!Eof()) .And. SC5->C5_FILIAL == xFilial("SC5") .And. SC5->C5_NUM == SD2->D2_PEDIDO
	cGerBol	:=	SC5->C5_ZBOLETO
EndIf
	
SE1->(dbSetOrder(2))//Filial+Cliente+Loja+Serie+Doc
SE1->(dbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_PREFIXO+F2_DOC)))
	
While SE1->(!Eof())	.And.;
 	SE1->E1_FILIAL		== xFilial("SE1")		.And.;
 	SE1->E1_CLIENTE 	== SF2->F2_CLIENTE	.And.;
 	SE1->E1_LOJA		== SF2->F2_LOJA 		.And.;
 	SE1->E1_PREFIXO  	== SF2->F2_PREFIXO	.And.;
 	SE1->E1_NUM 		== SF2->F2_DUPL

	If	AllTrim(Upper(SE1->E1_TIPO)) == "NF"
		SE1->(RecLock("SE1",.F.))
		SE1->E1_ZBOLETO := cGerBol
		SE1->(MsUnlock())			
	EndIf
	
	SE1->(dbSkip())
EndDo

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return Nil


