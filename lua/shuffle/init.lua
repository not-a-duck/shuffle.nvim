local methods = require'shuffle.methods'

local plugin = {}

-- Expose some methods as public
plugin.Reverse = methods.Reverse
plugin.Shuffle = methods.Shuffle
plugin.ShuffleVis = methods.ShuffleVis
plugin.Setup = methods.Setup

return plugin
