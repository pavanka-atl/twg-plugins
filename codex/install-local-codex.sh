#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKETPLACE_NAME="twg-local-marketplace"
PLUGIN_NAME="twg"
PLUGIN_KEY="${PLUGIN_NAME}@${MARKETPLACE_NAME}"
CODEX_HOME="${CODEX_HOME:-${HOME}/.codex}"
CODEX_CONFIG="${CODEX_HOME}/config.toml"
MARKETPLACE_FILE="${SCRIPT_DIR}/.agents/plugins/marketplace.json"
PLUGIN_MANIFEST="${SCRIPT_DIR}/plugins/${PLUGIN_NAME}/.codex-plugin/plugin.json"

if [[ ! -f "${MARKETPLACE_FILE}" ]]; then
  echo "Missing Codex marketplace manifest: ${MARKETPLACE_FILE}" >&2
  exit 1
fi
if [[ ! -f "${PLUGIN_MANIFEST}" ]]; then
  echo "Missing Codex plugin manifest: ${PLUGIN_MANIFEST}" >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required to update ${CODEX_CONFIG}." >&2
  exit 127
fi

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
  "${codex_bin}" plugin marketplace add "${SCRIPT_DIR}" >/dev/null 2>&1 || true
fi

python3 - "${CODEX_CONFIG}" "${MARKETPLACE_NAME}" "${SCRIPT_DIR}" "${PLUGIN_KEY}" <<'PY'
from __future__ import annotations

from datetime import datetime, timezone
import json
import sys
from pathlib import Path

config_path = Path(sys.argv[1])
marketplace_name = sys.argv[2]
marketplace_source = sys.argv[3]
plugin_key = sys.argv[4]

lines = config_path.read_text().splitlines() if config_path.exists() else []


def set_table_key(input_lines: list[str], *, header: str, key: str, value: str) -> list[str]:
    out: list[str] = []
    inside_target = False
    seen_target = False
    target_has_key = False

    for line in input_lines:
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            if inside_target and not target_has_key:
                out.append(f"{key} = {value}")
            inside_target = stripped == header
            if inside_target:
                seen_target = True
                target_has_key = False

        is_target_key = False
        if inside_target and "=" in stripped:
            is_target_key = stripped.split("=", 1)[0].strip() == key

        if is_target_key:
            out.append(f"{key} = {value}")
            target_has_key = True
        else:
            out.append(line)

    if inside_target and not target_has_key:
        out.append(f"{key} = {value}")

    if not seen_target:
        if out and out[-1] != "":
            out.append("")
        out.extend([header, f"{key} = {value}"])

    return out


timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
lines = set_table_key(lines, header="[features]", key="plugins", value="true")
lines = set_table_key(
    lines,
    header=f"[marketplaces.{marketplace_name}]",
    key="last_updated",
    value=json.dumps(timestamp),
)
lines = set_table_key(
    lines,
    header=f"[marketplaces.{marketplace_name}]",
    key="source",
    value=json.dumps(marketplace_source),
)
lines = set_table_key(
    lines,
    header=f"[marketplaces.{marketplace_name}]",
    key="source_type",
    value=json.dumps("local"),
)
lines = set_table_key(
    lines,
    header=f'[plugins."{plugin_key}"]',
    key="enabled",
    value="true",
)

config_path.parent.mkdir(parents=True, exist_ok=True)
config_path.write_text("\n".join(lines).rstrip() + "\n")
PY

cat <<EOF
Installed the TWG local Codex marketplace bundle.

Marketplace: ${SCRIPT_DIR}
Config:      ${CODEX_CONFIG}
Plugin:      ${PLUGIN_KEY}

Restart Codex and start a new thread before testing.
EOF
