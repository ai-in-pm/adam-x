<#
.SYNOPSIS
    Adam-x: A PhD-level AI coding assistant for your terminal
.DESCRIPTION
    This PowerShell script creates an AI agent named Adam-x that provides coding assistance,
    problem-solving, and documentation generation directly in your terminal.
.NOTES
    Version:        1.0
    Author:         AI Assistant
    Creation Date:  $(Get-Date -Format "yyyy-MM-dd")
#>

# Simple test to see if the script is running
Write-Host "Adam-x script is running..." -ForegroundColor Green

# Configuration
$global:AdamX = @{
    Name = "Adam-x"
    Version = "1.0.0"
    OllamaPath = "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe"  # Path to Ollama executable
    OllamaServer = "http://localhost:11434"  # Default Ollama server URL
    HistoryFile = Join-Path $PSScriptRoot "adam-x-history.json"
    ConfigFile = Join-Path $PSScriptRoot "adam-x-config.json"
    Model = "tinyllama"  # Default model
    Temperature = 0.7
    MaxTokens = 2000
    ConversationHistory = @()
    MaxHistoryLength = 10  # Maximum number of conversation turns to remember

    # Recommended models for different tasks
    RecommendedModels = @{
        "general" = @("llama3", "mistral", "tinyllama")
        "coding" = @("codellama", "wizardcoder", "deepseek-coder")
        "python" = @("codellama:python", "wizardcoder:python")
        "javascript" = @("codellama:javascript", "wizardcoder:javascript")
        "java" = @("codellama:java", "wizardcoder:java")
        "csharp" = @("codellama:csharp", "wizardcoder:csharp")
        "cpp" = @("codellama:cpp", "wizardcoder:cpp")
        "go" = @("codellama:go", "wizardcoder:go")
        "rust" = @("codellama:rust", "wizardcoder:rust")
    }

    # System prompts for different tasks
    SystemPrompts = @{
        "default" = "You are Adam-x, a PhD-level AI coding assistant. Provide expert-level coding advice, problem-solving, and explanations."
        "analyze" = "You are Adam-x, a PhD-level AI coding assistant specializing in code analysis. Analyze the provided code thoroughly, identifying potential bugs, performance issues, and suggesting improvements. Be specific and provide examples where appropriate."
        "document" = "You are Adam-x, a PhD-level AI coding assistant specializing in documentation. Create comprehensive, clear, and well-structured documentation for the provided code. Include purpose, usage examples, parameter descriptions, and return values."
        "explain" = "You are Adam-x, a PhD-level AI coding assistant specializing in code explanation. Explain the provided code in a clear, concise manner. Break down complex concepts and provide context for why certain approaches were taken."
        "improve" = "You are Adam-x, a PhD-level AI coding assistant specializing in code improvement. Suggest specific, actionable improvements to the provided code. Focus on performance, readability, maintainability, and best practices."
        "generate" = "You are Adam-x, a PhD-level AI coding assistant specializing in code generation. Generate high-quality, production-ready code based on the provided description. Include comments, error handling, and follow best practices for the specified language."
        "debug" = "You are Adam-x, a PhD-level AI coding assistant specializing in debugging. Identify and fix issues in the provided code. Explain the root cause of each issue and how your solution addresses it."
    }
}

# Function to display the welcome message
function Show-AdamXWelcome {
    $welcomeText = @"

    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║   █████╗ ██████╗  █████╗ ███╗   ███╗      ██╗  ██╗           ║
    ║  ██╔══██╗██╔══██╗██╔══██╗████╗ ████║      ╚██╗██╔╝           ║
    ║  ███████║██║  ██║███████║██╔████╔██║       ╚███╔╝            ║
    ║  ██╔══██║██║  ██║██╔══██║██║╚██╔╝██║       ██╔██╗            ║
    ║  ██║  ██║██████╔╝██║  ██║██║ ╚═╝ ██║██╗    ██╔╝ ██╗          ║
    ║  ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝    ╚═╝  ╚═╝          ║
    ║                                                               ║
    ║   PhD-Level AI Coding Assistant v$($global:AdamX.Version)                  ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝

"@
    Write-Host $welcomeText -ForegroundColor Cyan
    Write-Host "  Hello! I'm $($global:AdamX.Name), your terminal-based coding assistant." -ForegroundColor Yellow
    Write-Host "  Type 'help' to see available commands or ask me a coding question directly." -ForegroundColor Yellow
    Write-Host ""
}

# Function to load configuration
function Initialize-AdamXConfig {
    if (Test-Path $global:AdamX.ConfigFile) {
        try {
            $config = Get-Content $global:AdamX.ConfigFile | ConvertFrom-Json
            $global:AdamX.OllamaServer = $config.OllamaServer
            $global:AdamX.Model = $config.Model
            $global:AdamX.Temperature = $config.Temperature
            $global:AdamX.MaxTokens = $config.MaxTokens

            # Load conversation history if it exists
            if ($config.ConversationHistory) {
                $global:AdamX.ConversationHistory = $config.ConversationHistory
            }

            # Load max history length if it exists
            if ($config.MaxHistoryLength) {
                $global:AdamX.MaxHistoryLength = $config.MaxHistoryLength
            }

            Write-Host "Configuration loaded successfully." -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "Error loading configuration: $_" -ForegroundColor Red
            Write-Host "Using default configuration." -ForegroundColor Yellow
            return $false
        }
    }
    Write-Host "No configuration file found. Using default configuration." -ForegroundColor Yellow
    return $false
}

# Function to save configuration
function Save-AdamXConfig {
    try {
        $config = @{
            OllamaServer = $global:AdamX.OllamaServer
            Model = $global:AdamX.Model
            Temperature = $global:AdamX.Temperature
            MaxTokens = $global:AdamX.MaxTokens
            ConversationHistory = $global:AdamX.ConversationHistory
            MaxHistoryLength = $global:AdamX.MaxHistoryLength
        }
        $config | ConvertTo-Json -Depth 10 | Set-Content $global:AdamX.ConfigFile
        Write-Verbose "Configuration saved successfully."
        return $true
    }
    catch {
        Write-Host "Error saving configuration: $_" -ForegroundColor Red
        return $false
    }
}

