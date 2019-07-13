User Function DELSRZ
 
 
  
  aOp:= {"OK","Cancela"}
  cTit:= "Atencao!"
  cMsg:= "Esta rotina ajusta o resumo da folha para contabilizacao,apos clicar no OK aguarde a mensagem de finalização aparecer indicando o termino do processo!"
  
  nOp := Aviso(cTit,cMsg,aOp)
  
  if nOp = 1 
     
     cQueryDelet := "DELETE FROM " +RETSQLNAME("SRZ")
     TcSqlExec( cQueryDelet )
  
     aOp:= {"OK"}
     cTit:= "Atencao!"
     cMsg:= "Processo finalizado com sucesso!"
     Aviso(cTit,cMsg,aOp)
  
  ELSEIF nOp = 2
     RETURN
  endif 
  
  
Return
