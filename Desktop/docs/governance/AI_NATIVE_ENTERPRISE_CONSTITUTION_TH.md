# GitHub Complete Enterprise & AI-Native Logic

**Version:** 1.0.0  
**Language:** Thai  
**Sections:** 1–246  
**Scope:** GitHub Governance, Repository, Branching, CI/CD, Security, Release, Compliance, AI Agents และ Universal AI Provider

> เอกสารนี้รวมตรรกะทั้งหมดที่กำหนดในบทสนทนา ตั้งแต่ GitHub Core Logic จนถึง AI Provider-Agnostic และส่วนควบคุม AI บนขอบหน้าต่างหลัก

## หลักการสูงสุด

- **Long-term First** — ทุกการตัดสินใจมองระยะยาวก่อนระยะสั้น
- **One Truth** — มีแหล่งข้อมูลและตรรกะหลักเพียงชุดเดียว
- **AI is a Team Member** — AI เป็นสมาชิกทีมภายใต้นโยบาย ไม่ใช่ผู้มีอำนาจไม่จำกัด
- **Every Change Has Evidence** — ทุกการเปลี่ยนแปลงมีหลักฐาน
- **Documentation Never Lags Behind Code** — เอกสารเดินพร้อมโค้ด
- **Quality Is Continuous** — คุณภาพเป็นส่วนหนึ่งของทุก Increment
- **Provider Independent** — เปลี่ยน AI Provider ได้โดยไม่กระทบ Core

## สารบัญ

1. GitHub Core Logic — ข้อ 1–54
2. Enterprise Organization & Repository — ข้อ 55–100
3. Delivery, Security, AI Governance & Compliance — ข้อ 101–200
4. Final Governance Controls — ข้อ 201–220
5. Universal AI Provider & Main Window — ข้อ 221–246

---


# 1. GitHub คือแหล่งข้อมูลหลัก

GitHub ต้องเป็นศูนย์กลางของ Source Code, Documentation, Issues, Pull Requests, ADR, Tests, CI/CD, Releases, Artifacts, Version History และ Security Reports

- ห้ามมี Source Code สำคัญอยู่เฉพาะในเครื่องโดยไม่ Push
- เอกสารและหลักฐานต้องอ้างกลับไปยัง Commit หรือ Release ได้


# 2. One Repository, One Truth

กำหนด Repository หลักเพียงหนึ่งชุดต่อระบบ

Repository ทดลองต้องระบุสถานะ เช่น `prototype`, `experimental`, `migration`, `clean-room`, `legacy` หรือ `archive` และห้ามนำเข้าสู่ Production โดยไม่ผ่าน Review


# 3. Every Change Has Evidence

ทุกการเปลี่ยนแปลงต้องมีหลักฐานอย่างน้อยหนึ่งรายการ เช่น Issue, PR, Commit, ADR, Test Result, Build Result, Security Scan หรือ Review Comment


# 4. Branch หลัก

`main` เก็บโค้ดที่ผ่าน Review, Test, Build และ Security Gate แล้ว ห้ามพัฒนา Feature ใหญ่โดยตรงบน Branch นี้


# 5. Development Branch

`develop` ใช้รวม Feature และ Integration Test ก่อนเข้าสู่ `main` โปรเจกต์ขนาดเล็กอาจใช้ Feature Branch เปิด PR เข้า `main` โดยตรง


# 6. Feature Branch

รูปแบบ `feature/<feature-name>` ใช้เพิ่มความสามารถใหม่ เช่น `feature/calendar-sync`


# 7. Fix Branch

รูปแบบ `fix/<problem-name>` ใช้แก้ Bug ทั่วไป เช่น `fix/google-oauth-login`


# 8. Hotfix Branch

รูปแบบ `hotfix/<critical-problem>` ใช้เหตุเร่งด่วน เมื่อเสร็จต้อง Test, PR, Merge เข้า `main`, Sync กลับ `develop` และออก Patch Release


# 9. Release Branch

รูปแบบ `release/v<version>` ใช้เตรียม Version, Documentation, Full Test, Release Notes และ Artifacts โดยไม่เพิ่ม Feature ใหญ่


# 10. Documentation Branch

รูปแบบ `docs/<document-name>` ใช้ปรับเอกสารแยกจากงาน Feature


# 11. AI Branch

รูปแบบ `ai/<task-name>` งานจาก AI ต้องผ่าน Diff Review, Tests, Static Analysis, Secret Scan และ Human Approval ตามความเสี่ยง


# 12. ขั้นตอนการทำงานมาตรฐาน

มาตรฐาน:

```text
Inspect Repository → Create Branch → Implement → Format → Analyze → Test → Build
→ Security Scan → Diff Review → Commit → Push → PR → Review → Merge
→ Deploy/Release → Post-deploy Check
```


# 13. Repository Inspection

ตรวจคำสั่งหลัก:

```bash
git remote -v
git status
git branch --show-current
git log --oneline -10
git fetch --all --prune
```


# 14. File Change

อ่านไฟล์เดิมและไฟล์ที่เกี่ยวข้องก่อนแก้ หลังแก้ตรวจ:

```bash
git status --short
git diff
git diff --stat
```

ห้าม Commit Cache, Secret, Token, Password, Certificate หรือ Private Key


# 15. Commit Format

ใช้รูปแบบ `<type>(<scope>): <description>`

ประเภทมาตรฐาน: `feat`, `fix`, `docs`, `refactor`, `test`, `build`, `ci`, `chore`, `perf`, `security`, `revert`


# 16. Commit Scope

หนึ่ง Commit ควรทำงานหลักเพียงเรื่องเดียว หลีกเลี่ยงข้อความไม่ชัดเจน เช่น `update`, `fix`, `final`, `ล่าสุด`


# 17. Pull Request Content

PR ต้องมี Summary, Reason, Changes, Testing, Build Results, Risk, Screenshots, Related Issue, Rollback Plan และ Checklist


# 18. Pull Request Review

ตรวจ Scope, Architecture, Duplicate Code, Secrets, Tests, Error Handling, Platform Support, Documentation, Migration และ Rollback ห้าม Approve โดยดูเพียงชื่อไฟล์


