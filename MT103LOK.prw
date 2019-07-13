#Include "RwMake.ch" 
/*
+-----------+------------+----------------+-------------------+-------+---------------+
| Programa  | MT103LOK   | Desenvolvedor  | MAX/ROCHA         | Data  | 17/01/2012    |
+-----------+------------+----------------+-------------------+-------+---------------+
| Descricao | Valida��o da linha de nota fiscal de compra - verifica se existe na tabe|
+-----------+-------------------------------------------------------------------------+
|la de pre�os para grava��o do custo m�dio e exporta��o para o KP Betonmix            |
+----------+-------------+------------------------------------------------------------+
|08-06-2012 -> Verifica se existe na tabela de pre�os/fornecedor para                 |
|              valida��o do pre�o acordado e cadastrado pelo setor tecnol�gico        |
+----------+-------------+------------------------------------------------------------+
| DATA     | PROGRAMADOR | MOTIVO                                                     |
+----------+-------------+------------------------------------------------------------+
+----------+-------------+------------------------------------------------------------+
*/                                           
User Function MT103LOK()
   
/*Local aArea   := GetArea()
Local lRet := .T. 
Local nXi  := 0              
Local cCodPro := ""


// pesquisa DA1 
cCodPro := aCols[n][GDFieldPos("D1_COD")]
//Alert("Oi... MT103LOK")
If SB1->B1_TIPO="CC"         
   DBSelectArea("DA1")
   DbSetOrder(1)   
   If ! DBSeek(xFilial("DA1")+"000"+cCodPro ) 
      MSGBOX("Produto ainda n�o cadastrado no Faturamento\Cen�rio de Vendas\Tabela de pre�os... ", "Aten��o: Contacte o Dpto.Tecnol�gico!", "STOP"  ) 
      lRet := .F.
   EndIF
EndIF


//fim pesquisa

/*
dbSelectArea("SB1")
SB1->(dbSetOrder(1))
SB1->(MsSeek(xFilial("SB1")+aCols[n][GDFieldPos("D1_COD")] ))
If SB1->(Found()) 
    If SB1->B1_LIBMEIO $ "RN"
 		MsgBox(OemToAnsi("Produto com Restri��o ao Meio Ambiente! Favor verificar!!"),OemtoAnsi("Aviso !!!"),"ALERT")
		lRet := .F.
	Endif
    If SB1->B1_LIBMED $ "RN" .And. lRet
 		MsgBox(OemToAnsi("Produto com Restri��o a Medicina! Favor verificar!!"),OemtoAnsi("Aviso !!!"),"ALERT")
		lRet := .F.
	Endif
    If SB1->B1_LIBSEG $ "RN" .And. lRet
 		MsgBox(OemToAnsi("Produto com Restri��o a Seguran�a! Favor verificar!!"),OemtoAnsi("Aviso !!!"),"ALERT")
		lRet := .F.
	Endif
    If SB1->B1_LIBSEG $ "RN" .And. lRet
 		MsgBox(OemToAnsi("Produto com Restri��o a Seguran�a! Favor verificar!!"),OemtoAnsi("Aviso !!!"),"ALERT")
		lRet := .F.
	Endif                
	
   dbselectarea("SZ1")
   dbsetorder(1)
   If dbseek(xFilial("SZ1")+SB1->B1_GRUPO+SB1->B1_CODCLAS+SB1->B1_COSUCLA)
 //  If dbseek(xFilial("SZ1")+SD1->D1_GRUPO+SUBSTRING(SD1->D1_COD,3,6))
      If SZ1->Z1_NCM="S" .And. Empty(aCols[n][GDFieldPos("D1_POSIPI")])
 		MsgBox(OemToAnsi("Obrigatorio informar o NCM deste Produto! Favor verificar!!"),OemtoAnsi("Aviso !!!"),"ALERT")
		lRet := .F.
      Endif
   Endif

EndIf

RestArea(aArea)
Return(lRet)
*/

