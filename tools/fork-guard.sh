#!/bin/sh
# Checks that the fork patch of transcript-redactor survives every upstream merge:
# glab calls and curl bodies publish too, so their placeholders stay placeholders.
# Run from anywhere: sh tools/fork-guard.sh
set -eu

cd "$(dirname "$0")/.."

PLUGIN=plugins/transcript-redactor
HOOK=$PLUGIN/hooks/redact.ts
TESTS=$PLUGIN/tests/redact.test.ts

fail() {
  echo "fork-guard: $1" >&2
  exit 1
}

[ -f "$HOOK" ] || fail "$HOOK fehlt"
[ -f "$TESTS" ] || fail "$TESTS fehlt"

grep -q 'fork-patch' "$HOOK" ||
  fail "Marker fork-patch fehlt in redact.ts"
grep -qF '\bglab[ \t]+[a-z]' "$HOOK" ||
  fail "glab fehlt in PUBLISHES (redact.ts)"
grep -q '^const CURL_BODY = ' "$HOOK" ||
  fail "CURL_BODY fehlt in redact.ts"
grep -q 'publishesCommand(' "$HOOK" ||
  fail "publishesCommand( fehlt in redact.ts"
grep -q 'PUB1' "$TESTS" ||
  fail "Test PUB1 fehlt in redact.test.ts"
grep -q 'PUB2' "$TESTS" ||
  fail "Test PUB2 fehlt in redact.test.ts"

# the definition and a call: the patch is wired in, not only declared
grep -q '^const publishesCommand = ' "$HOOK" ||
  fail "Definition von publishesCommand fehlt in redact.ts"

echo "fork-guard: Fork-Patch vorhanden"
