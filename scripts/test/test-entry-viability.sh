#!/usr/bin/env bash
#
# scripts/test/test-entry-viability.sh — tests for the inclusion-bar decision logic.
#
# These drive `verdict_for_repo` with synthetic numbers and touch NO network, so they
# are deterministic and fast. The network layer (_check_github_repo/_check_plain_link)
# is a thin adapter over this function; the judgement lives here and is what is tested.
#
# Section C is the point of this file: POSITIVE CONTROLS. Every gate must be OBSERVED
# to fail against input it is supposed to reject, otherwise a gate that always returns
# PASS would pass a suite made only of PASS assertions. A check never seen to fail has
# not been shown to be a check.
#
# Section D is a mutation guard: it proves the assertions themselves are load-bearing
# by asserting the exact inverse of a known-good verdict is NOT produced.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../check-entry-viability.sh"   # guarded: does not run main when sourced

PASS=0; FAIL=0
pass() { PASS=$((PASS+1)); echo "PASS: $1"; }
fail() { FAIL=$((FAIL+1)); echo "FAIL: $1"; }

# assert_verdict <expect-PASS|expect-FAIL> <age> <commit_age> <contribs> <stars> <label>
assert_verdict() {
  local want="$1" v; shift
  v=$(verdict_for_repo "$1" "$2" "$3" "$4")
  local label="$5"
  if [ "$want" = "expect-PASS" ]; then
    [ "$v" = "PASS" ] && pass "$label" || fail "$label — wanted PASS, got: $v"
  else
    case "$v" in FAIL:*) pass "$label (rejected: ${v#FAIL: })" ;; *) fail "$label — wanted a FAIL, got: $v" ;; esac
  fi
}

echo "== A: entries that must be ACCEPTED =="
assert_verdict expect-PASS 300 4   20 441 "A1 established: 20 contributors, 441 stars, active"
assert_verdict expect-PASS  40 0    4   0 "A2 new but real: 4 contributors, 0 stars, committed today"
assert_verdict expect-PASS 400 10   1 120 "A3 solo but adopted: 1 contributor, 120 stars (star path)"
assert_verdict expect-PASS  30 365  2  51 "A4 exactly on every boundary"

echo
echo "== B: real cases this bar was designed from =="
# Observed 2026-09-11. The bar must reproduce the manual verdicts on these.
assert_verdict expect-FAIL 106 45   1   4 "B1 tokenscope — solo, stale 45d, 4 stars"
assert_verdict expect-PASS  40  0   4   0 "B2 PromptSpend — 0 stars but 4 contributors, active"
assert_verdict expect-PASS 300  4  20 441 "B3 snip — 20 contributors, 441 stars"

echo
echo "== C: POSITIVE CONTROLS — each gate must be observed to reject =="
assert_verdict expect-FAIL  29 0    9 999 "C1 age gate fires at 29d even when everything else is excellent"
assert_verdict expect-FAIL 999 366  9 999 "C2 staleness gate fires at 366d"
assert_verdict expect-FAIL 999 0    1  50 "C3 traction gate fires at 1 contributor + exactly 50 stars"
assert_verdict expect-FAIL 999 0    0   0 "C4 empty project rejected"
assert_verdict expect-FAIL   x 0    2 100 "C5 unreadable metadata rejected, never silently passed"
assert_verdict expect-FAIL 999 ''   2 100 "C6 empty metadata rejected, never silently passed"

echo
echo "== D: mutation guard — the assertions are load-bearing =="
# If verdict_for_repo were stubbed to always echo PASS, section C would fail loudly.
# Prove the harness distinguishes the two outcomes rather than accepting any string.
_v=$(verdict_for_repo 29 0 9 999)
[ "$_v" != "PASS" ] && pass "D1 a rejecting input does not yield the literal PASS" \
                    || fail "D1 rejecting input yielded PASS — the gate is inert"
_v=$(verdict_for_repo 300 4 20 441)
[ "$_v" = "PASS" ] && pass "D2 an accepting input yields exactly PASS" \
                   || fail "D2 accepting input did not yield PASS — the gate rejects everything"

