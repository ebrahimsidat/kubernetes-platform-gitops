# Changelog

All notable changes to this project are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-25

### Added

- Helm chart web-service with hardened Deployment, Service, Ingress, HPA, PDB, NetworkPolicy and helm test
- JSON schema validation of chart values
- Dev and prod environment values
- Argo CD AppProject and Applications (automated sync for dev, tag-pinned manual sync for prod)
- CI: yamllint, ShellCheck, helm lint, kubeconform, and a kind deployment under the restricted Pod Security Standard
