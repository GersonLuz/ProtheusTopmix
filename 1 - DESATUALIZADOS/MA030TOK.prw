#include "protheus.ch"

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} MA030TOK
Ponto de Entrada utilizado para realizar a atualização da Base de Interface 
         
@author 	Luciano M. Pinto
@since		29/08/2011
@version	P10  R1.4 
@return		lRetFun Sempre Verdadeiro 
@obs
Ponto de Entrada utiliza a função FSINTP13

/*/ 
//--------------------------------------------------------------------------------------- 
User Function MA030TOK()
/****************************************************************************************
* Chamada do Programa
*
*
***/
Local lRetFun	:= .T. 

	//***********************************************************************************
	// Função utilizada para guardar os valores do SA1 antes da alteração	  
	//***********************************************************************************
 	If ! U_FCNPJSA1() //testa raiz do cnpj
	   lRetFun := .F.
   EndIF 
   if ! U_FBLOQSA1() //Testa limite de credito do cliente.
      lRetFun := .F.
   EndIF      
   if lRetFun  
   	U_FSINTP13("SA1")  
   EndIF	
   //if ! U_FCHECP01() //Verifica se foi cadastrado o endereço de cobrança;
   //   lRetFun := .F.
   //EndIF  

lRetFun := U_FVldEndCob()

If ! lRetFun
   Aviso("Informe o endereço de cobrança","Favor informar o endereço de cobrança",{"Ok"}) 
   Return .F.
Endif   

Return(lRetFun)