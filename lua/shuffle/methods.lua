-- Settings
local settings = require('shuffle.settings')

-- all local variables
----------------------
local methods = {}
local window, buffer, tabpage, config, delimiter

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

local function get_range()
  -- Return begin line, end line
  local s_line = vim.api.nvim_buf_get_mark(0, "<")[1]
  local e_line = vim.api.nvim_buf_get_mark(0, ">")[1]
  return { s_line = s_line, e_line = e_line }
end

local function create_window()
  if config == nil then
    if settings.full_screen then
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

-- exported methods
-------------------

function methods.VReverse(...)
  -- any argument will be taken as separator
  local separator = delimiter
  if delimiter == nil then
    for _, v in ipairs({ ... }) do
      separator = tostring(v)
    end
  end
  s = separator or settings.separator

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
    vim.api.nvim_input("gv=")
  end
end

function methods.Reverse(...)
  -- any argument will be taken as separator
  local separator = delimiter
  if delimiter == nil then
    for _, v in ipairs({ ... }) do
      separator = tostring(v)
    end
  end
  s = separator or settings.separator

  local l = vim.api.nvim_get_current_line()
  local r = reverse_line(l, s)
  vim.api.nvim_set_current_line(r)

  if settings.gveq then
    vim.api.nvim_input("norm! =$")
  end
end

function methods.VShuffle(...)
  -- any non-number argument will be taken as separator
  local separator = delimiter
  local order = {}
  for _, v in ipairs({ ... }) do
    index = tonumber(v)
    if index == nil and delimiter == nil then
      separator = tostring(v)
    else
      table.insert(order, index)
    end
  end
  s = separator or settings.separator

  local range = get_range()
  if range == nil then
    error("Can not continue without a visual range")
  end

  local s_index = range.s_line - 1
  local e_index = range.e_line
  local lines = vim.api.nvim_buf_get_lines(0, s_index, e_index, false)
  for i, line in ipairs(lines) do
    local t = stringsplit_to_table(line, s)
    local y = {}
    for _, index in ipairs(order) do
      table.insert(y, t[index])
    end
    lines[i] = table.concat(y, s)
  end
  vim.api.nvim_buf_set_lines(0, s_index, e_index, false, lines)

  if settings.gveq then
    vim.api.nvim_input("gv=")
  end
end

function methods.Shuffle(...)
  -- any non-number argument will be taken as separator
  local separator = nil
  local order = {}
  for _, v in ipairs({ ... }) do
    index = tonumber(v)
    if index == nil and delimiter == nil then
      separator = tostring(v)
    else
      table.insert(order, index)
    end
  end
  s = separator or settings.separator

  local l = vim.api.nvim_get_current_line()
  local t = stringsplit_to_table(l, s)
  local y = {}
  for _, index in ipairs(order) do
    table.insert(y, t[index])
  end

  yr = table.concat(y, s)
  vim.api.nvim_set_current_line(yr)

  if settings.gveq then
    vim.api.nvim_input("norm! =$")
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
  delimiter = nil
end

-- Visual help showing indices for long strings
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

  -- Simply take any (the last argument) separator
  local separator = delimiter

  if delimiter == nil then
    for _, v in ipairs({ ... }) do
      separator = tostring(v)
      delimiter = separator
    end
  end

  s = separator or settings.separator
  local l = vim.api.nvim_get_current_line()
  local t = stringsplit_to_table(l, s)

  -- index:token pretty formatting
  local r = {}
  for i, e in ipairs(t) do
    r[i] = i .. " : " .. t[i]
    -- table.insert(r, i.." : "..t[i])
  end

  -- Update buffer contents
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, r)

  -- Update window position (only when relative='cursor')
  -- vim.api.nvim_win_set_config( window, config )
end

function methods.Setup(update)
  settings = setmetatable(update, { __index = settings })
end

return methods
