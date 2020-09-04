module Parse exposing (AST(..), integer, list, parse, string)

{-

   Parse a string of Lisp text, return Just AST if it is lega, Nothing if not.

-}

import Parser exposing (..)
import ParserHelpers exposing (..)


type AST
    = Str String
    | Num Int
    | LIST (List AST)


{-|

    > toAST "(* 2 (+ 3 4))"
    Just (LIST [Str "*",Num 2,LIST [Str "+",Num 3,Num 4]])

-}
parse : String -> Maybe AST
parse str =
    case run parser str of
        Ok ast ->
            Just ast

        Err _ ->
            Nothing


parser : Parser AST
parser =
    oneOf [ lazy (\_ -> list), string, integer ]


list : Parser AST
list =
    (succeed identity
        |. symbol "("
        |. spaces
        |= many parser
        |. spaces
        |. symbol ")"
        |. spaces
    )
        |> map LIST



-- STRING


string : Parser AST
string =
    oneOf [ operator, string_ ]


string_ : Parser AST
string_ =
    getChompedString
        (succeed ()
            |. chompIf (\c -> Char.isAlpha c)
            -- |. chompIf (\c -> not (Char.isDigit c))
            |. chompWhile (\c -> c /= ' ' && c /= ')')
        )
        |> map (String.trim >> Str)



-- OPERATORS


operator : Parser AST
operator =
    oneOf [ op "+", op "-", op "*", op "/", op "=", op ">", op "<" ]


op : String -> Parser AST
op opName =
    (succeed opName
        |. symbol opName
    )
        |> map Str



-- INTEGER


integer : Parser AST
integer =
    (succeed identity
        |= int
    )
        |> map Num
