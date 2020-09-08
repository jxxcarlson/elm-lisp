# A Typed Lisp in Elm

The code you find here outlines how one might go about writing
a kind of typed Lisp in Elm — an educational experiment for myself.
The files are

- *Parse.elm*, exporting one type, `AST`, and one function `parse`.
- *ParserHelpers.elm*, exporting one function, `many`, a clip from
  the package [Punie/parser-extras](https://package.elm-lang.org/packages/Punie/elm-parser-extras/latest/).
  The `many` combinator is used in module `Parse`
- *Lisp.elm*, exporting one function, `eval`
- *Lisp2.elm*, a superset of *Lisp.elm*, also exporting `evalToString`

[Medium article on this code](https://medium.com/@jxxcarlson/a-typed-lisp-in-elm-e5c733f63931)

One can evaluate Lisp expressions using `elm-repl` or by using the little node repl program  
described in the last section.

## Using elm-repl  

Examples:

```
$ elm repl

> import Parse exposing(parse)
> import Lisp2 exposing(eval)

> parse "(+ 1 2 3)"
Just (LIST [Str "+",Num 1,Num 2,Num 3])
    : Maybe Parse.AST

> eval "(+ 1 2 3)"
Just (VNum 6) : Maybe Lisp2.Value

> eval "(+ 1 2 haha!)"
Just Undefined : Maybe Lisp2.Value
```

Note that `eval` handles nonsense input in a somewhat graceful way.

## The repl

To use the repl:

```
$ elm make --optimize src/Repl/Main.elm --output=src/Repl/main.js
$ node src/Repl/repl.js
```

This repl program uses the code in `./src/Repl` following the outline
described in the Medium article [Elm as BlackBox](https://medium.com/@jxxcarlson/running-elm-as-a-blackbox-b1930592054b).  One uses the `Platform.Worker` program in `Repl.Main` to communicate with the
terminal via `node.js`.
