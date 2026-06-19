# pi token cost tracker — interactive menu function for zsh/bash.
# Source this file, or paste the function into your ~/.zshrc.
# Deployed automatically by install.sh. Manual: source this file then run `tokens`.

tokens() {
  local ct="$HOME/.pi/cost-tracker"
  local choice range month
  while true; do
    cat <<'MENU'

pi token cost tracker  (reads all roots in roots.conf)

  1) live spend — this month
  2) live spend — all history
  3) live spend — specific month/day
  4) squash month into archive (+ trend)
  5) show trend (history.csv)
  6) show archive detail for a month
  q) quit
MENU
    printf '\n> '; read -r choice || break
    case "$choice" in
      1) "$ct/api-equiv.sh" "$(date +%Y/%m)" ;;
      2) "$ct/api-equiv.sh" all ;;
      3) printf 'range (YYYY/MM or YYYY/MM/DD): '; read -r range
         [ -n "$range" ] && "$ct/api-equiv.sh" "$range" ;;
      4) printf 'month (YYYY/MM) [enter=current]: '; read -r month
         "$ct/monthly-rollup.sh" "${month:-$(date +%Y/%m)}" ;;
      5) column -t -s, "$ct/monthly/history.csv" 2>/dev/null \
           || echo "no archive yet; use option 4 first" ;;
      6) printf 'month (YYYY/MM): '; read -r month
         if [ -n "$month" ] && [ -f "$ct/monthly/${month//\//-}.json" ]; then
           jq . "$ct/monthly/${month//\//-}.json"
         else
           echo "no archive for ${month:-<empty>}; squash it first (option 4)"
         fi ;;
      q|Q) echo "bye"; break ;;
      *) echo "invalid: $choice" ;;
    esac
    printf '\n[enter to continue]'; read -r || break
  done
}
