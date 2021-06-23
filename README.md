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

### Note

May be very buggy, I do not aspire to work on this much.  It was mostly
to explore Lua integration in nvim while making something easy but not
too useless.

#
