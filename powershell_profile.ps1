
#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
(& "C:\Users\sbran\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | Invoke-Expression
#endregion

# Git autocomplete
Import-Module Posh-Git

Set-Alias -Name k -Value kubectl
Set-Alias -Name g -Value git
Set-Alias -Name d -Value docker


function Get-GitBranch {
    try {
        $branch = $(git branch | Select-String -Pattern "\*" -Raw).split()[1]
    }
    catch {
        $branch = ""
    }
    return $branch
}

function Get-IsDirty {
    return $(git status -s)
}

function Get-OriginDiff {
    param (
        [string]$branch
    )

    $output = @()

    try {
        $behind = git rev-list --count $branch..origin/$branch
        if (-not $?) {
            throw
        }
        $ahead = git rev-list --count origin/$branch..$branch

        if (($behind -ne "0") -or ($ahead -ne "0")) {
            $origin_diff = "(+${ahead}/-${behind}) "
            $diff_color = "darkyellow"
        }
        else {
            $origin_diff = "(up-to-date) "
            $diff_color = "cyan"
        }
    }
    catch {
        $origin_diff = "(untracked) "
        $diff_color = "red"
    } 
    $output += $diff_color
    $output += $origin_diff

    return , $output

}
function Get-LocationPrefix {
    $prefix = $(Get-Location) -replace $($home -replace '\\', '\\'), '~'
    return $prefix
}

function Prompt {
    # Previous command return code
    Write-Host -nonewline "`nReturn code: "
    Write-Host -foreground (($LASTEXITCODE % 128 -eq 0) ? "green" : "red") $LASTEXITCODE
    Write-Host "".PadRight($Host.UI.RawUI.WindowSize.Width, "-")

    # Python env (conda)
    Write-Host -nonewline -foreground white $Env:CONDA_PROMPT_MODIFIER.PadRight(10, ' ')

    # Git status
    $branch = Get-GitBranch
    if ($branch) {
        $OriginInfo = Get-OriginDiff $branch
        Write-Host -nonewline -foreground ($(Get-IsDirty -ne "") ? "yellow" : "cyan") "[${branch}] "
        Write-Host -nonewline -foreground $OriginInfo[0] ($OriginInfo[1] ?? "")
    }

    # CWD
    Write-Host -nonewline -foreground green $(Get-LocationPrefix)
    Write-Host " :"
    return "$ "
}
