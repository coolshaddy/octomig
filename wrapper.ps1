$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
$PSObject = Get-Content -Raw -Path $ScriptPath\conf.json | ConvertFrom-json
$user = $PSObject.Username
$pass = $PSObject.Password 
$url = $PSObject.Url
$apiKey = $PSObject.Api
$octopusDeployDatabaseName = $PSObject.database
$OctopusPath = "C:\Program Files\Octopus Deploy\Octopus\Octopus.Migrator.exe"
$Octopusexe = "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe"
$exportDirectory = "C:\export"
$exportoldDirectory = "c:\backup\export"
$exportPassword = "%D0H\\vW'RUc?buZ5"
$instanceName = "OctopusServer"
$servername = "10.128.0.8\SQLEXPRESS,1434"
$dbname = "poctopus_db"
$dbuser = "sa"
$dbpass = "Admin12345"
$octopususer = "admin"
$octopuspass = "%D0H\\vW'RUc?buZ5"
$octopusemail = "admin@bcidaho.com"
$license = "PExpY2Vuc2UgU2lnbmF0dXJlPSJMTm1qV2pRQ0NzVnVvRmlPNmd6T3dXbjFlYWhYSSs1ZWhHR0E1SG5uYkNFdFdYbTAxdHV1WDlrcE9HVm1oRk1UaGZaWVkrdzVqZDRXSzQ0ZnBaTHp1Zz09Ij4NCiAgPExpY2Vuc2VkVG8+aW50aW1ldGVjPC9MaWNlbnNlZFRvPg0KICA8TGljZW5zZUtleT4yNDMyOS0xMDQ2MS00NjQyMS01MjEyNDwvTGljZW5zZUtleT4NCiAgPFZlcnNpb24+Mi4wPCEtLSBMaWNlbnNlIFNjaGVtYSBWZXJzaW9uIC0tPjwvVmVyc2lvbj4NCiAgPFZhbGlkRnJvbT4yMDIxLTA4LTAyPC9WYWxpZEZyb20+DQogIDxLaW5kPlN1YnNjcmlwdGlvbjwvS2luZD4NCiAgPFZhbGlkVG8+MjAyMi0wOC0wMjwvVmFsaWRUbz4NCiAgPFByb2plY3RMaW1pdD5VbmxpbWl0ZWQ8L1Byb2plY3RMaW1pdD4NCiAgPE1hY2hpbmVMaW1pdD4xMDwvTWFjaGluZUxpbWl0Pg0KICA8VXNlckxpbWl0PlVubGltaXRlZDwvVXNlckxpbWl0Pg0KICA8Tm9kZUxpbWl0PlVubGltaXRlZDwvTm9kZUxpbWl0Pg0KICA8U3BhY2VMaW1pdD5VbmxpbWl0ZWQ8L1NwYWNlTGltaXQ+DQogIDxUYXNrQ2FwPjU8L1Rhc2tDYXA+DQo8L0xpY2Vuc2U+"
$weburl = "http://localhost:80/"
$ConfigName = "C:\Octopus\OctopusServer.config"
$connectString = "Data Source=10.128.0.8\SQLEXPRESS,1434;Initial Catalog=poctopus_db;Integrated Security=False;User ID=sa;Password=Admin12345"
$NodeName = "OCTOPUS"
$CommPort = "10943"

mkdir c:\backup\export

$secureStringPwd = $pass | ConvertTo-SecureString -AsPlainText -Force 

$ScriptPath1 = Split-Path $MyInvocation.MyCommand.Path
mkdir C:\backup\DatabaseBackup
mkdir C:\backup\FileBackup
Invoke-Command -ScriptBlock {
      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

      if((Get-PackageProvider | Where-Object {$_.Name -eq "NuGet"}) -eq $null)
    {
               Install-PackageProvider -Name NuGet -Force
    }
}



Invoke-Command -ScriptBlock{
    if ($null -eq (Get-Package | Where-Object {$_.Name -eq "SqlServerDsc"}))
    {
        # download specified module
        Install-Module -Name "SqlServerDsc" -Force
    }
}

Install-Module -Name SqlServerDsc -Scope AllUsers -Force;
#. "$ScriptPath1\sqlupgrade.ps1"

#. "$ScriptPath1\update.ps1"

. "$ScriptPath1\wrapper2.ps1"