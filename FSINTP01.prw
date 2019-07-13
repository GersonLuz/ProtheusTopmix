#Include "Protheus.ch"   

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSINTP01()
Visualiza os erros gerados na integração KP
        
@author Fernando Ferreira
@since 24/06/2010 
@return Nil
/*/
//---------------------------------------------------------------------------------------
User Function FSINTP01()
Local			aCabTel			:= {}
Private		aRotina			:=	{{"Visualizar", "AxVisual",0, 1}} 
Private 	cCadastro  	:= "Erros Log Integracao KP"
                                                                                       	
AAdd(aCabTel, {"Número Sequencial"		, "P00_ID"  	, "@X",   TamSx3("P00_ID")[1]   		, 0	, ,"","C","",""})
AAdd(aCabTel, {"Filial"						, "P00_FILIAL" , "@!",   TamSx3("P00_FILIAL")[1]	, 0	, ,"","C","",""})
AAdd(aCabTel, {"Filial de Orig."			, "P00_FILORI" , "@!",   TamSx3("P00_FILORI")[1]   , 0	, ,"","C","",""})
AAdd(aCabTel, {"Data do Erro"				, "P00_DATA"  	, ""	,   TamSx3("P00_FILORI")[1]   , 0	, ,"","D","",""})
AAdd(aCabTel, {"Hora do Erro"				, "P00_HORA"  	, "@!",   TamSx3("P00_HORA")[1]   	, 0	, ,"","C","",""})
AAdd(aCabTel, {"Pedido KP"					, "P00_PEDKP"  , "@!",   TamSx3("P00_PEDKP")[1]   	, 0	, ,"","C","",""})
AAdd(aCabTel, {"Rot. Integração"			, "P00_ROTINA" , "@!",   TamSx3("P00_ROTINA")[1]   , 0	, ,"","C","",""})

mBrowse(,,,,"P00",aCabTel)

Return Nil


