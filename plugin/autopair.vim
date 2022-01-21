" Vim autopair is the ultimate solution for closing the pairs
" Maintainer: Praveen Perumal <solvedbiscuit71>
" Repository: https://github.com/solvedbiscuit71/vim-autopair

if exists("g:loaded_autopair")
    finish
endif
let g:loaded_autopair = 1

"--------------: Setting Global Variables :---------------

if !exists("g:AutoPairs")
    let g:AutoPairs = { 
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

func! s:BeforeAndAfter()
    let row = getline('.')
    let pos = col('.') - 1

    let before = row[pos-1]
    let after = row[pos]

    return [before, after]
endf

"--------------------: Main Function :--------------------

func! g:AutoPairDelete()
    if !b:enable_autopair
        return "\<BS>"
    endif

    let [before, after] = s:BeforeAndAfter()
    if (has_key(g:AutoPairs,before) && g:AutoPairs[before] == after)
        return "\<BS>\<DELETE>"
    endif

    return "\<BS>"
endf

func! g:AutoPairLoad()
    if exists("b:enable_autopair")
        return
    endif
    let b:enable_autopair = 1

    if g:AutoPairMapBS
        execute 'inoremap <buffer> <silent> <BS> <C-R>=AutoPairDelete()<CR>'
    endif
endf

autocmd BufEnter * :call AutoPairLoad()
