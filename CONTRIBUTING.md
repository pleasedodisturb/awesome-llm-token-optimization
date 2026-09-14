# Contributing

Contributions are welcome! This list is curated, not comprehensive -- entries should be high-quality and directly relevant to reducing LLM token costs.

## Guidelines

### Adding a resource

- Use the format: `- [Name](URL) - Description.`
- Description should be concise (one sentence) and end with a period
- Place entries in the correct category, alphabetically within their section
- Open source tools should include a star badge: `![Stars](https://img.shields.io/github/stars/owner/repo)`

### What qualifies

- Tools that reduce token usage, track costs, or optimize inference
- Research papers with concrete efficiency improvements (include year and key metric)
- Official provider docs on caching, batching, or cost features
- Comprehensive guides with actionable strategies

### What doesn't qualify

- General LLM tutorials without a cost/efficiency angle
- Commercial products without a free tier or open source component
- Duplicate entries (check existing links first)
- Abandoned projects (no commits in 12+ months, unless seminal)
- Projects that do not meet the [inclusion bar](#inclusion-bar) below

### Inclusion bar

Being relevant is necessary but not sufficient — the list is curated, so an entry also
has to show that someone other than its author finds it useful. These thresholds are
published so a decline cites a rule rather than a judgement call, and so you can tell
in advance whether it is worth opening the PR.

**If the entry is a GitHub repository**, all of these must hold. CI checks it
automatically on every PR (`scripts/check-entry-viability.sh`):

| Check | Threshold |
|---|---|
| Repository age | at least **30 days** old |
| Last commit | within the last **12 months** |
| Traction | at least **2 contributors** *or* more than **50 stars** |
| Not archived | — |

Two contributors *or* fifty stars, not both, and stars alone are never required. Star
count is a poor proxy on its own: a five-week-old project with four people committing
daily has more going for it than a solo repo with a handful of stars that has not moved
in two months. Either a second person is building it, or an audience has found it.

**If the entry is anything else** — a hosted tool, a price index, a paper, a guide,
vendor documentation — CI does not judge it, and deliberately does not fetch it. In the
PR description, name the external evidence that it is used and maintained: downloads, a
public changelog, citations, independent coverage, a versioned data feed. Any concrete,
checkable signal is fine; "it is useful" is not one. A human confirms it, which is the
honest description of what was always happening.

**Self-submission is welcome.** Most entries here were submitted by their authors and
that is normal for a curated list. The PR template asks you to disclose it, which costs
you nothing — the bar above is the same either way. What is not accepted, following
[awesome-python](https://github.com/vinta/awesome-python/blob/master/CONTRIBUTING.md),
is *coordinated multi-entry self-promotion*: several related projects from the same
author or organisation, in one PR or across several.

**Below the bar today is not a no forever.** These are thresholds, not verdicts. If your
project is three weeks old or has just you working on it, come back — the check is
mechanical and it will pass when the numbers do.


### Process

1. Fork the repo
2. Add your entry in the correct section
3. Open a PR with a brief description of why this resource is valuable
4. One entry per PR preferred (easier to review)

### Academic papers

- Include: title, arxiv link, year, and one-line key result
- Prefer papers with code or reproducible results
- Include seminal older papers if they're foundational to a technique

## Quality standards

- All links must be working (no 404s)
- Descriptions must be factual and verifiable
- No affiliate links or tracking parameters
- English language only (for now)
