---
name: arch-merge-conflict
description: Merge two workspace.json commits, resolving merge conflicts while preserving element coordinates
allowed-tools: Read, Bash, Write, Edit, AskUserQuestion, TodoWrite
user-invocable: true
---

# Merging workspace.json from Two Commits

## Task

Merge two versions of the `structurizr/workspace.json` file from different commits, resolving merge conflicts to produce a valid JSON while preserving element coordinates.

## Argument

Two commit IDs separated by a space, e.g.: `abc1234 def5678`

The first commit is the **primary** (its structure takes priority), the second is **supplementary** (missing data is taken from it).

If no arguments are provided — ask the user via AskUserQuestion:
1. Primary commit ID in git (its structure takes priority)
2. Supplementary commit ID in git (missing data is taken from it)

## Algorithm

### Step 1. Retrieving File Versions

Extract `structurizr/workspace.json` contents from both commits:

```bash
git show <primary_commit>:structurizr/workspace.json > /tmp/workspace_base.json
git show <supplementary_commit>:structurizr/workspace.json > /tmp/workspace_extra.json
```

### Step 2. Analyzing Differences

1. Read both files
2. Identify differences:
   - New elements (id, x, y coordinates)
   - New relationships
   - New views or changes in existing views
   - Changes in configuration (configuration, styles)
3. Present a brief summary of differences to the user

### Step 3. Merging

Assemble the resulting `workspace.json`, following these rules:

1. **Base** — version from the primary commit
2. **Element coordinates** — preserve ALL coordinates from both commits. If an element exists in both — priority goes to the primary commit. Coordinates are defined in `elements` sections inside views:
   ```json
   "elements": [
     {
       "id": "3",
       "x": 240,
       "y": 142
     }
   ]
   ```
3. **Views** — merge all views from both commits. If a view with the same key exists in both — priority goes to the primary
4. **Relationships** — merge all relationships from both commits, avoiding duplicates (by vertices)
5. **Model** — DO NOT touch, workspace.json contains only layout data (coordinates and views), the model is stored in DSL

### Step 4. Validating the Result

1. Verify the result is valid JSON:
   ```bash
   python3 -c "import json; json.load(open('structurizr/workspace.json'))"
   ```
2. Verify all element coordinates are preserved (no element lost its x/y)
3. Run DSL validation:
   ```bash
   scripts/validate-dsl.sh
   ```

### Step 5. Result

Report to the user:
- How many elements/views were in each commit
- How many elements/views are in the result
- Whether there were conflicts and how they were resolved

### Step 6. Cleanup

Delete temporary files:
```bash
rm -f /tmp/workspace_base.json /tmp/workspace_extra.json
```
