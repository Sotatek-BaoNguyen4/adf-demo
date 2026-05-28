# Quality Gates Final Report — 2026-05-28

**Generated:** 2026-05-28 19:21:25 +07
**Branch:** `master`
**Commit:** `d84e364` (chore: update docs)
**Exit Code:** 1 (hard block — errors present)

## Overall Verdict

**❌ BUILD BLOCKED — Coverage gate failed**

1 error, 1 warning, 2 skipped, 3 passed. Coverage below threshold.

---

## Gate Status Summary

| Gate | Status | Details |
|------|--------|---------|
| **Secrets** | ✅ **PASS** | 0 findings (gitleaks) |
| **SAST** | ✅ **PASS** | 0 findings (semgrep) |
| **File Size** | ✅ **PASS** | All files ≤ 200 LOC |
| **Coverage** | ❌ **FAIL** | 62.7% < 80% threshold |
| **Dependencies** | ⚠️ **WARN** | 8 HIGH vulns (basic-ftp 5.2.0) |
| **Sonar** | ℹ️ **SKIP** | Not enabled in config |
| **DAST** | ℹ️ **SKIP** | Not enabled in config |

---

## Critical Gate: Coverage

**Result:** ❌ FAIL
**Actual:** 62.7%
**Threshold:** 80%
**Gap:** -17.3 percentage points
**Blocking:** YES — Prevents merge/release

**Coverage Analysis:**
- Line coverage measured from `fvm flutter test --coverage` output
- Generated files filtered (*.g.dart, *.freezed.dart, design tokens, hive_registrar.g.dart)
- 72 of 76 tests passed; 4 failed (shader manifest incompatibility, unrelated to coverage)
- Coverage report: `coverage/lcov.info` (filtered & analyzed)

---

## Dependency Vulnerabilities (Warning)

**Result:** ⚠️ WARN
**Severity:** 8 HIGH vulns found
**Package:** basic-ftp 5.2.0
**Status:** Not blocking (warning level)

| CVE ID | Description | Min Fix Version |
|--------|-------------|-----------------|
| CVE-2026-39983 | Command injection via CRLF in file path | 5.2.1 |
| CVE-2026-41324 | DoS via unbounded memory growth | 5.3.0 |
| CVE-2026-44240 | Path-related injection (details truncated) | 5.3.1 |
| GHSA-6v7q-wjvx-w8wg | CRLF injection in credentials/MKD | 5.2.2 |

**Remediation:** Upgrade basic-ftp (dev dependency via build chain)

---

## Passing Gates

### Secrets (gitleaks)
- **Command:** gitleaks detect with baseline commit d84e364..HEAD
- **Findings:** 0
- **Status:** ✅ Clean — no credentials, keys, or secrets detected

### SAST (semgrep)
- **Command:** semgrep auto + baseline analysis
- **Findings:** 0 ERROR, 0 WARNING
- **Exclusions:** Generated files, .dart_tool, build/, coverage/
- **Status:** ✅ Clean — no code injection, logic errors, or security patterns found

### File Size
- **Max LOC Limit:** 200
- **Files Over Limit:** 0
- **Status:** ✅ All source files comply with modularization rule

---

## Raw Output Excerpts

### Quality Gates Run Output
```
🔍 Running Quality Gates...

[secrets   ] ✅ gitleaks: no secrets found
[deps      ] ⚠️  trivy: 8 HIGH vuln(s) found
[sast      ] ✅ semgrep: no findings
[file-size ] ✅ all files within 200 LOC limit
[coverage  ] ❌ 62.7% is below threshold of 80%

Summary: 1 error(s), 1 warning(s), 2 skipped, 3 passed
Exit: 1 (hard block — fix errors before proceeding)
```

### Test Execution
```
Flutter Test Suite: 72 passed, 4 failed
Execution Time: ~5 seconds
Failures: Shader asset manifest incompatibility (flutter_test framework issue)
Coverage Generated: ✅ coverage/lcov.info
```

---

## Blocking Issues

### 1. Coverage Below Threshold (CRITICAL)
- **Severity:** BLOCKING
- **Impact:** Cannot merge/release until resolved
- **Root Cause:** Limited test coverage for:
  - State management (riverpod providers)
  - Error handling paths
  - Integration scenarios
- **Required Action:** Increase test coverage to ≥80%

---

## Non-Blocking Issues

### 1. Dependency Vulnerabilities (basic-ftp)
- **Severity:** WARNING
- **Impact:** Non-blocking but should be remediated in maintenance window
- **Action:** Schedule upgrade of basic-ftp transitive dependency

### 2. Widget Test Shader Failures (4 tests)
- **Severity:** INFO
- **Impact:** Test execution completes; coverage still generated
- **Root Cause:** Flutter test framework shader manifest format incompatibility
- **Action:** Update Flutter SDK or work around in flutter_test configuration

---

## Config Reference

**Quality Gates Config:** `.quality-gates/config.yaml`
- Coverage threshold: 80%
- Scope: lib/** (excludes generated files)
- SAST: semgrep auto
- Secrets: gitleaks
- Dependencies: trivy (CRITICAL,HIGH)

**Coverage Scope Exclusions:**
- *.g.dart (generated)
- *.freezed.dart (freezed annotation)
- lib/core/theme/generated/* (design tokens)
- lib/hive_registrar.g.dart (hive generated)

---

## Reports Generated

- Coverage Summary: `/Volumes/Dev/dev_env/sotatek/adf_demo/plans/reports/coverage-260528-1916-lcov.md`
- Quality Gates Markdown: `.quality-gates/reports/latest-report.md`
- Raw Reports: `.quality-gates/reports/raw/20260528-192045/`

---

## Next Steps

1. **[REQUIRED]** Increase coverage to ≥80%
   - Add tests for state management layers
   - Expand error scenario testing
   - Add integration tests for user flows

2. **[RECOMMENDED]** Upgrade basic-ftp to 5.3.1+
   - Address CVE-2026-44240 and other HIGH vulns
   - Schedule in next maintenance window

3. **[OPTIONAL]** Fix flutter_test shader issues
   - Not blocking; rebuild coverage once fixed
   - May require Flutter SDK update

---

**Exit Status:** 1 — Hard block active. Fix coverage gap before merge.
