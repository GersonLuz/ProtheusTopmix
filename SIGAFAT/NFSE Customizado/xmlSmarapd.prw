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

user function xmlSmarapd(cRPS, cOperacao)
	local cXml := ""
	Local cError   := ""
	Local cWarning := ""
	
	Local aDados := {}
	default cOperacao = "envio"
	Private oXml := NIL
	Private cMun		:= SM0->M0_CODMUN
	private aDmunicipio := u_NFSTLIB1(cMun)

	private oXml := u_NFSDESC()//("1", SF2->F2_EMISSAO, SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_CLIENTE, SF2->F2_LOJA, "")
	
	
	
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

static function Enviar(cRPS) // monta RPS

	local cXml := ""
	local cNameSpace   := ""//"http://www.abrasf.org.br/nfse.xsd"
	cXml += '<?xml version="1.0" encoding="utf-8"?>'
	cXml += '<tbnfd>'
	cXml += '	<nfd>'
	cXml += '		<numeronfd>0</numeronfd>'
	cXml += '		<codseriedocumento>7</codseriedocumento>'
	//se aliq=0 e oXml:_rps:_servicos:_servico:_issretido:Text == "1" -- 300
	if (Val(StrTran(oXml:_rps:_servicos:_servico:_aliquota:Text,",",".")) == 0)
	cXml += '		<codnaturezaoperacao>300</codnaturezaoperacao>'
	//se aliq>0 e oXml:_rps:_servicos:_servico:_issretido:Text == "1" e municipio = 3205002 -- 511
	Elseif ((Val(StrTran(oXml:_rps:_servicos:_servico:_aliquota:Text,",",".")) > 0) .AND. (oXml:_rps:_servicos:_servico:_issretido:Text == "2") .AND. (oXml:_rps:_prestacao:_codmunibge:Text == "3205002")) 
	cXml += '		<codnaturezaoperacao>511</codnaturezaoperacao>'
	//se aliq>0 e oXml:_rps:_servicos:_servico:_issretido:Text == "2" e municipio = 3205002 -- 512
	Elseif ((Val(StrTran(oXml:_rps:_servicos:_servico:_aliquota:Text,",",".")) > 0) .AND. (oXml:_rps:_servicos:_servico:_issretido:Text == "1") .AND. (oXml:_rps:_prestacao:_codmunibge:Text == "3205002"))
	cXml += '		<codnaturezaoperacao>512</codnaturezaoperacao>'
	//se aliq>0 e oXml:_rps:_servicos:_servico:_issretido:Text == "1" e municipio <> 3205002 -- 615
	Elseif ((Val(StrTran(oXml:_rps:_servicos:_servico:_aliquota:Text,",",".")) > 0) .AND. (oXml:_rps:_servicos:_servico:_issretido:Text == "2") .AND. (oXml:_rps:_prestacao:_codmunibge:Text != "3205002"))
	cXml += '		<codnaturezaoperacao>615</codnaturezaoperacao>'
	//se aliq>0 e oXml:_rps:_servicos:_servico:_issretido:Text == "2" e municipio <> 3205002 -- 616
	Elseif ((Val(StrTran(oXml:_rps:_servicos:_servico:_aliquota:Text,",",".")) > 0) .AND. (oXml:_rps:_servicos:_servico:_issretido:Text == "1") .AND. (oXml:_rps:_prestacao:_codmunibge:Text != "3205002"))
	cXml += '		<codnaturezaoperacao>616</codnaturezaoperacao>'
	Endif	
	cXml += '		<codigocidade>3</codigocidade>'
	cXml += '		<inscricaomunicipalemissor>' + u_ToXml(SM0->M0_INSCM) + '</inscricaomunicipalemissor>'
	cXml += '		<dataemissao>' + DTOC(SF2->F2_EMISSAO) + '</dataemissao>'
	cXml += '		<razaotomador>' + u_ToXml(StrTran((SA1->A1_NOME),"&","E")) + '</razaotomador>'
	cXml += '		<nomefantasiatomador>' + u_ToXml(StrTran((SA1->A1_NREDUZ),"&","E")) + '</nomefantasiatomador>'
	cXml += '		<enderecotomador>' + u_ToXml(oXml:_rps:_tomador:_logradouro:Text) + ', ' + u_ToXml(oXml:_rps:_tomador:_numend:Text) + '</enderecotomador>'
	cXml += '		<numeroendereco>' + u_ToXml(oXml:_rps:_tomador:_numend:Text) + '</numeroendereco>'
	cXml += '		<cidadetomador>' + u_ToXml(oXml:_rps:_tomador:_cidade:Text) + '</cidadetomador>'
	//cXml += '		<estadotomador>' + u_ToXml(oXml:_rps:_tomador:_uf:Text) + '</estadotomador>'
	cXml += '		<paistomador>Brasil</paistomador>'
	cXml += '		<estadotomador>' + u_ToXml(oXml:_rps:_tomador:_uf:Text) + '</estadotomador>'
	cXml += '		<fonetomador>' + u_ToXml(oXml:_rps:_tomador:_telefone:Text) + '</fonetomador>'
	cXml += '		<faxtomador />'
	cXml += '		<ceptomador>' + u_ToXml(oXml:_rps:_tomador:_cep:Text) + '</ceptomador>'
	cXml += '		<bairrotomador>' + u_ToXml(oXml:_rps:_tomador:_bairro:Text) + '</bairrotomador>'
	cXml += '		<emailtomador>' + u_ToXml(oXml:_rps:_tomador:_email:Text) + '</emailtomador>'
	cXml += '		<tppessoa>' + u_ToXml(SA1->A1_PESSOA) + '</tppessoa>'
	cXml += '		<cpfcnpjtomador>' + u_ToXml(oXml:_rps:_tomador:_cpfcnpj:Text) + '</cpfcnpjtomador>'
	cXml += '		<inscricaoestadualtomador>' + u_ToXml(SA1->A1_INSCR) + '</inscricaoestadualtomador>'
	cXml += '		<inscricaomunicipaltomador>' + u_ToXml(oXml:_rps:_tomador:_inscmun:Text) + '</inscricaomunicipaltomador>'
	cXml += '		<tbservico>'
	cXml += '			<servico>'
	cXml += '				<quantidade>1</quantidade>'
	//cXml += '				<descricao>' + u_ToXml(StrTran(StrTran(oXml:_rps:_servicos:_servico:_discr:Text,StrTran(oXml:_rps:_prestacao:_codmunibge:Text,'32','',1,1),'-' + oXml:_rps:_prestacao:_municipio:Text + '-',1,1),"SERV. CONCRETAGEM RPS:",' CEP: ' + oXml:_rps:_prestacao:_cep:Text + ' SERV. CONCRETAGEM RPS:')) + '</descricao>'
	//MARRETADO
	cXml += '				<descricao>' + u_ToXml(StrTran(StrTran(StrTran(oXml:_rps:_servicos:_servico:_discr:Text,StrTran(oXml:_rps:_prestacao:_codmunibge:Text,'32','',1,1),'-' + oXml:_rps:_prestacao:_municipio:Text + '-',1,1),"SERV. CONCRETAGEM RPS:",' CEP: ' + (SC5->C5_ZCEPOB) + ' SERV. CONCRETAGEM RPS:'),"EXIGIBILIDADE SUSPENSA POR DECISAO JUDICIAL CONF.PROCESSO 048070128870 10-08-2009 ","")) + '</descricao>'
	//cXml += '				<descricao>' + u_ToXml(StrTran(oXml:_rps:_servicos:_servico:_discr:Text,StrTran(oXml:_rps:_prestacao:_codmunibge:Text,'32','',1,1),'-' + oXml:_rps:_prestacao:_municipio:Text + '-',1,1)) + '</descricao>'
	cXml += '				<codatividade>' + u_ToXml(oXml:_rps:_servicos:_servico:_codigo:Text) + '</codatividade>'
	cXml += '				<valorunitario>' + u_ToXml(StrTran((oXml:_rps:_servicos:_servico:_valtotal:Text),".",",")) + '</valorunitario>'
	cXml += '				<aliquota>' + u_ToXml(Val(StrTran(oXml:_rps:_servicos:_servico:_aliquota:Text,",","."))/100) + '</aliquota>'
	//cXml += '				<impostoretido />'
	cXml += 				Iif(oXml:_rps:_servicos:_servico:_issretido:Text == "2", '<impostoretido>False</impostoretido>','<impostoretido>True</impostoretido>')
	cXml += '			</servico>'
	cXml += '		</tbservico>'
	cXml += '		<observacao />'
	cXml += '		<pis>' + u_ToXml(oXml:_rps:_valores:_pis:Text) + '</pis>'
	cXml += '		<cofins>' + u_ToXml(oXml:_rps:_valores:_cofins:Text) + '</cofins>'
	cXml += '		<csll>' + u_ToXml(oXml:_rps:_valores:_csll:Text) + '</csll>'
	cXml += '		<irrf>' + u_ToXml(oXml:_rps:_valores:_ir:Text) + '</irrf>'
	cXml += '		<inss>' + u_ToXml(oXml:_rps:_valores:_inss:Text) + '</inss>'
	cXml += '		<descdeducoesconstrucao />'
	cXml += '		<totaldeducoesconstrucao>' + u_ToXml(StrTran((oXml:_rps:_deducoes:_deducao:_valor:Text),".",",")) + '</totaldeducoesconstrucao>'
	cXml += 		Iif(oXml:_rps:_tomador:_codmunibge:Text == "3205002",'<tributadonomunicipio>true</tributadonomunicipio>','<tributadonomunicipio>false</tributadonomunicipio>')
	cXml += '		<numerort>' + u_ToXml(oXml:_rps:_identificacao:_numerorps:Text) + '</numerort>'
	cXml += '		<codigoseriert>7</codigoseriert>'
	//cXml += '		<dataemissaort>' + u_ToXml(oXml:_rps:_identificacao:_dthremissao:Text) + '</dataemissaort>'
	cXml += '		<dataemissaort>' + DTOC(SF2->F2_EMISSAO) + '</dataemissaort>'
	//cXml += '		<fatorgerador>' + u_ToXml(oXml:_rps:_valores:_pis:Text) + '</cofins>'
	cXml += '	</nfd>'
	cXml += '</tbnfd>'

