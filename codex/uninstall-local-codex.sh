#!/usr/bin/env bash
set -euo pipefail

MARKETPLACE_NAME="twg-local-marketplace"
PLUGIN_NAME="twg"
PLUGIN_KEY="${PLUGIN_NAME}@${MARKETPLACE_NAME}"
CODEX_HOME="${CODEX_HOME:-${HOME}/.codex}"
CODEX_CONFIG="${CODEX_HOME}/config.toml"

rm -rf "${CODEX_HOME}/plugins/cache/${MARKETPLACE_NAME}/${PLUGIN_NAME}"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required to update ${CODEX_CONFIG}." >&2
  exit 127
fi

python3 - "${CODEX_CONFIG}" "${MARKETPLACE_NAME}" "${PLUGIN_KEY}" <<'PY'
from __future__ import annotations

import sys
from pathlib import Path

config_path = Path(sys.argv[1])
marketplace_name = sys.argv[2]
plugin_key = sys.argv[3]
if not config_path.exists():
    raise SystemExit(0)

headers_to_remove = {
    f"[marketplaces.{marketplace_name}]",
    f'[plugins."{plugin_key}"]',
}
out: list[str] = []
skip_block = False

for line in config_path.read_text().splitlines():
    stripped = line.strip()
    if stripped.startswith("[") and stripped.endswith("]"):
        skip_block = stripped in headers_to_remove
    if not skip_block:
        out.append(line)

config_path.write_text("\n".join(out).rstrip() + "\n")
PY

if [[ -n "${CODEX_BIN:-}" ]]; then
  codex_bin="${CODEX_BIN}"
elif command -v codex >/dev/null 2>&1; then
  codex_bin="$(command -v codex)"
elif [[ -x "/Applications/Codex.app/Contents/Resources/codex" ]]; then
  codex_bin="/Applications/Codex.app/Contents/Resources/codex"
else
  codex_bin=""
fi

if [[ -n "${codex_bin}" ]]; then
  "${codex_bin}" plugin marketplace remove "${MARKETPLACE_NAME}" >/dev/null 2>&1 || true
fi

cat <<EOF
Removed the TWG local Codex marketplace bundle.

Restart Codex if it is open.
EOF
