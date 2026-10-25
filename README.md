# kubernetes-platform-gitops

[![CI](https://github.com/ebrahimsidat/kubernetes-platform-gitops/actions/workflows/ci.yml/badge.svg)](https://github.com/ebrahimsidat/kubernetes-platform-gitops/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A GitOps reference for delivering a stateless web service to Kubernetes with **Helm** and **Argo CD**, hardened to the
Kubernetes **restricted Pod Security Standard** and compatible with **OpenShift**'s default security context constraints.

Every change is linted, schema-validated against the Kubernetes API, and then **actually deployed** to a disposable
[kind](https://kind.sigs.k8s.io/) cluster in CI, where the chart's own `helm test` must pass before a merge.

## What's inside

| Path | Purpose |
| --- | --- |
| `charts/web-service/` | Helm chart: Deployment, Service, ConfigMap, ServiceAccount, optional Ingress, HPA, PodDisruptionBudget, NetworkPolicy, and a `helm test` hook |
| `charts/web-service/values.schema.json` | JSON schema so bad values fail at `helm install`, not at 2 a.m. |
| `environments/` | Per-environment overrides (dev: 1 replica; prod: 3–10 replicas, autoscaling, ingress with TLS) |
| `argocd/` | Argo CD `AppProject` (allow-listed repos, namespaces and kinds) and one `Application` per environment |
| `scripts/validate.sh` | The same lint and validation CI runs, for local use |
| `docs/` | Architecture, security controls and operations runbook |

## Security by default

The chart ships secure without any extra values:

- Runs as non-root, `allowPrivilegeEscalation: false`, **all Linux capabilities dropped**, `RuntimeDefault` seccomp profile.
- **Read-only root file system**; nginx writes only to a size-limited `emptyDir` at `/tmp`.
- No `runAsUser` hard-coded, so OpenShift can assign a UID from the project's range.
- Service account token **not mounted** (the workload never calls the Kubernetes API).
- `NetworkPolicy` allows ingress only from the same release and explicitly listed namespaces.
- `PodDisruptionBudget`, topology spread and `maxUnavailable: 0` rolling updates for zero-downtime maintenance.
- Config changes roll pods automatically through a `checksum/config` annotation.

See [docs/security.md](docs/security.md) for how each control maps to the CIS Kubernetes Benchmark and Pod Security Standards.

## Quick start

```bash
# Render and validate locally (needs helm and kubeconform)
bash scripts/validate.sh

# Install into any cluster
helm install web-service charts/web-service -n web-dev --create-namespace \
  -f environments/values-dev.yaml --wait
helm test web-service -n web-dev
```

### With Argo CD

```bash
kubectl apply -k argocd/
```

- **dev** tracks `main` with automated sync, pruning and self-heal.
- **prod** is pinned to a release tag (`v1.0.0`) and synced manually after change approval, so production only moves
  through a reviewed tag bump.

## Continuous integration

| Job | Checks |
| --- | --- |
| Lint and schema validation | `yamllint`, ShellCheck, `helm lint --strict` and `kubeconform -strict` for default, dev and prod values; Argo CD manifests against the CRD schema catalog |
| Deploy to kind and run helm test | Namespaces enforce the **restricted** Pod Security Standard; dev and prod releases installed with `--wait`; `helm test` on both; a configuration-change upgrade proves a clean zero-downtime rollout |

## Design decisions

- **One chart, many environments.** Environment differences live in small values files, which keeps reviews focused on
  what actually differs between dev and prod.
- **Pull-based delivery.** Argo CD pulls from Git, so CI never holds cluster credentials.
- **Unprivileged image.** `nginxinc/nginx-unprivileged` listens on 8080 and runs as a non-root user out of the box.

## License

[MIT](LICENSE) © 2026 Ebrahim Sidat
