# fabric-ai.nvim

A Neovim plugin that integrates [Fabric AI](https://github.com/danielmiessler/fabric)'s 220+ text processing patterns directly into your editor.

> **Version 1.0.0** - MVP Complete

## Features

- **Visual Selection Processing** - Select text and apply any Fabric pattern
- **URL Processing** - Process YouTube transcripts and web page content
- **Pattern Picker** - Fuzzy search with Telescope (or vim.ui.select fallback)
- **Pattern Preview** - See pattern descriptions before applying
- **Streaming Output** - Real-time display as Fabric processes
- **Floating Window** - Clean, centered output display
- **Output Actions** - Replace, yank, or open in new buffer
- **Cancel Support** - Cancel long-running operations anytime

## Requirements

- Neovim 0.10.0+
- [Fabric AI CLI](https://github.com/danielmiessler/fabric) (`fabric-ai`)
- Optional: [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) for enhanced picker with preview

## Installation

### rocks.nvim

```vim
:Rocks install fabric-ai.nvim
```

### lazy.nvim

```lua
{
  "PhantomYdn/fabric-ai.nvim",
  cmd = { "Fabric" },
  dependencies = {
    { "nvim-telescope/telescope.nvim", optional = true },
  },
  opts = {
    -- Default configuration (all optional)
    fabric_path = "fabric-ai",     -- Path to Fabric CLI
    patterns_path = nil,           -- Custom patterns dir (auto-detect if nil)
    timeout = 120000,              -- Command timeout in ms (2 minutes)
    window = {
      width = 0.8,                 -- 80% of editor width
      height = 0.8,                -- 80% of editor height
      border = "rounded",
    },
  },
  keys = {
    { "<leader>fa", ":'<,'>Fabric<CR>", mode = "v", desc = "Fabric AI" },
    { "<leader>fu", ":Fabric url<CR>", mode = "n", desc = "Fabric URL" },
  },
}
```

### Alternative: Load on VeryLazy

```lua
{
  "PhantomYdn/fabric-ai.nvim",
  event = "VeryLazy",
  dependencies = {
    { "nvim-telescope/telescope.nvim", optional = true },
  },
  opts = {},
}
```

### Note on Lazy-Loading

When using `cmd = { "Fabric" }`, the plugin loads on first command invocation. Run `:Fabric health` to trigger loading and verify your setup. If you prefer the plugin to load at startup (for immediate CLI validation), use `event = "VeryLazy"` instead.

## Usage

### Text Processing

1. Select text in visual mode (`v`, `V`, or `<C-v>`)
2. Run `:Fabric`
3. Pick a pattern from the fuzzy finder
4. View streaming output in floating window
5. Choose an action:

| Key | Action | Description |
|-----|--------|-------------|
| `r` | Replace | Replace original selection with output |
| `y` | Yank | Copy output to system clipboard |
| `n` | New Buffer | Open output in new markdown buffer |
| `q` | Quit | Close window, discard output |
| `<Esc>` | Quit | Same as `q` |
| `<C-c>` | Quit | Same as `q` |

### URL Processing

Process web pages and YouTube videos without copying content manually:

1. Place cursor on a URL in your buffer
2. Run `:Fabric url`
3. Pick a pattern
4. View output and choose an action

**YouTube URLs** (youtube.com, youtu.be) automatically extract transcripts using Fabric's `-y` flag.

**Other URLs** fetch and process web page content using Fabric's `-u` flag.

### During Processing

While Fabric is processing, you can cancel at any time by pressing `q`, `<Esc>`, or `<C-c>`.

### Commands

| Command | Description |
|---------|-------------|
| `:Fabric` | Process visual selection with pattern picker |
| `:Fabric run` | Same as `:Fabric` |
| `:Fabric url` | Process URL under cursor |
| `:Fabric health` | Run health check (`:checkhealth fabric-ai`) |

## Use Case Examples

### Summarize Long Text

```
1. Select a long article or documentation
2. :Fabric
3. Select "summarize" pattern
4. Press `r` to replace with summary, or `y` to copy
```

### Extract Wisdom from YouTube Video

```
1. Paste a YouTube URL in your buffer
2. Place cursor on the URL
3. :Fabric url
4. Select "extract_wisdom" pattern
5. Press `n` to open insights in new buffer
```

### Clean Text for Obsidian Notes

```
1. Select messy text (web copy, email, etc.)
2. :Fabric
3. Select "clean_text" or "improve_writing" pattern
4. Press `r` to replace with clean version
```

### Explain Code

```
1. Select a function or code block
2. :Fabric
3. Select "explain_code" pattern
4. Press `n` to open explanation in new buffer
```

### Improve Writing

```
1. Select your draft text
2. :Fabric
3. Select "improve_writing" pattern
4. Press `r` to replace, or `y` to compare
```

### Analyze Web Article

```
1. Paste article URL in buffer
2. Place cursor on URL
3. :Fabric url
4. Select "analyze_paper" or "extract_main_idea"
5. Press `n` to review analysis
```

## Configuration

### Default Configuration

```lua
require("fabric-ai").setup({
  -- Path to Fabric CLI executable
  fabric_path = "fabric-ai",
  
  -- Custom patterns directory (nil = auto-detect ~/.config/fabric/patterns)
  patterns_path = nil,
  
  -- Command timeout in milliseconds
  timeout = 120000,
  
  -- Floating window settings
  window = {
    width = 0.8,    -- Fraction of editor width (0.0-1.0)
    height = 0.8,   -- Fraction of editor height (0.0-1.0)
    border = "rounded",  -- Border style
  },
  
  -- Default output action (reserved for future use)
  default_action = "window",
})
```

### Border Styles

Valid border styles: `"none"`, `"single"`, `"double"`, `"rounded"`, `"solid"`, `"shadow"`

### Configuration Validation

The plugin validates your configuration on setup. Invalid values trigger a warning via `vim.notify()` and fall back to sensible defaults. For example:

- `timeout = -100` warns and uses `120000`
- `window.width = 2.0` warns and uses `0.8`

### Fabric CLI Check

On setup, the plugin checks if the Fabric CLI is available. If not found, a warning is displayed. This helps catch configuration issues early.

## How It Works

1. **Selection Capture** - Captures your visual selection and stores the range
2. **Pattern Discovery** - Runs `fabric-ai -l` to list available patterns
3. **Pattern Picker** - Shows Telescope picker (or vim.ui.select) with pattern preview
4. **Streaming Execution** - Runs `fabric-ai -s -p <pattern>` with your text as stdin
5. **Real-time Display** - Shows output in floating window as it streams
6. **Output Actions** - Apply chosen action (replace, yank, new buffer, or discard)

For URL processing, the flow is similar but uses `-y` (YouTube) or `-u` (web) flags instead of stdin.

## Health Check

Verify your setup with:

```vim
:checkhealth fabric-ai
```

Or:

```vim
:Fabric health
```

This checks:
- Neovim version (0.10.0+ required)
- Fabric CLI availability and version
- Patterns directory existence

## Known Limitations

- **Block-wise visual mode** (`<C-v>`) is not fully supported for the replace action. Character-wise (`v`) and line-wise (`V`) modes work correctly.
- **Telescope recommended** - Without Telescope, the fallback picker (vim.ui.select) lacks pattern preview.

## Troubleshooting

### "Fabric CLI not found"

Ensure `fabric-ai` is in your PATH, or configure the full path:

```lua
opts = {
  fabric_path = "/path/to/fabric-ai",
}
```

### "No patterns found"

Run `fabric-ai -U` to download/update patterns, then verify:

```bash
fabric-ai -l
```

### Plugin not loading

If using `cmd = { "Fabric" }`, the plugin loads lazily. Run `:Fabric health` to trigger load and check status.

### Processing times out

Increase the timeout for long content or slow connections:

```lua
opts = {
  timeout = 300000,  -- 5 minutes
}
```

## Documentation

Full documentation available via:

```vim
:help fabric-ai
```

## Contributing

See [AGENTS.md](AGENTS.md) for development guidelines.

## License

MIT License - see [LICENSE](LICENSE)

## Credits

- [Fabric AI](https://github.com/danielmiessler/fabric) by Daniel Miessler
- Inspired by the Neovim plugin ecosystem
