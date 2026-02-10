#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.." || exit 1

brew audit tlan16/tap/mac-cron
