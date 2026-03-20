---
name: infra-dev
description: >
  Infrastructure and deployment knowledge for kcode-v3.
  Covers Garden.io orchestration, Helm charts, Docker builds,
  Kubernetes deployment safety, and CI/CD conventions.
  Use when working on any infrastructure or deployment task —
  including deploys, Kubernetes clusters, namespaces, pods,
  Helm charts, Dockerfiles, Garden.io configs, and deployment debugging.
---

# Infrastructure Development Skill

> Deployment rules, config patterns, and conventions for `gardens/`, `helm/`, and service Dockerfiles.

## Use this skill when

- Implementing, modifying, or debugging Garden.io configs in `gardens/**`
- Working with Helm charts in `helm/**`
- Modifying Dockerfiles or container build configs
- Setting up or troubleshooting deployment workflows
- Reviewing infrastructure PRs or understanding deployment architecture

## Do not use this skill when

- Working exclusively on backend application code, frontend, or other apps
- The task has no infrastructure or deployment component

---

## Stack and Runtime

- Orchestration: Garden.io
- Container runtime: Docker
- Kubernetes deployment: Helm charts
- CI/CD: (to be documented - check `.gitlab-ci.yml` or GitHub Actions)
- Services: backend, frontend apps, litellm, mermaid-ast-server, mlflow

## Quick Commands

> **Always set `KUBECONFIG`** before running Garden — without it, Garden can't resolve the cluster context.

```bash
export KUBECONFIG=/root/repo/ink/kcode-v3/.devops/ink-dev-cluster.yaml
```

> **Note:** The path above is the default for the CI runner / devops setup. On local machines, adjust to your cluster config location.

> **Use Garden's bundled tools** (`garden tools kubectl/helm`) to avoid version mismatch with the cluster.

```bash
garden tools kubectl -- --kubeconfig .devops/ink-dev-cluster.yaml -n <namespace> <command>
garden tools helm   -- --kubeconfig .devops/ink-dev-cluster.yaml -n <namespace> <command>
```

The namespace follows: `kcode-v3-<branch-name>` (slashes → dashes). E.g. `ninhchu/helm` → `kcode-v3-ninhchu-helm`.

### Garden workflows (run from repo root)

| Command | Purpose |
|---------|---------|
| `KUBECONFIG=... garden validate` | Validate configs |
| `KUBECONFIG=... garden build` | Build all services |
| `KUBECONFIG=... garden deploy -l3` | Deploy (verbose) |
| `KUBECONFIG=... garden cleanup deploy` | Tear down deploy |
| `garden delete environment --env dev` | **DESTRUCTIVE** - destroy environment ⚠️ |

### Helm (via garden tools)

| Command | Purpose |
|---------|---------|
| `garden tools helm -- ... -n <ns> list --all` | See all releases + status |
| `garden tools helm -- ... -n <ns> history <release>` | Show revision history |
| `garden tools helm -- ... -n <ns> uninstall <release> --wait --timeout 120s` | Force clean uninstall |

### Building images

Always use `garden build` — never raw `docker build`. Garden handles tagging, registry push, caching, and dependency ordering.

```bash
# Build a specific service
KUBECONFIG=... garden build <service-name>

# Build all services
KUBECONFIG=... garden build

# Build then deploy in one pass
KUBECONFIG=... garden deploy -l3
```

The built image tag is available as `${actions.build.<name>.outputs.deploymentImageTag}` — referenced in `gardens/deploy/kcode-v3.garden.yaml`.

---

## Deployment Monitoring Workflow

**Never blindly wait for `garden deploy` to finish.** Garden only reports overall success/failure — it won't catch app-level problems like crash loops or misconfigurations until it times out (~20 min). Instead, run garden in the background and watch the cluster in parallel.

### The correct deploy loop

