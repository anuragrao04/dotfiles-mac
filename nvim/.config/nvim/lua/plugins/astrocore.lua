

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
        autoread = true, -- pick up external file changes (e.g. from Claude edits)
        fillchars = { vert = "│", horiz = "─", horizup = "┴", horizdown = "┬", vertleft = "┤", vertright = "├", verthoriz = "┼" },
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- which-key group for Claude Code
        ["<Leader>a"] = { desc = "AI/Claude Code" },

        -- Search dotfiles too, while still respecting .gitignore
        ["<Leader>fw"] = {
          function() require("snacks").picker.grep { hidden = true } end,
          desc = "Find words",
        },

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,

        -- Terminal management: one panel, swap sessions in/out
        -- Helper: hide all visible toggleterms
        ["<Leader>tf"] = {
          function()
            local Terminal = require("toggleterm.terminal")
            for _, t in ipairs(Terminal.get_all()) do if t:is_open() then t:close() end end
            local id = vim.g._last_toggleterm or 1
            vim.cmd(id .. "ToggleTerm direction=float")
          end,
          desc = "ToggleTerm float",
        },
        ["<Leader>th"] = {
          function()
            local Terminal = require("toggleterm.terminal")
            for _, t in ipairs(Terminal.get_all()) do if t:is_open() then t:close() end end
            local id = vim.g._last_toggleterm or 1
            vim.cmd(id .. "ToggleTerm size=10 direction=horizontal")
          end,
          desc = "ToggleTerm horizontal",
        },
        ["<Leader>tv"] = {
          function()
            local Terminal = require("toggleterm.terminal")
            for _, t in ipairs(Terminal.get_all()) do if t:is_open() then t:close() end end
            local id = vim.g._last_toggleterm or 1
            vim.cmd(id .. "ToggleTerm size=80 direction=vertical")
          end,
          desc = "ToggleTerm vertical",
        },
        ["<Leader>ts"] = {
          function()
            local Terminal = require("toggleterm.terminal")
            local terms = Terminal.get_all()
            if #terms == 0 then vim.notify("No terminals open", vim.log.levels.INFO) return end
            vim.ui.select(terms, {
              prompt = "Select terminal",
              format_item = function(t) return "#" .. t.id .. (t:is_open() and " (visible)" or "") end,
            }, function(choice)
              if not choice then return end
              for _, t in ipairs(Terminal.get_all()) do if t:is_open() then t:close() end end
              vim.g._last_toggleterm = choice.id
              choice:open()
            end)
          end,
          desc = "Select terminal",
        },
        ["<Leader>tn"] = {
          function()
            local Terminal = require("toggleterm.terminal")
            -- Close any visible terminal first
            for _, t in ipairs(Terminal.get_all()) do if t:is_open() then t:close() end end
            -- Find next ID and open it in the same spot
            local max_id = 0
            for _, t in ipairs(Terminal.get_all()) do
              if t.id > max_id then max_id = t.id end
            end
            local new_id = max_id + 1
            vim.g._last_toggleterm = new_id
            vim.cmd(new_id .. "ToggleTerm")
          end,
          desc = "New terminal",
        },
      },
      t = {},
    },
  },
}
