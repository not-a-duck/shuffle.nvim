# Shuffle

Shuffle lines quickly

```
apple banana cherry
```

`:Shuffle 2 3 1`

```
banana cherry apple
```

#

Also works with custom delimiters, default delimiter is a space.

```
apple,banana,cherry
```

`:Shuffle 2 3 1 ,`

```
banana,cherry,apple
```

# Visual mode shuffling (VShuffle)

When you want to get it done quickly, select the lines with uppercase `V`, then

```
apple : 1
banana : 2
cherry : 3
```

`:VShuffle 3 2 1`

```
1 : apple
2 : banana
3 : cherry
```

It also allows quick duplication, which will help you produce garbage code at
lightning speed.

```
apple
banana
cherry
```

`:VShuffle 1 1`

```
apple apple
banana banana
cherry cherry
```

### Note

May be buggy, I do not aspire to work on this much.  It was mostly to explore
Lua integration in nvim while making something easy but not too useless.

#