# Function to set up Adam-x for first use
function Initialize-AdamXSetup {
    Write-Host "Setting up $($global:AdamX.Name) for first use..." -ForegroundColor Green

    # Check if Ollama is installed
    if (-not (Test-Path $global:AdamX.OllamaPath)) {
        Write-Host "Ollama not found at $($global:AdamX.OllamaPath)" -ForegroundColor Red
        Write-Host "Please install Ollama from https://ollama.ai/download" -ForegroundColor Red
        return
    }

    # Check if Ollama is running
    try {
        $null = Invoke-RestMethod -Uri "$($global:AdamX.OllamaServer)/api/tags" -Method Get -ErrorAction Stop
        Write-Host "Ollama server is running at $($global:AdamX.OllamaServer)" -ForegroundColor Green
    }
    catch {
        Write-Host "Ollama server is not running. Please start Ollama and try again." -ForegroundColor Red
        return
    }

    # Ask for Ollama server URL
    $ollamaServer = Read-Host "Enter your Ollama server URL (or press Enter to use default: $($global:AdamX.OllamaServer))"
    if ($ollamaServer) {
        $global:AdamX.OllamaServer = $ollamaServer
    }

    # Ask for model
    $availableModels = & $global:AdamX.OllamaPath list | Select-Object -Skip 1 | ForEach-Object { if ($_ -match '^(\S+)') { $matches[1] } }

    if ($availableModels) {
        Write-Host "Available models:" -ForegroundColor Yellow
        $availableModels | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }

        $model = Read-Host "Enter the model to use (or press Enter to use default: $($global:AdamX.Model))"
        if ($model) {
            if ($availableModels -contains $model) {
                $global:AdamX.Model = $model
                Write-Host "Model set to: $model" -ForegroundColor Green
            }
            else {
                Write-Host "Model '$model' not found. Using default: $($global:AdamX.Model)" -ForegroundColor Yellow
            }
        }
        else {
            # If no model is entered and the default model is not available, use the first available model
            if (-not ($availableModels -contains $global:AdamX.Model)) {
                # Extract the full model name from the available models
                $fullModelName = & $global:AdamX.OllamaPath list | Select-Object -Skip 1 | Select-Object -First 1
                if ($fullModelName -match '^(\S+)') {
                    $global:AdamX.Model = $matches[1]
                    Write-Host "Default model not found. Using available model: $($global:AdamX.Model)" -ForegroundColor Yellow
                }
            }
        }
    }
    else {
        Write-Host "No models found. Please pull a model using 'ollama pull <model>' and try again." -ForegroundColor Yellow
        Write-Host "Recommended models for coding: codellama, llama3, mistral" -ForegroundColor Yellow
    }

    # Save configuration
    Save-AdamXConfig

    Write-Host "Setup complete!" -ForegroundColor Green
}

