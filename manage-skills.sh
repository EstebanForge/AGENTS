#!/usr/bin/env bash

# Skills Centralization Manager
# Symlinks agent skills directories to central ./skills

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CENTRAL_SKILLS="${SCRIPT_DIR}/skills"

# Agent paths to symlink
declare -A AGENTS=(
    ["Standard"]="${HOME}/.agents/skills"
    # NOTE: Disabled — Gemini already reads ~/.agents/skills (the emerging standard path)
    # ["Gemini"]="${HOME}/.gemini/skills"
    # NOTE: Disabled — Codex already reads ~/.agents/skills (the emerging standard path)
    # ["Codex"]="${HOME}/.codex/skills"
    ["Claude"]="${HOME}/.claude/skills"
    # NOTE: Disabled — OpenCode already reads ~/.agents/skills (the emerging standard path)
    # ["Opencode"]="${HOME}/.config/opencode/skills"
    ["Pi"]="${HOME}/.pi/agent/skills"
    ["Amp"]="${HOME}/.config/agents/skills"
    ["Qwen"]="${HOME}/.qwen/skills"
    ["Copilot"]="${HOME}/.copilot/skills"
    ["Cline"]="${HOME}/.cline/skills"
    ["Droid"]="${HOME}/.factory/skills"
    ["Goose"]="${HOME}/.config/goose/skills"
    ["Kilocode"]="${HOME}/.kilocode/skills"
)

# Append construct-cli agent paths when config.toml is present
detect_construct_agents() {
    local construct_config="${HOME}/.config/construct-cli/config.toml"

    if [[ ! -f "${construct_config}" ]]; then
        return 0
    fi

    local construct_home="${HOME}/.config/construct-cli/home"

    AGENTS["construct_Standard"]="${construct_home}/.agents/skills"
    # NOTE: Disabled — Gemini already reads ~/.agents/skills (the emerging standard path)
    # AGENTS["construct_Gemini"]="${construct_home}/.gemini/skills"
    AGENTS["construct_Claude"]="${construct_home}/.claude/skills"
    AGENTS["construct_Amp"]="${construct_home}/.config/amp/skills"
    AGENTS["construct_Qwen"]="${construct_home}/.qwen/skills"
    AGENTS["construct_Copilot"]="${construct_home}/.copilot/skills"
    # NOTE: Disabled — OpenCode already reads ~/.agents/skills (the emerging standard path)
    # AGENTS["construct_Opencode"]="${construct_home}/.config/opencode/skills"
    AGENTS["construct_Cline"]="${construct_home}/.cline/skills"
    # NOTE: Disabled — Codex already reads ~/.agents/skills (the emerging standard path)
    # AGENTS["construct_Codex"]="${construct_home}/.codex/skills"
    AGENTS["construct_Droid"]="${construct_home}/.factory/skills"
    AGENTS["construct_Goose"]="${construct_home}/.config/goose/skills"
    AGENTS["construct_Kilocode"]="${construct_home}/.kilocode/skills"
    AGENTS["construct_Pi"]="${construct_home}/.pi/agent/skills"

    echo "  construct-cli detected: added 12 agent paths from ${construct_home}"
}

# Create central skills directory if missing
ensure_central_skills() {
    if [[ ! -d "${CENTRAL_SKILLS}" ]]; then
        mkdir -p "${CENTRAL_SKILLS}"
        echo "✓ Created central skills directory: ${CENTRAL_SKILLS}"
    fi
}

# Backup existing path
backup_path() {
    local path=$1
    local backup
    backup="${path}.backup.$(date +%Y%m%d_%H%M%S)"

    if [[ -e "${path}" && ! -L "${path}" ]]; then
        mv "${path}" "${backup}"
        echo "  ↳ Backed up to: ${backup}"
        return 0
    fi
    return 1
}

# Link single agent
# $3: relink flag (1 = re-create even if already correctly linked)
link_agent() {
    local name=$1
    local target=$2
    local relink=${3:-0}
    local parent
    parent="$(dirname "${target}")"

    # Create parent directory if missing
    if [[ ! -d "${parent}" ]]; then
        mkdir -p "${parent}"
    fi

    # Handle existing path
    if [[ -L "${target}" ]]; then
        local current
        current="$(readlink "${target}")"
        if [[ "${current}" == "${CENTRAL_SKILLS}" ]]; then
            if [[ "${relink}" == "1" ]]; then
                rm "${target}"
                echo "↺ ${name}: Re-linking"
            else
                echo "✓ ${name}: Already linked"
                return 0
            fi
        else
            echo "⚠ ${name}: Symlink exists but points elsewhere"
            rm "${target}"
        fi
    elif [[ -e "${target}" ]]; then
        echo "→ ${name}: Backing up existing directory"
        backup_path "${target}"
    fi

    # Create symlink
    ln -s "${CENTRAL_SKILLS}" "${target}"
    echo "✓ ${name}: Linked to central skills"
}