echo
echo "== E: URL classification — the gate only runs if the URL is recognised as a repo =="
# This section exists because it was MISSING and a real bypass shipped: every test input
# was a canonical URL, so `repo_slug_from_url` was never exercised while `verdict_for_repo`
# was tested six ways. A GitHub URL carrying `?tab=...` (what the address bar gives you) or
# `#readme` was routed to the plain-link path and passed on HTTP 200, skipping every
# threshold. Found by independent review, not by this suite. Hence these.
assert_slug() {  # <url> <expected-slug-or-empty> <label>
  local got; got=$(repo_slug_from_url "$1")
  if [ "$got" = "$2" ]; then pass "$3"; else fail "$3 — wanted '$2', got '$got'"; fi
}
assert_slug "https://github.com/o/r"                        "o/r" "E1  canonical"
assert_slug "https://github.com/o/r/"                       "o/r" "E2  trailing slash"
assert_slug "https://github.com/o/r.git"                    "o/r" "E3  .git suffix"
assert_slug "https://github.com/o/r#readme"                 "o/r" "E4  fragment (was a bypass)"
assert_slug "https://github.com/o/r?tab=readme-ov-file"     "o/r" "E5  query (was a bypass)"
assert_slug "https://github.com/o/r/tree/main"              "o/r" "E6  deep path resolves to its repo"
assert_slug "https://github.com/o/r/blob/main/README.md#L2" "o/r" "E7  deep path + fragment"
assert_slug "http://github.com/o/r"                         "o/r" "E8  http"
assert_slug "https://www.github.com/o/r"                    "o/r" "E9  www"
# Positive controls: these must NOT be classified as repos, or the checker would
# call the GitHub API for something that has no repo and fail confusingly.
assert_slug "https://github.com/someuser"                   ""    "E10 user page is not a repo"
assert_slug "https://github.com/orgs/acme/projects/1"       ""    "E11 /orgs/ path is not a repo"
assert_slug "https://example.com/o/r"                       ""    "E12 non-GitHub host"
assert_slug "https://notgithub.com/o/r"                     ""    "E13 lookalike host"
assert_slug "https://gitlab.com/o/r"                        ""    "E14 gitlab"
# Hostnames are case-insensitive (RFC 3986); a mixed-case host was a third bypass,
# also found by independent review rather than by this suite.
assert_slug "https://GitHub.com/o/r"        "o/r"        "E15 mixed-case host (was a bypass)"
assert_slug "https://GITHUB.COM/o/r"        "o/r"        "E16 upper-case host"
assert_slug "https://WWW.GitHub.COM/o/r"    "o/r"        "E17 mixed-case www host"
assert_slug "https://github.com/Owner/Repo" "Owner/Repo" "E18 path casing PRESERVED (paths are case-sensitive)"
assert_slug "ftp://github.com/o/r"          ""           "E19 non-http scheme rejected"
assert_slug "https://github.com"            ""           "E20 bare host is not a repo"
# Four bypasses came out of hand-rolled URL parsing before this was handed to urlsplit:
# a #fragment, a ?query, a mixed-case host, an explicit :443, and user@ userinfo. Each
# classified a real repository as a plain link, skipping every threshold.
assert_slug "https://github.com:443/o/r"                     "o/r" "E21 explicit :443 (was a bypass)"
assert_slug "https://GitHub.com:443/o/r"                     "o/r" "E22 explicit :443, mixed case"
assert_slug "https://github.com:8443/o/r"                    ""    "E23 non-default port is not a repo URL"
assert_slug "https://user@github.com/o/r"                    ""    "E24 userinfo rejected (was a bypass)"
assert_slug "https://evil.com@github.com/o/r"                ""    "E25 userinfo that mimics another host rejected"
assert_slug "https://github.com/o/r/"                        "o/r" "E26 trailing slash still fine"
# A single trailing dot is a fully-qualified name that DNS treats as equivalent; urlsplit
# preserves it, so the comparison failed and the entry was skipped instead of checked.
assert_slug "https://github.com./o/r"                        "o/r" "E27 trailing-dot FQDN (was a bypass)"
assert_slug "https://www.github.com./o/r"                    "o/r" "E28 trailing-dot www FQDN"
assert_slug "https://GitHub.com./o/r"                        "o/r" "E29 trailing-dot, mixed case"
# CommonMark resolves character references inside a link destination, so these render as
# and navigate to github.com while the raw text does not match.
assert_slug 'https://github&#46;com/o/r'                     "o/r" "E30 numeric character reference (was a bypass)"
assert_slug 'https://github&period;com/o/r'                  "o/r" "E31 named character reference"
assert_slug 'https://git&#104;ub.com/o/r'                    "o/r" "E32 character reference mid-hostname"

