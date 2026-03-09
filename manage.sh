#!/usr/bin/env bash

# Agents Centralization Manager (Unified)
# Synchronizes both AGENTS.md instructions and skills folders.
# Supports local symlinking and construct-cli direct copying.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CENTRAL_AGENTS="${SCRIPT_DIR}/AGENTS.md"
CENTRAL_SKILLS="${SCRIPT_DIR}/skills"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Unified Agent Mapping
# Format: "InstructionsPath|SkillsPath" (Use "-" if not applicable)
# Note: Gemini, Codex, and Opencode support the emerging ~/.agents/skills standard
# and do not need separate skills mapping.
declare -A AGENTS=(
    # --- Standard & Standard-Supporting Agents ---
    ["Standard"]="${HOME}/.agents/AGENTS.md|${HOME}/.agents/skills"
    ["Gemini"]="${HOME}/.gemini/GEMINI.md|-"
    ["Codex"]="${HOME}/.codex/AGENTS.md|-"
    ["Opencode"]="${HOME}/.config/opencode/AGENTS.md|-"

    # --- Specific Agents ---
    ["Claude"]="${HOME}/.claude/CLAUDE.md|${HOME}/.claude/skills"
    ["Qwen"]="${HOME}/.qwen/QWEN.md|${HOME}/.qwen/skills"
    ["Amp"]="${HOME}/.config/amp/AGENTS.md|${HOME}/.config/amp/skills"
    ["Copilot"]="${HOME}/.copilot/copilot-instructions.md|${HOME}/.copilot/skills"
    ["Factory"]="${HOME}/.factory/AGENTS.md|${HOME}/.factory/skills"
    ["Goose"]="${HOME}/.config/goose/AGENTS.md|${HOME}/.config/goose/skills"
    ["Kilocode"]="${HOME}/.kilocode/rules/AGENTS.md|${HOME}/.kilocode/skills"
    ["Cline"]="${HOME}/Documents/Cline/Rules/AGENTS.md|${HOME}/.cline/skills"
    ["Pi"]="${HOME}/.pi/agent/AGENTS.md|${HOME}/.pi/agent/skills"
)

# Path detection for extra agents (VSCode, Windsurf)
detect_extra_agents() {
    # Check for VSCode
    local vscode_path=""
    if [[ -f "$HOME/Library/Application Support/Code/User/prompts/AGENTS.md.instructions.md" ]]; then
        vscode_path="$HOME/Library/Application Support/Code/User/prompts/AGENTS.md.instructions.md"
    elif [[ -f "$HOME/.config/Code/User/prompts/AGENTS.md.instructions.md" ]]; then
        vscode_path="$HOME/.config/Code/User/prompts/AGENTS.md.instructions.md"
    fi
    if [[ -n "${vscode_path}" ]]; then
        AGENTS["VSCode"]="${vscode_path}|-"
    fi

    # Check for Windsurf
    if [[ -f "$HOME/.codeium/windsurf/memories/global_rules.md" ]]; then
        AGENTS["Windsurf"]="$HOME/.codeium/windsurf/memories/global_rules.md|-"
    fi
}

# Path detection for construct-cli agents
detect_construct_agents() {
    local construct_config="$HOME/.config/construct-cli/config.toml"
    if [[ ! -f "$construct_config" ]]; then return 0; fi

    local construct_home="$HOME/.config/construct-cli/home"
    local construct_agents_dir="$construct_home/.agents"

    # 1. Surgical synchronization: only delete central components, not the whole folder
    mkdir -p "$construct_agents_dir"
    rm -f "$construct_agents_dir/AGENTS.md"
    rm -rf "$construct_agents_dir/skills"

    # 2. COPY contents from the repo (except .git) to the mounted home
    # Note: We don't use --delete here to preserve extra data in the target folder
    log_info "Synchronizing agents repository to construct-cli home (surgical mode)..."
    if command -v rsync >/dev/null 2>&1; then
        rsync -a --exclude='.git/' "$SCRIPT_DIR/" "$construct_agents_dir/"
    else
        cp -r "$SCRIPT_DIR/." "$construct_agents_dir/"
        rm -rf "$construct_agents_dir/.git"
    fi
    log_success "Repository synced to $construct_agents_dir"

    # Add construct variants
    AGENTS["construct_Standard"]="${construct_agents_dir}/AGENTS.md|${construct_agents_dir}/skills"
    AGENTS["construct_Claude"]="${construct_home}/.claude/CLAUDE.md|${construct_home}/.claude/skills"
    AGENTS["construct_Gemini"]="${construct_home}/.gemini/GEMINI.md|-"
    AGENTS["construct_Qwen"]="${construct_home}/.qwen/QWEN.md|${construct_home}/.qwen/skills"
    AGENTS["construct_Opencode"]="${construct_home}/.config/opencode/AGENTS.md|-"
    AGENTS["construct_Amp"]="${construct_home}/.config/amp/AGENTS.md|${construct_home}/.config/amp/skills"
    AGENTS["construct_Codex"]="${construct_home}/.codex/AGENTS.md|-"
    AGENTS["construct_Copilot"]="${construct_home}/.copilot/copilot-instructions.md|${construct_home}/.copilot/skills"
    AGENTS["construct_Droid"]="${construct_home}/.factory/AGENTS.md|${construct_home}/.factory/skills"
    AGENTS["construct_Goose"]="${construct_home}/.config/goose/AGENTS.md|${construct_home}/.config/goose/skills"
    AGENTS["construct_Kilocode"]="${construct_home}/.kilocode/rules/AGENTS.md|${construct_home}/.kilocode/skills"
    AGENTS["construct_Cline"]="${construct_home}/.cline/AGENTS.md|${construct_home}/.cline/skills"
    AGENTS["construct_Pi"]="${construct_home}/.pi/agent/AGENTS.md|${construct_home}/.pi/agent/skills"

    log_info "construct-cli detected: added 13 agent paths (Internal Copying Mode)"
}

