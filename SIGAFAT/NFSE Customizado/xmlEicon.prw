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

#include 'totvs.ch'
#include 'parmtype.ch'

user function xmlEicon(cRPS, cOperacao)
local cXml := ""
default cOperacao = "envio"
Private cMun		:= SM0->M0_CODMUN
private aDmunicipio := u_NFSTLIB1(cMun)
	
	cRPS := AllTrim(Str(cRPS))
	
	if cOperacao == "envio"
 cXml := Enviar(cRPS)
	elseif cOperacao == "consulta"
 cXml := Situacao()
	elseif cOperacao == "cancela"
 cXml := Cancelar(cRPS)
	elseif cOperacao == "situacao"
 cXml := Situacao()
	endIf
return cXml

static function Enviar(cRPS)
local cXml := ""
local cNameSpace   := ""//"http://www.abrasf.org.br/nfse.xsd"

    cXml += '<EnviarLoteRpsEnvio xmlns="http://www.giss.com.br/enviar-lote-rps-envio-v2_04.xsd" xmlns:tipos="http://www.giss.com.br/tipos-v2_04.xsd">'
    cXml +=     '<LoteRps versao="1.00">'
    cXml +=         '<tipos:NumeroLote>' + cRPS + '</tipos:NumeroLote>'
    cXml +=         '<tipos:Prestador>'
    cXml +=         	'<tipos:CpfCnpj><tipos:Cnpj>' + u_ToXml(SM0->M0_CGC) + '</tipos:Cnpj></tipos:CpfCnpj>'
    cXml +=         	'<tipos:InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</tipos:InscricaoMunicipal>'
    cXml +=         '</tipos:Prestador>'
    cXml +=         '<tipos:QuantidadeRps>1</tipos:QuantidadeRps>'
    cXml +=         Rps(cRPS)
    cXml +=     '</LoteRps>'
    cXml += '</EnviarLoteRpsEnvio>'
    
    //cXML := u_AssinaDig(cXml, GetMV('JR_NFSWCDG' , , "ciarama12"), "LoteRps", '', "ENVIAR", cNameSpace)
    
    
return cXml

static function Rps(cRPS)
local cXml := ""

    cXml += '<tipos:ListaRps>'
    cXml +=   '<tipos:Rps>'
    cXml +=     '<tipos:InfDeclaracaoPrestacaoServico>'
    cXml +=             IdRps(cRps)
    cXml +=             '<tipos:Competencia>' + u_ToXml(SF2->F2_EMISSAO) + '</tipos:Competencia>'
    cXml +=             IdServico()
    cXml +=             IdPrestador()
    cXml +=             IdTomador()    
    cXml +=     '					<tipos:OptanteSimplesNacional>2</tipos:OptanteSimplesNacional>'
    cXml +=     '					<tipos:IncentivoFiscal>2</tipos:IncentivoFiscal>'    
    cXml +=     '</tipos:InfDeclaracaoPrestacaoServico>'
    cXml +=   '</tipos:Rps>'
    cXml += '</tipos:ListaRps>'
return cXml

static function IdRps(cRps)
local cXml := ""

	cXml +=     '<tipos:Rps>'
    cXml +=     	'<tipos:IdentificacaoRps>'
    cXml +=         	'<tipos:Numero>' + u_ToXml(SF2->F2_DOC) + '</tipos:Numero>'
    cXml +=         	'<tipos:Serie>' + u_ToXml(SF2->F2_SERIE) + '</tipos:Serie>'
    cXml +=         	'<tipos:Tipo>1</tipos:Tipo>' // 1 - Recibo Provisório de Serviços / 2 - RPS Nota Fiscal Conjugada (Mista) / 3 - Cupom 
    cXml +=     	'</tipos:IdentificacaoRps>'
    cXml +=     	'<tipos:DataEmissao>' + u_ToXml(SF2->F2_EMISSAO) + '</tipos:DataEmissao>' 
    cXml +=     	'<tipos:Status>1</tipos:Status>' // 1 - Normal / 2 - Cancelado 
    cXml +=     '</tipos:Rps>'
    
return cXml

