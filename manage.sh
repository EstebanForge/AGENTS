#!/usr/bin/env bash

# Agents Centralization Manager (Unified)
# Synchronizes both AGENTS.md instructions and skills folders.
# Supports local symlinking and construct-cli direct copying.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CENTRAL_AGENTS="${SCRIPT_DIR}/AGENTS.md"
CENTRAL_SKILLS="${SCRIPT_DIR}/skills"
CENTRAL_PROMPTS="${SCRIPT_DIR}/prompts"

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
# Note: Antigravity, Codex, Opencode, and Pi support the emerging ~/.agents/skills standard
# and do not need separate skills mapping.
declare -A AGENTS=(
    # --- Standard & Standard-Supporting Agents ---
    ["Standard"]="${HOME}/.agents/AGENTS.md|${HOME}/.agents/skills"
    ["Antigravity"]="${HOME}/.gemini/GEMINI.md|${HOME}/.gemini/skills"
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
    ["Pi"]="${HOME}/.pi/agent/AGENTS.md|-"
    ["Zcode"]="${HOME}/.zcode/AGENTS.md|${HOME}/.zcode/skills"
)

declare -A PROMPTS=(
    ["Standard"]="${HOME}/.agents/prompts"
    ["Antigravity"]="${HOME}/.gemini/prompts"
    ["Pi"]="${HOME}/.pi/agent/prompts"
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
    AGENTS["construct_Antigravity"]="${construct_home}/.gemini/GEMINI.md|${construct_home}/.gemini/skills"
    AGENTS["construct_Qwen"]="${construct_home}/.qwen/QWEN.md|${construct_home}/.qwen/skills"
    AGENTS["construct_Opencode"]="${construct_home}/.config/opencode/AGENTS.md|-"
    AGENTS["construct_Amp"]="${construct_home}/.config/amp/AGENTS.md|${construct_home}/.config/amp/skills"
    AGENTS["construct_Codex"]="${construct_home}/.codex/AGENTS.md|-"
    AGENTS["construct_Copilot"]="${construct_home}/.copilot/copilot-instructions.md|${construct_home}/.copilot/skills"
    AGENTS["construct_Droid"]="${construct_home}/.factory/AGENTS.md|${construct_home}/.factory/skills"
    AGENTS["construct_Goose"]="${construct_home}/.config/goose/AGENTS.md|${construct_home}/.config/goose/skills"
    AGENTS["construct_Kilocode"]="${construct_home}/.kilocode/rules/AGENTS.md|${construct_home}/.kilocode/skills"
    AGENTS["construct_Cline"]="${construct_home}/.cline/AGENTS.md|${construct_home}/.cline/skills"
    AGENTS["construct_Pi"]="${construct_home}/.pi/agent/AGENTS.md|-"
    AGENTS["construct_Zcode"]="${construct_home}/.zcode/AGENTS.md|${construct_home}/.zcode/skills"
    PROMPTS["construct_Standard"]="${construct_agents_dir}/prompts"
    PROMPTS["construct_Antigravity"]="${construct_home}/.gemini/prompts"
    PROMPTS["construct_Pi"]="${construct_home}/.pi/agent/prompts"

    log_info "construct-cli detected: added 14 agent paths (Internal Copying Mode)"
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
    local backup
    backup="${path}.backup.$(date +%Y%m%d_%H%M%S)"
    if [[ -e "${path}" && ! -L "${path}" ]]; then
        mv "${path}" "${backup}"
        log_info "  ↳ Backed up to: ${backup}"
        return 0
    fi
    return 1
}

# --- Per-entry synchronization engine (skills + prompts) ---
# A category dir (skills/ or prompts/) is synced at per-entry granularity so
# files installed by other tools coexist with centrally-managed ones. A manifest
# file inside each target records which entry names this script owns, enabling
# clean removal and reconciliation when central entries are renamed or removed.
# Applies to BOTH standard agents (per-entry symlinks) and construct-cli sandbox
# paths (per-entry copy without --delete).
MANIFEST_NAME=".agents-central-managed"

