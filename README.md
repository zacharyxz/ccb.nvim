# ccb.nvim

Claude Code integration for Neovim. Opens [Claude Code](https://github.com/claude-code-best/claude-code) (`ccb`) in a [Snacks.nvim](https://github.com/folke/snacks.nvim) terminal window, with shortcuts for injecting file path + line number references directly into the ccb prompt.

This plugin is modeled after [codewhale.nvim](https://github.com/zacharyxz/codewhale.nvim).

## Features

- **Terminal toggle** — open/hide the ccb TUI in a right-side split
- **Smart focus** — jump to terminal if unfocused, hide if already focused
- **File references** — send file path + line number to the ccb prompt with a single keystroke
  - Normal mode: `<leader>ca` sends `current/file:L42:C3` (cursor position)
  - Visual mode: `<leader>cA` sends `current/file:L10:C2-L25` (selection range)
  - Count prefix: `32<leader>cl` sends `current/file:L32` (line 32)

## Requirements

- Neovim >= 0.10
- [Snacks.nvim](https://github.com/folke/snacks.nvim)
- [Claude Code](https://github.com/claude-code-best/claude-code) (`ccb` on `$PATH`)

## Installation

### lazy.nvim

```lua
{
  "zacharyxz/ccb.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  keys = {
    { "<leader>cb", "<cmd>CCB<cr>",       desc = "Toggle ccb" },
    { "<leader>cB", "<cmd>CCBFocus<cr>",   desc = "Focus ccb" },
    { "<leader>ca", desc = "Add file:line ref to ccb" },
    { "<leader>cA", desc = "Add selection ref to ccb", mode = "v" },
    { "<leader>cl", desc = "Add file:line ref (with count)" },
  },
}
```

### With custom options

```lua
{
  "zacharyxz/ccb.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    terminal = {
      split_side = "left",
      split_width = 0.25,
      snacks_win_opts = {
        wo = { winblend = 100 },
      },
    },
    keymaps = {
      toggle        = "<leader>cb",
      add_file      = "<leader>ca",
      add_selection = "<leader>cA",
      -- Disable a keymap
      focus = false,
    },
  },
}
```

## Configuration

`opts` is passed to `require("ccb").setup(opts)`.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `terminal.split_side` | `"left"` \| `"right"` | `"right"` | Which side the split opens on |
| `terminal.split_width` | `number` | `0.30` | Width ratio (0-1) |
| `terminal.auto_close` | `boolean` | `true` | Auto-close terminal buffer on exit |
| `terminal.snacks_win_opts` | `table` | `{}` | Merged into Snacks terminal `win` config |
| `terminal.cwd` | `string?` | `nil` | Working directory (default: current dir) |
| `terminal_cmd` | `string?` | `nil` | Override the binary (default: `ccb`) |
| `env` | `table<string,string>?` | `nil` | Extra environment variables |
| `keymaps` | `table` | see below | Keymap overrides (set to `false` to disable) |

### Default keymaps

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>cb` | `:CCB` | Toggle ccb terminal |
| `<leader>cB` | `:CCBFocus` | Smart focus/toggle |
| `<leader>ca` | `:CCBAddRef` | **Add file:line reference** (cursor position in normal mode) |
| `<leader>cA` | `:CCBAddRef` | **Add file:line reference** (selection range in visual mode) |
| `<leader>cl` | — | **Add file:line reference** with count as line number (e.g. `42<leader>cl` for line 42) |

## Commands

| Command | Description |
|---------|-------------|
| `:CCB` | Toggle terminal (show/hide) |
| `:CCBFocus` | Smart focus — jump to terminal, or hide if already focused |
| `:CCBOpen` | Open terminal without toggle logic |
| `:CCBClose` | Close the terminal |
| `:CCBAddRef` | Add current file:line reference to the ccb prompt |

## Terminal Key Bindings

Active inside the ccb terminal window:

| Key | Action |
|-----|--------|
| `<S-CR>` | New line (Shift+Enter) |

## File Reference Format

References are compact, relative-path strings sent directly to the ccb terminal:

```
lua/ccb/init.lua:L42          -- cursor at line 42
lua/ccb/init.lua:L21:C5-L35   -- selection from line 21 col 5 to line 35
lua/ccb/init.lua:L10:C1-L10   -- single-line selection at line 10
```

## License

MIT
