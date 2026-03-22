---
name: arch-review-solution
description: Conduct an architecture review of a solution (SAD) from 5 role perspectives and generate a findings report
allowed-tools: Read, Grep, Glob, Write, Edit, Bash, Agent, AskUserQuestion, TodoWrite
user-invocable: true
---

# Architecture Solution Review

## Task

Conduct a comprehensive review of an architecture solution (SAD) from the perspective of 5 roles, each with its own focus area and set of competencies. Generate a structured report with findings and recommendations.

## Argument

Path to the solution folder, e.g.: `solutions/005_BPMN 2.0 and BRD Generation`

If no argument is provided — ask the user.

## Algorithm

### Phase 1. Context Gathering

1. Read **all files** from `<solution folder>/input/` — business requirements (BR), descriptions, process diagrams.
   > **Large files:** BR documents with embedded BPMN XML often exceed the token limit. Read such files via `bash` (`cat file | head -N` + `cat file | tail -n +N`), not via Read.

2. Read **all files** from `<solution folder>/output/` — solution architecture document (SAD), SVG diagrams should also be read, SVG diagrams with the *-key.svg name pattern should not be read.

3. Read the current C4 architecture:
   - `structurizr/common.dsl` — common elements
   - All files `structurizr/domains/*/*.dsl` — domain models

4. If the `docs/` folder contains standards — read them. They contain normative requirements to reference during review. Standards may cover:
   - Architectural principles and rules
   - Information security requirements (Security Service)
   - Infrastructure standards
   - DevOps practices and requirements
   - Integration standards

5. Read `solutions/index.md` and **2–3 existing SADs** from `solutions/NNN_Name/output/` to understand the overall quality level and consistency between solutions.

### Phase 2. Review by Roles

Conduct a sequential review of the solution from the perspective of each of the 5 roles. For each role — **embody it**, use its focus area and competencies to identify findings, risks, and recommendations.

---

#### Role 1: Solution Architect

**Focus area:** technical quality of the solution, architecture correctness, completeness of design.

**Competencies and what to check:**
- **Component architecture:** is the solution properly decomposed into components/containers? Is there any mixing of responsibilities (SRP)? Are there redundant components?
- **Integration patterns:** are the chosen interaction patterns correct (sync/async, request-reply, event-driven)? Is there a single point of failure (SPOF)? Are error handling, timeouts, retries provided for?
- **Data flows:** are all flows described? Do protocols and data formats match standards? Are there implicit flows not reflected in the table?
- **Technology stack:** is the technology choice justified? Does the stack match accepted standards?
- **NFRs:** are non-functional requirements sufficient? Are there performance, availability, scalability metrics? Are claimed values realistic?
- **Modification descriptions:** are work descriptions sufficiently detailed for each system? Can effort be estimated from them?
- **Diagrams vs text:** do diagrams (containers, data flows) match the textual description? Are there discrepancies in system names, components, flows?
- **Open questions:** are all uncertainties documented? Are there hidden assumptions that could affect implementation?
- **Solution completeness:** does the SAD cover all requirements from the BR? Are there missing functional requirements?

---

#### Role 2: Enterprise Architect

**Focus area:** alignment with IT landscape, reuse of existing capabilities, impact on architecture.

**Competencies and what to check:**
- **IT landscape alignment:** does the solution fit the existing IT landscape (C4 model)? Does it duplicate capabilities of existing systems?
- **Reuse:** are existing systems, services, integrations maximally utilized? Are there cases where a new component is created instead of enhancing an existing one?
- **Consistency:** are system and component names aligned with CMDB and C4 model? Are naming conventions followed?
- **Architectural principles:** are architectural principles followed (if defined in `docs/`)?
- **Impact on adjacent systems:** has the impact on adjacent systems been assessed? Does the solution create excessive dependencies?
- **Solution scalability:** can the solution be scaled for other business domains? Are there built-in limitations that would prevent reuse?
- **Data management:** does the data model conform to standards? Is data being duplicated?
- **CMDB links:** are CMDB links filled in for all systems? If not — which systems need entries created?

---

