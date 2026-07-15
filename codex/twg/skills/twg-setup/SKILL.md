---
name: twg-setup
description: >
  Install, update, authenticate, or repair `twg` for Codex, including missing CLI
  or skills and doctor/auth follow-up. TWG gives Codex grounded work context across Jira, Confluence, Bitbucket, JSM, Assets, Slack,
  Google Drive, and more, so it can connect tickets, docs, code, people, and decisions; surface
  risks and dependencies; summarize progress; and keep work moving.
allowed-tools:
  - Bash
---

# TWG Setup for Codex

Use the installed `twg` CLI for Codex. This plugin ships no binary, wrapper, or local launcher.
Prefer `twg` on PATH; the flow below also resolves the standard launcher for a session that
predates the install.

## Before you act

- If non-sandboxed execution (escalate if supported) and an interactive terminal that can keep
  reading and send input back after the process starts are available, run the install, update,
  setup, or login flow below.
- Otherwise, only inspect read-only state. Do not run the installer, update, setup, or login;
  explain the limitation and give the user the exact commands instead.

## Interactive safety

- When `twg` shows an OAuth verification URL and user code, show both verbatim. The user can
  open the URL in any browser and enter the code. Never expose `device_code` or handle passwords,
  tokens, API keys, or 2FA/OTP codes.
- You may accept shown defaults for opening a browser, consent, and optional add-ons. Ask before
  uninstalling or overwriting configuration or credentials.

## Resolve the CLI

In Bash, run this once in the current terminal before the commands below. If it cannot resolve
the CLI, skip those commands and use the installer in step 2:

```bash
TWG_BIN="$(command -v twg || true)"
if [ -z "$TWG_BIN" ] && [ -x "$HOME/.local/bin/twg" ]; then
  TWG_BIN="$HOME/.local/bin/twg"
fi
if [ -z "$TWG_BIN" ]; then
  echo "twg was not found at the standard launcher path; install TWG or add its directory to PATH." >&2
  :
fi
```

On Windows PowerShell, use `& "$env:LOCALAPPDATA\Programs\twg\bin\twg.exe" <command>` when `twg` is not on PATH.

## Flow

1. Inspect (safe anywhere):

```bash
command -v twg || true
[ -n "$TWG_BIN" ] && "$TWG_BIN" --version || true
```

2. If neither `twg` nor the direct launcher can run, first explain that the
   official installer downloads the CLI and writes it to the standard install location.
   It installs its bundled skills. Ask the user for explicit approval before downloading
   or executing it. A setup request alone is not approval.

   Do not run either installer command until the user clearly approves. After
   approval, install:

   macOS / Linux:

```bash
curl -fsSL https://teamwork-graph.atlassian.com/cli/install | bash
```

   Windows PowerShell:

```powershell
curl.exe -fsSL https://teamwork-graph.atlassian.com/cli/install.ps1 -o "$env:TEMP\twg-install.ps1"
powershell -ExecutionPolicy Bypass -File "$env:TEMP\twg-install.ps1"
```

   Keep normal TWG skill installation enabled. Do not add `--skip-skills`: the
   installer must write the global TWG skill bundle.

3. With the resolved CLI, check for updates, then run doctor:

```bash
"$TWG_BIN" update --check
"$TWG_BIN" doctor
```

4. If doctor is not healthy, follow its recommendation. Run setup only if it recommends setup:

```bash
"$TWG_BIN" setup
```

   If doctor or auth output says auth is missing, expired, invalid, or can't be refreshed:

```bash
"$TWG_BIN" login --force
"$TWG_BIN" doctor
```

5. If Codex does not see TWG skills, or doctor reports a skill issue, refresh
   them at `~/.agents/skills`:

```bash
"$TWG_BIN" skills install --yes
```

Summarize any remaining issue plainly. After a skill install or refresh,
start a new Codex thread so new skills load.

## Continue The Original Request

When `doctor` is healthy, resume and complete the user's original request. Do not stop
at setup or ask the user to choose a new task.

## Things To Try

Only when the user's request was setup alone, offer a few useful TWG prompts for Codex:

- Summarize my work during the past month.
- What PRs are waiting on me, and which reviews are stale?
- I'm taking over on-call. Give me incidents, risks, runbooks, and follow-ups.
- Find owners, experts, related repos, and dependencies for this work.