# Emit the direct children names of a source dir (files + dirs, including
# dotfiles), one per line. This is the canonical "managed set".
managed_entry_names() {
    local src=$1 entry
    for entry in "${src}"/* "${src}"/.[!.]*; do
        [[ -e "${entry}" || -L "${entry}" ]] || continue
        printf '%s\n' "${entry#"${src}/"}"
    done
}

read_manifest() {
    local target=$1
    [[ -f "${target}/${MANIFEST_NAME}" ]] && cat "${target}/${MANIFEST_NAME}"
}

write_manifest() {
    local target=$1; shift
    if (( $# > 0 )); then
        printf '%s\n' "$@" | sort > "${target}/${MANIFEST_NAME}"
    else
        : > "${target}/${MANIFEST_NAME}"
    fi
}

# Standard mode: symlink each central entry into a real category directory.
# Args: $1=kind (skills|prompts) $2=name $3=src $4=target $5=force
sync_dir_symlink() {
    local kind=$1 name=$2 src=$3 target=$4 force=${5:-0}

    # Migrate a legacy whole-directory symlink into a merged real directory.
    if [[ -L "${target}" ]]; then
        if [[ "$(readlink "${target}")" == "${src}" ]]; then
            rm "${target}"; mkdir -p "${target}"
            log_info "${name}: Converted legacy ${kind} symlink to merged dir"
        else
            log_warning "${name}: ${kind} symlink points elsewhere, skipping"
            return 0
        fi
    else
        local ancestor; ancestor="$(find_existing_ancestor "${target}")"
        if [[ "${ancestor}" == "${HOME}" || "${ancestor}" == "/" ]]; then
            log_info "${name}: Agent not installed (skipped ${kind})"; return 0
        fi
        [[ -L "${target}" && ! -e "${target}" ]] && rm -f "${target}"   # dangling
        mkdir -p "${target}"
    fi

    local -A old_set=() new_set=()
    local s
    while IFS= read -r s; do [[ -n "$s" ]] && old_set["$s"]=1; done < <(read_manifest "${target}")

    local updated=0
    while IFS= read -r s; do
        [[ -z "$s" ]] && continue
        new_set["$s"]=1
        local src_entry="${src}/${s}" dst="${target}/${s}"
        if [[ -L "${dst}" && "$(readlink "${dst}")" == "${src_entry}" ]]; then
            if [[ "${force}" == "1" ]]; then rm "${dst}"; ln -s "${src_entry}" "${dst}"; updated=$((updated+1)); fi
            continue
        fi
        if [[ -L "${dst}" ]]; then
            rm "${dst}"                         # stale/foreign symlink: replace
        elif [[ -e "${dst}" ]]; then
            backup_path "${dst}"               # third-party real entry collision
        fi
        ln -s "${src_entry}" "${dst}"; updated=$((updated+1))
    done < <(managed_entry_names "${src}")

    # Reconcile: drop managed links whose entry left central.
    for s in "${!old_set[@]}"; do
        if [[ -z "${new_set[$s]+isset}" ]]; then
            local dst="${target}/${s}"
            if [[ -L "${dst}" ]]; then rm "${dst}"; log_info "${name}: Removed stale ${kind} link ${s}"; fi
        fi
    done

    write_manifest "${target}" "${!new_set[@]}"
    log_success "${name}: Synchronized ${kind} (${updated} link(s))"
}

# Construct mode: copy central entries without --delete; reconcile via manifest
# so dropped central entries are removed but third-party entries survive.
# Args: $1=kind $2=name $3=src $4=target
sync_dir_copy() {
    local kind=$1 name=$2 src=$3 target=$4

    if [[ "${target}" == "${HOME}/.config/construct-cli/home/.agents/"* ]]; then
        log_info "${name}: ${kind^} are source"; return 0
    fi
    [[ -L "${target}" && ! -e "${target}" ]] && rm -f "${target}"
    mkdir -p "${target}"

    local -A old_set=() new_set=()
    local s
    while IFS= read -r s; do [[ -n "$s" ]] && old_set["$s"]=1; done < <(read_manifest "${target}")
    while IFS= read -r s; do [[ -n "$s" ]] && new_set["$s"]=1; done < <(managed_entry_names "${src}")

    for s in "${!old_set[@]}"; do
        if [[ -z "${new_set[$s]+isset}" && -e "${target}/${s}" ]]; then
            rm -rf "${target:?}/${s}"; log_info "${name}: Removed stale ${kind} ${s}"
        fi
    done

    if command -v rsync >/dev/null 2>&1; then
        rsync -a "${src}/" "${target}/"
    else
        cp -r "${src}/." "${target}/"
    fi

    write_manifest "${target}" "${!new_set[@]}"
    log_success "${name}: Synchronized ${kind}"
}

# Reverse of sync_dir_symlink: remove only managed links + manifest.
# Args: $1=kind $2=name $3=target
unsync_dir_symlink() {
    local kind=$1 name=$2 target=$3
    if [[ -L "${target}" ]]; then
        rm "${target}"; log_success "${name}: Removed ${kind} symlink"
        local backup; backup="$(find "$(dirname "${target}")" -maxdepth 1 -name "$(basename "${target}").backup.*" 2>/dev/null | sort -r | head -n1)"
        [[ -n "${backup}" ]] && { mv "${backup}" "${target}"; log_info "  ↳ Restored backup"; }
        return 0
    fi
    [[ -d "${target}" ]] || return 0
    local s
    while IFS= read -r s; do
        [[ -z "$s" ]] && continue
        local dst="${target}/${s}"
        if [[ -L "${dst}" ]]; then
            rm "${dst}"
            local b; b="$(find "${target}" -maxdepth 1 -name "${s}.backup.*" 2>/dev/null | sort -r | head -n1)"
            [[ -n "${b}" ]] && mv "${b}" "${dst}"
        fi
    done < <(read_manifest "${target}")
    rm -f "${target}/${MANIFEST_NAME}"
    log_success "${name}: Removed managed ${kind} links"
}

# Reverse of sync_dir_copy.
# Args: $1=kind $2=name $3=target
unsync_dir_copy() {
    local kind=$1 name=$2 target=$3
    [[ -d "${target}" ]] || return 0
    local s
    while IFS= read -r s; do
        [[ -z "$s" ]] && continue
        rm -rf "${target:?}/${s}"
    done < <(read_manifest "${target}")
    rm -f "${target}/${MANIFEST_NAME}"
    log_success "${name}: Removed managed ${kind}"
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

    # --- Skills (per-entry granularity: coexist with third-party skills) ---
    if [[ "${skills_path}" != "-" ]]; then
        if [[ "${name}" == construct_* ]]; then
            sync_dir_copy "skills" "${name}" "${CENTRAL_SKILLS}" "${skills_path}"
        else
            sync_dir_symlink "skills" "${name}" "${CENTRAL_SKILLS}" "${skills_path}" "${force}"
        fi
    fi
}

# Prompts management (same per-entry engine as skills)
manage_prompts() {
    local name=$1; local target=$2; local force=${3:-0}
    if [[ "${name}" == construct_* ]]; then
        sync_dir_copy "prompts" "${name}" "${CENTRAL_PROMPTS}" "${target}"
    else
        sync_dir_symlink "prompts" "${name}" "${CENTRAL_PROMPTS}" "${target}" "${force}"
    fi
}

# Unified Unlink/Restore operation
unmanage_agent() {
    local name=$1; local paths=$2
    local agent_md="${paths%%|*}"; local skills_path="${paths#*|}"

    # Instructions: single file (symlink or copy)
    if [[ "${agent_md}" != "-" ]]; then
        if [[ "${name}" == construct_* && "${agent_md}" == "${HOME}/.config/construct-cli/home/.agents/"* ]]; then
            :
        elif [[ -L "${agent_md}" ]]; then
            rm "${agent_md}"; log_success "${name}: Removed symlink $(basename "${agent_md}")"
            local backup; backup="$(find "$(dirname "${agent_md}")" -maxdepth 1 -name "$(basename "${agent_md}").backup.*" 2>/dev/null | sort -r | head -n1)"
            [[ -n "${backup}" ]] && { mv "${backup}" "${agent_md}"; log_info "  ↳ Restored backup"; }
        elif [[ -e "${agent_md}" && "${name}" == construct_* ]]; then
            rm -f "${agent_md}"; log_success "${name}: Removed copy $(basename "${agent_md}")"
        fi
    fi

    # Skills: per-entry removal (manifest-driven)
    if [[ "${skills_path}" != "-" ]]; then
        if [[ "${name}" == construct_* && "${skills_path}" == "${HOME}/.config/construct-cli/home/.agents/"* ]]; then
            :
        elif [[ "${name}" == construct_* ]]; then
            unsync_dir_copy "skills" "${name}" "${skills_path}"
        else
            unsync_dir_symlink "skills" "${name}" "${skills_path}"
        fi
    fi
}

unmanage_prompts() {
    local name=$1; local target=$2
    if [[ "${name}" == construct_* && "${target}" == "${HOME}/.config/construct-cli/home/.agents/"* ]]; then return 0; fi
    if [[ "${name}" == construct_* ]]; then
        unsync_dir_copy "prompts" "${name}" "${target}"
    else
        unsync_dir_symlink "prompts" "${name}" "${target}"
    fi
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

    log_info "Syncing central skills, prompts & instructions (per-entry)..."

    # Migration: Pi now supports ~/.agents/skills natively
    unmanage_agent "Pi" "-|${HOME}/.pi/agent/skills"
    unmanage_agent "construct_Pi" "-|${HOME}/.config/construct-cli/home/.pi/agent/skills"

    for name in $(get_sorted_agents); do
        manage_agent "${name}" "${AGENTS[$name]}" "${force}"
        if [[ -n "${PROMPTS[$name]+isset}" ]]; then
            manage_prompts "${name}" "${PROMPTS[$name]}" "${force}"
        fi
    done
    log_success "Synchronization complete."
}

cmd_unlink() {
    detect_extra_agents; detect_construct_agents
    log_info "Removing central-managed entries (backups restored if present)..."
    for name in $(get_sorted_agents); do
        unmanage_agent "${name}" "${AGENTS[$name]}"
        if [[ -n "${PROMPTS[$name]+isset}" ]]; then
            unmanage_prompts "${name}" "${PROMPTS[$name]}"
        fi
    done
    log_success "Restoration complete."
}

cmd_status() {
    detect_extra_agents; detect_construct_agents
    log_info "Agent Synchronization Status"
    printf "  %-20s %-20s %-20s %-20s
" "AGENT" "INSTRUCTIONS" "SKILLS" "PROMPTS"
    echo "  --------------------------------------------------------------------------------"
    for name in $(get_sorted_agents); do
        local paths="${AGENTS[$name]}"; local md="${paths%%|*}"; local sk="${paths#*|}"
        local md_s="-"; local sk_s="-"; local pr_s="-"
        if [[ "${md}" != "-" ]]; then
            if [[ -L "${md}" ]]; then md_s="${GREEN}Linked${NC}"; elif [[ -f "${md}" ]]; then md_s="${YELLOW}File${NC}"; else md_s="Missing"; fi
            if [[ "${name}" == construct_* && ! -L "${md}" && -f "${md}" ]]; then md_s="${GREEN}Copied${NC}"; fi
        fi
        if [[ "${sk}" != "-" ]]; then
            if [[ -L "${sk}" ]]; then
                sk_s="${YELLOW}Legacy-link${NC}"
            elif [[ -d "${sk}" && -f "${sk}/${MANIFEST_NAME}" ]]; then
                local n; n="$(wc -l < "${sk}/${MANIFEST_NAME}" 2>/dev/null)"; n="${n//[[:space:]]/}"
                sk_s="${GREEN}Managed(${n})${NC}"
            elif [[ -d "${sk}" ]]; then
                sk_s="${YELLOW}Dir${NC}"
            else
                sk_s="Missing"
            fi
        fi
        if [[ -n "${PROMPTS[$name]+isset}" ]]; then
            local pr="${PROMPTS[$name]}"
            if [[ -L "${pr}" ]]; then
                pr_s="${YELLOW}Legacy-link${NC}"
            elif [[ -d "${pr}" && -f "${pr}/${MANIFEST_NAME}" ]]; then
                local m; m="$(wc -l < "${pr}/${MANIFEST_NAME}" 2>/dev/null)"; m="${m//[[:space:]]/}"
                pr_s="${GREEN}Managed(${m})${NC}"
            elif [[ -d "${pr}" ]]; then
                pr_s="${YELLOW}Dir${NC}"
            else
                pr_s="Missing"
            fi
        fi
        printf "  %-20s %-30b %-30b %-30b
" "${name}" "${md_s}" "${sk_s}" "${pr_s}"
    done
}
# Install or uninstall the fuse-agents shell plugin.
# Bootstraps (clone to /tmp) then hands off to the plugin's own script.
cmd_fuse_agents() {
    local action="${1:-install}"
    local script="${SCRIPT_DIR}/scripts/fuse-agents.sh"
    if [[ ! -x "${script}" ]]; then
        log_error "fuse-agents bootstrap script not found or not executable: ${script}"
        exit 1
    fi
    "${script}" "${action}"
}

# --- Purge: remove ALL skills + prompts (managed, third-party, backups) ---
# Leaves empty directories. NEVER touches instruction files or .md backups.
# Covers machine + construct-cli paths (driven by the AGENTS/PROMPTS maps).
purge_one() {
    local p=$1
    case "$p" in "$HOME"/*) ;; *) log_warning "REFUSE (outside HOME): $p"; return 0 ;; esac
    [[ -e "$p" || -L "$p" ]] || return 0
    local base par b
    base="$(basename "$p")"; par="$(dirname "$p")"
    # Remove only <skills|prompts>.backup.* siblings (never *.md backups).
    while IFS= read -r b; do
        [[ -z "$b" ]] && continue
        rm -rf "${b:?}"; log_info "  backup removed: ${b#"$HOME"/}"
    done < <(find "$par" -maxdepth 1 -name "${base}.backup.*" 2>/dev/null)
    if [[ -L "$p" ]]; then
        rm "$p"; mkdir -p "$p"; log_info "  symlink -> empty dir: ${p#"$HOME"/}"
    elif [[ -d "$p" ]]; then
        find "$p" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
        log_info "  emptied: ${p#"$HOME"/}"
    fi
}

cmd_purge() {
    detect_extra_agents; detect_construct_agents
    log_warning "PURGE: removing ALL skills + prompts (managed, third-party, backups)."
    log_warning "Instruction files (AGENTS.md / CLAUDE.md / etc.) and .md backups are NOT touched."
    local name paths_str sk p count=0
    local -A seen=()
    for name in "${!AGENTS[@]}"; do
        paths_str="${AGENTS[$name]}"; sk="${paths_str#*|}"
        [[ "$sk" == "-" || -n "${seen[$sk]+isset}" ]] && continue
        seen["$sk"]=1; purge_one "$sk"; count=$((count+1))
    done
    for name in "${!PROMPTS[@]}"; do
        p="${PROMPTS[$name]}"
        [[ -n "${seen[$p]+isset}" ]] && continue
        seen["$p"]=1; purge_one "$p"; count=$((count+1))
    done
    log_success "Purge complete: ${count} skills/prompts paths processed (now empty)."
}

# Double confirmation for interactive use (type PURGE, then yes).
confirm_purge() {
    echo
    log_warning "NUCLEAR OPTION: removes ALL skills + prompts from machine AND construct-cli."
    log_warning "Deletes third-party skills/prompts AND their backups. Not reversible."
    log_warning "Instruction files (AGENTS.md etc.) are kept."
    echo
    local a b
    read -rp "Type exactly PURGE to continue: " a || a=""
    [[ "$a" == "PURGE" ]] || { echo "Aborted."; return 1; }
    read -rp "Final confirmation - type yes: " b || b=""
    [[ "$b" == "yes" ]] || { echo "Aborted."; return 1; }
    return 0
}

# Interactive Menu
interactive_menu() {
    echo -e "${BLUE}=== Agents Centralization Manager ===${NC}"
    echo "Per-entry sync: central skills/prompts/instructions coexist with third-party ones."
    echo "Choose an action:"
    options=("Sync (add/update central)" "Force re-link central" "Unlink (remove central only)" "Status" "Install fuse-agents plugin" "Uninstall fuse-agents plugin" "Purge all skills/prompts (nuclear)" "Quit")
    COLUMNS=1
    select opt in "${options[@]}"; do
        case $opt in
            "Sync (add/update central)") cmd_link 0; break ;;
            "Force re-link central") cmd_link 1; break ;;
            "Unlink (remove central only)") cmd_unlink; break ;;
            "Status") cmd_status; break ;;
            "Install fuse-agents plugin") cmd_fuse_agents install; break ;;
            "Uninstall fuse-agents plugin") cmd_fuse_agents uninstall; break ;;
            "Purge all skills/prompts (nuclear)") if confirm_purge; then cmd_purge; fi; break ;;
            "Quit") exit 0 ;;
            *) echo "Invalid option $REPLY" ;;
        esac
    done
}

# Entry Point
if [[ $# -eq 0 ]]; then
    interactive_menu
else
    FORCE=0; YES=0; COMMAND=""
    for arg in "$@"; do
        case $arg in
            -f|--force) FORCE=1 ;;
            --yes) YES=1 ;;
            link|unlink|status|purge) COMMAND=$arg ;;
        esac
    done

    case "${COMMAND}" in
        link) cmd_link $FORCE ;;
        unlink) cmd_unlink ;;
        status) cmd_status ;;
        purge)
            if [[ "$YES" == "1" ]]; then
                cmd_purge
            else
                echo "Purge is destructive. Confirm with: $0 purge --yes"; exit 1
            fi
            ;;
        *) echo "Usage: $0 {link|unlink|status|purge} [-f|--force] [--yes]"; exit 1 ;;
    esac
fi

