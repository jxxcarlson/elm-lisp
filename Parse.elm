module Parse exposing (AST(..), toAST)

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
toAST : String -> Maybe AST
toAST str =
    case run parse str of
        Ok ast ->
            Just ast

        Err _ ->
            Nothing


parse : Parser AST
parse =
    oneOf [ lazy (\_ -> list), string, integer ]


list : Parser AST
list =
    (succeed identity
        |. symbol "("
        |. spaces
        |= manyWithSpace parse
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
            |. chompWhile (\c -> c /=  ' ' && c /= ')')
        )
        |> map (String.trim >> Str)



-- OPERATORS


operator : Parser AST
operator =
    oneOf [ op "+", op "-", op "*", op "/", op "=", op ">", op "<"]


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
