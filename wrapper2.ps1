$ScriptPath1 = Split-Path $MyInvocation.MyCommand.Path

. "$ScriptPath1\instancesetup.ps1"
. "$ScriptPath1\dataimp.ps1" 
