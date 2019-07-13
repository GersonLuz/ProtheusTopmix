#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FSNxtCod
Obtem próximo sequêncial numérico efetuando controle de lock.  
Para o controle de lock, foi utilizada a função MayIUseCode

@author        .iNi Sistemas
@since         13/08/2014

@param         cAlias		Alias da tabela desejada Ex.: SB1
@param         cCampo		Campo que contem o sequencial Ex.: B1_COD
@param         cChave		Prefixo do sequencial. Ex.: M->B1_GRUPO
@param         nTamSeq		Tamanho do sequêncial

@Obs
Exemplos de uso: 
->Código do produto B1_COD será formado pelo campo B1_GRUPO + sequencial de 4 dígitos.
	* Criar um gatilho no campo B1_GRUPO com regra: U_FSGetCod("SB1","B1_COD",M->B1_GRUPO,4)
	
->Código do produto B1_COD será formado pelo campo B1_GRUPO+B1_TIPO + sequencial de 2 dígitos.
	* Criar um gatilho no campo B1_GRUPO com regra: U_FSGetCod("SB1","B1_COD",M->B1_GRUPO+M->B1_TIPO,2)	

->Código do grupo BM_GRUPO será formado pelo campo BM_TIPGRU + sequencial de 4 dígitos.
	* Criar um gatilho no campo BM_TIPGRU com regra: U_FSGetCod("SBM","BM_GRUPO",M->BM_TIPGRU,4)

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     	Motivo

/*/
//-------------------------------------------------------------------
User Function FSNxtCod(cAlias,cCampo,cChave,nTamSeq)

Local 	aArea 	:= GetArea()
Local	cCod	:= ""
Local 	cQuery 	:= ""	
Local 	nTotal 	:=0

cQuery := "SELECT MAX("+cCampo+") AS CODIGO FROM "+RetSqlName(cAlias)+" WHERE D_E_L_E_T_ <> '*' "
If !Empty(cChave)
	cQuery += "AND "+cCampo+" LIKE '"+cChave+"%' "
EndIf

TcQuery cQuery New Alias "TMPQRY"
	
dbSelectArea("TMPQRY")
cCod := ALLTRIM(TMPQRY->CODIGO)
	
TMPQRY->(dbEval({|| nTotal++}))
FSCloseTab("TMPQRY")
	
RestArea(aArea)

If nTotal > 0 
	cCod := cChave+StrZero(Val(SUBSTR(cCod,Len(cChave)+1,nTamSeq))+1,nTamSeq)
		
	Do while !MayIUseCode(cCod)
		cCod := cChave+StrZero(Val(SUBSTR(cCod,Len(cChave)+1,nTamSeq))+1,nTamSeq)
	Enddo      
Else
	cCod := cChave+StrZero(1,nTamSeq)
Endif

Return cCod                         
    
/*{protheus.doc} FSCloseTab
Fecha a Tabela temporaria em uso
@param Recebe o alias da tabela em uso 
*/
Static Function FSCloseTab(cTabela)

	dbSelectArea(cTabela)
	dbCloseArea(cTabela)
	
	If File(cTabela+GetDBExtension())
		FErase(cTabela+GetDBExtension())
	EndIf	
	
Return