return cXml

static function Rps(cRPS)
	local cXml := ""

	cXml += '<ListaRps>'
	cXml +=   '<Rps>'
	cXml +=     '<InfDeclaracaoPrestacaoServico>'
	cXml +=             IdRps(cRps)
	cXml +=             '<Competencia>' + u_ToXml(SF2->F2_EMISSAO) + '</Competencia>'
	cXml +=             IdServico()
	cXml +=             IdPrestador()
	cXml +=             IdTomador()
	//cXml +=             IdConstrucao()
	cXml +=         '<RegimeEspecialTributacao>1</RegimeEspecialTributacao>' // 1-Sim / 2-Nao	
	cXml +=         '<OptanteSimplesNacional>2</OptanteSimplesNacional>' // 1-Sim / 2-Nao	
	cXml +=         '<IncentivoFiscal>2</IncentivoFiscal>' // 1-Sim / 2-Nao	
	cXml +=     '</InfDeclaracaoPrestacaoServico>'
	cXml +=   '</Rps>'
	cXml += '</ListaRps>'
return cXml

static function IdRps(cRps)
	local cXml := ""

	cXml +=     '<Rps Id="RPS_'+u_ToXml(SF2->F2_DOC)+'_U_1">'
	cXml +=     	'<IdentificacaoRps>'
	cXml +=         	'<Numero>' + u_ToXml(SF2->F2_DOC) + '</Numero>'
	cXml +=         	'<Serie>' + u_ToXml(SF2->F2_SERIE) + '</Serie>'
	cXml +=         	'<Tipo>1</Tipo>' // 1 - Recibo Provisório de Serviços / 2 - RPS Nota Fiscal Conjugada (Mista) / 3 - Cupom
	cXml +=     	'</IdentificacaoRps>'
	cXml +=     	'<DataEmissao>' + u_ToXml(SF2->F2_EMISSAO) + '</DataEmissao>'
	cXml +=     	'<Status>1</Status>' // 1 - Normal / 2 - Cancelado
	cXml +=     '</Rps>'