# Walk up from a path until we find an existing directory
find_existing_ancestor() {
    local dir; dir="$(dirname "$1")"
    while [[ ! -d "$dir" ]]; do dir="$(dirname "$dir")"; done
    echo "$dir"
}

# Backup existing path
backup_path() {
    local path=$1
    local backup="${path}.backup.$(date +%Y%m%d_%H%M%S)"
    if [[ -e "${path}" && ! -L "${path}" ]]; then
        mv "${path}" "${backup}"
        log_info "  ↳ Backed up to: ${backup}"
        return 0
    fi
    return 1
}

# Unified Link/Copy operation
manage_agent() {
    local name=$1; local paths=$2; local force=${3:-0}
    local agent_md="${paths%%|*}"; local skills_path="${paths#*|}"

    # --- Instructions (AGENTS.md) ---
    if [[ "${agent_md}" != "-" ]]; then
        local target="${agent_md}"
        if [[ "${name}" == construct_* ]]; then
            # Construct Mode: Direct Copy
            if [[ "${target}" != "${HOME}/.config/construct-cli/home/.agents/"* ]]; then
                mkdir -p "$(dirname "${target}")"
                cp -f "${CENTRAL_AGENTS}" "${target}"
                log_success "${name}: Updated AGENTS.md"
            else
                log_info "${name}: AGENTS.md is source"
            fi
        else
            # Standard Mode: Symlink
            local ancestor; ancestor="$(find_existing_ancestor "${target}")"
            if [[ "${ancestor}" != "${HOME}" && "${ancestor}" != "/" ]]; then
                local needs_link=1
                if [[ -L "${target}" ]]; then
                    if [[ "$(readlink "${target}")" == "${CENTRAL_AGENTS}" ]]; then
                        if [[ "${force}" == "1" ]]; then rm "${target}"; else needs_link=0; log_warning "${name}: AGENTS.md already linked"; fi
                    else rm "${target}"; fi
                elif [[ -f "${target}" ]]; then backup_path "${target}"; fi

                if [[ "${needs_link}" == "1" ]]; then
                    mkdir -p "$(dirname "${target}")"; ln -s "${CENTRAL_AGENTS}" "${target}"
                    log_success "${name}: Linked AGENTS.md"
                fi
            else log_info "${name}: Agent not installed (skipped AGENTS.md)"; fi
        fi
    fi

    # --- Skills ---
    if [[ "${skills_path}" != "-" ]]; then
        local target="${skills_path}"
        if [[ "${name}" == construct_* ]]; then
            # Construct Mode: Direct Copy
            if [[ "${target}" != "${HOME}/.config/construct-cli/home/.agents/"* ]]; then
                mkdir -p "$(dirname "${target}")"
                if command -v rsync >/dev/null 2>&1; then
                    rsync -a --delete "${CENTRAL_SKILLS}/" "${target}/"
                else
                    rm -rf "${target}" && cp -r "${CENTRAL_SKILLS}" "${target}"
                fi
                log_success "${name}: Synchronized skills"
            else
                log_info "${name}: Skills are source"
            fi
        else
            # Standard Mode: Symlink
            local ancestor; ancestor="$(find_existing_ancestor "${target}")"
            if [[ "${ancestor}" != "${HOME}" && "${ancestor}" != "/" ]]; then
                local needs_link=1
                if [[ -L "${target}" ]]; then
                    if [[ "$(readlink "${target}")" == "${CENTRAL_SKILLS}" ]]; then
                        if [[ "${force}" == "1" ]]; then rm "${target}"; else needs_link=0; log_warning "${name}: Skills already linked"; fi
                    else rm "${target}"; fi
                elif [[ -d "${target}" ]]; then backup_path "${target}"; fi

                if [[ "${needs_link}" == "1" ]]; then
                    mkdir -p "$(dirname "${target}")"; ln -s "${CENTRAL_SKILLS}" "${target}"
                    log_success "${name}: Linked skills"
                fi
            else log_info "${name}: Agent not installed (skipped skills)"; fi
        fi
    fi
}

