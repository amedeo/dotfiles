local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- TODO: Remove this workaround once macOS 26 (Tahoe) stops rejecting CS_LINKER_SIGNED
-- .so files loaded via dlopen(). All treesitter parsers and native plugins compiled
-- with a linker-signed ad-hoc signature (flags=0x20002) are killed with SIGKILL
-- CODESIGNING at runtime. Re-signing strips the linker-signed bit (-> flags=0x2).
local function resign_so_files()
  local paths = {
    vim.fn.stdpath("data"),
    vim.fn.exepath("nvim"):gsub("/bin/nvim$", "/lib/nvim"),
  }
  local count = 0
  for _, base in ipairs(paths) do
    local handle = io.popen(string.format("find %q -name '*.so' 2>/dev/null", base))
    if handle then
      for file in handle:lines() do
        -- chmod u+w in case file is read-only (e.g. homebrew cellar)
        os.execute(string.format("chmod u+w %q 2>/dev/null", file))
        os.execute(string.format("codesign --force --sign - %q 2>/dev/null", file))
        count = count + 1
      end
      handle:close()
    end
  end
  if count > 0 then
    vim.notify(
      string.format(
        "[macOS 26 workaround] Re-signed %d .so file(s) after update.\n"
          .. "Remove the post_update hook in lua/config/lazy.lua once macOS accepts\n"
          .. "linker-signed dylibs from dlopen() again.",
        count
      ),
      vim.log.levels.WARN,
      { title = "codesign workaround" }
    )
  end
end

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- LazyVim extras MUST be here (between base and your plugins)
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.ui.mini-starter" },

    { import = "lazyvim.plugins.extras.coding.luasnip" },
    { import = "lazyvim.plugins.extras.coding.mini-surround" },
    { import = "lazyvim.plugins.extras.editor.outline" },
    { import = "lazyvim.plugins.extras.ui.alpha" },
    { import = "lazyvim.plugins.extras.ui.mini-animate" },
    { import = "lazyvim.plugins.extras.util.dot" },

    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.toml" },

    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "catppuccin", "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- TODO: Remove this autocmd once macOS 26 (Tahoe) stops rejecting CS_LINKER_SIGNED
-- dylibs from dlopen(). Fires after every :Lazy sync/install/update.
vim.api.nvim_create_autocmd("User", {
  pattern = "LazySync",
  once = false,
  callback = function()
    vim.defer_fn(resign_so_files, 500)
  end,
})