#### Role 3: Information Security Specialist (Security Service)

**Focus area:** information protection, compliance with security policies, access management, audit.

**Competencies and what to check:**
- **Authentication and authorization:** are all inter-service interactions authenticated and authorized? Are all service accounts described? Are account types correct (service, JWT, etc.)?
- **Secret management:** are all secrets, tokens, keys stored in Vault? Are there hardcoded secrets? Is the rotation mechanism described?
- **Data protection in flows:** which flows contain protected information (PII, trade secrets, internal information)? Are protection measures sufficient (encryption, masking)?
- **Eye of Sauron and LLM:** do all LLM calls go through the Eye of Sauron? Is masking/unmasking implemented? Is there DLP verification?
- **Logging and audit:** does logging meet Security Service requirements? Are all critical operations logged? Is user action audit in place?
- **Network security:** are network segments and firewall rules described? In which namespace are services deployed? Does placement meet Security Service requirements?
- **Data access:** is the principle of least privilege followed? Are there excessive access rights to the Task Palantir / Library / other systems?
- **External system exchange:** is there data exchange with external systems? If so — is it approved by the Security Service?
- **Data classification:** are categories of processed data defined? Do protection measures match the data category?

---

#### Role 4: Adjacent System Owner

**Focus area:** impact of the solution on my system, new dependencies, SLA, operational aspects.

**Competencies and what to check:**

First identify **all adjacent systems** affected by the solution (both existing and new). For each adjacent system, conduct a review as its owner:

- **New dependencies:** what new integrations are proposed with my system? Are they agreed upon?
- **Load and SLA:** how will the solution impact my system's load? Does the expected load fit within current limits? Will SLA degrade?
- **Modifications to my system:** what modifications are proposed for my system? Are timelines and effort realistic? Who will implement the modifications?
- **Backward compatibility:** do the changes break existing integrations of my system with other consumers?
- **Operational support:** who will support the new integrations? Are development contacts and support teams defined? Is the support information sufficient?
- **Monitoring and alerting:** is monitoring of new integrations provided for? How will I learn about problems?
- **Rollback and degradation:** what happens if the new integration fails? Is graceful degradation provided for?

---

#### Role 5: Business Process Owner

**Focus area:** coverage of business requirements, end-user convenience, business value.

**Competencies and what to check:**
- **Requirements coverage:** are all business requirements from the BR implemented in the SAD? Compose a mapping: requirement → how it's implemented in the SAD. Mark missing or partially covered requirements.
- **User journey:** is the full user journey described? Is it clear? Are there unnecessary steps or non-obvious actions?
- **Business value:** does the SAD solve the stated business problems? Will the expected outcome be achieved (reduced effort, improved quality, etc.)?
- **Business constraints:** what constraints does the technical solution impose on the business process? Are they acceptable?
- **Usability:** how convenient is the solution for end users (process owners, analysts, methodologists)? Are their needs considered?
- **Iterability and flexibility:** does the solution support iterative refinement? Can artifacts be improved through prompt chains?
- **Artifact quality:** how is the quality of generated BPMN/BRD ensured? Is validation sufficient? Do artifacts meet standards?
- **Open questions:** are there unresolved questions blocking launch? Do "out of scope" limitations affect business value?

---

### Phase 3. Report Generation

Create the file `<solution folder>/output/SAD Review <Name>.md` using the following template:

