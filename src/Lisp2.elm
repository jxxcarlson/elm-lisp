module Lisp2 exposing (eval)

import List.Extra
import Maybe.Extra
import Parse exposing (AST(..), parse)


type Value
    = VStr String
    | VNum Int
    | VBool Bool
    | VList (List Value)
    | Undefined


eval : String -> Maybe Value
eval str =
    str |> parse |> Maybe.map evalAst


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
                    List.map (evalAst >> unWrapVnum) (List.drop 1 list)
                        |> Maybe.Extra.combine
                        |> Maybe.map List.sum
                        |> wrapVnum

                Just (Str "-") ->
                    if List.length list > 3 then
                        -- Too many args
                        Undefined

                    else if List.length list < 2 then
                        -- No args
                        Undefined

                    else if List.length list == 2 then
                        -- Unary minus
                        Maybe.map (\x -> -x) (getNumArg 1 list) |> wrapVnum

                    else
                        -- Binary minus
                        Maybe.map2 (-) (getNumArg 1 list) (getNumArg 2 list) |> wrapVnum

                Just (Str "/") ->
                    Maybe.map2 (//) (getNumArg 1 list) (getNumArg 2 list) |> wrapVnum

                Just (Str "=") ->
                    Maybe.map2 (==) (getNumArg 1 list) (getNumArg 2 list) |> wrapVBool

                Just (Str ">") ->
                    Maybe.map2 (>) (getNumArg 1 list) (getNumArg 2 list) |> wrapVBool

                Just (Str "if") ->
                    case getBoolArg 1 list of
                        Nothing ->
                            Undefined

                        Just True ->
                            List.Extra.getAt 2 list |> Maybe.map evalAst |> extract

                        Just False ->
                            List.Extra.getAt 3 list |> Maybe.map evalAst |> extract

                Just (Str "element") ->
                    case getNumArg 1 list of
                        Nothing ->
                            Undefined

                        Just k ->
                            List.Extra.getAt k (List.drop 2 list) |> Maybe.map evalAst |> extract

                _ ->
                    List.map evalAst list |> VList



-- HELPERS
-- Wrap/Unwrap


unWrapVnum : Value -> Maybe Int
unWrapVnum value =
    case value of
        VNum k ->
            Just k

        _ ->
            Nothing


wrapVnum : Maybe Int -> Value
wrapVnum maybeInt =
    case maybeInt of
        Nothing ->
            Undefined

        Just k ->
            VNum k


unWrapVBool : Value -> Maybe Bool
unWrapVBool value =
    case value of
        VBool b ->
            Just b

        _ ->
            Nothing


wrapVBool : Maybe Bool -> Value
wrapVBool maybeBool =
    case maybeBool of
        Nothing ->
            Undefined

        Just b ->
            VBool b



-- Exract a value


extract : Maybe Value -> Value
extract maybeValue =
    case maybeValue of
        Nothing ->
            Undefined

        Just val ->
            val



-- Args


getNumArg : Int -> List AST -> Maybe Int
getNumArg k list =
    List.Extra.getAt k list |> Maybe.map evalAst |> Maybe.andThen unWrapVnum


getBoolArg : Int -> List AST -> Maybe Bool
getBoolArg k list =
    List.Extra.getAt k list |> Maybe.map evalAst |> Maybe.andThen unWrapVBool



-- Eval


evalBool : (x -> x -> Bool) -> Maybe x -> Maybe x -> Bool
evalBool f a b =
    case ( a, b ) of
        ( Just a_, Just b_ ) ->
            f a_ b_

        _ ->
            False
