User Function CodGrupo()
	Local lRet := .F.  
	lRet := inclui
	
	If(lRet)
		lRet := Alltrim(M->N1_GRUPO) $ "CAB/CBL/CBT/VEA" .OR. (!Alltrim(M->N1_GRUPO) $ "CAB/CBL/CBT/VEA"  .AND. M->N1_ITEM <> "0001")

	EndIf
	
Return lRet