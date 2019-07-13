#INCLUDE "PROTHEUS.CH"
#Include "Rwmake.ch"
#Include "TopConn.ch"


/*************************************************************************************** 
                          DESENVOLVIMENTOS ADVPL - PROTHEUS                            *                                                   
****************************************************************************************
DESENVOLVEDOR: CRISTIANO FERREIRA DE OLIVEIRA         ***          DATA: 14/03/2018    * 
****************************************************************************************
                                   PROGRAMA: TPCTB002                                  *
****************************************************************************************
                  FUNÇÃO ATIVADA NA CONTABILIZAÇÃO DOS FUNCIONÁRIOS TOPMIX             * 
***************************************************************************************/ 

*************************************************
User Function TPCTB002(cTipo)
*************************************************

Private cConta

IF(cTipo == "D")   // CONTA DEBITO
	If ((SRZ->RZ_FILIAL == "010100") .OR. (SRZ->RZ_MAT $ GetMv("MV_TPUSCTB")))
	 cConta := SRV->RV_DEBADM
	Else
	 cConta := SRV->RV_DEBPRO
	Endif 
ELSEIF (cTipo == "C")   // CONTA CREDITO
   If ((SRZ->RZ_FILIAL == "010100") .OR. (SRZ->RZ_MAT $ GetMv("MV_TPUSCTB")))
	 cConta := SRV->RV_CREADM
	Else
	 cConta := SRV->RV_CREPRO
	Endif 
ENDIF	                                                                                                                                                                                           

Return (cConta)     // Retornar Conta Contábil