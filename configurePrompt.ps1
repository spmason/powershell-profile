$global:SvnPromptSettings.BeforeText = ' [svn: '
$global:GitPromptSettings.BeforeText = ' [git: '

# Set up a simple prompt, adding the git/svn prompt parts inside git/svn repos
function prompt {
	Write-Host($pwd) -nonewline
		
	# Git Prompt
	$Global:GitStatus = Get-GitStatus
	$Global:GitPromptSettings.IndexForegroundColor = [ConsoleColor]::Magenta
	Write-GitStatus $GitStatus
		
	# Svn Prompt
	$Global:SvnStatus = Get-SvnStatus
	Write-SvnStatus $SvnStatus
	  
	return '>
$ '
}

function DevTabExpansion($lastBlock){
	switch -regex ($lastBlock) {
		'dev (\S*)$' {
			ls $dev | ?{ $_.Name -match "^$($matches[1])" }
		}
	}
}

if(-not (Test-Path Function:\DefaultTabExpansion)) {
	Rename-Item Function:\TabExpansion DefaultTabExpansion
}

# Set up tab expansion and include git expansion
function TabExpansion($line, $lastWord) {
	$lastBlock = [regex]::Split($line, '[|;]')[-1]

	switch -regex ($lastBlock) {
		# Execute git tab completion for all git-related commands
		'git (.*)' { GitTabExpansion $lastBlock }
		# Execute git tab completion for all git-related commands
		'svn (.*)' { SvnTabExpansion $lastBlock }
		'dev (.*)' { DevTabExpansion $lastBlock }
		# Fall back on existing tab expansion
		default { DefaultTabExpansion $line $lastWord }
	}
}
