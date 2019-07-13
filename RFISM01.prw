#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa �RFISM01   � Autor �EDUARDO NAKAMATU    � Data � 25/07/06   ���
�������������������������������������������������������������������������͹��
���Descricao �INFORMA DATA PARA TRAVAR O MOVIMENTIO FISCAL               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RFISM01()

Private oFis                                                    
Private cFimLin := (chr(13)+chr(10))
Private dDTFIS := getmv("MV_BXDTFIN")
Private oDTFIS
Private dDTFIN := getmv("MV_DATAFIN")
Private oDTFIN              
Private cMsg1 := "Aten��o, n�o ser� poss�vel efetuar"
pRIVATE cMsg2 := "movimenta��es anteriores das datas"
pRIVATE cMsg3 := "informadas!!!"

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
DEFINE MSDIALOG oFis from 000,000 to 200,300 title "Ultimos Fechamentos" pixel
@ 005,005 Say OemToAnsi("Baixas") PIXEL COLORS CLR_HBLUE OF oFis 
@ 005,050 MsGet oDTFIS VAR dDTFIS SIZE 40,08 PIXEL OF oFis Valid !empty(dDTFIS)

@ 015,005 Say OemToAnsi("Financeiro") PIXEL COLORS CLR_HBLUE OF oFis 
@ 015,050 MsGet oDTFIN VAR dDTFIN SIZE 40,08 PIXEL OF oFis Valid !empty(dDTFIN)

@ 005,100 BUTTON "Confirma" OF oFIS SIZE 030,015 PIXEL ACTION FisOK(.t.,dDTFIS,dDTFIN)
@ 020,100 BUTTON "Cancela" OF oFIS SIZE 030,015 PIXEL ACTION FisOk(.f.)

@ 030,005 Say OemToAnsi(cMsg1) PIXEL COLORS CLR_HRED OF oFis                                                  
@ 040,005 Say OemToAnsi(cMsg2) PIXEL COLORS CLR_HRED OF oFis                                                  
@ 050,005 Say OemToAnsi(cMsg3) PIXEL COLORS CLR_HRED OF oFis                                                  

ACTIVATE MSDIALOG oFis CENTER

Return(.T.) 

static function FisOk(lPar,dParFIS,dPArFIN)

if lPar
     if MsgYESNO("Confirma atualizacao de datas de fechamento?","Atencao...","YESNO")
          putmv("MV_BXDTFIN",dParFis)
          putmv("MV_DATAFIN",dParFin)
          
     MsgInfo("Fechamento das Baixas     :"+dtoc(dParFIS)+chr(13)+chr(10)+;
             "Fechamento Financeiro :"+dtoc(dParFIN))
     endif
endif 

oFis:end()

return(.t.)
