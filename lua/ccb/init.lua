---ccb.nvim - Claude Code (ccb) integration for Neovim.
---
---@module 'ccb'

local M = {}

---@class ccb.Config
---@field terminal ccb.TerminalConfig?
---@field terminal_cmd string?           Override the ccb binary path.
---@field env table<string,string>?      Extra env vars for the terminal.
---@field keymaps table<string,string|false>? Keymap overrides (set to false to disable).

---@type ccb.Config
local defaults = {
  terminal = nil,
  terminal_cmd = nil,
  env = nil,
  keymaps = {
    toggle        = "<leader>cc",
    focus         = "<leader>cC",
    add_file      = "<leader>ca",
    add_selection = "<leader>cA",
    add_file_line = "<leader>cl",
  },
}

---Setup ccb.nvim.
---@param opts ccb.Config?
function M.setup(opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})

  -- Configure terminal
  local term_ok, terminal = pcall(require, "ccb.terminal")
  if term_ok and type(terminal.setup) == "function" then
    terminal.setup(opts.terminal, opts.terminal_cmd, opts.env)
  end

  M._create_commands()
  M._create_keymaps(opts.keymaps or {})
end

---Register user commands.
function M._create_commands()
  local term_ok, terminal = pcall(require, "ccb.terminal")
  if not term_ok then
    return
  end

  vim.api.nvim_create_user_command("CCB", function(opts)
    local args = opts.args and opts.args ~= "" and opts.args or nil
    terminal.toggle({}, args)
  end, {
    nargs = "*",
    desc = "Toggle the ccb terminal window",
  })

  vim.api.nvim_create_user_command("CCBFocus", function(opts)
    local args = opts.args and opts.args ~= "" and opts.args or nil
    terminal.focus_toggle({}, args)
  end, {
    nargs = "*",
    desc = "Smart focus/toggle ccb terminal",
  })

  vim.api.nvim_create_user_command("CCBOpen", function(opts)
    local args = opts.args and opts.args ~= "" and opts.args or nil
    terminal.open({}, args)
  end, {
    nargs = "*",
    desc = "Open ccb terminal",
  })

  vim.api.nvim_create_user_command("CCBClose", function()
    terminal.close()
  end, {
    desc = "Close ccb terminal",
  })

  ---Add the current file:line reference to the ccb prompt.
  vim.api.nvim_create_user_command("CCBAddRef", function()
    local context = require("ccb.context")
    local ref = context.get_ref()
    if ref then
      require("ccb.terminal").send_text(ref)
    else
      vim.notify("ccb.nvim: No file to reference.", vim.log.levels.WARN)
    end
  end, {
    desc = "Add current file:line reference to ccb",
    range = true,
  })
end

---Register default keymaps.
---@param keymaps table<string, string|false>
function M._create_keymaps(keymaps)
  local maps = {}

  -- Toggle
  if keymaps.toggle ~= false then
    maps[keymaps.toggle] = {
      action = "<cmd>CCB<cr>",
      desc = "Toggle ccb",
    }
  end

  -- Focus
  if keymaps.focus ~= false then
    maps[keymaps.focus] = {
      action = "<cmd>CCBFocus<cr>",
      desc = "Focus ccb",
    }
  end

  -- Add file reference (normal mode: cursor line)
  if keymaps.add_file ~= false then
    maps[keymaps.add_file] = {
      action = function()
        require("ccb.terminal").send_text(
          require("ccb.context").get_ref()
        )
      end,
      desc = "Add file:line ref to ccb",
    }
  end

  -- Add selection reference (visual mode)
  if keymaps.add_selection ~= false then
    maps[keymaps.add_selection] = {
      action = "<cmd>CCBAddRef<cr>",
      desc = "Add selection ref to ccb",
      mode = "v",
    }
  end

  -- Add file with count as line number
  if keymaps.add_file_line ~= false then
    maps[keymaps.add_file_line] = {
      action = function()
        local count = vim.v.count
        local ref
        if count > 0 then
          ref = require("ccb.context").get_ref_at(count)
        else
          ref = require("ccb.context").get_ref()
        end
        if ref then
          require("ccb.terminal").send_text(ref)
        end
      end,
      desc = "Add file:line ref (with count)",
    }
  end

  -- Register all keymaps
  for lhs, map in pairs(maps) do
    local opts = { noremap = true, silent = true, desc = map.desc }
    if map.mode then
      vim.keymap.set(map.mode, lhs, map.action, opts)
    else
      vim.keymap.set("n", lhs, map.action, opts)
    end
  end
end

return M
