#!/usr/bin/env bash
#
# scripts/check-entry-viability.sh — objective inclusion gate for new README entries.
#
# WHY THIS EXISTS: CONTRIBUTING.md previously said only "high-quality and directly
# relevant", which gave no stated ground to decline on. Six contributor PRs then sat
# 5-51 days, because with no written bar the cheapest action is to not decide. This
# script makes the repo-backed half of the bar mechanical, so a decline cites a rule
# rather than a judgement call.
#
# The bar (see CONTRIBUTING.md "Inclusion bar"):
#   repo-backed entry : age >= 30d AND last commit <= 365d AND (contributors >= 2 OR stars > 50)
#   any other entry   : the link must resolve; the submitter names an external metric in the PR
#
# Star count alone is deliberately NOT sufficient on its own and deliberately NOT
# required: a real case had a 0-star repo with 4 contributors committing daily, and a
# 4-star repo with 1 contributor stale for 6 weeks. Contributor count is the better
# discriminator; stars are kept only as an alternative path for solo projects that
# have demonstrably found an audience (awesome-rust uses `stars > 50` likewise).
#
# ARCHITECTURE: the decision logic (`verdict_for_repo`) takes plain numbers and touches
# no network, so scripts/test/test-entry-viability.sh can drive it with synthetic values
# and assert it FAILS where it must. A gate never observed to fail has not been shown
# to be a gate.
#
# Usage:
#   check-entry-viability.sh                     # check entries added vs origin/main
#   check-entry-viability.sh --base <ref>        # ...vs an explicit base
#   check-entry-viability.sh --url <url> [...]   # check specific URLs
#   check-entry-viability.sh --self-test         # run the decision-logic tests
#
# Exit: 0 all new entries pass · 1 at least one fails · 2 usage/tooling error

set -uo pipefail

MIN_REPO_AGE_DAYS=30
MAX_COMMIT_AGE_DAYS=365
MIN_CONTRIBUTORS=2
MIN_STARS=50
# CONTRIBUTING.md asks for one entry per PR. This is a sanity ceiling, and exceeding it
# is an explicit FAILURE, never a silent truncation — a gate that quietly stops checking
# reports success for entries it never looked at.
MAX_ENTRIES=20

FAILED=0

_days_since() {  # <iso8601> -> whole days elapsed; fails on unparseable OR future timestamps
  local ts="$1" epoch now
  [ -n "$ts" ] || return 1
  # Parse the FULL timestamp including its time component. Truncating to the calendar date
  # first (an earlier version did) reads "later today" as local midnight, so a commit dated
  # a few hours ahead was accepted with age 0 — and made any test of the guard depend on
  # what time of day the suite ran.
  epoch=$(date -j -u -f '%Y-%m-%dT%H:%M:%SZ' "$ts" +%s 2>/dev/null) \
    || epoch=$(date -u -d "$ts" +%s 2>/dev/null) \
    || epoch=$(date -j -f '%Y-%m-%d' "${ts%%T*}" +%s 2>/dev/null) \
    || return 1
  now=$(date +%s)
  # Compare epochs BEFORE dividing: integer division truncates toward zero, so a near-future
  # timestamp would yield 0 rather than a negative the downstream guard could catch. Git
  # committer dates are attacker-controlled, so a future timestamp is untrustworthy input.
  [ "$epoch" -gt "$now" ] && return 1
  echo $(( ( now - epoch ) / 86400 ))
}

