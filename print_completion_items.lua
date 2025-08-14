---@brief [[
---Print completion items as JSON to stdout.
---
---The following steps are performed:
---    1. Generate ripgrep's man page via `rg --generate man` command.
---    2. Convert ripgrep's man page to Markdown via `pandoc`.
---    3. Parse the Markdown output.
---
---To execute this script, run:
---
--->
---    nvim --clean --headless -l print_completion_items.lua
---<
---
---@brief ]]
local version_cmds = { 'nvim --version', 'rg -V', 'pandoc -v' }

local versions = {}
for _, cmd in ipairs(version_cmds) do
  local version = vim.split(vim.fn.system(cmd), '\n')[1]
  if vim.v.shell_error ~= 0 then
    print(cmd .. ' is required on PATH.')
    os.exit(1)
  end
  table.insert(versions, version)
end

local output = vim.fn.system("rg --generate man | pandoc --from man --to markdown")

local lines = vim.split(output, '\n')

local completion_items = {}

-- Track some mutable state during the loop
local insideOptionsSection = false
local flags = {}
local documentation = ''

local function insert_completion_items()
  if documentation then
    for _, flag in ipairs(flags) do
      table.insert(completion_items, {
        label = flag,
        documentation = {
          kind = 'markdown',
          value = documentation
        }
      })
    end
    flags = {}
    documentation = ''
  end
end

for _, line in ipairs(lines) do
  -- Quit after the level 1 section following ## INPUT OPTIONS
  if insideOptionsSection and line:sub(0, 2) == '# ' then
    break
  end
  if line == '## INPUT OPTIONS' then
    insideOptionsSection = true
  end
  if insideOptionsSection then
    local first_char = line:sub(1, 1)
    -- Lines with options start with * as they're strongly emphasized.
    if first_char == '*' then
      insert_completion_items()

      for match in line:gmatch('%-%-?[.a-zA-Z0-9-]+') do
        table.insert(flags, match)
      end

      -- Add flags as first line of documentation.
      documentation = documentation .. line .. '\n\n'
    end

    -- Documentation is in block quotes.
    if first_char == '>' then
      -- Trim block quotes from line
      documentation = documentation .. line:sub(3) .. '\n'
    end
  end
end

-- for the last -V, --version flag
insert_completion_items()

io.stdout:write(vim.json.encode({
  generated_at = vim.fn.strftime("%Y-%m-%dT%H:%M:%S"),
  versions = versions,
  completion_items = completion_items
}))
