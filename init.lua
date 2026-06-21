-- =============================================================================
-- Lite Neovim Configuration (YAGNI & Built-in Focused)
-- =============================================================================
-- This configuration prioritizes Neovim's built-in features, keeping it extremely
-- fast, lightweight, and free of unnecessary dependencies.
--
-- File types supported out-of-the-box: Markdown, LaTeX, Python, Rust, Ansible/YAML.
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
-- 2. Theme & Colors
--------------------------------------------------------------------------------
-- Set the built-in 'retrobox' colorscheme (a clean Gruvbox style added in Neovim 0.9)
vim.cmd("colorscheme retrobox")

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
-- 4. Buffer & Tab Navigation
--------------------------------------------------------------------------------
-- Switch between buffers (standard "tabs" for editing files)
-- Using a smart helper to prevent Netrw sidebar window from being replaced
local function prev_buffer()
  if vim.bo.filetype == 'netrw' then
    return -- Do nothing if focus is on the sidebar
  end
  vim.cmd('bprevious')
end

local function next_buffer()
  if vim.bo.filetype == 'netrw' then
    return -- Do nothing if focus is on the sidebar
  end
  vim.cmd('bnext')
end

-- Map Ctrl+j and Ctrl+k to move through buffers
vim.keymap.set('n', '<C-j>', prev_buffer, { silent = true, desc = 'Previous buffer' })
vim.keymap.set('n', '<C-k>', next_buffer, { silent = true, desc = 'Next buffer' })

-- Alternative: Navigate actual Vim Tabs (Uncomment these and comment out the buffer ones if preferred)
-- vim.keymap.set('n', '<C-j>', ':tabprevious<CR>', { silent = true, desc = 'Previous tab' })
-- vim.keymap.set('n', '<C-k>', ':tabnext<CR>', { silent = true, desc = 'Next tab' })

--------------------------------------------------------------------------------
-- 5. Custom Statusline (Dynamic & Colored)
--------------------------------------------------------------------------------
-- Clean, beautiful statusline highlighting modes and file information without plugins
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

-- Set statusline highlight colors matching the 'retrobox' colorscheme
vim.cmd([[
  highlight StatusNormal ctermbg=2 ctermfg=0 guibg=#b8bb26 guifg=#282828 gui=bold
  highlight StatusInsert ctermbg=4 ctermfg=0 guibg=#83a598 guifg=#282828 gui=bold
  highlight StatusVisual ctermbg=5 ctermfg=0 guibg=#d3869b guifg=#282828 gui=bold
  highlight StatusReplace ctermbg=1 ctermfg=0 guibg=#fb4934 guifg=#282828 gui=bold
  highlight StatusCmd ctermbg=3 ctermfg=0 guibg=#fabd2f guifg=#282828 gui=bold
  highlight StatusLineCustom ctermbg=8 ctermfg=7 guibg=#3c3836 guifg=#ebdbb2
]])

function _G.custom_statusline()
  local mode = vim.api.nvim_get_mode().mode
  local hl = '%#StatusNormal#'
  if mode == 'i' then
    hl = '%#StatusInsert#'
  elseif mode == 'v' or mode == 'V' or mode == '\22' then
    hl = '%#StatusVisual#'
  elseif mode == 'R' then
    hl = '%#StatusReplace#'
  elseif mode == 'c' then
    hl = '%#StatusCmd#'
  end

  local mode_str = modes[mode] or mode
  -- Formatted statusline: [MODE] | filename modified === filetype | line:col | percentage
  return string.format(
    '%s %s %%#StatusLineCustom# | %%f %%m %%= %%y | %%l:%%c | %%p%% ',
    hl,
    mode_str
  )
end

opt.statusline = '%!v:lua.custom_statusline()'

--------------------------------------------------------------------------------
-- 6. Filetype-Specific Settings & Autocommands
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
