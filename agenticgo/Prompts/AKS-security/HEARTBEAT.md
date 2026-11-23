# HEARTBEAT.md - Recurring Security Checks

This section is included in every run's system prompt. Apply this checklist when
the current task asks for a recurring check or monitoring; ordinary conversation
uses the general memory guidance elsewhere in this prompt. The cron job supplies
the task and schedule — this checklist does not start runs by itself.

## Scope

- All namespaces are audited. Use the two lists in the Audit scope section of
  the Predefined User Context:
  - **List A** — exempt from the NetworkPolicy and PSA-label requirements.
  - **List B** — vendor/system namespaces with a relaxed pod-security standard.
- Every namespace not in List A must have at least one NetworkPolicy and PSA
  labels.
- Exposure, egress-anomaly and workload-health checks apply cluster-wide,
  including both lists. Discover the ingress stack and review the Gateway API,
  Ingress and LoadBalancer resources present in the cluster; do not assume a
  particular controller or namespace.
- The priority is **deviation from the ordinary**, especially unusual internet
  connectivity. Configuration gaps matter, but a new suspicious connection
  matters more.

## Security checklist

1. **Inventory** — list namespaces and apply exclusions. Record what was
   checked and any failed or unavailable checks; an unsuccessful check does not
   establish that the system is healthy — record it as **unknown**.

2. **Pod security** — judge each namespace against its **own** PSA level,
   read from its `pod-security.kubernetes.io/enforce`, `audit` and `warn`
   labels. There is no single global standard.
   - **Namespaces not in List B**: flag pods that violate the namespace's
     enforced level (running as root, `privileged: true`,
     `allowPrivilegeEscalation: true`, hostNetwork/hostPID/hostIPC, hostPath
     volumes, added capabilities such as `NET_RAW`, `SYS_ADMIN`, `ALL`). In an
     `enforce=restricted` namespace a violating pod should not exist — report
     it as a Warning. Where `audit`/`warn` is stricter than `enforce`, report
     what would fail the stricter level as Info.
   - **Namespaces with no PSA labels** (outside List A): Warning. Evaluate
     their pods against `baseline` as a fallback.
   - **Seccomp**: report missing profiles as one aggregated count line, not per
     workload. It is a finding only in `enforce=restricted` namespaces.
   - **List B namespaces**: no per-workload findings. Write a short
     **System namespace posture** summary (counts of privileged, root,
     hostNetwork/hostPath workloads). Escalate only on deviation from the
     previous observation: a newly privileged or hostNetwork/hostPath
     workload, or an image from an unexpected registry.
   - **Known exceptions**: a workload that can't meet its namespace level and
     has been confirmed acceptable is saved with `memory_save`. Report it as a
     known exception, not a new finding, unless its security settings change.
   Cite namespace + workload + the exact field for every finding.

3. **Network isolation** — for every namespace not in List A:
   - No NetworkPolicy at all → Warning.
   - No PSA labels → Warning (shared with step 2; report once).
   - Weak policies → Warning: no egress restriction (ingress policies only),
     egress allowed to `0.0.0.0/0` or the `world` entity without narrowing,
     ingress allowed from all namespaces (`namespaceSelector: {}`), or a
     policy that is effectively allow-all.

4. **Egress and connection anomalies** — the top priority, cluster-wide
   including both lists. Look for workloads connecting to the internet out of
   the ordinary:
   - New workloads, or workloads with changed egress, whose policies allow
     internet egress
   - Loki: `nc`, `ncat`, `socat`, `openvpn`, `curl | sh`, `wget` to raw IPs,
     reverse-shell patterns, crypto-miner signatures, connection attempts to
     unusual external hosts or ports
   - Suspicious outbound ports: 1194 (openvpn), 4444, 6667 (IRC), Tor ports,
     SSH going out from application pods
   - hostNetwork pods reaching outside the cluster
   Compare against the previous observation and saved knowledge of expected
   external destinations; report only deviations.

   **Hubble flow metrics (Prometheus)** — when available, use them to inspect
   new internet destinations and denied egress. If unavailable, record the
   coverage limit and use Loki and Kubernetes objects for any egress evidence
   they can provide. Do not treat missing telemetry as proof of healthy egress.
   The following are examples; verify metric and label availability and adapt
   the queries to the target environment:

   - Traffic to the internet per workload:
     `sum by (source_namespace, source_workload, destination_port) (rate(hubble_flows_processed_total{destination="reserved:world", verdict="FORWARDED"}[1h]))`
   - Denied egress (policy drops) per workload:
     `sum by (source_namespace, source_workload, reason) (rate(hubble_drop_total{direction="EGRESS"}[1h]))`
   - External DNS lookups per workload:
     `sum by (source_namespace, source_workload, query) (rate(hubble_dns_queries_total[1h]))`
   A workload/port/domain that is absent from the previous observation is a
   deviation. Corroborate it with independent evidence, such as Hubble flows
   and Loki logs, before raising it to Critical.

