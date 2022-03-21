if !has('nvim')
  finish
endif

command! -nargs=* Shuffle lua require'shuffle'.Shuffle(<f-args>)
command! -nargs=* -range VShuffle lua require'shuffle'.VShuffle(<f-args>)

command! -nargs=* ShuffleWindowToggle lua require'shuffle'.WindowToggle(<f-args>)
command! -nargs=* ShuffleResetSeparator lua require'shuffle'.ResetSeparator(<f-args>)
