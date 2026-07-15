# Atlassian Teamwork Graph CLI

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/twg-logo-dark.png">
  <img src="assets/twg-logo.png" alt="Atlassian Teamwork Graph logo" width="40" height="40">
</picture>

Grounded Atlassian work context for AI agents

Learn more at https://teamworkgraph.com/.

Install this Codex plugin when you want Codex to set up and use TWG CLI. TWG CLI skills let agents use the Atlassian Teamwork Graph to answer work-context questions, explain ownership and dependencies, summarize progress, and guide reviews or handoffs.

The setup bridge installs or reuses the `twg` binary. After setup, global TWG skills are available, not only from this plugin.

## What Is Included

- `.codex-plugin/plugin.json` declares the Codex plugin metadata and user-facing `Atlassian Teamwork Graph` name.
- `skills/twg-setup/SKILL.md` helps Codex check, install, update, and verify `twg` CLI.
- `runtime/install.sh` delegates first-time installation to the hosted TWG installer.
- `runtime/manifest.json` records the version and default TWG auth setup command for plugin consumers.

## Install

Install `Atlassian Teamwork Graph` from the Atlassian Codex marketplace, then ask Codex to `Set up TWG CLI`.

Setup must run outside the sandbox via escalation when needed and inside an interactive PTY/background terminal that lets Codex keep reading output and send input as prompts appear.

If that execution mode is unavailable, ask the user to run the installer and verification commands in a normal terminal:

```bash
curl -fsSL https://teamwork-graph.atlassian.com/cli/install | bash
twg doctor
```

If `twg` is already installed on your machine, keep using that binary when it is current and healthy:

```bash
twg doctor
```

The version manifest is `https://teamwork-graph.atlassian.com/cli/manifest.json`.

If `twg` is missing, stale, or doctor reports setup/auth/skill issues, run the installer from the same PTY:

```bash
curl -fsSL https://teamwork-graph.atlassian.com/cli/install | bash
```

Watch the PTY and relay exact prompts, device-login URLs, verification codes, and requested user actions back to the user. Never handle secrets: if a step asks for a password, token, or 2FA/OTP code, let the user type it directly, and never ask the user to paste credentials back to you. Start a new Codex thread after setup or update so Codex can load newly installed skills.

## Things To Try

- Summarize my work during the past month.
- Catch me up on PROJ-123, this Confluence page, or this project.
- What PRs are waiting on me, and which reviews are stale?
- I'm taking over on-call. Give me incidents, risks, runbooks, and follow-ups.
- Find owners, experts, related repos, and dependencies for this work.

## Why No Runtime Wrapper

The plugin intentionally does not include `runtime/run_twg.sh` or a plugin-local `twg-bin`. Codex should call the `twg` binary directly after setup. This keeps Codex, terminal users, and other agents on one install and one set of bundled skills.

## Codex Plugin Versus Atlassian MCP

If both this plugin and an Atlassian MCP/Rovo connector are installed, prefer TWG for workflows that need the TWG CLI command surface or bundled TWG skills.

Keep the Atlassian MCP connector available for workflows that explicitly need MCP connector tools that are not covered by TWG. Do not ask Codex to use both surfaces for the same Atlassian lookup unless you intentionally want to compare results.
