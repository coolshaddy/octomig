$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
$PSObject = Get-Content -Raw -Path $ScriptPath\conf.json | ConvertFrom-json
$user = $PSObject.Username
$pass = $PSObject.Password 
$url = $PSObject.Url
$apiKey = $PSObject.Api
$octopusDeployDatabaseName = $PSObject.database
$OctopusPath = $PSObject.OctopusPath
$Octopusexe = $PSObject.OctopusExe
$exportDirectory = $PSObject.ExportDirectory
$exportoldDirectory = $PSObject.ExportOldDirectory
$exportPassword = $PSObject.ExportPassword
$instanceName = $PSObject.InstanceName
#$servername = "10.128.0.8\SQLEXPRESS,1434"
#$dbname = "poctopus_db"
#$dbuser = "sa"
#$dbpass = "Admin12345"
$octopususer = $PSObject.OctopusUser
$octopuspass = $PSObject.OctopusPassword
$octopusemail = $PSObject.OctopusMail
$license = $PSObject.license
$weburl = $PSObject.weburl
$ConfigName = $PSObject.ConfigName
$connectString = $PSObject.ConnectString
$NodeName = $PSObject.NodeName
$CommPort = $PSObject.CommPort

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
. "$ScriptPath1\sqlupgrade.ps1"

. "$ScriptPath1\update.ps1"

. "$ScriptPath1\wrapper2.ps1"