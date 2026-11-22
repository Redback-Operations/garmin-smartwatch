#!/usr/bin/env bash
# Run the repository's Python source-regression checks. No Garmin SDK required.
set -euo pipefail

usage(){
        printf '%s\n' 'Usage: bash run_tests.sh [test_filename_pattern]' \
        'Examples:' '  bash run_tests.sh' \
        "  bash run_tests.sh 'test_feedback_mode.py'" \
        'Optional: PYTHON_BIN=/path/to/python3 bash run_tests.sh'
}

# Accept help or a single test filename
if [[ ${1:-} == --help || ${1:-} == -h ]]; then usage; exit 0; fi
if [[ $# -gt 1 ]]; then usage >&2; exit 2; fi


# Resolve the repository root relative to this script in tests/.
PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Use python3 by default and allow a custom interpreter.
PYTHON_BIN="${PYTHON_BIN:-python3}"
if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
    printf 'Python 3 was not found. Install Python 3 or set PYTHON_BIN.\n' >&2
    exit 2
fi
if [[ ! -d tests || ! -d source || ! -f manifest.xml ]]; then
    printf 'Place run_tests.sh inside the project tests/ directory, beside the Python tests.\n' >&2
    exit 2
fi

# Select test files and create a unique log in test-results
PATTERN="${1:-test_*.py}"
mkdir -p test-results
LOG_FILE="$(mktemp "$PROJECT_ROOT/test-results/run-$(date -u +%Y%m%dT%H%M%SZ)-XXXXXX.log")"

# Disable errexit briefly so can capture both Python and tee exit codes.
set +e
{
    printf 'Garmin source-regression checks\nUTC: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'Project: %s\nPattern: %s\n' "${PROJECT_ROOT##*/}" "$PATTERN"
    # Record the commit and local changes when Git is available.
    if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        printf 'Commit: '; git rev-parse HEAD
        printf 'Working tree changes (tests use these local files):\n'
        git status --short
    fi
    "$PYTHON_BIN" -u - "$PATTERN" <<'PY'
import sys
import unittest

if sys.version_info < (3, 8):
    sys.exit("Python 3.8 or later is required.")
print("Python:", sys.version.split()[0])
# Load matching tests and treat an empty selection as an error.
suite = unittest.defaultTestLoader.discover("tests", pattern=sys.argv[1])
count = suite.countTestCases()
if count == 0:
    print("ERROR: No tests discovered. Check the filename pattern.", file=sys.stderr)
    sys.exit(2)
print("Discovered {} test cases. These inspect source; they do not run the watch app.".format(count))
result = unittest.TextTestRunner(verbosity=2).run(suite)
sys.exit(0 if result.wasSuccessful() else 1)
PY
} 2>&1 | tee "$LOG_FILE"

# Save both exit codes before another command resets PIPESTATUS.
statuses=("${PIPESTATUS[@]}")
set -e
printf '\nLog saved to: %s\n' "$LOG_FILE"
if [[ ${statuses[1]} -ne 0 ]]; then
    printf 'ERROR: Could not write the complete log.\n' >&2
    exit 2
fi
exit "${statuses[0]}"