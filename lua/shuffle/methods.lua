-- Settings
local settings = require('shuffle.settings')

-- all local variables
----------------------
local methods = {}
local window, buffer, tabpage, config, delimiter

-- all local functions
----------------------

local function echo(msg, highlight)
  local hl = highlight or "Todo"
  vim.cmd(string.format('echohl %s|echo "%s"', hl, msg))
end

local function stringsplit_to_table(str, separator)
  local t = {}
  local k = 1
  for x in string.gmatch(str, "([^"..separator.."]+)") do
    t[k] = x
    k = k + 1
  end
  return t
end

local function reverse_line(str, separator)
  -- reverse a string based on separator
  local t = stringsplit_to_table(str, separator)
  local k = 1
  local n = #t
  while k < n do
    t[k], t[n] = t[n], t[k]
    k = k + 1
    n = n - 1
  end

  return table.concat(t, separator)
end

local function get_range()
  -- Return begin line, end line
  local left_bracket = vim.api.nvim_buf_get_mark(0, "<")
  local right_bracket = vim.api.nvim_buf_get_mark(0, ">")
  local s_line = left_bracket[1]
  local s_column = left_bracket[2]
  local e_line = right_bracket[1]
  local e_column = right_bracket[2]
  return { s_line = s_line, e_line = e_line, s_column = s_column, e_column = e_column }
end

local function create_window()
  if config == nil then
    local width = nil
    local height = nil
    local col = nil
    local row = nil
    if settings.window_full_screen then
      width = vim.api.nvim_win_get_width(0)
      height = vim.api.nvim_win_get_height(0)
      col = 0
      row = 0
    else
      width = settings.window_width
      height = settings.window_height
      col = vim.api.nvim_win_get_width(0) - width - settings.window_col
      row = settings.window_row
    end

    config = {
      style = settings.window_style,
      border = settings.window_border,
      relative = settings.window_relative,
      focusable = false,
      col = col,
      row = row,
      width = width,
      height = height,
    }
  end

  buffer = vim.api.nvim_create_buf(false, true)
  window = vim.api.nvim_open_win(buffer, false, config)
  tabpage = vim.api.nvim_get_current_tabpage()

  vim.api.nvim_buf_set_option(buffer, 'bufhidden', 'wipe')
  vim.api.nvim_win_set_option(window, 'winblend', settings.window_opacity)
end

local function parse_arguments(...)
  -- Parse the separator and order
  local separator = delimiter
  local order = {}
  for _, v in ipairs({ ... }) do
    local index = tonumber(v)
    if index == nil and delimiter == nil then
      -- TODO make it possible to have multi-character separators
      separator = tostring(v)
    else
      table.insert(order, index)
    end
  end

  if delimiter == nil then
    delimiter = separator
  end

  return separator, order
end

-- exported methods
-------------------

function methods.VReverse(...)
  -- any argument will be taken as separator
  local separator, order = parse_arguments(...)
  local s = separator or settings.separator

  local range = get_range()
  if range == nil then
    error("Can not continue without a visual range")
  end

  local s_index = range.s_line - 1
  local e_index = range.e_line
  local lines = vim.api.nvim_buf_get_lines(0, s_index, e_index, false)
  for i, l in ipairs(lines) do
    local r = reverse_line(l, s)
    lines[i] = r
  end
  vim.api.nvim_buf_set_lines(0, s_index, e_index, false, lines)

  if settings.gveq then
    -- TODO Fix this for when people have remapped weird stuff
    vim.api.nvim_input("gv=")
  end
end

function methods.Reverse(...)
  -- any argument will be taken as separator
  local separator, order = parse_arguments(...)
  local s = separator or settings.separator

  local l = vim.api.nvim_get_current_line()
  local r = reverse_line(l, s)
  vim.api.nvim_set_current_line(r)

  if settings.gveq then
    -- TODO Fix this for when people have remapped weird stuff
    vim.api.nvim_input("=$")
  end
end

