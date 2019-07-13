#include "protheus.ch"

//______________________________________________________________________________________________________________________________________             
/*/{Protheus.doc} SX5NOTA
Filtra as s�rias das notas que poder�o ser utilizadas.
Por padr�o as notas que necessitam de webservice para controlar sua numera��o deve exibir uma s�rie espec�fica.

@Return lRet Se a s�rie poder� ou n�o ser utilizada

@author  Waldir de Oliveira
@since   14/10/2011
/*/
//______________________________________________________________________________________________________________________________________  
User Function SX5NOTA()
Local lRet := .F. 
Local cChave := ""

If GetMv("FS_KPON",Nil,.F.)
	If (IsInCallStack("MATA103") .And. cFormul=="S" ) .or. ;
		(IsInCallStack("MATA410") .And. !Empty(SC5->C5_ZORIGEM) .And. SC5->C5_ZTIPO == '2') .or. ;
		(IsInCallStack("MATA460A") .And. u_FTstTipo() != 1 /*1 = pedido normal*/ )
		If (AllTrim(SX5->X5_CHAVE)== GetMv("FS_SERIEKP")  )   //Serie do KP
			lRet := .T.                                                
			FAtuSerie()//Se for a s�rie do KP, resetar a numera��o da nota para 000000000. Para que a tela de numera��o n�o confunda o usu�rio	
		Else
			lRet := .F.	    
		EndIf
	Else
		lRet := .T.
	EndIf
Else
	lRet := .T.
EndIf
      
Return lRet     

//______________________________________________________________________________________________________________________________________             
/*/{Protheus.doc} FAtuSerie
Atualizar� o n�mero da s�rie da integra��o do KP para 0000000 Para n�o confundir o usu�rio

@Return Nil

@author  Waldir de Oliveira
@since   14/10/2011
/*/
//______________________________________________________________________________________________________________________________________  
Static Function FAtuSerie()
cChave := AllTrim( "NFF" + PadR( AllTrim(SX5->X5_CHAVE),3) +  xFilial("SF2")+X2PATH("SF2") )

//Alterando SXE
SXE->(dbGoTop())
While(SXE->(!Eof()))       
	If(AllTrim(SXE->(XE_ALIAS + XE_FILIAL)) == cChave)//Se encontrou Xe para a empresa e serie do KP, marretar 000
		RecLock("SXE",.F.)
		SXE->XE_NUMERO := PADL('0',SXE->XE_TAMANHO,'0')
		SXE->(MsUnlock())
	EndIf
	SXE->(dbSkip())
EndDo

//Alterando SXF
SXF->(dbGoTop())
While(SXF->(!Eof()))
	If(AllTrim(SXF->(XF_ALIAS + XF_FILIAL)) == cChave)//Se encontrou Xe para a empresa e serie do KP, marretar 000
		RecLock("SXf",.F.)
		SXF->XF_NUMERO := PADL('0',SXF->XF_TAMANHO,'0')
		SXF->(MsUnlock())
	EndIf
	SXF->(dbSkip())
EndDo
Return
