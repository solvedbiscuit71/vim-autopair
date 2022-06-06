# vim-autopair

The simplest implementation of auto completing quotes and brackets.

## Installation

- Vim-Plug  
    `Plug 'solvedbiscuit71/vim-autopair'`
- Packer  
    `use 'solvedbiscuit71/vim-autopair'`
- Use other plugin manager

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
        
### Support for html tags

This plugin also supports auto closing tags for html which only in HTML files.

* `>` triggers auto closing
* `/` triggers auto closing as single tag i.e `<br/>`