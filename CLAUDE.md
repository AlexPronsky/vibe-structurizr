# CLAUDE.md

## Project Description

Demo repository of Middle-earth architecture. Contains:
- C4 model of the Map of Middle-earth (Structurizr DSL)
- Design solutions with business requirements (BR) and solution architecture documents (SAD)

Language of all documentation, comments, and commits — **English**.

## Project Structure

```
structurizr/
  workspace.dsl            # Main file — assembles everything via !include
  workspace.json           # DO NOT EDIT OR DELETE (element coordinates + auto-save from UI)
  common.dsl               # Peoples and common systems of Middle-earth
  domains/
    genai/                 # Ent Advisors, Elrond the Healer, Bilbo the Chronicler
    agents/                # Fellowship of the Ring, Crossroads of Bree
    mlops_and_classic_ml/  # Rings of Power, Elven Blades
    ocr/                   # Dwarven Runes
    speech_analytics/      # Isengard Listeners, Aragorn's Palantir
solutions/
  index.md                 # Solution registry
  NNN_Name/
    input/                 # Business requirements (BR*.md) and diagrams (*.png)
    output/                # Solution architecture documents (SAD*.md)
scripts/
  validate-dsl.sh          # DSL validation via Structurizr API
  export-svg.sh            # Diagram export to SVG (Puppeteer)
  export-diagrams.js       # JS export script (used by export-svg.sh)
.claude/
  skills/                  # Claude Code skills (SAD generation, resource list, SVG export)
```

## Structurizr DSL — Conventions

- Modular structure: each domain = `[domain].dsl` (model) + `views.dsl` (views)
- `workspace.dsl` uses `!identifiers hierarchical` — all identifiers are hierarchical
- **NEVER delete `workspace.json`** — contains manually positioned element coordinates on diagrams
- **Scope in `!element`:** from an `!element systemA` block you **cannot reference containers of another system** — neither via `system.container` (e.g. `bree_crossroads.knowledge_palantir`), nor by simple name (e.g. `ent_core` from `!element bree_crossroads`). A container is visible only inside the `!element` of its own system. For cross-system relationships at the container level, use `softwareSystem -> container` or `container -> softwareSystem` (the system-level side is always accessible)
- Common elements (peoples, Eagles of Manwe, Istari) are defined in `common.dsl`, available across all domains
- Comments in DSL files — in English (`// System relationships`)
- Relationships include protocol: `"REST/HTTPS"`, `"kafka"`, `"TCP"`
- **autoLayout direction:** landscape and system diagrams (systemLandscape, systemContext) — top to bottom (`autoLayout` without parameters). Container diagrams (container) — left to right (`autoLayout lr`)

### Element Tags and Styles