return cXml

static function IDServico()
	local cXml := ""
	local aDadosNFSE := u_NFSDESC()
	//local aDadosZZ0  := u_NFSTLIB1(cMun) 

	cXml += '<Servico>'
	cXml += '	<Valores>'
	cXml += '		<ValorServicos>' + u_ToXml(oXml:_rps:_servicos:_servico:_valtotal:Text) + '</ValorServicos>'
	cXml += '		<ValorDeducoes>' + u_ToXml(oXml:_rps:_servicos:_servico:_valdedu:Text) + '</ValorDeducoes>'
	cXml += '		<ValorPis>' + u_ToXml(oXml:_rps:_servicos:_servico:_valpis:Text) + '</ValorPis>'
	cXml += '		<ValorCofins>' + u_ToXml(oXml:_rps:_servicos:_servico:_valcof:Text) + '</ValorCofins>'
	cXml += '		<ValorInss>' + u_ToXml(oXml:_rps:_servicos:_servico:_valinss:Text) + '</ValorInss>'
	cXml += '		<ValorIr>' + u_ToXml(oXml:_rps:_servicos:_servico:_valir:Text) + '</ValorIr>'
	cXml += '		<ValorCsll>' + u_ToXml(oXml:_rps:_servicos:_servico:_valcsll:Text) + '</ValorCsll>'
	cXml += '		<OutrasRetencoes>' + u_ToXml(oXml:_rps:_servicos:_servico:_outrasret:Text) + '</OutrasRetencoes>'
	cXml += '		<ValorIss>' + u_ToXml(oXml:_rps:_servicos:_servico:_valiss:Text) + '</ValorIss>' //exemplo dados xml
	//cXml += 		Iif(oXml:_rps:_servicos:_servico:_aliquota:Text != '', '<Aliquota>' + u_ToXml(Val(StrTran(oXml:_rps:_servicos:_servico:_aliquota,",",".")) / 100) + '</Aliquota>','0.00' )
	cXml += '		<Aliquota>' + u_ToXml(Val(StrTran(oXml:_rps:_servicos:_servico:_aliquota:Text,",",".")) / 100) + '</Aliquota>'
	//cXml += '		<Aliquota>' + u_ToXml(oXml:_rps:_servicos:_servico:_aliquota:Text) + '</Aliquota>'
	cXml += '		<DescontoIncondicionado>' + u_ToXml(oXml:_rps:_servicos:_servico:_descinc:Text) + '</DescontoIncondicionado>'
	cXml += '		<DescontoCondicionado>' + u_ToXml(oXml:_rps:_servicos:_servico:_desccond:Text) + '</DescontoCondicionado>'
	cXml += '	</Valores>'
	if SC5->C5_RECISS == '2'
		cXml +=     '<IssRetido>2</IssRetido>'
		cXml +=     '<ResponsavelRetencao>1</ResponsavelRetencao>'
	else
		cXml +=     '<IssRetido>1</IssRetido>'
	endif	
	cXml += '	<ItemListaServico>' + u_ToXml(aDmunicipio[1][2]) + '</ItemListaServico>'//ZZ0
	cXml += '	<CodigoCnae>' + u_ToXml(aDmunicipio[1][1]) + '</CodigoCnae>'
	cXml +=     Iif(!Empty(aDmunicipio[1][4]), '<CodigoTributacaoMunicipio>' + u_ToXml(aDmunicipio[1][4]) + '</CodigoTributacaoMunicipio>','' )
	//cXml += '	<Discriminacao>' + u_ToXml(oXml:_rps:_servicos:_servico:_discr:Text) + '</Discriminacao>'
	cXml += '	<Discriminacao>' + u_ToXml(StrTran(oXml:_rps:_servicos:_servico:_discr:Text,StrTran(oXml:_rps:_prestacao:_codmunibge:Text,'31','',1,1),'-' + oXml:_rps:_prestacao:_municipio:Text + '-',1,1)) + '</Discriminacao>'
	cXml += '	<CodigoMunicipio>' + u_ToXml(SM0->M0_CODMUN) + '</CodigoMunicipio>'
	cXml += '	<CodigoPais>1058</CodigoPais>'
	cXml += '	<ExigibilidadeISS>' + u_ToXml(oXml:_rps:_identificacao:_deveissmunprestador:Text) + '</ExigibilidadeISS>'
	cXml += '	<MunicipioIncidencia>' + u_ToXml(oXml:_rps:_prestacao:_codmunibge:Text) + '</MunicipioIncidencia>'	
	cXml += '</Servico>'