# Function to handle API calls to Ollama
function Invoke-AdamXAI {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Prompt,

        [Parameter(Mandatory=$false)]
        [string]$SystemMessage = $null,

        [Parameter(Mandatory=$false)]
        [string]$TaskType = "default",

        [Parameter(Mandatory=$false)]
        [int]$MaxRetries = 3,

        [Parameter(Mandatory=$false)]
        [switch]$UseHistory
    )

    # Set the system message based on task type if not explicitly provided
    if (-not $SystemMessage) {
        if ($global:AdamX.SystemPrompts.ContainsKey($TaskType)) {
            $SystemMessage = $global:AdamX.SystemPrompts[$TaskType]
        } else {
            $SystemMessage = $global:AdamX.SystemPrompts["default"]
        }
    }

    # Check if Ollama executable exists
    if (-not (Test-Path $global:AdamX.OllamaPath)) {
        Write-Host "Ollama executable not found at $($global:AdamX.OllamaPath)." -ForegroundColor Red
        Write-Host "Please install Ollama from https://ollama.ai/download" -ForegroundColor Yellow
        return $null
    }

    # Retry logic for API calls
    $retryCount = 0
    $success = $false
    $result = $null

    while (-not $success -and $retryCount -lt $MaxRetries) {
        try {
            # Check if Ollama is running
            try {
                $null = Invoke-RestMethod -Uri "$($global:AdamX.OllamaServer)/api/tags" -Method Get -ErrorAction Stop -TimeoutSec 5
            }
            catch {
                # Try to start Ollama if it's not running
                Write-Host "Ollama server is not running. Attempting to start it..." -ForegroundColor Yellow
                try {
                    Start-Process -FilePath $global:AdamX.OllamaPath -WindowStyle Hidden
                    # Wait for Ollama to start
                    $ollamaStarted = $false
                    $startAttempts = 0
                    while (-not $ollamaStarted -and $startAttempts -lt 5) {
                        Start-Sleep -Seconds 2
                        try {
                            $null = Invoke-RestMethod -Uri "$($global:AdamX.OllamaServer)/api/tags" -Method Get -ErrorAction Stop -TimeoutSec 5
                            $ollamaStarted = $true
                            Write-Host "Ollama server started successfully." -ForegroundColor Green
                        }
                        catch {
                            $startAttempts++
                        }
                    }

                    if (-not $ollamaStarted) {
                        Write-Host "Failed to start Ollama server. Please start it manually and try again." -ForegroundColor Red
                        return $null
                    }
                }
                catch {
                    Write-Host "Failed to start Ollama server" -ForegroundColor Red
                    Write-Host "Please start Ollama manually and try again." -ForegroundColor Yellow
                    return $null
                }
            }

            # Check if the model exists
            $modelExists = $false
            try {
                $availableModels = & $global:AdamX.OllamaPath list 2>$null | Select-Object -Skip 1
                foreach ($modelLine in $availableModels) {
                    if ($modelLine -match "^$($global:AdamX.Model)\s") {
                        $modelExists = $true
                        break
                    }
                }

                if (-not $modelExists) {
                    Write-Host "Model '$($global:AdamX.Model)' not found. Available models:" -ForegroundColor Yellow
                    $availableModels | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }

                    # Suggest pulling the model
                    $pullModel = Read-Host "Would you like to pull the '$($global:AdamX.Model)' model? (y/n)"
                    if ($pullModel -eq "y") {
                        Write-Host "Pulling model '$($global:AdamX.Model)'..." -ForegroundColor Yellow
                        & $global:AdamX.OllamaPath pull $global:AdamX.Model
                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "Model pulled successfully." -ForegroundColor Green
                            $modelExists = $true
                        } else {
                            Write-Host "Failed to pull model. Please check the model name and try again." -ForegroundColor Red
                            return $null
                        }
                    } else {
                        Write-Host "Using the first available model instead." -ForegroundColor Yellow
                        if ($availableModels.Count -gt 0) {
                            $firstModel = $availableModels[0] -split '\s+' | Select-Object -First 1
                            $global:AdamX.Model = $firstModel
                            Write-Host "Using model: $firstModel" -ForegroundColor Green
                            $modelExists = $true
                        } else {
                            Write-Host "No models available. Please pull a model using 'ollama pull <model>' and try again." -ForegroundColor Red
                            return $null
                        }
                    }
                }
            }
            catch {
                Write-Host "Error checking available models" -ForegroundColor Red
                return $null
            }

            # Prepare the API request
            $headers = @{
                "Content-Type" = "application/json"
            }

            # Prepare messages including history if requested
            $messages = @()
            $messages += @{
                role = "system"
                content = $SystemMessage
            }

            if ($UseHistory -and $global:AdamX.ConversationHistory.Count -gt 0) {
                foreach ($historyItem in $global:AdamX.ConversationHistory) {
                    $messages += @{
                        role = $historyItem.role
                        content = $historyItem.content
                    }
                }
            }

            $messages += @{
                role = "user"
                content = $Prompt
            }

            $body = @{
                model = $global:AdamX.Model
                messages = $messages
                options = @{
                    temperature = $global:AdamX.Temperature
                    num_predict = $global:AdamX.MaxTokens
                }
                stream = $false
            } | ConvertTo-Json -Depth 10

            # Make the API call
            $response = Invoke-RestMethod -Uri "$($global:AdamX.OllamaServer)/api/chat" -Method Post -Headers $headers -Body $body -TimeoutSec 120

            # Add to conversation history
            if ($UseHistory) {
                # Add user message to history
                $global:AdamX.ConversationHistory += @{
                    role = "user"
                    content = $Prompt
                }

                # Add assistant response to history
                $global:AdamX.ConversationHistory += @{
                    role = "assistant"
                    content = $response.message.content
                }

                # Trim history if it exceeds the maximum length
                while ($global:AdamX.ConversationHistory.Count -gt $global:AdamX.MaxHistoryLength * 2) {
                    $global:AdamX.ConversationHistory = $global:AdamX.ConversationHistory[2..($global:AdamX.ConversationHistory.Count - 1)]
                }

                # Save updated history
                Save-AdamXConfig
            }

            # Return the response
            $result = $response.message.content
            $success = $true
        }
        catch {
            $retryCount++
            if ($retryCount -lt $MaxRetries) {
                Write-Host "Error calling Ollama API" -ForegroundColor Red
                Write-Host "Retrying ($retryCount/$MaxRetries)..." -ForegroundColor Yellow
                Start-Sleep -Seconds ($retryCount * 2)  # Exponential backoff
            } else {
                Write-Host "Error calling Ollama API after $MaxRetries attempts" -ForegroundColor Red
                return $null
            }
        }
    }

    return $result
}

# Function to analyze code
function Invoke-AdamXCodeAnalysis {
    param (
        [Parameter(Mandatory=$true)]
        [string]$CodePath,

        [Parameter(Mandatory=$false)]
        [switch]$UseHistory
    )

    if (-not (Test-Path $CodePath)) {
        Write-Host "File not found: $CodePath" -ForegroundColor Red
        return
    }

    try {
        $code = Get-Content $CodePath -Raw -ErrorAction Stop
        $fileExtension = [System.IO.Path]::GetExtension($CodePath)
        $language = switch ($fileExtension) {
            ".ps1" { "PowerShell" }
            ".py" { "Python" }
            ".js" { "JavaScript" }
            ".ts" { "TypeScript" }
            ".cs" { "C#" }
            ".java" { "Java" }
            ".cpp" { "C++" }
            ".c" { "C" }
            ".go" { "Go" }
            ".rb" { "Ruby" }
            ".php" { "PHP" }
            ".html" { "HTML" }
            ".css" { "CSS" }
            ".sql" { "SQL" }
            default { "Unknown" }
        }

        # Check if we have a specialized model for this language
        $originalModel = $global:AdamX.Model
        $languageKey = $language.ToLower()
        if ($global:AdamX.RecommendedModels.ContainsKey($languageKey)) {
            $recommendedModels = $global:AdamX.RecommendedModels[$languageKey]
            $modelFound = $false

            # Check if any of the recommended models are available
            $availableModels = & $global:AdamX.OllamaPath list 2>$null | Select-Object -Skip 1
            foreach ($recommendedModel in $recommendedModels) {
                foreach ($modelLine in $availableModels) {
                    if ($modelLine -match "^$recommendedModel\s") {
                        $global:AdamX.Model = $recommendedModel
                        Write-Host "Using specialized $language model: $recommendedModel" -ForegroundColor Green
                        $modelFound = $true
                        break
                    }
                }
                if ($modelFound) { break }
            }

            # If no specialized model is found, suggest pulling one
            if (-not $modelFound -and $recommendedModels.Count -gt 0) {
                $pullModel = Read-Host "Would you like to pull a specialized $language model ($($recommendedModels[0]))? (y/n)"
                if ($pullModel -eq "y") {
                    Write-Host "Pulling model '$($recommendedModels[0])'..." -ForegroundColor Yellow
                    & $global:AdamX.OllamaPath pull $recommendedModels[0]
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "Model pulled successfully." -ForegroundColor Green
                        $global:AdamX.Model = $recommendedModels[0]
                    }
                }
            }
        }

        $prompt = @"
Analyze the following $language code and provide:
1. A summary of what the code does
2. Potential bugs or issues
3. Suggestions for improvement
4. Best practices that could be applied

Code:
```$language
$code
```
"@

        Write-Host "Analyzing $language code in $CodePath..." -ForegroundColor Yellow
        $analysis = Invoke-AdamXAI -Prompt $prompt -TaskType "analyze" -UseHistory:$UseHistory

        # Restore original model if it was changed
        if ($global:AdamX.Model -ne $originalModel) {
            $global:AdamX.Model = $originalModel
            Write-Host "Restored default model: $originalModel" -ForegroundColor Gray
        }

        if ($analysis) {
            Write-Host "Analysis of file: $CodePath" -ForegroundColor Green
            Write-Host $analysis
            return $analysis
        } else {
            Write-Host "Failed to analyze code." -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "Error analyzing code" -ForegroundColor Red
        return $null
    }
}

