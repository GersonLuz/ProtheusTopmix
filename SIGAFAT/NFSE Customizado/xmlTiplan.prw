#include 'totvs.ch'
#include 'parmtype.ch'

user function xmlTiplan(cRPS, cOperacao)
local cXml := ""
default cOperacao = "envio"
private aDmunicipio := u_NFSTLIB1(cMun)
private cNrps := cRPS	

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
    cXml += '<EnviarLoteRpsSincronoEnvio xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.abrasf.org.br/nfse.xsd">'
    cXml +=     '<LoteRps versao="2.03">'
    cXml +=         '<NumeroLote>' + cRPS + '</NumeroLote>'
    cXml +=         	'<CpfCnpj><Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj></CpfCnpj>'
    cXml +=         	'<InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</InscricaoMunicipal>'
    cXml +=         '<QuantidadeRps>1</QuantidadeRps>'
    cXml +=         Rps(cRPS)
    cXml +=     '</LoteRps>'
    cXml += '</EnviarLoteRpsSincronoEnvio>'
    
    //cXML := u_AssinaDig(cXml, GetMV('JR_NFSWCDG' , , "ciarama12"), "LoteRps", '', "ENVIAR", cNameSpace)
    
    
return cXml

static function Rps(cRPS)
local cXml := ""

    cXml += '<ListaRps>'
    cXml +=   '<Rps>'
    cXml +=     '<InfDeclaracaoPrestacaoServico xmlns="http://www.abrasf.org.br/nfse.xsd" Id="RPS_' +cRps+ '">'
    cXml +=             IdRps(cRps)
    cXml +=             '<Competencia>' + u_ToXml(SF2->F2_EMISSAO) + '</Competencia>'
    cXml +=             IdServico()
    cXml +=             IdPrestador()
    cXml +=             IdTomador()    
    cXml +=     '					<OptanteSimplesNacional>2</OptanteSimplesNacional>'
    cXml +=     '					<IncentivoFiscal>2</IncentivoFiscal>'    
    cXml +=     '</InfDeclaracaoPrestacaoServico>'
    cXml +=   '</Rps>'
    cXml += '</ListaRps>'
return cXml

static function IdRps(cRps)
local cXml := ""

	cXml +=     '<Rps>'
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
local oXml := u_NFSDESC()  
local aD := u_NFSTLIB1(cMun)
local cTextSGoncalo := ""


If(oXml:_rps:_prestacao:_codmunibgeinc:Text == '3304904') 
	cTextSGoncalo += FwNoAccent('DEDUÇÃO DOS MATERIAIS APLICADOS NA EXECUÇÃO DO SERVIÇO DE CONCRETAGEM DA BASE DE CALCULO DO ISSQN CONF. ACÓRDÃO DOS AUTO DE APELAÇÃO CIVIL Nº 2007.001.09717, ORIGINADOS DA 4º VARA CIVIL DA COMARCA DE SÃO GONÇALO EM 28/01/2008.')
