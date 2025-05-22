return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false, -- make sure it loads at startup
    priority = 1000, -- make sure to load this before all other plugins
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      -- vim.o.background = "light" -- or 'light' as needed
      --
      local c = require("vscode.colors").get_colors()
      require("vscode").setup({
        transparent = true,
        italic_comments = true,
        underline_links = true,
        disable_nvimtree_bg = true,
        -- color_overrides = {
        --   vscLineNumber = "#FFFFFF",
        -- },
        -- group_overrides = {
        --   Cursor = {
        --     fg = c.vscDarkBlue,
        --     bg = c.vscLightGreen,
        --     bold = true,
        --   },
        -- },
      })

      vim.cmd.colorscheme("vscode")
    end,
  },
}
