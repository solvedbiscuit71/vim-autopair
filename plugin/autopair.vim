" Vim autopair is the ultimate solution for closing the pairs
" Maintainer: Praveen Perumal <solvedbiscuit71>
" Repository: https://github.com/solvedbiscuit71/vim-autopair

if exists("g:loaded_autopair")
    finish
endif
let g:loaded_autopair = 1

"--------------: Setting Global Variables :---------------

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

if !exists("g:AutoPairMapBS")
    let g:AutoPairMapBS = 1
endif

"--------------------: Utils Function :-------------------


"--------------------: Main Function :--------------------

function! g:AutoPairDelete()
    if !b:enable_autopair
        return "\<BS>"
    endif

    return "\<BS>"
endfunction

function! g:LoadAutoPair()
    if exists("b:enable_autopair")
        return
    endif
    let b:enable_autopair = 1

    if g:AutoPairMapBS
        execute 'inoremap <buffer> <silent> <BS> <C-R>=AutoPairDelete()<CR>'
    endif
endfunction

autocmd BufEnter * :call LoadAutoPair()
