return {
  {
    "Prog-up/vscode.nvim",
    -- lazy = false, -- make sure it loads at startup
    -- priority = 1000, -- make sure to load this before all other plugins
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("vscode").setup({
        transparent = true,
        italic_comments = true,
        underline_links = true,
        disable_nvimtree_bg = true,
      })
      require("lualine").setup({
        options = {
          theme = "vscode",
        },
      })

      vim.cmd.colorscheme("vscode")
    end,
  },
}
