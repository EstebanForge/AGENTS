#!/usr/bin/env bash

# fuse-agents plugin bootstrap.
# Clones the plugin repo to a throwaway location under /tmp, then runs the
# plugin's own install.sh or uninstall.sh.
#   - install:   copies plugin into the persistent shell plugins dir + wires rc
#   - uninstall: removes the rc source block + plugin directory
# Reproducible on any machine with git + bash/zsh.

set -euo pipefail

REPO_URL="https://github.com/EstebanForge/fuse-agents.git"
STAGE_PREFIX="/tmp/fuse-agents-clone"
ACTION="${1:-install}"

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
    echo "Usage: $0 {install|uninstall}" >&2
}

case "${ACTION}" in
    install|uninstall) ;;
    -h|--help|help) usage; exit 0 ;;
    *) usage; exit 1 ;;
esac

# Bail early without git.
if ! command -v git >/dev/null 2>&1; then
    log_error "git not found. Install git and re-run."
    exit 1
fi

# Unique staging dir per run so concurrent/aborted runs don't collide.
STAGE_DIR="${STAGE_PREFIX}-$$"
if [[ -d "${STAGE_DIR}" ]]; then
    rm -rf "${STAGE_DIR}"
fi

log_info "Cloning fuse-agents to ${STAGE_DIR}"
git clone --depth 1 "${REPO_URL}" "${STAGE_DIR}"

RUNNER="${STAGE_DIR}/uninstall.sh"
if [[ "${ACTION}" == "install" ]]; then
    RUNNER="${STAGE_DIR}/install.sh"
fi

if [[ ! -f "${RUNNER}" ]]; then
    log_error "Expected ${RUNNER} in the cloned repo but it is missing."
    rm -rf "${STAGE_DIR}" 2>/dev/null || true
    exit 1
fi

# Hand off to the plugin's own installer/uninstaller.
log_info "Running fuse-agents ${ACTION}"
(
    cd "${STAGE_DIR}"
    if [[ ! -x "./$(basename "${RUNNER}")" ]]; then
        chmod +x "./$(basename "${RUNNER}")" || true
    fi
    "./$(basename "${RUNNER}")"
)

# Best-effort cleanup. Do not fail the run if /tmp is busy.
rm -rf "${STAGE_DIR}" 2>/dev/null || log_warning "Could not remove ${STAGE_DIR} (safe to ignore)"

# Verify the active shell rc reflects the action.
RC_FILE=""
if [[ -n "${ZSH_VERSION:-}" ]] || [[ "${SHELL:-}" == *"zsh"* ]]; then
    RC_FILE="${HOME}/.zshrc"
elif [[ -n "${BASH_VERSION:-}" ]] || [[ "${SHELL:-}" == *"bash"* ]]; then
    RC_FILE="${HOME}/.bashrc"
fi

if [[ "${ACTION}" == "install" ]]; then
    if [[ -n "${RC_FILE}" && -f "${RC_FILE}" ]] && grep -q "fuse-agents" "${RC_FILE}"; then
        log_success "fuse-agents installed. Restart your shell or run: source ${RC_FILE}"
    else
        log_warning "Installer finished but could not confirm the source line in ${RC_FILE:-shell rc}. Check the installer output above."
    fi
else
    if [[ -z "${RC_FILE}" || ! -f "${RC_FILE}" ]] || ! grep -q "fuse-agents" "${RC_FILE}"; then
        log_success "fuse-agents uninstalled. Restart your shell to clear loaded functions."
    else
        log_warning "Uninstaller finished but a fuse-agents reference still appears in ${RC_FILE}. Inspect it manually."
    fi
fi
