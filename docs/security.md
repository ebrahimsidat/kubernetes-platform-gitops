# Security controls

| Control | Where | Reference |
| --- | --- | --- |
| Run as non-root | `podSecurityContext.runAsNonRoot` | Pod Security Standard (restricted); CIS 5.2.6 |
| No privilege escalation | `securityContext.allowPrivilegeEscalation: false` | PSS restricted; CIS 5.2.5 |
| Drop all capabilities | `securityContext.capabilities.drop: [ALL]` | PSS restricted; CIS 5.2.8–5.2.9 |
| Seccomp `RuntimeDefault` | `podSecurityContext.seccompProfile` | PSS restricted; CIS 5.7.2 |
| Read-only root file system | `securityContext.readOnlyRootFilesystem` | Hardening best practice |
| No service account token | `automountServiceAccountToken: false` | CIS 5.1.6 |
| Network segmentation | `templates/networkpolicy.yaml` | CIS 5.3.2 |
| Resource requests and memory limit | `resources` | Prevents noisy-neighbour exhaustion |
| Least-privilege deployment scope | `argocd/project.yaml` allow-lists repos, namespaces and kinds | Separation of duties |
| Change control for production | prod `Application` pinned to a tag, manual sync | ITIL change management |

## Verification

CI creates its namespaces with `pod-security.kubernetes.io/enforce=restricted`. The Kubernetes API server rejects any
pod that breaks the restricted profile, so a regression in the chart's security settings fails the build.

## OpenShift

The chart does not set `runAsUser` or `fsGroup`, so it is admitted by the default `restricted-v2` SCC, which assigns a
UID from the project's range.
