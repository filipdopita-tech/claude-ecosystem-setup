# REQUIREMENTS.md
# Purpose: What must be true for this project to be correct.
# Update cadence: append-only — never delete requirements; mark superseded ones DEPRECATED.
# Read before implementing features or writing tests.

---

## Functional Requirements

<!-- Numbered FR-001 onward. Each requirement is a single testable statement. -->
<!-- Format: FR-NNN | Priority (MUST/SHOULD/COULD) | Status (ACTIVE/DEPRECATED) | Description -->

| ID      | Priority | Status     | Description                                                                |
|---------|----------|------------|----------------------------------------------------------------------------|
| FR-001  | MUST     | ACTIVE     | [FUNCTIONAL_REQUIREMENT_1]                                                 |
| FR-002  | MUST     | ACTIVE     | [FUNCTIONAL_REQUIREMENT_2]                                                 |
| FR-003  | SHOULD   | ACTIVE     | [FUNCTIONAL_REQUIREMENT_3]                                                 |
| FR-004  | COULD    | ACTIVE     | [FUNCTIONAL_REQUIREMENT_4]                                                 |
# Example rows:
# | FR-001 | MUST   | ACTIVE | User can upload an HTML file and receive a rendered MP4 within 60 seconds. |
# | FR-002 | MUST   | ACTIVE | System retries failed render jobs up to 3 times before marking as failed.  |
# | FR-003 | SHOULD | ACTIVE | User receives an email notification when the render completes.             |

## Non-Functional Requirements

### Performance

| ID      | Requirement                                                                        |
|---------|------------------------------------------------------------------------------------|
| NFR-P-1 | [PERFORMANCE_REQUIREMENT_1]                                                        |
| NFR-P-2 | [PERFORMANCE_REQUIREMENT_2]                                                        |
# Example:
# | NFR-P-1 | API p95 response time must be under 200 ms for all endpoints except /render. |

### Security

| ID      | Requirement                                                                        |
|---------|------------------------------------------------------------------------------------|
| NFR-S-1 | [SECURITY_REQUIREMENT_1]                                                           |
| NFR-S-2 | [SECURITY_REQUIREMENT_2]                                                           |
# Example:
# | NFR-S-1 | All API keys must be stored as environment variables; never committed to git. |
# | NFR-S-2 | All user-uploaded files must be scanned for malicious content before processing. |

### Accessibility

| ID      | Requirement                                                                        |
|---------|------------------------------------------------------------------------------------|
| NFR-A-1 | [ACCESSIBILITY_REQUIREMENT_1]                                                      |
# Example:
# | NFR-A-1 | Web UI must meet WCAG 2.1 AA standards for all interactive components. |

### Reliability

| ID      | Requirement                                                                        |
|---------|------------------------------------------------------------------------------------|
| NFR-R-1 | [RELIABILITY_REQUIREMENT_1]                                                        |
# Example:
# | NFR-R-1 | Service uptime must be 99.5% or higher measured monthly. |

## Acceptance Criteria

<!-- Link each AC to one or more FR IDs. Written in Given/When/Then or checklist style. -->

### AC for FR-001

- [ ] [ACCEPTANCE_CRITERION_1_FOR_FR_001]
- [ ] [ACCEPTANCE_CRITERION_2_FOR_FR_001]
# Example:
# - [ ] Given a valid HTML file, when uploaded via the API, then a job ID is returned within 2 s.
# - [ ] Given a job ID, when polled after processing, then the response contains a download URL.

### AC for FR-002

- [ ] [ACCEPTANCE_CRITERION_1_FOR_FR_002]
# Add sections as needed following this pattern.

## Change log

<!-- Append an entry whenever a requirement is added or changed. -->

| Date       | Changed by     | Change                                         |
|------------|----------------|------------------------------------------------|
| [DATE]     | [AUTHOR]       | Initial requirements captured.                 |
