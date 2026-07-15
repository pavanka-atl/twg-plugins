---
name: twg-setup
description: >
  Atlassian Teamwork Graph (TWG) gives Claude Code grounded Atlassian work
  context: discover in-flight work, pull Jira/Confluence/Bitbucket detail, map
  ownership and dependencies, triage reviews, roll up status, and run clean
  handoffs. Invoke to install, update, set up, authenticate, or health-check
  the `twg` CLI — including when `twg` is missing, TWG skills aren't visible,
  or doctor/auth output needs follow-up.
allowed-tools:
  - Bash
---

# TWG Setup for Claude Code

Goal: keep the `twg` binary current, authenticated, and healthy for Claude Code.
It ships no bundled binary — everything runs the real `twg` on PATH, so this
agent, other agents, and the terminal share one install and one set of skills.

## Drive It, Or Hand It Off?

Install, update, `twg setup`, and `twg login` are interactive — they print
URLs, codes, and prompts and wait for answers. Before running any of them,
confirm you have BOTH:

- non-sandboxed execution (escalate if supported), and
- an interactive terminal you can keep reading AND send input back to after
  the process starts.

A read-only TTY, or a `script`-style wrapper that can't feed input back,
does NOT qualify.

If you have both, drive it yourself: relay every device-login URL, code, and
prompt to the user, then write their answer back to the same terminal — never
invent answers. You may accept these specific prompts yourself without asking
the user first, taking the shown default (the capitalized letter, e.g. `Y/n`
means yes — twg's CLI marks defaults this way): opening a browser/OAuth URL,
consent-to-continue prompts, and optional add-ons like Bitbucket setup. If
taking the default declines an optional add-on, say so afterward instead of
letting it pass silently (e.g. "Skipped Bitbucket setup by default — run
`twg setup bitbucket` later if you want it"). For anything destructive or
hard to undo — uninstall, force-overwriting existing
config or credentials — stop and ask the user instead of taking the default.
Never handle secrets: if a step asks for a password, token, API key, or
2FA/OTP code, stop and let the user type it directly into the terminal.

If you can't fully drive an interactive terminal, don't start install, setup,
or login. Run the read-only checks below, then hand the user the exact
commands to run themselves. Never ask them to paste back credentials, tokens,
login codes, or any auth prompt contents — auth stays in their terminal.
Sharing non-sensitive status, like a `twg doctor` summary, is fine.

## Flow

1. Inspect (safe anywhere) — check what's installed:

```bash
command -v twg || true
twg --version || true
```

2. Install if `twg` is missing:

```bash
curl -fsSL https://teamwork-graph.atlassian.com/cli/install | bash
```

   If `twg` is already installed, check for an update instead (read-only,
   safe anywhere) and only reinstall if it reports a newer version:

```bash
twg update --check
```

   If the check itself fails, don't assume a reinstall is needed — note
   that the version couldn't be confirmed and continue to step 3 anyway;
   don't probe other URLs or guess at install locations.

3. Health-check after any install or update, and even when `twg` was already
   current:

```bash
twg doctor
```

4. Remediate if doctor isn't healthy. Run whatever doctor recommends — often
   `twg setup` for first-time configuration, but follow doctor's own
   suggestion if it differs — then re-run doctor to confirm.

5. Re-authenticate if doctor or auth output says auth is missing, expired,
   invalid, or can't be refreshed:

```bash
twg login --force
twg doctor
```

6. Refresh skills if still hidden. If Claude Code still cannot see TWG
   skills, refresh its copy, then reload:

```bash
twg skills install --agent claude --yes
```

Summarize any remaining issue plainly. After an install or skill update,
start a new Claude Code session so new skills load.

## Try Next

When setup is healthy, suggest a few useful TWG prompts for Claude Code. Let the user pick the first work-data request to run.

- Summarize my work during the past month.
- Catch me up on PROJ-123, this Confluence page, or this project.
- What PRs are waiting on me, and which reviews are stale?
- I'm taking over on-call. Give me incidents, risks, runbooks, and follow-ups.
- Find owners, experts, related repos, and dependencies for this work.

## Handy Commands

- `twg doctor` — re-run this health check anytime.
- `twg upkeep status` — see last auth refresh and update state.
- `twg logout` — clear stored credentials.
- `twg skills install --agent claude --yes` — refresh this agent's skill copy explicitly.
