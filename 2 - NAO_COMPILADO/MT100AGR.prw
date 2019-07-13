User Function MT100AGR()
	Local       nPosTES := ASCAN(aHeader, {|x| ALLTRIM(x[2]) == "D1_TES"}) 
 	Local       lRet     := .T. 
  	Local       nZ 
  	
  	
  	 For nZ := 1 To Len(aCols) 
              // alert(aCols[nZ,nPosTES])
              
    Next 
		 
Return( .F. )