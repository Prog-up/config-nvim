-- =============================================================================
-- Lite Neovim Configuration (YAGNI & Built-in Focused)
-- =============================================================================
-- This configuration prioritizes Neovim's built-in features, keeping it extremely
-- fast, lightweight, and free of unnecessary dependencies.
--
-- File types supported out-of-the-box: Markdown, LaTeX, Python, Rust, Ansible/YAML.
-- Theme: VS Code (loaded via vim.pack to match the lazyvim branch layout)
-- =============================================================================

--------------------------------------------------------------------------------
-- 1. General Options
--------------------------------------------------------------------------------
local opt = vim.opt

-- Appearance & UI
opt.termguicolors = true      -- Enable 24-bit RGB colors
opt.number = true             -- Show line numbers
opt.relativenumber = true     -- Show relative line numbers for easier jumping
opt.cursorline = true         -- Highlight the line under the cursor
opt.signcolumn = "yes"        -- Always show the sign column to prevent layout shifts
opt.scrolloff = 8             -- Keep at least 8 lines above/below cursor
opt.mouse = "a"               -- Enable mouse support in all modes
opt.showmode = false          -- Hide default mode text (already shown in custom statusline)

-- Clipboard Integration
opt.clipboard = "unnamedplus" -- Sync with system clipboard (requires xclip/xsel or pbcopy)

-- Search Options
opt.ignorecase = true         -- Ignore case in search patterns
opt.smartcase = true          -- Case-sensitive if pattern contains uppercase letters
opt.hlsearch = true           -- Highlight search results
opt.incsearch = true          -- Show search matches as you type

-- Tabs & Indentation (Default settings)
opt.tabstop = 4               -- Number of spaces a tab counts for
opt.shiftwidth = 4            -- Number of spaces for auto-indent
opt.expandtab = true          -- Convert tabs to spaces
opt.smartindent = true        -- Smart auto-indenting for programming languages

-- Window Splitting Layouts
opt.splitright = true         -- Focus moves right when splitting vertically
opt.splitbelow = true         -- Focus moves down when splitting horizontally

-- Performance & Backups
opt.updatetime = 250          -- Fast completion and trigger timeout (in ms)
opt.swapfile = false          -- Disable swap files
opt.backup = false            -- Disable backups
opt.writebackup = false       -- Disable write backups

--------------------------------------------------------------------------------
-- 2. Theme & Colors (VS Code)
--------------------------------------------------------------------------------
-- Load the vscode.nvim theme plugin from vim.pack
vim.cmd("packadd! vscode.nvim")

-- Configure the vscode theme
require("vscode").setup({
  transparent = true,
  italic_comments = true,
  underline_links = true,
  disable_nvimtree_bg = true,
})

-- Load the colorscheme
vim.cmd("colorscheme vscode")

--------------------------------------------------------------------------------
-- 3. File Explorer (Netrw) - Left Sidebar Panel
--------------------------------------------------------------------------------
-- Configure built-in Netrw to behave like a modern sidebar
vim.g.netrw_banner = 0         -- Hide the help banner at the top of netrw
vim.g.netrw_liststyle = 3      -- Tree-style listing (expand/collapse dirs)
vim.g.netrw_winsize = 20       -- Sidebar width (20% of the screen)
vim.g.netrw_browse_split = 4   -- Open selected files in the previous/last window
vim.g.netrw_altv = 1           -- Open split windows to the right
vim.g.netrw_keepdir = 0        -- Keep current working directory synced
vim.g.netrw_fastbrowse = 2     -- Keep directory listings up-to-date and clean

-- Clean up Netrw buffers when closed to prevent polluting the buffer list
vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    vim.opt_local.bufhidden = "wipe" -- Wipe buffer when it becomes hidden
  end
})

-- How to use Netrw (Cheat Sheet):
--   - <CR> : Open file or toggle/expand folder
--   - %    : Create a new file (prompts for name)
--   - d    : Create a new directory (prompts for name)
--   - R    : Rename file or directory under the cursor
--   - D    : Delete file or directory (prompts for confirmation)

