return {
  { -- Copilot
    'zbirenbaum/copilot.lua',
    config = function()
      require('copilot').setup {}
    end,
  },

  {
    'zbirenbaum/copilot-cmp',
    config = function()
      require('copilot_cmp').setup()
    end,
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          {
            'rafamadriz/friendly-snippets',
            config = function()
              local luasnip = require 'luasnip'
              luasnip.filetype_extend('typescriptreact', { 'javascript' })
              luasnip.filetype_extend('typescript', { 'javascript' })
              luasnip.filetype_extend('vue', { 'vue' })
              luasnip.filetype_extend('vue', { 'javascript' })
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'onsails/lspkind-nvim',
      {
        'roobert/tailwindcss-colorizer-cmp.nvim',
        -- optionally, override the default options:
        config = function()
          require('tailwindcss-colorizer-cmp').setup {
            color_square_width = 2,
          }
        end,
      },
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require 'lspkind'
      local types = require 'cmp.types'
      local str = require 'cmp.utils.str'

      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<CR>'] = cmp.mapping.confirm { select = true },

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = 'copilot' },
        },
        experimental = {
          ghost_text = true,
        },
        formatting = {
          expandable_indicator = true,
          fields = {
            cmp.ItemField.Abbr,
            cmp.ItemField.Kind,
            cmp.ItemField.Menu,
            cmp.ItemField.Info,
          },
          format = lspkind.cmp_format {
            mode = 'symbol_text',
            maxwidth = 60,
            before = function(entry, vim_item)
              vim_item.menu = ({
                copilot = '',
                nvim_lsp = 'ﲳ',
                nvim_lua = '',
                treesitter = '',
                path = 'ﱮ',
                buffer = '﬘',
                zsh = '',
                vsnip = '',
                spell = '暈',
                emoji = 'ﲃ',
              })[entry.source.name]

              local word = entry:get_insert_text()
              if entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet then
                word = vim.lsp.util.parse_snippet(word)
              end
              word = str.oneline(word)
              if entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet and string.sub(vim_item.abbr, -1, -1) == '~' then
                word = word .. '~'
              end
              vim_item.abbr = word
              vim_item = require('tailwindcss-colorizer-cmp').formatter(entry, vim_item)

              return vim_item
            end,
          },
        },
      }
    end,
  },
}