# Lite Neovim Configuration (Built-in & YAGNI)

A lightweight, high-performance, and plug-free Neovim configuration structured around Neovim's built-in capabilities and the standard package system (`vim.pack`).

Developed following **YAGNI (You Aren't Gonna Need It)** principles for speed and minimal overhead.

## Key Features

1. **Integrated Left Sidebar Panel**:
   - Built using Neovim's native file explorer **Netrw**.
   - Toggle the sidebar anytime using `<Ctrl-e>`.
   - Complete support for file creation, deletion, renaming, and directory creation directly in the sidebar.
2. **Tab & Buffer Navigation (`<Ctrl-h>` & `<Ctrl-l>`)**:
   - Cycle through open file tabs using `<Ctrl-h>` (previous tab) and `<Ctrl-l>` (next tab).
   - Smart sidebar transitions: pressing `<Ctrl-h>` while on the first tab moves focus directly into the sidebar. Pressing `<Ctrl-l>` while inside the sidebar jumps directly to the first tab on the right.
3. **Top Tabline with Dynamic Alignment**:
   - Displays all open files/buffers at the top of the text editor window only, leaving the top of the sidebar blank.
   - Designed using capsule bubbles in the VS Code blue theme (active: bright blue, inactive: dark blue-gray). Indicates unsaved changes with `●`.
4. **Bottom Bubble Statusline**:
   - Programmed with a unified blue capsule bubble theme (active: bright blue, inactive: dark blue-gray) displaying current mode, filepath, modified state, filetype, line:col, and percentage.
5. **Filetype-Specific Configuration**:
   - Optimized indentation and settings for **Markdown**, **LaTeX**, **Python**, **Rust**, and **Ansible**.
   - Auto-detects Ansible playbooks and tasks files automatically using Neovim's native API.

---

## Netrw Cheat Sheet (Left Sidebar Explorer)

Toggle the sidebar with **`<Ctrl-e>`**. While inside the sidebar, use the following keybindings:

| Key | Action |
| --- | --- |
| `l` / `<CR>` | Open file (in the editor window) / Expand folder / Toggle directory |
| `h` | Collapse folder (if expanded) / Jump to parent folder (if collapsed/file) / Go up a directory level |
| `%` | Create a new file (prompts for filename at the bottom command bar) |
| `d` | Create a new directory (prompts for folder name) |
| `R` | Rename the file/folder under the cursor |
| `D` | Delete the file/folder under the cursor (asks for confirmation) |

---

## Package Management via `vim.pack`

This configuration uses Neovim's built-in package manager (`vim.pack`). You don't need any complex plugin managers like Lazy.nvim or packer.nvim. 

### Structure
Packages are placed under standard directories:
- `~/.config/nvim/pack/plugins/start/` (Loaded automatically on startup)
- `~/.config/nvim/pack/plugins/opt/` (Loaded on-demand via `:packadd <plugin>`)

### How to Install a Plugin
To install any plugin, simply clone it into the `start` directory. For example, to install a colorscheme or syntax plugin:

```bash
git clone --depth 1 https://github.com/morhetz/gruvbox.git ~/.config/nvim/pack/plugins/start/gruvbox
```

To remove a plugin, delete its directory:
```bash
rm -rf ~/.config/nvim/pack/plugins/start/gruvbox
```

---

## Filetype Autocommand Rules

- **Markdown**: Enables word wrapping, spelling checks, 2-space tabs.
- **LaTeX**: Enables word wrapping, spelling checks, 2-space tabs.
- **Python**: Standard PEP8 4-space indentation.
- **Rust**: Standard 4-space indentation.
- **Ansible/YAML**: Standard 2-space indentation. Recognizes ansible files in tasks/playbooks directories and formats them accordingly.
