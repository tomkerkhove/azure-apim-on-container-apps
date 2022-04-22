param location string
param containerEnvironmentName string
param apiGatewayContainerAppName string
param baconApiContainerAppName string
param logAnalyticsWorkspaceId string
param apiManagementName string

@secure()
param selfHostedGatewayToken string

// Container App Landscape
resource environment 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
  name: containerEnvironmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(logAnalyticsWorkspaceId, '2020-03-01-preview').customerId
        sharedKey: listKeys(logAnalyticsWorkspaceId, '2020-03-01-preview').primarySharedKey
      }
    }
  }
}

var gatewayTokenSecretName = 'gateway-token'
resource apiGatewayContainerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: apiGatewayContainerAppName
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8081
      }
      dapr: {
        enabled: false
      }
      secrets: [
        {
          name: gatewayTokenSecretName
          value: selfHostedGatewayToken
        }
      ]
    }
    template: {
      containers: [
        {
          image: 'mcr.microsoft.com/azure-api-management/gateway:2.0.2'
          name: 'apim-gateway'
          resources: {
            cpu: '0.5'
            memory: '1.0Gi'
          }
          env: [
            { 
              name: 'config.service.endpoint'
              value: '${apiManagementName}.configuration.azure-api.net'
            }
            { 
              name: 'config.service.auth'
              secretRef: gatewayTokenSecretName
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 5
        rules:[
          {
            name: 'http'
            http:{
              metadata:{
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
    }
  }
}

resource baconApiContainerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: baconApiContainerAppName
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      ingress: {
        external: false
        targetPort: 443
      }
      dapr: {
        enabled: false
      }
      secrets: []
    }
    template: {
      containers: [
        {
          image: 'ghcr.io/tomkerkhove/bacon-api:latest'
          name: 'bacon-api'
          resources: {
            cpu: '0.5'
            memory: '1.0Gi'
          }
          env: []
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
        rules:[]
      }
    }
  }
}

output baconApiUrl string = baconApiContainerApp.properties.configuration.ingress.fqdn
