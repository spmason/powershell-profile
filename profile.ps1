Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Run posh-git init script
pushd
cd posh-git
# Load posh-git module from current directory
Import-Module .\posh-git
Enable-GitColors
popd

# Run posh-svn init script
pushd
cd posh-svn
# Load posh-svn module from current directory
Import-Module .\posh-svn
popd

. .\configurePrompt.ps1

$clrDir = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
$clrDir = split-path $clrDir
$latestClrDir = ls $clrDir | ?{$_.PSIsContainer} | select -last 1
$clrDir = join-path $clrDir $latestClrDir

$env:path = "$($env:path);$clrDir"
$env:EDITOR = "notepad"

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
function elevate-process{
	$file, [string]$arguments = $args;
	$psi = new-object System.Diagnostics.ProcessStartInfo $file;
	$psi.Arguments = $arguments;
	$psi.Verb = "runas";
	$psi.WorkingDirectory = get-location;
	[System.Diagnostics.Process]::Start($psi) >> $null
}
set-alias sudo elevate-process

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

function Start-VisualStudio{
	param([string]$projFile = "")
	
	if($projFile -eq ""){
		ls *.sln | select -first 1 | %{
			$projFile = $_
		}
	}
	
	echo "Starting visual studio with $projFile"
	. $projFile
}
set-alias vs Start-VisualStudio

function Set-Hosts{
	sudo notepad "$($env:SystemRoot)\system32\drivers\etc\hosts"
}
set-alias hosts Set-Hosts

function Start-Mongo{
	push-location
	
	cd $dropbox\apps\mongo\bin
	start-process run_mongo.bat
	
	pop-location
}

function Kill-Mongo{
	killAll "mongod"
}

function Start-Cassini{
	param([string]$location)
	
	if([System.String]::IsNullOrEmpty($location)){
		$location = gl
	}
	
	if($location.StartsWith(".\")){
		$location = $location.TrimStart('.', '\', '/')
	}
	
	if([System.IO.Path]::IsPathRooted($location) -eq $false){
		$gl = gl
		$location = [System.IO.Path]::Combine($gl, $location)
	}
	
	push-location
	
	cd $dropbox\apps\CassiniDev
	.\CassiniDev4.exe /a:$location
	
	pop-location
}

function Kill-All{
	param([string]$name)
	get-process | ?{$_.ProcessName -eq $name -or $_.Id -eq $name} | %{kill $_.Id}
}

function Suspend-All{
	param([string]$name)
	pushd
	dropbox
	cd apps\utils
	get-process | ?{$_.ProcessName -eq $name -or $_.Id -eq $name} | %{.\pausep $_.Id >> $null}
	popd
}

function Resume-All{
	param([string]$name)
	pushd
	dropbox
	cd apps\utils
	get-process | ?{$_.ProcessName -eq $name -or $_.Id -eq $name} | %{.\pausep $_.Id /r >> $null}
	popd
}

Pop-Location