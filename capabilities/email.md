# Capability: Send Email

> **Trigger**: User says "send email", "send newsletter", "email subscribers".
> **Script**: `scripts/ls-send-email.sh`

## Flow

1. Ask user for:
   - **To**: recipient email OR "subscribers" for newsletter
   - **Subject**: email subject line
   - **Body**: compose content (markdown supported)
2. Show preview and ask for confirmation
3. Run `scripts/ls-send-email.sh`
4. Script calls `POST /client/v2/emails` (or `/newsletters/send` for newsletters)
5. Report: "Email sent successfully" or error

## Important Notes

- Email content is NOT saved to git (it's a direct API call)
- Newsletter requires existing subscriber list in LiteStartup dashboard
- Markdown in body is converted to HTML by the server
- Always confirm with user before sending (irreversible action)

## Error Scenarios

| Error | Cause | Resolution |
|-------|-------|-----------|
| 401 | Invalid API key | Re-run `ls-bind.sh` |
| 422 | Invalid recipient or empty body | Fix input and retry |
| 429 | Rate limited | Wait (do NOT auto-retry) |
