#INCLUDE "PROTHEUS.CH"
/*/
 Funcao:  MT110LEG
 Autor:  Marinaldo de Jesus
 Descricao: Implementacao do Ponto de Entrada MT110LEG executado na funcao A110Legenda
    do programa MATA110 para adicionar novos elementos na Legenda
/*/
User Function MT110LEG()
 
 Local aLegend := ParamIxb[1] //Obtenho a Legenda padrao

 //Testo o Tipo
 IF !( ValType( aLegend ) == "A" )
  aLegend := {}
 EndIF
 
 /*/
  Se necessario, adiciono novos elementos aa Legenda Padrao
    
  aAdd( aLegend , { "CRDIMG16"  , OemToAnsi( "Em Pré-Analise" ) } )
  aAdd( aLegend , { "CFGIMG16"  , OemToAnsi( "Suspensa ou Aguardando Alterações" ) } )
 /*/

 //Verifico se estou querendo, apenas, as informacoes da Legenda
 IF IsInCallStack( "GetC1Status" )
  //"Roubo"/Recupero as Informacoes da Legenda de Cores
  __aLegend_ := aLegend
  //Forco o Erro
  UserException( "IGetC1Status" )
 EndIF

Return( aLegend )

