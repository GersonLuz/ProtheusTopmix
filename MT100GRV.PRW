#Include "RwMake.ch" 
#include "topconn.ch"
/*
+-----------+------------+----------------+-------------------+-------+---------------+
| Programa  | MT100GRV   | Desenvolvedor  | Max Rocha         | Data  | 01/11/2012    |
+-----------+------------+----------------+-------------------+-------+---------------+
| Descricao | Gravação da nota fiscal de Entrada                                      |
+-----------+-------------------------------------------------------------------------+
| DATA      | PROGRAMADOR | MOTIVO                                                    |
+-----------+-------------+-----------------------------------------------------------+
*/
                                         
User Function MT100GRV()
Local lRet := .T.
  // If LEN(RTRIM(M->CNFISCAL)) < 9
	//   MsgBox("Obrigatório o uso de 9 dígitos na Numeração da Nota Fiscal!","...ATENÇÃO...","STOP")
   //   lRet := .F.
  // EndIF

Return (lRet)  



//************************************************
//* Mostra documentos
//************************************************
        
/*
User Function fDOC110()  
dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1")+SC1->C1_PRODUTO)
	MsDocument( "SB1", SB1->( Recno() ), 1 ) 
Endif
Return
*/
                                                 
