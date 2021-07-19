# Shuffle

Shuffle lines quickly

**Before**
```
apple banana cherry
```

`:Shuffle 2 3 1`

**After**
```
banana cherry apple
```

#

Also works with custom delimiters, the default delimiter is a space.

**Before**
```
apple,banana,cherry
```

`:Shuffle 2 3 1 ,`

**After**
```
banana,cherry,apple
```

# Visual mode shuffling (VShuffle)

When you want to get it done quickly, select the lines with uppercase `V`, then

**Before**
```
apple : 1
banana : 2
cherry : 3
```

`:VShuffle 3 2 1`

**After**
```
1 : apple
2 : banana
3 : cherry
```

It also allows quick duplication, which will help you produce garbage code at
lightning speed.

**Before**
```
apple
banana
cherry
```

`:VShuffle 1 1`

**After**
```
apple apple
banana banana
cherry cherry
```

# But typing `:VShuffle` is not fast

Personally I have the following keybinds in my nvim configuration. Mapping the
capital letter S to VShuffle and the capital letter X to VReverse. Keybindings
are not enforced, so you will have to set your own.

```vim
vn S :VShuffle<space>
vn X :VReverse<space>
```

## Extra help

There is a small window available that updates as you look around. It can also
be used to specify a temporary delimiter other than the default separator. For
instance `:SShow ,` will both pop-up a little view to preview which index
corresponds to which token, as well as change the temporary delimiter. To
remove the temporary delimiter in favour of the default separator, simply call
`:SHide` once.  The dimensions and positions of the pop-up window may change to
something more favourable over time.

```vim
nn <space>s :SShow<CR>
nn <space>h :SHide<CR>
```

### Setup

Shuffle uses the default `=` to reindent lines it touches.  If you want to
disable this behaviour, just set `gveq` to false in your Lua configuration.
The following is what the configuration looks like with the current defaults.
These defaults can also be seen in [settings.lua](lua/shuffle/settings.lua).

```lua
require('shuffle').setup{
  separator = " ",
  gveq = true,

  -- Options for pop-up window
  window_width = 30
  window_height = 30
  window_opacity = 30
  window_style = 'minimal'
  window_border = 'none'
  window_relative = 'win'
  full_screen = false
  window_col = 1
  window_row = 1
}
```

#
