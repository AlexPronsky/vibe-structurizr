---
name: arch-list-resources
description: Collect all containers from Structurizr DSL and generate a resource table in resources.md
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# Collecting Containers from Structurizr DSL

## Task

Find all `container` definitions in all `.dsl` files of the project and generate a Markdown table.

## Algorithm

1. Find all `.dsl` files in `structurizr/`:
   ```
   Glob: structurizr/**/*.dsl
   ```

2. In each file, find `!element <system_id>` blocks — they contain containers. Get the system name from the `softwareSystem` definition in the same file (or in `common.dsl`).

3. Inside `!element`, find all lines of the form:
   ```
   <id> = container "<Name>" ...
   ```
   Extract the **container name** (the first string argument in quotes after `container`).

4. Determine the **system name** — find the `softwareSystem` with the corresponding identifier. The name is the first argument in quotes.

5. Generate the file **`resources.md` in the project root** (path: `./resources.md`, NOT in `solutions/`) with the following content:

```markdown
# Container Resources

| System | Container | CPU | RAM | GPU | SSD | Replicas |
|--------|-----------|-----|-----|-----|-----|----------|
| <system name> | <container name> | | | | | |
```

- Group rows by system (all containers of one system listed together)
- Sort systems alphabetically, containers within a system — also alphabetically
- Leave CPU, RAM, GPU, SSD, Replicas columns empty
