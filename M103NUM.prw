//______________________________________________________________________________________________________________________________________             
/*/{Protheus.doc} M103NUM

Ponto de entrada que � executado para buscar a numera��o de NFs de notas de entrada  

@Return cNum

@Obs  	Se a nota for de formul�rio pr�prio ent�o o WebService � chamado e o n�mero da nota � 
		atribu�do � vari�vel privada cNumero e a s�rie � vari�vel cSerie

@author  Waldir de Oliveira
@since   14/10/2011
/*/
//______________________________________________________________________________________________________________________________________  
User Function M103NUM()

	Local cNum := paramixb[1]

	If(cFormul=="S") //Verificando se participa do processo que deve consultar o Ws de Numera��o.
		cNum := u_FSGetNumWS()//Obtendo o pr�ximo numero de NF.
		cSerie := GetMv("FS_SERIEKP")//Serie do KP
		cNumero:= cNum	
	EndIf

Return cNum


