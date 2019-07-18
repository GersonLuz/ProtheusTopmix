// #########################################################################################
// Projeto: Nota Fiscal de Servi�o Eletronica 
// Fonte  : MSPPXMLNFSe.prw
// ---------+------------------------------+------------------------------------------------
// Data     | Autor                        | Descricao
// ---------+------------------------------+------------------------------------------------
//          | jrscatolon@jrscatolon.com.br | Gera��o do XML para envio a Secretaria da   
//          |                              | fazenda municipal. 
//          |                              |  
// ---------+------------------------------+------------------------------------------------

/*
 * Parametros utilizados
 * ---------------------
 * Par�metro: JR_OPSIMPN
 * Descri��o: Par�metro customizado. Usado pela rotina NFSEMSPP. Informa se o emissor � optante pelo simples.
 * Conte�do:  1=Sim, 2=N�o 
 * 
 * Par�metro: JR_ICFISCA
 * Descri��o: Par�metro customizado. Usando pela rotina NFSEMSPP. Informa se o emissor possui incentivo fiscal.
 * Conte�do:  1=Sim, 2=N�o
 * 
 * Par�metro: JR_CHVAUTO
 * Descri��o: Par�metro customizado. Usando pela rotina NFSEMSPP. Informa a chave de autorizacao emitida pelo site da prefeitura.
 * Conte�do:  <C�digo da chave de autoriza��o>
 *  
 * Par�metro: JR_CHVACES
 * Descri��o: Par�metro customizado. Usando pela rotina NFSEMSPP. Informa a chave de acesso emitida pelo site da prefeitura.
 * Conte�do:  <C�digo da chave de acesso>
 *
 *
 * 
 *  Criar os campos: 
 *  ----------------
 *  Campo:        BZ_XNUMATI
 *  Tipo:         C
 *  Tamanho:      20                        
 *  T�tulo:       N.Atividade 
 *  Descri��o:    Indica o Cod. Trib. Munic
 *  Help:         Campo customizado: Indica o c�digo de tributa��o municipal utilizado na NFSe
 *
 *  Campo:        B1_XNUMATI
 *  Tipo:         C
 *  Tamanho:      20                        
 *  T�tulo:       N.Atividade 
 *  Descri��o:    Indica o Cod. Trib. Munic
 *  Help:         Campo customizado: Indica o c�digo de tributa��o municipal utilizado na NFSe
 *
 */

#include 'totvs.ch'
#include 'parmtype.ch'

user function xmlEmbr(cRPS, cOperacao)
local cXml := ""
default cOperacao = "envio"
	
	cRPS := AllTrim(Str(Val(cRPS)))
	
	if cOperacao == "envio"
		cXml := Enviar(cRPS)
	elseif cOperacao == "consulta"
		cXml := Consultar(cRPS)
	elseif cOperacao == "cancela"
		cXml := Cancelar(cRPS)
	elseif cOperacao == "situacao"
		cXml := Situacao()
	endIf
return cXml

static function Enviar(cRPS)
local cXml := ""
local cNameSpace   := ""

	//cXml += '<?xml version="1.0" encoding="utf-8"?>'
    cXml += '<EnviarLoteRpsEnvio xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.abrasf.org.br/nfse">'
    cXml +=     '<LoteRps Id="l' + cRPS + '">'
    cXml +=         '<NumeroLote>' + cRPS + '</NumeroLote>'
    cXml +=         '<Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj>'
    cXml +=         '<InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</InscricaoMunicipal>'
    cXml +=         '<QuantidadeRps>1</QuantidadeRps>'
    //cXml +=         Rps(cRPS)
    cXml +=     '</LoteRps>'
    cXml += '</EnviarLoteRpsEnvio>'
    
    //cXML := u_AssinaDig(EncodeUTF8(cXML), GetMV('JR_NFSPSWD' , , "contabilidade"), "LoteRps", 'l'+cRPS, "ENVIAR", cNameSpace)
    
return cXml

static function Rps(cRPS)
local cXml := ""

    cXml += '<ListaRps>'
    cXml +=   '<Rps>'
    cXml +=     '<InfRps Id="r' + cRPS + '">'
    cXml +=             IdRps()
    //cXml +=             '<Competencia>' + u_ToXml(SF2->F2_EMISSAO) + '</Competencia>'
    cXml +=             IdServico()
    cXml +=             IdPrestador()
    cXml +=             IdTomador()
    cXml +=     '</InfRps>'
    cXml +=   '</Rps>'
    cXml += '</ListaRps>'
    
    //cXML := u_AssinaDig(EncodeUTF8(cXML), GetMV('JR_NFSPSWD' , , "contabilidade"), "InfRps", 'r'+cRPS, "ENVIAR", "")
return cXml

