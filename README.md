# CodeMCP

![Version](https://img.shields.io/badge/version-0.1.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

A simple CLI tool that initializes git repositories with codemcp.toml configuration.

## Installation

Install to /usr/local/bin (requires administrator privileges) or anywhere else in your $PATH:

```bash
sudo cp codemcp.sh /usr/local/bin/codemcp
sudo chmod +x /usr/local/bin/codemcp

# Verify installation
which codemcp
codemcp --version
```

## Usage

```bash
# Initialize in current directory
codemcp init

# Create a new project directory
codemcp init my-project

# Show help
codemcp --help
```

## Requirements

- Git
