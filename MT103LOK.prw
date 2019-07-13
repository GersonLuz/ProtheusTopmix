#Include "RwMake.ch" 
/*
+-----------+------------+----------------+-------------------+-------+---------------+
| Programa  | MT103LOK   | Desenvolvedor  | MAX/ROCHA         | Data  | 17/01/2012    |
+-----------+------------+----------------+-------------------+-------+---------------+
| Descricao | Validação da linha de nota fiscal de compra - verifica se existe na tabe|
+-----------+-------------------------------------------------------------------------+
|la de preços para gravação do custo médio e exportação para o KP Betonmix            |
+----------+-------------+------------------------------------------------------------+
|08-06-2012 -> Verifica se existe na tabela de preços/fornecedor para                 |
|              validação do preço acordado e cadastrado pelo setor tecnológico        |
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
      MSGBOX("Produto ainda não cadastrado no Faturamento\Cenário de Vendas\Tabela de preços... ", "Atenção: Contacte o Dpto.Tecnológico!", "STOP"  ) 
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
 		MsgBox(OemToAnsi("Produto com Restrição ao Meio Ambiente! Favor verificar!!"),OemtoAnsi("Aviso !!!"),"ALERT")
		lRet := .F.
	Endif
    If SB1->B1_LIBMED $ "RN" .And. lRet
 		MsgBox(OemToAnsi("Produto com Restrição a Medicina! Favor verificar!!"),OemtoAnsi("Aviso !!!"),"ALERT")
		lRet := .F.
	Endif
    If SB1->B1_LIBSEG $ "RN" .And. lRet
 		MsgBox(OemToAnsi("Produto com Restrição a Segurança! Favor verificar!!"),OemtoAnsi("Aviso !!!"),"ALERT")
		lRet := .F.
	Endif
    If SB1->B1_LIBSEG $ "RN" .And. lRet
 		MsgBox(OemToAnsi("Produto com Restrição a Segurança! Favor verificar!!"),OemtoAnsi("Aviso !!!"),"ALERT")
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

