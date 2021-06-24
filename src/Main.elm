port module Main exposing (..)

import Html.Styled exposing (toUnstyled)
import Browser
import Html exposing(..)

import Task.Create

documentView : (model -> Html msg) -> model -> Browser.Document msg
documentView view model = {
    title = "",
    body = [view model]
  }

main : Program () Task.Create.Model Task.Create.Msg
main =
    Browser.document
        { view = documentView <| Task.Create.view >> toUnstyled
        , update = Task.Create.update
        , init = \_ -> (Task.Create.init Task.Create.defaultSettings sendMsg msgReceiver, Cmd.none)
        , subscriptions = Task.Create.subscriptions
        }

-- PORTS

port sendMsg : String -> Cmd msg
port msgReceiver : (String -> msg) -> Sub msg
