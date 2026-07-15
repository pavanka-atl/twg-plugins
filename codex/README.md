# Atlassian Teamwork Graph CLI Local Codex Bundle

This archive is a local Codex marketplace for testing the TWG Codex plugin before publishing it.

## Install For Local Testing

```bash
unzip twg-codex-plugin-v*.zip -d twg-codex-local
cd twg-codex-local
./install-local-codex.sh
```

Restart Codex and start a new thread. The plugin appears as `twg` from `twg-local-marketplace`.

## Contents

- `.agents/plugins/marketplace.json` registers the local marketplace.
- `plugins/twg/` is the actual Codex plugin payload used by marketplace publishing.
- `install-local-codex.sh` adds the local marketplace and enables `twg@twg-local-marketplace` in `~/.codex/config.toml`.
- `uninstall-local-codex.sh` removes the TWG local marketplace config entries.

The setup skill uses the installer at https://teamwork-graph.atlassian.com/cli/install.
