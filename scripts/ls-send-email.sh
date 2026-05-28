#!/usr/bin/env bash
# T-PUBSKILL01 · Send email via LiteStartup (does NOT go through git).
# Usage: ls-send-email.sh --to=<email> --subject=<subject> --body=<body>
#    or: ls-send-email.sh --newsletter --subject=<subject> --body=<body>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"

# Parse arguments
TO=""
SUBJECT=""
BODY=""
NEWSLETTER=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --to=*) TO="${1#*=}"; shift ;;
        --subject=*) SUBJECT="${1#*=}"; shift ;;
        --body=*) BODY="${1#*=}"; shift ;;
        --newsletter) NEWSLETTER=true; shift ;;
        *) shift ;;
    esac
done

if [ -z "$SUBJECT" ]; then
    ls_error "Missing --subject"
fi

if [ -z "$BODY" ]; then
    ls_error "Missing --body"
fi

if [ "$NEWSLETTER" = true ]; then
    echo "Sending newsletter..."
    RESPONSE=$(ls_api POST "/client/v2/newsletters/send" "{\"subject\": \"${SUBJECT}\", \"content\": \"${BODY}\"}")
else
    if [ -z "$TO" ]; then
        ls_error "Missing --to (recipient email)"
    fi
    echo "Sending email to ${TO}..."
    RESPONSE=$(ls_api POST "/client/v2/emails" "{\"to_email\": \"${TO}\", \"subject\": \"${SUBJECT}\", \"content\": \"${BODY}\"}")
fi

ls_ok "Email sent"
echo "$RESPONSE"
