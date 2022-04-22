param apiManagementName string
param selfHostedGatewayName string
param baconApiUrl string

// API & Operations
var baconApiName = 'bacon-api'
resource baconApi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: '${apiManagementName}/${baconApiName}'
  properties: {
    path: '/bacon'
    apiType: 'http'
    displayName: 'Bacon API'
    subscriptionRequired: true
    subscriptionKeyParameterNames: {
      header: 'X-API-Key'
      query: 'apiKey'
    }
    protocols: [
      'http'
      'https'
    ]
  }
}
resource getBaconOperation 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  name: 'get'
  parent: baconApi
  properties: {
    displayName: 'Get Bacon'
    method: 'GET'
    urlTemplate: '/api/v1/bacon'
    description: 'Get various flavors of bacon'    
  }
}

// Backend and policy integration
var backendId = 'bacon-api-in-azure-container-apps'
resource baconApiBackend 'Microsoft.ApiManagement/service/backends@2021-08-01' = {
  name: '${apiManagementName}/${backendId}'
  properties: {
    title: 'Bacon API on Azure Container Apps'
    description: 'A running version of the Bacon API on Azure Container Apps which is only exposed inside the Container App Environment'
    protocol: 'http'
    url: 'http://${baconApiUrl}'
  }
}

resource baconApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {
  name: 'policy'
  parent: baconApi
  properties: {
    value: '<policies><inbound><base /><choose><when condition="@(context.Deployment.GatewayId.Equals("${selfHostedGatewayName}"))"><set-backend-service backend-id="${backendId}" /></when><otherwise><!-- Use default host --></otherwise></choose></inbound><backend><base /></backend><outbound><base /></outbound><on-error><base /></on-error></policies>'
    format: 'rawxml'
  }
}

// Gateway integration
resource exposeApiOnGateway 'Microsoft.ApiManagement/service/gateways/apis@2021-08-01' = {
  name: '${apiManagementName}/${selfHostedGatewayName}/${baconApiName}'
  properties: {}
  dependsOn: [
    baconApi
  ]
}

