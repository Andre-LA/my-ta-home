# ta-love
A textadept module for [love2d](http://love2d.org/) by [Alejandro Baez](https://twitter.com/a_baez).

### DESCRIPTION
The module right now doesn't have much. It has a quick template `module` build
that allows quick setup. The template itself builds a small `oop` with basic
inheritence.

Other than the template build, it also allows for running the love project by
using the build command `keys['cB']` to initiate. Eventually, this module should
have quick shortcut documentation to the love api and maybe autocomplete.

### INSTALL
Clone the repository to your `~/.textadept/modules` directory:

```
cd ~/.textadept/modules
hg clone https://bitbucket.org/a_baez/ta-love love
```

Then copy the `love.lua` lexer file into your `~/.textadept/lexers` directory:

```
cp ~/.textadept/modules/love/love.lua ~/.textadept/lexers/love.lua
```

### USAGE
Any time you want to use the module, you need to change the lexer to the `love`
lexer. You can do this by `Buffer->Select Lexer` or `keys['cL']` and selecting
the `love` lexer.

### KEYBINDINGS

    keys        description
    cL          pick love lexer from list to initiate love module.
    cB          used for runing love from current project.
    can         used to make a new file using the template contained in module.

