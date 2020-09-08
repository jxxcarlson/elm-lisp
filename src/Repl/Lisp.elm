module Repl.Lisp exposing (helpText, transform)

import Lisp2


transform : String -> String
transform input_ =
    let
        input =
            String.trim input_
    in
    Lisp2.evalToString input



-- HELP TEXT


helpText =
    """Commands:

    Just type an expression, e.g,

        (+ 1 2)

    to have it evaluated.
"""
