param(
    [Parameter(Position = 0)]
    [ValidateSet('init', 'commit', 'help')]
    [string]$Command = 'help'
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = $PSScriptRoot
Set-Location -LiteralPath $ProjectRoot

function Assert-Command {
    param([Parameter(Mandatory)][string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "$Name is required but was not found in PATH."
    }
}

function Show-Help {
    Write-Host @'
Under the Same Sky - PowerShell setup helper

Usage:
  .\setup.ps1 <command>

Commands:
  init     Install dependencies, fix npm audit issues, and create .env
  commit   Prompt for a message, stage all changes, commit, and push
  help     Show this help

Examples:
  .\setup.ps1 init
  .\setup.ps1 commit
  .\setup.ps1 help

Requirements:
  - Node.js and npm for the init command
  - Git for the commit command
'@
}

function Initialize-Project {
    Assert-Command 'node'
    Assert-Command 'npm.cmd'

    Write-Host 'Installing dependencies...'
    & npm.cmd install
    if ($LASTEXITCODE -ne 0) { throw 'npm install failed.' }

    Write-Host 'Fixing npm audit issues...'
    & npm.cmd audit fix
    if ($LASTEXITCODE -ne 0) { throw 'npm audit fix failed.' }

    $template = Join-Path $ProjectRoot '.env.example'
    $destination = Join-Path $ProjectRoot '.env'

    if (-not (Test-Path -LiteralPath $template -PathType Leaf)) {
        throw '.env.example was not found; .env was not created.'
    }

    if (Test-Path -LiteralPath $destination) {
        Write-Host '.env already exists; it was not overwritten.'
    }
    else {
        Copy-Item -LiteralPath $template -Destination $destination
        Write-Host 'Created .env from .env.example.'
    }

    Write-Host 'Project initialization complete.'
}

function Commit-And-Push {
    Assert-Command 'git'

    $message = Read-Host 'Commit message'
    if ([string]::IsNullOrWhiteSpace($message)) {
        throw 'Commit message cannot be empty.'
    }

    & git add .
    if ($LASTEXITCODE -ne 0) { throw 'git add failed.' }

    & git commit -m $message
    if ($LASTEXITCODE -ne 0) { throw 'git commit failed.' }

    & git push
    if ($LASTEXITCODE -ne 0) { throw 'git push failed.' }
}

try {
    switch ($Command) {
        'init' { Initialize-Project }
        'commit' { Commit-And-Push }
        'help' { Show-Help }
    }
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
