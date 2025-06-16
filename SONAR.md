# SonarCloud Integration

## Why We Chose SonarCloud

SonarCloud is a powerful SaaS-based code quality and security tool that integrates seamlessly with CI/CD pipelines. We selected it for the following reasons:

### ✅ Vulnerability Scanning (SAST)
- Scans source code for bugs, security hotspots, and code smells.
- Supports over 25 languages including Python, JavaScript, and Java.
- Uses industry-standard security rules (e.g., OWASP Top 10).

### ✅ Application Code and Dependency Scanning
- Analyzes both custom code and coverage quality.
- Identifies untested or error-prone areas of logic.
- Highlights outdated dependencies with known issues.

### ✅ Pipeline Enforcement
- Automatically fails CI/CD builds when Quality Gate is not passed.
- Customizable quality gates with thresholds (e.g., 80% coverage, no critical issues).

### 🚫 Secret Detection
- Limited native support for secrets; complementary tools (e.g., Trivy or GitLeaks) recommended.

### 🚀 Integration
- GitHub Actions, GitLab CI, Bitbucket Pipelines supported.
- Decorates Pull Requests with inline issues and coverage stats.