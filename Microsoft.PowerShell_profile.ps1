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
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$c
    )

    $branchName = $c -replace '\s+', '-' -replace '[^a-zA-Z0-9\-_]', ''
    if (-not $branchName) {
        Write-Host "Invalid branch name" -ForegroundColor Red
        return
    }

    $branchExists = git show-ref --verify --quiet "refs/heads/$branchName"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Branch '$branchName' already exists. Checking out..." -ForegroundColor Yellow
        git checkout $branchName
        return
    }

    Write-Host "Creating branch '$branchName' from current branch" -ForegroundColor Cyan

    git checkout -b $branchName
    git push -u origin $branchName
}

function gcheckout {
    param (
        [string]$arg1,
        [string]$arg2
    )

    if ($arg1 -eq "-b") {
        if (-not $arg2) {
            Write-Host "ERROR: Missing branch name"
            return
        }

        git checkout -b $arg2
    }
    else {
        if (-not $arg1) {
            Write-Host "ERROR: Missing branch name"
            return
        }

        git checkout $arg1
    }
}

function grename {
    param (
        [string]$o,
        [Parameter(Mandatory = $true)]
        [string]$n
    )

    if (-not $o) {
        $o = (git rev-parse --abbrev-ref HEAD).Trim()
        if (-not $o) {
            Write-Host "ERROR: Could not determine current branch" -ForegroundColor Red
            return
        }
    }

    $newName = $n -replace '\s+', '-' -replace '[^a-zA-Z0-9\-_]', ''
    if (-not $newName) {
        Write-Host "ERROR: Invalid new branch name" -ForegroundColor Red
        return
    }

    Write-Host "Renaming branch '$o' > '$newName'" -ForegroundColor Cyan

    git branch -m $o $newName
    $remoteExists = git ls-remote --heads origin $o
    if ($remoteExists) {
        git push origin :$o
    }

    git push -u origin $newName
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

function gtomaster {
    $currentBranch = (git rev-parse --abbrev-ref HEAD).Trim()
    if (-not $currentBranch) {
        Write-Host "ERROR: Could not determine current branch" -ForegroundColor Red
        return
    }

    if ($currentBranch -eq "master") {
        Write-Host "Already on master" -ForegroundColor Yellow
        return
    }

    git show-ref --verify --quiet refs/heads/master
    $masterExists = ($LASTEXITCODE -eq 0)

    if (-not $masterExists) {
        Write-Host "Master branch does not exist. Creating it..." -ForegroundColor Cyan
        git checkout -b master
    }
    else {
        git checkout master
    }

    Write-Host "Merging '$currentBranch' > master" -ForegroundColor Cyan
    git merge $currentBranch

    git checkout $currentBranch
}

function gdelete {
    param (
        [string]$b
    )

    if ($b) {
        $targetBranch = $b
    }
    else {
        $targetBranch = (git rev-parse --abbrev-ref HEAD).Trim()
    }

    if (-not $targetBranch) {
        Write-Host "ERROR: Could not determine target branch" -ForegroundColor Red
        return
    }

    if ($targetBranch -eq "master") {
        Write-Host "ERROR: You cannot delete 'master'" -ForegroundColor Red
        return
    }

    git show-ref --verify --quiet refs/heads/master
    $masterExists = ($LASTEXITCODE -eq 0)

    if (-not $masterExists) {
        Write-Host "Master does not exist. Creating it..." -ForegroundColor Cyan
        git checkout -b master
    }
    else {
        git checkout master
    }

    Write-Host "Deleting branch '$targetBranch'" -ForegroundColor Cyan

    git branch -D $targetBranch
    $remoteExists = git ls-remote --heads origin $targetBranch
    if ($remoteExists) {
        git push origin --delete $targetBranch
    }
}

function repos {
	Set-Location "C:\xampp\htdocs\"
}