# Adam-x: PhD-Level AI Coding Assistant

Adam-x is a powerful, terminal-based AI coding assistant that provides PhD-level expertise for your programming tasks. It lives in your terminal and is always ready to help with coding problems, analysis, documentation, and more.

This enhanced version uses Ollama as its AI backend, providing completely offline operation with the power of open-source large language models.

## Features

### Core Features
- **Code Analysis**: Get expert analysis of your code with suggestions for improvements
- **Documentation Generation**: Automatically generate comprehensive documentation for your code
- **Code Explanation**: Get detailed explanations of complex code
- **Code Generation**: Generate high-quality code based on your descriptions
- **Debugging Assistance**: Get help identifying and fixing bugs in your code
- **Best Practices**: Learn about coding best practices and patterns
- **Direct Q&A**: Ask any coding-related question and get expert answers
- **Offline Operation**: Works completely offline using Ollama

### Advanced Features
- **Language-Specific Models**: Automatically uses specialized models for different programming languages
- **Model Management**: Commands to pull, list, and delete Ollama models
- **Conversation History**: Maintain context across multiple interactions
- **Robust Error Handling**: Automatically recovers from common issues
- **Smart Prompts**: Optimized prompts for different coding tasks

## Requirements

- Windows PowerShell 5.1 or later
- [Ollama](https://ollama.ai/download) installed on your system

## Installation

### Prerequisites

1. Install [Ollama](https://ollama.ai/download) if you haven't already
   - Ollama provides the AI backend for Adam-x
   - It runs locally on your machine, ensuring privacy and offline operation

2. Pull a coding-focused model (any of these recommended models):
   - For general coding: `codellama`, `wizardcoder`, or `deepseek-coder`
   - For specific languages: `codellama:python`, `codellama:javascript`, etc.

```powershell
# Example: Pull the CodeLlama model
& "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe" pull codellama

# Or a smaller model if you have limited resources
& "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe" pull tinyllama
```

### Installation Steps

1. Clone or download this repository to your local machine

2. Run the installation script:

```powershell
.\Install-AdamX.ps1
```

3. Restart your PowerShell terminal or reload your profile:

```powershell
. $PROFILE
```

4. Run Adam-x:

```powershell
adam-x
```

5. On first run, you'll be guided through setup to:
   - Configure your Ollama server URL (default is http://localhost:11434)
   - Select a model from your installed Ollama models
   - If your preferred model isn't installed, Adam-x will offer to pull it for you

## Usage

Once installed, you can use Adam-x by typing `adam-x` in any PowerShell terminal. This will start the interactive Adam-x session.

### Available Commands

#### Core Commands
- `help` - Show help message with available commands
- `setup` - Configure Adam-x settings
- `exit` - Exit Adam-x

#### Code Assistance
- `analyze <file>` - Analyze code in a file
- `document <file> [output]` - Generate documentation for code
- `explain` - Explain a code snippet (will prompt for code)
- `improve` - Suggest improvements for code (will prompt for code)
- `generate <lang>` - Generate code based on description (will prompt for description)
- `debug` - Debug code (will prompt for code and error)

#### Model Management
- `model list` - List available models
- `model list details` - List available models with detailed information
- `model pull <name>` - Pull a model from Ollama (e.g., `model pull codellama:python`)
- `model delete <name>` - Delete a model
- `model use <name>` - Set the current model

Adam-x will automatically suggest specialized models for different programming languages. For example, when analyzing Python code, it will check if you have a Python-specific model installed and offer to use it.

#### Conversation
- `history` - Show conversation history
- `history clear` - Clear conversation history
- `chat <message>` - Chat with history enabled (maintains context between messages)

You can also simply type your coding question directly (note that direct questions don't use conversation history).

### Examples

```powershell
# Start Adam-x
adam-x

# Analyze a file
Adam-x> analyze C:\path\to\your\code.ps1

# Generate documentation
Adam-x> document C:\path\to\your\code.py C:\path\to\output\docs.md

# Ask a coding question
Adam-x> What's the best way to implement a singleton pattern in Python?

# Use a specialized model for Python
Adam-x> model use codellama:python

# Generate Python code with conversation history
Adam-x> chat Generate a Python class for a binary search tree
# Follow-up question using history
Adam-x> chat How would I add a method to find the minimum value?

# List available models
Adam-x> model list

# Pull a new model
Adam-x> model pull llama3
```

## Customization

Adam-x stores its configuration in `adam-x-config.json` in the installation directory. You can manually edit this file to change settings like:

- `OllamaServer`: Your Ollama server URL (default: "http://localhost:11434")
- `Model`: The AI model to use (default: "tinyllama")
- `Temperature`: Controls randomness in responses (0.0-1.0)
- `MaxTokens`: Maximum length of AI responses
- `MaxHistoryLength`: Maximum number of conversation turns to remember
- `ConversationHistory`: Your saved conversation history

You can also modify the `Adam-x.ps1` script to customize:

- `RecommendedModels`: The list of recommended models for different programming languages
- `SystemPrompts`: The system prompts used for different tasks

## Advanced Features

### Language-Specific Models

Adam-x maintains a list of recommended models for different programming languages and will automatically suggest or use specialized models when working with specific languages. This ensures you get the best possible results for your specific coding tasks.

### Conversation History

The conversation history feature allows Adam-x to maintain context across multiple interactions. This is especially useful when you're working on a complex problem that requires multiple questions and answers. Use the `chat` command to enable history.

### Smart Prompts

Adam-x uses specialized system prompts for different coding tasks, optimized to get the best results from the AI model. For example, the prompt for code generation includes specific instructions to generate well-commented, production-quality code with error handling.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- Powered by [Ollama](https://ollama.ai) and open-source language models
- Created with ❤️ by AI