# verdict_for_repo <age_days> <commit_age_days> <contributors> <stars>
# Pure: no network, no globals mutated. Echoes "PASS" or "FAIL: <reason>".
verdict_for_repo() {
  local age="$1" commit_age="$2" contribs="$3" stars="$4"
  # Anything that is not a plain non-negative integer is rejected, never coerced.
  # This covers empty/absent API fields AND negative ages: git committer dates are
  # attacker-controlled, so a repo can carry a future-dated HEAD commit, which yields a
  # negative age. Rejecting rather than clamping keeps the gate closed on input it
  # cannot trust. (Tested: I1-I3.)
  for v in "$age" "$commit_age" "$contribs" "$stars"; do
    case "$v" in
      '') echo "FAIL: repository metadata missing from the API response"; return 0 ;;
      -*) echo "FAIL: repository reports a future date — metadata not trustworthy"; return 0 ;;
      *[!0-9]*) echo "FAIL: unreadable repository metadata"; return 0 ;;
    esac
  done
  if [ "$age" -lt "$MIN_REPO_AGE_DAYS" ]; then
    echo "FAIL: repository is ${age}d old, bar is ${MIN_REPO_AGE_DAYS}d"; return 0
  fi
  if [ "$commit_age" -gt "$MAX_COMMIT_AGE_DAYS" ]; then
    echo "FAIL: last commit ${commit_age}d ago, bar is ${MAX_COMMIT_AGE_DAYS}d"; return 0
  fi
  if [ "$contribs" -lt "$MIN_CONTRIBUTORS" ] && [ "$stars" -le "$MIN_STARS" ]; then
    echo "FAIL: ${contribs} contributor(s) and ${stars} stars — needs >=${MIN_CONTRIBUTORS} contributors or >${MIN_STARS} stars"
    return 0
  fi
  echo "PASS"
}

# resolve_reference <label> <readme-path> -> the URL for a Markdown reference definition,
# or empty. Reads the WHOLE post-change README, not just the diff: a new entry may point at
# a link label that already existed on an unchanged line, and looking only at added lines
# made such an entry resolve to nothing and vanish from the gate.
resolve_reference() {
  local label="$1" readme="${2:-README.md}"
  [ -f "$readme" ] || return 0
  awk -v want="$label" '
    {
      line = $0
      if (match(line, /^[[:space:]]*\[[^]]+\][[:space:]]*:[[:space:]]*[^[:space:]]+/)) {
        lb = line; sub(/^[[:space:]]*\[/, "", lb); sub(/\].*$/, "", lb)
        if (tolower(lb) == tolower(want)) {
          u = line; sub(/^[^:]*:[[:space:]]*/, "", u); sub(/[[:space:]].*$/, "", u)
          # CommonMark allows an angle-bracketed destination: [ref]: <https://...>
          gsub(/^</, "", u); gsub(/>$/, "", u)
          print u; exit
        }
      }
    }' "$readme"
}

# extract_entry_urls [readme-path] — reads a unified diff on stdin, echoes one URL per added
# entry. Handles inline `- [N](url)`, added reference definitions `[ref]: url`, and entries
# `- [N][ref]` whose label is defined anywhere in the post-change README.
extract_entry_urls() {
  # Deduplicated: a reference-style entry emits its URL from the list-item branch (resolved
  # against the post-change README) AND from the added-definition branch. Without this the
  # same entry is checked twice and counts twice against MAX_ENTRIES.
  _extract_entry_urls_raw "$@" | awk '!seen[$0]++'
}

_extract_entry_urls_raw() {
  local readme="${1:-README.md}" line dest label
  while IFS= read -r line; do
    case "$line" in +*) : ;; *) continue ;; esac
    # A reference definition is NOT itself an entry. It only supplies a destination for an
    # added list item, and resolve_reference reads the post-change README, so a definition
    # added by this same diff is already visible there. Emitting one independently made a
    # docs-only PR (prose plus a [label]: url) get judged against the inclusion bar.
    printf '%s' "$line" | grep -qE '^\+[[:space:]]*[-*+][[:space:]]+\[' || continue
    # Destination of the ENTRY'S OWN leading link — not merely the first URL on the line.
    # An entry like `- [P][ref] — docs: https://example.com` would otherwise be judged on
    # example.com while the repository behind [ref] went unchecked.
    dest=$(_entry_destination "$line")
    case "$dest" in
      http://*|https://*) printf '%s\n' "$dest"; continue ;;
      '') continue ;;
      *) label="$dest" ;;
    esac
    resolve_reference "$label" "$readme"
  done
}

# _entry_destination <added-diff-line> -> the inline URL of the entry's leading link, or its
# reference label, or empty. Parsed in Python: matching brackets by regex is what let a
# trailing URL elsewhere on the line stand in for the entry's real destination.
_entry_destination() {
  python3 - "$1" <<'PYEOF' 2>/dev/null
import re, sys
line = sys.argv[1]
m = re.match(r'^\+[ \t]*[-*+][ \t]+', line)
if not m:
    sys.exit(0)
rest = line[m.end():]
if not rest.startswith('['):
    sys.exit(0)
depth = 0
for i, ch in enumerate(rest):          # find the matching close bracket of the link text
    if ch == '[':
        depth += 1
    elif ch == ']':
        depth -= 1
        if depth == 0:
            after = rest[i+1:]
            if after.startswith('('):
                end = after.find(')')
                if end == -1:
                    sys.exit(0)
                dest = after[1:end].strip().split()[0] if after[1:end].strip() else ''
                print(dest.strip('<>'))
            elif after.startswith('['):
                end = after.find(']')
                if end > 0:
                    print(after[1:end])
            break
PYEOF
}

