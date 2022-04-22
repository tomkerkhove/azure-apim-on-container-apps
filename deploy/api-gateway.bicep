param location string = resourceGroup().location
param resourceNamePrefix string = 'apim-container-apps'
param selfHostedGatewayName string = 'api-gateway-on-container-apps'

module infrastructure 'modules/api-management.bicep' = {
  name: 'api-management'
  params: {
    location: location
    apiManagementName: '${resourceNamePrefix}-api-management'
    selfHostedGatewayName: selfHostedGatewayName
  }
}
