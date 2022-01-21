" vim-autopair is the simplest implementation of auto completing quotes and brackets
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

if !exists("g:AutoPairMapCR")
    let g:AutoPairMapCR = 1
endif

if !exists("g:AutoPairCheck")
    let g:AutoPairCheck = "[A-Za-z0-9_]"
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

" pairs don't expand when after is either alphabet, number, underscore ( default)
" for quotes the same holds for before. whereas brackets is not.

func! g:AutoPairInsert(key)
    let [before, after] = s:BeforeAndAfter()
    if (a:key == "'" || a:key == '"' || a:key == "`")
        " skip the quotes
        if (after == g:AutoPairs[a:key])
            return "\<Right>"
        elseif (after =~ g:AutoPairCheck || before =~ g:AutoPairCheck)
            return a:key
        endif
    else
        if (after =~ g:AutoPairCheck)
            return a:key
        endif
    endif

    return a:key.g:AutoPairs[a:key]."\<ESC>i"
endf

func! g:AutoPairSkip(key)
    let [before, after] = s:BeforeAndAfter()
    if (after == a:key)
        return "\<Right>"
    endif

    return a:key
endf

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

func! g:AutoPairReturn()
    if !b:enable_autopair
        return "\<CR>"
    endif

    let [before, after] = s:BeforeAndAfter()
    if (has_key(g:AutoPairs,before) && g:AutoPairs[before] == after && ( before == "{" || before == "(" || before == "["))
        return "\<CR>\<ESC>=ko"
    endif

    return "\<CR>"
endf

func! g:AutoPairMapPairs()
    if !b:enable_autopair
        return
    endif

    for key in keys(g:AutoPairs)
        " To avoid the collision of single-quotes 
        let correct_key = substitute(key,"'","''",'g')
        execute 'inoremap <buffer> <silent> '.key." <C-R>=AutoPairInsert('".correct_key."')<CR>"
    endfor

    for value in values(g:AutoPairs)
        if (value == '}' || value == ')' || value == ']')
            execute 'inoremap <buffer> <silent> '.value." <C-R>=AutoPairSkip('".value."')<CR>"
        endif
    endfor
endf

func! g:AutoPairLoad()
    if exists("b:enable_autopair")
        return
    endif
    let b:enable_autopair = 1
    call g:AutoPairMapPairs()

    if g:AutoPairMapBS
        execute 'inoremap <buffer> <silent> <BS> <C-R>=AutoPairDelete()<CR>'
    endif

    if g:AutoPairMapCR
        execute 'inoremap <buffer> <silent> <CR> <C-R>=AutoPairReturn()<CR>'
    endif
endf

autocmd BufEnter * :call AutoPairLoad()