# unresolvable_entries [readme-path] — added list entries whose URL could NOT be determined,
# reference labels included. main() treats any output as a hard failure: enumerating valid
# Markdown forms is a losing game, refusing to pass an entry we could not read is not.
unresolvable_entries() {
  local readme="${1:-README.md}" line dest
  while IFS= read -r line; do
    case "$line" in +*) : ;; *) continue ;; esac
    printf '%s' "$line" | grep -qE '^\+[[:space:]]*[-*+][[:space:]]+\[' || continue
    # Resolvability is decided by the SAME path extract_entry_urls uses: the entry's own
    # leading destination. An earlier version accepted any URL anywhere on the line, so
    # `- [P](#anchor) — https://github.com/o/r` looked resolvable while the extractor found
    # nothing, and the entry vanished from the gate entirely.
    dest=$(_entry_destination "$line")
    case "$dest" in
      http://*|https://*) continue ;;
      '') printf '%s\n' "$line"; continue ;;
    esac
    if [ -n "$(resolve_reference "$dest" "$readme")" ]; then continue; fi
    printf '%s\n' "$line"
  done
}


# entry_count_verdict <count> -> "PASS" or "FAIL: <reason>". Pure.
entry_count_verdict() {
  local n="$1"
  case "$n" in ''|*[!0-9]*) echo "FAIL: could not count the entries in this change"; return 0 ;; esac
  if [ "$n" -gt "$MAX_ENTRIES" ]; then
    echo "FAIL: this change adds $n entries; the checker handles at most $MAX_ENTRIES. CONTRIBUTING.md asks for one entry per PR — please split it."
    return 0
  fi
  echo "PASS"
}