static function IdRps()
local cXml := ""

    cXml +=     	'<IdentificacaoRps>'
    cXml +=         	'<Numero>' + u_ToXml(SF2->F2_DOC) + '</Numero>'
    cXml +=         	'<Serie>' + u_ToXml(SF2->F2_SERIE) + '</Serie>'
    cXml +=         	'<Tipo>1</Tipo>' // 1 - Recibo Provis�rio de Servi�os / 2 - RPS Nota Fiscal Conjugada (Mista) / 3 - Cupom 
    cXml +=     	'</IdentificacaoRps>'
    cXml +=     	'<DataEmissao>' + u_ToXml(SF2->F2_EMISSAO)+"T08:00:00" + '</DataEmissao>'
    cXml +=     	'<NaturezaOperacao>1</NaturezaOperacao>'
    
    if .T. //GetMV("JR_OPSIMPN", .t.)
        //cXml +=             '<RegimeEspecialTributacao>2</RegimeEspecialTributacao>' // 1-Sim / 2-Nao
        cXml +=             '<OptanteSimplesNacional>' + u_ToXml(GetMV("JR_OPSIMPN",,"2")) + '</OptanteSimplesNacional>' // 1-Sim / 2-Nao
    endif

     if .T. //GetMV("JR_ICFISCA", .t.)
        cXml +=             '<IncentivadorCultural>' + u_ToXml(GetMV("JR_ICFISCA",,"2")) + '</IncentivadorCultural>' // 1-Sim / 2-Nao
    endif
    
    cXml +=     	'<Status>1</Status>' // 1 - Normal / 2 - Cancelado 
    //cXML += 		'<OutrasInformacoes>OUTRAS INFORMACOES:</OutrasInformacoes>' //m�ximo 255 caracteres

return cXml

static function IDServico()
local cXml := ""

    cXml += '<Servico>'
    cXml +=     '<Valores>'
    cXml +=         '<ValorServicos>' + u_ToXml(SF2->F2_BASEISS) + '</ValorServicos>'
    cXml +=         '<ValorPis>' + u_ToXml(SF2->F2_VALPIS) + '</ValorPis>'
    cXml +=         '<ValorCofins>' + u_ToXml(SF2->F2_VALCOFI) + '</ValorCofins>'
    cXml +=         '<ValorInss>' + u_ToXml(SF2->F2_VALINSS) + '</ValorInss>'
    cXml +=         '<ValorIr>' + u_ToXml(SF2->F2_VALIRRF) + '</ValorIr>'
    cXml +=         '<ValorCsll>' + u_ToXml(SF2->F2_VALCSLL) + '</ValorCsll>'
    //cXml +=         '<ValorIss>' + u_ToXml(SF2->F2_VALISS) + '</ValorIss>'
    //cXml +=         '<Aliquota>' + u_ToXml(nAliqISS) + '</Aliquota>'
    //cXml +=     	'<BaseCalculo>' + u_ToXml(SF2->F2_BASEISS) + '</BaseCalculo>'
    if SA1->A1_RECISS == '1'
        cXml +=     '<IssRetido>1</IssRetido>'
        //cXml +=     '<ResponsavelRetencao>1</ResponsavelRetencao>'
    else
        cXml +=     '<IssRetido>2</IssRetido>'
    endif
    cXml +=     '</Valores>'
    cXml +=     '<ItemListaServico>' + u_ToXml(cXNumAti) + '</ItemListaServico>'
    cXml +=     '<CodigoCnae>' + u_ToXml(cCodCNAE) + '</CodigoCnae>'
    cXml +=     '<CodigoTributacaoMunicipio>' + u_ToXml(cXNumAti) + '</CodigoTributacaoMunicipio>'
    cXml +=     '<Discriminacao>' + u_ToXml(cDicrimina) + '</Discriminacao>'
    cXml +=     '<CodigoMunicipio>' + u_ToXml(SM0->M0_CODMUN) + '</CodigoMunicipio>'

    cXml += '</Servico>'

return cXml

static function IdPrestador()
local cXml := ""

    cXml += '<Prestador>'
    //cXml +=     '<CpfCnpj>'
    cXml +=         '<Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj>'
    //cXml +=     '</CpfCnpj>'
    cXml +=     '<InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</InscricaoMunicipal>'
    cXml += '</Prestador>'

return cXml

