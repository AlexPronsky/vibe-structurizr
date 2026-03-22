---
name: arch-generate-solution
description: Generate a solution architecture document (SAD) and update Structurizr DSL based on input documents from the input folder
user-invocable: true
---

# Solution Architecture Document Generation

## Task

Based on input documents (BR, descriptions, process diagrams, etc.) from the `solutions/NNN_Name/input/` folder:
1. Analyze requirements and business process
2. Make changes to the Structurizr DSL (C4 architecture)
3. Validate DSL
4. Generate a SAD document draft in `solutions/NNN_Name/output/`

## Argument

Path to the solution folder, e.g.: `solutions/005_BPMN 2.0 and BRD Generation`

If no argument is provided — iterate through `solutions/NNN_Name/` folders from highest number (NNN) to lowest. The first folder that has files in `input/` but whose `output/` folder is empty or missing — that's the target. If no such folder exists — ask the user.

## Algorithm

### Phase 1. Preparation

1. Read all files from `<solution folder>/input/`. If there are multiple files — read all of them, they complement each other.
   > **BPMN files (.bpmn):** Use the ready-made script to parse BPMN XML:
   > ```bash
   > python3 scripts/parse-bpmn.py <path to .bpmn file>
   > ```
   > The script outputs participants, message flows, lanes, and tasks — everything needed for business process analysis. No need to read BPMN XML manually or via Read.
   > **Large files:** BR documents with embedded BPMN XML often exceed the Read tool's token limit (25000). Read such files directly via `bash` (`cat file | head -N` + `cat file | tail -n +N`), not via Read — this avoids errors and retries. If BPMN XML is embedded in the document — extract it to a temporary file and pass to `scripts/parse-bpmn.py`.
   > **BPMN diagrams and PNG/JPG duplicates:** BR documents may contain references to duplicate diagrams in PNG or JPG format alongside BPMN XML. These images are visual copies of the same BPMN diagrams. No need to read them — parsing the BPMN in XML format via the script is sufficient.
2. Read the current architecture:
   - `structurizr/common.dsl` — common elements (actors, external systems)
   - `structurizr/workspace.dsl` — overall structure and includes
   - All files `structurizr/domains/*/*.dsl` — domain models and views
3. Determine which systems, containers, and relationships from the input documents already exist in the architecture and which need to be added.

### Phase 2. Clarification

**MANDATORY** ask the user clarifying questions via AskUserQuestion. This is a BLOCKING requirement — you cannot proceed to Phase 3 without explicit answers from the user in the CURRENT session.

Even if you already know the answers from auto-memory, MEMORY.md, previous sessions, or project context — **still ask**. Memory may be outdated, and the user may have changed their mind.

Questions:
- Where to place new components (in which domain/system)
- Alternative options, if any
- Any ambiguities from the input documents

**DO NOT PROCEED with changes without explicit user answers to clarifying questions in this session.**

### Phase 3. Changes to Structurizr DSL

Make changes to DSL files, following conventions from CLAUDE.md:

#### DSL Conventions (key points)

- **`!element` scope:** from `!element systemA` you cannot reference containers of another system — neither via `system.container` nor by simple name. A container is visible ONLY inside the `!element` of its own system. For cross-system relationships, one side must be softwareSystem.
- **Cross-system container relationships (hierarchical identifiers):** if containers of different systems interact with each other, in addition to relationships inside `!element` blocks (container↔softwareSystem), add **cross-system container↔container relationships outside `!element` blocks** using full hierarchical names. This provides detail on solution views — showing which specific containers of another system are involved. The block is placed at the end of the domain file, after all `!element` blocks:
  ```dsl
  // Cross-system container relationships (for solution views)
  system_a.container_x -> system_b.container_y "Description" "Protocol" "Tags"

  // Cross-system data flows
  system_b.container_y -> system_a.container_x "INFxx. Description" "" "Dataflow,New"
  ```
  This works thanks to `!identifiers hierarchical` in workspace.dsl.

  > **IMPORTANT — relationship deduplication in Structurizr:** Structurizr deduplicates relationships with **identical descriptions** between the same elements (even if one relationship is system-level and another is container-level). Because of this, cross-system container↔container relationships may not appear on the solution view if their description matches system-level relationships from `!element` blocks.
  >
  > **Rule:** descriptions of cross-system relationships (both regular and Dataflow) must be **unique** — different from descriptions of system-level relationships in `!element` blocks. The simplest approach is to make the description more specific (mention the specific container instead of the system). Example (synchronous call — one arrow on containers, one INF on dataflow):
  > ```dsl
  > // Inside !element system_a (system-level):
  > container_x -> system_b "Sends data" "REST/HTTPS" "New"
  > system_b -> container_x "INF02. Data from System B" "" "Dataflow,New"
  >
  > // Cross-system (container-level) — descriptions DIFFER:
  > system_a.container_x -> system_b.container_y "Sends data to Container Y" "REST/HTTPS" "New"
  > system_b.container_y -> system_a.container_x "INF02. Data from Container Y" "" "Dataflow,New"
  > ```