# Function to generate documentation
function New-AdamXDocumentation {
    param (
        [Parameter(Mandatory=$true)]
        [string]$CodePath,

        [Parameter(Mandatory=$false)]
        [string]$OutputPath = $null,

        [Parameter(Mandatory=$false)]
        [switch]$UseHistory
    )

    if (-not (Test-Path $CodePath)) {
        Write-Host "File not found: $CodePath" -ForegroundColor Red
        return
    }

    try {
        $code = Get-Content $CodePath -Raw -ErrorAction Stop
        $fileExtension = [System.IO.Path]::GetExtension($CodePath)
        $language = switch ($fileExtension) {
            ".ps1" { "PowerShell" }
            ".py" { "Python" }
            ".js" { "JavaScript" }
            ".ts" { "TypeScript" }
            ".cs" { "C#" }
            ".java" { "Java" }
            ".cpp" { "C++" }
            ".c" { "C" }
            ".go" { "Go" }
            ".rb" { "Ruby" }
            ".php" { "PHP" }
            ".html" { "HTML" }
            ".css" { "CSS" }
            ".sql" { "SQL" }
            default { "Unknown" }
        }

        # Check if we have a specialized model for this language
        $originalModel = $global:AdamX.Model
        $languageKey = $language.ToLower()
        if ($global:AdamX.RecommendedModels.ContainsKey($languageKey)) {
            $recommendedModels = $global:AdamX.RecommendedModels[$languageKey]
            $modelFound = $false

            # Check if any of the recommended models are available
            $availableModels = & $global:AdamX.OllamaPath list 2>$null | Select-Object -Skip 1
            foreach ($recommendedModel in $recommendedModels) {
                foreach ($modelLine in $availableModels) {
                    if ($modelLine -match "^$recommendedModel\s") {
                        $global:AdamX.Model = $recommendedModel
                        Write-Host "Using specialized $language model: $recommendedModel" -ForegroundColor Green
                        $modelFound = $true
                        break
                    }
                }
                if ($modelFound) { break }
            }
        }

        $prompt = @"
Generate comprehensive documentation for the following $language code:
```$language
$code
```

Include:
1. Overview of what the code does
2. Detailed explanation of functions/classes/methods
3. Parameters and return values
4. Usage examples
5. Dependencies
6. Any important notes or caveats

Format the documentation in Markdown.
"@

        Write-Host "Generating documentation for $language code in $CodePath..." -ForegroundColor Yellow
        $documentation = Invoke-AdamXAI -Prompt $prompt -TaskType "document" -UseHistory:$UseHistory

        # Restore original model if it was changed
        if ($global:AdamX.Model -ne $originalModel) {
            $global:AdamX.Model = $originalModel
            Write-Host "Restored default model: $originalModel" -ForegroundColor Gray
        }

        if ($documentation) {
            if ($OutputPath) {
                try {
                    $documentation | Out-File -FilePath $OutputPath -ErrorAction Stop
                    Write-Host "Documentation saved to $OutputPath" -ForegroundColor Green
                }
                catch {
                    Write-Host "Error saving documentation to $OutputPath" -ForegroundColor Red
                    Write-Host "Generated Documentation:" -ForegroundColor Green
                    Write-Host $documentation
                }
            }
            else {
                Write-Host "Generated Documentation:" -ForegroundColor Green
                Write-Host $documentation
            }
            return $documentation
        } else {
            Write-Host "Failed to generate documentation." -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "Error generating documentation" -ForegroundColor Red
        return $null
    }
}

# Function to explain code
function Get-AdamXCodeExplanation {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Code,

        [Parameter(Mandatory=$false)]
        [string]$Language = "Unknown",

        [Parameter(Mandatory=$false)]
        [switch]$UseHistory
    )

    try {
        # Check if we have a specialized model for this language
        $originalModel = $global:AdamX.Model
        $languageKey = $Language.ToLower()
        if ($global:AdamX.RecommendedModels.ContainsKey($languageKey)) {
            $recommendedModels = $global:AdamX.RecommendedModels[$languageKey]
            $modelFound = $false

            # Check if any of the recommended models are available
            $availableModels = & $global:AdamX.OllamaPath list 2>$null | Select-Object -Skip 1
            foreach ($recommendedModel in $recommendedModels) {
                foreach ($modelLine in $availableModels) {
                    if ($modelLine -match "^$recommendedModel\s") {
                        $global:AdamX.Model = $recommendedModel
                        Write-Host "Using specialized $Language model: $recommendedModel" -ForegroundColor Green
                        $modelFound = $true
                        break
                    }
                }
                if ($modelFound) { break }
            }
        }

        $prompt = @"
Explain the following code in detail:
```$Language
$Code
```

Provide:
1. A line-by-line explanation
2. The overall purpose of the code
3. Any important concepts or patterns used
"@

        Write-Host "Explaining $Language code..." -ForegroundColor Yellow
        $explanation = Invoke-AdamXAI -Prompt $prompt -TaskType "explain" -UseHistory:$UseHistory

        # Restore original model if it was changed
        if ($global:AdamX.Model -ne $originalModel) {
            $global:AdamX.Model = $originalModel
            Write-Host "Restored default model: $originalModel" -ForegroundColor Gray
        }

        if ($explanation) {
            Write-Host "Code Explanation:" -ForegroundColor Green
            Write-Host $explanation
            return $explanation
        } else {
            Write-Host "Failed to explain code." -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "Error explaining code" -ForegroundColor Red
        return $null
    }
}

# Function to suggest code improvements
function Get-AdamXCodeImprovement {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Code,

        [Parameter(Mandatory=$false)]
        [string]$Language = "Unknown",

        [Parameter(Mandatory=$false)]
        [switch]$UseHistory
    )

    try {
        # Check if we have a specialized model for this language
        $originalModel = $global:AdamX.Model
        $languageKey = $Language.ToLower()
        if ($global:AdamX.RecommendedModels.ContainsKey($languageKey)) {
            $recommendedModels = $global:AdamX.RecommendedModels[$languageKey]
            $modelFound = $false

            # Check if any of the recommended models are available
            $availableModels = & $global:AdamX.OllamaPath list 2>$null | Select-Object -Skip 1
            foreach ($recommendedModel in $recommendedModels) {
                foreach ($modelLine in $availableModels) {
                    if ($modelLine -match "^$recommendedModel\s") {
                        $global:AdamX.Model = $recommendedModel
                        Write-Host "Using specialized $Language model: $recommendedModel" -ForegroundColor Green
                        $modelFound = $true
                        break
                    }
                }
                if ($modelFound) { break }
            }
        }

        $prompt = @"
Suggest improvements for the following code:
```$Language
$Code
```

Provide:
1. Specific improvements with code examples
2. Performance optimizations
3. Better practices or patterns
4. Readability enhancements
"@

        Write-Host "Finding improvements for $Language code..." -ForegroundColor Yellow
        $improvements = Invoke-AdamXAI -Prompt $prompt -TaskType "improve" -UseHistory:$UseHistory

        # Restore original model if it was changed
        if ($global:AdamX.Model -ne $originalModel) {
            $global:AdamX.Model = $originalModel
            Write-Host "Restored default model: $originalModel" -ForegroundColor Gray
        }

        if ($improvements) {
            Write-Host "Suggested Improvements:" -ForegroundColor Green
            Write-Host $improvements
            return $improvements
        } else {
            Write-Host "Failed to suggest improvements." -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "Error suggesting improvements" -ForegroundColor Red
        return $null
    }
}

# Function to generate code based on a description
function New-AdamXCode {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Description,

        [Parameter(Mandatory=$true)]
        [string]$Language,

        [Parameter(Mandatory=$false)]
        [string]$OutputPath = $null,

        [Parameter(Mandatory=$false)]
        [switch]$UseHistory
    )

    try {
        # Check if we have a specialized model for this language
        $originalModel = $global:AdamX.Model
        $languageKey = $Language.ToLower()
        if ($global:AdamX.RecommendedModels.ContainsKey($languageKey)) {
            $recommendedModels = $global:AdamX.RecommendedModels[$languageKey]
            $modelFound = $false

            # Check if any of the recommended models are available
            $availableModels = & $global:AdamX.OllamaPath list 2>$null | Select-Object -Skip 1
            foreach ($recommendedModel in $recommendedModels) {
                foreach ($modelLine in $availableModels) {
                    if ($modelLine -match "^$recommendedModel\s") {
                        $global:AdamX.Model = $recommendedModel
                        Write-Host "Using specialized $Language model: $recommendedModel" -ForegroundColor Green
                        $modelFound = $true
                        break
                    }
                }
                if ($modelFound) { break }
            }

            # If no specialized model is found, suggest pulling one
            if (-not $modelFound -and $recommendedModels.Count -gt 0) {
                $pullModel = Read-Host "Would you like to pull a specialized $Language model ($($recommendedModels[0]))? (y/n)"
                if ($pullModel -eq "y") {
                    Write-Host "Pulling model '$($recommendedModels[0])'..." -ForegroundColor Yellow
                    & $global:AdamX.OllamaPath pull $recommendedModels[0]
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "Model pulled successfully." -ForegroundColor Green
                        $global:AdamX.Model = $recommendedModels[0]
                    }
                }
            }
        }

        # Use a more specialized prompt for code generation
        $prompt = @"
Generate $Language code based on the following description:
$Description

Provide:
1. Well-commented, production-quality code
2. Explanation of design decisions
3. Any necessary setup or usage instructions
4. Error handling and edge cases
5. Best practices specific to $Language

Make sure the code is complete, functional, and follows modern $Language conventions.
"@

        Write-Host "Generating $Language code..." -ForegroundColor Yellow
        $generatedCode = Invoke-AdamXAI -Prompt $prompt -TaskType "generate" -UseHistory:$UseHistory

        # Restore original model if it was changed
        if ($global:AdamX.Model -ne $originalModel) {
            $global:AdamX.Model = $originalModel
            Write-Host "Restored default model: $originalModel" -ForegroundColor Gray
        }

        if ($generatedCode) {
            if ($OutputPath) {
                try {
                    $generatedCode | Out-File -FilePath $OutputPath -ErrorAction Stop
                    Write-Host "Generated code saved to $OutputPath" -ForegroundColor Green
                }
                catch {
                    Write-Host "Error saving generated code to $OutputPath" -ForegroundColor Red
                    Write-Host "Generated Code:" -ForegroundColor Green
                    Write-Host $generatedCode
                }
            }
            else {
                Write-Host "Generated Code:" -ForegroundColor Green
                Write-Host $generatedCode
            }
            return $generatedCode
        } else {
            Write-Host "Failed to generate code." -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "Error generating code" -ForegroundColor Red
        return $null
    }
}

