Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Run posh-git init script
. .\profile.example.ps1

# Define variables
. .\environment.ps1

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

Pop-Location