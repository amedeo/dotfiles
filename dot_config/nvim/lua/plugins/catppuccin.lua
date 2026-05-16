return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato", -- Default to mocha
      })
      vim.cmd([[colorscheme catppuccin]])
    end,
  },
}
