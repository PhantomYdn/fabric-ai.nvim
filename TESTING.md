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

## Milestone 5: URL Processing

### Test 12: URL Detection Under Cursor

**Steps:**
1. Create a buffer with the following content:
   ```
   Check out https://example.com for more info.
   ```
2. Position cursor anywhere on the URL (e.g., on "example")
3. Run `:Fabric url`

**Expected:**
- Pattern picker opens
- After selecting a pattern, processing begins
- Output streams to floating window

**Pass Criteria:** URL correctly detected and processed

---

### Test 13: YouTube URL Detection (youtube.com)

**Steps:**
1. Create a buffer with:
   ```
   Watch this: https://www.youtube.com/watch?v=dQw4w9WgXcQ
   ```
2. Position cursor on the URL
3. Run `:Fabric url`
4. Select a pattern (e.g., `extract_wisdom`)

**Expected:**
- YouTube URL detected
- Fabric uses `-y` flag (transcript extraction)
- Processing completes (may take longer due to transcript fetch)

**Verification:**
- If you have access to Fabric logs or verbose mode, verify `-y` flag was used

**Pass Criteria:** YouTube URL processed with transcript extraction

---

### Test 14: YouTube URL Detection (youtu.be)

**Steps:**
1. Create a buffer with:
   ```
   Short link: https://youtu.be/dQw4w9WgXcQ
   ```
2. Position cursor on the URL
3. Run `:Fabric url`

**Expected:**
- youtu.be URL recognized as YouTube
- Same behavior as Test 13

**Pass Criteria:** Short YouTube URLs handled correctly

---

### Test 15: Generic URL Processing

**Steps:**
1. Create a buffer with:
   ```
   Read more at https://github.com/danielmiessler/fabric
   ```
2. Position cursor on the URL
3. Run `:Fabric url`

**Expected:**
- URL detected as generic (not YouTube)
- Fabric uses `-u` flag (web page content)
- Page content processed through selected pattern

**Pass Criteria:** Generic URLs use `-u` flag

---

### Test 16: No URL Under Cursor

**Steps:**
1. Create a buffer with:
   ```
   This is just plain text without any URLs.
   ```
2. Position cursor on any word
3. Run `:Fabric url`

**Expected:**
- Warning: "No URL found under cursor" (yellow, not red)
- Hint: "Place cursor on a URL, then run :Fabric url"
- No Lua error

**Pass Criteria:** Graceful error handling

---

### Test 17: URL in Parentheses

**Steps:**
1. Create a buffer with:
   ```
   See the docs (https://example.com/docs) for details.
   ```
2. Position cursor on the URL (inside the parentheses)
3. Run `:Fabric url`

**Expected:**
- URL extracted without parentheses
- Processing works normally

**Pass Criteria:** URL extracted from wrapped context

---

### Test 18: URL Replace Action

**Steps:**
1. Create a buffer with:
   ```
   Link: https://example.com/article
   More text here.
   ```
2. Position cursor on the URL
3. Run `:Fabric url`
4. Select a pattern
5. Wait for processing
6. Press `r`

**Expected:**
- The URL text is replaced with Fabric output
- "More text here." line remains unchanged
- Undo with `u` restores the original URL

**Pass Criteria:** Replace action works for URL processing

---

### Test 19: URL Yank Action

**Steps:**
1. Position cursor on any URL
2. Run `:Fabric url`
3. Select pattern, wait for completion
4. Press `y`

**Expected:**
- "Output copied to clipboard" message
- Window closes
- Paste with `"+p` shows Fabric output

**Pass Criteria:** Yank action works for URL processing

---

### Test 20: URL New Buffer Action

**Steps:**
1. Position cursor on any URL
2. Run `:Fabric url`
3. Select pattern, wait for completion
4. Press `n`

**Expected:**
- Floating window closes
- New buffer opens with output
- Original buffer unchanged

**Pass Criteria:** New buffer action works for URL processing

---

### Test 21: Cancel URL Processing

**Steps:**
1. Position cursor on a YouTube URL (these take longer)
2. Run `:Fabric url`
3. Select a pattern
4. Immediately press `q` (or `<Esc>` or `<C-c>`)

**Expected:**
- "[Cancelled]" message appears briefly
- Window closes
- Processing stops

**Pass Criteria:** Cancel works during URL processing

---

### Test 22: URL with www. Prefix (No Protocol)

**Steps:**
1. Create a buffer with:
   ```
   Visit www.example.com for more.
   ```
2. Position cursor on `www.example.com`
3. Run `:Fabric url`

**Expected:**
- URL detected and `https://` prepended automatically
- Processing works normally

**Pass Criteria:** www. URLs handled without explicit protocol

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