static function IdTomador()
local cXml := ""
local aEndereco := ""

    DbSelectArea("SA1")
    DbSetOrder(1)
    
    SA1->(DbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))
    aEndereco := FisGetEnd(SA1->A1_END, SA1->A1_EST)

    cXml += '<Tomador>'
    cXml +=     '<IdentificacaoTomador>'
    cXml +=         '<CpfCnpj>'
    cXml +=             Iif(SA1->A1_PESSOA == 'F', '<Cpf>' + u_ToXml(SA1->A1_CGC) + '</Cpf>', '<Cnpj>' + u_ToXml(SA1->A1_CGC) + '</Cnpj>' )
    cXml +=         '</CpfCnpj>'
    cXml +=     '</IdentificacaoTomador>'
    cXml +=     '<RazaoSocial>' + u_ToXml(SA1->A1_NOME) + '</RazaoSocial>'
    cXml +=     '<Endereco>'
    cXml +=         '<Endereco>' + u_ToXml(aEndereco[1]) + '</Endereco>'
    cXml +=         '<Numero>' + left(u_ToXml(aEndereco[3]),5) + '</Numero>'
    //cXml +=         '<Complemento>' + u_ToXml(SA1->A1_COMPLEM) + '</Complemento>'
    cXml +=         '<Bairro>' + u_ToXml(SA1->A1_BAIRRO) + '</Bairro>'
    cMunTom := SA1->A1_IBGE
    if empty(cMunTom)
 		dbSelectArea("SX5")
 		dbSetOrder(1)
 		dbSeek(xFilial("SX5")+"AA"+SA1->A1_EST)
 		
 		cMunTom := substr(SX5->X5_DESCRI,2,2)+alltrim(SA1->A1_COD_MUN)
 	endIf
    
    cXml +=         '<CodigoMunicipio>' + u_ToXml(left(cMunTom, 7)) + '</CodigoMunicipio>'
    cXml +=         '<Uf>' + u_ToXml(SA1->A1_EST) + '</Uf>'
    cXml +=     '</Endereco>'
    cXml +=     '<Contato>'
    cXml +=         '<Telefone>' + allTrim(SA1->A1_DDD) + allTrim(SA1->A1_TEL) + '</Telefone>'
    cXml +=         '<Email>' + alltrim(SA1->A1_EMAIL) + '</Email>'
    cXml +=     '</Contato>'
    cXml += '</Tomador>'


return cXml

static function Situacao()
local cXml := ""
    
	cXml :=	'<ConsultarLoteRpsEnvio xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.abrasf.org.br/nfse">'
    cXml +=		'<Prestador>'
    cXml +=			'<Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj>'
    cXml +=			'<InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</InscricaoMunicipal>'
    cXml +=		'</Prestador>'
    cXml +=		'<Protocolo>'+alltrim(SF2->F2_XNFSPRT)+'</Protocolo>'
    cXml +=	'</ConsultarLoteRpsEnvio>' 

return cXml




user function consEmb()
return Consultar()

Static function Consultar(cRPS)
local cXml := ""

cRPS := AllTrim(Str(Val(SF2->F2_DOC)))

cXml := '<ConsultarNfseRpsEnvio xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.abrasf.org.br/nfse">' 
cXml +=    '<IdentificacaoRps>' 
cXml +=        '<Numero>' + cRPS + '</Numero>'
cXml +=        '<Serie>' + u_ToXml(SF2->F2_SERIE) + '</Serie>'
cXml +=        '<Tipo>1</Tipo>' // 1 - Recibo Provis�rio de Servi�os / 2 - RPS Nota Fiscal Conjugada (Mista) / 3 - Cupom 
cXml +=    '</IdentificacaoRps>' 
cXml +=    '<Prestador>' 
cXml +=        '<Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj>'
cXml +=        '<InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</InscricaoMunicipal>'
cXml +=    '</Prestador>' 
cXml += '</ConsultarNfseRpsEnvio>'

return EncodeUTF8(cXml)

user function sitEmb()

return Situacao()
user function cancEmb() 

Return Cancelar()

static function Cancelar(cRps)
local cXml := ""    
                    
cXml := '<CancelarNfseEnvio xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.abrasf.org.br/nfse">' 
cXml +=     '<Pedido>'                      
cXml +=         '<InfPedidoCancelamento>' 
cXml +=             '<IdentificacaoNfse>'
cXml +=                  '<Numero>' + AllTrim(SF2->F2_NFELETR) + '</Numero>'
cXml +=                  '<Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj>'
cXml +=                  '<InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</InscricaoMunicipal>'
cXml +=                  '<CodigoMunicipio>' + u_ToXml(SM0->M0_CODMUN) + '</CodigoMunicipio>'
cXml +=             '</IdentificacaoNfse>' 
cXml +=             '<CodigoCancelamento>1</CodigoCancelamento>'  /* C�digo de cancelamento com base na tabela de Erros e alertas. 1 � Erro na emiss�o, 2 � Servi�o n�o prestado, 3 � Erro de assinatura, 4 � Duplicidade da nota, 5 � Erro de processamento */
cXml +=         '</InfPedidoCancelamento>' 
cXml +=     '</Pedido>' 
cXml += '</CancelarNfseEnvio>' 

return EncodeUTF8(cXml)

user function EmbNumNF(oXml)
local cNFSE := ""
	cNFSE := WSAdvValue( oXml, "_CONSULTARNFSERPSRESPOSTA:_COMPNFSE:_NFSE:_INFNFSE:_NUMERO:TEXT","string" )
return cNFSE

user function EmbProtocolo(oXml)
local cProt := ""
	cProt := WSAdvValue( oXml, "_ENVIARLOTERPSRESPOSTA:_PROTOCOLO:TEXT","string")
return cProt

user function EmbCVer(oXml)
local cCVer := ""
	cCVer := WSAdvValue( oXml, "_CONSULTARNFSERPSRESPOSTA:_COMPNFSE:_NFSE:_INFNFSE:_CodigoVerificacao:TEXT","string")
return cCVer