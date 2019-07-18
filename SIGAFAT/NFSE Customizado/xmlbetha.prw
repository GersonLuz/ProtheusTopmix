// #########################################################################################
// Projeto: Nota Fiscal de Serviço Eletronica 
// Fonte  : MSPPXMLNFSe.prw
// ---------+------------------------------+------------------------------------------------
// Data     | Autor                        | Descricao
// ---------+------------------------------+------------------------------------------------
//          | jrscatolon@jrscatolon.com.br | Geração do XML para envio a Secretaria da   
//          |                              | fazenda municipal. 
//          |                              |  
// ---------+------------------------------+------------------------------------------------

/*
 * Parametros utilizados
 * ---------------------
 * Parâmetro: JR_OPSIMPN
 * Descrição: Parâmetro customizado. Usado pela rotina NFSEMSPP. Informa se o emissor é optante pelo simples.
 * Conteúdo:  1=Sim, 2=Não 
 * 
 * Parâmetro: JR_ICFISCA
 * Descrição: Parâmetro customizado. Usando pela rotina NFSEMSPP. Informa se o emissor possui incentivo fiscal.
 * Conteúdo:  1=Sim, 2=Não
 * 
 * Parämetro: JR_CHVAUTO
 * Descrição: Parâmetro customizado. Usando pela rotina NFSEMSPP. Informa a chave de autorizacao emitida pelo site da prefeitura.
 * Conteúdo:  <Código da chave de autorização>
 *  
 * Parämetro: JR_CHVACES
 * Descrição: Parâmetro customizado. Usando pela rotina NFSEMSPP. Informa a chave de acesso emitida pelo site da prefeitura.
 * Conteúdo:  <Código da chave de acesso>
 *
 *
 * 
 *  Criar os campos: 
 *  ----------------
 *  Campo:        BZ_XNUMATI
 *  Tipo:         C
 *  Tamanho:      20                        
 *  Título:       N.Atividade 
 *  Descrição:    Indica o Cod. Trib. Munic
 *  Help:         Campo customizado: Indica o código de tributação municipal utilizado na NFSe
 *
 *  Campo:        B1_XNUMATI
 *  Tipo:         C
 *  Tamanho:      20                        
 *  Título:       N.Atividade 
 *  Descrição:    Indica o Cod. Trib. Munic
 *  Help:         Campo customizado: Indica o código de tributação municipal utilizado na NFSe
 *
 */

#include 'totvs.ch'
#include 'parmtype.ch'

user function xmlBetha(cRPS, cOperacao)
local cXml := ""
default cOperacao = "envio"

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
local cError, cWarning
local cNameSpace   := ""

	//cXml += '<?xml version="1.0" encoding="utf-8"?>'
    cXml += '<EnviarLoteRpsEnvio xmlns="http://www.betha.com.br/e-nota-contribuinte-ws">'
    cXml +=     '<LoteRps Id="L' + cRPS + substr(time(),1,2) + substr(time(),4,2) + substr(time(),7,2)+'" versao="2.02">'
    cXml +=         '<NumeroLote>' + cRPS + substr(time(),1,2) + substr(time(),4,2) + substr(time(),7,2) + '</NumeroLote>'
    cXml +=         '<CpfCnpj><Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj></CpfCnpj>'
    cXml +=         '<InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</InscricaoMunicipal>'
    cXml +=         '<QuantidadeRps>1</QuantidadeRps>'
    cXml +=         Rps(cRPS)
    cXml +=     '</LoteRps>'
    cXml += '</EnviarLoteRpsEnvio>'
    cXml := EncodeUTF8(cXml)
    
    cXml := StrTran(cXml, chr(13), "")
	cXml := StrTran(cXml, chr(10), "")
    
    cXML := u_AssinaDig(cXML, GetMV('JR_NFSWCDG' , , ""), "InfDeclaracaoPrestacaoServico", 'R' + cRPS, "ENVIAR", "")
    //cXML := u_AssinaDig(cXML, GetMV('JR_NFSWCDG' , , "ciarama12"), "LoteRps", 'L' + cRPS, "ENVIAR", "")
    
return cXml

