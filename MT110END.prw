#INCLUDE "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} MT110END

@param  
@author Rodrigo Carvalho
@since  23/02/2016
@Obs    Para utilizar as rotinas padronizadas.
/*/
//--------------------------------------------------------------
User Function MT110END()                
    
Local nNumSC := PARAMIXB[1]  // Numero da Solicitação de compras 
Local nOpca  := PARAMIXB[2]  // 1 = Aprovar; 2 = Rejeitar; 3 = Bloquear 

If nOpca == 1

   DbSelectArea("SC1")
   RecLock("SC1",.F.)
   Replace C1_ZDTAPRO With Date()  // Preencher qdo liberado pelo aprovador cadastrado na tabela SAK (sem limite).
   Replace C1_ZEMP    With cEmpAnt // Empresa solicitante.
// Replace C1_ZMARCA  With ""      // Verificar de onde vem a informação.
   Replace C1_ZSTATUS With "1"     // Campos customizado para controle de abas, talvez possamos usar o padrão do sistema.
   SC1->(MsUnlock())
   
Endif

Return .T.