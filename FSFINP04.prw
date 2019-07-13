#Include "Protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINP04
Função chamada pelo ponto de entrada F590REC para utilizar o E1_ZBANCO
como filtro na geração dos borderôs.


@author Fernando dos Santos Ferreira 
@since 27/09/2011 
@version P11
@obs  
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFINP04()
Local cIdx		:= ""
Local cChv		:= ""
Local cFil  	:= ""  
Local cNomPrg	:= "FINP04"+AllTrim(xFilial())

Local	aPrg		:= {}
Local	aRet		:= {}
aAdd(aPrg,{2,"Mostra Lançamento Contábil?"	,1, {"Sim", "Não"}, 50,'.T.',.T.})							// [1]
aAdd(aPrg,{2,"Mostra Lançamento Contábil?"	,1, {"Sim", "Não"}, 50,'.T.',.T.})							// [2]
aAdd(aPrg,{2,"Contabiliza Transferência?" 	,1, {"Sim", "Não"}, 50,'.T.',.T.})							// [3]
aAdd(aPrg,{2,"Considera Rentenção Bancária?" ,2, {"Sim", "Não"}, 50,'.T.',.T.})							// [4]
aadd(aPrg,{1,"Do Banco"			,CriaVar("SE1->E1_ZBANCO")   ,"@!","" ,"SA6","",50 ,.F.}) 				// [5]
aadd(aPrg,{1,"Ate o Banco"		,CriaVar("SE1->E1_ZBANCO")   ,"@!","" ,"SA6","",50 ,.T.}) 				// [6]

aPrg[01][03] := ParamLoad(cNomPrg,aPrg,01,aPrg[01][03])
aPrg[02][03] := ParamLoad(cNomPrg,aPrg,02,aPrg[02][03])
aPrg[03][03] := ParamLoad(cNomPrg,aPrg,03,aPrg[03][03])
aPrg[04][03] := ParamLoad(cNomPrg,aPrg,04,aPrg[04][03])
aPrg[05][03] := ParamLoad(cNomPrg,aPrg,05,aPrg[05][03])
aPrg[06][03] := ParamLoad(cNomPrg,aPrg,06,aPrg[06][03])

If !ParamBox(aPrg,"Parametros",aRet,,,,,,,cNomPrg,.T.,.T.) 
	Return Nil	
EndIf

cChv  	:= SE1->(IndexKey())
cFil		:= "E1_ZBANCO >= '"+aRet[5]+"' .And. E1_ZBANCO <='"+aRet[6]+"'"
cIdx 		:= CriaTrab( Nil,.F. )

IndRegua( "SE1",cIdx,cChv,,cFil,"Selecionando Registros..." )

Return Nil


