" vim-autopair is the simplest implementation of auto completing quotes and brackets
" Maintainer: Praveen Perumal <solvedbiscuit71>
" Repository: https://github.com/solvedbiscuit71/vim-autopair

if exists("g:loaded_autopair")
    finish
endif
let g:loaded_autopair = 1

"--------------: Setting Global Variables :---------------

if !exists("s:AutoPairs")
  let s:AutoPairs = {
    \ "brackets" : {"{":"}","(":")","[":"]"},
    \ "quotes" : {"'":"'",'"':'"',"`":"`"}
    \ }
endif

if !exists("s:VoidTags")
  let s:VoidTags = [
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

"--------------------: Utils Function :-------------------

func! s:CurrentPos()
  return [getline('.'), col('.') - 1]
endf

func! s:BeforeAndAfter()
  let [line,pos] = s:CurrentPos()
  return [line[pos-1],line[pos]]
endf

" GetTagName -> return [tagname, no_of_attributes]
func! s:GetTagName()
  let [line,pos] = s:CurrentPos()

  " Skip if '<' not present in the current line
  if (count(line,"<") == 0)
    return ['',0]
  endif

  " Skip if '>' present in the beforeLine"
  let beforeLine = split(line[0:pos-1],'<')[-1]
  if (count(beforeLine,">") != 0)
    return ['',0]
  endif

  let attributes = split('<'.beforeLine,' ')
  let name = attributes[0]
  if (name == '<')
    return ['',0]
  else
    return [split(name,'<')[-1],len(attributes)-1]
  endif
endf

func! s:IsExpansionValidForAfter(key)
  " Check if it's closebracket
  for close in values(s:AutoPairs.brackets)
    if (a:key == close)
      return v:true
    endif
  endfor

  " Check for quotes
  for quote in keys(s:AutoPairs.quotes)
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
  for open in keys(s:AutoPairs.brackets)
    if (a:key == open)
      return v:true
    endif
  endfor

  " Check for quotes
  for quote in keys(s:AutoPairs.quotes)
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
    return a:key.s:AutoPairs["brackets"][a:key]."\<ESC>i"
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
    return a:key.s:AutoPairs["quotes"][a:key]."\<ESC>i"
  endif

  return a:key
endf

"--------------------: Main Function :--------------------

func! s:AutoPairInsert(key)
  if (has_key(s:AutoPairs.brackets,a:key))
    return s:InsertBrackets(a:key)
  else
    return s:InsertQuotes(a:key)
  endif
endf

func! s:AutoPairInsertTags()
  let [name,attributes] = s:GetTagName()
  let [before,after] = s:BeforeAndAfter()
  if (before == "/" || name == "" || name[0] == "/" || name[0] == "!")
    return ">"
  elseif (index(s:VoidTags,name) == -1)
    return "></".name.">\<ESC>%i"
  endif

  return ">"
endf

func! s:AutoPairInsertSlash()
  let [before,after] = s:BeforeAndAfter()
  if (before == "<")
    return "/"
  endif

  let [name,attributes] = s:GetTagName()
  if (name == "")
    return "/"
  elseif (((before == name[strlen(name)-1] && attributes == 0)  || before == " " || before == "'" || before == '"' ) && after == "")
    return "/>"
  else
    return "/"
  endif
endf

func! s:AutoPairSkip(key)
  let [before, after] = s:BeforeAndAfter()
  if (after == a:key)
    return "\<Right>"
  endif

  return a:key
endf

func! s:AutoPairDelete()
  let [before, after] = s:BeforeAndAfter()
  if (has_key(s:AutoPairs.brackets,before) && s:AutoPairs.brackets[before] == after)
    return "\<BS>\<DELETE>"
  elseif (has_key(s:AutoPairs.quotes,before) && s:AutoPairs.quotes[before] == after)
    return "\<BS>\<DELETE>"
  endif

  return "\<BS>"
endf

func! s:AutoPairReturn()
  let [before, after] = s:BeforeAndAfter()
  if (has_key(s:AutoPairs.brackets,before) && s:AutoPairs.brackets[before] == after)
    return "\<CR>\<ESC>=ko"
  endif

  if (exists("g:AutoPairEnableTags") && before == ">" && after == "<")
    return "\<CR>\<ESC>=ko"
  endif

  return "\<CR>"
endf

func! s:AutoPairMapPairs()
  for key in keys(s:AutoPairs.brackets)
    execute 'inoremap <buffer> <silent> '.key." <C-R>=<SID>AutoPairInsert('".key."')<CR>"
  endfor

  for key in keys(s:AutoPairs.quotes)
    let passed_key = substitute(key,"'","''",'g')
    execute 'inoremap <buffer> <silent> '.key." <C-R>=<SID>AutoPairInsert('".passed_key."')<CR>"
  endfor

  " Map } ] ) to skip if it's after
  for value in values(s:AutoPairs.brackets)
    execute 'inoremap <buffer> <silent> '.value." <C-R>=<SID>AutoPairSkip('".value."')<CR>"
  endfor
endf

"--------------------: Loading Plugin :-------------------

func! s:AutoPairLoad()
  call s:AutoPairMapPairs()

  execute 'inoremap <buffer> <silent> <BS> <C-R>=<SID>AutoPairDelete()<CR>'
  execute 'inoremap <buffer> <silent> <CR> <C-R>=<SID>AutoPairReturn()<CR>'
endf

func! s:AutoPairLoadTags()
  execute 'inoremap <buffer> <silent> > <C-R>=<SID>AutoPairInsertTags()<CR>'
  execute 'inoremap <buffer> <silent> / <C-R>=<SID>AutoPairInsertSlash()<CR>'
endf

autocmd BufEnter * :call <SID>AutoPairLoad()
autocmd BufEnter *.html :call <SID>AutoPairLoadTags()