# 19. Merge Strategy

- Squash and Merge: feature/fix/docs/ai
- Merge Commit: release/integration
- Rebase and Merge: เมื่อประวัติ Commit ถูกจัดโครงสร้างดี


# 20. Branch Protection

Require PR, Approval, Status Checks, Up-to-date Branch, Conversation Resolution และ Code Owner Review พร้อม Block Force Push และ Branch Deletion


# 21. Required Status Checks

สถานะที่ควรบังคับ: format, analyze, unit-test, integration-test, security-scan, secret-scan, dependency-scan และ platform builds ตาม Scope


# 22. CI Trigger

รัน CI บน `pull_request`, `push` เข้า Branch หลัก และ `workflow_dispatch` แยก Quick Checks กับ Full Build


# 23. CI Sequence

Checkout → Setup Toolchain → Restore Cache → Install Dependencies → Generate Code → Format → Analyze → Test → Coverage → Security → Build → Upload Artifact


# 24. Flutter CI

สำหรับ Flutter:

```bash
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Build แต่ละ Platform บน Runner ที่รองรับ


# 25. CI Failure

หา Error แรก แยก Root Cause ตรวจ Toolchain, Dependency, Secret และ Path ห้ามปิด Test หรือ Security Check เพื่อให้ Workflow ผ่าน


# 26. Dependency

ก่อนเพิ่ม Dependency ให้ตรวจ License, Maintenance, Security Advisory, Platform Support, Size และ Breaking Change พร้อมเพิ่ม Test และอัปเดต Docs


# 27. Secret Management

เก็บ Secret ใน GitHub Actions Secrets, Environments, OS Credential Store หรือ Secret Manager ห้ามเก็บใน Source และห้ามพิมพ์ลง Log


# 28. Secret Leak Response

Rotate/Revoke ทันที ตรวจ History, Logs, Forks และ Artifacts สร้าง Incident และเพิ่ม Push Protection/Secret Scan


# 29. Security Scan

ตรวจ Dependency, Secret, Static Code, Misconfiguration, License, Container Image, Actions Permission และ Artifact Integrity


# 30. GitHub Actions Security

ใช้ Action จากผู้เผยแพร่ที่เชื่อถือได้ Pin Version หรือ SHA ระวัง PR จาก Fork และ `pull_request_target` และใช้ Least Privilege


# 31. Build Artifact

ชื่อ Artifact ควรมี Project, Version, Platform, Architecture, Build Type, Commit SHA และวันที่ Build


# 32. Artifact Checksum

สร้าง SHA-256 หรือกลไก Integrity ที่เทียบเท่า และตรวจ Checksum ก่อนเผยแพร่หรือ Deploy


# 33. Release Gate

Release ต้องตรวจ Version, Changelog, Docs, Tests, Builds, Security, Migration, Rollback, Artifacts และ Checksums


# 34. Semantic Versioning

ใช้ `MAJOR.MINOR.PATCH`: MAJOR = Breaking, MINOR = Compatible Feature, PATCH = Compatible Fix


# 35. Tag

ใช้ Tag รูปแบบ `vX.Y.Z` และห้ามย้าย Tag Release เดิมไป Commit ใหม่


# 36. Release Notes

Release Notes ควรมี Highlights, Features, Improvements, Fixes, Security, Breaking Changes, Migration, Known Issues, Artifacts, Checksums และ Contributors


# 37. Deployment

PR → CI → Merge → Build → Staging → Smoke Test → Approval → Production → Health Check


# 38. Server Deployment

Deploy ผ่าน CI/CD ใช้ Artifact หรือ `git pull --ff-only` หลีกเลี่ยงคำสั่งทำลายประวัติบน Production


# 39. GitHub Pages

Build Web → Upload Pages Artifact → Deploy Pages ใช้ permission เท่าที่จำเป็นและตั้ง concurrency


# 40. Issue

Issue ต้องมี Problem, Expected Result, Current Result, Reproduction, Environment, Evidence, Acceptance Criteria, Priority และ Risk


# 41. Label

ใช้ Label แยก `type`, `priority`, `status`, `platform`, `ai-generated` และ `breaking-change`


# 42. Milestone

รวมงานตาม Phase หรือ Version และผูก Issue สำคัญกับ Milestone


# 43. Project Board

สถานะพื้นฐาน: Backlog, Ready, In Progress, Review, Testing, Blocked, Done ห้าม Done หาก PR/Test ยังไม่ผ่าน


# 44. CODEOWNERS

กำหนด Owner ให้ `.github/`, core, architecture, configuration และไฟล์สำคัญ การแก้ Sensitive Path ต้องมี Code Owner Review


# 45. Documentation

README, CONTRIBUTING, SECURITY, CHANGELOG, LICENSE, ADR, Architecture, Setup, Release และ Troubleshooting ต้องเดินพร้อม Code


# 46. ADR

ADR ต้องมี Title, Status, Context, Decision, Alternatives, Consequences, Risks, Evidence, Date และ Owner


# 47. AI Development

AI ต้องอ่านข้อกำหนด ตรวจ Repository แก้เฉพาะ Scope เพิ่ม Tests รัน Validation ตรวจ Diff และเปิด PR

AI ห้าม Force Push `main`, Commit Secret, Claim Tests ที่ไม่ได้รัน หรือเปลี่ยน Architecture โดยไม่มี ADR


# 48. AI Evidence

เก็บ Task, Files Changed, Diff Summary, Commands Run, Tests, Builds, Limitations, Risk และ Rollback


# 49. Conflict Resolution

ห้าม Accept All โดยไม่อ่าน รวมตรรกะที่จำเป็น ตรวจ Imports/Config แล้วรัน Format, Analyze และ Tests


# 50. Rebase

ใช้ `git rebase origin/main` อย่างระมัดระวัง หากผิดใช้ `git rebase --abort` ห้าม Rebase Shared Branch โดยไม่ประสานงาน


# 51. Rollback

ใช้ `git revert` เป็นค่าเริ่มต้น หลีกเลี่ยง `reset --hard` และ Force Push บน Branch กลาง


# 52. Backup

ก่อน Migration/Release ใหญ่ ให้ Tag, Backup Database/Config/Artifacts, บันทึก SHA และทดสอบ Restore Git ไม่ใช่ Backup ของข้อมูลผู้ใช้


# 53. Repository Cleanup

ตรวจ Import, Workflow, Build Script, Docs, Migration และ Release Reference ก่อนลบไฟล์ หากไม่มั่นใจให้ Archive ก่อน


# 54. Definition of Done

งานเสร็จเมื่อ Requirement, Review, Tests, Build, Security, Documentation, No Secrets, No Conflicts, Merge, Artifact/Deployment และ Evidence ครบ


# 55. GitHub Organization

ใช้ Organization เป็นศูนย์กลางของ Repositories, Teams, Policies, Security, Billing, Audit, Apps, Runners, Secrets, Projects และ Packages มี Owner อย่างน้อยสองคนและบังคับ 2FA


# 56. Organization Owner

จำกัดจำนวน Owner ใช้ Security Key และมีบัญชีกู้คืน ห้ามใช้ Bot เป็น Owner และหลีกเลี่ยงใช้ Owner ในงานประจำ


# 57. Team

แบ่ง Team ตามหน้าที่ เช่น platform, frontend, backend, mobile, security, release, docs และ ai-agents ให้สิทธิ์ผ่าน Team มากกว่ารายบุคคล


# 58. Repository Creation

ก่อนสร้าง Repository ให้กำหนด Name, Purpose, Owner, Visibility, License, Default Branch, Data Classification, Runtime, Deployment และ Lifecycle


# 59. Repository Lifecycle

ใช้สถานะ proposed, prototype, active, maintenance, deprecated, archived, retired เมื่อ Deprecated ต้องระบุ Replacement และ End-of-support


# 60. Repository Visibility

ก่อน Public ให้ตรวจ Secret, History, License, Personal Data, Internal Endpoints และ Proprietary Content ห้าม Private → Public โดยไม่มี Security Review


# 61. Repository Ruleset

ใช้ Rulesets ควบคุม Branch, Tags, Push, Merge, Force Push, Deletion, Required Checks, Reviews, Signed Commits และ Paths


# 62. Bypass

จำกัด Bypass เฉพาะ Emergency, Recovery หรือ Security Incident และบันทึก Reason, Approver, Time, SHA, Impact และ Issue


# 63. Merge Queue

PR Approved → Merge Group → Required Checks → Merge เพื่อลดปัญหา Main แตกจาก PR ที่ผ่านแยกกัน


# 64. Auto-merge

เปิด Auto-merge ได้เมื่อ Review, Required Checks, Conflict, Conversation และ Branch Update ผ่าน ห้ามใช้กับงานเสี่ยงสูง


# 65. Stacked Pull Request

แยกงานใหญ่เป็น PR ต่อเนื่อง เช่น Data Model → Repository → Service → UI → Migration และระบุ Dependency ชัดเจน


# 66. Monorepo

Monorepo ต้องมี Path-based CI, Dependency Graph, Path Ownership, Cache แยก Package, Version Strategy และ Selective Test


# 67. Multi-repository

Multi-repository ต้องมี API Contract, Dependency Ownership, Compatibility Matrix, Release Order และ Integration Test


# 68. Repository Catalog

สร้าง `repository-catalog.yaml` เก็บ owner, status, criticality, visibility, language, deployment และ data classification


# 69. Template Repository

ใช้ Template Repository ที่มี README, LICENSE, SECURITY, CONTRIBUTING, CODEOWNERS, Workflows, Issue และ PR Templates


# 70. Community Health

จัด Community Health Files ระดับ Organization เพื่อให้ Repository ใช้มาตรฐานร่วมกัน


# 71. Issue Template

Issue Template แยก Bug, Feature, Security, Docs, Technical Debt, Incident และ Release Task


# 72. Pull Request Template

PR Template บังคับ Summary, Issue, Type, Testing, Screenshots, Security, Migration, Docs, Rollback และ Checklist


# 73. GitHub Projects

GitHub Projects ใช้บริหารงานระดับ Repository, Team, Product, Release, Roadmap และ Incident พร้อม Custom Fields


# 74. Project Automation

Automation ตัวอย่าง: Issue created → Backlog, PR opened → Review, PR merged → Done แต่ต้องตรวจสถานะจริงเสมอ


# 75. Roadmap

Roadmap แสดง Initiative, Epic, Milestone, Feature, Dependency, Target Date และ Risk


# 76. Discussions

Discussions ใช้คำถาม แนวคิด Proposal และ Announcement ไม่ใช้แทน Bug, Security Report หรือ Incident


# 77. Wiki

Wiki เหมาะกับคู่มือที่เปลี่ยนบ่อย เอกสารที่ผูกกับ Version ควรอยู่ใน Repository


# 78. Git LFS

ใช้ Git LFS กับ Binary ใหญ่ กำหนด Pattern, Quota, Backup, Retention และ Access Control


# 79. Large Repository

Repository ใหญ่ควรใช้ shallow clone, sparse checkout, LFS, selective build และย้าย Artifact ออกจาก Git History


# 80. Submodule

Submodule ต้องกำหนด Version, Permission และ CI Checkout ชัดเจน ห้ามชี้ไป Commit ที่เข้าถึงไม่ได้


# 81. Subtree

Subtree ต้องกำหนด Source, Prefix, Sync Direction, Owner และ Conflict Strategy


# 82. GitHub Packages

GitHub Packages ใช้เก็บ Container, npm, Maven, NuGet และ Package ภายใน โดยมี Version, Owner, License และ Access Control


# 83. Container Registry

Container Image ต้อง Scan, ไม่มี Secret, ใช้ Non-root เมื่อทำได้, มี SBOM, Digest, Signature หรือ Attestation


# 84. Package Retention

กำหนด Retention ของ Stable, RC, Nightly และ Untagged Packages ห้ามลบสิ่งที่ Production ใช้อยู่


# 85. Dependabot

Dependabot: Security Update ทันที, Patch รวมรายสัปดาห์, Minor ตามรอบ, Major แยก PR และทดสอบ Migration


# 86. Dependency Review

Dependency Review ตรวจ Vulnerability, License, Transitive Dependency, Maintainer, Install Hook และ Package Source


# 87. CodeQL

CodeQL รันบน PR, Main, Schedule และ Release สำคัญ Critical/High ต้องแก้หรือมี Risk Acceptance


# 88. Secret Scanning

เปิด Secret Scanning และ Push Protection ตรวจ Commit, PR, History, Logs, Artifacts และ Forks


# 89. Security Advisory

ใช้ Private Security Advisory สำหรับช่องโหว่ที่ยังไม่เปิดเผย พัฒนา Patch ใน Private Fork ก่อนประกาศ


# 90. Vulnerability Response

จัดระดับ Critical, High, Medium, Low และกำหนด Owner, Mitigation, Review Date และ Expiration สำหรับ Risk Acceptance


# 91. SBOM

สร้าง SBOM รูปแบบ SPDX หรือ CycloneDX ระบุ Package, Version, License, Supplier, Hash และ Dependency Relationship


# 92. Artifact Attestation

Artifact Attestation ต้องยืนยัน Repository, Commit, Workflow, Environment และ Builder


# 93. Signing

Sign Commit, Tag, Container, Artifact และ App ตามความเสี่ยง พร้อม Rotation, Backup และ Revocation Plan


# 94. Supply-chain Security

ป้องกัน Supply-chain Attack ด้วย Pin Action, Lock Dependency, Verify Checksum, Trusted Registry, SBOM และ Ephemeral Runner


# 95. Reusable Workflow

Reusable Workflow ลดความซ้ำและกำหนด Inputs, Outputs, Secrets และ Version ชัดเจน


# 96. Composite Action

Composite Action ใช้รวม Steps ซ้ำ ต้องมี README, Inputs, Outputs, Version และ Tests


# 97. Workflow Permission

Workflow ใช้ Least Privilege เริ่มจาก `contents: read` แล้วเพิ่มเฉพาะสิทธิ์จำเป็น


# 98. OpenID Connect

ใช้ OIDC แทน Cloud Credential ระยะยาว และจำกัด Trust ตาม Organization, Repository, Branch, Tag, Environment และ Workflow


# 99. Cache

Cache Key อิง OS, Tool Version, Lock File Hash, Architecture และ Build Mode ห้าม Cache Credentials


# 100. Artifact Retention

กำหนด Retention ตามประเภท PR, Nightly, RC, Stable, Security และ Compliance Evidence


# 101. Concurrency

ใช้ Concurrency ป้องกัน Workflow ซ้อน Production ควรไม่ Cancel กลางทางโดยไม่มี Recovery


# 102. Matrix Build

Matrix Build ใช้ทดสอบหลาย OS, Runtime, Architecture และ Configuration พร้อมกำหนด fail-fast ตามงาน


# 103. Self-hosted Runner

Self-hosted Runner ต้องแยกเครื่อง จำกัด Network Patch สม่ำเสมอ ล้าง Workspace และไม่ใช้กับ Fork ที่ไม่เชื่อถือ


# 104. Runner Label

ใช้ Runner Labels เช่น windows, linux, macos, x64, flutter, signing, production และแยก Signing Runner


# 105. Workflow Cost

ควบคุม Cost ด้วย Path Filter, Cache, Timeout, Cancel Workflow เก่า และ Full Build เฉพาะ Main/Release


# 106. Workflow Timeout

ทุก Job ควรมี Timeout เหมาะสมและตรวจ Root Cause เมื่อช้าผิดปกติ


# 107. Retry

Retry เฉพาะ Network, Registry, Cloud API หรือ Upload ชั่วคราว ไม่ Retry Compile, Test หรือ Security Failure


# 108. Environment Deployment

แยก development, staging, production และใช้ Protected Secrets, Reviewers, Branch Restrictions และ Deployment History


# 109. Deployment Protection

ก่อน Production ตรวจ Artifact, Tests, Security, Approval, Incident, Migration, Backup และ Rollback


# 110. Progressive Deployment

รองรับ Canary, Blue-Green, Rolling, Feature Flag และ Percentage Rollout พร้อม Metrics และ Rollback


# 111. Canary

Canary ค่อย ๆ เพิ่ม Traffic เช่น 5% → 25% → 100% และหยุดเมื่อเกิน Threshold


# 112. Blue-Green

Blue-Green Deploy ไป Green, Smoke Test, Switch Traffic, Monitor และเก็บ Blue เพื่อ Rollback


# 113. Feature Flag

Feature Flag ต้องมี Owner, Purpose, Default, Target, Expiry และ Removal Plan


# 114. Database Migration Deployment

Migration ปลอดภัย: Backup → Backward-compatible Schema → Deploy Code → Migrate Data → Validate → Remove Old Schema ภายหลัง


# 115. Release Train

Release Train ปล่อยตามรอบ งานไม่ทันให้เลื่อนแทนลด Quality Gate ยกเว้น Security Hotfix


# 116. Mobile Signing

Android จัดการ Keystore/Play Signing และ iOS จัดการ Certificate/Profile/App Store Key โดยไม่ Commit Secret


# 117. Certificate Rotation

ทะเบียน Certificate ต้องมี Owner, Created, Expiry, Environment, Renewal และ Revocation พร้อมแจ้งเตือนล่วงหน้า


# 118. Store Release

ก่อน Store Release ตรวจ Version, Signing, Privacy, Permissions, Screenshots, Metadata, Tests, Notes และ Rollout


# 119. Desktop Release

Desktop Installer ต้องมี Code Signing, Version Metadata, Uninstaller, Upgrade Path, Checksum, Malware Scan และ Supported OS


# 120. GitHub API

GitHub API ใช้ Automation, Reporting, Issues, Releases, Inventory และ Compliance โดยใช้ Token สิทธิ์ต่ำสุด


# 121. REST API

REST API ต้องรองรับ API Version, Status Code, Pagination, Retry-After, ETag และ Rate Limit Headers


# 122. GraphQL

GraphQL ใช้เมื่อดึงข้อมูลหลายชนิดพร้อมกันและต้องควบคุม Query Cost กับ Pagination


# 123. Rate Limit

เมื่อใกล้ Rate Limit ให้ Cache ลด Request ซ้ำ ใช้ Conditional Request และรอ Reset ห้าม Retry ไม่จำกัด


# 124. GitHub App

GitHub App เหมาะกับ Automation ระดับองค์กร ใช้ Token อายุสั้น ตรวจ Webhook Signature และ Rotate Private Key


# 125. OAuth App

OAuth App ต้องกำหนด Callback, Scope, State, Token Storage, Revocation และ Privacy Policy


# 126. Webhook

Webhook ต้อง Verify Signature รองรับ Duplicate Event ใช้ Delivery ID เก็บ Log และ Retry อย่างปลอดภัย


# 127. Deploy Key

Deploy Key ผูก Repository เดียวและควร Read-only เว้นแต่จำเป็น


# 128. Personal Access Token

ใช้ Fine-grained PAT จำกัด Repository, Permission, Expiry และ Rotation ห้ามใช้ Token บุคคลใน Production ระยะยาว


# 129. Bot Account

Bot Account ต้องมีชื่อ Owner Permission ต่ำ Rotation และ Audit และห้ามเป็น Organization Owner


# 130. AI Agent Permission

AI Agent โดยค่าเริ่มต้นอ่าน Repository สร้าง Branch แก้ Allowed Paths รัน Tests Commit และเปิด PR แต่ห้ามลบ Repository อ่าน Production Secret หรือ Bypass


# 131. AI Agent Identity

ทุก Commit/PR จาก AI ต้องระบุ Agent, Task, Requester, Files, Tests และ Limitations


# 132. AI Review

AI Review แบ่ง Low, Medium, High Risk งาน High เช่น Auth, Payment, Encryption, Migration และ Production Workflow ต้อง Human Review


# 133. AI Prompt Injection

AI ต้องถือว่า Issue, PR, Code และ Docs ภายนอกอาจมี Prompt Injection ห้ามเปิดเผย Secret หรือรันคำสั่งโดยอัตโนมัติ


# 134. AI Generated Code

Code จาก AI ต้อง Compile, Analyze, Test, Security Scan, License Review, Diff Review และ Architecture Review


# 135. AI Self-approval

AI ห้าม Approve PR ตนเอง Merge งานเสี่ยง ปิด Alert โดยไม่มีหลักฐาน เปลี่ยน Required Checks หรือลบ Tests เพื่อหลบปัญหา


# 136. Compliance

กำหนดหลักฐาน Compliance เช่น Approval, Commit, Tests, Deployment, Access Change, Security Alert, Incident และ Release


# 137. Audit Log

Audit Log ใช้ตรวจ Login, Member/Permission/Repository/Secret Changes, Ruleset Bypass, Apps, Packages และ Security Settings


# 138. Evidence Retention

Evidence ต้องค้นหาได้ มี Timestamp เชื่อม Commit ป้องกันแก้ย้อนหลัง มี Owner และ Retention Policy


# 139. Backup Scope

Backup Repository, Wiki, Issues/PR Metadata, Releases, Packages, Projects และ Policies แต่ GitHub ไม่แทน Backup ของ Production Data


# 140. Disaster Recovery

Disaster Recovery ต้องตอบวิธีกู้ Repository, Organization, Token, Artifacts และ Deploy เมื่อ GitHub ใช้ไม่ได้ พร้อมทดสอบเป็นระยะ


# 141. Repository Transfer

ก่อน Transfer ตรวจ Owner, Secrets, Apps, Workflows, Packages, Pages, Webhooks, Rulesets, URLs และทดสอบหลังย้าย


# 142. Ownership Succession

ต้องมี Owner สำรอง Recovery Account Documentation Key Rotation Billing Contact Domain และ Release Credentials


# 143. Account Recovery

บัญชีสำคัญเปิด 2FA มี Recovery Codes/Security Key และเมื่อสงสัยถูกยึดให้ Revoke Sessions, Rotate Token/SSH และตรวจ Audit


# 144. Domain and Pages

Custom Domain ของ Pages ต้องตั้ง DNS, HTTPS, Verification, Takeover Protection, Ownership และ Renewal


# 145. Open-source License

ก่อน Open Source เลือก License และตรวจ Dependency/Asset Compatibility ห้ามใช้ Code ที่ไม่มีสิทธิ์


# 146. Contributor

Contributor ต้องทำตาม Code of Conduct, Contribution Guide, Commit Style, Tests, License และ Security Policy


# 147. CLA and DCO

ใช้ CLA หรือ DCO ตามนโยบายและอธิบาย Contributor อย่างชัดเจน


# 148. Fork Security

PR จาก Fork ห้ามเข้าถึง Secrets Deploy Production หรือรันบน Sensitive Self-hosted Runner และต้องระวัง `pull_request_target`


# 149. License Compliance

ตรวจ Dependency, Asset, Font, Snippet License, Attribution, Notice และ Source Distribution Requirement


# 150. Incident Management

Incident Record ต้องมี ID, Severity, Start, Detection, Impact, Systems, Owner, Timeline, Mitigation, Root Cause, Recovery และ Follow-up


# 151. Incident Severity

ตัวอย่าง SEV-1 ระบบหลักล่ม/ข้อมูลรั่ว, SEV-2 ผลกระทบสูง, SEV-3 จำกัด, SEV-4 เล็กน้อย


# 152. Incident Branch

ใช้ Branch `incident/<incident-id>-<short-name>` และเชื่อมทุก Commit กับ Incident


# 153. Postmortem

Postmortem ต้องมี What Happened, Impact, Timeline, Root Cause, Factors, What Went Well, Improvements, Actions, Owners และ Deadlines


# 154. Observability

Deployment ต้องมี Logs, Metrics, Traces, Error Reporting, Health Checks, Alerts และ Dashboards เชื่อม Version/Commit/Workflow


# 155. Health Check

หลัง Deploy ตรวจ Service, Database, Auth, Critical APIs, Main Flow, Error Rate, Latency และ Resources


# 156. Rollback Trigger

Rollback เมื่อ Error สูง, Data Corruption, Auth ล้มเหลว, Performance รุนแรง, Security Issue หรือ Critical Flow แตก


# 157. Release Validation

หลัง Release ตรวจ Download, Checksum, Version, Install, Upgrade, Clean Install, Known Issues และ Rollback


# 158. Version Compatibility

มี Compatibility Matrix ของ App, API, Database Schema, Plugin, OS และ Runtime


# 159. Plugin Version

Plugin ต้องมี API Contract, Min/Max Host Version, Permissions, Sandbox, Signature, Tests และ Deprecation Policy


# 160. Deprecation

Deprecation ต้องประกาศ Alternative, Removal Date, Warning, Docs, Usage Check และถอดใน Major Version เมื่อ Breaking


# 161. Data Classification

จัด Data Classification เป็น Public, Internal, Confidential, Restricted และห้าม Restricted Data ลง GitHub


# 162. Personal Data

ห้ามใช้ Personal/Patient Data จริงใน Tests, Screenshots, Logs, Issues, PRs, Artifacts หรือ Demos


# 163. Log Redaction

Redact Password, Token, Authorization Header, Cookie, Personal Data, Private Key และ Payment Data จาก Logs


# 164. Test Data

Test Data ต้องไม่ใช่ Production จริง สร้างซ้ำได้ ลบได้ ไม่มี Secret และครอบคลุม Edge Cases


# 165. Generated File

Generated File ต้องระบุ Source, Command, Commit Policy และห้ามแก้ตรงหากมี Template


# 166. Lock File

Application ควร Commit Lock Files เช่น `pubspec.lock`, `package-lock.json`, `Cargo.lock` เพื่อ Build ทำซ้ำได้


# 167. Toolchain Pinning

Pin Version ของ Flutter, Dart, Node, Java, Gradle, Python, Rust, CMake และ Actions


# 168. Reproducible Build

Reproducible Build ต้องควบคุม Dependencies, Toolchain, Environment, Time Data, Scripts, Commit และ Network Downloads


# 169. Build Metadata

Application ควรแสดง Version, Build Number, Commit SHA, Build Date, Channel และ Environment โดยไม่เผยข้อมูลเสี่ยง


# 170. Changelog

Changelog แยก Added, Changed, Deprecated, Removed, Fixed และ Security พร้อมอ้าง Issue/PR


# 171. Conventional Release

Conventional Commits ช่วยคำนวณ Version แต่ Release Owner ต้องตรวจ Version สุดท้าย


# 172. Release Candidate

Release Candidate ต้อง Feature Freeze, Full Test, Production-like Artifact, แก้เฉพาะ Bugs และมี Known Issues


# 173. Nightly Build

Nightly ใช้ Integration Testing ไม่ถือเป็น Stable มีอายุสั้นและระบุ Commit SHA


# 174. Release Freeze

ช่วง Freeze ห้าม Feature ใหม่ อนุญาต Bug/Security Fix และต้อง Approval เพิ่ม


# 175. Branch Cleanup

หลัง Merge ลบ Branch ที่ไม่ใช้ แต่ห้ามลบ Branch ที่ยังมีงานไม่ Merge


# 176. Tag Cleanup

ห้ามลบหรือย้าย Stable Release Tags; Experimental Tags ลบได้ตามนโยบาย


# 177. Commit Signing

ระบบสำคัญอาจบังคับ Verified Commit/Tag บน Protected Branch


# 178. CODEOWNERS Advanced

CODEOWNERS ต้องครอบคลุม default `*`, `.github/`, security, core และ docs โดยตรวจลำดับ Pattern


# 179. Sensitive Path

Sensitive Paths เช่น workflows, auth, migrations, infrastructure, deployment, CODEOWNERS และ manifests ต้อง Review เพิ่ม


# 180. Binary Review

Binary ต้องมี Source, Checksum, Malware Scan, License และควรเก็บใน Release มากกว่า Git


# 181. Malware Prevention

Scan Artifact/Dependency ตรวจ Signature, Checksum และ Source ห้ามรัน Binary ไม่ทราบที่มาบน Runner สำคัญ


# 182. Workflow Change Review

ทุกการแก้ Workflow ต้องตรวจ Permissions, Secrets, Triggers, Fork Behavior, Commands, Downloads, Action Versions และ Deploy Target


# 183. Shell Script

Shell Script ต้องหยุดเมื่อ Error Validate Input Quote Variables ไม่พิมพ์ Secret และตรวจ Exit Code


# 184. PowerShell

PowerShell ใช้ `$ErrorActionPreference = 'Stop'`, ตรวจ `$LASTEXITCODE`, Validate Paths และไม่ส่ง Token ใน Command Line


# 185. YAML Validation

Workflow YAML ต้องผ่าน Syntax, Indentation, Expressions, Secret Names, Triggers และ Permission Validation


# 186. Configuration as Code

เก็บ Workflows, Dependabot, CODEOWNERS, Templates, Release Config, Infrastructure และ Security Policy เป็น Code ผ่าน PR


# 187. Policy Exception

Policy Exception ต้องมี Policy, Reason, Scope, Owner, Risk, Mitigation, Approval และ Expiration


# 188. Quality Metrics

ติดตาม Build Success, Test Pass, Lead Time, Review Time, Deployment Frequency, Change Failure, MTTR, Alert Age และ Docs


# 189. Pull Request Size

PR ควร Review ได้ หากใหญ่ให้แบ่ง Stack แยก Refactor/Feature และอธิบาย Architecture


# 190. Review SLA

กำหนด Review SLA ตาม Priority แต่ห้าม Merge ข้าม Review เพียงเพราะช้า ยกเว้น Emergency Process


# 191. Review Comment

Review Comments แยก Blocking, Suggestion, Question, Nit และ Security; Blocking ต้อง Resolve


# 192. Requested Changes

เมื่อ Requested Changes ให้แก้ อธิบายข้อโต้แย้ง รัน Tests ใหม่ และขอ Review ซ้ำ


# 193. Draft Pull Request

Draft PR ใช้ขอ Feedback และรัน CI แต่ห้าม Merge จน Ready for Review


# 194. Abandoned Pull Request

PR ไม่มีความเคลื่อนไหวให้แจ้ง Owner ใส่ stale สรุปสถานะ และปิดตามนโยบายโดยไม่ทำงานสูญหาย


# 195. Stale Automation

Stale Bot ห้ามปิด Security, Incident, Data Loss, Release Blocker หรือ Compliance Issues อัตโนมัติ


# 196. Support

กำหนด Support Channels เช่น Issues, Discussions, Email หรือ Help Desk และห้ามส่ง Secret ใน Public Issue


# 197. SECURITY.md

`SECURITY.md` ระบุ Supported Versions, Private Reporting, Required Evidence, Response Policy และ Disclosure


# 198. SUPPORT.md

`SUPPORT.md` ระบุ Channels, Scope, Versions, Required Information และสิ่งที่ห้ามส่ง


# 199. Governance

Governance ต้องกำหนดผู้ตัดสิน Architecture, Release, Security, Repository Ownership, Bypass, Incident และ Documentation


# 200. Final Enterprise Definition of Done

Enterprise Complete เมื่อมี Ownership, Rulesets, CODEOWNERS, Templates, CI/CD, Security, SBOM, Integrity, Release, Rollback, DR, Audit, AI Policy และ Documentation


# 201. Policy Rollout

นโยบายใหม่ต้องออกแบบ ทดลองกับ Repository ตัวอย่าง ใช้ Evaluate ดู Insights แก้ผลกระทบ ประกาศ Effective Date แล้ว Active


# 202. Repository Custom Properties

Custom Properties เช่น system-owner, business-owner, lifecycle, criticality, classification, deployment, support-tier และ ai-access-level


# 203. Repository Policy

Organization ควบคุมการสร้าง ลบ เปลี่ยน Visibility Transfer Fork Template และ Custom Properties ของ Repository


# 204. Custom Role

ใช้ Custom Roles เช่น Security Auditor, Release Operator, Metadata Manager, Actions Maintainer และ AI PR Operator แทน Admin


# 205. Ruleset Evaluation

Ruleset มี Disabled, Evaluate, Active และห้ามค้าง Evaluate โดยไม่มี Owner/Decision Date


# 206. Ruleset Conflict

ตรวจ Rulesets ที่ซ้อนกัน Required Check Names, Bypass Lists, Branch Patterns และระดับ Enterprise/Org/Repo


# 207. Delegated Bypass

Bypass Flow ต้องมี Request, Reason, Issue, Independent Approval และ Audit Evidence


# 208. Immutable Release

Stable Release ควร Immutable: ห้ามเปลี่ยน Tag แทนที่ Artifact หรือใช้ Version เดิมกับ Binary ใหม่


# 209. Provenance Verification

Production Artifact ต้องตรวจย้อนกลับ Repository, Commit, Workflow, Event, Environment, Approver, SBOM, Checksum และ Attestation


# 210. Artifact Promotion

Build Once, Promote Same Artifact ผ่าน Development → Staging → Production โดยใช้ artifact-id, version, SHA, checksum และ attestation


# 211. Golden Path

Golden Path: Approved Template → Registration → Ownership → Security Baseline → Standard CI → Release → Monitoring → Maintenance


# 212. Repository Scorecard

Repository Scorecard วัด Ownership, Docs, Protection, CI, Tests, Dependencies, Security, Release Integrity, Backup และ AI Governance


# 213. Repository Drift

ตรวจ Configuration Drift เช่น Ruleset, Workflow Version, CODEOWNERS, Required Checks, Secret Scan, Default Branch และ Visibility


# 214. Break-glass

Break-glass Account ใช้ฉุกเฉินเท่านั้น มี Security สูง Alert ทุกครั้ง Rotate หลังใช้ และสร้าง Incident


# 215. Human–AI Responsibility Matrix

AI ทำงานผ่าน Branch/PR; มนุษย์รับผิดชอบ Approval, Bypass, Production Deployment, Secrets และ Repository Deletion


# 216. AI Context Boundary

ก่อน AI ทำงานกำหนด Allowed Repositories/Branches/Paths, Read-only/Forbidden Paths, Commands, Network, Secrets และ Approval


# 217. AI Change Budget

กำหนด AI Change Budget เช่น จำนวนไฟล์ บรรทัด Dependencies Architecture Layers Migrations Workflows และ Risk Level


# 218. AI Evidence Manifest

AI Evidence Manifest เก็บ task_id, requester, agent, repository, base_commit, branch, files, commands, tests, builds, limitations และ risk


# 219. Periodic Governance Review

ทบทวน Owners, Membership, Admin, Bots, Keys, Apps, Rulesets, Exceptions, Secrets, Certificates, Runners, Alerts, Archives, AI Permissions และ DR


# 220. GitHub Constitution Change

การแก้ Constitution ต้องผ่าน Proposal, Impact Analysis, Migration Plan, PR, Governance Approval, Version, Changelog และ Effective Date


# 221. Universal AI Provider

ระบบต้องรองรับ OpenAI, Anthropic, Google Gemini, Azure AI, GitHub Models, Amazon Bedrock, Mistral, Cohere, xAI, DeepSeek, Groq, Ollama, LM Studio, LocalAI และ Custom OpenAI-compatible API ผ่าน Adapter/Plugin โดยไม่ผูก Core กับค่ายเดียว


# 222. AI Provider Abstraction

Core เรียกผ่าน Interface กลาง เช่น connect, disconnect, listModels, checkHealth, sendMessage, streamResponse, cancelRequest, countTokens, estimateCost และ getCapabilities ห้าม UI เรียก Provider SDK โดยตรง


# 223. Main Window AI Control

เพิ่ม AI Control บนขอบ/แถบด้านบนของหน้าต่างหลัก แสดง Provider, Model, Status, Mode, Active Task, Stop, Settings และ Usage


# 224. AI Provider Selector

ตัวเลือก `[AI Provider ▼] [Model ▼]` ต้องตรวจ Config/Credential, Test Connection, Load Models, Check Capabilities, Show Status และ Rollback Provider เดิมเมื่อเชื่อมไม่สำเร็จ


# 225. Provider Capability

Capability Registry รองรับ Text, Streaming, Image, Audio, Tool Calling, Structured Output, Code, Files, Long Context, Embeddings, Web Search, Reasoning และ Local Processing UI ปิดสิ่งที่ Model ไม่รองรับ


# 226. Provider Registry

Provider Registry เก็บ id, type, adapter, enabled, authentication, privacy และ capabilities แยกจาก Source Code


# 227. Custom AI Provider

ผู้ใช้เพิ่ม Provider เองได้ด้วย Name, Base URL, API Type/Version, Model Endpoint, Auth, Key Reference, Timeout, Streaming, Headers และ Privacy โดยไม่เก็บ API Key Plain Text


# 228. Local AI

รองรับ Ollama, LM Studio, LocalAI, llama.cpp server และ Internal Local Models ตรวจ service, endpoint, installed model, memory, context และ hardware


# 229. AI Fallback

Fallback: Primary → Secondary → Local → Manual และต้องแจ้งผู้ใช้ทุกครั้ง ห้ามส่งข้อมูลไป Provider Privacy ต่ำกว่าโดยไม่อนุญาต


# 230. AI Routing

AI Orchestrator เลือก Provider ตามงาน เช่น Coding, Long Context, Vision, Confidential Local, Cost-optimized และให้ผู้ใช้ Override


# 231. AI Mode

AI Modes: Off, Ask, Assist, Review, Plan, Agent, Autonomous Restricted ค่าเริ่มต้นควร Ask หรือ Assist


# 232. AI Status Indicator

Status ที่แสดง: Disconnected, Connecting, Connected, Thinking, Generating, Running Tools, Waiting Approval, Rate Limited, Error, Offline, Cancelled และต้องมีข้อความไม่ใช้สีอย่างเดียว


# 233. AI Task Control

ผู้ใช้ต้อง Pause, Resume, Stop, Cancel, Approve, Reject, View Plan, View Changes, View Evidence และ Open PR ได้จากหน้าต่างหลัก


# 234. AI Privacy Indicator

แสดง Privacy: Local Only, Organization Internal, Approved Cloud, External Cloud, Restricted พร้อมระบุ Data leaves device หรือไม่


# 235. Sensitive Data Routing

Password, API Key, Token, Private Key, Patient/Personal Data, Production DB, Contracts และ Incident Evidence ต้องผ่าน Classification, Redaction, Provider Policy และ Approval Gate


# 236. AI Credential

Credential เก็บใน OS Credential Manager, Environment Secret, Encrypted Vault, GitHub Secrets หรือ Organization Secret Manager ห้ามอยู่ใน Source, Logs, Screenshots, Issues, PRs หรือ Prompt History


# 237. Provider Health

ตรวจ Provider Health: Connection, Authentication, Latency, Rate Limit, Models, Service, Streaming และ Tool Calling พร้อมแสดงสถานะ


# 238. AI Cost Control

รองรับ Token/Cost Estimate, Daily/Monthly Budget, Per-task Limit, Warning Threshold และ Hard Stop


# 239. AI Conversation Portability

Conversation History ใช้รูปแบบกลาง ไม่ผูก Provider และเก็บ provider/model metadata เพื่อย้าย Context ได้


# 240. AI Provider Switching

สลับ Provider ต้อง Save State, Summarize Context, Check Compatibility/Privacy, Request Permission หากขอบเขตเปลี่ยน และบันทึก Checkpoint


# 241. Provider Lock-in Prevention

ป้องกัน Lock-in ด้วย Interface กลาง, Prompt Templates แยก SDK, Tool Schema กลาง, Neutral Conversation Format, Model Mapping และ Provider สำรอง


# 242. AI Plugin

Provider ใหม่เพิ่มผ่าน Plugin เช่น `ai_provider_openai`, `ai_provider_gemini`, `ai_provider_ollama`, `ai_provider_custom` พร้อม Manifest


# 243. AI Provider Approval

ก่อนอนุมัติ Provider ให้ตรวจ Terms, Retention, Training Policy, Data Location, Security, Auth, Logging, Deletion, Incident Response, Cost และ Availability


# 244. Main Window Layout

Main Window แนะนำ: Top Bar มี App/Project/Branch/AI Provider/Model/Status; Sidebar; Main Workspace; Resizable AI Panel; Bottom Status Bar มี Repo/Branch/Tests/AI Task/Privacy/Usage


# 245. Compact AI Header

โหมด Compact บนขอบหน้าต่างหลัก: `[AI: Provider ▼] [Model ▼] [● Status] [Ask AI] [Stop]` หน้าจอเล็กยุบเป็น `[AI ●]`


# 246. Final Universal AI Principle

Provider เปลี่ยนได้แต่ Core ต้องมั่นคง Model เปลี่ยนได้แต่ Business Rules เป็นของแอป AI ช่วยได้แต่ผู้ใช้ควบคุม Cloud ล่มได้แต่แอปต้องทำงานต่อ ข้อมูลอ่อนไหวต้องเคารพ Privacy และทุก AI Action ต้องมี Identity/Evidence


---

# GitHub Enterprise Master Flow

```text
Business Requirement
→ Architecture and Risk Review
→ Issue / Epic / Milestone
→ Branch Creation
→ Implementation
→ Local Validation
→ Commit and Push
→ Pull Request
→ Automated Quality Gates
→ Human and Security Review
→ Merge Queue
→ Build Signed Artifact
→ Generate SBOM and Attestation
→ Deploy Staging
→ Approval
→ Progressive Production Deployment
→ Health Check and Monitoring
→ Release Evidence
→ Incident and Rollback if Required
→ Documentation and Changelog
→ Close Work Item
→ Continuous Improvement
```

# Ultimate Rules

```text
No repository without an owner.
No production system without classification.
No change without evidence.
No merge without validation.
No release without provenance.
No deployment without rollback.
No bypass without audit.
No secret without rotation.
No AI action without identity.
No AI-generated risk without human accountability.
No policy without an owner.
No exception without an expiration date.
No governance document outside governance.
```
