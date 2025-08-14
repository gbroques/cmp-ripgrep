---@brief [[
---*cmp-ripgrep-flags*	nvim-cmp completion source for ripgrep flags.
---@brief ]]
local cmp = require('cmp')
local read = require('cmp_ripgrep_flags.read')

local source = {}

local completion_items = read.completion_items()

---@divider =
---
---By default the completion source is available everywhere.
---
---It's recommended to pass a function to the `enabled` option
---to restrict where the completion source provides suggestions.
---
---Additionally, users may customize the `kind`, which is the icon displayed
---to the left of the source on the right-hand side of the completion menu.
---
---Finally, numerous `rg` flags are filtered out from completion by default
---as they break the live_grep_args picker, or aren't very useful.
---
---The default excluded flags may be overridden via the `exclude` option.
---
---The below setup restricts the completion source to the live_grep_args picker,
---and displays the default options for the `kind` and `exclude` options.
--->lua
---  local function is_current_picker_live_grep_args()
---    local bufnr = vim.api.nvim_get_current_buf()
---    local current_picker = require('telescope.actions.state').get_current_picker(bufnr)
---    if current_picker == nil then
---      return false
---    end
---    -- You need to update this if you customize the default prompt_title for the picker.
---    return current_picker and current_picker.prompt_title == 'Live Grep (Args)'
---  end
---  local cmp = require('cmp')
---  cmp.setup({
---    -- Enable completion when picker is live_grep_args, and buffer type is prompt.
---    -- Completion is disabled by default for the prompt buffer type:
---    -- https://github.com/hrsh7th/nvim-cmp/issues/60
---    enabled = function()
---      local is_prompt = vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt'
---      return (is_prompt and is_current_picker_live_grep_args()) or not is_prompt
---    end,
---    sources = {
---      {
---        name = 'ripgrep_flags',
---        option = {
---          -- Only enable the completion source when the current picker is live_grep_args
---          enabled = is_current_picker_live_grep_args,
---
---          -- Default kind that may be removed or overridden.
---          kind = cmp.lsp.CompletionItemKind.Variable,
---
---          -- Exclude flags that break the picker, or are not very useful.
---          -- If you're happy with the following, then you may remove it as it's the default.
---          exclude = {
---            -- INPUT OPTIONS
---            '-f', '--file',
---            -- SEARCH OPTIONS
---            '-v', '--invert-match', -- see http://github.com/nvim-telescope/telescope-live-grep-args.nvim/issues/65
---            '--mmap',
---            '-j', '--threads',
---            -- OUTPUT OPTIONS
---            '-A', '--after-context',
---            '-B', '--before-context',
---            '--color',
---            '--colors',
---            '--column',
---            '-C', '--context',
---            '--context-separator',
---            '--field-context-separator',
---            '--field-match-separator',
---            '--heading',
---            '-h', '--help',
---            '--hostname-bin',
---            '--hyperlink-format',
---            '--include-zero',
---            '-n', '--line-number',
---            '-N', '--no-line-number',
---            '-0', '--null',
---            '--passthru',
---            '-p', '--pretty',
---            '-q', '--quiet',
---            '-r', '--replace',
---            '--vimgrep',
---            '-H', '--with-filename',
---            '-I', '--no-filename',
---            -- OUTPUT MODES
---            '-c', '--count',
---            '--count-matches',
---            '-l', '--files-with-matches',
---            '--files-without-match',
---            '--json', -- see https://github.com/nvim-telescope/telescope-live-grep-args.nvim/issues/4
---            -- LOGGING OPTIONS
---            '--debug',
---            '--stats',
---            '--trace',
---            -- OTHER BEHAVIORS
---            '--files',
---            '--generate',
---            '--type-list',
---            '--pcre2-version',
---            '-V', '--version'
---          }
---        }
---      },
---    },
---  })
---<

---The following fields are the plugin options.
---@class cmp-ripgrep-flags.Option
---@field enable fun(): boolean Return `true` if completion items should be returned or not.
---@field kind lsp.CompletionItemKind Defaults to Variable.
---@field exclude string[] List of flags to exclude from completion items.
local default_option = {
  enabled = function()
    return true
  end,
  kind = cmp.lsp.CompletionItemKind.Variable,
  -- Exclude flags that break the live_grep_args picker, or are not very useful.
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

---@private
---@class cmp-ripgrep-flags.SourceCompletionApiParams : cmp.SourceCompletionApiParams
---@field option cmp-ripgrep-flags.Option
---
---Invoke completion.
---@param params cmp-ripgrep-flags.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
  local option = vim.tbl_extend('force', default_option, params.option)
  if not option.enabled() then
    callback({})
    return
  end
  local filtered_items = {}
  for _, item in ipairs(completion_items) do
    if not vim.tbl_contains(option.exclude, item.label) then
      item.kind = option.kind
      table.insert(filtered_items, item)
    end
  end
  callback(filtered_items)
end

---@private
---Return the keyword pattern for triggering completion.
---@return string
function source:get_keyword_pattern()
  -- See :help pattern-overview
  -- include the . in the character class for rg's -. flag.
  return [[--\=[.a-zA-Z0-9-]\+]]
end

---@private
---Return trigger characters for triggering completion.
function source:get_trigger_characters()
  return { '-' }
end

---@private
---@return string
function source:get_debug_name()
  return 'ripgrep_flags'
end

return source
