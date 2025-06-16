# 🕷️ Why We Chose OWASP ZAP for DAST in DevSecOps

## 🎯 Purpose

In our DevSecOps pipeline, **OWASP ZAP** (Zed Attack Proxy) is the chosen tool for performing **Dynamic Application Security Testing (DAST)**. ZAP enables us to evaluate the runtime behavior and attack surface of our web application in staging environments before code reaches production.

---

## ✅ Why ZAP?

| Capability                     | Reason for Selection                                                                 |
|-------------------------------|----------------------------------------------------------------------------------------|
| 🔓 Open Source & Community     | Free to use, maintained by OWASP, widely adopted in industry                         |
| 🕷️ DAST Focus                  | Specifically designed for scanning running web applications and APIs                 |
| 🖥️ GUI + CLI Support           | Enables both manual exploratory testing and automated CI/CD workflows               |
| 🔐 Runtime Vulnerability Detection | Finds issues that SAST and SBOM scanners cannot (e.g., XSS, misconfigured headers) |
| 🧪 Pre-Deployment Testing      | Enables security validation in test/staging environments during CI/CD               |
| 📄 Customizable Reporting      | Outputs results in HTML, JSON, or SARIF formats for audits and dashboards           |

---

### 📍 When: Post-deployment to staging in CI/CD

ZAP is triggered **after the application is deployed** to a temporary or staging environment. This ensures that ZAP can interact with the real HTTP layer — not just the source code — to:

1. **Spider and crawl** the full web application (including JS routes)
2. **Passively inspect** all responses for vulnerabilities (e.g., missing CSP headers)
3. **Actively inject** payloads for high-risk vulnerability testing (e.g., XSS, CSRF, SQLi)

---

## 🛠 Vulnerabilities ZAP Can Detect

| Category                | Examples ZAP Identifies                                 |
|-------------------------|----------------------------------------------------------|
| ⚠️ Input validation      | Cross-site scripting (XSS), reflected parameters         |
| 🔐 Header misconfig      | Missing X-Frame-Options, CSP, HSTS                       |
| 🔍 Information exposure  | Debug messages, server banners, internal paths          |
| 🍪 Cookie issues         | Lack of `Secure`, `HttpOnly`, or `SameSite` flags       |
| 🔄 Session handling      | Insecure logout, weak token reuse, session timeout gaps |

---

## 📊 Value in DevSecOps Pipeline

| DevSecOps Goal            | How ZAP Helps                                              |
|---------------------------|-------------------------------------------------------------|
| ✅ Shift-left security     | DAST runs pre-release and blocks risky deployments          |
| 🚫 Fail-fast               | Pipeline can fail based on risk level (High, Medium alerts) |
| 🔍 Continuous validation   | Detects regressions and security drifts over time           |
| 📈 Auditable reports       | HTML/SARIF reports can be archived and analyzed             |
| 🛡️ Defense-in-depth        | Complements SAST (SonarCloud) and SCA (Trivy)               |

---

## 🧠 Summary

OWASP ZAP was selected because it brings **critical runtime awareness** to our DevSecOps pipeline. It helps ensure that:

- Our web application is resilient to real-world HTTP-based attacks
- Deployments are gated by security validation
- Security issues are discovered **before users ever encounter them**

It acts as the DAST layer in our defense strategy — validating security **not just in code, but in behavior**.