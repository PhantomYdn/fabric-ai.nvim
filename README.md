# fabric-ai.nvim

A Neovim plugin that integrates [Fabric AI](https://github.com/danielmiessler/fabric)'s 220+ text processing patterns directly into your editor.

> **Status:** In Development (MVP)

## Features

- **Visual Selection Processing** - Select text and apply any Fabric pattern
- **Pattern Picker** - Fuzzy search with Telescope (or vim.ui.select fallback)
- **Pattern Preview** - See pattern descriptions before applying
- **Streaming Output** - Real-time display as Fabric processes
- **Floating Window** - Clean, centered output display
- **Output Actions** - Replace, yank, or open in new buffer
- **Cancel Support** - Cancel long-running operations anytime

## Requirements

- Neovim 0.10.0+
- [Fabric AI CLI](https://github.com/danielmiessler/fabric) (`fabric-ai`)
- Optional: [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) for enhanced picker

## Installation

### lazy.nvim

```lua
{
  "yourusername/fabric-ai.nvim",
  cmd = { "Fabric" },
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
  },
}
```

### Alternative: Load on VeryLazy

```lua
{
  "yourusername/fabric-ai.nvim",
  event = "VeryLazy",
  opts = {},
}
```

## Usage

### Basic Workflow

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

### During Processing

While Fabric is processing, you can cancel at any time:

- Press `q`, `<Esc>`, or `<C-c>` to cancel and close

### Commands

| Command | Description |
|---------|-------------|
| `:Fabric` | Process visual selection with pattern picker |
| `:Fabric run` | Same as `:Fabric` |
| `:Fabric health` | Run health check (`:checkhealth fabric-ai`) |

### Health Check

Verify your setup:

```vim
:checkhealth fabric-ai
```

Or:

```vim
:Fabric health
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
  
  -- Default output action (not yet implemented)
  default_action = "window",
})
```

### Border Styles

Valid border styles: `"none"`, `"single"`, `"double"`, `"rounded"`, `"solid"`, `"shadow"`

## How It Works

1. **Selection Capture** - Captures your visual selection and stores the range
2. **Pattern Discovery** - Runs `fabric-ai -l` to list available patterns
3. **Pattern Picker** - Shows Telescope picker (or vim.ui.select) with pattern preview
4. **Streaming Execution** - Runs `fabric-ai -s -p <pattern>` with your text as stdin
5. **Real-time Display** - Shows output in floating window as it streams
6. **Output Actions** - Apply chosen action (replace, yank, new buffer, or discard)

## Known Limitations

- **Block-wise visual mode** (`<C-v>`) is not fully supported for the replace action. Character-wise (`v`) and line-wise (`V`) modes work correctly.

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

## Contributing

See [AGENTS.md](AGENTS.md) for development guidelines.

## License

MIT License - see [LICENSE](LICENSE)

## Credits

- [Fabric AI](https://github.com/danielmiessler/fabric) by Daniel Miessler
- Inspired by the Neovim plugin ecosystem
