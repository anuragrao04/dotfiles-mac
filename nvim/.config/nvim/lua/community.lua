-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.colorscheme.tokyonight-nvim" },
  { import = "astrocommunity.completion.copilot-lua-cmp" },
  { import = "astrocommunity.ai.opencode-nvim" },
  { import = "astrocommunity.git.diffview-nvim" },
  {
    "zbirenbaum/copilot.lua",
    opts = {
      filetypes = {
        markdown = true,
      },
    },
  },
  -- import/override with your plugins folder
}
