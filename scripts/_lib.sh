#!/usr/bin/env bash
# T-PUBSKILL01 · Shared library for LiteStartup skill scripts.
# Security: API key is read from file, NEVER echoed to stdout.

set -euo pipefail

# --- Configuration ---
CREDENTIALS_FILE="${HOME}/.litestartup/credentials"
CONFIG_FILE="litestartup.yaml"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Functions ---

ls_error() {
    echo -e "${RED}ERROR:${NC} $1" >&2
    exit 1
}

ls_warn() {
    echo -e "${YELLOW}WARN:${NC} $1" >&2
}

ls_ok() {
    echo -e "${GREEN}✅${NC} $1"
}

# Read API key from credentials file (NEVER echo it)
ls_get_api_key() {
    if [ ! -f "$CREDENTIALS_FILE" ]; then
        ls_error "No credentials found. Run ls-bind.sh first."
    fi
    cat "$CREDENTIALS_FILE"
}

# Read endpoint from litestartup.yaml (simple grep)
ls_get_endpoint() {
    local config_dir
    config_dir=$(ls_find_config_dir)
    if [ -z "$config_dir" ]; then
        ls_error "No litestartup.yaml found in workspace."
    fi
    grep -oP '(?<=endpoint:\s).*' "${config_dir}/${CONFIG_FILE}" | tr -d ' "'
}

# Find directory containing litestartup.yaml (search upward)
ls_find_config_dir() {
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -f "${dir}/${CONFIG_FILE}" ]; then
            echo "$dir"
            return
        fi
        dir=$(dirname "$dir")
    done
    echo ""
}

# Make authenticated API call (key from file, not from args)
ls_api() {
    local method="$1"
    local path="$2"
    local body="${3:-}"
    local endpoint
    local api_key

    endpoint=$(ls_get_endpoint)
    api_key=$(ls_get_api_key)

    local url="${endpoint}${path}"
    local args=(-s -X "$method" -H "Authorization: Bearer ${api_key}" -H "Content-Type: application/json")

    if [ -n "$body" ]; then
        args+=(-d "$body")
    fi

    local response
    response=$(curl "${args[@]}" "$url")

    # Parse response code
    local code
    code=$(echo "$response" | grep -oP '"code"\s*:\s*\K[0-9]+' 2>/dev/null || echo "0")

    if [ "$code" -ge 400 ] 2>/dev/null; then
        local message
        message=$(echo "$response" | grep -oP '"message"\s*:\s*"\K[^"]+' 2>/dev/null || echo "Unknown error")
        ls_error "API error ($code): $message"
    fi

    echo "$response"
}
