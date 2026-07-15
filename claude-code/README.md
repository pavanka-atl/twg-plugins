# Atlassian Teamwork Graph CLI

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/twg-logo-dark.png">
  <img src="assets/twg-logo.png" alt="Atlassian Teamwork Graph logo" width="40" height="40">
</picture>

Grounded Atlassian work context for AI agents

Learn more at https://teamworkgraph.com/.

Install this Claude Code plugin when you want Claude to set up and use TWG CLI. TWG CLI skills let agents use the Atlassian Teamwork Graph to answer work-context questions, explain ownership and dependencies, summarize progress, and guide reviews or handoffs.

The setup bridge installs or reuses the `twg` binary. After setup, global TWG skills are available, not only from this plugin.

## Install

Add the Atlassian Claude Code marketplace and install the TWG plugin:

```bash
claude plugin marketplace add git@bitbucket.org:atlassian/claude-code-marketplace.git
claude plugin install twg@atlassian-marketplace
```

Start a new Claude Code session after installation, then ask Claude to `set up twg`.

Claude Code can inspect `twg` state, but install, update, setup, and login are interactive. Ask the user to run exact terminal commands for those flows; a TTY wrapper alone is not enough if Claude cannot send input after the command starts. Authentication stays in the user's terminal — never ask the user to paste back credentials, tokens, or login codes.

When user-run setup is needed, ask the user to run the installer and verification commands in a normal terminal:

```bash
curl -fsSL https://teamwork-graph.atlassian.com/cli/install | bash
twg doctor
```

If `twg` is already installed on your machine, keep using that binary when it is current and healthy:

```bash
twg doctor
twg skills install --agent claude --yes
```

Run the explicit skills command only when Claude Code was installed after the original TWG install and does not see TWG skills yet.

If `twg` is missing, stale, or doctor reports setup/auth/skill issues, tell the user to run the needed command in a normal terminal:

```bash
curl -fsSL https://teamwork-graph.atlassian.com/cli/install | bash
```

The version manifest is `https://teamwork-graph.atlassian.com/cli/manifest.json`.

After user-run setup or update, start a new Claude Code session so Claude can load newly installed skills.

## Things To Try

- Summarize my work during the past month.
- Catch me up on PROJ-123, this Confluence page, or this project.
- What PRs are waiting on me, and which reviews are stale?
- I'm taking over on-call. Give me incidents, risks, runbooks, and follow-ups.
- Find owners, experts, related repos, and dependencies for this work.

## Authenticate

If auth remains incomplete after install, ask the user to continue setup in a normal terminal:

```bash
twg setup
```

Credentials remain in the normal TWG auth store; the plugin contains no credentials.

## Why No Runtime Wrapper

The plugin intentionally does not include `bin/twg`, `runtime/run_twg.sh`, a SessionStart runtime-data hook, or a plugin-local `twg-bin`. Claude Code should call the `twg` binary directly after setup. This keeps Claude Code, terminal users, and other agents on one install and one set of skills.

The only bundled skill is `twg-setup`, which helps Claude find or install TWG CLI, verify Claude Code skills, authenticate, and run `twg doctor`.

## Claude Code Plugin Versus Atlassian MCP

If both this plugin and an Atlassian MCP/Rovo connector are installed, prefer TWG for workflows that need the TWG CLI command surface or bundled TWG skills.

Keep the Atlassian MCP connector available for workflows that explicitly need MCP connector tools that are not covered by TWG. Do not ask Claude to use both surfaces for the same Atlassian lookup unless you intentionally want to compare results.
