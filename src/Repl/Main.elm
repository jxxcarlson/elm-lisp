port module Repl.Main exposing (main)

import Cmd.Extra exposing (withCmd, withNoCmd)
import Json.Decode as D
import Json.Encode as E
import List.Extra
import Platform exposing (Program)
import Repl.Lisp as Blackbox


port get : (String -> msg) -> Sub msg


port put : String -> Cmd msg



--
-- port sendFileName : E.Value -> Cmd msg
--
--
-- port receiveData : (E.Value -> msg) -> Sub msg


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { residualCommand : String }


type Msg
    = Input String


type alias Flags =
    ()


init : () -> ( Model, Cmd Msg )
init _ =
    { residualCommand = "" } |> withNoCmd


subscriptions : Model -> Sub Msg
subscriptions _ =
    get Input


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input input ->
            case input == "" of
                True ->
                    model |> withNoCmd

                False ->
                    processCommand { model | residualCommand = getResidualCmd input } input


processCommand : Model -> String -> ( Model, Cmd Msg )
processCommand model cmdString =
    let
        args =
            String.split " " cmdString
                |> List.map String.trim
                |> List.filter (\item -> item /= "")

        cmd =
            List.head args

        arg =
            List.Extra.getAt 1 args
                |> Maybe.withDefault ""
    in
    case cmd of
        Just ":help" ->
            model |> withCmd (put Blackbox.helpText)

        _ ->
            model |> withCmd (put <| Blackbox.transform (removeComments cmdString))



-- HELPERS


{-| This is used in the context

:get FILENAME xxx yyy zzz

in which xxx yyy zzzz is the command to be
applied to the contents of FILENAME once
it is received.

-}
getResidualCmd : String -> String
getResidualCmd input =
    let
        args =
            input
                |> String.split " "
                |> List.filter (\s -> s /= "")
    in
    args
        |> List.drop 2
        |> String.join " "


removeComments : String -> String
removeComments input =
    input
        |> String.lines
        |> List.filter (\line -> String.left 1 line /= "#")
        |> String.join "\n"
        |> String.trim
