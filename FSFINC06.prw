#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch' 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FSFINC06
Visualiza a tela de log de alterações na liberação de crédito
                 
@author 	Fernando Ferreira
@since 	01/03/2013
@version	P11
@obs 
         
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 

/*/ 
//------------------------------------------------------------------- 
User Function FSFINC06()

Local 	cAlias  	:= "P08"
Local 	cTitle  	:= "Log de alterações - Rotina de Liberação de crédito"
Local 	oBrowser	:= FWMBrowse():New()

Private aRotina		:= MenuDef()

oBrowser:SetAlias(cAlias)
oBrowser:SetDescription(cTitle)

// Ativação da Classe 
oBrowser:Activate()       

Return Nil

//------------------------------------------------------------------- 
/*/{Protheus.doc} MenuDef 
Define as operações a serem realizadas no processo.
                 
@author 	Fernando Ferreira
@since 	30/07/2012
@version	P11
@return	aRotina Array com as rotinas disponiveis.
@obs 
Projeto: FS006618 - Informações complementares do DANFE
         
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 

/*/ 
//------------------------------------------------------------------- 
Static Function MenuDef()
Local aRotina	:= {}		

ADD OPTION aRotina Title "Visualizar" Action "VIEWDEF.FSFINC06" OPERATION 2 ACCESS 0 
	
Return aRotina

//------------------------------------------------------------------- 
/*/{Protheus.doc} ModelDef 
Função Utilizada para manipulação do Model do processo.
                 
@author 	Fernando Ferreira
@since 	30/07/2012
@version	P11
@obs 
         
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 

/*/ 
//------------------------------------------------------------------- 
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados 
Local	oStruP08		:= FWFormStruct(1, "P08")
Local	oModel		:= MPFormModel():New("MP08",,)


//	cOwner: Objeto Pai
// Adiciona ao modelo um componente de formulário 
oModel:AddFields("P08MASTER", /*cOwner*/, oStruP08)

oModel:SetPrimaryKey( { "P08_FILIAL", "P08_SEQ", "P08_USUARI", "P08_CLIENT", "P08_LOJA" } )

// Adiciona a descrição do Modelo de Dados 
oModel:SetDescription("Log de Alterações no crédito de clientes")

// Adiciona a descrição do Componente do Modelo de Dados 
oModel:GetModel("P08MASTER"):SetDescription("Log de Alterações")  
 	
Return oModel

//------------------------------------------------------------------- 
/*/{Protheus.doc} ViewDef 
[Descrição da Função]
                 
@author 	Fernando Ferreira
@since 	31/01/2012
@version	P11
@obs 
         
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 

/*/ 
//------------------------------------------------------------------- 
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado 
Local	oModel := FWLoadModel( "FSFINC06" )

// Cria a estrutura a ser usada na View 
Local oStruP08 := FWFormStruct( 2, "P08" ) 

// Interface de visualização construída 
Local	 oView	:= Nil

// Cria o objeto de View 
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado na View 
oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo formulário  
// (antiga Enchoice) 
oView:AddField("VIEW_P08", oStruP08, "P08MASTER")

// Criar um "box" horizontal para receber algum elemento da view 
oView:CreateHorizontalBox("TELA", 100)

oView:EnableTitleView("VIEW_P08")

// Relaciona o identificador (ID) da View com o "box" para exibição 
oView:SetOwnerView("VIEW_P08", "TELA")
		
// Retorna o objeto de View criado		
Return oView
                            

