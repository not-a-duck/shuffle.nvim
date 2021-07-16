local methods = require'shuffle.methods'

local plugin = {}

-- Expose some methods as public
plugin.Reverse = methods.Reverse
plugin.VReverse = methods.VReverse
plugin.Shuffle = methods.Shuffle
plugin.VShuffle = methods.VShuffle
plugin.setup = methods.Setup

return plugin