static function Rps(cRPS)
local cXml := ""

    cXml += '<ListaRps>'
    cXml +=   '<Rps>'
    cXml +=     '<InfDeclaracaoPrestacaoServico Id="R' + cRPS + '">'  
    cXml +=   	   		'<Rps>'
    cXml +=             	IdRps()
    cXml +=   	   		'</Rps>'
    cXml +=             '<Competencia>' + u_ToXml(SF2->F2_EMISSAO) + '</Competencia>'
    cXml +=             IdServico()
    cXml +=             IdPrestador()
    cXml +=             IdTomador()
        
    if SuperGetMV("JR_OPSIMPN",, "2") == "1"
        cXml +=     '<RegimeEspecialTributacao>'+SuperGetMV("JR_OPSIMPN",, "2")+'</RegimeEspecialTributacao>'
    endif
    
    if SA1->(FieldPos("A1_XNATOPE")) > 0
	    if !empty(SA1->A1_XNATOPE)
	    	/*Código de natureza da operação
			1 – Tributação no município
			2 – Tributação fora do município
			3 – Isenção
			4 – Imune
			5 – Exigibilidade suspensa por decisão judicial
			6 – Exigibilidade suspensa por procedimento administrativo
			7 – Não Incidência
			8 – Substituição Tributária*/
	    
	    	cXml +=         '<NaturezaOperacao>' + u_ToXml(SA1->A1_XNATOPE) + '</NaturezaOperacao>' // 1-Sim / 2-Nao
	    endIf
    endIf
    
    cXml +=         '<OptanteSimplesNacional>' + u_ToXml(GetMV("JR_OPSIMPN",,"2")) + '</OptanteSimplesNacional>' // 1-Sim / 2-Nao
    cXml +=         '<IncentivoFiscal>' + u_ToXml(GetMV("JR_ICFISCA",,"2")) + '</IncentivoFiscal>' // 1-Sim / 2-Nao 
    cXml +=     '</InfDeclaracaoPrestacaoServico>'
    cXml +=   '</Rps>'
    cXml += '</ListaRps>'
return cXml

static function IdRps()
local cXml := ""

    cXml +=     	'<IdentificacaoRps>'
    cXml +=         	'<Numero>' + u_ToXml(SF2->F2_DOC) + '</Numero>'
    cXml +=         	'<Serie>' + u_ToXml(SF2->F2_SERIE) + '</Serie>'
    cXml +=         	'<Tipo>1</Tipo>' // 1 - Recibo Provisório de Serviços / 2 - RPS Nota Fiscal Conjugada (Mista) / 3 - Cupom 
    cXml +=     	'</IdentificacaoRps>'
    cXml +=     	'<DataEmissao>' + u_ToXml(SF2->F2_EMISSAO) + '</DataEmissao>'
    cXml +=     	'<Status>1</Status>' // 1 - Normal / 2 - Cancelado 

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
    //if SA1->A1_RECISS == '1'
    //    cXml +=         '<ValorIss>' + u_ToXml(SF2->F2_VALISS) + '</ValorIss>'//'</ValorIss>'
    //endif
    //cXml +=     	'<BaseCalculo>' + u_ToXml(SF2->F2_BASEISS) + '</BaseCalculo>'
    //cXml +=         '<Aliquota>' + u_ToXml(nAliqISS) + '</Aliquota>'
    cXml +=     '</Valores>'
    if SA1->A1_RECISS == '1'
        cXml +=     '<IssRetido>1</IssRetido>'
        cXml +=     '<ResponsavelRetencao>1</ResponsavelRetencao>'
    else
        cXml +=     '<IssRetido>2</IssRetido>'
    endif
    cXml +=     '<ItemListaServico>' + u_ToXml(cXNumAti)/*u_ToXml(transform(val(cXNumAti),"@E 99,99"))*/ + '</ItemListaServico>'
    cXml +=     '<CodigoTributacaoMunicipio>'+ u_ToXml(cXNumAti) +'</CodigoTributacaoMunicipio>'
    cXml +=     '<Discriminacao>' + u_ToXml(cDicrimina) + '</Discriminacao>'
    cXml +=     '<CodigoMunicipio>' + u_ToXml(SM0->M0_CODMUN) + '</CodigoMunicipio>'
    cXml +=     '<ExigibilidadeISS>1</ExigibilidadeISS>'
    cXml +=     '<MunicipioIncidencia>' + u_ToXml(cMunPresta) + '</MunicipioIncidencia>'
    cXml += '</Servico>'

