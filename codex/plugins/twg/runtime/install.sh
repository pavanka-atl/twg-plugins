#!/usr/bin/env bash
set -euo pipefail

VERSION="${TWG_PLUGIN_VERSION:-1.0.24}"
INSTALL_URL="${TWG_PLUGIN_INSTALL_URL:-https://teamwork-graph.atlassian.com/cli/install}"
POWERSHELL_INSTALL_URL="${TWG_PLUGIN_INSTALL_PS1_URL:-https://teamwork-graph.atlassian.com/cli/install.ps1}"
DRY_RUN="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [--dry-run]"
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

extract_semver() {
  sed -nE 's/.*([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -n 1
}

EXISTING_TWG="$(command -v twg || true)"
if [[ -n "${EXISTING_TWG}" ]]; then
  echo "TWG CLI is already installed: ${EXISTING_TWG}"
  EXISTING_VERSION_OUTPUT="$("${EXISTING_TWG}" --version 2>/dev/null || true)"
  if [[ -n "${EXISTING_VERSION_OUTPUT}" ]]; then
    echo "Installed version: ${EXISTING_VERSION_OUTPUT}"
  fi
  EXISTING_VERSION="$(printf "%s\n" "${EXISTING_VERSION_OUTPUT}" | extract_semver || true)"
  if [[ -n "${EXISTING_VERSION}" && "${EXISTING_VERSION}" != "${VERSION}" ]]; then
    echo ""
    echo "This Codex plugin was built for TWG v${VERSION}. If your installed CLI or skills are stale, run:"
    echo "  curl -fsSL ${INSTALL_URL} | bash"
  fi
  echo ""
  echo "The TWG CLI install already provides the operational binary and bundled skills."
  echo "Run health checks with:"
  echo "  twg doctor"
  echo ""
  echo "If Codex does not see updated TWG skills after setup or update, start a new Codex thread."
  exit 0
fi

echo "TWG CLI is not installed on PATH."
echo "This Codex plugin delegates setup to the hosted TWG installer so every agent and the terminal share one binary and one set of skills."
echo "Requested release: v${VERSION}"

OS="$(uname -s)"
case "${OS}" in
  MINGW*|MSYS*|CYGWIN*)
    echo "Windows installation must run from PowerShell or Command Prompt, not Git Bash/MSYS."
    echo "Run this in PowerShell:"
    echo "  \$installer = irm ${POWERSHELL_INSTALL_URL}; & ([scriptblock]::Create(\$installer)) -Version ${VERSION}"
    if [[ "${DRY_RUN}" == "true" ]]; then
      exit 0
    fi
    exit 1
    ;;
esac

if [[ "${DRY_RUN}" == "true" ]]; then
  echo "Dry run: would install TWG CLI with the hosted TWG installer:"
  echo "  curl -fsSL --retry 2 \"${INSTALL_URL}\" | bash -s -- --version ${VERSION}"
  exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required to run the hosted TWG installer." >&2
  exit 127
fi

curl -fsSL --retry 2 "${INSTALL_URL}" | bash -s -- --version "${VERSION}"

if command -v twg >/dev/null 2>&1; then
  echo ""
  echo "TWG CLI installed. Running a non-blocking health check:"
  twg doctor || true
  echo ""
  echo "If TWG skills were installed or updated, start a new Codex thread."
else
  echo "TWG installer completed, but twg is still not on PATH. Open a new shell or add the install directory to PATH." >&2
fi
