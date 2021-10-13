Configuration SQLInstall
{

     param ($user)
     Install-Module -Name SqlServerDsc -Scope AllUsers -Force;
     Import-DscResource -ModuleName SqlServerDsc
     Import-DscResource -ModuleName PSDesiredStateConfiguration
     
     node localhost
     {
          WindowsFeature 'NetFramework45'
          {
               Name   = 'NET-Framework-45-Core'
               Ensure = 'Present'
          }

         
          SqlSetup 'InstallDefaultInstance'
          {

               InstanceName        = 'SQLEXPRESS'
               Action              = "Upgrade"
               Features            = 'SQLENGINE'
               SourcePath          = $sqlsourcepath
               SQLSysAdminAccounts = $user
               DependsOn           = '[WindowsFeature]NetFramework45'

          }
     }


}
$sqlsourcepath = 'C:\SQL2016\setup'
$user = whoami
mkdir -Path C:\SQL2016
cd C:\SQL2016
$sqlpath = "C:\SQL2016"
$url = "https://download.microsoft.com/download/4/1/A/41AD6EDE-9794-44E3-B3D5-A1AF62CD7A6F/sql16_sp2_dlc/en-us/SQLEXPRADV_x64_ENU.exe"
$outpath = "C:\SQL2016\setup.exe"
Invoke-WebRequest -Uri $url -OutFile $outpath
.$sqlpath\setup.exe /UIMODE=Normal /ACTION=INSTALL /Q /IACCEPTSQLSERVERLICENSETERMS=true
Install-Module -Name SqlServerDsc -Scope AllUsers -Force;
#mkdir -Path c:\dsc\SQLInstall;
SQLInstall -OutputPath C:\SQL2016 -user $user
Start-DscConfiguration -Path C:\SQL2016 -Wait -Force -Verbose 
cd C:\Windows\System32