# Function to debug code
function Debug-AdamXCode {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Code,

        [Parameter(Mandatory=$false)]
        [string]$Language = "Unknown",

        [Parameter(Mandatory=$false)]
        [string]$ErrorMsg = "",

        [Parameter(Mandatory=$false)]
        [switch]$UseHistory
    )

    try {
        # Check if we have a specialized model for this language
        $originalModel = $global:AdamX.Model
        $languageKey = $Language.ToLower()
        if ($global:AdamX.RecommendedModels.ContainsKey($languageKey)) {
            $recommendedModels = $global:AdamX.RecommendedModels[$languageKey]
            $modelFound = $false

            # Check if any of the recommended models are available
            $availableModels = & $global:AdamX.OllamaPath list 2>$null | Select-Object -Skip 1
            foreach ($recommendedModel in $recommendedModels) {
                foreach ($modelLine in $availableModels) {
                    if ($modelLine -match "^$recommendedModel\s") {
                        $global:AdamX.Model = $recommendedModel
                        Write-Host "Using specialized $Language model: $recommendedModel" -ForegroundColor Green
                        $modelFound = $true
                        break
                    }
                }
                if ($modelFound) { break }
            }
        }

        $prompt = @"
Debug the following $Language code:
```$Language
$Code
```

$(if ($ErrorMsg) { "The code produces the following error: $ErrorMsg" })

Provide:
1. Identification of the issue(s)
2. Explanation of what's causing the problem
3. Fixed version of the code
4. How to prevent similar issues in the future
5. Any additional best practices that could improve the code
"@

        Write-Host "Debugging $Language code..." -ForegroundColor Yellow
        $debugResult = Invoke-AdamXAI -Prompt $prompt -TaskType "debug" -UseHistory:$UseHistory

        # Restore original model if it was changed
        if ($global:AdamX.Model -ne $originalModel) {
            $global:AdamX.Model = $originalModel
            Write-Host "Restored default model: $originalModel" -ForegroundColor Gray
        }

        if ($debugResult) {
            Write-Host "Debugging Results:" -ForegroundColor Green
            Write-Host $debugResult
            return $debugResult
        } else {
            Write-Host "Failed to debug code." -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "Error debugging code" -ForegroundColor Red
        return $null
    }
}

