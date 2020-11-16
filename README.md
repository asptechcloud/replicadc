# replicadc

Deploy a replica DC and connect to on-prem/other existing domain.


An existing VNet needs to be set-up with a S2S VPN or ExpressRoute with private peering - this must be completed before the template is deployed.

In order for the template to work, DNS servers in the Azure VNet need to point to on-premises domain controllers. When the servers come online, they will need to know how to resolve DNS in order to both join the domain and be promoted as a replica domain controller. This custom DNS server setting is configured within the virtual network (VNet).

Prior to running this template, ensure Active Directory Sites and Services is set up within the ADDS environment on-premises. 


[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fasptechcloud%2Freplicadc%2Fmain%2Fazuredeploy.json)