static function IDServico()
local cXml := ""
local oXml := u_NFSDESC()    
	 cXml +=     '<tipos:Servico>'
	 cXml +=     '	<tipos:Valores>'
	 cXml +=     '		<tipos:ValorServicos>'+ u_ToXml(oXml:_rps:_servicos:_servico:_valtotal:Text) +'</tipos:ValorServicos>'
	 cXml +=     '		<tipos:ValorDeducoes>'+ u_ToXml(oXml:_rps:_servicos:_servico:_valdedu:Text) +'</tipos:ValorDeducoes>'
	 cXml +=     '		<tipos:ValorPis>'+ u_ToXml(oXml:_rps:_servicos:_servico:_valpis:Text) +'</tipos:ValorPis>'
	 cXml +=     '		<tipos:ValorCofins>'+ u_ToXml(oXml:_rps:_servicos:_servico:_valcof:Text) +'</tipos:ValorCofins>'
	 cXml +=     '		<tipos:ValorInss>'+ u_ToXml(oXml:_rps:_servicos:_servico:_valinss:Text) +'</tipos:ValorInss>'
	 cXml +=     '		<tipos:ValorIr>'+ u_ToXml(oXml:_rps:_servicos:_servico:_valir:Text) +'</tipos:ValorIr>'
	 cXml +=     '		<tipos:ValorCsll>'+ u_ToXml(oXml:_rps:_servicos:_servico:_valcsll:Text) +'</tipos:ValorCsll>'
	 cXml +=     '		<tipos:OutrasRetencoes>'+ u_ToXml(oXml:_rps:_servicos:_servico:_outrasret:Text) +'</tipos:OutrasRetencoes>'
	 cXml +=     '		<tipos:ValTotTributos>'+ u_ToXml(oXml:_rps:_servicos:_servico:_valtrib:Text) +'</tipos:ValTotTributos>'
	 cXml +=     '		<tipos:ValorIss>'+ u_ToXml(oXml:_rps:_servicos:_servico:_valiss:Text) +'</tipos:ValorIss>'
	 cXml +=     '		<tipos:Aliquota>'+ u_ToXml(oXml:_rps:_servicos:_servico:_aliquota:Text) +'</tipos:Aliquota>'
	 cXml +=     '		<tipos:DescontoIncondicionado>'+ u_ToXml(oXml:_rps:_servicos:_servico:_descinc:Text) +'</tipos:DescontoIncondicionado>'
	 cXml +=     '		<tipos:DescontoCondicionado>'+ u_ToXml(oXml:_rps:_servicos:_servico:_desccond:Text) +'</tipos:DescontoCondicionado>'
	 cXml +=     '	</tipos:Valores>'
	 cXml +=     '	<tipos:IssRetido>'+ u_ToXml(oXml:_rps:_servicos:_servico:_issretido:Text) +'</tipos:IssRetido>'
	 cXml +=     '	<tipos:ItemListaServico>'+ u_ToXml(oXml:_rps:_servicos:_servico:_codigo:Text) +'</tipos:ItemListaServico>'
	 cXml +=     '	<tipos:CodigoTributacaoMunicipio>'+ u_ToXml(oXml:_rps:_servicos:_servico:_codtrib:Text) +'</tipos:CodigoTributacaoMunicipio>'
	 cXml +=     '	<tipos:Discriminacao>'+ u_ToXml(oXml:_rps:_servicos:_servico:_discr:Text) +'</tipos:Discriminacao>'
	 cXml +=     '	<tipos:CodigoMunicipio>'+ u_ToXml(oXml:_rps:_prestacao:_codmunibgeinc:Text) +'</tipos:CodigoMunicipio>'
	 cXml +=     '	<tipos:CodigoPais>0076</tipos:CodigoPais>'
	 cXml +=     '	<tipos:ExigibilidadeISS>'+ u_ToXml(oXml:_rps:_identificacao:_deveissmunprestador:Text) +'</tipos:ExigibilidadeISS>'
	 cXml +=     '	<tipos:MunicipioIncidencia>'+ u_ToXml(oXml:_rps:_prestacao:_codmunibgeinc:Text) +'</tipos:MunicipioIncidencia>'
	 cXml +=     '</tipos:Servico>'