# Function to list available models
function Get-AdamXModels {
    param (
        [Parameter(Mandatory=$false)]
        [switch]$ShowDetails
    )

    try {
        Write-Host "Checking available models..." -ForegroundColor Yellow
        $models = & $global:AdamX.OllamaPath list 2>$null

        if ($models.Count -le 1) {
            Write-Host "No models found." -ForegroundColor Red
            return
        }

        Write-Host "Available models:" -ForegroundColor Green

        if ($ShowDetails) {
            # Show full details
            $models | ForEach-Object { Write-Host $_ -ForegroundColor Cyan }
        } else {
            # Show just the model names
            $models | Select-Object -Skip 1 | ForEach-Object {
                if ($_ -match '^(\S+)') {
                    Write-Host "  $($matches[1])" -ForegroundColor Cyan
                }
            }
        }

        # Show recommended models that aren't installed
        $installedModels = @()
        $models | Select-Object -Skip 1 | ForEach-Object {
            if ($_ -match '^(\S+)') {
                $installedModels += $matches[1]
            }
        }

        $recommendedNotInstalled = @()
        foreach ($category in $global:AdamX.RecommendedModels.Keys) {
            foreach ($model in $global:AdamX.RecommendedModels[$category]) {
                if (-not $installedModels.Contains($model) -and -not $recommendedNotInstalled.Contains($model)) {
                    $recommendedNotInstalled += $model
                }
            }
        }

        if ($recommendedNotInstalled.Count -gt 0) {
            Write-Host "`nRecommended models not installed:" -ForegroundColor Yellow
            foreach ($model in $recommendedNotInstalled) {
                Write-Host "  $model" -ForegroundColor DarkYellow
            }
            Write-Host "Use 'model pull <name>' to install these models." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error listing models" -ForegroundColor Red
    }
}

# Function to pull a model
function Get-AdamXModel {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ModelName
    )

    try {
        Write-Host "Pulling model '$ModelName'..." -ForegroundColor Yellow
        & $global:AdamX.OllamaPath pull $ModelName

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Model '$ModelName' pulled successfully." -ForegroundColor Green
            return $true
        } else {
            Write-Host "Failed to pull model '$ModelName'." -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error pulling model" -ForegroundColor Red
        return $false
    }
}

# Function to delete a model
function Remove-AdamXModel {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ModelName
    )

    try {
        # Check if the model exists
        $modelExists = $false
        $models = & $global:AdamX.OllamaPath list 2>$null | Select-Object -Skip 1
        foreach ($modelLine in $models) {
            if ($modelLine -match "^$ModelName\s") {
                $modelExists = $true
                break
            }
        }

        if (-not $modelExists) {
            Write-Host "Model '$ModelName' not found." -ForegroundColor Red
            return $false
        }

        # Confirm deletion
        $confirm = Read-Host "Are you sure you want to delete model '$ModelName'? (y/n)"
        if ($confirm -ne "y") {
            Write-Host "Deletion cancelled." -ForegroundColor Yellow
            return $false
        }

        Write-Host "Deleting model '$ModelName'..." -ForegroundColor Yellow
        & $global:AdamX.OllamaPath rm $ModelName

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Model '$ModelName' deleted successfully." -ForegroundColor Green

            # If the deleted model was the current model, switch to another available model
            if ($global:AdamX.Model -eq $ModelName) {
                $availableModels = & $global:AdamX.OllamaPath list 2>$null | Select-Object -Skip 1
                if ($availableModels.Count -gt 0) {
                    $firstModel = $availableModels[0] -split '\s+' | Select-Object -First 1
                    $global:AdamX.Model = $firstModel
                    Write-Host "Current model switched to: $firstModel" -ForegroundColor Yellow
                    Save-AdamXConfig
                }
            }

            return $true
        } else {
            Write-Host "Failed to delete model '$ModelName'." -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error deleting model" -ForegroundColor Red
        return $false
    }
}