# Unified Unlink/Restore operation
unmanage_agent() {
    local name=$1; local paths=$2
    local agent_md="${paths%%|*}"; local skills_path="${paths#*|}"

    for target in "${agent_md}" "${skills_path}"; do
        if [[ "${target}" == "-" ]]; then continue; fi
        if [[ "${name}" == construct_* && "${target}" == "${HOME}/.config/construct-cli/home/.agents/"* ]]; then continue; fi

        if [[ -L "${target}" ]]; then
            rm "${target}"
            log_success "${name}: Removed symlink $(basename "${target}")"
            local backup; backup="$(find "$(dirname "${target}")" -maxdepth 1 -name "$(basename "${target}").backup.*" 2>/dev/null | sort -r | head -n1)"
            if [[ -n "${backup}" ]]; then mv "${backup}" "${target}"; log_info "  ↳ Restored backup"; fi
        elif [[ -e "${target}" && "${name}" == construct_* ]]; then
            rm -rf "${target}"
            log_success "${name}: Removed copy $(basename "${target}")"
        fi
    done
}

# Get sorted agent names: regular first, then construct_
get_sorted_agents() {
    local all_agents; all_agents=$(echo "${!AGENTS[@]}" | tr ' ' '\n')
    # Sort regular agents alphabetically, then construct_ agents alphabetically
    {
        echo "${all_agents}" | grep -v "^construct_" | sort
        echo "${all_agents}" | grep "^construct_" | sort
    }
}

# Main Commands
cmd_link() {
    local force=${1:-0}
    detect_extra_agents; detect_construct_agents

    log_info "Managing Agent Configuration & Skills..."
    for name in $(get_sorted_agents); do
        manage_agent "${name}" "${AGENTS[$name]}" "${force}"
    done
    log_success "Synchronization complete."
}

cmd_unlink() {
    detect_extra_agents; detect_construct_agents
    log_info "Unlinking and restoring original states..."
    for name in $(get_sorted_agents); do
        unmanage_agent "${name}" "${AGENTS[$name]}"
    done
    log_success "Restoration complete."
}

cmd_status() {
    detect_extra_agents; detect_construct_agents
    log_info "Agent Synchronization Status"
    printf "  %-20s %-20s %-20s
" "AGENT" "INSTRUCTIONS" "SKILLS"
    echo "  --------------------------------------------------------------------------------"
    for name in $(get_sorted_agents); do
        local paths="${AGENTS[$name]}"; local md="${paths%%|*}"; local sk="${paths#*|}"
        local md_s="-"; local sk_s="-"
        if [[ "${md}" != "-" ]]; then
            if [[ -L "${md}" ]]; then md_s="${GREEN}Linked${NC}"; elif [[ -f "${md}" ]]; then md_s="${YELLOW}File${NC}"; else md_s="Missing"; fi
            if [[ "${name}" == construct_* && ! -L "${md}" && -f "${md}" ]]; then md_s="${GREEN}Copied${NC}"; fi
        fi
        if [[ "${sk}" != "-" ]]; then
            if [[ -L "${sk}" ]]; then sk_s="${GREEN}Linked${NC}"; elif [[ -d "${sk}" ]]; then sk_s="${YELLOW}Dir${NC}"; else sk_s="Missing"; fi
            if [[ "${name}" == construct_* && ! -L "${sk}" && -d "${sk}" ]]; then sk_s="${GREEN}Copied${NC}"; fi
        fi
        printf "  %-20s %-30b %-30b
" "${name}" "${md_s}" "${sk_s}"
    done
}
# Interactive Menu
interactive_menu() {
    echo -e "${BLUE}=== Agents Centralization Manager ===${NC}"
    echo "Please choose an action:"
    options=("Sync (Smart)" "Force Sync (Overwrite All)" "Restore (Unlink)" "Status" "Quit")
    select opt in "${options[@]}"; do
        case $opt in
            "Sync (Smart)") cmd_link 0; break ;;
            "Force Sync (Overwrite All)") cmd_link 1; break ;;
            "Restore (Unlink)") cmd_unlink; break ;;
            "Status") cmd_status; break ;;
            "Quit") exit 0 ;;
            *) echo "Invalid option $REPLY" ;;
        esac
    done
}

# Entry Point
if [[ $# -eq 0 ]]; then
    interactive_menu
else
    FORCE=0
    COMMAND=""
    for arg in "$@"; do
        case $arg in
            -f|--force) FORCE=1 ;;
            link|unlink|status) COMMAND=$arg ;;
        esac
    done

    case "${COMMAND}" in
        link) cmd_link $FORCE ;;
        unlink) cmd_unlink ;;
        status) cmd_status ;;
        *) echo "Usage: $0 {link|unlink|status} [-f|--force]"; exit 1 ;;
    esac
fi