echo
echo "== F: entry-count ceiling — must FAIL loudly, never truncate silently =="
# Also found by independent review, not by this suite. The extraction pipeline ended in
# `head -20`, so a change adding 21+ entries checked the first 20 and printed "All new
# entries meet the bar" — reporting success for entries it never looked at. Exceeding
# the ceiling is now an explicit failure.
assert_count() {  # <expect-PASS|expect-FAIL> <count> <label>
  local v; v=$(entry_count_verdict "$2")
  if [ "$1" = "expect-PASS" ]; then
    [ "$v" = "PASS" ] && pass "$3" || fail "$3 — wanted PASS, got: $v"
  else
    case "$v" in FAIL:*) pass "$3" ;; *) fail "$3 — wanted a FAIL, got: $v" ;; esac
  fi
}
assert_count expect-PASS 1   "F1  one entry"
assert_count expect-PASS 20  "F2  exactly at the ceiling"
assert_count expect-FAIL 21  "F3  one over the ceiling is REJECTED, not truncated"
assert_count expect-FAIL 500 "F4  far over the ceiling"
assert_count expect-FAIL ""  "F5  uncountable input rejected, never silently passed"
assert_count expect-FAIL "x" "F6  non-numeric input rejected"

echo
echo "== G: integration — a check that cannot run must not report success =="
# The fifth finding from independent review, and the sharpest one: `git diff` ran inside
# process substitution, so its exit status was discarded. An unresolvable base ref gave
# an empty URL list, indistinguishable from "this PR adds nothing", and the gate exited 0.
# Failing to look must never be reported as looking and finding nothing.
CHECKER="$SCRIPT_DIR/../check-entry-viability.sh"
( cd "$SCRIPT_DIR/.." && bash "$CHECKER" --base refs/heads/definitely-not-a-ref >/dev/null 2>&1 )
rc=$?
[ "$rc" -eq 2 ] && pass "G1 unresolvable base ref exits 2 (refuses to report)" \
                || fail "G1 unresolvable base ref exited $rc, wanted 2 — a silent pass"
( cd "$SCRIPT_DIR/.." && bash "$CHECKER" --base HEAD >/dev/null 2>&1 )
rc=$?
[ "$rc" -eq 0 ] && pass "G2 valid base with no new entries exits 0" \
                || fail "G2 valid base exited $rc, wanted 0"

echo
echo "== H: entry extraction — every legal Markdown bullet must be seen =="
# Sixth finding from independent review. The extractor matched only "- [", but CommonMark
# also allows * and + as bullets and permits leading indentation, so a validly-rendered
# entry produced an empty URL list and the gate exited 0 having checked nothing.
assert_extract() {  # <diff-line> <expected-count> <label>
  local n; n=$(printf '%s\n' "$1" | extract_entry_urls | grep -c .)
  if [ "$n" = "$2" ]; then pass "$3"; else fail "$3 — wanted $2 url(s), got $n"; fi
}
assert_extract '+- [a](https://github.com/o/r)'      1 "H1  dash bullet"
assert_extract '+* [a](https://github.com/o/r)'      1 "H2  asterisk bullet (was a bypass)"
assert_extract '++ [a](https://github.com/o/r)'      1 "H3  plus bullet (was a bypass)"
assert_extract '+  - [a](https://github.com/o/r)'    1 "H4  indented bullet (was a bypass)"
assert_extract "+$(printf '\t')- [a](https://github.com/o/r)"    1 "H5  tab-indented bullet"
# Positive controls: lines that must NOT be treated as new entries.
assert_extract '-- [a](https://github.com/o/r)'      0 "H6  REMOVED line is not a new entry"
assert_extract ' - [a](https://github.com/o/r)'      0 "H7  context line is not a new entry"
assert_extract '+Some prose with https://github.com/o/r inline' 0 "H8  prose link is not a list entry"
assert_extract '+## https://github.com/o/r'          0 "H9  heading is not a list entry"

