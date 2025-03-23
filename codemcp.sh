#!/usr/bin/env bash

# codemcp
# CLI tool for codemcp operations

set -e

# Script version
VERSION="0.1.0"

# Show help message
show_help() {
  cat << EOF
codemcp v${VERSION}

Usage: codemcp [command] [options]

A tool for CodeMCP operations.

Commands:
  init         Initialize a git repository with codemcp.toml configuration
  help         Show this help message

Options:
  -h, --help     Show this help message and exit
  -v, --version  Show version information and exit

EOF
}

# Show command help message
show_command_help() {
  local command="$1"
  
  case "$command" in
    init)
      cat << EOF
codemcp init - Initialize a git repository with codemcp.toml

Usage: codemcp init [project_name] [options]

Arguments:
  project_name   Optional. If provided, creates a new directory with this name
                 and initializes the project there. If not provided, 
                 initializes in the current directory.

This command:
  1. Creates a new directory (if project_name is provided)
  2. Initializes a git repository (if not already initialized)
  3. Creates a codemcp.toml configuration file from template
  4. Commits the codemcp.toml file with "init: codemcp" message

Options:
  -h, --help     Show this help message and exit

EOF
      ;;
    *)
      show_help
      ;;
  esac
}

# Show version
show_version() {
  echo "codemcp v${VERSION}"
}

# Colors for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print colored message
print_message() {
  local color=$1
  local message=$2
  echo -e "${color}${message}${NC}"
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Create codemcp.toml template
create_codemcp_template() {
  local project_name="${1:-My Project}"
  
  # Convert project name to title case for display
  local display_name="$project_name"
  if [[ "$display_name" == "My Project" ]]; then
    display_name="My Project"
  else
    # Keep original name but capitalize first letter of each word
    display_name=$(echo "$display_name" | sed -e 's/\b\(.\)/\u\1/g')
  fi
  
  cat > codemcp.toml << EOL
project_prompt = """
Before beginning work on this feature, write "Hello, World!". Do this only once.
"""
EOL
  print_message "$GREEN" "✓ Created codemcp.toml template"
}

# Initialize repository
cmd_init() {
  local project_name=""
  
  # Parse init command arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_command_help "init"
        exit 0
        ;;
      -*)
        print_message "$RED" "Error: Unknown option $1 for init command"
        show_command_help "init"
        exit 1
        ;;
      *)
        # First non-option argument is the project name
        if [ -z "$project_name" ]; then
          project_name="$1"
        else
          print_message "$RED" "Error: Unexpected argument $1"
          show_command_help "init"
          exit 1
        fi
        shift
        ;;
    esac
  done

  # Check if git is installed
  if ! command_exists git; then
    print_message "$RED" "Error: Git is not installed. Please install git and try again."
    exit 1
  fi
  
  # Handle project directory creation if project name is provided
  if [ -n "$project_name" ]; then
    # Check if directory already exists
    if [ -d "$project_name" ]; then
      print_message "$RED" "Error: Directory '$project_name' already exists"
      exit 1
    fi
    
    print_message "$YELLOW" "→ Creating project directory: $project_name"
    mkdir -p "$project_name"
    cd "$project_name"
    print_message "$GREEN" "✓ Created and entered project directory"
  fi

  # Check if git is already initialized
  if [ -d ".git" ]; then
    print_message "$YELLOW" "ℹ Git repository already initialized"
  else
    print_message "$YELLOW" "→ Initializing git repository..."
    git init
    print_message "$GREEN" "✓ Git repository initialized"
  fi

  # Create codemcp.toml if it doesn't exist
  if [ -f "codemcp.toml" ]; then
    print_message "$YELLOW" "ℹ codemcp.toml already exists"
  else
    create_codemcp_template "$project_name"
  fi

  # Check if there are changes to commit
  if git status --porcelain | grep -q "codemcp.toml"; then
    print_message "$YELLOW" "→ Committing codemcp.toml..."
    git add codemcp.toml
    git commit -m "init: codemcp"
    print_message "$GREEN" "✓ Committed codemcp.toml"
  else
    print_message "$YELLOW" "ℹ No changes to commit"
  fi

  # Print summary
  if [ -n "$project_name" ]; then
    print_message "$GREEN" "✓ Project '$project_name' initialized successfully!"
  else
    print_message "$GREEN" "✓ Initialization complete!"
  fi
}

# Main function
main() {
  # No arguments, show help
  if [ $# -eq 0 ]; then
    show_help
    exit 0
  fi

  # Parse command
  case "$1" in
    init)
      shift
      cmd_init "$@"
      ;;
    help)
      shift
      if [ $# -eq 0 ]; then
        show_help
      else
        show_command_help "$1"
      fi
      exit 0
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    -v|--version)
      show_version
      exit 0
      ;;
    *)
      print_message "$RED" "Error: Unknown command $1"
      show_help
      exit 1
      ;;
  esac
}

# Run main with all arguments
main "$@"
