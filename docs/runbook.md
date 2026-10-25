# Operations runbook

## Health

```bash
kubectl -n web-prod get deploy,pods,hpa,pdb -l app.kubernetes.io/instance=web-service
helm test web-service -n web-prod --logs
```

## Pods not becoming ready

1. `kubectl -n web-prod describe pod <pod>` and check events for image pull, scheduling, or admission errors.
2. `kubectl -n web-prod logs <pod>`. nginx errors about a read-only file system mean a path outside `/tmp` is
   being written to.
3. Readiness probe failures: `kubectl -n web-prod port-forward deploy/web-service 8080:8080` and
   `curl -i localhost:8080/healthz`.

## Admission rejected (Pod Security)

`violates PodSecurity "restricted:latest"` means a values override weakened the security context. Remove the override;
do not relax the namespace label.

## Scaling

- Temporary: `kubectl -n web-prod scale deploy/web-service --replicas=5` (the HPA will take over again).
- Permanent: change `autoscaling.minReplicas` and `maxReplicas` in `environments/values-prod.yaml` through a pull request.

## Rollback

```bash
# GitOps (preferred): revert the pull request that changed targetRevision, then sync
argocd app sync web-service-prod

# Emergency: roll back to the previous synced revision
argocd app history web-service-prod
argocd app rollback web-service-prod <history-id>
```

## Node maintenance

`kubectl drain <node> --ignore-daemonsets` is safe: the PodDisruptionBudget keeps at least two production pods running
while pods move.
