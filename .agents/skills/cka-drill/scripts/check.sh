#!/usr/bin/env bash
# CKA Drill Grader — shared helper library
# Sourced automatically by AI-generated grade-current.sh scripts.
# Do not edit the individual grader scripts — they are regenerated per drill.
#
# Usage in generated scripts:
#   source "$(dirname "${BASH_SOURCE[0]}")/lib/check.sh"

PASS_COUNT=0
FAIL_COUNT=0
RESULTS=()

PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null)}"
export KUBECONFIG="${KUBECONFIG:-$PROJECT_ROOT/configs/config}"

# Execute a command on a VM node via vagrant ssh
# Usage: vm_exec <vm_name> <shell_command>
vm_exec() {
  local vm="$1"; shift
  cd "$PROJECT_ROOT" && vagrant ssh "$vm" -- "$@" 2>/dev/null
}

# Register a passing sub-task
# Usage: check_pass "Human-readable label"
check_pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  RESULTS+=("  PASS  $1")
}

# Register a failing sub-task with an explanation
# Usage: check_fail "Human-readable label" "reason why it failed"
check_fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  RESULTS+=("  FAIL  $1${2:+ — $2}")
}

# Assert kubectl auth can-i returns 'yes'
# Usage: assert_can_i <verb> <resource> <as_subject> <namespace> "label"
assert_can_i() {
  local result
  result=$(kubectl auth can-i "$1" "$2" --as="$3" -n "$4" 2>/dev/null)
  [[ "$result" == "yes" ]] \
    && check_pass "$5" \
    || check_fail "$5" "kubectl auth can-i returned '${result:-<error>}'"
}

# Assert a file exists on a VM node
# Usage: assert_vm_file_exists <vm_name> <remote_path> "label"
assert_vm_file_exists() {
  vm_exec "$1" "test -f '$2'" &>/dev/null \
    && check_pass "$3" \
    || check_fail "$3" "$1:$2 not found"
}

# Print the final scorecard and exit (0 = all pass, 1 = any fail)
# Usage: print_scorecard "Scenario Title"
print_scorecard() {
  local scenario="$1"
  local total=$((PASS_COUNT + FAIL_COUNT))
  local pct=0
  [[ $total -gt 0 ]] && pct=$((PASS_COUNT * 100 / total))

  echo ""
  echo "── CKA Proctor Scorecard ──────────────────────────────"
  echo "  Scenario: $scenario"
  echo "───────────────────────────────────────────────────────"
  for r in "${RESULTS[@]}"; do echo "$r"; done
  echo "───────────────────────────────────────────────────────"
  echo "  Score: $PASS_COUNT / $total sub-tasks  (${pct}%)"
  echo "───────────────────────────────────────────────────────"
  echo ""

  [[ $FAIL_COUNT -eq 0 ]] && exit 0 || exit 1
}
