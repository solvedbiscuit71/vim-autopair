# vim-autopair

The simplest implementation of auto completing quotes and brackets.

## Installation

- Vim-Plug  
    `Plug 'solvedbiscuit71/vim-autopair'`
- Packer  
    `use 'solvedbiscuit71/vim-autopair'`
- Use other plugin manager

And put this in your .vimrc
`set smartindent`

## Usage

The current content, where `|` is the cursor

```txt
foo|
```

Press the `(` key,

```txt
foo(|)
```

Now, pressing the `)` key will skip it.
```txt
foo()|
```

Now, press the `{` key and press `<CR>` key

```txt
foo(){
    |
}
```

Now, press `"` key the content becomes

```txt
foo(){
    "|"
}
```

Now, pressing the `<BS>` will remove the pairs

```txt
foo(){
    |
}
```

## Option

- g:AutoPairMapCR

        Default: 1
        
        Map <CR> to insert a new indentation in case of brackets
        set to 0 to disable
- g:AutoPairMapBS

        Default: 1
        
        Map <BS> to delete the brackets, quotes together if empty
        set to 0 to disable
        
### Support for html tags

This plugin also supports auto completion for html tags which currently works only in `*.html` files.

- g:AutoPairEnableTags
    
        Default: 1

        Map '>' to trigger a function to auto complete the closing tags.
        Set to 0 to disable
