$global:SvnPromptSettings.BeforeText = ' [svn: '
$global:GitPromptSettings.BeforeText = ' [git: '
$global:HgPromptSettings.BeforeText = ' [hg: '

# Set up a simple prompt, adding the git/hg/svn prompt parts inside git/hg/svn repos
function prompt {
	Write-Host($pwd) -nonewline
		
	# Git Prompt
	$Global:GitStatus = Get-GitStatus
	$Global:GitPromptSettings.IndexForegroundColor = [ConsoleColor]::Magenta
	Write-GitStatus $GitStatus
		
	# Mercurial Prompt
	$Global:HgStatus = Get-HgStatus
	Write-HgStatus $HgStatus
		
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
		# mercurial and tortoisehg tab expansion
		'(hg|hgtk) (.*)' { HgTabExpansion($lastBlock) }
		# Development folder tab expansion
		'dev (.*)' { DevTabExpansion $lastBlock }
		# Fall back on existing tab expansion
		default { DefaultTabExpansion $line $lastWord }
	}
}
