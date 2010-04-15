Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Run posh-git init script
pushd
cd posh-git
. .\profile.example.ps1
popd

# Define variables
if(!(Test-Path .\environment.ps1)){
	Write-Error "Environment configfile cannot be found"
	copy environment.example.ps1 environment.ps1
	notepad .\environment.ps1
}

. .\environment.ps1

if($dropbox -eq $null -or !(Test-Path $dropbox)){
	Write-Error "Dropbox directory cannot be found or is not defined: $dropbox"
}

if($dev -eq $null -or !(Test-Path $dev)){
	Write-Error "Dev directory cannot be found or is not defined: $dev"
}

# Define aliases
function Get-Git-Status{
	git status
}
set-alias gs Get-Git-Status

function Set-Location-Dev{
	Push-Location
	cd $dev
}
set-alias dev Set-Location-Dev

function Set-Location-Dropbox{
	Push-Location
	cd $dropbox
}
set-alias dropbox Set-Location-Dropbox

function Set-Location-Profile{
	Push-Location
	cd ~\Documents\WindowsPowerShell
}
set-alias profile Set-Location-Profile

function Start-Notepad{
	notepad $args
}
set-alias n Start-Notepad

function Start-Mongo{
	push-location
	
	cd $dropbox\apps\mongo\bin
	start-process run_mongo.bat
	
	pop-location
}

function Kill-Mongo{
	killAll "mongod"
}

function Kill-All{
	param([string]$name)
	get-process | ?{$_.ProcessName -eq $name} | %{kill $_.Id}
}

Pop-Location