if !has('nvim')
    finish
endif

command! -nargs=* Reverse lua require'shuffle'.Reverse(<f-args>)
command! -nargs=* Shuffle lua require'shuffle'.Shuffle(<f-args>)

command! -nargs=* -range ShuffleVis lua require'shuffle'.ShuffleVis(<f-args>)