return cXml

static function IdPrestador()
local cXml := ""

    cXml += '<Prestador>'
    cXml +=     '<CpfCnpj><Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj></CpfCnpj>'
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
	//cXml +=     	'<Telefone>4835220026</Telefone>'
	cXml +=     	'<Email>'+u_ToXml(SA1->A1_EMAIL)+'</Email>'
	cXml +=     '</Contato>
    cXml += '</Tomador>'


return cXml

static function Consultar(cRPS)
local cXml := ""
	
    cXml += '<ws:ConsultarNfseRpsEnvio xmlns:ws="http://www.betha.com.br/e-nota-contribuinte-ws">' 
    cXml +=    '<IdentificacaoRps>' 
    cXml +=        '<Numero>' + u_ToXml(SF2->F2_DOC) + '</Numero>'
    cXml +=        '<Serie>' + u_ToXml(SF2->F2_SERIE) + '</Serie>'
    cXml +=        '<Tipo>1</Tipo>' // 1 - Recibo Provisório de Serviços / 2 - RPS Nota Fiscal Conjugada (Mista) / 3 - Cupom 
    cXml +=    '</IdentificacaoRps>' 
    cXml +=    '<Prestador>' 
    cXml +=        '<Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj>'
    cXml +=        '<InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</InscricaoMunicipal>'
    cXml +=    '</Prestador>' 
    cXml += '</ws:ConsultarNfseRpsEnvio>'
	cXml := EncodeUTF8(cXml)
	
return cXml

static function Situacao()
local cXml := ""

	cXml := '<ConsultarLoteRpsEnvio xmlns="http://www.betha.com.br/e-nota-contribuinte-ws">'  
    cXml +=    '<Prestador>' 
    cXml +=        '<Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj>'
    cXml +=        '<InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</InscricaoMunicipal>'
    cXml +=    '</Prestador>' 
    cXml +=    '<Protocolo>'+alltrim(SF2->F2_XNFSPRT)+'</Protocolo>'
    cXml += '</ConsultarLoteRpsEnvio>'

return cXml

static function Cancelar(cRPS)
local cXml := ""

	cXml := '<ws:CancelarNfseEnvio xmlns:ws="http://www.betha.com.br/e-nota-contribuinte-ws">' 
    cXml +=     '<Pedido>'                      
    cXml +=         '<InfPedidoCancelamento Id="'+cRPS+'">' 
    cXml +=             '<IdentificacaoNfse>'
    cXml +=                  '<Numero>' + AllTrim(SF2->F2_NFELETR) + '</Numero>'
    cXml +=                  '<Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj>'
    cXml +=                  '<InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</InscricaoMunicipal>'
    cXml +=                  '<CodigoMunicipio>' + u_ToXml(SM0->M0_CODMUN) + '</CodigoMunicipio>'
    cXml +=             '</IdentificacaoNfse>' 
    cXml +=             '<CodigoCancelamento>1</CodigoCancelamento>'  /* Código de cancelamento com base na tabela de Erros e alertas. 1 – Erro na emissão, 2 – Serviço não prestado, 3 – Erro de assinatura, 4 – Duplicidade da nota, 5 – Erro de processamento */
    cXml +=         '</InfPedidoCancelamento>' 
    cXml +=     '</Pedido>' 
    cXml += '</ws:CancelarNfseEnvio>' 
    cXml := EncodeUTF8(cXml)

return cXml

user function BethaNumNF(oXml)
local cNFSE := ""
	cNFSE := WSAdvValue( oXml, "_CONSULTARNFSERPSRESPOSTA:_COMPLNFSE:_NFSE:_INFNFSE:_NUMERO:TEXT","string" )
return cNFSE

user function BethaProtocolo(oXml)
local cProt := ""
	cProt := WSAdvValue( oXml, "_ENVIARLOTERPSRESPOSTA:_PROTOCOLO:TEXT","string")
return cProt

user function BethaCVer(oXml)
local cCVer := ""
	cCVer := WSAdvValue( oXml, "_CONSULTARNFSERPSRESPOSTA:_COMPLNFSE:_NFSE:_INFNFSE:_CodigoVerificacao:TEXT","string")
return cCVer