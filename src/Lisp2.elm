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

                Just (Str "/") ->
                    Maybe.map2 (//) (getNumArg 1 list) (getNumArg 2 list) |> wrapVNum

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
    List.Extra.getAt k list |> Maybe.map evalAst |> Maybe.andThen unWrapVNum


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

-- ????

module Lisp exposing (eval, evalAst, getItem, unwrapList)

import List.Extra
import Maybe.Extra
import Parse exposing (AST(..), parse)


type Value
    = VStr String
    | VNum Int
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



{-|

    > ast = parse "(abc 2 3)"
    Just (LIST [Str "abc",Num 2,Num 3])
        : Maybe Parse.AST

    > Maybe.andThen (getItem 0) ast
    Just (Str "abc") : Maybe Parse.AST

    > Maybe.andThen (getItem 1) ast
    Just (Num 2) : Maybe Parse.AST

-}
getItem : Int -> AST -> Maybe AST
getItem k ast =
    case ast of
        LIST list ->
            List.Extra.getAt k list

        _ ->
            Nothing


{-|

    > ast = parse "(1 2 3)"
    Just (LIST [Num 1,Num 2,Num 3])
        : Maybe Parse.AST

    > Maybe.andThen unwrapList ast
    Just [Num 1,Num 2,Num 3]

-}
unwrapList : AST -> Maybe (List AST)
unwrapList ast =
    case ast of
        LIST list ->
            Just list

        _ ->
            Nothing
