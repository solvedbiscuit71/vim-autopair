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
    \ "brackets" : {"{":"}","(":")","[":"]"},
    \ "quotes" : {"'":"'",'"':'"',"`":"`"}
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

if !exists("g:AutoPairEnableTags")
  let g:AutoPairEnableTags = 1
endif

"--------------------: Utils Function :-------------------

func! s:CurrentPos()
  return [getline('.'), col('.') - 1]
endf

func! s:BeforeAndAfter()
  let [line,pos] = s:CurrentPos()
  return [line[pos-1],line[pos]]
endf

func! s:GetTagName()
  let [line,pos] = s:CurrentPos()
  let beforeLine = line[0:pos-1]
  let name = split('<'.split(beforeLine,'<')[-1],' ')[0]
  if (name == '<')
    return ''
  else
    return split(name,'<')[-1]
  endif
endf

func! s:IsExpansionValidForAfter(key)
  " Check if it's closebracket
  for close in values(g:AutoPairs.brackets)
    if (a:key == close)
      return v:true
    endif
  endfor

  " Check for quotes
  for quote in keys(g:AutoPairs.quotes)
    if (a:key == quote)
      return v:true
    endif
  endfor

  " Check if it's comma
  if (a:key == ",")
    return v:true
  endif

  " Check if it's empty or space or newline
  if (a:key == "" || a:key == " " || a:key == "\n")
    return v:true
  endif

  return v:false
endf

func! s:IsExpansionValidForBefore(key)
  " Check if it's openbracket
  for open in keys(g:AutoPairs.brackets)
    if (a:key == open)
      return v:true
    endif
  endfor

  " Check for quotes
  for quote in keys(g:AutoPairs.quotes)
    if (a:key == quote)
      return v:true
    endif
  endfor

  " Check if it's comma, equal
  if (a:key == "," || a:key == "=")
    return v:true
  endif

  " Check if it's empty or space or newline
  if (a:key == "" || a:key == " " || a:key == "\n")
    return v:true
  endif

  return v:false
endf

func! s:InsertBrackets(key)
  let [before, after] = s:BeforeAndAfter()
  if (s:IsExpansionValidForAfter(after))
    return a:key.g:AutoPairs["brackets"][a:key]."\<ESC>i"
  endif

  return a:key
endf

func! s:InsertQuotes(key)
  let [before,after] = s:BeforeAndAfter()
  let [line,pos] = s:CurrentPos()
  if (before == '\')
    return a:key
  elseif (after == a:key)
    return "\<Right>"
  elseif (line[pos-2:pos-1] == repeat(a:key,2))
    return repeat(a:key,4)."\<ESC>2hi" 
  elseif (s:IsExpansionValidForBefore(before) && s:IsExpansionValidForAfter(after))
    return a:key.g:AutoPairs["quotes"][a:key]."\<ESC>i"
  endif

  return a:key
endf

"--------------------: Main Function :--------------------

func! g:AutoPairInsert(key)
  if (has_key(g:AutoPairs.brackets,a:key))
    return s:InsertBrackets(a:key)
  else
    return s:InsertQuotes(a:key)
  endif
endf

func! g:AutoPairInsertTags()
  let name = s:GetTagName()
  let [before,after] = s:BeforeAndAfter()
  if (before == "/" || name == "" || name[0] == "/" || name[0] == "!")
    return ">"
  elseif (index(g:VoidTags,name) == -1)
    return "></".name.">\<ESC>%i"
  endif

  return ">"
endf

func! g:AutoPairInsertSlash()
  let name = s:GetTagName()
  let [before,after] = s:BeforeAndAfter()
  if (before == "<" || name == "" || name[0] == "/" || name[0] == "!")
    return "/"
  else
    return "/>"
  endif
endf

func! g:AutoPairSkip(key)
  let [before, after] = s:BeforeAndAfter()
  if (after == a:key)
    return "\<Right>"
  endif

  return a:key
endf

func! g:AutoPairDelete()
  let [before, after] = s:BeforeAndAfter()
  if (has_key(g:AutoPairs.brackets,before) && g:AutoPairs.brackets[before] == after)
    return "\<BS>\<DELETE>"
  elseif (has_key(g:AutoPairs.quotes,before) && g:AutoPairs.quotes[before] == after)
    return "\<BS>\<DELETE>"
  endif

  return "\<BS>"
endf

func! g:AutoPairReturn()
  let [before, after] = s:BeforeAndAfter()
  if (has_key(g:AutoPairs.brackets,before) && g:AutoPairs.brackets[before] == after)
    return "\<CR>\<ESC>=ko"
  endif

  if (exists("g:AutoPairEnableTags") && before == ">" && after == "<")
    return "\<CR>\<ESC>=ko"
  endif

  return "\<CR>"
endf

func! g:AutoPairMapPairs()
  for key in keys(g:AutoPairs.brackets)
    execute 'inoremap <buffer> <silent> '.key." <C-R>=AutoPairInsert('".key."')<CR>"
  endfor

  for key in keys(g:AutoPairs.quotes)
    let passed_key = substitute(key,"'","''",'g')
    execute 'inoremap <buffer> <silent> '.key." <C-R>=AutoPairInsert('".passed_key."')<CR>"
  endfor

  " Map } ] ) to skip if it's after
  for value in values(g:AutoPairs.brackets)
    execute 'inoremap <buffer> <silent> '.value." <C-R>=AutoPairSkip('".value."')<CR>"
  endfor
endf

func! g:AutoPairLoad()
  if exists("b:enable_autopair")
    return
  endif
  let b:enable_autopair = 1

  " Map pairs
  call g:AutoPairMapPairs()

  " Map <BS> to remove empty pairs
  if g:AutoPairMapBS
    execute 'inoremap <buffer> <silent> <BS> <C-R>=AutoPairDelete()<CR>'
  endif

  " Map <CR> to create indentation for brackets
  if g:AutoPairMapCR
    execute 'inoremap <buffer> <silent> <CR> <C-R>=AutoPairReturn()<CR>'
  endif
endf

func! g:AutoPairLoadTags()
  if (!g:AutoPairEnableTags || exists("b:enable_tags"))
    return
  endif
  let b:enable_tags = 1

  execute 'inoremap <buffer> <silent> > <C-R>=AutoPairInsertTags()<CR>'
  execute 'inoremap <buffer> <silent> / <C-R>=AutoPairInsertSlash()<CR>'
endf

autocmd BufEnter * :call AutoPairLoad()
autocmd BufEnter *.html :call AutoPairLoadTags()
