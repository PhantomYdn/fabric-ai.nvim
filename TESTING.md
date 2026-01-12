# Testing Guide: fabric-ai.nvim

This document provides manual testing procedures for fabric-ai.nvim.
Use this to verify functionality during development and before releases.

---

## Prerequisites

1. Neovim 0.10.0+ installed
2. Fabric AI CLI installed and working (`fabric-ai -l` lists patterns)
3. Plugin loaded in Neovim
4. A test file with text content

## Test File Setup

Create a simple test file or use any existing file:

```
Line 1: Hello World
Line 2: This is a test
Line 3: Some more text here
Line 4: Final line
```

---

## Milestone 4: Output Actions

### Test 1: Basic Replace Action (Line-wise)

**Steps:**
1. Open the test file
2. Position cursor on line 2
3. Press `V` (line-wise visual) to select the entire line
4. Type `:Fabric` and press Enter
5. Select a simple pattern (e.g., `summarize`)
6. Wait for processing to complete
7. Verify footer shows `[r]eplace [y]ank [n]ew buffer [q]uit`
8. Press `r`

**Expected:**
- Line 2 is replaced with Fabric output
- Window closes
- Undo with `u` restores original text

**Pass Criteria:** Original line replaced, undo works

---

### Test 2: Basic Replace Action (Character-wise)

**Steps:**
1. Open the test file
2. Position cursor at start of "Hello" on line 1
3. Press `v` then move to select just "Hello World"
4. Type `:Fabric` and press Enter
5. Select a pattern
6. Wait for processing
7. Press `r`

**Expected:**
- Only "Hello World" is replaced
- Rest of line preserved ("Line 1: " prefix remains)

**Pass Criteria:** Partial line replacement works correctly

---

### Test 3: Multi-line Character-wise Replace

**Steps:**
1. Select from middle of line 1 to middle of line 3 using `v`
2. Run `:Fabric`, select pattern
3. Press `r` after completion

**Expected:**
- Selected portion replaced
- Lines before/after selection preserved

**Pass Criteria:** Multi-line partial replacement works

---

### Test 4: Yank Action

**Steps:**
1. Select some text, run `:Fabric`
2. Wait for processing
3. Press `y`

**Expected:**
- Message: "Output copied to clipboard"
- Window closes

**Verification:**
- Open new buffer, paste with `"+p`
- Should contain Fabric output

**Pass Criteria:** Content in system clipboard

---

### Test 5: New Buffer Action

**Steps:**
1. Select some text, run `:Fabric`
2. Wait for processing
3. Press `n`

**Expected:**
- Floating window closes
- New buffer opens with Fabric output
- Buffer filetype is "markdown" (verify with `:set ft?`)
- Buffer is listed (`:ls` shows it)

**Pass Criteria:** New buffer created with correct content and settings

---

### Test 6: Quit Action

**Steps:**
1. Select some text, run `:Fabric`
2. Wait for processing
3. Press `q` (or `<Esc>`)

**Expected:**
- Window closes
- Original selection unchanged

**Pass Criteria:** Clean window closure, no side effects

---

### Test 7: Cancel During Processing

**Steps:**
1. Select some text, run `:Fabric`
2. Select a pattern
3. While processing (before completion), press `q`

**Expected:**
- "[Cancelled]" message appears briefly
- Window closes
- Processing stops

**Variations:**
- Test with `<Esc>` - same behavior
- Test with `<C-c>` - same behavior

**Pass Criteria:** Cancel works during processing

---

### Test 8: Block-wise Selection (Known Limitation)

**Steps:**
1. Position cursor, press `<C-v>` for block mode
2. Select a rectangular region across multiple lines
3. Run `:Fabric`
4. Press `r`

**Expected:**
- May not work correctly (known limitation)
- Document observed behavior

**Purpose:** Verify known limitation, not a pass/fail test

---

### Test 9: Empty Selection Handling

**Steps:**
1. Without selecting any text, run `:Fabric`

**Expected:**
- Warning message: "No visual selection found" (yellow, not red)
- Hint: "Select text in visual mode, then run :Fabric"
- No Lua error thrown

**Pass Criteria:** Graceful error handling, no stack trace

---

### Test 10: Source Buffer Deleted During Processing

**Steps:**
1. Select text, run `:Fabric`
2. While processing, close the source buffer (`:bd!`)
3. Wait for processing to complete
4. Try to press `r`

**Expected:**
- Error message: "Source buffer no longer exists"
- No Lua error/stack trace

**Pass Criteria:** Edge case handled gracefully

---

### Test 11: Window Footer Visibility

**Steps:**
1. Run any `:Fabric` command

**Verify:**
- Window border shows title: " Fabric AI: {pattern_name} "
- Window border shows footer: " [r]eplace [y]ank [n]ew buffer [q]uit "

**Pass Criteria:** Both title and footer visible

---

## Quick Regression Test

For rapid verification after changes, run these in order:

1. `V` line 2 -> `:Fabric` -> select pattern -> `y` -> verify clipboard
2. `V` line 3 -> `:Fabric` -> select pattern -> `n` -> verify new buffer
3. `V` line 4 -> `:Fabric` -> select pattern -> `r` -> verify replacement
4. `v` select partial -> `:Fabric` -> `q` -> verify window closes
5. No selection -> `:Fabric` -> verify warning (no error)

---

## Test Results Template

Use this template to record test results:

```
Date: YYYY-MM-DD
Tester: [name]
Neovim Version: [nvim --version]
Fabric Version: [fabric-ai --version]

| Test | Result | Notes |
|------|--------|-------|
| Test 1 | PASS/FAIL | |
| Test 2 | PASS/FAIL | |
| Test 3 | PASS/FAIL | |
| Test 4 | PASS/FAIL | |
| Test 5 | PASS/FAIL | |
| Test 6 | PASS/FAIL | |
| Test 7 | PASS/FAIL | |
| Test 8 | N/A | Known limitation |
| Test 9 | PASS/FAIL | |
| Test 10 | PASS/FAIL | |
| Test 11 | PASS/FAIL | |
```

---

## Adding New Tests

When implementing new features:

1. Write test cases BEFORE or DURING implementation
2. Add tests to appropriate milestone section
3. Include: Steps, Expected results, Pass criteria
4. Update Quick Regression Test if needed

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-12 | Initial testing guide for Milestone 4 |
