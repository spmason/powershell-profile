Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Run posh-git init script
. .\profile.example.ps1

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
function gitStatus{
	git status
}
set-alias gs gitStatus

function cdDev{
	cd $dev
}
set-alias dev cdDev

function cdDropbox{
	cd $dropbox
}
set-alias dropbox cdDropbox

function openNotepad{
	notepad $args
}
set-alias n openNotepad

function runMongo{
	push-location
	
	cd $dropbox\apps\mongo\bin
	start-process run_mongo.bat
	
	pop-location
}

function killMongo{
	killAll "mongod"
}

function killAll{
	param([string]$name)
	get-process | ?{$_.ProcessName -eq $name} | %{kill $_.Id}
}

Pop-Location