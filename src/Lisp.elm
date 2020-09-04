module Lisp exposing (eval)

import List.Extra
import Maybe.Extra
import Parse exposing (AST(..), parse)


type Value
    = VStr String
    | VNum Int
    | VBool Bool
    | VList (List Value)
    | Undefined
    | ParseError


{-|

    > eval "(+ 1 2)"
    VNum 3 : Value

    > eval "(+ 1 a)"
    Undefined : Value

-}
eval : String -> Value
eval str =
    case str |> parse |> Maybe.map evalAst of
        Just val ->
            val

        Nothing ->
            ParseError


evalAst : AST -> Value
evalAst ast =
    case ast of
        Num k ->
            VNum k

        Str s ->
            VStr s

        LIST list ->
            case List.head list of
                Just (Str "+") ->
                    List.map (evalAst >> unWrapVNum) (List.drop 1 list)
                        |> Maybe.Extra.combine
                        |> Maybe.map List.sum
                        |> wrapVNum

                Just (Str "-") ->
                    if List.length list > 3 then
                        -- Too many args
                        Undefined

                    else if List.length list < 2 then
                        -- No args
                        Undefined

                    else if List.length list == 2 then
                        -- Unary minus
                        Maybe.map (\x -> -x) (getNumArg 1 list) |> wrapVNum

                    else
                        -- Binary minus
                        Maybe.map2 (-) (getNumArg 1 list) (getNumArg 2 list) |> wrapVNum

                _ ->
                    List.map evalAst list |> VList



-- HELPERS
-- WRAP/UNWRAP


unWrapVNum : Value -> Maybe Int
unWrapVNum value =
    case value of
        VNum k ->
            Just k

        _ ->
            Nothing


wrapVNum : Maybe Int -> Value
wrapVNum maybeInt =
    case maybeInt of
        Nothing ->
            Undefined

        Just k ->
            VNum k



-- ARGS


getNumArg : Int -> List AST -> Maybe Int
getNumArg k list =
    List.Extra.getAt k list |> Maybe.map evalAst |> Maybe.andThen unWrapVNum
