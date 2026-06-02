#!/usr/bin/env bash
# T-PUBSKILL01 · Bind a content repo to LiteStartup.
# Usage: ls-bind.sh [repo_url]
# If repo_url is not provided, uses the current git remote origin.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"

# --- Get repo URL ---
REPO_URL="${1:-}"
if [ -z "$REPO_URL" ]; then
    REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
fi
if [ -z "$REPO_URL" ]; then
    ls_error "Could not detect repo URL. Pass it as argument: ls-bind.sh <repo_url>"
fi

# --- Get API key from user ---
if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "No credentials found. Please paste your LiteStartup API key."
    echo "(Generate one at https://api.litestartup.com/settings/api-keys with scope 'system.publish')"
    echo ""
    read -rsp "API Key: " API_KEY_INPUT
    echo ""

    if [ -z "$API_KEY_INPUT" ]; then
        ls_error "API key cannot be empty."
    fi

    mkdir -p "$(dirname "$CREDENTIALS_FILE")"
    echo -n "$API_KEY_INPUT" > "$CREDENTIALS_FILE"
    chmod 600 "$CREDENTIALS_FILE"
    ls_ok "Credentials saved to ${CREDENTIALS_FILE}"
fi

# --- Call bind API ---
echo "Binding repo: ${REPO_URL}"
RESPONSE=$(ls_api POST "/client/v2/repo-sync/bind" "{\"repo_url\": \"${REPO_URL}\"}")

BINDING_ID=$(echo "$RESPONSE" | grep -oP '"binding_id"\s*:\s*\K[0-9]+' 2>/dev/null || echo "")
DOMAIN_SLUG=$(echo "$RESPONSE" | grep -oP '"domain_slug"\s*:\s*"\K[^"]+' 2>/dev/null || echo "")

if [ -z "$BINDING_ID" ]; then
    # Might be 409 (already bound) - extract from response
    BINDING_ID=$(echo "$RESPONSE" | grep -oP '"binding_id"\s*:\s*\K[0-9]+' 2>/dev/null || echo "unknown")
    DOMAIN_SLUG=$(echo "$RESPONSE" | grep -oP '"domain_slug"\s*:\s*"\K[^"]+' 2>/dev/null || echo "")
fi

# --- Create litestartup.yaml ---
ENDPOINT="https://api.litestartup.com"

cat > litestartup.yaml << EOF
version: 1
binding_id: ${BINDING_ID}
domain_slug: ${DOMAIN_SLUG}
endpoint: ${ENDPOINT}
repo_url: ${REPO_URL}
sync:
  blog:
    path: "blog/**/*.md"
  website:
    path: "website/**/*.html"
  docs:
    path: "docs/**/*.md"
  changelog:
    path: "changelog/**/*.md"
EOF

ls_ok "Created litestartup.yaml"
ls_ok "Repo bound successfully (binding_id: ${BINDING_ID})"
echo ""
echo "Next steps:"
echo "  1. git add litestartup.yaml && git commit -m 'init litestartup' && git push"
echo "  2. Create content in blog/, website/, docs/, changelog/"
echo "  3. Run ls-sync.sh to publish"
