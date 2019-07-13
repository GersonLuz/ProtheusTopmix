#include "protheus.ch"

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} MA030TOK
Ponto de Entrada utilizado para realizar a atualiza��o da Base de Interface 
         
@author 	Luciano M. Pinto
@since		29/08/2011
@version	P10  R1.4 
@return		lRetFun Sempre Verdadeiro 
@obs
Ponto de Entrada utiliza a fun��o FSINTP13

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
	// Fun��o utilizada para guardar os valores do SA1 antes da altera��o	  
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
   //if ! U_FCHECP01() //Verifica se foi cadastrado o endere�o de cobran�a;
   //   lRetFun := .F.
   //EndIF  

lRetFun := U_FVldEndCob()

If ! lRetFun
   Aviso("Informe o endere�o de cobran�a","Favor informar o endere�o de cobran�a",{"Ok"}) 
   Return .F.
Endif   

Return(lRetFun)