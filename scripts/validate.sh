#!/usr/bin/env bash
# Lint and schema-validate the chart for every environment, exactly as CI does.
# Requires: helm >= 3.14, kubeconform >= 0.6.
set -euo pipefail

CHART="charts/web-service"
K8S_VERSION="${K8S_VERSION:-1.31.0}"
CRD_SCHEMAS='https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'

cd "$(dirname "$0")/.."

for values in "" environments/values-dev.yaml environments/values-prod.yaml; do
  label="${values:-defaults}"
  args=()
  [[ -n "$values" ]] && args=(-f "$values")

  echo "==> helm lint (${label})"
  helm lint --strict "$CHART" "${args[@]}"

  echo "==> kubeconform (${label})"
  helm template web-service "$CHART" "${args[@]}" \
    | kubeconform -strict -summary -kubernetes-version "$K8S_VERSION"
done

echo "==> kubeconform (Argo CD manifests)"
kubeconform -strict -summary -kubernetes-version "$K8S_VERSION" \
  -schema-location default -schema-location "$CRD_SCHEMAS" \
  -skip Kustomization argocd/

echo "All checks passed."
