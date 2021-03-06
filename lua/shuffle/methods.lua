-- Settings
local settings = require('shuffle.settings')

-- all local variables
----------------------
local methods = {}

-- same but tables of them
local tabpages = {}

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

local function get_range()
  -- Return begin line, end line
  local left_bracket = vim.api.nvim_buf_get_mark(0, "<")
  local right_bracket = vim.api.nvim_buf_get_mark(0, ">")
  local s_line = left_bracket[1]
  local s_column = left_bracket[2]
  local e_line = right_bracket[1]
  local e_column = right_bracket[2]
  return {
    s_line = s_line,
    e_line = e_line,
    s_column = s_column,
    e_column = e_column,
  }
end

local function create_tabpage(window, buffer, config)
  local tabpage = vim.api.nvim_get_current_tabpage()
  tabpages[tabpage] = {
    ['window'] = window,
    ['buffer'] = buffer,
    ['config'] = config,
    ['separator'] = settings.separator,
  }
  return tabpage
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

  local buffer = vim.api.nvim_create_buf(false, true)
  local window = vim.api.nvim_open_win(buffer, false, config)
  local tabpage = create_tabpage(window, buffer, config)

  vim.api.nvim_buf_set_option(buffer, 'bufhidden', 'wipe')
  vim.api.nvim_win_set_option(window, 'winblend', settings.window_opacity)
end

local function get_current_tab()
  local tabpage = vim.api.nvim_get_current_tabpage()
  if tabpages[tabpage] == nil then
    create_tabpage(nil, nil, nil)
  end
  return tabpages[tabpage]
end

local function destroy_window()
  local tab = get_current_tab()
  local window = tab['window']
  if window == nil then
    error("Window should not be nil here")
  end
  vim.api.nvim_win_close(window, true)
  tab['window'] = nil
  tab['buffer'] = nil
  tab['config'] = nil
end

local function parse_arguments(...)
  local separator = nil

  -- Parse the separator and order
  local order = {}
  for _, v in ipairs({ ... }) do
    local index = tonumber(v)
    if index == nil then
      separator = tostring(v)
    else
      table.insert(order, index)
    end
  end

  return separator, order
end

-- exported methods
-------------------

function methods.VShuffle(...)
  -- any non-number argument will be taken as separator
  local s, order = parse_arguments(...)
  local tab = get_current_tab()
  s = s or tab['separator']

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
end

function methods.Shuffle(...)
  -- any non-number argument will be taken as separator
  local s, order = parse_arguments(...)
  local tab = get_current_tab()
  s = s or tab['separator']

  local l = vim.api.nvim_get_current_line()
  local t = stringsplit_to_table(l, s)
  local y = {}
  for _, index in ipairs(order) do
    table.insert(y, t[index])
  end

  local yr = table.concat(y, s)
  vim.api.nvim_set_current_line(yr)
end

function methods.Update()
  local tab = get_current_tab()
  local window = tab['window']
  local buffer = tab['buffer']

  if window == nil then
    return
  end

  local s = tab['separator'] or settings.separator
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
end

function methods.WindowToggle(...)
  local tab = get_current_tab()
  if tab['window'] == nil then
    create_window()
    vim.cmd([[
    augroup DUCKSHUFFLE
    autocmd!
    autocmd CursorMoved,CursorMovedI * :lua require'shuffle'.Update()
    augroup END
    ]])
    methods.Update()
  else
    -- TODO figure out whether it is important to remove the autocmd ...
    -- vim.cmd("autocmd! DUCKSHUFFLE")
    destroy_window()
  end
end

function methods.ResetSeparator(...)
  local s, order = parse_arguments(...)
  local tab = get_current_tab()

  if s ~= settings.separator then
    tab['separator'] = s
  else
    tab['separator'] = settings.separator
  end
  methods.Update()
end

local function Print(structure, prefix)
  prefix = prefix or "X"
  local s_type = type(structure)
  if (s_type ~= "table") then
    print(prefix .. " = " .. structure .. " (" .. s_type .. ")")
    return
  end
  print(prefix .. " (" .. s_type .. ")")
  for k, v in pairs(structure) do
    Print(v, prefix .. "[" .. tostring(k) .. "]")
  end
end

local function Update(T, U)
  if type(T) ~= "table" or type(U) ~= "table" then
    Print(T, "defaults")
    Print(U, "update")
    error("Invalid types given in Update(T, U) (see above)!")
  end
  for k, v in pairs(U) do
    c = T[k]
    if c == nil then
      error("Update was unsuccessful, because key ??" .. tostring(k) .. "?? is invalid!")
    end
    if type(c) == "table" then
      Update(c, v)
    else
      T[k] = v
    end
  end
end

function methods.Setup(update)
  update = update or {}
  Update(settings, update)
end

return methods
