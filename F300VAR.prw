#include "protheus.ch" 

//------------------------------------------------------------------- 
/*/{Protheus.doc} F300VAR() 

@protected	
@author		Rodrigo Carvalho
@since		27/10/2015
@version 	P11
@obs			Verificar os parametros do retorno SISPAG.
            Parametros: ({cFilAtu,cBanco,cAgencia,cConta,dBaixa,cNumTit,cValPag,nJuros,nMulta,cTipoImp,cSegmento,cDesc1,cDesc2,cDesc3,cDesc4,xBuffer})        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------ 
User Function F300VAR()

Local lVerDesc := SuperGetMv("MC_VERDESC",,.T.)

If Alltrim( PARAMIXB [1][6] ) $  "0000192393"  // IDCNAB
   Pare := "sim"
Endif

If PARAMIXB[1][8] == nDescont .And. nDescont > 0 .And. lVerDesc  // valor de juros for igual ao valor de desconto, zera o valor de desconto. (Erro da rotina)
   nDescont := 0
Endif   

Return .t.