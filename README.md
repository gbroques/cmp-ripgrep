# cmp-ripgrep-flags

[nvim-cmp](https://github.com/hrsh7th/nvim-cmp) completion source for [ripgrep](https://github.com/BurntSushi/ripgrep) flags.

Documentation for each flag is derived from [ripgrep's man page](https://man.archlinux.org/man/rg.1).

> [!WARNING]
> Currently experimental until v1.0.0 release.

## Motivation

[telescope-live-grep-args.nvim](https://github.com/nvim-telescope/telescope-live-grep-args.nvim) allows passing flags to the underlying ripgrep (`rg`) command that powers the search.

Adding a completion source for flags allows them to be more discoverable, and aids with memory in case they're forgot.

It could also be useful a completion source for a more raw `:Rg` command from plugins such as [duane9/nvim-rg](https://github.com/duane9/nvim-rg).

https://github.com/user-attachments/assets/d2ae029c-fd7f-455d-bd9d-24311fccd417

## Installation

If you use [lazy.nvim](https://github.com/folke/lazy.nvim) as your plugin manager:
```lua
{
  'gbroques/cmp-ripgrep-flags',
  dependencies = 'hrsh7th/nvim-cmp'
}
```

## Setup & Configuration

By default the completion source is available everywhere.

It's recommended to pass a function to the `enabled` option
to restrict where the completion source provides suggestions.

Additionally, users may customize the `kind`, which is the icon displayed
to the left of the source on the right-hand side of the completion menu.

Finally, numerous `rg` flags are filtered out from completion by default
as they break the live_grep_args picker, or aren't very useful.

The default excluded flags may be overridden via the `exclude` option.

The below setup restricts the completion source to the live_grep_args picker,
and displays the default options for the `kind` and `exclude` options.

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
local cmp = require('cmp')
cmp.setup({
  -- Enable completion when picker is live_grep_args, and buffer type is prompt.
  -- Completion is disabled by default for the prompt buffer type.
  -- See https://github.com/hrsh7th/nvim-cmp/issues/60
  enabled = function()
    local is_prompt = vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt'
    return (is_prompt and is_current_picker_live_grep_args()) or not is_prompt
  end,
  sources = {
    {
      name = 'ripgrep_flags',
      option = {
        -- Only enable the completion source when the current picker is live_grep_args
        enabled = is_current_picker_live_grep_args,

        -- Default kind that may be removed or overridden.
        kind = cmp.lsp.CompletionItemKind.Variable,

        -- Exclude flags that break the picker, or are not very useful.
        -- If you're happy with the following, then you may remove it as it's the default.
        exclude = {
          -- INPUT OPTIONS
          '-f', '--file',
          -- SEARCH OPTIONS
          '-v', '--invert-match', -- see http://github.com/nvim-telescope/telescope-live-grep-args.nvim/issues/65
          '--mmap',
          '-j', '--threads',
          -- OUTPUT OPTIONS
          '-A', '--after-context',
          '-B', '--before-context',
          '--color',
          '--colors',
          '--column',
          '-C', '--context',
          '--context-separator',
          '--field-context-separator',
          '--field-match-separator',
          '--heading',
          '-h', '--help',
          '--hostname-bin',
          '--hyperlink-format',
          '--include-zero',
          '-n', '--line-number',
          '-N', '--no-line-number',
          '-0', '--null',
          '--passthru',
          '-p', '--pretty',
          '-q', '--quiet',
          '-r', '--replace',
          '--vimgrep',
          '-H', '--with-filename',
          '-I', '--no-filename',
          -- OUTPUT MODES
          '-c', '--count',
          '--count-matches',
          '-l', '--files-with-matches',
          '--files-without-match',
          '--json', -- see https://github.com/nvim-telescope/telescope-live-grep-args.nvim/issues/4
          -- LOGGING OPTIONS
          '--debug',
          '--stats',
          '--trace',
          -- OTHER BEHAVIORS
          '--files',
          '--generate',
          '--type-list',
          '--pcre2-version',
          '-V', '--version'
        }
      }
    },
  },
})
```

## Additional Configuration

The following is additional suggested configuration.

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
        ripgrep_flags = "[Ripgrep]",
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

### Excluding Global Snippets

If you use [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets), then exclude [global snippets](https://github.com/rafamadriz/friendly-snippets/blob/main/snippets/global.json) such as time and timeHMS since they show up in the live grep args prompt:
```lua
-- sample lazy.nvim configuration
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

