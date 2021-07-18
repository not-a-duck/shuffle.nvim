local defaults = {}

defaults.separator = " "
defaults.gveq = true

-- Window options
defaults.window_width = 30
defaults.window_height = 50
defaults.window_opacity = 30
defaults.window_style = 'minimal'
defaults.window_border = 'none'
defaults.window_relative = 'cursor'
defaults.window_col = vim.api.nvim_win_get_width(0) - defaults.window_width - 1
defaults.window_row = 1

return defaults
