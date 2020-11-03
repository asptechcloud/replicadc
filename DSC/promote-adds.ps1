Configuration CreateADReplicaDC 
{ 
   param 
    ( 
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Parameter(Mandatory)][System.Management.Automation.PSCredential]$safemodeAdminCreds,

        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
    
        )

    Import-DscResource -ModuleName xActiveDirectory, xPendingReboot, xStorage, PSDesiredStateConfiguration, xDSCDomainJoin
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential]$SafeCreds = New-Object System.Management.Automation.PSCredential ($safemodeAdminCreds.UserName, $safemodeAdminCreds.Password)

    Node localhost
    {
       LocalConfigurationManager            
       {            
          ActionAfterReboot = 'ContinueConfiguration'            
          ConfigurationMode = 'ApplyOnly'            
          RebootNodeIfNeeded = $true            
       }

       WindowsFeature RSAT 
       {
          Ensure = "Present"
          Name = "RSAT"
       }

        xWaitforDisk Disk2
        {
            DiskId = 2
            RetryIntervalSec =$RetryIntervalSec
            RetryCount = $RetryCount
        }

        xDisk ADDataDisk {
            DiskId = 2
            DriveLetter = "F"
            DependsOn = "[xWaitForDisk]Disk2"
        }

        xDSCDomainjoin JoinDomain
        {
            Domain = $DomainName
            Credential = $DomainCreds
            DependsOn = "[xDisk]ADDataDisk"
		}
       WindowsFeature ADDSInstall 
       { 
          Ensure = "Present" 
          Name = "AD-Domain-Services"
          DependsOn = "[xDSCDomainJoin]JoinDomain"
       }

       xWaitForADDomain DscForestWait 
       { 
          DomainName = $DomainName 
          DomainUserCredential= $DomainCreds
          RetryCount = $RetryCount
          RetryIntervalSec = $RetryIntervalSec
          DependsOn = "[WindowsFeature]ADDSInstall"
      }

      xADDomainController ReplicaDC 
      { 
         DomainName = $DomainName 
         DomainAdministratorCredential = $DomainCreds
         SafemodeAdministratorPassword = $SafeCreds
         DatabasePath = "F:\NTDS\Database"
         LogPath = "F:\NTDS\Logs"
         SysvolPath = "F:\SYSVOL"
         DependsOn = "[xWaitForADDomain]DscForestWait"
      }

      xPendingReboot Reboot1
      { 
         Name = "RebootServer"
         DependsOn = "[xADDomainController]ReplicaDC"
      }
   }
}