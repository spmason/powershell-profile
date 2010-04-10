# Inspired by Mark Embling
# http://www.markembling.info/view/my-ideal-powershell-prompt-with-git-integration

. .\Utils.ps1

function Get-GitDirectory {
    Coalesce-Args `
        (Get-Item '.\.git' -Force 2>$null).FullName `
        { git rev-parse --git-dir 2>$null }
}

function Get-GitBranch($gitDir = $(Get-GitDirectory)) {
    if ($gitDir) {
        if (Test-Path $gitDir\rebase-merge\interactive) {
            $r = '|REBASE-i'
            $b = "$(Get-Content $gitDir\rebase-merge\head-name)"
        } elseif (Test-Path $gitDir\rebase-merge) {
            $r = '|REBASE-m'
            $b = "$(Get-Content $gitDir\rebase-merge\head-name)"
        } else {
            if (Test-Path $gitDir\rebase-apply) {
                if (Test-Path $gitDir\rebase-apply\rebasing) {
                    $r = '|REBASE'
                } elseif (Test-Path $gitDir\rebase-apply\applying) {
                    $r = '|AM'
                } else {
                    $r = '|AM/REBASE'
                }
            } elseif (Test-Path $gitDir\MERGE_HEAD) {
                $r = '|MERGING'
            } elseif (Test-Path $gitDir\BISECT_LOG) {
                $r = '|BISECTING'
            }

            $b = ?? { git symbolic-ref HEAD 2>$null } `
                    { "($(
                        Coalesce-Args `
                            { git describe --exact-match HEAD 2>$null } `
                            {
                                $ref = Get-Content $gitDir\HEAD 2>$null
                                if ($ref -and $ref.Length -ge 7) {
                                    return $ref.Substring(0,7)+'...'
                                } else {
                                    return $null
                                }
                            } `
                            'unknown'
                    ))" }
        }

        if ('true' -eq $(git rev-parse --is-inside-git-dir 2>$null)) {
            if ('true' -eq $(git rev-parse --is-bare-repository 2>$null)) {
                $c = 'BARE:'
            } else {
                $b = 'GIT_DIR!'
            }
        }

        "$c$($b -replace 'refs/heads/','')$r"
    }
}

function Get-GitStatus {
    if($gitDir = Get-GitDirectory)
    {
        $indexAdded = @()
        $indexModified = @()
        $indexDeleted = @()
        $indexUnmerged = @()
        $filesAdded = @()
        $filesModified = @()
        $filesDeleted = @()
        $filesUnmerged = @()
        $aheadCount = (git cherry 2>$null | where { $_ -like '+*' } | Measure-Object).Count
        
        $diffIndex = git diff-index -M --name-status --cached HEAD |
                     ConvertFrom-CSV -Delim "`t" -Header 'Status','Path'
        $diffFiles = git diff-files -M --name-status |
                     ConvertFrom-CSV -Delim "`t" -Header 'Status','Path'

        $grpIndex = $diffIndex | Group-Object Status -AsHashTable
        $grpFiles = $diffFiles | Group-Object Status -AsHashTable

        if($grpIndex.A) { $indexAdded += $grpIndex.A | %{ $_.Path } }
        if($grpIndex.M) { $indexModified += $grpIndex.M | %{ $_.Path } }
        if($grpIndex.R) { $indexModified += $grpIndex.R | %{ $_.Path } }
        if($grpIndex.D) { $indexDeleted += $grpIndex.D | %{ $_.Path } }
        if($grpIndex.U) { $indexUnmerged += $grpIndex.U | %{ $_.Path } }
        if($grpFiles.M) { $filesModified += $grpFiles.M | %{ $_.Path } }
        if($grpFiles.R) { $filesModified += $grpFiles.R | %{ $_.Path } }
        if($grpFiles.D) { $filesDeleted += $grpFiles.D | %{ $_.Path } }
        if($grpIndex.U) { $filesUnmerged += $grpIndex.U | %{ $_.Path } }
        
        $untracked = git ls-files -o --exclude-standard
        if($untracked) { $filesAdded += $untracked }

        $index = New-Object PSObject @(,@($diffIndex | %{ $_.Path } | ?{ $_ })) |
            Add-Member -PassThru NoteProperty Added    $indexAdded |
            Add-Member -PassThru NoteProperty Modified $indexModified |
            Add-Member -PassThru NoteProperty Deleted  $indexDeleted |
            Add-Member -PassThru NoteProperty Unmerged $indexUnmerged
        $working = New-Object PSObject @(,@(@($diffFiles | %{ $_.Path }) + @($filesAdded) | ?{ $_ })) |
            Add-Member -PassThru NoteProperty Added    $filesAdded |
            Add-Member -PassThru NoteProperty Modified $filesModified |
            Add-Member -PassThru NoteProperty Deleted  $filesDeleted |
            Add-Member -PassThru NoteProperty Unmerged $filesUnmerged
        
        $status = New-Object PSObject -Property @{
            GitDir          = $gitDir
            Branch          = Get-GitBranch $gitDir
            AheadBy         = $aheadCount
            HasIndex        = [bool]$index
            Index           = $index
            HasWorking      = [bool]$working
            Working         = $working
            HasUntracked    = [bool]$untracked
        }
        
        return $status
    }
}

function Enable-GitColors {
    $env:TERM = 'cygwin'
    $env:LESS = 'FRSX'
}
