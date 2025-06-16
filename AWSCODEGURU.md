# AWS CodeGuru Security Integration

## Why We Chose AWS CodeGuru Security

AWS CodeGuru Security is a static application security testing (SAST) tool that uses machine learning and automated reasoning to detect security vulnerabilities in your source code. It integrates natively with AWS and provides contextual feedback for developers.

### ✅ Vulnerability Scanning
- Performs deep static analysis on Python and Java code.
- Detects hard-to-spot issues such as hardcoded credentials, injection flaws, privilege escalation, and data leaks.
- Uses ML-based detection models based on Amazon’s secure coding practices.

### ✅ Application Code Scanning
- Supports local code scanning via the AWS CLI or CodeGuru Security GitHub Action.
- Surfaces precise recommendations with line-level detail and remediation suggestions.
- Annotates PRs with security findings automatically (via GitHub Actions).

### ❌ Secret Detection
- Limited native secret detection; best combined with Trivy or GitLeaks for broader coverage.

### ❌ Dependency Scanning
- Focuses on code vulnerabilities rather than third-party libraries. Use Trivy or Dependabot for SBOM-based CVEs.

### ✅ Pipeline Enforcement
- Can fail CI/CD builds by parsing SARIF output or setting thresholds for critical findings.
- Outputs compatible SARIF files for GitHub’s security dashboard.

### 🚀 Integration
- GitHub Actions: via `aws-actions/codeguru-security-scan` or custom CLI steps.
- Best suited for projects hosted on AWS or requiring ML-enhanced code security feedback.