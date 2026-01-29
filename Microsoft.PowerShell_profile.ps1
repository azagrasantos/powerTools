function Write-BranchName () {
    try {
        $branch = git rev-parse --abbrev-ref HEAD

        if ($branch -eq "HEAD") {
            $branch = git rev-parse --short HEAD
            Write-Host " ($branch)" -ForegroundColor "red"
        }
        else {
            Write-Host " ($branch)" -ForegroundColor "blue"
        }
    } catch {
        Write-Host " (sin ramas)" -ForegroundColor "yellow"
    }
}

function prompt {
    $base = "PS "
    $path = "$($executionContext.SessionState.Path.CurrentLocation)"
    $userPrompt = "$('>' * ($nestedPromptLevel + 1)) "

    Write-Host "`n$base" -NoNewline

    if (Test-Path .git) {
        Write-Host $path -NoNewline -ForegroundColor "green"
        Write-BranchName
    }
    else {
        Write-Host $path -ForegroundColor "green"
    }

    return $userPrompt
}

function gpush {
    param (
        [Parameter(Mandatory=$true)]
        [string]$m,

        [string]$r
    )
	
    git commit -a -m "$m"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Commit failure." -ForegroundColor Red
        return
    }
    $remoteBranch = if ($r) { $r } else { "master" }
    Write-Host "Pushing to origin $remoteBranch" -ForegroundColor Cyan
    git push origin $remoteBranch
}

function repos {
    Set-Location "C:\xampp\htdocs"
}

function branch {
    param (
        [Parameter(Mandatory=$true)]
        [string]$b
    )

    $branchName = $b.ToLower() `
        -replace '\s+', '-' `
        -replace '[^a-z0-9\-_]', ''

    if (-not $branchName) {
        Write-Host "Invalid branch name!" -ForegroundColor Red
        return
    }
    Write-Host "Creating branch '$branchName'" -ForegroundColor Cyan
    git checkout -b $branchName
    if ($LASTEXITCODE -ne 0) { return }
    git push -u origin $branchName
}

function gcheckout {
    param (
        [string]$flag,
        [string]$name
    )

    if ($flag -ne "-b" -or -not $name) {
        Write-Host "ERROR: Correct usage: gcheckout -b branch_name"
        return
    }

    git checkout -b $name
}

function gpull {
    git fetch --all
    git pull
}

function gclone {
    param (
        [Parameter(Mandatory=$true)]
        [string]$r
    )

    $repoName = $r -replace '\s+', '-' -replace '[^a-zA-Z0-9\-_]', ''

    if (-not $repoName) {
        Write-Host "Invalid repository name!" -ForegroundColor Red
        return
    }

    $githubUser = "azagrasantos"
    $remoteUrl = "git@github.com:$githubUser/$repoName.git"
    Write-Host "Cloning '$remoteUrl' into '$repoName'" -ForegroundColor Cyan

    git clone $remoteUrl $repoName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Repository has been successfully cloned" -ForegroundColor Green
    } else {
        Write-Host "Cloning error '$remoteUrl'" -ForegroundColor Red
    }
}