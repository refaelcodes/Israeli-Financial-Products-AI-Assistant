[CmdletBinding()]
param(
    [switch]$NoBrowser
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$backendDir = Join-Path $root "backend"
$frontendDir = Join-Path $root "frontend"
$backendScript = Join-Path $backendDir "fund_ai_app.py"
$database = Join-Path $backendDir "fund_combined_db.db"
$requirements = Join-Path $backendDir "requirements.txt"
$frontendPackage = Join-Path $frontendDir "package.json"
$frontendModules = Join-Path $frontendDir "node_modules"
$logsDir = Join-Path $root "logs"
$backendUrl = "http://127.0.0.1:5000/api/health"
$frontendUrl = "http://127.0.0.1:5173"

function Show-LaunchError {
    param([string]$Message)

    try {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show(
            $Message,
            "Israeli Funds AI Assistant",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
    catch {
        Write-Error $Message
    }
}

function Test-HttpEndpoint {
    param([string]$Url)

    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 2
        return $response.StatusCode -ge 200 -and $response.StatusCode -lt 500
    }
    catch {
        return $false
    }
}

function Wait-HttpEndpoint {
    param(
        [string]$Url,
        [int]$TimeoutSeconds = 45
    )

    $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
    while ([DateTime]::UtcNow -lt $deadline) {
        if (Test-HttpEndpoint -Url $Url) {
            return $true
        }
        Start-Sleep -Milliseconds 500
    }
    return $false
}

function Resolve-Python {
    $localAppData = [Environment]::GetFolderPath("LocalApplicationData")
    $candidates = @(
        (Join-Path $localAppData "Python\bin\python.exe"),
        (Join-Path $localAppData "Programs\Python\Python314\python.exe"),
        (Join-Path $localAppData "Programs\Python\Python313\python.exe"),
        (Join-Path $localAppData "Programs\Python\Python312\python.exe")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    $command = Get-Command python.exe -ErrorAction SilentlyContinue
    if ($command -and $command.Source -notlike "*WindowsApps*") {
        return $command.Source
    }

    return $null
}

function Run-HiddenAndWait {
    param(
        [string]$FilePath,
        [string]$Arguments,
        [string]$WorkingDirectory,
        [string]$Name
    )

    $stdout = Join-Path $logsDir "$Name-install.stdout.log"
    $stderr = Join-Path $logsDir "$Name-install.stderr.log"
    $startInfo = @{
        FilePath = $FilePath
        ArgumentList = $Arguments
        WorkingDirectory = $WorkingDirectory
        WindowStyle = "Hidden"
        RedirectStandardOutput = $stdout
        RedirectStandardError = $stderr
        Wait = $true
        PassThru = $true
    }
    $process = Start-Process @startInfo

    if ($process.ExitCode -ne 0) {
        throw "$Name dependency installation failed. See logs in $logsDir."
    }
}

try {
    foreach ($required in @($backendScript, $database, $requirements, $frontendPackage)) {
        if (-not (Test-Path -LiteralPath $required)) {
            throw "Required file is missing:`n$required"
        }
    }

    New-Item -ItemType Directory -Path $logsDir -Force | Out-Null

    $python = Resolve-Python
    if (-not $python) {
        throw "Python 3.10 or newer was not found. Install Python and run the shortcut again."
    }

    $npmCommand = Get-Command npm.cmd -ErrorAction SilentlyContinue
    if (-not $npmCommand) {
        throw "Node.js/npm was not found. Install Node.js 18 or newer and run the shortcut again."
    }
    $npm = $npmCommand.Source

    & $python -c "import flask, flask_cors, jwt" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Run-HiddenAndWait -FilePath $python -Arguments ('-m pip install -r "{0}"' -f $requirements) -WorkingDirectory $backendDir -Name "backend"
    }

    if (-not (Test-Path -LiteralPath $frontendModules)) {
        Run-HiddenAndWait -FilePath $npm -Arguments "install --no-audit --no-fund" -WorkingDirectory $frontendDir -Name "frontend"
    }

    if (-not (Test-HttpEndpoint -Url $backendUrl)) {
        $backendStdout = Join-Path $logsDir "backend.stdout.log"
        $backendStderr = Join-Path $logsDir "backend.stderr.log"
        $backendStartInfo = @{
            FilePath = $python
            ArgumentList = ('"{0}"' -f $backendScript)
            WorkingDirectory = $backendDir
            WindowStyle = "Hidden"
            RedirectStandardOutput = $backendStdout
            RedirectStandardError = $backendStderr
        }
        Start-Process @backendStartInfo | Out-Null

        if (-not (Wait-HttpEndpoint -Url $backendUrl -TimeoutSeconds 45)) {
            throw "Backend did not start. Check:`n$backendStderr"
        }
    }

    if (-not (Test-HttpEndpoint -Url $frontendUrl)) {
        $frontendStdout = Join-Path $logsDir "frontend.stdout.log"
        $frontendStderr = Join-Path $logsDir "frontend.stderr.log"
        $frontendStartInfo = @{
            FilePath = $npm
            ArgumentList = "run dev -- --host 127.0.0.1"
            WorkingDirectory = $frontendDir
            WindowStyle = "Hidden"
            RedirectStandardOutput = $frontendStdout
            RedirectStandardError = $frontendStderr
        }
        Start-Process @frontendStartInfo | Out-Null

        if (-not (Wait-HttpEndpoint -Url $frontendUrl -TimeoutSeconds 60)) {
            throw "Frontend did not start. Check:`n$frontendStderr"
        }
    }

    if (-not $NoBrowser) {
        Start-Process $frontendUrl
    }
}
catch {
    Show-LaunchError -Message $_.Exception.Message
    exit 1
}
