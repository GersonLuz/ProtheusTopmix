#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT150OK
Ponto de Entrada para Limpar dados do WF.

@protected
@author    Rodrigo Carvalho
@since     10/05/2016
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function MT150OK(lRotPad,aColsPar,aHeadPar)

//Local nOpcx     := PARAMIXB[01]
Local lRetPEnt  := .T.
Local cMarca    := ""
Local aArea     := GetArea()
Local nPosPreco := 0
Local cLstVldGr := SuperGetMv("MC_LSTGRPG",,"1601/1602/1603/4200/")
Local cErro     := ""

Default aColsPar := aCols
Default aHeadPar := aHeader
Default lRotPad  := .T.

For nXy := 1 To Len(aColsPar)  
    
    If lRotPad .And. GDdeleted(nXy)
       Loop
    Endif   
      
       nPosMarca := Ascan(aHeadPar,{|x| Alltrim(x[2])== "C8_ZMARCA"})
       nPosProdu := Ascan(aHeadPar,{|x| Alltrim(x[2])== "C8_PRODUTO"})       
       nPosPreco := Ascan(aHeadPar,{|x| Alltrim(x[2])== "C8_PRECO"})              
       cMarca    := Alltrim(Upper(aColsPar[nXy,nPosMarca]))

       If aColsPar[nXy,nPosPreco] > 0
          
          DbSelectARea("SB1")
          DbSetOrder(1)
          DbSeek(xFilial("SB1") + aColsPar[nXy,nPosProdu] )
    
          If ! Empty(SB1->B1_FABRIC) .And. Alltrim(SB1->B1_GRUPO) $ cLstVldGr
          
             If (! cMarca $ Upper(SB1->B1_FABRIC)) .Or. Empty(cMarca)  
             
                cErro += Alltrim(SB1->B1_COD)+" - "+Left(Alltrim(SB1->B1_DESC),20)+" Marcas: "+Alltrim(SB1->B1_FABRIC)+CRLF
                lRetPEnt := .F.
             
             Endif
          
          Endif
          
       Endif

Next nXy  
                
RestArea(aArea)

If ! lRetPEnt
   Aviso("Informe a Marca","É necessário informar a MARCA do(s) produto(s) abaixo:"+CRLF+cErro,{"Ok"},3)
Endif

Return(lRetPEnt)