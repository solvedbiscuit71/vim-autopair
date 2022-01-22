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

if !exists("g:VoidTags")
    let g:VoidTags = [
        \ "area",
        \ "base",
        \ "br",
        \ "col",
        \ "command",
        \ "embed",
        \ "hr",
        \ "img",
        \ "input",
        \ "keygen",
        \ "link",
        \ "meta",
        \ "param",
        \ "source",
        \ "track",
        \ "wbr"
        \ ]
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

if !exists("g:AutoPairEnableTags")
    let g:AutoPairEnableTags = 1
endif

"--------------------: Utils Function :-------------------

func! s:BeforeAndAfter()
    let row = getline('.')
    let pos = col('.') - 1

    let before = row[pos-1]
    let after = row[pos]

    return [before, after]
endf

func! s:CurrentPos()
    return [getline('.'), col('.') - 1]
endf

func! s:GetTagName()
    let [line,pos] = s:CurrentPos()
    let beforeLine = line[0:pos-1]
    let name = split(split(beforeLine,'<')[-1],' ')[0]
    return name
endf

"--------------------: Main Function :--------------------

" pairs don't expand when after is either alphabet, number, underscore ( default)
" for quotes the same holds for before. whereas brackets is not.

func! g:AutoPairInsert(key)
    let [before, after] = s:BeforeAndAfter()
    let [line, pos] = s:CurrentPos()
    if (a:key == "'" || a:key == '"' || a:key == "`")
        " skip the quotes
        if (before == '\')
            return a:key
        elseif (line[pos-2:pos-1] == repeat(a:key,2))
            return repeat(a:key,4)."\<ESC>2hi" 
        elseif (after == g:AutoPairs[a:key])
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

func! g:AutoPairInsertTag()
    let name = s:GetTagName()
    let [before,after] = s:BeforeAndAfter()
    if (before == "/" || name[0] == "/" || name[0] == "!" || after =~ g:AutoPairCheck)
        return ">"
    elseif (index(g:VoidTags,name) == -1)
        return "></".name.">\<ESC>%i"
    endif

    return ">"
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
    if (has_key(g:AutoPairs,before) && g:AutoPairs[before] == after)
        return "\<CR>\<ESC>=ko"
    endif

    if (exists("b:enable_tags") && before == ">" && after == "<")
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

func! g:AutoPairMapTags()
    if !b:enable_tags
        return
    endif

    execute 'inoremap <buffer> <silent> > <C-R>=AutoPairInsertTag()<CR>'
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

func! g:AutoPairLoadTags()
    if !g:AutoPairEnableTags
        return
    endif

    if exists("b:enable_tags")
        return
    endif
    let b:enable_tags = 1
    call g:AutoPairMapTags()
endf

autocmd BufEnter * :call AutoPairLoad()
autocmd BufEnter *.html :call AutoPairLoadTags()
