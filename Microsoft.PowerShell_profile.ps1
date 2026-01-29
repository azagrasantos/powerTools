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
        [string]$m
    )

    $gitDir = git rev-parse --git-dir 2>$null
    if (-not $gitDir) {
        Write-Host "You must run gpush inside a Git repository." -ForegroundColor Red
        return
    }

    $currentBranch = git rev-parse --abbrev-ref HEAD
    if (-not $currentBranch) {
        Write-Host "Could not determine current branch." -ForegroundColor Red
        return
    }

    Write-Host "Committing changes on branch '$currentBranch'" -ForegroundColor Cyan

    git add -A
    git commit -m "$m" 2>$null

    if ($LASTEXITCODE -ne 0) {
        Write-Host "No changes to commit, continuing..." -ForegroundColor Yellow
    }

    $remoteBranches = git ls-remote --heads origin $currentBranch
    if (-not $remoteBranches) {
        Write-Host "Remote branch '$currentBranch' does not exist, creating it..." -ForegroundColor Cyan
    }

    Write-Host "Pushing branch '$currentBranch' to origin" -ForegroundColor Cyan
    git push -u origin $currentBranch
}

function branch {
    param (
        [Parameter(Mandatory=$true)]
        [string]$b
    )

    $branchName = $b.ToLower() -replace '\s+', '-' -replace '[^a-z0-9\-_]', ''
    if (-not $branchName) {
        Write-Host "Invalid branch name" -ForegroundColor Red
        return
    }

    Write-Host "Creating branch '$branchName'" -ForegroundColor Cyan

    git checkout -b $branchName

    if (-not (git rev-parse --verify HEAD 2>$null)) {
        git commit --allow-empty -m "First commit $branchName"
    }

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

function repos {
	Set-Location "C:\xampp\htdocs\"
}