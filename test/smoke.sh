#!/usr/bin/env bash
#
# Smoke test for the language server setup.
#
# Language servers here fail silently: if the binary goes missing, nvim just
# quietly stops attaching it and diagnostics never appear. That is how
# typescript-language-server and ruby-lsp both stayed broken for months. This
# script builds a throwaway project per language, opens a file in headless
# nvim, and checks that the expected servers actually attach.
#
# Usage:
#   test/smoke.sh              # all languages
#   test/smoke.sh python ruby  # only the named ones
#
# Exits non-zero if any case fails.

set -uo pipefail

SMOKE_LUA=$(cd "$(dirname "$0")" && pwd)/smoke.lua

FIXTURES=$(mktemp -d)
trap 'rm -rf "$FIXTURES"' EXIT

PASS=0
FAIL=0
FAILED_CASES=()

# Wait this long for a server to come up. rust-analyzer is the slow one.
TIMEOUT_MS=${SMOKE_TIMEOUT_MS:-40000}

# run_case <name> <dir> <file> <expected-servers-csv> <min-diagnostics>
#
# Passes if every expected server attaches and at least min-diagnostics
# diagnostics arrive. min-diagnostics of 0 means "attach is enough" -- used for
# servers that report nothing on a syntactically valid file.
run_case() {
  local name=$1 dir=$2 file=$3 want=$4 min_diags=$5

  printf '  %-12s ' "$name"

  local out
  out=$(cd "$dir" && WANT="$want" MIN_DIAGS="$min_diags" TIMEOUT_MS="$TIMEOUT_MS" \
    nvim --headless -n "+edit $file" "+luafile $SMOKE_LUA" +qa 2>&1 |
    grep '^SMOKE ')

  case "$out" in
    "SMOKE ok"*)
      printf 'ok      %s\n' "${out#SMOKE ok }"
      PASS=$((PASS + 1))
      ;;
    *)
      printf 'FAIL    %s\n' "${out#SMOKE fail }"
      FAIL=$((FAIL + 1))
      FAILED_CASES+=("$name")
      ;;
  esac
}

# --- fixtures -------------------------------------------------------------
#
# Each builds a minimal but realistic project: the servers use root markers
# (pyproject.toml, a lockfile, .git) to decide where the project starts, and
# ty in particular reports nothing for files outside its project root.

fixture_python() {
  local d=$FIXTURES/python
  mkdir -p "$d"
  printf '[project]\nname = "smoke"\nversion = "0.1.0"\nrequires-python = ">=3.11"\n' \
    > "$d/pyproject.toml"
  cat > "$d/main.py" <<'PY'
def pages(title: str) -> int:
    return title
PY
  run_case python "$d" main.py ruff,ty 1
}

fixture_typescript() {
  local d=$FIXTURES/typescript
  mkdir -p "$d"
  printf '{"compilerOptions":{"strict":true,"target":"es2022","module":"esnext","moduleResolution":"bundler"}}\n' \
    > "$d/tsconfig.json"
  cat > "$d/main.ts" <<'TS'
const pages: number = "720";
TS
  # typescript-language-server loads tsserver.js out of the project's own
  # node_modules, so the dependency has to be here. Pinned to 5.x because
  # TypeScript 7 dropped tsserver.js entirely.
  (cd "$d" && npm init -y >/dev/null 2>&1 &&
    npm install --silent --no-audit --no-fund typescript@5 >/dev/null 2>&1)
  run_case typescript "$d" main.ts ts_ls 1
}

fixture_ruby() {
  local d=$FIXTURES/ruby
  mkdir -p "$d"
  # ruby-lsp needs a project root; .git is the marker it finds here.
  (cd "$d" && git init -q .)
  cat > "$d/main.rb" <<'RB'
class Book
  def initialize(title)
    @title = title
  end
end
RB
  # ruby-lsp only emits diagnostics when RuboCop is set up, so attaching is
  # all we assert.
  run_case ruby "$d" main.rb ruby_lsp 0
}

fixture_rust() {
  local d=$FIXTURES/rust
  mkdir -p "$d"
  (cd "$d" && cargo init --quiet --name smoke . >/dev/null 2>&1)
  cat > "$d/src/main.rs" <<'RS'
fn main() {
    let pages: i32 = "720";
    println!("{}", pages);
}
RS
  # rust-analyzer's diagnostics arrive from cargo check, which is too slow and
  # too environment-dependent to gate on; attaching is the signal we want.
  run_case rust "$d" src/main.rs rust_analyzer 0
}

# --- main -----------------------------------------------------------------

ALL=(python typescript ruby rust)
CASES=("$@")
if [ ${#CASES[@]} -eq 0 ]; then
  CASES=("${ALL[@]}")
fi

echo "nvim LSP smoke test"
echo

for c in "${CASES[@]}"; do
  case $c in
    python)     fixture_python ;;
    typescript) fixture_typescript ;;
    ruby)       fixture_ruby ;;
    rust)       fixture_rust ;;
    *) echo "  unknown case: $c (known: ${ALL[*]})"; FAIL=$((FAIL + 1)) ;;
  esac
done

echo
if [ "$FAIL" -eq 0 ]; then
  echo "$PASS passed"
  exit 0
fi

echo "$PASS passed, $FAIL failed: ${FAILED_CASES[*]}"
echo
echo "A missing server usually means its binary is gone from PATH. See the"
echo "install commands in README.md -- and note that a server installed with"
echo "'npm install -g' or 'gem install' disappears whenever mise changes the"
echo "active Node or Ruby version."
exit 1