```markdown
# SAD Review <Name>

**Review date:** <current date>
**Reviewed document:** [SAD <Name>](SAD <Name>.md)

## Summary

| Role | Critical | Significant | Minor | Recommendations |
| --- | --- | --- | --- | --- |
| Solution Architect | N | N | N | N |
| Enterprise Architect | N | N | N | N |
| Security Specialist (Security Service) | N | N | N | N |
| Adjacent System Owner | N | N | N | N |
| Business Process Owner | N | N | N | N |
| **Total** | **N** | **N** | **N** | **N** |

### Finding Classification

- 🔴 **Critical** — blocks implementation or creates significant risk. Requires mandatory correction before SAD approval.
- 🟡 **Significant** — notable deficiency that needs to be addressed, but doesn't block implementation.
- 🟢 **Minor** — small defect, typo, stylistic comment.
- 💡 **Recommendation** — improvement suggestion, not a finding.

---

## 1. Solution Architect

### Findings

| # | Severity | SAD Section | Description | Recommendation |
| --- | --- | --- | --- | --- |
| SA-1 | 🔴/🟡/🟢 | <section> | <problem description> | <what needs to be done> |
| ... | ... | ... | ... | ... |

### Overall Assessment

<Brief summary from the Solution Architect perspective: strengths of the solution and main areas for improvement>

---

## 2. Enterprise Architect

### Findings

| # | Severity | SAD Section | Description | Recommendation |
| --- | --- | --- | --- | --- |
| EA-1 | 🔴/🟡/🟢 | <section> | <problem description> | <what needs to be done> |
| ... | ... | ... | ... | ... |

### Overall Assessment

<Brief summary from the Enterprise Architect perspective>

---

## 3. Information Security Specialist (Security Service)

### Findings

| # | Severity | SAD Section | Description | Recommendation |
| --- | --- | --- | --- | --- |
| SEC-1 | 🔴/🟡/🟢 | <section> | <problem description> | <what needs to be done> |
| ... | ... | ... | ... | ... |

### Overall Assessment

<Brief summary from the Security Specialist perspective>

---

## 4. Adjacent System Owner

For each affected adjacent system — a separate subsection.

### 4.1 <System Name 1>

| # | Severity | SAD Section | Description | Recommendation |
| --- | --- | --- | --- | --- |
| SYS-1 | 🔴/🟡/🟢 | <section> | <problem description> | <what needs to be done> |
| ... | ... | ... | ... | ... |

### 4.2 <System Name 2>

| # | Severity | SAD Section | Description | Recommendation |
| --- | --- | --- | --- | --- |
| SYS-N | 🔴/🟡/🟢 | <section> | <problem description> | <what needs to be done> |
| ... | ... | ... | ... | ... |

### Overall Assessment

<Brief summary from the adjacent system owners' perspective>

---

## 5. Business Process Owner

### Business Requirements Coverage

| Requirement from BR | Status | Comment |
| --- | --- | --- |
| <requirement> | ✅ Covered / ⚠️ Partial / ❌ Not covered | <explanation> |
| ... | ... | ... |

### Findings

| # | Severity | SAD Section | Description | Recommendation |
| --- | --- | --- | --- | --- |
| BIZ-1 | 🔴/🟡/🟢 | <section> | <problem description> | <what needs to be done> |
| ... | ... | ... | ... | ... |

### Overall Assessment

<Brief summary from the Business Process Owner perspective>

---

## Final Conclusion

<Overall summary of the review across all roles. Key risks, mandatory improvements, recommendations for next steps>

### Recommended Order for Addressing Findings

1. <Critical findings — by priority>
2. <Significant findings — by priority>
3. <Minor findings and recommendations>
```

### Phase 4. Final Verification

1. Re-read the generated report and verify:
   - All 5 roles are represented
   - Summary table correctly reflects the number of findings
   - Finding numbering is sequential within each role (SA-1, SA-2, ...; EA-1, EA-2, ...; etc.)
   - Findings are specific — reference specific SAD sections and contain actionable recommendations
   - No duplicate findings between roles (if overlapping — include cross-reference like "see also SA-N")
2. Present a summary to the user: finding count per role and overall verdict

## Review Rules

- **Be specific:** each finding must reference a specific section, table, or wording in the SAD. Avoid generic phrases like "insufficiently detailed."
- **Be constructive:** each finding must include a correction recommendation.
- **Consider context:** reference business requirements from `input/`, standards from `docs/`, the existing C4 model, and other SADs.
- **Don't invent problems:** if a section is well designed — note it in the overall assessment. Don't look for findings where there are none.
- **Separate roles:** a finding from the Solution Architect should not concern security (that's the Security Service's domain), and a Security Service finding should not concern business value (that's the Process Owner's domain). If a finding spans roles — place it in the most relevant role and add a cross-reference.
