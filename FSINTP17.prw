#Include "Protheus.ch"
#Define cEol Chr(13)+Chr(10)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FSINTP17

Função responsavel pela integração dos registros que não foram processados on-line pelas
rotinas de cadastros

@author        Rafael Almeida
@since         01/12/2011
@version       P11
/*/
//---------------------------------------------------------------------------------------
User Function FSINTP17()

Local		aAreOld	:= {GetArea()}
Local		cQry 		:= ""      
Local		lRegDel	:= .F.      
Local 	cAmbi	:= SuperGetMv( "FS_INTDBAM" , .F., "E" )

Private	aAlias	:= {"SA1","SA2","SA3","SB1","SF4","CTT","DA3","DA4","P01"}  
Private	cAlsTem	:=	""
Private	nXi		:= 0     

If cAmbi <> "E"

	For nXi := 1 To Len(aAlias)              
	
		Conout("Processando: "+aAlias[nXi])
		Do Case
			Case aAlias[nXi] == "SA1"
				
				cQry := cEol+" SELECT"
				cQry += cEol+" R_E_C_N_O_"
				cQry += cEol+" FROM"
				cQry += cEol+"		"+RetSqlName(aAlias[nXi])+" SA1"
				cQry += cEol+" WHERE"                             
				cQry += cEol+" 	SA1.A1_ZTIPO = 'S'"
				cQry += cEol+" AND "
				cQry += cEol+" 	SA1.A1_ZFLAG <> '*'"
						
			Case aAlias[nXi] == "SA2"
				
				cQry := cEol+" SELECT"
				cQry += cEol+" R_E_C_N_O_"
				cQry += cEol+" FROM"
				cQry += cEol+"		"+RetSqlName(aAlias[nXi])+" SA2"
				cQry += cEol+" WHERE"                             
				cQry += cEol+" 	SA2.A2_ZFLAG <> '*'"
			
			Case aAlias[nXi] == "SA3"
				
				cQry := cEol+" SELECT"
				cQry += cEol+" R_E_C_N_O_"
				cQry += cEol+" FROM"
				cQry += cEol+"		"+RetSqlName(aAlias[nXi])+" SA3"
				cQry += cEol+" WHERE"                             
				cQry += cEol+" 	SA3.A3_ZFLAG <> '*'"
			
			Case aAlias[nXi] == "SB1"                    
			
				cQry := cEol+" SELECT"
				cQry += cEol+" 	R_E_C_N_O_"
				cQry += cEol+" FROM"
				cQry += cEol+"		"+RetSqlName(aAlias[nXi])+" SB1"
				cQry += cEol+" WHERE" 
				cQry += cEol+" 	(SB1.B1_GRUPO IN ('8001','8002') OR SB1.B1_TIPO = 'CC')"
				cQry += cEol+" AND" 
				cQry += cEol+" 	SB1.B1_ZFLAG <> '*'"
				
			Case aAlias[nXi] == "SF4"
			
				cQry := cEol+" SELECT"
				cQry += cEol+" 	R_E_C_N_O_"
				cQry += cEol+" FROM"
				cQry += cEol+"		"+RetSqlName(aAlias[nXi])+" SF4"
				cQry += cEol+" WHERE"                             
				cQry += cEol+" 	SF4.F4_CODIGO > '500'"
				cQry += cEol+" AND "
				cQry += cEol+" 	SF4.F4_ZFLAG <> '*'"
			
			Case aAlias[nXi] == "CTT"
			
				cQry := cEol+" SELECT"
				cQry += cEol+" 	R_E_C_N_O_"
				cQry += cEol+" FROM"
				cQry += cEol+"		"+RetSqlName(aAlias[nXi])+" CTT"
				cQry += cEol+" WHERE"                             
				cQry += cEol+" 	CTT.CTT_ZFLAG <> '*'"
			
			Case aAlias[nXi] == "DA3"
	
				cQry := cEol+" SELECT"
				cQry += cEol+" 	R_E_C_N_O_"
				cQry += cEol+" FROM"
				cQry += cEol+"		"+RetSqlName(aAlias[nXi])+" DA3"
				cQry += cEol+" WHERE"                             
				cQry += cEol+" 	DA3.DA3_ZFLAG <> '*'"
			
			Case aAlias[nXi] == "DA4"
			                  	
				cQry := cEol+" SELECT"
				cQry += cEol+" 	R_E_C_N_O_"
				cQry += cEol+" FROM"
				cQry += cEol+"		"+RetSqlName(aAlias[nXi])+" DA4"
				cQry += cEol+" WHERE"                             
				cQry += cEol+" 	DA4.DA4_ZFLAG <> '*'"
	
			Case aAlias[nXi] == "P01"			
				cQry := cEol+"  SELECT
				cQry += cEol+" 	 R_E_C_N_O_
				cQry += cEol+"  FROM
				cQry += cEol+" 		"+RetSqlName(aAlias[nXi])+" P01
				cQry += cEol+"  WHERE
				cQry += cEol+"  	P01.P01_ZFLAG <> '*'
			
		EndCase          
		cAlsTem	:= GetNextAlias()
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAlsTem, .F., .T.)
		SET DELETED OFF	
		(cAlsTem)->(dbGoTop())	
		While (cAlsTem)->(!Eof())
			// Foi necessário utilizar o dbGoTo para aproveitamento da função
			// FSPutTab que realiza as inserções e atualizações no banco
			&(aAlias[nXi]+"->(dbGoTo((cAlsTem)->R_E_C_N_O_))")
			If (&(aAlias[nXi]+"->(DELETED())"))
				U_FSPutTab(aAlias[nXi],"I",.T.)
			Else
				U_FSPutTab(aAlias[nXi],"I",.F.)
			EndIf
			(cAlsTem)->(dbSkip())
		EndDo
		SET DELETED ON
		U_FSCloAre(cAlsTem)
	Next
EndIf
aEval(aAreOld, {|xAux| RestArea(xAux)})
                                         
Return Nil    