-- Robust toggle function for the sidebar
local function toggle_sidebar()
  -- Look for an open Netrw window
  local netrw_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == 'netrw' then
      netrw_win = win
      break
    end
  end

  if netrw_win then
    -- Close Netrw if it is already open
    vim.api.nvim_win_close(netrw_win, true)
  else
    -- Open Netrw using built-in Lexplore
    vim.cmd('Lexplore')
  end
end

-- Keymap to toggle sidebar (Ctrl + e)
vim.keymap.set('n', '<C-e>', toggle_sidebar, { silent = true, desc = 'Toggle Left Sidebar Explorer' })

--------------------------------------------------------------------------------
-- 4. Buffer / Tab Navigation (Ctrl-h and Ctrl-l)
--------------------------------------------------------------------------------
-- Helper to list valid file buffers (excluding netrw and special panels)
local function get_valid_buffers()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  local valid = {}
  for _, buf in ipairs(bufs) do
    local bufnr = buf.bufnr
    local ft = vim.bo[bufnr].filetype
    local bt = vim.bo[bufnr].buftype
    if ft ~= 'netrw' and bt == '' then
      table.insert(valid, bufnr)
    end
  end
  return valid
end

-- Helper to switch focus to the sidebar window
local function go_to_sidebar()
  local netrw_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == 'netrw' then
      netrw_win = win
      break
    end
  end

  if netrw_win then
    vim.api.nvim_set_current_win(netrw_win)
  else
    -- If sidebar is closed, open and focus it
    vim.cmd('Lexplore')
  end
end

-- Helper to switch focus to the editor window
local function go_to_editor(buffer_to_focus)
  local editor_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype ~= 'netrw' then
      editor_win = win
      break
    end
  end

  if editor_win then
    vim.api.nvim_set_current_win(editor_win)
    if buffer_to_focus then
      vim.api.nvim_set_current_buf(buffer_to_focus)
    end
  end
end

-- Handle Ctrl-h: move left to previous tab, or jump to sidebar if on the first tab
local function handle_ctrl_h()
  if vim.bo.filetype == 'netrw' then
    return -- Do nothing if we are already in the sidebar
  end

  local valid_bufs = get_valid_buffers()
  if #valid_bufs == 0 then
    go_to_sidebar()
    return
  end

  local cur_buf = vim.api.nvim_get_current_buf()

  -- If we are in the first tab, pressing Ctrl-h moves focus to the sidebar
  if cur_buf == valid_bufs[1] then
    go_to_sidebar()
    return
  end

  -- Otherwise, navigate to the previous buffer in the list
  local target_idx = nil
  for i, bufnr in ipairs(valid_bufs) do
    if bufnr == cur_buf then
      target_idx = i
      break
    end
  end

  if target_idx then
    local prev_idx = target_idx - 1
    if prev_idx < 1 then
      prev_idx = #valid_bufs
    end
    vim.api.nvim_set_current_buf(valid_bufs[prev_idx])
  else
    vim.api.nvim_set_current_buf(valid_bufs[1])
  end
end

-- Handle Ctrl-l: move right to next tab, or jump to the first tab if in the sidebar
local function handle_ctrl_l()
  if vim.bo.filetype == 'netrw' then
    local valid_bufs = get_valid_buffers()
    if #valid_bufs > 0 then
      go_to_editor(valid_bufs[1])
    else
      go_to_editor()
    end
    return
  end

  local valid_bufs = get_valid_buffers()
  if #valid_bufs <= 1 then
    return
  end

  local cur_buf = vim.api.nvim_get_current_buf()
  local target_idx = nil
  for i, bufnr in ipairs(valid_bufs) do
    if bufnr == cur_buf then
      target_idx = i
      break
    end
  end

  if target_idx then
    local next_idx = target_idx + 1
    if next_idx > #valid_bufs then
      next_idx = 1
    end
    vim.api.nvim_set_current_buf(valid_bufs[next_idx])
  else
    vim.api.nvim_set_current_buf(valid_bufs[1])
  end
end

