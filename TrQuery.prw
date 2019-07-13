User Function TrQuery(cAliaAuxi,cNovoAlia)
******************************************************************************
* Transforma uma query read-only em arquivo de trabalho leitura e gravacao
* Parametros: <cAliaAuxi> obrigatorio
*             [cNovoAlia] Novo alias do arquivo de trabalho, caso este nao seja
*             informado assumirá c Alias
* Retorno: retorna o nome do arquivo de trabalho que deverá ser apagado.
***            

Local aStruAuxi  := {}
Local cArquTrab  := ""
Local nxI        := 0
Local lReabArqu  := (cNovoAlia == NIL .Or. cNovoAlia == cAliaAuxi)
Local nXE        := 0

cNovoAlia := Iif(lReabArqu,CriaTrab(,.F.),cNovoAlia)
               
dbSelectArea(cAliaAuxi)

aStruAuxi := dbStruct()

For nXE := 1 To Len(aStruAuxi)
    If AllTrim(aStruAuxi[nXE,2]) == "N" 
       aStruAuxi[nXE,3] := aStruAuxi[nXE,3] + 5
    EndIf
Next

cArquTrab := CriaTrab(aStruAuxi)
dbUseArea(.T.,,cArquTrab,cNovoAlia,.F.,.F.)

dbSelectArea(cAliaAuxi)
dbGoTop()
While !Eof()

	dbSelectArea(cNovoAlia)
	(cNovoAlia)->(dbAppend())  //RecLock(cNovoAlia,.T.)
	
	dbSelectArea(cAliaAuxi)
	
	For nxI := 1 To (cAliaAuxi)->(FCount())
            (cNovoAlia)->(&(FieldName(nxI))) := FieldGet(nxI)
	Next

	dbSelectArea(cAliaAuxi)
	dbSkip()
EndDo

dbSelectArea(cAliaAuxi)
dbCloseArea()

If lReabArqu
	dbSelectArea(cNovoAlia)
	dbCloseArea()
	dbUseArea(.T.,,cArquTrab,cAliaAuxi,.F.,.F.)
Endif

Return(cArquTrab)
