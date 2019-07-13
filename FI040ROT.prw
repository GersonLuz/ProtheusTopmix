#Include "Protheus.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} FI040ROT
Imprime notas de saida  - Imprime notas fiscais de serviço
        
@author Giulliano Santos
@since 31/10/2011 
@version P11      
@return aArray	Opções adicionais no protocolo.
@obs 
Projeto FS005495 
Ponto de entrada utiliza a funçãoFSFINR07
 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FI040ROT

Local aArray := {} 

aArray := aClone(PARAMIXB)
FMenDef(@aArray)

Return aArray


//------------------------------------------------------------------- 
/*/{Protheus.doc} FMenDef() 
Insere um item na rotina 

@protected
@author Giulliano Santos
@since 31/10/2011 
@version P11
@obs 
Projeto FS005495
 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FMenDef(aArray)  

aAdd( aArray,{"Protocolo","U_FSFINR07",0,15}) // Gerar protocolo

Return Nil                  


//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINR07() 
Gera o protocolo

@author Giulliano Santos
@since 31/10/2011 
@version P11
@obs 
Projeto FS005495
 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function FSFINR07()

Local wnrel		:= Nil
Local cString	:= "SE1"
Local cTit		:= "Protocolo"
Local cNmPrg	:= "FSFINR01"                               
Local Tamanho	:= "M" 
	
Private nLastKey:=0
Private aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }

//Definindo o relatório
wnrel := SetPrint(cString,cTit,"",@cTit,"", "", "",.F.,.F.,.F.,Tamanho,,.F.)
	
If nLastKey != 27
	SetDefault(aReturn,cString)                                        
	RptStatus({|| FPrcRel()})	
	Set Device To Screen
	If aReturn[5] == 1
	   Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif
		MS_FLUSH()
	Endif		
	
Return Nil       


//------------------------------------------------------------------- 
/*/{Protheus.doc} FPrcRel() 
Gera o protocolo

@protected
@author Giulliano Santos
@since 31/10/2011 
@version P11
@obs 
Projeto FS005495
 
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
Static Function FPrcRel()   

Local cCliente := CriaVar("A1_NOME" , .F.)
Local cEndCob	:= ""
Local aAreas  := {SC5->(GetArea()), SA1->(GetArea()) , CC2->(GetArea()), GetArea()}
Local nLinRel := 0 
Local cMunCc2 := ""

cCliente := Posicione("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA, "A1_NOME")

SC5->(dbSetOrder(1))

If (SC5->(dbSeek(SE1->(E1_FILORIG + E1_PEDIDO))))
	
	CC2->(dbSetOrder(1))
	If (CC2->(dbSeek(xFilial("CC2") + SC5->C5_ZEST + SC5->C5_ZMUN )))
	    cMunCc2 := CC2->CC2_MUN  
	EndIf

	cEndCob  := AllTrim(SC5->C5_ZENDCOB) + " , " + AllTrim(SC5->C5_ZENDNUM) + " , " + AllTrim(SC5->C5_ZBAIROC) + " , " + AllTrim(SC5->C5_ZCOMPLE) + " , " +	cMunCc2

Else
    Alert("Endereço de cobrança não encontrado para este titulo!")
EndIf


@ nLinRel++,00 PSAY SM0->M0_NOMECOM
@ nLinRel++,00 PSAY "MOTOBOY          : _________________________________________________________"
@ nLinRel++,00 PSAY "DESTINATARIO     : " + cCliente
@ nLinRel++,00 PSAY "ENDERECO         : " + cEndCob 
@ nLinRel++,00 PSAY "NUMERO DA FATURA : " + SE1->E1_NUM
@ nLinRel++,00 PSAY "VENCIMENTO       : " + U_FSAjuDat(SE1->E1_VENCTO) + " / "+ SE1->E1_PARCELA
@ nLinRel++,00 PSAY "DATA EMISSAO     : " + U_FSAjuDat(SE1->E1_EMISSAO)



@ nLinRel++,00 PSAY "OBS              : " + Iif(Posicione("SC5",6,xFilial("SC5") + SE1->E1_NUM+SE1->E1_SERIE,"C5_RECISS")=="1", "RETEM ISS", "NAO RETEM ISS")
@ nLinRel++,00 PSAY "DATA DA ENTREGA  : __/__/____"

nLinRel += 2

@ nLinRel++,00 PSAY "_________________________________________________"
@ nLinRel++,00 PSAY "         ASSINATURA COM NOME LEGIVEL             "


aEval(aAreas, {|x|RestArea(x)})   
Return Nil


          