| Tag | Purpose | Visual Style |
|-----|---------|-------------|
| `External` | External systems | Grey (#666666) |
| `DB` | Databases | Cylinder shape |
| `Pipe` | Kafka, queues | Pipe shape |
| `NotInProd` | Artifacts not yet deployed to production | Dashed border, semi-transparent |
| `Dataflow` | Data flows | Dashed line |
| `New` | New systems/containers/relationships | Green border (#2EA44F) |
| `Changed` | Modified systems/containers/relationships | Dark blue border (#1B3A6B) |

### Example: Adding a New System to a Domain

```dsl
// In file domains/[domain]/[domain].dsl
new_system = softwareSystem "Name" "Description"

// External system
ext_system = softwareSystem "Name" "Description" "External"

// Relationship
new_system -> eye_of_sauron "Consults the Eye" "REST/HTTPS"
```

### Solution Views (Consolidated Views)

If a solution affects containers in multiple systems, create a **single consolidated view** for that solution combining all involved containers. Key format: `solution_NNN_containers` and `solution_NNN_dataflow`.

Container view is created from any of the affected systems. Containers of other systems are included via `include "element.parent==<system>"`, and related external systems via `include "->element.parent==<system>->"` ([documentation](https://docs.structurizr.com/dsl/cookbook/container-view-multiple-software-systems/)):

```dsl
// Consolidated container view for the solution
container primary_system "solution_NNN_containers" "Solution NNN: system architecture" {
    include "element.parent==primary_system"
    include "element.parent==other_system"
    include "->element.parent==primary_system->"
    include "->element.parent==other_system->"
    exclude relationship.tag==Dataflow
    exclude "element.type==SoftwareSystem -> element.type==SoftwareSystem"
    autoLayout lr
}
```

INFxx flow numbering is **sequential** across all `!element` blocks within a solution.

## Solution Documents (SAD/BR) — Structure

Each SAD follows the template:
1. **General Information** — glossary, project description
2. **Business Architecture** — link to BR, business requirements
3. **Architecture Solution** — systems, data flows, diagrams
4. **Implementation Requirements**
5. **Information Security**

Markdown tables are used for systems, flows, and glossaries.

### SAD Document Rules

- In section **3.2 Information Architecture** — **one** data flow table (with sequential INF numbering) and **one** data flow diagram (from solution view) + legend
- In section **3.3 System Architecture** — **one** container diagram (from solution view) + legend
- If the solution spans multiple systems — use the consolidated solution view, not separate diagrams per system

## Development Environment (Dev Container + Docker)

The project runs inside a **VS Code Dev Container** on WSL2. Docker containers (Structurizr etc.) run via Docker-in-Docker.

### Networking Details

- Dev Container is on the `bridge` network, Structurizr on `ai-arch_default`. By default, **they cannot see each other**.
- `host.docker.internal` **does not work** reliably in WSL2 Dev Containers — do not use.
- To connect, attach the Dev Container to Structurizr's network:
  ```bash
  docker network connect ai-arch_default $(hostname)
  ```
  After this, Structurizr is accessible by container name: `http://structurizr:8080`

### Docker volume mounts

When running `docker run` from the Dev Container, volumes are mounted **relative to the Windows host**, not the Dev Container.
Use the `HOST_PROJECT_ROOT` variable (contains the host path to the project):
```bash
docker run --rm -v "${HOST_PROJECT_ROOT}/structurizr:/work" ...
```
**Do not use** `/workspaces/ai-arch/...` in `-v` — the Docker daemon cannot see this path.

## Commands

```bash
# Start Structurizr (web UI at http://localhost:8080)
docker compose up -d

# Stop
docker compose down
```

## DSL Validation

After changing DSL files, **always** verify the result using the validation script:

```bash
scripts/validate-dsl.sh
```

The script automatically restarts Structurizr (cache reset), calls the API with HMAC authorization, and verifies DSL parsing. Exit code: 0 — valid, 1 — error (with message).

> **Important:** The old verification method via `curl -s http://structurizr:8080/workspace/diagrams > /dev/null` + `grep -i ERROR` in logs **DOES NOT WORK** — the `/workspace/diagrams` endpoint returns an HTML shell without parsing DSL. Parsing only occurs when loading workspace JSON via API (`/api/workspace/1`), which requires HMAC authorization. The `validate-dsl.sh` script does this automatically.

### Diagram Export to SVG

Export via Puppeteer — renders diagrams exactly as in the UI, preserving manual coordinates from `workspace.json`:
```bash
scripts/export-svg.sh
```
The script will automatically start Structurizr (if not running), configure the network, and export all diagrams.
Result: SVG files in `structurizr/export/`, readable via `Read`.
After review, delete: `rm -rf structurizr/export`

## File System Quirks (9p / WSL2)

The project is mounted via 9p (Windows → WSL2 → Dev Container). The 9p metadata cache can desynchronize during rapid sequential operations, causing files to become "corrupted" (`???????` in permissions, ENOENT on stat).

**Prevention:**
- **Do not use Edit/Read immediately after Write** on the same file — this is the primary trigger. If you need to create a file and immediately modify it — write the full content in a single Write call
- When creating a new file via Write — **wait** (`sync && sleep 1`) before Edit/Read on that file
- Alternative: create files via `bash` (`cat > file << 'EOF'`), this uses a single system call and avoids the issue

**If a file is already corrupted** (cannot read/edit):
1. Try saving data via `cat` (often works even when `stat`/`cp` fail): `cat file.md > file.md.bak`
2. If `cat` also fails — the content is already in context (from a previous Read result), write it to `.bak`
3. Delete the original: `rm file.md`
4. Edit the `.bak` copy
5. Rename: `mv file.md.bak file.md`
6. **Never** recreate a file from scratch by memory — always preserve data using one of the methods above

## Commit Rules

- Messages in English
- Brief description of the change (examples: "Add C2 level for the Council of the Wise", "Add dev container")
