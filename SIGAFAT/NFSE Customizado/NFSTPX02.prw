#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} NFSTPX002
//TODO Descrição auto-gerada.
@author lucas.borges
@since 25/01/2019
@version 1.0
@description Dummy Function
@type function
/*/
User Function NFSTPX02()
Return

/*/{Protheus.doc} NFSTLIB1
//TODO Descrição auto-gerada.
@author lucas.borges
@since 25/01/2019
@version 1.0
@return array, Array contendo os dados da consulta
@param cMunicipio, characters, Codigo do municipio
@type function
/*/
User Function NFSTLIB1(cMunicipio)

	Local	aDados := {}
	Local cQry   := "SELECT * FROM  "+RetSqlName("ZZ0")+" WHERE ZZ0_CODMUN='"+cMunicipio+"' AND ZZ0_FILIAL="+xFilial("ZZ0")

	Default cMunicipio := ""

	dbUsearea(.T.,"TOPCONN",TCGenQry(,,cQry), "TMPQRY")
	TMPQRY->(DBGotop())
	Do While TMPQRY->(!EOF())
		aAdd(aDados, {TMPQRY->ZZ0_CNAE, TMPQRY->ZZ0_NUMTRI,  TMPQRY->ZZ0_CODMUN, TMPQRY->ZZ0_CTRMUN})
		TMPQRY->(DBSkip())
	EndDo

	TMPQRY->(DBCloseArea())
Return aDados

User Function NFSDESC ()
	
	Local cError   := ""
	Local cWarning := ""
	Local oXml := NIL
	Local aDados := {}

	private aDadosNota := u_nfseXMLEnv("1", SF2->F2_EMISSAO, SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_CLIENTE, SF2->F2_LOJA, "")
	if(Len(aDadosNota) > 0)
		oXml := XmlParser( aDadosNota[1], "_", @cError, @cWarning )
		If (oXml == NIL )
			MsgStop("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
			Return
		Endif
		AAdd( aDados, oXml:_rps:_servicos:_servico:_discr:Text)
		AAdd( aDados, oXml:_rps:_servicos:_servico:_aliquota:Text)
		AAdd( aDados, oXml:_rps:_servicos:_servico:_quant:Text)
		AAdd( aDados, oXml:_rps:_servicos:_servico:_valunit:Text)
		AAdd( aDados, oXml:_rps:_servicos:_servico:_valtotal:Text)
		AAdd( aDados, oXml:_rps:_servicos:_servico:_basecalc:Text)
		AAdd( aDados, oXml:_rps:_servicos:_servico:_issretido:Text)
		AAdd( aDados, oXml:_rps:_servicos:_servico:_valdedu:Text)
		AAdd( aDados, oXml:_rps:_servicos:_servico:_valredu:Text)
		AAdd( aDados, oXml:_rps:_servicos:_servico:_valiss:Text)
		AAdd( aDados, oXml:_rps:_servicos:_servico:_valliq:Text)
		AAdd( aDados, oXml:_rps:_servicos:_servico:_unidmed:Text)
		AAdd( aDados, oXml:_rps:_prestacao:_codmunibge:Text)	
	EndIf

Return oXml