echo
echo "== I: untrusted timestamps — future dates must not satisfy a freshness check =="
# Raised in review as a bypass. It is not one: git committer dates are attacker-controlled,
# but a future date yields a NEGATIVE age and the non-negative-integer guard already
# rejects it. These assertions pin that behaviour so it cannot regress into a real bypass
# if the guard is ever loosened to accept signed integers.
assert_verdict expect-FAIL 300 -3000 9 999 "I1  future-dated HEAD commit rejected, not treated as fresh"
assert_verdict expect-FAIL -50 0     9 999 "I2  future-dated repo creation rejected"
assert_verdict expect-FAIL 300 -1    2 100 "I3  one day in the future is already rejected"

echo
echo "== J: reference-style links and fail-closed on unreadable entries =="
# Findings 8 and 9 from independent review. `- [Name][ref]` produced no URL at all, so the
# gate exited 0 having checked nothing; the first fix only read reference definitions from
# ADDED lines, so an entry pointing at a label that already existed in README still vanished.
# References now resolve against the whole post-change file. And since enumerating Markdown
# forms is a losing game, J6-J10 pin the structural rule: an entry whose URL cannot be
# resolved is a hard failure, never a skip.
JT="$(mktemp -d)"
# The fixture mirrors the POST-change README: it contains both the pre-existing reference
# and the one the diff adds. An earlier fixture omitted the added definition, which hid a
# double-counting bug because only one of the two code paths could fire.
printf '# T\n\n- [x](https://example.com/x)\n\n[existing-ref]: https://github.com/o/existing\n[proj]: https://github.com/o/r\n' > "$JT/README.md"
trap 'rm -rf "$JT"' EXIT

assert_extract2() {  # <diff> <expected-count> <label>
  local n; n=$(printf '%s\n' "$1" | extract_entry_urls "$JT/README.md" | grep -c .)
  if [ "$n" = "$2" ]; then pass "$3"; else fail "$3 — wanted $2 url(s), got $n"; fi
}
assert_unresolvable() {  # <diff> <expected-count> <label>
  local n; n=$(printf '%s\n' "$1" | unresolvable_entries "$JT/README.md" | grep -c .)
  if [ "$n" = "$2" ]; then pass "$3"; else fail "$3 — wanted $2, got $n"; fi
}

assert_extract2 '+- [P](https://github.com/o/r)'                            1 "J1  inline link"
assert_extract2 "$(printf '+- [P][proj]\n+[proj]: https://github.com/o/r')"  1 "J2  reference added in the same diff yields ONE url, not two"
assert_extract2 '+- [New][existing-ref]'                                    1 "J3  reference ALREADY in README resolves (was a bypass)"
assert_extract2 '+- [New][EXISTING-REF]'                                    1 "J4  reference labels are case-insensitive"
# A definition on its own is not an entry: a docs-only PR adding prose plus a link label
# must not be judged against the inclusion bar. An earlier version counted it and J5 locked
# that in — the assertion was wrong, not the code.
assert_extract2 '+[proj]: https://github.com/o/r'                           0 "J5  bare reference definition is NOT an entry"
# CommonMark allows an angle-bracketed destination in a reference definition.
assert_extract2 "+[proj2]: <https://github.com/o/r2>"                        0 "J12 angle-bracket definition alone is not an entry"
# The entry's OWN link destination is what gets judged — not merely the first URL on the
# line. Otherwise a trailing "docs: https://example.com" stands in for the real repository.
assert_extract2 "+- [P][existing-ref] — docs: https://example.com" 1 "J13 trailing URL does not displace the entry destination"
assert_extract2 "+- [P](https://github.com/o/r) - also https://example.com" 1 "J14 inline entry ignores a trailing URL"
# CommonMark allows an optional title after the destination; consuming it produced a
# malformed URL and rejected a valid entry.
assert_extract2 '+- [T](https://github.com/o/r "official site")'            1 "J11 link title does not corrupt the URL"

