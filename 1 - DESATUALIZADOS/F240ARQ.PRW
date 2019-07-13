#include "protheus.ch" 
#include "msole.ch" 

//------------------------------------------------------------------- 
/*/{Protheus.doc}  
Ponto de Entrada da Rotina FINA240 retorna Filtro dos Borderos.

@protected	
@author		Ederson Colen
@since		21/06/2012
@version 	P11
@obs			Desenvolvimento Atendimento Pontual
				Chamada da Tela de filro e retorno dos borderos que seram gerados no arquivo
				e Filtro no arquivo SEA para agilizar o processo de gravação dos dados no arquivo.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/                                                                                          
//------------------------------------------------------------------ 

User Function F240ARQ()

Local cVldPerg := PADR('FIN240',10)
Local nContPer := 0
Local lExiPerg := .F.

Local cIndexSEA := ""
Local cFiltSEA  := ""
Local nIndex    := 0
Private lSaiTela := .F.
Private nRecno  
Public lAchou   := .T.

//Busca o numero do Parâmetro de Data Pagamento Bordero.
SX1->(dbseek(cVldPerg))

While SX1->(! Eof()) .And. SX1->X1_GRUPO == cVldPerg

   If AllTrim(SX1->X1_PERGUNT) == "Data Pagamento Bordero?"
      nContPer := Val(Right(AllTrim(SX1->X1_VAR01),2))-1
		lExiPerg := .T.
		EXIT
	EndIf
	nContPer += 1

	SX1->(dbSkip())

EndDo

nContPer += 1

Pergunte("FINA240",.F.)    

//Verificar se a variável foi criada se não é que não foi chamada pela rotina SIFINE03
If (Type('cFilBord') = "U" .Or. cFilBord = Nil)
   //	Aviso("A T E N C A O","Ha Rotina FINA300 foi encapsulada e o menu não esta configurado corretamente. Favor entrar em contato com a TI e solicitar que o menu seja corrigido chamando a Rotina SIFINE03.",{"OK"})
	cFilBord := ""
EndIf

//Chama a Tela de Filtro dos Borderos e retorna o Filtro que será utilizado no Ponto de Entrada F240FILTC.
If (Type('lSispag') = 'U' .Or. lSispag = Nil)
MsgAlert("Favor selecionar os Parâmetros.")
Else  
 If (lSispag)  
	If ! lExiPerg
   	cFilBord := U_SIFINP01("FINA300",MV_PAR01,MV_PAR02,"341")
	Else
   	cFilBord := U_SIFINP01("FINA300",MV_PAR01,MV_PAR02,"341",&("MV_PAR"+StrZero(nContPer,2)))
	EndIf	
	
	//Foi incluido este filtro pois estava passando todos os borderos com isso agilizando o processo.
	//No fonte ja existe um tratamento que retorna a tabela sem filtro.
 	nRecno := Recno()
  	cIndexSEA  := CriaTrab(nil,.f.)
	cFiltSEA := ' EA_FILIAL == "'+xFilial("SEA")+'" .And. '
	cFiltSEA += ' EA_NUMBOR $ '+Iif(Empty(cFilBord),'""',cFilBord)
  	IndRegua("SEA",cIndexSEA,SEA->(IndexKey(1)),,cFiltSEA,"Selecionando Registros...")
 	dbSelectArea("SEA") 
	dbSetOrder(1)
	dbGoTop(nRecno)  
 Endif      
Endif                                                                      
                
Return (lAchou)