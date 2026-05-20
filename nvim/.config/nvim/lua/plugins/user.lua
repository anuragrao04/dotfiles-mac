---@type LazySpec
return {
  {
    "max397574/better-escape.nvim",
    opts = {
      mappings = {
        t = {
          j = {
            j = function()
              local bufname = vim.api.nvim_buf_get_name(0)
              if bufname:match "lazygit" then return "jj" end
              return "<C-\\><C-n>"
            end,
          },
        },
      },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    opts = { direction = "vertical", size = 80, terminal_mappings = true },
  },
  {
    -- Show active terminal number in statusline
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      local term_component = {
        provider = function()
          local id = vim.g._last_toggleterm
          if not id then return "" end
          local ok, Terminal = pcall(require, "toggleterm.terminal")
          if not ok then return "" end
          local count = #Terminal.get_all()
          if count == 0 then return "" end
          return "  " .. id .. "/" .. count .. " "
        end,
        hl = { fg = "#9ece6a", bold = true },
      }
      if opts.statusline then table.insert(opts.statusline, #opts.statusline, term_component) end
    end,
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>", mode = { "n", "t" } },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>", mode = { "n", "t" } },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>", mode = { "n", "t" } },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>", mode = { "n", "t" } },
      { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", mode = { "n", "t" } },
    },
    lazy = false,
  },
  {
    "anuragrao04/pi-coding-agent.nvim",
    config = function() require("pi_coding_agent").setup() end,
    keys = {
      { "<leader>at", "<cmd>PiToggle<cr>", desc = "Toggle pi" },
      { "<leader>ac", "<cmd>PiContinue<cr>", desc = "Continue pi session" },
      { "<leader>ar", "<cmd>PiResume<cr>", desc = "Resume pi session" },
      { "<leader>am", "<cmd>PiSelectModel<cr>", desc = "Select pi model" },
      { "<leader>ab", "<cmd>PiSendBuffer<cr>", desc = "Send buffer to pi" },
      { "<leader>as", "<cmd>PiSendSelection<cr>", mode = "v", desc = "Send selection to pi" },
    },
  },
  {
    "hat0uma/csvview.nvim",
    ---@module "csvview"
    ---@type CsvView.Options
    opts = {
      parser = { comments = { "#", "//" } },
      keymaps = {
        -- Text objects for selecting fields
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        -- Excel-like navigation
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
      },
    },
    cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle", "CsvViewInfo" },
  },
}