function methods.VShuffle(...)
  -- any non-number argument will be taken as separator
  local separator, order = parse_arguments(...)
  local s = separator or settings.separator

  local range = get_range()
  if range == nil then
    error("Can not continue without a visual range")
  end

  -- TODO Potentially
  -- It could be a neat idea to have 'precise' mode active in visual block
  -- selections as well
  -- Current situation: Visual selection on the same line triggers 'precise'
  -- mode, which only uses the visual selection for the split-join (i.e. the
  -- left and right column of the selections are considered when shuffling)
  local precise = (range.s_line == range.e_line) and (range.e_column ~= 2147483647)

  local s_index = range.s_line - 1
  local e_index = range.e_line
  local lines = vim.api.nvim_buf_get_lines(0, s_index, e_index, false)

  if precise then
    for i, line in ipairs(lines) do
      local lvline = string.sub(line, 1, range.s_column)
      local rvline = string.sub(line, range.e_column + 2, #line + 1)
      local vline = string.sub(line, range.s_column + 1, range.e_column + 1)
      local t = stringsplit_to_table(vline, s)
      local y = {}
      for _, index in ipairs(order) do
        table.insert(y, t[index])
      end
      lines[i] = lvline .. table.concat(y, s) .. rvline
    end
  else
    for i, line in ipairs(lines) do
      local t = stringsplit_to_table(line, s)
      local y = {}
      for _, index in ipairs(order) do
        table.insert(y, t[index])
      end
      lines[i] = table.concat(y, s)
    end
  end
  vim.api.nvim_buf_set_lines(0, s_index, e_index, false, lines)

  if settings.gveq then
    -- TODO Fix this for when people have remapped weird stuff
    vim.api.nvim_input("gv=")
  end
end

function methods.Shuffle(...)
  -- any non-number argument will be taken as separator
  local separator, order = parse_arguments(...)
  local s = separator or settings.separator

  local l = vim.api.nvim_get_current_line()
  local t = stringsplit_to_table(l, s)
  local y = {}
  for _, index in ipairs(order) do
    table.insert(y, t[index])
  end

  local yr = table.concat(y, s)
  vim.api.nvim_set_current_line(yr)

  if settings.gveq then
    -- TODO Fix this for when people have remapped weird stuff
    vim.api.nvim_input("=$")
  end
end

function methods.Hide()
  if window then
    vim.cmd("autocmd! DUCKSHUFFLE")
    vim.api.nvim_win_close(window, true)
  end

  -- Turn it off
  window = nil
  config = nil
  tabpage = nil
  buffer = nil
end

-- Visual help showing indices for long strings
-- NOTE Also useful as debug window for quick feedback during development
function methods.Show(...)
  if not (tabpage == vim.api.nvim_get_current_tabpage()) then
    -- We keep track of the tabpage the window was instantiated on, so that we
    -- can start a new window whenever we switch tabs.
    methods.Hide()
  end

  if not window then
    -- Refreshes the window on cursor movement
    vim.cmd([[
    augroup DUCKSHUFFLE
    autocmd!
    autocmd CursorMoved,CursorMovedI * :lua require'shuffle'.Show()
    augroup END
    ]])
    create_window()
  end

  local separator, order = parse_arguments(...)
  local s = separator or settings.separator

  local l = vim.api.nvim_get_current_line()
  local t = stringsplit_to_table(l, s)

  -- index:token pretty formatting
  local r = {}
  for i, e in ipairs(t) do
    r[i] = i .. " : " .. t[i]
    -- table.insert(r, i.." : "..t[i])
  end

  -- NOTE Debug info
  -- r[#r + 1] = "mode : " .. vim.api.nvim_get_mode()["mode"]
  -- local range = get_range()
  -- if range ~= nil then
  --   r[#r + 1] = "range.s_line : " .. range.s_line
  --   r[#r + 1] = "range.e_line : " .. range.e_line
  --   r[#r + 1] = "range.s_column : " .. range.s_column
  --   r[#r + 1] = "range.e_column : " .. range.e_column
  -- end

  -- Update buffer contents
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, r)

  -- Update window position (only when relative='cursor')
  -- vim.api.nvim_win_set_config( window, config )
end

function methods.ResetDelimiter()
  delimiter = nil
end

function methods.Setup(update)
  settings = setmetatable(update, { __index = settings })
end

return methods
