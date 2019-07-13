#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"
/*/
 Funcao:  MT110COR
 Autor:  Marinaldo de Jesus
 Descricao: Implementacao do Ponto de Entrada MT110COR executado na funcao MATA110
    do programa MATA110 Tratamento de cores na mBrowse
/*/
User Function MT110COR()

 Local aCores := ParamIxb[1] //Obtenho a Legenda padrao
 
 Local nBmpPos

 //Testo o Tipo
 IF !( ValType( aCores ) == "A" )
  aCores := {}
 EndIF
    
 /*/
  Se necessario, adiciono novos elementos aa Legenda Padrao

  IF nToL(SC1-&gt;( FieldPos( "C1_APROV" ) ) )
 
   aAdd( aCores , { "C1_APROV=='1'" , "CRDIMG16" } )  //"Em Pré-Analise"
   aAdd( aCores , { "C1_APROV=='2'" , "CFGIMG16" } )  //"Suspensa ou Aguardando Alterações"
 
  EndIF
 /*/
  
 nBmpPos := aScan( aCores , { |aBmp| Upper( AllTrim( aBmp[2] ) ) == "BR_AMARELO" } )
 IF ( nBmpPos &gt; 0 )
  IF !( "C1_QUANT" $ aCores[ nBmpPos ][1] )
   aCores[ nBmpPos ][1] += " .AND. C1_QUJE&lt;&gt;C1_QUANT" //Redefino SC Parcialmente Atendida (Tem um BUG na Logica padrao)
  EndIF 
 EndIF

 //Verifico se estou querendo, apenas, as informacoes da Legenda
 IF IsInCallStack( "GetC1Status" )
  //"Roubo"/Recupero as Informacoes da Legenda de Cores
  __aColors_ := aCores
  //Forco o Erro
  UserException( "IGetC1Status" )
 EndIF

Return( aCores )      

/*/
 Funcao:  GetC1Status
 Autor:  Marinaldo de Jesus
 Descricao: Retornar o Status da SC1 conforme Array de Cores da mBrowse
 Sintaxe: StaticCall( U_MT110COR , GetC1Status , cAlias , cResName , lArrColors )
/*/
Static Function GetC1Status( cAlias , cResName , lArrColors )

 Local bGetColors := { || Mata110() }   
 Local bGetLegend := { || A110Legenda() }

 DEFAULT cAlias   := "SC1"

Return( StaticCall( u_mBrowseLFilter , BrwGetSLeg , @cAlias , @bGetColors , @bGetLegend , @cResName , @lArrColors ) )

/*/
 Funcao:  __Dummy
 Autor:  Marinaldo de Jesus
 Data:  22/04/2011
 Descricao: __Dummy (nao faz nada, apenas previne warning de compilacao)
 Sintaxe: 
/*/
Static Function __Dummy( lRecursa )
 Local oException
 TRYEXCEPTION
  DEFAULT lRecursa := .F.
  IF !( lRecursa )
   BREAK
  EndIF
  GetC1Status()
  lRecursa := __Dummy( .F. )
 CATCHEXCEPTION USING oException
 ENDEXCEPTION
Return( lRecursa )
