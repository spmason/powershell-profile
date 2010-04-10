Push-Location $psScriptRoot
. ./Utils.ps1
. ./GitUtils.ps1
. ./GitPrompt.ps1
. ./GitTabExpansion.ps1
Pop-Location

Export-ModuleMember -Function @(
        'Write-GitStatus', 
        'Get-GitStatus', 
        'Enable-GitColors', 
        'Get-GitDirectory',
        'GitTabExpansion')
