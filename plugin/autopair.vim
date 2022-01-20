" Vim autopair is the ultimate solution for closing the pairs
" Maintainer: Praveen Perumal <solvedbiscuit71>
" Repository: https://github.com/solvedbiscuit71/vim-autopair

" Check if plugin already loaded
if exists("g:loaded_autopair")
    finish
endif
let g:loaded_autopair = 1

if !exists("g:autopairs")
    let g:autopairs = { 
        \ "{" : "}",
        \ "[" : "]",
        \ "(" : ")",
        \ '"' : '"',
        \ "'" : "'",
        \ "`" : "`"
        \ }
endif
