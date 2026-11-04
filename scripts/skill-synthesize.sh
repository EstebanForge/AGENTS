#!/usr/bin/env bash

# skill-synthesize: Scaffolds, validates, and registers synthesized skills.
# Follows writing-for-agents and SKILL-MECHANICS standards.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_DIR="${REPO_ROOT}/skills"

# Colors (mirrors manage.sh)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

usage() {
    cat <<EOF
Usage:
  $0 new <skill-name> [--user-invoked]
  $0 validate <skill-name>
  $0 link

Commands:
  new       Scaffold a new skill with SKILL.md and patterns.md
  validate  Verify frontmatter, structure, and token/line budgets for a skill
  link      Sync skills across agent harnesses via manage.sh
EOF
}

validate_skill() {
    local name="$1"
    local dir="${SKILLS_DIR}/${name}"
    local skill_file="${dir}/SKILL.md"
    local patterns_file="${dir}/patterns.md"
    local errors=0

    if [[ ! -d "${dir}" ]]; then
        log_error "Skill directory not found: ${dir}"
        return 1
    fi

    if [[ ! -f "${skill_file}" ]]; then
        log_error "Missing SKILL.md in ${dir}"
        return 1
    fi

    # Check YAML frontmatter presence
    if ! head -n 1 "${skill_file}" | grep -q '^---$'; then
        log_error "SKILL.md missing opening '---' frontmatter delimiter"
        ((errors++))
    fi

    # Check name matches directory
    local frontmatter_name
    frontmatter_name="$(grep -m 1 '^name:' "${skill_file}" | awk '{print $2}' | tr -d '\r"' || true)"
    if [[ "${frontmatter_name}" != "${name}" ]]; then
        log_error "Frontmatter name '${frontmatter_name}' does not match directory name '${name}'"
        ((errors++))
    fi

    # Check for description or disable-model-invocation
    local has_desc has_disabled
    has_desc="$(grep -c '^description:' "${skill_file}" || true)"
    has_disabled="$(grep -c '^disable-model-invocation: true' "${skill_file}" || true)"

    if [[ "${has_desc}" -eq 0 && "${has_disabled}" -eq 0 ]]; then
        log_error "SKILL.md must have 'description:' or 'disable-model-invocation: true'"
        ((errors++))
    fi

    # Check patterns.md existence
    if [[ ! -f "${patterns_file}" ]]; then
        log_warning "patterns.md missing in ${dir}. Recommended for editor history"
    fi

    if (( errors > 0 )); then
        log_error "Validation failed for ${name} with ${errors} error(s)"
        return 1
    fi

    log_success "Skill '${name}' passed structural validation"
    return 0
}

scaffold_skill() {
    local name="$1"
    local user_invoked="${2:-false}"
    local dir="${SKILLS_DIR}/${name}"
    local skill_file="${dir}/SKILL.md"
    local patterns_file="${dir}/patterns.md"

    if [[ -e "${dir}" ]]; then
        log_error "Skill '${name}' already exists at ${dir}"
        exit 1
    fi

    mkdir -p "${dir}"

    if [[ "${user_invoked}" == "--user-invoked" ]]; then
        cat <<EOF > "${skill_file}"
---
name: ${name}
description: One-line summary for user reference.
disable-model-invocation: true
---

# ${name}

Procedure steps go here. One paragraph per line.

## Protocol

1. Step 1
2. Step 2

## Completion Criteria

- [ ] Verifiable criteria
EOF
    else
        cat <<EOF > "${skill_file}"
---
name: ${name}
description: Action verb leading trigger summary. Use when specific condition happens.
---

# ${name}

Universal procedure. One paragraph per line.

## Protocol

1. Step 1
2. Step 2

## Completion Criteria

- [ ] Verifiable criteria
EOF
    fi

    cat <<EOF > "${patterns_file}"
# Patterns: ${name}

## Initial Pattern

Observed: Recurring workflow pattern identified across sessions.
Rule: Standardize procedure into executable steps.
Executor: all
Status: active
EOF

    log_success "Created skill '${name}' at ${dir}"
    validate_skill "${name}"
}

if (( $# == 0 )); then
    usage
    exit 1
fi

ACTION="$1"
shift

case "${ACTION}" in
    new)
        if (( $# == 0 )); then
            log_error "Skill name required"
            usage
            exit 1
        fi
        scaffold_skill "$1" "${2:-}"
        ;;
    validate)
        if (( $# == 0 )); then
            log_error "Skill name required"
            usage
            exit 1
        fi
        validate_skill "$1"
        ;;
    link)
        log_info "Synchronizing via manage.sh..."
        "${REPO_ROOT}/manage.sh" link
        ;;
    -h|--help|help)
        usage
        exit 0
        ;;
    *)
        usage
        exit 1
        ;;
esac
