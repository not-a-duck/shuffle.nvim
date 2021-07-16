local methods = require'shuffle.methods'

local plugin = {}

-- Expose some methods as public
plugin.Reverse = methods.Reverse
plugin.Shuffle = methods.Shuffle
plugin.VShuffle = methods.VShuffle
plugin.Setup = methods.Setup

return plugin
