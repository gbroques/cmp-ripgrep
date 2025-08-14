local cmp = require('cmp')

-- For creating a custom nvim-cmp completion source see :help cmp-develop.
local source = {}

local function is_windows()
  return package.config:sub(1, 1) == '\\'
end

local path_sep = is_windows() and '\\' or '/'

-- copied from https://www.reddit.com/r/neovim/comments/tk1hby/comment/i1nipld/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
local function get_path_to_script()
  local str = debug.getinfo(2, 'S').source:sub(2)
  if is_windows() then
    str = str:gsub('/', '\\')
  end
  return str:match('(.*' .. path_sep .. ')')
end

local completion_items = {}
local script_path = get_path_to_script()
local file = io.open(script_path .. path_sep .. 'completion_items.json', 'r')
if file then
  local content = file:read("*a")
  completion_items = vim.json.decode(content).completion_items
  file:close()
else
  print("Error: Could not open completion_items.json")
end

local default_option = {
  enabled = function()
    return true
  end,
  kind = cmp.lsp.CompletionItemKind.Variable,
  -- exclude flags that break the picker, or are otherwise not useful.
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
    '--column', '--no-column',
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
    '-q', '--quiet',
    '-p', '--pretty',
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

---Invoke completion.
---@param params cmp.SourceCompletionApiParams
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

---Return the keyword pattern for triggering completion.
---@return string
function source:get_keyword_pattern()
  -- See :help pattern-overview
  -- include the . in the character class for rg's -. flag.
  return [[--\=[.a-zA-Z0-9-]\+]]
end

---Return trigger characters for triggering completion.
function source:get_trigger_characters()
  return { '-' }
end

---@return string
function source:get_debug_name()
  return 'ripgrep_flags'
end

return source
