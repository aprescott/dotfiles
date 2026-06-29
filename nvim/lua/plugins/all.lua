return {
  {
    "rmagatti/auto-session",
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      -- log_level = 'debug',
      single_session_mode = true,
    },
  },

  {
    'projekt0n/github-nvim-theme',
    name = 'github-theme',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('github-theme').setup({
        -- ...
      })

      vim.cmd('colorscheme github_dark_default')
    end,
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        offsets = {
          {
            filetype = "neo-tree",
            text = "Files",
            highlight = "Directory",
            separator = true,
          },
        },
      },
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false, -- neo-tree will lazily load itself
    opts = {
      window = {
        position = "float",
      },
      filesystem = {
        hijack_netrw_behavior = "disabled",
        filtered_items = {
          visible = true,
        },
      },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate'
  },

  { "lukas-reineke/virt-column.nvim", opts = {} },
  { "github/copilot.vim" },
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      local set = vim.keymap.set

      -- Add a cursor to every search result in the buffer.
      set({"n", "x"}, "<D-d>", function() mc.matchAddCursor(1) end)
      set({"n", "x"}, "<D-u>", function() mc.matchAddCursor(-1) end)

      -- Append/insert for each line of visual selections.
      -- Similar to block selection insertion.
      set("x", "<D-S-L>", mc.appendVisual)

      -- Mappings defined in a keymap layer only apply when there are
      -- multiple cursors. This lets you have overlapping mappings.
      mc.addKeymapLayer(function(layerSet)
        -- Enable and clear cursors using escape.
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)

      -- Customize how cursors look.
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { reverse = true })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn"})
      hl(0, "MultiCursorMatchPreview", { link = "Search" })
      hl(0, "MultiCursorDisabledCursor", { reverse = true })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { link = "SignColumn"})
    end
  },

  {
    "ibhagwan/fzf-lua",
    lazy = false,
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- or if using mini.icons/mini.nvim
    -- dependencies = { "nvim-mini/mini.icons" },
    ---@module "fzf-lua"
    ---@type fzf-lua.Config|{}
    ---@diagnostic disable: missing-fields
    opts = {
      files = {
        git_icons = true,
      },
      grep = {
        fzf_opts = {
          ["--nth"] = "3..",
        },
      },
    },
    ---@diagnostic enable: missing-fields
    keys = {
      { "<C-k>",  "<cmd>FzfLua builtin<cr>" },
      { "<D-p>",  "<cmd>FzfLua files<cr>" },
      { "<C-\\>", "<cmd>FzfLua buffers<cr>" },
      { "<D-r>",  "<cmd>FzfLua grep_project<cr>" },
    },
  },

  {
    "folke/which-key.nvim",
    enabled = false,
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  { "lewis6991/gitsigns.nvim" },
  { "HiPhish/rainbow-delimiters.nvim" },
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        mode     = "background",

        RGB      = true;  -- #RGB hex codes
        RRGGBB   = true;  -- #RRGGBB hex codes
        names    = true;  -- "Name" codes like Blue
        RRGGBBAA = true; -- #RRGGBBAA hex codes
        rgb_fn   = true; -- CSS rgb() and rgba() functions
        hsl_fn   = true; -- CSS hsl() and hsla() functions
        css      = true; -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn   = true; -- Enable all CSS *functions*: rgb_fn, hsl_fn
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    -- rainbow-delimiters.nvim integration, per the ibl README
    config = function()
      local highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }
      local highlight_active = {
        "RainbowRedActive",
        "RainbowYellowActive",
        "RainbowBlueActive",
        "RainbowOrangeActive",
        "RainbowGreenActive",
        "RainbowVioletActive",
        "RainbowCyanActive",
      }
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed",          { fg = "#5c3035" })
        vim.api.nvim_set_hl(0, "RainbowYellow",       { fg = "#5c4e2e" })
        vim.api.nvim_set_hl(0, "RainbowBlue",         { fg = "#2a4a6b" })
        vim.api.nvim_set_hl(0, "RainbowOrange",       { fg = "#5c3f20" })
        vim.api.nvim_set_hl(0, "RainbowGreen",        { fg = "#2e4a2e" })
        vim.api.nvim_set_hl(0, "RainbowViolet",       { fg = "#4a2e5c" })
        vim.api.nvim_set_hl(0, "RainbowCyan",         { fg = "#1e4a4a" })
        vim.api.nvim_set_hl(0, "RainbowRedActive",    { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellowActive", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlueActive",   { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrangeActive", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowGreenActive",  { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowVioletActive", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyanActive",   { fg = "#56B6C2" })
      end)
      vim.g.rainbow_delimiters = { highlight = highlight_active }
      require("ibl").setup({ indent = { highlight = highlight, char = "▏" }, scope = { highlight = highlight_active } })
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end,
  },
  { "nvim-treesitter/nvim-treesitter-context" },
  { "neovim/nvim-lspconfig" },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  },

  ---@module "neominimap.config.meta"
  {
    "Isrothy/neominimap.nvim",
    enabled = false,
    version = "v3.x.x",
    lazy = false, -- NOTE: NO NEED to Lazy load
    -- Optional. You can also set your own keybindings
    keys = {
      -- Global Minimap Controls
      -- { "<leader>nm", "<cmd>Neominimap Toggle<cr>", desc = "Toggle global minimap" },
      -- { "<leader>no", "<cmd>Neominimap Enable<cr>", desc = "Enable global minimap" },
      -- { "<leader>nc", "<cmd>Neominimap Disable<cr>", desc = "Disable global minimap" },
      -- { "<leader>nr", "<cmd>Neominimap Refresh<cr>", desc = "Refresh global minimap" },

      -- Window-Specific Minimap Controls
      -- { "<leader>nwt", "<cmd>Neominimap WinToggle<cr>", desc = "Toggle minimap for current window" },
      -- { "<leader>nwr", "<cmd>Neominimap WinRefresh<cr>", desc = "Refresh minimap for current window" },
      -- { "<leader>nwo", "<cmd>Neominimap WinEnable<cr>", desc = "Enable minimap for current window" },
      -- { "<leader>nwc", "<cmd>Neominimap WinDisable<cr>", desc = "Disable minimap for current window" },

      -- Tab-Specific Minimap Controls
      -- { "<leader>ntt", "<cmd>Neominimap TabToggle<cr>", desc = "Toggle minimap for current tab" },
      -- { "<leader>ntr", "<cmd>Neominimap TabRefresh<cr>", desc = "Refresh minimap for current tab" },
      -- { "<leader>nto", "<cmd>Neominimap TabEnable<cr>", desc = "Enable minimap for current tab" },
      -- { "<leader>ntc", "<cmd>Neominimap TabDisable<cr>", desc = "Disable minimap for current tab" },

      -- Buffer-Specific Minimap Controls
      -- { "<leader>nbt", "<cmd>Neominimap BufToggle<cr>", desc = "Toggle minimap for current buffer" },
      -- { "<leader>nbr", "<cmd>Neominimap BufRefresh<cr>", desc = "Refresh minimap for current buffer" },
      -- { "<leader>nbo", "<cmd>Neominimap BufEnable<cr>", desc = "Enable minimap for current buffer" },
      -- { "<leader>nbc", "<cmd>Neominimap BufDisable<cr>", desc = "Disable minimap for current buffer" },

      ---Focus Controls
      -- { "<leader>nf", "<cmd>Neominimap Focus<cr>", desc = "Focus on minimap" },
      -- { "<leader>nu", "<cmd>Neominimap Unfocus<cr>", desc = "Unfocus minimap" },
      -- { "<leader>ns", "<cmd>Neominimap ToggleFocus<cr>", desc = "Switch focus on minimap" },
    },
    init = function()
      -- The following options are recommended when layout == "float"
      vim.opt.wrap = false
      vim.opt.sidescrolloff = 36 -- Set a large value

      --- Put your configuration here
      ---@type Neominimap.UserConfig
      vim.g.neominimap = {
        auto_enable = true,
        float = { z_index = 100 },
      }
    end,
  },

  {
    'saghen/blink.cmp',
    enabled = false,
    dependencies = {
      'saghen/blink.lib',
      -- optional: provides snippets for the snippet source
      'rafamadriz/friendly-snippets',
    },
    build = function()
      -- build the fuzzy matcher, optionally add a timeout to `pwait(timeout_ms)`
      -- you can use `gb` in `:Lazy` to rebuild the plugin as needed
      require('blink.cmp').build():pwait()
    end,

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = { preset = 'default' },

      -- (Default) Only show the documentation popup when manually triggered
      completion = { documentation = { auto_show = false } },

      -- (Default) list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"`
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = "rust" }
    },
  }
}
