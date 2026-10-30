default:
    @just --list

# Check manage script syntax and shellcheck
check:
    bash -n manage.sh
    shellcheck manage.sh

# Show agent sync status across installed agents
status:
    ./manage.sh status

# Synchronize rules, prompts, and skills to all agents
sync:
    ./manage.sh sync

# Local CI verification gate
ci: check