-- Map Ctrl-h and Ctrl-l
vim.keymap.set('n', '<C-h>', handle_ctrl_h, { silent = true, desc = 'Previous buffer or go to sidebar' })
vim.keymap.set('n', '<C-l>', handle_ctrl_l, { silent = true, desc = 'Next buffer or go to first tab' })

--------------------------------------------------------------------------------
-- 5. Tabline (Displaying all open tabs/buffers at the top)
--------------------------------------------------------------------------------
opt.showtabline = 2 -- Always show the tabline at the top

-- Custom tabline rendering function in pure Lua (zero dependencies)
function _G.custom_tabline()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  local valid_bufs = {}
  for _, buf in ipairs(bufs) do
    local bufnr = buf.bufnr
    local ft = vim.bo[bufnr].filetype
    local bt = vim.bo[bufnr].buftype
    if ft ~= 'netrw' and bt == '' then
      table.insert(valid_bufs, buf)
    end
  end

  local s = ''
  local cur_buf = vim.api.nvim_get_current_buf()

  for i, buf in ipairs(valid_bufs) do
    local bufnr = buf.bufnr
    local name = vim.fn.bufname(bufnr)
    if name == '' then
      name = '[No Name]'
    else
      name = vim.fn.fnamemodify(name, ':t') -- extract filename only
    end

    if buf.changed == 1 then
      name = name .. ' ●'
    end

    -- Format active vs inactive tabs using built-in TabLine colors
    if bufnr == cur_buf then
      s = s .. '%#TabLineSel# ' .. i .. ':' .. name .. ' '
    else
      s = s .. '%#TabLine# ' .. i .. ':' .. name .. ' '
    end
  end

  s = s .. '%#TabLineFill#%='
  return s
end

opt.tabline = '%!v:lua.custom_tabline()'

--------------------------------------------------------------------------------
-- 6. Custom Bubble Statusline (Matches lazyvim branch design but 100% native)
--------------------------------------------------------------------------------
-- Setup highlight colors matching VS Code colors with rounded cap support
vim.cmd([[
  highlight StatusLineCustom ctermbg=8 ctermfg=7 guibg=#2d2d2d guifg=#d4d4d4
  
  " Mode status styling (Normal: Green-blue)
  highlight StatusNormalText guibg=#4ec9b0 guifg=#1e1e1e gui=bold
  highlight StatusNormalCap guifg=#4ec9b0 guibg=#2d2d2d
  
  " Mode status styling (Insert: Light blue)
  highlight StatusInsertText guibg=#569cd6 guifg=#1e1e1e gui=bold
  highlight StatusInsertCap guifg=#569cd6 guibg=#2d2d2d
  
  " Mode status styling (Visual: Magenta)
  highlight StatusVisualText guibg=#c586c0 guifg=#1e1e1e gui=bold
  highlight StatusVisualCap guifg=#c586c0 guibg=#2d2d2d
  
  " Mode status styling (Replace: Red)
  highlight StatusReplaceText guibg=#d16969 guifg=#1e1e1e gui=bold
  highlight StatusReplaceCap guifg=#d16969 guibg=#2d2d2d
  
  " Mode status styling (Command: Yellow)
  highlight StatusCmdText guibg=#dcdcaa guifg=#1e1e1e gui=bold
  highlight StatusCmdCap guifg=#dcdcaa guibg=#2d2d2d
  
  " Content/File details status styling (Darker Gray)
  highlight StatusFileText guibg=#3c3c3c guifg=#d4d4d4
  highlight StatusFileCap guifg=#3c3c3c guibg=#2d2d2d
]])

local modes = {
  ['n']      = 'NORMAL',
  ['no']     = 'N-PENDING',
  ['v']      = 'VISUAL',
  ['V']      = 'V-LINE',
  ['\22']    = 'V-BLOCK',
  ['s']      = 'SELECT',
  ['S']      = 'S-LINE',
  ['\19']     = 'S-BLOCK',
  ['i']      = 'INSERT',
  ['R']      = 'REPLACE',
  ['Rv']     = 'V-REPLACE',
  ['c']      = 'COMMAND',
  ['cv']     = 'VIM EX',
  ['ce']     = 'EX',
  ['r']      = 'PROMPT',
  ['rm']     = 'MORE',
  ['r?']     = 'CONFIRM',
  ['!']      = 'SHELL',
  ['t']      = 'TERMINAL',
}

