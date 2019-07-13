#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa �TPFIN001  � Autor �CRISTIANO FERREIRA  � Data � 17/09/07     ���
�������������������������������������������������������������������������͹��
���Descricao �INFORMA DATA PARA TRAVAR O MOVIMENTO FINANCEIRO             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function TPFIN001()

Private oFin                                                    
Private cFimLin := (chr(13)+chr(10))
Private dDTFIN := getmv("MV_DATAFIN")
Private oDTFIN              
Private cMsg1 := "Aten��o, n�o ser� poss�vel efetuar"
Private cMsg2 := "movimenta��es anteriores das datas"
Private cMsg3 := "informadas!!!"


//���������������������������������������������������������������������Ŀ
//� Somente Usu�rios Cont�bil e Master Faturamento                      �
//�����������������������������������������������������������������������
IF (__cUserId == '000021' .OR. __cUserId == '000208' .OR. __cUserId == '000270')
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
	DEFINE MSDIALOG oFin from 000,000 to 150,300 title "Fechamento" pixel
	@ 005,005 Say OemToAnsi("Financeiro") PIXEL COLORS CLR_HBLUE OF oFin 
	@ 005,050 MsGet oDTFIN VAR dDTFIN SIZE 40,08 PIXEL OF oFin Valid !empty(dDTFIN)
	
	@ 005,100 BUTTON "Confirma" OF oFIN SIZE 030,015 PIXEL ACTION FinOK(.t.,dDTFIN)      
	
	@ 035,100 BUTTON "Cancela" OF oFIN SIZE 030,015 PIXEL ACTION FinOK(.f.,dDTFIN)
	
	
	@ 020,005 Say OemToAnsi(cMsg1) PIXEL COLORS CLR_HRED OF oFin                                                  
	@ 030,005 Say OemToAnsi(cMsg2) PIXEL COLORS CLR_HRED OF oFin                                                  
	@ 040,005 Say OemToAnsi(cMsg3) PIXEL COLORS CLR_HRED OF oFin                                                  
	
	ACTIVATE MSDIALOG oFin CENTER
ENDIF	

Return(.T.) 

*************************************************
Static function FinOk(lPar,dPArFIN)
*************************************************

if lPar
     if MsgYESNO("Confirma atualizacao da data de bloqueio?","Atencao...","YESNO")
          putmv("MV_DATAFIN",dParFin)
          
     MsgInfo("Bloqueio Financeiro:"+dtoc(dParFIN)+chr(13)+chr(10))
     endif
endif 

oFin:end()

return(.t.)