- **autoLayout:** landscape and system diagrams — `autoLayout` (top to bottom). Container diagrams (containers) — `autoLayout lr` (left to right). **Data flow diagrams (dataflow) — in the opposite direction:** if containers use `autoLayout lr`, then dataflow uses `autoLayout rl`; if containers use `autoLayout tb`, then dataflow uses `autoLayout bt`. This ensures identical element placement on both diagrams, with arrows pointing in opposite directions (dependencies vs data direction).
- Relationships include protocol: `"REST/HTTPS"`, `"kafka"`, `"TCP"`, `"MCP/HTTPS"`
- Tags: `"External"`, `"DB"`, `"Pipe"`, `"NotInProd"`, `"Dataflow"`, `"New"`, `"Changed"`
- **`"New"` and `"Changed"` tags:** all **new** elements and relationships added as part of this solution should be tagged `"New"`. All **modified** (pre-existing but being changed) elements and relationships should be tagged `"Changed"`. These tags visually highlight changes on diagrams (green border/line for New, blue for Changed). Examples:
  ```dsl
  genai_chatbot_service = container "GenAI Chatbots" "GenAI Chatbots" "Python" "New"
  genai_integrations = container "GenAI Integrations" "GenAI Integrations" "Java" "Changed"
  jaicp -> genai_chatbot_service "Forwards user questions" "REST/HTTPS" "New"
  ```
- Data flows are tagged `"Dataflow"` and follow the format `"INFxx. Description"`. INFxx numbering is **sequential within each system** — so that per-system dataflow views have sequential numbering. For example: in `!element system_a` flows are numbered INF01–INF05, in `!element system_b` — also INF01–INF03 (independently).
- Data flows between containers of different systems: in each `!element` block, describe flows at the system↔container level (not cross-system container↔container), so that containers of other systems don't "leak" onto data flow diagrams.
- **Synchronous vs asynchronous interactions:**
  - **Synchronous call** (REST/HTTPS, MCP/HTTPS, TCP, etc.) = **one** arrow on containers (from caller to callee) and **one** data flow on dataflow (showing data returned in the response — from callee to caller). Don't duplicate with a return arrow — this clutters the diagram and creates a false impression of asynchronous interaction.
  - **Asynchronous interaction** (kafka, RabbitMQ — when system A sends a message to B, then B separately calls A back) = **two** arrows on containers (A→B and B→A) and **two** data flows on dataflow.
- **Relationship and data flow consistency:** the number of arrows on the container diagram and on the data flow diagram **must match**. Each non-Dataflow relationship between a pair of elements must correspond to **exactly one** data flow (Dataflow). Don't create multiple data flows for a pair that has only one relationship. This rule applies at ALL levels: inside `!element` blocks (system↔container) and in cross-system relationships (container↔container). **Verify this after creating all relationships, before DSL validation.**
- **NEVER delete `workspace.json`**

#### Views (views.dsl)

For each new system with containers, add 3 views:
```dsl
systemContext <system> "<key>_system" "<Name> IT system" {
    include *
    exclude relationship.tag==Dataflow
    autoLayout
}

container <system> "<key>_containers" "<Name>: system architecture" {
    include *
    exclude relationship.tag==Dataflow
    exclude "element.type==SoftwareSystem -> element.type==SoftwareSystem"
    autoLayout lr
}

container <system> "<key>_dataflow" "<Name>: data flows" {
    include *
    exclude relationship.tag!=Dataflow
    exclude "element.type==SoftwareSystem -> element.type==SoftwareSystem"
    autoLayout rl
}
```

#### Solution View (Consolidated View)

If the solution affects containers in **multiple systems**, create a single consolidated view. It is used in the SAD for the single container diagram and single data flow diagram.

Key format: `solution_NNN_containers` and `solution_NNN_dataflow`.

