#
# Ollama Skills Library — Setup Script (PowerShell)
# ==================================================
# Converts SKILL.md files to Modelfiles and builds Ollama models.
#
# Usage:
#   .\setup.ps1 -All                        # Build all bundles
#   .\setup.ps1 -Bundle legal               # Build only legal bundle
#   .\setup.ps1 -Skill legal/contract       # Build specific skill
#   .\setup.ps1 -DryRun                     # Preview without building
#   .\setup.ps1 -BaseModel mistral -All     # Use different base model
#

param(
    [switch]$All,
    [string]$Bundle = "",
    [string]$Skill = "",
    [string]$BaseModel = "llama3.2",
    [switch]$DryRun,
    [switch]$Help
)

# ============================================================================
# Configuration
# ============================================================================

$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$RepoRoot = $ScriptDir

# ============================================================================
# Functions
# ============================================================================

function Print-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host ("=" * 60)
    Write-Host $Message
    Write-Host ("=" * 60)
    Write-Host ""
}

function Print-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Print-OK {
    param([string]$Message)
    Write-Host "[OK]   $Message" -ForegroundColor Green
}

function Print-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Print-Usage {
    Write-Host @"
Usage: .\setup.ps1 [OPTIONS]

Options:
  -All                      Build all bundles (default)
  -Bundle NAME              Build only this bundle (e.g., legal, finance)
  -Skill BUNDLE/SKILL       Build specific skill (e.g., legal/contract-review)
  -BaseModel MODEL          Use this Ollama base model (default: llama3.2)
  -DryRun                   Preview without building
  -Help                     Show this help message

Examples:
  .\setup.ps1 -All
  .\setup.ps1 -Bundle legal
  .\setup.ps1 -Skill legal/contract-review
  .\setup.ps1 -BaseModel mistral -All
  .\setup.ps1 -DryRun

"@
}

function Test-Ollama {
    $OllamaExists = $null -ne (Get-Command ollama -ErrorAction SilentlyContinue)
    if (-not $OllamaExists) {
        Print-Error "Ollama is not installed or not in PATH"
        Print-Info "Install from: https://ollama.com"
        return $false
    }
    
    $OllamaVersion = & ollama --version 2>$null
    Print-OK "Ollama found: $OllamaVersion"
    return $true
}

function Test-Python {
    $PythonExists = $null -ne (Get-Command python3 -ErrorAction SilentlyContinue)
    if (-not $PythonExists) {
        Print-Error "Python 3 is not installed or not in PATH"
        return $false
    }
    
    $PythonVersion = & python3 --version 2>&1
    Print-OK "Python 3 found: $PythonVersion"
    return $true
}

function Invoke-Conversion {
    Print-Info "Converting SKILL.md files to Modelfiles..."
    
    $CmdArgs = @("$RepoRoot/convert.py", "--base-model", $BaseModel)
    
    if ($Bundle) {
        $CmdArgs += @("--bundle", $Bundle)
    }
    
    if ($DryRun) {
        $CmdArgs += "--dry-run"
    }
    
    $ProcArgs = @{
        FilePath     = "python3"
        ArgumentList = $CmdArgs
        NoNewWindow  = $false
        Wait         = $true
        PassThru     = $true
    }
    
    $Result = Start-Process @ProcArgs
    
    if ($Result.ExitCode -eq 0) {
        Print-OK "Conversion complete"
        return $true
    } else {
        Print-Error "Conversion failed with exit code $($Result.ExitCode)"
        return $false
    }
}

function Invoke-Build {
    if ($DryRun) {
        Print-Info "Dry run enabled, skipping model build"
        return $true
    }
    
    $ModelsDir = Join-Path $RepoRoot "models"
    
    if (-not (Test-Path $ModelsDir)) {
        Print-Error "models/ directory not found"
        return $false
    }
    
    Print-Info "Building Ollama models..."
    
    $Total = 0
    $Built = 0
    
    # If building specific skill
    if ($Skill) {
        $Parts = $Skill -split "/"
        $BundleName = $Parts[0]
        $SkillName = $Parts[1]
        $Modelfile = Join-Path $ModelsDir $BundleName $SkillName "Modelfile"
        
        if (-not (Test-Path $Modelfile)) {
            Print-Error "Modelfile not found: $Modelfile"
            return $false
        }
        
        $ModelName = "skills-$($BundleName -replace '_', '-')-$($SkillName -replace '_', '-')"
        Print-Info "Building: $ModelName"
        
        $Result = & ollama create $ModelName -f $Modelfile 2>&1
        if ($LASTEXITCODE -eq 0) {
            Print-OK "Built: $ModelName"
            $Built++
        } else {
            Print-Error "Failed to build: $ModelName"
        }
        $Total++
    } else {
        # Find all Modelfiles
        $Modelfiles = Get-ChildItem -Path $ModelsDir -Recurse -Filter "Modelfile" -File
        
        foreach ($Modelfile in $Modelfiles) {
            $BundlePath = Split-Path -Parent (Split-Path -Parent $Modelfile.FullName)
            $BundleName = Split-Path -Leaf $BundlePath
            $SkillDir = Split-Path -Leaf (Split-Path -Parent $Modelfile.FullName)
            $ModelName = "skills-$($BundleName -replace '_', '-')-$($SkillDir -replace '_', '-')"
            
            Print-Info "Building: $ModelName"
            
            $Result = & ollama create $ModelName -f $Modelfile.FullName 2>&1
            if ($LASTEXITCODE -eq 0) {
                Print-OK "Built: $ModelName"
                $Built++
            } else {
                Print-Error "Failed to build: $ModelName"
            }
            $Total++
        }
    }
    
    Print-Info "Build summary: $Built/$Total models built successfully"
    
    return ($Built -eq $Total)
}

function Invoke-List {
    Print-Info "Installed Ollama models:"
    
    $Models = & ollama list 2>&1 | Select-String "^skills-"
    
    if ($Models) {
        Write-Host $Models
    } else {
        Print-Info "No skills models found"
    }
}

# ============================================================================
# Main
# ============================================================================

function Main {
    Print-Header "Ollama Skills Library — Setup Script"
    
    if ($Help) {
        Print-Usage
        exit 0
    }
    
    # Display config
    Write-Host "Configuration:"
    Write-Host "  Base model      : $BaseModel"
    Write-Host "  Bundle filter   : $(if ($Bundle) { $Bundle } else { "(all)" })"
    Write-Host "  Skill filter    : $(if ($Skill) { $Skill } else { "(all)" })"
    Write-Host "  Dry run         : $DryRun"
    Write-Host ""
    
    # Checks
    if (-not (Test-Python)) {
        exit 1
    }
    if (-not (Test-Ollama)) {
        exit 1
    }
    
    # Convert
    if (-not (Invoke-Conversion)) {
        exit 1
    }
    
    # Build
    if (-not (Invoke-Build)) {
        exit 1
    }
    
    # List
    Write-Host ""
    Invoke-List
    
    Print-Header "Setup Complete"
    Print-OK "All done! Run: ollama run skills-<bundle>-<skill>"
}

Main