return cXml

static function IdPrestador()
	local cXml := ""

	cXml += '<Prestador>'
	cXml +=     '<CpfCnpj><Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj></CpfCnpj>' 
	cXml +=     '<InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</InscricaoMunicipal>'
	//cXml +=     '<InscricaoEstadual>' + u_ToXml(SM0->M0_INSC) + '</InscricaoEstadual>'
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
	//cXml +=     	Iif(SA1->A1_PESSOA == 'J', '<InscricaoMunicipal>' + u_ToXml(SA1->A1_INSCRM) + '</InscricaoMunicipal>','' )
	If SA1->A1_PESSOA == 'J'
	cXml +=		IIf(!Empty(SA1->A1_INSCRM),'<InscricaoMunicipal>' + u_ToXml(SA1->A1_INSCRM) + '</InscricaoMunicipal>','')
	//cXml +=		IIf(!Empty(SA1->A1_INSCR),'<InscricaoEstadual>' + u_ToXml(SA1->A1_INSCR) + '</InscricaoEstadual>','') //adicionado 06/05/2019 por solicitação da Barbara - faturamento
	EndIf
	cXml +=     '</IdentificacaoTomador>'
cXml +=     '<RazaoSocial>' + u_ToXml(StrTran((SA1->A1_NOME),"&","E")) + '</RazaoSocial>'
	cXml +=     '<Endereco>'
	cXml +=         '<Endereco>' + u_ToXml(oXml:_rps:_tomador:_logradouro:Text) + '</Endereco>'
	cXml +=         '<Numero>' + u_ToXml(oXml:_rps:_tomador:_numend:Text) + '</Numero>'
	cXml +=             Iif(!Empty(SA1->A1_COMPLEM), '<Complemento>' + u_ToXml(SA1->A1_COMPLEM) + '</Complemento>','' )
	//cXml +=             Iif(SA1->A1_COMPLEM != '                                                  ', '<Complemento>' + u_ToXml(SA1->A1_COMPLEM) + '</Complemento>','' )
	//cXml +=         '<Complemento>' + u_ToXml(SA1->A1_COMPLEM) + '</Complemento>'
	cXml +=         '<Bairro>' + u_ToXml(oXml:_rps:_tomador:_bairro:Text) + '</Bairro>'
	cXml +=         '<CodigoMunicipio>' + u_ToXml(oXml:_rps:_tomador:_codmunibge:Text) + '</CodigoMunicipio>'
	cXml +=         '<Uf>' + u_ToXml(oXml:_rps:_tomador:_uf:Text) + '</Uf>'
	cXml +=			'<CodigoPais>1058</CodigoPais>'
	cXml +=         '<Cep>' + u_ToXml(oXml:_rps:_tomador:_cep:Text) + '</Cep>'
	cXml +=     '</Endereco>'
	if !empty(SA1->A1_EMAIL)
	cXml +=     '<Contato>'
	cXml +=			'<Telefone>'+ u_ToXml(oXml:_rps:_tomador:_telefone:Text) +'</Telefone>'
	cXml +=			'<Email>' + u_ToXml(oXml:_rps:_tomador:_email:Text) + '</Email>'
	cXml +=     '</Contato>'
	endIf
	cXml += '</Tomador>'
	