Container view is created from any of the affected systems. Containers of all systems are included via `include "element.parent==<system>"`, and related external systems via `include "->element.parent==<system>->"` ([documentation](https://docs.structurizr.com/dsl/cookbook/container-view-multiple-software-systems/)):

```dsl
container <primary_system> "solution_NNN_containers" "Solution NNN: system architecture" {
    include "element.parent==<primary_system>"
    include "element.parent==<other_system>"
    include "->element.parent==<primary_system>->"
    include "->element.parent==<other_system>->"
    exclude relationship.tag==Dataflow
    exclude "element.type==SoftwareSystem -> element.type==SoftwareSystem"
    autoLayout lr
}

container <primary_system> "solution_NNN_dataflow" "Solution NNN: data flows" {
    include "element.parent==<primary_system>"
    include "element.parent==<other_system>"
    include "->element.parent==<primary_system>->"
    include "->element.parent==<other_system>->"
    exclude relationship.tag!=Dataflow
    exclude "element.type==SoftwareSystem -> element.type==SoftwareSystem"
    autoLayout rl
}
```

### Phase 4. DSL Validation

Run validation:
```bash
scripts/validate-dsl.sh
```

If there are errors — fix and re-validate. Do not proceed to the next phase until the DSL is valid.

### Phase 4.5. Diagram Export to SVG

First determine whether the solution affects **one** or **multiple** systems. Depending on this, perform **only one** of the two export variants.

**Before export**, comment out the contents of the `NotInProd` style in `structurizr/workspace.dsl` so that elements not deployed to production are not highlighted on diagrams in the SAD document:

```dsl
// Before:
element "NotInProd" {
    border dashed
    stroke "#666666"
    strokeWidth 4
    opacity 60
}

// After (contents commented out):
element "NotInProd" {
    // border dashed
    // stroke "#666666"
    // strokeWidth 4
    // opacity 60
}
```

#### Variant A. Solution affects one system — export per-system views

Export diagrams:
```bash
scripts/export-svg.sh
```

Copy per-system SVG files from `structurizr/export/` to `<solution folder>/output/`:
- `<key>_dataflow.svg`, `<key>_dataflow-key.svg`
- `<key>_containers.svg`, `<key>_containers-key.svg`

Delete the temporary export folder:
```bash
rm -rf structurizr/export
```

#### Variant B. Solution affects multiple systems — export solution views

1. **Renumber INF flows** in DSL files so that numbering is **sequential across all `!element` blocks** involved in the solution. Order: by systems in the same order they appear in the solution view. For example: `!element system_a` — INF01–INF05, `!element system_b` — INF06–INF08 (continuing the numbering).

2. **Export diagrams**:
   ```bash
   scripts/export-svg.sh
   ```

3. **Copy solution SVG files** from `structurizr/export/` to `<solution folder>/output/`:
   - `solution_NNN_dataflow.svg` and `solution_NNN_dataflow-key.svg`
   - `solution_NNN_containers.svg` and `solution_NNN_containers-key.svg`

4. **Restore INF flow numbering** — revert to per-system numbering (INF01–INFxx within each system), so the DSL remains in a consistent state for per-system views.

5. Delete the temporary export folder:
   ```bash
   rm -rf structurizr/export
   ```

**After export**, uncomment the `NotInProd` style contents back to the original state (remove `// ` before each line inside the block).

#### Containers and Dataflow Diagram Consistency Verification

After copying SVG files to output, **always** verify consistency using the ready-made script:

```bash
bash scripts/verify-svg-consistency.sh <solution folder>/output/*_containers.svg <solution folder>/output/*_dataflow.svg
```

The script counts arrows (by protocols `[REST/HTTPS]`, `[MCP/HTTPS]`, etc.) on containers and unique INF codes on dataflow. If counts don't match — the script exits with code 1.

**If counts don't match** — typical causes and fixes:
1. **Extra data flows (more INFs than arrows on containers):** multiple data flows created for a pair of elements (request + response), but only one relationship. For synchronous calls there should be **one** relationship and **one** data flow — remove the extra one.
2. **Extra reverse arrows on containers:** a reverse relationship B→A created for a synchronous call (REST, MCP) in addition to the direct A→B. Remove the reverse — synchronous calls are shown as a single arrow from the caller.
3. **Cross-system Dataflow relationships not appearing on solution view:** Structurizr deduplicates relationships with identical descriptions. If a cross-system container↔container relationship has the same description as a system-level relationship from the `!element` block — change the cross-system relationship description to make it unique (e.g., mention the specific container instead of the system).
4. **System-level relationship appearing instead of container-level:** on the solution view both systems are expanded to containers, system-level relationships may be suppressed. Ensure that for each system-level relationship there is a cross-system container-level counterpart with a **unique** description.

After fixing — re-export SVG and verify again.

#### Legend Processing (key SVG)

After copying, edit the legend SVG files (`*-key.svg`) to reduce element sizes:
- Reduce all sizes by **half**: rect, font-size, tspan dy, rx/ry, stroke-width — all proportionally. Exact original sizes may vary between files — the key is to maintain the ×0.5 ratio (e.g., rect `450x300` → `225x150`, font-size `30px` → `15px`, tspan dy `40px` → `20px`)
- Place **up to 8 elements** per row with ~250px horizontal spacing. If more than 8 elements — wrap to the next row
- Arrows (Dataflow, Relationship, etc.) should also be reduced proportionally and shifted vertically for visual alignment with rectangles
- Update viewBox to match actual content: width = min(element count, 8) × 250 + padding, height ≈ 200 per row

### Phase 5. SAD Generation

#### Preparation: Examples from Existing Solutions

1. Read the file `solutions/index.md` — registry of all solutions.
2. Select **one most relevant** existing solution (by topic, involved systems, or integration type).
3. Read the SAD document for that solution from `solutions/NNN_Name/output/`.
4. Extract examples of table field values: "CMDB Link", "Account Type", "Credential Storage", "Location", "Criticality", "Technology Stack", etc.
5. When generating the SAD — if the new solution involves **the same systems or similar fields**, use values from examples (CMDB links, account types, location, etc.) to ensure consistency between solutions.

#### Document Generation

Create the file `<solution folder>/output/SAD <Name>.md` using the template:

```markdown
# SAD <Project Name>

# 1. General Project/Task Information

## 1.1 Glossary

| Term | Description |
| --- | --- |
| ... | ... |

## 1.2 Project/Task Description

<Goals, customer, consumers, constraints — from input documents>

# 2. Business Architecture and Requirements

[<Document Name>](../input/<file name>.md)

# 3. Architecture Solution Description

## 3.1 Proposed Solution Description

<Textual description of the solution>

**List of systems and IT services used:**

| System/Service | Description | CMDB Link |
| --- | --- | --- |
| ... | ... | |

<Description of microservices and components>

## 3.2 Information Architecture

### Data Flow Diagram

![](solution_NNN_dataflow.svg)

![](solution_NNN_dataflow-key.svg)

**Data flow description:**

| Code | Data Object | Source | Consumer | Type | Status | Mode | Data | Protocol | Transport | Comment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| INF01 | ... | ... | ... | ... | New | Synchronous | ... | REST/HTTPS | HTTP | |

## 3.3 System Architecture

### Container Diagram

![](solution_NNN_containers.svg)

![](solution_NNN_containers-key.svg)

# 4. Implementation

## 4.1 Implementation Requirements

- ...

## 4.2 System and IT Service Modifications

| System/Service | Work Description |
| --- | --- |
| ... | ... |

# 5. Information Security

## 5.1 Authentication and Authorization

| Purpose | Consumer System | Account Type | Status | Role | Role Status | Credential Storage | Data Flows |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ... | ... | Service | New | ... | New | Vault | ... |

## 5.2 Logging and Audit

<Logging requirements from input documents>

## 5.3 External Data Access

<Description or "Not required">

## 5.4 System and IT Service Publishing

| System/Service | Location |
| --- | --- |
| ... | Citadel of Minas Tirith |

## 5.5 Flows with Protected Information

<Description of protected data in flows>

## 5.6 File Exchange with External Systems

- <Description or "Not required">

# 6. Support Information

| System/Service | Development Contact | Support Team | Criticality | Technology Stack |
| --- | --- | --- | --- | --- |
| ... | | | | ... |

# 7. Non-Functional Requirements

| Metric | Value |
| --- | --- |
| ... | ... |

# 8. Open Questions

1. ...
```

**SAD filling rules:**
- In section 3.2 — **one** data flow table with sequential INF numbering (numbering must match the SVG diagram of the solution view — i.e., sequential across all affected systems) and **one** data flow diagram (from solution view) + legend
- In section 3.3 — **one** container diagram (from solution view) + legend
- Glossary: take from input documents, supplement with architecture terms
- Data flows: must correspond to INFxx from DSL
- Systems table: all systems and containers involved in the solution
- NFRs: transfer from the NFR section of input documents
- Open questions: document unresolved questions identified during analysis
- Security section: secrets in Vault, all flows with authorization, logging per Security Service requirements

### Phase 6. Final Verification

1. Extract relationship labels from SVG diagrams to cross-reference with the data flow table in the SAD:
   ```bash
   python3 scripts/extract-svg-labels.py <solution folder>/output/*_containers.svg <solution folder>/output/*_dataflow.svg
   ```
   The script automatically detects diagram type and outputs: for containers — description + protocol of each arrow, for dataflow — INF codes with descriptions. Cross-reference the output with the data flow table in the SAD.
2. Ensure consistency of INF codes, system names, and descriptions between SAD and DSL
3. Update the SAD document if needed
4. Present a summary of changes to the user
