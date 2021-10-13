$sqlbackupFolderLocation = "C:\backup\DatabaseBackup"
$fileBackupLocation = "C:\backup\FileBackup"
$downloadDirectory = "${env:Temp}"

# This is the default install location, but yours could be different
$installPath = "${env:ProgramFiles}\Octopus Deploy\Octopus"
$serverExe = "$installPath\Octopus.Server.Exe"

# Get the latest minor/patch version
$currentVersion = (Invoke-RestMethod "$Url/api").Version
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$versions = Invoke-RestMethod "https://octopus.com/download/upgrade/v3"
$upgradeVersion = $versions[-1].Version

if ($upgradeVersion -eq $currentVersion) {
    Write-Host "No new versions found. Quitting..."
    exit
}

# Download the installer
$msiFilename = "Octopus.$upgradeVersion-x64.msi"
Write-Host "Downloading $msiFilename"
Start-Bitstransfer -source "https://download.octopusdeploy.com/octopus/$msiFilename" -Destination "$downloadDirectory\$msiFilename"

# Place Octopus into maintenance mode
if (-not (Invoke-RestMethod -Uri "$url/api/maintenanceconfiguration" -Headers @{'X-Octopus-ApiKey' = $apiKey}).IsInMaintenanceMode) {
    Invoke-RestMethod `
        -Method Put `
        -Uri "$url/api/maintenanceconfiguration" `
        -Headers @{'X-Octopus-ApiKey' = $apiKey} `
        -Body (@{ Id = "maintenance"; IsInMaintenanceMode = $true } | ConvertTo-Json)
}

$versionSplit = $currentVersion -Split "\."
$upgradeSplit = $upgradeVersion -Split "\."

if ($versionSplit[0] -ne $upgradeSplit[0])
{
    Write-Host "Major version upgrade has been detected, backing up all the folders"

    $serverFolders = Invoke-RestMethod -Uri "$url/api/configuration/server-folders/values" -Headers @{'X-Octopus-ApiKey' = $apiKey}

    $msiExitCode = (Start-Process -FilePath "robocopy" -ArgumentList "$($serverFolders.LogsDirectory) $filebackUpFolder\TaskLogs /mir" -Wait -Passthru).ExitCode
    if ($msiExitCode -ge 8) 
    {
        Throw "Unable to copy files to $filebackUpFolder\TaskLogs"
    }

    $msiExitCode = (Start-Process -FilePath "robocopy" -ArgumentList "$($serverFolders.ArtifactsDirectory) $filebackUpFolder\Artifacts /mir" -Wait -Passthru).ExitCode
    if ($msiExitCode -ge 8) 
    {
        Throw "Unable to copy files to $filebackUpFolder\Artifacts"
    }

    $msiExitCode = (Start-Process -FilePath "robocopy" -ArgumentList "$($serverFolders.PackagesDirectory) $filebackUpFolder\Packages /mir" -Wait -Passthru).ExitCode
    if ($msiExitCode -ge 8) 
    {
        Throw "Unable to copy files to $filebackUpFolder\Packages"
    }
}

# Finish any remaining tasks and stop the service
& $serverExe node --instance="OctopusServer" --drain=true --wait=0
& $serverExe service --instance="OctopusServer" --stop

# Backup database
$backupFileName = "$octopusDeployDatabaseName" + (Get-Date -Format FileDateTime) + '.bak'
$backupFileFullPath = "$sqlbackupFolderLocation\$backupFileName"

$instanceConfig = (& $serverExe show-configuration --instance="OctopusServer" --format="JSON") | Out-String | ConvertFrom-Json
   
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString = $instanceConfig.'Octopus.Storage.ExternalDatabaseConnectionString'

$command = $sqlConnection.CreateCommand()
$command.CommandType = [System.Data.CommandType]'Text'
$command.CommandTimeout = 0

Write-Host "Opening the connection"
$sqlConnection.Open()

$command.CommandText = "BACKUP DATABASE [$octopusDeployDatabaseName]
  TO DISK = '$backupFileFullPath'
      WITH FORMAT"
$command.ExecuteNonQuery()

Write-Host "Successfully backed up the database $octopusDeployDatabaseName"
Write-Host "Closing the connection"
$sqlConnection.Close()

# Running the installer
$msiToInstall = "$downloadDirectory\$msiFilename"
Write-Host "Installing $msiToInstall"
$msiExitCode = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $msiToInstall /quiet" -Wait -Passthru).ExitCode 
Write-Output "Server MSI installer returned exit code $msiExitCode" 

# Upgrade database and restart service
& $serverExe database --instance="OctopusServer" --upgrade
& $serverExe service --instance="OctopusServer" --start
. $OctopusPath export --instance $instanceName --directory $exportoldDirectory --password $exportPassword --include-tasklogs
& $serverExe node --instance="OctopusServer" --drain=false


Remove-Item "$downloadDirectory\$msiFilename"
