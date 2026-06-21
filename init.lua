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

-- Custom navigation functions for Netrw (h/l open/close folders)
local function netrw_l()
  -- Simulate Enter (opens file or expands/collapses directory)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, true, true), 'm', true)
end

local function netrw_h()
  local line = vim.api.nvim_get_current_line()
  local row = vim.api.nvim_win_get_cursor(0)[1]

  -- If we are at the very top, run the fallback (go up a directory)
  if row <= 1 then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('-', true, true, true), 'm', true)
    return
  end

  -- In netrw tree view, directories end with '/'
  local is_dir = line:match('/$')

  if is_dir then
    -- Check if it's expanded by inspecting the next line's indentation.
    local next_line = vim.fn.getline(row + 1)
    local cur_indent = line:match('^[|%s]*') or ''
    local next_indent = next_line:match('^[|%s]*') or ''

    if #next_indent > #cur_indent then
      -- It is expanded! Press <CR> to collapse it.
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, true, true), 'm', true)
      return
    end
  end

  -- If it's a file or a collapsed directory, try to jump to the parent directory line.
  local cur_indent = line:match('^[|%s]*') or ''
  if #cur_indent > 0 then
    for r = row - 1, 1, -1 do
      local p_line = vim.fn.getline(r)
      local p_indent = p_line:match('^[|%s]*') or ''
      if #p_indent < #cur_indent and p_line:match('/$') then
        vim.api.nvim_win_set_cursor(0, { r, 0 })
        return
      end
    end
  end

  -- Fallback: Go up one directory level (simulates '-' in netrw)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('-', true, true, true), 'm', true)
end

--------------------------------------------------------------------------------
-- 4. Buffer / Tab Navigation Helpers (Ctrl-h and Ctrl-l)
--------------------------------------------------------------------------------
-- Helper to list valid file buffers (excluding netrw, directories, and special panels)
local function get_valid_buffers()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  local valid = {}
  for _, buf in ipairs(bufs) do
    local bufnr = buf.bufnr
    local name = vim.api.nvim_buf_get_name(bufnr)
    local ft = vim.bo[bufnr].filetype
    local bt = vim.bo[bufnr].buftype

    -- Exclude netrw, special buffers, directories, and netrw URLs
    local is_netrw = ft == 'netrw' or name:match('^netrw://')
    local is_dir = vim.fn.isdirectory(name) == 1
    local is_special = bt ~= ''

    if not is_netrw and not is_dir and not is_special then
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
  else
    -- If there is no editor window, split vertically and open the buffer
    vim.cmd('vsplit')
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

-- Clean up Netrw buffers when closed and bind custom keymaps local to the buffer
vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    vim.opt_local.bufhidden = "wipe" -- Wipe buffer when it becomes hidden
    
    -- Map h/l locally in netrw buffer for folder open/close navigation
    vim.keymap.set('n', 'l', netrw_l, { silent = true, buffer = true, desc = 'Open folder/file' })
    vim.keymap.set('n', 'h', netrw_h, { silent = true, buffer = true, desc = 'Collapse folder or jump to parent' })

    -- Overwrite Netrw's built-in Ctrl-l mapping (which defaults to refreshing directory)
    vim.keymap.set('n', '<C-l>', handle_ctrl_l, { silent = true, buffer = true, desc = 'Go to first tab' })
    vim.keymap.set('n', '<C-h>', handle_ctrl_h, { silent = true, buffer = true, desc = 'Go to sidebar' })
  end
})

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

-- Map Ctrl-h and Ctrl-l
vim.keymap.set('n', '<C-h>', handle_ctrl_h, { silent = true, desc = 'Previous buffer or go to sidebar' })
vim.keymap.set('n', '<C-l>', handle_ctrl_l, { silent = true, desc = 'Next buffer or go to first tab' })

--------------------------------------------------------------------------------
-- 5. Highlight Colors (Blue Bubble Theme for Statusline and Tabline)
--------------------------------------------------------------------------------
vim.cmd([[
  highlight StatusLineCustom ctermbg=8 ctermfg=7 guibg=#1e1e1e guifg=#808080
  
  " Active Blue Bubble Highlights (VS Code Blue)
  highlight StatusActiveText guibg=#007acc guifg=#ffffff gui=bold
  highlight StatusActiveCap guifg=#007acc guibg=#1e1e1e
  
  " Secondary Dark Blue Bubble Highlights (Muted Blue-Gray)
  highlight StatusSecondaryText guibg=#2d3d5a guifg=#d4d4d4
  highlight StatusSecondaryCap guifg=#2d3d5a guibg=#1e1e1e
  
  " Tabline layout colors
  highlight TabLineFill guibg=#1e1e1e guifg=#808080
]])

--------------------------------------------------------------------------------
-- 6. Tabline (Displaying all open tabs/buffers at the top of the editor)
--------------------------------------------------------------------------------
opt.showtabline = 2 -- Always show the tabline at the top

-- Custom tabline rendering function in pure Lua (zero dependencies)
function _G.custom_tabline()
  -- Calculate sidebar width dynamically to align tabs with the text editor only
  local sidebar_width = 0
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == 'netrw' then
      sidebar_width = vim.api.nvim_win_get_width(win) + 1 -- plus vertical separator
      break
    end
  end

  local s = ''
  -- Pad the left side matching the sidebar width
  if sidebar_width > 0 then
    s = s .. '%#TabLineFill#' .. string.rep(' ', sidebar_width)
  end

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

  local cur_buf = vim.api.nvim_get_current_buf()

  -- Render tabs as bubbles
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

    -- Format active vs inactive tabs using blue bubble highlights
    if bufnr == cur_buf then
      s = s .. '%#StatusActiveCap#%#StatusActiveText#' .. i .. ':' .. name .. '%#StatusActiveCap# '
    else
      s = s .. '%#StatusSecondaryCap#%#StatusSecondaryText#' .. i .. ':' .. name .. '%#StatusSecondaryCap# '
    end
  end

  s = s .. '%#TabLineFill#%='
  return s
end

opt.tabline = '%!v:lua.custom_tabline()'

--------------------------------------------------------------------------------
-- 7. Custom Bubble Statusline (100% native blue theme)
--------------------------------------------------------------------------------
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

-- Render bottom statusline using rounded capsule bubbles ( and ) in blue theme
function _G.custom_statusline()
  local mode = vim.api.nvim_get_mode().mode
  local mode_str = modes[mode] or mode

  -- Render status bubbles uniformly in blue colors
  local mode_bubble = string.format(
    '%%#StatusActiveCap#%%#StatusActiveText#%s%%#StatusActiveCap#',
    mode_str
  )

  local file_bubble = '%#StatusSecondaryCap#%#StatusSecondaryText#%f %m%#StatusSecondaryCap#'
  local filetype_bubble = '%#StatusSecondaryCap#%#StatusSecondaryText#%Y%#StatusSecondaryCap#'

  local pos_bubble = '%#StatusActiveCap#%#StatusActiveText#%l:%c %p%%%#StatusActiveCap#'

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
-- 8. Filetype-Specific Settings & Autocommands
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
