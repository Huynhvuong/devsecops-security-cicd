<p align="center">
  <img src="./assets/devsecops-cicd.png" alt="DevSecOps CI/CD Logo"/>
</p>

# 🔐 DevSecOps Solution: CI/CD, Deployment & Security Governance

This project demonstrates a secure-by-design CI/CD pipeline built for a sample application hosted in a **public GitHub repository**.  
You can find the source and reference implementation at: 👉 [https://github.com/Everfit-io/devops-test](https://github.com/Everfit-io/devops-test)
 It aligns with DevSecOps principles, enabling security checks at every step of development and deployment.

## 📚 Table of Contents

- [Objective](#-objective)
- [Solution Overview](#-solution-overview)
- [Metrics & Governance](#-metrics--governance)
- [Security Control Strategy](#-security-control-strategy)
- [Environment and Secret Management](#-environment-and-secret-management)
- [Pipeline Flow (Secured)](#-pipeline-flow-secured)
- [Infrastructure as Code (IaC) with Terraform](#-infrastructure-as-code-iac-with-terraform)
- [Post deployment Stage: DAST Scan with OWASP ZAP](#post-deployment-stage)
- [Security & Quality Metrics Reporting](#-security--quality-metrics-reporting)
- [Next Steps](#-next-steps)
- [Summary](#-summary)

---

## 🎯 Objective

> Build a robust and scalable DevSecOps pipeline that:
- Automates testing, analysis, and deployment
- Continuously scans for vulnerabilities, misconfigurations, and leaked secrets
- Enforces compliance and quality gates before any production release

---

## 🛠️ Solution Overview

| Layer                    | Tool/Method                        | Purpose                                           |
|--------------------------|------------------------------------|---------------------------------------------------|
| 🧪 Testing                | `pytest`                          | Validates correctness and measures code coverage  |
| 🧠 Static Analysis        | [SonarCloud](./SONAR.md)           | Scans for bugs, code smells, and coverage gaps    |
| 🛡️ Vulnerability Scanning| [Trivy](./TRIVY.md)                | Scans dependencies, IaC, secrets, Docker images   |
| 🤖 ML-SAST                | [AWS CodeGuru Security](./AWSCODEGURU.md) | Finds complex flaws via machine learning     |
| 🌐 DAST                   | [OWASP ZAP](./ZAP.md)              | Dynamic Application Security Testing (DAST) for runtime vulnerabilities |
| 🔄 CI/CD Engine           | [GitHub Actions](./GITHUB_ACTIONS.md) | Automates the end-to-end workflow              |
| 🚀 Deployment             | Docker + AWS ECR + gated deploys   | Only deploy after all security conditions pass   |

## 📊 Metrics & Governance

| Control Point         | Implementation                        |
|------------------------|----------------------------------------|
| 🔍 CVE Threshold       | Trivy `--exit-code=1 --severity=HIGH`  |
| 🚫 Quality Gate        | SonarCloud gate check via API          |
| 🔐 Secret Detection    | Trivy `secret` scan                    |
| 📁 IaC Misconfig       | Trivy `config` scan                    |
| 🌐 DAST Findings       | ZAP scan results                       |
| ✅ Verification Layer  | SARIF uploads + GitHub annotations     |

---

## 🔐 Security Control Strategy

- ✅ **Shift-Left Security**: Vulnerability and secret scanning integrated early (on PR).
- ✅ **Fail-Fast Strategy**: Pipelines fail immediately on high/critical security findings.
- ✅ **Policy as Code**: Quality Gates, severity thresholds, and IaC checks are enforced via configuration.
- ✅ **Immutable Delivery**: Signed containers and reproducible builds reduce attack surface.
- ✅ **Audit & Visibility**: SARIF reports flow into GitHub Security Dashboard for traceability.
- ✅ **Environment Hardening**: Only minimal GitHub permissions (e.g., `id-token: write`, `security-events: write`) are granted.
- ✅ **Secrets manager**: GitHub Secrets and OIDC tokens used for secure authentication

## 🔐 Environment and Secret Management

To ensure environment-specific configurations and credentials are securely handled, the pipeline integrates the following strategies:

  ### GitHub Secrets
  - Used to store tokens, AWS credentials, and SonarCloud keys.
  - Referenced in workflows using `${{ secrets.VARIABLE_NAME }}` syntax.
  - Enables separation of concerns between code and sensitive values.

  ### Terraform Environment Separation
  - Infrastructure as Code (IaC) for different environments (dev, staging, prod) is handled using **Terraform workspaces**.
  - Backend configuration and state locking are managed through remote state (AWS S3 + DynamoDB).
  - Reduces reliance on static GitHub secrets and enforces role-based access through OIDC tokens.

  ### Secret Manager Integration
  - AWS Secrets Manager and SSM Parameter Store are used to fetch runtime environment variables during startup Application.

---

## 🔄 Pipeline Flow (Secured)

### 🔃 On Pull Request to `main` Branch

- Runs on PRs that modify files exlude in the `terraform/` directory and `.github/workflows/terraform-*`

📄 Triggered Workflows:
- `codeguru-scan.yml`
- `trivy-code-scan.yml`
- `unit-tests-and-sonarqube.yml`

### 1️⃣ Unit Tests + Static Analysis
- Run tests, generate `coverage.xml`
- Analyze with SonarCloud (code smells, coverage, Quality Gate)
- Fail pipeline if UnitTest or Quality Gate is not passed

### 2️⃣ Code Scanning with Trivy

- Detect CVEs, leaked secrets, and misconfigs
- Upload SARIF to GitHub Security Dashboard

### 3️⃣ AWS CodeGuru Security Scan

- Run ML-based static analysis on code
- Upload results to GitHub dashboard

- ✅ PR cannot be merged unless all jobs succeed (via GitHub branch protection rules)

### 🔃 On PR Merged to `main` Branch

- Triggered only when changes are merged to main, excluding updates to the `terraform/` directory and any files under `.github/workflows/terraform-*`. This ensures the backend deployment workflow is not executed for infrastructure-related modifications.

📄 Triggered Workflows:
- `backend-deploy-trigger.yml`
🚀 **Stages:**
1. Re-run unit tests and SonarCloud analysis to catching any issues introduced by concurrent changes or merge conflicts.
2. Build Docker image and push to ECR
3. Scan built image with Trivy
4. Deploy to AWS ECS **only if all previous stages pass**

---

## 🌱 Infrastructure as Code (IaC) with Terraform

This project uses **Terraform** for managing AWS infrastructure in a secure, automated, and reviewable way. The Terraform workflows are tightly integrated with GitHub Actions and follow a CI/CD approach for infrastructure changes.

### 🏗️ Terraform CI/CD Pipeline

| Event                | Workflow                | Action Taken                |
|----------------------|-------------------------|-----------------------------|
| PR to `main`         | `terraform-plan.yml`    | Plan, comment, upload plan  |
| Merge to `main`      | `terraform-apply.yml`   | Download plan, apply infra  |

#### 1️⃣ On Pull Request to `main` (Terraform Plan)

- **Workflow:** `.github/workflows/terraform-plan.yml`
- **What happens:**
  - Runs on PRs that modify files in the `terraform/` directory.
  - Checks out code and configures AWS credentials using OIDC.
  - Runs `terraform init` and `terraform plan` for the target environment (e.g., `dev`).
  - Uploads the generated plan file as a workflow artifact.
  - Posts a summary of the Terraform plan as a comment on the PR for reviewer visibility.
  - **No infrastructure is changed at this stage.**
  - If the plan or workflow fails, the PR cannot be merged (enforced by branch protection rules).

#### 2️⃣ On Merge to `main` (Terraform Apply)

- **Workflow:** `.github/workflows/terraform-apply.yml`
- **What happens:**
  - Triggered when changes are merged to `main` that affect `terraform/`.
  - Downloads the previously generated plan artifact.
  - Applies the Terraform plan to update AWS infrastructure.
  - Notifies the team of success or failure via Microsoft Teams integration.
  - Uses secure AWS authentication via OIDC and GitHub secrets.

---

### Post deployment Stage
### DAST Scan with OWASP ZAP

- **Note:** Due to limited resources, full DAST (Dynamic Application Security Testing) scans with [OWASP ZAP](./ZAP.md) are currently performed **manually as a post-deployment step**.  
- These scans are **not yet integrated into the automated CI/CD pipeline**.  
- After deployment, we run ZAP to scan the running application for runtime/web vulnerabilities and review the results separately.
- As resources allow, we plan to automate and integrate DAST scanning into the CI/CD process for even stronger security coverage.

---

## 📈 Security & Quality Metrics Reporting

After each pipeline run, the following metrics are collected and can be reviewed in the GitHub Security tab, workflow artifacts, or manual reports:

  ### 🛡️ Trivy Scan Metrics
  - **Vulnerability Count:** Number of vulnerabilities found, grouped by severity (CRITICAL, HIGH, MEDIUM, LOW, UNKNOWN).
  - **Secrets Detected:** Number of hardcoded secrets or credentials found in code or images.
  - **Misconfigurations:** Number of infrastructure or Dockerfile misconfigurations detected.
  - **Pass/Fail Status:** Pipeline fails if any CRITICAL or HIGH vulnerabilities are found (configurable).

  ### 🤖 CodeGuru Security Metrics
  - **Findings Count:** Number of security findings, grouped by severity (Critical, High, Medium, Low, Info).
  - **Types of Issues:** Categories such as injection, insecure configuration, or AWS best practice violations.
  - **Pass/Fail Status:** Workflow fails if any findings meet or exceed the configured severity threshold.

  ### 🧠 SonarCloud/SonarQube Metrics
  - **Quality Gate Status:** Indicates if the code meets the defined quality standards (coverage, bugs, vulnerabilities, code smells, duplications).
  - **Coverage:** Percentage of code covered by unit tests.
  - **Bugs & Vulnerabilities:** Number and severity of detected issues.
  - **Code Smells & Duplications:** Maintainability and code health indicators.
  - **Pass/Fail Status:** Pipeline fails if the SonarCloud/SonarQube Quality Gate is not passed.

  ### 🌐 OWASP ZAP DAST Metrics (Manual Post-Deployment)
  - **Alert Count:** Number of runtime vulnerabilities found, grouped by risk level (High, Medium, Low, Informational).
  - **Types of Vulnerabilities:** E.g., XSS, SQL Injection, authentication issues, etc.
  - **Remediation Status:** Manual review and tracking of resolved vs. outstanding issues.

  **Where to find these metrics:**
  - **GitHub Security Tab:** Aggregates SARIF results from Trivy and CodeGuru for each PR and branch. [Click to see Security Tab report](./assets/security-tab.png)
  - **SonarCloud/SonarQube Dashboard:** Quality Gate status, coverage, and code quality metrics. [Click to see SonarCloud report](./assets/sonar-dashboard.png)
  - **Manual ZAP Reports:** Uploaded or linked as artifacts after manual DAST scans. [Click to see ZAP report](./assets/zap-report.png)
  - **Pipeline Controls & Annotations:** Inline feedback and status checks block merging if critical issues or quality gate failures are found. [Trivy failed](./assets/trivy-failed.png), [Sonar failed](./assets/sonar-failed.png), [Pipeline stopped](./assets/pipeline-stopped.png)
  - **Workflow Artifacts:** Downloadable reports ( table, or JSON) for Trivy, ZAP and CodeGuru scans. [Click to download Report.zip](./assets/Report.zip)
  - **Demo Application:** Visit our demo application at [https://app-poc.dev.vault22.io](https://app-poc.dev.vault22.io) to see the application deployed using this pipeline.
---

## 🏁 Next Steps

To further strengthen and evolve this DevSecOps pipeline, consider:

- **Remediating Detected Issues:** Prioritize and address vulnerabilities, code quality problems, and misconfigurations identified by the pipeline to continuously improve security and reliability.
- **Automating DAST Scans:** Integrate OWASP ZAP or similar tools directly into CI/CD for continuous runtime security testing.
- **Enabling Dependency Review:** Activate GitHub Dependabot and dependency review for automatic alerts and PRs on vulnerable libraries.
- **Enhancing Monitoring & Auditing:** Set up cloud-native monitoring, alerting, and regular IAM audits.
- **Centralized Security Dashboard:** Aggregate all security findings (Trivy, SonarCloud, CodeGuru, ZAP, etc.) into a centralized dashboard or reporting system for unified visibility, easier tracking, and faster remediation.


## ✅ Summary
As a **DevSecOps-driven project**, this setup ensures:

| ✅ Benefit              | 💡 Description                                                        |
|------------------------|------------------------------------------------------------------------|
| 🔁 Consistent Delivery  | Repeatable builds on every change                                     |
| 🔍 Continuous Assurance | Scans for CVEs, secrets, and code vulnerabilities early in the pipeline |
| 🔐 Security by Default | Secrets protected, images signed, builds gated                        |
| 🔎 Transparency         | GitHub Security tab + PR annotations for clear visibility             |

This solution aligns with modern frameworks such as:
- NIST SSDF
- OWASP SAMM
- GitHub Advanced Security

> **Note:** Depending on the specific requirements of each project or organization, the pipeline configuration, security controls, and quality gates can be adjusted and customized as needed.

---

📂 We invite your feedback and strategic direction to align this solution with business objectives and compliance requirements.  
Your review and input will help us prioritize enhancements, integrations, and rollout plans for broader adoption.

**Thank you for your time and consideration.**