return cXml


static function IdConstrucao()
	local cXml := ""
	cXml += '<ConstrucaoCivil>'
	cXml += '	<CodigoObra>'+ u_ToXml(cValToChar(SC6->(Recno()))) + '</CodigoObra>'
	cXml += '	<Art>'+ u_ToXml(SC5->C5_ARTOBRA) + '</Art>'
	cXml += '</ConstrucaoCivil>'	
return cXml



////////////////////////////////////////////
static function Consultar(cRPS)
	local cXml := ""

	cXml += '<ns1:ConsultarNfseRpsEnvio xmlns:ns1="http://www.giss.com.br/consultar-nfse-rps-envio-v2_04.xsd" xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns:tipos="http://www.giss.com.br/tipos-v2_04.xsd">'
	cXml +=    '<ns1:IdentificacaoRps>'
	cXml +=        '<Numero>' + u_ToXml(SF2->F2_DOC) + '</Numero>'
	cXml +=        '<Serie>' + u_ToXml(SF2->F2_SERIE) + '</Serie>'
	cXml +=        '<Tipo>1</Tipo>' // 1 - Recibo Provisório de Serviços / 2 - RPS Nota Fiscal Conjugada (Mista) / 3 - Cupom
	cXml +=    '</ns1:IdentificacaoRps>'
	cXml +=    '<ns1:Prestador>'
	cXml +=        '<CpfCnpj>'
	cXml +=        		'<Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj>'
	cXml +=        '</CpfCnpj>'
	cXml +=        '<InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</InscricaoMunicipal>'
	cXml +=    '</ns1:Prestador>'
	cXml += '</ns1:ConsultarNfseRpsEnvio>'

