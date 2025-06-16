# Trivy Integration

## Why We Chose Trivy

Trivy by Aqua Security is an all-in-one, open-source security scanner for CI/CD pipelines. We use it to enforce security across source code, containers, and secrets.

### ✅ Vulnerability Scanning
- Scans application dependencies (e.g., pip, npm) for known CVEs.
- Supports SBOM (Software Bill of Materials) generation.
- Blocks CI/CD pipelines if high/critical vulnerabilities are found.

### ✅ Secret Detection
- Detects hardcoded secrets like API keys, tokens, passwords.
- Lightweight and quick, ideal for scanning on every commit or pull request.

### ✅ Image Scanning (Optional)
- Scans Docker images for OS-level vulnerabilities and misconfigurations.
- Integrates with Cosign or ECR for image signing and attestation.
- Ensures secure build artifacts are published.

### 🚀 Integration
- GitHub Actions: `aquasecurity/trivy-action` for secret/config/dependency/image scanning.
- Works in combination with other tools like Cosign, GitLeaks.