# Function to set the current model
function Set-AdamXModel {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ModelName
    )

    try {
        # Check if the model exists
        $modelExists = $false
        $models = & $global:AdamX.OllamaPath list 2>$null | Select-Object -Skip 1
        foreach ($modelLine in $models) {
            if ($modelLine -match "^$ModelName\s") {
                $modelExists = $true
                break
            }
        }

        if (-not $modelExists) {
            Write-Host "Model '$ModelName' not found." -ForegroundColor Red
            $pullModel = Read-Host "Would you like to pull this model? (y/n)"
            if ($pullModel -eq "y") {
                $success = Get-AdamXModel -ModelName $ModelName
                if (-not $success) {
                    return $false
                }
            } else {
                return $false
            }
        }

        $global:AdamX.Model = $ModelName
        Save-AdamXConfig
        Write-Host "Current model set to: $ModelName" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error setting model" -ForegroundColor Red
        return $false
    }
}

# Function to manage conversation history
function Get-AdamXHistory {
    param (
        [Parameter(Mandatory=$false)]
        [switch]$Clear
    )

    if ($Clear) {
        $confirm = Read-Host "Are you sure you want to clear the conversation history? (y/n)"
        if ($confirm -eq "y") {
            $global:AdamX.ConversationHistory = @()
            Save-AdamXConfig
            Write-Host "Conversation history cleared." -ForegroundColor Green
        } else {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
        }
        return
    }

    if ($global:AdamX.ConversationHistory.Count -eq 0) {
        Write-Host "No conversation history." -ForegroundColor Yellow
        return
    }

    Write-Host "Conversation History:" -ForegroundColor Green
    $historyIndex = 0
    for ($i = 0; $i -lt $global:AdamX.ConversationHistory.Count; $i += 2) {
        $historyIndex++
        $userMessage = $global:AdamX.ConversationHistory[$i].content
        $assistantMessage = if ($i + 1 -lt $global:AdamX.ConversationHistory.Count) { $global:AdamX.ConversationHistory[$i + 1].content } else { "[No response]" }

        Write-Host "[$historyIndex] User:" -ForegroundColor Cyan
        Write-Host $userMessage -ForegroundColor White
        Write-Host "[$historyIndex] Adam-x:" -ForegroundColor Magenta
        Write-Host $assistantMessage -ForegroundColor Gray
        Write-Host "--------------------------" -ForegroundColor DarkGray
    }
}

