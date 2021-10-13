$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $user, $secureStringPwd

Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
$Session = New-PSSession -ComputerName PSrelease01 -Credential $cred
Invoke-Command -ComputerName PSrelease01 -ScriptBlock { mkdir c:\export } -Credential $cred
Copy-Item -Path $exportoldDirectory\* -Destination $exportDirectory -Recurse -ToSession $Session
Invoke-Command -ComputerName PSrelease01 -ScriptBlock {

. $args[0] create-instance --instance $args[1] --config $args[9] --serverNodeName $args[2]
. $args[0] database --instance $args[1] --connectionString $args[10] --create
. $args[0] configure --instance $args[1] --webForceSSL "False" --webListenPrefixes $args[3] --commsListenPort $args[4] --usernamePasswordIsEnabled "True" --activeDirectoryIsEnabled "False"
. $args[0] service --instance $args[1] --stop
. $args[0] admin --instance $args[1] --username $args[5] --email $args[6] --password $args[7]
. $args[0] license --instance $args[1] --licenseBase64 $args[8]
. $args[0] service --instance $args[1] --install --reconfigure --start
 } -Credential $cred -ArgumentList $Octopusexe, $instanceName, $NodeName, $weburl, $CommPort, $octopususer, $octopusemail, $octopuspass, $license, $ConfigName, $connectString, $OctopusPath, $exportDirectory, $exportPassword

 