```
1. Start garden deploy in background (or a separate terminal)
   KUBECONFIG=... garden deploy -l3

2. Immediately start watching the cluster in another terminal
   garden tools kubectl -- ... -n <namespace> get pods -w

3. As soon as pods appear, check their status:
   - All Running? → let garden finish normally
   - Any CrashLoopBackOff / Error / Init stuck? → start debugging NOW

4. Diagnose the root cause (logs, describe, Helm state)
   - Do NOT apply fixes yet while garden is still running
   - garden holds a Helm lock; applying changes mid-deploy causes
     "another operation in progress" on the next attempt

5. Once you understand the problem:
   a. Stop the garden terminal (Ctrl+C)
   b. Wait for Helm to finish its current operation or rollback
      garden tools helm -- ... -n <namespace> list --all
      # Wait until status is NOT "pending-*"
   c. Apply the fix (config change, secret, etc.)
   d. Run garden deploy again

6. If the release ends up in "failed" state after stopping:
   → helm uninstall --wait, then redeploy (see below)
```

### Watching the cluster during deploy

```bash
# Watch pod status in real time
garden tools kubectl -- ... -n <namespace> get pods -w

# Stream logs from a specific pod as it starts
garden tools kubectl -- ... -n <namespace> logs -f <pod> --previous

# Check events for scheduling/volume failures
garden tools kubectl -- ... -n <namespace> get events --sort-by='.lastTimestamp' | tail -20
```

---

## Deployment Debugging

When something goes wrong, work **from symptoms → root cause** using this mental model:

```
Pod not healthy?
  → What is the pod status? (get pods)
  → What does the log/event say? (logs --previous, describe pod)
  → Is it a missing secret/configmap, crash, or scheduling issue?

Helm upgrade failed?
  → Is the release stuck in "failed" state? (helm list --all)
  → Did --atomic rollback also fail? (leaves release permanently locked)
  → Fix: helm uninstall --wait, then redeploy

garden command hangs?
  → Is kubectl delete --wait=true running? (ps aux | grep kubectl)
  → Which CRD has a finalizer blocking deletion?
  → Fix: patch out the finalizer, let deletion proceed
```

### Step 1 — Check pod status

```bash
garden tools kubectl -- ... -n <namespace> get pods
```

| Status | Meaning |
|--------|---------|
| `CrashLoopBackOff` | App crashing on startup — read logs |
| `CreateContainerConfigError` | Missing Secret or ConfigMap |
| `Init:0/1` | Init container stuck — often missing volume or configmap |
| `Pending` | Not scheduled — PVC not bound or node pressure |

```bash
# Read crash logs (--previous is key for CrashLoopBackOff)
garden tools kubectl -- ... logs <pod> --previous

# Events and volume errors
garden tools kubectl -- ... describe pod <pod>
```

### Step 2 — Check the Helm release state

```bash
garden tools helm -- ... -n <namespace> list --all
```

If status is `failed` or `pending-upgrade`, the release is **locked**. No further deploys or cleanups will work until this is resolved.

**Fix: force uninstall then redeploy**
```bash
garden tools helm -- ... -n <namespace> uninstall <release> --wait --timeout 120s
KUBECONFIG=... garden deploy -l3
```

### Step 3 — If uninstall or cleanup hangs: find stuck finalizers

Garden's `cleanup deploy` and `helm uninstall --wait` can hang indefinitely if a CRD operator hasn't removed its finalizer (e.g. because a dependency secret is missing).

```bash
# See which kubectl process is blocking
ps aux | grep kubectl | grep delete

# Check if a specific CRD has a finalizer + deletionTimestamp
garden tools kubectl -- ... -n <namespace> get <crd-kind> <name> \
  -o jsonpath='{.metadata.deletionTimestamp}{"\n"}{.metadata.finalizers}'

# Force-remove the finalizer to unblock deletion
garden tools kubectl -- ... -n <namespace> \
  patch <crd-kind> <name> \
  -p '{"metadata":{"finalizers":null}}' --type=merge
```

Known CRDs with finalizers in this project:
- `redisreplications.redis.redis.opstreelabs.in` → `redisReplicationFinalizer`
- `clusters.postgresql.cnpg.io` → CNPG operator finalizer
- `records.dns.cloudflare.upbound.io` → `finalizer.managedresource.crossplane.io` (Crossplane)

