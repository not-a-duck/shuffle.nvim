local methods = require('shuffle.methods')

local plugin = {
  -- Expose some methods as public
  Shuffle = methods.Shuffle,
  VShuffle = methods.VShuffle,
  WindowToggle = methods.WindowToggle,
  Update = methods.Update,
  ResetDelimiter = methods.ResetDelimiter,
  setup = methods.Setup,
}

return plugin
