---@brief [[
---@private
---
---Module for reading completion_items.json into memory as a Lua table.
---
---completion_items.json is generated. See CONTRIBUTING.md for details.
---
---@brief ]]
local M = {}

function M.completion_items()
  local completion_items = {}
  local script_path = M._get_script_path()
  local file = io.open(M._join_path(script_path, 'completion_items.json'), 'r')
  if file then
    local content = file:read('*a') -- *a reads the whole file
    completion_items = vim.json.decode(content).completion_items
    file:close()
  else
    print('Error: Could not open completion_items.json')
  end
  return completion_items
end

-- copied from https://www.reddit.com/r/neovim/comments/tk1hby/comment/i1nipld/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
function M._get_script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  if M._is_windows() then
    str = str:gsub('/', '\\')
  end
  local path_separator = M._get_path_separator()
  return str:match('(.*' .. path_separator .. ')')
end

function M._join_path(...)
  local segments = { ... }
  local path_separator = M._get_path_separator()
  local path = ''
  for i, segment in ipairs(segments) do
    if i == 1 then -- first index starts at 1 in lua
      path = segment
    else
      path = path .. path_separator .. segment
    end
  end
  return path
end

function M._get_path_separator()
  return M._is_windows() and '\\' or '/'
end

function M._is_windows()
  return package.config:sub(1, 1) == '\\'
end

return M
