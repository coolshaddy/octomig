
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $user, $secureStringPwd

$Session1 = New-PSSession -ComputerName PSrelease01 -Credential $creds
Invoke-Command -ComputerName PSrelease01 -ScriptBlock {
. $args[11] import --instance $args[1] --directory $args[12] --password $args[13]
. $args[0] service --instance $args[1] --stop --start
} -Credential $creds -ArgumentList $Octopusexe, $instanceName, $NodeName, $weburl, $CommPort, $octopususer, $octopusemail, $octopuspass, $license, $ConfigName, $connectString, $OctopusPath, $exportDirectory, $exportPassword