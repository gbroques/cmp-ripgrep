# cmp-ripgrep-flags

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
  'gbroques/cmp-ripgrep-flags',
  dependencies = 'hrsh7th/nvim-cmp'
}
```

## Setup

Whether the completion source is enabled, and which flags are available for completion are configurable.

For setup and configuration, see [doc/cmp-ripgrep-flags.txt](./doc/cmp-ripgrep-flags.txt) or `:help cmp-ripgrep-flags`.

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

