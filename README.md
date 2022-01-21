# vim-autopair

The simplest implementation of the auto completing quotes and brackets.

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
- g:AutoPairCheck

        Default: "[A-Za-z0-9_]"

        Check if the before and after character of the cursor doesn't
        match with the g:AutoPairCheck before expanding the pairs
        
#### Credits

This plugin is highly inspired by [jiangmiao's auto-pairs](https://github.com/jiangmiao/auto-pairs) 
for code references.