return cXml

static function Situacao()
	local cXml := ""

	cXml :=	'<ns1:ConsultarLoteRpsEnvio xmlns:ns1="http://www.giss.com.br/consultar-lote-rps-envio-v2_04.xsd" xmlns:tipos="http://www.giss.com.br/tipos-v2_04.xsd" xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
	cXml +=		'<ns1:Prestador>'
	cXml +=			'<CpfCnpj><Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj></CpfCnpj>'
	cXml +=			'<InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</InscricaoMunicipal>'
	cXml +=		'</ns1:Prestador>'
	cXml +=		'<ns1:Protocolo>'+alltrim(SF2->F2_XNFSPRT)+'</ns1:Protocolo>'
	cXml +=	'</ns1:ConsultarLoteRpsEnvio>'

return cXml

static function Cancelar(cRPS)
	local cXml := ""

	cXml := '<ns1:CancelarNfseEnvio xmlns:ns1="http://www.giss.com.br/cancelar-nfse-envio-v2_04.xsd" xmlns:tipos="http://www.giss.com.br/tipos-v2_04.xsd" xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
	cXml +=     '<Pedido>'
	cXml +=         '<InfPedidoCancelamento Id="'+cRPS+'">'
	cXml +=             '<IdentificacaoNfse>'
	cXml +=                 '<Numero>' + AllTrim(SF2->F2_NFELETR) + '</Numero>'
	cXml +=					'<CpfCnpj><Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj></CpfCnpj>'
	cXml +=					'<InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</InscricaoMunicipal>'
	cXml +=                 '<CodigoMunicipio>' + u_ToXml(SM0->M0_CODMUN) + '</CodigoMunicipio>'
	cXml +=             '</IdentificacaoNfse>'
	cXml +=             '<CodigoCancelamento>1</CodigoCancelamento>'  /* Código de cancelamento com base na tabela de Erros e alertas. 1 – Erro na emissão, 2 – Serviço não prestado, 3 – Erro de assinatura, 4 – Duplicidade da nota, 5 – Erro de processamento */
	cXml +=         '</InfPedidoCancelamento>'
	cXml +=     '</Pedido>'
	cXml += '</ns1:CancelarNfseEnvio>'
	cXml := EncodeUTF8(cXml)

return cXml

/*user function PortalFacilNumNF(oXml)
	local cNFSE := ""
	cNFSE := WSAdvValue( oXml, "_NS3_CONSULTARLOTERPSRESPOSTA:_NS3_COMPNFSE:_NS3_NFSE:_NS3_INFNFSE:_NS3_NUMERO:TEXT","string" )
return cNFSE

user function PortalFacilProtocolo(oXml)
	local cProt := ""
	cProt := WSAdvValue( oXml, "_NS3_ENVIARLOTERPSRESPOSTA:_NS3_PROTOCOLO:TEXT","string")
return cProt

user function PortalFacilCVer(oXml)
	local cCVer := ""
	cCVer := WSAdvValue( oXml, "_NS3_CONSULTARLOTERPSRESPOSTA:_NS3_COMPLNFSE:_NS3_NFSE:_NS3_INFNFSE:_NS3_CodigoVerificacao:TEXT","string")
return cCVer*/