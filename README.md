# Azure API Management's Self-Hosted Gateway on Azure Container Apps
Playground to run Azure API Management's self-hosted gateway on Azure Container Apps.

## Scenario

![Scenario](./media/overview.png)

## Deployment

1. Deploy the Azure API Management with Bicep, for example:
```shell
az deployment group create --resource-group <rg-name> --template-file .\deploy\api-gateway.bicep --parameters resourceNamePrefix='apim-container-apps-sandbox'
```
2. Generate a gateway token in the "Deployment" blade of your self-hosted gateway
3. Deploy the application to Azure Container Apps with Bicep, for example:
```shell
az deployment group create --resource-group <rg-name> --template-file .\deploy\app.bicep --parameters resourceNamePrefix='apim-container-apps-sandbox' apiManagementName='<apim-name>' selfHostedGatewayToken='<token>'
```