# _gh_api <path> — GitHub REST via curl, not `gh`. Works unauthenticated (60 req/hour,
# comfortably above the 20-entry ceiling) and uses GH_TOKEN when one is present. Using curl
# keeps the bootstrap path working: on the PR that adds this checker there is no trusted
# base copy, so it runs without a token, and `gh` refuses to run at all in that state.
_gh_api() {
  local path="$1"
  local -a hdrs=(-H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28')
  [ -n "${GH_TOKEN:-}" ] && hdrs+=(-H "Authorization: Bearer $GH_TOKEN")
  curl -sS --fail --proto '=https' --max-time 20 "${hdrs[@]}" "https://api.github.com/$path" 2>/dev/null
}

_check_github_repo() {  # <owner/repo> <original-url>
  local slug="$1" url="$2" meta created pushed stars contribs age commit_age verdict
  meta=$(_gh_api "repos/$slug") || {
    echo "  FAIL  $url"; echo "        repository not reachable via the GitHub API (private, renamed, or deleted)"
    FAILED=1; return
  }
  created=$(printf '%s' "$meta" | jq -r '.created_at // empty')
  # NOT pushed_at: that updates on any push to any branch or tag, so a dormant repo can
  # look current by re-pushing an old commit under a new ref. CONTRIBUTING.md promises
  # "last commit", so read the actual head commit of the default branch.
  #
  # There is deliberately NO fallback to pushed_at when this lookup fails. A fallback here
  # is a fail-OPEN: the lookup failing is exactly the case where we know least, and
  # substituting a weaker signal lets a stale repo through. An empty value propagates to
  # verdict_for_repo, which rejects it as missing metadata.
  local default_branch
  default_branch=$(printf '%s' "$meta" | jq -r '.default_branch // empty')
  if [ -z "$default_branch" ]; then
    echo "  FAIL  $url"; echo "        API did not report a default branch"; FAILED=1; return
  fi
  local branch_enc
  branch_enc=$(python3 -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$default_branch")
  pushed=$(_gh_api "repos/$slug/commits?per_page=1&sha=$branch_enc" \
             | jq -r '.[0].commit.committer.date // .[0].commit.author.date // empty' 2>/dev/null)
  if [ -z "$pushed" ]; then
    echo "  FAIL  $url"; echo "        could not read the last commit on '$default_branch' — refusing to fall back to a weaker signal"
    FAILED=1; return
  fi
  stars=$(printf '%s' "$meta"   | jq -r '.stargazers_count // 0')
  if [ "$(printf '%s' "$meta" | jq -r '.archived')" = "true" ]; then
    echo "  FAIL  $url"; echo "        repository is archived"; FAILED=1; return
  fi
  contribs=$(_gh_api "repos/$slug/contributors?per_page=100" | jq 'length' 2>/dev/null || echo 0)
  age=$(_days_since "$created") || age=""
  commit_age=$(_days_since "$pushed") || commit_age=""
  verdict=$(verdict_for_repo "${age:-x}" "${commit_age:-x}" "${contribs:-0}" "${stars:-0}")
  if [ "$verdict" = "PASS" ]; then
    echo "  PASS  $url  (${age}d old, last commit ${commit_age}d, ${contribs} contributors, ${stars} stars)"
  else
    echo "  FAIL  $url"; echo "        ${verdict#FAIL: }"; FAILED=1
  fi
}

# repo_slug_from_url <url> -> "owner/repo", or empty if the URL is not a GitHub repo.
# Pure: no network. Strips the fragment and query FIRST, then takes host + the first two
# path segments, so `?tab=readme-ov-file` (what GitHub's address bar gives you) and
# `#readme` cannot route a repository entry away from the repository checks.
# Deeper paths (/tree/main, /blob/...) still resolve to their owning repository.
# repo_slug_from_url <url> -> "owner/repo", or empty if the URL is not a GitHub repo URL.
#
# Parsed by Python's urlsplit rather than by shell string-munging. Four separate bypasses
# came out of hand-rolled parsing — a trailing `#fragment`, a `?query`, a mixed-case host,
# an explicit `:443`, and `user@github.com` userinfo — each of which classified a real
# repository as a plain link and skipped every threshold. Deferring to the same parser the
# HTTP client agrees with closes the whole class instead of one case at a time.
# Userinfo is rejected outright: it has no legitimate use in a list entry and is a classic
# way to make a URL's apparent host differ from its real one.
repo_slug_from_url() {
  python3 - "$1" <<'PYEOF' 2>/dev/null
import html, sys
from urllib.parse import urlsplit, unquote
RESERVED = {"", "orgs", "about", "features", "pricing", "sponsors",
            "collections", "topics", "marketplace", "settings", "apps"}
try:
    # CommonMark resolves character references inside a link destination, so
    # `https://github&#46;com/o/r` renders as and navigates to github.com. Decode before
    # parsing or the entry classifies as a non-GitHub link and skips every threshold.
    u = urlsplit(html.unescape(sys.argv[1].strip()))
    if u.scheme not in ("http", "https"):
        sys.exit(0)
    if u.username or u.password:     # userinfo: apparent host may differ from the real one
        sys.exit(0)
    # A single trailing dot makes a fully-qualified name that DNS treats as equivalent, but
    # urlsplit preserves it, so "github.com." compared unequal and the entry was skipped.
    host = (u.hostname or "").lower().rstrip(".")
    if host not in ("github.com", "www.github.com"):
        sys.exit(0)
    if u.port not in (None, 80, 443):
        sys.exit(0)
    parts = [p for p in unquote(u.path).split("/") if p]
    if len(parts) < 2:
        sys.exit(0)
    owner, repo = parts[0], parts[1]
    if repo.endswith(".git"):
        repo = repo[:-4]
    if owner.lower() in RESERVED or not repo:
        sys.exit(0)
    if any(c in owner + repo for c in "@ \t\n?#"):
        sys.exit(0)
    print(f"{owner}/{repo}")
except Exception:
    sys.exit(0)
PYEOF
}

# url_hostname <url> -> lowercased hostname via the same parser, or empty.
url_hostname() {
  python3 - "$1" <<'PYEOF' 2>/dev/null
import html, sys
from urllib.parse import urlsplit
try:
    print((urlsplit(html.unescape(sys.argv[1].strip())).hostname or "").lower().rstrip("."))
except Exception:
    pass
PYEOF
}

check_url() {
  local url="$1" slug host
  slug=$(repo_slug_from_url "$url")
  if [ -n "$slug" ]; then
    _check_github_repo "$slug" "$url"
    return
  fi
  # A URL pointing at GitHub that does not reduce to a plain owner/repo is a hard failure:
  # letting it through as "not a repo" is how a rejected repository dressed up with userinfo
  # or an odd port would skip the thresholds.
  host=$(url_hostname "$url")
  case "$host" in
    github.com|www.github.com)
      echo "  FAIL  $url"
      echo "        GitHub URL that does not resolve to a plain owner/repo — link to the repository directly"
      FAILED=1; return ;;
  esac
  # Everything else — hosted tools, price indexes, papers, guides — is NOT fetched. This
  # checker only judges what it can judge objectively. Fetching contributor-supplied URLs
  # from a CI runner was an SSRF primitive (link-local metadata, runner-local services,
  # redirect chains, DNS rebinding) and bought nothing the reviewer cannot see by clicking
  # the link. CONTRIBUTING.md requires the submitter to name an external metric for these;
  # confirming it is a human judgement, so the gate says so plainly instead of guessing.
  echo "  SKIP  $url"
  echo "        not a GitHub repository — reviewer confirms the external metric named in the PR"
}

main() {
  local base="origin/main" mode="diff" urls=()
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --base) base="${2:?--base needs a ref}"; shift 2 ;;
      --url)  mode="urls"; shift; while [ "$#" -gt 0 ] && [ "${1#--}" = "$1" ]; do urls+=("$1"); shift; done ;;
      --self-test) exec "$(dirname "$0")/test/test-entry-viability.sh" ;;
      -h|--help) sed -n '3,26p' "$0"; exit 0 ;;
      *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
  done

  for c in jq curl python3; do
    command -v "$c" >/dev/null || { echo "ERROR: required command '$c' not found" >&2; exit 2; }
  done

  if [ "$mode" = "diff" ]; then
    # Capture the diff and CHECK ITS STATUS before parsing. Running it inside process
    # substitution discards the exit code, so an unresolvable base ref yields an empty
    # list that is indistinguishable from "this PR adds no entries" — and the gate then
    # reports success for a change it never managed to read. Failing to look must never
    # be reported as looking and finding nothing.
    local diff_out
    if ! diff_out=$(git diff "$base"...HEAD -- README.md 2>&1); then
      echo "ERROR: could not diff README.md against '$base' — refusing to report a result." >&2
      printf '%s\n' "$diff_out" | head -3 | sed 's/^/  /' >&2
      exit 2
    fi
    # Match any added Markdown list item, not just "- [". CommonMark accepts -, * and +
    # as bullet markers and permits leading indentation, so a stricter pattern let a valid
    # rendered entry slip past the gate entirely.
    mapfile -t urls < <(printf '%s\n' "$diff_out" | extract_entry_urls README.md)

    local unresolvable
    unresolvable=$(printf '%s\n' "$diff_out" | unresolvable_entries README.md)
    if [ -n "$unresolvable" ]; then
      echo "ERROR: these added entries have no URL this checker can resolve:" >&2
      printf '%s\n' "$unresolvable" | sed 's/^/  /' >&2
      echo "Refusing to report a result for an entry that could not be read." >&2
      exit 2
    fi
  fi

  if [ "${#urls[@]}" -eq 0 ]; then
    echo "No new README entries in this change — nothing to check."; exit 0
  fi

  local count_verdict
  count_verdict=$(entry_count_verdict "${#urls[@]}")
  if [ "$count_verdict" != "PASS" ]; then
    echo "${count_verdict#FAIL: }" >&2
    exit 1
  fi

  echo "Checking ${#urls[@]} new entr$([ "${#urls[@]}" -eq 1 ] && echo y || echo ies) against the inclusion bar:"
  echo
  for u in "${urls[@]}"; do check_url "$u"; done
  echo
  if [ "$FAILED" -ne 0 ]; then
    echo "At least one entry does not meet the bar in CONTRIBUTING.md#inclusion-bar."
    echo "This is not a judgement about the project — it is the published threshold."
    exit 1
  fi
  echo "All new entries meet the bar."
}

# Run only when executed directly. Sourcing (as the test suite does) must expose the
# functions WITHOUT running main — otherwise the suite cannot drive verdict_for_repo.
if [ "${BASH_SOURCE[0]:-$0}" = "$0" ]; then
  main "$@"
fi