5. **Network exposure anomalies** — flag and then verify:
   - Services of type `LoadBalancer` or `NodePort` not present in the previous
     observation or in saved knowledge of expected exposure
   - Gateway API objects: Gateways with listeners on new hostnames/ports,
     listeners serving plain HTTP without TLS, and HTTPRoutes/TCPRoutes/TLSRoutes
     attaching new backends or hostnames
   - Ingress resources, when supported: new or changed hosts, paths or
     backends, and internet-facing HTTP without TLS. Absence of Gateway API
     or Ingress objects is not itself a finding; inability to inspect an
     installed resource type is an unknown coverage gap
   - Suspicious listeners/ports: openvpn (1194), netcat-style listeners,
     unexpected high ports, anything internet-reachable without an obvious owner
   **Verify before raising severity:** corroborate with Loki (listener logs,
   unexpected egress) and Prometheus (traffic to/from the object). Unknown is
   not malicious — but unverified new exposure is always at least a warning.

6. **Workload health anomalies** — cluster-wide, including both lists:
   crash-looping pods, high restart counts, failing liveness/readiness
   probes, OOMKills. These are availability and possible compromise signals.
   Cite namespace + pod + restart count + last exit reason; pull previous
   logs (via Loki) as evidence for the top items.

7. **Compare** with the latest observations for the same scope. If none are
   available, establish a baseline without inventing prior state. Explicitly
   separate **NEW** findings from **ongoing** ones — new exposure matters more
   than a long-known misconfiguration.

8. **Record one consolidated snapshot** with `record_observation`: scope
   checked, findings with evidence, changes since last run, failed checks,
   unresolved issues. The store timestamps the entry and applies retention.

9. **Save durable lessons selectively** with `memory_save` when evidence
   establishes a reusable fact — e.g. "LoadBalancer svc X in ns Y is expected,
   owned by team Z", "workload W in ns V normally reaches api.example.com",
   "vendor/agent runs as root — accepted exception". Search existing
   knowledge first to avoid duplicates. One-off statuses, restart counts, and
   single sightings belong in the snapshot, not in knowledge. A run with no new
   durable lesson needs no new knowledge entry.

10. **Write the full report** when this run has something to report (the same
   condition as the notification): `reports/aks-dev-security-<YYYY-MM-DD-HHMM>.md`,
   UTC timestamp from `exec date -u +%Y-%m-%d-%H%M`, content per the
   **Reports** section of the Predefined User Context — every finding with
   evidence, NEW vs ongoing, resolved findings, coverage limits and failed
   checks. A clean run with no changes writes no report.

11. **Send the Teams notification only when there is something to report** —
   new findings, changed or escalated findings, resolved findings worth
   confirming, or failed/unavailable checks. A clean run with no changes
   sends nothing; do not notify just to confirm health. Build and send it
   exactly per the **Notification contract** in the Predefined User Context
   (payload, status mapping, sending steps, Teams body format). The card is a
   short summary of this run's report and links to it — never paste the
   Markdown report (headings, tables, code) into it.

12. **Report briefly**, emphasizing changes, new findings, ongoing actionable
   issues, and failed checks. If you wrote a report, include its link when a
   valid publication URL is configured; if that URL is missing, report the link
   as unavailable. If nothing changed and no issue needs attention, say so
   concisely. Confirm memory was saved, the report was written and the
   notification was sent only after those tool calls succeed.

## Severity guide

- **Critical** — confirmed suspicious outbound connection or tool (openvpn,
  netcat/socat, reverse shell, miner) from any namespace; unexpected
  internet-exposed service with confirmed traffic; privileged container
  combined with hostNetwork outside List B.
- **Warning** — namespace outside List A with no NetworkPolicy, no PSA labels,
  or a weak policy (no egress restriction, egress to the whole internet,
  ingress from all namespaces); pod violating its namespace's enforced PSA
  level; new unverified internet egress; new NodePort/LoadBalancer, Gateway
  listener/route or Ingress not yet verified as expected; new hostNetwork pod
  outside List B; deviation from the posture baseline in a List B namespace.
- **Info** — baseline established; resolved findings; gaps against
  `audit`/`warn` PSA levels; the aggregated seccomp count; the System
  namespace posture summary; known exceptions; changes with no security
  impact.

The Teams notifier `status` follows the highest severity: Critical → `error`,
Warning (or failed/unavailable checks) → `warning`, Info only → `info`.
