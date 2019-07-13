#Include "RwMake.ch" 

//______________________________________________________________________________________________________________________________________             
/*/{Protheus.doc} MT100TOK
Ponto de Entrada chamado na confirmação da nota de entrada
Usado para verificar se o Ws de numeração de Nf está ativo. 

@author  Waldir de Oliveira 
@since   14/10/2011
                   
Validação da qtde de dígitos da Nota Fiscal 
@author  Max Rocha
@since   07/11/2012

/*/
//______________________________________________________________________________________________________________________________________  
User Function MT100TOK  

Local lRet := .T.
//lRet := lRet .And. FVerNumWS()	//Verificando o WS de Numeração de NFs.
	
  If (FunName() =  'MATA103') .OR. (FunName() =  'MATA910')
   // verificar nome da variavel	If M->C103FORM <> 'S'			//Condicao para validar se e formulario proprio, permitir sem numero. Jean Santos   
      	If LEN(RTRIM(M->CNFISCAL)) < 9 
	   		MsgBox("Obrigatório o uso de 9 dígitos na Numeração da Nota Fiscal! "+FunName(),"...ATENÇÃO...","STOP")
      		lRet := .F.
      	EndIF
   //   EndIf            
  EndIF
                 
  If FunName() ==  'MATA920'
      If LEN(RTRIM(M->C920NOTA)) < 9 
	   	MsgBox("Obrigatório o uso de 9 dígitos na Numeração da Nota Fiscal! "+FunName(),"...ATENÇÃO...","STOP")
      	lRet := .F.
      EndIF              
   EndIF  
         
   If lRet .And. FunName() <>  'MATA920'
   	lRet:=U_FVldChav()
   EndIf
   
   if (Alltrim(cESPECIE) == 'CTE') // VALIDANDO ESPECIE CTE
	  if(Empty(aInfAdic[10]) .OR. Empty(aInfAdic[11]) .OR. Empty(aInfAdic[12]) .OR. Empty(aInfAdic[13]))  //MUNICIPIO ORIGEM E DESTINO
	  MsgInfo("É necessário informar o Municipio de Origem e Destino na aba: Informações Adicionais.")
	  lRet := .F.
	  endif
   endif
   
Return lRet


//______________________________________________________________________________________________________________________________________             
/*/{Protheus.doc} FVerNumWS
Verifica se o Ws de Numeração de Notas está ativo.	

@author  Waldir de Oliveira
@since   14/10/2011
/*/                                                                                           
//______________________________________________________________________________________________________________________________________  
Static Function FVerNumWS()
	Local lRet := .T. 
	If GetMv("FS_KPON",Nil,.F.) .and. ! IsInCallStack("MATA920")//MAX: Verifica se há deve buscar do WS   e se não está no lançamento manual de NF
		IF(cFormul=="S")
   		lRet := U_FSVerWS() //Verificando o WS de Numeração de NFs.
		EndIf
	EndIF	
Return lRet
 