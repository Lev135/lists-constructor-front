module Main exposing (..)

import Browser
import Html exposing(..)

import MTask

view : MTask.Form -> Browser.Document MTask.Msg
view model = {
    title = "",
    body = [MTask.view model]  -- div [] <|  List.map viewRainBowEl rainbow
  }
  
main =
    Browser.document
        { view = view
        , update = MTask.update
        , init = MTask.init
        , subscriptions = \_ -> Sub.none
        }