### Known Failure Patterns

**`garden cleanup deploy` hangs for 5+ minutes**
Caused by `kubectl delete --wait=true` blocked on operator CRD finalizers. The operator can't process the finalizer because a secret it depends on doesn't exist (which itself doesn't exist because the release was in `failed` state). Find the blocking CRD and patch out the finalizer.

**Helm `failed` state after `--atomic` rollback also fails**
This happens when the rollback encounters resources in a partially-applied state (e.g. Ingress referencing services that don't exist yet). The release becomes permanently locked. Only `helm uninstall` can recover it.

**`Could not read cluster from kubeconfig for context`**
Garden couldn't find the cluster. Set `KUBECONFIG` env var before running any garden command.

**`Large number of files (N) found in Build action`**
Garden is scanning `.venv`, `node_modules`, etc. because `.gardenignore` is missing or incomplete. Add them to `.gardenignore` at the project root.

**oauth2-proxy `upstream ids must be unique` / `upstream paths must be unique`**
oauth2-proxy derives an upstream ID from the URL path. Two upstreams with the same path suffix crash the proxy. Check the `upstreams = [...]` list in `gardens/deploy/kcode-v3.garden.yaml` for duplicates (e.g. two entries ending in `/docs`).

---

## Network & Routing Debugging

When a service returns wrong content or unexpected redirects, **don't guess — trace the actual traffic**. The fastest way is to stream nginx logs from multiple pods in parallel while making a live request.

### Watch which pod actually receives a request

```bash
# Stream logs from the suspected service in one terminal
garden tools kubectl -- ... -n <namespace> logs -f deploy/<service-name> | grep -v health

# Stream logs from the catch-all service in another
garden tools kubectl -- ... -n <namespace> logs -f deploy/kcode-client | grep "docs\|api"
```

Then make the request (browser reload or curl) and compare which pod logged it. This pinpoints misrouting without any guessing.

### Test a service directly from inside the cluster

```bash
# Spawn a throwaway curl pod inside the cluster namespace
garden tools kubectl -- ... -n <namespace> run curl-test \
  --image=curlimages/curl --restart=Never --rm -it -- \
  curl -sv http://<service-name>/<path>
```

Use `-sv` to see request/response headers — especially `Location:` for redirect debugging.

### oauth2-proxy upstream routing rules

oauth2-proxy routes requests to upstreams by **longest prefix match**, evaluated **left to right** in the `upstreams = [...]` list. Key rules:

| Rule | Detail |
|------|--------|
| **Order matters** | More specific paths must come before catch-all `/`. Put specific upstreams first. |
| **Trailing slash matters** | `http://svc:80/docs` matches `/docs` but NOT `/docs/`. Use `http://svc:80/docs/` to match both. |
| **Path is preserved** | oauth2-proxy does NOT strip the path prefix. `/docs/page` is forwarded as `/docs/page` to the upstream. |
| **Duplicate IDs crash** | Two upstreams with the same path suffix (e.g. both ending in `/docs`) cause a startup crash. |

```toml
# WRONG: kcode-client catches everything before user-docs
upstreams = ["http://kcode-client:80", "http://user-docs:80/docs/"]

# CORRECT: specific paths first, catch-all last
upstreams = ["http://backend:8000/api/", "http://user-docs:80/docs/", "http://kcode-client:80"]
```

### nginx redirect pitfalls in proxied environments

When nginx sits behind a reverse proxy (like oauth2-proxy), the `Host` header is the internal service name, not the public domain. This causes:

**Problem: `absolute_redirect on` (nginx default)**
nginx generates `Location: http://<internal-service-name>/path/` — the internal hostname leaks to the browser.

```nginx
# Fix: always use relative redirects behind a proxy
server {
    absolute_redirect off;
    ...
}
```

**Problem: 301 (Moved Permanently) for trailing-slash redirect**
Browsers cache 301 responses indefinitely. If the routing later changes, users stay broken until they clear cache manually.

```nginx
# Fix: use an explicit 302 for path canonicalization
location = /docs {
    return 302 /docs/;   # 302 = temporary, not cached
}

location /docs/ {
    index index.html;
    try_files $uri $uri/ /docs/index.html;
}
```

## Project Knowledge

### Garden Configs

- Root config: `project.garden.yml`
- Build configs: `gardens/builds/*.garden.yaml`
- Deploy configs: `gardens/deploy/*.garden.yaml`
- Workflow definitions: `gardens/workflows/*.garden.yaml`

### Helm Charts

- Chart root: `helm/kcode-v3-ink/`
- Chart definition: `helm/kcode-v3-ink/Chart.yaml`
- Values: `helm/kcode-v3-ink/values.yaml`
- Templates: `helm/kcode-v3-ink/templates/`
- Sub-charts: `helm/kcode-v3-ink/charts/`

### Service Dockerfiles

- Backend: `apps/backend/Dockerfile`
- Frontend: `apps/frontend/Dockerfile`
- kcode-client: `apps/kcode-client/Dockerfile`
- litellm: `apps/litellm/Dockerfile`
- mermaid-ast-server: `apps/mermaid-ast-server/Dockerfile`
- mlflow: `apps/mlflow/Dockerfile`

## Architectural Rules

1. **Garden Config Structure**
   - Separate build, deploy, and workflow concerns
   - Use Garden variables for environment-specific values
   - Keep service dependencies explicit in deploy configs
   - Test configs with `garden validate` before committing

2. **Helm Chart Conventions**
   - Follow Helm best practices for template structure
   - Use `values.yaml` for all configurable parameters
   - Include resource limits and requests
   - Define proper liveness/readiness probes
   - Maintain backward compatibility for chart upgrades

3. **Docker Best Practices**
   - Multi-stage builds for smaller images
   - Use appropriate base images (Alpine when possible)
   - Pin dependency versions
   - Minimize layer count
   - Don't include secrets in images

4. **Deployment Safety**
   - Always validate in dev environment first
   - Use rolling updates, not recreate strategy
   - Keep rollback capability ready
   - Document manual intervention steps if required

## Domain Attention Points

- **Service interdependencies**: Backend depends on PostgreSQL, Weaviate; frontend depends on backend
- **Environment variables**: Many services require specific env vars (check `.env.example` files)
- **Resource allocation**: Monitor resource requests/limits when adding services
- **Network policies**: Understand service-to-service communication requirements
- **Data persistence**: Some services (PostgreSQL, Weaviate) require persistent volumes

## Testing Requirements

Minimum validation for infra changes:
- Garden config validation passes (`garden validate`)
- Helm lint passes
- Test deployment in dev environment
- Verify service health endpoints respond
- Check logs for startup errors

> **For app-level issues** during deployment (e.g., crash loops caused by app code), see the [backend-dev](../../../apps/backend/.agent/skills/backend-dev/SKILL.md) and [backend-debug](../../../apps/backend/.agent/skills/backend-debug/SKILL.md) skills.

## Safety and Boundaries

### Always do

- Validate Garden configs before committing
- Test Helm charts in non-production first
- Document environment-specific values
- Include rollback instructions for risky changes
- Check resource usage impact

### Ask first

- Production deployment configuration changes
- Database migration strategies
- Service scaling parameters
- Network policy or security changes
- Adding new external dependencies or services
- Certificate or secrets management changes

### Never do

- Never commit credentials or API keys to Garden/Helm configs
- Never deploy to production without explicit user confirmation
- Never remove resource limits without justification
- Never change production DNS/ingress without backup plan
- Never disable health checks to "fix" failing deployments
- Never modify service code for infrastructure-only tasks

## Definition of Done

For each completed task, provide:

1. What infrastructure change was made and why
2. Files/configs touched
3. Validation commands run (garden validate, helm lint, etc.)
4. Deployment test results (if applicable)
5. Rollback procedure if needed
6. Environment-specific notes or prerequisites
