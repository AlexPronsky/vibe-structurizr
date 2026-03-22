# Architecture as Code + LLM: Demo Repository

Demo repository for the article: **"Did you know that LLMs can take the Architecture as Code approach to the next level?"**

This repository demonstrates an approach to automating architectural work using **Structurizr DSL** (Architecture as Code) and **Claude Code** (LLM assistant). The architecture is described using the IT landscape of Middle-earth as an example.

**Other languages:**
- [`Russian version`](https://github.com/AlexPronsky/vibe-structurizr/tree/main-ru)

## Concept

Architects spend up to 80% of their time not on making decisions, but on documenting them: drawing diagrams, filling in tables, synchronizing artifacts, iterating on review comments. The **Architecture as Code** approach transforms architecture from pictures into code, and an **LLM agent** takes over the routine: generating DSL code, creating document drafts, and performing preliminary reviews.

## Project Structure

```
structurizr/
  workspace.dsl              # Main file — assembles everything via !include
  workspace.json             # Element coordinates on diagrams (auto-save from UI)
  common.dsl                 # Common actors and external systems (peoples of Middle-earth)
  domains/                   # Architectural domains
    genai/                   #   Ent Advisors, Elrond the Healer, Bilbo the Chronicler
    agents/                  #   Fellowship of the Ring, Crossroads of Bree
    mlops_and_classic_ml/    #   Rings of Power, Elven Blades
    ocr/                     #   Dwarven Runes
    speech_analytics/        #   Isengard Listeners, Aragorn's Palantir

solutions/                   # Design solutions
  index.md                   #   Solution registry
  NNN_Name/
    input/                   #   Business requirements (BR) and process diagrams
    output/                  #   Solution architecture documents (SAD)

scripts/
  validate-dsl.sh            # DSL validation via Structurizr API
  export-svg.sh              # Diagram export to SVG (Puppeteer)
  export-diagrams.js         # JS export script

docs/
  Security Standards/           # Security standards considered during review
  Corporate Architecture Standards/  # Corporate standards considered during review

.claude/
  skills/                    # Claude Code Skills
    arch-generate-solution/  #   Solution architecture document generation
    arch-review-solution/    #   Architecture review from 5 roles
    arch-make-svg/           #   Diagram export to SVG
    arch-list-resources/     #   Resource table collection from containers
    arch-merge-conflict/     #   Conflict resolution in workspace.json
```

## Skills — What the LLM Agent Can Do

The repository contains 5 skills for Claude Code, each being a natural language instruction describing a complex algorithm:

| Skill | Description |
|-------|-------------|
| **arch-generate-solution** | Takes a business requirements file, asks clarifying questions, modifies the DSL model, validates it, and generates a solution architecture document draft in Markdown |
| **arch-review-solution** | Reviews a completed solution from the perspective of 5 roles (Solution Architect, Enterprise Architect, Security, Adjacent System Owner, Business Process Owner) and produces a findings report |
| **arch-make-svg** | Renders all Structurizr views as SVG files |
| **arch-list-resources** | Parses the DSL and compiles a resource summary table (CPU/GPU/RAM/SSD/Replicas) for all containers |
| **arch-merge-conflict** | Resolves merge conflicts in `workspace.json` while preserving element coordinates |

## Quick Start

### Requirements

- Docker and Docker Compose
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (CLI or IDE plugin)

### Step 1. Configure ENV and Start Structurizr

```bash
cp .env.example .env
docker compose up -d
```

The web interface will be available at http://localhost:8080. Structurizr is needed for DSL validation and diagram export — the skills call it automatically.

### Step 2. Generate a Solution Architecture Document

The repository already includes sample business requirements: [`solutions/001_Forging Runic Diagrams and Covenant Scrolls/input/BR Forging Runic Diagrams and Covenant Scrolls.md`](solutions/001_Forging%20Runic%20Diagrams%20and%20Covenant%20Scrolls/input/BR%20Forging%20Runic%20Diagrams%20and%20Covenant%20Scrolls.md). Run the skill without parameters — it will automatically find this solution and generate a SAD:

```
/arch-generate-solution
```

What happens:
1. The agent reads the BR and the current C4 model
2. Asks clarifying questions — which domain to place components in, which options to choose
3. Makes changes to the Structurizr DSL (new systems, containers, relationships)
4. Validates the DSL via `scripts/validate-dsl.sh`
5. Exports diagrams to SVG via `scripts/export-svg.sh`
6. Generates a SAD document draft in `solutions/NNN_Name/output/`

Output — an updated C4 model, SVG diagrams (containers + data flows), and a ready SAD draft in Markdown.

### Step 3. Review the Architecture Solution

After generation (or for any existing SAD), run the review:

```
/arch-review-solution solutions/NNN_Name
```

The agent will conduct a review from the perspective of 5 roles:
- **Solution Architect** — technical quality, decomposition, NFRs
- **Enterprise Architect** — alignment with IT landscape, system reuse
- **Security Specialist** — authentication, secrets, data protection
- **Adjacent System Owner** — impact on each affected system
- **Business Process Owner** — coverage of business requirements

Output — a structured report with findings (critical / significant / minor / recommendations) in `solutions/NNN_Name/output/`.

## Key Features of the Approach

- **Single source of truth** — one model generates all diagrams (landscape, containers, data flows)
- **Version control** — architecture is stored in git, enabling diff and code review
- **Multiple views of one model** — via the tag mechanism: one model, but dependency and data flow diagrams are generated separately
- **Automatic validation** — DSL is verified via the Structurizr API, errors are caught before review
- **LLM automation** — DSL code, document, and review generation via Claude Code Skills

## Links

- [Structurizr](https://structurizr.com/) — Architecture as Code tool in C4 Model format
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — LLM assistant with file system access
- [Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code/skills) — Custom commands for Claude Code
