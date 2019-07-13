#include "RWMAKE.CH"
#include "PROTHEUS.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINIDESBH
Conjunto de funções para trazer os dados da DESBH

@author    IR
@version   11.8
@since     09/10/2015
@Obs

Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------------------------------
User Function FINIDESBH()
Return(Nil)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINIDBH1
Busca o Código de NF Eletronica da tabela livros fiscais para correto preenchimento nas NFs
de Remessa ao emitir a DESBH.

@author    IR
@version   11.8
@since     09/10/2015
@Obs

Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------------------------------
User Function FINIDBH1(cFilRem,cNumRem,cSerRem)

Local aArea 	:= {GetArea("P02"),GetArea("SC5"),GetArea("SF2")}
Local cNumNFEle := Space(15)
Local cQuery	:= ""

P02->(dbSetOrder(4))
If P02->(dbSeek(AvKey(cFilRem,"P02_FILIAL")+AvKey(cNumRem,"P02_NUM2")+AvKey(cSerRem,"P02_SERIE2")))
	SC5->(dbOrderNickName("FSIND00002"))
	If SC5->(dbSeek(P02->P02_FILIAL+P02->P02_NUM1))
		cQuery := " SELECT F3_NFELETR, F3_EMISSAO "
		cQuery += " FROM "+RetSqlName("SF3")
		cQuery += " WHERE F3_FILIAL = '"+SC5->C5_FILIAL+"'"
		cQuery += " AND F3_NFISCAL = '"+SC5->C5_NOTA+"'"
		cQuery += " AND F3_SERIE = '"+SC5->C5_SERIE+"'"
		cQuery += " AND D_E_L_E_T_ <> '*'"
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"SF3TMP",.F.,.T.)
		
		If !SF3TMP->(EOF())
			cNumNFEle := iIf(!Empty(SF3TMP->F3_NFELETR),Substr(SF3TMP->F3_EMISSAO,1,4)+Substr(SF3TMP->F3_NFELETR,7,19),Space(13))
			//cNumNFEle := iIf(!Empty(SF3TMP->F3_NFELETR),Substr(SF3TMP->F3_EMISSAO,1,4)+SF3TMP->F3_NFELETR,Space(15)) CRISTIANO FERREIRA 21.07.2017
			// INFORMAÇÃO DE DATA DUPLICADA
		EndIf
		
		If Select("SF3TMP") > 0
			SF3TMP->(dbCloseArea())
		EndIf
	EndIf
EndIf                                                       

                 
aEval(aArea,{|n|RestArea(n)})
cNumNFEle := cFilRem+cNumRem+cSerRem
Return(cNumNFEle)
                                                              
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINIDBH2
Busca o valor da NF da tabela livros fiscais para correto preenchimento nas NFs
de Remessa ao emitir a DESBH.

@author    IR
@version   11.8
@since     09/10/2015
@Obs

Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------------------------------
User Function FINIDBH2(cFilRem,cNumRem,cSerRem)

Local aArea 	:= {GetArea("P02"),GetArea("SC5"),GetArea("SF2")}
Local cValNFEle := Space(9)
Local cQuery	:= ""

P02->(dbSetOrder(4))
If P02->(dbSeek(AvKey(cFilRem,"P02_FILIAL")+AvKey(cNumRem,"P02_NUM2")+AvKey(cSerRem,"P02_SERIE2")))
	SC5->(dbOrderNickName("FSIND00002"))
	If SC5->(dbSeek(P02->P02_FILIAL+P02->P02_NUM1))
		cQuery := " SELECT F3_VALCONT "
		cQuery += " FROM "+RetSqlName("SF3")
		cQuery += " WHERE F3_FILIAL = '"+SC5->C5_FILIAL+"'"
		cQuery += " AND F3_NFISCAL = '"+SC5->C5_NOTA+"'"
		cQuery += " AND F3_SERIE = '"+SC5->C5_SERIE+"'"
		cQuery += " AND D_E_L_E_T_ <> '*'"
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"SF3TMP",.F.,.T.)
		
		If !SF3TMP->(EOF())
			cValNFEle := iIf(!Empty(SF3TMP->F3_VALCONT),Transform(SF3TMP->F3_VALCONT,"@R 999999999.99"),Space(9))
		EndIf
		
		If Select("SF3TMP") > 0
			SF3TMP->(dbCloseArea())
		EndIf
	EndIf
EndIf                                                       

                 
aEval(aArea,{|n|RestArea(n)})

Return(cValNFEle)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINIDBH3
Verifica se existe NF amarrada a Remessa ao emitir a DESBH.

@author    IR
@version   11.8
@since     09/10/2015
@Obs

Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------------------------------
User Function FINIDBH3(cFilRem,cNumRem,cSerRem)

Local aArea 	:= {GetArea("P02"),GetArea("SC5"),GetArea("SF2")}
Local lOk 		:= .F.

P02->(dbSetOrder(4))
If P02->(dbSeek(AvKey(cFilRem,"P02_FILIAL")+AvKey(cNumRem,"P02_NUM2")+AvKey(cSerRem,"P02_SERIE2")))
	SC5->(dbOrderNickName("FSIND00002"))
	If SC5->(dbSeek(P02->P02_FILIAL+P02->P02_NUM1))
		If !Empty(SC5->C5_NOTA)
			lOk := .T.
		EndIf
	EndIf
EndIf                                                       
                
aEval(aArea,{|n|RestArea(n)})

Return(lOk)