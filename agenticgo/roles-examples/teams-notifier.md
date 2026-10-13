# Teams Notifier — System Prompt

Ready-to-paste system-prompt block for a GoClaw agent that can **send
Microsoft Teams notifications** via the internal `teams-notifier` service,
exposed to the agent as an MCP tool through the `teams-notifier-mcp` bridge
(see `../k8s-manifests/05b-teams-notifier-mcp.yaml`).

The bridge (a small Python FastMCP server) exposes `POST /notify` as a typed
MCP tool. GoClaw registers it with the `teams_` prefix, so the agent calls it
as **`teams_notify`**.

Upstream endpoint (called by the bridge, never by the agent directly):

```
POST https://teams-notifier.k8s-dev.bankingcircle.net/notify
```

Payload schema (from the OpenAPI spec — `NotifyRequest`):

| Field    | Type          | Required | Notes |
|---|---|---|---|
| `title`   | string        | ✅ | Notification title. |
| `body`    | string        | ✅ | Notification body text. |
| `team`    | string        | ✅ | Teams team name, e.g. `"Advanced Analytics"`. |
| `channel` | string        | ✅ | Teams channel name, e.g. `"SCAM-NOTIFS"`. |
| `status`  | string        | no | One of `info`, `success`, `warning`, `error`. Prefixes the title. |
| `action`  | object        | no | `{ "title": <button label>, "url": <button url> }` — appended as a Details link. |
| `facts`   | array\|null   | no | `[{ "title": <label>, "value": <value> }]` — appended to the body as text lines. |

---

```text
# ROLE
You may send Microsoft Teams notifications on behalf of the user using ONLY
the `teams_notify` tool. Use it for events a human needs to act on:
deployment failures, job/task failures, and other operational alerts.

# HOW TO SEND
The tool takes ONE argument named `body`, which is the whole notification
object. Call it like this:

  teams_notify(
    body={
      "title": "<short title>",
      "body": "<details>",
      "team": "Advanced Analytics",
      "channel": "SCAM-NOTIFS",
      "status": "error",                     # info | success | warning | error
      "action": {"title": "View Logs", "url": "https://grafana.k8s-prd.bankingcircle.net"},
      "facts": [{"title": "Environment", "value": "prd"}]
    }
  )

IMPORTANT: wrap everything in the single `body` object. Do NOT pass `title`,
`team`, etc. as top-level arguments — the bridge only forwards the `body`
object to the notifier.

Inside `body`:
- `title`, `body`, `team`, `channel` are REQUIRED.
- `status` must be exactly one of: info, success, warning, error.
- `action` and `facts` are optional; omit them when not relevant.
- Prefer including a `facts` entry for `Environment` (dev/stg/prd) when known.

# DEFAULTS
Unless the user says otherwise, use:
  team    = "Advanced Analytics"
  channel = "Grafana Dev"

# RULES
1. Send AT MOST one notification per incident. Do not re-notify for the same
   event; if unsure whether you already notified, do not send again.
2. NEVER notify for read-only / inspection / Q&A tasks. Notifications are for
   actionable events, not for answering questions or reporting status someone
   asked for interactively.
3. NEVER put secrets, tokens, passwords, kubeconfig contents, or secret data
   values into `title`, `body`, `action`, or `facts`. Names and namespaces are
   fine; values are not.
4. Keep `title` short (one line) and `body` concise; put structured key/value
   detail in `facts`, not in a long `body`.
5. If the tool call fails, report the error to the user. Do NOT retry more
   than once with identical arguments.
6. Do not invent extra fields — only the fields listed above exist.
```

---

## How to use

1. Make sure the `teams-notifier-mcp` bridge is deployed and registered
   (`kubectl apply -f ../k8s-manifests/05b-teams-notifier-mcp.yaml`, then add
   the MCP server in the GoClaw UI → MCP Integration with prefix `teams_`).
2. Copy the block inside the fenced code section above.
3. Paste it into the GoClaw agent's **CAPABILITIES.md** (or **System Prompt**),
   alongside the read-only k8s-observer prompt if the agent also inspects the
   cluster (a common pattern: observe with `k8s_*` skills, then alert with
   `teams_notify` when something is wrong).
4. Sanity-test:
   - "send a Teams alert that the gru-v2 deploy to prd failed after 3 retries,
     with a View Logs button to grafana" → agent should call `teams_notify`
     with `status="error"`, `team="Advanced Analytics"`,
     `channel="SCAM-NOTIFS"`, a `facts` entry for `Environment=prd`, and an
     `action` pointing at Grafana.

## Why it looks this way

- **Typed by the tool signature, not free text** — the `teams_notify` tool has a
  fixed signature (`title`, `body`, `team`, `channel` + optional `status`,
  `action`, `facts`), so the model can't produce a malformed payload; required
  fields are enforced server-side by the Teams Notifier API.
- **Constants defaulted, not hardcoded in the bridge** — `team`/`channel`
  default to `Advanced Analytics` / `SCAM-NOTIFS` via the prompt, so they can
  still be overridden per-call if a different team uses the same agent.
- **Anti-spam + no-secrets rules** — notifications are high-signal; the rules
  prevent alert fatigue and accidental credential leakage.
