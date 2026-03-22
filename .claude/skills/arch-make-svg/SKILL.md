---
name: arch-make-svg
description: Export all Structurizr views to SVG files
allowed-tools: Read, Edit, Bash, AskUserQuestion, TodoWrite
user-invocable: true
---

# Diagram Export to SVG

## Task

Export all Structurizr views to SVG files in the `structurizr/export/` folder.

## Algorithm

### Step 1. Clarification — NotInProd style

**Mandatory** ask the user via AskUserQuestion. Do not use answers from memory or previous sessions — always ask explicitly:
- **Question:** "Should elements not deployed to production be highlighted (dashed border, semi-transparent)?"
- **Options:** "Yes, highlight" / "No, hide highlighting"

### Step 2. Preparation (if user chose "No, hide highlighting")

Comment out the contents of the `NotInProd` style in `structurizr/workspace.dsl` so that elements not deployed to production are not highlighted on diagrams:

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

### Step 3. Export

Run the diagram export:
```bash
scripts/export-svg.sh
```

### Step 4. Restoration (if the NotInProd style was commented out in step 2)

Uncomment the `NotInProd` style contents back to the original state (remove `// ` before each line inside the block).

### Step 5. Result

Inform the user that SVG files are saved in `structurizr/export/`, and list the exported files.