return cXml

static function IdPrestador()
local cXml := ""

    cXml += '<tipos:Prestador>'
    cXml +=     '<tipos:CpfCnpj><tipos:Cnpj>' + u_ToXml(SM0->M0_CGC) + '</tipos:Cnpj></tipos:CpfCnpj>'
   // cXml +=     '<tipos:InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</tipos:InscricaoMunicipal>'
    cXml += '</tipos:Prestador>'

return cXml

static function IdTomador()
local cXml := ""
local aEndereco := ""

    DbSelectArea("SA1")
    DbSetOrder(1)
    
    SA1->(DbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))
    aEndereco := FisGetEnd(SA1->A1_END, SA1->A1_EST)

    cXml += '<tipos:TomadorServico>'
    cXml +=     '<tipos:IdentificacaoTomador>'
    cXml +=         '<tipos:CpfCnpj>'
    cXml +=             Iif(SA1->A1_PESSOA == 'F', '<tipos:Cpf>' + u_ToXml(SA1->A1_CGC) + '</tipos:Cpf>', '<tipos:Cnpj>' + u_ToXml(SA1->A1_CGC) + '</tipos:Cnpj>' )
    cXml +=         '</tipos:CpfCnpj>'
    cXml +=     '</tipos:IdentificacaoTomador>'
    cXml +=     '<tipos:RazaoSocial>' + u_ToXml(SA1->A1_NOME) + '</tipos:RazaoSocial>'
    cXml +=     '<tipos:Endereco>'
    cXml +=         '<tipos:Endereco>' + u_ToXml(aEndereco[1]) + '</tipos:Endereco>'
    cXml +=         '<tipos:Numero>' + left(u_ToXml(aEndereco[3]),5) + '</tipos:Numero>'
    //cXml +=         '<Complemento>' + u_ToXml(SA1->A1_COMPLEM) + '</Complemento>'
    cXml +=         '<tipos:Bairro>' + u_ToXml(SA1->A1_BAIRRO) + '</tipos:Bairro>'
    cXml +=         '<tipos:CodigoMunicipio>' + u_ToXml(left(SA1->A1_IBGE, 7)) + '</tipos:CodigoMunicipio>'
    cXml +=         '<tipos:Uf>' + u_ToXml(SA1->A1_EST) + '</tipos:Uf>'
    cXml +=         '<tipos:Cep>' + u_ToXml(SA1->A1_CEP) + '</tipos:Cep>'
    cXml +=     '</tipos:Endereco>'
    if !empty(SA1->A1_EMAIL)
    	cXml +=     '<tipos:Contato>'
    	//cXml +=			'<Telefone>?</Telefone>'
    	cXml +=			'<tipos:Email>' + u_ToXml(SA1->A1_EMAIL) + '</tipos:Email>'
    	cXml +=     '</tipos:Contato>'
    endIf
    cXml += '</tipos:TomadorServico>'


return cXml

static function IdConstrucao()
local cXml := ""

cXml +=     '					<tipos:ConstrucaoCivil>'
cXml +=     '						<tipos:CodigoObra>' + u_ToXml(SC5->C5_OBRA) + '</tipos:CodigoObra>'
cXml +=     '					</tipos:ConstrucaoCivil>'

return cXml



static function Consultar(cRPS)
local cXml := ""
	
	cXml += '<ns1:ConsultarNfseRpsEnvio xmlns:ns1="http://www.giss.com.br/consultar-nfse-rps-envio-v2_04.xsd" xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns:tipos="http://www.giss.com.br/tipos-v2_04.xsd">' 
    cXml +=    '<ns1:IdentificacaoRps>' 
    cXml +=        '<tipos:Numero>' + u_ToXml(SF2->F2_DOC) + '</tipos:Numero>'
    cXml +=        '<tipos:Serie>' + u_ToXml(SF2->F2_SERIE) + '</tipos:Serie>'
    cXml +=        '<tipos:Tipo>1</tipos:Tipo>' // 1 - Recibo Provisório de Serviços / 2 - RPS Nota Fiscal Conjugada (Mista) / 3 - Cupom 
    cXml +=    '</ns1:IdentificacaoRps>' 
    cXml +=    '<ns1:Prestador>' 
    cXml +=        '<tipos:CpfCnpj>'
    cXml +=        		'<tipos:Cnpj>' + u_ToXml(SM0->M0_CGC) + '</tipos:Cnpj>'
    cXml +=        '</tipos:CpfCnpj>'
    cXml +=        '<tipos:InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</tipos:InscricaoMunicipal>'
    cXml +=    '</ns1:Prestador>' 
    cXml += '</ns1:ConsultarNfseRpsEnvio>'
	
