# A Typed Lisp in Elm

The code you find here outlines how one might go about writing
a kind of typed Lisp in Elm.  The files are

- *Parse.elm*, exporting one type, `AST`, and one function `parse`.
- *ParserHelpers.elm*, exporting one function, `many`, a clip from
  the package [Punie/parser-extras](https://package.elm-lang.org/packages/Punie/elm-parser-extras/latest/).
  The `many` combinator is used in module `Parse`
- *Lisp.elm*, exporting one function, `eval`
- *Lisp2.elm*, a superset of *Lisp.elm*, also exporting `evalToString`

[Medium article on this code](https://medium.com/@jxxcarlson/a-typed-lisp-in-elm-e5c733f63931)

At present, things are set up to evaluate Lisp expressions with a repl. See notes at end.

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
