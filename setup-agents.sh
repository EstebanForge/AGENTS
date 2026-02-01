#!/usr/bin/env bash

# Setup Agent AGENTS.md Symlinks
# Portable across macOS and Linux with automatic path detection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CENTRAL_AGENTS="${SCRIPT_DIR}/AGENTS.md"

# Agent AGENTS.md paths mapping (core agents - always available)
declare -A AGENTS_PATHS=(
    ["gemini"]="$HOME/.gemini/GEMINI.md"
    ["qwen"]="$HOME/.qwen/AGENTS.md"
    ["opencode"]="$HOME/.config/opencode/AGENTS.md"
    ["claude"]="$HOME/.claude/CLAUDE.md"
    ["amp"]="$HOME/.config/amp/AGENTS.md"
    ["codex"]="$HOME/.codex/AGENTS.md"
    ["copilot"]="$HOME/.copilot/AGENTS.md"
    ["factory"]="$HOME/.factory/AGENTS.md"
    ["goose"]="$HOME/.config/goose/AGENTS.md"
    ["kilocode"]="$HOME/.kilocode/rules/AGENTS.md"
    ["cline"]="$HOME/Documents/Cline/Rules/AGENTS.md"
    ["cline_alt"]="$HOME/Cline/Rules/AGENTS.md"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Path detection for extra agents (VSCode, Windsurf)
detect_extra_agents() {
    local paths_found=0

    # Check for VSCode - macOS
    if [[ -f "$HOME/Library/Application Support/Code/User/prompts/AGENTS.md.instructions.md" ]]; then
        AGENTS_PATHS["vscode"]="$HOME/Library/Application Support/Code/User/prompts/AGENTS.md.instructions.md"
        paths_found=$((paths_found + 1))
    # Check for VSCode - Linux
    elif [[ -f "$HOME/.config/Code/User/prompts/AGENTS.md.instructions.md" ]]; then
        AGENTS_PATHS["vscode"]="$HOME/.config/Code/User/prompts/AGENTS.md.instructions.md"
        paths_found=$((paths_found + 1))
    fi

    # Check for Windsurf
    if [[ -f "$HOME/.codeium/windsurf/memories/global_rules.md" ]]; then
        AGENTS_PATHS["windsurf"]="$HOME/.codeium/windsurf/memories/global_rules.md"
        paths_found=$((paths_found + 1))
    fi

    log_info "Detected $paths_found extra agent paths"
}

# Detect all agent paths (core + extra)
detect_agent_paths() {
    detect_extra_agents
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_central_file() {
    if [[ ! -f "$CENTRAL_AGENTS" ]]; then
        log_error "Central AGENTS.md does not exist: $CENTRAL_AGENTS"
        exit 1
    fi
}

create_symlinks() {
    check_central_file
    detect_agent_paths

    local total=0
    local success=0
    local skipped=0

    log_info "Creating symlinks to central AGENTS.md..."

    for key in "${!AGENTS_PATHS[@]}"; do
        local target_path="${AGENTS_PATHS[$key]}"
        total=$((total + 1))

        if [[ -z "$target_path" ]]; then
            log_warning "Empty target path for $key, skipping"
            skipped=$((skipped + 1))
            continue
        fi

        local parent_dir
        parent_dir=$(dirname "$target_path")

        if [[ ! -d "$parent_dir" ]]; then
            log_info "Creating parent directory for $key: $parent_dir"
            mkdir -p "$parent_dir"
        fi

        if [[ -L "$target_path" ]]; then
            log_warning "Already symlinked: $target_path"
            skipped=$((skipped + 1))
            continue
        fi

        if [[ -f "$target_path" ]]; then
            if [[ ! -L "$target_path" ]]; then
                mv "$target_path" "${target_path}.backup.$(date +%Y%m%d_%H%M%S)"
                log_info "Backed up: $target_path"
            fi
            ln -sf "$CENTRAL_AGENTS" "$target_path"
            log_success "Linked $key -> $target_path"
            success=$((success + 1))
        else
            log_warning "Target path does not exist for $key: $target_path"
            skipped=$((skipped + 1))
        fi
    done

    echo ""
    log_info "Summary:"
    echo "  Total agents: $total"
    echo "  Successful:   $success"
    echo "  Skipped:     $skipped"
}

remove_symlinks() {
    log_info "Removing symlinks..."

    local total=0
    local removed=0

    for key in "${!AGENTS_PATHS[@]}"; do
        local target_path="${AGENTS_PATHS[$key]}"
        total=$((total + 1))

        if [[ -z "$target_path" ]]; then
            continue
        fi

        if [[ -L "$target_path" ]]; then
            rm "$target_path"
            log_success "Removed symlink: $target_path"

            local latest_backup
            latest_backup=$(find "$(dirname "${target_path}")" -maxdepth 1 -name "$(basename "${target_path}").backup.*" 2>/dev/null | sort -r | head -n1)
            if [[ -n "$latest_backup" ]]; then
                mv "$latest_backup" "$target_path"
                log_info "Restored backup: $latest_backup"
            fi
            removed=$((removed + 1))
        else
            log_warning "Not a symlink or does not exist: $target_path"
        fi
    done

    echo ""
    log_info "Removed $removed symlink(s) out of $total checked"
}

show_status() {
    log_info "Current symlink status:"

    for key in "${!AGENTS_PATHS[@]}"; do
        local target_path="${AGENTS_PATHS[$key]}"
        local status="Does not exist"

        if [[ -L "$target_path" ]]; then
            local real_path
            real_path=$(readlink "$target_path")
            if [[ "$real_path" == "$CENTRAL_AGENTS" ]]; then
                status="Symlinked -> $CENTRAL_AGENTS"
            else
                status="Symlinked -> $real_path (not central)"
            fi
        elif [[ -f "$target_path" ]]; then
            status="Regular file (not symlinked)"
        fi

        printf "  %-12s %s\n" "$key:" "$status"
    done
}

show_help() {
    cat <<EOF
Setup Agent AGENTS.md Symlinks - Centralize Agent Configuration Files

Usage: $(basename "$0") [command]

Commands:
  link      Create symlinks from all agent AGENTS.md files to central AGENTS.md
  unlink    Remove all symlinks and restore original files
  status    Show current symlink status for all agents
  help      Show this help message

Central AGENTS.md: ${CENTRAL_AGENTS}

Supported Agents (14 total):
  Core agents (always available):
    Gemini   ~/.gemini/GEMINI.md
    Qwen     ~/.qwen/AGENTS.md
    OpenCode ~/.config/opencode/AGENTS.md
    Claude    ~/.claude/CLAUDE.md
    Amp       ~/.config/amp/AGENTS.md
    Codex     ~/.codex/AGENTS.md
    Copilot   ~/.copilot/AGENTS.md
    Factory   ~/.factory/AGENTS.md
    Goose     ~/.config/goose/AGENTS.md
    Kilo Code ~/.kilocode/rules/AGENTS.md
    Cline     ~/Documents/Cline/Rules/AGENTS.md
    Cline Alt ~/Cline/Rules/AGENTS.md

  Extra agents (detected if available):
    VSCode    ~/Library/Application Support/Code/User/prompts/AGENTS.md.instructions.md (macOS)
    VSCode    ~/.config/Code/User/prompts/AGENTS.md.instructions.md (Linux)
    Windsurf  ~/.codeium/windsurf/memories/global_rules.md

Notes:
  - Claude uses CLAUDE.md (not AGENTS.md)
  - Cline has two possible locations; both checked
  - Extra agents (VSCode, Windsurf) detected automatically at runtime
  - Script creates parent directories if they do not exist
  - Backs up existing files before creating symlinks
  - Unlinking restores backups automatically
  - Fully portable - no hardcoded OS-specific paths
EOF
}

main() {
    case "${1:-}" in
        link)
            create_symlinks
            ;;
        unlink)
            remove_symlinks
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