assert_unresolvable '+- [P](https://github.com/o/r)'  0 "J6  resolvable inline entry not flagged"
assert_unresolvable '+- [New][existing-ref]'          0 "J7  entry using an existing reference not flagged"
assert_unresolvable '+- [Ghost][no-such-ref]'         1 "J8  entry citing an UNDEFINED reference is flagged"
assert_unresolvable '+- [Mystery](#anchor)'           1 "J9  entry with no URL at all is flagged"
assert_unresolvable '+Some prose without a link'      0 "J10 non-list line is not flagged"
# Resolvability must use the SAME path the extractor uses. Accepting any URL anywhere on
# the line let an entry with an unresolvable leading destination look fine while the
# extractor found nothing — so the entry vanished from the gate entirely.
assert_unresolvable "+- [P](#anchor) — https://github.com/o/r"  1 "J15 trailing URL does not excuse an unresolvable destination"
assert_unresolvable "+- [P][undefined-ref] — https://github.com/o/r" 1 "J16 trailing URL does not excuse an undefined reference"

echo
echo "== K: _days_since rejects untrustworthy timestamps before arithmetic =="
# Tenth finding from independent review. Integer division truncates toward zero, so a
# timestamp less than a day in the future produced 0 — read downstream as "committed
# today" — and the non-negative guard never saw it. Epochs are now compared before dividing.
assert_days() {  # <iso> <expect-ok|expect-reject> <label>
  if out=$(_days_since "$1" 2>/dev/null); then
    [ "$2" = "expect-ok" ] && pass "$3 (${out}d)" || fail "$3 — wanted rejection, got ${out}d"
  else
    [ "$2" = "expect-reject" ] && pass "$3 (rejected)" || fail "$3 — wanted a value, got rejection"
  fi
}
# +1 minute and +1 hour usually stay on the SAME UTC date, so these fail against a guard
# that truncates to the calendar date — regardless of what time the suite runs. The earlier
# +12h version only crossed a date boundary some of the time and was therefore flaky.
assert_days "$(date -u -v+1M +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '+1 minute' +%Y-%m-%dT%H:%M:%SZ)" expect-reject "K1a 1 minute in the future rejected (same-day, was a bypass)"
assert_days "$(date -u -v+1H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '+1 hour' +%Y-%m-%dT%H:%M:%SZ)"   expect-reject "K1b 1 hour in the future rejected (usually same-day)"
assert_days "$(date -u -v+30d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '+30 days' +%Y-%m-%dT%H:%M:%SZ)" expect-reject "K2  30d in the future rejected"
assert_days "$(date -u +%Y-%m-%dT%H:%M:%SZ)"        expect-ok     "K3  now is accepted"
assert_days "2020-01-01T00:00:00Z"                  expect-ok     "K4  a past date is accepted"
assert_days "not-a-date"                            expect-reject "K5  unparseable input rejected"
assert_days ""                                      expect-reject "K6  empty input rejected"

echo
echo "== L: non-GitHub entries are SKIPPED, never fetched =="
# The checker used to fetch every contributor-supplied URL to prove the link resolved. That
# was an SSRF primitive from a CI runner — link-local metadata, runner-local services,
# redirect chains and DNS rebinding each needed separate mitigation — and it bought nothing
# a reviewer cannot see by clicking the link. Non-repo entries are now judged by a human
# against the metric CONTRIBUTING.md requires them to name.
CHK="$SCRIPT_DIR/../check-entry-viability.sh"
assert_url_verdict() {  # <url> <PASS|FAIL|SKIP> <label>
  local got
  got=$(bash "$CHK" --url "$1" 2>&1 | grep -oE '^  (PASS|FAIL|SKIP)' | head -1 | tr -d ' ')
  if [ "$got" = "$2" ]; then pass "$3"; else fail "$3 — wanted $2, got ${got:-none}"; fi
}
assert_url_verdict "https://example.com/anything"      SKIP "L1  non-GitHub URL is skipped, not fetched"
assert_url_verdict "http://169.254.169.254/"           SKIP "L2  metadata endpoint is skipped, not fetched"
assert_url_verdict "http://127.0.0.1:8080/"            SKIP "L3  loopback is skipped, not fetched"
assert_url_verdict "https://user@github.com/o/r"       FAIL "L4  malformed GitHub URL still fails closed"
assert_url_verdict "https://github.com:8443/o/r"       FAIL "L5  odd-port GitHub URL still fails closed"

echo
echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
