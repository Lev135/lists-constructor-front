module Main exposing (..)

import Html.Styled exposing (toUnstyled)
import Browser
import Html exposing(..)

import MTask
import LatexEditor

viewL : LatexEditor.Model -> Browser.Document LatexEditor.Msg
viewL model = {
    title = "",
    body = [toUnstyled <| LatexEditor.view model]
  }

view : MTask.Form -> Browser.Document MTask.Msg
view model = {
    title = "",
    body = [MTask.view model]  -- div [] <|  List.map viewRainBowEl rainbow
  }
  
main =
    Browser.document
        { view = viewL
        , update = LatexEditor.update
        , init = LatexEditor.init "ID"
        , subscriptions = LatexEditor.subscriptions
        }
