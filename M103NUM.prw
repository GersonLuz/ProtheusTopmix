//______________________________________________________________________________________________________________________________________             
/*/{Protheus.doc} M103NUM

Ponto de entrada que é executado para buscar a numeração de NFs de notas de entrada  

@Return cNum

@Obs  	Se a nota for de formulário próprio então o WebService é chamado e o número da nota é 
		atribuído à variável privada cNumero e a série à variável cSerie

@author  Waldir de Oliveira
@since   14/10/2011
/*/
//______________________________________________________________________________________________________________________________________  
User Function M103NUM()

	Local cNum := paramixb[1]

	If(cFormul=="S") //Verificando se participa do processo que deve consultar o Ws de Numeração.
		cNum := u_FSGetNumWS()//Obtendo o próximo numero de NF.
		cSerie := GetMv("FS_SERIEKP")//Serie do KP
		cNumero:= cNum	
	EndIf

Return cNum


