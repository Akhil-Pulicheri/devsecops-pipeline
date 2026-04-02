# Cloud-Native DevSecOps Pipeline

An automated CI/CD pipeline that integrates security scanning at every stage
of the software development lifecycle.

## What This Project Does

Every time code is pushed to this repository, the following happens automatically:

1. **Dependency Check (SCA)** — Trivy scans all third-party libraries for known vulnerabilities
2. **Code Review (SAST)** — Semgrep reads the source code looking for security anti-patterns
3. **Container Build** — The app is packaged into a Docker container with security hardening
4. **Container Scan** — Trivy scans the container image for OS-level vulnerabilities
5. **Live Attack Test (DAST)** — OWASP ZAP attacks the running application to find exploitable bugs
6. **Deploy** — If all checks pass, the app is deployed to AWS using Terraform

## Tools Used

| Tool | Purpose |
|------|---------|
| GitHub Actions | CI/CD automation |
| Trivy | Dependency & container scanning |
| Semgrep | Static code analysis |
| OWASP ZAP | Dynamic security testing |
| Docker | Containerisation |
| Terraform | Infrastructure as Code |
| AWS EC2 | Cloud deployment |

## Architecture

See `docs/architecture.md` for the full pipeline diagram.