-- Render bottom statusline using rounded capsule bubbles ( and )
function _G.custom_statusline()
  local mode = vim.api.nvim_get_mode().mode
  local mode_prefix = 'Normal'
  if mode == 'i' then
    mode_prefix = 'Insert'
  elseif mode == 'v' or mode == 'V' or mode == '\22' then
    mode_prefix = 'Visual'
  elseif mode == 'R' then
    mode_prefix = 'Replace'
  elseif mode == 'c' then
    mode_prefix = 'Cmd'
  end

  local mode_str = modes[mode] or mode

  -- Render bubbles
  local mode_bubble = string.format(
    '%%#Status%sCap#%%#Status%sText#%s%%#Status%sCap#',
    mode_prefix, mode_prefix, mode_str, mode_prefix
  )

  local file_bubble = '%#StatusFileCap#%#StatusFileText#%f %m%#StatusFileCap#'
  local filetype_bubble = '%#StatusFileCap#%#StatusFileText#%Y%#StatusFileCap#'

  local pos_bubble = string.format(
    '%%#Status%sCap#%%#Status%sText#%%l:%%c %%p%%%%%%#Status%sCap#',
    mode_prefix, mode_prefix, mode_prefix
  )

  return string.format(
    ' %%#StatusLineCustom# %s  %s %%= %s  %s ',
    mode_bubble,
    file_bubble,
    filetype_bubble,
    pos_bubble
  )
end

opt.statusline = '%!v:lua.custom_statusline()'

--------------------------------------------------------------------------------
-- 7. Filetype-Specific Settings & Autocommands
--------------------------------------------------------------------------------
-- Enable filetype detection, filetype plugins, and indentation rules (built-in)
vim.cmd("filetype plugin indent on")

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local config_group = augroup("FileTypeConfig", { clear = true })

-- Markdown settings
autocmd("FileType", {
  pattern = "markdown",
  group = config_group,
  callback = function()
    vim.opt_local.wrap = true          -- Wrap long lines
    vim.opt_local.spell = true         -- Enable spellcheck
    vim.opt_local.shiftwidth = 2       -- 2 spaces indent
    vim.opt_local.tabstop = 2
    vim.g.markdown_recommended_style = 0 -- Prevent built-in plugin overriding settings
  end
})

-- LaTeX settings
autocmd("FileType", {
  pattern = { "tex", "latex" },
  group = config_group,
  callback = function()
    vim.opt_local.wrap = true          -- Wrap long lines
    vim.opt_local.spell = true         -- Enable spellcheck
    vim.opt_local.shiftwidth = 2       -- 2 spaces indent
    vim.opt_local.tabstop = 2
  end
})

-- Python settings
autocmd("FileType", {
  pattern = "python",
  group = config_group,
  callback = function()
    vim.opt_local.shiftwidth = 4       -- PEP8 standard 4 spaces indent
    vim.opt_local.tabstop = 4
    vim.opt_local.expandtab = true
  end
})

-- Rust settings
autocmd("FileType", {
  pattern = "rust",
  group = config_group,
  callback = function()
    vim.opt_local.shiftwidth = 4       -- Standard 4 spaces indent
    vim.opt_local.tabstop = 4
    vim.opt_local.expandtab = true
  end
})

-- Ansible & YAML settings
-- Using Neovim's built-in filetype detection pattern helper (no plugins needed)
vim.filetype.add({
  pattern = {
    [".*/tasks/.*%.ya?ml"] = "yaml.ansible",
    [".*/playbooks/.*%.ya?ml"] = "yaml.ansible",
    [".*%-playbook%.ya?ml"] = "yaml.ansible",
    ["local%.ya?ml"] = "yaml.ansible",
  }
})

autocmd("FileType", {
  pattern = { "yaml", "yaml.ansible", "ansible" },
  group = config_group,
  callback = function()
    vim.opt_local.shiftwidth = 2       -- Standard 2 spaces for YAML/Ansible
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
  end
})