# Unlink single agent
unlink_agent() {
    local name=$1
    local target=$2

    if [[ ! -L "${target}" ]]; then
        echo "○ ${name}: Not a symlink (skipped)"
        return 0
    fi

    local current
    current="$(readlink "${target}")"
    if [[ "${current}" != "${CENTRAL_SKILLS}" ]]; then
        echo "⚠ ${name}: Symlink points elsewhere (skipped)"
        return 0
    fi

    rm "${target}"
    echo "✓ ${name}: Unlinked"

    # Restore most recent backup if exists
    local backup
    backup="$(find "$(dirname "${target}")" -maxdepth 1 -name "$(basename "${target}").backup.*" 2>/dev/null | sort -r | head -n1)"
    if [[ -n "${backup}" ]]; then
        mv "${backup}" "${target}"
        echo "  ↳ Restored from: ${backup}"
    fi
}

# Check status of single agent
check_status() {
    local name=$1
    local target=$2

    if [[ -L "${target}" ]]; then
        local current
        current="$(readlink "${target}")"
        if [[ "${current}" == "${CENTRAL_SKILLS}" ]]; then
            echo "✓ ${name}: Linked"
        else
            echo "⚠ ${name}: Symlink to ${current}"
        fi
    elif [[ -d "${target}" ]]; then
        echo "○ ${name}: Directory (not linked)"
    elif [[ -e "${target}" ]]; then
        echo "⚠ ${name}: File exists (unexpected)"
    else
        echo "○ ${name}: Not present"
    fi
}

# Main commands
cmd_link() {
    ensure_central_skills

    # Count already-linked agents
    local already_linked=0
    for name in "${!AGENTS[@]}"; do
        local target="${AGENTS[$name]}"
        if [[ -L "${target}" && "$(readlink "${target}")" == "${CENTRAL_SKILLS}" ]]; then
            already_linked=$((already_linked + 1))
        fi
    done

    local relink=0
    if [[ "${already_linked}" -gt 0 ]]; then
        echo "${already_linked} agent(s) are already linked."
        printf "Re-link them all to fix any issues? [y/N] "
        read -r answer
        if [[ "${answer}" =~ ^[Yy]$ ]]; then
            relink=1
        fi
        echo
    fi

    echo "Linking agent skills to: ${CENTRAL_SKILLS}"
    echo
    for name in "${!AGENTS[@]}"; do
        link_agent "${name}" "${AGENTS[$name]}" "${relink}"
    done
    echo
    echo "Done. All agents now share central skills directory."
}

cmd_unlink() {
    echo "Unlinking agent skills from: ${CENTRAL_SKILLS}"
    echo
    for name in "${!AGENTS[@]}"; do
        unlink_agent "${name}" "${AGENTS[$name]}"
    done
    echo
    echo "Done. Agents restored to original state."
}

cmd_status() {
    echo "Agent Skills Status"
    echo "Central: ${CENTRAL_SKILLS}"
    echo
    for name in "${!AGENTS[@]}"; do
        check_status "${name}" "${AGENTS[$name]}"
    done
}

cmd_help() {
    cat <<EOF
Skills Centralization Manager

Usage: $(basename "$0") <command>

Commands:
  link      Link all agent skills directories to central ./skills
  unlink    Unlink and restore original directories (from backups)
  status    Show current link status for all agents
  help      Show this help message

Examples:
  $(basename "$0") link
  $(basename "$0") status
  $(basename "$0") unlink

Agents managed (${#AGENTS[@]} total):
EOF
    for name in "${!AGENTS[@]}"; do
        echo "  - ${name}: ${AGENTS[$name]}"
    done | sort
}

# Entry point
main() {
    local cmd=${1:-help}

    detect_construct_agents

    case "${cmd}" in
        link)    cmd_link ;;
        unlink)  cmd_unlink ;;
        status)  cmd_status ;;
        help)    cmd_help ;;
        *)
            echo "Error: Unknown command '${cmd}'"
            echo "Run '$(basename "$0") help' for usage."
            exit 1
            ;;
    esac
}

main "$@"