End If

  
	 cXml +=     '<Servico>'
	 cXml +=     '	<Valores>'
	 cXml +=     '		<ValorServicos>'+ u_ToXml(val(oXml:_rps:_servicos:_servico:_valtotal:Text)) +'</ValorServicos>'
	 cXml +=     '		<ValorDeducoes>'+ u_ToXml(val(oXml:_rps:_servicos:_servico:_valdedu:Text)) +'</ValorDeducoes>'	 
	 cXml +=     '		<ValorIss>'+ u_ToXml(val(oXml:_rps:_servicos:_servico:_valiss:Text)) +'</ValorIss>'
	 cXml +=     '		<Aliquota>'+ u_ToXml(val(oXml:_rps:_servicos:_servico:_aliquota:Text)) +'</Aliquota>'
	 cXml +=     '		<DescontoIncondicionado>'+ u_ToXml(oXml:_rps:_servicos:_servico:_descinc:Text) +'</DescontoIncondicionado>'
	 cXml +=     '		<DescontoCondicionado>'+ u_ToXml(oXml:_rps:_servicos:_servico:_desccond:Text) +'</DescontoCondicionado>'
	 cXml +=     '	</Valores>'
	 cXml +=     '	<IssRetido>'+ u_ToXml(oXml:_rps:_servicos:_servico:_issretido:Text) +'</IssRetido>'
	 If SC5->(FieldPos("C5_CLIINT")) > 0 .And. SC5->(FieldPos("C5_CGCINT")) > 0 .And. SC5->(FieldPos("C5_IMINT")) > 0;
					   .And. !Empty(SC5->C5_CLIINT) .And. !Empty(SC5->C5_CGCINT) .And. !Empty(SC5->C5_IMINT)
	 	cXml +=     '	<ResponsavelRetencao>2</ResponsavelRetencao>'
	 ELSEif(oXml:_rps:_servicos:_servico:_issretido:Text == "2")
	 	
	 ELSE
	 	cXml +=     '	<ResponsavelRetencao>1</ResponsavelRetencao>'
	 EndIf
	 
	 
	 
	 cXml +=     '	<ItemListaServico>'+ u_ToXml(aD[1][2]) +'</ItemListaServico>'
	 cXml +=     '	<CodigoCnae>'+ u_ToXml(aD[1][1]) +'</CodigoCnae>'
	 cXml +=     '	<CodigoTributacaoMunicipio>'+ u_ToXml(aD[1][2]) +'</CodigoTributacaoMunicipio>'
	 cXml +=     '	<Discriminacao>'+ u_ToXml(oXml:_rps:_servicos:_servico:_discr:Text + cTextSGoncalo ) + '</Discriminacao>'
	 cXml +=     '	<CodigoMunicipio>'+ u_ToXml(oXml:_rps:_prestacao:_codmunibgeinc:Text) +'</CodigoMunicipio>'
	 cXml +=     '	<ExigibilidadeISS>1</ExigibilidadeISS>'
	 cXml +=     '	<MunicipioIncidencia>'+ u_ToXml(oXml:_rps:_prestacao:_codmunibgeinc:Text) +'</MunicipioIncidencia>'
	 cXml +=     '</Servico>'
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
local oXml := u_NFSDESC() 

    DbSelectArea("SA1")
    DbSetOrder(1)
    
    SA1->(DbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))
    aEndereco := FisGetEnd(SA1->A1_END, SA1->A1_EST)

    cXml += '<Tomador>'
    cXml +=     '<IdentificacaoTomador>'
    cXml +=         '<CpfCnpj>'
    cXml +=             Iif(SA1->A1_PESSOA == 'F', '<Cpf>' + u_ToXml(SA1->A1_CGC) + '</Cpf>', '<Cnpj>' + u_ToXml(SA1->A1_CGC) + '</Cnpj>' )
    cXml +=         '</CpfCnpj>'
    
    If(!Empty(SA1->A1_INSCRM) .AND. SA1->A1_INSCRM != "ISENTO" .AND. SA1->A1_PESSOA != 'F') 
    	cXml +=         '<InscricaoMunicipal>' + StrTran( FwNoAccent(u_ToXml(SA1->A1_INSCRM)), "-", "" ) + '</InscricaoMunicipal>'
    EndIf
    
    cXml +=     '</IdentificacaoTomador>'
    cXml +=     '<RazaoSocial>' + u_ToXml(SA1->A1_NOME) + '</RazaoSocial>'
    cXml +=     '<Endereco>'
    cXml +=         '<Endereco>' + u_ToXml(aEndereco[1]) + '</Endereco>'
    cXml +=         '<Numero>' + left(u_ToXml(aEndereco[3]),5) + '</Numero>'
    //cXml +=         '<Complemento>' + u_ToXml(SA1->A1_COMPLEM) + '</Complemento>'
    cXml +=         '<Bairro>' + u_ToXml(SA1->A1_BAIRRO) + '</Bairro>'
    cXml +=         '<CodigoMunicipio>'+ u_ToXml(oXml:_rps:_tomador:_codmunibge:Text) +'</CodigoMunicipio>'
    cXml +=         '<Uf>' + u_ToXml(SA1->A1_EST) + '</Uf>'
    cXml +=         '<Cep>' + u_ToXml(SA1->A1_CEP) + '</Cep>'
    cXml +=     '</Endereco>'
    if !empty(SA1->A1_EMAIL)
    	cXml +=     '<Contato>'
    	//cXml +=			'<Telefone>?</Telefone>'
    	cXml +=			'<Email>' + u_ToXml(SA1->A1_EMAIL) + '</Email>'
    	cXml +=     '</Contato>'
    endIf
    cXml += '</Tomador>'


return cXml

static function IdConstrucao()
local cXml := ""

cXml +=     '					<ConstrucaoCivil>'
cXml +=     '						<CodigoObra>' + u_ToXml(SC5->C5_OBRA) + '</CodigoObra>'
cXml +=     '					</ConstrucaoCivil>'

return cXml



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
    cXml +='<CpfCnpj><Cnpj>' + u_ToXml(SM0->M0_CGC) + '</Cnpj></CpfCnpj>'
    cXml +='<InscricaoMunicipal>' + u_ToXml(SM0->M0_INSCM) + '</InscricaoMunicipal>'
    cXml +=                 '<CodigoMunicipio>' + u_ToXml(SM0->M0_CODMUN) + '</CodigoMunicipio>'
    cXml +=             '</IdentificacaoNfse>' 
    cXml +=             '<CodigoCancelamento>1</CodigoCancelamento>'  /* Código de cancelamento com base na tabela de Erros e alertas. 1 – Erro na emissão, 2 – Serviço não prestado, 3 – Erro de assinatura, 4 – Duplicidade da nota, 5 – Erro de processamento */
    cXml +=         '</InfPedidoCancelamento>' 
    cXml +=     '</Pedido>' 
    cXml += '</ns1:CancelarNfseEnvio>' 
    cXml := EncodeUTF8(cXml)

return cXml

user function TiPlanNumNF(oXml)
local cNFSE := ""
	cNFSE := WSAdvValue( oXml, "_NS3_CONSULTARLOTERPSRESPOSTA:_NS3_COMPNFSE:_NS3_NFSE:_NS3_INFNFSE:_NS3_NUMERO:TEXT","string" )
return cNFSE

user function TiPlanProtocolo(oXml)
local cProt := ""
	cProt := WSAdvValue( oXml, "_NS3_ENVIARLOTERPSRESPOSTA:_NS3_PROTOCOLO:TEXT","string")
return cProt

user function TiPlanCVer(oXml)
local cCVer := ""
	cCVer := WSAdvValue( oXml, "_NS3_CONSULTARLOTERPSRESPOSTA:_NS3_COMPLNFSE:_NS3_NFSE:_NS3_INFNFSE:_NS3_CodigoVerificacao:TEXT","string")
return cCVer