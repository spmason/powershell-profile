Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

function Test-InPath($fileName){
	$found = $false
	Find-InPath $fileName | %{$found = $true}
	
	return $found
}

function Find-InPath($fileName){
	$env:PATH.Split(';') | %{
		if(Test-Path $_){
			ls $_ | ?{ $_.Name -like $fileName }
		}
	}
}

# Run posh-git init script
pushd
cd posh-git
# Load posh-git module from current directory
Import-Module .\posh-git
Enable-GitColors
popd
if(Test-InPath ssh-agent.*){
	. .\ssh-agent-utils.ps1
}else{
	Write-Error "ssh-agent cannot be found in your PATH, please add it"
}

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
	Write-Error "Environment configfile cannot be found - please edit & continue"
	copy environment.example.ps1 environment.ps1
	notepad .\environment.ps1
}

. .\environment.ps1

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

function Set-Location-Dev($folder){
	Push-Location
	
	if($folder -ne ""){
		cd "$dev\$folder"
		return
	}
	
	cd $dev
}
set-alias dev Set-Location-Dev

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
	
	if(($projFile -eq "") -and (Test-Path src)){
		ls src\*.sln | select -first 1 | %{
			$projFile = $_
		}
	}
	
	if($projFile -eq ""){
		echo "No project file found"
		return
	}
	
	echo "Starting visual studio with $projFile"
	. $projFile
}
set-alias vs Start-VisualStudio

function Set-Hosts{
	sudo notepad "$($env:SystemRoot)\system32\drivers\etc\hosts"
}
set-alias hosts Set-Hosts

function Kill-All{
	param([string]$name)
	get-process | ?{$_.ProcessName -eq $name -or $_.Id -eq $name} | %{kill $_.Id}
}

Pop-Location