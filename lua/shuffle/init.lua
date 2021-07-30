local methods = require('shuffle.methods')

local plugin = {
  -- Expose some methods as public
  Reverse = methods.Reverse
  VReverse = methods.VReverse
  Shuffle = methods.Shuffle
  VShuffle = methods.VShuffle
  Show = methods.Show
  Hide = methods.Hide
  setup = methods.Setup
}

return plugin