return cXml

static function Situacao()
local cXml := ""
    
	cXml :=	'<ns1:ConsultarLoteRpsEnvio xmlns:ns1="http://www.giss.com.br/consultar-lote-rps-envio-v2_04.xsd" xmlns:tipos="http://www.giss.com.br/tipos-v2_04.xsd" xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
    cXml +=		'<ns1:Prestador>'
    cXml +=			'<tipos:CpfCnpj><tipos:Cnpj>' + u_ToXml(SM0->M0_CGC) + '</tipos:Cnpj></tipos:CpfCnpj>'
    cXml +=			'<tipos:InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</tipos:InscricaoMunicipal>'
    cXml +=		'</ns1:Prestador>'
    cXml +=		'<ns1:Protocolo>'+alltrim(SF2->F2_XNFSPRT)+'</ns1:Protocolo>'
    cXml +=	'</ns1:ConsultarLoteRpsEnvio>' 

return cXml

static function Cancelar(cRPS)
local cXml := ""

	cXml := '<ns1:CancelarNfseEnvio xmlns:ns1="http://www.giss.com.br/cancelar-nfse-envio-v2_04.xsd" xmlns:tipos="http://www.giss.com.br/tipos-v2_04.xsd" xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' 
    cXml +=     '<Pedido>'                      
    cXml +=         '<tipos:InfPedidoCancelamento Id="'+cRPS+'">' 
    cXml +=             '<tipos:IdentificacaoNfse>'
    cXml +=                 '<tipos:Numero>' + AllTrim(SF2->F2_NFELETR) + '</tipos:Numero>'
    cXml +='<tipos:CpfCnpj><tipos:Cnpj>' + u_ToXml(SM0->M0_CGC) + '</tipos:Cnpj></tipos:CpfCnpj>'
    cXml +='<tipos:InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</tipos:InscricaoMunicipal>'
    cXml +=                 '<tipos:CodigoMunicipio>' + u_ToXml(SM0->M0_CODMUN) + '</tipos:CodigoMunicipio>'
    cXml +=             '</tipos:IdentificacaoNfse>' 
    cXml +=             '<tipos:CodigoCancelamento>1</tipos:CodigoCancelamento>'  /* Código de cancelamento com base na tabela de Erros e alertas. 1 – Erro na emissão, 2 – Serviço não prestado, 3 – Erro de assinatura, 4 – Duplicidade da nota, 5 – Erro de processamento */
    cXml +=         '</tipos:InfPedidoCancelamento>' 
    cXml +=     '</Pedido>' 
    cXml += '</ns1:CancelarNfseEnvio>' 
    cXml := EncodeUTF8(cXml)

return cXml

user function EiconNumNF(oXml)
local cNFSE := ""
	cNFSE := WSAdvValue( oXml, "_NS3_CONSULTARLOTERPSRESPOSTA:_NS3_COMPNFSE:_NS3_NFSE:_NS3_INFNFSE:_NS3_NUMERO:TEXT","string" )
return cNFSE

user function EiconProtocolo(oXml)
local cProt := ""
	cProt := WSAdvValue( oXml, "_NS3_ENVIARLOTERPSRESPOSTA:_NS3_PROTOCOLO:TEXT","string")
return cProt

user function EiconCVer(oXml)
local cCVer := ""
	cCVer := WSAdvValue( oXml, "_NS3_CONSULTARLOTERPSRESPOSTA:_NS3_COMPLNFSE:_NS3_NFSE:_NS3_INFNFSE:_NS3_CodigoVerificacao:TEXT","string")
return cCVer