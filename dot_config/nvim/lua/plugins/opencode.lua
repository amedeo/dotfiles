return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for ask()/select(), and required if you use the snacks provider
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  init = function()
    -- Plugin reads config from this global (per README)
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- optional: customize later (see lua/opencode/config.lua in the plugin)
    }

    -- Required for auto-reload behavior when opencode edits files
    vim.o.autoread = true
  end,
  keys = {
    {
      "<leader>oa",
      function()
        require("opencode").ask("@this: ", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "Ask opencode",
    },
    {
      "<leader>oo",
      function()
        require("opencode").select()
      end,
      mode = { "n", "x" },
      desc = "Opencode actions…",
    },
    {
      "<leader>ot",
      function()
        require("opencode").toggle()
      end,
      mode = { "n", "t" },
      desc = "Toggle opencode",
    },
    {
      "go",
      function()
        return require("opencode").operator("@this ")
      end,
      mode = { "n", "x" },
      expr = true,
      desc = "Add range to opencode",
    },
    {
      "goo",
      function()
        return require("opencode").operator("@this ") .. "_"
      end,
      mode = "n",
      expr = true,
      desc = "Add line to opencode",
    },
  },
}
