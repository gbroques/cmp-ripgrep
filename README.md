# cmp-ripgrep

[nvim-cmp](https://github.com/hrsh7th/nvim-cmp) completion source for [ripgrep](https://github.com/BurntSushi/ripgrep) flags.

> [!WARNING]
> Currently experimental until v1.0.0 release.

## Motivation

[telescope-live-grep-args.nvim](https://github.com/nvim-telescope/telescope-live-grep-args.nvim) allows passing flags to the underlying ripgrep (`rg`) command that powers the search.

Adding a completion source for flags allows them to be more discoverable, and aids with memory in case they're forgot.

https://github.com/user-attachments/assets/d2ae029c-fd7f-455d-bd9d-24311fccd417

## Installation

If you use [lazy.nvim](https://github.com/folke/lazy.nvim) as your plugin manager:
```lua
{
  'gbroques/cmp-ripgrep',
  dependencies = 'hrsh7th/nvim-cmp'
}
```

## Setup

By default, the completion source is enabled everywhere.

To limit it to only the live_grep_args picker, then add the following code:
```lua
local function is_current_picker_live_grep_args()
  local bufnr = vim.api.nvim_get_current_buf()
  local current_picker = require('telescope.actions.state').get_current_picker(bufnr)
  if current_picker == nil then
    return false
  end
  -- You need to update this if you customize the default prompt_title for the picker.
  return current_picker and current_picker.prompt_title == 'Live Grep (Args)'
end
require('cmp').setup({
  -- Enable completion when picker is live_grep_args, and buffer type is prompt.
  -- Completion is disabled by default for the prompt buffer type:
  -- https://github.com/hrsh7th/nvim-cmp/issues/60
  enabled = function()
    local is_prompt = vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt'
    return (is_prompt and is_current_picker_live_grep_args()) or not is_prompt
  end,
  sources = {
    {
      name = 'ripgrep',
      -- Only enable the completion source when the current picker is live_grep_args
      option = { enabled = is_current_picker_live_grep_args }
    },
  },
})
```

## Configuration

### Customizing the Kind

The kind controlling the icon of completion items in the menu may be customized.

It defaults to Variable.
```lua
require('cmp').setup({
  -- Enable completion when picker is live_grep_args, and buffer type is prompt.
  -- Completion is disabled by default for the prompt buffer type:
  -- https://github.com/hrsh7th/nvim-cmp/issues/60
  enabled = function()
    local is_prompt = vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt'
    return (is_prompt and is_current_picker_live_grep_args()) or not is_prompt
  end,
  sources = {
    {
      name = 'ripgrep',
      option = {
        -- Only enable the completion source when the current picker is live_grep_args
        enabled = is_current_picker_live_grep_args,
        kind = require('cmp').lsp.CompletionItemKind.Variable
      }
    },
  },
})
```

### Customizing Completion Flags

Numerous flags are filtered out because they either break the picker, or aren't very useful.

These may be overridden by passing `exclude` to `option`.

The default list may be seen below:

```lua
require('cmp').setup({
  -- Enable completion when picker is live_grep_args, and buffer type is prompt.
  -- Completion is disabled by default for the prompt buffer type:
  -- https://github.com/hrsh7th/nvim-cmp/issues/60
  enabled = function()
    local is_prompt = vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt'
    return (is_prompt and is_current_picker_live_grep_args()) or not is_prompt
  end,
  sources = {
    {
      name = 'ripgrep',
      option = {
        -- Only enable the completion source when the current picker is live_grep_args
        enabled = is_current_picker_live_grep_args,
        -- exclude flags that break the picker, or are otherwise not useful.
        exclude = {
          '-v', '--invert-match', -- http://github.com/nvim-telescope/telescope-live-grep-args.nvim/issues/65
          '--json',               -- https://github.com/nvim-telescope/telescope-live-grep-args.nvim/issues/4
          '-h', '--help',
          '--color',
          '--colors',
          '--passthru',
          '-A', '--after-context',
          '-B', '--before-context',
          '-C', '--context',
          '-0', '--null',
          '-q', '--quiet',
          '-p', '--pretty',
          '-c', '--count',
          '--count-matches',
          '--include-zero',
          '--stats',
          '--type-list',
          '-f', '--file',
          '-l', '--files-with-matches',
          '--files-without-match',
          '--files',
          '--debug',
          '--trace',
          '-j', '--threads',
          '-r', '--replace',
          '-H', '--with-filename',
          '-I', '--no-filename',
          '--column', '--no-column',
          '-N', '--no-line-number',
          '-n', '--line-number',
          '--field-match-separator',
          '--field-context-separator',
          '--context-separator',
          '--pcre2-version',
          '--generate',
          '--mmap',
          '--heading',
          '--hostname-bin',
          '--vimgrep',
          '--hyperlink-format'
        }
      }
    },
  },
})
```

### Displaying Ripgrep as a Source

If you want to [customize the menu appearance](https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#basic-customisations) to show Ripgrep as the source, then you might have the following code:

```lua
local cmp = require('cmp')
cmp.setup {
  formatting = {
    format = function(entry, vim_item)
      -- Kind icons
      vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
      -- Source
      vim_item.menu = ({
        -- 👇 Show Ripgrep source
        ripgrep = "[Ripgrep]",
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        luasnip = "[LuaSnip]",
        nvim_lua = "[Lua]",
        latex_symbols = "[LaTeX]",
      })[entry.source.name]
      return vim_item
    end
  },
}
```

### Excluding global Snippets

If you use rafamadriz/friendly-snippets, then exclude [global snippets](https://github.com/rafamadriz/friendly-snippets/blob/main/snippets/global.json) such as time and timeHMS since they show up in the live grep args prompt:
```lua
-- sample lazy.nvim configurationg
{
  'L3MON4D3/LuaSnip',
  dependencies = { 'rafamadriz/friendly-snippets' },
  config = function()
    require('luasnip').config.setup {}
    require("luasnip.loaders.from_vscode").lazy_load({ exclude = 'global' })
  end
}
```

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Related Plugins

* [lukas-reineke/cmp-rg](https://github.com/lukas-reineke/cmp-rg)

