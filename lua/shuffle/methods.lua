local defaults = require'shuffle.settings'

local methods = {}

-- all local functions
----------------------

local function echo(msg, highlight)
  highlight = highlight or "Todo"
  vim.cmd(string.format('echohl %s|echo "%s"', highlight, msg))
end

local function stringsplit_to_table(string, separator)
  t = {}
  k = 1
  for x in string.gmatch(string, "([^"..separator.."]+)") do
    t[k] = x
    k = k + 1
  end
  return t
end

local function reverse_line(string, separator)
  -- reverse a string based on separator
  t = stringsplit_to_table(string, separator)
  k = 1
  n = #t
  while k < n do
    t[k], t[n] = t[n], t[k]
    k = k + 1
    n = n - 1
  end

  return table.concat(t, separator)
end

function get_range()
  -- Return begin line, end line iff visual mode
  -- TODO visual block mode seems to not register as visual mode
  -- local mode = vim.api.nvim_get_mode()["mode"]
  local s_line = vim.api.nvim_buf_get_mark(0, "<")[1]
  local e_line = vim.api.nvim_buf_get_mark(0, ">")[1]
  return { s_line = s_line, e_line = e_line }
end

-- exported methods
-------------------

function methods.Reverse(...)
  -- any argument will be taken as separator
  local separator = nil
  for _, v in ipairs({ ... }) do
    separator = tostring(v)
  end
  s = separator or methods.settings.separator

  -- TODO visual selection multi-line mode (see VShuffle)
  local l = vim.api.nvim_get_current_line()
  local r = reverse_line(l, s)
  vim.api.nvim_set_current_line(r)
end

function methods.VShuffle(...)
  -- any non-number argument will be taken as separator
  local separator = nil
  local order = {}
  for _, v in ipairs({ ... }) do
    index = tonumber(v)
    if index == nil then
      separator = tostring(v)
    else
      table.insert(order, index)
    end
  end
  s = separator or methods.settings.separator

  local range = get_range()
  if range == nil then
    error("Can not continue")
  end

  -- Loop from range.s_line to range.e_line
  local c_line = range.s_line
  while c_line <= range.e_line do
    vim.api.nvim_win_set_cursor(0, {c_line, 0})

    local l = vim.api.nvim_get_current_line()
    local t = stringsplit_to_table(l, s)
    local y = {}
    for _, index in ipairs(order) do
      table.insert(y, t[index])
    end

    yr = table.concat(y, s)
    vim.api.nvim_set_current_line(yr)

    c_line = c_line + 1
  end
end

function methods.Shuffle(...)
  -- any non-number argument will be taken as separator
  local separator = nil
  local order = {}
  for _, v in ipairs({ ... }) do
    index = tonumber(v)
    if index == nil then
      separator = tostring(v)
    else
      table.insert(order, index)
    end
  end
  s = separator or methods.settings.separator

  local l = vim.api.nvim_get_current_line()
  local t = stringsplit_to_table(l, s)
  local y = {}
  for _, index in ipairs(order) do
    table.insert(y, t[index])
  end

  yr = table.concat(y, s)
  vim.api.nvim_set_current_line(yr)
end

-- Settings
methods.settings = defaults

function methods.Setup(settings)
  methods.settings = setmetatable(settings, {__index = defaults})
end

return methods