# Function to handle user commands
function Invoke-AdamXCommand {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Command
    )

    $commandParts = $Command -split ' '
    $mainCommand = $commandParts[0].ToLower()

    switch ($mainCommand) {
        "help" {
            Write-Host "Available commands:" -ForegroundColor Yellow
            Write-Host "`nCore Commands:" -ForegroundColor White
            Write-Host "  help                - Show this help message" -ForegroundColor Cyan
            Write-Host "  setup               - Configure Adam-x settings" -ForegroundColor Cyan
            Write-Host "  exit                - Exit Adam-x" -ForegroundColor Cyan

            Write-Host "`nCode Assistance:" -ForegroundColor White
            Write-Host "  analyze <file>      - Analyze code in a file" -ForegroundColor Cyan
            Write-Host "  document <file> [output] - Generate documentation for code" -ForegroundColor Cyan
            Write-Host "  explain             - Explain a code snippet (will prompt for code)" -ForegroundColor Cyan
            Write-Host "  improve             - Suggest improvements for code (will prompt for code)" -ForegroundColor Cyan
            Write-Host "  generate <lang>     - Generate code based on description (will prompt for description)" -ForegroundColor Cyan
            Write-Host "  debug               - Debug code (will prompt for code and error)" -ForegroundColor Cyan

            Write-Host "`nModel Management:" -ForegroundColor White
            Write-Host "  model list          - List available models" -ForegroundColor Cyan
            Write-Host "  model pull <name>   - Pull a model from Ollama" -ForegroundColor Cyan
            Write-Host "  model delete <name> - Delete a model" -ForegroundColor Cyan
            Write-Host "  model use <name>    - Set the current model" -ForegroundColor Cyan

            Write-Host "`nConversation:" -ForegroundColor White
            Write-Host "  history             - Show conversation history" -ForegroundColor Cyan
            Write-Host "  history clear       - Clear conversation history" -ForegroundColor Cyan
            Write-Host "  chat <message>      - Chat with history enabled" -ForegroundColor Cyan

            Write-Host ""
            Write-Host "You can also simply type your coding question directly." -ForegroundColor Yellow
            Write-Host "(Note: Direct questions don't use conversation history. Use 'chat' for that.)" -ForegroundColor Yellow
        }
        "setup" {
            Initialize-AdamXSetup
        }
        "analyze" {
            if ($commandParts.Count -lt 2) {
                Write-Host "Usage: analyze <file>" -ForegroundColor Red
                return $true
            }
            $filePath = $commandParts[1]
            Invoke-AdamXCodeAnalysis -CodePath $filePath
        }
        "document" {
            if ($commandParts.Count -lt 2) {
                Write-Host "Usage: document <file> [output]" -ForegroundColor Red
                return $true
            }
            $filePath = $commandParts[1]
            $outputPath = if ($commandParts.Count -ge 3) { $commandParts[2] } else { $null }
            New-AdamXDocumentation -CodePath $filePath -OutputPath $outputPath
        }
        "explain" {
            Write-Host "Enter the code to explain (type 'END' on a new line when finished):" -ForegroundColor Yellow
            $codeLines = @()
            $line = ""
            do {
                $line = Read-Host
                if ($line -ne "END") {
                    $codeLines += $line
                }
            } while ($line -ne "END")

            $code = $codeLines -join "`n"
            Write-Host "Enter the language (e.g., Python, JavaScript, etc.):" -ForegroundColor Yellow
            $language = Read-Host

            Get-AdamXCodeExplanation -Code $code -Language $language
        }
        "improve" {
            Write-Host "Enter the code to improve (type 'END' on a new line when finished):" -ForegroundColor Yellow
            $codeLines = @()
            $line = ""
            do {
                $line = Read-Host
                if ($line -ne "END") {
                    $codeLines += $line
                }
            } while ($line -ne "END")

            $code = $codeLines -join "`n"
            Write-Host "Enter the language (e.g., Python, JavaScript, etc.):" -ForegroundColor Yellow
            $language = Read-Host

            Get-AdamXCodeImprovement -Code $code -Language $language
        }
        "generate" {
            if ($commandParts.Count -lt 2) {
                Write-Host "Usage: generate <language>" -ForegroundColor Red
                return $true
            }

            $language = $commandParts[1]
            Write-Host "Enter a description of the code you want to generate:" -ForegroundColor Yellow
            $description = Read-Host

            Write-Host "Enter output file path (or press Enter to display in console):" -ForegroundColor Yellow
            $outputPath = Read-Host
            if ([string]::IsNullOrWhiteSpace($outputPath)) {
                $outputPath = $null
            }

            New-AdamXCode -Description $description -Language $language -OutputPath $outputPath
        }
        "debug" {
            Write-Host "Enter the code to debug (type 'END' on a new line when finished):" -ForegroundColor Yellow
            $codeLines = @()
            $line = ""
            do {
                $line = Read-Host
                if ($line -ne "END") {
                    $codeLines += $line
                }
            } while ($line -ne "END")

            $code = $codeLines -join "`n"
            Write-Host "Enter the language (e.g., Python, JavaScript, etc.):" -ForegroundColor Yellow
            $language = Read-Host

            Write-Host "Enter the error message (if any):" -ForegroundColor Yellow
            $errorMsg = Read-Host

            Debug-AdamXCode -Code $code -Language $language -ErrorMsg $errorMsg
        }
        "model" {
            if ($commandParts.Count -lt 2) {
                Write-Host "Usage: model <list|pull|delete|use> [name]" -ForegroundColor Red
                return $true
            }

            $modelCommand = $commandParts[1].ToLower()
            switch ($modelCommand) {
                "list" {
                    $showDetails = $false
                    if ($commandParts.Count -ge 3 -and $commandParts[2].ToLower() -eq "details") {
                        $showDetails = $true
                    }
                    Get-AdamXModels -ShowDetails:$showDetails
                }
                "pull" {
                    if ($commandParts.Count -lt 3) {
                        Write-Host "Usage: model pull <name>" -ForegroundColor Red
                        return $true
                    }
                    $modelName = $commandParts[2]
                    Get-AdamXModel -ModelName $modelName
                }
                "delete" {
                    if ($commandParts.Count -lt 3) {
                        Write-Host "Usage: model delete <name>" -ForegroundColor Red
                        return $true
                    }
                    $modelName = $commandParts[2]
                    Remove-AdamXModel -ModelName $modelName
                }
                "use" {
                    if ($commandParts.Count -lt 3) {
                        Write-Host "Usage: model use <name>" -ForegroundColor Red
                        return $true
                    }
                    $modelName = $commandParts[2]
                    Set-AdamXModel -ModelName $modelName
                }
                default {
                    Write-Host "Unknown model command: $modelCommand" -ForegroundColor Red
                    Write-Host "Available commands: list, pull, delete, use" -ForegroundColor Yellow
                }
            }
        }
        "history" {
            $clearHistory = $false
            if ($commandParts.Count -ge 2 -and $commandParts[1].ToLower() -eq "clear") {
                $clearHistory = $true
            }
            Get-AdamXHistory -Clear:$clearHistory
        }
        "chat" {
            if ($commandParts.Count -lt 2) {
                Write-Host "Usage: chat <message>" -ForegroundColor Red
                return $true
            }

            $message = $Command.Substring("chat ".Length)
            $response = Invoke-AdamXAI -Prompt $message -UseHistory
            Write-Host $response -ForegroundColor Green
        }
        "exit" {
            return $false
        }
        default {
            # Treat as a direct question to the AI
            $response = Invoke-AdamXAI -Prompt $Command
            Write-Host $response -ForegroundColor Green
        }
    }

    return $true
}

# Main function to run Adam-x
function Start-AdamX {
    Write-Host "Initializing Adam-x..." -ForegroundColor Cyan

    # Check if configuration exists, otherwise run setup
    $configExists = Initialize-AdamXConfig
    Write-Host "Configuration exists: $configExists" -ForegroundColor Cyan

    if (-not $configExists) {
        Write-Host "Running setup..." -ForegroundColor Cyan
        Initialize-AdamXSetup
    }

    # Show welcome message
    Show-AdamXWelcome

    # Main interaction loop
    $continue = $true
    while ($continue) {
        Write-Host "Adam-x> " -NoNewline -ForegroundColor Magenta
        $userInput = Read-Host

        if (-not [string]::IsNullOrWhiteSpace($userInput)) {
            $continue = Invoke-AdamXCommand -Command $userInput
        }
    }

    Write-Host "Goodbye! Adam-x is shutting down." -ForegroundColor Cyan
}

# Start Adam-x if the script is being run directly
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    Write-Host "Starting Adam-x..." -ForegroundColor Cyan
    try {
        Start-AdamX
    } catch {
        Write-Host "Error starting Adam-x: $_" -ForegroundColor Red
    }
    Write-Host "Script execution completed." -ForegroundColor Cyan
}

# Export functions for module usage
# This allows the script to be imported as a module
if ($MyInvocation.InvocationName -ne $MyInvocation.MyCommand.Name) {
    Export-ModuleMember -Function Start-AdamX, Invoke-AdamXCommand, Invoke-AdamXCodeAnalysis, New-AdamXDocumentation,
        New-AdamXExplanation, New-AdamXImprovement, New-AdamXCode, New-AdamXDebug, Get-OllamaModels,
        Invoke-OllamaModelPull, Remove-OllamaModel, Set-AdamXModel
}
